/*
* Name           : RailsTicketCancellationCntrl
* Created Date   : 18 march 2022
* Created By     : Mahendra k
* Purpose        : Rails Ticket cancelllation Details Info
* Test class     : RailsTicketCancellationCntrlTest
*/
public class RailsTicketCancellationCntrl{
    
    @AuraEnabled(cacheable=true)
    public static string GetRailsIsCancellable(string ordItemId){
        system.debug('ordItemId-->'+ordItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Total_Fare__c,Amount_Recieved_Currency__c,Guid__c,Email_Copy__c,Email__c,Business_Unit__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Route_Id__c,Country__c from Order_Items__c where id=:ordItemId];
        system.debug('==ordIt='+ordIt);
        if(!ordIt.isEmpty()){
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='railsIsCancellable'];
            string tinNo =String.isNotBlank(ordIt[0].Order_Item_Reference_No__c)?ordIt[0].Order_Item_Reference_No__c:'';
            string emailid=String.isNotBlank(ordIt[0].Email__c)?ordIt[0].Email__c:ordIt[0].Email_Copy__c;
            string itemUuid = String.isNotBlank(ordIt[0].Guid__c)?ordIt[0].Guid__c:'';
            
            string jsonbody='{"tin":"'+tinNo+'","emailId":"'+emailid+'","seats":[],"uuid":"'+itemUuid+'"}';
            http ht=new http(); 
            HttpRequest httpReq= new HttpRequest();                    
            httpReq.setEndpoint(APIMData.Endpoint__c);
            httpReq.setMethod('POST');
            httpReq.setBody(jsonBody);
            httpReq = HttpRequestUtil.populateCAPIHeaders(httpReq);
            system.debug('===isCanclResbody=='+httpReq.getBody());
            httpReq.setHeader('BusinessUnit','RAILS');   
            httpReq.setHeader('Currency','INR');        
            string jsonHeaders='-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---Country_Name--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
            try{                
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                system.debug('===isCanclRes=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsIsCancellable',APIMData.Endpoint__c,tinNo,jsonBody,resBody,jsonHeaders,'');
                    return res.getBody();
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsIsCancellable',APIMData.Endpoint__c,tinNo,jsonBody,resBody,jsonHeaders,'');
                    return res.getBody();
                }
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsIsCancellable',APIMData.Endpoint__c,tinNo,jsonBody,'Try catch exception',jsonHeaders,String.valueOf(e));
                return 'Apex Error';
            }
        }else{
            return 'No Tin Found';
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static string railsV1Cancel(string orderItemId,list<string> selSeats){   
        system.debug('orderItemId-->' +orderItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Total_Fare__c,Business_Unit__c,Order_Item_Reference_No__c,Date_Of_Purchase__c,Guid__c,Email__c,Email_Copy__c,No_of_seats__c,Country__c from Order_Items__c where id=:orderItemId];
        string tin = ordIt[0].Order_Item_Reference_No__c;
        string emailId = ordIt[0].Email__c;
        string itemUuid = ordIt[0].Guid__c;
        
        //return 'success';
        system.debug('railsV1Cancel-->' );
        if(!ordIt.isEmpty()){
            datetime curDtme = system.now();
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            string seats =JSON.serialize(selSeats);
            string jsonbody='{"tin":"'+tin+'","emailId":"'+emailid+'","seats":'+seats+',"uuid":"'+itemUuid+'"}';
            APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='railsv1Cancel'];
            
            dateTime dT=ordIt[0].Date_Of_Purchase__c;
            Date myOrDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            date  errorDate = date.newInstance(2022, 6, 13);
            
            http ht=new http(); 
            HttpRequest httpReq= new HttpRequest();                    
            httpReq.setEndpoint(APIMData.Endpoint__c);
            httpReq.setMethod('POST');
            httpReq.setBody(jsonBody);
            httpReq = HttpRequestUtil.populateCAPIHeaders(httpReq);
            system.debug('===body=='+ httpReq.getBody());
            httpReq.setHeader('BusinessUnit','RAILS');  
            httpReq.setHeader('Currency','INR');              
            string jsonHeaders='Headers-Channel_Name-'+httpReq.getHeader('Channel_Name')+'---Country_Name--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
            try{                
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                system.debug('===V1canclRes=='+res.getBody());
                
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsV1Cancel',APIMData.Endpoint__c,tin,jsonBody,resBody,jsonHeaders,'');
                    return res.getBody();
                }else{
                    system.debug('-else--'+res.getBody());
                    if(myOrDate < errorDate){
                        
                        string errMsgtoshw='Please Cancel the Ticket manually because Date Of Purchase is less than 13th June';
                        string respJson='{"errorcode":"","errormsg":"","detailedmsg":"'+errMsgtoshw+'"}';
                        DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsV1Cancel',APIMData.Endpoint__c,tin,jsonBody,respJson,jsonHeaders,errMsgtoshw);
                        return respJson;
                    }else{
                        DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsV1Cancel',APIMData.Endpoint__c,tin,jsonBody,resBody,jsonHeaders,'');
                        return res.getBody();
                    }
                }
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsV1Cancel',APIMData.Endpoint__c,tin,jsonBody,'Try Catch Exception',jsonHeaders,String.valueOf(e));
                return 'Apex Error';
            }
        }else{
            return 'No Tin Found';
        }
    }
    
}