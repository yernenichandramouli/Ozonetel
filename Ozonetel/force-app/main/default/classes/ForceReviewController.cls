/**
* Name           : ForceReviewController
* Created Date   : 15 Nov 2017
* Created By     : Veeramanikanta R
* Purpose        : Used for Agents to give ratings and reviews for transactions
*
**/
public class ForceReviewController {
    
    public transient List<ResponseWrapper> reqWrapperList{get;set;}
    public List<ResponseWrapper> reqVFList{get;set;}
    public date fromDate{get;set;}
    public date toDate{get;set;}
    public string tId{get;set;}
    public integer overallRating{get;set;}
    public integer busQuality{get;set;}
    public integer punctuality{get;set;}
    public integer staffBehaviour{get;set;}
    public string comment{get;set;}
    public list<ResponseWrapper> InnerList{get; set;}
    public list<ResponseWrapper> ListRequested{get; set;}
    Integer i {get; set;} 
    public Integer setPageSize {get; set;} 
    public Map<string,ResponseWrapper> mObj{get;set;}
    public string tinNo{get;set;}
    public string country{get;set;}
    public List<DBLog_Summary__c> dbLogList;
    
    public ForceReviewController (){
        reqWrapperList= new list<ResponseWrapper>();
        reqVFList=new list<ResponseWrapper>(); 
        mObj=new Map<string,ResponseWrapper>();       
        
        string mrrJson='[{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false}]';
        //  reqWrapperList= (List<ResponseWrapper>)System.JSON.deserialize(mrrJson,List<ResponseWrapper>.class);       
        InnerList=new list<ResponseWrapper>();
        ListRequested=new list<ResponseWrapper>();
        InnerList=reqWrapperList;
        setPageSize = 20;
        i = 0; 
        next(); 
    }
    
