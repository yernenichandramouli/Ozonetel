trigger RefundOrderItemsTrigger on Refund_Order_Items__c (after update) {
    if(trigger.isAfter && trigger.isUpdate   ){
        system.debug('enter trigger');
        system.debug(trigger.new);
        RefundOrderItemsTriggerHandler.CaseDataUpdate(trigger.new);
    }
}