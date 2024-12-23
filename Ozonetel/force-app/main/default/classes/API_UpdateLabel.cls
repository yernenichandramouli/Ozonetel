/*
* Name           : API_UpdateLabel
* Created Date   : 13 Jun 2022
* Created By     : Veeramanikanta R
* Purpose        : API to update Custom Labels
* Test class     : API_UpdateLabelTest
*/
@RestResource(urlMapping='/redBus/UpdateLabel/*')
global without sharing class API_UpdateLabel{
    @HttpPost
    global static ResponseWrapper UpdateLabel()
    {
        RestRequest req = RestContext.request;       
        RestResponse res = RestContext.response;
        ResponseWrapper resp=new ResponseWrapper();
        RequestWrapper  rqw= (RequestWrapper)JSON.deserialize(req.requestBody.toString(),RequestWrapper.class);   
        string boId;
        boId=rqw.boId;
        if(boId==null || string.isBlank(boId) ||rqw.status==null ||string.isBlank(rqw.status)){
            resp.message='BO Id or Status can\'t be empty';
            return resp;
        }
        string channel=req.headers.get('channel'); 
        string js='{"boId":"1234"}';       
        resp.boId=boId;
        

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,Bolt_Bo_ids_2__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
        Set<String> instantRefundBoIds;
        if(System.Label.BO_BOLT_Enable_Field=='Bolt_Bo_ids__c')
        instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
        else
        instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids_2__c.split(','));

        if(rqw.status=='add'){
            if(instantRefundBoIds.contains(boId)){
                resp.message='BO Id is already exists';
            }else{
                string status ='add';
                createUpdateMetaData(status,boId);
                resp.message='BO Id added successfully';
            }
        }else if(rqw.status=='remove'){
            if(!instantRefundBoIds.contains(boId)){
                resp.message = 'BO Id does not exists.';
            }
            createUpdateMetaData('remove',boId);
            resp.message='BO Id removed successfully';               
        } 
        
        return resp;
    }

    public static void createUpdateMetaData(string action, string boId){
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for(RPW_BO_ids__mdt objMetadata :[SELECT Id, Bolt_Bo_ids__c,Bolt_Bo_ids_2__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1]){
            Metadata.CustomMetadata metadataRec =  new Metadata.CustomMetadata();
            metadataRec.fullName = 'RPW_BO_ids__mdt.'+objMetadata.DeveloperName;
            metadataRec.label = objMetadata.MasterLabel;
            Metadata.CustomMetadataValue customFieldtoUpdate = new Metadata.CustomMetadataValue();
            if(System.Label.BO_BOLT_Enable_Field=='Bolt_Bo_ids__c'){
            customFieldtoUpdate.field = 'Bolt_Bo_ids__c';
            if(action =='add'){
                customFieldtoUpdate.value = objMetadata.Bolt_Bo_ids__c+','+boId;
            }else if(action == 'remove'){
                customFieldtoUpdate.value = objMetadata.Bolt_Bo_ids__c.replace(','+boId,'');
            }
            }else{
            customFieldtoUpdate.field = 'Bolt_Bo_ids_2__c';
            if(action =='add'){
                customFieldtoUpdate.value = objMetadata.Bolt_Bo_ids_2__c+','+boId;
            }else if(action == 'remove'){
                customFieldtoUpdate.value = objMetadata.Bolt_Bo_ids_2__c.replace(','+boId,'');
            }
            }
            metadataRec.values.add(customFieldtoUpdate);
            mdContainer.addMetadata(metadataRec);
        }
            system.debug('mdContainer**'+mdContainer); 
            Id jobId;
            if (!Test.isRunningTest()) {
            jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
            }
            updateBoList();
            system.debug('jobId***'+jobId);
    } 

    @future(callout=true)
    public static void updateBoList() {
        list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
        List<String> instantRefundBoIds = new List<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));

        if(!instantRefundBoIds.isEmpty()){
            String jsonBody='{"boltOperators":"'+string.join(instantRefundBoIds,',')+'"}';
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('cx_secure_hash', 'x5vuOAXurxUP3SyE6AlKlLIxeu38lCrS9ogDtg3K');
            req.setTimeout(120000);
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='updateSelfHelpBoltBOList'].Endpoint__c);
            req.setMethod('POST');
            req.setBody(jsonBody);

            System.debug(':: JSONBody ::: '+jsonBody);
    
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.Type__c = 'Update SelfHelp BoltBO Lisrt';
            dbl.Payment_Request_Sent_Time__c = system.now();
            dbl.Request_Data__c = string.valueof(req)+jsonBody;
            System.debug(':: Request ::: '+string.valueof(req)+jsonBody);
            dbl.SentAt__c = system.now();
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            try{
                res = http.send(req);
                System.debug(':: Response ::: '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                dbl.Payment_Request_Response_Time__c = System.now();
                insert dbl;
    
            }catch(Exception e){
                dbl.Response_Received__c =  String.valueOf(res+'..Body..'+res.getBody());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());                  
                insert dbl;
            }
        }
        
    }
    
    global class RequestWrapper{
        public string boId;
        public string name;
        public string status;
    }
    
    global class ResponseWrapper{
        public string boId;
        public string message;        
    }   
}