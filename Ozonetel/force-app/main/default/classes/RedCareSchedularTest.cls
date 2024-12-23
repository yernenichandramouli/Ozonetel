@isTest
private class RedCareSchedularTest{
    public static testMethod void  testRedCare() 
    {
        Test.StartTest();
        Order_Items__c  orIt= new Order_Items__c();
        orIt.Order_Item_Reference_No__c = 'TM6686279816';
        orIt.name = '12211663367079914  ';
        orIt.Order_Id__c = '12211663367073522';
        orIt.status__c ='Created';
        orIt.Service_Provider_Name__c = 'RedBus';
        orIt.Guid__c='5e8477ad5405f0055be4ce5801020100';
        insert orIt;
        
        Case cs = new Case();
        cs.Status ='Open';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='Booking Issues';
        cs.Issue_Sub_Category__c='Need M ticket/ E ticket';  
        cs.Transaction_ID__c=orIt.id;
        cs.Phone_No_ct__c='9989878789';
        cs.tin_no__c=orIt.Order_Item_Reference_No__c;
        cs.redCare_Status__c='API NULL';
        
        insert cs;
        cs.TAT_Value__c=-8;
        cs.redCare_Amount__c=2;
        cs.Status ='Closed';
        
        CaseComment cc=new CaseComment();
        cc.CommentBody='Test Comment Body';
        cc.ParentId=cs.Id;
        insert cc;
        update cs;
        RedCareSchedular redSch= new RedCareSchedular();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, redSch);
        Test.stoptest();
        
    }
}