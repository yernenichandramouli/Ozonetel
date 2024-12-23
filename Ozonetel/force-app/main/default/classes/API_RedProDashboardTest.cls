@isTest
public class API_RedProDashboardTest
{
    
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='9491322718',Business_Unit__c='REDBUS_ID'));
        } 
        insert orderList ;
        
    }
    /*
Name:SuccessTest
Description: Used to test API functionality with Success response(returns records)
*/
    public static testMethod void SuccessTest()
    {
        Test.startTest();
        
        list<Order_Items__c> ol=[select id,name,email__c,Business_Unit__c,Mobile__c,Service_Provider_Info__c,Service_Provider_Id__c from Order_Items__c limit 1]; 
        Service_Provider__c sp=new Service_Provider__c();
        sp.Location__c='Karnataka';
        sp.Operator_Id__c='3538';
        insert sp;
        ol[0].Service_Provider_Info__c=sp.id;
        ol[0].Service_Provider_Id__c='3538';
        update ol;
        Case c=new Case();
        c.Transaction_ID__c=ol[0].id;
        c.SS_Route_Id__c='8404193';       
        c.Issue_Type__c='Bus Operator Service';   
        c.Issue_Sub_Category__c='I was not allowed to board the bus'; 
        c.Phone_No_ct__c='9491322718';
        c.BO_Agreed_RB__c='agree';
        c.BO_Action__c=1;
        c.BO_Email__c = 'sudarshan.vr@gmail.com';
        c.BO_Email1__c = 'sudarshan.vr@gmail.com';
        c.BD_Email1__c = 'sudarshan.vr@gmail.com';
        c.BD_Email__c = 'sudarshan.vr@gmail.com';
        
        
        insert c;  
        case cs=[select id,Service_Provider_Id__c from case where id=:c.id];
        System.debug('c->'+c.Service_Provider_Id__c+'--c to->'+c );
        casecomment cc=new casecomment();
        cc.CommentBody='STC--> Test';
        cc.ParentId=c.id;
        insert cc;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/redProdDashboard?boId=23';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.addHeader('channel', 'RB+');
        req.addParameter('boId', '3538');
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_RedProDashboard.getDashboardDetails();
        
        Test.stopTest();
    }    
    public static testMethod void SuccessTest2()
    {
        Test.startTest();
        
        list<Order_Items__c> ol=[select id,name,email__c,Business_Unit__c,Mobile__c,Service_Provider_Info__c,Service_Provider_Id__c from Order_Items__c limit 1]; 
        Service_Provider__c sp=new Service_Provider__c();
        sp.Location__c='Karnataka';
        sp.Operator_Id__c='3538';
        insert sp;
        ol[0].Service_Provider_Info__c=sp.id;
        ol[0].Service_Provider_Id__c='3538';
        update ol;
        Case c=new Case();
        c.Transaction_ID__c=ol[0].id;
        c.SS_Route_Id__c='8404193';       
        c.Issue_Type__c='Bus Operator Service';   
        c.Issue_Sub_Category__c='I was not allowed to board the bus'; 
        c.Phone_No_ct__c='9491322718';
        c.BO_Agreed_RB__c='disagree';
        c.BO_Action__c=1;
        c.BO_Email__c = 'sudarshan.vr@gmail.com';
        c.BO_Email1__c = 'sudarshan.vr@gmail.com';
        c.BD_Email1__c = 'sudarshan.vr@gmail.com';
        c.BD_Email__c = 'sudarshan.vr@gmail.com';
        
        
        
        insert c;  
        case cs=[select id,Service_Provider_Id__c from case where id=:c.id];
        System.debug('c->'+c.Service_Provider_Id__c+'--c to->'+c );
        casecomment cc=new casecomment();
        cc.CommentBody='STC--> Test';
        cc.ParentId=c.id;
        insert cc;
        cs.Status='Closed';
        update cs;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/redProdDashboard?boId=23';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.addHeader('channel', 'RB+');
        req.addParameter('boId', '3538');
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_RedProDashboard.getDashboardDetails();
        
        Test.stopTest();
    }    
}