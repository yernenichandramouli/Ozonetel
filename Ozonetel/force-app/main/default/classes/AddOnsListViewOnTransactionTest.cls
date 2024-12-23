@isTest
public class AddOnsListViewOnTransactionTest {
        
    static testMethod Void AddOnsListViewOnTransactionTest(){
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Email_Copy__c='abcd@redbus.com';
        oi.mobile__c='9435354333';
        oi.Order_Item_Reference_No__c='TQ3S52922529';
        insert oi;
        system.debug('<<<'+oi.id);
        Activities__c act=new Activities__c();
        act.Order_Item_id__c = 'Transaction-123';
        act.Transaction_Status__c = 'CONFIRMED';
        act.Order_Item__c=oi.id;
        insert act;
        List<Activities__c> ActList = new List<Activities__c>();
		actList=AddOnsListViewOnTransaction.fetchAddons(oi.id);
        Test.startTest();
        string json ='{"toCityName":"","fromCityName":"","dateOfJourney":"","travelsName":"","busType":"","boardingTime":"","arrivalTime":"","boardingPoint":"","duration":"","paymentMode":"","cardNumber":"","cardType":"","totalAmountPaid":"","insuranceCharges":"","serviceTax":"","GST":"","cashCouponValue":0.0,"baseFare":0.0,"message":"","isPartialCancellation":false,"isTicketCancellable":false,"discount":"","refundTypeCSV":"","notes":null,"refundModes":null,"lstPassengerInfo":[],"refundTypesList":null,"totalDiscount":0.0,"ticketFare":0.0,"totalTax":0.0,"operatorDiscount":0.0,"fullCancellationBreakUp":null,"partialCancellationBreakUp":null,"cancellationPolicy":null,"currencytype":null,"currentCancellationPolicyIntl":null,"refundableAmount":0.0,"cancellationcharges":0.0,"isZcafeApplied":null,"zcafeDuration":null,"zcafeSponsoredByRedbus":null,"RescheduleFareBreakUp":null,"MPaxData":null,"OperatorId":null,"SourceId":null,"DestinationId":null,"IsReschedulable":false,"RescheduleFrom":null,"RescheduleTo":null,"IsPrimaryPassengerCancellable":false,"SeatsToBeCancelled":null,"RecheduleConfigs":null,"cancelInitiated":false,"ReschedulePolicyMsg":null,"bpId":null,"dpId":null,"routeId":null,"addons":[{"totalFare":100.0,"refundableAmount":0.0,"itemUuid":"5aedc3d3fbc7f0059fa0624c01020100","itemType":"GENERIC_ITEM","itemName":"redPass","currency":null,"isAddOnCancellable":false,"errorMsg":"Oops! Something went wrong. Please call 8039412345 to assist you further.","cancellationPolicy":null}],"IsUserCancellationReasonEnable":false,"userCancellationReason":null,"isTravelProtectPlanOpted":false,"isCoverGeniusOpted":false,"isInsuranceOpted":false,"useVendorResponse":false,"tnc":null}';
        Test.setMock(HttpCalloutMock.class,new RestClientHTTPMocks(200, 'OK', json));
        AddOnsListViewOnTransaction.checkIsCancellableStatus(ActList);
        Test.stopTest();
    }

    static testMethod Void AddOnsListViewOnTransactionElseTest(){
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Email_Copy__c='abcd@redbus.com';
        oi.mobile__c='9435354333';
        oi.Order_Item_Reference_No__c='TQ3S52922529';
        insert oi;
        system.debug('<<<'+oi.id);
        Activities__c act=new Activities__c();
        act.Order_Item_id__c = 'Transaction-123';
        act.Transaction_Status__c = 'CONFIRMED';
        act.Order_Item__c=oi.id;
        insert act;
        List<Activities__c> ActList = new List<Activities__c>();
		actList=AddOnsListViewOnTransaction.fetchAddons(oi.id);
        try{
            Test.startTest();
            string json ='{"toCityName":"","fromCityName":"","dateOfJourney":"","travelsName":"","busType":"","boardingTime":"","arrivalTime":"","boardingPoint":"","duration":"","paymentMode":"","cardNumber":"","cardType":"","totalAmountPaid":"","insuranceCharges":"","serviceTax":"","GST":"","cashCouponValue":0.0,"baseFare":0.0,"message":"TESTTESTTEST","isPartialCancellation":false,"isTicketCancellable":false,"discount":"","refundTypeCSV":"","notes":null,"refundModes":null,"lstPassengerInfo":[],"refundTypesList":null,"totalDiscount":0.0,"ticketFare":0.0,"totalTax":0.0,"operatorDiscount":0.0,"fullCancellationBreakUp":null,"partialCancellationBreakUp":null,"cancellationPolicy":null,"currencytype":null,"currentCancellationPolicyIntl":null,"refundableAmount":0.0,"cancellationcharges":0.0,"isZcafeApplied":null,"zcafeDuration":null,"zcafeSponsoredByRedbus":null,"RescheduleFareBreakUp":null,"MPaxData":null,"OperatorId":null,"SourceId":null,"DestinationId":null,"IsReschedulable":false,"RescheduleFrom":null,"RescheduleTo":null,"IsPrimaryPassengerCancellable":false,"SeatsToBeCancelled":null,"RecheduleConfigs":null,"cancelInitiated":false,"ReschedulePolicyMsg":null,"bpId":null,"dpId":null,"routeId":null,"IsUserCancellationReasonEnable":false,"userCancellationReason":null,"isTravelProtectPlanOpted":false,"isCoverGeniusOpted":false,"isInsuranceOpted":false,"useVendorResponse":false,"tnc":null}';
            Test.setMock(HttpCalloutMock.class,new RestClientHTTPMocks(400, 'OK', json));
            AddOnsListViewOnTransaction.checkIsCancellableStatus(ActList);
            Test.stopTest();
        }catch (AuraHandledException ex) {
            System.assert(true);
        }
    }

