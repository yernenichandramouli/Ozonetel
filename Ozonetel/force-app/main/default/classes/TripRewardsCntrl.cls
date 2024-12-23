/*
* Name           : TripRewardsCntrl
* Created Date   : 04 march 2024
* Created By     : Mahendra k
* Purpose        : TripRewards Info
* Test class     : TripRewardsCntrlTest
*/
public class TripRewardsCntrl{
    
    @AuraEnabled(cacheable=true)
    public static String GetAllStreaksByTransId(string ordItemId){
       system.debug('ordItemId-->'+ordItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Rb_User_ID__c,Guid__c,Corrected_Date_of_Journey__c,Source_City_Id__c,Destination_City_Id__c,Business_Unit__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Route_Id__c,Country__c from Order_Items__c where id=:ordItemId];
        system.debug('==ordIt='+ordIt);
        Map<String, Object> errorMsgReturn = new Map<String, Object>();

        if(!ordIt.isEmpty() && String.isNotBlank(ordIt[0].Guid__c) && String.isNotBlank(ordIt[0].Rb_User_ID__c)){
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='GetAllStreaksByTransId'];
            string userId =String.isNotBlank(ordIt[0].Rb_User_ID__c)?ordIt[0].Rb_User_ID__c:'';
            string itemUUID=String.isNotBlank(ordIt[0].Guid__c)?ordIt[0].Guid__c:'';
            string tinNo =String.isNotBlank(ordIt[0].Order_Item_Reference_No__c)?ordIt[0].Order_Item_Reference_No__c:'';
            
           // userId='20494517';
           // itemUUID='a6830b8011e5f0066c4b1b4001020100';
            string jsonbody='{"UserID":"'+userId+'","UUID":"'+itemUUID+'"}';
            
            http ht=new http(); 
            HttpRequest httpReq= new HttpRequest();                    
            httpReq.setEndpoint(APIMData.Endpoint__c);
            httpReq.setMethod('POST');
            httpReq.setBody(jsonBody);
            httpReq.setHeader('Country_Name','IND');   
            httpReq.setHeader('Auth_Key','22ba-4146-b68f-7f89e733a144,b33239e5-16ff-4f8e-b75c-3ce040d1a559');   
            httpReq.setHeader('Language','en');  
            httpReq.setHeader('BusinessUnit','Bus');   
            httpReq.setHeader('Channel_Name','CRM');  
            httpReq.setHeader('Content-Type','application/json');
            system.debug('==body=='+httpReq.getBody());   
            string jsonHeaders='-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---Country_Name--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
            try{   
               //string mockResp ='{"OpId":15926,"OpName":"Virtual_travels","StreakStatus":"ACTIVE","MaxOfferAmount":31,"TripBookingCount":2,"TripCompletionCount":0,"TotalTxnCount":2,"StreakStartDate":"2024-02-21 19:45:27","StreakEndDate":"2024-04-21 19:45:27","RedemptionStartDate":"2024-03-16 22:10:00","RedemptionDate":"2024-06-20 20:15:27","IsRedeemable":false,"Consent":true,"ConsentUUID":"a6830b8011e5f0066c4b1b4001020100","IsLastBooking":true,"SortOrder":0,"Txns":[{"UUID":"a6830b8011e5f0066c4b1b4001020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 19:30:00","SrcID":69283,"DestID":65782,"Position":1},{"UUID":"60af0d4f11e5f0066c4b1b4002020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 22:10:00","SrcID":69283,"DestID":65782,"Position":2}],"PositionOfTxn":1}';
   
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                system.debug('===req=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetAllStreaksByTransId',APIMData.Endpoint__c,tinNo,jsonBody,resBody,jsonHeaders,'');
                    return resBody;
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetAllStreaksByTransId',APIMData.Endpoint__c,tinNo,jsonBody,resBody,jsonHeaders,'');
                    return resBody;
                }
                
                //return mockResp;
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetAllStreaksByTransId',APIMData.Endpoint__c,tinNo,jsonBody,'Try catch exception',jsonHeaders,String.valueOf(e));
                system.debug('---trycatch---'+e);
                return 'Try catch error';
            }
            
        }else{
            return 'UserId or ItemUUid is blank- Please check once';
        }
     }  
    

