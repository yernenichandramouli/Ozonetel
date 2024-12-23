public class HighLightPanelDataGet {
    
    public static string recId{get; set;}
    public HighLightPanelDataGet(ApexPages.StandardController sc) {
        system.debug('<<sc.getRecord().id'+sc.getRecord().id);
        recId = sc.getRecord().id;
    }
    
    @AuraEnabled
    public static String getUIThemeDescription() {
        String theme = UserInfo.getUiThemeDisplayed();
        return theme;
    }
    
    @AuraEnabled(cacheable=true)
    public static case caseData(string csId){
        case cs = [select id,Total_Ticket_Amount__c,Case_Category__c,Refund_Amount__c,HFT__c,Refund_Status__c,Does_Customer_Require_CallBack__c,CallBack_Requested_Time__c from case where id =: csId];
        return cs; 
    }
    
    @AuraEnabled(cacheable=true)
    public static Order_Items__c transactionData(string ordId){
        Order_Items__c ord=[select id,StreakStatus__c,Assurance_Service__c,isCancellableFromApi__c,Total_Fare__c,Cancelled_Time__c,Business_Unit__c,Item_Type__c,Service_Provider_Id__c,Date_of_Issue_New__c,Related_To__c,Related_Id__c,HFT__c,Refund_Amount__c,Refund_Status__c,Payment_Currency__c,(select Refund_Amount__c  from Refund_Order_Items__r) 
                            from Order_Items__c where id =: ordId];
        if(ord.Refund_Amount__c == '' || ord.Refund_Amount__c == Null){
            Decimal refundTotal = 0.0;
            for(Refund_Order_Items__c ref : ord.Refund_Order_Items__r ){
                if(ref.Refund_Amount__c!=null){
                    refundTotal = refundTotal + Decimal.valueof(ref.Refund_Amount__c.substring(3).trim());
                }
            }
            ord.Refund_Amount__c = String.valueof(refundTotal);
        } 

        return ord;        
    } 
    
    @AuraEnabled
    public static list<CaseComment> getCaseComment(string csId){
        system.debug('<<csId'+csId);
        List<CaseComment> casecmts = [select Id,commentbody,CreatedBy.name,CreatedDate, ParentId from CaseComment where ParentId =: csId order by CreatedDate desc];
        system.debug('<<<List'+casecmts);
        return casecmts;  
    }
    
    @AuraEnabled 
    public static void UpdateCaseComment(string Id, string comment ){
        system.debug('csId-->'+Id+'--comment->'+comment);
        casecomment cc=new casecomment();
        cc.Id=Id;
        cc.commentbody=comment;
        try{
            update cc;
        }catch(Exception e){
            System.debug('er->'+e);
        }
        
    }
    @AuraEnabled
    public static void ViewAllUpdateCaseComments(List<CaseComment> ccData){
        try{
            update ccData;  
        }catch(Exception e){
            system.debug('er->'+e); 
        }
    }
    // To fetch the connected service transaction. CRM-1899
    @AuraEnabled(cacheable=true)
    public static Order_Items__c fetchConnectedTransaction(string transactionId){
        List<Order_Items__c> orderItemList = New List<Order_Items__c>();
        System.debug(':::: transactionId = '+transactionId);
        Order_Items__c orit = [SELECT Id, Order_Id__c, Umbrella_TIN__c, Umbrella_UUID__c FROM Order_Items__c WHERE Id =:transactionId AND Umbrella_TIN__c!=Null AND Umbrella_UUID__c!=Null LIMIT 1];
        if(string.isNotBlank(orit.Order_Id__c)){
            orderItemList = [SELECT Id, Name FROM Order_Items__c WHERE Order_Id__c=:orit.Order_Id__c and Id!=:transactionId AND Umbrella_TIN__c=: orit.Umbrella_TIN__c AND Umbrella_UUID__c =:orit.Umbrella_UUID__c LIMIT 1];
        }
        if(!orderItemList.isEmpty()){
            return orderItemList[0];
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static lead LeadData(string lId){
        Lead ld = [select id,SrcCityName__c,DestCityName__c,DOJEnd__c,DOJStart__c,FirstQuoteTime__c,ThirdQuoteTime__c, CustomerUrl__c from lead where id =: lId];
        return ld; 
    }

    @AuraEnabled(cacheable=true) 
    public static boolean validateBOIds(string transactionId){
        boolean isBoltBoId = false;
        try {
            Order_Items__c ord=[select id,Service_Provider_Id__c,Service_Provider_Info__r.Operator_Id__c,Service_Provider_Info__r.Name  from Order_Items__c where id =: transactionId LIMIT 1];
            list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
           String oprtrId = ord.Service_Provider_Id__c != null ? ord.Service_Provider_Id__c :(ord.Service_Provider_Info__r!=null && ord.Service_Provider_Info__r.Operator_Id__c!= null)? ord.Service_Provider_Info__r.Operator_Id__c:'';
            if(string.isNotBlank(oprtrId)){
                Set<String> boltBOIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
                if(boltBOIds.contains(oprtrId)){
                    isBoltBoId=true;
                }
            }
           return isBoltBoId;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true) 
    public static boolean StreaksTripReward(string transactionId){
        boolean isStreakId = false;
        try {
            Order_Items__c ord=[select id,StreakId__c from Order_Items__c where id =: transactionId LIMIT 1];
            String streakId = String.isNotBlank(ord.StreakId__c)?ord.StreakId__c:'';
            if(string.isNotBlank(streakId)){
                    isStreakId=true;
                
            }
           return isStreakId;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}