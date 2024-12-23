/*
* Name           : NPSBusDetractorController 
* Created Date   : 8 Aug 2018
* Created By     : Mahendra k
* Purpose        : Used for Agents to give NPS ratings and reviews for Bus transactions
* Test class     : NPSBusDetractorControllerTest
*/
public class NPSBusDetractorController {
   
    public date doj{get;set;}
    public date submitdate{get;set;}
    public List<case> caseList{get;set;}
    public string comment{get;set;}
    public string selCsId{get;set;}
    public string requestId{get;set;}
    public boolean popupCS{get;set;}
    public string tinNo{get;set;}
    
    public NPSBusDetractorController(){
        caseList=new list<case>();
        popupCS=false;
    }
    public void search()
    {
        system.debug('doj==>>'+doj);
        system.debug('submitdate==>>'+submitdate);
        caseList=new list<case>();
        caseList.clear();
        Id userId = UserInfo.getUserID();
        String qry = 'SELECT id,casenumber,OwnerId,SS_DOJ__c,Issue_Type__c,transaction_id__r.name,transaction_id__r.id,Source_And_Destination__c,Nps_Response_Date__c,Issue_Sub_Category__c,Request_Id__c,TIN_No__c,Phone_No_ct__c,Email_Id_ct__c,NP_Score__c,Bus_Operator_Namee__c,Location__c,No_Of_Rooms__c,Feedback__c,Status,Origin from case  where  status!=\'Closed\' and Origin=\'NPS Bus\' and Issue_Type__c =\'NPS\' and Issue_Sub_Category__c= \'NPS Bus\' AND OwnerId=:userId ';
        System.debug('caseList..'+caseList.size());
        String dum ='';
        if(doj != null && submitdate !=null)
        {
            DateTime tempDOJ = doj.addDays(-1);
            DateTime startDOJ = DateTime.newInstanceGMT(tempDOJ.year(),tempDOJ.month(),tempDOJ.day(),18,30,00);
            DateTime endDOJ = DateTime.newInstanceGMT(doj.year(),doj.month(),doj.day(),18,29,59);
            System.debug('doj..'+doj);

            DateTime subDate = submitdate.addDays(-1);
            DateTime startSubDOJ = DateTime.newInstanceGMT(subDate.year(),subDate.month(),subDate.day(),18,30,00);
            DateTime endSubDOJ = DateTime.newInstanceGMT(submitdate.year(),submitdate.month(),submitdate.day(),18,29,59);
            dum  = doj+'..'+startSubDOJ+'..'+endSubDOJ;
            System.debug('startSubDOJ..'+startSubDOJ+'..endSubDOJ..'+endSubDOJ+'..'+subDate);
            qry =qry+' And ((SS_DOJ__c=:doj) OR (Nps_Response_Date__c>=:startSubDOJ AND Nps_Response_Date__c<=:endSubDOJ)) limit 200';
            System.debug('..qry41..'+qry);
            caseList = DataBase.query(qry);
    
        }
         
        else if(doj !=null)
        {
            DateTime tempDOJ = doj.addDays(-1);
            DateTime startDOJ = DateTime.newInstanceGMT(tempDOJ.year(),tempDOJ.month(),tempDOJ.day(),18,30,00);
            DateTime endDOJ = DateTime.newInstanceGMT(doj.year(),doj.month(),doj.day(),18,29,59);
            qry =qry+' And (SS_DOJ__c=:doj) limit 200 ';
            dum =String.valueOf(doj);
              System.debug('..qry51..'+qry);
               caseList = DataBase.query(qry);
        }
        
        else if(submitdate !=null)
        {
            DateTime subDate = submitdate.addDays(-1);
            DateTime startSubDOJ = DateTime.newInstanceGMT(subDate.year(),subDate.month(),subDate.day(),18,30,00);
            DateTime endSubDOJ = DateTime.newInstanceGMT(submitdate.year(),submitdate.month(),submitdate.day(),18,29,59);
            qry =qry+' AND (Nps_Response_Date__c>=:startSubDOJ AND Nps_Response_Date__c<=:endSubDOJ) limit 200';
            dum =startSubDOJ +'..'+endSubDOJ ;
              System.debug('..qry60..'+qry);
               caseList = DataBase.query(qry);
        }
   

       else
        {
            qry =qry+' limit 200';
              System.debug('..qry65..'+qry);
               caseList = DataBase.query(qry);
             // dum  = 'else dum..';
        }
        System.debug('Final Query..'+qry);
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,String.valueOf(caseList.size())+'..'+dum+'..'+qry));
        caseList = DataBase.query(qry);
        system.debug('caseList==>>'+caseList);
    }
    public void caseUpdate()   {
        case csobj=[select id,status,casenumber,Email_Id_ct__c from case where id=:selCsId];
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
            dbl.Type__c = 'NPS Bus Detractor';
            //dbl.Payment_Request_Sent_Data__c=string.valueof(req.getBody());
            dbl.Request_Data__c = string.valueof(req.getBody());
            try{
                res=h.send(req);
                //dbl.Payment_Request_Response_Data__c=res.getBody();
                dbl.Response_Received__c = res.getBody();
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                if(res.getstatusCode()==200 && res.getstatus()=='OK' && String.isNotBlank(res.getBody()))
                {
                    map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                    System.debug('res obj-->'+resObj.get('url'));
               
                    if(resObj.get('url')!='')
                    {
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
                    }
                    else
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'API Response Is Invalid..'));
                }
                else
                {
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
        public integer BusinessUnit=0;
        public integer CountryCode=1;
        public integer Language=1;
        public string AgentName;
        public string OrderNumber;
        public Request(string requestId,string comments,string tinNo, string agentname){
            this.RequestId=requestId;
            this.Comments=comments;
            this.OrderNumber=tinNo;
            this.AgentName=agentname;
        }        
    }
}