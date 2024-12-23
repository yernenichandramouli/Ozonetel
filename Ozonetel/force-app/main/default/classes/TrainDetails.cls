public class TrainDetails{
    
    @Auraenabled(cacheable=true)
    public static string GetTrainDetails(string ordItemId,string source){
        
        List<Order_Items__c> ordLs=new List<Order_Items__c>();
        ordLs=[select id,name,Order_Item_Reference_No__c,Guid__c,Service_Provider_Reference_No__c  from Order_Items__c where id=:ordItemId];
        if(!ordLs.isEmpty()){
            String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TrainPNRDetails'].Endpoint__c;
            endPoint=endPoint+ordLs[0].Order_Item_Reference_No__c+'&uuid='+ordLs[0].Guid__c+'&pnr='+ordLs[0].Service_Provider_Reference_No__c;
            //endPoint='https://loco.redbus.com/api/Rails/v1/PnrDetails?tin=R4H82970801&uuid=7b068492d809e005d4b52ab401020b00&pnr=4125977165';
            HttpRequest req = new HttpRequest();
            req = HttpRequestUtil.populateCAPIHeaders(req);
            Http ht = new Http();
            req.setMethod('GET');
            req.setTimeout(120000);                     
            req.setEndpoint(endPoint);
            HttpResponse res = ht.send(req);
            string resBody=res.getBody();
            System.debug('resBody-->'+resBody);
            string mockResp='{ "pnrNo": "2810955620", "dateOfJourney": "2021-11-16T14:45:00", "trainNumber": "01118", "trainName": "PCOI ET EXP SPL", "sourceStation": "PCOI", "destinationStation": "JBP", "reservationUpto": "JBP", "boardingPoint": "PCOI", "journeyClass": "SL", "numberOfpassenger": 3, "chartStatus": "NOT_PREPARED", "passengerList": [ { "passengerSerialNumber": 1, "passengerAge": 17, "bookingStatus": "CNF", "bookingCoachId": "S3", "bookingBerthNo": 37, "currentStatus": "CNF", "currentCoachId": "S3", "currentBerthNo": 37, "passengerName": "Nitin rai", "seniorCitizenApplicable": false }, { "passengerSerialNumber": 2, "passengerAge": 52, "bookingStatus": "CNF", "bookingCoachId": "S3", "bookingBerthNo": 34, "currentStatus": "CNF", "currentCoachId": "S3", "currentBerthNo": 34, "passengerName": "virendra rai", "seniorCitizenApplicable": false }, { "passengerSerialNumber": 3, "passengerAge": 47, "bookingStatus": "CNF", "bookingCoachId": "S3", "bookingBerthNo": 35, "currentStatus": "CNF", "currentCoachId": "S3", "currentBerthNo": 35, "passengerName": "sheela rai", "seniorCitizenApplicable": false } ], "bookingFare": 230, "quota": "GN" }';
            return resBody;
        }
        return null;
    }
}