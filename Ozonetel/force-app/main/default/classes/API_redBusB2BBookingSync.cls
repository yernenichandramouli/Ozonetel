/**
* (c) 2019 RedBus
*
* Name           :
* Created Date   : 
* Created By     : 
* Purpose        : 
*
**/
@RestResource(urlMapping='/redBus/v1/redBusB2BBookingSync/*')
global without sharing class API_redBusB2BBookingSync
{
    static Map<String,List<Database.UpsertResult>> mapObjtoSavedResults = new Map<String,List<Database.UpsertResult>>(); 
    static Id dbLogSummId;
    static string ProcessExceptionTableName;   
    @HttpPost
    global static Response BookingDetails()
    {
        Response resp=new Response();        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        system.debug('-----------Requested data--------'+req.requestBody.toString());
        try
        {
            if(!string.isBlank(string.valueof(req.requestBody.toString())))
            {
                BookingRequest bookingData= new BookingRequest();
                bookingData = (BookingRequest)JSON.deserialize(req.requestBody.toString(),BookingRequest.class);
                system.debug('---bookingData----'+bookingData);
                dbl.Payment_Request_Sent_Time__c = System.now();
                dbl.Type__c ='B2B Syncing-'+bookingData.type;
                dbl.redBus_SentAt__c = bookingData.sentAt;
                dbl.SentAt__c = System.now();
                dbl.Region__c = bookingData.region;
                dbl.SyncedFrom__c = bookingData.syncFrom;
                dbl.cZentrix_Type__c = dbl.Region__c;
                
                if(String.isBlank(dbl.cZentrix_Type__c))
                {
                    Decimal timeDiff = decimal.valueof((DateTime.now().getTime() - Datetime.valueOf(bookingData.sentAt).getTime())/(60*60))/1000;
                    dbl.cZentrix_Type__c = timeDiff>5.0?'INTL':'IND';
                }
                Database.SaveResult saveResult = DataBase.insert(dbl,false);
                dbLogSummId = dbl.id;
                
                if(bookingData.orderItems!=null && !bookingData.orderItems.isEmpty())
                {
                    list<Order_Items__c> orderItems = new list<Order_Items__c>();
                    ProcessExceptionTableName = 'orderItems';
                    map<string,Service_Provider__c> mapserviceProvider = new map<string,Service_Provider__c>();
                    
                    for(API_redBusB2BBookingSync.OrderItem  orIt: bookingData.orderItems)
                    {
                        if(string.isNotBlank(string.valueof(orIt.order_item_reference_no)))
                        {
                            Service_Provider__c serpro = new Service_Provider__c();   
                            serpro.Operator_Id__c = orIt.service_provider_id;
                            if(String.isNotBlank(orIt.service_provider_name))
                            {
                                if(String.valueOf(orIt.service_provider_name).length()>80)
                                {
                                    serpro.name =  string.valueof(orIt.service_provider_name).substring(0,80);
                                }
                                else
                                {
                                    serpro.name = orIt.service_provider_name;
                                }
                                serpro.TravelsFullName__c = orIt.service_provider_name;
                            }else {
                                serpro.name =  'NA';
                                serpro.TravelsFullName__c = 'NA';
                            }
                            mapserviceProvider.put(serpro.Operator_Id__c,serpro);     
                        }                      
                    }    
                    
                    if(!mapserviceProvider.isempty())
                        Database.upsert(mapserviceProvider.values(),Service_Provider__c.Operator_Id__c,false);
                    
                    for(API_redBusB2BBookingSync.OrderItem  orIt: bookingData.orderItems)
                    {
                        if(string.isNotBlank(string.valueof(orIt.order_item_reference_no)))
                        {
                            Order_Items__c orderIt = new Order_Items__c();
                            list<InventoryWrapper> inventWrapper=new list<InventoryWrapper>();
                            System.debug('inveT-->'+orIt.inventoryItems);
                            if(String.isNotBlank(orIt.inventoryItems)){
                                inventWrapper  = (list<InventoryWrapper>)JSON.deserialize(orIt.inventoryItems, list<InventoryWrapper>.class);
                                if(!inventWrapper.isEmpty()){
                                    orderIt.Mobile__c=inventWrapper[0].passenger.mobile;
                                    orderIt.Email__c=inventWrapper[0].passenger.email;
                                } 
                            }
                            if(string.isNotBlank(orIt.service_provider_id))
                                orderIt.Service_Provider_Info__r = new Service_Provider__c(Operator_Id__c=orIt.service_provider_id); 
                            
                            orderIt.status__c=orIt.status;
                            if(orIt.status=='TR_BOOKED_PO_COMPLETED'){
                            orderIt.Transaction_Status__c='Booked';
                            }else if(orIt.status=='TR_CANCELLED_PO_COMPLETED'){
                            orderIt.Transaction_Status__c='Cancelled';
                            }
                            orderIt.ID__c = string.valueof(orIt.order_item_reference_no);
                            orderIt.Name = orderIt.ID__c;
                            orderIt.Order_Item_Reference_No__c = string.valueof(orIt.order_item_reference_no);
                            orderIt.Business_Unit__c ='REDBUS_IN';
                            orderIt.RecordTypeId=Schema.getGlobalDescribe().get('Order_Items__c').getDescribe().getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId();
                            orderIt.Boarding_Time__c = String.isNotBlank(orIt.boarding_time)?datetime.valueof(orIt.boarding_time.replace('T',' ')):null;
                            orderIt.Bus_Type__c = orIt.bus_type;                           
                            orderIt.Cancellation_Policy__c = orIt.cancellation_policy;
                            orderIt.Date_Of_Purchase__c = String.isNotBlank(orIt.date_of_purchase)?datetime.valueof(orIt.date_of_purchase.replace('T',' ')):null;                                
                            orderIt.Destination__c = orIt.destination_city;
                            orderIt.Dropping_Point__c = orIt.dropping_point;
                            orderIt.Dropping_Time__c=String.isNotBlank(orIt.dropTime)?datetime.valueof(orIt.dropTime.replace('T',' ')):null;
                            orderIt.Source__c = orIt.source_city;
                            orderIt.Service_Provider_Name__c = orIt.service_provider_name;
                            orderIt.Service_Provider_Id__c = orIt.service_provider_id;
                            orderIt.Service_Charge__c = orIt.service_charge;
                            orderIt.Prime_Departure_Time__c =String.isNotBlank(orIt.Prime_DepartureTime)?datetime.valueof(orIt.Prime_DepartureTime.replace('T',' ')):null;
                            orderIt.Boarding_Point__c  = orIt.boarding_point;
                            orderIt.Agent_IP__c = orIt.agent_ip;
                            orderIt.BP_LandMark__c = orIt.bplandmark;
                            orderIt.Primary_Boarding_Point_Time__c = String.isNotBlank(orIt.primary_boarding_time)?datetime.valueof(orIt.primary_boarding_time.replace('T',' ')):null;
                            orderIt.Date_Of_Service__c= String.isNotBlank(orIt.primary_boarding_time)?datetime.valueof(orIt.primary_boarding_time.replace('T',' ')):null;
                            orderIt.Is_Partial_Cancellation_Allowed__c = orIt.Is_partial_cancellation_allowed;
                            orderIt.hasRTCBreakup__c = orIt.has_RTCBreakup;
                            orderIt.Operator_Cancellation_Charges__c = double.valueof(orIt.operator_cancellation_charges);
                            orderIt.Cancellation_Reason__c = orIt.cancellationReason;
                            orderIt.Cancellation_Time__c = String.isNotBlank(orIt.cancellation_time)?datetime.valueof(orIt.cancellation_time.replace('T',' ')):null;
                            orderIt.Refund_Amount__c = orIt.totalRefundAmount;
                            orderIt.MTicket_Enabled__c = orIt.mTicket_enable;
                            orderIt.BP_Address__c = orIt.bp_Address;
                            orderIt.Seat_No__c= orIt.seat_no;
                            orderIt.Cancelled_Seats__c= orIt.cancelledSeats;
                            orderIt.Exception_Refund_Amount__c= orIt.exepRefundAmount;
                            orderIt.Exception_Refund_Type__c= orIt.exepRefundType;
                            orderIt.Exception_Refund_AgentId__c= orIt.exepRefundAgentId;
                            orderIt.Exception_Refund_DateOfInitiation__c= String.isNotBlank(orIt.exepRefundDateOfInitiation)?datetime.valueof(orIt.exepRefundDateOfInitiation.replace('T',' ')):null;
                            orderIt.Service_Provider_Reference_PNR_No__c=orIt.service_provider_reference_no;
                            orderIt.Route_Id__c=orIt.route_id;
                            orderIt.ServiceID__c=orIt.serviceId;
                            orderIt.Item_Type__c = orIt.item_type;
                            orderIt.Service_Start_Time__c= String.isNotBlank(orIt.serviceStartTime)?datetime.valueof(orIt.serviceStartTime.replace('T',' ')):null;
                            orderIt.First_Boarding_Point_Time__c= String.isNotBlank(orIt.firstBoardingPointTime)?datetime.valueof(orIt.firstBoardingPointTime.replace('T',' ')):null;
                            orderIt.B2B_Cancellation_Timestamp__c= String.isNotBlank(orIt.Cancellation_Timestamp)?datetime.valueof(orIt.Cancellation_Timestamp.replace('T',' ')):null;

                           if(String.isNotBlank(orIt.bookedBy)){
                               map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(system.label.B2B_Transaction_Account);
                               if(resObj.containsKey(orIt.bookedBy)){
                                orderIt.Inventory_Type__c=string.valueOf(resObj.get(orIt.bookedBy));
                               } else{
                                orderIt.Inventory_Type__c='Other Partner';
                               }   
                               //orderIt.Inventory_Type__c=string.valueOf(resObj.get(orIt.bookedBy));
                            }

                            
                            orderIt.Total_Fare_Value__c=orIt.totalFare;
                             orderIt.Agent_IP__c  = orIt.pickUpContactNo;

                            if(String.isNotBlank(orIt.destinationCityId))
                                orderIt.Destination_City_Id__c=orIt.destinationCityId;
                            
                            if(String.isNotBlank(orIt.destinationCityId))
                                orderIt.Source_City_Id__c=orIt.sourceCityId;
                            
                            if(String.isNotBlank(orIt.inventory_id))
                                orderIt.Inventory_ID__c = orIt.inventory_id;
                            
                            if(String.isNotBlank(orIt.inventoryItems))
                                orderIt.Seatadditionaldetails__c = String.valueOf(orIt.inventoryItems);
                            
                            
                            if(orIt.reschedulingPolicy !=null){ 
                                orderIt.Rescheduling_Charges__c = string.valueof(orIt.reschedulingPolicy.rescheduling_Charges);
                                orderIt.Window_Time__c =String.isNotBlank(orIt.reschedulingPolicy.windowTime)?datetime.valueof(orIt.reschedulingPolicy.windowTime.replace('T',' ')):null;
                            }
                            
                            orderItems.add(orderIt);
                        }
                        
                    }
                    if(!orderItems.isEmpty())
                    {
                        List<String> lstSuccessOrders = new List<String>();
                        List<String> lstFailedOrders = new List<String>();
                        
                        Database.UpsertResult[] orderItemUpsertResult= Database.upsert(orderItems,Order_Items__c.ID__c,false);
                        system.debug('--orderItems-'+orderItems);
                        
                        for(Integer i=0;i<orderItemUpsertResult.size();i++)
                        {
                            if (orderItemUpsertResult.get(i).isSuccess())
                            {
                                lstSuccessOrders.add(orderItems[i].Name);
                                System.debug('119...');
                                
                            }
                            else 
                            {
                                lstFailedOrders.add(orderItems[i].Name);
                                System.debug('125...');
                                
                                
                            }
                        }
                        System.debug('130...');   
                        resp.orderItemsSuccess = new List<String>();
                        resp.orderItemsFailed= new List<String>();
                        System.debug('133...');
                        resp.orderItemsSuccess.addAll(lstSuccessOrders);
                        System.debug('135...');
                        resp.orderItemsFailed.addAll(lstFailedOrders);
                        System.debug('137...');
                        resp.orderItemsFailedCount =resp.orderItemsFailed.size();
                        resp.orderItemsSuccessCount =resp.orderItemsSuccess.size();
                        if(resp.orderItemsFailedCount>0 && resp.orderItemsSuccessCount>0)
                            resp.finalStatus = 'Partial';
                        else if(resp.orderItemsFailedCount>0)
                            resp.finalStatus = 'Failed';
                        else
                            resp.finalStatus = 'Success';
                        
                    }
                    orderItems.clear();
                }
                
                Attachment att = new Attachment();
                att.name = 'Data-'+String.valueOf(System.Now());
                att.Body = blob.valueof(req.requestBody.toString());
                att.ParentId = Id.valueOf(dbLogSummId);
                database.insert(att);
                
                //missing linking future
                dbl.Payment_Request_Response_Time__c = System.now();
                DataBase.upsert(dbl);
            }
            
        }
        catch(exception e)
        {
            resp = new response();
            resp.exceptionDescription = string.valueof(e);
            resp.exceptionTableName = ProcessExceptionTableName;
            resp.finalStatus = 'Exception';
            //DBLog_Summary__c dbl = new DBLog_Summary__c(id=dbLogSummId);
        }
        
        //insert dbl;
        return resp; 
    } 
    
    public class BookingRequest
    {
        public string type { get; set; }
        public string sentAt { get; set; }
        public string region{get;set;}
        public string syncFrom{get;set;}    
        public List<OrderItem> orderItems { get; set; }
        public BookingRequest()
        {
            orderItems = new List<OrderItem>();
        }
    }
    public class OrderItem 
    {
        public string order_item_reference_no;
        public string business_unit;
        public String boarding_time;
        public string bus_type;
        public string cancellation_policy;
        public string date_of_purchase;
        public string destination_city;
        public string dropping_point;
        public string dropTime;
        public string inventoryItems{ get; set;}
        public string service_provider_reference_no{ get; set;}
        public string source_city{ get; set;}
        public string service_provider_name{ get; set;}
        public string service_charge{ get;set;}
        public string Prime_DepartureTime{ get; set;}
        public string primary_boarding_time{ get; set;}
        public string agent_ip { get; set; }
        public string bplandmark{ get; set; }
        public string boarding_point{ get; set; }
        public boolean is_partial_cancellation_allowed { get; set; }
        public boolean  has_RTCBreakup { get; set; }
        public string totalRefundAmount{ get; set; }
        public String cancellation_time { get; set; }
        public string cancellationReason { get; set; }
        Public string inventory_id{ get; set; }
        public boolean mTicket_enable{ get; set; }
        public string  bp_Address{ get; set; }
        public decimal operator_cancellation_charges { get; set; }
        public string sourceCityId { get; set; }
        public string destinationCityId{ get; set; }
        public string seat_no{ get; set;}
        public string cancelledSeats{ get; set;}
        public string exepRefundAmount{ get; set;}
        public string exepRefundType{ get; set;}
        public string exepRefundAgentId{ get; set;}
        public string exepRefundDateOfInitiation{ get; set;}
        public string service_provider_id;
        public string status;
        public string route_id;
        public string serviceId;
        public decimal totalFare;
        public string pickUpContactNo;
        public string item_type;   
        public string serviceStartTime;
        public string firstBoardingPointTime;
        public string bookedBy;
        public string Cancellation_Timestamp{ get; set; }

        
        public ReschedulingPolicyCls reschedulingPolicy{ get; set; }
        
    }
    
    public class ReschedulingPolicyCls
    {
        public string rescheduling_Charges{ get; set; }
        public string windowTime{ get; set; }  
    }
    
    global class Response
    {
        string exceptionDescription;
        string exceptionTableName;
        string exceptionId;
        list<string> orderItemsSuccess;
        integer orderItemsSuccessCount;
        list<string> orderItemsFailed;
        integer orderItemsFailedCount;
        list<string> orderItemsFailDescription;
        string finalStatus;        
    }      
    global class InventoryWrapper
    {
        public Passenger passenger;
    }   
    public class Passenger
    {
        public string email;
        public string mobile;    
    }
}