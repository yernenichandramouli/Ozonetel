@isTest
public class RpoolDetailsTest{

  static testMethod void CampaignTest()
    {
      campaign c=new campaign();
      c.name='Test';
      c.status='P1';
      insert c;
      c.status='P2';
      update c;
      
      RpoolDetails r=new RpoolDetails();
      r.RpoolData();
    }

}