@isTest
public class TripRewardsCntrlTest{
    @testsetup
    static void testCreateOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<200 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Rb_User_ID__c='12345678',Guid__c='1234567890456789',Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718',Date_Of_Purchase__c=system.now()));
        } 
        insert orderList ;
    }
    
    public static testMethod void tripTransTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp ='{"OpId":15926,"OpName":"Virtual_travels","StreakStatus":"ACTIVE","MaxOfferAmount":31,"TripBookingCount":2,"TripCompletionCount":0,"TotalTxnCount":2,"StreakStartDate":"2024-02-21 19:45:27","StreakEndDate":"2024-04-21 19:45:27","RedemptionStartDate":"2024-03-16 22:10:00","RedemptionDate":"2024-06-20 20:15:27","IsRedeemable":false,"Consent":true,"ConsentUUID":"a6830b8011e5f0066c4b1b4001020100","IsLastBooking":true,"SortOrder":0,"Txns":[{"UUID":"a6830b8011e5f0066c4b1b4001020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 19:30:00","SrcID":69283,"DestID":65782,"Position":1},{"UUID":"60af0d4f11e5f0066c4b1b4002020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 22:10:00","SrcID":69283,"DestID":65782,"Position":2}],"PositionOfTxn":1}';

        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        TripRewardsCntrl.GetAllStreaksByTransId(ol[0].id);   
        Test.stopTest();
    }
    
     public static testMethod void tripErrorTransTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp ='';

        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        TripRewardsCntrl.GetAllStreaksByTransId(ol[0].id);   
        Test.stopTest();
    }
    
    
     public static testMethod void userTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"15926":{"OpId":15926,"OpName":"Virtual_travels","StreakStatus":"ACTIVE","MaxOfferAmount":31,"TripBookingCount":2,"TripCompletionCount":0,"TotalTxnCount":2,"StreakStartDate":"2024-02-21 19:45:27","StreakEndDate":"2024-04-21 19:45:27","RedemptionStartDate":"2024-03-16 22:10:00","RedemptionDate":"2024-06-20 20:15:27","IsRedeemable":false,"Consent":true,"ConsentUUID":"a6830b8011e5f0066c4b1b4001020100","IsLastBooking":true,"SortOrder":1,"Txns":[{"UUID":"a6830b8011e5f0066c4b1b4001020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 19:30:00","SrcID":69283,"DestID":65782,"Position":0},{"UUID":"60af0d4f11e5f0066c4b1b4002020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 22:10:00","SrcID":69283,"DestID":65782,"Position":0}]},"27461":{"OpId":27461,"OpName":"TestBo rtcFlow","StreakStatus":"ACTIVE","MaxOfferAmount":0,"TripBookingCount":1,"TripCompletionCount":0,"TotalTxnCount":3,"StreakStartDate":"2024-02-21 20:15:37","StreakEndDate":"2024-03-02 20:15:37","RedemptionDate":"2024-03-04 08:43:25","IsRedeemable":false,"Consent":true,"ConsentUUID":"f175a59f1203f0066c4b1b4002020100","IsLastBooking":false,"SortOrder":0,"Txns":[{"UUID":"f175a59f1203f0066c4b1b4002020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-02-26 13:30:00","SrcID":69283,"DestID":65782,"Position":0}]}}';

        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        TripRewardsCntrl.GetAllStreaksByUserId(ol[0].id);
        Test.stopTest();
    }
    
      public static testMethod void userErrorTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='';

        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        TripRewardsCntrl.GetAllStreaksByUserId(ol[0].id);
        Test.stopTest();
    }
    
    
    public static testMethod void accountUserTest()
    {
        
        Test.startTest();
        Account acc = new Account();
       acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.lastname='Test Account';
        acc.PersonEmail='test@redbus.in';
        acc.PersonMobilePhone='9491322718';
        acc.email_copy__c='te@r.com';
        acc.User_Id__c ='345678';
        insert acc;
        
        string mockResp='{"15926":{"OpId":15926,"OpName":"Virtual_travels","StreakStatus":"ACTIVE","MaxOfferAmount":31,"TripBookingCount":2,"TripCompletionCount":0,"TotalTxnCount":2,"StreakStartDate":"2024-02-21 19:45:27","StreakEndDate":"2024-04-21 19:45:27","RedemptionStartDate":"2024-03-16 22:10:00","RedemptionDate":"2024-06-20 20:15:27","IsRedeemable":false,"Consent":true,"ConsentUUID":"a6830b8011e5f0066c4b1b4001020100","IsLastBooking":true,"SortOrder":1,"Txns":[{"UUID":"a6830b8011e5f0066c4b1b4001020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 19:30:00","SrcID":69283,"DestID":65782,"Position":0},{"UUID":"60af0d4f11e5f0066c4b1b4002020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 22:10:00","SrcID":69283,"DestID":65782,"Position":0}]},"27461":{"OpId":27461,"OpName":"TestBo rtcFlow","StreakStatus":"ACTIVE","MaxOfferAmount":0,"TripBookingCount":1,"TripCompletionCount":0,"TotalTxnCount":3,"StreakStartDate":"2024-02-21 20:15:37","StreakEndDate":"2024-03-02 20:15:37","RedemptionDate":"2024-03-04 08:43:25","IsRedeemable":false,"Consent":true,"ConsentUUID":"f175a59f1203f0066c4b1b4002020100","IsLastBooking":false,"SortOrder":0,"Txns":[{"UUID":"f175a59f1203f0066c4b1b4002020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-02-26 13:30:00","SrcID":69283,"DestID":65782,"Position":0}]}}';

        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        TripRewardsCntrl.AccountStreaksByUserId(acc.id);
        Test.stopTest();
    }
    
     public static testMethod void ErroraccountUserTest()
    {
        
        Test.startTest();
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.lastname='Test Account';
        acc.PersonEmail='test@redbus.in';
        acc.PersonMobilePhone='9491322718';
        acc.email_copy__c='te@r.com';
        acc.User_Id__c ='345678';
        insert acc;
        
        string mockResp='';

        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        TripRewardsCntrl.AccountStreaksByUserId(acc.id);
        Test.stopTest();
    }
    
  }