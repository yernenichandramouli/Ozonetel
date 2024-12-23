@isTest 
public class CallFeedbackCntr_Test 
{
     
     static testMethod void feedbackTest(){  
       List<Call_Details__c> lstcld= new List<Call_Details__c> ();
       Call_Details__c cld = new Call_Details__c();
        cld.Rating__c= 'good';
        cld.Call_Unique_Id__c= '1234567';
        lstcld.add(cld);
        insert lstcld;
        cld.Rating__c= '';
        cld.Call_Unique_Id__c= '124567';
        update lstcld;
        
        PageReference pageRef = Page.IVRCallFeedback;
        pageRef.getParameters().put('UCId',lstcld[0].Call_Unique_Id__c);
        Test.setCurrentPage(pageRef);
        
        CallFeedbackCntr callF= new CallFeedbackCntr ();
        callF.selRating='bad';
        callF.insertfdbck();
        callF.performUpdate();
     }
 }