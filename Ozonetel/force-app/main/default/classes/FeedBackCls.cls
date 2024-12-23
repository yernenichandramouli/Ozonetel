global class FeedBackCls {
    
    global Case_Feedback__c cf{get;set;}
    global boolean msg{get;set;}
    global string  UCId{get;set;}
    global boolean childCase{get;set;}
    global FeedBackCls()
    {
        msg = false;
        childCase=false;
    }
    global PageReference sfInsert()
    {
     UCId=apexpages.currentpage().getparameters().get('UCId');
     if(string.isNotblank(UCId)){
      PageReference myVFPage = new PageReference('/apex/IVRCallFeedback?UCId='+UCId);
      myVFPage.setRedirect(true);
      return myVFPage;
      }else {
        string cid=apexpages.currentpage().getparameters().get('cid');
        string rating=apexpages.currentpage().getparameters().get('rate');
        string timeStamp = apexpages.currentpage().getparameters().get('dateT');
        boolean ro=false;
        
        case cs=[SELECT id,ClosedDate,Closed_By__c,ParentId,CaseNumber FROM case WHERE id=:cid];

        list<Case_Feedback__c> cfb=new list<Case_Feedback__c>();
      if(cs.ParentId==null){
        if(cs.ClosedDate!=Null)
        {
         // List<Case_Feedback__c> cfbList=[select id,Submited_DateTime__c,Case_Name__c,Channel__c,Rating__c from Case_Feedback__c where Case_Number__c=:cs.CaseNumber and Channel__c=''];
           for(Case_Feedback__c c:[SELECT id,createdDate,Channel__c,Case_Closed_By__c,Time_Stamp__c,Submited_DateTime__c FROM Case_Feedback__c WHERE Case_Number__c =:cs.CaseNumber and Channel__c='Email-web'])
            {
                ro=true;
                break;
                system.debug('+++++++++++++'+c.createdDate);
                system.debug('+++++++++++++'+cs.closedDate);
                cfb.add(c);
            }
           system.debug('---no feedback--'); 
        } 
        if(ro==true)
        {
            msg=false;
            system.debug('msg=false'+ro);
        }
        if(ro==false)
        {
           system.debug('--insert--'+ro);
            cf=new Case_Feedback__c();
            cf.Case_Name__c=cid;
            cf.Rating__c=rating;
            cf.Channel__c='Email-web';
            cf.Time_Stamp__c = timeStamp;
            cf.Case_Closed_By__c=cs.Closed_By__c;
            system.debug('--cf--'+cf);
            insert cf;
            msg=true;
        }
     }else{
      childCase=true;
     }
   }
   
    return null;
 }
}