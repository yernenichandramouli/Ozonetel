/*
* Name           : API_GetBoIdCases
* Created Date   : 07 sep 2022
* Created By     : 
* Purpose        : API for return cases with Bo Id
* Test class     : API_GetBoIdCasesTest
*/
@RestResource(urlMapping='/redBus/GetBoIdCases/*')
global without sharing class API_GetBoIdCases
{
    global static set<string> splitBoids= new set<string>();
    global static list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
    global static boolean instantRefundFeature;
    
    @HttpGet
    global static recordsFound getCases()
    { 
        RestRequest request = RestContext.request;
        List<case> caseList=new  List<case>();
        list<caseDetails> cDetails=new list<caseDetails>();
        
        string channel=request.headers.get('channel');
        String lstBoIds=RestContext.request.params.get('lstBoIds');
        
        if(channel=='RB+'){  
            Map<String,String>  mapQueries = new Map<String,String>();
            for(DataDeletionSetup__mdt dd:[SELECT Id,DeveloperName,QueryDetails__c FROM DataDeletionSetup__mdt where DeveloperName IN('RedProwinALL') ])
            {
                mapQueries.put(dd.DeveloperName,dd.QueryDetails__c);
            }
            
            if(lstBoIds!=null){
                for(string s:lstBoIds.split(',')){
                    splitBoids.add(s);
                }
                
                caseList= DataBase.query(string.valueOf(mapQueries.get('RedProwinALL')));
            }   
            
            recordsFound rf=new recordsFound();  
            caseDetails cd;
            
            if(!caseList.isEmpty()){
                for(case c:caseList){
                
                    Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
                    if(string.isNotBlank(c.Service_Provider_Id__c) && instantRefundBoIds.contains(c.Service_Provider_Id__c) ){
                       instantRefundFeature=true;
                    }else{
                       instantRefundFeature=false;
                    }  
                    
                    cd=new caseDetails(c.casenumber,c.Service_Provider_Id__c,c.Bus_Operator_Namee__c,c.status,string.valueOf(c.createdDate),c.Refund_Type__c,instantRefundFeature);
                    cDetails.add(cd);
                    rf.caseRecords='Yes';
                    rf.caseDetails.add(cd); 
                }
                String casesJson=json.serialize(cDetails);
                System.debug('casesJson-->'+casesJson);                        
                return rf;
            }else{                
                rf.caseRecords='No Cases Found';         
                return rf;
            }  
            
        }else{
             recordsFound rf=new recordsFound(); 
             rf.caseRecords='Please add channel in headers';
            return rf;
        } 
        
        
    }
    
    global class recordsFound{
        public list<caseDetails> caseDetails=new list<caseDetails>();
        public string caseRecords;
        
    }
    
    global class caseDetails{
        public string caseNumber;
        public string boId;
        public string vendorName;
        public string status;
        public string createdDateTime;
        public string instantRefund;
        public boolean instantRefundFeature;
        
        public caseDetails(string caseNumber,string boId,string vendorName,string status,string createdDateTime,string instantRefund,boolean instantRefundFeature){
            this.caseNumber=caseNumber;
            this.boId=boId;
            this.vendorName=vendorName;
            this.status=status;
            this.createdDateTime=createdDateTime;
            this.instantRefund=instantRefund;
            this.instantRefundFeature=instantRefundFeature;
            
        }
        
    }
}