@isTest
private class SyncPollingCntrlTest{
    
    static testMethod void SyncPollingTest()
    {
        Order_Items__c ot=new Order_Items__c();
        ot.Order_Item_Reference_No__c='123';
        insert ot;
        ApexPages.currentPage().getParameters().put('id','123');
        ApexPages.currentPage().getParameters().put('source','B2B');
        SyncPollingCntrl s=new SyncPollingCntrl ();
        s.searchOrder();
    }
    static testMethod void SyncPollingTest2()
    {    
        Order_Items__c ot=new Order_Items__c();
        ot.Order_Id__c='123';
        insert ot;
        ApexPages.currentPage().getParameters().put('id','123');
        ApexPages.currentPage().getParameters().put('source','B2C');
        SyncPollingCntrl s=new SyncPollingCntrl ();
        s.searchOrder();
    }   
}