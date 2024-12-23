@isTest
public class SuggestionTemplateTest{

@isTest
  public static  void TestTemplate()
    {
      Test.startTest(); 
    SuggestionTemplate.GetTemplate('India','Domestic-Bus','Acko Insurance Claim -','Acko Insurance Claim -');
        SuggestionTemplate.SearchTemplates('India','Domestic-Bus','Acko Insurance Claim -');
        case c=new case();
        c.status='Open';
        insert c;
        case cs=[select id,casenumber from case where id=:c.id];
        boolean isSTC = true;
        SuggestionTemplate.SaveCaseComment(string.valueOf(cs.id),'Test Comment', isSTC,isSTC);
        SuggestionTemplate.SaveCaseComment(string.valueOf(cs.id),'Test Comment', false,isSTC);
        SuggestionTemplate.SaveCaseComment(string.valueOf(cs.id),'Test Comment', isSTC,false);
        SuggestionTemplate.SaveCaseComment(string.valueOf(cs.id),'Test Comment', false,false);
        
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        Test.stopTest(); 
    }
}