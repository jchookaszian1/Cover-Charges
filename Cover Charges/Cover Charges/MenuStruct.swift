class MenuStruct {
    
    //MARK: Properties
    
    var name: String
    var amount: String
    //MARK: Initialization
    
    init?(itemName: String, amountInput: String) {
        name = itemName
        amount = amountInput
        
    }
}
