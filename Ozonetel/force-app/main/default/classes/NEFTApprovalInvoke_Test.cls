@isTest
public class NEFTApprovalInvoke_Test
{
     Static TestMethod void method()
    {
        test.startTest();
        Account accnt= new Account();
        accnt.Review__c = 'test';
        accnt.Amount__c  = 10;
        accnt.Name = 'test';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        accnt.RecordTypeId = recordTypeId;
        insert accnt;
        
        Case c = new Case();
        c.AccountId = accnt.Id;
        c.InitiatedBy__c='test';
        c.status='Reject for NEFT';
        c.NEFT_Status_Bit__c  =false;
        c.Customer_Name__c = accnt.Id;
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        insert c;
         
        NEFTApprovalInvoke.NEFTApprovalAPICall(new List<string>{c.Id});
    }
    
    Static TestMethod void method1()
    {
        test.startTest();
        Account accnt= new Account();
        accnt.Review__c = 'test';
        accnt.Amount__c  = 10;
        accnt.Name = 'test';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        accnt.Bank_Account_Number__c = '234234234';
        accnt.BankName__c= 'hdfc';
        accnt.IFSCCode__c='23234234';
        accnt.BranchName__c = 'domlur';
        accnt.Beneficiary_Name__c = 'asdadasd';
       // accnt.PersonEmail = 'test@gmail.com';
        //accnt.PersonMobilePhone ='345345345345';
        accnt.User_Id__c ='123';
        accnt.RecordTypeId = recordTypeId;
        insert accnt;
        
        Case c = new Case();
        c.AccountId = accnt.Id;
        c.InitiatedBy__c='test';
        c.status='Approved for NEFT';
        c.NEFT_Status_Bit__c  =false;
        c.Customer_Name__c = accnt.Id;
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        insert c;
        NEFTApprovalInvoke.Status st = new NEFTApprovalInvoke.Status();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        NEFTApprovalInvoke.NEFTApprovalAPICall(new List<string>{c.Id});
    }
    
     Static TestMethod void method3()
    {
        test.startTest();
        Account accnt= new Account();
        accnt.Review__c = 'test';
        accnt.Amount__c  = 10;
        accnt.Name = 'test';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        accnt.Bank_Account_Number__c = '234234234';
        accnt.BankName__c= 'hdfc';
        accnt.IFSCCode__c='23234234';
        accnt.BranchName__c = 'domlur';
        accnt.Beneficiary_Name__c = 'asdadasd';
        accnt.User_Id__c ='123';
        accnt.RecordTypeId = recordTypeId;
        insert accnt;
        
        Case c = new Case();
        c.AccountId = accnt.Id;
        c.InitiatedBy__c='test';
        c.status='Approved for NEFT';
        c.NEFT_Status_Bit__c  =false;
        c.Customer_Name__c = accnt.Id;
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        insert c;
        NEFTApprovalInvoke.NEFTAPIping(null,null,null);
    }
}