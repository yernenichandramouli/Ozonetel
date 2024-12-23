/**
* Name           : NPSDetractorController 
* Created Date   : 13 June 2018
* Created By     : Veeramanikanta
* Purpose        : Used for Agents to give NPS ratings and reviews for Hotel transactions
*
**/
public class NPSDetractorController {
    public date checkinDate{get;set;}
    public date fromDate{get;set;}
    public date toDate{get;set;}
    public List<case> caseList{get;set;}
    public string comment{get;set;}
    public string selCsId{get;set;}
    public string requestId{get;set;}
    public boolean popupCS{get;set;}
    public string tinNo{get;set;}
    
    public NPSDetractorController(){
        caseList=new list<case>();
        popupCS=false;
    }
    public void search(){
        caseList=[select id,casenumber,CheckIn_Date__c,Request_Id__c,TIN_No__c,Phone_No_ct__c,Email_Id_ct__c,NP_Score__c,Hotel_Name__c,Location__c,No_Of_Rooms__c,Feedback__c,Status,Origin from case where CheckIn_Date__c>=:fromDate and CheckIn_Date__c<=:toDate and status!='Closed' and OwnerId=:UserInfo.getUserID()];
        popupCS=true;
    } 
    
    public void caseUpdate(){
        case csobj=[select id,status,casenumber from case where id=:selCsId];
         String userName=UserInfo.getName()+'('+UserInfo.getUserName()+')';
        if(csobj.status=='Closed'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Email is already sent to customer'));
        }else{
            
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            Request reWrap=new Request(requestId,comment,tinNo,userName);
            String jsonBody=JSON.serialize(reWrap);
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type','application/json');
            
            jsonBody=JSON.serialize(jsonBody);
            System.debug('jsonBody-->'+jsonBody); 
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='NPSDetractor_Resend'];
            string jsonCM='{"action":"Post","body":'+jsonBody+',"endPoint":"'+APIMData.Endpoint__c+'","headers":"","isIncreasedTimeout":true}';
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
            HTTP h = new HTTP();
            System.debug('jsonCM-->'+jsonCM); 
            HttpRequest req= new HttpRequest();
            HTTPResponse res=new HTTPResponse();        
            req = HttpRequestUtil.populateHeaders(req);               
            req.setMethod('POST');
            req.setBody(jsonCM);
            req.setEndpoint(APIMData.Endpoint__c);  
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.Type__c = 'NPS Detractor';
            //dbl.Payment_Request_Sent_Data__c=string.valueof(req.getBody());
            dbl.Request_Data__c = string.valueof(req.getBody());
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            try{
                res=h.send(req);
                //dbl.Payment_Request_Response_Data__c=res.getBody();
                dbl.Response_Received__c = res.getBody();
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                
                System.debug('res-->'+res);
                System.debug('selCsId-->'+selCsId);
                string mockJs='{ "url": "https://nps.redbus.in/home/survey?token=598430043410&hash=1L6tplf4iPzvjtxhh7kF2FUd-IU7eQAC1lOm_kipbrw" }';
                map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                System.debug('res obj-->'+resObj.get('url'));
                // if(resObj!=null){
                if(resObj.get('url')!=''){
                    case cObj=new case();
                    casecomment cc=new casecomment();
                    cc.parentid=selCsId;
                    cc.commentbody=comment;
                    insert cc;
                    cObj.id=selCsId;
                    cObj.status='Closed';
                    cObj.nps_url__c=string.valueof(resObj.get('url'));
                    update cObj;
                    popupCS=true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,csObj.casenumber+'->Email sent successfully'));
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'API failed'));
                }
            }catch(Exception e){
                dbl.Exception_Description__c='Error-->'+e;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Something went wrong, Please try again. Error-->'+e));
            }
            insert dbl ;
        }       
    }
    
    public class Request{
        public string Comments;
        public string RequestId;
        public integer BusinessUnit=6;
        public integer CountryCode=1;
        public string AgentName;
        public integer Language=1;
        public string OrderNumber;
        public Request(string requestId,string comments,string tinNo,string agentname){
            this.RequestId=requestId;
            this.Comments=comments;
            this.OrderNumber=tinNo;
            this.AgentName=agentname;
        }        
    }
    
}