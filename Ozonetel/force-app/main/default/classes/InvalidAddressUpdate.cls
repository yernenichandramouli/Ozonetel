public class InvalidAddressUpdate {
    
    @AuraEnabled(cacheable=true)
    public static Order_Items__c GetDetails( string ordId){
        system.debug('ordId'+ordId);
        Order_Items__c oi = [select id,Business_Unit__c,Transaction_Status__c,Boarding_Point__c from Order_Items__c where id=: ordId];
        system.debug('<<<oi'+oi);
        return oi;   
    }
    @AuraEnabled
    public static string InvalidAddressCaseCreate(string ordId, string comment, string status, string customerBP){
        case c=new case();
        string msg ='';
        try{
            system.debug('<<<<ordId'+ordId+'status'+status);
            c= [select id from case where transaction_id__c =: ordId and origin=:'InBound Call' and Issue_Type__c='I need help to board my Bus' and Issue_Sub_Category__c='Issue with Boarding Address'];
            system.debug('<<<<c'+c);
            if(c!= null ){
                msg='already exist';
                system.debug('<<<<msg'+msg);
                
                return msg;
            }
            
        }catch(Exception e){}

        Order_Items__c oi = [select id,Business_Unit__c from Order_Items__c where id=: ordId];    
        c.Description=comment;
        c.Issue_Type__c='I need help to board my Bus';
        c.Issue_Sub_Category__c ='Issue with Boarding Address';
        c.Origin='InBound Call';
        c.Subject = status;
        Group BdQ=[select id from Group where type='Queue' AND developername='bdsupport_international'];
        Group ISEqueue=[select id from Group where type='Queue' AND developername='ISE_queue'];
        c.transaction_id__c=ordId;
        c.Customer_provided_Boarding_Point__c = customerBP;
        c.Business_Unit_ct__c=oi.Business_Unit__c;
        if(c.Business_Unit_ct__c=='REDBUS_ID'){
            c.status ='Escalated to ISE';
            c.OwnerId=ISEqueue.id;
        }else{
           c.status = 'Open';
           c.ownerid=BDQ.id;     
        }
        c.country__c=OrderItemTransactionResource__c.getValues(c.Business_Unit_ct__c).Case_Country__c;
        system.debug('<<<<c.country__c'+c.country__c);
        c.Business_Type__c=OrderItemTransactionResource__c.getValues(c.Business_Unit_ct__c).Case_Business_Type__c;
        system.debug('<<<c.Business_Type__c'+c.Business_Type__c);
        try{
            insert c;
            case cse = [select casenumber from case where id=:c.id ];
            msg='Case '+cse.casenumber+' is created.';
        }catch(Exception e){
            system.debug('<<<e'+e);
            msg='error';
        }
        
        
        return msg ;
    }
}