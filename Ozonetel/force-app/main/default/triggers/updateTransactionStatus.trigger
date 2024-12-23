trigger updateTransactionStatus on Order_Items__c (Before Insert,Before Update)
{    
    ID RedTypeId= Schema.getGlobalDescribe().get('Order_Items__c').getDescribe().getRecordTypeInfosByName().get('Bus Booking').getRecordTypeId();
    //ID B2BRecTypeId= Schema.getGlobalDescribe().get('Order_Items__c').getDescribe().getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId();
    
    Map<String,String> mapStatusCats = new Map<String,String>();
    
    //API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
    //APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='update_TransactionStatus'];
    
    //if(APIMData.EnableLog__c)
    set<string> rescIds=new set<string>();
    
    for(Transaction_Status_Category__c tsc : Transaction_Status_Category__c.getAll().Values())
    {
        mapStatusCats.put(tsc.Status__c,tsc.Category__c);
    }
    
    if(Trigger.isBefore && (Trigger.IsInsert || Trigger.isUpdate))
    {
        for(Order_Items__c tn: Trigger.New)
        {
            //if(RedTypeId==tn.RecordTypeId || B2BRecTypeId==tn.RecordTypeId)
            if(RedTypeId==tn.RecordTypeId)
            {
                System.Debug('@@==>>tn: '+tn);
                if(!String.IsBlank(tn.Status__c) && mapStatusCats.ContainsKey(tn.Status__c) && mapStatusCats.get(tn.Status__c) == 'WFT')
                {
                    tn.Transaction_Status__c = 'WFT';
                    tn.Transaction_Status_WFT_GFT__c = 'WFT';
                }
                else if(!String.IsBlank(tn.Status__c) && mapStatusCats.ContainsKey(tn.Status__c) && mapStatusCats.get(tn.Status__c) == 'GFT')
                {
                    tn.Transaction_Status__c = 'GFT - Payment Debited but Ticket not Generated';
                    tn.Transaction_Status_WFT_GFT__c = 'GFT';
                    if(tn.Rescheduling_For__c!=null){
                        rescIds.add(tn.Order_Id__c);
                    }
                }
                else if(!String.IsBlank(tn.Service_Provider_Reference_No__c) && String.IsBlank(tn.Order_Item_Reference_No__c))
                {
                    tn.Transaction_Status__c = 'Misbooking - PNR generated but ticket not confirmed';
                    tn.Transaction_Status_WFT_GFT__c = 'GFT';
                }
                else if(!String.IsBlank(tn.Status__c) && mapStatusCats.ContainsKey(tn.Status__c) && mapStatusCats.get(tn.Status__c) == 'Confirmed')
                {
                    tn.Transaction_Status__c = 'Booked';
                    tn.Transaction_Status_WFT_GFT__c = '';
                }
                else if(!String.IsBlank(tn.Status__c) && mapStatusCats.ContainsKey(tn.Status__c) && mapStatusCats.get(tn.Status__c) == 'Cancelled')
                {
                    tn.Transaction_Status__c = 'Ticket Cancelled'+' - '+tn.Refund_Status__c;
                    tn.Transaction_Status_WFT_GFT__c = '';
                }
            } 
            System.debug('Trans status..'+tn.Transaction_Status__c );
            System.debug('updateTransactionStatus insert..'+tn.status__c);
        }
        
        if(!rescIds.isEmpty()) {
            List<Payment_Items__c> pitems=new List<Payment_Items__c>();
            pItems=[select id,name,Payment_Status__c,Order_Id__c,Creation_Time__c from Payment_Items__c where Payment_Status__c='COMPLETED' and Payment_System__c!='OP_SL_OFFER' and Order_Id__c in:rescIds order by Creation_Time__c asc];
            Map<string,Payment_Items__c> piMap=new Map<string,Payment_Items__c>();
            for(Payment_Items__c p:pItems){
                piMap.put(p.Order_ID__c,p);
            }
            
            for(Order_Items__c tn: Trigger.New)
            {
                System.debug('status-->'+tn.Status__c);
                if(tn.Status__c== 'TR_TENTATIVE_SUCCESSFUL_PO_COMPLETED' &&  piMap!=null && piMap.get(tn.Order_Id__c).Creation_Time__c>=tn.Creation_Time__c){
                    tn.Transaction_Status__c = 'GFT - Payment Debited but Ticket not Generated';
                    tn.Transaction_Status_WFT_GFT__c = 'GFT';
                }else if(string.isBlank(tn.Order_Item_Reference_No__c)){
                    tn.Transaction_Status__c = 'WFT';
                    tn.Transaction_Status_WFT_GFT__c = 'WFT';
                }
            }
        }
    }    
}