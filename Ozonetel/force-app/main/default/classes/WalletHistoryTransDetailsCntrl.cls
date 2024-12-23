/**
 * (c) 2023 RedBus
 *
 * Name           : WalletHistoryTransDetailsCntrl
 * Created Date   : 23 may 2023
 * Created By     : mahendra k 
 * Purpose        : Controller class for WalletHistoryDetails
 *
 **/
 
 public class WalletHistoryTransDetailsCntrl{
    
 @AuraEnabled(Cacheable=true)
    public static string GetWalletHistoryDetails(string ordItemId){ 
     List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Rb_User_ID__c,Order_Item_Reference_No__c from Order_Items__c where id=:ordItemId];
        system.debug('==ordIt='+ordIt);
         http ht=new http(); 
         HttpRequest httpReq= new HttpRequest(); 
        if(!ordIt.isEmpty()){
            if(string.isNotBlank(ordIt[0].Rb_User_ID__c)){
          API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='WalletHistory'];
                string  rbUsrId=String.isNotBlank(ordIt[0].Rb_User_ID__c)?ordIt[0].Rb_User_ID__c:'';
                httpReq.setEndpoint(APIMData.Endpoint__c+'userId='+rbUsrId);
                httpReq.setMethod('GET');
                httpReq = HttpRequestUtil.populateHeaders(httpReq);
                string jsonHeaders ='===jsonbody=='+APIMData.Endpoint__c+'userId='+rbUsrId+'-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---countryname--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
            try{                
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                system.debug('===isCanclRes=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                   DblogforQuickActionLwcCtrl.dblogCaptureMethod('Transaction-WalletHistory',APIMData.Endpoint__c+'userId='+rbUsrId,ordIt[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                    return res.getBody();
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('Transaction-WalletHistory',APIMData.Endpoint__c+'userId='+rbUsrId,ordIt[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                    return res.getBody();
                }
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('Transaction-WalletHistory',APIMData.Endpoint__c+'userId='+rbUsrId,ordIt[0].Order_Item_Reference_No__c,'','',jsonHeaders,String.valueOf(e));
                return 'Apex Error';
            }
        }else{
           return 'No signed user found';
        }
        }else{
            return 'No Tin Found or not confirmed booking';
        }
    
    }
  }