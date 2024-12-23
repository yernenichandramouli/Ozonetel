/**
 * (c) 2023 RedBus
 *
 * Name           : Initiate Refund
 * Created Date   : 10 aug 2023
 * Created By     : Mahendra k
 * Purpose        : To initiate Refund.
 * JiraId         : 
 * Test class     : InitiateRefundCtrlTest
 *
 **/
public class InitiateRefundCtrl {

    @AuraEnabled(cacheable=true)
    public static string initiateRefundMethod(string activityId){
    system.debug('----recordId----'+activityId);
    list<Activities__c> actLst=[select id,Refund_Response_Message__c,Refund_CustRefund_ID__c,Refund_Initiated_Time__c,id__c,Business_Unit__c,Order_Id__c from Activities__c where id=:activityId];
     API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Initiate_Refund_CMAPI'];        
    if(!actLst.isEmpty() && string.isNotblank(actLst[0].Business_Unit__c) ){
              string strBUnit ='REDBUS_'+actLst[0].Business_Unit__c.split('_')[1];
               Map<string,string> bodyValue = new map<string,string>();
                bodyValue.put('transactionNo',actLst[0].Id__c);
                bodyValue.put('cseName',userinfo.getName());
                bodyValue.put('cartId',actLst[0].Order_Id__c);
                
                system.debug('-------------------BODY------------'+JSON.serialize(bodyValue));
                
                 //https://cmapi.redbus.com/api/Refund/v2/Initiate/Cart
                 //body:{"cartId":"13533227796638489","cseName":"Yuliani Puji Lestari","transactionNo":"13533227796660873"}
                 //resp:{"InitiatedTime":"2023-08-10T16:05:58.429","CartId":13533227796638489,"CustRefundId":0,"IsSuccess":true,"refundAmount":101900.0,"ResponseMessage":"REFUND_CREATED"}
                
                Http http = new Http(); 
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req.setTimeout(120000);
                req = HttpRequestUtil.populateCMAPIHeaders(req,strBUnit);   
                req.setEndpoint(APIMData.Endpoint__c);
                req.setBody(JSON.serialize(bodyValue));
                req.setMethod('POST');
                 string responseValue='';
                  string jsonHeaders='';
           try{  
                jsonHeaders ='-Headers-Channel_Name--'+req.getHeader('Channel_Name')+'---countryname--'+req.getHeader('Country_Name')+'--auth_key-'+req.getHeader('auth_key')+'--BusinessUnit--'+req.getHeader('BusinessUnit')+'--SelectedCurrency--'+req.getHeader('SelectedCurrency')+'--Currency-'+req.getHeader('Currency');
                res = http.send(req);
                responseValue = res.getBody();
                refundResponse resp   = new refundResponse();
                system.debug('-------------------responseValue------------'+responseValue);

                if(res.getStatusCode()==200 )
                {
                    resp = (refundResponse)JSON.deserialize( responseValue, refundResponse.class);
                    if(resp.IsSuccess=='true')
                      {
                        if(!string.isBlank(resp.CustRefundId))
                        {
                            actLst[0].Refund_CustRefund_ID__c = resp.CustRefundId;
                        }
                        
                        if(string.valueof(resp.InitiatedTime).contains('T') && !string.valueof(resp.InitiatedTime).contains('0001-01-01T00:00:00'))
                        {
                            actLst[0].Refund_Initiated_Time__c = datetime.valueof(string.valueof(resp.InitiatedTime).replace('T',' '));
                        }
                        else if(!string.valueof(resp.InitiatedTime).contains('0001-01-01T00:00:00'))
                        {
                           actLst[0].Refund_Initiated_Time__c = datetime.valueof((string)resp.InitiatedTime);
                        }
                        
                        if(!string.isBlank(resp.ResponseMessage))
                        {
                            actLst[0].Refund_Response_Message__c = resp.ResponseMessage;
                        }
                         DblogforQuickActionLwcCtrl.dblogCaptureMethod('Initiate Refund Cargo',APIMData.Endpoint__c,actLst[0].Order_Id__c,JSON.serialize(bodyValue),responseValue,jsonHeaders,'');
                         return 'Refund Created successfully'; 
                          
                      }else{ 
                        DblogforQuickActionLwcCtrl.dblogCaptureMethod('Initiate Refund Cargo',APIMData.Endpoint__c,actLst[0].Order_Id__c,JSON.serialize(bodyValue),responseValue,jsonHeaders,resp.ResponseMessage);
                        return 'Initiate Refund Failed'+'-'+resp.ResponseMessage; 
                      }
                }else{
                        DblogforQuickActionLwcCtrl.dblogCaptureMethod('Initiate Refund Cargo',APIMData.Endpoint__c,actLst[0].Order_Id__c,JSON.serialize(bodyValue),responseValue,jsonHeaders,'Failed Wrong Status Code Received');
                   return 'Failed Wrong Status Code Received';
                }  
            }catch(Exception e){
              DblogforQuickActionLwcCtrl.dblogCaptureMethod('Initiate Refund Cargo',APIMData.Endpoint__c,actLst[0].Order_Id__c,JSON.serialize(bodyValue),responseValue,jsonHeaders,String.valueOf(e));
              return 'Apex Error';
            }           
    }else{
          DblogforQuickActionLwcCtrl.dblogCaptureMethod('Initiate Refund Cargo',APIMData.Endpoint__c,actLst[0].Order_Id__c,'','','','No activities is present or Business Unit is Empty');
        return 'No activities is present or Business Unit is Empty';
   }
   
   
 }
   
    public class refundResponse
    {
        @AuraEnabled
        public string InitiatedTime;
        @AuraEnabled
        public string CustRefundId;
        @AuraEnabled
        public string IsSuccess;
        @AuraEnabled
        public string ResponseMessage; 
    }
    
  }