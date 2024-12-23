/*
* Name           : AttachmentTriggerHandler
* Created Date   : 18 Feb 2017
* Created By     : Veeramanikanta R
* Purpose        : Confirm bulk DBT transactions 
* Test class     : AttachmentTriggerHandlerTest
*/

public class AttachmentTriggerHandler{
    @Future(callout=true)
    public static void DBTConfirmations(set<id> attIds){
        String[] filelines = new String[]{};   
            string MyFile;     
        string mockResponseDBT=system.label.DBTMockResponse;
        list<string> dbtAmounts=new list<string>();
        list<string> dbtBanks=new list<string>();
        list<DBTWrapper> dwList=new list<DBTWrapper>();
        Map<string,DBT__c> amountMap=new Map<string,DBT__c>();
        list<DBT__c> dbtInsertList=new list<DBT__c>();
        list<case> caselist=new list<case>();
        List<Payment_Items__c> pObj=new List<Payment_Items__c>();
        List<DBLog_Summary__c> dblsList=new List<DBLog_Summary__c>();
        List<casecomment> ccList=new list<casecomment>();    
        List<case> caseUpList=new List<case>();
        List<DBT__c> dbtUpsertList=new List<DBT__c>();
        Map<string,case> caseMap=new Map<string,case>();
        List<string> tripIds=new List<string>();
        Map<string,List<Payment_Items__c>> payMap=new Map<string,List<Payment_Items__c>>();
        string paymentUUID;
        List<attachment> attList=new List<attachment>();
        attList=[select id,name,body,contenttype from attachment where id in:attIds];
        for(attachment att:attList){
            MyFile=EncodingUtil.base64Encode(att.body);
            blob MyBlob= EncodingUtil.base64Decode(MyFile);
            MyFile=MyBlob.toString();   
            filelines = MyFile.split('\n'); 
            System.debug('FileLines-->'+filelines);
            System.debug('FileLines size-->'+filelines.size());
            for(Integer i=1;i<filelines.size();i++) {                
                String[] inputvalues = new String[]{};                                   
                    filelines[i]=filelines[i].replaceall('"','');
                System.debug('fileLines ra->'+filelines[i]);
                inputvalues = filelines[i].split('_,');
                system.debug('%%%%%%% each Line::::: '+inputvalues);
                System.debug('in0-->'+inputvalues[0]+'in1-->'+inputvalues[1]+'in2-->'+inputvalues[2]+'in3-->'+inputvalues[3]+'in4-->'+inputvalues[4]);
                string sDate=inputvalues[2];
                datetime tDate=date.valueOf(sDate);
                if(tDate== System.today()){                                     
                    DBTWrapper dw=new DBTWrapper();
                    dw.bankName=inputvalues[0];
                    DBTConsoleController dtc=new DBTConsoleController();
                    dw.amount=inputvalues[1];
                    dw.formattedAmount=dtc.amountFormat(inputvalues[1]);
                    dw.creditedDate=inputvalues[3];
                    dw.description=inputvalues[4];
                    System.debug('inp4--->'+inputvalues[4]);
                    if(!dbtAmounts.contains(dw.formattedAmount)){                                                         
                        dbtBanks.add(inputvalues[0]);                
                        dbtAmounts.add(dw.formattedAmount);
                        dwList.add(dw);
                    }
                }
            }
        }
        System.debug('dbtAmounts-->'+dbtAmounts);
        if(!dwList.isEmpty()){
            Map<string,DBT__c> dbInMap=new Map<string,DBT__c>();
            List<DBT__c> dbtNoCase=new List<DBT__c>();
            List<string> failedStatuses=new List<string>{'Fuzzy Match Found','Fuzzy Match Not Found','No Case Found','API Failed-No Result','API Failed','PaymentId not Exist','Hash Failed'};
                for(DBT__c d:[select id,Amount__c,status__c,bank_name__c,Formatted_Amount__c  from DBT__c where Formatted_Amount__c  in: dbtAmounts and createddate=today]){
                    if(!failedStatuses.contains(d.status__c)){
                        amountMap.put(d.Amount__c,d);               
                    }else if(failedStatuses.contains(d.status__c)){
                        dbInMap.put(d.amount__c,d);
                    }
                }
            
            System.debug('amuontMap 1-->'+amountMap+'dbInMap 1-->'+dbInMap);
            for(case c:[select id,AmountD__c,Trip_Id_ct__c,casenumber,transaction_id__c,status,bank_name__c from case where AmountD__c in: dbtAmounts and createddate=today]){
                caseMap.put(c.AmountD__c,c);
                tripIds.add(c.Trip_Id_ct__c);
            }
            
            for(Payment_Items__c p:[select id,Payment_System__c,Guid__c,Order_ID__c,Creation_Time__c from Payment_Items__c where Order_ID__c in:tripIds and Payment_System__c ='ONLINE' ORDER BY Creation_Time__c DESC]){            
                if(payMap.containsKey(p.Order_ID__c))
                    payMap.get(p.Order_ID__c).add(p);
                else
                    payMap.put(p.Order_ID__c,new list<Payment_Items__c>{p});
            }
            System.debug('dwList-->'+dwList);
            integer countItr=0;
            for(DBTWrapper dWObj:dwList){
                DBTConsoleController dtc=new DBTConsoleController();
                System.debug('amuont M-->'+amountMap.get(dWObj.amount) );
                if(amountMap.get(dWObj.amount)==null || (amountMap.get(dWObj.amount)!=null && amountMap.get(dWObj.amount).amount__c==null) ){
                    System.debug('1->'+caseMap.get(dWobj.formattedAmount)+'--2-->'+dWobj.formattedAmount+'=2.1-->'+caseMap.get(dWobj.formattedAmount)+'&&3-->'+dWobj.bankname+'=3.1-->'+caseMap.get(dWobj.formattedAmount));
                    
                    if(caseMap.get(dWobj.formattedAmount)!=null && dWobj.formattedAmount==caseMap.get(dWobj.formattedAmount).amountD__c && dWobj.bankname==caseMap.get(dWobj.formattedAmount).bank_name__c){
                        if(caseMap.get(dWobj.formattedAmount).Trip_Id_ct__c!=null){
                            System.debug('map-->'+caseMap.get(dWobj.formattedAmount).Trip_Id_ct__c);
                            System.debug('payMap-->'+payMap);
                            DBT__c dObj=new DBT__c();
                            DBLog_Summary__c dbl = new DBLog_Summary__c();
                            
                            if(countItr<49){
                                if(!payMap.isEmpty() && caseMap.get(dWobj.formattedAmount).Trip_Id_ct__c!=null &&!payMap.get(caseMap.get(dWobj.formattedAmount).Trip_Id_ct__c).isEmpty()){
                                    countItr++;
                                    System.debug('payMap-->'+payMap);
                                    paymentUUID=payMap.get(caseMap.get(dWobj.formattedAmount).Trip_Id_ct__c)[0].Guid__c;                     
                                    API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                                    APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='DBT'];
                                    String userName=UserInfo.getName()+'('+UserInfo.getUserName()+')';
                                    userName= userName.replace('@', '-');
                                    string bankRefId=caseMap.get(dWobj.formattedAmount).casenumber;
                                    string slatId='656d7f6d7hf6adf68ds77fd6sd8fs7d86f7ds6f7s';
                                    //string hashValue=DBTConsoleController.Generatehash(paymentUUID+'|'+bankRefId+'|'+slatId);
                                    /* string jsBody='{"text" :"'+paymentUUID+'|'+bankRefId+'|'+slatId+'"}';
                                    
                                    string encryptedValue;
                                    Http ht = new http();
                                    HttpRequest reqh = HttpRequestUtil.populateHeaders(new HttpRequest());
                                    HttpResponse resh = new HttpResponse();
                                    reqh.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='DBT_Encryption'].Endpoint__c);
                                    reqh.setMethod('POST');
                                    reqh.setBody(jsBody);
                                    resh=ht.send(reqh);
                                    
                                    if(resh.getStatus() =='OK' && resh.getStatusCode() ==200 && String.isNotBlank(resh.getBody()))
                                    {
                                        encryptedValue= String.valueOf(resh.getBody());
                                        encryptedValue= encryptedValue.removeStart('"').removeEnd('"');
                                        System.debug('encryptedValue-->'+encryptedValue);
                                    }  
                                    string  hashValue=encryptedValue; */
                                    string  hashValue=GenericUtils.getsha512hash(paymentUUID+'|'+bankRefId+'|'+slatId);
                                    //string hashValue='test';
                                    if(hashValue==null){
                                        dObj.status__c='Hash Failed';
                                    }else{                                    
                                        if(dbInMap.get(dWObj.amount)!=null){
                                            dObj.id=dbInMap.get(dWObj.amount).id;
                                        }
                                        dObj.case__c=caseMap.get(dWobj.formattedAmount).id;
                                        dObj.bank_name__c=dWObj.bankName;
                                        dObj.amount__c=dWObj.amount;
                                        dObj.Formatted_Amount__c=dWObj.formattedAmount;
                                        dObj.Credited_Date_Time__c=dWObj.creditedDate;
                                        dObj.Description__c=dWobj.description;
                                        dObj.Scheduler__c=true;
                                        dObj.Trip_Id__c=caseMap.get(dWobj.formattedAmount).Trip_Id_ct__c;
                                        dObj.Voucher_Id__c=AttachmentTriggerHandler.getVoucher(dWobj.description);
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
                                        dbl.Type__c = 'DBT Confirmation';
                                        dbl.Request_Data__c=req.getbody();
                                        dbl.Payment_Transaction_Name__c=caseMap.get(dWobj.formattedAmount).transaction_id__c;
                                        try{
                                            System.debug('req body-->'+req);
                                            res=h.send(req);
                                            // string mockResponse='{"isTicketGenrated":true,"isGFT":false,"IsvoucherExpired":false,"concludeResponse":"http://m.redbus.id/Confirm?tin=IDN3826899206\u0026ChannelName=MOBILE_WEB"}';
                                            string mockResponse=mockResponseDBT;
                                            dbl.Response_Received__c=res.getbody();
                                            System.debug('res-->'+res.getbody());
                                            string resP='{"isTicketGenrated":"true","isGFT":"false","concludeResponse":""}';
                                            map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getBody());                                          
                                            if(string.valueOf(resObj.get('isTicketGenrated'))=='true'){
                                                dbl.Payment_Ping_Status__c='Ticket Generated';
                                                dObj.status__c='Ticket Generated';
                                                CaseComment csComm = new CaseComment();
                                                csComm.ParentId = caseMap.get(dWobj.formattedAmount).id;
                                                csComm.commentBody = 'DBT Ticket Confirmed successfully';
                                                ccList.add(csComm);
                                                caseMap.get(dWobj.formattedAmount).status='Closed';
                                                caseUpList.add(caseMap.get(dWobj.formattedAmount));                                            
                                            }
                                            else if(string.valueOf(resObj.get('IsvoucherExpired'))=='true'){
                                                dbl.Payment_Ping_Status__c='Voucher Expired';
                                                dObj.status__c='Voucher is Expired';
                                            }
                                            else if(string.valueOf(resObj.get('isGFT'))=='true'){
                                                dbl.Payment_Ping_Status__c='GFT';
                                                dObj.status__c='GFT';  
                                            }
                                            else{
                                                dbl.Payment_Ping_Status__c='Ticket not Generated';
                                                dObj.status__c='API Failed-No Result';
                                            }
                                            
                                        }catch(Exception e){
                                            dObj.status__c='API Failed';
                                            dbl.Payment_Ping_Status__c='API Failed';
                                            dbl.Exception_Description__c=string.valueof(e);                                                                                                                                              
                                        }                                             
                                    }
                                }else{                           
                                    dObj.status__c='PaymentId not Exist';
                                }
                            }
                            dbtUpsertList.add(dObj);
                            dblsList.add(dbl); 
                        }                    
                    }
                    else{                        
                        if(dbInMap.get(dWObj.amount)==null){
                            API_DBTConfirmation.Response resp=new API_DBTConfirmation.Response();
                            string descriptionV=dWobj.description.replace('_','');
                            system.debug('descriptionV-->'+descriptionV);
                            string voucherVal=AttachmentTriggerHandler.getVoucher(descriptionV);
                            
                            if(dWObj.bankName=='BRI' || dWObj.bankName=='Mandiri'){ 
                                DBTConfirmGeneric dbCf=new DBTConfirmGeneric();    
                                DateTime todaysDate = System.today();
                                String todaysDateStr = todaysDate.format('yyyy-MM-dd')+'T00:00:00Z';
                                string amountP=dWObj.amount.replaceAll(',','');                  
                                resp=dbCf.voucherMatch('Attachment',voucherVal.trim(),dWObj.bankName,decimal.valueOf(amountP),todaysDateStr); 
                            }
                            if((dWObj.bankName!='BRI' && dWObj.bankName!='Mandiri')||resp.statusCode==200.10){ 
                                DBT__c dObj=new DBT__c();
                                dObj.status__c='No Case Found';
                                dObj.amount__c=dWObj.amount;
                                dObj.formatted_amount__c=dWObj.formattedAmount;
                                dObj.bank_name__c=dWObj.bankName;
                                dObj.Credited_Date_Time__c=dWObj.creditedDate;
                                dObj.Description__c=descriptionV;
                                dObj.Scheduler__c=true;
                                dObj.Voucher_Id__c=voucherVal;
                                dbtNoCase.add(dObj);
                            }
                            
                        }    
                    }
                }
            }   
            if(!ccList.isEmpty()){
                insert ccList;
            }
            
