@isTest
private class CampaignTriggerHandlerTest{
 static testMethod void CampaignStatusUpdate()
    {
      Campaign c=new Campaign();
      c.name='Test Campaing';
      c.status='New';
      insert c;
      c.status='Closed';
      update c;
    }
}