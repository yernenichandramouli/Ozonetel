/*
* Name           : DBTConfirmGeneric
* Created Date   : 14 Aug 2020
* Created By     : Veeramanikanta R
* Purpose        : API to Confirm DBT Transactions
* Test class     : API_DBTConfirmationTest
*/
public class DBTConfirmGeneric{
    
    public API_DBTConfirmation.Response voucherMatch(string source,string voucherId, string bankName,decimal amount,string createdDate){
        System.debug('voucherId->'+voucherId+'<---bankName-->'+bankName+'<---amount--->'+amount+'<--createdDate--->'+createdDate);
        API_DBTConfirmation.Response resp=new API_DBTConfirmation.Response();
        decimal addedAmount=amount+1000;
        decimal lessAmount=amount-1000;
        decimal greaterAmount=amount+1500;
        datetime dayValue=date.valueOf(createddate);
        datetime addDay=date.valueOf(createddate).adddays(1);
        
        System.debug('dayValue->'+dayValue+'<--addDay-->'+addDay+'<--addedAmount-->'+addedAmount);
        List<case> csList=new List<case>();
        String resultValue;
        List<Payment_Items__c> payLs=new List<Payment_Items__c>();
        csList=[select id,casenumber,Trip_Id_ct__c,Review__c,Transaction_ID__c,ID_ctp__c,Bank_Name__c,Amount__c,createddate from case where  createddate>=:dayValue and createddate<=:addDay and issue_type__c='DBT' and Bank_Name__c=:bankName and Amount__c=:amount];
        if(!csList.isEmpty()){
            List<DBT__c> dbtAmountLs=new List<DBT__c>();
            dbtAmountLs=[select id,AmountF__c from DBT__c where AmountF__c=:amount and Bank_Name__c=:bankName and createddate>=:dayValue and createddate<=:addDay];
            if(!dbtAmountLs.isEmpty()){
                payLs=[select id,Payment_System__c,Guid__c,Order_ID__c,Creation_Time__c,Account_Holder_Name__c from Payment_Items__c where Order_ID__c=:csList[0].Trip_Id_ct__c and Payment_System__c ='ONLINE' and Account_Holder_Name__c!='' ORDER BY Creation_Time__c DESC limit 1];
                if(!payLs.isEmpty() && string.isNotBlank(payLs[0].Guid__c)){
                    resp=ConfirmDBT(source,csList[0],amount,bankName,csList[0].id_ctp__c,payLs[0].Guid__c);               
                    return resp;
                }else{
                    resp.statusCode=200.10;
                    resp.message='Amount Matched But Payment Item Not available'; 
                    return resp;
                }
            }else{
                resp.statusCode=200.16;
                resp.message='Amuout is not Paid'; 
                return resp;
            }
        }else{
            csList=new list<case>();
            //createddate>=:dayValue and createddate<=:addDay and  and Amount__c<:addedAmount 
            csList=[select id,casenumber,Trip_Id_ct__c,Review__c,Transaction_ID__c,ID_ctp__c,Bank_Name__c,Amount__c,createddate from case where createddate>=:dayValue and createddate<=:addDay and  issue_type__c='DBT' and id_ctp__c!='' and id_ctp__c=:voucherId and Bank_Name__c=:bankName and Amount__c<:addedAmount  limit 1];
            System.debug('csList-->'+csList);
            List<DBT__c> dbtAmountLs=new List<DBT__c>();
            dbtAmountLs=[select id,AmountF__c,Voucher_Id__c from DBT__c where Voucher_Id__c=:voucherId and Bank_Name__c=:bankName and createddate>=:dayValue and createddate<=:addDay];

            if(!dbtAmountLs.isEmpty() && !csList.isEmpty() && string.isNotBlank(voucherId)){
                payLs=[select id,Payment_System__c,Guid__c,Order_ID__c,Creation_Time__c,Account_Holder_Name__c from Payment_Items__c where Order_ID__c=:csList[0].Trip_Id_ct__c and Payment_System__c ='ONLINE' and Account_Holder_Name__c!='' ORDER BY Creation_Time__c DESC limit 1];
                if(!payLs.isEmpty() &&string.isNotBlank(payLs[0].Guid__c)){
                    resp=ConfirmDBT(source,csList[0],amount,bankName,csList[0].id_ctp__c,payLs[0].Guid__c);              
                    return resp;
                }else{
                    resp.message='Voucher Matched But Payment Item Not available'; 
                    resp.statusCode=200.12;
                    return resp;
                }
            }else{
                resp.message='Amount or Voucher Not matched';
                resp.statusCode=200.14;
                return resp;
            }
        }        
    }
    
