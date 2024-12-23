@isTest
Public class CaseExtension_Test{
 static testMethod void casetest(){
 
        Case cs1 = new Case();
        Id recTypeId=Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosByName().get('Chat').getRecordTypeId();
        cs1.RecordTypeId = recTypeId;
        cs1.Status ='Initiated';
        cs1.Origin = 'Chat';
        cs1.Issue_Type__c ='Bus Cancellation';
        cs1.Issue_Sub_Category__c ='Alternate bus not arranged';
        cs1.Ownerid = UserInfo.getUserId();
        insert cs1;
        
        CaseExtension csext = new CaseExtension(new ApexPages.StandardController(cs1));
         csext.saveDetails();
  }
 }