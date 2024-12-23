/*
* Name           : OutBoundFdbckCallingNotification
* Created Date   : 27 sep 2022
* Created By     : Mahendra reddy 
* Purpose        : send feedbacklink
* Test class     : OutBoundFdckCallingNotificationTest
*/
public class OutBoundFdbckCallingNotification{
    
  @Auraenabled(cacheable=true)
    public static string SendFdbckLink(string recordId){
        system.debug('>>recordId-->'+recordId);
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        List<OutBound_Feedback_Calling__c> busHrFedLst=new List<OutBound_Feedback_Calling__c>();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        busHrFedLst=[select id,name,ownerid,BO_id__c,BO_Name__c,TIN_no__c,DOJ__c,Second_Phone_no__c,OrderItem_Uuid__c,Call_Ended__c,Call_Status__c,Call_Back_Time__c,Call_Disposition_Status__c,Customer_Name__c,Destination__c,Phone_No__c,Source__c from OutBound_Feedback_Calling__c where id =:recordId];
         if(!busHrFedLst.isEmpty()){
            system.debug('--->>'+busHrFedLst);
            string itemUUid='';
            
            if(string.isNotBlank(busHrFedLst[0].OrderItem_Uuid__c)){
               itemUUid=String.isNotBlank(busHrFedLst[0].OrderItem_Uuid__c)?busHrFedLst[0].OrderItem_Uuid__c:'';
            }else if(string.isnotBlank(busHrFedLst[0].TIN_no__c)){
              list<Order_Items__c> lstort =[select id,Guid__c,Order_Item_Reference_No__c from Order_Items__c where Order_Item_Reference_No__c =:busHrFedLst[0].TIN_no__c];
              itemUUid=String.isNotBlank(lstort[0].Guid__c)?lstort[0].Guid__c:'';
            }
            
            string customerName=String.isNotBlank(busHrFedLst[0].Customer_Name__c)?busHrFedLst[0].Customer_Name__c:'';
            string doj=String.isNotBlank(busHrFedLst[0].DOJ__c)?busHrFedLst[0].DOJ__c:'';
            
            string Source=String.isNotBlank(busHrFedLst[0].Source__c)?busHrFedLst[0].Source__c:'';
            string destination=String.isNotBlank(busHrFedLst[0].Destination__c)?busHrFedLst[0].Destination__c:'';
            string boName=String.isNotBlank(busHrFedLst[0].BO_Name__c)?busHrFedLst[0].BO_Name__c:'';
            string cusWatspNo='';
            if(String.isNotBlank(busHrFedLst[0].Second_Phone_no__c)){
            cusWatspNo=String.isNotBlank(busHrFedLst[0].Second_Phone_no__c)?busHrFedLst[0].Second_Phone_no__c:'';
            }else{
              cusWatspNo=String.isNotBlank(busHrFedLst[0].Phone_No__c)?busHrFedLst[0].Phone_No__c:'';
            }
            cusWatspNo='91'+cusWatspNo.replaceAll('[^0-9]', '');
            
            String encodedUrl='https://www.redbus.in/review?oid='+itemUUid+'&utm_source=ratings&utm_medium=whatsapp&utm_campaign=feedbackCallingSF&iso=IND&la=en&cnt=';
            //https://www.redbus.in/review?oid=aabc1148d4a5f005e2483f9f03020100&utm_source=ratings&utm_medium=whatsapp&utm_campaign=ratingCommunication&iso=IND&la=en&cnt=
            string urlBody='url='+encodedUrl+',cD='+System.now();

            Http shrtHt = new Http();
            HttpRequest shrtReq = new HttpRequest();
            HttpResponse shrtResp = new HttpResponse();                                   
            shrtReq.setMethod('POST');                  
            shrtReq.setBody(urlBody);
            shrtReq.setendpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Shorten'].Endpoint__c);
            shrtResp=shrtHt.send(shrtReq);
            system.debug('---shrtReq--'+shrtReq+'---body--'+shrtReq.getBody());
        try{     
            shrtResp=shrtHt.send(shrtReq);
             system.debug('--shrtResp------->>'+shrtResp);
            
        if(shrtResp.getstatuscode()==200 && String.isNotBlank(shrtResp.getbody()))
        {
            system.debug('--respppp------->>'+shrtResp.getbody());
            map<string,object> resObj = (map<string,object>)JSON.deserializeUntyped(shrtResp.getbody());
            map<string,object> resObj1=(map<string,object>)resObj.get('data');
            string shortenURL='https://s.redbus.com/'+resObj1.get('short'); 
            system.debug('--FinalshortenURL------->>'+shortenURL);
                                    
            string fromatedDataJson='{"customerName":"'+customerName+'","DOJ":"'+doj+'","Destination":"'+destination+'","Link":"'+shortenURL+'","OperatorName":"'+boName+'","Source":"'+Source+'"}';
            //string jsonStr=JSON.serialize(fromatedDataJson);

            list<string> channelst =new list<string>();
            channelst.add('whatsapp');
           
            WhatsappRequestWrapper reqstWrap=new WhatsappRequestWrapper();
            reqstWrap.channels=channelst;
            reqstWrap.name='feedback_new_user_sf';
            
            
            Address adrs =new Address();
            adrs.whatsapp_number=cusWatspNo;
            
            MessageDetails msgdtls=new MessageDetails();
            msgdtls.TemplateName='feedback_new_user_sf';
            msgdtls.DataJsonStr=fromatedDataJson;
            msgdtls.DataComplexity=1;
            msgdtls.Language='en';
            
            reqstWrap.MessageDetails=msgdtls;
            reqstWrap.address=adrs;
            reqstWrap.data_params=null;
            
            String smsJsonBody=JSON.serialize(reqstWrap);
               
            system.debug('==smsJsonBody==='+smsJsonBody);
                  
           APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='atomSendNotificationWhatsApp'];
            
          /* Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type','application/json');
            headers.put('Channel_Name','WEB_DIRECT');
            headers.put('Country_Name','IND');
            headers.put('BusinessUnit','BUS');
            headers.put('Language', 'en');
            list<HeadersWrapper> hlist=new list<HeadersWrapper>();
            for(string o:headers.keyset()){
            //maxKey = counts.get(s1)>counts.get(maxKey)?s1:maxKey;
            System.debug('key-->'+o+''+'Value-->'+headers.get(o));
            hlist.add(new HeadersWrapper(o,headers.get(o))); 
            }
            
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson); 
              
            string jsonCM='{"action":"Post","body":'+smsJsonBody+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
            
            System.debug('jsonCM-->'+jsonCM);*/
           
            Http ht = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            req.setHeader('Channel_Name','WEB_DIRECT');
            req.setHeader('Content-Type','application/json');
            req.setHeader('Country_Name', 'IND'); 
            req.setHeader('BusinessUnit', 'BUS');  
            req.setHeader('Language', 'en');             
            req.setMethod('POST');
            req.setEndpoint(APIMData.Endpoint__c);
            req.setBody(smsJsonBody);
            resp = ht.send(req);
            system.debug('---reqBody--'+req.getBody());

            system.debug('----resp----'+resp+'---rspBody--'+resp.getbody());
            map<string,object> resOb = (map<string,object>)JSON.deserializeUntyped(resp.getbody());
            string respcode=string.valueof(resOb.get('code'));
            string  errormsg=string.valueof(resOb.get('error'));
            string statusMsg=string.valueof(resOb.get('statusMessage'));
              
        if(resp.getstatuscode()==200 && String.isNotBlank(resp.getbody()))
        {  
            if((errormsg==null || errormsg=='') && respcode=='200'){
            
              return 'Feedback Link send Successfully';
            }else{
            
            return statusMsg;
            }
        } else{
        
          return 'No API Response';
        }    
           
        }else{
            return 'No API Response';
        }
        }catch(Exception e){
            return 'Apex Error';
        }
      }else{  
       return 'no records found';
       }
    }
    
  
    
    //Start Request Wrapper for wattsUp
    public class Address
    {
        public string whatsapp_number { get; set; }
    }

    public class MessageDetails
    {
        public string TemplateName { get; set; }
        public string DataJsonStr { get; set; }
        public integer DataComplexity { get; set; }
        public string Language { get; set; }
    }

    public class WhatsappRequestWrapper
    {
        public object data_params { get; set; }
        public List<string> channels { get; set; }
        public string name { get; set; }
        public Address address { get; set; }
        public MessageDetails MessageDetails { get; set; }
    }
 //End Request Wrapper for wattsUp
 
 
    public class HeadersWrapper{       
        public string key;
        public string value;
        public HeadersWrapper(string key,string value){
            this.key=key;
            this.value=value;
        }
    }
}