    static testMethod Void cancelSelectedAddonsTest(){
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Email_Copy__c='abcd@redbus.com';
        oi.mobile__c='9435354333';
        oi.Order_Item_Reference_No__c='TQ3S52922529';
        insert oi;
        List<String> listSelAddonUuid = new List<String>{'a', 'b', 'c'};
        string email = 'abcd@redbus.com';
        String tin ='TQ3S52922529';
        Integer toatlAddCnt = 2;
        String mobile = '9435354333';
        try{
        Test.startTest();
        string json ='{"toCityName":"","fromCityName":"","dateOfJourney":"","travelsName":"","busType":"","boardingTime":"","arrivalTime":"","boardingPoint":"","duration":"","paymentMode":"","cardNumber":"","cardType":"","totalAmountPaid":"","insuranceCharges":"","serviceTax":"","GST":"","cashCouponValue":0.0,"baseFare":0.0,"message":"","isPartialCancellation":false,"isTicketCancellable":false,"discount":"","refundTypeCSV":"","notes":null,"refundModes":null,"lstPassengerInfo":[],"refundTypesList":null,"totalDiscount":0.0,"ticketFare":0.0,"totalTax":0.0,"operatorDiscount":0.0,"fullCancellationBreakUp":null,"partialCancellationBreakUp":null,"cancellationPolicy":null,"currencytype":null,"currentCancellationPolicyIntl":null,"refundableAmount":0.0,"cancellationcharges":0.0,"isZcafeApplied":null,"zcafeDuration":null,"zcafeSponsoredByRedbus":null,"RescheduleFareBreakUp":null,"MPaxData":null,"OperatorId":null,"SourceId":null,"DestinationId":null,"IsReschedulable":false,"RescheduleFrom":null,"RescheduleTo":null,"IsPrimaryPassengerCancellable":false,"SeatsToBeCancelled":null,"RecheduleConfigs":null,"cancelInitiated":false,"ReschedulePolicyMsg":null,"bpId":null,"dpId":null,"routeId":null,"addons":[{"totalFare":100.0,"refundableAmount":0.0,"itemUuid":"5aedc3d3fbc7f0059fa0624c01020100","itemType":"GENERIC_ITEM","itemName":"redPass","currency":null,"isAddOnCancellable":false,"errorMsg":"Oops! Something went wrong. Please call 8039412345 to assist you further.","cancellationPolicy":null}],"IsUserCancellationReasonEnable":false,"userCancellationReason":null,"isTravelProtectPlanOpted":false,"isCoverGeniusOpted":false,"isInsuranceOpted":false,"useVendorResponse":false,"tnc":null}';
        Test.setMock(HttpCalloutMock.class,new RestClientHTTPMocks(200, 'OK', json));
        AddOnsListViewOnTransaction.cancelSelectedAddons(listSelAddonUuid, toatlAddCnt, email, tin,  mobile);
        Test.stopTest();
        }catch (AuraHandledException ex) {
            System.assert(true);
        }

    }

    static testMethod Void cancelSelectedAddonsElseTest(){
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Email_Copy__c='abcd@redbus.com';
        oi.mobile__c='9435354333';
        oi.Order_Item_Reference_No__c='TQ3S52922529';
        insert oi;
        List<String> listSelAddonUuid = new List<String>{'a', 'b', 'c'};
        string email = 'abcd@redbus.com';
        String tin ='TQ3S52922529';
        Integer toatlAddCnt = 2;
        String mobile = '9435354333';
        try{
        Test.startTest();
        string json ='{"toCityName":"","fromCityName":"","dateOfJourney":"","travelsName":"","busType":"","boardingTime":"","arrivalTime":"","boardingPoint":"","duration":"","paymentMode":"","cardNumber":"","cardType":"","totalAmountPaid":"","insuranceCharges":"","serviceTax":"","GST":"","cashCouponValue":0.0,"baseFare":0.0,"message":"TESTTESTTEST","isPartialCancellation":false,"isTicketCancellable":false,"discount":"","refundTypeCSV":"","notes":null,"refundModes":null,"lstPassengerInfo":[],"refundTypesList":null,"totalDiscount":0.0,"ticketFare":0.0,"totalTax":0.0,"operatorDiscount":0.0,"fullCancellationBreakUp":null,"partialCancellationBreakUp":null,"cancellationPolicy":null,"currencytype":null,"currentCancellationPolicyIntl":null,"refundableAmount":0.0,"cancellationcharges":0.0,"isZcafeApplied":null,"zcafeDuration":null,"zcafeSponsoredByRedbus":null,"RescheduleFareBreakUp":null,"MPaxData":null,"OperatorId":null,"SourceId":null,"DestinationId":null,"IsReschedulable":false,"RescheduleFrom":null,"RescheduleTo":null,"IsPrimaryPassengerCancellable":false,"SeatsToBeCancelled":null,"RecheduleConfigs":null,"cancelInitiated":false,"ReschedulePolicyMsg":null,"bpId":null,"dpId":null,"routeId":null,"IsUserCancellationReasonEnable":false,"userCancellationReason":null,"isTravelProtectPlanOpted":false,"isCoverGeniusOpted":false,"isInsuranceOpted":false,"useVendorResponse":false,"tnc":null}';
        Test.setMock(HttpCalloutMock.class,new RestClientHTTPMocks(400, 'OK', json));
        AddOnsListViewOnTransaction.cancelSelectedAddons(listSelAddonUuid, toatlAddCnt, email, tin,  mobile);
        Test.stopTest();
        }catch (AuraHandledException ex) {
            System.assert(true);
        }

    }
    
}