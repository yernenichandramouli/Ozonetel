public class DBTConsoleController {
    public string bankName{get;set;}
    public string amount{get;set;}
    public string formattedAmount;
    public list<case> caseList{get;set;}
    public string paymentUUID;
    public List<Payment_Items__c> pObj;
    
    public DBTConsoleController (){
        caseList=new list<case>();
    }
    
    public void DBTSearchAndConfirm(){
        amount=amount.trim();
        List<DBT__c> dList=new List<DBT__C>();
        dList=[select id,case__c,case__r.casenumber,case__r.status,Formatted_Amount__c,status__c from DBT__c where amount__c=:amount and Bank_Name__c=:bankName and createddate=today and status__c!='No Case Found' limit 1];
        if(bankName=='--None--' || bankName=='' || amount==null || amount==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select bank name [or] Enter amount'));
        }else if(dList.size()>0){
            if(dList[0].case__r.casenumber!=null)
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'There is already one DBT record is available with this amount, Case number->'+dList[0].case__r.casenumber+', Status->'+dList[0].status__c));       
            else
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is already one DBT record is available with this amount'));       
            
        }
        else{
            formattedAmount=amountFormat(amount);
            caseList=[select id,casenumber,transaction_id__c,Trip_Id_ct__c,amountd__c,issue_type__c from case where createddate=today and issue_type__c='DBT' and Bank_Name__c=:bankName and amountd__c=:formattedAmount limit 1];
            if(!caseList.isEmpty()){
                
                if(caseList[0].Trip_Id_ct__c!=null){
                    set<string> dbtPgTypes=new set<string>(System.Label.DBT_PG_Types.split(','));
                   
                    pObj=[select id,Payment_System__c,Payment_Gateway_Type__c,Guid__c,Order_ID__c,Creation_Time__c,Account_Holder_Name__c from Payment_Items__c where Order_ID__c=:caseList[0].Trip_Id_ct__c and Payment_Gateway_Type__c in:dbtPgTypes and Payment_System__c ='ONLINE' and Account_Holder_Name__c!='' ORDER BY Creation_Time__c DESC limit 1];
                    if(!pObj.isEmpty()){
                        
                        paymentUUID=pObj[0].Guid__c;  
                        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='DBT'];
                        String userName=UserInfo.getName()+'('+UserInfo.getUserName()+')';
                        userName= userName.replace('@', '-');
                        string bankRefId=caseList[0].casenumber;
                        string slatId='656d7f6d7hf6adf68ds77fd6sd8fs7d86f7ds6f7s';
                        // string hashValue=Generatehash(paymentUUID+'|'+bankRefId+'|'+slatId);
                        string  hashValue=GenericUtils.getsha512hash(paymentUUID+'|'+bankRefId+'|'+slatId);
                        if(hashValue==null){
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.Error,'Encryption Failed, Please try again'));
                        }else{
                            List<DBT__c> dbInList=new List<DBT__c>();
                            dbInList=[select id,case__c,case__r.casenumber,case__r.status,Formatted_Amount__c from DBT__c where amount__c=:amount and Bank_Name__c=:bankName and createddate=today and status__c='No Case Found' limit 1];
                            DBT__c dObj=new DBT__c();
                            if(!dbInList.isEmpty())
                                dObj.id=dbInList[0].id;
                            
                            dObj.case__c=caseList[0].id;
                            dObj.bank_name__c=bankName;
                            dObj.amount__c=amount;
                            dObj.Formatted_Amount__c=formattedAmount;
                            dObj.Trip_Id__c=caseList[0].Trip_Id_ct__c;
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
                            dbl.Payment_Transaction_Name__c=caseList[0].transaction_id__c;
                            try{
                                System.debug('req body-->'+req);
                                res=h.send(req);
                                dbl.Response_Received__c=res.getbody();
                                System.debug('res-->'+res.getbody());
                                string resP='{"isTicketGenrated":"true","isGFT":"false","concludeResponse":""}';
                                map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());  
                                
                                if(string.valueOf(resObj.get('isTicketGenrated'))=='true'){
                                    dbl.Payment_Ping_Status__c='Ticket Generated';
                                    dObj.status__c='Ticket Generated';
                                    CaseComment csComm = new CaseComment();
                                    csComm.ParentId = caseList[0].id;
                                    csComm.commentBody = 'DBT Ticket Confirmed successfully';
                                    insert csComm;
                                    
                                    caseList[0].status ='Closed';
                                    update caseList;
                                    upsert dObj;
                                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'Ticket generated successfully!, Case number->'+caseList[0].casenumber));
                                }
                                else if(string.valueOf(resObj.get('IsvoucherExpired'))=='true'){
                                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.INFO,'GFT-Ticket could not be generated successfully, Reason:Voucher is expired. Please process refund, Case number->'+caseList[0].casenumber));
                                    dbl.Payment_Ping_Status__c='Voucher Expired';
                                    dObj.status__c='Voucher is Expired';
                                    upsert dObj;
                                }
                                else if(string.valueOf(resObj.get('isGFT'))=='true'){
                                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.INFO,'GFT-Ticket could not be generated successfully, Reason:Technical issues(iDNC / vendor failures),Please process refund. Case number->'+caseList[0].casenumber));
                                    dbl.Payment_Ping_Status__c='GFT';
                                    dObj.status__c='GFT';
                                    upsert dObj;
                                }
                                else{
                                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.Warning,'Ticket is not generated, Please try again [Or] Contact Admin->'+string.valueOf(resObj.get('Error')+', Case number->'+caseList[0].casenumber)));
                                    dbl.Payment_Ping_Status__c='Ticket not Generated';
                                }
                            }catch(Exception e){
                                dbl.Payment_Ping_Status__c='API Failed';
                                dbl.Exception_Description__c=string.valueof(e);                               
                                ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'API failed, Please try again!!'+e+', Case number->'+caseList[0].casenumber));  
                            }
                            insert dbl;                            
                        }                 
                    }else
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Online Payment items is not available, Please sync the transaction, Case number->'+caseList[0].casenumber));
                }else{ 
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Trip id is not exist, Case number->'+caseList[0].casenumber));
                }
                
            }else{
                List<DBT__c> dbInList=new List<DBT__c>();
                dbInList=[select id,case__c,case__r.casenumber,case__r.status,Formatted_Amount__c from DBT__c where amount__c=:amount and Bank_Name__c=:bankName and createddate=today and status__c='No Case Found' limit 1];
                
                DBT__c dObj=new DBT__c();
                dObj.status__c='No Case Found';
                dObj.amount__c=amount;
                dObj.formatted_amount__c=formattedAmount;
                dObj.bank_name__c=bankName;
                if(dbInList.isEmpty()){
                    insert dObj;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'No DBT case found with this amount. DBT Recrod has been created, Please search manually in DBT queue'));
                }else{
                    dObj.id=dbInList[0].id;
                    upsert dObj;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Still No DBT case found with this amount!! Please search manually in DBT queue'));
                }
            }
        }
        
    }
    
    /*public static string Generatehash(string hV) {
        string jsBody='{"text" :"'+hV+'"}';
        
        string encryptedValue;
        Http ht = new http();
        HttpRequest req = HttpRequestUtil.populateHeaders(new HttpRequest());
        HttpResponse resp = new HttpResponse();
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='DBT_Encryption'].Endpoint__c);
        req.setMethod('POST');
        req.setBody(jsBody);
        resp=ht.send(req);
        // System.debug('resp--->'+resp+'-->resp b-->'+resp.getbody());
        
        if(resp.getStatus() =='OK' && resp.getStatusCode() ==200 && String.isNotBlank(resp.getBody()))
        {
            encryptedValue= String.valueOf(resp.getBody());
            encryptedValue= encryptedValue.removeStart('"').removeEnd('"');
            System.debug('encryptedValue-->'+encryptedValue);
        }   
        
        return encryptedValue;
    }	*/
    
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
    
    public String amountFormat(string amount){
        String data=amount.replaceAll(',','');
        // String data ;
        amount=amount.replaceAll(',','');
        System.debug('amount-->'+amount);
        if(amount.contains('.')){
            data = amount.split('\\.')[0];
        }
        String[] convertStringtochar = data.split('');
        String output = '';
        Integer count = convertStringtochar.size()-3;
        for(Integer i = convertStringtochar.size()-1; i>=0; i--){
            output = convertStringtochar[i]+output;
            if (count == i && i!=0) {
                output = '.'+output;
                count = count - 3;
            }
        }
        return output;
    }  
}