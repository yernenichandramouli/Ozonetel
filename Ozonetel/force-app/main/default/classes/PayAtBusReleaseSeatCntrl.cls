/*
* Name           : PayAtBusReleaseSeatCntrl
* Created Date   : 03 march 2023
* Created By     : Mahendra k
* Purpose        : PayAtBus Release Seat
* Test class     : PayAtBusReleaseSeatCntrlTest
*/
public class PayAtBusReleaseSeatCntrl{
    
 @AuraEnabled(Cacheable=true)
    public static string GetPayAtBusTrans(string ordItemId){
        system.debug('ordItemId-->'+ordItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Service_Provider_Reference_PNR_No__c,Order_Id__c,Business_Unit__c,status__c,Order_Item_Reference_No__c,Guid__c from Order_Items__c where id=:ordItemId];
        system.debug('==ordIt='+ordIt);
        
        if(!ordIt.isEmpty() && (ordIt[0].Business_Unit__c =='REDBUS_PE' || ordIt[0].Business_Unit__c=='REDBUS_CO') ){

            if(ordIt[0].status__c=='TR_TENTATIVE_BLOCK_FOR_OFFLINE_PO_INITIATED'){
        
               String tripId = String.isNotBlank(ordIt[0].Order_Id__c)?ordIt[0].Order_Id__c:'';
               String tin =String.isNotBlank(ordIt[0].Order_Item_Reference_No__c)?ordIt[0].Order_Item_Reference_No__c:'';

            list<case> cseLst=[select id,caseNumber,Trip_ID__c,Issue_Type__c,Transaction_Id__c,TIN_No__c from case where Issue_Type__c='Pay at bus' and (Trip_ID__c=:tripId or TIN_No__c=:tin)];
          if(!cseLst.isEmpty()){ 
           
               API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='PayAtBusVoucherCancelAPI'];
                
                string  itemUUid=String.isNotBlank(ordIt[0].Guid__c)?ordIt[0].Guid__c:'';
                string  caseNo=String.isNotBlank(cseLst[0].casenumber)?cseLst[0].casenumber:'';
                
                http ht=new http(); 
                HttpRequest req= new HttpRequest(); 
                req.setEndpoint(APIMData.Endpoint__c+itemUUid+'/'+caseNo+'/'+'0'+'/'+true);
                req.setMethod('GET');
                req = HttpRequestUtil.populateCapiPayatBusHeaders(req);
                string jsonHeaders ='===jsonbody=='+req.getEndpoint()+'-Headers-Channel_Name--'+req.getHeader('Channel_Name')+'---countryname--'+req.getHeader('Country_Name')+'--auth_key-'+req.getHeader('auth_key')+'--BusinessUnit--'+req.getHeader('BusinessUnit')+'--SelectedCurrency--'+req.getHeader('SelectedCurrency')+'--Currency-'+req.getHeader('Currency');
            try{                
                HttpResponse res = ht.send(req);
                string resBody=res.getBody();
                system.debug('===isCanclRes=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                   DblogforQuickActionLwcCtrl.dblogCaptureMethod('PayatbusSeatRelease',req.getEndpoint(),ordIt[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                   if('true'.equalsIgnorecase(resBody)){
                      return 'Seat Released successfully ';
                   }else if('false'.equalsIgnorecase(resBody)){
                      return 'Failed to Release'; 
                   }else{
                      return res.getBody(); 
                   }
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('PayatbusSeatRelease',req.getEndpoint(),ordIt[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                    return res.getBody();
                }
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('PayatbusSeatRelease',req.getEndpoint(),ordIt[0].Order_Item_Reference_No__c,'','',jsonHeaders,String.valueOf(e));
                return 'Apex Error';
            }
        }else{
            return 'No case Found';
        }
      }else{
            return 'Seat Release will Not Supported for this Transcation';
       }

      }else{
           return 'Suported For Only Latam';
      } 
    }
 }