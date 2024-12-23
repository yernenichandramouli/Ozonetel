public class DBTFuzzyQueueable implements Queueable,Database.AllowsCallouts{

    public list<ID> dbtNoCaseIds = new list<ID>();
    public DBTFuzzyQueueable(List<id> caseIds){
        dbtNoCaseIds = caseIds;
    }
    public void execute(QueueableContext context)
    {
        List<DBT__c> dbtlst = new List<DBT__c>();
        dbtlst=[select id,Name,Amount__c,Bank_Name__c,CreatedDate,Formatted_Amount__c,Credited_Date_Time__c,Description__c,Error_Code__c,Error_Message__c,Matched_OrderID__c,Status__c from DBT__c where id in:dbtNoCaseIds];
        List<DBTRequestWapper> lstDBTreqwpr = new List<DBTRequestWapper>();
        list<DBTresponse> DBTres = new list<DBTresponse>();
        List<DBT__c> Upadtedbtlst = new List<DBT__c>();
        List<DBT__c> finalDBTRecordsToUpdate = new List<DBT__c>();
        list<string> pymntUUidlst = new list<string>();
       
        
          for(DBT__c db:dbtlst){
          
          lstDBTreqwpr.add(new DBTRequestWapper(db.id,db.Bank_Name__c,db.Formatted_Amount__c.replace('.',''),db.CreatedDate.addMinutes(-330).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),db.Description__c));
         
          }
          if(!lstDBTreqwpr.isEmpty())
          {
            HTTPResponse resp=new HTTPResponse();        
            try
            {
             resp=HTTPUtil.sendGenericHTTPRequest([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='DBTFuzzyLogicAPI'].Endpoint__c,'POST',json.serialize(json.serialize(lstDBTreqwpr)),new Map<String,String>(),120000,'DBT Fuzzy Logic');
             system.debug('resbdy-->>'+resp.getBody()+'resp-->>'+resp);
             if(resp.getStatusCode()==200 && resp.getstatus()=='OK' && resp.getBody()!=null && resp.getBody()!='null' && String.isNotBlank(resp.getBody()))
             {
                DBTres = (list<DBTresponse>)JSON.deserialize(resp.getBody(),list<DBTresponse>.class);            
                for(DBTresponse d:DBTres)
                {
                    DBT__c dbtObj = new DBT__c(id=d.Id);                        
                    System.debug('d-->'+d);
                    
                    if(d.IsProcessed==true)
                    {
                        dbtObj.Status__c='Fuzzy Match Found';
                        dbtObj.Matched_OrderID__c = d.MatchedOrderID;
                        pymntUUidlst.add(d.MatchedOrderID);
                    }
                    else
                    {
                        dbtObj.Status__c='Fuzzy Match Not Found';
                        dbtObj.Error_Code__c=d.ErrorMetaInfo.ErrorCode;
                        dbtObj.Error_Message__c=d.ErrorMetaInfo.ErrorMsg;
                    }
                    Upadtedbtlst.add(dbtObj);
                }
                
             Map<string,string> mapPIidToOrderId = new Map<string,string>();
             Map<string,string> mapOrdidTocaseNum = new Map<string,string>();
             
             for(Payment_Items__c p:[select id,Guid__c,Order_ID__c from Payment_Items__c where Guid__c IN :pymntUUidlst] ){
                mapPIidToOrderId.put(p.Guid__c,p.Order_ID__c);
             }
             
             List<case> caseUpList=new List<case>();
             List<caseComment> ccList=new List<caseComment>();
             
             for(case cs:[select id,casenumber,origin,status,Issue_Type__c,Transaction_ID__r.Order_Id__c,Trip_Id_ct__c from case where Issue_Type__c='DBT' and Origin ='Complaint Tracker' and status !='Closed' and Trip_Id_ct__c in:mapPIidToOrderId.values()])
             {
                system.debug('cs-->>'+cs); 
                /*cs.status ='Closed';
                caseComment cc=new caseComment();
                cc.CommentBody='Confirmed by Fuzzy logic';
                cc.parentid=cs.id;
                ccList.add(cc);
                system.debug('ccList-->>'+ccList);
                caseUpList.add(cs);
                system.debug('caseUpList-->>'+caseUpList);*/
                mapOrdidTocaseNum.put(cs.Trip_Id_ct__c,cs.id);
             }
             
             if(!mapPIidToOrderId.isEmpty() && !mapOrdidTocaseNum.isEmpty())
             {
                 for(DBT__c dbt:Upadtedbtlst)
                 {
                    if(mapPIidToOrderId.containsKey(dbt.Matched_OrderID__c) && mapOrdidTocaseNum.containsKey(mapPIidToOrderId.get(dbt.Matched_OrderID__c)))
                        dbt.case__c = mapOrdidTocaseNum.get(mapPIidToOrderId.get(dbt.Matched_OrderID__c));
                    finalDBTRecordsToUpdate.add(dbt);
                 }
             }
             
             else
             {
                finalDBTRecordsToUpdate.addall(Upadtedbtlst);
             }
             
             If(!finalDBTRecordsToUpdate.isEmpty())
                 update finalDBTRecordsToUpdate;
              
               
            /* If(!ccList.isEmpty())
                insert ccList;
             
             If(!caseUpList.isEmpty())
               update caseUpList; */
           
            }
         }
         Catch(Exception e)
         {
               System.debug('fuzzy mapper error..'+e);
         }
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
    }
    
}