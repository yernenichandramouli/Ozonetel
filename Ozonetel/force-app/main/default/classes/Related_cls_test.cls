@isTest
public class Related_cls_test
{
    Static testMethod void method1()
    {
        Account a=new Account();
        a.Name='test';
        Id recTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        a.RecordTypeId=recTypeId ;
        insert a;
        
        Order_Items__c oi=new Order_Items__c();
        oi.Name='test';
        oi.status__c='test1';
        oi.Customer_Name__c=a.Id;
        oi.Primary_Contact_Customer__c=a.Id;
        insert oi;
        
        ApexPages.CurrentPage().getParameters().put('Id',a.Id);
        ApexPages.StandardController ap=new ApexPages.StandardController(a);
        Related_cls rc=new Related_cls(ap);
    }
}