/*
* Name           : API_Get_Cases
* Created Date   : 16 May 2017
* Created By     : Veeramanikanta R
* Purpose        : API for requested Bus Operator Service Cases
* Test class     : API_Get_Cases_Test
*/
@RestResource(urlMapping='/redBus/getCases/*')
global without sharing class API_Get_Cases
{
    global static DateTime setStringToDateFormat(String myDate,string check) {
        String[] myDateOnly = myDate.split(' ');
        String[] strDate = myDateOnly[0].split('/');
        Integer myIntDate;
        
        if(check=='fd'){
            myIntDate = integer.valueOf(strDate[0])-1;
            System.debug('myIntDate -->'+myIntDate );
        }else{
            myIntDate = integer.valueOf(strDate[0]);
        }
        
        Integer myIntMonth = integer.valueOf(strDate[1]);
        Integer myIntYear = integer.valueOf(strDate[2]);
        DateTime d = DateTime.newInstanceGMT(myIntYear, myIntMonth, myIntDate);
        System.debug('ret-->'+d);
        return d;
    }
    
    @HttpPost
    global static recordsFound getCases()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestJson='{"serviceProviderId":"1234","fromDate":"01/05/2017","toDate":"12/05/2017","routeIds":[2333,2434]}';
        RequestWrapper reqWrapObj=new RequestWrapper();
        reqWrapObj=(RequestWrapper)JSON.deserialize(req.requestBody.toString(),RequestWrapper.class);
        System.debug('routeIds-->'+reqWrapObj.routeIds);        
        list<case> cList=new list<case>();
        list<caseDetails> cDetails=new list<caseDetails>();
        
        DateTime mf=setStringToDateFormat(reqWrapObj.fromDate,'fD');
        DateTime mt=setStringToDateFormat(reqWrapObj.toDate,'tD');
        //  mf=mf.addDays(-1);
        System.debug('mf a r-->'+mf);
        
        mf=DateTime.newInstanceGMT(mf.year(),mf.month(),mf.day(),18,30,00);
        mt=DateTime.newInstanceGMT(mt.year(),mt.month(),mt.day(),18,29,59);
        
        System.debug('mf-->'+mf+'<--mt-->'+mt);
        
        cList=[select id,TIN_No__c,TIN__c,SS_DOJ__c,casenumber,status,SS_Route_Id__c,Issue_Type__c,Issue_Sub_Category__c,createdDate,Description,Service_Provider_Id__c,Route_Id__c from Case where (SS_Route_Id__c in:reqWrapObj.routeIds OR Route_Id__c in:reqWrapObj.routeIds)  AND Service_Provider_Id__c =: reqWrapObj.serviceProviderId AND createdDate>:mf AND createdDate<:mt AND Issue_Type__c='Bus Operator Service'];       
        
        set<id> sids=new set<id>();
        sids.add('500p0000003H4Ji');
        sids.add('500p0000003a0ut');
        //cList=[select id,casenumber,status,SS_Route_Id__c,Issue_Type__c,Issue_Sub_Category__c,createdDate,Description,Service_Provider_Id__c from Case where id in:sids];
        caseDetails cd;
        recordsFound rf=new recordsFound();  
        
        if(!cList.isEmpty()){          
            for(case c:cList){
                string routeIdValue=c.SS_Route_Id__c;
                string tinValue=c.TIN_No__c;
                if(c.SS_Route_Id__c==null)routeIdValue=c.Route_Id__c;
                if(c.TIN_No__c==null)tinValue=c.TIN__c;
                
                cd=new caseDetails(c.casenumber,c.Issue_Type__c,c.Issue_Sub_Category__c,string.valueOf(c.createdDate),c.Description,routeIdValue,c.Service_Provider_Id__c,tinValue,string.valueOf(c.SS_DOJ__c));
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
    }
    
    global class RequestWrapper{
        public string serviceProviderId;
        public string fromDate;
        public string toDate;
        public list<string> routeIds;
    }
    
    global class recordsFound{
        public list<caseDetails> caseDetails=new list<caseDetails>();
        public string caseRecords;
        
    }
    global class caseDetails{
        public string caseNumber;
        public string issueType;
        public string subIssueType;
        public string createdDate;
        public string description;
        public string routeId;
        public string serviceProviderId;
        public string tin;
        public string doj;        
        
        public caseDetails(string caseNumber,string issueType,string subIssueType,string createdDate,string description,string routeId,string serviceProviderId,string tin,string doj){
            this.caseNumber=caseNumber;
            this.issueType=issueType;
            this.subIssueType=subIssueType;
            this.createdDate=createdDate;
            this.description=description;
            this.routeId=routeId;
            this.serviceProviderId=serviceProviderId;
            this.tin=tin;
            this.doj=doj;           
        }
        
    } 
    
}