@isTest
private class DBTSchedulerTest{
    public static testMethod void  testDBTCaseCreation() 
    {
        
        Order_Items__c  orIt= new Order_Items__c();
        orIt.Order_Item_Reference_No__c = 'TM6686279816';
        orIt.name = '12211663367079914  ';
        orIt.Order_Id__c = '12211663367073522';
        orIt.status__c ='Created';
        orIt.Service_Provider_Name__c = 'RedBus';
        orIt.Guid__c='5e8477ad5405f0055be4ce5801020100';
        orIt.Bank_Account_Number__c='12345';
        orIt.Date_Of_Purchase__c=System.today();
        insert orIt;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'online';
        p.Order_Item_Name__c = orIt.id;
        p.ID__c = '12345';
        p.Bank_Account_Number__c='12345';
        p.Payment_System__c='ONLINE';
        p.Creation_Time__c=System.today();
        insert p;
        Test.StartTest();
        DBTScheduler dbtSch= new DBTScheduler ();
        String sche ='0 0 20 * * ? *';
        system.schedule('DBT Scheduler', sche, dbtSch);
        
        Test.stopTest();
    } 
    
    public static testMethod void  testDBTCaseUpdate() 
    {
        
        Orders__c o=new Orders__c();
        o.name='12211663367073522';
        insert o;
        
        Order_Items__c  orIt= new Order_Items__c();
        orIt.Order_Item_Reference_No__c = 'TM6686279816';
        orIt.Order_Name__c=o.id;
        orIt.name = '12211663367079914';
        orIt.Order_Id__c = '12211663367073522';
        orIt.status__c ='Created';
        orIt.Service_Provider_Name__c = 'RedBus';
        orIt.Guid__c='5e8477ad5405f0055be4ce5801020100';
        orIt.Bank_Account_Number__c='12345';
        orIt.Date_Of_Purchase__c=System.today();
        insert orIt;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'online';
        p.Order_Item_Name__c = orIt.id;
        p.ID__c = '12345';
        p.Bank_Account_Number__c='12345';
        p.Payment_System__c='ONLINE';
        p.Creation_Time__c=System.today();
        p.Amount_Payable_Value__c=1234;
        insert p;
        
        case c=new case();
        //c.transaction_id__c=orIt.id;
        c.issue_type__c='DBT';
        c.trip_id_ct__c='12211663367073522';
        
        insert c;
        
        Test.StartTest();
        DBTScheduler dbtSch= new DBTScheduler ();
        String sche ='0 0 23 * * ? *';
        system.schedule('DBT Scheduler', sche, dbtSch);
        
        Test.stopTest();
    } 
}