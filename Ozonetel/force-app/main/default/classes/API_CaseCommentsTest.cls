/**
* Name           : API_CaseCommentsTest
* Created Date   : 17 May 2017
* Created By     : Veeramanikanta R
* Purpose        : Testing API functionality for API_CaseComments
**/

@isTest
public class API_CaseCommentsTest
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
        
        Case c=new Case();
        c.SS_Route_Id__c='8404193';       
        c.Issue_Type__c='Bus Operator Service';    
        c.Phone_No_ct__c='9491322718';     
        insert c;  
        casecomment cc=new casecomment();
        cc.CommentBody='(STC) Test';
        cc.ParentId=c.id;
        insert cc;
        
        //  string jsonBody='[{"subIssueType":null,"issueType":null,"caseNumber":"375704","caseComments":["Hello BD Team, Can you please check this case","Test 2nd CaseComment"]},{"subIssueType":"I am unable to create/use wallet account","issueType":"Wallet","caseNumber":"375712","caseComments":["Comment for 375712"]}]';
        string jsonBody='[{"tin":"TM7B94395035","ticketAmount":"INR 132","subIssueType":null,"status":"Open","source":"Jamnagar","notes":null,"lastModifiedTime":"2018-06-26 17:06:32","issueType":"DBT","doj":"2018-07-22 23:45:00","destination":"Rajkot","description":"DBT payment","createdDateTime":"2018-06-05 17:08:18","caseNumber":"2504648","caseComment":[{"createdTime":"2018-06-26 17:06:31","comment":" Hello show to customer"},{"createdTime":"2018-06-11 13:24:39","comment":" Test Comment"}]}]';  
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseComments.getCaseComments();
        
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
        c.Phone_No_ct__c='9491322718';
       
        
        insert c;  
        case cs=[select id,Service_Provider_Id__c from case where id=:c.id];
        System.debug('c->'+c.Service_Provider_Id__c+'--c to->'+c );
        casecomment cc=new casecomment();
        cc.CommentBody='STC--> Test';
        cc.ParentId=c.id;
        insert cc;
        
        //  string jsonBody='[{"subIssueType":null,"issueType":null,"caseNumber":"375704","caseComments":["Hello BD Team, Can you please check this case","Test 2nd CaseComment"]},{"subIssueType":"I am unable to create/use wallet account","issueType":"Wallet","caseNumber":"375712","caseComments":["Comment for 375712"]}]';
        //  string jsonBody='[{"tin":"TM7B94395035","ticketAmount":"INR 132","subIssueType":null,"status":"Open","source":"Jamnagar","notes":null,"lastModifiedTime":"2018-06-26 17:06:32","issueType":"DBT","doj":"2018-07-22 23:45:00","destination":"Rajkot","description":"DBT payment","createdDateTime":"2018-06-05 17:08:18","caseNumber":"2504648","caseComment":[{"createdTime":"2018-06-26 17:06:31","comment":" Hello show to customer"},{"createdTime":"2018-06-11 13:24:39","comment":" Test Comment"}]}]';  
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI ='https://cs13.salesforce.com/services/apexrest/redBus/CaseComments?boId=3538&country=India';
        req.httpMethod = 'GET';//HTTP Request Type
        req.addParameter('boId', '3538');
        req.addHeader('channel', 'RB+');
        RestContext.request = req;
        //  RestContext.response= res;        
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseComments.getCaseComments();
        
        Test.stopTest();
    }
}