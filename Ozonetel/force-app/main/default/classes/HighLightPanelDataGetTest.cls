@isTest
public class HighLightPanelDataGetTest {
@isTest
    public static void testDataGetMethod(){
      Order_Items__c ord = new Order_Items__c();
      ord.Total_Fare_Currency__c='INR'; 
      ord.Total_Fare_Value__c=100; 
      ord.Service_Provider_Id__c = '15926';
      insert ord;
      case cs = new case();
      List<CaseComment> ccData = New List<CaseComment>();
      cs.Refund_Amount__c=10;
      cs.Refund_Status__c='processing';
      cs.Transaction_ID__c = ord.Id;  
      insert cs;
      HighLightPanelDataGet.caseData(cs.Id);
      HighLightPanelDataGet.transactionData(ord.Id); 
      casecomment cc = new casecomment();
      cc.commentbody='test comment';
      cc.parentId=cs.Id;
      ccData.add(cc);
      HighLightPanelDataGet.getCaseComment(cs.Id);
      HighLightPanelDataGet.UpdateCaseComment(cc.Id, 'test2');
      HighLightPanelDataGet.ViewAllUpdateCaseComments(ccData); 
      HighLightPanelDataGet.getUIThemeDescription();  
      lead ld = new lead ();
      ld.lastname='ABC';
      ld.Status='New';
      ld.Remarks__c='test';
      insert ld;
      HighLightPanelDataGet.LeadData(ld.id);  
      HighLightPanelDataGet.validateBOIds(ord.Id);
      HighLightPanelDataGet.StreaksTripReward(ord.Id);
      //Connected transaction Test 
      Order_Items__c order1 = new Order_Items__c();
      order1.Order_Id__c='13817275132276428'; 
      order1.Umbrella_TIN__c='TTAP80559073'; 
      order1.Umbrella_UUID__c = 'a200bfbc22d7f006de86aae3040a0100';
      insert order1;
      Order_Items__c order2 = new Order_Items__c();
      order2.Order_Id__c='INR'; 
      order2.Umbrella_TIN__c='TTAP80559073'; 
      order2.Umbrella_UUID__c = 'a200bfbc22d7f006de86aae3040a0100';
      insert order2;
      HighLightPanelDataGet.fetchConnectedTransaction(order1.Id);
    }
}