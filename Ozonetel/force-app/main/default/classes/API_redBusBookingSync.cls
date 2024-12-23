/**
* (c) 2019 RedBus
*
* Name           : API_BusBookingSync
* Created Date   : 24 April 2019
* Created By     : Sreenivas M
* Purpose        : Optimized class for syncing the bus booking data
* Existing Class : API_redBus_Booking 
*
**/
@RestResource(urlMapping='/redBus/v1/redBusBookingSync/*')
global without sharing class API_redBusBookingSync
{
    static string ProcessExceptionId;
    static string ProcessExceptionTableName;
    static list<string> cancelOrderItemIds = new list<string>();
    static list<string> refundIds = new list<string>();
    static set<string> allOrdersids = new set<string>();
    static set<string> allOrderItemids = new set<string>();
    static list<string> OrderIds = new list<string>();
    static list<string> orderItemIds = new list<string>();
    static list<string> OrderItemFareComponentids = new list<string>();
    static list<string> PaymentSessionIds = new list<string>();
    static list<string> PaymentItemsIds = new list<string>();
    static list<string> PGPaymentItemsids = new list<string>();
    static list<string> BusOrderItemDetailsids = new list<string>();
    static list<string> TravellerInfoIds = new list<string>();
    static list<string> locationids = new list<string>();
    static list<string> serviceids = new list<string>();
    static list<string> bustypeids = new list<string>();
    static map<string,Location__c> busLocations = new map<string,Location__c>();
    static map<string,Bus_Type__c> busType = new map<string,Bus_Type__c>();
    static map<string,Service_Provider__c> serviceProvider = new map<string,Service_Provider__c>();
    static map<string,account> OrderItemCustomerMap = new map<string,account>();
    static Set<String> setSuccessOritems;
    static Set<String> setSuccessOrders;
    static Set<String> setSuccessPayItems;
    static list<account> custListOr = new list<account>();
    
    static map<string,OrderItemTransactionResource__c> oitrMap = new map<string,OrderItemTransactionResource__c>();
    static list<DB_Log__c> DBLog = new list<DB_Log__c>();
    
    static list<string> orderItemFailedPro = new list<string>();
    static list<string> PaymentItemsFailedPro = new list<string>();
    static list<string> OrderFailedPro = new list<string>();
    static list<string> OrderItemFareComponentFailedPro = new list<string>();
    static list<string> PaymentSessionFailedPro = new list<string>();
    static list<string> PGPaymentItemsFailedPro = new list<string>();
    static list<string> BusOrderItemDetailsFailedPro = new list<string>();
    static list<string> TravellerInfoFailedPro = new list<string>();
    static list<string> cancelOrderItemFailedPro = new list<string>();
    static list<string> refundFailedPro = new list<string>();    
    static list<string> pgReferencePayItems = new list<string>();
    static list<string> PaymentItemSessionIds = new list<string>();
    static set<string> filterOrderIds = new set<string>();
    static map<string,string> AddedList = new map<string,string>();
    static Map<String,Account> mapOrderItemsTravelsAccs = new Map<String,Account>();
    static Id dbLogSummId;
    
    @HttpPost
    global static response doPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        system.debug('-----------data--------'+req.requestBody.toString());
        
        response resp = new response();
        
        list<string> orCustList = new list<string>();
        List<string> orItemcustList = new List<string>();
        
        // Start Added by Sreenivas M 
        setSuccessOritems = new Set<String>(); 
        setSuccessOrders = new Set<String>(); 
        setSuccessPayItems = new Set<String>(); 
        //End Adeed By Sreenivas M
        
        map<string,string> primaryCustomerIds = new map<string,string>();
        set<string> customerIds = new set<string>();
        set<string> primaryEmails = new set<string>();
        set<string> custPhoneNumbers = new set<string>();
        set<string> primaryPhoneNumbers = new set<string>();
        set<string> orItemprimaryEmails = new set<string>();
        map<string,string> orderitemOrdersMap = new map<string,string>();
        map<string,string> orderItemDojMap = new map<string,string>();
        map<string,string> BookingStatus = new map<string,string>();
        
        
        try
        {
            if(!string.isBlank(string.valueof(req.requestBody.toString())))
            {
                map<string,object> booking = (map<string,object>)JSON.deserializeUntyped(req.requestBody.toString());
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                dbl.Payment_Request_Sent_Time__c = System.now();
                if(booking.KeySet().contains('type') && !string.isBlank(string.valueof(booking.get('type'))))
                {
                    dbl.Type__c = string.valueof(booking.get('type'));
                }
                if(booking.KeySet().contains('sentAt') && !string.isBlank(string.valueof(booking.get('sentAt'))))
                {
                    dbl.redBus_SentAt__c = string.valueof(booking.get('sentAt'));
                    dbl.SentAt__c = System.now();
                }
                DataBase.insert(dbl,false);
                dbLogSummId = dbl.id;
                
                /*-------------------------------Orders Start--------------------------------*/
                if(booking.KeySet().contains('orders') && booking.get('orders')!=null && booking.get('orders')!='')
                {
                    list<object> ordersList = (list<object>)booking.get('orders');
                    if(!ordersList.isEmpty())
                    {
                        list<Orders__c> orders = new list<Orders__c>();
                        ProcessExceptionTableName = 'orders';
                        for(object orValue: ordersList)
                        {
                            map<string,object> order = (map<string,object>)(orValue);
                            Orders__c ord = new Orders__c();
                            
                            if(order.KeySet().contains('business_unit') && !string.isBlank(string.valueof(order.get('business_unit'))))
                            {
                                ord.Business_Unit__c = string.valueof(order.get('business_unit'));
                            }
                            if(order.KeySet().contains('id') && !string.isBlank(string.valueof(order.get('id'))))
                            {
                                ord.ID__c = string.valueof(order.get('id'));
                                ord.Name = string.valueof(order.get('id'));
                                ProcessExceptionId = ord.ID__c;
                                OrderIds.add(ord.ID__c);
                            }
                            if(order.KeySet().contains('additional_details') && !string.isBlank(string.valueof(order.get('additional_details'))))
                            {
                                ord.Additional_Details__c = string.valueof(order.get('additional_details'));
                            }
                            
                            if(order.KeySet().contains('created_by') && !string.isBlank(string.valueof(order.get('created_by'))))
                            {
                                ord.Created_By__c = string.valueof(order.get('created_by'));
                            }
                            
                            if(order.KeySet().contains('creation_time') && !string.isBlank(string.valueof(order.get('creation_time'))))
                            {
                                if(string.valueof(order.get('creation_time')).contains('T'))
                                {
                                    ord.Creation_Time__c = datetime.valueof(string.valueof(order.get('creation_time')).replace('T',' '));
                                }
                                else
                                {
                                    ord.Creation_Time__c = datetime.valueof((string)order.get('creation_time'));
                                }
                            }
                            if(order.KeySet().contains('transaction_source') && !string.isBlank(string.valueof(order.get('transaction_source'))))
                            {
                                ord.Transaction_Source__c = string.valueof(order.get('transaction_source'));
                            }
                            
                            if(order.KeySet().contains('item_count') && !string.isBlank(string.valueof(order.get('item_count'))))
                            {
                                ord.Item_Count__c = integer.valueof(order.get('item_count'));
                            }
                            
                            if(order.KeySet().contains('creation_time_long') && !string.isBlank(string.valueof(order.get('creation_time_long'))))
                            {
                                ord.Creation_Time_Long__c = string.valueof(order.get('creation_time_long'));
                            }
                            if(order.KeySet().contains('cust_id') && !string.isBlank(string.valueof(order.get('cust_id'))))
                            {
                                ord.Cust_Id__c = string.valueof(order.get('cust_id'));
                            }
                            if(order.KeySet().contains('selected_payment_currency') && !string.isBlank(string.valueof(order.get('selected_payment_currency'))))
                            {
                                ord.Selected_Payment_Currency__c = string.valueof(order.get('selected_payment_currency'));
                            }
                            if(order.KeySet().contains('guid') && !string.isBlank(string.valueof(order.get('guid'))))
                            {
                                ord.Guid__c = string.valueof(order.get('guid'));
                            }
                            if(order.KeySet().contains('status_flag') && !string.isBlank(string.valueof(order.get('status_flag'))))
                            {
                                ord.status_flag__c = boolean.valueof(order.get('status_flag'));
                            }
                            if(order.KeySet().contains('cust_details') && !string.isBlank(string.valueof(order.get('cust_details'))))
                            {
                                ord.Cust_Details__c = string.valueof(order.get('cust_details'));
                                map<string,object> custDetailsInfo = (map<string,object>)JSON.deserializeUntyped(ord.Cust_Details__c);
                                
                                if(custDetailsInfo.KeySet().contains('UserId') && !string.isBlank(string.valueof(custDetailsInfo.get('UserId'))) && custDetailsInfo.get('UserId')!=0 && custDetailsInfo.get('UserId')!=-1)
                                {
                                    account cust = new account();
                                    cust.AccountSource = 'Signed In User';
                                    cust.LastName = 'N/A';
                                    if(custDetailsInfo.get('UserId')!=0)
                                    {
                                        cust.User_Id__c = string.valueof(custDetailsInfo.get('UserId'));
                                        ord.User_Id__c = cust.User_Id__c;
                                        customerIds.add(string.valueof(custDetailsInfo.get('UserId')));
                                    }
                                    if(custDetailsInfo.KeySet().contains('PEmail') && !string.isBlank(string.valueof(custDetailsInfo.get('PEmail'))))
                                    {
                                        cust.Email_Copy__c = string.valueof(custDetailsInfo.get('PEmail'));                                                                                                                        
                                        if(validateEmail(cust.Email_Copy__c))
                                        {
                                            cust.PersonEmail = string.valueof(custDetailsInfo.get('PEmail'));
                                            primaryEmails.add(string.valueof(custDetailsInfo.get('PEmail')));
                                            
                                        }
                                    }
                                    if(custDetailsInfo.KeySet().contains('PMobile') && !string.isBlank(string.valueof(custDetailsInfo.get('PMobile'))))
                                    {
                                        cust.PersonMobilePhone = string.valueof(custDetailsInfo.get('PMobile'));
                                        cust.LastName = cust.PersonMobilePhone;
                                        custPhoneNumbers.add(cust.PersonMobilePhone);
                                    }
                                    if(custDetailsInfo.KeySet().contains('Dob') && !string.isBlank(string.valueof(custDetailsInfo.get('Dob'))))
                                        cust.Birthdate__c = datetime.valueof(string.valueof(custDetailsInfo.get('Dob')));
                                    
                                    if(custDetailsInfo.KeySet().contains('DisplayName') && !string.isBlank(string.valueof(custDetailsInfo.get('DisplayName'))))
                                        cust.LastName = string.valueof(custDetailsInfo.get('DisplayName'));
                                    
                                    if(custDetailsInfo.KeySet().contains('Gender') && !string.isBlank(string.valueof(custDetailsInfo.get('Gender'))))
                                        cust.Gender__c = string.valueof(custDetailsInfo.get('Gender'));
                                    
                                    if(custDetailsInfo.KeySet().contains('IsEmailVerified') && !string.isBlank(string.valueof(custDetailsInfo.get('IsEmailVerified'))))
                                        cust.IsEmailIdVerified__c = boolean.valueof(custDetailsInfo.get('IsEmailVerified'));
                                    if(custDetailsInfo.KeySet().contains('IsMobileVerified') && !string.isBlank(string.valueof(custDetailsInfo.get('IsMobileVerified'))))
                                        cust.IsMobileVerified__c = boolean.valueof(custDetailsInfo.get('IsMobileVerified'));
                                    
                                    if(custDetailsInfo.KeySet().contains('PasswordExists') && !string.isBlank(string.valueof(custDetailsInfo.get('PasswordExists'))))
                                        cust.PasswordExists__c = boolean.valueof(custDetailsInfo.get('PasswordExists'));
                                    
                                    if(custDetailsInfo.KeySet().contains('isWalletEnabled') && !string.isBlank(string.valueof(custDetailsInfo.get('isWalletEnabled'))))
                                        cust.isWalletEnabled__c = boolean.valueof(custDetailsInfo.get('isWalletEnabled'));
                                    
                                    if(custDetailsInfo.KeySet().contains('WalletId') && !string.isBlank(string.valueof(custDetailsInfo.get('WalletId'))))
                                        cust.WalletId__c = string.valueof(custDetailsInfo.get('WalletId'));
                                    
                                    if(custDetailsInfo.KeySet().contains('CountryCode') && !string.isBlank(string.valueof(custDetailsInfo.get('CountryCode'))))
                                        cust.CountryCode__c = string.valueof(custDetailsInfo.get('CountryCode'));
                                    
                                    if(custDetailsInfo.KeySet().contains('PhoneCode') && !string.isBlank(string.valueof(custDetailsInfo.get('PhoneCode'))))
                                        cust.PhoneCode__c = string.valueof(custDetailsInfo.get('PhoneCode'));
                                    
                                    if(custDetailsInfo.KeySet().contains('PreferredCurrency') && !string.isBlank(string.valueof(custDetailsInfo.get('PreferredCurrency'))))
                                        cust.PreferredCurrency__c = string.valueof(custDetailsInfo.get('PreferredCurrency'));
                                    
                                    cust.UpdatedOn__c = system.now();
                                    orCustList.add(JSON.serialize(cust));
                                    System.debug('orCustList..'+orCustList);
                                }
                            }
                            
                            /*
                            if(order.KeySet().contains('updated_by') && !string.isBlank(string.valueof(order.get('updated_by'))))
                            {
                            ord.Updated_By__c = string.valueof(order.get('updated_by'));
                            }

                            if(order.KeySet().contains('updated_time') && !string.isBlank(string.valueof(order.get('updated_time'))))
                            {
                            if(string.valueof(order.get('updated_time')).contains('T'))
                            {
                            ord.Updated_Time__c = datetime.valueof(string.valueof(order.get('updated_time')).replace('T',' '));
                            }
                            else
                            {
                            ord.Updated_Time__c = datetime.valueof((string)order.get('updated_time'));
                            }
                            if(oitrMap.KeySet().Contains(ord.Business_Unit__c) && !string.isBlank(string.valueof(oitrMap.get(ord.Business_Unit__c).UTC_time_difference_in_min__c)))
                            {
                            ord.Updated_Time__c = ord.Updated_Time__c.addMinutes(integer.valueof(oitrMap.get(ord.Business_Unit__c).UTC_time_difference_in_min__c));
                            } 
                            }
                            if(order.KeySet().contains('version') && !string.isBlank(string.valueof(order.get('version'))))
                            {
                            ord.Version__c = integer.valueof(order.get('version'));
                            }
                            */
                            orders.add(ord);
                        }
                        
                        if(!orders.isEmpty())
                        {
                            Database.UpsertResult[] upsertResult = Database.upsert(orders,Orders__c.ID__c,false);
                            
                            list<string> SuccessList = new list<string>();
                            list<string> FailedList = new list<string>();
                            list<string> FailedDesscList = new list<string>();
                            for(Integer i=0;i<upsertResult.size();i++)
                            {
                                if (upsertResult.get(i).isSuccess())
                                {
                                    SuccessList.add(orderids[i]);
                                }
                                else if(!upsertResult.get(i).isSuccess())
                                {
                                    DBLog.add(prepareDBLog('Orders',string.valueof(orderids[i]),string.valueof(upsertResult.get(i).getErrors())));
                                    OrderFailedPro.add(JSON.Serialize(orders[i]));
                                    FailedList.add(orderids[i]);
                                    FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                                }
                            }
                            setSuccessOrders.addAll(SuccessList);
                            resp.ordersSuccess = SuccessList;
                            resp.ordersSuccessCount = SuccessList.size();
                            resp.ordersFailed = FailedList;
                            resp.ordersFailedCount = FailedList.size();
                            resp.ordersFailDescription = FailedDesscList;
                            if(orders.size()==SuccessList.size())
                            {
                                resp.ordersProcessStatus = 'Success';
                            }
                            else
                                if(orders.size()==FailedList.size())
                            {
                                resp.ordersProcessStatus = 'Fail';
                            }
                            else
                            {
                                resp.ordersProcessStatus = 'Partial';
                            }
                            dbl.Orders_Success__c = string.join(SuccessList,',');
                            dbl.Orders_Success_Count__c = SuccessList.size();
                            dbl.Orders_Failed__c = string.join(FailedList,',');
                            dbl.Orders_Failed_Count__c = FailedList.size();
                            if( !string.isBlank(string.join(FailedDesscList,',')) && string.valueof(string.join(FailedDesscList,',')).length()>25000)
                            {
                                dbl.Orders_Fail_Description__c = string.valueof(string.join(FailedDesscList,',')).substring(0,24000);
                            }
                            else
                            {
                                dbl.Orders_Fail_Description__c = string.join(FailedDesscList,',');
                            }
                            
                            dbl.Orders_Process_Status__c = resp.ordersProcessStatus;
                        }
                        orders.clear();
                        dbl.Orders_Received_Data_Ids__c = string.join(OrderIds,',');
                    }
                }
                /*-------------------------------Orders End-----------------------------------*/
                
                /*--------------------------OrderItems Start-------------------------------------------*/
                if(booking.KeySet().contains('orderItems') && booking.get('orderItems')!=null && booking.get('orderItems')!='')
                {
                    list<object> orderItemsList = (list<object>)booking.get('orderItems');
                    list<WFT_GFT__c> listWFTGFT = new list<WFT_GFT__c>();
                    
                    if(!orderItemsList.isEmpty())
                    {
                        list<Order_Items__c> orderItems = new list<Order_Items__c>();
                        ProcessExceptionTableName = 'orderItems';
                        for(object orderItemsValue: orderItemsList)
                        {
                            map<string,object> orIt = (map<string,object>)(orderItemsValue);
                            Order_Items__c orderIt = new Order_Items__c();
                            
                            if(orIt.KeySet().contains('id') && orIt.get('id')!=null && orIt.get('id')!='')
                            {
                                
                                orderIt.ID__c = string.valueof(orIt.get('id'));
                                orderIt.Name = string.valueof(orIt.get('id'));
                                ProcessExceptionId = orderIt.ID__c;
                                orderItemIds.add(orderIt.ID__c);
                                if(orIt.KeySet().contains('item_type') && string.isNotBlank(string.valueof(orIt.get('item_type'))) && string.valueof(orIt.get('item_type'))=='BUS')
                                {
                                    orderIt.Item_Type__c = string.valueof(orIt.get('item_type'));
                               
                                    if(orIt.KeySet().contains('order_id') && orIt.get('order_id')!=null && orIt.get('order_id')!='')
                                    {
                                        orderitemOrdersMap.put(string.valueof(orIt.get('order_id')),string.valueof(orIt.get('order_id')));
                                        orderItemDojMap.put(string.valueof(orIt.get('id')),string.valueof(orIt.get('id')));
                                        allOrdersids.add(string.valueof(orIt.get('order_id')));
                                        allOrderItemids.add(string.valueof(orIt.get('id')));
                                        filterOrderIds.add(string.valueof(orIt.get('order_id')));
                                    }
                                    
                                }
                                
                                if(orIt.KeySet().contains('business_unit') && orIt.get('business_unit')!=null && orIt.get('business_unit')!='')
                                {
                                    orderIt.Business_Unit__c = string.valueof(orIt.get('business_unit'));
                                }
                                
                                if(orIt.KeySet().contains('additional_details') && orIt.get('additional_details')!=null && orIt.get('additional_details')!='')
                                {
                                    orderIt.Additional_Details__c = string.valueof(orIt.get('additional_details'));
                                }
                                if(orIt.KeySet().contains('created_by') && orIt.get('created_by')!=null && orIt.get('created_by')!='')
                                {
                                    orderIt.Created_By__c = string.valueof(orIt.get('created_by'));
                                }
                                if(orIt.KeySet().contains('creation_time') && !string.isBlank(string.valueof(orIt.get('creation_time'))))
                                {
                                    if(string.valueof(orIt.get('creation_time')).contains('T'))
                                    {
                                        orderIt.Creation_Time__c = datetime.valueof(string.valueof(orIt.get('creation_time')).replace('T',' '));
                                    }
                                    else
                                    {
                                        orderIt.Creation_Time__c = datetime.valueof((string)orIt.get('creation_time'));
                                    }
                                }
                                
                                if(orIt.KeySet().contains('seatadditionalDetails') && string.isNotBlank(string.valueof(orIt.get('seatadditionalDetails'))))
                                {
                                    orderIt.Seatadditionaldetails__c = string.valueof(orIt.get('seatadditionalDetails'));
                                    map<string,object> seatdetailsInfo = (map<string,object>)JSON.deserializeUntyped(orderIt.Seatadditionaldetails__c);
                                    
                                    if(seatdetailsInfo.KeySet().contains('31') && string.isNotBlank(string.valueof(seatdetailsInfo.get('31'))))
                                        orderIt.RUC_Address__c = string.valueof(seatdetailsInfo.get('31'));
                                    
                                    if(seatdetailsInfo.KeySet().contains('30') && String.isNotBlank(String.valueOf(seatdetailsInfo.get('30'))))
                                        orderIt.RUC_Reason__c = string.valueof(seatdetailsInfo.get('30'));
                                    
                                    if(seatdetailsInfo.KeySet().contains('29') && string.isNotBlank(string.valueof(seatdetailsInfo.get('29'))))
                                        orderIt.RUC_Number__c = string.valueof(seatdetailsInfo.get('29'));
                                }
                                
                                if(orIt.KeySet().contains('OldTin') && string.isNotBlank(string.valueof(orIt.get('OldTin'))))
                                    orderIt.Old_Order_Item_Reference_No__c = string.valueof(orIt.get('OldTin'));
                                
                                if(orIt.KeySet().contains('reschedulingFor') && string.isNotBlank(string.valueof(orIt.get('reschedulingFor'))))
                                    orderIt.Rescheduling_For__c = string.valueof(orIt.get('reschedulingFor'));
                                
                                if(orIt.KeySet().contains('cancellationReason') && string.isNotBlank(string.valueof(orIt.get('cancellationReason'))))
                                    orderIt.Cancellation_Reason__c = string.valueof(orIt.get('cancellationReason'));
                                
                                if(orIt.KeySet().contains('rescheduledTo') && string.isNotBlank(string.valueof(orIt.get('rescheduledTo'))))
                                    orderIt.RescheduledTo__c = string.valueof(orIt.get('rescheduledTo'));
                                
                                if(orIt.KeySet().contains('transaction_source') && orIt.get('transaction_source')!=null && orIt.get('transaction_source')!='')
                                    orderIt.Transaction_Source__c = string.valueof(orIt.get('transaction_source'));
                                
                                if(orIt.KeySet().contains('updated_by') && orIt.get('updated_by')!=null && orIt.get('updated_by')!='')
                                    orderIt.Updated_By__c = string.valueof(orIt.get('updated_by'));
                                
                                if(orIt.KeySet().contains('version') && orIt.get('version')!=null && orIt.get('version')!='')
                                    orderIt.Version__c = integer.valueof(orIt.get('version'));
                                
                                if(orIt.KeySet().contains('amount_recieved_currency') && orIt.get('amount_recieved_currency')!=null && orIt.get('amount_recieved_currency')!='')
                                    orderIt.Amount_Recieved_Currency__c = string.valueof(orIt.get('amount_recieved_currency'));
                                
                                if(orIt.KeySet().contains('business_unit_conversion_currency') && orIt.get('business_unit_conversion_currency')!=null && orIt.get('business_unit_conversion_currency')!='')
                                    orderIt.Business_Unit_Conversion_Currency__c = string.valueof(orIt.get('business_unit_conversion_currency'));
                                
                                if(orIt.KeySet().contains('cancellation_time') && !string.isBlank(string.valueof(orIt.get('cancellation_time'))))
                                {
                                    System.debug('Cancellation_Time__c...'+orIt.get('cancellation_time'));
                                    if(string.valueof(orIt.get('cancellation_time')).contains('T'))
                                    {
                                        orderIt.Cancellation_Time__c = datetime.valueof(string.valueof(orIt.get('cancellation_time')).replace('T',' '));
                                    }
                                    else
                                    {
                                        orderIt.Cancellation_Time__c = datetime.valueof((String)orIt.get('cancellation_time'));
                                    }
                                    
                                }
                                if(orIt.KeySet().contains('child_purchase_item_id') && orIt.get('child_purchase_item_id')!=null && orIt.get('child_purchase_item_id')!='')
                                    orderIt.Child_Purchase_Item_ID__c = string.valueof(orIt.get('child_purchase_item_id'));
                                
                                if(orIt.KeySet().contains('date_of_service') && orIt.get('date_of_service')!=null && orIt.get('date_of_service')!='')
                                {
                                    if(string.valueof(orIt.get('date_of_service')).contains('T'))
                                        orderIt.Date_Of_Service__c = datetime.valueof(string.valueof(orIt.get('date_of_service')).replace('T',' '));
                                    
                                    else        
                                        orderIt.Date_Of_Service__c = datetime.valueof((string)orIt.get('date_of_service'));
                                    
                                }
                                
                                if(orIt.KeySet().contains('discount_currency') && orIt.get('discount_currency')!=null && orIt.get('discount_currency')!='')
                                {
                                    orderIt.Discount_Currency__c = string.valueof(orIt.get('discount_currency'));
                                }
                                
                                if(orIt.KeySet().contains('inventory_id') && orIt.get('inventory_id')!=null && orIt.get('inventory_id')!='')
                                {
                                    orderIt.Inventory_ID__c = string.valueof(orIt.get('inventory_id'));
                                }
                                if(orIt.KeySet().contains('serviceId') && orIt.get('serviceId')!=null && orIt.get('serviceId')!='')
                                {
                                    orderIt.ServiceID__c = string.valueof(orIt.get('serviceId'));
                                }
                                
                                if(orIt.KeySet().contains('order_id') && orIt.get('order_id')!=null && orIt.get('order_id')!='')
                                {
                                    orderIt.Order_Id__c = string.valueof(orIt.get('order_id'));
                                    if(!'CANCELLATIONANDREFUNDS'.equalsIgnoreCase(dbl.Type__c))
                                    {
                                        Orders__c ords = new Orders__c();
                                        ords.id__c =  orderIt.Order_Id__c;
                                        orderIt.Order_Name__r = ords;
                                    }
                                    
                                }
                                if(orIt.KeySet().contains('order_item_reference_no') && orIt.get('order_item_reference_no')!=null && orIt.get('order_item_reference_no')!='')
                                {
                                    orderIt.Order_Item_Reference_No__c = string.valueof(orIt.get('order_item_reference_no'));
                                }
                                if(orIt.KeySet().contains('parent_purchase_item_id') && orIt.get('parent_purchase_item_id')!=null && orIt.get('parent_purchase_item_id')!='')
                                {
                                    orderIt.Parent_Purchase_Item_ID__c = string.valueof(orIt.get('parent_purchase_item_id'));
                                }
                                if(orIt.KeySet().contains('payment_currency') && orIt.get('payment_currency')!=null && orIt.get('payment_currency')!='')
                                {
                                    orderIt.Payment_Currency__c = string.valueof(orIt.get('payment_currency'));
                                }
                                if(orIt.KeySet().contains('primary_passenger_id') && orIt.get('primary_passenger_id')!=null && orIt.get('primary_passenger_id')!='')
                                {
                                    orderIt.Primary_Passenger_Id__c = string.valueof(orIt.get('primary_passenger_id'));
                                    if(!string.isBlank(string.valueof(orderIt.id__c)) && orderItemDojMap.KeySet().Contains(orderIt.id__c))
                                    {
                                        primaryCustomerIds.put(string.valueof(orIt.get('primary_passenger_id')),string.valueof(orIt.get('primary_passenger_id')));
                                        System.debug('primaryCustomerIds..'+primaryCustomerIds);
                                    }
                                }
                                if(orIt.KeySet().contains('purchase_item_currency') && orIt.get('purchase_item_currency')!=null && orIt.get('purchase_item_currency')!='')
                                {
                                    orderIt.Purchase_Item_Currency__c = string.valueof(orIt.get('purchase_item_currency'));
                                }
                                if(orIt.KeySet().contains('service_provider_name') && orIt.get('service_provider_name')!=null && orIt.get('service_provider_name')!='')
                                {
                                    orderIt.Service_Provider_Name__c = string.valueof(orIt.get('service_provider_name'));
                                }
                                if(orIt.KeySet().contains('service_provider_id') && orIt.get('service_provider_id')!=null && orIt.get('service_provider_id')!='')
                                {
                                    Service_Provider__c serpro = new Service_Provider__c();
                                    serpro.Operator_Id__c = string.valueof(orIt.get('service_provider_id'));
                                    
                                    if(String.isNotBlank(orderIt.Service_Provider_Name__c))
                                    {
                                        if(String.valueOf(orderIt.Service_Provider_Name__c).length()>80)
                                        {
                                            serpro.name =  string.valueof(orderIt.Service_Provider_Name__c).substring(0,80);
                                        }
                                        else
                                        {
                                            serpro.name =  orderIt.Service_Provider_Name__c;
                                        }
                                        serpro.TravelsFullName__c = string.valueof(orIt.get('service_provider_name'));
                                    }
                                    else
                                    {
                                        serpro.name =  'NA';
                                        serpro.TravelsFullName__c = 'NA';
                                    }
                                    serviceProvider.put(serpro.Operator_Id__c,serpro);
                                    orderIt.Service_Provider_Id__c = string.valueof(orIt.get('service_provider_id'));
                                    orderIt.Service_Provider_Info__r = new Service_Provider__c(Operator_Id__c = orderIt.Service_Provider_Id__c); 
                                }
                                
                                if(orIt.KeySet().contains('status') && orIt.get('status')!=null && orIt.get('status')!='')
                                {
                                    orderIt.status__c = string.valueof(orIt.get('status'));
                                }
                                if(orIt.KeySet().contains('sub_item_count') && orIt.get('sub_item_count')!=null && orIt.get('sub_item_count')!='')
                                {
                                    orderIt.Sub_Item_Count__c = integer.valueof(orIt.get('sub_item_count'));
                                }
                                if(orIt.KeySet().contains('tentative_key') && orIt.get('tentative_key')!=null && orIt.get('tentative_key')!='')
                                {
                                    orderIt.Tentative_Key__c = string.valueof(orIt.get('tentative_key'));
                                }
                                if(orIt.KeySet().contains('total_fare_currency') && orIt.get('total_fare_currency')!=null && orIt.get('total_fare_currency')!='')
                                {
                                    orderIt.Total_Fare_Currency__c = string.valueof(orIt.get('total_fare_currency'));
                                }
                                if(orIt.KeySet().contains('total_fare_value') && orIt.get('total_fare_value')!=null && orIt.get('total_fare_value')!='')
                                {
                                    orderIt.Total_Fare_Value__c = double.valueof(orIt.get('total_fare_value'));
                                }
                                if(orIt.KeySet().contains('total_tax_currency') && orIt.get('total_tax_currency')!=null && orIt.get('total_tax_currency')!='')
                                {
                                    orderIt.Total_Tax_Currency__c = string.valueof(orIt.get('total_tax_currency'));
                                }
                                
                                if(orIt.KeySet().contains('insuranceCharge') && orIt.get('insuranceCharge')!=null && orIt.get('insuranceCharge')!='')
                                {
                                    orderIt.Insurance_Charges__c = double.valueof(orIt.get('insuranceCharge'));
                                }
                                
                                if(orIt.KeySet().contains('amenities') && orIt.get('amenities')!=null && orIt.get('amenities')!='')
                                {
                                    orderIt.Amenities__c = String.valueof(orIt.get('amenities'));
                                }
                                
                                if(orIt.KeySet().contains('pkgId') && orIt.get('pkgId')!=null && orIt.get('pkgId')!='')
                                {
                                    orderIt.Package_Id__c= String.valueof(orIt.get('pkgId'));
                                }
                                if(orIt.KeySet().contains('pkgName') && orIt.get('pkgName')!=null && orIt.get('pkgName')!='')
                                {
                                    orderIt.Package_Name__c= String.valueof(orIt.get('pkgName'));
                                }
                                
                                if(orIt.KeySet().contains('service_provider_reference_no') && orIt.get('service_provider_reference_no')!=null && orIt.get('service_provider_reference_no')!='')
                                {
                                    orderIt.Service_Provider_Reference_No__c = string.valueof(orIt.get('service_provider_reference_no'));
                                    if(string.valueof(orIt.get('service_provider_reference_no')).length()>255)
                                    {
                                        orderIt.Service_Provider_Reference_PNR_No__c = string.valueof(orIt.get('service_provider_reference_no')).substring(0,255);
                                    }
                                    else
                                    {
                                        orderIt.Service_Provider_Reference_PNR_No__c = string.valueof(orIt.get('service_provider_reference_no'));
                                    }
                                }
                                if(orIt.KeySet().contains('creation_time_long') && orIt.get('creation_time_long')!=null && orIt.get('creation_time_long')!='')
                                {
                                    orderIt.Creation_Time_Long__c = string.valueof(orIt.get('creation_time_long'));
                                }
                                if(orIt.KeySet().contains('date_of_service_long') && orIt.get('date_of_service_long')!=null && orIt.get('date_of_service_long')!='')
                                {
                                    orderIt.Date_Of_Service_Long__c = string.valueof(orIt.get('date_of_service_long'));
                                }
                                if(orIt.KeySet().contains('conversionRate') && orIt.get('conversionRate')!=null && orIt.get('conversionRate')!='')
                                {
                                    orderIt.ConversionRate__c = double.valueof(orIt.get('conversionRate'));
                                }
                                
                                if(orIt.KeySet().contains('inventory_type') && orIt.get('inventory_type')!=null && orIt.get('inventory_type')!='')
                                {
                                    orderIt.Inventory_Type__c = string.valueof(orIt.get('inventory_type'));
                                }
                                
                                if(orIt.KeySet().contains('email') && orIt.get('email')!=null && orIt.get('email')!='')
                                {
                                    if(string.valueof(orIt.get('email')).length()<255)
                                    {
                                        orderIt.Email_Copy__c = string.valueof(orIt.get('email'));
                                    }
                                    else
                                    {
                                        orderIt.Email_Copy__c = string.valueof(orIt.get('email')).substring(0,255);
                                    }
                                    if(!string.valueof(orIt.get('email')).contains(' ')&&validateEmail(string.valueof(orIt.get('email')))==true)
                                    {
                                        orderIt.Email__c = string.valueof(orIt.get('email'));
                                    }
                                }
                                if(orIt.KeySet().contains('mobile') && orIt.get('mobile')!=null && orIt.get('mobile')!='')
                                {
                                    orderIt.Mobile__c = string.valueof(orIt.get('mobile'));
                                    
                                        account acc = new account();
                                        acc.AccountSource = 'OrderItem';
                                        acc.lastname = string.valueof(orIt.get('mobile'));
                                        acc.PersonMobilePhone = string.valueof(orIt.get('mobile'));
                                        If(String.isNotBlank(orderIt.Business_Unit__c) && BusinessUnitMapping__c.getValues(orderIt.Business_Unit__c)!=null)
                                            acc.CountryCode__c = String.valueOf(BusinessUnitMapping__c.getValues(orderIt.Business_Unit__c).Country__c);
                                        
                                        primaryPhoneNumbers.add(acc.PersonMobilePhone);
                                        System.debug('primaryPhoneNumbers..'+primaryPhoneNumbers);
                                        if(orIt.KeySet().contains('email') && !string.isBlank(string.valueof(orIt.get('email'))))
                                        {
                                            if(string.valueof(orIt.get('email')).length()<255)
                                            {
                                                acc.Email_Copy__c = string.valueof(orIt.get('email'));
                                            }
                                            else
                                            {
                                                acc.Email_Copy__c = string.valueof(orIt.get('email')).substring(0,255);
                                            }
                                            if(!string.valueof(orIt.get('email')).contains(' ')&& validateEmail(string.valueof(orIt.get('email')))==true)
                                            {
                                                acc.PersonEmail = string.valueof(orIt.get('email'));
                                                orItemprimaryEmails.add(acc.PersonEmail);
                                                
                                            }
                                        }
                                        custListOr.add(acc);
                                        mapOrderItemsTravelsAccs.put(acc.PersonMobilePhone,acc);
                                        System.debug('custListOr..'+custListOr);
                                    }
                                    
                                }
                                if(orIt.KeySet().contains('receivable_amount_value') && orIt.get('receivable_amount_value')!=null && orIt.get('receivable_amount_value')!='')
                                {
                                    orderIt.Receivable_Amount_Value__c = double.valueof(orIt.get('receivable_amount_value'));
                                }
                                if(orIt.KeySet().contains('receivable_amount_currency') && orIt.get('receivable_amount_currency')!=null && orIt.get('receivable_amount_currency')!='')
                                {
                                    orderIt.Receivable_Amount_Currency__c = string.valueof(orIt.get('receivable_amount_currency'));
                                }
                                if(orIt.KeySet().contains('view_details') && orIt.get('view_details')!=null && orIt.get('view_details')!='')
                                {
                                    orderIt.View_Details__c = string.valueof(orIt.get('view_details'));
                                }
                                
                                if(orIt.KeySet().contains('date_of_purchase') && orIt.get('date_of_purchase')!=null && orIt.get('date_of_purchase')!='')
                                {
                                    if(string.valueof(orIt.get('date_of_purchase')).contains('T'))
                                        orderIt.Date_Of_Purchase__c = datetime.valueof(string.valueof(orIt.get('date_of_purchase')).replace('T',' '));
                                    
                                    else
                                        orderIt.Date_Of_Purchase__c = datetime.valueof((string)orIt.get('date_of_purchase'));
                                    
                                }
                                
                                if(orIt.KeySet().contains('guid') && orIt.get('guid')!=null && orIt.get('guid')!='')
                                {
                                    orderIt.Guid__c = string.valueof(orIt.get('guid'));
                                }
                                if(orIt.KeySet().contains('tentative_details') && orIt.get('tentative_details')!=null && orIt.get('tentative_details')!='')
                                {
                                    orderIt.Tentative_Details__c = string.valueof(orIt.get('tentative_details'));
                                }
                                if(orIt.KeySet().contains('rb_user_Id') && orIt.get('rb_user_Id')!=null && orIt.get('rb_user_Id')!='')
                                {
                                    orderIt.Rb_User_ID__c = string.valueof(orIt.get('rb_user_Id'));
                                }
                                if(orIt.KeySet().contains('client_ip') && orIt.get('client_ip')!=null && orIt.get('client_ip')!='')
                                {
                                    orderIt.Client_Ip__c = string.valueof(orIt.get('client_ip'));
                                }
                                if(orIt.KeySet().contains('cancellation_policy') && orIt.get('cancellation_policy')!=null && orIt.get('cancellation_policy')!='')
                                {
                                    orderIt.Cancellation_Policy__c = string.valueof(orIt.get('cancellation_policy'));
                                }
                                
                                if(orIt.KeySet().contains('agent_ip') && orIt.get('agent_ip')!=null && orIt.get('agent_ip')!='')
                                {
                                    orderIt.Agent_IP__c = string.valueof(orIt.get('agent_ip'));
                                }
                                if(orIt.KeySet().contains('isreturn') && orIt.get('isreturn')!=null && orIt.get('isreturn')!='')
                                {
                                    orderIt.isreturn__c = boolean.valueof(orIt.get('isreturn'));
                                }
                                if(orIt.KeySet().contains('transaction_charge') && orIt.get('transaction_charge')!=null && orIt.get('transaction_charge')!='')
                                {
                                    orderIt.Transaction_Charge__c = double.valueof(orIt.get('transaction_charge'));
                                }
                                
                                if(orIt.KeySet().contains('total_fare_paid_to_operator') && orIt.get('total_fare_paid_to_operator')!=null && orIt.get('total_fare_paid_to_operator')!='')
                                {
                                    orderIt.Total_Fare_Paid_To_Operator__c = double.valueof(orIt.get('total_fare_paid_to_operator'));
                                }
                                if(orIt.KeySet().contains('exp_time') && orIt.get('exp_time')!=null && orIt.get('exp_time')!='')
                                {
                                    if(string.valueof(orIt.get('exp_time')).contains('T'))
                                    {
                                        orderIt.Exp_Time__c = datetime.valueof(string.valueof(orIt.get('exp_time')).replace('T',' '));
                                    }
                                    else
                                    {
                                        orderIt.Exp_Time__c = datetime.valueof((string)orIt.get('exp_time'));
                                    }
                                }
                                
                                if(orIt.KeySet().contains('Is_partial_cancellation_allowed') && orIt.get('Is_partial_cancellation_allowed')!=null && orIt.get('Is_partial_cancellation_allowed')!='')
                                {
                                    orderIt.Is_Partial_Cancellation_Allowed__c = boolean.valueof(orIt.get('Is_partial_cancellation_allowed'));
                                }
                                if(orIt.KeySet().contains('operator_cancellation_charges') && orIt.get('operator_cancellation_charges')!=null && orIt.get('operator_cancellation_charges')!='')
                                {
                                    orderIt.Operator_Cancellation_Charges__c = double.valueof(orIt.get('operator_cancellation_charges'));
                                }
                                if(orIt.KeySet().contains('force_cancelled') && orIt.get('force_cancelled')!=null && orIt.get('force_cancelled')!='')
                                {
                                    orderIt.Force_Cancelled__c = boolean.valueof(orIt.get('force_cancelled'));
                                }
                                if(orIt.KeySet().contains('confirm_time') && orIt.get('confirm_time')!=null && orIt.get('confirm_time')!='')
                                {
                                    orderIt.Ticket_Confirmed_Time__c = datetime.valueof(string.valueof(orIt.get('confirm_time')));
                                    
                                }                       
                                if(orIt.KeySet().contains('isExceptionalBusCancellation') && orIt.get('isExceptionalBusCancellation')!=null && orIt.get('isExceptionalBusCancellation')!='')
                                {
                                    orderIt.is_Exceptional_BusCancellation__c= boolean.valueof(orIt.get('isExceptionalBusCancellation'));
                                    
                                }
                                
                                if(orIt.KeySet().contains('isMIMBooking') && orIt.get('isMIMBooking')!=null && orIt.get('isMIMBooking')!='')
                                {
                                    orderIt.isMIM_Booking__c= boolean.valueof(orIt.get('isMIMBooking'));
                                    
                                }
                                if(orIt.KeySet().contains('isReschedulable') && orIt.get('isReschedulable')!=null && orIt.get('isReschedulable')!='')
                                {
                                    orderIt.isReschedulable__c= boolean.valueof(orIt.get('isReschedulable'));                            
                                }
                                if(orIt.KeySet().contains('boardingPointId') && orIt.get('boardingPointId')!=null && orIt.get('boardingPointId')!='')
                                {
                                    orderIt.Boarding_Point_Id__c= string.valueof(orIt.get('boardingPointId'));                            
                                }
                                if(orIt.KeySet().contains('identityProofs') && orIt.get('identityProofs')!=null && orIt.get('identityProofs')!='')
                                {
                                    orderIt.Identity_Proofs__c= string.valueof(orIt.get('identityProofs'));                            
                                }
                                if(orIt.KeySet().contains('primaryProofId') && orIt.get('primaryProofId')!=null && orIt.get('primaryProofId')!='')
                                {
                                    orderIt.Primary_Proof_Id__c= string.valueof(orIt.get('primaryProofId'));                            
                                }
                                if(orIt.KeySet().contains('primaryProofType') && orIt.get('primaryProofType')!=null && orIt.get('primaryProofType')!='')
                                {
                                    orderIt.Primary_Proof_Type__c= string.valueof(orIt.get('primaryProofType'));                            
                                }
                                if(orIt.KeySet().contains('primaryProofName') && orIt.get('primaryProofName')!=null && orIt.get('primaryProofName')!='')
                                {
                                    orderIt.Primary_Proof_Name__c= string.valueof(orIt.get('primaryProofName'));                            
                                }
                                
                                if(orIt.KeySet().contains('live_operator_force_cancel_status') && orIt.get('live_operator_force_cancel_status')!=null && orIt.get('live_operator_force_cancel_status')!='')
                                {
                                    orderIt.live_Operator_Force_Cancel_Status__c = string.valueof(orIt.get('live_operator_force_cancel_status'));
                                }
                                if(orIt.KeySet().contains('flag') && !string.isBlank(string.valueof(orIt.get('flag'))))
                                {
                                    orderIt.Flag__c = double.valueof(orIt.get('flag'));
                                }
                                if(orIt.KeySet().contains('accountHolderName') && !string.isBlank(string.valueof(orIt.get('accountHolderName'))))
                                {
                                    orderIt.Account_Holder_Name__c = String.valueof(orIt.get('accountHolderName'));
                                }
                                if(orIt.KeySet().contains('bankAccountNumber') && !string.isBlank(string.valueof(orIt.get('bankAccountNumber'))))
                                {
                                    orderIt.Bank_Account_Number__c = String.valueof(orIt.get('bankAccountNumber'));
                                }
                                if(orIt.KeySet().contains('bankName') && !string.isBlank(string.valueof(orIt.get('bankName'))))
                                {
                                    orderIt.Bank_Name__c = String.valueof(orIt.get('bankName'));
                                }
                                if(orIt.KeySet().contains('insuranceProviderName') && !string.isBlank(string.valueof(orIt.get('insuranceProviderName'))))
                                {
                                    orderIt.Insurance_Provider__c = String.valueof(orIt.get('insuranceProviderName'));
                                }
                                
                                if(orIt.KeySet().contains('paymentDetails') && string.isNotBlank(string.valueof(orIt.get('paymentDetails'))))
                                {
                                    orderIt.Payment_Details__c = String.valueof(orIt.get('paymentDetails'));
                                }
                                
                                if(orIt.KeySet().contains('order_uuid') && string.isNotBlank(string.valueof(orIt.get('order_uuid'))))
                                {
                                    orderIt.OrderUuid__c = String.valueof(orIt.get('order_uuid'));
                                }
                                
                                if(orIt.KeySet().contains('droppingTime') && string.isNotBlank(string.valueof(orIt.get('droppingTime'))))
                                {
                                    if(string.valueof(orIt.get('droppingTime')).contains('T'))
                                    {
                                        orderIt.Dropping_Time__c = datetime.valueof(string.valueof(orIt.get('droppingTime')).replace('T',' '));
                                    }
                                    else
                                    {
                                        orderIt.Dropping_Time__c = datetime.valueof((string)orIt.get('droppingTime'));
                                    }
                                }
                                
                                if(orIt.KeySet().contains('bplandmark') && string.isNotBlank(string.valueof(orIt.get('bplandmark'))))
                                {
                                    orderIt.BP_LandMark__c = String.valueof(orIt.get('bplandmark'));
                                }
                                
                                if(orIt.KeySet().contains('boarding_point') && string.isNotBlank(string.valueof(orIt.get('boarding_point'))))
                                {
                                    orderIt.Boarding_Point__c  = string.valueof(orIt.get('boarding_point'));
                                }
                                
                                if(orIt.KeySet().contains('bus_type') && string.isNotBlank(string.valueof(orIt.get('bus_type'))))
                                {
                                    orderIt.Bus_Type__c = string.valueof(orIt.get('bus_type'));
                                }
                                
                                if(orIt.KeySet().contains('destination_city') && string.isNotBlank(string.valueof(orIt.get('destination_city'))))
                                {
                                    orderIt.Destination__c = string.valueof(orIt.get('destination_city'));
                                }
                                
                                if(orIt.KeySet().contains('source_city') && string.isNotBlank(string.valueof(orIt.get('source_city'))))
                                {
                                    orderIt.Source__c = string.valueof(orIt.get('source_city'));
                                }
                                
                                if(orIt.KeySet().contains('dropping_point') && string.isNotBlank(string.valueof(orIt.get('dropping_point'))))
                                {
                                    orderIt.Dropping_Point__c = string.valueof(orIt.get('dropping_point'));
                                }
                                
                                if(orIt.KeySet().contains('seat_no') && string.isNotBlank(string.valueof(orIt.get('seat_no'))))
                                {
                                    orderIt.Seat_No__c = string.valueof(orIt.get('seat_no'));
                                }
                                
                                if(orIt.KeySet().contains('route_id') && string.isNotBlank(string.valueof(orIt.get('route_id'))))
                                {
                                    orderIt.Route_ID__c = string.valueof(orIt.get('route_id'));
                                }
                                                                
                                if(orIt.KeySet().contains('boarding_time') && !string.isBlank(string.valueof(orIt.get('boarding_time'))))
                                {
                                    if(string.valueof(orIt.get('boarding_time')).contains('T'))
                                    {
                                        orderIt.Boarding_Time__c = datetime.valueof(string.valueof(orIt.get('boarding_time')).replace('T',' '));
                                    }
                                    else
                                    {
                                        orderIt.Boarding_Time__c = datetime.valueof((string)orIt.get('boarding_time'));
                                    }
                                }
                                
                                if(orIt.KeySet().contains('primary_boarding_time') && !string.isBlank(string.valueof(orIt.get('primary_boarding_time'))))
                                {
                                    if(string.valueof(orIt.get('primary_boarding_time')).contains('T'))
                                    {
                                        orderIt.Primary_Boarding_Point_Time__c = datetime.valueof(string.valueof(orIt.get('primary_boarding_time')).replace('T',' '));
                                    }
                                    else
                                    {
                                        orderIt.Primary_Boarding_Point_Time__c = datetime.valueof((string)orIt.get('primary_boarding_time'));
                                    }
                                }                               
                                
                                WFT_GFT__c WG = new WFT_GFT__c();
                                WG.ID__c = orderIt.id__c;
                                WG.Transaction_Name__r = new Order_Items__c(id__c=orderIt.id__c);
                                listWFTGFT.add(WG);
                                /*
                                if(orIt.KeySet().contains('updated_time') && !string.isBlank(string.valueof(orIt.get('updated_time'))))
                                {
                                if(string.valueof(orIt.get('updated_time')).contains('T'))
                                {
                                orderIt.Updated_Time__c = datetime.valueof(string.valueof(orIt.get('updated_time')).replace('T',' '));
                                }
                                else
                                {
                                orderIt.Updated_Time__c = datetime.valueof((string)orIt.get('updated_time'));
                                }
                                if(oitrMap.KeySet().Contains(orderIt.Business_Unit__c) && !string.isBlank(string.valueof(oitrMap.get(orderIt.Business_Unit__c).UTC_time_difference_in_min__c)))
                                {
                                orderIt.Updated_Time__c = orderIt.Updated_Time__c.addMinutes(integer.valueof(oitrMap.get(orderIt.Business_Unit__c).UTC_time_difference_in_min__c));
                                } 
                                }

                                if(orIt.KeySet().contains('amount_recieved_value') && orIt.get('amount_recieved_value')!=null && orIt.get('amount_recieved_value')!='')
                                {
                                orderIt.Amount_Recieved_Value__c = double.valueof(orIt.get('amount_recieved_value'));
                                }
                                if(orIt.KeySet().contains('business_unit_conversion_value') && orIt.get('business_unit_conversion_value')!=null && orIt.get('business_unit_conversion_value')!='')
                                {
                                orderIt.Business_Unit_Conversion_Value__c = double.valueof(orIt.get('business_unit_conversion_value'));
                                }
                                if(orIt.KeySet().contains('discount_value') && orIt.get('discount_value')!=null && orIt.get('discount_value')!='')
                                {
                                orderIt.Discount_Value__c = double.valueof(orIt.get('discount_value'));
                                }
                                if(orIt.KeySet().contains('total_tax_value') && orIt.get('total_tax_value')!=null && orIt.get('total_tax_value')!='')
                                {
                                orderIt.Total_Tax_Value__c = double.valueof(orIt.get('total_tax_value'));
                                }
                                if(orIt.KeySet().contains('markupValue') && orIt.get('markupValue')!=null && orIt.get('markupValue')!='')
                                {
                                orderIt.MarkupValue__c = double.valueof(orIt.get('markupValue'));
                                }
                                if(orIt.KeySet().contains('conversion_info') && orIt.get('conversion_info')!=null && orIt.get('conversion_info')!='')
                                {
                                orderIt.Conversion_Info__c = string.valueof(orIt.get('conversion_info'));
                                }
                                if(orIt.KeySet().contains('old_order_item_reference_no') && orIt.get('old_order_item_reference_no')!=null && orIt.get('old_order_item_reference_no')!='')
                                {
                                orderIt.Old_Order_Item_Reference_No__c = string.valueof(orIt.get('old_order_item_reference_no'));
                                }
                                if(orIt.KeySet().contains('spot_cancel_time_minutes') && orIt.get('spot_cancel_time_minutes')!=null && orIt.get('spot_cancel_time_minutes')!='')
                                {
                                orderIt.Spot_Cancel_Time_Minutes__c = string.valueof(orIt.get('spot_cancel_time_minutes'));
                                }
                                */
                                orderItems.add(orderIt);
                            }
                    
                    if(!serviceProvider.isempty())
                    {
                        Database.UpsertResult[] upsertResult1 =Database.upsert(serviceProvider.values(),Service_Provider__c.Operator_Id__c,false);
                    }
                    if(!orderItems.isEmpty())
                    {
                        Database.UpsertResult[] upsertResult = Database.upsert(orderItems,Order_Items__c.ID__c,false);
                        list<string> SuccessList = new list<string>();
                        list<string> FailedList = new list<string>();
                        list<string> FailedDesscList = new list<string>();
                        for(Integer i=0;i<upsertResult.size();i++)
                        {
                            
                            if (upsertResult.get(i).isSuccess())
                            {
                                SuccessList.add(orderItemIds[i]);
                            }
                            else if(!upsertResult.get(i).isSuccess())
                            {
                                DBLog.add(prepareDBLog('OrderItems',string.valueof(orderItemIds[i]),string.valueof(upsertResult.get(i).getErrors())));
                                FailedList.add(orderItemIds[i]);
                                FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                                orderItemFailedPro.add(JSON.Serialize(orderItems[i]));
                            }
                        }
                        resp.orderItemsSuccess = SuccessList;
                        resp.orderItemsSuccessCount = SuccessList.size();
                        resp.orderItemsFailed = FailedList;
                        resp.orderItemsFailedCount = FailedList.size();
                        resp.orderItemsFailDescription = FailedDesscList;
                        if(orderItems.size()==SuccessList.size())
                        {
                            resp.orderItemsProcessStatus = 'Success';
                        }
                        else
                            if(orderItems.size()==FailedList.size())
                        {
                            resp.orderItemsProcessStatus = 'Fail';
                        }
                        else
                        {
                            resp.orderItemsProcessStatus = 'Partial';
                        }
                        
                        setSuccessOritems.addAll(SuccessList); //Added By Sreenivas M
                        
                        dbl.Order_Items_Success__c = string.join(SuccessList,',');
                        dbl.Order_Items_Success_Count__c = SuccessList.size();
                        dbl.Order_Items_Failed__c = string.join(FailedList,',');
                        dbl.Order_Items_Failed_Count__c = FailedList.size();
                        if( !string.isBlank(string.valueof(string.join(FailedDesscList,','))) && string.valueof(string.join(FailedDesscList,',')).length()>25000)
                        {
                            dbl.Order_Items_Fail_Description__c = string.valueof(string.join(FailedDesscList,',')).substring(0,24000);
                        }
                        else
                        {
                            dbl.Order_Items_Fail_Description__c = string.join(FailedDesscList,',');
                        }
                        
                        dbl.Order_Items_Process_Status__c = resp.orderItemsProcessStatus;
                        
                    }
                    if(!listWFTGFT.isEmpty())
                    {
                        Database.upsert(listWFTGFT,WFT_GFT__c.ID__c,false);
                    }
                    
                    orderItems.clear();
                }
                }
                /*--------------------------OrderItems End---------------------------------------------*/
                
                /*--------------------------PaymentItems Start---------------------------------------------*/
                if(booking.KeySet().contains('paymentItems') && !string.isBlank(string.valueof(booking.get('paymentItems'))))
                {
                    list<object> PayItemList = (list<object>)booking.get('paymentItems');
                    if(!PayItemList.isEmpty())
                    {
                        list<Payment_Items__c> PaymentItems = new list<Payment_Items__c>();
                        list<WFT_GFT_Payment__c> listWFTGFTPayments = new list<WFT_GFT_Payment__c>();
                        ProcessExceptionTableName = 'paymentItems';
                        for(object PayValue: PayItemList)
                        {
                            map<string,object> PayIt = (map<string,object>)(PayValue);
                            Payment_Items__c PayItem = new Payment_Items__c();
                            string BusinessUnit;
                            if(PayIt.KeySet().contains('order_id') && !string.isBlank(string.valueof(PayIt.get('order_id'))))
                            {
                                PayItem.Order_ID__c = string.valueof(PayIt.get('order_id'));
                                Orders__c ords = new Orders__c();
                                ords.id__c =  PayItem.Order_ID__c;
                                PayItem.Order_Name__r = ords;
                                allOrdersids.add(string.valueof(PayIt.get('order_id')));
                            }
                            if(PayIt.KeySet().contains('id') && !string.isBlank(string.valueof(PayIt.get('id'))))
                            {
                                PayItem.ID__c = string.valueof(PayIt.get('id'));
                                PayItem.Name = string.valueof(PayIt.get('id'));
                                ProcessExceptionId = PayItem.ID__c;
                                PaymentItemsIds.add(PayItem.ID__c);
                            }
                            
                            if(PayIt.KeySet().contains('pgName') && !string.isBlank(string.valueof(PayIt.get('pgName'))))
                                PayItem.Payment_Gateway_Type__c = string.valueof(PayIt.get('pgName'));
                            
                            if(PayIt.KeySet().contains('creation_time') && !string.isBlank(string.valueof(PayIt.get('creation_time'))))
                            {
                                if(string.valueof(PayIt.get('creation_time')).contains('T'))
                                {
                                    PayItem.Creation_Time__c = datetime.valueof(string.valueof(PayIt.get('creation_time')).replace('T',' '));
                                }
                                else
                                {
                                    PayItem.Creation_Time__c = datetime.valueof((string)PayIt.get('creation_time'));
                                }
                                
                            }
                            
                            if(PayIt.KeySet().contains('updated_by') && !string.isBlank(string.valueof(PayIt.get('updated_by'))))
                            {
                                PayItem.Updated_By__c = string.valueof(PayIt.get('updated_by'));
                            }
                            if(PayIt.KeySet().contains('updated_time') && !string.isBlank(string.valueof(PayIt.get('updated_time'))))
                            {
                                if(string.valueof(PayIt.get('updated_time')).contains('T'))
                                {
                                    PayItem.Updated_Time__c = datetime.valueof(string.valueof(PayIt.get('updated_time')).replace('T',' '));
                                }
                                else
                                {
                                    PayItem.Updated_Time__c = datetime.valueof((string)PayIt.get('updated_time'));
                                }
                            }
                            
                            if(PayIt.KeySet().contains('business_unit_currency') && !string.isBlank(string.valueof(PayIt.get('business_unit_currency'))))
                            {
                                PayItem.Business_Unit_Currency__c = string.valueof(PayIt.get('business_unit_currency'));
                            }
                            if(PayIt.KeySet().contains('business_unit_value') && !string.isBlank(string.valueof(PayIt.get('business_unit_value'))))
                            {
                                PayItem.Business_Unit_Value__c = double.valueof(PayIt.get('business_unit_value'));
                            }
                            if(PayIt.KeySet().contains('amount_payable_currency') && !string.isBlank(string.valueof(PayIt.get('amount_payable_currency'))))
                            {
                                PayItem.Amount_Payable_Currency__c = string.valueof(PayIt.get('amount_payable_currency'));
                            }
                            if(PayIt.KeySet().contains('amount_payable_value') && !string.isBlank(string.valueof(PayIt.get('amount_payable_value'))))
                            {
                                PayItem.Amount_Payable_Value__c = double.valueof(PayIt.get('amount_payable_value'));
                            }
                            
                            if(PayIt.KeySet().contains('payment_status') && !string.isBlank(string.valueof(PayIt.get('payment_status'))))
                            {
                                PayItem.Payment_Status__c = string.valueof(PayIt.get('payment_status'));
                            }
                            
                            if(PayIt.KeySet().contains('payment_system') && !string.isBlank(string.valueof(PayIt.get('payment_system'))))
                            {
                                PayItem.Payment_System__c = string.valueof(PayIt.get('payment_system'));
                            }
                            if(PayIt.KeySet().contains('payment_system_ref_no') && !string.isBlank(string.valueof(PayIt.get('payment_system_ref_no'))))
                            {
                                PayItem.Payment_System_Ref_No__c = string.valueof(PayIt.get('payment_system_ref_no'));
                            }
                            if(PayIt.KeySet().contains('settled_currency') && !string.isBlank(string.valueof(PayIt.get('settled_)urrency'))))
                            {
                                PayItem.Settled_Currency__c = string.valueof(PayIt.get('settled_currency'));
                            }
                            
                            if(PayIt.KeySet().contains('creation_time_long') && !string.isBlank(string.valueof(PayIt.get('creation_time_long'))))
                            {
                                PayItem.Creation_time_Long__c = string.valueof(PayIt.get('creation_time_long'));
                            }
                            if(PayIt.KeySet().contains('settlement_time_long') && !string.isBlank(string.valueof(PayIt.get('settlement_time_long'))))
                            {
                                PayItem.Settlement_Time_Long__c = string.valueof(PayIt.get('settlement_time_long'));
                            }
                            
                            if(PayIt.KeySet().contains('guid') && !string.isBlank(string.valueof(PayIt.get('guid'))))
                            {
                                PayItem.Guid__c = string.valueof(PayIt.get('guid'));
                            }
                            if(PayIt.KeySet().contains('commission') && !string.isBlank(string.valueof(PayIt.get('commission'))))
                            {
                                PayItem.commission__c = double.valueof(PayIt.get('commission'));
                            }
                            if(PayIt.KeySet().contains('payment_type') && !string.isBlank(string.valueof(PayIt.get('payment_type'))))
                            {
                                PayItem.Payment_Type__c = string.valueof(PayIt.get('payment_type'));
                            }
                            if(PayIt.KeySet().contains('is_complete') && !string.isBlank(string.valueof(PayIt.get('is_complete'))))
                            {
                                PayItem.Is_Complete__c = boolean.valueof(PayIt.get('is_complete'));
                            }
                            if(PayIt.KeySet().contains('pgtype') && string.isNotBlank(string.valueof(PayIt.get('pgtype'))))
                            {
                                PayItem.PG_Type__c = String.valueof(PayIt.get('pgtype'));
                            }
                            
                            if(PayIt.KeySet().contains('bankAccountNumber') && string.isNotBlank(string.valueof(PayIt.get('bankAccountNumber'))))
                            {
                                PayItem.Bank_Account_Number__c = String.valueof(PayIt.get('bankAccountNumber'));
                            }
                            
                            if(PayIt.KeySet().contains('accountHolderName') && string.isNotBlank(string.valueof(PayIt.get('accountHolderName'))))
                            {
                                PayItem.Account_Holder_Name__c = String.valueof(PayIt.get('accountHolderName'));
                            }
                            
                            if(PayIt.KeySet().contains('bankName') && string.isNotBlank(string.valueof(PayIt.get('bankName'))))
                            {
                                PayItem.Bank_Name__c = String.valueof(PayIt.get('bankName'));
                            }
                            
                            WFT_GFT_Payment__c wftGftPayment = new WFT_GFT_Payment__c();
                            wftGftPayment.ID__c = PayItem.id__c;
                            wftGftPayment.Payment_Items_Name__r = new Payment_Items__c(id__c=PayItem.id__c);
                            listWFTGFTPayments.add(wftGftPayment);
                            
                            /*
                            if(PayIt.KeySet().contains('additional_details') && !string.isBlank(string.valueof(PayIt.get('additional_details'))))
                            {
                            PayItem.Additional_Details__c = string.valueof(PayIt.get('additional_details'));
                            }

                            if(PayIt.KeySet().contains('transaction_source') && !string.isBlank(string.valueof(PayIt.get('transaction_source'))))
                            {
                            PayItem.Transaction_Source__c = string.valueof(PayIt.get('transaction_source'));
                            }

                            if(PayIt.KeySet().contains('version') && !string.isBlank(string.valueof(PayIt.get('version'))))
                            {
                            PayItem.Version__c = integer.valueof(PayIt.get('version'));
                            }
                            if(PayIt.KeySet().contains('settled_value') && !string.isBlank(string.valueof(PayIt.get('settled_value'))))
                            {
                            PayItem.Settled_Value__c = double.valueof(PayIt.get('settled_value'));
                            }
                            if(PayIt.KeySet().contains('settlement_time') && !string.isBlank(string.valueof(PayIt.get('settlement_time'))))
                            {
                            if(string.valueof(PayIt.get('settlement_time')).contains('T'))
                            {
                            PayItem.Settlement_Time__c = datetime.valueof(string.valueof(PayIt.get('settlement_time')).replace('T',' '));
                            }
                            else
                            {
                            PayItem.Settlement_Time__c = datetime.valueof((string)PayIt.get('settlement_time'));
                            }
                            }

                            if(PayIt.KeySet().contains('has_discrepancy') && !string.isBlank(string.valueof(PayIt.get('has_discrepancy'))))
                            {
                            PayItem.Has_Discrepancy__c = integer.valueof(PayIt.get('has_discrepancy'));
                            }
                            if(PayIt.KeySet().contains('is_reconceiled') && !string.isBlank(string.valueof(PayIt.get('is_reconceiled'))))
                            {
                            PayItem.Is_Reconceiled__c = integer.valueof(PayIt.get('is_reconceiled'));
                            }

                            */
                            PaymentItems.add(PayItem);
                        }
                        if(!PaymentItems.isEmpty())
                        {
                            Database.UpsertResult[] upsertResult = Database.upsert(PaymentItems,Payment_Items__c.ID__c,false);
                            list<string> SuccessList = new list<string>();
                            list<string> FailedList = new list<string>();
                            list<string> FailedDesscList = new list<string>();
                            for(Integer i=0;i<upsertResult.size();i++)
                            {
                                if (upsertResult.get(i).isSuccess())
                                {
                                    SuccessList.add(PaymentItemsIds[i]);
                                    
                                }
                                else if(!upsertResult.get(i).isSuccess())
                                {
                                    DBLog.add(prepareDBLog('PaymentItems',string.valueof(PaymentItemsIds[i]),string.valueof(upsertResult.get(i).getErrors())));
                                    FailedList.add(PaymentItemsIds[i]);
                                    FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                                    PaymentItemsFailedPro.add(JSON.Serialize(PaymentItems[i]));
                                }
                            }
                            setSuccessPayItems.addAll(SuccessList);
                            resp.paymentItemsSuccess = SuccessList;
                            resp.paymentItemsSuccessCount = SuccessList.size();
                            resp.paymentItemsFailed = FailedList;
                            resp.paymentItemsFailedCount = FailedList.size();
                            resp.paymentItemsFailDescription = FailedDesscList;
                            if(PaymentItems.size()==SuccessList.size())
                            {
                                resp.paymentItemsProcessStatus = 'Success';
                            }
                            else
                                if(PaymentItems.size()==FailedList.size())
                            {
                                resp.paymentItemsProcessStatus = 'Fail';
                            }
                            else
                            {
                                resp.paymentItemsProcessStatus = 'Partial';
                            }
                            dbl.Payment_Items_Success__c = string.join(SuccessList,',');
                            dbl.Payment_Items_Success_Count__c = SuccessList.size();
                            dbl.Payment_Items_Failed__c = string.join(FailedList,',');
                            dbl.Payment_Items_Failed_Count__c = FailedList.size();
                            if(!string.isBlank(string.valueof(string.join(FailedDesscList,','))) && string.valueof(string.join(FailedDesscList,',')).length()>25000)
                            {
                                dbl.Payment_Items_Fail_Description__c = string.valueof(string.join(FailedDesscList,',')).substring(0,24000);
                            }
                            else
                            {
                                dbl.Payment_Items_Fail_Description__c = string.join(FailedDesscList,',');
                            }
                            
                            dbl.Payment_Items_Process_Status__c = resp.paymentItemsProcessStatus;
                        }
                        
                        if(!listWFTGFTPayments.isEmpty())
                        {
                            Database.upsert(listWFTGFTPayments,WFT_GFT_Payment__c.ID__c,false);
                            
                        }
                        PayItemList.clear();
                    }
                }
                /*--------------------------PaymentItems End-----------------------------------------------*/
                
                /*--------------------------BusOrderItemDetails Start-------------------------------------*/
                if(booking.KeySet().contains('busOrderItemDetails') && booking.get('busOrderItemDetails')!=null && booking.get('busOrderItemDetails')!='')
                {
                    list<object> busOrderList = (list<object>)booking.get('busOrderItemDetails');
                    if(!busOrderList.isEmpty())
                    {
                        list<Bus_Order_Item_Details__c> BusOrderItemDetails = new list<Bus_Order_Item_Details__c>();
                        ProcessExceptionTableName = 'busOrderItemDetails';
                        for(object busOrdeInfo: busOrderList)
                        {
                            map<string,object> BusOr = (map<string,object>)(busOrdeInfo);
                            
                            Bus_Order_Item_Details__c BusOrItem = new Bus_Order_Item_Details__c();
                            string BusinessUnit;
                            if(BusOr.KeySet().contains('id') && !string.isBlank(string.valueof(BusOr.get('id'))))
                            {
                                BusOrItem.ID__c = string.valueof(BusOr.get('id'));
                                BusOrItem.Name = string.valueof(BusOr.get('id'));
                                Order_Items__c OrItem = new Order_Items__c();
                                OrItem.ID__c = BusOrItem.ID__c;
                                BusOrItem.Order_Item_Name__r = OrItem;
                                ProcessExceptionId = BusOrItem.ID__c;
                                BusOrderItemDetailsids.add(BusOrItem.ID__c);
                                allOrderItemids.add(BusOrItem.ID__c);
                            }
                            if(BusOr.KeySet().contains('boarding_point') && !string.isBlank(string.valueof(BusOr.get('boarding_point'))))
                            {
                                BusOrItem.Boarding_Point__c = string.valueof(BusOr.get('boarding_point'));
                            }
                            if(BusOr.KeySet().contains('boarding_point_id') && !string.isBlank(string.valueof(BusOr.get('boarding_point_id'))))
                            {
                                BusOrItem.Boarding_Point_ID__c = string.valueof(BusOr.get('boarding_point_id'));
                                
                            }
                            if(BusOr.KeySet().contains('boarding_time') && !string.isBlank(string.valueof(BusOr.get('boarding_time'))))
                            {
                                if(string.valueof(BusOr.get('boarding_time')).contains('T'))
                                {
                                    BusOrItem.Boarding_Time__c = datetime.valueof(string.valueof(BusOr.get('boarding_time')).replace('T',' '));
                                }
                                else
                                {
                                    BusOrItem.Boarding_Time__c = datetime.valueof((string)BusOr.get('boarding_time'));
                                }
                            }
                            if(BusOr.KeySet().contains('bus_type') && !string.isBlank(string.valueof(BusOr.get('bus_type'))))
                            {
                                BusOrItem.Bus_Type__c = string.valueof(BusOr.get('bus_type'));
                                
                            }
                            if(BusOr.KeySet().contains('destination_city') && !string.isBlank(string.valueof(BusOr.get('destination_city'))))
                            {
                                BusOrItem.Destination_City__c = string.valueof(BusOr.get('destination_city'));
                            }
                            if(BusOr.KeySet().contains('destination_id') && !string.isBlank(string.valueof(BusOr.get('destination_id'))))
                            {
                                BusOrItem.Destination_Id__c = string.valueof(BusOr.get('destination_id'));
                            }
                            if(BusOr.KeySet().contains('item_details') && !string.isBlank(string.valueof(BusOr.get('item_details'))))
                            {
                                BusOrItem.Item_Details__c = string.valueof(BusOr.get('item_details'));
                                
                            }
                            if(BusOr.KeySet().contains('primary_boarding_time') && !string.isBlank(string.valueof(BusOr.get('primary_boarding_time'))))
                            {
                                if(string.valueof(BusOr.get('primary_boarding_time')).contains('T'))
                                {
                                    BusOrItem.Primary_Boarding_Time__c = datetime.valueof(string.valueof(BusOr.get('primary_boarding_time')).replace('T',' '));
                                }
                                else
                                {
                                    BusOrItem.Primary_Boarding_Time__c = datetime.valueof((string)BusOr.get('primary_boarding_time'));
                                }
                            }
                            if(BusOr.KeySet().contains('route_id') && !string.isBlank(string.valueof(BusOr.get('route_id'))))
                            {
                                BusOrItem.Route_ID__c = string.valueof(BusOr.get('route_id'));
                            }
                            if(BusOr.KeySet().contains('source_city') && !string.isBlank(string.valueof(BusOr.get('source_city'))))
                            {
                                BusOrItem.Source_City__c = string.valueof(BusOr.get('source_city'));
                            }
                            if(BusOr.KeySet().contains('source_id') && !string.isBlank(string.valueof(BusOr.get('source_id'))))
                            {
                                BusOrItem.Source_ID__c = string.valueof(BusOr.get('source_id'));
                                
                            }
                            if(BusOr.KeySet().contains('starting_location') && !string.isBlank(string.valueof(BusOr.get('starting_location'))))
                            {
                                BusOrItem.Starting_Location__c = string.valueof(BusOr.get('starting_location'));
                            }
                            if(BusOr.KeySet().contains('starting_location_id') && !string.isBlank(string.valueof(BusOr.get('starting_location_id'))))
                            {
                                BusOrItem.Starting_Location_ID__c = string.valueof(BusOr.get('starting_location_id'));
                            }
                            
                            if(BusOr.KeySet().contains('ticket_details') && !string.isBlank(string.valueof(BusOr.get('ticket_details'))))
                            {
                                BusOrItem.Ticket_Details__c = string.valueof(BusOr.get('ticket_details'));
                            }
                            if(BusOr.KeySet().contains('dropping_point') && !string.isBlank(string.valueof(BusOr.get('dropping_point'))))
                            {
                                BusOrItem.Dropping_Point__c = string.valueof(BusOr.get('dropping_point'));
                            }
                            if(BusOr.KeySet().contains('dropping_point_id') && !string.isBlank(string.valueof(BusOr.get('dropping_point_id'))))
                            {
                                BusOrItem.Dropping_Point_ID__c = string.valueof(BusOr.get('dropping_point_id'));
                                
                            }
                            /*
                            if(BusOr.KeySet().contains('refund_status') && string.isNotBlank(string.valueof(BusOr.get('refund_status'))))
                            {
                            BusOrItem.Refund_Status__c = string.valueof(BusOr.get('refund_status'));
                            }
                            */
                            BusOrderItemDetails.add(BusOrItem);
                        }
                        if(!BusOrderItemDetails.isEmpty())
                        {
                            Database.UpsertResult[] upsertResult = Database.upsert(BusOrderItemDetails,Bus_Order_Item_Details__c.ID__c,false);
                            list<string> SuccessList = new list<string>();
                            list<string> FailedList = new list<string>();
                            list<string> FailedDesscList = new list<string>();
                            for(Integer i=0;i<upsertResult.size();i++)
                            {
                                if (upsertResult.get(i).isSuccess())
                                {
                                    SuccessList.add(BusOrderItemDetailsids[i]);
                                }
                                else if(!upsertResult.get(i).isSuccess())
                                {
                                    DBLog.add(prepareDBLog('BusOrderItemDetails',string.valueof(BusOrderItemDetailsids[i]),string.valueof(upsertResult.get(i).getErrors())));
                                    BusOrderItemDetailsFailedPro.add(JSON.Serialize(BusOrderItemDetails[i]));
                                    FailedList.add(BusOrderItemDetailsids[i]);
                                    FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                                }
                            }
                            resp.busOrderItemDetailsSuccess = SuccessList;
                            resp.busOrderItemDetailsSuccessCount = SuccessList.size();
                            resp.busOrderItemDetailsFailed = FailedList;
                            resp.busOrderItemDetailsFailedCount = FailedList.size();
                            resp.busOrderItemDetailsFailDescription = FailedDesscList;
                            if(BusOrderItemDetails.size()==SuccessList.size())
                            {
                                resp.busOrderItemDetailsProcessStatus = 'Success';
                            }
                            else
                                if(BusOrderItemDetails.size()==FailedList.size())
                            {
                                resp.busOrderItemDetailsProcessStatus = 'Fail';
                            }
                            else
                            {
                                resp.busOrderItemDetailsProcessStatus = 'Partial';
                            }
                            dbl.BusOrder_Item_Details_Success__c = string.join(SuccessList,',');
                            dbl.BusOrder_Item_Details_Success_Count__c = SuccessList.size();
                            dbl.BusOrder_Item_Details_Failed__c = string.join(FailedList,',');
                            dbl.BusOrder_Item_Details_Failed_Count__c = FailedList.size();
                            if(!string.isBlank(string.valueof(string.join(FailedDesscList,','))) && string.valueof(string.join(FailedDesscList,',')).length()>25000)
                            {
                                dbl.BusOrder_Item_Details_Fail_Description__c = string.valueof(string.join(FailedDesscList,',')).substring(0,24000);
                            }
                            else
                            {
                                dbl.BusOrder_Item_Details_Fail_Description__c = string.join(FailedDesscList,',');
                            }
                            
                            dbl.BusOrder_Item_Details_Process_Status__c = resp.busOrderItemDetailsProcessStatus;
                        }
                        busOrderList.clear();
                    }
                }
                /*-----------------------------BusOrderItemDetails End----------------------------*/
                
                /*-----------------------------TravellerInfo Start------------------------------*/
                if(booking.KeySet().contains('travellerInfo') && booking.get('travellerInfo')!=null && booking.get('travellerInfo')!='')
                {
                    list<object> TravelerList = (list<object>)booking.get('travellerInfo');
                    
                    if(!TravelerList.isEmpty())
                    {
                        list<Traveller_Info__c> TravellerInfo = new list<Traveller_Info__c>();
                        ProcessExceptionTableName = 'travellerInfo';
                        for(object TravelerInfo: TravelerList)
                        {
                            map<string,object> tra = (map<string,object>)(TravelerInfo);
                            Traveller_Info__c trinfo = new Traveller_Info__c();
                            string BusinessUnit;
                            if(tra.KeySet().contains('bus_order_item_details_id') && !string.isBlank(string.valueof(tra.get('bus_order_item_details_id'))))
                            {
                                trinfo.Bus_Order_Item_Details_Id__c = string.valueof(tra.get('bus_order_item_details_id'));
                                Order_Items__c orItem = new Order_Items__c(id__c=trinfo.Bus_Order_Item_Details_Id__c);
                                trinfo.Order_Item_Name__r = orItem;
                                /*  Bus_Order_Item_Details__c BOI = new Bus_Order_Item_Details__c();
                                    BOI.ID__c = trinfo.Bus_Order_Item_Details_Id__c;
                                    trinfo.Bus_Order_Item_Details__r = BOI;
                                */
                                allOrderItemids.add(string.valueof(tra.get('bus_order_item_details_id')));
                            }
                            if(tra.KeySet().contains('id') && !string.isBlank(string.valueof(tra.get('id'))))
                            {
                                trinfo.ID__c = string.valueof(tra.get('id'));
                                trinfo.Name = string.valueof(tra.get('id'));
                                ProcessExceptionId = trinfo.ID__c;
                                TravellerInfoIds.add(trinfo.ID__c);
                                if(primaryCustomerIds.KeySet().Contains(string.valueof(tra.get('id'))) && tra.KeySet().contains('mobile_no') && !AddedList.KeySet().contains(string.valueof(tra.get('mobile_no'))))
                                {
                                    account cust = new account();
                                    AddedList.put(string.valueof(tra.get('mobile_no')),string.valueof(tra.get('mobile_no')));
                                    if(mapOrderItemsTravelsAccs.containsKey(string.valueof(tra.get('mobile_no'))))
                                        cust = mapOrderItemsTravelsAccs.get(string.valueof(tra.get('mobile_no')));
                                    
                                    cust.AccountSource = 'Traveller Info';
                                    
                                    if(tra.KeySet().contains('email_id') && !string.isBlank(string.valueof(tra.get('email_id'))))
                                    {
                                        if(string.valueof(tra.get('email_id')).length()<255)
                                        {
                                            cust.Email_Copy__c = string.valueof(tra.get('email_id'));
                                        }
                                        else
                                        {
                                            cust.Email_Copy__c = string.valueof(tra.get('email_id')).substring(0,255);
                                        }
                                        if(!string.valueof(tra.get('email_id')).contains(' ')&& validateEmail(string.valueof(tra.get('email_id')))==true)
                                        {
                                            cust.PersonEmail = string.valueof(tra.get('email_id'));
                                            orItemprimaryEmails.add(cust.PersonEmail);
                                            System.debug('orItemprimaryEmails..'+orItemprimaryEmails);
                                        }
                                    }
                                    if(tra.KeySet().contains('dateOfBirth') && !string.isBlank(string.valueof(tra.get('dateOfBirth'))))
                                    {
                                        if(string.valueof(tra.get('dateOfBirth')).contains('T'))
                                        {
                                            cust.PersonBirthdate = date.valueof(string.valueof(tra.get('dateOfBirth')).replace('T',' '));
                                        }
                                        else
                                        {
                                            cust.PersonBirthdate = date.valueof((string)tra.get('dateOfBirth'));
                                        }
                                    }
                                    if(tra.KeySet().contains('gender') && !string.isBlank(string.valueof(tra.get('gender'))))
                                    {
                                        cust.Gender__c = string.valueof(tra.get('gender'));
                                    }
                                    if(tra.KeySet().contains('mobile_no') && !string.isBlank(string.valueof(tra.get('mobile_no'))))
                                    {
                                        cust.PersonMobilePhone = string.valueof(tra.get('mobile_no'));
                                        
                                    }
                                    if(tra.KeySet().contains('passenger_name') && !string.isBlank(string.valueof(tra.get('passenger_name'))))
                                    {
                                        cust.lastName = string.valueof(tra.get('passenger_name'));
                                    }
                                    else
                                        if(tra.KeySet().contains('mobile_no') && !string.isBlank(string.valueof(tra.get('mobile_no'))))
                                    {
                                        cust.lastName = string.valueof(tra.get('mobile_no'));
                                    }
                                    else
                                    {
                                        cust.lastName = 'N/A';
                                    }
                                    orItemcustList.add(JSON.Serialize(cust));
                                    System.debug('orItemcustList..'+orItemcustList);
                                }
                            }
                            if(tra.KeySet().contains('additional_details') && !string.isBlank(string.valueof(tra.get('additional_details'))))
                            {
                                trinfo.Additional_Details__c = string.valueof(tra.get('additional_details'));
                            }
                            
                            if(tra.KeySet().contains('city') && !string.isBlank(string.valueof(tra.get('city'))))
                            {
                                trinfo.City__c = string.valueof(tra.get('city'));
                            }
                            if(tra.KeySet().contains('country') && !string.isBlank(string.valueof(tra.get('country'))))
                            {
                                trinfo.Country__c = string.valueof(tra.get('country'));
                            }
                            if(tra.KeySet().contains('postalCode') && !string.isBlank(string.valueof(tra.get('postalCode'))))
                            {
                                trinfo.PostalCode__c = string.valueof(tra.get('postalCode'));
                            }
                            if(tra.KeySet().contains('state') && !string.isBlank(string.valueof(tra.get('state'))))
                            {
                                trinfo.State__c = string.valueof(tra.get('state'));
                            }
                            if(tra.KeySet().contains('age') && !string.isBlank(string.valueof(tra.get('age'))))
                            {
                                trinfo.Age__c = integer.valueof(tra.get('age'));
                            }
                            if(tra.KeySet().contains('alternate_mobile_no') && !string.isBlank(string.valueof(tra.get('alternate_mobile_no'))))
                            {
                                trinfo.Alternate_Mobile_No__c = string.valueof(tra.get('alternate_mobile_no'));
                            }
                            if(tra.KeySet().contains('dateOfBirth') && !string.isBlank(string.valueof(tra.get('dateOfBirth'))))
                            {
                                if(string.valueof(tra.get('dateOfBirth')).contains('T'))
                                {
                                    trinfo.DateOfBirth__c = datetime.valueof(string.valueof(tra.get('dateOfBirth')).replace('T',' '));
                                }
                                else
                                {
                                    trinfo.DateOfBirth__c = datetime.valueof((string)tra.get('dateOfBirth'));
                                }
                            }
                            if(tra.KeySet().contains('email_id') && !string.isBlank(string.valueof(tra.get('email_id'))))
                            {
                                if(string.valueof(tra.get('email_id')).length()<255)
                                {
                                    trinfo.Email_Id_copy__c = string.valueof(tra.get('email_id'));
                                }
                                else
                                {
                                    trinfo.Email_Id_copy__c = string.valueof(tra.get('email_id')).substring(0,255);
                                }
                                if(!string.valueof(tra.get('email_id')).contains(' ') && validateEmail(string.valueof(tra.get('email_id')))==true)
                                {
                                    trinfo.Email_ID__c = string.valueof(tra.get('email_id'));
                                }
                            }
                            if(tra.KeySet().contains('gender') && !string.isBlank(string.valueof(tra.get('gender'))))
                            {
                                trinfo.Gender__c = string.valueof(tra.get('gender'));
                            }
                            if(tra.KeySet().contains('issuing_authority') && !string.isBlank(string.valueof(tra.get('issuing_authority'))))
                            {
                                trinfo.Issuing_Authority__c = string.valueof(tra.get('issuing_authority'));
                            }
                            if(tra.KeySet().contains('mobile_no') && !string.isBlank(string.valueof(tra.get('mobile_no'))))
                            {
                                trinfo.Mobile_No__c = string.valueof(tra.get('mobile_no'));
                            }
                            if(tra.KeySet().contains('name_on_proof') && !string.isBlank(string.valueof(tra.get('name_on_proof'))))
                            {
                                trinfo.Name_On_Proof__c = string.valueof(tra.get('name_on_proof'));
                            }
                            if(tra.KeySet().contains('passenger_name') && !string.isBlank(string.valueof(tra.get('passenger_name'))))
                            {
                                trinfo.Passenger_Name__c = string.valueof(tra.get('passenger_name'));
                            }
                            
                            if(tra.KeySet().contains('proof_id') && !string.isBlank(string.valueof(tra.get('proof_id'))))
                            {
                                trinfo.Proof_Id__c = string.valueof(tra.get('proof_id'));
                            }
                            if(tra.KeySet().contains('proof_type') && !string.isBlank(string.valueof(tra.get('proof_type'))))
                            {
                                trinfo.Proof_Type__c = string.valueof(tra.get('proof_type'));
                            }
                            if(tra.KeySet().contains('title') && !string.isBlank(string.valueof(tra.get('title'))))
                            {
                                trinfo.Title__c = string.valueof(tra.get('title'));
                            }
                            if(tra.KeySet().contains('creation_time_long') && !string.isBlank(string.valueof(tra.get('creation_time_long'))))
                            {
                                trinfo.Creation_Time_Long__c = string.valueof(tra.get('creation_time_long'));
                            }
                            if(tra.KeySet().contains('address') && !string.isBlank(string.valueof(tra.get('address'))))
                            {
                                trinfo.Address__c = string.valueof(tra.get('address'));
                            }
                            if(tra.KeySet().contains('addressLine1') && !string.isBlank(string.valueof(tra.get('addressLine1'))))
                            {
                                trinfo.addressLine1__c = string.valueof(tra.get('addressLine1'));
                            }
                            if(tra.KeySet().contains('addressLine2') && !string.isBlank(string.valueof(tra.get('addressLine2'))))
                            {
                                trinfo.addressLine2__c = string.valueof(tra.get('addressLine2'));
                            }
                            /*
                            if(tra.KeySet().contains('created_by') && !string.isBlank(string.valueof(tra.get('created_by'))))
                            {
                            trinfo.Created_By__c = string.valueof(tra.get('created_by'));
                            }
                            if(tra.KeySet().contains('creation_time') && !string.isBlank(string.valueof(tra.get('creation_time'))))
                            {
                            if(string.valueof(tra.get('creation_time')).contains('T'))
                            {
                            trinfo.Creation_Time__c = datetime.valueof(string.valueof(tra.get('creation_time')).replace('T',' '));
                            }
                            else
                            {
                            trinfo.Creation_Time__c = datetime.valueof((string)tra.get('creation_time'));
                            }
                            }
                            if(tra.KeySet().contains('transaction_source') && !string.isBlank(string.valueof(tra.get('transaction_source'))))
                            {
                            trinfo.Transaction_Source__c = string.valueof(tra.get('transaction_source'));
                            }
                            if(tra.KeySet().contains('updated_by') && !string.isBlank(string.valueof(tra.get('updated_by'))))
                            {
                            trinfo.Updated_By__c = string.valueof(tra.get('updated_by'));
                            }
                            if(tra.KeySet().contains('updated_time') && !string.isBlank(string.valueof(tra.get('updated_time'))))
                            {
                            if(string.valueof(tra.get('updated_time')).contains('T'))
                            {
                            trinfo.Updated_Time__c = datetime.valueof(string.valueof(tra.get('updated_time')).replace('T',' '));
                            }
                            else
                            {
                            trinfo.Updated_Time__c = datetime.valueof((string)tra.get('updated_time'));
                            }
                            }
                            if(tra.KeySet().contains('version') && !string.isBlank(string.valueof(tra.get('version'))))
                            {
                            trinfo.Version__c = integer.valueof(tra.get('version'));
                            }
                            if(tra.KeySet().contains('passenger_type') && !string.isBlank(string.valueof(tra.get('passenger_type'))))
                            {
                            trinfo.Passenger_Type__c = string.valueof(tra.get('passenger_type'));
                            }
                            if(tra.KeySet().contains('addressLine3') && !string.isBlank(string.valueof(tra.get('addressLine3'))))
                            {
                            trinfo.addressLine3__c = string.valueof(tra.get('addressLine3'));
                            }

                            if(tra.KeySet().contains('guid') && !string.isBlank(string.valueof(tra.get('guid'))))
                            {
                            trinfo.Guid__c = string.valueof(tra.get('guid'));
                            }
                            */
                            TravellerInfo.add(trinfo);
                        }
                        if(!TravellerInfo.isEmpty())
                        {
                            Database.UpsertResult[] upsertResult = Database.upsert(TravellerInfo,Traveller_Info__c.ID__c,false);
                            list<string> SuccessList = new list<string>();
                            list<string> FailedList = new list<string>();
                            list<string> FailedDesscList = new list<string>();
                            for(Integer i=0;i<upsertResult.size();i++)
                            {
                                if (upsertResult.get(i).isSuccess())
                                {
                                    SuccessList.add(TravellerInfoIds[i]);
                                }
                                else if(!upsertResult.get(i).isSuccess())
                                {
                                    DBLog.add(prepareDBLog('TravellerInfo',string.valueof(TravellerInfoIds[i]),string.valueof(upsertResult.get(i).getErrors())));
                                    TravellerInfoFailedPro.add(JSON.Serialize(TravellerInfo[i]));
                                    FailedList.add(TravellerInfoIds[i]);
                                    FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                                }
                            }
                            resp.travellerInfoSuccess = SuccessList;
                            resp.travellerInfoSuccessCount = SuccessList.size();
                            resp.travellerInfoFailed = FailedList;
                            resp.travellerInfoFailedCount = FailedList.size();
                            resp.travellerInfoFailDescription = FailedDesscList;
                            if(TravellerInfo.size()==SuccessList.size())
                            {
                                resp.travellerInfoProcessStatus = 'Success';
                            }
                            else
                                if(TravellerInfo.size()==FailedList.size())
                            {
                                resp.travellerInfoProcessStatus = 'Fail';
                            }
                            else
                            {
                                resp.travellerInfoProcessStatus = 'Partial';
                            }
                            dbl.Traveller_Info_Success__c = string.join(SuccessList,',');
                            dbl.Traveller_Info_Success_Count__c = SuccessList.size();
                            dbl.Traveller_Info_Failed__c = string.join(FailedList,',');
                            dbl.Traveller_Info_Failed_Count__c = FailedList.size();
                            if(!string.isBlank(string.valueof(string.join(FailedDesscList,','))) && string.valueof(string.join(FailedDesscList,',')).length()>25000)
                            {
                                dbl.Traveller_Info_Fail_Description__c = string.valueof(string.join(FailedDesscList,',')).substring(0,24000);
                            }
                            else
                            {
                                dbl.Traveller_Info_Fail_Description__c = string.join(FailedDesscList,',');
                            }
                            dbl.Traveller_Info_Process_Status__c = resp.travellerInfoProcessStatus;
                            
                        }
                        
                        TravelerList.clear();
                    }
                }
                /*----------------------------TravellerInfo End-------------------------------*/
                
                /*-----------------------------CancelledOrderItems Start----------------------*/
                if(booking.KeySet().contains('cancelledOrderItems') && booking.get('cancelledOrderItems')!=null && booking.get('cancelledOrderItems')!='')
                {
                    list<object> CancelOrderItemList = (list<object>)booking.get('cancelledOrderItems');
                    list<Cancelled_Order_Items__c> CancelOrderItems = new list<Cancelled_Order_Items__c>();
                    List<Order_Items__c> listOrItemsCanOrItems = new list<Order_Items__c>();
                    List<Orders__c> listOrdersCanOrItems = new list<Orders__c>();
                    
                    Set<String> setItemIdsForUpdate = new Set<String>();
                    Set<String> setOrderIdsForUpdate = new Set<String>();
                    
                    ProcessExceptionTableName = 'cancelledOrderItems';
                    
                    for(object CanOrItemValue: CancelOrderItemList)
                    {
                        map<string,object> Canorder = (map<string,object>)(CanOrItemValue);
                        Cancelled_Order_Items__c CanOrdItem = new Cancelled_Order_Items__c();
                        if(Canorder.KeySet().contains('id') && !string.isBlank(string.valueof(Canorder.get('id'))))
                        {
                            CanOrdItem.ID__c = string.valueof(Canorder.get('id'));
                            CanOrdItem.name = CanOrdItem.ID__c;
                            ProcessExceptionId = CanOrdItem.ID__c;
                            cancelOrderItemIds.add(CanOrdItem.ID__c);
                        }
                        
                        string BusinessUnit;
                        if(Canorder.KeySet().contains('order_item_id') && !string.isBlank(string.valueof(Canorder.get('order_item_id'))))
                        {
                            CanOrdItem.Order_Item_ID__c = string.valueof(Canorder.get('order_item_id'));
                            Order_Items__c orItem = new Order_Items__c(id__c=CanOrdItem.Order_Item_ID__c);
                            CanOrdItem.Order_Item_Name__r = orItem;
                            allOrderItemids.add(CanOrdItem.Order_Item_ID__c);
                            
                            Order_Items__c orItem1 = new Order_Items__c(id__c=CanOrdItem.Order_Item_ID__c);
                            orItem1.Name = String.valueOf(CanOrdItem.Order_Item_ID__c);
                            
                            //Added By Sreenivas M
                            if((setSuccessOritems.isEmpty() || !setSuccessOritems.contains(orItem.id__c)) && !setItemIdsForUpdate.contains(orItem.id__c))
                            {
                                setItemIdsForUpdate.add(orItem.id__c);
                                listOrItemsCanOrItems.add(orItem1);
                            }
                            
                        }
                        
                        if(Canorder.KeySet().contains('order_id') && !string.isBlank(string.valueof(Canorder.get('order_id'))))
                        {
                            CanOrdItem.Order_ID__c = string.valueof(Canorder.get('order_id'));
                            Orders__c ords = new Orders__c(id__c =  CanOrdItem.Order_ID__c);
                            CanOrdItem.Order_Name__r = ords;
                            allOrdersids.add(CanOrdItem.Order_ID__c);
                            
                            Orders__c ords1 = new Orders__c(id__c =  CanOrdItem.Order_ID__c);
                            ords1.Name = String.valueOf(CanOrdItem.Order_ID__c);
                            
                            //Added By Sreenivas M
                            if((setSuccessOrders.isEmpty() || !setSuccessOrders.contains(ords.id__c)) && !setOrderIdsForUpdate.contains(ords.id__c))
                            {
                                setOrderIdsForUpdate.add(ords.id__c);
                                listOrdersCanOrItems.add(ords1);
                            }
                        }
                        
                        if(Canorder.KeySet().contains('additional_details') && !string.isBlank(string.valueof(Canorder.get('additional_details'))))
                        {
                            CanOrdItem.Additional_Details__c = string.valueof(Canorder.get('additional_details'));
                        }
                        
                        if(Canorder.KeySet().contains('creation_time') && !string.isBlank(string.valueof(Canorder.get('creation_time'))))
                        {
                            if(string.valueof(Canorder.get('creation_time')).contains('T'))
                            {
                                CanOrdItem.Creation_Time__c = datetime.valueof(string.valueof(Canorder.get('creation_time')).replace('T',' '));
                            }
                            else
                            {
                                CanOrdItem.Creation_Time__c = datetime.valueof((string)Canorder.get('creation_time'));
                            }
                        }
                        if(Canorder.KeySet().contains('transaction_source') && !string.isBlank(string.valueof(Canorder.get('transaction_source'))))
                        {
                            CanOrdItem.Transaction_Source__c = string.valueof(Canorder.get('transaction_source'));
                        }
                        
                        if(Canorder.KeySet().contains('order_item_reference_no') && !string.isBlank(string.valueof(Canorder.get('order_item_reference_no'))))
                        {
                            CanOrdItem.order_Item_Reference_No__c = string.valueof(Canorder.get('order_item_reference_no'));
                        }
                        if(Canorder.KeySet().contains('status') && !string.isBlank(string.valueof(Canorder.get('status'))))
                        {
                            CanOrdItem.Status__c = string.valueof(Canorder.get('status'));
                        }
                        if(Canorder.KeySet().contains('service_provider_reference_no') && !string.isBlank(string.valueof(Canorder.get('service_provider_reference_no'))))
                        {
                            CanOrdItem.Service_Provider_Name__c = string.valueof(Canorder.get('service_provider_reference_no'));
                        }
                        if(Canorder.KeySet().contains('seates_to_be_cancelled') && !string.isBlank(string.valueof(Canorder.get('seates_to_be_cancelled'))))
                        {
                            CanOrdItem.Seates_to_be_cancelled__c = string.valueof(Canorder.get('seates_to_be_cancelled'));
                        }
                        if(Canorder.KeySet().contains('total_fare_currency') && !string.isBlank(string.valueof(Canorder.get('total_fare_currency'))))
                        {
                            CanOrdItem.Total_Fare_Currency__c = string.valueof(Canorder.get('total_fare_currency'));
                        }
                        if(Canorder.KeySet().contains('total_fare_value') && !string.isBlank(string.valueof(Canorder.get('total_fare_value'))))
                        {
                            CanOrdItem.Total_Fare_Value__c = double.valueof(Canorder.get('total_fare_value'));
                        }
                        if(Canorder.KeySet().contains('total_tax_currency') && !string.isBlank(string.valueof(Canorder.get('total_tax_currency'))))
                        {
                            CanOrdItem.Total_Tax_Currency__c = string.valueof(Canorder.get('total_tax_currency'));
                        }
                        if(Canorder.KeySet().contains('total_tax_value') && !string.isBlank(string.valueof(Canorder.get('total_tax_value'))))
                        {
                            CanOrdItem.Total_Tax_Value__c = double.valueof(Canorder.get('total_tax_value'));
                        }
                        if(Canorder.KeySet().contains('operator_cancellation_status') && !string.isBlank(string.valueof(Canorder.get('operator_cancellation_status'))))
                        {
                            CanOrdItem.Operator_Cancellation_Status__c = string.valueof(Canorder.get('operator_cancellation_status'));
                        }
                        if(Canorder.KeySet().contains('cancellation_reference_no') && !string.isBlank(string.valueof(Canorder.get('cancellation_reference_no'))))
                        {
                            CanOrdItem.Cancellation_Reference_No__c = string.valueof(Canorder.get('cancellation_reference_no'));
                        }
                        if(Canorder.KeySet().contains('business_unit') && !string.isBlank(string.valueof(Canorder.get('business_unit'))))
                        {
                            CanOrdItem.Business_Unit__c = string.valueof(Canorder.get('business_unit'));
                        }
                        if(Canorder.KeySet().contains('cancellation_time') && !string.isBlank(string.valueof(Canorder.get('cancellation_time'))))
                        {
                            if(string.valueof(Canorder.get('cancellation_time')).contains('T'))
                            {
                                CanOrdItem.Cancellation_Time__c = datetime.valueof(string.valueof(Canorder.get('cancellation_time')).replace('T',' '));
                            }
                            else
                            {
                                CanOrdItem.Cancellation_Time__c = datetime.valueof((string)Canorder.get('cancellation_time'));
                            }
                        }
                        if(Canorder.KeySet().contains('primary_passenger_id') && !string.isBlank(string.valueof(Canorder.get('primary_passenger_id'))))
                        {
                            CanOrdItem.Primary_Passenger_Id__c = string.valueof(Canorder.get('primary_passenger_id'));
                        }
                        if(Canorder.KeySet().contains('service_provider_id') && !string.isBlank(string.valueof(Canorder.get('service_provider_id'))))
                        {
                            CanOrdItem.Service_Provider_Id__c = string.valueof(Canorder.get('service_provider_id'));
                        }
                        if(Canorder.KeySet().contains('service_provider_name') && !string.isBlank(string.valueof(Canorder.get('service_provider_name'))))
                        {
                            CanOrdItem.Service_Provider_Name__c = string.valueof(Canorder.get('service_provider_name'));
                        }
                        if(Canorder.KeySet().contains('date_of_purchase') && !string.isBlank(string.valueof(Canorder.get('date_of_purchase'))))
                        {
                            if(string.valueof(Canorder.get('date_of_purchase')).contains('T'))
                            {
                                CanOrdItem.Date_Of_Purchase__c = datetime.valueof(string.valueof(Canorder.get('date_of_purchase')).replace('T',' '));
                            }
                            else
                            {
                                CanOrdItem.Date_Of_Purchase__c = datetime.valueof((string)Canorder.get('date_of_purchase'));
                            }
                        }
                        if(Canorder.KeySet().contains('guid') && !string.isBlank(string.valueof(Canorder.get('guid'))))
                        {
                            CanOrdItem.Guid__c = string.valueof(Canorder.get('guid'));
                        }
                        if(Canorder.KeySet().contains('creation_time_long') && !string.isBlank(string.valueof(Canorder.get('creation_time_long'))))
                        {
                            CanOrdItem.Creation_Time_Long__c = string.valueof(Canorder.get('creation_time_long'));
                        }
                        if(Canorder.KeySet().contains('cancellation_reason') && !string.isBlank(string.valueof(Canorder.get('cancellation_reason'))))
                        {
                            CanOrdItem.Cancellation_Reason__c = string.valueof(Canorder.get('cancellation_reason'));
                        }
                        
                        if(Canorder.KeySet().contains('client_ip') && !string.isBlank(string.valueof(Canorder.get('client_ip'))))
                        {
                            CanOrdItem.Client_IP__c = string.valueof(Canorder.get('client_ip'));
                        }
                        
                        /*
                        if(Canorder.KeySet().contains('created_by') && !string.isBlank(string.valueof(Canorder.get('created_by'))))
                        {
                        CanOrdItem.Created_By__c = string.valueof(Canorder.get('created_by'));
                        }
                        if(Canorder.KeySet().contains('updated_by') && !string.isBlank(string.valueof(Canorder.get('updated_by'))))
                        {
                        CanOrdItem.Updated_By__c = string.valueof(Canorder.get('updated_by'));
                        }
                        if(Canorder.KeySet().contains('updated_time') && !string.isBlank(string.valueof(Canorder.get('updated_time'))))
                        {
                        if(string.valueof(Canorder.get('updated_time')).contains('T'))
                        {
                        CanOrdItem.Updated_Time__c = datetime.valueof(string.valueof(Canorder.get('updated_time')).replace('T',' '));
                        }
                        else
                        {
                        CanOrdItem.Updated_Time__c = datetime.valueof((string)Canorder.get('updated_time'));
                        }
                        }
                        if(Canorder.KeySet().contains('version') && !string.isBlank(string.valueof(Canorder.get('version'))))
                        {
                        CanOrdItem.Version__c = integer.valueof(Canorder.get('version'));
                        }
                        */
                        CancelOrderItems.add(CanOrdItem);
                    }
                    if(!CancelOrderItems.isEmpty())
                    {
                        if(!listOrdersCanOrItems.isEmpty())
                            Database.UpsertResult[] ordersupsertResult = Database.upsert(listOrdersCanOrItems,Orders__c.ID__c,false);
                        if(!listOrItemsCanOrItems.isEmpty())
                            Database.UpsertResult[] itemsupsertResult = Database.upsert(listOrItemsCanOrItems,Order_Items__c.ID__c,false);
                        
                        Database.UpsertResult[] upsertResult = Database.upsert(CancelOrderItems,Cancelled_Order_Items__c.ID__c,false);
                        
                        list<string> SuccessList = new list<string>();
                        list<string> FailedList = new list<string>();
                        list<string> FailedDesscList = new list<string>();
                        for(Integer i=0;i<upsertResult.size();i++)
                        {
                            if (upsertResult.get(i).isSuccess())
                            {
                                SuccessList.add(cancelOrderItemIds[i]);
                            }
                            else if(!upsertResult.get(i).isSuccess())
                            {
                                DBLog.add(prepareDBLog('CancelOrderItems',string.valueof(cancelOrderItemIds[i]),string.valueof(upsertResult.get(i).getErrors())));
                                cancelOrderItemFailedPro.add(JSON.Serialize(CancelOrderItems[i]));
                                FailedList.add(cancelOrderItemIds[i]);
                                FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                            }
                        }
                        
                        resp.cancelledOrderItemsSuccess = SuccessList;
                        resp.cancelledOrderItemsSuccessCount = SuccessList.size();
                        resp.cancelledOrderItemsFailed = FailedList;
                        resp.cancelledOrderItemsFailedCount = FailedList.size();
                        resp.cancelledOrderItemsFailDescription = FailedDesscList;
                        if(cancelOrderItemIds.size()==SuccessList.size())
                            resp.cancelledOrderItemsProcessStatus = 'Success';
                        else if(cancelOrderItemIds.size()==FailedList.size())
                            resp.cancelledOrderItemsProcessStatus = 'Fail';
                        else
                            resp.cancelledOrderItemsProcessStatus = 'Partial';
                        
                        dbl.Cancelled_Order_Items_Success__c = string.join(SuccessList,',');
                        dbl.Cancelled_Order_Items_Success_Count__c = resp.cancelledOrderItemsSuccessCount;
                        dbl.Cancelled_Order_Items_Failed__c =string.join(FailedList,',');
                        dbl.Cancelled_Order_Items_Failed_Count__c = resp.cancelledOrderItemsFailedCount;
                        
                        if( !string.isBlank(string.valueof(string.join(FailedDesscList,','))) && string.valueof(string.join(FailedDesscList,',')).length()>25000)
                           {
                                dbl.Cancelled_Order_Items_Fail_Description__c= string.valueof(string.join(FailedDesscList,',')).substring(0,24000);
                           }
                           else
                           {
                                dbl.Cancelled_Order_Items_Fail_Description__c= string.join(FailedDesscList,',');
                           }
                           
                        
                        dbl.Cancelled_Order_Items_Process_Status__c = resp.cancelledOrderItemsProcessStatus;
                    }
                    cancelOrderItemIds.clear();
                }
                /*-------------------------------CancelledOrderitems End------------------------*/
                
                /*--------------------------------RefundOrderItems Start---------------------*/
                
                if(booking.KeySet().contains('refundOrderItems') && booking.get('refundOrderItems')!=null && booking.get('refundOrderItems')!='')
                {
                    list<object> refundOrderItemsList = (list<object>)booking.get('refundOrderItems');
                    list<Refund_Order_Items__c> RefundOrderItems = new list<Refund_Order_Items__c>();
                    List<Order_Items__c> listOrItemsRefOrItems = new list<Order_Items__c>();
                    List<Payment_Items__c> listPayItemsRefOrItems = new list<Payment_Items__c>();            
                    Set<String> setItemIdsForUpdate = new Set<String>();
                    Set<String> setPayIdsForUpdate = new Set<String>();
                    
                    ProcessExceptionTableName = 'refundOrderItems';
                    for(object refundValue: refundOrderItemsList)
                    {
                        map<string,object> refundItem = (map<string,object>)(refundValue);
                        Refund_Order_Items__c RefundOrdItem = new Refund_Order_Items__c();
                        if(refundItem.KeySet().contains('id') && !string.isBlank(string.valueof(refundItem.get('id'))))
                        {
                            RefundOrdItem.ID__c = string.valueof(refundItem.get('id'));
                            RefundOrdItem.name = RefundOrdItem.ID__c;
                            ProcessExceptionId = RefundOrdItem.ID__c;
                            refundIds.add(RefundOrdItem.ID__c);
                        }
                        
                        if(refundItem.KeySet().contains('order_item_id') && !string.isBlank(string.valueof(refundItem.get('order_item_id'))))
                        {
                            RefundOrdItem.Order_Item_ID__c = string.valueof(refundItem.get('order_item_id'));
                            Order_Items__c orItem = new Order_Items__c(id__c = RefundOrdItem.Order_Item_ID__c);
                            RefundOrdItem.Order_Item_Name__r = orItem;
                            allOrderItemids.add(RefundOrdItem.Order_Item_ID__c);
                            
                            Order_Items__c orItem1 = new Order_Items__c(id__c = RefundOrdItem.Order_Item_ID__c);
                            orItem1.Name = String.valueOf(RefundOrdItem.Order_Item_ID__c);
                            
                            //Added By Sreenivas M
                            if((setSuccessOritems.isEmpty() || !setSuccessOritems.contains(orItem.id__c)) && !setItemIdsForUpdate.contains(orItem.id__c))
                            {
                                setItemIdsForUpdate.add(orItem.id__c);
                                listOrItemsRefOrItems.add(orItem1);
                            }
                        }
                        
                        if(refundItem.KeySet().contains('payment_item_id') && !string.isBlank(string.valueof(refundItem.get('payment_item_id'))))
                        {
                            RefundOrdItem.Payment_Item_ID__c = string.valueof(refundItem.get('payment_item_id'));
                            /*
                            Payment_Items__c Pitems = new Payment_Items__c(Id__c = RefundOrdItem.Payment_Item_ID__c);
                            RefundOrdItem.Payment_Item_Name__r = Pitems;
                            Added By Sreenivas M
                            Payment_Items__c Pitems1 = new Payment_Items__c(Id__c = RefundOrdItem.Payment_Item_ID__c);
                            Pitems1.Name = String.valueOf(RefundOrdItem.Payment_Item_ID__c);

                            if((setSuccessPayItems.isEmpty() || !setSuccessPayItems.contains(Pitems.Id__c)) && !setPayIdsForUpdate.contains(Pitems.Id__c))
                            {
                            setPayIdsForUpdate.add(Pitems.Id__c);
                            listPayItemsRefOrItems.add(Pitems1);
                            }
                            */
                            
                        }
                        
                        if(refundItem.KeySet().contains('additional_details') && !string.isBlank(string.valueof(refundItem.get('additional_details'))))
                        {
                            RefundOrdItem.Additional_Details__c = string.valueof(refundItem.get('additional_details'));
                        }
                        if(refundItem.KeySet().contains('created_by') && !string.isBlank(string.valueof(refundItem.get('created_by'))))
                        {
                            RefundOrdItem.Created_By__c = string.valueof(refundItem.get('created_by'));
                        }
                        if(refundItem.KeySet().contains('creation_time') && !string.isBlank(string.valueof(refundItem.get('creation_time'))))
                        {
                            if(string.valueof(refundItem.get('creation_time')).contains('T'))
                            {
                                RefundOrdItem.Creation_Time__c = datetime.valueof(string.valueof(refundItem.get('creation_time')).replace('T',' '));
                            }
                            else
                            {
                                RefundOrdItem.Creation_Time__c = datetime.valueof((string)refundItem.get('creation_time'));
                            }
                        }
                        if(refundItem.KeySet().contains('transaction_source') && !string.isBlank(string.valueof(refundItem.get('transaction_source'))))
                        {
                            RefundOrdItem.Transaction_Source__c = string.valueof(refundItem.get('transaction_source'));
                        }
                        
                        if(refundItem.KeySet().contains('status') && !string.isBlank(string.valueof(refundItem.get('status'))))
                        {
                            RefundOrdItem.Status__c = string.valueof(refundItem.get('status'));
                        }
                        if(refundItem.KeySet().contains('refund_reason') && !string.isBlank(string.valueof(refundItem.get('refund_reason'))))
                        {
                            RefundOrdItem.Refund_Reason__c = string.valueof(refundItem.get('refund_reason'));
                        }
                        if(refundItem.KeySet().contains('customer_name') && !string.isBlank(string.valueof(refundItem.get('customer_name'))))
                        {
                            RefundOrdItem.Customer_Name__c = string.valueof(refundItem.get('customer_name'));
                        }
                        if(refundItem.KeySet().contains('mobile_no') && !string.isBlank(string.valueof(refundItem.get('mobile_no'))))
                        {
                            RefundOrdItem.Mobile_No__c = string.valueof(refundItem.get('mobile_no'));
                        }
                        if(refundItem.KeySet().contains('email_id') && !string.isBlank(string.valueof(refundItem.get('email_id'))))
                        {
                            if(string.valueof(refundItem.get('email_id')).length()<255)
                            {
                                RefundOrdItem.Email_Id_copy__c = string.valueof(refundItem.get('email_id'));
                            }
                            else
                            {
                                RefundOrdItem.Email_Id_copy__c = string.valueof(refundItem.get('email_id')).substring(0,255);
                            }
                            if(!string.valueof(refundItem.get('email_id')).contains(' ')&& validateEmail(string.valueof(refundItem.get('email_id')))==true)
                            {
                                RefundOrdItem.Email_ID__c = string.valueof(refundItem.get('email_id'));
                            }
                        }
                        if(refundItem.KeySet().contains('refund_for_tin') && !string.isBlank(string.valueof(refundItem.get('refund_for_tin'))))
                        {
                            RefundOrdItem.Refund_For_Tin__c = string.valueof(refundItem.get('refund_for_tin'));
                        }
                        if(refundItem.KeySet().contains('refund_type') && !string.isBlank(string.valueof(refundItem.get('refund_type'))))
                        {
                            RefundOrdItem.Refund_Type__c = string.valueof(refundItem.get('refund_type'));
                        }
                        
                        if(refundItem.KeySet().contains('pg_name') && !string.isBlank(string.valueof(refundItem.get('pg_name'))))
                        {
                            RefundOrdItem.PG_Name__c = string.valueof(refundItem.get('pg_name'));
                        }
                        if(refundItem.KeySet().contains('pg_reference_no') && !string.isBlank(string.valueof(refundItem.get('pg_reference_no'))))
                        {
                            RefundOrdItem.PG_Reference_No__c = string.valueof(refundItem.get('pg_reference_no'));
                            
                            pgReferencePayItems.add(RefundOrdItem.PG_Reference_No__c);
                        }
                        if(refundItem.KeySet().contains('pg_type') && !string.isBlank(string.valueof(refundItem.get('pg_type'))))
                        {
                            RefundOrdItem.PG_Type__c = string.valueof(refundItem.get('pg_type'));
                        }
                        if(refundItem.KeySet().contains('bank_name') && !string.isBlank(string.valueof(refundItem.get('bank_name'))))
                        {
                            RefundOrdItem.Bank_Name__c = string.valueof(refundItem.get('bank_name'));
                        }
                        if(refundItem.KeySet().contains('card_no') && !string.isBlank(string.valueof(refundItem.get('card_no'))))
                        {
                            RefundOrdItem.Card_No__c = string.valueof(refundItem.get('card_no'));
                        }
                        if(refundItem.KeySet().contains('creation_time_long') && !string.isBlank(string.valueof(refundItem.get('creation_time_long'))))
                        {
                            RefundOrdItem.Creation_Time_Long__c = string.valueof(refundItem.get('creation_time_long'));
                        }
                        if(refundItem.KeySet().contains('guid') && !string.isBlank(string.valueof(refundItem.get('guid'))))
                        {
                            RefundOrdItem.Guid__c = string.valueof(refundItem.get('guid'));
                        }
                        if(refundItem.KeySet().contains('arnNumber') && !string.isBlank(string.valueof(refundItem.get('arnNumber'))))
                        {
                            RefundOrdItem.ARN_Number__c = string.valueof(refundItem.get('arnNumber'));
                        }
                        if(refundItem.KeySet().contains('cleared_time') && !string.isBlank(string.valueof(refundItem.get('cleared_time'))))
                        {
                            if(string.valueof(refundItem.get('cleared_time')).contains('T'))
                            {
                                RefundOrdItem.cleared_time__c = datetime.valueof(string.valueof(refundItem.get('cleared_time')).replace('T',' '));
                            }
                            else
                            {
                                RefundOrdItem.cleared_time__c = datetime.valueof((string)refundItem.get('cleared_time'));
                            }
                        }
                        if(refundItem.KeySet().contains('refunded_amount') && !string.isBlank(string.valueof(refundItem.get('refunded_amount'))))
                        {
                            RefundOrdItem.refunded_amount__c = double.valueof(refundItem.get('refunded_amount'));
                        }
                        if(refundItem.KeySet().contains('refunded_time') && !string.isBlank(string.valueof(refundItem.get('refunded_time'))))
                        {
                            if(string.valueof(refundItem.get('refunded_time')).contains('T'))
                            {
                                RefundOrdItem.refunded_time__c = datetime.valueof(string.valueof(refundItem.get('refunded_time')).replace('T',' '));
                            }
                            else
                            {
                                RefundOrdItem.refunded_time__c = datetime.valueof((string)refundItem.get('refunded_time'));
                            }
                        }
                        /*
                        if(refundItem.KeySet().contains('updated_by') && !string.isBlank(string.valueof(refundItem.get('updated_by'))))
                        {
                        RefundOrdItem.Updated_By__c = string.valueof(refundItem.get('updated_by'));
                        }
                        if(refundItem.KeySet().contains('updated_time') && !string.isBlank(string.valueof(refundItem.get('updated_time'))))
                        {
                        if(string.valueof(refundItem.get('updated_time')).contains('T'))
                        {
                        RefundOrdItem.Updated_Time__c = datetime.valueof(string.valueof(refundItem.get('updated_time')).replace('T',' '));
                        }
                        else
                        {
                        RefundOrdItem.Updated_Time__c = datetime.valueof((string)refundItem.get('updated_time'));
                        }
                        }
                        if(refundItem.KeySet().contains('version') && !string.isBlank(string.valueof(refundItem.get('version'))))
                        {
                        RefundOrdItem.Version__c = integer.valueof(refundItem.get('version'));
                        }
                        */
                        System.debug('RefundOrdItem...'+RefundOrdItem.Order_Item_Name__r);
                        RefundOrderItems.add(RefundOrdItem);
                    }
                    if(!RefundOrderItems.isEmpty())
                    {
                        System.debug('RefundOrderItems...'+RefundOrderItems);
                        
                        if(!listOrItemsRefOrItems.isEmpty())
                            Database.UpsertResult[] itemsupsertResult = Database.upsert(listOrItemsRefOrItems,Order_Items__c.ID__c,false);
                        
                        if(!listPayItemsRefOrItems.isEmpty())
                            Database.UpsertResult[] payitemsupsertResult = Database.upsert(listPayItemsRefOrItems,Payment_Items__c.ID__c,false);
                        
                        Database.UpsertResult[] upsertResult = Database.upsert(RefundOrderItems,Refund_Order_Items__c.ID__c,false);
                        list<string> SuccessList = new list<string>();
                        list<string> FailedList = new list<string>();
                        list<string> FailedDesscList = new list<string>();
                        List<Id> listRefIds = new List<Id>();
                        
                        for(Integer i=0;i<upsertResult.size();i++)
                        {
                            listRefIds.add(upsertResult.get(i).getId());
                            
                            if (upsertResult.get(i).isSuccess())
                            {
                                SuccessList.add(refundIds[i]);
                            }
                            else if(!upsertResult.get(i).isSuccess())
                            {
                                DBLog.add(prepareDBLog('RefundOrderItems',string.valueof(refundIds[i]),string.valueof(upsertResult.get(i).getErrors())));
                                refundFailedPro.add(JSON.Serialize(RefundOrderItems[i]));
                                FailedList.add(refundIds[i]);
                                FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                            }
                        }
                        
                        resp.refundOrderItemsSuccess = SuccessList;
                        resp.refundOrderItemsSuccessCount = SuccessList.size();
                        resp.refundOrderItemsFailed = FailedList;
                        resp.refundOrderItemsFailedCount = FailedList.size();
                        resp.refundOrderItemsFailDescription = FailedDesscList;
                        
                        if(RefundOrderItems.size()==SuccessList.size())
                            resp.refundOrderItemsProcessStatus = 'Success';
                        else if(RefundOrderItems.size()==FailedList.size())
                            resp.refundOrderItemsProcessStatus = 'Fail';
                        else
                            resp.refundOrderItemsProcessStatus = 'Partial';
                        
                        dbl.Refund_Order_Items_Success__c = string.join(SuccessList,',');
                        dbl.Refund_Order_Items_Success_Count__c = resp.refundOrderItemsSuccessCount;
                        dbl.Refund_Order_Items_Failed__c = string.join(FailedList,',');
                        dbl.Refund_Order_Items_Failed_Count__c = resp.refundOrderItemsFailedCount;
                        
                         if( !string.isBlank(string.valueof(string.join(FailedDesscList,','))) && string.valueof(string.join(FailedDesscList,',')).length()>25000)
                           {
                                dbl.Refund_Order_Items_Fail_Description__c = string.valueof(string.join(FailedDesscList,',')).substring(0,24000);
                           }
                           else
                           {
                                dbl.Refund_Order_Items_Fail_Description__c = string.join(FailedDesscList,',');
                           }
                       
                        
                        dbl.Refund_Order_Items_Process_Status__c = resp.refundOrderItemsProcessStatus;
                    }
                    RefundOrderItems.clear();
                }
                /*--------------------------------RefundOrderItems End---------------------*/
                
                if(!DBLog.isEmpty())
                    database.insert(DBLog);
                
                Attachment att = new Attachment();
                att.name = 'Data'+String.valueOf(System.Now());
                att.Body = blob.valueof(req.requestBody.toString());
                att.ParentId = Id.valueOf(dbLogSummId);
                database.insert(att);
                
            
            if(!OrderIds.isEmpty() || !orderItemIds.isEmpty() || !OrderItemFareComponentids.isEmpty() || !PaymentSessionIds.isEmpty() || !PaymentItemsIds.isEmpty() || !PGPaymentItemsids.isEmpty() || !BusOrderItemDetailsids.isEmpty() || !TravellerInfoIds.isEmpty() || !cancelOrderItemIds.isEmpty() || !refundIds.isEmpty() )
            {
                API_redBus_Booking_Future.ProcessBookingINfo(customerIds, custPhoneNumbers, orCustList, primaryEmails, primaryPhoneNumbers, orItemprimaryEmails, orItemcustList, allOrdersids, allOrderItemids, OrderItemFareComponentids, PaymentSessionIds, PaymentItemsIds, PGPaymentItemsids, BusOrderItemDetailsids,  TravellerInfoIds, PaymentItemSessionIds, pgReferencePayItems,cancelOrderItemIds,refundIds, filterOrderIds,dbLogSummId,orderItemFailedPro,PaymentItemsFailedPro,OrderFailedPro,OrderItemFareComponentFailedPro,PaymentSessionFailedPro,PGPaymentItemsFailedPro,BusOrderItemDetailsFailedPro,TravellerInfoFailedPro,cancelOrderItemFailedPro,refundFailedPro);
            }
            
            dbl.Payment_Request_Response_Time__c = System.now();
            DataBase.upsert(dbl);
         
          }
        }
        catch(exception e)
        {
            //Database.rollback(sp);
            resp = new response();
            resp.exceptionDescription = string.valueof(e);
            resp.exceptionTableName = ProcessExceptionTableName;
            resp.exceptionId = ProcessExceptionId;
            
            DBLog_Summary__c dbl = new DBLog_Summary__c(id=dbLogSummId);
            dbl.Traveller_Info_Data_Received_Ids__c = string.join(TravellerInfoIds,',');
            dbl.Orders_Received_Data_Ids__c = string.join(OrderIds,',');
            dbl.Order_Items_Data_Received_Ids__c = string.join(orderItemIds,',');
            dbl.Order_Item_Fare_Components_Received_Ids__c = string.join(OrderItemFareComponentids,',');
            dbl.PG_Payment_Items_Data_Received_Ids__c = string.join(PaymentSessionIds,',');
            dbl.Payment_Items_Data_Received_Ids__c = string.join(PaymentItemsIds,',');
            dbl.PG_Payment_Items_Data_Received_Ids__c = string.join(PGPaymentItemsids,',');
            dbl.BusOrder_Items_Data_Received_Ids__c = string.join(BusOrderItemDetailsids,',');
            dbl.Cancelled_Order_Items_Data_Received_Ids__c = string.join(cancelOrderItemIds,',');
            dbl.Refund_Order_Items_Data_Received_Ids__c = string.join(refundIds,',');
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
        Boolean res = true;
        //String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        
        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    }
    
    static DB_Log__c prepareDBLog(String objName,String recId,String errDesc)
    {
        DB_Log__c DB = new DB_Log__c();
        DB.Object_Name__c = objName;
        DB.Lock_type__c = 'redBus Data process';
        DB.DBLog_Summary__c = Id.valueOf(dbLogSummId);
        DB.ID__c = recId;     
        DB.Error_Description__c = errDesc;
        if(DB.Error_Description__c.Contains('getStatusCode=INVALID_FIELD'))
        {
            DB.Locked_record__c = false;
        }
        return DB;
    }    
    
    global class Response
    {
        string exceptionDescription;
        string exceptionTableName;
        string exceptionId;
        list<string> ordersSuccess;
        integer ordersSuccessCount;
        list<string> ordersFailed;
        integer ordersFailedCount;
        list<string> ordersFailDescription;
        string ordersProcessStatus;
        list<string> orderItemsSuccess;
        integer orderItemsSuccessCount;
        list<string> orderItemsFailed;
        integer orderItemsFailedCount;
        list<string> orderItemsFailDescription;
        string orderItemsProcessStatus;
        list<string> orderItemFareComponentsSuccess;
        integer orderItemFareComponentsSuccessCount;
        list<string> orderItemFareComponentsFailed;
        integer orderItemFareComponentsFailedCount;
        list<string> orderItemFareComponentsFailDescription;
        string orderItemFareComponentsProcessStatus;
        list<string> paymentItemsSuccess;
        integer paymentItemsSuccessCount;
        list<string> paymentItemsFailed;
        integer paymentItemsFailedCount;
        list<string> paymentItemsFailDescription;
        string paymentItemsProcessStatus;
        list<string> paymentSessionsSuccess;
        integer paymentSessionsSuccessCount;
        list<string> paymentSessionsFailed;
        integer paymentSessionsFailedCount;
        list<string> paymentSessionsFailDescription;
        string paymentSessionsProcessStatus;
        list<string> pgPaymentItemsSuccess;
        integer pgPaymentItemsSuccessCount;
        list<string> pgPaymentItemsFailed;
        integer pgPaymentItemsFailedCount;
        list<string> pgPaymentItemsFailDescription;
        string pgPaymentItemsProcessStatus;
        list<string> travellerInfoSuccess;
        integer travellerInfoSuccessCount;
        list<string> travellerInfoFailed;
        integer travellerInfoFailedCount;
        list<string> travellerInfoFailDescription;
        string travellerInfoProcessStatus;
        list<string> busOrderItemDetailsSuccess;
        integer busOrderItemDetailsSuccessCount;
        list<string> busOrderItemDetailsFailed;
        integer busOrderItemDetailsFailedCount;
        list<string> busOrderItemDetailsFailDescription;
        string busOrderItemDetailsProcessStatus;
        list<string> refundOrderItemsSuccess;
        integer refundOrderItemsSuccessCount;
        list<string> refundOrderItemsFailed;
        integer refundOrderItemsFailedCount;
        list<string> refundOrderItemsFailDescription;
        string refundOrderItemsProcessStatus;
        list<string> cancelledOrderItemsSuccess;
        integer cancelledOrderItemsSuccessCount;
        list<string> cancelledOrderItemsFailed;
        integer cancelledOrderItemsFailedCount;
        list<string> cancelledOrderItemsFailDescription;
        string cancelledOrderItemsProcessStatus;
        public Response()
        {
            
        }
    }
    
}