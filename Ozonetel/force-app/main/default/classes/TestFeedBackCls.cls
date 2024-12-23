@isTest 
public class TestFeedBackCls
{
     
     static testMethod void testMethod1()      
     
     {
        Case c = new Case();
        c.Status = 'New';
        c.Origin = 'Email';
        insert c;
        
        Case_Feedback__c cfb=new Case_Feedback__c();
        cfb.Case_Name__c=c.id;
        cfb.Time_Stamp__c='2016-12-16 2005:58:29Z';
        insert cfb;
        
        PageReference pageRef = Page.CaseFeedback;
        pageRef.getParameters().put('cid', String.valueOf(c.Id));
        pageRef.getParameters().put('rate','Good');
        pageRef.getParameters().put('dateT',c.LastModified_String__c);        
        Test.setCurrentPage(pageRef);
        
        FeedBackCls fd = new FeedBackCls();
        fd.sfInsert();
        
        Case c1 = new Case();
        c1.Status = 'Closed';
        c1.Origin = 'Email';
        insert c1;
        
        Case_Feedback__c cfb1=new Case_Feedback__c();
        cfb1.Case_Name__c=c1.id;
        cfb1.Time_Stamp__c=c1.LastModified_String__c;
        insert cfb1;
        
        PageReference pageRef1 = Page.CaseFeedback;
        pageRef1.getParameters().put('cid', String.valueOf(c1.Id));
        pageRef1.getParameters().put('rate','Good');
        pageRef1.getParameters().put('dateT',c1.LastModified_String__c);        
        Test.setCurrentPage(pageRef1);
        
        FeedBackCls fd1 = new FeedBackCls();
        fd1.sfInsert();
        
     }

}