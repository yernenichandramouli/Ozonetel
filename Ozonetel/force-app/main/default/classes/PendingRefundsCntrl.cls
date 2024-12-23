/**
 * (c) 2018 RedBus
 *
 * Name           : PendingRefundsCntrl
 * Created Date   : 25 May 2018
 * Created By     : Sreenivas M
 * Purpose        : Controller class for PendingRefunds Page
 *
 **/
public class PendingRefundsCntrl {

    public Date startDt{get;set;}
    public Date endDt{get;set;}
    public String status{get;set;}
    public String country{get;set;}
    public string transactionId{get;set;}
       
    public string requestLabel{get;set;}
    public string requestLabel2{get;set;}
    public string result{get;set;}
    public string refStatus{get;set;}
    public PendingRefundsWrapper refundWrap{get;set;}
    
    public String comments{get;set;}
    public String pgRefNum{get;set;}
    public date refundedDate{get;set;}
    public String selRecId{get;set;}
    public Boolean isUpdateSuccess{get;set;}    
    Map<String,Datum> mapReqIdtoData;
    private final integer listLimit;
   public list<PendingDisplayWrapper> respDisplayWraper {get;set;} 
   
    public DBLog_Summary__c dbl;
    
    public PendingRefundsCntrl()
    {
        listLimit = 1000;
        isUpdateSuccess = false;
        startDt = System.Today();
        endDt = System.Today();
       respDisplayWraper = new List<PendingDisplayWrapper>();
        
       string userCountry =[Select country from User where Id=:UserInfo.getUserId()].country;
        
        if('India'.equalsIgnoreCase(userCountry))
             country='IND';
             
        else if('Indonesia'.equalsIgnoreCase(userCountry))
             country='IDN';
             
        else if('Malaysia'.equalsIgnoreCase(userCountry))
             country='MYS';
             
        else if('Singapore'.equalsIgnoreCase(userCountry))
             country='SGP';
             
        else if('Peru'.equalsIgnoreCase(userCountry))
             country='PER';
             
        else if('Colombia'.equalsIgnoreCase(userCountry))
             country='COL';
             
        refundWrap = new PendingRefundsWrapper();
        mapReqIdtoData = new Map<String,Datum>();
        dbl = new DBLog_Summary__c();
        
    }
    
  
    
    public Object Search()
    {    
        refStatus='';
        if(startDt.daysBetween(endDt)>29)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The Difference Between Start Date and End Date Must be Leas Than 30 Days'));
            return null;
        }
        
