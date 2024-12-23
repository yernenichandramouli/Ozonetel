public class CaseIssuesController{
public static integer userTripsCounter=0;
    
    @AuraEnabled(Cacheable=true)
    public static List<IssuesWrapper> fetchIssues(string caseId){
        system.debug('caseid-->'+caseId);
        case csObj=new case();
        csObj=[select id,Selected_Issues__c from case where id=:caseId];
        List<Case_Issues__mdt> csIssuesLs=new List<Case_Issues__mdt>();
        csIssuesLs=[select id,masterlabel,Issue__c,issue_no__c from Case_Issues__mdt];
        
        List<string> caseIssuesLs=new List<string>();
        if(string.isNotBlank(csObj.Selected_Issues__c)){
            caseIssuesLs=csObj.Selected_Issues__c.split(',');
        }
        List<IssuesWrapper> iwList=new List<IssuesWrapper>();
        integer indexRow=0;
        for(Case_Issues__mdt c:csIssuesLs){
            IssuesWrapper iw=new IssuesWrapper();
            iw.issueName=c.Issue__c;
            iw.issueNo=c.masterlabel;
            if(!caseIssuesLs.isEmpty() && caseIssuesLs.contains(string.valueOf(c.issue_no__c)))
                iw.isChecked=true;
            else
                iw.isChecked=false;
            
            iw.index=indexRow;  
            iwList.add(iw); 
            indexRow++;
        }
        return iwList;
    }
    
    @Auraenabled(cacheable=true)
    public static string GetPastTransactionDetails(string caseId){
        system.debug('caseId TT-->'+caseId);
        case csObj=new case();
        csObj=[select id,tat_notifier_email__c,Phone_No_ct__c,Booking_Mobile_No__c from case where id=:caseId];
        API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='FetchPastTransactionDetails'];
        
        String emailId = String.isNotBlank(csObj.tat_notifier_email__c)?csObj.tat_notifier_email__c:'NA';
        String mobileNo = String.isNotBlank(csObj.Phone_No_ct__c)?csObj.Phone_No_ct__c:String.isNotBlank(csObj.Booking_Mobile_No__c)?csObj.Booking_Mobile_No__c:'NA';
        
        string endPoint;
        if(mobileNo!='NA'){
            endPoint=APIMData.Endpoint__c+'NA&mob='+mobileNo;
        }else if(emailId!='NA'){
            endPoint=APIMData.Endpoint__c+emailId+'&mob=NA';
        }else{
            endPoint=APIMData.Endpoint__c+emailId+'&mob='+mobileNo;
        }
        // endPoint='http://10.5.4.97:8080/userData?emailid=nilika.haldar@redbus.com&mob=NA';
        System.debug('endPointH-->'+endPoint);
        string jsBody='';
        string jsonCM='{"action":"GET","body":"","endPoint":"'+endPoint+'","headers":""}';
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        req.setHeader('Channel_Name','WEB_DIRECT');
        req.setHeader('Content-Type','application/json');
        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
        req.setHeader('Country_Name', 'IND'); 
        req.setHeader('BusinessUnit', 'BUS');  
        req.setHeader('Language', 'en');             
        req.setMethod('POST');
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
        req.setEndpoint(APIMData.Endpoint__c);
        req.setBody(jsonCM);
        resp = ht.send(req);
        System.debug('resp-->'+resp);
        System.debug('resp-->'+resp.getBody());
        string respBody=resp.getBody();
        
        return respBody;
    }
    
    @Auraenabled(cacheable=true)
    public static string GetPastCaseDetails(string caseId){
        system.debug('caseId TT-->'+caseId);
        case cObj=new case();
        cObj=[select id,Booking_Mobile_No__c,Phone_No_ct__c,TAT_Notifier_Email__c  from case where id=:caseId];
        string fromDate='2019001';
        string toDate='2022005';
        string jsReqBody='{ "tat_notifier_email__c": "'+cObj.TAT_Notifier_Email__c+'", "Phone_No_ct__c": "'+cObj.Phone_No_ct__c+'", "Booking_Mobile_No__c": "'+cObj.Booking_Mobile_No__c+'", "from_date": "'+fromDate+'", "to_date": "'+toDate+'" }';
        //jsReqBody='{ "tat_notifier_email__c": "", "Phone_No_ct__c": "", "Booking_Mobile_No__c": "918884580492", "from_date": "2021005", "to_date": "2022001" }';
        API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='FetchPastCaseDetails'];
        
        /*string emailId='';
string mobileNo='';
string endPoint=APIMData.Endpoint__c+emailId+'&mob='+mobileNo;
endPoint='http://10.5.4.97:8080/userData?emailid=nilika.haldar@redbus.com&mob=NA';
string jsBody='';
string jsonCM='{"action":"GET","body":"","endPoint":"'+endPoint+'","headers":""}';
*/
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        req.setHeader('Channel_Name','WEB_DIRECT');
        req.setHeader('Content-Type','application/json');
        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
        req.setHeader('Country_Name', 'IND'); 
        req.setHeader('BusinessUnit', 'BUS');  
        req.setHeader('Language', 'en');             
        req.setMethod('POST');
        req.setBody(jsReqBody);
        req.setEndpoint(APIMData.Endpoint__c);
        resp = ht.send(req);
        System.debug('resp-->'+resp);
        System.debug('resp-->'+resp.getBody());
        string respBody=resp.getBody();
        // string respBody='[{ "caseNumber": "123", "issue": "Bus break down", "subIssue": "No Refund" }, { "caseNumber": "879", "issue": "Seat damanged", "subIssue": "Seat issue" } ]';
        // respBody='[ { "subIssueType": null, "issuetype": "Call Drop", "caseNumber": "15965189", "Notes": null, "tin": null, "tripId": null, "DateOfCreation": "2021-05-12T14:37:58.000Z", "open_date_and_time__c": "2021-05-12T14:37:58.000Z", "status": "Closed", "operatorId": null, "isRTC": false }, { "subIssueType": "Initiate Bus Cancellation", "issuetype": "Bus Cancellation", "caseNumber": "16093357", "Notes": null, "tin": "TQ7N25695119", "tripId": "12995429794578081", "DateOfCreation": "2021-06-23T08:44:01.000Z", "open_date_and_time__c": "2021-06-23T08:44:01.000Z", "status": "Rejected For Bus Cancellation", "operatorId": "15926", "isRTC": false }, { "subIssueType": "I was charged extra fare for this booking", "issuetype": "Booking Issues", "caseNumber": "16097823", "Notes": null, "tin": "TQ7N25695119", "tripId": "12995429794578081", "DateOfCreation": "2021-06-24T11:23:45.000Z", "open_date_and_time__c": "2021-06-24T11:23:45.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Help with availability of my preferred bus", "issuetype": "Need help to make a new bus tick", "caseNumber": "16119493", "Notes": null, "tin": "TQ7N25695119", "tripId": "12995429794578081", "DateOfCreation": "2021-06-29T12:26:02.000Z", "open_date_and_time__c": "2021-06-29T12:26:02.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Initiate Bus Cancellation", "issuetype": "Bus Cancellation", "caseNumber": "16417866", "Notes": null, "tin": "TQ9H58545248", "tripId": "13035761942647657", "DateOfCreation": "2021-08-25T12:12:52.000Z", "open_date_and_time__c": "2021-08-25T12:12:52.000Z", "status": "Rejected For Bus Cancellation", "operatorId": "8516", "isRTC": false }, { "subIssueType": "Poor bus quality", "issuetype": "Bus Operator Service", "caseNumber": "16985138", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-12T11:00:20.000Z", "open_date_and_time__c": "2021-11-12T11:00:20.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Rude staff behavior", "issuetype": "I felt unsafe during the journey", "caseNumber": "17096945", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-25T06:33:52.000Z", "open_date_and_time__c": "2021-11-25T06:33:52.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Boarding / Dropping point changed", "issuetype": "Bus Operator Service", "caseNumber": "17096951", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-25T06:34:26.000Z", "open_date_and_time__c": "2021-11-25T06:34:26.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "My bus driver demanded additional fare", "issuetype": "Bus Operator Service", "caseNumber": "17099159", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-25T11:08:39.000Z", "open_date_and_time__c": "2021-11-25T11:08:39.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Initiate Bus Cancellation", "issuetype": "Bus Cancellation", "caseNumber": "16677592", "Notes": null, "tin": "TQB432353858", "tripId": "13069547434287890", "DateOfCreation": "2021-10-08T14:28:39.000Z", "open_date_and_time__c": "2021-10-08T14:28:39.000Z", "status": "Rejected For Bus Cancellation", "operatorId": "15926", "isRTC": false } ]';
        return respBody;
    }
    
    @AuraEnabled
    public static string saveIssues(string caseId,string upIssues){
        
        system.debug('upIssues-->'+upIssues);   
        List<IssuesWrapper> issWrapperLs=new List<IssuesWrapper>(); 
        issWrapperLs = (List<IssuesWrapper>)JSON.deserialize(upIssues,List<IssuesWrapper>.class);
        case cs=new case();
        cs.id=caseId;
        string selIssues;
        for(IssuesWrapper is:issWrapperLs){
            if(is.isChecked){
                if(string.isBlank(selIssues))
                    selIssues=is.issueNo.replaceall('I_','')+',';
                else
                    selIssues=selIssues+is.issueNo.replaceall('I_','')+',';
            }
        }
        if(string.isNotBlank(selIssues)){
            cs.Selected_Issues__c=selIssues.removeEnd(',');
            update cs;
        }     
        return 'Success';
    }
    
   /*  @Auraenabled(cacheable=true)
    public static string userTrips(string caseId){
  string response= CaseIssuesController.userTrips(caseId);
    return response;
    }*/
    
    @Auraenabled(cacheable=true)
    public static string userTrips(string caseId,string category){
    userTripsCounter++;
    System.debug('userTripsCounter-->'+userTripsCounter);
        string region;
        string tripId;
        string tin;
        case csObj=new case();
        csObj=[select id,tat_notifier_email__c,Phone_No_ct__c,Booking_Mobile_No__c from case where id=:caseId];
        
        String emailId = String.isNotBlank(csObj.tat_notifier_email__c)?csObj.tat_notifier_email__c:'';
        String phoneNo = String.isNotBlank(csObj.Phone_No_ct__c)?csObj.Phone_No_ct__c:String.isNotBlank(csObj.Booking_Mobile_No__c)?csObj.Booking_Mobile_No__c:'';
        //emailId='nilika.haldar@redbus.com';
        //PhoneNo='8884580492';
         string respBody;
       // for(integer i=0;i<4;i++){
        
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateHeaders(req);
        String apiEndPoint='';
        if(region=='Rails'){
            apiEndPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='RailsUserTrips'].Endpoint__c;
            apiEndPoint = apiEndPoint+'phone='+phoneNo;
        }else{
            apiEndPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='UserTrips'].Endpoint__c;         
           if(category=='Single'){
            apiEndPoint = apiEndPoint+'emailid='+emailId+'&phone='+PhoneNo+'&tripid=&tin=';
           // apiEndPoint = apiEndPoint+'emailid=mani.renus@gmail.com&phone=9491322718&tripid=&tin=';
            }else if(category=='Multiple'){
            apiEndPoint = apiEndPoint+'emailid='+emailId+'&phone='+PhoneNo+'&tripid=&tin=&category=multiple&numtimes=6';
            //apiEndPoint = apiEndPoint+'emailid=mani.renus@gmail.com&category=multiple&numtimes=6';
            }
        }
        
        System.debug('..apiEndPoint2...'+apiEndPoint);
        req.setEndpoint(apiEndPoint); 
        req.setMethod('GET');
        
        /*   if('INTL'.equalsIgnoreCase(region)){
req.setHeader('Country_Name', 'INTL');      
countryCode='INTL';
system.debug('countryCode==>>'+countryCode);
}else if('RDC'.equalsIgnoreCase(region)){
req.setHeader('Country_Name', 'RDC'); 
}*/
       
        res=http.send(req);      
        respBody=res.getBody();
        System.debug('respBody-->'+respBody);
       // }
        //respBody='[{ "tin": "TQCC86854658", "transactionNo": "13096562136630217", "cartId": "13096562136620305", "status": "CONFIRMED", "dateOfJourney": "11/30/2021 5:00:00 PM", "source": "Manali", "destination": "Delhi", "BoardingPoint": "Zingbus Lounge Majnu Ka Tila", "travels": "zingbus", "pnr": "ZB211116191428", "seats": "19,20", "userId": "-1", "emailId": "mani.renus@gmail.com", "phone": "919491322718", "creationDate": "2021-11-16T19:14:27", "trainName": "", "trainNo": "" }, { "tin": "TQCB14985342", "transactionNo": "13095837985478601", "cartId": "13095837985466497", "status": "CONFIRMED", "dateOfJourney": "11/27/2021 5:00:00 PM", "source": "Delhi", "destination": "Manali", "BoardingPoint": "Private Bus Stand Parking (Manali)", "travels": "IntrCity SmartBus", "pnr": "IC107702601582#GDS_ab23b9e591852eb91636979748", "seats": "4D,4C", "userId": "6553313", "emailId": "mani.renus@gmail.com", "phone": "919491322718", "creationDate": "2021-11-15T18:05:48", "trainName": "", "trainNo": "" }, { "tin": "", "transactionNo": "13095827143711907", "cartId": "13095827143689603", "status": "TENTATIVE_EXPIRED", "dateOfJourney": "11/27/2021 5:00:00 PM", "source": "Delhi", "destination": "Manali", "BoardingPoint": "Private Bus Stand Parking (Manali)", "travels": "IntrCity SmartBus", "pnr": "", "seats": "4D,4C", "userId": "-1", "emailId": "6d616e692e72656e757340676d61696c2e636f6d", "phone": "919491322718", "creationDate": "2021-11-15T17:43:12", "trainName": "", "trainNo": "" } ]';
        return respBody;
    }
    
    public class IssuesWrapper{
        @Auraenabled
        public string issueName;
        @Auraenabled
        public string issueNo;
        @Auraenabled
        public boolean isChecked; 
        @Auraenabled  
        public integer index;      
    }
}