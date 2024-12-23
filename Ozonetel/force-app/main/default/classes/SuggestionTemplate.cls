public class SuggestionTemplate{
    
    @AuraEnabled(Cacheable=true)
    public static List<Issue_Based_TAT__mdt> GetTemplate(string country,string busType,string issue,string subIssue) {
        System.debug('issue-->'+issue+'---subIssue->'+subIssue);
        if(string.isNotBlank(country) && string.isNotBlank(busType)){
        return [SELECT Id,Issue_Type__c,Issue_Sub_Category__c,Suggestion_Template__c,Template_Name__c,Country__c,Business_Type__c  FROM Issue_Based_TAT__mdt where Country__c=:country and Business_Type__c=:busType and Issue_Type__c=:issue and Issue_Sub_Category__c=:subIssue ]; 
        }else{
         return [SELECT Id,Issue_Type__c,Issue_Sub_Category__c,Suggestion_Template__c,Template_Name__c,Country__c,Business_Type__c  FROM Issue_Based_TAT__mdt where Issue_Type__c=:issue and Issue_Sub_Category__c=:subIssue ]; 
        }      
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<Issue_Based_TAT__mdt> SearchTemplates(string country,string busType,string template){
        System.debug('temp-->'+template);
        set<string> tempSet=new set<string>();
        //where Issue_Type__c=:template 
        string tempName='%'+template+'%';
        if(string.isNotBlank(tempName)){
            list<Issue_Based_TAT__mdt> isuList=new list<Issue_Based_TAT__mdt>();  
            list<Issue_Based_TAT__mdt> retIsuList=new list<Issue_Based_TAT__mdt>();   
            if(string.isNotBlank(country) && string.isNotBlank(busType)){     
            isuList=[SELECT Id,Issue_Type__c,Issue_Sub_Category__c,Suggestion_Template__c,Template_Name__c FROM Issue_Based_TAT__mdt where Country__c=:country and Business_Type__c=:busType and template_name__c!=null and template_name__c LIKE : tempName];     
            }else{
                isuList=[SELECT Id,Issue_Type__c,Issue_Sub_Category__c,Suggestion_Template__c,Template_Name__c FROM Issue_Based_TAT__mdt where template_name__c LIKE : tempName];      
            }   
            for(Issue_Based_TAT__mdt ib:isuList){
                if(!tempSet.contains(ib.Template_Name__c)){
                    tempSet.add(ib.Template_Name__c);
                    retIsuList.add(ib);
                }
            }
            return retIsuList;
        }else
            return null;
    }
    
    @AuraEnabled
    public static string SaveCaseComment(string csId,string comment, boolean isSTC, boolean isRTB){
        system.debug('csId-->'+csId+'--comment->'+comment+'isSTC-->'+isSTC+'isRTB'+isRTB);
        /*        casecomment cc=new casecomment();
cc.parentid=csId;
cc.commentbody=comment;
case cObj=new case(); */
        List<casecomment> ccList =new List<casecomment>();

        if(isSTC == true || isRTB == true){

            if(isSTC == true){
            
                casecomment cc= new casecomment();            
                cc.parentid=csId;
                if(!(comment.containsIgnoreCase('(stc)'))){
                   cc.CommentBody='(STC)'+comment;        
                }
                else
                    cc.CommentBody= comment;
                ccList.add(cc);
            }
            if(isRTB == true){
                casecomment cc= new casecomment();
                cc.parentid=csId;
                if(!(comment.containsIgnoreCase('(rtb)'))){
                  cc.CommentBody='(RTB)'+comment;                
                }
                else
                    cc.CommentBody=comment;
                ccList.add(cc);
            }
        }
        else{
            casecomment cc= new casecomment();
            cc.parentid=csId;
            cc.CommentBody=comment;
            ccList.add(cc);           
        }
        
        /*cObj=[select id,casenumber,Template_Used__c from case where id=:csId];
if(cObj.Template_Used__c==null)
cObj.Template_Used__c=1;
else
cObj.Template_Used__c=cObj.Template_Used__c+1;
*/
        try{
            // update cObj;
            //            insert cc;
            system.debug('<<<'+ccList);
            
            insert ccList;
            //            System.debug('cr->'+cc);
            return 'Success';
        }catch(Exception e){
            System.debug('er->'+e);
            return 'Failed->'+string.valueof(e);
        }
    }
}