/*
* Name           : callPopUpPaymentDetailsCtrl
* Created Date   : 2023-DEC-13
* Created By     : VR Sudarshan 
* Purpose        : Controller to show the refund details of predicted transaction on call details page.
* Test class     : callPopUpPaymentDetailsCtrlTest
* Jira Id        : CRM-1576
*/
public class callPopUpPaymentDetailsCtrl {

    @AuraEnabled(cacheable=true)
    public static List<finalWrapperToReturn> fetchPaymentDetails(string callDetailsId){
        List<finalWrapperToReturn> wrapperList = new List<finalWrapperToReturn>();

        finalWrapperToReturn wrapper = new finalWrapperToReturn();
        List<Call_Details__c> callDetailsData = [SELECT ID, TIN_No__c, PredictedOrderUuid__c FROM Call_Details__c WHERE Id=: callDetailsId AND Business_Unit__c!='RAILS' LIMIT 1];

        if(!callDetailsData.isEmpty() && String.isNotBlank(callDetailsData[0].PredictedOrderUuid__c)){
            List<Order_Items__c> ordList = [select id,Creation_Time__c,Transaction_Status_WFT_GFT__c,Transaction_Status__c, Ticket_Confirmed_Time__c,Cancellation_Time__c, Refund_Status__c,status__c, Refund_Initiated_Time__c,  (select Id,Refund_Amount__c,Created_By__c,Refund_Reason__c, Creation_Time__c,PG_Type__c, Card_No__c,Bank_Name__c, ARN_Number__c, Order_Item_Name__c,Order_Item_Name__r.Name, PG_Reference_No__c, PG_Name__c,Refunded_Time__c, Refund_Type__c,createdDate  from Refund_Order_Items__r) from Order_Items__c where OrderUuid__c =:callDetailsData[0].PredictedOrderUuid__c LIMIT 1];
            for (Order_Items__c ord : ordList) {
                wrapper.transactionStatus = String.isNotBlank(ord.Transaction_Status__c)?ord.Transaction_Status__c:'No Data';
                if(String.isNotBlank(ord.Transaction_Status_WFT_GFT__c)){
                    wrapper.isGFT = true;
                }else{
                    wrapper.isGFT = false;
                }
                List<dataToBeMapped> refundDataList = new List<dataToBeMapped>();
                Integer refundOrderItemNumber = 1;
                System.debug('::: Size of OrderItems ='+ord.Refund_Order_Items__r.size());
                if (ord.Refund_Order_Items__r.size()>0) {
                    for (Refund_Order_Items__c refundItem : ord.Refund_Order_Items__r) {
                        Map<string,string> pathListToShow = New Map<string,string>();
                        dataToBeMapped refundData = new dataToBeMapped();
                        refundData.arnNumber = String.isNotBlank(refundItem.ARN_Number__c)?refundItem.ARN_Number__c:'No Data';
                        refundData.refundType = String.isNotBlank(refundItem.Refund_Type__c)?refundItem.Refund_Type__c:'No Data';
                        refundData.transactionId = String.isNotBlank(refundItem.Order_Item_Name__r.Name)?refundItem.Order_Item_Name__r.Name:'No Data';
                        refundData.pgReferenceId = String.isNotBlank(refundItem.PG_Reference_No__c)?refundItem.PG_Reference_No__c:'No Data';
                        refundData.pgName = String.isNotBlank(refundItem.PG_Name__c)?refundItem.PG_Name__c:'No Data';
                        refundData.paymentType = String.isNotBlank(refundItem.PG_Type__c)?refundItem.PG_Type__c:'No Data';
                        refundData.isUpiPayment = refundItem.PG_Type__c=='UPIPayments' || refundItem.PG_Type__c=='UPI Payments'?true:false;
                        refundData.cardNumber = String.isNotBlank(refundItem.Card_No__c)?refundItem.Card_No__c:'No Data';
                        refundData.bankName = String.isNotBlank(refundItem.Bank_Name__c)?refundItem.Bank_Name__c:'No Data';
                        refundData.refundCreatedBy = String.isNotBlank(refundItem.Created_By__c)?refundItem.Created_By__c:'No Data';
                        refundData.refundReason = String.isNotBlank(refundItem.Refund_Reason__c)?refundItem.Refund_Reason__c:'';
                        // refundData.transactionStatus = String.isNotBlank(ord.Transaction_Status__c)?ord.Transaction_Status__c:'No Data';
                        

                        string formattedCancellationTime = '-- Data not Available--';
                        if(string.isNotBlank(String.valueOf(ord.Cancellation_Time__c))){
                            formattedCancellationTime = String.valueOf(ord.Cancellation_Time__c.date())+' | '+ord.Cancellation_Time__c.format('HH:mm:ss');
                        }

                        string formattedBookingCnfrmTime = '-- Data not Available--';
                        if(string.isNotBlank(String.valueOf(ord.Ticket_Confirmed_Time__c))){
                            formattedBookingCnfrmTime = String.valueOf(ord.Ticket_Confirmed_Time__c.date())+' | '+ord.Ticket_Confirmed_Time__c.format('HH:mm:ss');
                        }
                    
                        string formattedTransactionCreationTime = '-- Data not Available--';
                        if(String.isNotBlank(String.valueOf(ord.Creation_Time__c))){
                            formattedTransactionCreationTime = String.valueOf(ord.Creation_Time__c.date())+' | '+ord.Creation_Time__c.format('HH:mm:ss');
                        }

                        string refundCreationTime = '-- Data not Available--';
                        if(String.isNotBlank(String.valueOf(refundItem.Creation_Time__c))){
                            refundCreationTime = String.valueOf(refundItem.Creation_Time__c.date())+' | '+refundItem.Creation_Time__c.format('HH:mm:ss');
                        }

                        string refundedOnTime = '-- Data not Available--';
                        if(String.isNotBlank(String.valueOf(refundItem.Refunded_Time__c))){
                            refundedOnTime = String.valueOf(refundItem.Refunded_Time__c.date())+' | '+refundItem.Refunded_Time__c.format('HH:mm:ss');
                        }

                        
                        if(String.isNotBlank(String.valueOf(refundItem.Refunded_Time__c))){
                            refundData.refundHappened = true;
                            refundData.refundStatus='credited';
                        }else{
                            refundData.refundStatus='initiated';
                            refundData.refundHappened = false;
                            dateTime tempRefundDate = refundItem.createdDate;
                            refundData.tentativeRefundDate = String.valueOf(tempRefundDate.date().addDays(2));
                            
                        }
                        //refundData.pgLink = 'No Data';
                        if(String.isNotBlank(refundItem.PG_Name__c)){
                            list<PG_Credentialscntrl.ResponseData> respData = PG_Credentialscntrl.getPGdetails(string.valueOf(ord.Id));
                            refundData.pgLink = String.isNotBlank(String.valueOf(respData[0].pgLink))?String.valueOf(respData[0].pgLink):'No Data';
                        }else{
                            refundData.pgLink = 'Incorrect PG Name';
                        }

                        if(formattedCancellationTime != '-- Data not Available--'){
                            refundData.cancellationApplicable = true;
                            refundData.sldsBoxWidth='width:187%';
                        }else{
                            refundData.cancellationApplicable = false;
                            refundData.sldsBoxWidth='width:225%';
                        }
                        
                        refundData.refundSlNO = refundOrderItemNumber;
                        refundData.refundAmount = String.isNotBlank(refundItem.Refund_Amount__c)?refundItem.Refund_Amount__c:'No Data';
                        refundOrderItemNumber++;
                        refundDataList.add(refundData);
                        wrapper.refundOrdersData = refundDataList;
                        pathListToShow.put('CreationTime',+formattedTransactionCreationTime);
                        pathListToShow.put('BookingTime',+formattedBookingCnfrmTime);
                        pathListToShow.put('CancellationTime',+formattedCancellationTime);
                        pathListToShow.put('RefundCreationTime',+refundCreationTime);
                        pathListToShow.put('RefundedOn',+refundedOnTime);
                        refundData.pathListwithTime = pathListToShow;
                        refundData.currentActivePath = formattedTransactionCreationTime;
                        if(formattedBookingCnfrmTime!='-- Data not Available--'){
                            refundData.currentActivePath = formattedBookingCnfrmTime;
                        }
                        if(formattedCancellationTime!='-- Data not Available--'){
                            refundData.currentActivePath = formattedCancellationTime;
                        }
                        if(refundCreationTime!='-- Data not Available--'){
                            refundData.currentActivePath = refundCreationTime;
                        }
                        if(refundedOnTime!='-- Data not Available--'){
                            refundData.currentActivePath = refundedOnTime;
                        }
                    }
                    wrapperList.add(wrapper);
                }else{
                    wrapper.noRefunds = true;
                    wrapper.errorMessage = 'No refunds exits for this transaction';
                    wrapperList.add(wrapper);
                }
                
            }
            return wrapperList;
        }
        wrapper.isError=true;
        wrapper.errorMessage = 'Unable to fetch refund details. Invalid Transaction, Please contact system administrator.';
        wrapperList.add(wrapper);
        return wrapperList;
    }

