public with sharing class Chat_Transcript_Case_Create {
    public list<Order_Items__c> orilst{get;set;}
    public list<lead> leadList{get;set;}
    public Case cs{get;set;}
    public String tripId{get;set;}
    public Id ctId;
    public string popupDescription{get;set;}
    public string chatSummerization{get;set;}
    
    public Chat_transcript_case_create()
    {       
        ctId = ApexPages.CurrentPage().getParameters().get('Id');
        system.debug('ctId---->>'+ctId);
        cs = new Case();
        orilst = new list<Order_Items__c>();
        leadList=new list<lead>();
        displayCreateCase=false;
        isWhatsappChat=false;
        Boolean isEnableChatCaseCreate= Boolean.valueOf(System.Label.EnableChatCaseCreate);  
        if(String.isNotBlank(ctId)){
                
            cs.OwnerId=UserInfo.getUserId();
            cs.Country__c = [SELECT id,name,Country from User WHERE Id=:UserInfo.getUserId()].Country;
            cs.Business_Type__c = [SELECT id,name,Business_Type__c from User WHERE Id=:UserInfo.getUserId()].Business_Type__c;
            cs.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('InBound Call').getRecordTypeId();
            
            List<MessagingSession> ms = [select id,caseId from MessagingSession where id =:ctId];
            if(ms.size()>0){
                isWhatsappChat=true;
                displayCreateCase=true;
                cs.Origin='Chat Whatsapp';
                cs.Channel_ct__c='Whatsapp';
            }
            //Predicted_Issue_Type__c
            List<LiveChatTranscript> lct = [select id,Chat_Session_Key__c, Tin_Number__c,Order_Uuid__c,OrderItem_Uuid__c,status,TCode__c,Predicted_Sub_Issue_Type__c from LiveChatTranscript where id =:ctId];
            if(lct.size()>0){
            system.debug('>>>>>>>>>>>>>>'+lct[0].Chat_Session_Key__c);
                if(lct[0].Chat_Session_Key__c!=null){
                  List<Live_Chat_Monitor__c> lmc = [select id,Chat_Summarize__c,Action__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:lct[0].Chat_Session_Key__c];
                   if(string.isNotBlank(lmc[0].Chat_Summarize__c)){
                      chatSummerization=lmc[0].Chat_Summarize__c;
                   }
                   
                   if(lmc[0].Action__c=='Chat Ended' && isEnableChatCaseCreate){
                     displayCreateCase=true;
                   }
                 }
                  
                if(cs.Business_Type__c =='BusHire'){
                    cs.Origin='Chat Website';                
                }
                if(string.isNotBlank(lct[0].Predicted_Sub_Issue_Type__c)){
                     cs.Predicted_Sub_Issue_Type__c = lct[0].Predicted_Sub_Issue_Type__c;
                }
                if(string.isNotBlank(lct[0].TCode__c)){
                   leadList=[select id,TCode__c from lead where TCode__c=:lct[0].TCode__c];
                   if(!leadList.isEmpty()){
                      cs.Lead__c=leadList[0].id;
                   }
                }
                
                if(lct[0].status == 'InProgress' && !isEnableChatCaseCreate)   
                    displayCreateCase=true;
                    
                if(lct[0].Order_Uuid__c != null & lct[0].Order_Uuid__c !=''){
                    orilst = [Select Id,Recordtypeid,Business_Unit__c,Order_Id__c,Customer_Name__c,Customer_Name__r.Phone_10_Digits__c,Customer_Name__r.PersonEmail From Order_Items__c Where Order_Uuid__c =:lct[0].Order_Uuid__c];
                }
                if(!orilst.isEmpty()){
                    tripId=orilst[0].Order_Id__c;
                    cs.Phone_No_ct__c=orilst[0].Customer_Name__r.Phone_10_Digits__c;
                    cs.Email_Id_ct__c=orilst[0].Customer_Name__r.PersonEmail;
                    System.debug('tat notfi 3'+orilst[0].Customer_Name__r.PersonEmail);
                    cs.TAT_Notifier_Email__c=orilst[0].Customer_Name__r.PersonEmail;
                    System.debug('tat notfi'+cs.TAT_Notifier_Email__c);
                    cs.Transaction_ID__c=orilst[0].Id;
                    cs.Business_Unit_ct__c=orilst[0].Business_Unit__c;
                    if(orilst[0].recordtypeid==Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId()){
                        cs.Type='B2B';
                        cs.Partner__c='Amazon';
                    }                    
                }
            }
        }
    }
    public pageReference saveMethod()
    {
        try
        {
            if(cs.Does_Customer_Require_CallBack__c)               
                cs.CallBack_Requested_Time__c = cs.CallBack_Requested_Time__c!=null?System.now().addHours(Integer.valueOf(cs.Call_Back_Time__c)):null;
            
            System.debug('pop up des-->'+popupDescription);         
            System.debug('Customer Name-->'+cs.Customer_Name__c+'Issue_Type__c--'+cs.Issue_Type__c);
            if('Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) && 'B2B'.equalsIgnoreCase(cs.Type)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Create bus canellation case from Initiate Bus Cancellation button at Transcation Level'));
                return null;
            }else {
                system.debug('<<<<displayPopup'+displayPopup);
                system.debug('<<<case number '+cs.CaseNumber);
                Insert cs;
                System.debug('Case ID after insert-->'+cs.Id);
                System.debug('Customer Name after insert-->'+cs.Customer_Name__c);
                CaseComment cc=new CaseComment();
                cc.parentid=cs.id;
                
                if(string.isNotBlank(chatSummerization)){
                  cc.commentbody='Summary ->'+chatSummerization;
                  insert cc;
               } 
                
                if(ctid!=null){
                    List<LiveChatTranscript> lct = [select id,Chat_Summarize_Edit__c,caseId,Leadid,Lead__c from LiveChatTranscript where id =:ctId];
                    system.debug('<<<ENtered inside if condition');
                    if(lct.size()>0){
                        lct[0].caseId=cs.id;
                        if(string.isNotBlank(chatSummerization)){
                          lct[0].Chat_Summarize_Edit__c ='Summary ->'+chatSummerization;
                        }
                        if(!leadList.isEmpty()){
                        lct[0].Leadid=leadList[0].id;
                        lct[0].Lead__c=leadList[0].id;
                        }
                        
                        update lct;
                        system.debug('<<<lct'+lct);
                    }
                    List<MessagingSession> ms = [select id,caseId from MessagingSession where id =:ctId];
                    system.debug('<<<ENtered inside if condition');
                    if(ms.size()>0){
                        ms[0].caseId=cs.id;
                        update ms;
                        system.debug('<<<ms'+ms);
                    }      
                              }
                System.debug('Customer Name after insert-->'+cs.Customer_Name__c);
                //              alert('Case '+cs.casenumber+'is created');                
                PageReference pRef = new PageReference('/'+ctId);
                return pRef;
                
            }
        }
        catch(exception e){ApexPages.addMessages(e); return null;}
        
    }
    
    public boolean displayPopup {get;set;}
    public boolean displayCreateCase {get; set;}
    public boolean isWhatsappChat {get; set;}
    
    public pageReference showPopup()
    { 
        System.debug('calling showPopup');
        
        system.debug('ctId --->>'+ctId);
        if(String.isNotBlank(ctId)){
            List<LiveChatTranscript> lct = [select id, Tin_Number__c from LiveChatTranscript where id =:ctId];
            system.debug('lct'+lct);
            if(lct.size()>0){
                list<Order_Items__c> oiList =[select id from Order_Items__c where Order_Item_Reference_No__c=:lct[0].Tin_Number__c limit 1];
                system.debug('oiList'+oiList);
                if(oiList.size()>=1){
                    list<case> clist=[select id,parentId,status,Transaction_ID__c from Case where Transaction_ID__c=:oiList[0].id and status!='Closed'];
                    System.debug('size here-->'+clist.size()); 
                    if(clist.size()>=1){  
                        System.debug('size here 2-->'+clist.size());   
                        displayPopup = true;
                        system.debug('<<<displayPopup'+displayPopup);
                    }
                    else{
                        saveMethod();
                        System.debug('after savemethod');
                        PageReference pRef = new PageReference('/'+ctId);
                        return pRef;  
                        
                    }
                } 
            }
            else{
                List<MessagingSession> ms = [select id,caseId from MessagingSession where id =:ctId];
                if(ms.size()>0){
                    saveMethod();
                    System.debug('after savemethod');
                    PageReference pRef = new PageReference('/'+ctId);
                    return pRef; 
                } 
            }
        }
        return null;
    }
    
    public void closePopup() {
        system.debug('<<<'+displayPopup);
        displayPopup = false;       
    }
    //Added below method 
    public pageReference Cancel(){
        PageReference pref = new PageReference('/'+ctId);
        return pref;
    }
    
}