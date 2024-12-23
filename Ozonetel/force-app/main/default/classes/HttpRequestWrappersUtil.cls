/**
* (c) 2018 RedBus
*
* Name           : HttpRequestWrappersUtil
* Created Date   : 29 May 2018
* Created By     : Sreenivas M
* Purpose        : This class will stores the all Request Wrappers Related to Integration 
* Test class     : 
*
**/

public class HttpRequestWrappersUtil
{
    public class Dataparams
    {
        public string message { get; set; }
        public string terms { get; set; }
        public string title { get; set; }
        public string typeid { get; set; }
        public string id { get; set; }
        public string action { get; set; }
        public string postScript { get; set; }
        public string expiryTime { get; set; }
        public string actionTitle { get; set; }
        public string sid { get; set; }
        public string time_to_live { get; set; }
        public string timestamp { get; set; }
    }
    
    public class Pushdata
    {
        public List<string> EmailId { get; set; }
        public Dataparams dataparams { get; set; }
    }
    
    public class CustomMessageDetails
    {
        public string TemplateName { get; set; }
        public string DataJsonStr { get; set; }
        public string DataComplexity { get; set; }
    }
    
    public class SMSMessage
    {
        public string senderId { get; set; }
        public string mobileNo { get; set; }
        public String message { get; set; }
        public boolean isUnicodeSms { get; set; }
        public CustomMessageDetails CustomMessageDetails { get; set; }
    }
    
    public class SMSRequest
    {
        public SMSMessage SMSMessage { get; set; }
    }
    
    public class Smsdata
    {
        public List<SMSRequest> SMSRequest { get; set; }
        public string NotificationType { get; set; }
        public string Language { get; set; }
        public boolean IsTemplateUsedForMessage { get; set; }
    }
    
    public class EmailServiceRequest
    {
        public string Subject { get; set; }
        public string Sender { get; set; }
        public string Receiver { get; set; }
        public string body { get; set; }
        public string SenderDisplayName { get; set; }
        public string language { get; set; }
        public CustomMessageDetails CustomMessageDetails { get; set; }
    }
    
    public class EmailRequest
    {
        public EmailServiceRequest EmailServiceRequest { get; set; }
    }
    
    public class Emaildata
    {
        public string NotificationType { get; set; }
        public string Language { get; set; }
        public boolean IsTemplateUsedForMessage { get; set; }
        public List<EmailRequest> EmailRequests { get; set; }
    }
    
    public class SendSMSEMailReqWrapper
    {
        public List<string> type { get; set; }
        public Smsdata smsdata { get; set; }
        public Emaildata emaildata { get; set; }
        public Pushdata pushdata { get; set; }
    }
    
    public class Address
    {
        public String links { get; set; }
        public string whatsapp_number { get; set; }
    }
    
    public class AttachmentDetails
    {
    }
    
    public class MessageDetails
    {
        public string TemplateName { get; set; }
        public string DataJsonStr { get; set; }
        public integer DataComplexity { get; set; }
        public string Language { get; set; }
        public string TIN { get; set; }
    }
    
    public class WhatsAppRequestWrapper
    {
        public String data_params { get; set; }
        public List<string> channels { get; set; }
        public String name { get; set; }
        public Address address { get; set; }
        public AttachmentDetails AttachmentDetails { get; set; }
        public MessageDetails MessageDetails { get; set; }
    }
    
    public class NPSDetractorFetchResponse
    {  
        
        public string RequestId { get; set; }
        public string CheckInDate { get; set; }
        public string TIN { get; set; }
        public string MobileNumber { get; set; }
        public string EmailId {get; set; }
        public string NPS { get; set; }
        public string HotelName{ get; set; }
        public string Location { get; set; }
        public string NoOfRooms { get; set; }
        public string Feedback { get; set; }
        public string Status { get; set; }
        public string Comments  {get; set;}
        public string LockedBy {get; set;}
    }
    
