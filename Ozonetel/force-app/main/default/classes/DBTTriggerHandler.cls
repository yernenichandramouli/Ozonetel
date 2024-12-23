Public class DBTTriggerHandler{ 

    
public static void dbtAfterInsert(List<DBT__c> TriggerNew)
 {
 System.debug('tt nn-->'+TriggerNew);
 List<id> NocaseDBTlst = new List<id>();
   for(DBT__c dbt:TriggerNew)
   {
     
   if('No Case Found'.equalsIgnoreCase(dbt.Status__c)&&String.isNotBlank(dbt.Bank_Name__c)&&String.isNotBlank(dbt.Formatted_Amount__c)&&String.isNotBlank(dbt.Description__c))
    { 
        NocaseDBTlst.add(dbt.id);
        system.debug('dbtcaselst-->>'+NocaseDBTlst);
    } 
    }
 system.debug('NocaseDBTlst=====new==>>>>>>>>'+NocaseDBTlst);
 if(!NocaseDBTlst.isEmpty() )
    {
        system.debug('callingQueueable-->>');
         //Nocasefound(NocaseDBTlst);
         System.enqueuejob(new DBTFuzzyQueueable(NocaseDBTlst));
    }
}
 
        
   
/*
public static void Nocasefound(List<id> dbtNoCaseIds){
    List<DBT__c> dbtlst = new List<DBT__c>();
    dbtlst=[select id,Name,Amount__c,Bank_Name__c,CreatedDate,Formatted_Amount__c,Credited_Date_Time__c,Description__c,Error_Code__c,Error_Message__c,Matched_OrderID__c,Status__c from DBT__c where id in:dbtNoCaseIds];
    List<DBTRequestWapper> lstDBTreqwpr = new List<DBTRequestWapper>();
    list<DBTresponse> DBTres = new list<DBTresponse>();
    List<DBT__c> Upadtedbtlst = new List<DBT__c>();
    list<string> pymntUUidlst = new list<string>();
    string dbtId;
    
      for(DBT__c db:dbtlst){
      
      lstDBTreqwpr.add(new DBTRequestWapper(db.id,db.Bank_Name__c,db.Formatted_Amount__c.replace('.',''),db.CreatedDate.addMinutes(-330).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),db.Description__c));
      dbtId=db.id;
      }
      if(!lstDBTreqwpr.isEmpty()){
        string jsonBody =json.serialize(lstDBTreqwpr); 
        jsonBody=json.serialize(jsonBody); 
        system.debug('jsonBody-->>'+jsonBody);
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='DBTFuzzyLogicAPI'];
        string jsonCM='{"action":"post","body":'+jsonBody+',"endPoint":"'+APIMData.Endpoint__c+'","headers":""}';
        system.debug('jsonCM-->>'+jsonCM);
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
        system.debug('endpoint-->>'+APIMData.Endpoint__c);      
        HTTP h = new HTTP();
        HTTPRequest req= new  HTTPRequest();
        HTTPResponse resp=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req);               
        req.setMethod('POST');
        req.setBody(jsonCM);
        req.setEndpoint(APIMData.Endpoint__c);
        system.debug('reqbdy-->>'+req.getbody());
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'DBT Fuzzy Logic';
        dbl.Payment_Request_Sent_Data__c=string.valueof(req.getBody());
        try{
        resp=h.send(req);
         system.debug('resbdy-->>'+resp.getBody()+'resp-->>'+resp);
       if(resp.getStatusCode()==200 && resp.getstatus()=='OK' && resp.getBody()!=null)
        {
         dbl.Payment_Request_Response_Data__c = String.valueOf(resp+'..Body..'+resp.getBody());    
          DBTres = (list<DBTresponse>)JSON.deserialize(resp.getBody(),list<DBTresponse>.class);
        
         for(DBTresponse d:DBTres){
          DBT__c dbtObj = new DBT__c();
         
           System.debug('d-->'+d);
          if(d.IsProcessed==true){
            dbtObj.id=d.Id;
            system.debug('dbtObj.id-->'+dbtObj.id);
            dbtObj.Status__c='Fuzzy Match Found';
            dbtObj.Matched_OrderID__c = d.MatchedOrderID;
            pymntUUidlst.add(d.MatchedOrderID);
          }else{
            dbtObj.id=d.Id;
            dbtObj.Status__c='Fuzzy Match Not Found';
            dbtObj.Error_Code__c=d.ErrorMetaInfo.ErrorCode;
            dbtObj.Error_Message__c=d.ErrorMetaInfo.ErrorMsg;
            }
            Upadtedbtlst.add(dbtObj);
            
         }   
         list<string> idlst = new list<string>();
        for(Payment_Items__c p:[select id,Order_Name__r.name,Amount_Payable_Value__c,Guid__c,Order_ID__c,Order_Item_Name__c,Order_Item_Name__r.name from Payment_Items__c where Guid__c IN :pymntUUidlst] ){
           system.debug('p-->>'+p+'order--->>'+p.Order_ID__c);
           
           idlst.add(p.Order_ID__c);
           system.debug('idlst-->>'+idlst) ;   
         }
         List<case> caseUpList=new List<case>();
         List<caseComment> ccList=new List<caseComment>();
       for(case cs:[select id,casenumber,origin,status,Issue_Type__c,Transaction_ID__r.Order_Id__c,Trip_Id_ct__c from case where Issue_Type__c='DBT' and Origin ='Complaint Tracker' and status !='Closed' and Trip_Id_ct__c in:idlst]){
       system.debug('cs-->>'+cs); 
            cs.status ='Closed';
            caseComment cc=new caseComment();
            cc.CommentBody='Confirmed by Fuzzy logic';
            cc.parentid=cs.id;
            ccList.add(cc);
            system.debug('ccList-->>'+ccList);
            caseUpList.add(cs);
            system.debug('caseUpList-->>'+caseUpList);
        }
         If(!Upadtedbtlst.isEmpty())
          update Upadtedbtlst;
           system.debug('insertUpadtedbtlst-->'+Upadtedbtlst);
           
        If(!ccList.isEmpty())
            insert ccList;
            system.debug('insertccList-->'+ccList);
        
         If(!caseUpList.isEmpty())
           update caseUpList;
           system.debug('insertcaseUpList-->'+caseUpList);

        
        }
        }Catch(Exception e)
          {
           dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());
          }
       
         insert dbl;
     } 
     
    }
    public class DBTRequestWapper{
    public string Id { get; set; }
    public string BankName { get; set; }
    public string Amount { get; set; }
    public string CreditedDateTime { get; set; }
    public string Description { get; set; }
      public DBTRequestWapper(string Id,string BankName,string Amount,string CreditedDateTime,string Description){
        this.Id=Id;
        this.BankName=BankName ;
        this.Amount=Amount;
        this.CreditedDateTime=CreditedDateTime;
        this.Description=Description;
        
      }
    }
    
    public class ErrorMetaInfo
    {
    public string ErrorCode { get; set; }
    public string ErrorMsg { get; set; }
    }
    
    public class DBTresponse
    {
    public string Id { get; set; }
    public Boolean IsProcessed { get; set; }
    public string MatchedOrderID { get; set; }
    public string ConcludeResponse { get; set; }
    public ErrorMetaInfo ErrorMetaInfo { get; set; }
    }*/
}