/*
* Name           : API_TripCaseDetails
* Created Date   : 04 MARCH 2019
* Created By     : Sreenivas M
* Purpose        : Returns the list cases related to particular trip
*/
@RestResource(urlMapping='/redBus/TripCaseDetails/*')
global without sharing class API_TripCaseDetails
{
    global static RestResponse res;
    global static list<String> internalIssueTypes;
    global static Set<String> setMoboileNum;
    public static Set<String> SkipInternalBusnsType = new Set<String>(System.label.Internal_Business_Type.split(','));
    
    @HttpPost
    global static ResponseCaseDetails casedetails()
    {
        
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'Case Trip Details';
        
        RestRequest req = RestContext.request;
        setMoboileNum = new Set<String>();
        res = RestContext.response;
        ResponseCaseDetails resp=new ResponseCaseDetails();
        list<ResponesCase> respcslst = new  list<ResponesCase>();
        System.debug('res s-->'+req.requestBody.toString());
        dbl.Endpoint__c =req.requestURI;
        caseinformation  cd= (caseInformation)JSON.deserialize(req.requestBody.toString(),caseInformation.class); 

        
        String strQry ='select id,casenumber,createddate,TAT_Value__c,RR_SLA_Priority__c,TIN_No__c,Trip_Id_ct__c,Issue_Type__c,Issue_Sub_Category__c,status,Phone_No_ct__c,parent.casenumber,notes__c,Date_of_Journey__c from case where';
        string channel=req.headers.get('Channel');
        dbl.Request_Data__c=req.requestBody.toString();
        dbl.SyncedFrom__c =channel;
        
        if('IVR-Ameyo'.equalsIgnoreCase(channel)){
      
            if(string.isBlank(cd.mobile) || cd.mobile.length() < 8)
            {
                res.statuscode = 400;
                resp.error='Failed To Process The Request.Invalid Input Received';
                resp.errorDescription = 'Mobile number is Missing/Wrong';    
                dbl.CallOut_Status_Code__c = '400';
                dbl.Response_Received__c = resp.errorDescription;
                insert dbl;                 
                return resp;
            }else{
                
                String updatedMobile = cd.mobile.length()==10?+'91'+cd.mobile:cd.phoneCode+cd.mobile;               
                setMoboileNum.add(cd.mobile);
                setMoboileNum.add(updatedMobile);
                if ('B2B'.equalsIgnoreCase(cd.status))
                	strQry = strQry+' Inventory_Type__c = \'Amazon\' AND issue_type__c NOT IN:internalIssueTypes AND Business_Type__c not in:SkipInternalBusnsType AND createddate = LAST_N_DAYS:30  AND (Phone_No_ct__c IN :setMoboileNum OR Booking_Mobile_No__c IN:setMoboileNum OR Signed_in_User_Mobile__c IN :setMoboileNum) order by lastmodifieddate desc';
                else if('All'.equalsIgnoreCase(cd.status))
                    strQry = strQry+' issue_type__c NOT IN:internalIssueTypes AND Type!=\'B2B\' AND Business_Type__c not in:SkipInternalBusnsType AND createddate = LAST_N_DAYS:30  AND (Phone_No_ct__c IN :setMoboileNum OR Booking_Mobile_No__c IN:setMoboileNum OR Signed_in_User_Mobile__c IN :setMoboileNum) order by lastmodifieddate desc';
                else
                    strQry = strQry+' Status!=\'Closed\' AND  issue_type__c not in:internalIssueTypes AND Business_Type__c not in:SkipInternalBusnsType AND (Phone_No_ct__c IN :setMoboileNum OR Booking_Mobile_No__c IN:setMoboileNum OR Signed_in_User_Mobile__c IN :setMoboileNum)';
                resp=getQueryResult(strQry);
                 dbl.CallOut_Status_Code__c ='200';
                dbl.Response_Received__c = String.valueOf(resp);
                insert dbl;  
                return resp;
            }
        }else{
            if(string.isBlank(cd.tin) && string.isBlank(cd.tripid))
            {
                res.statuscode = 400;
                resp.error='Failed To Process The Request.Invalid Input Received';
                resp.errorDescription = 'TripId Or Tin Details is Missing';    
                dbl.CallOut_Status_Code__c = '400';
                dbl.Response_Received__c = String.valueOf(resp.errorDescription);
                insert dbl;         
                return resp;
            }
            else 
            {
                if(String.isNotBlank(cd.tripid))
                    strQry = strQry+' Trip_Id_ct__c =\''+cd.tripid+'\' AND ';
                
                if(String.isNotBlank(cd.tin))
                    strQry = strQry+' TIN_No__c=\''+ cd.tin+'\' AND ';
                
                if(String.isNotBlank(cd.issuetype))
                    strQry = strQry+' Issue_Type__c=\''+cd.issuetype+'\' AND ';
                
                if(String.isNotBlank(cd.subissuetype))
                    strQry = strQry+' Issue_Sub_Category__c=\''+cd.subissuetype+'\'';
                
                strQry = strQry.removeEnd('AND ');
                
                System.debug('Final Query..'+strQry);
                resp=getQueryResult(strQry);
                dbl.CallOut_Status_Code__c ='200';
                dbl.Response_Received__c = String.valueOf(resp);
                insert dbl;    
                return resp;
            }
        }
    }         
    
    global static ResponseCaseDetails getQueryResult(string query){
    System.debug('query-->'+query);
       internalIssueTypes= new list<String>(); 
       internalIssueTypes.addAll(System.Label.Internal_IssueTypes.split(','));  
        ResponseCaseDetails resp=new ResponseCaseDetails();
        res = RestContext.response;
        try
        {
            resp.listCases = new List<ResponesCase>();
            integer count=0;
            for(case cs:DataBase.query(query))
            {
                ResponesCase resCs = new ResponesCase();
                resCs.casenumber=cs.casenumber;
                resCs.tin=cs.TIN_No__c;
                resCs.tripId = cs.Trip_Id_ct__c;
                resCs.issuetype=cs.Issue_Type__c;
                resCs.subissuetype=cs.Issue_Sub_Category__c;
                resCs.status=cs.status; 
                resCs.tatValue=cs.TAT_Value__c;
                resCs.tatcrossed = (resCs.tatValue>0 && cs.RR_SLA_Priority__c==1)?true:false;
               // resCs.createdDateTime=string.valueOf(cs.createddate.addminutes(-330));
                resCs.createdDateTime=string.valueOf(cs.createddate);             
                resCs.doj=string.valueof(cs.Date_of_Journey__c);
                resCs.notes=cs.notes__c;
                resCs.parentCaseNumber=cs.parent.casenumber;
                count=count+1;
                resp.listCases.add(resCs);
            }
            
            res.statuscode = 200;
            resp.caseCount=count;
            resp.error = '';
            resp.errorDescription ='';
        }
        Catch(Exception e)
        {
            res.statuscode = 417;
            resp.error = 'An Error Occured While Processing';
            resp.errorDescription =String.valueOf(e);
        }
        return resp;
    }
    
    global class caseInformation
    {
        public string tin;
        public string tripid;
        public string issuetype;
        public string subissuetype;
        public string mobile;
        public string status;
        public string phoneCode;
    }
    
    global Class ResponseCaseDetails
    {
        public String error;
        public String errorDescription;
        public integer caseCount;
        public List<ResponesCase> listCases;
        
    }
    
    global Class ResponesCase
    {
        public string casenumber;
        public string issuetype;
        public string subissuetype;
        public string tin;
        public string status;
        public string tripId;
        public decimal tatValue;
        public boolean tatcrossed;   
        public string parentCaseNumber;
        public string createdDateTime;  
        public string doj;
        public string notes; 
    }   
}