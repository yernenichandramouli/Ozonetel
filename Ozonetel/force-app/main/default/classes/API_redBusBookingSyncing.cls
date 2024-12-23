/**
* (c) 2019 RedBus
*
* Name           : API_BusBookingSyncing
* Created Date   : 24 April 2019
* Created By     : Sreenivas M
* Purpose        : Optimized class for syncing the bus booking data
* Existing Class : API_redBus_Booking 
*
**/
@RestResource(urlMapping='/redBus/v1/redBusBookingSyncing/*')
global without sharing class API_redBusBookingSyncing
{
    static string ProcessExceptionId;
    static string ProcessExceptionTableName;    
    static String emailRegex;
    static Map<String,list<string>> mapObjNametoRcvdIds = new Map<String,list<String>>();
    static Map<String,List<Database.UpsertResult>> mapObjtoSavedResults = new Map<String,List<Database.UpsertResult>>();    
    static Set<String> setSuccessOritems;
    static Set<String> setSuccessOrders;
    static map<string,account> OrderItemCustomerMap = new map<string,account>();
    static map<string,string> AddedList = new map<string,string>();
    static Map<String,Account> mapOrderItemsTravelsAccs = new Map<String,Account>();
    static Id dbLogSummId;
    static Map<String,String> mapRecIdToOrderId = new Map<String,String>();
    
    @HttpPost
    global static response doPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string reqBody = req.requestBody.toString();        
        response resp = new response();
        List<Account> orItemcustList = new List<Account>();
        set<string> rescheduleOrderIds=new set<string>();
        setSuccessOritems = new Set<String>(); 
        setSuccessOrders = new Set<String>(); 
        set<string> businessType =new set<string>();
        emailRegex = System.Label.Validate_Email_Regex;
        try
        {
            
            if(string.isNotBlank(reqBody))
            {
                map<string,string> primaryCustomerIds = new map<string,string>();
                set<string> primaryPhoneNumbers = new set<string>();
                set<string> orItemprimaryEmails = new set<string>();
                
                BookingRequest tempbooking = new BookingRequest();
                tempbooking = (BookingRequest)JSON.deserialize(reqBody,BookingRequest.class);
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                dbl.Payment_Request_Sent_Time__c = System.now();
                dbl.Type__c ='Syncing-'+tempbooking.type;
                dbl.redBus_SentAt__c = tempbooking.sentAt;
                dbl.SentAt__c = System.now();
                dbl.Region__c = tempbooking.region;
                dbl.SyncedFrom__c = tempbooking.syncFrom;
                dbl.cZentrix_Type__c = dbl.Region__c;
                
                if(String.isBlank(dbl.cZentrix_Type__c))
                {
                    Decimal timeDiff = decimal.valueof((DateTime.now().getTime() - Datetime.valueOf(tempbooking.sentAt).getTime())/(60*60))/1000;
                    dbl.cZentrix_Type__c = timeDiff>5.0?'INTL':'IND';
                }
                
                Database.SaveResult saveResult = DataBase.insert(dbl,false);
                dbLogSummId = dbl.id;
                
                /*-------------------------------Orders Start--------------------------------*/
                if(tempbooking.orders!=null &&!tempbooking.orders.isEmpty())
                {
                    list<Orders__c> orders = new list<Orders__c>();
                    ProcessExceptionTableName = 'Orders';
                    mapObjNametoRcvdIds.put('Orders',new List<String>{});
                    
                    for(API_redBusBookingSyncing.Order order: tempbooking.orders)
                    {
                        Orders__c ord = new Orders__c();
                        ord.Business_Unit__c = order.business_unit;
                        
                        if(string.isNotBlank(string.valueof(order.id)))
                        {
                            ord.ID__c = string.valueof(order.id);
                            ord.Name = string.valueof(order.id);
                            ProcessExceptionId = ord.ID__c;
                            mapObjNametoRcvdIds.get('Orders').add(ord.ID__c);
                            mapRecIdToOrderId.put(ord.ID__c,ord.ID__c);
                            
                        }
                        ord.Additional_Details__c = order.additional_details;
                        ord.Created_By__c = order.created_by;
                        ord.Creation_Time__c = String.isNotBlank(order.creation_time)? datetime.valueof(order.creation_time.replace('T',' ')):null;
                        ord.Transaction_Source__c = order.transaction_source;
                        ord.Item_Count__c = order.item_count;   
                        ord.Guid__c = order.guid;
                        ord.Selected_Payment_Currency__c =order.selected_payment_currency;
                        ord.status_flag__c = order.status_flag;
                        ord.Creation_Time_Long__c = order.creation_time_long!=null?string.valueof(order.creation_time_long):'';
                        
                        if(order.cust_id!=null)
                            ord.Cust_Id__c = string.valueof(order.cust_id);                            
                        
                        if(String.isNotBlank(order.cust_details))
                            ord.Cust_Details__c = order.cust_details;
                        
                        orders.add(ord);
                    }
                    
                    if(!orders.isEmpty())
                    {
                        Database.UpsertResult[] orderUpsertResult = Database.upsert(orders,Orders__c.ID__c,false);
                        mapObjtoSavedResults.put('Orders',orderUpsertResult);
                        resp.ordersFailedCount =0;
                        orders.clear();
                        dbl.Orders_Received_Data_Ids__c = string.join(mapObjNametoRcvdIds.get('Orders'),',');
                    }
                    
                    
                }
                
                /*-------------------------------Orders End-----------------------------------*/
                
                /*--------------------------OrderItems Start-------------------------------------------*/                    
                
                if(tempbooking.orderItems!=null && !tempbooking.orderItems.isEmpty())
                {
                    list<Order_Items__c> orderItems = new list<Order_Items__c>();
                    list<Order_Items__c> couponOrderItems = new list<Order_Items__c>();
                    list<WFT_GFT__c> listWFTGFT = new list<WFT_GFT__c>();
                    ProcessExceptionTableName = 'orderItems';
                    mapObjNametoRcvdIds.put('OrderItems',new List<String>{});
                    
                    map<String,Transaction_Status_Category__c> mapTransStatus = new Map<String,Transaction_Status_Category__c>();
                    
                    for(Transaction_Status_Category__c tsc : Transaction_Status_Category__c.getAll().Values())
                        mapTransStatus.put(tsc.Status__c,tsc);
                    
                    for(API_redBusBookingSyncing.OrderItem  orIt: tempbooking.orderItems)
                    {
                        if(string.isNotBlank(string.valueof(orIt.id)))
                        {
                            Order_Items__c orderIt = new Order_Items__c();
                            orderIt.ID__c = string.valueof(orIt.id);
                            orderIt.Name = string.valueof(orIt.id);
                            ProcessExceptionId = orderIt.ID__c;
                            mapObjNametoRcvdIds.get('OrderItems').add(orderIt.ID__c);
                            
                            if(string.isNotBlank(orIt.item_type) && ('BUS'.equalsIgnoreCase(orIt.item_type) || 'Coupon'.equalsIgnoreCase(orIt.item_type) ||'RAILS'.equalsIgnoreCase(orIt.item_type) ||'HOTEL'.equalsIgnoreCase(orIt.item_type) ))
                            {
                                orderIt.Item_Type__c = orIt.item_type;                               
                                if(String.isNotBlank(string.valueof(orIt.order_id)))
                                {
                                    orderIt.Order_Id__c = string.valueof(orIt.order_id);
                                    
                                    mapRecIdToOrderId.put(orderIt.ID__c,orderIt.Order_Id__c);
                                    if(dbl.Type__c.containsIgnoreCase('BOOKING'))
                                    {
                                        Orders__c ords = new Orders__c();
                                        ords.id__c =  orderIt.Order_Id__c;
                                        orderIt.Order_Name__r = ords;
                                    }
                                }
                            }
                            
                            if(string.isNotBlank(orIt.reschedulingFor)){
                                rescheduleOrderIds.add(string.valueof(orIt.order_id));
                            }
                            businessType.add(orIt.item_type);
                            orderIt.HFT__c=orIt.hft;
                            orderIt.Business_Unit__c = orIt.business_unit;
                            orderIt.Additional_Details__c = orIt.additional_details;                            
                            orderIt.Created_By__c = orIt.created_by;
                            orderIt.Creation_Time__c = String.isNotBlank(orIt.creation_time)?datetime.valueof(orIt.creation_time.replace('T',' ')):null;
                            orderIt.Old_Order_Item_Reference_No__c = orIt.OldTin;
                            orderIt.Rescheduling_For__c = orIt.reschedulingFor;
                            orderIt.Cancellation_Reason__c = orIt.cancellationReason;
                            orderIt.Transaction_Source__c = orIt.transaction_source;
                            orderIt.Updated_By__c = orIt.updated_by;
                            orderIt.Version__c = orIt.version;
                            orderIt.Amount_Recieved_Currency__c = orIt.amount_recieved_currency;
                            orderIt.Business_Unit_Conversion_Currency__c = orIt.business_unit_conversion_currency;
                            orderIt.Cancellation_Time__c = String.isNotBlank(orIt.cancellation_time)?datetime.valueof(orIt.cancellation_time.replace('T',' ')):null;
                            orderIt.Child_Purchase_Item_ID__c = orIt.child_purchase_item_id;
                            orderIt.Date_Of_Service__c = String.isNotBlank(orIt.date_of_service)?datetime.valueof(orIt.date_of_service.replace('T',' ')):null; 
                            orderIt.Discount_Currency__c = orIt.discount_currency;
                            orderIt.Inventory_ID__c = orIt.inventory_id;
                            orderIt.ServiceID__c = orIt.serviceId;
                            orderIt.Purchase_Item_Currency__c = orIt.purchase_item_currency;
                            orderIt.Service_Provider_Name__c = orIt.service_provider_name;
                            orderIt.Service_Provider_Id__c = orIt.service_provider_id;
                            orderIt.Parent_Purchase_Item_ID__c = orIt.parent_purchase_item_id;
                            orderIt.Payment_Currency__c = orIt.payment_currency;
                            orderIt.status__c = orIt.status;
                            orderIt.Sub_Item_Count__c = orIt.sub_item_count;
                            orderIt.Tentative_Key__c = orIt.tentative_key;
                            orderIt.Total_Fare_Currency__c = orIt.total_fare_currency;
                            orderIt.Total_Fare_Value__c = orIt.total_fare_value;
                            orderIt.Total_Tax_Currency__c = orIt.total_tax_currency;
                            orderIt.Insurance_Charges__c = orIt.insuranceCharge;
                            orderIt.Amenities__c = orIt.amenities;
                            orderIt.Package_Id__c= orIt.pkgId;
                            orderIt.Package_Name__c= orIt.pkgName;
                            orderIt.Receivable_Amount_Currency__c = orIt.receivable_amount_currency;
                            orderIt.View_Details__c = orIt.view_details;
                            orderIt.Date_Of_Purchase__c = String.isNotBlank(orIt.date_of_purchase)?datetime.valueof(orIt.date_of_purchase.replace('T',' ')):null;
                            orderIt.Guid__c = orIt.guid;
                            orderIt.Tentative_Details__c = orIt.tentative_details;                              
                            orderIt.Client_Ip__c = orIt.client_ip;
                            orderIt.Cancellation_Policy__c = orIt.cancellation_policy;
                            orderIt.Agent_IP__c = orIt.agent_ip;                               
                            orderIt.is_Exceptional_BusCancellation__c= orIt.isExceptionalBusCancellation;
                            orderIt.isMIM_Booking__c= orIt.isMIMBooking;
                            orderIt.isReschedulable__c= orIt.isReschedulable;
                            orderIt.Boarding_Point_Id__c= orIt.boardingPointId;
                            
                            orderIt.Primary_Proof_Id__c= orIt.primaryProofId;
                            orderIt.Primary_Proof_Type__c= orIt.primaryProofType;
                            orderIt.Primary_Proof_Name__c= orIt.primaryProofName;  
                            orderIt.live_Operator_Force_Cancel_Status__c = orIt.live_operator_force_cancel_status;
                            orderIt.Flag__c = orIt.flag;
                            orderIt.Account_Holder_Name__c = orIt.accountHolderName;
                            orderIt.Bank_Account_Number__c = orIt.bankAccountNumber;
                            orderIt.Bank_Name__c = orIt.bankName;
                            orderIt.Insurance_Provider__c = orIt.insuranceProviderName;
                            orderIt.Payment_Details__c = orIt.paymentDetails;
                            orderIt.OrderUuid__c = orIt.order_uuid;
                            orderIt.Dropping_Time__c = String.isNotBlank(orIt.droppingTime)?datetime.valueof(orIt.droppingTime.replace('T',' ')):null;
                            orderIt.BP_LandMark__c = orIt.bplandmark;
                            orderIt.Boarding_Point__c  = orIt.boarding_point;
                            orderIt.Bus_Type__c = orIt.bus_type;
                            orderIt.Destination__c = orIt.destination_city;
                            orderIt.Source__c = orIt.source_city;
                            orderIt.Dropping_Point__c = orIt.dropping_point;
                            orderIt.Seat_No__c = orIt.seat_no;
                            orderIt.Boarding_Time__c = String.isNotBlank(orIt.boarding_time)?datetime.valueof(orIt.boarding_time.replace('T',' ')):null;
                            orderIt.Primary_Boarding_Point_Time__c = String.isNotBlank(orIt.primary_boarding_time)?datetime.valueof(orIt.primary_boarding_time.replace('T',' ')):null;
                            orderIt.Force_Cancelled__c = orIt.force_cancelled;
                            orderIt.Ticket_Confirmed_Time__c = String.isNotBlank(orIt.confirm_time)?datetime.valueof(orIt.confirm_time.replace('T',' ')):null;
                            orderIt.Exp_Time__c = String.isNotBlank(orIt.exp_time)?datetime.valueof(orIt.exp_time.replace('T',' ')):null;
                            orderIt.Is_Partial_Cancellation_Allowed__c = orIt.Is_partial_cancellation_allowed;
                            orderIt.Seatadditionaldetails__c = orIt.seatadditionalDetails;
                            orderIt.Inventory_Type__c = orIt.inventory_type;
                            orderIt.Route_Id__c = orIt.route_id;
                            orderIt.Related_Id__c = orIt.couponId;
                            orderIt.Related_Uuid__c = orIt.couponUUid;
                            orderIt.Destination_City_Id__c= orIt.destLocationId;
                            orderIt.Source_City_Id__c= orIt.srcLocationId;
                            orderIt.Rebooked_To__c= orIt.rebookedTo;
                            orderIt.Rebooking_For__c= orIt.rebookingFor;
                            orderIt.Rebook_Agent_Id__c= orIt.rebookAgentId;
                            orderIt.Refunded_By__c= orIt.refundedBy;
                            orderIt.Cancellation_Type__c = orIt.cancellationType;
                            orderIt.Bpass_Status__c= orIt.bPassStatus;
                            orderIt.Bpass_ProviderName__c= orIt.bPassProviderName;
                            orderIt.Bpass_Charge__c= orIt.bPassCharge;
                            orderIt.Assurance_Description__c=orIt.assurDescription;
                            orderIt.Assurance_Category__c=orIt.assurCategory;
                            orderIt.Assurance_FundedBy__c=orIt.assurFundedBy;
                            orderIt.Assurance_RefundShare__c=orIt.assurRefundShare;
                            orderIt.Assurance_Amount_PaidBy_Customer__c=orIt.assurAmountPaidByCustomer;
                            orderIt.Travel_Protection_Insurance__c=orIt.InsuranceDetails;
                            orderIt.isAggregator__c=string.Valueof(orIt.isAggregator);
                            orderIt.Customer_Preffered_Lang__c=orIt.customerPrefferedLang;
                            orderIt.StreakId__c=orIt.streakId;
                            orderIt.StreakStatus__c=orIt.streakStatus;
                            orderIt.Vendor_PNR__c=orIt.vendorPnr;

                            //Connected Services Start 
                            orderIt.Umbrella_TIN__c =orIt.connectedTIN;
                            orderIt.Connected_Items__c = orIt.connectedItems;
                            orderIt.Umbrella_UUID__c = orIt.connectedUUID;
                            if(orIt.LayoverData!=null){
                                orderIt.Layover_Duration_min__c = orIt.LayoverData.journeyTime;
                                orderIt.has_Layover_Transport__c = orIt.LayoverData.hasTransport;
                                orderIt.Layover_BP_Time__c = String.isNotBlank(orIt.LayoverData.boardingTime)?datetime.valueof(orIt.LayoverData.boardingTime.replace('T',' ')).addMinutes(330):null;
                                orderIt.Layover_DP_Time__c = String.isNotBlank(orIt.LayoverData.droppingTime)?datetime.valueof(orIt.LayoverData.droppingTime.replace('T',' ')).addMinutes(330):null;
                                orderIt.Layover_DP_Address__c = orIt.LayoverData.LayoverDp.address;
                                orderIt.Layover_BP_Address__c = orIt.LayoverData.LayoverBp.address;
                            }
                            //Connected Services end

                            
                           if(string.isNotBlank(string.valueOf(string.valueOf(orIt.streakConsentPending)))){
                                orderIt.StreakConsentPending__c=boolean.valueof(orIt.streakConsentPending);
                            }
                            
                            if(string.isNotBlank(string.valueOf(string.valueOf(orIt.is_return)))){
                                orderIt.isReturnTrip__c=boolean.valueof(orIt.is_return);
                            }
                            
                            if(string.isNotBlank(string.valueOf(string.valueOf(orIt.isCancellableFromApi)))){
                                orderIt.isCancellableFromApi__c=boolean.valueof(orIt.isCancellableFromApi);
                            }
                               
                                                        
                            if(String.isNotBlank(orIt.boardingTz) && String.isNotBlank(orderIt.Business_Unit__c) && orIt.boardingTz.startsWithIgnoreCase('UTC') && ('REDBUS_COM'.equalsIgnoreCase(orderIt.Business_Unit__c) || 'REDBUS_ID'.equalsIgnoreCase(orderIt.Business_Unit__c) || 'REDBUS_VN'.equalsIgnoreCase(orderIt.Business_Unit__c) || 'REDBUS_KH'.equalsIgnoreCase(orderIt.Business_Unit__c)))
                            {
                            orderIt.Conversion_TimeZone__c = orIt.boardingTz;
                            List<String> hoursMins =orIt.boardingTz.right(5).split(':');
                            String minsDifVal =String.valueOf(orIt.boardingTz.subString(3,4))+String.valueOf((Integer.valueOf(hoursMins[0])*60)+Integer.valueOf(hoursMins[1]));
                            orderIt.Boarding_Time_Local__c     = ConvertUTCStrtoLocalTimeStr(orIt.boarding_time,minsDifVal);
                           
                            if(!String.isBlank(orIt.droppingTz) && orIt.droppingTz.startsWithIgnoreCase('UTC')){
                                List<String> DroppinghoursMins =orIt.droppingTz.right(5).split(':');
                                String droppingminsDifVal =String.valueOf(orIt.droppingTz.subString(3,4))+String.valueOf((Integer.valueOf(DroppinghoursMins[0])*60)+Integer.valueOf(DroppinghoursMins[1]));
                                orderIt.Dropping_Time_Local__c     = ConvertUTCStrtoLocalTimeStr(orIt.droppingTime,droppingminsDifVal);
                            }else{
                                orderIt.Dropping_Time_Local__c     = ConvertUTCStrtoLocalTimeStr(orIt.droppingTime,minsDifVal);
                            }
                            orderIt.Dropping_Time_Local__c     = ConvertUTCStrtoLocalTimeStr(orIt.droppingTime,minsDifVal);
                            orderIt.Cancellation_Time_Local__c = ConvertUTCStrtoLocalTimeStr(orIt.cancellation_time,minsDifVal);
                            orderIt.Date_of_Issue_Local__c     = ConvertUTCStrtoLocalTimeStr(orIt.date_of_purchase,minsDifVal);
                            orderIt.Date_of_Journey_Local__c   = ConvertUTCStrtoLocalTimeStr(orIt.date_of_service,minsDifVal);

                            }

                            // if(orIt.isShifted!=null){
                            //     orderIt.isShifted__c = orIt.isShifted;
                            // }

                            // if(orIt.historicalDetails!=null){
                            //     orderIt.Historic_Details__c = orIt.historicalDetails;
                            // }
                            
                            if(orIt.isMticketEnabled!=null){
                                orderIt.Accept_M_Ticket__c= orIt.isMticketEnabled;    
                            }
                            if(orIt.isGSTInSelected!=null && orIt.isGSTInSelected){
                                orderIt.Booking_type__c='Business Trip';
                            }else{
                                orderIt.Booking_type__c='Personal Trip';
                            }
                            
                            if(String.isNotBlank(orderIt.Related_Id__c))
                            {
                                orderIt.Related_To__r = new Order_Items__c(ID__c=orderIt.Related_Id__c);
                            }
                            
                            orderIt.Return_RouteId__c=orIt.retRouteId;
                            
                            orderIt.Return_DroppingTime__c= String.isNotBlank(orIt.retDroppingTime)?datetime.valueof(orIt.retDroppingTime.replace('T',' ')):null;
                            orderIt.Return_BoardingTime__c= String.isNotBlank(orIt.retBoardingTime)?datetime.valueof(orIt.retBoardingTime.replace('T',' ')):null;
                            orderIt.Return_PrimaryBoardingTime__c= String.isNotBlank(orIt.retPrimaryBoardingTime)?datetime.valueof(orIt.retPrimaryBoardingTime.replace('T',' ')):null;
                            
                            orderIt.Return_GateOpenTime__c=orIt.retGateOpenTime;
                            orderIt.Return_GateCloseTime__c= orIt.retGateCloseTime;
                            orderIt.Gate_OpenTime__c= orIt.gateOpenTime;
                            orderIt.Gate_ClosedTime__c= orIt.gateClosedTime;
                            orderIt.Assurance_Service__c=orIt.assuranceService;
                            orderIt.Primary_Boarding_Time_Local__c= String.isNotBlank(orIt.PrimaryBoardingTimeLocal)?datetime.valueof(orIt.PrimaryBoardingTimeLocal.replace('T',' ')):null;
                            orderIt.Service_Notes__c=orIt.serviceNotes;
                            orderIt.Country__c=orIt.Country;
                            orderIt.Total_Order_value__c=orIt.total_Order_value;
                            orderIt.No_Of_BusPass_Transactions__c=orIt.noOfTransactions;
                            orderIt.Availed_Count_Buspass__c=orIt.availedCount;
                            orderIt.Discard_Reason__c=orIt.discardReason;
                            orderIt.Is_Pay_at_Operator__c=orIt.isPayAtOperatorBooking;
                            orderIt.Date_Of_BusPass_Exipry__c = String.isNotBlank(orIt.dateOfRealization)?datetime.valueof(orIt.dateOfRealization.replace('T',' ')):null;
                            

                            orderIt.Operator_Features__c =string.valueOf(orIt.operatorFeature);
                            if(orIt.operatorFeature!=null && orIt.operatorFeature.containsKey('4'))
                                orderIt.Bus_Vaccinated__c=true;
                            
                            if(mapTransStatus.containsKey(orderIt.Status__c))
                            {
                                orderIt.Transaction_Status__c = mapTransStatus.get(orderIt.Status__c).Transaction_Status__c;
                                orderIt.Transaction_Status_WFT_GFT__c = mapTransStatus.get(orderIt.Status__c).Transaction_FT_Status__c;
                                
                                if(orderIt.Transaction_Status__c.startsWithIgnoreCase('Ticket Cancelled'))
                                    orderIt.Transaction_Status__c = 'Ticket Cancelled'+' - '+orderIt.Refund_Status__c;
                                
                                if(String.IsNotBlank(orderIt.Service_Provider_Reference_No__c) && String.IsBlank(orderIt.Order_Item_Reference_No__c) && 'BUS'.equalsIgnoreCase(orderIt.Item_Type__c))
                                {
                                    orderIt.Transaction_Status__c = 'Misbooking - PNR generated but ticket not confirmed';
                                    orderIt.Transaction_Status_WFT_GFT__c = 'GFT';
                                }
                            }

                            if(string.isNotBlank(string.valueOf(orIt.exceptionalRefundCount))){
                                orderIt.Exceptional_Refund_Count__c= Integer.valueof(orIt.exceptionalRefundCount);
                            }

                            if(String.isNotBlank(string.valueOf(orIt.boardingPointAddress))){
                                orderIt.Complete_BP_Address__c=string.valueof(orIt.boardingPointAddress);
                            }

                            if(string.isNotBlank(string.valueOf(string.valueOf(orIt.isnewuser)))){
                                orderIt.IsNewUser__c=boolean.valueof(orIt.isnewuser);
                            }
                            
                            if(String.isNotBlank(orIt.order_item_reference_no))
                                orderIt.Order_Item_Reference_No__c = orIt.order_item_reference_no;
                            
                            if(String.isNotBlank(orIt.vehicleNumber))
                                orderIt.Vehicle_number__c = orIt.vehicleNumber;
                            
                            if(orIt.receivable_amount_value!=null)
                                orderIt.Receivable_Amount_Value__c = double.valueof(orIt.receivable_amount_value);
                            
                            if(orIt.transaction_charge!=null)
                                orderIt.Transaction_Charge__c = double.valueof(orIt.transaction_charge);
                            
                            if(orIt.total_fare_paid_to_operator!=null)
                                orderIt.Total_Fare_Paid_To_Operator__c = double.valueof(orIt.total_fare_paid_to_operator);
                            
                            if(orIt.operator_cancellation_charges!=null)
                                orderIt.Operator_Cancellation_Charges__c = double.valueof(orIt.operator_cancellation_charges);
                            
                            if(orIt.creation_time_long!=null)
                                orderIt.Creation_Time_Long__c = string.valueof(orIt.creation_time_long);
                            
                            if(orIt.date_of_service_long!=null)
                                orderIt.Date_Of_Service_Long__c = string.valueof(orIt.date_of_service_long);
                            
                            if(orIt.conversionRate!=null)
                                orderIt.ConversionRate__c = double.valueof(orIt.conversionRate);                                    
                            
                            if(orIt.rb_user_Id!=null)
                                orderIt.Rb_User_ID__c = String.valueof(orIt.rb_user_Id);
                            
                            if(orIt.rescheduledTo!=null && !orIt.rescheduledTo.isEmpty())
                                orderIt.RescheduledTo__c = String.valueOf(orIt.rescheduledTo);
                            
                            if(orIt.identityProofs!=null && !orIt.identityProofs.isEmpty())
                                orderIt.Identity_Proofs__c = String.valueOf(orIt.identityProofs);                                                                 
                            
                            if(orIt.boardingPassItems!=null && !orIt.boardingPassItems.isEmpty())
                            {
                                list<BoardingPassItem> lstbp= orIt.boardingPassItems; 
                                system.debug('--lstbp---'+lstbp);
                                orderIt.Bus_Pass_Vendor_Status__c=String.valueOf(lstbp[0].VendorStatus); 
                            }   
                            
                            if(string.isNotBlank(orderIt.Seatadditionaldetails__c))
                            {
                                map<string,object> seatdetailsInfo = (map<string,object>)JSON.deserializeUntyped(orderIt.Seatadditionaldetails__c);
                                if('INTL'.equalsIgnoreCase(dbl.cZentrix_Type__c)){
                                    if(seatdetailsInfo.KeySet().contains('31') && string.isNotBlank(string.valueof(seatdetailsInfo.get('31'))))
                                        orderIt.RUC_Address__c = string.valueof(seatdetailsInfo.get('31'));
                                    
                                    if(seatdetailsInfo.KeySet().contains('30') && String.isNotBlank(String.valueOf(seatdetailsInfo.get('30'))))
                                        orderIt.RUC_Reason__c = string.valueof(seatdetailsInfo.get('30'));
                                    
                                    if(seatdetailsInfo.KeySet().contains('29') && string.isNotBlank(string.valueof(seatdetailsInfo.get('29'))))
                                        orderIt.RUC_Number__c = string.valueof(seatdetailsInfo.get('29'));
                                    
                                }  
                                
                                if(seatdetailsInfo.KeySet().contains('109') && string.isNotBlank(string.valueof(seatdetailsInfo.get('109'))))
                                    orderIt.GST_No__c= string.valueof(seatdetailsInfo.get('109'));
                            }
                            
                            
                            
                            if(orIt.primary_passenger_id!=null)
                            {
                                orderIt.Primary_Passenger_Id__c = string.valueof(orIt.primary_passenger_id);
                                if(string.isNotBlank(orderIt.id__c))
                                    primaryCustomerIds.put(orderIt.Primary_Passenger_Id__c,orderIt.Primary_Passenger_Id__c);
                                
                            }
                            
                            if(String.isNotBlank(orIt.service_provider_reference_no))
                            {
                                orderIt.Service_Provider_Reference_No__c = orIt.service_provider_reference_no;
                                if(string.valueof(orIt.service_provider_reference_no).length()>255)
                                    orderIt.Service_Provider_Reference_PNR_No__c = string.valueof(orIt.service_provider_reference_no).substring(0,255);
                                else
                                    orderIt.Service_Provider_Reference_PNR_No__c = orIt.service_provider_reference_no;
                                
                            }
                            
                            if(String.isNotBlank(orIt.email))
                            {
                                if(string.valueof(orIt.email).length()<255)
                                    orderIt.Email_Copy__c = orIt.email;
                                else
                                    orderIt.Email_Copy__c = string.valueof(orIt.email).substring(0,255);
                                
                                if(validateEmail(orIt.email))
                                    orderIt.Email__c = orIt.email;
                                
                            }
                            
                            if(String.isNotBlank(orIt.mobile))
                            {
                                orderIt.Mobile__c = orIt.mobile;
                                
                                account acc = new account();
                                acc.AccountSource = 'OrderItem';
                                acc.lastname = orderIt.Mobile__c;
                                acc.PersonMobilePhone = orderIt.Mobile__c;
                                
                                If(String.isNotBlank(orderIt.Business_Unit__c) && BusinessUnitMapping__c.getValues(orderIt.Business_Unit__c)!=null)
                                    acc.CountryCode__c = String.valueOf(BusinessUnitMapping__c.getValues(orderIt.Business_Unit__c).Country__c);
                                
                                primaryPhoneNumbers.add(acc.PersonMobilePhone);
                                
                                if(String.isNotBlank(orIt.email))
                                {
                                    acc.Email_Copy__c = orderIt.Email_Copy__c;
                                    acc.PersonEmail = orderIt.Email__c;
                                    orItemprimaryEmails.add(acc.PersonEmail);
                                    
                                }
                                
                                mapOrderItemsTravelsAccs.put(acc.PersonMobilePhone,acc);
                                
                            }
                            
                            if('RAILS'.equalsIgnoreCase(orderIt.Item_Type__c))
                            {
                                dbl.Send_To__c  ='Rails';
                                orderIt.RecordTypeId=Schema.getGlobalDescribe().get('Order_Items__c').getDescribe().getRecordTypeInfosByName().get('Rails').getRecordTypeId();
                                orderIt.Service_Provider_Reference_PNR_No__c=orIt.pnr;
                                orderIt.Journey_Details__c=string.valueOf(orIt.journeyDetails);
                                orderIt.Traveller_Details__c=string.valueOf(orIt.subOrderItems);
                                orderIt.Train_Details__c=string.valueOf(orIt.trainDetails);
                                orderIt.Customer_Price_Breakup__c=string.valueOf(orIt.customerPriceBreakUp);
                                orderIt.No_Of_Adults__c=string.valueOf(orIt.numberOfAdults);
                                orderIt.No_Of_Children__c=string.valueOf(orIt.numberOfChildren);
                                orderIt.Reservation_Id__c=orIt.reservationId;
                                orderIt.Date_of_Realization__c= String.isNotBlank(orIt.dateof_Realization)?datetime.valueof(orIt.dateof_Realization.replace('T',' ')):null;
                                
                                JourneyDetails jdObj = new JourneyDetails();
                                jdObj = (JourneyDetails)JSON.deserialize(orIt.journeyDetails,JourneyDetails.class);
                                orderIt.Boarding_Point_Id__c=jdObj.boardingPointDetails.stationCode; 
                                orderIt.Boarding_Point__c  =jdObj.boardingPointDetails.stationName;
                                orderIt.Boarding_Time__c =String.isNotBlank(jdObj.boardingPointDetails.departureTime)?datetime.valueof(jdObj.boardingPointDetails.departureTime.replace('T',' ')).addMinutes(330):null;
                                orderIt.Primary_Boarding_Point_Time__c =String.isNotBlank(jdObj.boardingPointDetails.departureTime)?datetime.valueof(jdObj.boardingPointDetails.departureTime.replace('T',' ')).addMinutes(330):null;
                                //orderIt.Primary_Boarding_Point_Time__c=String.isNotBlank(jdObj.boardingPointDetails.arrivalTime)?datetime.valueof(jdObj.boardingPointDetails.arrivalTime.replace('T',' ')):null;
                                orderIt.Source__c =jdObj.boardingPointDetails.boardingLocation;
                                
                                orderIt.Destination__c =jdObj.droppingPointDetails.destLocation;
                                orderIt.Dropping_Point_Id__c=jdObj.droppingPointDetails.stationCode;
                                orderIt.Dropping_Point__c =jdObj.droppingPointDetails.stationName;
                                orderIt.Dropping_Time__c = String.isNotBlank(jdObj.droppingPointDetails.arrivalTime)?datetime.valueof(jdObj.droppingPointDetails.arrivalTime.replace('T',' ')).addMinutes(330):null;
                                orderIt.Booking_type__c = orIt.bookingType==null?'':String.valueOf(orIt.bookingType);
                                System.debug('Booking_type__c...'+orderIt.Booking_type__c);
                            }
                            
                            if ('HOTEL'.equalsIgnoreCase(orderIt.Item_Type__c)) {
        						orderIt.RecordTypeId=Schema.getGlobalDescribe().get('Order_Items__c').getDescribe().getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
                                orderIt.Hotel_Name__c= orIt.hotelName;
                                orderIt.Hotel_Booking_Id__c = orIt.hotelId;
								orderIt.Date_Of_Service__c= String.isNotBlank(orIt.checkinTime)?datetime.valueof(orIt.checkinTime):null;
                                orderIt.Date_Of_Service_Long__c= String.isNotBlank(orIt.checkinTime)?orIt.checkinTime:null;
                                orderIt.Date_of_Realization__c= String.isNotBlank(orIt.checkoutTime)?datetime.valueof(orIt.checkoutTime):null;
                                orderIt.Check_In__c= String.isNotBlank(orIt.checkinTime)?datetime.valueof(orIt.checkinTime):null;
                                orderIt.Check_Out__c= String.isNotBlank(orIt.checkoutTime)?datetime.valueof(orIt.checkoutTime):null;
								orderIt.No_Of_Adults__c=orIt.numberOfAdults;
                                orderIt.No_Of_Children__c=orIt.numberOfChildren;
                                orderIt.No_Of_Rooms__c=orIt.totalRoomCount;
                                orderIt.BP_Address__c=orIt.boardingPointAddress;
                                orderIt.Service_Provider_Reference_PNR_No__c=orIt.pnr;
                                orderIt.Package_Id__c=orIt.bookingId;
                            }
                            
                            if('Coupon'.equalsIgnoreCase(orderIt.Item_Type__c))
                            {
                                orderIt.RecordTypeId=Schema.getGlobalDescribe().get('Order_Items__c').getDescribe().getRecordTypeInfosByName().get('Coupon').getRecordTypeId();
                                orderIt.Eligible_Bus_Operators__c = orIt.eligibleBOs;
                                orderIt.Male_Count__c= orIt.malecount;
                                orderIt.Female_Count__c= orIt.femalecount;                                  
                                orderIt.Date_of_Realization__c= String.isNotBlank(orIt.dateof_Realization)?datetime.valueof(orIt.dateof_Realization.replace('T',' ')):null;
                                
                                if(String.isNotBlank(orderIt.Transaction_Status__c) && orderIt.Transaction_Status__c.startsWithIgnoreCase('Ticket Cancelled'))
                                {   
                                    orderIt.Transaction_Status__c = 'Coupon Cancelled'+' - '+orderIt.Refund_Status__c;
                                    if(String.isNotBlank(orderIt.Cancellation_Reason__c) && orderIt.Cancellation_Reason__c.contains('REDEMPTION'))
                                        orderIt.Transaction_Status__c = 'Coupon Redeemed'+' - '+orderIt.Refund_Status__c;
                                    
                                }
                                couponOrderItems.add(orderIt);
                            }
                            else
                            {
                                orderItems.add(orderIt);
                            }
                            
                        }
                    }
                    
                    
                    if(!couponOrderItems.isEmpty())
                    {
                        Database.UpsertResult[] couponOrderItemUpsertResult = Database.upsert(couponOrderItems,Order_Items__c.ID__c,false);
                        resp.orderItemsFailedCount =0;
                        mapObjtoSavedResults.put('OrderItems',couponOrderItemUpsertResult);
                        
                    }
                    
                    if(!orderItems.isEmpty())
                    {
                        Database.UpsertResult[] orderItemUpsertResult = Database.upsert(orderItems,Order_Items__c.ID__c,false);
                        resp.orderItemsFailedCount =0;
                        if(mapObjtoSavedResults.containsKey('OrderItems'))
                            mapObjtoSavedResults.get('OrderItems').addAll(orderItemUpsertResult);
                        else
                            mapObjtoSavedResults.put('OrderItems',orderItemUpsertResult);
                        
                    }
                    orderItems.clear();
                    couponOrderItems.clear();
                }
                
                /*--------------------------OrderItems End---------------------------------------------*/
                
                /*--------------------------PaymentItems Start---------------------------------------------*/
                if(tempbooking.paymentItems!=null && !tempbooking.paymentItems.isEmpty())
                {
                    list<Payment_Items__c> PaymentItems = new list<Payment_Items__c>();
                    list<WFT_GFT_Payment__c> listWFTGFTPayments = new list<WFT_GFT_Payment__c>();
                    ProcessExceptionTableName = 'paymentItems';
                    mapObjNametoRcvdIds.put('PaymentItems',new List<String>{});
                    
                    for(API_redBusBookingSyncing.PaymentItem  PayIt: tempbooking.paymentItems )
                    {
                        if(string.isNotBlank(string.valueof(PayIt.id)))
                        {
                            Payment_Items__c PayItem = new Payment_Items__c();
                            PayItem.ID__c = String.valueof(PayIt.id);
                            PayItem.Name = PayItem.ID__c;
                            ProcessExceptionId = PayItem.ID__c;
                            mapObjNametoRcvdIds.get('PaymentItems').add(PayItem.ID__c);
                            string BusinessUnit;
                            
                            if(String.isNotBlank(string.valueof(PayIt.order_id)))
                            {
                                PayItem.Order_ID__c = string.valueof(PayIt.order_id);
                                Orders__c ords = new Orders__c();
                                ords.id__c =  PayItem.Order_ID__c;
                                PayItem.Order_Name__r = ords;
                                mapRecIdToOrderId.put(PayItem.ID__c,PayItem.Order_ID__c);
                            }
                            
                            PayItem.Payment_Gateway_Type__c = PayIt.pgName;
                            PayItem.Creation_Time__c = String.isNotBlank(PayIt.creation_time)?datetime.valueof(PayIt.creation_time.replace('T',' ')):null;
                            PayItem.Updated_By__c = PayIt.updated_by;
                            PayItem.Updated_Time__c = String.isNotBlank(PayIt.updated_time)?datetime.valueof(PayIt.updated_time.replace('T',' ')):null;
                            PayItem.Business_Unit_Currency__c = PayIt.business_unit_currency;
                            PayItem.Payment_Status__c = PayIt.payment_status;
                            PayItem.Is_Complete__c = PayIt.is_complete;
                            PayItem.PG_Type__c = PayIt.pgtype;
                            PayItem.Bank_Account_Number__c = PayIt.bankAccountNumber;
                            PayItem.Account_Holder_Name__c = PayIt.accountHolderName;
                            PayItem.Bank_Name__c = PayIt.bankName;
                            PayItem.Payment_System__c = PayIt.payment_system;
                            PayItem.Payment_System_Ref_No__c = PayIt.payment_system_ref_no;
                            PayItem.Settled_Currency__c = PayIt.settled_currency;
                            PayItem.Guid__c = PayIt.guid;
                            PayItem.Amount_Payable_Currency__c = PayIt.amount_payable_currency;
                            
                            if('ONLINE'.equalsIgnoreCase(PayItem.Payment_System__c))
                                PayItem.PG_Reference_ID__c = PayItem.Payment_System_Ref_No__c;
                            
                            if(PayIt.payment_type!=null)
                                PayItem.Payment_Type__c = String.valueof(PayIt.payment_type);
                            
                            if(PayIt.business_unit_value!=null)
                                PayItem.Business_Unit_Value__c = double.valueof(PayIt.business_unit_value);
                            
                            if(PayIt.amount_payable_value!=null)
                                PayItem.Amount_Payable_Value__c = double.valueof(PayIt.amount_payable_value);
                            
                            if(PayIt.commission!=null)
                                PayItem.commission__c = double.valueof(PayIt.commission);
                            
                            PaymentItems.add(PayItem);
                        }
                    }
                    if(!PaymentItems.isEmpty())
                    {
                        Database.UpsertResult[] paymentItemUpsertResult = Database.upsert(PaymentItems,Payment_Items__c.ID__c,false);
                        resp.paymentItemsFailedCount =0;
                        mapObjtoSavedResults.put('PaymentItems',paymentItemUpsertResult);
                    }
                    PaymentItems.clear();
                }
                
                /*--------------------------PaymentItems End-----------------------------------------------*/
                
                /*--------------------------BusOrderItemDetails Start-------------------------------------*/
                
                if(Boolean.valueOf(System.Label.EnableBusOrderItems) && tempbooking.busOrderItemDetails!=null && !tempbooking.busOrderItemDetails.isEmpty())
                {
                    list<Bus_Order_Item_Details__c> BusOrderItemDetails = new list<Bus_Order_Item_Details__c>();
                    ProcessExceptionTableName = 'busOrderItemDetails';
                    mapObjNametoRcvdIds.put('BusOrderItems',new List<String>{});
                    
                    for(API_redBusBookingSyncing.BusOrderItemDetails BusOr: tempbooking.busOrderItemDetails)
                    {
                        if(string.isNotBlank(string.valueof(BusOr.id)))
                        {
                            Bus_Order_Item_Details__c BusOrItem = new Bus_Order_Item_Details__c();
                            BusOrItem.ID__c = string.valueof(BusOr.id);
                            BusOrItem.Name = BusOrItem.ID__c;
                            BusOrItem.Order_Item_Name__r = new Order_Items__c(ID__c = BusOrItem.ID__c);
                            ProcessExceptionId = BusOrItem.ID__c;
                            mapObjNametoRcvdIds.get('BusOrderItems').add(BusOrItem.ID__c);
                            
                            BusOrItem.Primary_Boarding_Time__c = String.isNotBlank(BusOr.primary_boarding_time)?datetime.valueof(BusOr.primary_boarding_time.replace('T',' ')):null;
                            BusOrItem.Route_ID__c = BusOr.route_id;
                            BusOrItem.Source_City__c = BusOr.source_city;
                            BusOrItem.Source_ID__c = BusOr.source_id;
                            BusOrItem.Starting_Location__c = BusOr.starting_location;
                            BusOrItem.Starting_Location_ID__c = BusOr.starting_location_id;
                            BusOrItem.Ticket_Details__c = BusOr.ticket_details;
                            BusOrItem.Dropping_Point__c = BusOr.dropping_point;
                            BusOrItem.Dropping_Point_ID__c = BusOr.dropping_point_id;
                            BusOrItem.Boarding_Point__c = BusOr.boarding_point;
                            BusOrItem.Boarding_Point_ID__c = BusOr.boarding_point_id;
                            BusOrItem.Boarding_Time__c = String.isNotBlank(BusOr.boarding_time)?datetime.valueof(BusOr.boarding_time.replace('T',' ')):null;
                            BusOrItem.Bus_Type__c = BusOr.bus_type;
                            BusOrItem.Destination_City__c = BusOr.destination_city;
                            BusOrItem.Destination_Id__c = BusOr.destination_id;
                            BusOrItem.Item_Details__c = BusOr.item_details;
                            BusOrderItemDetails.add(BusOrItem);
                        }
                    }
                    
                    if(!BusOrderItemDetails.isEmpty())
                    {
                        Database.UpsertResult[] busOrderItemUpsertResult = Database.upsert(BusOrderItemDetails,Bus_Order_Item_Details__c.ID__c,false);
                        resp.busOrderItemDetailsFailedCount =0;
                        mapObjtoSavedResults.put('BusOrderItems',busOrderItemUpsertResult);
                    }
                    BusOrderItemDetails.clear();
                }
                /*-----------------------------BusOrderItemDetails End----------------------------*/
                
                /*-----------------------------TravellerInfo Start------------------------------*/
                if(tempbooking.travellerInfo!=null && !tempbooking.travellerInfo.isEmpty())
                {
                    list<Traveller_Info__c> TravellerInfo = new list<Traveller_Info__c>();
                    ProcessExceptionTableName = 'travellerInfo';
                    mapObjNametoRcvdIds.put('TravellerInfo',new List<String>{});
                    
                    for(API_redBusBookingSyncing.TravellerInfo  tra: tempbooking.travellerInfo)
                    {
                        if(string.isNotBlank(string.valueof(tra.id)))
                        {
                            Traveller_Info__c trinfo = new Traveller_Info__c();
                            trinfo.ID__c = string.valueof(tra.id);
                            trinfo.Name = trinfo.ID__c;
                            ProcessExceptionId = trinfo.ID__c;
                            mapObjNametoRcvdIds.get('TravellerInfo').add(trinfo.ID__c);
                            if(string.isNotBlank(string.valueof(tra.bus_order_item_details_id)))
                            {
                                trinfo.Bus_Order_Item_Details_Id__c = string.valueof(tra.bus_order_item_details_id);
                                Order_Items__c orItem = new Order_Items__c(id__c=trinfo.Bus_Order_Item_Details_Id__c);
                                trinfo.Order_Item_Name__r = orItem;
                                
                            }
                            
                            if(String.isNotBlank(tra.email_id))
                            {
                                if(string.valueof(tra.email_id).length()<255)
                                    trinfo.Email_Id_copy__c = tra.email_id;
                                else
                                    trinfo.Email_Id_copy__c = string.valueof(tra.email_id).substring(0,255);
                                
                                if(validateEmail(tra.email_id))
                                    trinfo.Email_ID__c  = tra.email_id;
                            }
                            
                            
                            if(primaryCustomerIds.KeySet().Contains(trinfo.ID__c) && String.isNotBlank(tra.mobile_no) && !AddedList.KeySet().contains(tra.mobile_no))
                            {
                                account cust = new account();
                                cust.AccountSource = 'Traveller Info';
                                AddedList.put(tra.mobile_no,tra.mobile_no);
                                if(mapOrderItemsTravelsAccs.containsKey(tra.mobile_no))
                                    cust = mapOrderItemsTravelsAccs.get(tra.mobile_no);
                                
                                cust.Email_Copy__c = trinfo.Email_Id_copy__c;
                                
                                if(String.isNotBlank(trinfo.Email_ID__c))
                                {
                                    cust.PersonEmail = trinfo.Email_ID__c;
                                    orItemprimaryEmails.add(cust.PersonEmail);
                                }
                                
                                cust.Gender__c = tra.gender;
                                cust.PersonMobilePhone = tra.mobile_no;
                                
                                if(string.isNotBlank(tra.passenger_name))
                                {
                                    cust.lastName = tra.passenger_name;
                                }
                                else if(String.isNotBlank(cust.PersonMobilePhone))
                                {
                                    cust.lastName = cust.PersonMobilePhone;
                                }
                                else
                                {
                                    cust.lastName = 'N/A';
                                }
                                orItemcustList.add(cust);
                                //  System.debug('orItemcustList..'+orItemcustList);
                            }
                            
                            trinfo.Additional_Details__c = tra.additional_details;
                            trinfo.City__c = tra.city;
                            trinfo.Country__c = tra.country;
                            trinfo.PostalCode__c = tra.postalCode;
                            trinfo.State__c = tra.state;
                            trinfo.Age__c = tra.age;
                            trinfo.Alternate_Mobile_No__c = tra.alternate_mobile_no;
                            trinfo.Mobile_No__c = tra.mobile_no;
                            trinfo.Name_On_Proof__c = tra.name_on_proof;
                            trinfo.Passenger_Name__c = tra.passenger_name;
                            trinfo.Proof_Id__c = tra.proof_id;
                            trinfo.Proof_Type__c = tra.proof_type;
                            trinfo.Title__c = tra.title;
                            trinfo.Address__c = tra.address;
                            trinfo.addressLine1__c = tra.addressLine1;
                            trinfo.addressLine2__c = tra.addressLine2;
                            trinfo.DateOfBirth__c = String.isNotBlank(tra.dateOfBirth)?datetime.valueof(tra.dateOfBirth.replace('T',' ')):null;
                            trinfo.Gender__c = tra.gender;
                            trinfo.Issuing_Authority__c = tra.issuing_authority;
                            TravellerInfo.add(trinfo);
                        }
                    }
                    
                    if(!TravellerInfo.isEmpty())
                    {
                        Database.UpsertResult[] travellerInfoUpsertResult = Database.upsert(TravellerInfo,Traveller_Info__c.ID__c,false);
                        resp.travellerInfoFailedCount =0;
                        mapObjtoSavedResults.put('TravellerInfo',travellerInfoUpsertResult);
                        
                    }
                    
                    TravellerInfo.clear();
                }
                /*----------------------------TravellerInfo End-------------------------------*/
                
                /*-----------------------------CancelledOrderItems Start----------------------*/
                if(tempbooking.cancelledOrderItems!=null && !tempbooking.cancelledOrderItems.isEmpty())
                {
                    list<Cancelled_Order_Items__c> CancelOrderItems = new list<Cancelled_Order_Items__c>();
                    ProcessExceptionTableName = 'CancelOrderItems';
                    List<Order_Items__c> listOrItemsCanOrItems = new list<Order_Items__c>();
                    List<Orders__c> listOrdersCanOrItems = new list<Orders__c>();
                    
                    Set<String> setItemIdsForUpdate = new Set<String>();
                    Set<String> setOrderIdsForUpdate = new Set<String>();
                    mapObjNametoRcvdIds.put('CancelOrderItems',new List<String>{});
                    
                    for(API_redBusBookingSyncing.CancellationItem Canorder: tempbooking.cancelledOrderItems)
                    {
                        Cancelled_Order_Items__c CanOrdItem = new Cancelled_Order_Items__c();
                        if(string.isNotBlank(string.valueof(Canorder.id)))
                        {    
                            CanOrdItem.ID__c = string.valueof(Canorder.id);
                            CanOrdItem.name = CanOrdItem.ID__c;
                            ProcessExceptionId = CanOrdItem.ID__c;
                            mapObjNametoRcvdIds.get('CancelOrderItems').add(CanOrdItem.ID__c);
                            
                            if(string.isNotBlank(string.valueof(Canorder.order_item_id)))
                            {
                                CanOrdItem.Order_Item_ID__c = string.valueof(Canorder.order_item_id);
                                CanOrdItem.Order_Item_Name__r = new Order_Items__c(id__c=CanOrdItem.Order_Item_ID__c);
                                
                                Order_Items__c orItem1 = new Order_Items__c(id__c=CanOrdItem.Order_Item_ID__c);
                                orItem1.Name = String.valueOf(CanOrdItem.Order_Item_ID__c);
                                
                                //Added By Sreenivas M
                                if((setSuccessOritems.isEmpty() || !setSuccessOritems.contains(CanOrdItem.Order_Item_ID__c)) && !setItemIdsForUpdate.contains(CanOrdItem.Order_Item_ID__c))
                                {
                                    setItemIdsForUpdate.add(CanOrdItem.Order_Item_ID__c);
                                    listOrItemsCanOrItems.add(orItem1);
                                }
                                
                            }
                            
                            if(string.isNotBlank(string.valueof(Canorder.order_id)))
                            {
                                CanOrdItem.Order_ID__c = string.valueof(Canorder.order_id);
                                CanOrdItem.Order_Name__r = new Orders__c(id__c =  CanOrdItem.Order_ID__c);
                                mapRecIdToOrderId.put(CanOrdItem.ID__c,CanOrdItem.Order_ID__c);
                                
                                Orders__c ords1 = new Orders__c(id__c =  CanOrdItem.Order_ID__c);
                                ords1.Name = String.valueOf(CanOrdItem.Order_ID__c);
                                
                                //Added By Sreenivas M
                                if((setSuccessOrders.isEmpty() || !setSuccessOrders.contains(CanOrdItem.Order_ID__c)) && !setOrderIdsForUpdate.contains(CanOrdItem.Order_ID__c))
                                {
                                    setOrderIdsForUpdate.add(CanOrdItem.Order_ID__c);
                                    listOrdersCanOrItems.add(ords1);
                                }
                            }
                            
                            
                            
                            
                            CanOrdItem.Additional_Details__c = Canorder.additional_details;
                            CanOrdItem.Creation_Time__c = String.isNotBlank(Canorder.creation_time)?datetime.valueof(Canorder.creation_time.replace('T',' ')):null;
                            CanOrdItem.Transaction_Source__c = Canorder.transaction_source;
                            CanOrdItem.order_Item_Reference_No__c = Canorder.order_item_reference_no;
                            CanOrdItem.Status__c = Canorder.status;
                            CanOrdItem.Service_Provider_Name__c = Canorder.service_provider_reference_no;
                            CanOrdItem.Seates_to_be_cancelled__c = Canorder.seates_to_be_cancelled;
                            CanOrdItem.Operator_Cancellation_Status__c = Canorder.operator_cancellation_status;
                            CanOrdItem.Total_Tax_Currency__c = Canorder.total_tax_currency;
                            CanOrdItem.Total_Fare_Currency__c = Canorder.total_fare_currency;
                            CanOrdItem.Cancellation_Reference_No__c = Canorder.cancellation_reference_no;
                            CanOrdItem.Service_Provider_Id__c = Canorder.service_provider_id;
                            CanOrdItem.Service_Provider_Name__c = Canorder.service_provider_name;
                            CanOrdItem.Date_Of_Purchase__c = String.isNotBlank(Canorder.date_of_purchase)?datetime.valueof(Canorder.date_of_purchase.replace('T',' ')):null;
                            CanOrdItem.Cancellation_Reason__c = Canorder.cancellation_reason;
                            CanOrdItem.Client_IP__c = Canorder.client_ip;
                            CanOrdItem.Total_Fare_Value__c = Canorder.total_fare_value;
                            CanOrdItem.Guid__c = Canorder.guid;
                            CanOrdItem.Business_Unit__c = Canorder.business_unit;
                            CanOrdItem.Cancellation_Time__c = String.isNotBlank(Canorder.cancellation_time)?datetime.valueof(Canorder.cancellation_time.replace('T',' ')):null;
                            
                            if(Canorder.operator_cancellation_charges!=null)
                                CanOrdItem.Operator_Cancellation_Charges__c = double.valueof(Canorder.operator_cancellation_charges);
                            
                            if(Canorder.total_tax_value!=null)
                                CanOrdItem.Total_Tax_Value__c = double.valueof(Canorder.total_tax_value);
                            
                            if(Canorder.primary_passenger_id!=null)
                                CanOrdItem.Primary_Passenger_Id__c = string.valueof(Canorder.primary_passenger_id);
                            
                            CancelOrderItems.add(CanOrdItem);
                        }
                    }
                    
                    if(!CancelOrderItems.isEmpty())
                    {
                        if(!listOrdersCanOrItems.isEmpty())
                            Database.UpsertResult[] ordersupsertResult = Database.upsert(listOrdersCanOrItems,Orders__c.ID__c,false);
                        if(!listOrItemsCanOrItems.isEmpty())
                            Database.UpsertResult[] itemsupsertResult = Database.upsert(listOrItemsCanOrItems,Order_Items__c.ID__c,false);
                        
                        Database.UpsertResult[] cancelledOrderUpsertResult = Database.upsert(CancelOrderItems,Cancelled_Order_Items__c.ID__c,false);
                        resp.cancelledOrderItemsFailedCount=0;                      
                        mapObjtoSavedResults.put('CancelOrderItems',cancelledOrderUpsertResult);
                        
                        
                    }
                    CancelOrderItems.clear();
                }
                /*-------------------------------CancelledOrderitems End------------------------*/
                
                /*--------------------------------RefundOrderItems Start---------------------*/
                
                if(tempbooking.refundOrderItems!=null && !tempbooking.refundOrderItems.isEmpty())
                {
                    
                    list<Refund_Order_Items__c> RefundOrderItems = new list<Refund_Order_Items__c>();
                    List<Order_Items__c> listOrItemsRefOrItems = new list<Order_Items__c>();
                    List<Payment_Items__c> listPayItemsRefOrItems = new list<Payment_Items__c>();            
                    Set<String> setItemIdsForUpdate = new Set<String>();
                    Set<String> setPayIdsForUpdate = new Set<String>();
                    ProcessExceptionTableName = 'refundOrderItems';
                    mapObjNametoRcvdIds.put('RefundOrderItems',new List<String>{});
                    
                    for(API_redBusBookingSyncing.RefundItem  refundItem: tempbooking.refundOrderItems)
                    {
                        if(string.isNotBlank(string.valueof(refundItem.id)))
                        {
                            Refund_Order_Items__c RefundOrdItem = new Refund_Order_Items__c();
                            RefundOrdItem.ID__c = string.valueof(refundItem.id);
                            RefundOrdItem.name = RefundOrdItem.ID__c;
                            ProcessExceptionId = RefundOrdItem.ID__c;
                            mapObjNametoRcvdIds.get('RefundOrderItems').add(RefundOrdItem.ID__c);
                            if(String.isNotBlank(String.valueOf(refundItem.order_item_id)))
                            {
                                RefundOrdItem.Order_Item_ID__c = string.valueof(refundItem.order_item_id);
                                Order_Items__c orItem = new Order_Items__c(id__c = RefundOrdItem.Order_Item_ID__c);
                                RefundOrdItem.Order_Item_Name__r = orItem;
                                
                                Order_Items__c orItem1 = new Order_Items__c(id__c = RefundOrdItem.Order_Item_ID__c);
                                orItem1.Name = String.valueOf(RefundOrdItem.Order_Item_ID__c);
                                
                                //Added By Sreenivas M
                                if((setSuccessOritems.isEmpty() || !setSuccessOritems.contains(orItem.id__c)) && !setItemIdsForUpdate.contains(orItem.id__c))
                                {
                                    setItemIdsForUpdate.add(orItem.id__c);
                                    listOrItemsRefOrItems.add(orItem1);
                                }
                            }
                            
                            if(refundItem.payment_item_id!=null)
                            {
                                RefundOrdItem.Payment_Item_ID__c = string.valueof(refundItem.payment_item_id);
                                
                            }
                            
                            RefundOrdItem.Additional_Details__c = refundItem.additional_details;
                            RefundOrdItem.Created_By__c = refundItem.created_by;
                            RefundOrdItem.Creation_Time__c = String.isNotBlank(refundItem.creation_time)?datetime.valueof(refundItem.creation_time.replace('T',' ')):null;
                            RefundOrdItem.Transaction_Source__c = refundItem.transaction_source;
                            RefundOrdItem.Status__c = refundItem.status;
                            RefundOrdItem.Refund_Reason__c = refundItem.refund_reason;
                            RefundOrdItem.Customer_Name__c = refundItem.customer_name;
                            RefundOrdItem.Mobile_No__c = refundItem.mobile_no;
                            RefundOrdItem.Guid__c = refundItem.guid;
                            RefundOrdItem.ARN_Number__c = refundItem.arnNumber;
                            RefundOrdItem.Refund_For_Tin__c = refundItem.refund_for_tin;
                            RefundOrdItem.Refund_Type__c = refundItem.refund_type;
                            RefundOrdItem.PG_Name__c = refundItem.pg_name;
                            RefundOrdItem.PG_Reference_No__c = refundItem.pg_reference_no;
                            RefundOrdItem.PG_Type__c = refundItem.pg_type;
                            RefundOrdItem.Bank_Name__c = refundItem.bank_name;
                            RefundOrdItem.Card_No__c = refundItem.card_no;
                            RefundOrdItem.Auto_NEFT_Status__c= refundItem.autoNeftStatus;
                            RefundOrdItem.Disbursal_ID__c= refundItem.disbursalID;
                            RefundOrdItem.Disbursal_Mode__c=refundItem.disbursalMode;
                            RefundOrdItem.Disbursal_Status__c=refundItem.disbursalStatus;
                            RefundOrdItem.cleared_time__c = String.isNotBlank(refundItem.cleared_time)?datetime.valueof(refundItem.cleared_time.replace('T',' ')):null;
                            RefundOrdItem.refunded_time__c = String.isNotBlank(refundItem.refunded_time)?datetime.valueof(refundItem.refunded_time.replace('T',' ')):null;
                            
                            if(refundItem.creation_time_long!=null)
                                RefundOrdItem.Creation_Time_Long__c = string.valueof(refundItem.creation_time_long);
                            
                            if(refundItem.refunded_amount!=null)
                                RefundOrdItem.refunded_amount__c = double.valueof(refundItem.refunded_amount);
                            
                            if(String.isNotBlank(refundItem.email_id))
                            {
                                if(string.valueof(refundItem.email_id).length()<255)
                                    RefundOrdItem.Email_Id_copy__c = refundItem.email_id;
                                else
                                    RefundOrdItem.Email_Id_copy__c = string.valueof(refundItem.email_id).substring(0,255);
                                
                                if(validateEmail(refundItem.email_id))
                                    RefundOrdItem.Email_ID__c  = refundItem.email_id;
                            }
                            RefundOrderItems.add(RefundOrdItem);
                        }
                    }
                    
                    if(!RefundOrderItems.isEmpty())
                    {
                        if(!listOrItemsRefOrItems.isEmpty())
                            Database.UpsertResult[] itemsupsertResult = Database.upsert(listOrItemsRefOrItems,Order_Items__c.ID__c,false);
                        
                        Database.UpsertResult[] refundOrderUpsertResult = Database.upsert(RefundOrderItems,Refund_Order_Items__c.ID__c,false);
                        resp.refundOrderItemsFailedCount =0;
                        mapObjtoSavedResults.put('RefundOrderItems',refundOrderUpsertResult);
                        
                    }
                    RefundOrderItems.clear();
                }
                /*--------------------------------RefundOrderItems End---------------------*/
                
                
                Attachment att = new Attachment();
                att.name = 'Data-'+String.valueOf(System.Now());
                att.Body = blob.valueof(req.requestBody.toString());
                att.ParentId = Id.valueOf(dbLogSummId);
                database.insert(att);
                
                
                if(!mapObjNametoRcvdIds.values().isEmpty())
                {
                    Set<String> emptyStr = new Set<String>();
                    API_redBusBookingSyncingFuture.ProcessBookingINfo(primaryPhoneNumbers, orItemprimaryEmails,JSON.Serialize(orItemcustList),dbLogSummId,JSON.serialize(mapObjNametoRcvdIds),JSON.serialize(mapObjtoSavedResults),JSON.serialize(mapRecIdToOrderId),dbl.cZentrix_Type__c,rescheduleOrderIds,businessType,dbl.SyncedFrom__c);
                    
                    //API_redBusBookingSyncingFuture.ProcessBookingINfo(customerIds,custPhoneNumbers, JSON.serialize(orCustList),primaryEmails, primaryPhoneNumbers, orItemprimaryEmails,JSON.Serialize(orItemcustList),dbLogSummId,JSON.serialize(mapObjNametoRcvdIds),JSON.serialize(mapObjtoSavedResults),JSON.serialize(mapRecIdToOrderId),dbl.cZentrix_Type__c);
                }
                
                
                //Addons/Activities Mapping
                map<string,object> activitiesMap = (map<string,object>)JSON.deserializeUntyped(reqBody);
                if(activitiesMap.containsKey('addonItems'))
                {
                  list<object> listAddons = (list<object>)activitiesMap.get('addonItems');
                  if(listAddons<>null && !listAddons.isEmpty())
                      API_ActivitiesSyncFuture.processActivities(dbl.Type__c,Json.serialize(new Map<string,object>{'addonItems'=>activitiesMap.get('addonItems')}));
                }
                
                dbl.Payment_Request_Response_Time__c = System.now();
                DataBase.upsert(dbl);
                
            }
            
        }
        catch(exception e)
        {
            resp.exceptionDescription = string.valueof(e);
            resp.exceptionTableName = ProcessExceptionTableName;
            resp.exceptionId = ProcessExceptionId;
            
            DBLog_Summary__c dbl = new DBLog_Summary__c(id=dbLogSummId);
            dbl.Traveller_Info_Data_Received_Ids__c = string.join(mapObjNametoRcvdIds.get('TravellerInfo'),',');
            dbl.Orders_Received_Data_Ids__c = string.join(mapObjNametoRcvdIds.get('Orders'),',');
            dbl.Order_Items_Data_Received_Ids__c = string.join(mapObjNametoRcvdIds.get('OrderItems'),',');
            dbl.Payment_Items_Data_Received_Ids__c = string.join(mapObjNametoRcvdIds.get('PaymentItems'),',');
            dbl.BusOrder_Items_Data_Received_Ids__c = string.join(mapObjNametoRcvdIds.get('BusOrderItems'),',');
            dbl.Cancelled_Order_Items_Data_Received_Ids__c = string.join(mapObjNametoRcvdIds.get('CancelledOrerItems'),',');
            dbl.Refund_Order_Items_Data_Received_Ids__c = string.join(mapObjNametoRcvdIds.get('RefundOrerItems'),',');
            dbl.Exception_Description__c = string.valueof(e);
            dbl.Exception_Table_Name__c = ProcessExceptionTableName;
            dbl.Exception_ID__c = ProcessExceptionId;
            dbl.Payment_Request_Response_Time__c = System.now();
            Database.upsert(dbl);
        } 
        return resp;
    }
    
    global static Boolean validateEmail(String email) 
    {
        if (email.length() > 78) {
            return false;
        }
        Boolean res = true;
        //String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        // String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        
        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    }
    
    static Datetime processDate(String dt)
    {
        if(String.isNotBlank(dt) && dt!='null')
        {
            if(dt.contains('T'))
                return datetime.valueof(dt.replace('T',' '));
            else
                return datetime.valueof(dt);
        }
        return null;    
        
    }
    
    static string ConvertUTCStrtoLocalTimeStr(String utcTimeStr,String minutesDiff)
    {
     if(String.isBlank(utcTimeStr) || String.isBlank(minutesDiff))
     return '';
     
     Datetime dt = Datetime.valueOfGMT(utcTimeStr);
     return dt.addMinutes(Integer.valueOf(minutesDiff)).formatGMT('dd-MM-yyyy h:mm a');
    }
    
    global class Response
    {
        string exceptionDescription;
        string exceptionTableName;
        string exceptionId;
        integer ordersFailedCount;
        integer orderItemsFailedCount;
        integer paymentItemsFailedCount;
        integer travellerInfoFailedCount;
        integer busOrderItemDetailsFailedCount;
        integer refundOrderItemsFailedCount;
        integer cancelledOrderItemsFailedCount;
        public Response()
        {
            
        }
    }
    
    public class BookingRequest
    {
        public string type { get; set; }
        public string sentAt { get; set; }
        public string region{get;set;}
        public string syncFrom{get;set;}    
        public List<Order> orders { get; set; }
        public List<OrderItem> orderItems { get; set; }
        public List<OrderItemFareComponent> orderItemFareComponents { get; set; }
        public List<BusOrderItemDetails> busOrderItemDetails { get; set; }
        public List<TravellerInfo> travellerInfo { get; set; }
        public List<PaymentItem> paymentItems { get; set; }
        public List<PaymentSession> paymentSessions { get; set; }
        public List<PGPaymentItem> pgPaymentItems { get; set; }
        public List<CancellationItem> cancelledOrderItems{get;set;}
        public List<RefundItem> refundOrderItems{get;set;}
       
        
        public BookingRequest()
        {
            orders = new List<Order>();
            orderItems = new List<OrderItem>();
            orderItemFareComponents = new List<OrderItemFareComponent>();
            busOrderItemDetails = new List<BusOrderItemDetails>();
            travellerInfo = new List<TravellerInfo>();
            paymentItems = new List<PaymentItem>();
            paymentSessions = new List<PaymentSession>();
            pgPaymentItems = new List<PGPaymentItem>();
            cancelledOrderItems = new List<CancellationItem>();
            refundOrderItems = new List<RefundItem>();
          
        }
    }
    public class Order
    {
        public long id { get; set; }
        public string additional_details { get; set; }
        public string created_by { get; set; }                
        public string creation_time { get; set; }
        public string transaction_source { get; set; }
        public string updated_by { get; set; }
        public DateTime updated_time { get; set; }
        public integer version { get; set; }
        public integer item_count { get; set; }
        public string business_unit { get; set; }
        public long creation_time_long { get; set; }
        public long cust_id { get; set; }
        public string selected_payment_currency { get; set; }
        public boolean status_flag { get; set; }
        public string cust_details { get; set; }
        public string guid { get; set; }
    }
    
    public class OrderItem 
    {
        public long id { get; set; }
        public string additional_details { get; set; }
        public string created_by { get; set; }
        public String creation_time { get; set; }
        public string transaction_source { get; set; }
        public integer flag { get; set; }
        public string updated_by { get; set; }
        public DateTime updated_time { get; set; }
        public integer version { get; set; }
        public string amount_recieved_currency { get; set; }
        public decimal amount_recieved_value { get; set; }
        public string business_unit { get; set; }
        public string business_unit_conversion_currency { get; set; }
        public decimal business_unit_conversion_value { get; set; }
        public String cancellation_time { get; set; }
        public string child_purchase_item_id { get; set; }
        public String date_of_service { get; set; }
        public string discount_currency { get; set; }
        public decimal discount_value { get; set; }
        public string inventory_id { get; set; }
        public string item_type { get; set; }
        public string order_id { get; set; }
        public string order_item_reference_no { get; set; }
        public string payment_currency { get; set; }
        public string parent_purchase_item_id { get; set; }
        public long primary_passenger_id { get; set; }
        public string purchase_item_currency { get; set; }
        public string service_provider_id { get; set; }
        public string service_provider_name { get; set; }
        public string status { get; set; }
        public integer sub_item_count { get; set; }
        public string tentative_key { get; set; }
        public string total_fare_currency { get; set; }
        public decimal total_fare_value { get; set; }
        public string total_tax_currency { get; set; }
        public decimal total_tax_value { get; set; }
        public string service_provider_reference_no { get; set; }
        public long creation_time_long { get; set; }
        public long date_of_service_long { get; set; }
        public decimal conversionRate { get; set; }
        public decimal markupValue { get; set; }
        public string inventory_type { get; set; }
        public string conversion_info { get; set; }
        public string email { get; set; }
        public string mobile { get; set; }
        public decimal receivable_amount_value { get; set; }
        public string receivable_amount_currency { get; set; }
        public string view_details { get; set; }
        public String date_of_purchase { get; set; }
        public string guid { get; set; }
        public string tentative_details { get; set; }
        public integer rb_user_Id { get; set; }
        public string client_ip { get; set; }
        public string cancellation_policy { get; set; }
        public string old_order_item_reference_no { get; set; }
        public decimal spot_cancel_time_minutes { get; set; }
        public boolean is_return { get; set; }
        public decimal transaction_charge { get; set; }
        public string support_action { get; set; }
        public decimal total_fare_paid_to_operator { get; set; }
        public String exp_time { get; set; }
        public boolean is_partial_cancellation_allowed { get; set; }
        public decimal operator_cancellation_charges { get; set; }
        public boolean force_cancelled { get; set; }
        public string live_operator_force_cancel_status { get; set; }
        public string agent_ip { get; set; }
        public string serviceId { get; set; }
        public String confirm_time { get; set; }        
        public boolean isMIMBooking { get; set; }
        public boolean isReschedulable { get; set; }
        public boolean isExceptionalBusCancellation { get; set; }
        public double insuranceCharge { get; set; } 
        public string amenities { get; set; }
        public string boardingPointId{get;set;}
        public boolean isMticketEnabled;
        public boolean isGSTInSelected;
        
        public string boardingPointegerId { get; set; }
        public List<IdentityProof> identityProofs { get; set; }
        
        public string primaryProofId { get; set; }
        public string primaryProofType { get; set; }
        public string primaryProofName { get; set; }
        public double rescheduleCharge { get; set; }
        
        //rechedule charge
        public string reschedulingFor { get; set; }
        public string isRescheduled { get; set; }
        public string OldTin { get; set; }
        //adding ruc details
        public string seatadditionalDetails { get; set; }      
        public string[] rescheduledTo { get; set; }
        public string cancellationReason { get; set; }
        public string bankAccountNumber { get; set; }
        public string accountHolderName { get; set; }
        public string insuranceProviderName { get; set; }
        public String droppingTime { get; set; }
        public string bplandmark { get; set; }
        public string bankName{get;set;}
        
        public string paymentDetails { get; set; }
        // public string historicalDetails { get; set; }
        // public boolean isShifted { get; set; }
        public string order_uuid { get; set; }
        
        //package piligrimage data
        public string pkgId { get; set; }
        public string pkgName { get; set; }
        
        public string boarding_point { get; set; }
        public string bus_type { get; set; }
        public string destination_city { get; set; }
        public string source_city { get; set; }
        public string dropping_point { get; set; }
        public String boarding_time { get; set; }
        public string seat_no { get; set; }
        public string route_id { get; set; }
        public String primary_boarding_time { get; set; }
        public string eligibleBOs{get;set;}
        public string vehicleNumber{get;set;}
        public string couponId{get;set;}
        public string couponUUid{get;set;}
        public integer malecount{get;set;}
        public integer femalecount{get;set;}
        public String dateof_Realization{ get; set; }
        public string cnr{get;set;}
        public string destLocationId{get;set;}
        public string srcLocationId{get;set;}
        public string rebookingFor{get;set;}
        public string rebookedTo{get;set;}
        public string rebookAgentId{get;set;}
        public string hft{get;set;}
        public string bPassStatus { get; set; }
        public string bPassProviderName { get; set; }
        public double bPassCharge { get; set; }
        //Cancellation flags
        public string cancellationType{get;set;}
        public string refundedBy{get;set;}
        public string assurCategory{get;set;}
        public string assurDescription{get;set;}
        public string assurFundedBy{get;set;}
        public string assurRefundShare{get;set;}
        public decimal assurAmountPaidByCustomer{get;set;}
        
        public string retRouteId { get; set; }
        public string retGateOpenTime { get; set; }
        public string retGateCloseTime{ get; set; }
        public string retDroppingTime { get; set; }
        public string retBoardingTime{ get; set; }
        public string retPrimaryBoardingTime { get; set; }
        public string gateOpenTime{ get; set; }
        public string  gateClosedTime { get; set; }
        public string assuranceService{get;set;}
        public string serviceNotes;
        public string PrimaryBoardingTimeLocal;
        public string Country;
        public integer noOfTransactions{get;set;}
        public integer availedCount{get;set;}
        public string dateOfRealization{get;set;}
        public integer total_Order_value {get; set;}
        public string discardReason;
        public string isPayAtOperatorBooking;
        public List<BoardingPassItem> boardingPassItems { get; set; }   
        public string InsuranceDetails{get; set;}  
        public map<string,string> operatorFeature{get;set;}
        
        public string pnr;
        public string subOrderItems;
        public string customerPriceBreakUp;
        public string journeyDetails;
        public string trainDetails;
        public string numberOfAdults;
        public string numberOfChildren;
        public string reservationId;
        public integer isAggregator;
        public string customerPrefferedLang;
        public string boardingTz;
        public string droppingTz;
        public integer bookingType;
        public integer exceptionalRefundCount;
        public string boardingPointAddress;
        public boolean isnewuser;
        public string streakId;
        public string vendorPnr;
        public string streakStatus;
        public boolean streakConsentPending;
        public boolean isCancellableFromApi { get; set; }

        public string connectedUUID { get; set; }
        public string connectedTIN { get; set; }
        public string connectedItems { get; set; }
        public LayoverData layoverData { get; set; }
        public string hotelName { get; set; }
        public string hotelId { get; set; }
        public string checkoutTime { get; set; }
        public string checkinTime { get; set; }
        public integer totalRoomCount;
        public string bookingId;
    }

    //Connected services Wrapper
    public class LayoverBp
    {
        public string address { get; set; }
        public string name { get; set; }
    }
    public class LayoverData
    {
        public String boardingTime { get; set; }
        public string cityName { get; set; }
        public String droppingTime { get; set; }
        public Boolean hasTransport { get; set; }
        public string journeyTime { get; set; }
        public LayoverBp layoverBp { get; set; }
        public LayoverDp layoverDp { get; set; }
    }
    public class LayoverDp
    {
        public string address { get; set; }
        public string name { get; set; }
    }
    //
    
    public class PaymentItem
    {
        public long id { get; set; }
        public string additional_details { get; set; }
        public string created_by { get; set; }
        public String creation_time { get; set; }
        public string transaction_source { get; set; }
        public string updated_by { get; set; }
        public String updated_time { get; set; }
        public integer version { get; set; }
        public string business_unit_currency { get; set; }
        public decimal business_unit_value { get; set; }
        public string amount_payable_currency { get; set; }
        public decimal amount_payable_value { get; set; }
        public long order_id { get; set; }
        public string payment_status { get; set; }
        public long payment_session_id { get; set; }
        public string payment_system { get; set; }
        public string payment_system_ref_no { get; set; }
        public string settled_currency { get; set; }
        public decimal settled_value { get; set; }
        public String settlement_time { get; set; }
        public long creation_time_public { get; set; }
        public long settlement_time_public { get; set; }
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
        public string latestPgStatus { get; set; }
        public long PgRefNo { get; set; }
        public boolean IsOffline { get; set; }
        public string bankName { get; set; }
    }
    
    public class BusOrderItemDetails
    {
        public long id { get; set; }
        public string boarding_point { get; set; }
        public string boarding_point_id { get; set; }
        public String boarding_time { get; set; }
        public string bus_type { get; set; }
        public string destination_city { get; set; }
        public string destination_id { get; set; }
        public string item_details { get; set; }
        public String primary_boarding_time { get; set; }
        public string route_id { get; set; }
        public string source_city { get; set; }
        public string source_id { get; set; }
        public string starting_location { get; set; }
        public string starting_location_id { get; set; }
        public string ticket_details { get; set; }
        public string dropping_point { get; set; }
        public string dropping_point_id { get; set; }
        public string refund_status { get; set; }
        
        public string isRescheduled { get; set; }
        public string OldTin { get; set; }
        public string reschedulingFor { get; set; }
        public String droppingTime { get; set; }
        public string bplandmark { get; set; }
    }
    
    public class TravellerInfo
    {
        public long id { get; set; }
        public string additional_details { get; set; }
        public string created_by { get; set; }
        public String creation_time { get; set; }
        public string transaction_source { get; set; }
        public string updated_by { get; set; }
        public String updated_time { get; set; }
        public integer version { get; set; }
        public string city { get; set; }
        public string country { get; set; }
        public string postalCode { get; set; }
        public string state { get; set; }
        public integer age { get; set; }
        public string alternate_mobile_no { get; set; }
        public String dateOfBirth { get; set; }
        public string email_id { get; set; }
        public string gender { get; set; }
        public string issuing_authority { get; set; }
        public string mobile_no { get; set; }
        public string name_on_proof { get; set; }
        public string passenger_name { get; set; }
        public string passenger_type { get; set; }
        public string proof_id { get; set; }
        public string proof_type { get; set; }
        public string title { get; set; }
        public long creation_time_public { get; set; }
        public string address { get; set; }
        public string addressLine1 { get; set; }
        public string addressLine2 { get; set; }
        public string addressLine3 { get; set; }
        public string guid { get; set; }
        public long bus_order_item_details_id { get; set; }
        public map<string, string> additionalDetails { get; set; }
    }
    
    public class CancellationItem
    {
        public long id                                  { get; set; }
        public string additional_details                { get; set; }
        public string created_by                        { get; set; }
        public String creation_time                  { get; set; }
        public string transaction_source                { get; set; }
        public string updated_by                        { get; set; }
        public String updated_time                   { get; set; }
        public integer version                             { get; set; }
        public string order_item_reference_no           { get; set; }
        public long order_item_id                      { get; set; }
        public string status                            { get; set; }
        public string service_provider_reference_no     { get; set; }
        public string seates_to_be_cancelled            { get; set; }
        public string total_fare_currency               { get; set; }
        public decimal total_fare_value                { get; set; }
        public string total_tax_currency                { get; set; }
        public decimal total_tax_value                 { get; set; }
        public string operator_cancellation_status      { get; set; }
        public string cancellation_reference_no         { get; set; }
        public string business_unit                     { get; set; }
        public String cancellation_time              { get; set; }
        public long primary_passenger_id               { get; set; }
        public string service_provider_id               { get; set; }
        public string service_provider_name             { get; set; }
        public String date_of_purchase               { get; set; }
        public string guid                              { get; set; }
        public long creation_time_long                 { get; set; }
        public string cancellation_reason               { get; set; }
        public long order_id                           { get; set; }
        public string client_ip                         { get; set; }
        public decimal operator_cancellation_charges { get; set; }
        
    }   
    public class RefundItem
    {
        public long id                      { get; set; }
        public string additional_details    { get; set; }
        public string created_by            { get; set; }
        public String creation_time      { get; set; }
        public String refunded_time     { get; set; }
        public String cleared_time       { get; set; }
        public decimal refunded_amount      { get; set; }
        public string transaction_source    { get; set; }
        public string updated_by            { get; set; }
        public String updated_time       { get; set; }
        public integer version                 { get; set; }
        public string status                { get; set; }
        public string refund_reason         { get; set; }
        public string customer_name         { get; set; }
        public string mobile_no             { get; set; }
        public string email_id              { get; set; }
        public string refund_for_tin        { get; set; }
        public string refund_type           { get; set; }
        public long order_item_id          { get; set; }
        public long payment_item_id         { get; set; }
        public string pg_name               { get; set; }
        public string pg_reference_no       { get; set; }
        public string pg_type               { get; set; }
        public string bank_name             { get; set; }
        public string card_no               { get; set; }
        public long creation_time_long     { get; set; }
        public string guid                  { get; set; }
        public string arnNumber             { get; set; }
        public string autoNeftStatus;
        public string disbursalID   { get; set; }
        public string disbursalMode  { get; set; }
        public string disbursalStatus  {get; set;}
    }
    
    public class IdentityProof
    {
        public string proofType { get; set; }
        public string proofId { get; set; }
        public string nameOnProof { get; set; }
    }
    
    public class BoardingPassItem    {
        public string VendorStatus { get; set; } 
        //public object QRBarCode { get; set; } 
    }
    
    public class JourneyDetails{
        public dpWrapper droppingPointDetails;
        public bpWrapper boardingPointDetails;
        
    }
    public class dpWrapper{
        public string destLocation;
        public string arrivalTime;
        public string stationName;
        public string stationCode;
    }
    public class bpWrapper{
        public string boardingLocationId;
        public string boardingLocation;
        public string arrivalTime;
        public string stationName;
        public string departureTime;
        public string stationCode;
    }
    
    public class OrderItemFareComponent{}
    public class PaymentSession{}
    public class PGPaymentItem{}   
    
}