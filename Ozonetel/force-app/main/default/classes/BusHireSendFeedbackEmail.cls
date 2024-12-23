public class BusHireSendFeedbackEmail {
    public String LId{get;set;}
    
    public BusHireSendFeedbackEmail(ApexPages.StandardController sc) {
        Lead ld = [select TCodeHash__c from lead where id =:sc.getRecord().id ];
        Lid=ld.id;                 
    }
    
    @AuraEnabled
    public static string sendFeedbackEmail(string Lid){
        try
        {
            Lead ld = [select TCodeHash__c, Status from lead where id =:Lid ];
            if (ld.status != 'Converted'){
                return'status error';                
            }
            else{
                Http http = new Http();
                HttpRequest req = HttpRequestUtil.populateBusHireHeaders(new HttpRequest());
                HttpResponse res = new HttpResponse();
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='BusHireSendFeedbackEmail'].Endpoint__c+ld.TCodeHash__c);
                req.setMethod('GET');
                req.setHeader('Authorization','Basic UkJfU0ZBOmNKeXVlclh4Ui1lUFBsa2xsM1o1Sy15ZW12Ujg5WTJnLXA5MHF3Z0U1bUotZ2RIMjhpbmpZWQ==');
                res = http.send(req);
                if(res.getStatusCode() == 200){
                    return 'success';
                }
                else {
                    System.debug(res.getBody());
                    return 'Something went wrong. Please contact Admin!';
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Error..'+e);    
            return 'Something went wrong. Please contact Admin!';	
        } 
        
    }
    @AuraEnabled
    public static string sendWhatsappMessage(string Lid){
        try
        {
            Lead ld = [select TCodeHash__c, Status from lead where id =:Lid ];
            Http http = new Http();
            HttpRequest req = HttpRequestUtil.populateBusHireHeaders(new HttpRequest());
            HttpResponse res = new HttpResponse();
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='BusHireSendWhatsappMsg'].Endpoint__c+ld.TCodeHash__c);
            req.setMethod('GET');
            req.setHeader('Authorization','Basic UkJfU0ZBOmNKeXVlclh4Ui1lUFBsa2xsM1o1Sy15ZW12Ujg5WTJnLXA5MHF3Z0U1bUotZ2RIMjhpbmpZWQ==');
            res = http.send(req);
            system.debug('<<<res'+res.getBody());
            system.debug('<<<rescode'+res.getStatusCode());
            system.debug('<<<resstatus'+res.getstatus());
            APIResponse Resp = new APIResponse();
            Resp = (APIResponse)JSON.deserialize(res.getBody(),APIResponse.class);
            system.debug('resp'+resp);
            if(res.getBody() != null){
                system.debug('<<<resp'+resp);
                system.debug('resp.error'+resp.error);
                if(resp.error == null || resp.error =='' ){
                    return 'success';             
                }
                else{
                    string error = 'Error while sending message : '+resp.error;
                    return error;
                }               
            }
            else
                return 'Something went wrong. Please contact Admin!';	            	
        }
        catch(Exception e)
        {
            System.debug('Error..'+e);    
            return 'Something went wrong. Please contact Admin!';	
        }
    }
    public class Status{
			public Integer StatusCode{get;set;}
			public String StatusMsg{get;set;}
	}
    Public class APIResponse
    {
        public string Error{get;set;}
   		public Response Response{get;set;}
		public Status Status{get;set;}
    }		
		public class Response{
			public String Status{get;set;}
		}

}