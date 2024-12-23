public class CampaignTriggerHandler{
    public static void BeforeUpdate(List<Campaign> TriggerNew,Map<id,Campaign> TriggeroldMap){        
        List<Object_Info__c> Ols=new List<Object_Info__c>();
        for(Campaign cg:TriggerNew){
            if(TriggeroldMap.get(cg.id).status!=cg.status){
                Object_Info__c oi=new Object_Info__c();
                oi.name=cg.Name;
                oi.New_Status__c=cg.status;
                oi.Old_Status__c=TriggeroldMap.get(cg.id).status;
                oi.Campaign__c=cg.id;
                Ols.add(oi);
            }
        }
        
        if(!Ols.isEmpty())
            insert Ols;
        
    }    
}