@AuraEnabled(cacheable=true)
    public static Map<String, Object> GetAllStreaksByUserId(string ordItemId){
       system.debug('ordItemId-->'+ordItemId);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt=[select id,Rb_User_ID__c,Guid__c,Corrected_Date_of_Journey__c,Source_City_Id__c,Destination_City_Id__c,Business_Unit__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Route_Id__c,Country__c from Order_Items__c where id=:ordItemId];
        system.debug('==ordIt='+ordIt);
        Map<String, Object> responseData = new Map<String, Object>();
       // string testResp='{"15926":{"OpId":15926,"OpName":"Virtual_travels","StreakStatus":"ACTIVE","MaxOfferAmount":31,"TripBookingCount":2,"TripCompletionCount":0,"TotalTxnCount":2,"StreakStartDate":"2024-02-21 19:45:27","StreakEndDate":"2024-04-21 19:45:27","RedemptionStartDate":"2024-03-16 22:10:00","RedemptionDate":"2024-06-20 20:15:27","IsRedeemable":false,"Consent":true,"ConsentUUID":"a6830b8011e5f0066c4b1b4001020100","IsLastBooking":true,"SortOrder":1,"Txns":[{"UUID":"a6830b8011e5f0066c4b1b4001020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 19:30:00","SrcID":69283,"DestID":65782,"Position":0},{"UUID":"60af0d4f11e5f0066c4b1b4002020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 22:10:00","SrcID":69283,"DestID":65782,"Position":0}]},"27461":{"OpId":27461,"OpName":"TestBo rtcFlow","StreakStatus":"ACTIVE","MaxOfferAmount":0,"TripBookingCount":1,"TripCompletionCount":0,"TotalTxnCount":3,"StreakStartDate":"2024-02-21 20:15:37","StreakEndDate":"2024-03-02 20:15:37","RedemptionDate":"2024-03-04 08:43:25","IsRedeemable":false,"Consent":true,"ConsentUUID":"f175a59f1203f0066c4b1b4002020100","IsLastBooking":false,"SortOrder":0,"Txns":[{"UUID":"f175a59f1203f0066c4b1b4002020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-02-26 13:30:00","SrcID":69283,"DestID":65782,"Position":0}]}}';
      //  responseData = (Map<String, Object>) JSON.deserializeUntyped(testResp);
        
        Map<String, Object> errorMsgReturn = new Map<String, Object>();

        if(!ordIt.isEmpty() && String.isNotBlank(ordIt[0].Rb_User_ID__c)){
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='GetAllStreaksByUserId'];
            string userId =String.isNotBlank(ordIt[0].Rb_User_ID__c)?ordIt[0].Rb_User_ID__c:'';
            
           // userId='20494517';
            string tinNo =String.isNotBlank(ordIt[0].Order_Item_Reference_No__c)?ordIt[0].Order_Item_Reference_No__c:'';
            string jsonbody='{"UserID":"'+userId+'"}';
            http ht=new http(); 
            HttpRequest httpReq= new HttpRequest();                    
            httpReq.setEndpoint(APIMData.Endpoint__c);
            httpReq.setMethod('POST');
            httpReq.setBody(jsonBody);
            httpReq.setHeader('Country_Name','IND');   
            httpReq.setHeader('Auth_Key','22ba-4146-b68f-7f89e733a144,b33239e5-16ff-4f8e-b75c-3ce040d1a559');   
            httpReq.setHeader('Language','en'); 
            httpReq.setHeader('BusinessUnit','Bus');    
            httpReq.setHeader('Channel_Name','CRM'); 
            httpReq.setHeader('Content-Type','application/json'); 
            system.debug('==body=='+httpReq.getBody());   
            string jsonHeaders='-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---Country_Name--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
            try{      
               HttpResponse res = ht.send(httpReq);
               string resBody=res.getBody();
                system.debug('===req=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                    responseData = (Map<String, Object>) JSON.deserializeUntyped(resBody);
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetAllStreaksByUserId',APIMData.Endpoint__c,tinNo,jsonBody,resBody,jsonHeaders,'');
                     
                    return responseData;
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetAllStreaksByUserId',APIMData.Endpoint__c,tinNo,jsonBody,resBody,jsonHeaders,'');
                    responseData = (Map<String, Object>) JSON.deserializeUntyped(resBody);
                    string errorMsg = (string)responseData.get('Msg');
                    system.debug('>>>>errorMsg>>>'+errorMsg);
                    errorMsgReturn.put('errorMessage', errorMsg);
                    return errorMsgReturn;
                }
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetAllStreaksByUserId',APIMData.Endpoint__c,tinNo,jsonBody,'Try catch exception',jsonHeaders,String.valueOf(e));
                system.debug('---trycatch---'+e);
                errorMsgReturn.put('errorMessage', 'Please try again catch error');
                return errorMsgReturn;
            }
            
        }else{
            errorMsgReturn.put('errorMessage', 'UserId is blank- Please check once');
            return errorMsgReturn;
        }
     }  

