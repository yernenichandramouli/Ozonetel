/*
* Name           : RailsPNRstatusCheckCntrl
* Created Date   : 24 feb 2023
* Created By     : Mahendra k
* Purpose        : Rails PNR Status and TG Status check
* Test class     : RailsPNRstatusCheckCntrlTest
*/
public class RailsPNRstatusCheckCntrl{
    
 @AuraEnabled(Cacheable=true)
    public static string GetRailsPNRstatus(string ordItemId){
        system.debug('ordItemId-->'+ordItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Service_Provider_Reference_PNR_No__c,Order_Item_Reference_No__c,Guid__c from Order_Items__c where id=:ordItemId];
        system.debug('==ordIt='+ordIt);
         http ht=new http(); 
         HttpRequest httpReq= new HttpRequest(); 
        if(!ordIt.isEmpty()){
          API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='railsPNRstatus'];
                string  pnrNo=String.isNotBlank(ordIt[0].Service_Provider_Reference_PNR_No__c)?ordIt[0].Service_Provider_Reference_PNR_No__c:'';
                //string jsonbody='{"tin":"","emailId":"","itemUuid":"'+itemUUid+'"}';                 
                httpReq.setEndpoint(APIMData.Endpoint__c+pnrNo);
                httpReq.setMethod('GET');
                httpReq = HttpRequestUtil.populateRailPNRHeaders(httpReq);
                string jsonHeaders ='===jsonbody=='+APIMData.Endpoint__c+pnrNo+'-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---countryname--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
            try{                
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                system.debug('===isCanclRes=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                   DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsPNRstatus',APIMData.Endpoint__c+pnrNo,ordIt[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                    return res.getBody();
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsPNRstatus',APIMData.Endpoint__c+pnrNo,ordIt[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                    return res.getBody();
                }
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsPNRstatus',APIMData.Endpoint__c+pnrNo,ordIt[0].Order_Item_Reference_No__c,'','',jsonHeaders,String.valueOf(e));
                return 'Apex Error';
            }
        }else{
            return 'No Tin Found';
        }
    }
    
    @AuraEnabled(Cacheable=true)
    public static string GetRailsTGstatus(string ordItemId){
        system.debug('ordItemId-->'+ordItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Service_Provider_Reference_PNR_No__c,Order_Item_Reference_No__c,Guid__c from Order_Items__c where id=:ordItemId];
        system.debug('==ordIt='+ordIt);
          http ht=new http(); 
         HttpRequest httpReq= new HttpRequest(); 
        if(!ordIt.isEmpty()){
          API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='RailsTGstatusAPI'];
                string  itemUUid=String.isNotBlank(ordIt[0].Guid__c)?ordIt[0].Guid__c:'';
                string endPoint = APIMData.Endpoint__c+itemUUid;      
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
                string jsonHeaders ='===endPoint=='+endPoint+'-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---countryname--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');

            try{ 
                HttpResponse res = ht.send(httpReq);               
                string resBody=res.getBody();
                system.debug('===Res=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                   DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsTGstatus',APIMData.Endpoint__c+itemUUid,ordIt[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                    return res.getBody();
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsTGstatus',APIMData.Endpoint__c+itemUUid,ordIt[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                    return res.getBody();
                }
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('railsTGstatus',APIMData.Endpoint__c+itemUUid,ordIt[0].Order_Item_Reference_No__c,'','',jsonHeaders,String.valueOf(e));
                return 'Apex Error';
            }
        }else{
            return 'No Tin Found';
        }
    }
    
    
       //wrapper class
    public class HeadersWrapper
    {       
        public string key;
        public string value;
        public HeadersWrapper(string key,string value){
            this.key=key;
            this.value=value;
        }
    }
 }