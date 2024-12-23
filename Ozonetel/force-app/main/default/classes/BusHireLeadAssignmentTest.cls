@isTest
public class BusHireLeadAssignmentTest
{
public static testMethod void TestAssignment()
    {
        Test.startTest();
        user u=[select id,username from user where id=:userinfo.getuserid()];
        lead l=new lead();
        l.lastname='Test Name';
        l.status='New';
        l.ownerid=u.id;
        insert l;
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        BusHireLeadAssignment b=new BusHireLeadAssignment(sc);
        b.ldObj=l;
        b.ShowLeads();
        u.Group__c='Group 1';
        update u;
        b.ShowLeads();
        Test.stopTest();       
     }     
  }