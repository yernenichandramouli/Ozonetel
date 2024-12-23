/*
* Name           : API_BOCaseDetails
* Created Date   : 10 Feb 2020
* Created By     : Veeramanikanta R
* Purpose        : API for return case count details for each BO 
* Test class     : API_BOCaseDetailsTest
*/
@RestResource(urlMapping='/redBus/BOCasesDetails/*')
global without sharing class API_BOCaseDetails
{
    @HttpGet
    global static list<CaseCount> GetBOCasesCount()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<case> csList=new List<case>();
        
        csList=[select id,Status,casenumber,Service_Provider_Id__c,Service_Provider_Name__c,BO_Action__c from case where Country__c='India' and Service_Provider_Id__c!=null and issue_type__c='Bus Operator Service' and CreatedDate = LAST_N_DAYS:30];
        list<CaseCount> csWrpLs=new list<CaseCount>();
        set<string> allBOsLs=new set<string>();
        Map<string,integer> opCsMap=new Map<string,integer>();
        Map<string,integer> borespCsMap=new Map<string,integer>();
        System.debug('csList-->'+csList);
        for(case c:csList){
            System.debug('c-->'+c);
            CaseCount cw=new CaseCount();
            allBOsLs.add(c.Service_Provider_Id__c);
            cw.BOId=c.Service_Provider_Id__c;
          //  if(c.status!='Awaiting BO Response' && c.status!='Closed' && c.status!='BO Replied'){
            if((c.BO_Action__c==null || c.BO_Action__c<=0) && c.status!='Closed' ){
                if(opCsMap.get(c.Service_Provider_Id__c)!=null){
                    opCsMap.put(c.Service_Provider_Id__c,opCsMap.get(c.Service_Provider_Id__c)+1);
                }else{
                    opCsMap.put(c.Service_Provider_Id__c,1);
                }
            }
            if(c.status=='Awaiting BO Response'){
                if(borespCsMap.get(c.Service_Provider_Id__c)!=null){
                    borespCsMap.put(c.Service_Provider_Id__c,borespCsMap.get(c.Service_Provider_Id__c)+1);
                }else{
                    borespCsMap.put(c.Service_Provider_Id__c,1);
                }
            }
            
        }
        for(string s:allBOsLs){
            CaseCount ccw=new CaseCount();
            
            ccw.BOId=s;
            ccw.openCases=opCsMap.get(s);
            ccw.awaitingResponseCases=borespCsMap.get(s);
            csWrpLs.add(ccw);
        }
        
        System.debug('opCsMap-->'+opCsMap);
        System.debug('csWrpLs-->'+csWrpLs);
        return csWrpLs;
    }
    
    global class CaseCount{
        public string BOId;
        public integer openCases;    
        public integer awaitingResponseCases; 
    }        
}