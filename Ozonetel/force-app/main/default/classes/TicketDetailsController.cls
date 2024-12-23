/*
* Name           : TicketDetailsController
* Created Date   : 20 Oct 2020
* Created By     : Veeramanikanta R
* Purpose        : Fetch Ticket Details Info
* Test class     : TicketDetailsControllerTest
*/
public class TicketDetailsController{
    
    @Auraenabled(cacheable=true)
    public static string GetTicketDetails(string ordItemId,string type){
        system.debug('ordItemId-->'+ordItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Service_Notes__c,Amount_Recieved_Currency__c,Business_Unit__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Route_Id__c,Country__c from Order_Items__c where id=:ordItemId];
        if(!ordIt.isEmpty()){
            String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketDetails'].Endpoint__c;
            string busUnit=ordIt[0].Business_Unit__c;
            http ht=new http(); 
            HttpRequest httpReq= new HttpRequest();                    
            httpReq.setEndpoint('callout:Ticket_Details/'+ordIt[0].Order_Item_Reference_No__c);
            httpReq = HttpRequestUtil.populateHeaders(httpReq);
            httpReq.setMethod('GET');
            httpReq.setHeader('Channel_Name','MOBILE_APP');
            httpReq.setHeader('auth_key','487a342c-92f1-41ae-81fa-aaa5120f6bb3');
            httpReq.setHeader('Country_Name','IND');
            try{                
                if('REDBUS_COM'.equalsIgnoreCase(busUnit)){
                    httpReq.setHeader('Country_Name','RDC');
                    httpReq.setHeader('SelectedCurrency',ordIt[0].Amount_Recieved_Currency__c);
                    httpReq.setHeader('Currency',ordIt[0].Amount_Recieved_Currency__c);
                }else{
                    httpReq.setHeader('Country_Name',OrderItemTransactionResource__c.getValues(busUnit).Auth_Key__c);
                    httpReq.setHeader('SelectedCurrency',OrderItemTransactionResource__c.getValues(busUnit).Default_Currency__c);
                }
                
                if(string.isNotBlank(busUnit) &&!busUnit.startsWith('REDBUS_'))
                {
                    httpReq.setHeader('Operator',busUnit.split('_')[0]);
                }
                
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                    return res.getBody();
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
    
    @Auraenabled
    public static string GetCoPassengerDetails(string ordItemId,string type){
        system.debug('ordItemId-->'+ordItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        try{
            ordIt=[select id,Date_Of_Service__c,Boarding_Time__c,Dropping_Time__c,ServiceID__c,Business_Unit__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Route_Id__c,Country__c from Order_Items__c where id=:ordItemId];

            if(!ordIt.isEmpty()){
                DateTime boardingPointEpoch = Datetime.newInstance(ordIt[0].Boarding_Time__c.date(),Time.newInstance(24, 00, 00, 0));
                DateTime droppingPointEpoch = Datetime.newInstance(ordIt[0].Dropping_Time__c.date(),Time.newInstance(23, 59, 59, 0));
                long strEpoch=boardingPointEpoch.getTime()/1000;
                long endEpoch=droppingPointEpoch.getTime()/1000;
                string BusUnit = 'REDBUS_'+ordIt[0].Business_Unit__c.split('_')[1];
                Country_Codes__c ccObj= Country_Codes__c.getValues(BusUnit);  
                string ounit=ccObj.ou__c;  
                String endpoint;
                if(BusUnit=='REDBUS_IN'){
                endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='CoPassengerDetails'].Endpoint__c+'&serviceid='+ordIt[0].ServiceID__c+'&operatorid='+ordIt[0].Service_Provider_Id__c+'&startepocsec='+strEpoch+'&endepocsec='+endEpoch+'&ou='+ounit;
               }else{
                endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='CoPassengerDetailsIntl'].Endpoint__c+'&serviceid='+ordIt[0].ServiceID__c+'&operatorid='+ordIt[0].Service_Provider_Id__c+'&startepocsec='+strEpoch+'&endepocsec='+endEpoch+'&ou='+ounit;
                }
               
                //endPoint='http://neon.intlomsproxy.redbus.in/v2/ticket?a=121&serviceid=64824&operatorid=18819&startepocsec=1614819359&endepocsec=1614855359&ou=2';
                // endPoint='http://intl-api.neon.redbus.com/v2/ticket?a=121&serviceid=64824&operatorid=18819&startepocsec=1614819359&endepocsec=1614855359&ou=2';
                HttpResponse res = new HttpResponse();
                Map<String, String> omsHeaders= new Map<String, String>();
                omsHeaders.put('Content-Type','application/json');
                res = HTTPUtil.sendGenericHTTPRequest(endpoint,'GET','""',omsHeaders,100000,'Get Co-Pass Details');
                
                // string jsonResp='{ "status": { "type": "SUCCESS", "description": "Operation successfully completed", "code": "200" }, "errors": [  ], "data": [{ "orderId" : "12345678" "orderItemId" : "123455678" "status" : "CONFIRMED" "name" : "XYZ" "email" : "xyz@gmail.com" "phone" : "9875643232" } ] }';
               // string jsonResp='{ "status": { "type": "SUCCESS", "description": "Operation successfully completed", "code": "200" }, "errors": [], "data": [{ "orderId": "12345678", "orderItemId": "123455678", "status": "CONFIRMED", "name": "XYZ", "email": "xyz@gmail.com", "phone": "9875643232" } ] }';
            //    system.debug('::: Request :::'+req.getbody());
               system.debug('::: Request :::'+String.valueOf(res+'..Body..'+res.getBody()));
                return res.getBody();
            }else{
                return 'No Tin Found';           
            }
        }catch(Exception e){
            return 'Apex Error';
        }
    }
}