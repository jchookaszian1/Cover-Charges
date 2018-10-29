/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

const functions = require('firebase-functions'),
      admin = require('firebase-admin')
const secureCompare = require('secure-compare');
admin.initializeApp();

const stripe = require('stripe')(functions.config().stripe.token),
      currency = functions.config().stripe.currency || 'USD';

// [START chargecustomer]
// Charge the Stripe customer whenever an amount is written to the Realtime database
exports.createStripeCharge = functions.database.ref('/stripe_customers/{userId}/charges/{id}').onWrite((change,context) => {
    const val = change.after.val();
    // This onWrite will trigger whenever anything is written to the path, so
    // noop if the charge was deleted, errored out, or the Stripe API returned a result (id exists)
    if (val === null || val.id || val.error) return null;
    // Look up the Stripe customer id written in createStripeCustomer
    return admin.database().ref(`/stripe_customers/${context.params.userId}/customer_id`).once('value').then(snapshot => {
        return snapshot.val();
    }).then(customer => {
        // Create a charge using the pushId as the idempotency key, protecting against double charges
        const amount = val.amount;
        const dest = val.destination;
        const barCharge = val.barPrice;
        const idempotency_key = context.params.id;
        let charge = {amount, currency, customer, destination:{account:dest,amount:barCharge}};
        if (val.source !== null) charge.source = val.source;
        return stripe.charges.create(charge, {idempotency_key});
    }).then(response => {
        // If the result is successful, write it back to the database
        return context.data.ref.set(response);
    }, error => {
        // We want to capture errors and render them in a user-friendly way, while
        // still logging an exception with Stackdriver
        return context.data.ref.child('error').set(userFacingMessage(error)).then(() => {
            return reportError(error, {user: context.params.userId});
        });
    }
           );
});
// [END chargecustomer]]
exports.createStripeCustomAccount = functions.database.ref('stripe_bar_users/{userId}/type').onWrite((change,context) => {
    return admin.database().ref(`/stripe_bar_users/${context.params.userId}/`).once('value').then(snapshot => {
        return snapshot.val();
    }).then(val => {


        return stripe.accounts.create({
            country: "US",
            type: "custom",
            external_account: {
                object: "bank_account",
                account_number: val.external_account.account_number,
                routing_number: val.external_account.routing_number,
                currency: val.external_account.currency,
                country: val.external_account.country
            },
            legal_entity: {
                address: {
                    city: val.legal_entity.address.city,
                    line1: val.legal_entity.address.line1,
                    postal_code: val.legal_entity.address.postal_code,
                    state: val.legal_entity.address.state
                },
                business_name: val.legal_entity.business_name,
                business_tax_id: val.legal_entity.business_tax_id,
                dob: {
                    day: val.legal_entity.dob.day,
                    month: val.legal_entity.dob.month,
                    year: val.legal_entity.dob.year
                },
                first_name: val.legal_entity.first_name,
                last_name: val.legal_entity.last_name,
                ssn_last_4: val.legal_entity.ssn_last_4,
                type: val.legal_entity.type
            },
            tos_acceptance: {
                date: val.tos_acceptance.date,
                ip: val.tos_acceptance.ip
            }

        })}).then(acct => {
        change.after.ref.parent.child('external_account').set(null)
        change.after.ref.parent.child('legal_entity').set(null)
        change.after.ref.parent.child('tos_acceptance').set(null)
        return change.after.ref.parent.child('acc_id').set(acct.id);
    });


})
exports.organizeWallets = functions.database.ref('stripe_customers/{userId}/receipts/wallet/{ticketId}/isExpired').onUpdate((change,context) => {
    const source = change.after.val()
    if(source === true)
        {
            var oldRef = admin.database().ref(`/stripe_customers/${context.params.userId}/receipts/wallet/${context.params.ticketId}`)
            var newRef = admin.database().ref(`/stripe_customers/${context.params.userId}/receipts/history/${context.params.ticketId}`)
            moveFbRecord(oldRef,newRef)
        }
    return 0
})
function moveFbRecord(oldRef, newRef) {
     oldRef.once('value', function(snap)  {
          newRef.set( snap.val(), function(error) {
               if( !error ) {  oldRef.remove(); }
               else if( typeof(console) !== 'undefined' && console.error ) {  console.error(error); }
          });
     });
}

