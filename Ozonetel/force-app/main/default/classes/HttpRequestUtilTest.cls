@isTest
private class HttpRequestUtilTest{
    @isTest static void testMethod1(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateHeaders(req);
    }
    
     @isTest static void testMethod2(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Default_Currency__c='INR';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        req = HttpRequestUtil.populateCMAPIHeaders(req,'REDBUS_IN');
    }
    
     @isTest static void testMethod3(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateCAPICountryHeaders(req,'REDBUS_IN','India');
    }
     @isTest static void testMethod4(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateCAPIHeaders(req);
    }
     @isTest static void testMethod5(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateBusHireHeaders(req);
    }
    
     @isTest static void testMethod6(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateAckoInsuranceHeaders(req);
    }
    
     @isTest static void testMethod7(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateDisbursalHeaders(req);
    }
    
     @isTest static void testMethod8(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populatePassUpdatePGTxnIdHeaders(req);
    }
    
     @isTest static void testMethod9(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateRailPNRHeaders(req);
    }
    
     @isTest static void testMethod10(){
        
        HttpRequestUtil.prepareSMSReqData('test','test','test','test','test','test',false,'test',false);
        HttpRequestUtil.prepareEmailReqData('test','test','test','test','test','test','test','test','test','test',false);
        HttpRequestUtil.prepareSMSRequest('test','test','test','test','test','test',false);
        HttpRequestUtil.prepareEmailRequest('test','test','test','test','test','test','test','test','test');
        HttpRequestUtil.prepareWhatsappRequest('test','test',1,'test','test','test');
    }
}