    public class PaasRefundUpsertRequest
    {
        public boolean isInsertTrue { get; set; } // if record to be inserted with final status of refund, check whether record already exists or not 
        public RefundStatus refundStatus { get; set; } // refundStatus should be enums provided below.
        public string refundMsg { get; set; } // what is reason for refunding from CSE, keep some enums from your end.
        public string requestId { get; set; } // requestId, this is the Id what you get in GetPendingRefunds call-- needed only when isInsertTrue property is false. i.e to update record.
        public string orderId { get; set; }  // Payment UUID
        public string transactionId { get; set; } // paas TransactionId
        public string bankArnNumber { get; set; } // bankArnNumber/Neft ref number/PGTransactionId
        public string amount { get; set; } // refunded Amount
        public string refundedBy { get; set; } // who initiated the refund from SF?
        public string modifiedSource { get; set; } // Who modified/insisted to Amend the refundTransaction. can be respective team name.
        public string initiatedTime { get; set; } // When did  refund Initiated?
        public string comments{get;set;} // Used to pass the refund failed reason
    }
    
    public enum RefundStatus
    {
        SUCCESS,
            FAILED,
            DISCARDED,
            AWAITING,
            SF_CSE_REF_FAILED
            }
    
    public class ConfirmDetails
    {
        public integer errorCode { get; set; }
        public string pnr { get; set; }
        public string respCode { get; set; }
        public string cancellationPolicy { get; set; }
        public boolean isMTicketEnabled { get; set; }
        public integer routeId { get; set; }
        public string doj { get; set; }
        public string seatnames { get; set; }
        public string lisErrorCode { get; set; }
        public string contactNo { get; set; }
        public string vendorPnr { get; set; }
        public string rescheduleRefNo { get; set; }
        public List<object> seatWisePnr { get; set; }
    }
    
    public class PaymentResponse
    {
        public string PaymentItemId;
        public string PgTransactionId;
        public string PaymentStatus;
        public string RbPgId;
        public string IsOffline;
        public string Amount;
        public string PGType;
        public string GatewayName;
    }
    
    public class ListConfirmOrderDTO
    {
        public string orderItemUuid { get; set; }
        public ConfirmDetails confirmDetails { get; set; }
    }
    
    public class ConfirmTicket
    {
        public List<ListConfirmOrderDTO> listConfirmOrderDTO { get; set; }
        public string confirmType { get; set; }
    }
    
    public class GenericHeadersWrapper
    {       
        public string key;
        public string value;
        public GenericHeadersWrapper(string key,string value){
            this.key=key;
            this.value=value;
        }
    }
    
    public class NPSBusDectractorsResponse
    {  
        public Integer RequestId { get; set; }
        public string DateOfJourney { get; set; }
        public string TIN { get; set; }
        public string MobileNumber { get; set; }
        public string EmailId { get; set; }
        public string NPS { get; set; }
        public string Travels { get; set; }
        public string OperatorId { get; set; }
        public string Routes { get; set; }
        public Integer NoofSeats { get; set; }
        public string Feedback { get; set; }
        public string Status { get; set; }
        public string CreateDate{get;set;}
    }
    public class PaymentItem
    {
        public String id { get; set; }
        public string additional_details { get; set; }
        public string created_by { get; set; }
        public datetime creation_time { get; set; }
        public string transaction_source { get; set; }
        public string updated_by { get; set; }
        public datetime updated_time { get; set; }
        public integer version { get; set; }
        public string business_unit_currency { get; set; }
        public decimal business_unit_value { get; set; }
        public string amount_payable_currency { get; set; }
        public decimal amount_payable_value { get; set; }
        public String order_id { get; set; }
        public string payment_status { get; set; }
        public integer payment_session_id { get; set; }
        public string payment_system { get; set; }
        public string payment_system_ref_no { get; set; }
        public string settled_currency { get; set; }
        public decimal settled_value { get; set; }
        public datetime settlement_time { get; set; }
        public integer creation_time_public { get; set; }
        public integer settlement_time_public { get; set; }
        public boolean has_discrepancy { get; set; }
        public boolean is_reconceiled { get; set; }
        public decimal commission { get; set; }
        public integer payment_type { get; set; }
        public boolean is_complete { get; set; }
        public string guid { get; set; }
        public string pgName { get; set; }
        public string pgtype { get; set; }
        public string bankAccountNumber { get; set; }
        public string accountHolderName { get; set; }
        public string latestPgStatus{get;set;}
        public Boolean isOffline{get;set;}
        public String PgRefNo{get;set;}
        public String operationType{get;set;}
        
    }
    
