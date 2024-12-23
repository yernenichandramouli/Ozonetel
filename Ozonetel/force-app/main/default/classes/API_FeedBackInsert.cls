/*
* Name           : API_FeedBackInsert
* Created Date   : 12 may 2020
* Created By     : Mahendra K
* Purpose        : Feedback insert for particular case
*/
@RestResource(urlMapping='/redBus/FeedBackInsert/*')
global class API_FeedBackInsert
{
    @HttpPost
    global static ResponseFeedBackDetails feedbackdetails()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ResponseFeedBackDetails resp=new ResponseFeedBackDetails();
        try{
            system.debug('----entered line no 18');
            feedInformation  cd= (feedInformation)JSON.deserialize(req.requestBody.toString(),feedInformation.class); 
            system.debug('----json-----'+cd);
            if(String.isBlank(cd.rating)){
                res.statuscode = 400;
                resp.casenumber=cd.casenumber;
                resp.errorMessage='Rating can not be empty';
                return resp;
             }else if('Bad'.equalsIgnoreCase(cd.rating) && string.IsBlank(cd.reason)){
                res.statuscode = 400;
                resp.casenumber=cd.casenumber;
                resp.errorMessage='Reason can not be empty for the Bad Rating';
                return resp;
            }else if(String.isNotBlank(cd.chatsessionId) && String.isNotBlank(cd.casenumber)){
                res.statuscode = 400;
                resp.casenumber=cd.casenumber;
                resp.sessionId=cd.chatsessionId;
                resp.errorMessage='please Enter any one from sessionId Or Casenumber';
                return resp;
            }else if(String.isBlank(cd.chatsessionId)&&String.isBlank(cd.casenumber))
            {
                res.statuscode = 400;
                resp.casenumber=cd.casenumber;
                resp.sessionId=cd.chatsessionId;
                resp.errorMessage='Please Enter chatsessionId or casenumber';
                return resp;
            }
            else if(String.isNotBlank(cd.chatsessionId)){
                list<Live_Chat_Monitor__c> chatTranList = new list<Live_Chat_Monitor__c>();
                list<Live_Chat_Monitor__c> lstChatMntrInsert = new list<Live_Chat_Monitor__c>();
                chatTranList=[SELECT id,Chat_Session_Key__c,Reason__c,Feedback_Details__c,rating__c,Channel__c,Submited_DateTime__c FROM Live_Chat_Monitor__c where Chat_Session_Key__c=:cd.chatsessionId ];
                 dateTime submitedTime=system.now();
                string logResponse='[{"channel":"'+cd.channel+'","rating":"'+cd.rating+'","submiteddate":"'+submitedTime+'","reason":"'+cd.reason+'"}]';
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('chatFeedBackInsert','',cd.chatsessionId,'',logResponse,'','');

                if(!chatTranList.isEmpty()){
                   boolean firstTimeInsert=false;
                   boolean updateRating=false;
                     if(string.isBlank(chatTranList[0].Feedback_Details__c)){
                        string jsonFirstTime='[{"channel":"'+cd.channel+'","rating":"'+cd.rating+'","submiteddate":"'+submitedTime+'","reason":"'+cd.reason+'"}]';
                        chatTranList[0].Feedback_Details__c=jsonFirstTime;
                        firstTimeInsert=true;
                      }else{
                       string existJson=chatTranList[0].Feedback_Details__c;
                       string jsonew='{"channel":"'+cd.channel+'","rating":"'+cd.rating+'","submiteddate":"'+submitedTime+'","reason":"'+cd.reason+'"}';
                       feedWrapper fedWrapDetails=(feedWrapper)System.JSON.deserialize(jsonew,feedWrapper.class);
                       map<string,object> newFedMap= (map<string,object>)JSON.deserializeUntyped(jsonew);
                       System.debug('newFedmap-->'+newFedMap);
                       List<feedWrapper> respWrapper=(List<feedWrapper>)System.JSON.deserialize(existJson,List<feedWrapper>.class);
                        Map<string,feedWrapper> mpF=new  Map<string,feedWrapper>();
                        list<feedWrapper> fdList=new List<feedWrapper>();
                        for(feedWrapper fd:respWrapper){
                        if(fd.channel==fedWrapDetails.channel){
                            fd.rating=fedWrapDetails.rating;
                               updateRating=true;                
                         }
                          mpF.put(fd.channel,fd); 
                         fdList.add(fd);
                        }
                      
                         string ssT1=JSON.serialize(fdList);
                         chatTranList[0].Feedback_Details__c=ssT1;
                           if(mpF.get(fedWrapDetails.channel)==null){
                           string ssT=JSON.serialize(fdList);
                            chatTranList[0].Feedback_Details__c=ssT.removeend(']')+','+jsonew+']';
                             }
                           System.debug('fdList HH--->'+fdList);         
                      }
                   if(firstTimeInsert && !chatTranList.isEmpty()){
                       chatTranList[0].isChat__c=false;
                       chatTranList[0].rating__c=cd.rating;
                       chatTranList[0].Reason__c=cd.reason;
                       chatTranList[0].Channel__c=cd.channel;
                       chatTranList[0].Submited_DateTime__c=system.now();
                       update chatTranList;
                       res.statuscode = 200;
                       resp.sessionId=chatTranList[0].Chat_Session_Key__c;
                       resp.errorMessage='Rating successfully submitted'; 
                   }else if(updateRating && !chatTranList.isEmpty()){
                       chatTranList[0].isChat__c=false;
                       chatTranList[0].rating__c=cd.rating;
                       chatTranList[0].Reason__c=cd.reason;
                       chatTranList[0].Channel__c=cd.channel;
                       chatTranList[0].Submited_DateTime__c=system.now();
                       update chatTranList;
                       res.statuscode = 200;
                       resp.sessionId=chatTranList[0].Chat_Session_Key__c;
                       resp.errorMessage='Rating is updated successfully'; 
                   }else{
                       chatTranList[0].isChat__c=false;
                       chatTranList[0].rating__c=cd.rating;
                       chatTranList[0].Reason__c=cd.reason;
                       chatTranList[0].Channel__c=cd.channel;
                       chatTranList[0].Submited_DateTime__c=system.now();
                       update chatTranList;
                       res.statuscode = 200;
                       resp.sessionId=chatTranList[0].Chat_Session_Key__c;
                       resp.errorMessage='Rating successfully submitted'; 
                   }
                }
                else{
                    res.statuscode = 400;
                    resp.sessionId=cd.chatsessionId;
                    resp.errorMessage='Session Id is not available';
                }
             }else{
                // case number csat start
                List<case> csseList= new List<case>(); 
                boolean updFdbckVals =false;
                boolean insertFdbckVals=false;
                Map<string,string> mapChannel=new Map<string,string>();
                Map<string,string> mapRating=new Map<string,string>();
                list<Case_Feedback__c> fdbckLst = new list<Case_Feedback__c>();
                csseList=[select id,casenumber,Closed_By__c,status from case where status ='Closed' and casenumber =:cd.casenumber];
                if(!csseList.isEmpty()){
                    List<Case_Feedback__c> cfbList=[select id,Reason__c,Submited_DateTime__c,Case_Name__c,Channel__c,Rating__c from Case_Feedback__c where Case_Number__c=:csseList[0].casenumber and Channel__c=:cd.channel];
                    
                if(!cfbList.isEmpty()){  
                  for(Case_Feedback__c cf:cfbList){  
                    if(cd.channel==cf.Channel__c && cd.Rating!=cf.rating__c){  
                        cf.Rating__c=cd.rating;
                        cf.Reason__c =cd.reason;
                        cf.Channel__c=cd.channel;
                        cf.Submited_DateTime__c=system.now();  
                        updFdbckVals=true;
                        insertFdbckVals=false;
                        fdbckLst.add(cf); 
                      
                     }else if(cd.channel==cf.Channel__c && cd.Rating==cf.rating__c){
                        res.statuscode = 200;
                        resp.casenumber=cd.casenumber;
                        resp.errorMessage='Rating is Already submitted';
                     }
                   }
                    
                   if(!fdbckLst.isEmpty() && updFdbckVals){
                        DataBase.update(fdbckLst,false);
                        res.statuscode = 200;
                        resp.casenumber=csseList[0].casenumber;
                        resp.errorMessage='Rating is updated successfully ';
                   }
                   
                    
                  }else{
                        Case_Feedback__c cfb=new Case_Feedback__c();
                        cfb.Rating__c=cd.rating;
                        cfb.Reason__c=cd.reason;
                        cfb.Channel__c=cd.channel;
                        cfb.Case_Name__c =csseList[0].id;
                        cfb.Case_Closed_By__c=csseList[0].Closed_By__c;
                        cfb.Submited_DateTime__c=system.now();
                        
                        Database.saveResult insertResult = Database.insert(cfb,false);
                        res.statuscode = 200;
                        resp.casenumber=csseList[0].casenumber;
                        resp.errorMessage='Rating successfully submitted'; 
                  }  
   
                }
                else{
                    res.statuscode = 400;
                    resp.casenumber=cd.casenumber;
                    resp.errorMessage='Case is not available or case is not colsed';
                    
                }  
            }
        }catch(Exception e){
            res.statuscode = 417;
            resp.errorMessage='Failed-->'+string.valueof(e);
        }
        return resp;
    }
    
    global class feedInformation
    {
        public string casenumber;
        public string chatsessionId;
        public string rating;
        public datetime submitteddate;
        public string channel;
        public string reason;
        
    }
    
    global Class ResponseFeedBackDetails
    {
        public String casenumber;
        public String errorMessage;
        public string sessionId;
        
    }
    public class feedWrapper{
    public string channel;
    public string rating;
    public string submiteddate;
}
}