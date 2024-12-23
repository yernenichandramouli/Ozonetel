@isTest
public class MultipleLeadsExtensionTest
{
    public static testMethod void TestMultipleLeads()
    {
        Test.startTest();
        
        user u=[select id,username from user where id=:userinfo.getuserid()];
        lead l=new lead();
        l.lastname='Test Name';
        l.status='New';
        l.ownerid=u.id;
        insert l;
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        MultipleLeadsExtension m=new MultipleLeadsExtension(sc);
        
        Test.stopTest();
        
      }
  }