    public class AgentDetail
    {
        public string campaign_name { get; set; }
        public string agent_id { get; set; }
        public string agentstate { get; set; }
    }
    
    public class Response
    {
        public string transaction_id { get; set; }
        public string response_code { get; set; }
        public string status { get; set; }
        public AgentDetail agent_detail { get; set; }
        public string reason { get; set; }
    }
    
    public class AgentAvailableResponse
    {
        public Response response { get; set; }
    }
    
    public class RefundStatusWrapper{
        public string status{get;set;}
        public List<RefundStatusData> data{get;set;}
        public RefundStatusWrapper(){
            data=new List<RefundStatusData>();
        }
    }  
    
    public class RefundStatusData{
        public string orderId{get;set;}
        public string refId{get;set;}
        public string refundStatus{get;set;}
        public string type{get;set;}
        public string amount{get;set;}
        public string processedTime{get;set;}
        public string processedBy{get;set;}
        public string comment{get;set;}
        public string transactionId{get;set;}
    }
    
    public class ActivityCancelRequest
    {
        public boolean backToSource{get;set;}
        public string reason{get;set;}
        public string cancelledBy{get;set;}
        public string emailID{get;set;}
    }
    
    public class CancellationPolicy
    {
        public string description { get; set; }
        public string chargesValue { get; set; }
    }
    
    public class AddonsCancellationResponse
    {
        public double totalFare { get; set; }
        public double refundableAmount { get; set; }
        public string itemUuid { get; set; }
        public string itemType { get; set; }
        public string itemName { get; set; }
        //public string currency { get; set; }
        public boolean isAddOnCancellable { get; set; }
        public String errorMsg { get; set; }
        public List<CancellationPolicy> cancellationPolicy { get; set; }
    }
    
    public class CancelTicketResponse
    {
        public String NewTicket { get; set; }
        public String Message { get; set; }
        public boolean Status { get; set; }
        public double RefundAmount { get; set; }
        public double CancellationCharges { get; set; }
        public boolean IsRefundSuccess { get; set; }
        public boolean NeftRefundSupported { get; set; }
        public String OrderId { get; set; }
        public String SalesChannel { get; set; }
        public String BusinessUnit { get; set; }
        public String Country { get; set; }
        public String SelectedLanguage { get; set; }
        public String SeatNames { get; set; }
        public String CancelledSeatNames { get; set; }
        public List<string> CancelledAddons { get; set; }
    }
    
    public class Context
    {
        public string TCode { get; set; }
        public string CustomerName { get; set; }
        public string source { get; set; }
        public string destination { get; set; }
        public string JourneyDate { get; set; }
        public string NoofPax { get; set; }
    }
    
    public class RnRrequestWrapper
    {
        public string uid { get; set; }
        public string channel { get; set; }
        public string country { get; set; }
        public string lang { get; set; }
        public string query { get; set; }
        public integer sessionTime { get; set; }
        public boolean useCustomContext { get; set; }
        public string endpoint_identifier { get; set; }
        public Context context { get; set; }
    }  
    
    //B2B api request and response wrapper
    public class CaseRequestWrapper
    {
        public string tin;
        public string status;
        public CaseRequestWrapper(string tin,string status){
            this.tin=tin;
            this.status=status;
        }
    } 
    
    public class ResponseWrapper
    {
        public string tin { get; set; }
        public string responseCode { get; set; }
        public string responseMessage { get; set; }
    }    
    //End-B2B wrapper
    
    public class RequestedBy    {
        public string SystemName { get; set; } 
        public string UserName { get; set; } 
    }
    
    public class DisbursalRequestWrap  {
        public string DisbursalID { get; set; } 
        public RequestedBy RequestedBy { get; set; } 
    }
    
    public class DisbursalCaseNumberUpdate    {
        public string DisbursalID { get; set; } 
        public string CaseID { get; set; } 
    }
    
