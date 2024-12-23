@isTest
public class ForceReviewControllerTest
{
    /*
Name:successTest
Description: 
*/
    
    public static testMethod void getTransactionTest(){
        Test.startTest();
        
        ForceReviewController fr=new ForceReviewController();
        
        fr.fromdate=System.today();
        fr.toDate=System.today();
        
        string json='[{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false},{"FBResultId":6467331,"DateOfJourney":"15-10-2017","TIN":"SG17A68304187","CustomerName":"Oh Alvin","BoardingPointTime":"00:00","DroppingPointTime":"00:00","BoardingPointName":"Malacca","DroppingPointName":"Singapore","Country":2,"OperatorName":"KKKL Travel & Tours Pte Ltd","SourceName":"Malacca","DestinationName":"Singapore","UserId":"12092477","EmailId":"boeylee67@gmail.com","mobileNo":"6596646700","IsRated":true,"IsReviewed":false},{"FBResultId":6423076,"DateOfJourney":"29-10-2017","TIN":"SG17A30232391","CustomerName":"Nur Hazwani Hamid","BoardingPointTime":"06:00","DroppingPointTime":"00:00","BoardingPointName":"Singapore","DroppingPointName":"Kuala lumpur","Country":2,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"12044409","EmailId":"wanie_wan1315@hotmail.sg","mobileNo":"6584882511","IsRated":false,"IsReviewed":false}]';
        string resJson='[{"FBResultId":0,"DateOfJourney":"2017-09-21T00:00","TIN":"SG179F3284335","CustomerName":"Tan Chai Huat","BoardingPointTime":"2017-09-21T07:00","DroppingPointTime":null,"BoardingPointName":"2017-09-21T07:00","DroppingPointName":"Terminal Bersepadu Selatan","Country":0,"OperatorName":"Starmart Express","SourceName":"Singapore","DestinationName":"Kuala lumpur","UserId":"0","EmailId":"youjin@live.com.my","mobileNo":"6598247150","IsRated":false,"IsReviewed":false,"BusType":"SVIP"},{"FBResultId":0,"DateOfJourney":"2017-09-21T00:00","TIN":"SG179F2401249","CustomerName":"Mohd Suhaimi Bin Zulakafli","BoardingPointTime":"2017-09-21T15:30","DroppingPointTime":null,"BoardingPointName":"2017-09-21T15:30","DroppingPointName":"Singapore","Country":0,"OperatorName":"Starmart Express","SourceName":"Kuala lumpur","DestinationName":"Singapore","UserId":"11593063","EmailId":"keraongalongsuhaimi@gmail.com","mobileNo":"6583489874","IsRated":true,"IsReviewed":false,"BusType":"SVIP"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', resJson));
        fr.getTransactions();
        fr.hasNext=false;
        fr.hasPrevious=false;
        // fr.previous();
        fr.FRPage();
        // ForceReviewController2.ResponseWrapper sobj= (ForceReviewController2.ResponseWrapper)System.JSON.deserialize(resJson,ForceReviewController2.ResponseWrapper.class);  
        ForceReviewController.ResponseWrapper sobj=new ForceReviewController.ResponseWrapper();
        sobj.FBResultId=12;
        sobj.CustomerName='Test Customer';
        sobj.BoardingPointTime='Test BP';
        sobj.DroppingPointTime='Test DP';
        sobj.BoardingPointName='Test BPN';
        sobj.DroppingPointName='Test DPN';
        sobj.Country=0;
        sobj.OperatorName='Test ON';
        sobj.SourceName='Test SN';
        sobj.DestinationName='Test Dest';
        sobj.UserId='Test Uid';
        sobj.EmailId='Test@t.com';
        sobj.mobileNo='9491322718';
        sobj.IsRated=true;
        sobj.IsReviewed=false;
        sobj.BusType='Test BT';
        
        Test.stopTest();
    }
    
    public static testMethod void submitTest(){
        Test.startTest();
        
        ForceReviewController fr=new ForceReviewController();
        String resJson='{"message":"Thank you for your feedback","code":25}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', resJson));        
        fr.submit();
        String resJson2='{"message":"Thank you for your feedback","code":204}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', resJson2));        
        fr.submit();  
        String resJson3='{"message":"Thank you for your feedback","code":400}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', resJson3));        
        fr.submit();  
        fr.UpdateRating();
        fr.hasNext=true;
        fr.hasPrevious=true;
        // fr.previous();
        
        Test.stopTest();
    }
    
}