public class CaseExtension {

    public Case cs{get;set;}
    public string source{get; set;}
    public CaseExtension(ApexPages.StandardController controller) 
    {
        source='';
        source=System.currentPageReference().getParameters().get('Source');
        cs = new Case();
        cs.Country__c = [SELECT id,name,Country from User WHERE Id=:UserInfo.getUserId()].Country;
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
        if(source=='callpopup'){
          cs.Origin = 'Inbound Call';
          cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('InBound Call').getRecordTypeId();
        }else{
        cs.Origin = 'Chat';
        }
        
        if('Indonesia'.equalsIgnoreCase(cs.Country__c))
            cs.Business_Type__c = 'Indonesia-Bus';
        if('India'.equalsIgnoreCase(cs.Country__c))
            cs.Business_Type__c = 'Domestic-Bus';
    }
    
    public PageReference saveDetails()
    { 
    try{
      cs.status = 'Bus Cancellation'.equalsIgnoreCase(cs.issue_type__c)?'Initiated':'Closed'.equalsIgnoreCase(cs.status)?'Closed':'Open';
      insert cs;
      PageReference p = new PageReference('/'+cs.id);
      p.setRedirect(true);
      return p;
      }catch(Exception e){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,String.valueOf(e)));
        return null;

      }
      
    }
      

}