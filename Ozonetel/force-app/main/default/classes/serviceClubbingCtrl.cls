/*
* Name           : serviceClubbingCtrl
* Created Date   : 14 DEC 2022
* Created By     : VR Sudarshan 
* Purpose        : To display Busshift data.
* Test class     : serviceClubbingCtrlTest
* Jira Id        : CRM-1257
*/
public class serviceClubbingCtrl {

    @AuraEnabled
    public static Map<string,object> getBusShiftDetails(String transactionId){
        Map<string,object> finalMap = New Map<String,Object>();
        List<Order_Items__c> transactionList = [SELECT Id, isShifted__c, Historic_Details__c  FROM Order_Items__c WHERE Id =:transactionId LIMIT 1];
        if(transactionList[0].isShifted__c){
            string jsonData = transactionList[0].Historic_Details__c;
            Root  bdData = (Root)JSON.deserialize(jsonData,Root.class); 
            list<BusShiftHistory> busListr = New List<BusShiftHistory>();
            busListr =bdData.BusShiftHistory;
            for(BusShiftHistory busH:busListr){
                finalMap.put('updatedDetails',JSON.serialize(busH.updatedDetails));
                finalMap.put('prevDetails',JSON.serialize(busH.prevDetails));
                System.debug('::: finalMap :::: '+finalMap);
            }
        }else{
            finalMap.put('Error','Service Clubbing Details are not available');

        }
        return finalMap;

    }


    public class Address
    {
        public string state { get; set; }
        public string pincode { get; set; }
        public string country { get; set; }
        public string city { get; set; }
        public string addressLine2 { get; set; }
        public string addressLine1 { get; set; }
    }

    public class BoardingPointDetails
    {
        public DateTime boardingtime { get; set; }
        public Location location { get; set; }
        public string landMark { get; set; }
        public string country { get; set; }
        public List<string> contactNos { get; set; }
        public Address address { get; set; }
    }

    public class BusShiftHistory
    {
        public UpdatedDetails updatedDetails { get; set; }
        public DateTime updateTime { get; set; }
        public PrevDetails prevDetails { get; set; }
    }

    public class CustomerPriceBreakUp
    {
        public Decimal value { get; set; }
        public Decimal refundableValue { get; set; }
        public boolean isCancellationPolicyApplicable { get; set; }
        public string componentName { get; set; }
        public Decimal trueValue { get; set; }
    }

    public class DeparturePointDetails
    {
        public DateTime departuretime { get; set; }
        public string landMark { get; set; }
        public List<string> contactNos { get; set; }
        public Address address { get; set; }
    }

    public class Location
    {
        public Integer lon { get; set; }
        public Integer lat { get; set; }
    }

    public class PrevDetails
    {
        public TicketDetails ticketDetails { get; set; }
        public string serviceProviderName { get; set; }
        public List<SeatDetail> seatDetails { get; set; }
        public string routeId { get; set; }
        public DateTime cancellationReferenceTime { get; set; }
        public string busType { get; set; }
        public DateTime boardingTime { get; set; }
        public string boardingPoint { get; set; }
    }

    public class Root
    {
        public List<BusShiftHistory> busShiftHistory { get; set; }
    }

    public class SeatDetail
    {
        public TravellerDetailsVO travellerDetailsVO { get; set; }
        public string seatType { get; set; }
        public string seatName { get; set; }
        public boolean isPartiallyCancellable { get; set; }
        public List<CustomerPriceBreakUp> customerPriceBreakUp { get; set; }
    }

    public class TicketDetails
    {
        public DeparturePointDetails departurePointDetails { get; set; }
        public BoardingPointDetails boardingPointDetails { get; set; }
    }

    public class TravellerDetailsVO
    {
        public string title { get; set; }
        public string proofId { get; set; }
        public string name { get; set; }
        public string mobileNo { get; set; }
        public string issuingAuthority { get; set; }
        public string idProofType { get; set; }
        public string gender { get; set; }
        public string email { get; set; }
        public string dateOfBirth { get; set; }
        public string alternateNumber { get; set; }
        public integer age { get; set; }
        public Address address { get; set; }
    }

    public class UpdatedDetails
    {
        public DateTime updatedDateOfJourney { get; set; }
        public TicketDetails ticketDetails { get; set; }
        public string serviceProviderName { get; set; }
        public List<SeatDetail> seatDetails { get; set; }
        public string routeId { get; set; }
        public DateTime cancellationReferenceTime { get; set; }
        public string busType { get; set; }
        public DateTime boardingTime { get; set; }
        public string boardingPoint { get; set; }
    }


}