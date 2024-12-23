/*
* Name           : GSTregulationSMSController
* Created Date   : 13 02 2022
* Created By     : Mahendra 
* Purpose        : 
* Test class     : GSTregulationSMSControllerTest
*/
public class GSTregulationSMSController{
    
    @Auraenabled(cacheable=false)
    public static string GetTicketDetails(string ordItemId, string EmailId){
        DBLog_Summary__c dbLog=new DBLog_Summary__c();
        dbLog.Type__c='Send GST Invoice';
        system.debug('ordItemId-->'+ordItemId);
        system.debug('EmailId-->'+EmailId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();

        ordIt=[select id,Service_Notes__c,isAggregator__c,Business_Unit__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Route_Id__c,Country__c from Order_Items__c where id=:ordItemId];
        
        if(!ordIt.isEmpty() && ordIt[0].isAggregator__c=='2'){
            try{
                system.debug('====');
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData=[SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='GSTregulationSMS'];
                system.debug('====endpoint====='+APIMData.Endpoint__c);
                string busUnit=ordIt[0].Business_Unit__c;
                //string body='{"tin":["'+ordIt[0].Order_Item_Reference_No__c+'"]}';
                string body='{"data": [{"tin": "'+ordIt[0].Order_Item_Reference_No__c+'","email": "'+emailid+'"}]}';
                http ht=new http(); 
                HttpRequest httpReq= new HttpRequest();                    
                httpReq.setEndpoint(APIMData.Endpoint__c);
                httpReq = HttpRequestUtil.populateHeaders(httpReq);
                httpReq.setMethod('POST');
                httpReq.setBody(body);
                system.debug('-==reqBody=='+httpReq.getBody());
                
                dbLog.Request_Data__c ='Request Data :::: '+string.valueof(httpReq)+'===jsonbody=='+body+'-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---countryname--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
                dbLog.Payment_Transaction_Name__c =ordIt[0].Id;
                HttpResponse res = ht.send(httpReq);
                dbLog.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                dbLog.EndPoint__c = String.valueOf(httpReq.getEndpoint());
                dbLog.CallOut_Status__c = string.valueOf(res.getStatus());
                
                string resBody=res.getBody();
                system.debug('===resBody===>>'+resBody);
                dbLog.Response_Received__c=resBody;
                insert dbLog;
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                    return 'GST SMS has been sent successfully';
                }else{
                    return 'No API Response';
                }
                
            }catch(Exception e){
                return 'Apex Error';
            }
            
        }else{
            return 'No Tin Found';
        }
        
    }
}