    public class UpdateDisbursalStatusWrap {
        public string DisbursalID { get; set; } 
        public string Status { get; set; } 
        public string voucherRefId { get; set; } 
        public string voucherValidity { get; set; } 
        public string ReferenceID { get; set; } 
        public string DisbursalFailureReason { get; set; } 
        public string ConfirmationResonse { get; set; } 
    }
    
    public class PassUpdatePGTxnIdWrap {
        public integer TransactionID { get; set; } 
        public string PaymentItemUUID { get; set; } 
        public string PGTransactionID { get; set; } 
    }
    
    public class generateDisReq {
        public integer amount { get; set; } 
        public string order_id { get; set; } 
        public string order_uuid { get; set; } 
        public string country_name { get; set; } 
        public string email { get; set; } 
        public string phone_num { get; set; } 
    }
    
    //Start - ShortRoute Buses Bording Points
    public class BpList {
        @AuraEnabled
        public Integer locationId { get; set; }
        @AuraEnabled
        public String locationName { get; set; }
        @AuraEnabled
        public String BpAddress{ get; set; }
    }
    public class ShortRouteStops{
        @AuraEnabled
        public List<BpList> bpList { get; set; }
        @AuraEnabled
        public List<BpList> dpList { get; set; }
    }
    public class p42{
        @AuraEnabled
        public integer Eta { get; set; }
        @AuraEnabled
        public integer EstTimeToReachDest { get; set; }
        @AuraEnabled
        public string BpDp { get; set; }
        @AuraEnabled
        public boolean FlexiTicket { get; set; }
    }
    public class inv{
        @AuraEnabled
        public string bt {get; set;}
        @AuraEnabled
        public string sn {get; set;}        
        @AuraEnabled
        public string tvs {get; set;}        
        @AuraEnabled
        public p42 p42 { get; set; }
        
    }
    public class busDetails{
        @AuraEnabled
        public List<inv> inv { get; set; }
    }
    Public Class NotificationResponse{
        public string statusMessage{ get;set; }
        public boolean isEmailSent{ get;set; }
        public boolean isSMSSent{ get;set; }
        public boolean isWhatsAppSent{ get;set; }
        public string emailRespId{ get;set; }
        public string SMSRespId{ get;set; }
        public string WhatsRespId{ get;set; }
        public string Data{ get;set; }
    }
    //End - ShortRoute Buses Bording Points            
    public class TicketFare{
        @AuraEnabled
        public string currencyType{get; set; }
        @AuraEnabled
        public decimal amount{get; set; }       
    }
    public class customerPriceBreakUp{
        @AuraEnabled
        public string componentName{get; set;}
        @AuraEnabled
        public decimal value{get; set; }
    }
    public class fareBreakup{
        @AuraEnabled
        public decimal baseFare{get; set;}
        @AuraEnabled
        public decimal totalAmount{get; set;}
    }
    public class Addons{
        @AuraEnabled
        public string addonType{get; set;}
        @AuraEnabled
        public string title{get; set;}
        @AuraEnabled
        public fareBreakup fareBreakup{get; set;}
    }
    public class priceBreakupResponse{
        @AuraEnabled
        public List<customerPriceBreakUp> customerPriceBreakUp{get; set;}
        @AuraEnabled
        public decimal Discount{get; set;}
        @AuraEnabled
        public TicketFare TicketFare{get; set;}
        @AuraEnabled
        public List<Addons> Addons{get; set;}
        @AuraEnabled
        public string errorMsg{get; set;}
    }
    public class data{
        @AuraEnabled
        public String conductorName{get;set;}
        @AuraEnabled
        public String assignStatus{get;set;}
        @AuraEnabled
        public String trackingType{get;set;}
        @AuraEnabled
        public String conductorNumber{get;set;}
        @AuraEnabled
        public String source{get;set;}
        @AuraEnabled
        public String driverName{get;set;}
        @AuraEnabled
        public String destination{get;set;}
        @AuraEnabled
        public String driverNumber{get;set;}
        @AuraEnabled
        public String serviceNo{get;set;}
        @AuraEnabled
        public String vehicleNumber{get;set;}
        @AuraEnabled
        public Integer passengerCount{get;set;}
        @AuraEnabled
        public String operatorServiceNum{get;set;}        
    }
    public class busAssignmentResponse{
        @AuraEnabled
        public List<data> data{get; set;}
        @AuraEnabled
        public string showError{get; set;}
        @AuraEnabled
        public string operator{get; set;}
    }
    
