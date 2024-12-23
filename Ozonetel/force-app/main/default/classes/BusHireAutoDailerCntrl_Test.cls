@isTest
public class BusHireAutoDailerCntrl_Test
{
    Static testMethod void bushireTest()
    {
    
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.is_Error_Occurred__c=true;
        usrDt.Last_5_Lead_Ids__c='00Q0p000001SD7Q';
        usrDt.User__c=UserInfo.getUserId();
         
        insert usrDt;
        user  usr=[select id,CZentrix_Agent_Id__c from user where id=:userInfo.getuserid()];
        list<Lead> Ledlist = new list<Lead>();
        Lead ld = new Lead();
        ld.Status = 'RnR';
        ld.ownerid=usr.id;
        ld.Call_back_request_time__c =system.now().addminutes(-30);
        ld.LastName='MAHI';
        ld.Agent_Mobile__c='1234567890';
        ld.OwnerId = UserInfo.getUserId();
        ld.Consider_For_Assignment__c=true;
        ld.Priority__c=5;
        ld.SrcCityName__c='Hyderabad';
        ld.DestCityName__c='Vishakhapatman';
        ld.DOJStart__c=System.today().adddays(1);
        ld.NumberOfQuotes__c=2;
        ld.IsMobileVerified__c=true;
        ld.Phone='3412312312';
        Ledlist.add(ld );
        insert Ledlist;
        
        
        Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        string json='{"result":"SUCCESS","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));

        BusHireAutoDailerCntrl busHrautodia= new BusHireAutoDailerCntrl ();
        busHrautodia.getAgentCallDetails();
        busHrautodia.callToCustomer();
        Test.stopTest();
    }
    Static testMethod void bushireErrorTest()
    {
    
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.is_Error_Occurred__c=true;
        usrDt.Last_5_Lead_Ids__c='00Q0p000001SD7Q';
        usrDt.User__c=UserInfo.getUserId();
        usrDt.AgentStatus__c='Available';
        insert usrDt;
        
        list<Lead> Ledlist = new list<Lead>();
        Lead ld = new Lead();
        ld.Status = 'RnR';
        ld.LastName='Mahi';
        ld.Priority__c=5;
        ld.Phone='3412312312';
        
        Ledlist.add(ld );
        insert Ledlist;
       
        Test.startTest();
        BusHireAutoDailerCntrl busHrautodia= new BusHireAutoDailerCntrl ();
        string json='{"result":"SUCCESS","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));

        busHrautodia.getAgentCallDetails();
        busHrautodia.callToCustomer();
        busHrautodia.AssginLeads();
         busHrautodia.UpdateAgentStatus();
        Test.stopTest();
    }
}