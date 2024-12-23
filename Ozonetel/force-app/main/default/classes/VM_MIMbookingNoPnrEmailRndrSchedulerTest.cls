@isTest
private class VM_MIMbookingNoPnrEmailRndrSchedulerTest{
    public static testMethod void  testSendRemainder() 
    {
      
          Test.StartTest();
        Order_Items__c  orItm = new Order_Items__c();
        orItm.isMIM_Booking__c = true;
        orItm.Business_Unit__c ='REDBUS_VN';
        orItm.Seat_No__c ='NA';
        DateTime currentDateTime = DateTime.now();
        String formattedDateTimeString = currentDateTime.format('dd-MM-yyyy hh:mm a');
        orItm.Date_of_Journey_Local__c = formattedDateTimeString;
        orItm.Ticket_Confirmed_Time__c =system.now();
        orItm.Service_Provider_Name__c ='Test Travel';
        orItm.Destination__c ='Chennai';
        orItm.Source__c ='Bangalore';
       // orItm.Total_Fare__c ='500';
        insert orItm; 
        
        VM_MIMbookingNoPnrEmailRndrScheduler ar= new VM_MIMbookingNoPnrEmailRndrScheduler();
        String sche = '0 0 0 ? * * *';
        system.schedule('Test', sche, ar);
        Test.StopTest();
     
     }
   
}