//Account level Streaks
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> AccountStreaksByUserId(string accountId){
       system.debug('accountId-->'+accountId);
        List<Account> acList=new List<Account>();
        acList=[select id,User_Id__c from Account where id=:accountId];
        Map<String, Object> responseData = new Map<String, Object>();
        //string testResp='{"15926":{"OpId":15926,"OpName":"Virtual_travels","StreakStatus":"ACTIVE","MaxOfferAmount":31,"TripBookingCount":2,"TripCompletionCount":0,"TotalTxnCount":2,"StreakStartDate":"2024-02-21 19:45:27","StreakEndDate":"2024-04-21 19:45:27","RedemptionStartDate":"2024-03-16 22:10:00","RedemptionDate":"2024-06-20 20:15:27","IsRedeemable":false,"Consent":true,"ConsentUUID":"a6830b8011e5f0066c4b1b4001020100","IsLastBooking":true,"SortOrder":1,"Txns":[{"UUID":"a6830b8011e5f0066c4b1b4001020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 19:30:00","SrcID":69283,"DestID":65782,"Position":0},{"UUID":"60af0d4f11e5f0066c4b1b4002020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-03-16 22:10:00","SrcID":69283,"DestID":65782,"Position":0}]},"27461":{"OpId":27461,"OpName":"TestBo rtcFlow","StreakStatus":"ACTIVE","MaxOfferAmount":0,"TripBookingCount":1,"TripCompletionCount":0,"TotalTxnCount":3,"StreakStartDate":"2024-02-21 20:15:37","StreakEndDate":"2024-03-02 20:15:37","RedemptionDate":"2024-03-04 08:43:25","IsRedeemable":false,"Consent":true,"ConsentUUID":"f175a59f1203f0066c4b1b4002020100","IsLastBooking":false,"SortOrder":0,"Txns":[{"UUID":"f175a59f1203f0066c4b1b4002020100","Src":"Kolar (Karnataka)","Dest":"Hisar (Rajasthan)","DOJ":"2024-02-26 13:30:00","SrcID":69283,"DestID":65782,"Position":0}]}}';
        Map<String, Object> errorMsgReturn = new Map<String, Object>();

        if(!acList.isEmpty() && String.isNotBlank(acList[0].User_Id__c)){
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='GetAllStreaksByUserId'];
            string userId =String.isNotBlank(acList[0].User_Id__c)?acList[0].User_Id__c:'';
            
           //userId='20494517';
            string tinNo =acList[0].id;

            string jsonbody='{"UserID":"'+userId+'"}';
            
            http ht=new http(); 
            HttpRequest httpReq= new HttpRequest();                    
            httpReq.setEndpoint(APIMData.Endpoint__c);
            httpReq.setMethod('POST');
            httpReq.setBody(jsonBody);
            httpReq.setHeader('Country_Name','IND');   
            httpReq.setHeader('Auth_Key','22ba-4146-b68f-7f89e733a144,b33239e5-16ff-4f8e-b75c-3ce040d1a559');   
            httpReq.setHeader('Language','en');   
            httpReq.setHeader('BusinessUnit','Bus');   
            httpReq.setHeader('Channel_Name','CRM');  
            httpReq.setHeader('Content-Type','application/json');
            system.debug('==body=='+httpReq.getBody());   
            string jsonHeaders='-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+'---Country_Name--'+httpReq.getHeader('Country_Name')+'--auth_key-'+httpReq.getHeader('auth_key')+'--BusinessUnit--'+httpReq.getHeader('BusinessUnit')+'--SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+'--Currency-'+httpReq.getHeader('Currency');
            try{      
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                system.debug('===AccountStreaksByRes=='+res.getBody());
                if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                {
                    responseData = (Map<String, Object>) JSON.deserializeUntyped(resBody);
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetAccountStreaks',APIMData.Endpoint__c,tinNo,jsonBody,resBody,jsonHeaders,'');
                    return responseData;
                }else{
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetAccountStreaks',APIMData.Endpoint__c,tinNo,jsonBody,resBody,jsonHeaders,'');
                    responseData = (Map<String, Object>) JSON.deserializeUntyped(resBody);
                    string errorMsg = (string)responseData.get('Msg');
                    system.debug('>>>>errorMsg>>>'+errorMsg);
                    errorMsgReturn.put('errorMessage', errorMsg);
                    return errorMsgReturn;
                }
               //return responseData;
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetAccountStreaks',APIMData.Endpoint__c,tinNo,jsonBody,'Try catch exception',jsonHeaders,String.valueOf(e));
                system.debug('---trycatch---'+e);
                errorMsgReturn.put('errorMessage', 'Please try again catch error');
                return errorMsgReturn;
            }
            
        }else{
            errorMsgReturn.put('errorMessage', 'UserId is blank- Please check once');
            return errorMsgReturn;
        }
     }   
}