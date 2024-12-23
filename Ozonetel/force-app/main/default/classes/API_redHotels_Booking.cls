/*
* Name           : API_redHotels_Booking
* Created Date   : 13 Dec 2017
* Created By     : Veeramanikanta R
* Purpose        : Used for Push hotels data to SF
* Test class     : API_redHotels_Booking_Test
*/
@RestResource(urlMapping='/redBus/redHotel_Booking/*')
global without sharing class API_redHotels_Booking
{
    static list<string> orderItemIds=new list<string>();
    static string ProcessExceptionId;
    static string ProcessExceptionTableName;
    
    @HttpPost
    global static response doPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Response resp=new Response();
        try{ 
            System.debug('req--->'+req.requestBody.toString());
            String mJson='{"type":"BOOKING","sentAt":"2017-09-17 11:05:27","hotels":[{"email":"nantha138@gmail.com","orderItemId":"12345","phone":"9901313573","hotel_name":"Hotel Durai( 20 Kms away from Pondicherry)","orderId":2649491,"checkIn":"2017-12-23T00:00:00","checkOut":"2017-12-24T00:00:00","pax":{"Item1":2,"Item2":"2,2","Item3":"0,0"},"destination":"Cuddalore","paidAmount":1355.00000,"discountAmount":null,"offerCodeUsed":null,"status":"CONFIRMED","dateOfBooking":"2017-12-13T00:00:00","operationType":"UPDATE"},{"email":"mani@gmail.com","orderItemId":"67890","phone":"9491322718","hotel_name":"Shewtha Hotel (Beside bustand)","orderId":2649556,"checkIn":"2017-12-23T00:00:00","checkOut":"2017-12-24T00:00:00","pax":{"Item1":2,"Item2":"2,2","Item3":"0,0"},"destination":"Karimnagar","paidAmount":1234.00000,"discountAmount":null,"offerCodeUsed":null,"status":"CONFIRMED","dateOfBooking":"2017-12-13T00:00:00","operationType":"UPDATE"}]}';
            //map<string,object> booking = (map<string,object>)JSON.deserializeUntyped(req.requestBody.toString());
            map<string,object> booking = (map<string,object>)JSON.deserializeUntyped(req.requestBody.toString());
            list<object> hotelsList = (list<object>)booking.get('hotels');
            System.debug('test'+hotelsList);
            List<Order_Items__c> tObjList=new List<Order_Items__c>();
            ProcessExceptionTableName='OrderItems';
            Id recTypeId = Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();        
            integer cihours=0;
            integer ciminutes=0;
            integer cohours=0;
            integer cominutes=0;
            integer doiMinutes;
            integer doiHours;
            string dateOfIssue;
            string checkInTime;
            string checkOutTime;  
           
           set<string> userIds=new set<string>();
                   map<string,account> OrdersUserIdsMap = new map<string,account>();

           for(Object o:hotelsList){
                map<string,object> hotelObj=(map<string,object>)(o);
                if(string.valueof(hotelObj.get('rbUserId')) !='')
               userIds.add(string.valueof(hotelObj.get('rbUserId')));
           } 
           System.debug('userIds-->'+userIds);
            for(Account acc:[select id,User_Id__c from account where User_Id__c in:userIds]){
                     OrdersUserIdsMap.put(acc.User_Id__c,acc);
            }
            System.debug('OrdersUserIdsMap--->'+OrdersUserIdsMap);      
            for(Object o:hotelsList){
                map<string,object> hotelObj=(map<string,object>)(o);
                Order_Items__c tObj=new Order_Items__c();
                map<string, object> paxObj= (map<string, object>)hotelObj.get('pax');
                System.debug('paxObj-->'+string.valueof(paxObj.get('Item1')));
                
                orderItemIds.add(string.valueof(hotelObj.get('orderItemId')));
                ProcessExceptionId = string.valueof(hotelObj.get('orderItemId'));
                tObj.RecordTypeId=recTypeId;
                
                if(OrdersUserIdsMap.KeySet().Contains(string.valueof(hotelObj.get('rbUserId'))))
                tObj.Customer_Name__c = OrdersUserIdsMap.get(string.valueof(hotelObj.get('rbUserId'))).id;
                               
                tObj.ID__c=string.valueof(hotelObj.get('orderItemId'));
                tObj.No_Of_Rooms__c=integer.valueof(paxObj.get('Item1'));
                tObj.No_Of_Adults__c=string.valueof(paxObj.get('Item2'));
                tObj.No_Of_Children__c=string.valueof(paxObj.get('Item3'));
                
                tObj.Name=string.valueof(hotelObj.get('orderItemId'));
                tObj.Hotel_name__c=string.valueof(hotelObj.get('hotel_name'));
                tObj.Order_Id__c=string.valueof(hotelObj.get('orderId'));
                tObj.Email__c=string.valueof(hotelObj.get('email'));
                tObj.Mobile__c=string.valueof(hotelObj.get('phone'));
                tObj.Discount_Value__c=double.valueof(hotelObj.get('discountAmount'));
                tObj.Offer_Code__c=string.valueof(hotelObj.get('offerCodeUsed'));
                tObj.Hotel_Booking_Id__c=string.valueof(hotelObj.get('hotelBookingId'));
                tObj.Voucher_Id__c=string.valueof(hotelObj.get('voucherId'));
                
                checkInTime=string.valueof(hotelObj.get('checkInTime'));
                checkOutTime=string.valueof(hotelObj.get('checkOutTime'));
                
                if(string.valueof(hotelObj.get('checkInTime')).contains(':'))
                {               
                    cihours= integer.valueof(checkInTime.substring(0,2));
                    ciminutes= integer.valueof(checkInTime.substring(3,5));
                }else if(string.valueof(hotelObj.get('checkInTime'))!=''){
                    cihours= integer.valueof(checkInTime.substring(0,2));
                    ciminutes= integer.valueof(checkInTime.substring(2,4));
                }
                
                if(string.valueof(hotelObj.get('checkOutTime')).contains(':'))
                {               
                    cohours= integer.valueof(checkOutTime.substring(0,2));
                    cominutes= integer.valueof(checkOutTime.substring(3,5));
                }else if(string.valueof(hotelObj.get('checkOutTime'))!=''){
                    cohours= integer.valueof(checkOutTime.substring(0,2));
                    cominutes= integer.valueof(checkOutTime.substring(2,4));
                }
                
                datetime OrDate;
                if(string.valueof(hotelObj.get('checkInDate')).contains('T'))
                {
                    tObj.Check_In__c = datetime.valueof(string.valueof(hotelObj.get('checkInDate')).replace('T',' ')).addHours(cihours).addMinutes(ciminutes);
                }
                else
                {
                    tObj.Check_In__c = datetime.valueof((string)hotelObj.get('checkInDate')).addHours(cihours).addMinutes(ciminutes);
                }
                
                if(string.valueof(hotelObj.get('checkOutDate')).contains('T'))
                {
                    tObj.Check_Out__c= datetime.valueof(string.valueof(hotelObj.get('checkOutDate')).replace('T',' ')).addHours(cohours).addMinutes(cominutes);
                }
                else
                {
                    tObj.Check_Out__c = datetime.valueof((string)hotelObj.get('checkOutDate')).addHours(cohours).addMinutes(cominutes);
                }            
                tObj.Destination__c=string.valueof(hotelObj.get('destination'));
                tObj.Total_Fare_Value__c=double.valueof(hotelObj.get('totalFareValue'));
                tObj.Rb_User_ID__c=string.valueof(hotelObj.get('rbUserId'));
                tObj.Total_Fare_Currency__c=string.valueof(hotelObj.get('totalFareCurrency'));
                tObj.Booking_Signed_in_Email_ID__c=string.valueof(hotelObj.get('signedInUserEmail'));
                tObj.Booking_Signed_in_Phone_Number__c=string.valueof(hotelObj.get('signedInUserMobile'));               
                tObj.Transaction_Status__c=string.valueof(hotelObj.get('status'));
                
                    
                if(string.valueof(hotelObj.get('dateOfBooking')).contains('T'))
                {
                    tObj.Date_Of_Purchase__c= datetime.valueof(string.valueof(hotelObj.get('dateOfBooking')).replace('T',' '));
                }
                else
                {
                    tObj.Date_Of_Purchase__c = datetime.valueof((string)hotelObj.get('dateOfBooking'));
                }
                
                tObjList.add(tObj);       
            }
            
            Database.UpsertResult[] upsertResult = Database.upsert(tObjList,Order_Items__c.ID__c,false);
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
                    FailedList.add(orderItemIds[i]);
                    FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                }
            }    
            resp.orderItemsSuccess = SuccessList;
            resp.orderItemsSuccessCount = SuccessList.size();
            resp.orderItemsFailedCount = FailedList.size();
            resp.orderItemsFailedCount = FailedList.size();
            resp.orderItemsFailDescription = FailedDesscList;
            if(tObjList.size()==SuccessList.size())
            {
                resp.orderItemsProcessStatus = 'Success';
            }
            else
                if(tObjList.size()==FailedList.size())
            {
                resp.orderItemsProcessStatus = 'Fail';
            }
            else
            {
                resp.orderItemsProcessStatus = 'Partial';
            }
            
        }catch(Exception e){
            System.debug('Exception-->'+e);
            resp = new response();
            resp.exceptionDescription = string.valueof(e);
            resp.exceptionTableName = ProcessExceptionTableName;
            resp.exceptionId = ProcessExceptionId;
        }
        return resp;
        
    }
    global class Response
    {
        string exceptionDescription;
        string exceptionTableName;
        string exceptionId;
        
        /*  list<string> ordersSuccess;
integer ordersSuccessCount;
list<string> ordersFailed;
integer ordersFailedCount;
list<string> ordersFailDescription;
string ordersProcessStatus;*/
        
        list<string> orderItemsSuccess;
        integer orderItemsSuccessCount;
        list<string> orderItemsFailed;
        integer orderItemsFailedCount;
        list<string> orderItemsFailDescription;
        string orderItemsProcessStatus;
    }
    
}