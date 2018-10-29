class TicketStruct {
    
    //MARK: Properties
    
    var name: String
    var key: String
    var amount: String
    //MARK: Initialization
    
    init?(itemName: String, price: String, amountID: String) {
        name = itemName
        key = price
        amount = amountID
        
    }
}

