/*
* Name           : RailsPostRefundBreakCntrl
* Created Date   : 06 feb 2023
* Created By     : Mahendra k
* Purpose        : Rails refundBreakup post cancellation
* Test class     : RailsPostRefundBreakCntrlTest
*/
public class RailsPostRefundBreakCntrl{
    
 @AuraEnabled(Cacheable=true)
    public static string GetRailsRefundBreak(string ordItemId){
        system.debug('ordItemId-->'+ordItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Total_Fare__c,Amount_Recieved_Currency__c,Guid__c,Email_Copy__c,Email__c,Business_Unit__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Route_Id__c,Country__c from Order_Items__c where id=:ordItemId];
        system.debug('==ordIt='+ordIt);
         http ht=new http(); 
         HttpRequest httpReq= new HttpRequest(); 
        if(!ordIt.isEmpty()){
          API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='RailspostRefundbreakAPI'];
                string  itemUUid=String.isNotBlank(ordIt[0].Guid__c)?ordIt[0].Guid__c:'';
                string jsonbody='{"tin":"","emailId":"","itemUuid":"'+itemUUid+'"}';                 
                httpReq.setEndpoint(APIMData.Endpoint__c);
                httpReq.setMethod('POST');
                httpReq.setBody(jsonBody);
                httpReq = HttpRequestUtil.populateCAPIHeaders(httpReq);
                system.debug('===isCanclResbody=='+httpReq.getBody());
                httpReq.setHeader('BusinessUnit','RAILS');        
                string jsonHeaders ='===jsonbody=='+jsonbody+'-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---countryname--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
            try{                
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                system.debug('===isCanclRes=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                   DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsRefundBreak',APIMData.Endpoint__c,ordIt[0].Order_Item_Reference_No__c,jsonbody,resBody,jsonHeaders,'');
                    return res.getBody();
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsRefundBreak',APIMData.Endpoint__c,ordIt[0].Order_Item_Reference_No__c,jsonbody,resBody,jsonHeaders,'');
                    return res.getBody();
                }
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsRefundBreak',APIMData.Endpoint__c,ordIt[0].Order_Item_Reference_No__c,'','',jsonHeaders,String.valueOf(e));
                return 'Apex Error';
            }
        }else{
            return 'No Tin Found';
        }
    }
   
    
  // rails  new api to show refund list
      
 @AuraEnabled(Cacheable=true)
    public static string GetRailsRefundList(string ordItemId){
        system.debug('ordItemId-->'+ordItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Total_Fare__c,Amount_Recieved_Currency__c,Guid__c,OrderUuid__c,Email__c,Business_Unit__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Route_Id__c,Country__c from Order_Items__c where id=:ordItemId];
        system.debug('==ordIt='+ordIt);
         http ht=new http(); 
         HttpRequest httpReq= new HttpRequest(); 
        if(!ordIt.isEmpty()){
          API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='RailsRefundList'];
                string  itemUUid=String.isNotBlank(ordIt[0].OrderUuid__c)?ordIt[0].OrderUuid__c:'';
                //'5a93b7b7112be00607d69c2e01010a00';
                //String.isNotBlank(ordIt[0].Guid__c)?ordIt[0].Guid__c:'';
                string tin=String.isNotBlank(ordIt[0].Order_Item_Reference_No__c) ? ordIt[0].Order_Item_Reference_No__c : '';
                //string jsonbody='{"tin":"","emailId":"","itemUuid":"'+itemUUid+'"}';   
                string endPoint = APIMData.Endpoint__c+itemUUid+'&tin='+'&email=';          
                httpReq.setEndpoint(endPoint);
                httpReq.setMethod('GET');
                //httpReq = HttpRequestUtil.populateCAPICountryHeaders(new HttpRequest(),'','');
                httpReq.setHeader('Content-Type','application/json');
                httpReq.setHeader('auth_key','2d00da61-5b39-4b2a-899f-016c2ae51319');
                httpReq.setHeader('Channel_Name','MOBILE_WEB');
                httpReq.setHeader('SelectedCurrency','INR');
                httpReq.setHeader('Country_Name','IND');
                httpReq.setHeader('BusinessUnit','RAILS');
                httpReq.setHeader('Currency','INR');
                system.debug('==Reqbody=='+httpReq.getBody());
                string jsonHeaders ='===endPoint=='+endPoint+'-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---countryname--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
            try{                
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                system.debug('===Response=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                   DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsRefundList',endPoint,ordIt[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                    return res.getBody();
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsRefundList',endPoint,ordIt[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                    return res.getBody();
                }
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsRefundList',endPoint,ordIt[0].Order_Item_Reference_No__c,'','',jsonHeaders,String.valueOf(e));
                return 'Apex Error';
            }
        }else{
            return 'No Tin Found';
        }
    }
   // from Refund list passing selected uuid to get refund break up
    @AuraEnabled(Cacheable=true)
    public static string GetRailsRefundDetailsBreakUP(string orderItemUuid){
        system.debug('orderItemUuid-->'+orderItemUuid);
        //List<Order_Items__c> ordIt=new List<Order_Items__c>();
        //ordIt=[select id,Total_Fare__c,Amount_Recieved_Currency__c,Guid__c,Email_Copy__c,Email__c,Business_Unit__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Route_Id__c,Country__c from Order_Items__c where Guid__c=:orderItemUuid];
         http ht=new http(); 
         HttpRequest httpReq= new HttpRequest(); 
        if(string.isNotBlank(orderItemUuid)){
          API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='RailRefundBreakupDetails'];
                //string  itemUUid=String.isNotBlank(ordIt[0].Guid__c)?ordIt[0].Guid__c:'';
                //string tin=String.isNotBlank(ordIt[0].Order_Item_Reference_No__c) ? ordIt[0].Order_Item_Reference_No__c : '';
                string jsonbody='{"tin":"","emailId":"","itemUuid":"'+orderItemUuid+'"}';   
                httpReq.setEndpoint(APIMData.Endpoint__c);
                httpReq.setMethod('POST');
               //httpReq = HttpRequestUtil.populateCAPICountryHeaders(new HttpRequest(),'','');
                httpReq.setHeader('Content-Type','application/json');
                httpReq.setHeader('auth_key','2d00da61-5b39-4b2a-899f-016c2ae51319');
                httpReq.setHeader('Channel_Name','MOBILE_WEB');
                httpReq.setHeader('SelectedCurrency','INR');
                httpReq.setHeader('Country_Name','IND');
                httpReq.setHeader('BusinessUnit','RAILS');
                httpReq.setHeader('Currency','INR');
                httpReq.setBody(jsonBody);
                system.debug('===Reqbody=='+httpReq.getBody());
                string jsonHeaders ='===jsonbody=='+jsonbody+'-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---countryname--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
     
            try{                
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                system.debug('===resp=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                   DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsRefundBreakDetails',APIMData.Endpoint__c,orderItemUuid,jsonbody,resBody,jsonHeaders,'');
                    return res.getBody();
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsRefundBreakDetails',APIMData.Endpoint__c,orderItemUuid,jsonbody,resBody,jsonHeaders,'');
                    return res.getBody();
                }
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsRefundBreakDetails',APIMData.Endpoint__c,orderItemUuid,'','',jsonHeaders,String.valueOf(e));
                return 'Apex Error';
            }
        }else{
            return 'No Tin Found';
        }
    }
 }