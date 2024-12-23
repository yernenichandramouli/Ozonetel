/*
* Name           : NPSDetractorScheduler 
* Created Date   : 13 June 2018
* Created By     : Veeramanikanta R
* Purpose        : Scheduler for creating NPS cases for Hotels
* Test class     : NPSDetractorSchedulerTest
*/
global class NPSDetractorScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        NPSCallout();
    }
    
    @future(callout=true)
    public static void NPSCallout()
    {        
        list<case> caseList = new list<case>();
        Set<String> setPaymentUUids = new Set<String>();
        
        date fromDate=System.today().adddays(-1);
        date toDate=System.today();
        
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='NPSDetractor'];
        
        string ep=APIMData.Endpoint__c+fromDate+'&toDate='+toDate;
        System.debug('endpoint-->'+ep);
        string jsonCM='{"action":"GET","body":"","endPoint":"'+ep+'","headers":""}';
        
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req);               
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setMethod('POST');
        req.setBody(jsonCM);
        req.setEndpoint(APIMData.Endpoint__c);
        dbl.SentAt__c = system.now();
        dbl.Type__c = 'NPS Scheduler';
        dbl.Payment_Request_Sent_Time__c = system.now();
        //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+jsonCM;
        dbl.Request_Data__c = string.valueof(req)+jsonCM;
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        
        try{
            res=h.send(req);  
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            String jsonMock='[{"RequestId":713,"CheckInDate":"2017-02-03 00:00:00.0","TIN":"T171U6625739","MobileNumber":"9538956479","EmailId":"raghavendra.g1729@gmail.com","NPS":8,"HotelName":"Palm Era Resorts","Location":"Coorg","NoOfRooms":1,"Feedback":"","Status":"Follow-Up Pending"},{"RequestId":706,"CheckInDate":"2017-02-03 00:00:00.0","TIN":"T17233146273","MobileNumber":"8157057972","EmailId":"muneebkkv@gmail.com","NPS":8,"HotelName":"Rainbow Cottage","Location":"Ooty","NoOfRooms":1,"Feedback":"","Status":"Follow-Up Pending"}]';
            if(res.getStatus()=='OK' && res.getStatusCode()==200){
                System.debug('req-->'+req);
                System.debug('rr-->'+res.getbody()); 
                //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);
                dbl.Response_Received__c = String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);
                dbl.Payment_Request_Response_Time__c = System.now();
                dbl.Payment_Ping_Status__c = 'NPS Scheduler Success';  
                List<Response> tinList=new List<Response>();
                set<string> tins=new set<string>();
                list<case> listCases=new list<case>();
                Map<string,case> caseMap=new Map<string,case>();
                list<Order_Items__c> tList=new list<Order_Items__c>();
                Map<string,Order_Items__c> trnMap=new Map<string,Order_items__c>();
                list<case> casesToCreate=new list<case>();
                List<case> casesToUpdate=new List<case>();
                casesToCreate.clear();
                casesToUpdate.clear();
                
                List<Response> resTins=new List<Response>();
                resTins= (List<Response>)System.JSON.deserialize(res.getbody(),List<Response>.class);
                
                System.debug('res-->'+resTins);
                
                for(Response r:resTins){
                    tinList.add(r);
                    tins.add(r.tin);
                }
                string hotelRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();

                tList=[select id,Voucher_Id__c,name,Order_Item_Reference_No__c from Order_Items__c where Voucher_Id__c in:tins and recordTypeId=:hotelRecType];
                for(Order_Items__c t:tList){
                    trnMap.put(t.Order_Item_Reference_No__c,t);
                }
                //  Id RecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
                System.debug('trnMap-->'+trnMap);
                System.debug('caseMap-->'+caseMap);
                for(Response r:resTins){                 
                    Case cs = new Case();
                    cs.Request_Id__c=r.RequestId;
                    cs.CheckIn_Date__c=date.valueof(r.CheckInDate);
                    cs.TIN_No__c=r.tin;
                    cs.Phone_No_ct__c=r.MobileNumber;
                    cs.Email_Id_ct__c=r.EmailId;
                    cs.NP_Score__c=r.nps;
                    cs.Hotel_Name__c=r.HotelName;
                    cs.Location__c=r.location;
                    cs.No_Of_Rooms__c=r.NoOfRooms;
                    cs.Feedback__c=r.Feedback;
                    cs.Status = r.status;
                    
                    // cs.RecordTypeId = RecTypeId ;
                    cs.Origin ='NPS Hotels';
                    if(trnMap.get(r.tin)!=null)
                        cs.Transaction_ID__c=trnMap.get(r.tin).id;
                    casesToCreate.add(cs);
                }
                if(!casesToCreate.isEmpty())
                    database.insert(casesToCreate,false);
                
            }else{
                dbl.Payment_Request_Response_Time__c = System.now();
                dbl.Payment_Ping_Status__c = 'NPS Scheduler API Fail';
            } 
        } catch(Exception e){
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.Payment_Ping_Status__c = 'NPS Scheduler Fail';
            dbl.Exception_Description__c = string.valueOf(e);
        }
        insert dbl;
    }
    
    public class Response
    {  
        public string RequestId;
        public string CheckInDate;
        public string TIN;
        public string MobileNumber;
        public string EmailId;
        public string NPS;
        public string HotelName;
        public string Location;
        public string NoOfRooms;
        public string Feedback;
        public string Status;
        public string Comments;
        public string LockedBy;
    }
}