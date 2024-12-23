/**
*
* Name           : RescheduleBreakUpController 
* Created Date   : 14 Aug 2017
* Created By     : Veeramanikanta
* Purpose        : Display Reschedule BreakUp
*
**/
public class RescheduleBreakUpController {
    public List<RefundBreakUpWrapper> rbResponse{get;set;}
    public string orderId;
    public RescheduleBreakUpController (){
        orderId= ApexPages.currentPage().getParameters().get('orderId');       
        showBreakUp();
    }
    
    public void showBreakUp(){
        rbResponse=new List<RefundBreakUpWrapper>();
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Reschedule_Breakup'];
        
        HttpResponse res = new HttpResponse();        
        Http http = new Http();        
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        String tinNum = ApexPages.currentPage().getParameters().get('tin');       
        req.setEndpoint(APIMData.Endpoint__c+orderId);
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
        req.setHeader('BusinessUnit', 'BUS');
        req.setHeader('Country_Name', 'INTL');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        res = http.send(req);
        system.debug('json-->'+res.getbody());
        
        string jsonString='[{"Type":"Total_Fare","DisplayName":"Total Fare","Value":{"currencyType":"IDR","amount":237500}},{"Type":"OFFERS","DisplayName":"Offers Used","Value":{"currencyType":"IDR","amount":237500}},{"Type":"Reschedule Charges","DisplayName":"Reschedule Charges","Value":{"currencyType":"IDR","amount":20000}},{"Type":"Reschedule Amount","DisplayName":"Amount available for booking","Value":{"currencyType":"IDR","amount":-7500}}]';
        rbResponse=(List<RefundBreakUpWrapper>)JSON.deserialize(res.getbody(),List<RefundBreakUpWrapper>.class);
        System.debug('rb-->'+rbResponse);    
    }
      
    public class RefundBreakUpWrapper{
        public string Type{get;set;}
        public String DisplayName{get;set;}
        public string pgType{get;set;}
        public Money Value{get;set;}
        
    }
    public class Money{
        public string currencyType{get;set;}
        public decimal amount{get;set;}
    }
    
}