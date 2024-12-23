/*
* Name           : FeedbackInsertScheduler
* Created Date   : 01 Jun 2020
* Created By     : Mahendra K
* Purpose        : Feedback insert for particular chatTranscript
*/
global class FeedbackInsertScheduler implements Schedulable {
  
   global void execute(SchedulableContext sc) {
        System.abortJob(sc.getTriggerId());
        System.schedule('Feedback Insert scheduler-- '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(Label.FeedBck_Insert_Time)).minute()+' */1 ? * *', this);
        feedBackinsert();
    }
    
   public  static void feedBackinsert() 
   {
      map<String,Live_Chat_Monitor__c> mapChatkeyIds = new map<String,Live_Chat_Monitor__c>();
      list<Live_Chat_Monitor__c> lstChatMntrs = new list<Live_Chat_Monitor__c>();
      map<id,LiveChatTranscript> maplvechatTrans= new map<id,LiveChatTranscript>();
      list<LiveChatTranscript> lstChatTrans = new list<LiveChatTranscript>();
      map<id,Case_Feedback__c> mapFdback= new map<id,Case_Feedback__c>();
      list<Case_Feedback__c> lstCfb=new list<Case_Feedback__c>();
      set<id> setCaseId=new set<id>();
        
     for(Live_Chat_Monitor__c lvechatMontr :[SELECT id,Chat_Session_Key__c,Reason__c,rating__c,channel__c,Submited_DateTime__c,Feedback_Details__c FROM Live_Chat_Monitor__c where (Feedback_Details__c!=null or rating__c!=null) and isChat__c=false])
      {
         mapChatkeyIds.put(lvechatMontr.Chat_Session_Key__c,lvechatMontr);
       
      }
    
     for(LiveChatTranscript lvechatTrans :[SELECT id,Feedback_Details__c,CaseId,ChatKey,Reason__c,Chat_Session_Key__c,rating__c,case.status,channel__c,ContactId,Name FROM LiveChatTranscript where Chat_Session_Key__c in :mapChatkeyIds.keySet()])
     {
       system.debug('---lvechatTrans----'+lvechatTrans);
       if(mapChatkeyIds.containsKey(lvechatTrans.Chat_Session_Key__c)){
            lvechatTrans.Feedback_Details__c=mapChatkeyIds.get(lvechatTrans.Chat_Session_Key__c).Feedback_Details__c;
            lvechatTrans.Rating__c= mapChatkeyIds.get(lvechatTrans.Chat_Session_Key__c).rating__c;
            lvechatTrans.Channel__c= mapChatkeyIds.get(lvechatTrans.Chat_Session_Key__c).channel__c;
            lvechatTrans.Reason__c= mapChatkeyIds.get(lvechatTrans.Chat_Session_Key__c).Reason__c;
            lvechatTrans.Submited_DateTime__c=system.now();
            lvechatTrans.id=lvechatTrans.id;
           lstChatTrans.add(lvechatTrans);
            
            Live_Chat_Monitor__c lchat =new Live_Chat_Monitor__c();
            lchat.isChat__c=true;
            lchat.id=mapChatkeyIds.get(lvechatTrans.Chat_Session_Key__c).id;
            lstChatMntrs.add(lchat);
            
         if(lvechatTrans.CaseId!=null && lvechatTrans.case.status=='closed'){
            
           maplvechatTrans.put(lvechatTrans.CaseId,lvechatTrans);
           setCaseId.add(lvechatTrans.CaseId);   
           system.debug('--setCaseId--'+setCaseId);
           }
         }
      }
      
      if(!lstChatTrans.isEmpty()){
        DataBase.update(lstChatTrans,false);
        DataBase.update(lstChatMntrs,false);
      }
      
      
                       
      for(Case_Feedback__c cfbcklst :[select id,Case_Name__c,Channel__c,rating__c,Reason__c from Case_Feedback__c where Case_Name__c in :setCaseId]){
              mapFdback.put(cfbcklst.Case_Name__c,cfbcklst);

      }
      
      for(id csId:setCaseId)
      {
         if(maplvechatTrans.containsKey(csId))
         {
                LiveChatTranscript transcpt = new LiveChatTranscript();
                transcpt = maplvechatTrans.get(csId);
                Case_Feedback__c cfb=new Case_Feedback__c();
                cfb.Rating__c=  transcpt.rating__c;
                cfb.Channel__c= transcpt.channel__c ;
                cfb.Reason__c=  transcpt.Reason__c ;
                cfb.Submited_DateTime__c=system.now();
                cfb.Case_Name__c =csId;
                
               if(mapFdback.containsKey(csId))
                 cfb.id=mapFdback.get(csId).id;
                 
                lstCfb.add(cfb);
        
         }
      }
      
      if(!lstCfb.isEmpty())
      {
        system.debug('--final update--'+lstCfb);
        DataBase.upsert(lstCfb,false);
      }
   }
}