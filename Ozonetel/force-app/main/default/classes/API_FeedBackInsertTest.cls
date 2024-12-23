@isTest
public class API_FeedBackInsertTest
{
    
    public static testMethod void ChatSuccessTest()
    {
        Test.startTest();
        Live_Chat_Monitor__c chatMontr = new Live_Chat_Monitor__c();
        chatMontr.rating__c ='';
        chatMontr.Chat_Session_Key__c='bf8e65bb-0648-4ba8-8e72-96fe15050d87';
        chatMontr.channel__c='Web';
        insert chatMontr;
        Live_Chat_Monitor__c chatmonObj=[SELECT id,Chat_Session_Key__c,rating__c,Channel__c,Submited_DateTime__c FROM Live_Chat_Monitor__c where id=:chatMontr.id];
        string jsonBody='{"casenumber":"","Rating":"good","Channel":"Web","chatsessionId":"'+chatmonObj.Chat_Session_Key__c+'"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        Test.stopTest();
    }
    
    public static testMethod void caseSuccessTest()
    {
        Test.startTest();
        Case c=new Case();
        c.status='closed';   
        insert c;  
        case csseList=[select id,casenumber,status from case where id =:c.id];
        string jsonBody='{"casenumber":"'+csseList.casenumber+'","Rating":"good","Channel":"web","chatsessionId":" "}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        Test.stopTest();
    }
    public static testMethod void ratingEmpty(){
        Test.startTest();
        string jsonBody='{"casenumber":"","Rating":"good","Channel":"web","chatsessionId":" "}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        Test.stopTest();
    }
    public static testMethod void ratingIsEmpty(){
        Test.startTest();
        string jsonBody='{"casenumber":"1245677","Rating":"","Channel":"web","chatsessionId":"97434567323456 "}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        Test.stopTest();
    }
    public static testMethod void ratingIsnotEmpty(){
        Test.startTest();
        string jsonBody='{"casenumber":"1245677","Rating":"good","Channel":"web","chatsessionId":"97434567323456 "}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        Test.stopTest();
    }
    public static testMethod void reasonIsnotEmpty(){
        Test.startTest();
        string jsonBody='{"casenumber":"1245677","Rating":"good","reason":"good","Channel":"web","chatsessionId":"97434567323456 "}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        case cs = new case();
        cs.status='Closed';
        insert cs;
        jsonBody='{"casenumber":"'+cs.casenumber+'","Rating":"good","reason":"good","Channel":"web","chatsessionId":""}';
        req = new RestRequest(); 
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        jsonBody='{"casenumber":"","Rating":"good","reason":"good","Channel":"web","chatsessionId":""}';
        req = new RestRequest(); 
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        
        Live_Chat_Monitor__c chatMontr = new Live_Chat_Monitor__c();
        chatMontr.rating__c ='';
        chatMontr.Chat_Session_Key__c='123';
        chatMontr.channel__c='Web';
        chatMontr.Feedback_Details__c ='[{"channel":"Web","rating":"Good","reason":"Test","submiteddate":"'+system.now()+'"}]';
      	insert chatMontr;
        
        jsonBody='{"casenumber":"","Rating":"good","reason":"good","Channel":"Web","chatsessionId":"123"}';
        req = new RestRequest(); 
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        
        Test.stopTest();
    }
    public static testMethod void reasonIsnotEmpty2(){
        Test.startTest();
        string jsonBody='{"casenumber":"1245677","Rating":"good","reason":"good","Channel":"web","chatsessionId":"97434567323456 "}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
		case cs = new case();
        cs.status='Closed';
        insert cs;
        jsonBody='{"casenumber":"'+cs.casenumber+'","Rating":"good","reason":"good","Channel":"web","chatsessionId":""}';
        req = new RestRequest(); 
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        jsonBody='{"casenumber":"","Rating":"good","reason":"good","Channel":"web","chatsessionId":""}';
        req = new RestRequest(); 
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        
        Live_Chat_Monitor__c chatMontr = new Live_Chat_Monitor__c();
        chatMontr.rating__c ='';
        chatMontr.Chat_Session_Key__c='123';
        chatMontr.channel__c='Web';
      	insert chatMontr;
        jsonBody='{"casenumber":"","Rating":"good","reason":"good","Channel":"Web","chatsessionId":"123"}';
        req = new RestRequest(); 
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
        case cse = new case();
        cse.status='Closed';
        insert cse;
        system.debug('<<<<casenumber'+cse.CaseNumber);
		case cs1 = [select casenumber from case where id =: cse.id ];
        system.debug('cs1.csnum'+cs1.CaseNumber);
        Case_Feedback__c cfb = new Case_Feedback__c();
        cfb.Case_Name__c= cs1.id;
        cfb.Channel__c='Web';
        insert cfb;
        jsonBody='{"casenumber":"'+cs1.casenumber+'","Rating":"good","reason":"good","Channel":"web","chatsessionId":""}';       
        req = new RestRequest(); 
        req.requestURI = '/services/apexrest/redBus/FeedBackInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_FeedBackInsert.feedbackdetails();
 
        Test.stopTest();
    }
}