public class ActivityOtherItemsExtension {    
    public string recId;
    public List<Activities__c> accList{get;set;}
    public string paymentItemsResponse;
    public string custPriceBreakupResp;
    public List<PriceBreakupWrapper> priceBreakup{get;set;}
    public PaymentItemsWrapper payWrapper{get;set;}   
    public ActivityOtherItemsExtension(ApexPages.StandardController controller) {
        accList=new List<Activities__c>();
        recId= ApexPages.currentPage().getParameters().get('id');
        accList=[select id,Service_Provider_Details__c,Payment_Details__c,Sub_Order_Items__c,Customer_Price_Breakup__c from Activities__c where id=:recId];        
        if(!accList.isEmpty()){
            paymentItemsResponse=accList[0].Payment_Details__c;
            custPriceBreakupResp=accList[0].Customer_Price_Breakup__c;
            getDetails();
        }
    }    
    public void getDetails(){
        priceBreakup=new List<PriceBreakupWrapper>();
        payWrapper=new PaymentItemsWrapper();                
        string jsonGH='[ { "name": "NA", "isPartiallyCancellable": true, "customerPriceBreakUp": [ { "value": 1500, "type": null, "refundableValue": 1500, "isCancellationPolicyApplicable": true, "componentName": "BASIC_FARE" }, { "value": 100, "type": null, "refundableValue": 100, "isCancellationPolicyApplicable": true, "componentName": "COMMISSION" }, { "value": 50, "type": null, "refundableValue": 50, "isCancellationPolicyApplicable": true, "componentName": "COMMISSION_SGST" }, { "value": 50, "type": null, "refundableValue": 50, "isCancellationPolicyApplicable": true, "componentName": "COMMISSION_CGST" }, { "value": 50, "type": null, "refundableValue": 50, "isCancellationPolicyApplicable": true, "componentName": "COMMISSION_IGST" } ] } ]';        
        //  custPriceBreakupResp = custPriceBreakupResp.replaceAll('\\\\', '');
        string newJsonP='[{"value":16.2064,"type":null,"refundableValue":16.2064,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"},{"value":1.52,"type":null,"refundableValue":1.52,"isCancellationPolicyApplicable":true,"componentName":"COMMISSION"},{"value":0.0,"type":null,"refundableValue":0.0,"isCancellationPolicyApplicable":true,"componentName":"COMMISSION_SGST"},{"value":0.0,"type":null,"refundableValue":0.0,"isCancellationPolicyApplicable":true,"componentName":"COMMISSION_CGST"},{"value":0.2736,"type":null,"refundableValue":0.2736,"isCancellationPolicyApplicable":true,"componentName":"COMMISSION_IGST"}]';
        priceBreakup= (List<PriceBreakupWrapper>)JSON.deserialize(custPriceBreakupResp, List<PriceBreakupWrapper>.class);                
        string jsonPaymentItems='{ "uuid": "81c357668301f0058fc8999901010100", "id": "12411339030575921", "amountPaid": { "currencyType": "INR", "amount": 350 }, "amountReceivable": { "currencyType": "INR", "amount": 0 }, "paymentItemList": [ { "uuid": "8399b6818301f005a3a7d0da01030100", "id": "12411339277186057", "refunds": [ { "refundType": "ONLINE", "refundTime": "1551417502955609", "refundStatus": "REFUND_CREATED", "refundAmount": { "currencyType": "INR", "amount": 1400 }, "refNo": null, "order_item_uuid": "81d1e56a8301f0058fc8999901020100", "orderItemId": null, "channel": "OMS" } ], "orderId": "12411339030575921", "businessUnitValue": { "currencyType": "INR", "amount": 1750 }, "paymentItemValue": { "currencyType": "INR", "amount": 1750 }, "paymentStatus": "COMPLETED", "paymentSessionId": "12411339030575921", "paymentSystem": "ONLINE", "paymentSystemRefNo": "8399b6818301f005a3a7d0da01030100", "updatedBy": null, "creationTime": "2019-03-01T05:16:49", "bankName": "SBICARD", "cardNo": "1234567890123456", "pgType": "CreditCard", "pgName": "TESTPAY", "_meta": null, "bank_ref_num": null, "bankAccountNumber": null, "accountHolderName": null } ], "orderId": "12411339030575921", "orderValue": { "currencyType": "INR", "amount": 350 }, "businessUnit": "REDBUS_IN", "creationTime": "2019-03-01T05:16:18" }';        
        payWrapper=(PaymentItemsWrapper)JSON.deserialize(paymentItemsResponse, PaymentItemsWrapper.class);   
        System.debug('payWrapper->'+payWrapper);
    }    
    public class PriceBreakupWrapper{       
        public string value{get;set;}             
        public string type{get;set;}
        public string refundableValue{get;set;}
        public string componentName{get;set;}
        public string isCancellationPolicyApplicable{get;set;}
    }
    public class PaymentItemsWrapper{        
        public string uuid{get;set;}
        public amountPaid_wrapper amountPaid{get;set;}
        public amountReceivable_wrapper amountReceivable{get;set;}
        public List<paymentItemList> paymentItemList{get;set;}        
    }
    public class amountPaid_wrapper{
        public string currencyType{get;set;}
        public string amount{get;set;}
    }
    public class amountReceivable_wrapper{
        public string currencyType{get;set;}
        public string amount{get;set;}
    }
    public class paymentItemList{
        public string uuId{get;set;}
        public string id{get;set;}
        public list<refundsClass> refunds{get;set;}
        public string paymentStatus{get;set;}
        public string paymentSystem{get;set;}
        public string paymentSystemRefNo{get;set;}
        public string  paymentSessionId{get;set;}
        public string creationTime{get;set;}
        public string bankName{get;set;}
        public string cardNo{get;set;}
        public string pgType{get;set;}
        public string pgName{get;set;}
        public string bank_ref_num{get;set;}
        public string bankAccountNumber{get;set;}
        public string accountHolderName{get;set;}
        public paymentItemValueWrapper paymentItemValue{get;set;}
    }
    public class paymentItemValueWrapper{
        public string currencyType{get;set;}
        public string amount{get;set;}
    }
    public class refundsClass{
        public string refundType{get;set;}
        public string refundTime{get;set;}
        public string refundStatus{get;set;}
        public string refNo{get;set;}
        public string order_item_uuid{get;set;}
        public string orderItemId{get;set;}
        public string channel{get;set;}
        public refundAmount_wrapper refundAmount{get;set;}
    }    
    public class refundAmount_wrapper{
        public string currencyType{get;set;}
        public string amount{get;set;}        
    }     
}