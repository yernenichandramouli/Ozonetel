@isTest
public class ActivityOtherItemsExtension_Test
{
    static testMethod void activityPaymentdtls() 
    {
    Activities__c a=new Activities__c();
    a.name='Test';
    a.Payment_Details__c='{"uuid":"ef7f61cc8340f005a3a7d0da01010100","id":"12413518422412897","amountPaid":{"currencyType":"INR","amount":1750.0},"amountReceivable":{"currencyType":"INR","amount":0.0},"paymentItemList":[{"uuid":"f193be5c8340f005a3a7d0da01030100","id":"12413518701523681","refunds":null,"orderId":"12413518422412897","businessUnitValue":{"currencyType":"INR","amount":1750.0},"paymentItemValue":{"currencyType":"INR","amount":1750.0},"paymentStatus":"COMPLETED","paymentSessionId":"12413518422412897","paymentSystem":"ONLINE","paymentSystemRefNo":"f193be5c8340f005a3a7d0da01030100","updatedBy":null,"creationTime":"2019-03-04T08:57:17","bankName":"SBICARD","cardNo":"1234567890123456","pgType":"CreditCard","pgName":"TESTPAY","_meta":null,"bank_ref_num":null,"bankAccountNumber":null,"accountHolderName":null}],"orderId":"12413518422412897","orderValue":{"currencyType":"INR","amount":1750.0},"businessUnit":"REDBUS_IN","creationTime":"2019-03-04T08:56:42"}';
    a.Customer_Price_Breakup__c='[{"name":"NA","isPartiallyCancellable":true,"customerPriceBreakUp":[{"value":1500.0,"type":null,"refundableValue":1500.0,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"},{"value":100.0,"type":null,"refundableValue":100.0,"isCancellationPolicyApplicable":true,"componentName":"COMMISSION"},{"value":50.0,"type":null,"refundableValue":50.0,"isCancellationPolicyApplicable":true,"componentName":"COMMISSION_SGST"},{"value":50.0,"type":null,"refundableValue":50.0,"isCancellationPolicyApplicable":true,"componentName":"COMMISSION_CGST"},{"value":50.0,"type":null,"refundableValue":50.0,"isCancellationPolicyApplicable":true,"componentName":"COMMISSION_IGST"}],"custInfo":{"name":"Shankarnath Reddy","mobileNo":"9019411236","email":"Shankarnath.Reddy@redbus.in"}}]';
    insert a;
    List<activities__c> aLs=new List<activities__c>();
    aLs=[select id from Activities__c where id=:a.id];
    Apexpages.currentpage().getparameters().put('id',aLs[0].id);
    ActivityOtherItemsExtension acObj = new ActivityOtherItemsExtension(new ApexPages.StandardController(a));
    acObj.getDetails();
    
    ActivityOtherItemsExtension.PriceBreakupWrapper prcbrkp= new  ActivityOtherItemsExtension.PriceBreakupWrapper();
    prcbrkp.type='test';
    prcbrkp.value='123';
    prcbrkp.refundableValue='Test1';
    prcbrkp.componentName='Test';
    prcbrkp.isCancellationPolicyApplicable='test';
    
    list<ActivityOtherItemsExtension.paymentItemList> lstPay= new list<ActivityOtherItemsExtension.paymentItemList>();
    ActivityOtherItemsExtension.PaymentItemsWrapper ActvtyItems = new ActivityOtherItemsExtension.PaymentItemsWrapper();
    ActivityOtherItemsExtension.amountReceivable_wrapper amuntRecve = new ActivityOtherItemsExtension.amountReceivable_wrapper();
    ActivityOtherItemsExtension.amountPaid_wrapper  amuntpd = new ActivityOtherItemsExtension.amountPaid_wrapper();
    ActvtyItems.amountPaid=amuntpd;
    ActvtyItems.uuid='12345678';
    ActvtyItems.paymentItemList=lstPay;
    ActvtyItems.amountReceivable=amuntRecve;
    
    amuntpd.currencyType='Ruppe';
    amuntpd.amount='100rs';   
    amuntRecve.currencyType='Rupee';
    amuntRecve.amount='100rs'; 
 
    ActivityOtherItemsExtension.paymentItemList  paymlst = new ActivityOtherItemsExtension.paymentItemList();
    ActivityOtherItemsExtension.paymentItemValueWrapper  pymntvalwrpr = new ActivityOtherItemsExtension.paymentItemValueWrapper();
   list<ActivityOtherItemsExtension.refundsClass>  listpymntvalwrpr = new list<ActivityOtherItemsExtension.refundsClass>();

    paymlst.uuId='12344';
    paymlst.id='123444567892';
    paymlst.paymentSystem='Manual';
    paymlst.paymentStatus='open';
    paymlst.paymentSystemRefNo='12344';
    paymlst.paymentSessionId='456798';
    paymlst.creationTime='today';
    paymlst.cardNo='1234412345678';
    paymlst.bankName='Test';
    paymlst.pgType='Card';
    paymlst.pgName='12344';
    paymlst.bank_ref_num='12344';
    paymlst.bankAccountNumber='12344';
    paymlst.accountHolderName='56789';
    paymlst.paymentItemValue=pymntvalwrpr;
    paymlst.refunds=listpymntvalwrpr;
    
    ActivityOtherItemsExtension.paymentItemValueWrapper  paymntvalue = new ActivityOtherItemsExtension.paymentItemValueWrapper();
    paymntvalue.currencyType='';
    paymntvalue.amount='100rs';
    
    ActivityOtherItemsExtension.refundsClass  refundcls = new ActivityOtherItemsExtension.refundsClass();
    ActivityOtherItemsExtension.refundAmount_wrapper refndwrppr = new ActivityOtherItemsExtension.refundAmount_wrapper();
    refundcls.refundType='Buscancel';
    refundcls.refundTime='Today';
    refundcls.refundStatus='open';
    refundcls.refundTime='Today';
    refundcls.refNo='12345678';
    refundcls.order_item_uuid='1223344';
    refundcls.orderItemId='678910';
    refundcls.channel='web';
    refundcls.refundAmount=refndwrppr;
    
    ActivityOtherItemsExtension.refundAmount_wrapper  refndwrpr = new ActivityOtherItemsExtension.refundAmount_wrapper();
    refndwrpr.currencyType='Ruppe';
    refndwrpr.amount='100rs';   
    }
    
}