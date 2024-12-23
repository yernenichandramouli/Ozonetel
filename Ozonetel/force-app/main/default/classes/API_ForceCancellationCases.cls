/*
* Name           : API_ForceCancellationCases
* Created Date   : 27 Jan 2021
* Created By     : Mahendra Reddy
* Purpose        : API for requested to fetch ForceCancellation Cases
* Test class     : API_Get_Cases_Test
*/
@RestResource(urlMapping='/redBus/getForceCancellationCases/*')
global without sharing class API_ForceCancellationCases
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
        String requestJson='{"operatorid":"1234","fromDate":"01/05/2017","toDate":"12/05/2017"}';
        RequestWrapper reqWrapObj=new RequestWrapper();
        reqWrapObj=(RequestWrapper)JSON.deserialize(req.requestBody.toString(),RequestWrapper.class);
        System.debug('reqWrapObj-->'+reqWrapObj);        
        list<case> cList=new list<case>();
        list<caseDetails> cDetails=new list<caseDetails>();
        DateTime mf;
        DateTime mt;
        if(string.isNotBlank(reqWrapObj.fromDate)&&string.isNotBlank(reqWrapObj.toDate)){
         mf=setStringToDateFormat(reqWrapObj.fromDate,'fD');
         mt=setStringToDateFormat(reqWrapObj.toDate,'tD');
        //  mf=mf.addDays(-1);
        System.debug('mf a r-->'+mf);
        
        mf=DateTime.newInstanceGMT(mf.year(),mf.month(),mf.day(),18,30,00);
        mt=DateTime.newInstanceGMT(mt.year(),mt.month(),mt.day(),18,29,59);
        
        System.debug('mf-->'+mf+'<--mt-->'+mt);
        
        }
        
        if(string.isNotBlank(reqWrapObj.operatorid)){
        cList=[select id,TIN_No__c,TIN__c,SS_DOJ__c,casenumber,SS_Route_Id__c,Issue_Type__c,Issue_Sub_Category__c,createdDate,Description,Service_Provider_Id__c,Trip_Id_ct__c,Total_Ticket_Amount__c,Refund_Amount__c,Service_Provider_Name__c,Seats__c,FC_Cancelled_Seats__c,Date_of_Issue_of_Ticket__c,ClosedDate,Status,Force_Cancellation_Status__c,FC_Denied_Reason__c,Force_Cancellation_Charges__c,Closed_By__c from Case where Issue_Type__c='Force Cancellation' and Service_Provider_Id__c =:reqWrapObj.operatorid and Country__c =:reqWrapObj.country];       
        }
        
       /* if(string.isNotBlank(reqWrapObj.country)){
        cList=[select id,TIN_No__c,TIN__c,SS_DOJ__c,casenumber,SS_Route_Id__c,Issue_Type__c,Issue_Sub_Category__c,createdDate,Description,Service_Provider_Id__c,Trip_Id_ct__c,Total_Ticket_Amount__c,Refund_Amount__c,Service_Provider_Name__c,Seats__c,FC_Cancelled_Seats__c,Date_of_Issue_of_Ticket__c,ClosedDate,Status,Force_Cancellation_Status__c,FC_Denied_Reason__c,Force_Cancellation_Charges__c,Closed_By__c from Case where Issue_Type__c='Force Cancellation' and Country__c =:reqWrapObj.country];       
        }*/
        
        if(mf!=null&& mt!=null){
        cList=[select id,TIN_No__c,TIN__c,SS_DOJ__c,casenumber,SS_Route_Id__c,Issue_Type__c,Issue_Sub_Category__c,createdDate,Description,Service_Provider_Id__c,Trip_Id_ct__c,Total_Ticket_Amount__c,Refund_Amount__c,Service_Provider_Name__c,Seats__c,FC_Cancelled_Seats__c,Date_of_Issue_of_Ticket__c,ClosedDate,Status,Force_Cancellation_Status__c,FC_Denied_Reason__c,Force_Cancellation_Charges__c,Closed_By__c from Case where Issue_Type__c='Force Cancellation' and createdDate>:mf AND createdDate<:mt and Country__c =:reqWrapObj.country];       
        }
        
        System.debug('==========>'+cList);
        caseDetails cd;
        recordsFound rf=new recordsFound();  
        
        if(!cList.isEmpty()){          
            for(case c:cList){
                string routeIdValue=c.SS_Route_Id__c;
                string tinValue=c.TIN_No__c;
                if(c.TIN_No__c==null)tinValue=c.TIN__c;
                
                cd=new caseDetails(c.casenumber,c.Issue_Type__c,c.Issue_Sub_Category__c,string.valueOf(c.createdDate),c.Description,c.Trip_Id_ct__c,c.Service_Provider_Id__c,tinValue,string.valueOf(c.SS_DOJ__c),c.Total_Ticket_Amount__c,string.valueOf(c.Refund_Amount__c),c.Service_Provider_Name__c,c.Seats__c,c.FC_Cancelled_Seats__c,string.valueOf(c.Date_of_Issue_of_Ticket__c),string.valueOf(c.ClosedDate),c.status,c.Force_Cancellation_Status__c,c.FC_Denied_Reason__c,string.valueOf(c.Force_Cancellation_Charges__c),c.Closed_By__c);
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
        public string operatorid;
        public string fromDate;
        public string toDate;
        public string country;
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
        public string TripId;
        public string serviceProviderId;
        public string tin;
        public string doj; 
        public string totalTicketAmnt;
        public string refundAmnt;
        public string serviceProviderName;
        public string Seats;
        public string CancelledSeats;
        public string dateofIssue;
        public string closedDate;
        public string Status;
        public string ForcecanclStatus;
        public string FcDinedReason;
        public string FCcharges;
        public string ClosedBy;
        //public string 
              
        
        public caseDetails(string caseNumber,string issueType,string subIssueType,string createdDate,string description,string TripId,string serviceProviderId,string tin,string doj,string totalTicketAmnt,string refundAmnt,string serviceProviderName,string Seats,string CancelledSeats,string dateofIssue,string closedDate,string Status,string ForcecanclStatus,string FcDinedReason,string FCcharges,string ClosedBy){
            this.caseNumber=caseNumber;
            this.issueType=issueType;
            this.subIssueType=subIssueType;
            this.createdDate=createdDate;
            this.description=description;
            this.TripId=TripId;
            this.serviceProviderId=serviceProviderId;
            this.tin=tin;
            this.doj=doj;  
            this.totalTicketAmnt=totalTicketAmnt;
            this.refundAmnt=refundAmnt;
            this.serviceProviderName=serviceProviderName;
            this.Seats=Seats;
            this.CancelledSeats=CancelledSeats;
            this.dateofIssue=dateofIssue;
            this.closedDate=closedDate;
            this.Status=Status;
            this.ForcecanclStatus=ForcecanclStatus;
            this.FcDinedReason=FcDinedReason;
            this.FCcharges=FCcharges;
            this.ClosedBy=ClosedBy;
                      
        }
        
    } 
    
}