    public void getTransactions(){
    
        
        if(fromDate==null || toDate==null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter From date and To date'));
        }else{
        reqWrapperList= new list<ResponseWrapper>();
            reqWrapperList.clear();
             reqVFList=new list<ResponseWrapper>();
             reqVFList.clear();
            String fromDate1=fromDate.year()+'-'+fromDate.month()+'-'+fromDate.day();
            String toDate1=toDate.year()+'-'+toDate.month()+'-'+toDate.day();
            System.debug('fromDate-->'+fromDate+'toDate-->'+toDate);
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='ForceReview'];
            String endPoint;
            HTTP h = new HTTP();
            HttpRequest req= new HttpRequest();
            HTTPResponse res=new HTTPResponse();        
            req = HttpRequestUtil.populateHeaders(req);               
            req.setHeader('auth_key','487a342c-92f1-41ae-81fa-aaa5120f6bb3');
            req.setHeader('Channel_Name', 'MOBILE_APP');
            req.setHeader('Country_Name', 'INTL');
            //req.setHeader('Accept', 'application/msgpack1');
            req.setMethod('GET');
            // req.setEndpoint('http://cmapi-pp.redbus.com/api/Ticket/v1/RnR/unReviewed/2017-11-04/2017-11-06');
            req.setEndpoint(APIMData.Endpoint__c+country+'/'+fromDate1+'/'+toDate1);
            System.debug('endpoint-->'+APIMData.Endpoint__c+country+'/'+fromDate1+'/'+toDate1);
            res=h.send(req);   
            // string mrrJson=res.getbody();
            string mrrJson='[{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false}]';
            
            System.debug('mrrJson-->'+mrrJson);
            //  string mrrJson='[{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false}]';
            reqWrapperList= (List<ResponseWrapper>)System.JSON.deserialize(res.getbody(),List<ResponseWrapper>.class);       
            
            
            integer counter = 0;
            //&& counter<reqWrapperList.size()
            while(counter<1000 && counter<reqWrapperList.size()) {
            reqVFList.add(reqWrapperList[counter++]);
            }
            System.debug('reqWrapperList-->'+reqWrapperList.size());
            System.debug('reqVFList-->'+reqVFList.size());
            
            InnerList=new list<ResponseWrapper>();
            ListRequested=new list<ResponseWrapper>();
            InnerList=reqVFList;
            getTin();
        /*    for(ResponseWrapper r:){
            reqVFList.add();
            
            }
            
            for(integer i=0;reqWrapperList.size()<1000;i++){
              reqVFList.add(new ResponseWrapper(reqWrapperList));
            }
             for (integer i = 0; i < sList.size(); i++)
              myWrapperList.add(new MyWrapper(sList[i],iList[i]));
            }*/
            
            if(reqWrapperList.size()>20000){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'With this date range more than 10,000 transactions found, Please reduce date range and try again!'));
            
            }else{
            setPageSize = 20;
            i = 0; 
            next();
            } 
        }
    }
    
    public void getTin(){
        tId=Apexpages.currentpage().getparameters().get('tid');        
        System.debug('req wr-->'+reqVFList);
        mObj=new  Map<string,ResponseWrapper>();
        for(ResponseWrapper r:reqVFList){
            mObj.put(r.tin,r);
        }    
        System.debug('mObj here-->'+mObj);
    }
    public void UpdateRating(){
        System.debug('Rated-->'+overallRating);
        busQuality=overallRating;
        punctuality=overallRating;
        staffBehaviour=overallRating;
        
        
    }
    
    public boolean hasNext{
        get{
            return hsaNextFunction();
        }set;
    }
    
    public boolean hasPrevious{
        get{
            return hasPrevious();
        }set;
    }
    
    public boolean hsaNextFunction(){       
        if(i >= InnerList.size()) {
            return false; 
        } else {
            return true; 
        }
    }
    
    public boolean hasPrevious(){
        if(i <= setPageSize) {
            return false; 
        } else {
            return true; 
        }
    }
    
    public void next() 
    {
        reqVFList= nextFunction();
    }
    
    public void previous() 
    {
        reqVFList= previousFunction();
    } 
    
    public list<ResponseWrapper> nextFunction(){   
        ListRequested=new list<ResponseWrapper>();
        integer startNumber;
        integer size = InnerList.size();
        if(hsaNextFunction())
        {
            if(size <= (i + setPageSize))
            {
                startNumber = i;
                i = size;
            }
            else
            {
                i = (i + setPageSize);
                startNumber = (i - setPageSize);
            }
            
            for(integer start = startNumber; start < i; start++)
            {
                ListRequested.add(InnerList[start]);
            }   
        }  
        
        return ListRequested;
    }    
    
    public list<ResponseWrapper> previousFunction(){   
        ListRequested = new list<ResponseWrapper>(); 
        integer size = InnerList.size(); 
        if(i == size)
        {
            if(math.mod(size, setPageSize) > 0)
            {    
                i = size - math.mod(size, setPageSize);
            }
            else
            {
                i = (size - setPageSize);
            } 
        }
        else
        {
            i = (i - setPageSize);
        }
        for(integer start = (i - setPageSize); start < i; ++start)
        {
            ListRequested.add(InnerList[start]);
        } 
        return ListRequested;
    } 
    
    public pagereference FRPage(){
        System.debug('tinNo-->'+tinNo);
        PageReference myVFPage = new PageReference('/apex/ForceReviewPage?tId='+tinNo);
        myVFPage.setRedirect(false);
        return myVFPage;
        
    }
    
    public void submit(){
      // System.debug('review--->'+mObj.get('tId'));
      //(busQuality==0 && punctuality==0 && staffBehaviour==0) || 
      if((busQuality==0 && punctuality==0 && staffBehaviour==0 && comment=='')){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please give the Rating/Review'));
       }else{
      
      System.debug('comment-->'+comment);
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='ForceReviewSumbit'];
        System.debug('bq-->'+busQuality+'pun-->'+punctuality+'sb-->'+staffBehaviour);       
        string jsonNew=    JSON.serialize(
            new Map<String, Object> {
                'TIN' => tId,
                    'Tip' => comment,
                    'AgentName' => UserInfo.getName()+'('+UserInfo.getUserName()+')',
                    'Country' => 2,
                    'IsFromTripHistory' => true,
                    'SurveyTypeId' => 1,    
                    'ratings' => new Object[] {
                        new Map<String, Object> {
                            'questionId' => '1',
                                'rating' => string.valueof(busQuality)        
                                },new Map<String, Object> {
                                    'questionId' => '2',
                                        'rating' => string.valueof(punctuality)        
                                        },new Map<String, Object> {
                                            'questionId' => '3',
                                                'rating' =>string.valueof(staffBehaviour)       
                                                }
                    },  
                        'BaseObject' => new Map<String, Object> {
                            'ChannelInfo' => new Map<String, Object> {
                                'ChannelName' => 1
                                    },
                                        'CountryInfo' => new Map<String, Object> {
                                            'CountryName' => 2
                                                },
                                                    'BusinessUnit' => 2
                                                    } 
            }
        );
        
        System.debug('jsonNew-->'+jsonNew);
        
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        // req = HttpRequestUtil.populateHeaders(req);               
        req.setHeader('auth_key','a8d87a36-3fdc-4207-bf94-18b2afe24f6b');
        req.setHeader('AuthToken','3554a663-c59e-4fb0-a4ce-9459cf485952,bf1176f1-cb5e-4381-9da0-e0c687b6c5d9,192f09fa-960b-4273-a4a5-9d23ef56a207,6797c669-e4ae-45d2-9846-7810417d936a');
        req.setHeader('Channel_Name', 'SFA');
        req.setHeader('Country_Name', 'IND');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('BusinessUnit', 'BUS');
        req.setMethod('POST');
        req.setEndpoint(APIMData.Endpoint__c);
        //req.setbody(gen.getasString());
        req.setbody(jsonNew);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'Force Review';
        dbl.Request_Data__c = jsonNew;
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());

        try{
            res=h.send(req);
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.Response_Received__c = res.getBody();
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            Response sobj= (Response)System.JSON.deserialize(res.getbody(),Response.class);  
            System.debug('obj-->'+sobj.code);  
            System.debug('res-->'+res.getbody());  
            string sj='{"message":"Sorry! your feedback already exists!","code":204}';
            
            Map<string,object> resMap=(Map<string,object>)JSON.deserializeUntyped(res.getbody());   
            System.debug('s bo-->'+resMap.get('Code'));  
            
            if(string.valueof(resMap.get('code'))=='25')
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Rating has been submitted successfully'));
            else if(string.valueof(resMap.get('code'))=='204')
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'This trip rating already exist'));
            else if(string.valueof(resMap.get('code'))=='400')
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter valid ratings'));
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured, Please contact Admin'+e));            
            dbl.Exception_Description__c='Error-->'+e;
        } 
        insert dbl;
       }      
    }
    
    public class Response{
        public string message{get;set;}
        public string code{get;set;}
    }  
   public class ResponseWrapper{
        public Integer FBResultId{get;set;}
        public String DateOfJourney{get;set;}
        public String TIN{get;set;}
        public String CustomerName{get;set;}
        public String BoardingPointTime{get;set;}
        public String DroppingPointTime{get;set;}
        public String BoardingPointName{get;set;}
        public String DroppingPointName{get;set;}
        public Integer Country{get;set;}
        public String OperatorName{get;set;}
        public String SourceName{get;set;}
        public String DestinationName{get;set;}
        public String UserId{get;set;}
        public String EmailId{get;set;}
        public String mobileNo{get;set;}
        public boolean IsRated{get;set;}
        public boolean IsReviewed{get;set;}
        public string BusType{get;set;}
    }
}