    public API_DBTConfirmation.Response ConfirmDBT(string source,case cObj,decimal amount,string bankName,string voucherId,string paymentUUID){
        API_DBTConfirmation.Response resp=new API_DBTConfirmation.Response();
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='DBT'];
        String userName=UserInfo.getName()+'('+UserInfo.getUserName()+')';
        userName= userName.replace('@', '-');
        string bankRefId=cObj.casenumber;
        string slatId='656d7f6d7hf6adf68ds77fd6sd8fs7d86f7ds6f7s';               
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
        }  */
        // string  hashValue=encryptedValue;
        System.debug('The given value is = '+(paymentUUID+'|'+bankRefId+'|'+slatId));
       string  hashValue=GenericUtils.getsha512hash(paymentUUID+'|'+bankRefId+'|'+slatId);
		System.debug('The hash value is = '+hashValue);
        if(hashValue!=null){
            
            DBTConfirmHandler.Request reqW=new DBTConfirmHandler.Request('true',userName,paymentUUID,bankRefId,hashValue);
            String dbtJson=json.serialize(reqW); 
            System.debug('Something is = '+dbtJson);

            HTTP h = new HTTP();
            HttpRequest req= new HttpRequest();
            HTTPResponse res=new HTTPResponse();        
            req.setMethod('POST');
            req.setBody(dbtJson);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Country_Name', 'IDN'); 
            req.setTimeout(100020);
            req.setendpoint(APIMData.Endpoint__c);                   
            System.debug('req body-->'+req);
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.Type__c = 'DBT Confirmation-'+source;
            dbl.Request_Data__c=req.getbody();
            dbl.Payment_Transaction_Name__c=cObj.transaction_id__c;
            res=h.send(req);
            system.debug('<<<res'+res);
            system.debug('<<es.getBody()'+res.getbody());
            dbl.Response_Received__c=res.getbody();
            insert dbl;
            List<DBT__c> dbtObjLs=new List<DBT__c>();
            dbtObjLs=[select id,Description__c,Voucher_Id__c from DBT__c where Voucher_Id__c=:voucherId];
            
            DBT__c dObj=new DBT__c();
            if(!dbtObjLs.isEmpty()){
                dObj.id=dbtObjLs[0].id;
            }
            dObj.case__c=cObj.id;
            dObj.bank_name__c=bankName;
            dObj.amount__c=string.valueOf(amount);
            //  dObj.Formatted_Amount__c=formattedAmount;
            dObj.Trip_Id__c=cObj.Trip_Id_ct__c;
            
            map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());    
            system.debug('<<resObj'+resObj);
            if(string.valueOf(resObj.get('isTicketGenrated'))=='true'){
                
                dObj.Status__c='Ticket Generated';
                upsert dObj;
                case c=new case();
                c=cObj;
                c.status='Closed';
                c.Review__c=Source;               
                CaseComment csComm = new CaseComment();
                csComm.ParentId = cObj.id;
                csComm.commentBody = 'DBT Ticket Confirmed successfully';
                insert csComm;
                update c;
                dbl.Payment_Ping_Status__c='Ticket Generated';
                resp.message='Ticket Generated';
                resp.statusCode=200;
                return resp;
            } else if(string.valueOf(resObj.get('IsvoucherExpired'))=='true'){
                
                dObj.status__c='Voucher Expired';
                upsert dObj;
                case c=new case();
                c=cObj;
                c.status='Open';
                c.Review__c=Source;
                CaseComment csComm = new CaseComment();
                csComm.ParentId = cObj.id;
                csComm.commentBody = 'Voucher is Expired';
                insert csComm;               
                update c;
                
                dbl.Payment_Ping_Status__c='Voucher Expired';
                resp.message='Voucher Expired';
                resp.statusCode=200.2;
                return resp;
            }else if(string.valueOf(resObj.get('isGFT'))=='true'){
                dObj.status__c='GFT';
                upsert dObj;
                case c=new case();
                c=cObj;
                c.status='Open';
                c.Review__c=Source;
                CaseComment csComm = new CaseComment();
                csComm.ParentId = cObj.id;
                csComm.commentBody = 'Ticket not generated!! Turned to GFT';
                insert csComm;               
                update c;
                dbl.Payment_Ping_Status__c='GFT';
                resp.message='GFT';
                resp.statusCode=200.4;
                return resp;
            }else{
                resp.message='Ticket Not Generated';
                resp.statusCode=200.6;
                return resp;
            }
        }else{
            resp.message='Failed! Hash Failed';
            resp.statusCode=200.8;
            return resp;
        }        
    }    
}