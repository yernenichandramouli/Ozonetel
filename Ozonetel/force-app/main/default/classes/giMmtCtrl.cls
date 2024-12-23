/*
* Name           : giMmtCtrl
* Created Date   : 17-OCT-2024
* Created By     : VR Sudarshan 
* Purpose        : Helper class that handles giMmt b2b flows.
* Test class     : giMmtCtrlTest
* Jira Id        : CRM-1983
*/
public class giMmtCtrl {

    //Method to iniate bus cancellation at seat seller.
    @future(callout=true)
    public static void initiateSSBusCancellation(string caseId){
        List<case> csLst=new List<case>();
        csLst=[select id,PNR__c, CaseNumber from case where Id=:caseId AND Channel_ct__c in ('MMT', 'GI') AND My_Desk_Id__c!=null AND PNR__c!=null];
        If(!csLst.isEmpty()){
            List<CaseComment> caseCommentListToInsert = new List<CaseComment>();
            List<DBLog_Summary__c> dbLogListToInsert = new List<DBLog_Summary__c>();
            try{
                for(case c: csLst){
                    DBLog_Summary__c  dbLogBC=new DBLog_Summary__c();  
                    dbLogBC.type__c ='GiMmt-Bus Cancellation Insert';
                    dbLogBC.Case_Number__c=c.CaseNumber;
                    API_EndPoints__mdt APIMData= [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='B2BBusCancellation'];   
                    user uObj=[select id,Phone,MobilePhone,email from user where id=:UserInfo.getUserID()];
                    string jsonBody='{"tin":"'+c.PNR__c+'","agentId":"'+uObj.email+'","message": "Initiated"}';  
                    OAuthGeneric oauthObj=new OAuthGeneric(); 
                    Http h= new Http();
                    HttpRequest req = new HttpRequest();
                    HttpResponse res = new HttpResponse();
                    req.setHeader('Accept', 'application/json');
                    req.setHeader('Content-Type', 'application/json');
                    req.setEndpoint(APIMData.Endpoint__c);
                    req.setMethod('POST');
                    req.setBody(jsonBody);    
                    System.debug('jsonBody-->'+jsonBody);
                    dbLogBC.Request_Data__c=string.valueof(req)+'Body :'+jsonBody;
                    dbLogBC.EndPoint__c = String.valueOf(req.getEndpoint());
                    res=h.send(req);
                    string busCResp= res.getBody();     
                    System.debug('busCResp->'+busCResp);
                    dbLogBC.Response_Received__c=busCResp;
                    dbLogBC.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                    dbLogBC.CallOut_Status__c = string.valueOf(res.getStatus());
                    dbLogListToInsert.add(dbLogBC);
                    map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(busCResp);
                    if(resObj!=null && string.valueof(resObj.get('status'))=='Initiated'){
                        CaseComment cc = new CaseComment();
                        cc.commentBody = 'The cancellation request has been initiated by the seat seller.';
                        cc.ParentId=c.id;
                        caseCommentListToInsert.add(cc);
                    }
                }
                if(!caseCommentListToInsert.isEmpty()){
                    Database.insert(caseCommentListToInsert);
                }
                if(!dbLogListToInsert.isEmpty()){
                    Database.insert(dbLogListToInsert);
                }
            }catch(Exception e){
                System.debug('::: Exception occured at Line no '+e.getLineNumber()+ ' with an error message of '+e.getMessage());
            }
            
        }
    }

    //Method to sync GiMmt Trasaction by pushing to redis
    @future(callout=true)
    public static void pushToRedisB2b(String pnrToSync){
        Map<String, String> dataMap = new Map<String, String>();
        Map<String, Object> jsonData = new Map<String, Object>();
        if(String.isNotBlank(pnrToSync)){
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.type__c ='PushToRedisMMTGI';
            Http ht = new Http();
            HttpRequest shrtReq = new HttpRequest();
            HttpResponse shrtResp = new HttpResponse();
            shrtReq = HttpRequestUtil.populateHeaders(shrtReq);
            dataMap.put(pnrToSync,'{}');
            jsonData.put('data', dataMap);
            jsonData.put('region', 'IND');
            List<string> redisDbNumList = System.Label.RedisDBNum.split(',');
            Integer redisNum = redisDbNumList.size()>=4?Integer.valueOf(System.Label.RedisDBNum.split(',')[3]):15;
            jsonData.put('dbNum', redisNum);
            shrtReq.setMethod('POST');  
            string finjsBody = JSON.serialize(jsonData);
            System.debug('jsBody...'+finjsBody ); 
            shrtReq.setBody(finjsBody);
            shrtReq.setTimeout(120000);
            API_EndPoints__mdt config = new API_EndPoints__mdt();
            config = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='PushToRedisB2b' limit 1];
            shrtReq.setendpoint(config.Endpoint__c);
            dbl.Request_Data__c = 'Request..'+shrtReq+'..'+shrtReq.getBody()+'..Response..'+shrtReq.getEndpoint();
            dbl.EndPoint__c = String.valueOf(shrtReq.getEndpoint());
            if(config.EnableLog__c){
                shrtResp=ht.send(shrtReq);
                dbl.Response_Received__c = String.valueOf(shrtResp+'...Body..'+shrtResp.getBody());
                dbl.CallOut_Status_Code__c = string.valueOf(shrtResp.getStatusCode());
                dbl.CallOut_Status__c = string.valueOf(shrtResp.getStatus());   
                insert dbl;
            }
        }
    }
}