        refundWrap = new PendingRefundsWrapper();
        String jsonBody = '{"startTime":"'+startDt+'","endTime":"'+endDt+'","country":"'+country+'"}';
        System.debug('jsonBody ...'+jsonBody);
        Continuation con = new Continuation(120);         
        con.continuationMethod='processResponse';          
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Country_Name', +country); 
        req.setMethod('POST');
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='PendingRefunds'].Endpoint__c);
        req.setBody(jsonBody);    
        system.debug('::: requestHeaders = '+string.valueof(req.getHeader('Country_Name'))+'Body :'+JSON.serialize(jsonBody));
        // System.debug(':::: Request Data ::: ' +string.valueof(req)+'..'+String.valueOf(Jsonbody));
        System.debug('Endpoint ...'+req.getEndpoint());    
        this.requestLabel = con.addHttpRequest(req);
        return con;
    }
     
    public Object processResponse() 
    {  
          System.debug('this.requestLabel...'+this.requestLabel);
          HttpResponse response = Continuation.getResponse(this.requestLabel);
          System.debug('Response status..'+response);
          System.debug('Response statuscode..'+response.getStatusCode());
          this.result = response.getBody();
          System.debug('Result....'+this.result);
          refundWrap = new PendingRefundsWrapper();
          mapReqIdtoData.clear();
          refundWrap =(PendingRefundsWrapper)JSON.deserialize(this.result,PendingRefundsWrapper.class);
          if(refundWrap!=null && refundWrap.data!=null && !refundWrap.data.isEmpty())
          {
             system.debug('==='+refundWrap.data.size());
             
            integer counter = 0;
            integer loopCount = 0;
            List<Datum> tmpcase = new List<Datum>();
                    respDisplayWraper = new list<PendingDisplayWrapper>();
                    
            for(Datum dn : refundWrap.data)
            {
                if(counter < listLimit)
                {
                   system.debug('==if=='+counter);
                    tmpcase.add(dn);
                    counter++;
                }
                else
                {
                 system.debug('==else block=='+loopCount);
                    loopCount++;
                    respDisplayWraper.add(new PendingDisplayWrapper(tmpcase,loopCount));
                    tmpcase = new List<Datum>();
                    tmpcase.add(dn);
                    counter = 0;
                    system.debug('===130==='+respDisplayWraper.size());
                    system.debug('===132==='+respDisplayWraper);
                }   
                  mapReqIdtoData.put(dn.requestId,dn);
              }
              
            if(respDisplayWraper.size() == 0 )
            {
                loopCount++;
                respDisplayWraper.add(new PendingDisplayWrapper(tmpcase,loopCount));
            }
          }
          return null;
    }

    Public Object updateInPaas()
    {
      dbl = new DBLog_Summary__c();
      isUpdateSuccess = false;
      if(String.isBlank(refStatus) || (('Success'.equalsIgnoreCase(refStatus) && String.isBlank(pgRefNum)) || ('Failed'.equalsIgnoreCase(refStatus) && String.isBlank(comments))))
      {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select Status/Fill All Required Refund Details'));
        return null;
      }
      
      System.debug('selRecId...'+selRecId+'..'+mapReqIdtoData.containsKey(selRecId));
      Datum d = mapReqIdtoData.get(selRecId);
      System.debug('d..'+d);
      HttpRequestWrappersUtil.PaasRefundUpsertRequest refReq = new HttpRequestWrappersUtil.PaasRefundUpsertRequest();
      refReq.isInsertTrue = false;
      
      if('Success'.equalsIgnoreCase(refStatus))
      {
         refReq.refundStatus = HttpRequestWrappersUtil.RefundStatus.SUCCESS;
         refReq.bankArnNumber =pgRefNum;
          refReq.refundMsg ='Refunded Through PGConsole';
      }
      else
      {
         refReq.refundStatus = HttpRequestWrappersUtil.RefundStatus.SF_CSE_REF_FAILED;
         refReq.bankArnNumber ='';
         refReq.refundMsg ='Refunded Through PGConsole Failed';
         refReq.comments=comments;
      }
     
     
      refReq.requestId =selRecId;
      refReq.orderId =d.orderId;
      refReq.transactionId =d.transactionId ;
      
      refReq.amount =d.amount;
      refReq.refundedBy =UserInfo.getName()+'('+UserInfo.getUserName()+')';
      refReq.modifiedSource = 'SFA';
      refReq.initiatedTime = String.valueOf(System.Today());
      
      dbl.type__c ='Update PG Ref in Paas';
      dbl.Payment_Items_Success__c = selRecId;
      dbl.Payment_Ping_Status__c = 'Payment Ping Initiated';
      dbl.Orders_Received_Data_Ids__c = d.trexOrderUuid;
      dbl.Payment_Items_Data_Received_Ids__c = d.orderId;
      dbl.Payment_Items_Process_Status__c = d.transactionId;
      
      Continuation con = new Continuation(120);
      con.continuationMethod='processUpdateResponse';
      HttpRequest req = new HttpRequest();
      req.setHeader('Content-Type', 'application/json');
      req.setHeader('Country_Name', +country); 
      req.setMethod('POST');
      req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='AmendRefundRecord'].Endpoint__c);
      req.setBody(JSON.serialize(refReq));
      dbl.Request_Data__c = Req+'..Body...'+ JSON.serialize(refReq)+'---Header--Country_Name--'+Req.getHeader('Country_Name');       
      this.requestLabel2 = con.addHttpRequest(req);
    /*  pgRefNum ='';
      comments ='';
      refStatus =''; */
      
      return con;
      
    }

    public Object processUpdateResponse()
    {
          try
          {
              String respString ='Error while processing request.Please retry..';
              HttpResponse response = Continuation.getResponse(this.requestLabel2);
              String respBody = response.getBody();
              System.debug('respBody ....'+respBody);
              dbl.Response_Received__c =respBody;
              map<string,object> updateDetails = (map<string,object>)JSON.deserializeUntyped(respBody);
              if(updateDetails.containsKey('amendState') && Boolean.Valueof((Boolean)updateDetails.get('amendState')))
              {
               dbl.Payment_Ping_Status__c = 'Payment Ping Sucess';
               ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Record Details Has Been Updated Successfully!'));
               isUpdateSuccess = true;
              }
              else
              {
               dbl.Payment_Ping_Status__c = 'Payment Ping Failed';
               dbl.Exception_Description__c = String.valueOf((String)updateDetails.get('responseMessage'));
               ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error While Updating Records.Please re-try..!'+String.valueOf((String)updateDetails.get('responseMessage'))));
              }
           }
           Catch(Exception e)
           {
            dbl.Exception_Description__c = String.valueOf(e);
           }
          insert dbl;
          return null;
    }
    
      
public class Datum
{
    public string creationTime { get; set; }
    public string transactionId { get; set; }
    public string orderId { get; set; }
    public string amount { get; set; }
    public string currencyCode { get; set; }
    public string gatewayName { get; set; }
    public string pgTransactionId { get; set; }
    public string dateOfCreationInLong { get; set; }
    public string refundStatus { get; set; }
    public string refundType { get; set; }
    public string processedTime { get; set; }
    public string trexOrderUuid { get; set; }
    public string requestId {get; set;}
    public string mobile{get;set;}
    public string emailId{get;set;}
}

public class PendingRefundsWrapper
{
    public List<Datum> data { get; set; }
    public string error { get; set; }
    public string message { get; set; }
}


Public class PendingDisplayWrapper
{
    public List<Datum> refundData { get; set; }
    public  integer blockNumber {get;set;}
    public PendingDisplayWrapper(List<Datum> rd,integer i){
        refundData =rd;
        blockNumber = i;
    }
}

}