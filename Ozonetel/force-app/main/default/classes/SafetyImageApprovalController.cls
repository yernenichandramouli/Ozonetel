public class SafetyImageApprovalController{


@AuraEnabled(Cacheable=true) 
    public static List<TransactionWrapper> getAllTransactions(date doj){
        System.debug('doj-->'+doj);
        integer dayYear=doj.year();
        integer dayNum=doj.dayOfYear();
        string dayNo= string.valueOf(dayYear)+string.valueOf(dayNum);
       // dayNo='2020161';
        List<TransactionWrapper> twList;
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SafetyImgGetIds'];     

        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        req = HttpRequestUtil.populateCAPIHeaders(req);
        req.setHeader('Channel_Name','SFA');
        req.setTimeout(120000);
        req.setMethod('GET');            
        req.setEndpoint(APIMData.Endpoint__c+dayNo);
        resp = ht.send(req);
        string resBody=resp.getBody();
        twList=new list<TransactionWrapper>();
       // resBody='[ { "uuid": "71e94fb2a76ff0055722993402020100", "doi": "2020-06-08", "src": "551", "dest": "1110" }, { "uuid": "5fbf35d1a777f005e2483f9f01020100", "doi": "2020-06-08", "src": "248", "dest": "316" }, { "uuid": "3dd0f34ea713f005e2483f9f01020100", "doi": "2020-06-08", "src": "347", "dest": "248" } ]';

        twList= (list<TransactionWrapper>)System.JSON.deserialize(resBody,List<TransactionWrapper>.class);              
     system.debug('twList->'+twList);
      return twList;
    }
    @AuraEnabled(Cacheable=true) 
     public static List<ImageWrappper> GetImages(string uuId){    
     //uuId='71e94fb2a76ff0055722993402020100'; 
       API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
       APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SafetyGetImages'];     
       
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        req = HttpRequestUtil.populateCAPIHeaders(req);
        req.setHeader('Channel_Name','SFA');
        req.setTimeout(120000);
        req.setMethod('GET');            
        req.setEndpoint(APIMData.Endpoint__c+uuId);
        resp = ht.send(req);
        string resBody=resp.getBody();
        System.debug('resBodyII-->'+resBody);
     // resBody=' { "https://ugc-dynamic-tags.s3-ap-southeast-1.amazonaws.com/CovidAudit/71e94fb2a76ff0055722993402020100_2_0_socialdistance.png": "NEW" ,  "https://s3-ap-southeast-1.amazonaws.com/rb-plus/BI/IND/WM/15931/53/FR/L/oNVSRs.jpeg": "NEW2","https://s3-ap-southeast-1.amazonaws.com/rb-plus/BI/IND/WM/15931/53/FR/L/ARzuBL.jpeg": "NEW2","https://s3-ap-southeast-1.amazonaws.com/rb-plus/BI/IND/WM/17886/4/FR/L/SloVuV.jpeg": "NEW" ,"https://s3-ap-southeast-1.amazonaws.com/rb-plus/BI/IND/WM/17886/4/AM/L/PzJ8WF.jpeg": "NEW2","https://s3-ap-southeast-1.amazonaws.com/rb-plus/BI/IND/WM/17886/4/AM/L/kdJyBN.jpeg": "NEW2" } ';
     // resBody=' { "https://ugc-dynamic-tags.s3-ap-southeast-1.amazonaws.com/CovidAudit/71e94fb2a76ff0055722993402020100_2_0_socialdistance.png": "NEW" ,  "https://s3-ap-southeast-1.amazonaws.com/rb-plus/BI/IND/WM/15931/53/FR/L/oNVSRs.jpeg": "NEW2"} ';

       map<string,object> imagesMap=new map<string,object>();
        imagesMap= (map<string,object>)JSON.deserializeUntyped(resBody);

     
        list<ImageWrappper> imgWrapList=new list<ImageWrappper>();
        Map<string,string> imgTagMap=new Map<string,string>();
        imgTagMap.put('1','Staff Mask');
        imgTagMap.put('2','Deep Cleaned Bus');
        imgTagMap.put('3','Social Distancing');
        imgTagMap.put('4','Hand Sanitizer');
        for(string key:imagesMap.keyset()){            
              ImageWrappper i=new ImageWrappper();
              i.imageId=key;
              i.imageTag=key.substringAfter('_');
              System.debug('img tag-->'+i.imageTag);
              if(i.imageTag!=null || i.imageTag!=''){
                  i.imageTag=i.imageTag.substringBefore('_');
                  i.imageTag=imgTagMap.get(i.imageTag);
                  System.debug('img tag lp-->'+i.imageTag);
               }
              i.status=string.valueOf(imagesMap.get(key));
              imgWrapList.add(i);
        }   
        System.debug('imgWrapList-->'+imgWrapList);
        return  imgWrapList; 
    }
    
    @AuraEnabled(Cacheable=true)  
   public static string updatestatus(string imgUpStr){     
        System.debug('imgUpStr--->'+imgUpStr);
        if(imgUpStr.contains('NEW')){
          return 'New';
        }
        else{
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
       
        imgUpStr=imgUpStr.removeEnd(',');
        imgUpStr=imgUpStr.replace('undefined','');
       // imgUpStr='{'+imgUpStr+'}';
        System.debug('imgUpStr 4-->'+imgUpStr); 
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SafetyUpdateImages'];     
        DBLog_Summary__c dbl=new DBLog_Summary__c();
        dbl.Type__c='Safety Image Approval';
       
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        req = HttpRequestUtil.populateCAPIHeaders(req);
        req.setHeader('Channel_Name','SFA');
        req.setTimeout(120000);
        req.setMethod('POST');        
        req.setBody(imgUpStr);  
        dbl.Request_Data__c=string.valueOf(req)+'--'+imgUpStr;  
            
        req.setEndpoint(APIMData.Endpoint__c);
        resp = ht.send(req);
         dbl.Response_Received__c=resp.getBody();   
         System.debug('resp-->'+resp);
          if(resp.getBody()=='true'){
            return 'Success';
          }else{
            return 'Failed';
          }
        // insert dbl;
           }
    }
     
   public class TransactionWrapper{
   
      @auraEnabled  public string uuid{get;set;}
      @auraEnabled  public string doi{get;set;}
      @auraEnabled  public string src{get;set;}
      @auraEnabled public string dest{get;set;}      
      }
      public class ImageWrappper{
      @auraEnabled  public string imageId{get;set;}
      @auraEnabled  public string status{get;set;}
       @auraEnabled public string imageTag{get;set;}
      }
}