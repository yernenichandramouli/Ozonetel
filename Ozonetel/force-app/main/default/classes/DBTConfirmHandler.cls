public class DBTConfirmHandler{
    
    @future(callout=true)
    public static void dbtConfirm(set<id> cIds,set<string> tripIds){
        
        List<DBT__c> dbtCList=new List<DBT__c>();
        Map<string,DBT__c> dbtMap=new Map<string,DBT__c>();
        
        for(DBT__c d:[select id,amount__c,formatted_amount__c,bank_name__c from DBT__c where createddate=today and status__c='No Case Found']){
            dbtMap.put(d.formatted_amount__c,d);
        }

        Map<string,list<Payment_Items__c>> pMap=new Map<string,list<Payment_Items__c>>();
        set<string> dbtPgTypes=new set<string>(System.Label.DBT_PG_Types.split(','));
        for(Payment_Items__c p:[select id,Order_Name__r.name,Amount_Payable_Value__c,Business_Amount__c,Order_Item_Name__c,Order_Item_Name__r.name,Guid__c,Account_Holder_Name__c from Payment_Items__c where Order_Name__r.name in:tripIds and Payment_Gateway_Type__c in:dbtPgTypes and Payment_System__c='ONLINE' and Account_Holder_Name__c!='' order by Creation_Time__c DESC ]){
            
            if(pMap.containsKey(p.Order_Name__r.name )){            
                pMap.get(p.Order_Name__r.name).add(p);            
            }else{            
                pMap.put(p.Order_Name__r.name,new list<Payment_Items__c>{p});            
            }       
        }
        
        System.debug('calling dbt!!');
        System.debug('pMap-->'+pMap);
        List<case> caseList=new List<case>();
        caseList=[select id,casenumber,bank_name__c,trip_id_ct__c,amountd__c,transaction_id__c from case where id in:cIds];
        List<casecomment> ccList=new List<casecomment>();
        List<case> caseCompleteList=new List<case>();
        List<DBLog_Summary__c> dbList=new List<DBLog_Summary__c>();
         System.debug('caseList-->'+caseList);
        for(case c:caseList){
            System.debug('dbtMap-->'+dbtMap);
         //   System.debug('dbtMap.get(c.amountd__c).formatted_amount__c -->'+dbtMap.get(c.amountd__c).formatted_amount__c );
          //  System.debug('pMap.get(c.trip_id_ct__c)--->'+pMap.get(c.trip_id_ct__c));
            System.debug('amountd-->'+c.AmountD__c+'trip_id_ct__c-->'+c.trip_id_ct__c);
            System.debug('c-->'+c);
            if(dbtMap!=null && dbtMap.get(c.amountd__c)!=null && c.amountd__c==dbtMap.get(c.amountd__c).formatted_amount__c && c.bank_name__c==dbtMap.get(c.amountd__c).bank_name__c && pMap!=null && pMap.get(c.trip_id_ct__c)!=null){
                DBT__c d=new DBT__c();
                System.debug('dbt mp-->'+dbtMap.get(c.amountd__c));
                d=dbtMap.get(c.amountd__c);
                d.trip_id__c=c.trip_id_ct__c;
                d.case__c=c.id;
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='DBT'];
                String userName=UserInfo.getName()+'('+UserInfo.getUserName()+')';
                userName= userName.replace('@', '-');
                string bankRefId=c.casenumber;
                string slatId='656d7f6d7hf6adf68ds77fd6sd8fs7d86f7ds6f7s';
                // set<string> ss=new set<string>();
                // ss.add(paymentMap.get(c.amountd__c)+'|'+bankRefId+'|'+slatId);
                //string hashValue=Generatehash(ss);
                string paymentUUID=string.valueof(pMap.get(c.trip_id_ct__c)[0].Guid__c);
                
                /* string jsBody='{"text" :"'+paymentUUID+'|'+bankRefId+'|'+slatId+'"}';
                
                string encryptedValue;
                Http ht = new http();
                HttpRequest reqh = HttpRequestUtil.populateHeaders(new HttpRequest());
                HttpResponse resh = new HttpResponse();
                reqh.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='DBT_Encryption'].Endpoint__c);
                reqh.setMethod('POST');
                reqh.setBody(jsBody);
                resh=ht.send(reqh);
                // System.debug('resp--->'+resp+'-->resp b-->'+resp.getbody());
                
                if(resh.getStatus() =='OK' && resh.getStatusCode() ==200 && String.isNotBlank(resh.getBody()))
                {
                    encryptedValue= String.valueOf(resh.getBody());
                    encryptedValue= encryptedValue.removeStart('"').removeEnd('"');
                    System.debug('encryptedValue-->'+encryptedValue);
                }  */
        		string  hashValue=GenericUtils.getsha512hash(paymentUUID+'|'+bankRefId+'|'+slatId);
                
                if(hashValue!=null){
                    Request reqW=new Request('true',userName,paymentUUID,bankRefId,hashValue);
                    String dbtJson=json.serialize(reqW); 
                    
                    System.debug('dbj-->'+dbtJson);
                    
                    HTTP h = new HTTP();
                    HttpRequest req= new HttpRequest();
                    HTTPResponse res=new HTTPResponse();        
                    req.setMethod('POST');
                    req.setBody(dbtJson);
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Country_Name', 'IDN'); 
                    req.setTimeout(100020);
                    req.setendpoint(APIMData.Endpoint__c);
                    DBLog_Summary__c dbl = new DBLog_Summary__c();
                    dbl.Type__c = 'DBT Confirmation';
                    dbl.Request_Data__c=req.getbody();
                    dbl.Payment_Transaction_Name__c=c.transaction_id__c;
                    try{
                        System.debug('req body-->'+req);
                        res=h.send(req);
                        dbl.Response_Received__c=res.getbody();
                        dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                        dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                        System.debug('res-->'+res.getbody());
                        string resP='{"isTicketGenrated":"true","isGFT":"false","concludeResponse":""}';
                        map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());  
                        
                        if(string.valueOf(resObj.get('isTicketGenrated'))=='true'){
                            dbl.Payment_Ping_Status__c='Ticket Generated';
                            CaseComment csComm = new CaseComment();
                            csComm.ParentId = c.id;
                            csComm.commentBody = 'DBT Ticket Confirmed successfully';
                            ccList.add(csComm);
                            
                            c.status ='Closed';
                            d.status__c='Ticket Generated';
                            caseCompleteList.add(c);
                        }
                        else if(string.valueOf(resObj.get('IsvoucherExpired'))=='true'){
                            dbl.Payment_Ping_Status__c='Voucher Expired';
                            d.status__c='Voucher is Expired';
                        }
                        else if(string.valueOf(resObj.get('isGFT'))=='true'){
                            dbl.Payment_Ping_Status__c='GFT';
                            d.status__c='GFT';
                        }
                        else{
                            dbl.Payment_Ping_Status__c='Ticket not Generated';
                        }
                    }catch(Exception e){
                        dbl.Payment_Ping_Status__c='API Failed';
                        dbl.Exception_Description__c=string.valueof(e);                
                    }
                    dbList.add(dbl);
                    dbtCList.add(d);
                }
                if(!ccList.isEmpty())
                  insert ccList;
                
                if(!caseCompleteList.isEmpty())
                    update caseCompleteList;
                
                if(!dbList.isEmpty())
                    insert dbList;
                
                if(!dbtCList.isEmpty())
                    update dbtCList;
                
            }
        }
    } 
    
    public class Request{
        public string IsPaid;
        public string AgentName;
        public string PaymentItemUUID;
        public string Pgtxnid;
        public string Hash;     
        public Request(string IsPaid,string AgentName,string PaymentItemUUID,string Pgtxnid,string Hash){
            this.IsPaid=IsPaid;
            this.AgentName=AgentName;
            this.PaymentItemUUID=PaymentItemUUID;
            this.Pgtxnid=Pgtxnid;
            this.Hash=Hash;  
        }
    }
    
    
}