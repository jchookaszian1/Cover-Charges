class ReceiptStruct {
    
    //MARK: Properties
    
    var name: String
    var key: String
    var date: Int
    //MARK: Initialization
    
    init?(barName: String, receiptID: String, dateID: Int) {
        name = barName
        key = receiptID
        date = dateID
        
    }
}
