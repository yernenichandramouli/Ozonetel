@isTest
public class SelfHelplinkControllerTest {  
    @isTest
    public static void testgetSelfHelp(){
        Case c=new Case();
        c.SS_Route_Id__c='8404193';
        c.origin='Chat';
        c.Order_UUId__c='123456789';
        c.Country__c='India';
        c.Transaction_UUID__c='123456789';
        c.Issue_Sub_Category__c='test';
        c.Issue_Type__c='Bus Operator Service';         
        insert c;  
        
        test.startTest();       
        ApexPages.StandardController con = new ApexPages.StandardController(c);
        string json='{"status_code":200,"data":{"url":"teste","short":"wcodtai"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, '', json));
        SelfHelplinkController.GetSelfHelpLink(c.id);
        test.stopTest();
        
    }
    
    
}