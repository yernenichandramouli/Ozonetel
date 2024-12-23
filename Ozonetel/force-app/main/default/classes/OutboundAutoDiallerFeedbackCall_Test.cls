@isTest
public class OutboundAutoDiallerFeedbackCall_Test
{
    
    @testsetup
    static void createFeedback(){
        List<OutBound_Feedback_Calling__c> orderFdbcList = new List<OutBound_Feedback_Calling__c>();        
        for(Integer i = 0 ; i<200 ; i++) {
            orderFdbcList.add(new OutBound_Feedback_Calling__c(BO_Name__c='test',doj__c='12-11-2022 12:40:00',Source__c='bangalore',Destination__c='Hyderabad',IVR_status__c='fail',Dialled_Count__c=1,Call_Unique_Id__c ='FBC23456789',Phone_No__c='123456789',OrderItem_Uuid__c='09491322718',TIN_no__c='TN345678',Call_Disposition_Status__c='Open'));
        } 
        insert orderFdbcList ;
    }
    
    
    Static testMethod void fdbckCallTest()
    {
        
        user  usr=[select id,username from user where id=:userInfo.getuserid()];
        
        list<OutBound_Feedback_Calling__c> fb=[select id from OutBound_Feedback_Calling__c];
        
        Test.startTest();
        string json='{"result":"SUCCESS","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        string tst=OutboundAutoDiallerFeedbackCalling.callToCustomer(fb[0].id);
        
        Test.stopTest();
    }
    Static testMethod void bushireErrorTest()
    {
        Test.startTest();
        list<OutBound_Feedback_Calling__c> fb=[select id from OutBound_Feedback_Calling__c];
        
        string json='{"result":"error","IsEmailSent":false,"status":"error","IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        string fbtst=OutboundAutoDiallerFeedbackCalling.callToCustomer(fb[0].id);
        Test.stopTest();
    }
    
    Static testMethod void ErrorTest()
    {
        Test.startTest();
        
        string json='{"result":"test","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(205, 'OK', json));
        string fbtst=OutboundAutoDiallerFeedbackCalling.callToCustomer('test');
        list<OutBound_Feedback_Calling__c> fbst =OutboundAutoDiallerFeedbackCalling.getDetails();
        
        Test.stopTest();
    }
    
    Static testMethod void failErrorTest()
    {
        Test.startTest();
        list<OutBound_Feedback_Calling__c> fb=[select id from OutBound_Feedback_Calling__c];
        
        string json='{"result":"error","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        string fbtst=OutboundAutoDiallerFeedbackCalling.callToCustomer(fb[0].id);
        Test.stopTest();
    }
    Static testMethod void failTest()
    {
        Test.startTest();
        list<OutBound_Feedback_Calling__c> fb=[select id from OutBound_Feedback_Calling__c];
        
        string json='';
        ///'{"result":"error","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        string fbtst=OutboundAutoDiallerFeedbackCalling.callToCustomer(fb[0].id);
        Test.stopTest();
    }
    
     Static testMethod void feedbckLink()
    {
        Test.startTest();
        list<OutBound_Feedback_Calling__c> fb=[select id from OutBound_Feedback_Calling__c];
        
        string json='{"status_code":200,"data":{"url":"https:www.redbus.idRefund?orderId=Op7Oao9gae2OIVF x81kbYrMXbkwh2U6nbQfko5RzuTXkn5a110xKLWrzxqm7y&Tin=nqRyUS2hsrHk3rIdQ9bo9WZWkWp45Kb5Lfso5erM4=&isEc=true&IsNewEncr=True,cD=2020-10-03 05:08:56","short":"jeqvxrl"}}';
        ///'{"result":"error","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        string fbtst=OutBoundFdbckCallingNotification.SendFdbckLink(fb[0].id);
        Test.stopTest();
    }
}