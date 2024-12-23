/**
 * (c) 2017 RedBus
 *
 * Name           : NEFTApprovalInvoke
 * Created Date   : 04 Mar 2017
 * Created By     : Sreenivas M
 * Purpose        : Handler class to make a call to Wallet NEFT Approval
 * Test class     : NEFTApprovalInvoke_Test
 *
 **/
 
public class NEFTApprovalInvoke{
   @InvocableMethod
   public static void NEFTApprovalAPICall(List<string> caseId)
   {
         Case caseObj = new Case();
         NEFTResponse resp = new NEFTResponse();
         caseObj = [select id,InitiatedBy__c,AccountId,status,Owner.Name, NEFT_Status_Bit__c from Case where id=:caseId[0] limit 1];
         string cseName = caseObj.InitiatedBy__c;

         if('Reject for NEFT'.equalsIgnoreCase(caseObj.status))
         {
            caseObj.status='Closed';
            caseObj.NEFT_Status_Bit__c = true;
            caseComment cc=new caseComment();
            cc.CommentBody='Rejected for NEFT';
            cc.parentid=caseObj.id;
            insert cc;
            update caseObj;
            return;
         }
         
         if('Approved for NEFT'.equalsIgnoreCase(caseObj.status) && !caseObj.NEFT_Status_Bit__c)
         {
             NEFTApprovalInvoke.NEFTAPIping(caseId[0],caseObj.AccountId,cseName);
             system.debug('******resp*******'+resp  );
         }
         
      
   }
    
    /* API call for  NEFT with wallet debit*/
    @future(Callout=true)
    public static void NEFTAPIping(String csId,string accntId, string cseName)
    {
        
        NEFTResponse resp = new NEFTResponse();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        HttpResponse res = new HttpResponse();   
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        API_EndPoints__mdt apiProp = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='NEFTWalletDebit'];
        
        try
        {       
            Account accnt = [select id, Bank_Account_Number__c,BankName__c,IFSCCode__c,BranchName__c,Beneficiary_Name__c,Amount__c, PersonEmail, PersonMobilePhone ,User_Id__c from Account where id=:accntId limit 1];                      
            system.debug('******accnt *******'+accnt );
            string tempuserid = string.isblank(accnt.User_Id__c) ? '' : accnt.User_Id__c;
            
            string jsonbody = '{"emailId":"'+accnt.PersonEmail+'","IFSCCode":"'+accnt.IFSCCode__c+'","branchName":"'+accnt.BranchName__c+'","accountNumber":"'+accnt.Bank_Account_Number__c+'","bankName":"'+accnt.BankName__c+'","accHolderName":"'+accnt.Beneficiary_Name__c+'","mobileNo":"'+accnt.PersonMobilePhone+'","userId":"'+tempuserid +'","amount":"'+string.valueof(accnt.Amount__c)+'","cseName":"'+cseName+'","transactionType":"1"}';
            System.debug('body....'+jsonbody);
            
            req = HttpRequestUtil.populateHeaders(req);
            req.setMethod('POST');            
            req.setBody(jsonbody);
            req.setEndpoint(apiProp.Endpoint__c);
            
            dbl.Type__c = 'NEFT Wallet Debit';
            dbl.Payment_Request_Sent_Time__c = system.now();
            //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+jsonBody;
            dbl.Request_Data__c = string.valueof(req)+jsonBody;
            dbl.SentAt__c = system.now();
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            res = http.send(req);
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            string responseValue = res.getBody();
            Case caseObj = new Case(); 
            
            //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
            dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
            dbl.Payment_Request_Response_Time__c = System.now();
            caseComment cc=new caseComment();

            
            if(res.getStatus()=='OK' && res.getStatusCode()==200)
            {
                system.debug('------responseValue---------------'+responseValue);
                resp  = (NEFTResponse)JSON.deserialize( responseValue, NEFTResponse.class);
                system.debug('------resp  status 200---------------'+resp  );
                
                if(resp != null && resp.Status !=null && resp.Status.code=='200' && (resp.ResponseMessage =='Debit Successfull'))
                {
                    caseObj.status='Closed';
                    caseObj.NEFT_Status_Bit__c = true;
                    dbl.Payment_Ping_Status__c = 'NEFT Wallet Debit Success';
                    cc.CommentBody='NEFT Wallet Debit Success';
                    cc.parentid=Id.valueOf(csId);
                }
                else
                {
                    caseObj.status='Open';
                    dbl.Payment_Ping_Status__c = 'NEFT Wallet Debit Failed-'+resp.ResponseMessage;
                }
                
                if(resp.ResponseMessage == 'Insufficient Wallet Balance')
                {
                    caseObj.status='Closed';
                    caseObj.NEFT_Status_Bit__c = true;
                    dbl.Payment_Ping_Status__c = 'Insufficient Wallet Balance';
                    cc.CommentBody='Insufficient Wallet Balance';
                    cc.parentid=Id.valueOf(csId);
                }
            }
            
            else
            {
                caseObj.status='Open';
                dbl.Payment_Ping_Status__c = 'NEFT Wallet Debit Ping Failed';
            }
            If(cc.CommentBody!=null && cc.CommentBody!=''){
                insert cc;
            }
            caseObj.id = Id.valueOf(csId);
            update caseObj;
            if(apiProp.EnableLog__c)
                insert dbl;
        }
        
        Catch(Exception e)
        {
            dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.Payment_Ping_Status__c = 'NEFT Wallet Debit Exception';
            dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());              
            system.debug('-------NEFT API--Exception---------------'+e);
            if(apiProp.EnableLog__c)
                insert dbl;
            
            if(ApexPages.currentPage()!=null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
        
    }
     
   public class NEFTResponse
   {
         public string ResponseMessage{get;set;}
         public Status status{get;set;}
   }
    
    public class Status
    {
       
        public string code {get;set;}
        public string statusCode {get;set;}
        public string statusMessage {get;set;}
        public string error {get;set;}
        public string type{get;set;}
        
         public Status()
        {
            System.debug('Testing..'+code+statusCode+statusMessage+error+type);       }
    }    
    
}