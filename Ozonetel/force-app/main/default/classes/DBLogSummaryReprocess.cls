public class DBLogSummaryReprocess 
{
    public string DBLogId {get; set;}
    public boolean ButtonShow {get; set;}
    public list<attachment> DBLogAttachment;
    public string response {get; set;}
    public DBLogSummaryReprocess(ApexPages.StandardController controller) 
    {
        DBLogId = ApexPages.currentPage().getParameters().get('id'); 
        DBLogAttachment = new list<attachment>();
    }
    public void DBLogButtonEnable()
    {
        
        DBLogAttachment = [select id, Body, ParentId from attachment where ParentId=:DBLogId limit 1];
        if(!DBLogAttachment.isEmpty())
        {
            ButtonShow =  True;
        }
        else
        {
            ButtonShow = False;   
        }
    }
    public void SessionIdPing()
    {
        DBLogAttachment = [select id, Body, ParentId from attachment where ParentId=:DBLogId limit 1];
        if(!DBLogAttachment.isEmpty())
        {
            string BookingData;
            for(attachment att: DBLogAttachment)
            {
                BookingData = att.Body.tostring();
                if(!string.isBlank(BookingData))
                {
                    HttpRequest req = new HttpRequest();
                    req.setTimeout(120000);
                    HttpResponse res = new HttpResponse();
                    Http http = new Http(); 
                    req.setEndpoint(system.Label.SalesforceAPI+'/services/apexrest/redBus/redBus_Booking/');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Authorization','Bearer '+UserInfo.getSessionId());
                    req.setMethod('POST');
                    req.setBody(BookingData);
                    try
                    {
                        res = http.send(req);
                        string responseValue = res.getBody();
                        if(res.getStatusCode()==200)
                        {
                            response = 'Success';
                        }
                        else
                        {
                            response = 'Fail';
                        }
                    }
                    catch(exception e)
                    {
                        response = 'Fail';
                    }
                }
            }
        }
    }

}