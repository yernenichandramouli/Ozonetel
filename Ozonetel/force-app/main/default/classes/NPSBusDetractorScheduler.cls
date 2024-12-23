/*
* Name           : NPSBusDetractorScheduler 
* Created Date   : 8 Aug 2018
* Created By     : Mahendra k
* Purpose        : Scheduler for creating NPS cases for Busses 
* Test class     : NPSBusDetractorSchedulerTest
*/
global class NPSBusDetractorScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        NPSBuscallout();
    }
   @future(callout=true)
    public static void NPSBuscallout()
    {        
        list<case> caseList = new list<case>();
        Set<String> setPaymentUUids = new Set<String>();
        
         
       date fromDate=System.today().adddays(-1);
       date toDate=System.today();
        //string fromDate='2018-10-2';
        //string toDate='2018-10-3';
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='NPSDetractor'];
        
        string ep=APIMData.Endpoint__c+fromDate+'&toDate='+toDate+'&bu='+1;
        System.debug('endpoint-->'+ep);
        string jsonCM='{"action":"GET","body":"","endPoint":"'+ep+'","headers":""}';
        
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        System.debug('jsonCM-->'+jsonCM);
        
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req);               
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setBody(jsonCM);
        req.setEndpoint(APIMData.Endpoint__c);
        dbl.SentAt__c = system.now();
        dbl.Type__c = 'NPS Bus Scheduler';
        dbl.Payment_Request_Sent_Time__c = system.now();
        //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+jsonCM;
        dbl.Request_Data__c = string.valueof(req)+jsonCM;
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        
        try{
            res=h.send(req);  
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.Response_Received__c = String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);
            String jsonMock='[{"RequestId":713,"CheckInDate":"2017-02-03 00:00:00.0","TIN":"T171U6625739","MobileNumber":"9538956479","EmailId":"raghavendra.g1729@gmail.com","NPS":8,"HotelName":"Palm Era Resorts","Location":"Coorg","NoOfRooms":1,"Feedback":"","Status":"Follow-Up Pending"},{"RequestId":706,"CheckInDate":"2017-02-03 00:00:00.0","TIN":"T17233146273","MobileNumber":"8157057972","EmailId":"muneebkkv@gmail.com","NPS":8,"HotelName":"Rainbow Cottage","Location":"Ooty","NoOfRooms":1,"Feedback":"","Status":"Follow-Up Pending"}]';
            if(res.getStatus()=='OK' && res.getStatusCode()==200){
                System.debug('req-->'+req);
                System.debug('rr-->'+res.getbody()); 
                //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);
                dbl.Response_Received__c = String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);
                dbl.Payment_Request_Response_Time__c = System.now();
                dbl.Payment_Ping_Status__c = 'NPS bus Scheduler Success';  
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
                
                for(Response r:resTins)
                {
                    tinList.add(r);
                    if(String.isNotBlank(r.tin))
                         tins.add(r.tin);
                    
                }
                
                tList=[select id,Order_Item_Reference_No__c,name from Order_Items__c where Order_Item_Reference_No__c in:tins];
                for(Order_Items__c t:tList){
                    trnMap.put(t.Order_Item_Reference_No__c,t);
                }
                // Id RecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
                System.debug('trnMap-->'+trnMap);
                System.debug('caseMap-->'+caseMap);

                 Id  grpId = [Select id from Group where type='Queue' AND developername='NPS_Queue'].id;
                for(Response r:resTins){                 
                    Case cs = new Case();
                    cs.Request_Id__c= string.valueof(r.RequestId);
                    cs.SS_DOJ__c=date.valueof(r.DateOfJourney);
                  //  cs.SS_DOJ__c= datetime.valueof((string)r.DateOfJourney);
                    cs.TIN_No__c=r.tin;
                    cs.Phone_No_ct__c=r.MobileNumber;
                    cs.Email_Id_ct__c=r.EmailId;
                    cs.NP_Score__c=r.NPS;
                    cs.Bus_Operator_Namee__c =r.Travels;
                    cs.Service_Providerr_Id__c=r.OperatorId;
                    cs.Feedback__c=r.Feedback;
                    cs.Status = r.status;
                    cs.Source_And_Destination__c=r.Routes;
                    cs.No_of_Seats__c=string.valueof(r.NoofSeats);
                    cs.Issue_Type__c ='NPS';
                    cs.Issue_Sub_Category__c='NPS Bus';
                    cs.Origin ='NPS Bus';
                    cs.ownerId = grpId;
                  //  cs.Nps_Response_Date__c=date.valueof(r.CreateDate);
                      cs.Nps_Response_Date__c= datetime.valueof((string)r.CreateDate);
                   

                    if(trnMap.get(r.tin)!=null)
                        cs.Transaction_ID__c=trnMap.get(r.tin).id;
                    casesToCreate.add(cs);
                }
                if(!casesToCreate.isEmpty())
                    database.insert(casesToCreate,false);
                
            }else{
                dbl.Payment_Request_Response_Time__c = System.now();
                dbl.Payment_Ping_Status__c = 'NPS Bus Scheduler API Fail';
            } 
        } catch(Exception e){
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.Payment_Ping_Status__c = 'NPS Bus Scheduler Fail';
            dbl.Exception_Description__c = string.valueOf(e);
        }
        insert dbl;
    }
    
    public class Response
    {  
      
    public Integer RequestId { get; set; }
    public string DateOfJourney { get; set; }
    public string TIN { get; set; }
    public string MobileNumber { get; set; }
    public string EmailId { get; set; }
    public string NPS { get; set; }
    public string Travels { get; set; }
    public string OperatorId { get; set; }
    public string Routes { get; set; }
    public Integer NoofSeats { get; set; }
    public string Feedback { get; set; }
    public string Status { get; set; }
    public string CreateDate{get;set;}
}
   
}