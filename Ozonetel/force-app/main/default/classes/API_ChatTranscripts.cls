@RestResource(urlMapping='/redBus/v1/getChatTranscripts/*')
global without sharing class API_ChatTranscripts
{    
    @HttpGet
    global static ChatResponse getChatTranscripts()
    {
        RestRequest request = RestContext.request;
        String epocFrmdte=RestContext.request.params.get('startFrom');
        String epocTodte=RestContext.request.params.get('endTo');
        
        system.debug('--reqS--'+epocFrmdte+'--reqEn--'+epocTodte);
       // String requestJson='{"fromDate":"01/05/2017","toDate":"12/05/2017"}';
       // RequestWrapper reqWrapObj=new RequestWrapper();
       // reqWrapObj=(RequestWrapper)JSON.deserialize(req.requestBody.toString(),RequestWrapper.class);
       
        ChatResponse resp=new ChatResponse();  
        list<LiveChatTranscript> chatTrnsList=new list<LiveChatTranscript>();
        list<chatTranscriptDetails> cDetails=new list<chatTranscriptDetails>();
        long frmDt;long toDt;
        
        if(string.isNotblank(epocFrmdte) && string.isNotblank(epocTodte)){
           frmDt=long.valueof(epocFrmdte);
           toDt=long.valueof(epocTodte);
        }else{
          resp.errormsg='Bad Request.From Date and To date are mandatory--Please input the  Values'; 
          resp.recordCount= 0;       
          return resp;
        }
        
        
        DateTime frmdte = DateTime.newInstance(frmDt * 1000);
        DateTime todte = DateTime.newInstance(toDt * 1000);
        
        if(todte < frmdte)
        {
          resp.errormsg='From Date should be less than To Date'; 
          resp.recordCount= 0;        
          return resp;
        }
        else
        {

        System.debug('mf-->'+frmdte+'<--mt-->'+frmdte);
        
        string chatStatus = system.label.LiveChatTranscript_Status;
        list<string> chatStatusList = new list<string>();
        chatStatusList = chatStatus.split(','); 
        
        chatTrnsList=[SELECT id,StartTime,Case.CaseNumber,Owner.Email,Chat_Ended_By__c,Sub_Issue_Type__c,CreatedBy.Name,Owner.Name,LiveChatDeployment.MasterLabel,LiveChatButton.MasterLabel,Name,EndTime,Issue_Type__c,Customer_Name__c,rating__c,Body,Chat_Session_Key__c,Source__c,Destination__c,Mobile_No__c,status,channel__c,ContactId FROM LiveChatTranscript where Status not in:chatStatusList and EndTime>:frmdte AND EndTime<:todte];       
        System.debug('-->chatTrnsList...'+chatTrnsList);
           
        if(!chatTrnsList.isEmpty())
        {
            resp.errormsg='';           
            resp.recordCount=chatTrnsList.size();
            List<ChatTranscriptDetails> lstChatDet = new List<ChatTranscriptDetails>();
            
            for(LiveChatTranscript ct:chatTrnsList)
            {               
                ChatTranscriptDetails ch=new ChatTranscriptDetails();
                ch.chatid=ct.Name;
                ch.issuetype=ct.Issue_Type__c;
                ch.customername=ct.Customer_Name__c;
                ch.subissuetype =ct.Sub_Issue_Type__c;
                ch.rating=ct.rating__c;
                ch.body=ct.body;
                ch.source=ct.Source__c;
                ch.destination=ct.Destination__c;
                ch.mobileno=ct.Mobile_No__c;   
                ch.status=ct.status;
                ch.chatstarttime = String.valueOf(ct.StartTime);
                ch.chatendtime= String.valueOf(ct.EndTime);
                ch.chatendedby = ct.Chat_Ended_By__c;
                ch.agentname = ct.Owner.Email;     
                ch.chatbutton = ct.LiveChatButton.MasterLabel;
                ch.chatdeployment = ct.LiveChatDeployment.MasterLabel;
                ch.caseNumber = ct.Case.CaseNumber;
                lstChatDet.add(ch);
            }
            resp.data.addAll(lstChatDet);           
            String chatJson=json.serialize(lstChatDet);
            System.debug('-->chatJson-->'+chatJson);                        
            return resp;
        }
        else{                
            resp.recordCount=0;        
            return resp;
        }
      }
    }
    
    
    global class ChatResponse{
        public list<ChatTranscriptDetails> data=new list<ChatTranscriptDetails>();
        public string errormsg;
        public integer recordCount;
        
    }
    global class ChatTranscriptDetails{
        public string chatid;
        public string issuetype;
        public string subissuetype;
        public string customername;
        public string rating;
        public string body;
        public string source;
        public string destination;
        public string mobileno;
        public string status;
        public string chatstarttime;
        public string chatendtime;
        public string chatendedby;
        public string agentname;
        Public string casenumber;
         
        public string chatbutton;
        public string chatdeployment;
    } 
 }