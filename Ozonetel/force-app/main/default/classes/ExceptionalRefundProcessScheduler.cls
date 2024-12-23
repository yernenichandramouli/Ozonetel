global class ExceptionalRefundProcessScheduler implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        Date PriviousDays = System.Today().addDays(-Integer.Valueof(Label.WFTDeletionTime));
        string caseQuery = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='CaseExceptionalRefund'].QueryDetails__c;
        return DataBase.getQueryLocator(caseQuery);
    }
    
    global void execute(DataBase.BatchableContext bc,List<case> caseList)
    {
        List<Cancellation_Process_DB_Log__c> cpList=new List<Cancellation_Process_DB_Log__c>();
        List<case> csUpList=new List<case>();
        map<id,case> caseMap = new map<id,case>();
        Set<String> allowedExceptionalErrorMsg = new Set<String>(System.label.ExceptionalRefundValidErrorMsg.split(';'));
        
        for(case cObj:caseList){
            ExceptionalRefundRequestApprove exr=new ExceptionalRefundRequestApprove();
            exr.isApproved=true;
            exr.orderItemUuid=cObj.OrderItem_Uuid__c;
            exr.orderUuid=cObj.Order_UUId__c;
            exr.approvedBy='SF System';
            exr.channel='SFA';
            OperatorContribution oc=new OperatorContribution();
            oc.currencyType='INR';
            
            if(cObj.parent.Refund_Type__c=='Instant resolution - BO contest Accepted'){
              oc.amount=0;
            }else if(cObj.parent.Refund_Type__c =='Instant resolution - BO contest partially approved' || cObj.Refund_Type__c=='Instant resolution - BO contest partially approved'){

               oc.amount=cObj.parent.FC_Refunded_Amount__c!=null ? cObj.parent.FC_Refunded_Amount__c : cObj.FC_Refunded_Amount__c!=null ? cObj.FC_Refunded_Amount__c :0;
            }else{
             oc.amount=cObj.Refund_amount__c;
            }
            
            
            // exr.operatorContribution.currencyType='INR';
            //exr.operatorContribution.amount=cObj.Refund_amount__c;
            exr.operatorContribution=oc;
            string reqJson=Json.serialize(exr);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();        
            req.setTimeout(120000);
            req.setHeader('Channel_Name','WEB_DIRECT');
            req.setHeader('auth_key','fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
            req.setHeader('Country_Name','IND');
            req.setHeader('Content-Type','application/json');
            req.setHeader('BusinessUnit','BUS');
            req.setMethod('PUT');
            req.setBody(reqJson);         
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='ExceptionalRefundApproval'].Endpoint__c);
            res=http.send(req);
            string respJson=res.getBody();            
            Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();
            cp.Type__c='Exceptional Refund-BO Settlement';
            cp.Trip_Id__c=cObj.Order_UUId__c;
            cp.Code__c=cObj.casenumber;
            cp.FC_API_Request_Data__c=reqJson;
            cp.FC_API_Request_Response__c=respJson;
            cp.Transaction_Name__c = cObj.Transaction_ID__c;
            
            string ss='{ "status": "SUCCESS", "error_message": "", "error_code": 0, "data": { "orderUuid": "5aaa2016e00df0055722993401010100", "orderItemUuid": "48aefbf3e030f0055722993401020100", "orderItemId": 13230982928261017, "orderId": 13229782750789809, "approval": "SUCCESS", "operatorContribution": { "currencyType": "INR", "amount": 163.91 } } }';
            if(respJson!=''){
                try{
                    map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(respJson);
                    string ob=JSON.serialize(resObj.get('data'));
                    string errorMessage = string.isNotBlank(string.valueOf(resObj.get('error_message')))?string.valueOf(resObj.get('error_message')):'';
                    System.debug('ob-->'+ob);
                    map<string,object> resObj1= (map<string,object>)JSON.deserializeUntyped(string.valueOf(ob));
                    System.debug('o-->'+resObj1.get('approval'));
                    
                    if((resObj1!=null && resObj1.get('approval')=='SUCCESS') || (resObj.get('error_code')==7 && allowedExceptionalErrorMsg.contains(errorMessage))){
                        cObj.Refund_Type__c='Instant resolution - BO Accepted';
                        if(string.isNotBlank(cObj.Category__c))
                            cObj.Category__c=cObj.Category__c+',Scheduler-Instant resolution - BO Accepted';
                        else
                            cObj.Category__c='Scheduler-Instant resolution - BO Accepted';
                        case cParObj=new case();
                        cParObj.id=cObj.parentId;
                        cParObj.Refund_Type__c='Instant resolution - BO Accepted';
                        csUpList.add(cObj);
                        if(!csUpList.contains(cParObj)){
                            csUpList.add(cParObj);
                        }
                    }
                }catch(Exception e){
                    cp.FC_API_Request_Response__c=string.valueOf(e);
                }
            }
            cpList.add(cp);
        }
        //create a map that will hold the values of the list 
        caseMap.putAll(csUpList);

        if(!cpList.isEmpty()){
            DataBase.insert(cpList,false);
            
        }
        if(caseMap.size()>0){
            DataBase.update(caseMap.values(),false);
        }
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(Label.Transaction_Report_Recipients.Split(','));
        mail.setToAddresses(toAddresses);
        mail.setSubject('Exceptional Refund Process Scheduler: '+a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    global class ExceptionalRefundRequestApprove{
        public boolean isApproved;
        public string orderItemUuid;
        public string orderUuid;
        public string approvedBy;
        public string channel;
        public OperatorContribution operatorContribution;
    }
    global class OperatorContribution{
        public string currencyType;
        public decimal amount;
    }
}