    public class finalWrapperToReturn{
        @AuraEnabled
        public List<dataToBeMapped> refundOrdersData { get; set; }
        @AuraEnabled
        public Boolean isError { get; set; }
        @AuraEnabled
        public Boolean noRefunds { get; set; }
        @AuraEnabled
        public string errorMessage { get; set; }
        @AuraEnabled
        public String transactionStatus { get; set; }
        @AuraEnabled
        public boolean isGFT { get; set; }
    }

    public class dataToBeMapped{
        @AuraEnabled
        public string arnNumber { get; set; }
        @AuraEnabled
        public string refundCreatedBy { get; set; }
        @AuraEnabled
        public string refundReason { get; set; }
        @AuraEnabled
        public string refundType { get; set; }
        @AuraEnabled
        public string transactionId { get; set; }
        @AuraEnabled
        public string pgReferenceId { get; set; }
        @AuraEnabled
        public string pgName { get; set; }
        @AuraEnabled
        public string pgLink { get; set; }
        @AuraEnabled
        public Integer refundSlNO { get; set; }
        @AuraEnabled
        public string refundAmount { get; set; }
        @AuraEnabled
        public string refundStatus { get; set; }
        @AuraEnabled
        public Map<string,string> pathListwithTime { get; set; } 
        @AuraEnabled
        public string currentActivePath { get; set; } 
        @AuraEnabled
        public boolean refundHappened { get; set; }
        @AuraEnabled
        public String tentativeRefundDate { get; set; }
        @AuraEnabled
        public String paymentType { get; set; }
        @AuraEnabled
        public String cardNumber { get; set; }
        @AuraEnabled
        public String bankName { get; set; }
        @AuraEnabled
        public boolean isUpiPayment { get; set; }
        @AuraEnabled
        public Boolean cancellationApplicable { get; set; }
        @AuraEnabled
        public string sldsBoxWidth { get; set; }
    }
}