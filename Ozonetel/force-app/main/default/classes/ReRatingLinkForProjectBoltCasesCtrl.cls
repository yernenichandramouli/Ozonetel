/*
* Name           : ReRatingLinkForProjectBoltCasesCtrl
* Created Date   : 18 OCT 2022
* Created By     : VR Sudarshan 
* Purpose        : ReRating Link for project Bolt Cases
* Test class     : ReRatingLinkForProjectBoltCasesCtrlTest
* Jira Id        : CRM-1221
*/
global class ReRatingLinkForProjectBoltCasesCtrl implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    public string query;
    public string GenericAPIEndpoint;
    public API_EndPoints__mdt APIMData;

    public ReRatingLinkForProjectBoltCasesCtrl(String strQuery) {
        APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI2'];     
        GenericAPIEndpoint=APIMData.Endpoint__c;

        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }
        else {
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='ReRatingLinkBoltCases'].QueryDetails__c;
        }
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug(':::: Query :::: '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){
        List<case> caseListToUpdate = New List<case>();
        List<DBLog_Summary__c> dbLogListToUpdate = new List<DBLog_Summary__c>();
        DateTime startDate = system.now();
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='ReRatingLink_BoltCases'];
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');

        if(!lstcases.isEmpty()){
            for(case c: lstcases){
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                dbl.type__c ='ReRating Link For Bolt Cases';
                boolean isPreStatus=false;
                String allPreviousStatus=String.isNotBlank(c.All_Previous_Status_Dates__c)?c.All_Previous_Status_Dates__c:'';
                List<String> values = allPreviousStatus.split(';');
                for(String value:values){
                    if(value.Contains('Re-Open')){  
                        isPreStatus=true;
                    }
                }
                Decimal hours = Integer.valueOf((startDate.getTime() - c.Closed_Date_and_Time__c.getTime())/(1000*60*60));
                if(test.isRunningTest()){
                    hours=80;
                }
                if(hours>72 && isPreStatus == false){
                    try{
                        string endPoint=APIMData.Endpoint__c+c.TIN__c+'&TravelsName='+c.Service_Provider_Name__c+'&ReRating='+true+'&CaseId='+c.Id;
                        list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
                        for(string o:headers.keyset()){
                            hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o)));
                        }
                        String headerJson=json.serialize(hlist); 
                        String headerJson2=json.serialize(headerJson); 
                        string genericJson='{"action":"POST","endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
                        System.debug('genericJson-->'+genericJson);
                        Http http = new Http();
                        HttpRequest req = new HttpRequest();
                        HttpResponse res = new HttpResponse();
                        req = HttpRequestUtil.populateHeaders(req); 
                        req.setMethod('POST');
                        req.setEndpoint(GenericAPIEndpoint);
                        req.setBody(genericJson);
                        res = http.send(req);
                        dbl.Request_Data__c = string.valueof(req)+genericJson;
                        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                        dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                        dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                        dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                        string responseValue = res.getBody();
                        if(responseValue=='\"SUCCESS\"' && res.getStatusCode()==200){
                            c.isReratingLink_Sent__c = true;
                            caseListToUpdate.add(c);
                        }
                        dbLogListToUpdate.add(dbl);
                    }catch(Exception e){
                        dbl.Exception_Description__c=string.valueOf(e);
                        dbLogListToUpdate.add(dbl);
                        System.debug('An exception occurred: ' + e.getMessage());
                }
                }
            }
            if(!caseListToUpdate.isEmpty()){
                DataBase.update(caseListToUpdate);
            }

            if(!dbLogListToUpdate.isEmpty()){
                insert dbLogListToUpdate;
            }
        }
    }

    global void finish(DataBase.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com'});
        mail.setSubject('ReRating Link for Project Bolt Cases '+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}