    public class ErrorCls
    {
        public string pnr { get; set; }
        public string error { get; set; }
    }

    public class DataCls
    {
        public decimal refundAmount { get; set; }
        public string pnr { get; set; }
    }

    public class RedRailsReconResponse
    {
        public string status { get; set; }
        public List<ErrorCls> errors { get; set; }
        public List<DataCls> data { get; set; }
    }
    
    public class CancellationDetail
    {
        public string pnr { get; set; }
        public decimal refundAmount { get; set; }
    }

    public class RedRailsReconRequest
    {
        public boolean isMultiSeatCancel { get; set; }
        public List<CancellationDetail> cancellationDetails { get; set; }
    }
  
  // Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse);
    public class CargTrackingRequestWrapperDetails
    {
        public string updateType { get; set; }
        public ExtraDetails extraDetails { get; set; }
    }
    public class ExtraInfo
    {
        public string agentNumber { get; set; }
        public string agentName { get; set; }
    }
    public class ExtraDetails
    {
        public List<TrackingInfo> trackingInfo { get; set; }
       // public FirstMileDelivery firstMileDelivery { get; set; }
        //public LastMileDelivery lastMileDelivery { get; set; }
    }

    public class FirstMileDelivery
    {
        public string serviceProviderName { get; set; }
    }

    public class LastMileDelivery
    {
        public string serviceProviderName { get; set; }
    }
    
    public class TrackingInfo
    {
        public string stage { get; set; }
        public string stageHeader { get; set; }
        public string status { get; set; }
        public string reason { get; set; }
        public string comments { get; set; }
        public string stageType { get; set; }
        public string deliveryStatus { get; set;}
        public string stageDate{ get; set;}
        public integer updatedTime { get; set; }
        public integer stageId    { get; set; }
        public List<string> extraInfo { get; set; }   
   }

//cargo cancellation
  public class CargoCancellationRequest
    {
        public integer cancellationCharges { get; set; }
        public integer refundAmount { get; set; }
        public integer nonRefundableCharges { get; set; }
        public string cancellationSource { get; set; }
        public string uuid {get; set;}
        public string businessUnit { get; set; }
        public string channel { get; set; }
        public string refundedBy { get; set; }
        public string operatorCancellationStatus { get; set; }
        public string cancellationReason { get; set; }
    }
    
    public class CustomerAndCallbackRecord
    {
        public CustomerRecord customerRecord { get; set; }
    }

    public class CustomerRecord
    {
        public string phone1{ get; set; }
        public string callTime{ get; set; }
        public string callEndTime{ get; set; }
        public string sfRecId{ get; set; }
        public string orderItemId { get; set; }
        public string orderId{get;set;}
        public string reason{get;set;}
    }
    
    
    public class Properties
    {
       public boolean updatedot_customer { get; set; }
       public boolean migratedot_customer { get; set; }
    }
    
    public class AmeyoCMAPIRequestWrapper
    {
        public string campaignId { get; set; }
        public List<CustomerAndCallbackRecord> customerAndCallbackRecords { get; set; }
        public string leadId { get; set; }
        public Properties properties { get; set; }
        public string attempts { get; set; }
        public string status { get; set; }
    }
    
    public class CallbackProperties
    {
        public string customerId { get; set; }
        public string phone { get; set; }
    }
    
    public class AmeyoCMAPIResponseWrapper
    {
        public CallbackProperties callbackProperties { get; set; }
        public string callbackTime { get; set; }
        public integer campaignId { get; set; }
        public string id { get; set; }
        public boolean isSelfCallback { get; set; }
        public string userId { get; set; }
        public boolean crmIntegrated { get; set; }
        public string crmTypeString { get; set; }
        public boolean crmSuccess { get; set; }
        public integer customerId { get; set; }
        public boolean isInserted { get; set; }
        public string resultTypeString { get; set; }
        public string message { get; set; }
    }
    
    
}