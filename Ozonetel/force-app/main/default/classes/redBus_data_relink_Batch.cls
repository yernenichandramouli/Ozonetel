global class redBus_data_relink_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts
{ 
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Map<String,DataReLinkInterval__c> mapintvl = DataReLinkInterval__c.getAll();
        integer interval = integer.valueof(mapintvl.get('Interval').Start_Time__c);
        integer EndInterval = integer.valueof(mapintvl.get('Interval').End_Time__c);
        list<string> PGPaymentIds = new list<string>();
       /* for(PG_Payment_Items__c PG: [select id, ID__c from PG_Payment_Items__c where Creation_Time__c>=:interval and Creation_Time__c<=:EndInterval and Linked__c=:false limit 1000])
        {
            PGPaymentIds.add(PG.ID__c);
        }
        if(!PGPaymentIds.isEmpty())
        {
            return  Database.getQueryLocator([select id, id__c, Payment_Session_Name__c,Customer_Name__c,Primary_Contact_Customer__c,Order_Item_Name__c, Payment_Session_ID__c,Settlement_Time__c, Creation_Time__c,Updated_Time__c, Order_ID__c, Order_Name__c,Linked__c,Re_Linktime__c from Payment_Items__c where (Linked__c=:false and Re_Linktime__c>=:interval and Re_Linktime__c<=:EndInterval and Order_Name__c!='') OR ID__c IN: PGPaymentIds ]);
        }
        else */
        {
        //integer interval = integer.valueof(system.Label.Data_Re_link_time_interval);
            return  Database.getQueryLocator([select id, id__c, Payment_Session_Name__c,Customer_Name__c,Primary_Contact_Customer__c,Order_Item_Name__c, Payment_Session_ID__c,Settlement_Time__c, Creation_Time__c,Updated_Time__c, Order_ID__c, Order_Name__c,Linked__c,Re_Linktime__c from Payment_Items__c where Linked__c=:false and Re_Linktime__c>=:interval and Re_Linktime__c<=:EndInterval and Order_Name__c!='']);
        }
    }
    global void execute(Database.BatchableContext BC, list<Payment_Items__c> PayItemData)
    {
        set<string> orderIds = new set<string>();
        map<string,Order_Items__c> mapOrderOrderItems = new map<string,Order_Items__c>();
        set<string> paymentIds = new set<string>();
        Map<String,DataReLinkInterval__c> mapintvl = DataReLinkInterval__c.getAll();
        integer interval = integer.valueof(mapintvl.get('Interval').Start_Time__c);
        integer EndInterval = integer.valueof(mapintvl.get('Interval').End_Time__c);
        for(PG_Payment_Items__c PG: [select id, ID__c from PG_Payment_Items__c where Creation_Time__c>=:interval and Creation_Time__c<=:EndInterval and Linked__c=:false limit 1000])
        {
            paymentIds.add(PG.ID__c);
        }
        system.debug('-----------paymentIds----------'+paymentIds.size());
        for(Payment_Items__c PI: PayItemData)
        {
            if(!string.isBlank(PI.Order_ID__c))
            {
                orderIds.add(PI.Order_ID__c);
                paymentIds.add(PI.id__c);
            }
        }
        system.debug('-----------paymentIds----------'+paymentIds.size());
        for(Order_Items__c orItem: [select id, id__c,Seat_No__c, mobile__c,Service_Provider_Id__c,Service_Provider_Name__c,Refund_Status__c, Boarding_Point__c, Boarding_Time__c, Bus_Type__c, Destination__c, Dropping_Point__c, Source__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c,Order_Id__c, Business_Unit__c from Order_Items__c where Order_Id__c IN: orderIds])
        {
             mapOrderOrderItems.put(orItem.Order_Id__c,orItem);   
        }
        if(!mapOrderOrderItems.isEmpty())
        {
            Map<string,Payment_Items__c> MapPIEx = new Map<string,Payment_Items__c>();
            for(Payment_Items__c PS: [select id, id__c, Payment_Session_Name__c,Customer_Name__c,Primary_Contact_Customer__c,Order_Item_Name__c, Payment_Session_ID__c,Settlement_Time__c, Creation_Time__c,Updated_Time__c, Order_ID__c, Order_Name__c from Payment_Items__c where Id__c IN: paymentIds ])
            {
                if(mapOrderOrderItems.KeySet().contains(PS.Order_ID__c))
                {
                    if(string.isBlank(string.valueof(PS.Customer_Name__c)) && !string.isBlank(string.valueof(mapOrderOrderItems.get(PS.Order_ID__c).Customer_Name__c)))
                    {
                        PS.Customer_Name__c = mapOrderOrderItems.get(PS.Order_ID__c).Customer_Name__c;
                    }
                    if(string.isBlank(string.valueof(PS.Primary_Contact_Customer__c)) && !string.isBlank(string.valueof(mapOrderOrderItems.get(PS.Order_ID__c).Primary_Contact_Customer__c)))
                    {
                        PS.Primary_Contact_Customer__c = mapOrderOrderItems.get(PS.Order_ID__c).Primary_Contact_Customer__c;
                    }
                    if(string.isBlank(string.valueof(PS.Order_Item_Name__c)) )
                    {
                        PS.Order_Item_Name__c = mapOrderOrderItems.get(PS.Order_ID__c).id;
                    }
                }
                MapPIEx.put(PS.id__c,PS);
             }
             Map<string,PG_Payment_Items__c> MapPGEx = new Map<string,PG_Payment_Items__c>();
            for(PG_Payment_Items__c PS: [select id, id__c,Order_Name__c,Order_Item_Name__c, Payment_Items__c,PG_Name__c, PG_Reference_No__c,Customer_Name__c,Primary_Contact_Customer__c from PG_Payment_Items__c where id__c IN: paymentIds])
            {
                if(!string.isBlank(string.valueof(PS.id__c)))
                {
                    if(MapPIEx.KeySet().Contains(PS.id__c))
                    {
                        if(string.isBlank(string.valueof(PS.Customer_Name__c)) && !string.isBlank(string.valueof(MapPIEx.get(PS.ID__c).Customer_Name__c)))
                        {
                            PS.Customer_Name__c = MapPIEx.get(PS.ID__c).Customer_Name__c;
                        }
                        if(string.isBlank(string.valueof(PS.Primary_Contact_Customer__c)) && !string.isBlank(string.valueof(MapPIEx.get(PS.ID__c).Primary_Contact_Customer__c)))
                        {
                            PS.Primary_Contact_Customer__c = MapPIEx.get(PS.ID__c).Primary_Contact_Customer__c;
                        }
                        if(string.isBlank(string.valueof(PS.Order_Name__c)) && !string.isBlank(string.valueof(MapPIEx.get(PS.ID__c).Order_Name__c)))
                        {
                            PS.Order_Name__c = MapPIEx.get(PS.ID__c).Order_Name__c;
                        }
                        if(string.isBlank(string.valueof(PS.Order_Item_Name__c)) && !string.isBlank(string.valueof(MapPIEx.get(PS.ID__c).Order_Item_Name__c)))
                        {
                            PS.Order_Item_Name__c = MapPIEx.get(PS.ID__c).Order_Item_Name__c;
                        }
                        if(!string.isBlank(string.valueof(PS.PG_Name__c)))
                        {
                            MapPIEx.get(PS.ID__c).Payment_Gateway_Type__c = PS.PG_Name__c;
                        }
                        if(!string.isBlank(string.valueof(PS.ID__c)))
                        {
                            MapPIEx.get(PS.ID__c).PG_Reference_ID__c = PS.PG_Reference_No__c;
                        }
                    }
                }
                MapPGEx.put(PS.id__c,PS);
            }
            if(!MapPGEx.isEmpty())
            {
                database.update(MapPGEx.values(),false);
            }
            if(!MapPIEx.isEmpty())
            {
                database.update(MapPIEx.values(),false);
            }
        }
    }
    global void finish(Database.BatchableContext BC)
    {
       // redBus_data_relink_Batch  batchJob = new redBus_data_relink_Batch();
       // Database.executeBatch(batchJob);
       CaseCreationonTraStatus_Batch cls = new CaseCreationonTraStatus_Batch();
       DataBase.executeBatch(cls,50);
    }
}