global class ExperiencesCancellation

{
    public static string activityUuid{get;set;}
    public static string endPoint{get;set;}
    public static Activities__c actObj{get;set;}
    public static Id recId{get;set;}

    public ExperiencesCancellation(ApexPages.StandardController controller)
    {
        System.debug('ExperiencesCancellation...');
        //Id recId = ApexPages.CurrentPage().getparameters().get('id');
        recId = controller.getId();
        actObj = new Activities__c();
        actObj = [Select id,Activity_uuid__c,Customer_Email_id__c from Activities__c Where Id=:recId];
        activityUuid = actObj.Activity_uuid__c;
        System.debug('actObj con'+actObj);

    }

    @AuraEnabled
    public static string isCancellable(String recdId)
    {
        System.debug('isCancellable..');
        String IsCan = '';
         Cancellation_Process_DB_Log__c cpr = new Cancellation_Process_DB_Log__c();
        try
        {
            if(String.isNotBlank(recdId))
            {  
                cpr.Type__c='isCancellable';
                actObj = [Select id,Activity_uuid__c,Order_Id__c,Customer_Email_id__c from Activities__c Where Id=:recdId];
                cpr.OrderItemUuid__c = actObj.Activity_uuid__c; 
                cpr.Trip_Id__c = actObj.Order_Id__c;
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('AuthToken','a5dc7b12-face-4c15-859e-beddbb775b80,2c285f83-852d-4b26-a7cb-35ea0305956c,1be75928-100f-4941-8ec1-0d5e43ab796f,d130404b-7313-425d-bc12-2a8e52adb15e');
                req.setTimeout(120000);              
                endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='IsActivityCancellableURL'].Endpoint__c;
                req.setEndpoint(endPoint+actObj.Activity_uuid__c+'/refund-details');
                req.setMethod('GET');
                System.debug('req..'+req);
                cpr.IsCacellable_API_Request_Data__c = string.valueof(req)+'Body :'+': Headers Info:AuthToken:a5dc7b12-face-4c15-859e-beddbb775b80,2c285f83-852d-4b26-a7cb-35ea0305956c,1be75928-100f-4941-8ec1-0d5e43ab796f,d130404b-7313-425d-bc12-2a8e52adb15e';
                res = http.send(req);                      
                string responseValue = res.getBody();
                cpr.IsCacellable_API_Request_Response__c = string.valueof(res)+' Body : '+responseValue; 
                IsCan = JSON.serialize(responseValue);
 
            }
        }
        catch(Exception e)
        {
            System.debug('Error..'+e);
            cpr.IsCacellable_API_Request_Response__c = String.valueof(e);

        }
        insert cpr;
        return IsCan;

    }

    @AuraEnabled
    public static string cancelActivity(string recId)
    {
       
        System.debug('cancelActivity..');
        String respString='';
          
        Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();
        try
        {
            if(String.isNotBlank(recId))
            {   
                cp.Type__c='Cancel Activity';
                actObj = [Select id,Activity_uuid__c,Order_Id__c,Customer_Email_id__c from Activities__c Where Id=:recId];
                cp.OrderItemUuid__c = actObj.Activity_uuid__c; 
                cp.Trip_Id__c = actObj.Order_Id__c;
                cp.Message__c = 'Cancellation Validation Check';
                if(actObj!=null && String.isNotBlank(actObj.Activity_uuid__c))
                {
                    try
                    {
                        cp.Message__c= 'Cancellation Started';
                        Http ht = new Http();
                        HttpRequest req = new HttpRequest();
                        HttpResponse resp = new HttpResponse();
                        req.setHeader('Content-Type', 'application/json');
                        req.setHeader('AuthToken', 'a5dc7b12-face-4c15-859e-beddbb775b80,2c285f83-852d-4b26-a7cb-35ea0305956c,1be75928-100f-4941-8ec1-0d5e43ab796f,d130404b-7313-425d-bc12-2a8e52adb15e');
                        req.setMethod('POST');
                        System.debug('endPoint..'+endPoint);
                        System.debug('actObj..'+actObj);
                        endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='IsActivityCancellableURL'].Endpoint__c;
                        req.setEndpoint(endPoint+actObj.Activity_uuid__c+'/cancel');
                        HttpRequestWrappersUtil.ActivityCancelRequest canReq = new HttpRequestWrappersUtil.ActivityCancelRequest();
                        canReq.backToSource = true;
                        canReq.cancelledBy = UserInfo.getName()+'('+UserInfo.getUserName()+')';
                        canReq.emailID = actObj.Customer_Email_id__c;
                        canReq.reason = 'As requested by customer';
                        req.setBody(JSON.serialize(canReq));
                        cp.NC_API_Request_Data__c = string.valueof(req)+'Body :'+JSON.serialize(canReq)+': Headers Info:AuthToken:a5dc7b12-face-4c15-859e-beddbb775b80,2c285f83-852d-4b26-a7cb-35ea0305956c,1be75928-100f-4941-8ec1-0d5e43ab796f,d130404b-7313-425d-bc12-2a8e52adb15e';
                        resp =  ht.send(req);
                        cp.Message__c= 'Cancellation Finished';
                        cp.NC_API_Request_Response__c =resp.getBody();
                        respString= JSON.serialize(resp.getBody());
                        
                    } catch (Exception e) {
                        System.debug('Error in Cancellation..'+e);
                        respString= JSON.serialize(e);
                        cp.NC_API_Request_Response__c =respString;
                        cp.Message__c= 'Cancellation Failed';
                    }
                   
                }
                
            }
        }
        catch(Exception e)
        {
             cp.Message__c= 'Cancellation Error';
             cp.Detailed_Message__c = String.valueof(e);
             respString= JSON.serialize(e);
        }
        System.debug('respString..'+respString);
        cp.FCU_API_Response_Data__c = respString;
        insert cp;
        return respString;
     
    }
}