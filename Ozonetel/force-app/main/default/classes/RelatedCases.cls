public class RelatedCases {
    @AuraEnabled(cacheable=true)
    public static case getParentCase(string caseId){
        case cse = [select id,ParentId from case where id=:caseId ];
        case pcase = [select id,CaseNumber,Status from case where id=:cse.parentId];  
        if (pcase != null){
            system.debug('<<<parent case '+pcase);
            return pcase;               
        }
        else
            return null;
    }
    @AuraEnabled(cacheable=true)
    
    public static List<case> getrelatedCases(string caseId){
        List<case> cseList = new List<case>();
        case cse = [select id,TIN__c,Email_Id_ct__c,Phone_No_ct__c,Booking_Mobile_No__c,ParentId from case where id=:caseId ];
        if(string.isNotBlank(cse.TIN__c)){
          cseList =[select id,caseNumber,status from case where TIN__c=:cse.TIN__c and id !=:cse.ParentId and id !=:caseId ];
        }else if(string.isNotBlank(cse.Phone_No_ct__c)){
          cseList =[select id,caseNumber,status,Email_Id_ct__c,Phone_No_ct__c,Booking_Mobile_No__c from case where Phone_No_ct__c=:cse.Phone_No_ct__c and id !=:cse.ParentId and id !=:caseId ];
        }else if(string.isNotBlank(cse.Booking_Mobile_No__c)){
          cseList =[select id,caseNumber,status,Email_Id_ct__c,Phone_No_ct__c,Booking_Mobile_No__c from case where Booking_Mobile_No__c=:cse.Booking_Mobile_No__c and id !=:cse.ParentId and id !=:caseId ];
        }else if(string.isNotBlank(cse.Email_Id_ct__c)){
          cseList =[select id,caseNumber,status,Email_Id_ct__c,Phone_No_ct__c,Booking_Mobile_No__c from case where Email_Id_ct__c=:cse.Email_Id_ct__c and id !=:cse.ParentId and id !=:caseId ];
        }
        
        system.debug('<<<case list '+ cseList);       
        if(cseList != null){
            return cseList;            
        }
        else
            return null;
    }
    
   @AuraEnabled

    public static list<case> getChilidCases(string caseId){
        List<case> cseList = new List<case>();
        cseList =[select id,caseNumber,status from case where ParentId =:caseId];
        if(cseList !=null){
            return cseList;
        }        
        else
            return null;
    }
}