            if(!caseUpList.isEmpty()){
                update caseUpList;
            }
            
            if(!dbtUpsertList.isEmpty()){           
                upsert dbtUpsertList;
            }
            
            if(!dblsList.isEmpty()){
                insert dblsList;
            }
            
            if(!dbtNoCase.isEmpty()){
                insert dbtNoCase;
            }       
        }        
    }
    
    public static string getVoucher(string voucherId){
        string voucherNo;
        string voucherFiveDigitsId;
        voucherId=voucherId.replaceAll('/','');
        //Pattern pattern = Pattern.compile('\\w+([0-9]+)\\w+([0-9]+)');
        Pattern pat = Pattern.compile('([0-9]+)');
        System.debug('pat-->'+pat);
        Matcher matcher = pat.matcher(voucherId);
        for(integer i = 0 ; i <10; i++) {
            if(matcher.find()){       
                System.debug('mat->'+matcher.group());
                voucherNo=matcher.group();
                if(voucherNo.length()==5 && voucherNo!='95031'){
                    voucherFiveDigitsId=voucherNo;
                    System.debug('voucherNo->'+voucherNo); 
                }
            }
        }
        if(voucherFiveDigitsId==null)
           voucherFiveDigitsId='';
        return voucherFiveDigitsId;
    }    
    
    public class DBTWrapper{
        public string amount;
        public string formattedAmount;
        public string bankName;
        public string creditedDate;
        public string description;
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