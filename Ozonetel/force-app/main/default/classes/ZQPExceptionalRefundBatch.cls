global class ZQPExceptionalRefundBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    
    public string query;
      
    public ZQPExceptionalRefundBatch (String strQuery)
    {
        if(String.isNotBlank(strQuery))
            Query = strQuery;
         else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='ZQPCaseExceptionalRefund'].QueryDetails__c;
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        DateTime now = System.now();
        System.Debug('query...'+Query);
        Query = Query+now.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        System.Debug('query...'+Query);
        return Database.getQueryLocator(Query);
    }
    
   global void execute(DataBase.BatchableContext bc, List<Case> lstcases) {
    	System.debug('Processing cases... Query: ' + Query);
	    List<DBLog_Summary__c> dblList = new List<DBLog_Summary__c>();
    	List<Case> csUpList = new List<Case>();
        List<casecomment> ccInsert = new List<casecomment>();
    	Http http = new Http();

    	for (Case cs : lstcases) {
        	try {
	            HttpRequest req1 = new HttpRequest();
    	        req1 = HttpRequestUtil.populateHeaders(req1);
        	    req1.setMethod('GET'); 
         	   	req1.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt WHERE DeveloperName = 'CapiMaxRefundableAPI'].Endpoint__c + cs.Order_UUId__c + '&tin=' + cs.TIN_No__c);
            	HttpResponse res1 = http.send(req1);
            	System.debug('REQUEST: ' + req1 + ' RESPONSE: ' + res1.getBody());

	            decimal maxRefundRespamount;
                if(res1.getStatusCode()==200){
					maxRefundRespamount = double.valueOf(res1.getBody());
            	}else{
             		maxRefundRespamount = 0;
           		}
				
	            ExceptionalRefundRequest exr = createRefundRequest(cs, maxRefundRespamount);
				string reqJson=Json.serialize(exr);
	            HttpRequest req = new HttpRequest();
    	        req.setTimeout(120000);
        	    req.setMethod('POST');
            	req.setBody(reqJson);
	            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt WHERE DeveloperName = 'TicketCancellation'].Endpoint__c);
    	        req.setHeader('Content-Type', 'application/json');
        	    req.setHeader('Channel_Name', 'SFA');
            	req.setHeader('auth_key', 'a8d87a36-3fdc-4207-bf94-18b2afe24f6b');
				req.setHeader('Country_Name','IND');
                req.setHeader('BusinessUnit','BUS');

          	  	HttpResponse resp = http.send(req);

	            logDBSummary(dblList, req, resp);
    	        if (resp.getStatusCode()==200) {
                    casecomment cc=new casecomment();
        			cc.parentId=cs.Id;
                    cc.commentbody='Closing Case after Exceptional Refund processed';
					ccInsert.add(cc);
        	        cs.Status = 'Closed';
            	    csUpList.add(cs);
            	}
        	} catch (Exception e) {
            	System.debug('Error processing case: ' + e.getMessage());
        	}
    	}

	    if (!dblList.isEmpty()) {
    	    Database.insert(dblList, false);
    	}
        if (!ccInsert.isEmpty()) {
        	try {
            	insert ccInsert;
        	} catch (DmlException e) {
            	System.debug('Error inserting case comments: ' + e.getMessage());
        	}
    	}
    	if (!csUpList.isEmpty()) {
        	try {
            	update csUpList;
        	} catch (DmlException e) {
            	System.debug('Error updating cases: ' + e.getMessage());
        	}
    	}
	}

	private ExceptionalRefundRequest createRefundRequest(Case cs, Decimal maxRefundRespamount) {
    	ExceptionalRefundRequest exr = new ExceptionalRefundRequest();
    	Refund oc = new Refund();
    	oc.currencyType = 'INR';
		if (maxRefundRespamount < cs.Refund_Amount__c) {
        	oc.amount=maxRefundRespamount;
        }
        else {
        	oc.amount=cs.Refund_Amount__c;
        }
        exr.refund = oc;
	    exr.orderItemUuid = cs.OrderItem_Uuid__c;
	    exr.reason = 'ZQP Incorrect Booking';
	    exr.ticketNo = cs.TIN_No__c;
    	exr.emailId = cs.Booking_Email_ID__c;
    	exr.mobileno = cs.Booking_Mobile_No__c;
    	exr.cancellationType = '1';
    	exr.selectedRefundType = 'BACK_TO_SOURCE';
    	exr.isExceptionalCancellation = true;
    	exr.IsExceptionalRefundApproved = false;
        exr.createdby = 'SF System';
        exr.selectedSeat='';
    	return exr;
	}

	private void logDBSummary(List<DBLog_Summary__c> dblList, HttpRequest req, HttpResponse resp) {
    	DBLog_Summary__c dbl = new DBLog_Summary__c();
    	dbl.Type__c = 'ZQP Exceptional Refund';
    	dbl.Request_Data__c = String.valueOf(req) + ' - Body -> ' + req.getBody();
    	dbl.EndPoint__c = req.getEndpoint();
    	dbl.Response_Received__c = String.valueOf(resp) + '..Body..' + resp.getBody();
    	dblList.add(dbl);
	}

    
    global void finish(DataBase.BatchableContext bc){
        
    }
    
    global class ExceptionalRefundRequest{
        public string ticketNo;
        public string selectedSeat;
        public string selectedRefundType;
        public Refund refund;
        public string reason;
        public string orderItemUuid;
        public string mobileno;
        public string emailId;
        public string createdby;
        public string cancellationType;
        public decimal exceptionalRefundCount;
        public boolean isExceptionalCancellation;
        public string operatorContribution;
        public boolean isZcafeApplied;
        public boolean IsExceptionalRefundApproved;
        public boolean isExceptionalBusCancellation;
        public boolean isBusCancellation;
        public string cnr;
    }
    global class Refund{
        public string currencyType;
        public double amount;
    }
}