@isTest
public class casePrepopulating_cls_Test
{
    Static TestMethod void method()
    {
        Account acc = new Account();
        acc.Name='SampleName';
        acc.Phone='9584561234';
        acc.Email__c='Sample@gmail.com';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        acc.RecordTypeId = recordTypeId;
        Insert acc;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.Customer_Name__c=acc.Id;
        ori.Business_Unit__c ='REDBUS_IN';
        ori.Creation_Time__c = System.now();
        Insert ori;
        
        Case cs = new Case();
        cs.Email_Id_ct__c='Sample@gmail.com';
        cs.Phone_No_ct__c='9584561234';
        cs.OwnerId=UserInfo.getUserId();
        cs.Transaction_ID__c=ori.Id;
        cs.Does_Customer_Require_CallBack__c=true;
        cs.Call_Back_Time__c='1';
        Insert cs;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('tId',ori.Id);
        ApexPages.StandardController cls = new ApexPages.StandardController(ori);
        casePrepopulating_cls cscls = new casePrepopulating_cls(cls);
        cscls.saveMethod();
        cscls.boltNotification();
        cscls.showPopup();
        Test.StopTest();
    }
    Static TestMethod void method2()
    {
         Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        Insert ori; 
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('tId',ori.Id);
        ApexPages.StandardController cls = new ApexPages.StandardController(ori);
        casePrepopulating_cls cscls = new casePrepopulating_cls(cls);
        cscls.showPopup();
        cscls.closePopup();
    }
}