@isTest
public class ActivityViewRedirectionCntrlTest{
    static testMethod void activityTest()
    {
     Activities__c act = new Activities__c();
       act.name ='test';
       insert act; 
      ApexPages.StandardController sc = new ApexPages.StandardController(act);
       ActivityViewRedirectionCntrl ac = new ActivityViewRedirectionCntrl(sc);
    ac.checkAddonOrNot();
    }
  }