/**
 * (c) 2018 RedBus
 *
 * Name           : BusHireSendNPSEmail
 * Created Date   : 06 Mar 2018
 * Created By     : Sreenivas M
 * Purpose        : Controller class to send the BusHire NPS Email
 *
 **/
global class BusHireSendNPSEmail
{
    webservice static string sendNPSmail(String Tcode)
    { 
        Http ht = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = HttpRequestUtil.populateBusHireHeaders(new HttpRequest());
        req.setMethod('GET');
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='BusHireNPS'].Endpoint__c+Tcode);
        res = ht.send(req);
        System.debug('response..'+res+'..Body..'+res.getBody());
        if(res.getStatusCode()==200 && res.getStatus()=='OK' && res.getBody()!=null)
        {
                    
            NPSResponse npsResp = new NPSResponse();
            npsResp = (NPSResponse)JSON.deserialize(res.getBody(),NPSResponse.class);
            System.debug('npsResp response..'+npsResp);
            if(npsResp.Status!=null && npsResp.Status.get('StatusCode')=='200' && npsResp.Response!=null && String.isNotBlank(npsResp.Response.get('Data')))
            {
            return JSON.serialize('Email Has Sent Successfully');
            }
            else
            {
            String errMsg = 'Error while sending an email--'+npsResp.Error.get('ErrorMsg');
            return JSON.serialize(errMsg);
            }
        }
        return JSON.serialize('Unable To Send Request...Status Code is -'+res.getStatusCode());
    }
    
    Public class NPSResponse
   {
    public Map<String,String> Error{get;set;}
    public Map<String,String> Response{get;set;}
    public Map<String,String> Status{get;set;}
   
   }
}