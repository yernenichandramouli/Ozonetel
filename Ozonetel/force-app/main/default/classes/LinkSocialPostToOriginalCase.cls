/** Assumsion : Case to social Post Is one to one map , this is code based on some logic assigns one specific Social post from case A to case B and deleats case A **/

Public Class LinkSocialPostToOriginalCase
{ 
    Public static void Link(list<SocialPost> FromTrigger) 
    {  
        map<Id,SocialPost> CheckCaseOrigin=new map<Id,SocialPost>();
        map<Id,SocialPost> OriginalCase=new map<Id,SocialPost>(); 
        map<Id,Id> ReplyTo=new map<Id,Id>();     
        
        list<case> DeleteCases=new list<case>();
        set<id> DeleteCasesId=new set<id>();
            
        for(SocialPost SP : FromTrigger)
        {       
               if(SP.ReplyToId!=null && SP.Name.contains('Comment From:'))
               {           
                    ReplyTo.put(SP.ParentId,SP.ReplyToId);
                    CheckCaseOrigin.put(SP.ReplyToId,SP);
               }
        }
           
        Set<Id> CaseIds=CheckCaseOrigin.keySet();
        list<case> CaseList=[SELECT id,Origin FROM Case WHERE id =:CaseIds and (Origin='Facebook' OR Origin='Twitter')];
        list<SocialPost> OriginalSocialPostList=[SELECT id,ParentId FROM SocialPost WHERE id IN : ReplyTo.values() AND ParentId!=Null];       
        
        for(SocialPost SP : OriginalSocialPostList)
        {
            OriginalCase.put(Sp.id,SP);        
        }  
        
        set<id> ReplyToIds=OriginalCase.KeySet();
        
        for(Id i : ReplyToIds)
        {
            if(CheckCaseOrigin.containskey(i))
            {
                DeleteCasesId.add(CheckCaseOrigin.get(i).ParentId);
                CheckCaseOrigin.get(i).ParentID=OriginalCase.get(i).ParentID;    
            }
        }
           
        DeleteCases=[SELECT id FROM case WHERE id IN:DeleteCasesId];
        
        if(DeleteCases!=null)
        {
            System.debug('DeleteCases------>'+DeleteCases);
            try{
                Delete DeleteCases;
            }
            catch(Exception e)
            {
                System.debug('Exception----->'+e);
            }
        }
        }     
}