exports.getStripeBalance =
    functions.https.onRequest((req, res) =>  {
    const key = req.query.key;

    // Exit if the keys don't match
    if (!secureCompare(key, functions.config().cron.key)) {
        console.log('The key provided in the request does not match the key set in the environment. Check that', key,
                    'matches the cron.key attribute in `firebase env:get`');
        res.status(403).send('Security key does not match. Make sure your "key" URL query parameter matches the ' +
                             'cron.key environment variable.');
        return;
    }
    admin.database().ref(`/stripe_bar_users/`).once('value').then(snapshot => {
        snapshot.forEach(function(childSnapshot) {
            var storage = childSnapshot.child("acc_id").val();
                stripe.balance.retrieve({stripe_account: storage}, function(error, balance) {
                    if(error != null)
                    {
                        admin.database().ref('/stripe_bar_users/' + childSnapshot.key).set(error);
                    }
                    else
                    {
                        admin.database().ref('/stripe_bar_users/' + childSnapshot.key + '/balance').set(balance.available[0].amount)
                    }
                })

        });
    })
    res.send("User data refreshed.");

});
exports.getDailyData = functions.https.onRequest((req, res) => {
    //create database ref
    var dbRef = admin.database().ref('/stripe_bar_users');
    //do a bunch of stuff

    //send back response
    res.redirect(200);
});
// When a user is created, register them with Stripe
exports.createStripeCustomer = functions.auth.user().onCreate((user) => {
  return stripe.customers.create({
    email: user.email,
  }).then((customer) => {
    return admin.database().ref(`/stripe_customers/${user.uid}/customer_id`).set(customer.id);
  });
});

exports.deletePaymentSource = functions.database.ref('/stripe_customers/{userId}/sources').onDelete((snap, context) => {
  const deletedData = (snap.val());
  for (var first in deletedData) break;

  console.log(deletedData)
  console.log(first)
  console.log(deletedData[first])
  return admin.database().ref(`/stripe_customers/${context.params.userId}/customer_id`).once('value').then(snapshot => {
      return snapshot.val();
  }).then(customer => {
      return stripe.customers.deleteCard(customer,deletedData[first].id)
    })
})

// Add a payment source (card) for a user by writing a stripe payment source token to Realtime database
exports.addPaymentSource = functions.database.ref('/stripe_customers/{userId}/sources/{pushId}/token').onWrite((change,context) => {
    const source = change.after.val();
    if (source === null) return null;
    return admin.database().ref(`/stripe_customers/${context.params.userId}/customer_id`).once('value').then(snapshot => {
        return snapshot.val();
    }).then(customer => {
        return stripe.customers.createSource(customer, {source});
    }).then(response => {
        return change.after.ref.parent.set(response);
    }, error => {
        return change.after.ref.parent.child('error').set(userFacingMessage(error)).then(() => {
            return reportError(error, {user: context.params.userId});
        });
    });
});

// When a user deletes their account, clean up after them
exports.cleanupUser = functions.auth.user().onDelete((user) => {
  return admin.database().ref(`/stripe_customers/${user.uid}`).once('value').then(
      (snapshot) => {
        return snapshot.val();
      }).then((customer) => {
        return stripe.customers.del(customer.customer_id);
      }).then(() => {
        return admin.database().ref(`/stripe_customers/${user.uid}`).remove();
      });
    });

// To keep on top of errors, we should raise a verbose error report with Stackdriver rather
// than simply relying on console.error. This will calculate users affected + send you email
// alerts, if you've opted into receiving them.
// [START reporterror]
function reportError(err, context = {}) {
  // This is the name of the StackDriver log stream that will receive the log
  // entry. This name can be any valid log stream name, but must contain "err"
  // in order for the error to be picked up by StackDriver Error Reporting.
  const logName = 'errors';
  const log = logging.log(logName);

  // https://cloud.google.com/logging/docs/api/ref_v2beta1/rest/v2beta1/MonitoredResource
  const metadata = {
    resource: {
      type: 'cloud_function',
      labels: {function_name: process.env.FUNCTION_NAME},
    },
  };

  // https://cloud.google.com/error-reporting/reference/rest/v1beta1/Errorcontext
  const errorcontext = {
    message: err.stack,
    serviceContext: {
      service: process.env.FUNCTION_NAME,
      resourceType: 'cloud_function',
    },
    context: context,
  };

  // Write the error log entry
  return new Promise((resolve, reject) => {
    log.write(log.entry(metadata, errorcontext), (error) => {
      if (error) {
       return reject(error);
      }
      return resolve();
    });
  });
}
// [END reporterror]

// Sanitize the error message for the user
function userFacingMessage(error) {
  return error.type ? error.message : 'An error occurred, developers have been alerted';
}
