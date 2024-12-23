@isTest
private class callPopUpPaymentDetailsCtrlTest {
    @isTest static void fullRefundTestMethod(){
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c ='2551211';
        orIt.OrderUuid__c ='123333';
        orIt.Date_Of_Service__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        orIt.Email_Copy__c ='test@mail.com';
        orIt.Total_Fare_Currency__c  = 'INR';
        orIt.Payment_Details__c ='{"id":13497991163146082,"orderId":13497991163146082,"uuid":"3f0ebdecfe8bf005de86aae302010100","creationTime":"2023-06-20T08:14:55","businessUnit":"REDBUS_IN","orderValue":{"currencyType":"INR","amount":0},"amountReceivable":{"currencyType":"INR","amount":0},"amountPaid":{"currencyType":"INR","amount":0},"refundableSurplus":{"currencyType":"INR","amount":0},"paymentItemList":[{"id":13497991207847210,"orderId":13497991163146082,"uuid":"3f6400a5fe8bf005773af32a02030100","refunds":[{"reason":"Instant refund - Collectible from BO","updatedBy":"IRIS Refunds","refundedBy":"(integration@redbus.com.lexbackup)","refundType":"ONLINE","refundTime":1687778321395917,"refundStatus":"REFUND_SUCCESSFUL","refundAmount":{"currencyType":"INR","amount":15.5},"refundCreationTime":"2023-06-26T11:17:37","refundCategory":"EXCEPTIONAL_REFUND","order_item_uuid":"3f0ec464fe8bf005de86aae302020100","channel":"SFA","refNo":"1254554418","orderItemId":0,"index":5},{"reason":"Instant refund - Collectible from BO","updatedBy":"IRIS Refunds","refundedBy":"(integration@redbus.com.lexbackup)","refundType":"ONLINE","refundTime":1687777364099013,"refundStatus":"REFUND_SUCCESSFUL","refundAmount":{"currencyType":"INR","amount":5},"refundCreationTime":"2023-06-26T11:01:31","refundCategory":"EXCEPTIONAL_REFUND","order_item_uuid":"3f0ec464fe8bf005de86aae302020100","channel":"SFA","refNo":"1254554418","orderItemId":0,"index":4},{"reason":"Instant refund - Collectible from BO","updatedBy":"IRIS Refunds","refundedBy":"(integration@redbus.com.lexbackup)","refundType":"ONLINE","refundTime":1687776882264967,"refundStatus":"REFUND_SUCCESSFUL","refundAmount":{"currencyType":"INR","amount":10},"refundCreationTime":"2023-06-26T10:53:34","refundCategory":"EXCEPTIONAL_REFUND","order_item_uuid":"3f0ec464fe8bf005de86aae302020100","channel":"SFA","refNo":"1254554418","orderItemId":0,"index":3},{"reason":"Instant refund - Collectible from BO","updatedBy":"IRIS Refunds","refundedBy":"(integration@redbus.com.lexbackup)","refundType":"ONLINE","refundTime":1687776399438801,"refundStatus":"REFUND_SUCCESSFUL","refundAmount":{"currencyType":"INR","amount":12},"refundCreationTime":"2023-06-26T10:45:07","refundCategory":"EXCEPTIONAL_REFUND","order_item_uuid":"3f0ec464fe8bf005de86aae302020100","channel":"SFA","refNo":"1254554418","orderItemId":0,"index":2},{"reason":"Collectible From BO","updatedBy":"IRIS Refunds","refundedBy":"(integration@redbus.com.lexbackup)","refundType":"ONLINE","refundTime":1687776036827627,"refundStatus":"REFUND_SUCCESSFUL","refundAmount":{"currencyType":"INR","amount":10},"refundCreationTime":"2023-06-26T10:38:51","refundCategory":"EXCEPTIONAL_REFUND","order_item_uuid":"3f0ec464fe8bf005de86aae302020100","channel":"SFA","refNo":"1254554418","orderItemId":0,"index":1}],"businessUnitValue":{"currencyType":"INR","amount":52.5},"paymentItemValue":{"currencyType":"INR","amount":52.5},"paymentStatus":"COMPLETED","paymentSessionId":13497991163146082,"paymentSystem":"ONLINE","paymentSystemRefNo":"T2306201345060563517644","updatedBy":"CAPI","creationTime":"2023-06-20T08:15:00","pgName":"PhonePe","pgtype":"UPI Payments","cardNo":"","bankName":"","bankAccountNumber":"","accountHolderName":"","bank_ref_num":"","itemUuids":null,"paymentSubType":"","_meta":{"version":null,"confirm_millisecond":""}}]}';
        insert orIt;

        Refund_Order_Items__c refundOrder = new Refund_Order_Items__c();
        refundOrder.Name='Test';
        refundOrder.Order_Item_Name__c = orIt.Id;
        refundOrder.Refunded_Amount__c = 123;
        refundOrder.ARN_Number__c = 'TESTTEST';
        refundOrder.PG_Reference_No__c = 'PhonePe';
        refundOrder.PG_Name__c = 'PhonePe';
        refundOrder.Refunded_Time__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        insert refundOrder;

        Case cs = new Case();
        cs.transaction_id__c = orIt.Id;
        cs.Status ='Escalated to BD';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='I felt unsafe during the journey';
        cs.Issue_Sub_Category__c ='My bus met with an accident';
        cs.TIN_No__c='TIN6473553';
        cs.Total_Fare_Value__c=250.00;
        cs.Price_Paid_Currency_ctp__c='INR';
        insert cs;

        call_details__c c=new call_details__c ();
        c.PredictedOrderUuid__c ='123333';
        c.Case__c = cs.Id;
        insert c;

        callPopUpPaymentDetailsCtrl.fetchPaymentDetails(String.valueOf(c.Id));


    }
}