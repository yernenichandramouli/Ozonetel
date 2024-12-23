global without sharing class API_redBus_Booking_Future
{
    @future(callout=true)
    public static void ProcessBookingINfo(  set<string> customerIds, 
                                            set<string> custPhoneNumbers, 
                                            list<string> custList,
                                            set<string> primaryEmails,
                                            set<string> primaryPhoneNumbers, 
                                            set<string> orItemprimaryEmails, 
                                            list<string> orItemcustList, 
                                            set<string> allOrdersids,
                                            set<string> allOrderItemids, 
                                            list<string> OrderItemFareComponentids, 
                                            list<string> PaymentSessionIds, 
                                            list<string> PaymentItemsIds, 
                                            list<string> PGPaymentItemsids, 
                                            list<string> BusOrderItemDetailsids, 
                                            list<string> TravellerInfoIds, 
                                            list<string> PaymentItemSessionIds, 
                                            list<string> pgReferencePayItems, 
                                            list<string> cancelOrderItemIds,
                                            list<string> refundIds,
                                            set<string> filterOrderIds,
                                            string DBLoagID,
                                            list<string> orderItemFailedPro,
                                            list<string> PaymentItemsFailedPro,
                                            list<string> OrderFailedPro,
                                            list<string> OrderItemFareComponentFailedPro,
                                            list<string> PaymentSessionFailedPro,
                                            list<string> PGPaymentItemsFailedPro,
                                            list<string> BusOrderItemDetailsFailedPro,
                                            list<string> TravellerInfoFailedPro,
                                            list<string> cancelOrderItemFailedPro,
                                            list<string> refundFailedPro)
    {
      DBLog_Summary__c dbl = new DBLog_Summary__c();
      datetime starttime = system.now();
      try
      {  
        //system.debug('---------------OrderFailedPro-------------------'+OrderFailedPro.size());
          //      system.debug('---------------OrderFailedPro-------------------'+OrderFailedPro);
        If(!orderItemFailedPro.isEmpty() || !PaymentItemsFailedPro.isEmpty() || !OrderFailedPro.isEmpty() || !OrderItemFareComponentFailedPro.isEmpty() || !PaymentSessionFailedPro.isEmpty() || !PGPaymentItemsFailedPro.isEmpty() || !BusOrderItemDetailsFailedPro.isEmpty() || !TravellerInfoFailedPro.isEmpty() || !cancelOrderItemFailedPro.isEmpty() || !refundFailedPro.isEmpty())
        {
            Set<String> ordItemIds = new Set<String>();
            DBLog_Summary__c dbs = [SELECT Id,SentAt__c,Order_Items_Failed__c,Payment_Items_Failed__c FROM DBLog_Summary__c WHERE Id=: DBLoagID LIMIT 1];
            Map<String,DB_Log__c> mapDBLogs = new Map<String,DB_Log__c>();
            for(DB_Log__c db : [SELECT Id,DBLog_Summary__c,Failure_Process__c,Lock_released__c,Lock_Released_Time__c,Lock_type__c,Object_Name__c,ID__c,Locked_record__c,Error_Description__c FROM DB_Log__c WHERE DBLog_Summary__c =: dbs.Id AND Locked_record__c = True])
            {
                mapDBLogs.put(db.ID__c,db);
            }
            
            if(!orderItemFailedPro.isEmpty())
            {
                Map<String,Order_Items__c> mapOrdItems_Failed = new Map<String,Order_Items__c>();
                for(string ac: orderItemFailedPro)
                {
                    Order_Items__c od = new Order_Items__c();
                    od = (Order_Items__c)JSON.deserialize(ac,Order_Items__c.class);
                    ordItemIds.add(string.valueof(od.ID__c));
                    mapOrdItems_Failed.put(od.ID__c,od);
                }   
                List<Order_Items__c> updateFailedOdItems = new List<Order_Items__c>();
                for(Order_Items__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM Order_Items__c WHERE ID__c IN: ordItemIds])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                            }
                            else
                            if(mapOrdItems_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Order_Items__c oit = mapOrdItems_Failed.get(oi.ID__c);
                                updateFailedOdItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapOrdItems_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Order_Items__c oit = mapOrdItems_Failed.get(oi.ID__c);
                                updateFailedOdItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedOdItems.IsEmpty())
                {
                   // DataBase.Upsert(updateFailedOdItems,Order_Items__c.ID__c,false);
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedOdItems,Order_Items__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedOdItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedOdItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedOdItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
            If(!PaymentItemsFailedPro.isEmpty())
            {
                Set<String> Ids_Failed = new Set<String>();
                Map<String,Payment_Items__c> mapItm_Failed = new Map<String,Payment_Items__c>();
                for(string ac: PaymentItemsFailedPro)
                {
                    Payment_Items__c od = new Payment_Items__c();
                    od = (Payment_Items__c)JSON.deserialize(ac,Payment_Items__c.class);
                    Ids_Failed.add(string.valueof(od.ID__c));
                    mapItm_Failed.put(od.ID__c,od);
                }   
                
               /* if(!String.IsBlank(dbs.Payment_Items_Failed__c))
                {
                    for(String s : dbs.Payment_Items_Failed__c.Split(', '))
                    {
                        Ids_Failed.add(s);
                    }
                } */
                List<Payment_Items__c> updateFailedItems = new List<Payment_Items__c>();
                for(Payment_Items__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM Payment_Items__c WHERE ID__c IN: Ids_Failed])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;    
                            }
                            else
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Payment_Items__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Payment_Items__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedItems.IsEmpty())
                {
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedItems,Payment_Items__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
            If(!OrderFailedPro.isEmpty())
            {
                system.debug('---------------OrderFailedPro-------------------'+OrderFailedPro.size());
                system.debug('---------------OrderFailedPro-------------------'+OrderFailedPro);
                Set<String> Ids_Failed = new Set<String>();
                Map<String,Orders__c> mapItm_Failed = new Map<String,Orders__c>();
                for(string ac: OrderFailedPro)
                {
                    system.debug('---------------ac-------------------'+ac);
                    Orders__c od = new Orders__c();
                    od = (Orders__c)JSON.deserialize(ac,Orders__c.class);
                    Ids_Failed.add(string.valueof(od.ID__c));
                    mapItm_Failed.put(od.ID__c,od);
                }   
                
               /* if(!String.IsBlank(dbs.Payment_Items_Failed__c))
                {
                    for(String s : dbs.Payment_Items_Failed__c.Split(', '))
                    {
                        Ids_Failed.add(s);
                    }
                } */
                List<Orders__c> updateFailedItems = new List<Orders__c>();
                for(Orders__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM Orders__c WHERE ID__c IN: Ids_Failed])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;    
                            }
                            else
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Orders__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Orders__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedItems.IsEmpty())
                {
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedItems,Orders__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
            
            If(!OrderItemFareComponentFailedPro.isEmpty())
            {
                Set<String> Ids_Failed = new Set<String>();
                Map<String,Order_Item_Fare_Component__c> mapItm_Failed = new Map<String,Order_Item_Fare_Component__c>();
                for(string ac: OrderItemFareComponentFailedPro)
                {
                    Order_Item_Fare_Component__c od = new Order_Item_Fare_Component__c();
                    od = (Order_Item_Fare_Component__c)JSON.deserialize(ac,Order_Item_Fare_Component__c.class);
                    Ids_Failed.add(string.valueof(od.ID__c));
                    mapItm_Failed.put(od.ID__c,od);
                }   
                
               /* if(!String.IsBlank(dbs.Payment_Items_Failed__c))
                {
                    for(String s : dbs.Payment_Items_Failed__c.Split(', '))
                    {
                        Ids_Failed.add(s);
                    }
                } */
                List<Order_Item_Fare_Component__c> updateFailedItems = new List<Order_Item_Fare_Component__c>();
                for(Order_Item_Fare_Component__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM Order_Item_Fare_Component__c WHERE ID__c IN: Ids_Failed])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;    
                            }
                            else
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Order_Item_Fare_Component__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Order_Item_Fare_Component__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedItems.IsEmpty())
                {
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedItems,Order_Item_Fare_Component__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
//-----------------------   
If(!PaymentSessionFailedPro.isEmpty())
            {
                Set<String> Ids_Failed = new Set<String>();
                Map<String,Payment_Session__c> mapItm_Failed = new Map<String,Payment_Session__c>();
                for(string ac: PaymentSessionFailedPro)
                {
                    Payment_Session__c od = new Payment_Session__c();
                    od = (Payment_Session__c)JSON.deserialize(ac,Payment_Session__c.class);
                    Ids_Failed.add(string.valueof(od.ID__c));
                    mapItm_Failed.put(od.ID__c,od);
                }   
                
               /* if(!String.IsBlank(dbs.Payment_Items_Failed__c))
                {
                    for(String s : dbs.Payment_Items_Failed__c.Split(', '))
                    {
                        Ids_Failed.add(s);
                    }
                } */
                List<Payment_Session__c> updateFailedItems = new List<Payment_Session__c>();
                for(Payment_Session__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM Payment_Session__c WHERE ID__c IN: Ids_Failed])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;    
                            }
                            else
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Payment_Session__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Payment_Session__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedItems.IsEmpty())
                {
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedItems,Payment_Session__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
//---------------------------------------
            If(!PGPaymentItemsFailedPro.isEmpty())
            {
                Set<String> Ids_Failed = new Set<String>();
                Map<String,PG_Payment_Items__c> mapItm_Failed = new Map<String,PG_Payment_Items__c>();
                for(string ac: PGPaymentItemsFailedPro)
                {
                    PG_Payment_Items__c od = new PG_Payment_Items__c();
                    od = (PG_Payment_Items__c)JSON.deserialize(ac,PG_Payment_Items__c.class);
                    Ids_Failed.add(string.valueof(od.ID__c));
                    mapItm_Failed.put(od.ID__c,od);
                }   
                
               /* if(!String.IsBlank(dbs.Payment_Items_Failed__c))
                {
                    for(String s : dbs.Payment_Items_Failed__c.Split(', '))
                    {
                        Ids_Failed.add(s);
                    }
                } */
                List<PG_Payment_Items__c> updateFailedItems = new List<PG_Payment_Items__c>();
                for(PG_Payment_Items__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM PG_Payment_Items__c WHERE ID__c IN: Ids_Failed])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;    
                            }
                            else
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                PG_Payment_Items__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                PG_Payment_Items__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedItems.IsEmpty())
                {
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedItems,PG_Payment_Items__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
//------------------------------------------
            If(!BusOrderItemDetailsFailedPro.isEmpty())
            {
                Set<String> Ids_Failed = new Set<String>();
                Map<String,Bus_Order_Item_Details__c> mapItm_Failed = new Map<String,Bus_Order_Item_Details__c>();
                for(string ac: BusOrderItemDetailsFailedPro)
                {
                    Bus_Order_Item_Details__c od = new Bus_Order_Item_Details__c();
                    od = (Bus_Order_Item_Details__c)JSON.deserialize(ac,Bus_Order_Item_Details__c.class);
                    Ids_Failed.add(string.valueof(od.ID__c));
                    mapItm_Failed.put(od.ID__c,od);
                }   
                
               /* if(!String.IsBlank(dbs.Payment_Items_Failed__c))
                {
                    for(String s : dbs.Payment_Items_Failed__c.Split(', '))
                    {
                        Ids_Failed.add(s);
                    }
                } */
                List<Bus_Order_Item_Details__c> updateFailedItems = new List<Bus_Order_Item_Details__c>();
                for(Bus_Order_Item_Details__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM Bus_Order_Item_Details__c WHERE ID__c IN: Ids_Failed])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;    
                            }
                            else
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Bus_Order_Item_Details__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Bus_Order_Item_Details__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedItems.IsEmpty())
                {
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedItems,Bus_Order_Item_Details__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
//------------------------------------------
            If(!BusOrderItemDetailsFailedPro.isEmpty())
            {
                Set<String> Ids_Failed = new Set<String>();
                Map<String,Bus_Order_Item_Details__c> mapItm_Failed = new Map<String,Bus_Order_Item_Details__c>();
                for(string ac: BusOrderItemDetailsFailedPro)
                {
                    Bus_Order_Item_Details__c od = new Bus_Order_Item_Details__c();
                    od = (Bus_Order_Item_Details__c)JSON.deserialize(ac,Bus_Order_Item_Details__c.class);
                    Ids_Failed.add(string.valueof(od.ID__c));
                    mapItm_Failed.put(od.ID__c,od);
                }   
                
               /* if(!String.IsBlank(dbs.Payment_Items_Failed__c))
                {
                    for(String s : dbs.Payment_Items_Failed__c.Split(', '))
                    {
                        Ids_Failed.add(s);
                    }
                } */
                List<Bus_Order_Item_Details__c> updateFailedItems = new List<Bus_Order_Item_Details__c>();
                for(Bus_Order_Item_Details__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM Bus_Order_Item_Details__c WHERE ID__c IN: Ids_Failed])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;    
                            }
                            else
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Bus_Order_Item_Details__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Bus_Order_Item_Details__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedItems.IsEmpty())
                {
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedItems,Bus_Order_Item_Details__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
//-----------------------------
If(!TravellerInfoFailedPro.isEmpty())
            {
                Set<String> Ids_Failed = new Set<String>();
                Map<String,Traveller_Info__c> mapItm_Failed = new Map<String,Traveller_Info__c>();
                for(string ac: TravellerInfoFailedPro)
                {
                    Traveller_Info__c od = new Traveller_Info__c();
                    od = (Traveller_Info__c)JSON.deserialize(ac,Traveller_Info__c.class);
                    Ids_Failed.add(string.valueof(od.ID__c));
                    mapItm_Failed.put(od.ID__c,od);
                }   
                
               /* if(!String.IsBlank(dbs.Payment_Items_Failed__c))
                {
                    for(String s : dbs.Payment_Items_Failed__c.Split(', '))
                    {
                        Ids_Failed.add(s);
                    }
                } */
                List<Traveller_Info__c> updateFailedItems = new List<Traveller_Info__c>();
                for(Traveller_Info__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM Traveller_Info__c WHERE ID__c IN: Ids_Failed])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;    
                            }
                            else
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Traveller_Info__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Traveller_Info__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedItems.IsEmpty())
                {
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedItems,Traveller_Info__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
//------------------------------
If(!cancelOrderItemFailedPro.isEmpty())
            {
                Set<String> Ids_Failed = new Set<String>();
                Map<String,Cancelled_Order_Items__c> mapItm_Failed = new Map<String,Cancelled_Order_Items__c>();
                for(string ac: cancelOrderItemFailedPro)
                {
                    Cancelled_Order_Items__c od = new Cancelled_Order_Items__c();
                    od = (Cancelled_Order_Items__c)JSON.deserialize(ac,Cancelled_Order_Items__c.class);
                    Ids_Failed.add(string.valueof(od.ID__c));
                    mapItm_Failed.put(od.ID__c,od);
                }   
                
               /* if(!String.IsBlank(dbs.Payment_Items_Failed__c))
                {
                    for(String s : dbs.Payment_Items_Failed__c.Split(', '))
                    {
                        Ids_Failed.add(s);
                    }
                } */
                List<Cancelled_Order_Items__c> updateFailedItems = new List<Cancelled_Order_Items__c>();
                for(Cancelled_Order_Items__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM Cancelled_Order_Items__c WHERE ID__c IN: Ids_Failed])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;    
                            }
                            else
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Cancelled_Order_Items__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Cancelled_Order_Items__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedItems.IsEmpty())
                {
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedItems,Cancelled_Order_Items__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
//---------------------------------
If(!refundFailedPro.isEmpty())
            {
                Set<String> Ids_Failed = new Set<String>();
                Map<String,Refund_Order_Items__c> mapItm_Failed = new Map<String,Refund_Order_Items__c>();
                for(string ac: refundFailedPro)
                {
                    Refund_Order_Items__c od = new Refund_Order_Items__c();
                    od = (Refund_Order_Items__c)JSON.deserialize(ac,Refund_Order_Items__c.class);
                    Ids_Failed.add(string.valueof(od.ID__c));
                    mapItm_Failed.put(od.ID__c,od);
                }   
                
               /* if(!String.IsBlank(dbs.Payment_Items_Failed__c))
                {
                    for(String s : dbs.Payment_Items_Failed__c.Split(', '))
                    {
                        Ids_Failed.add(s);
                    }
                } */
                List<Refund_Order_Items__c> updateFailedItems = new List<Refund_Order_Items__c>();
                for(Refund_Order_Items__c oi : [SELECT Id,ID__c,LastModifiedDate,lastmodifiedbyid FROM Refund_Order_Items__c WHERE ID__c IN: Ids_Failed])
                {
                    if(mapDBLogs.ContainsKey(oi.ID__c))
                    {
                        mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done';
                        if((oi.LastModifiedDate.getTime()-dbs.SentAt__c.getTime())>=0)
                        {
                            if(oi.lastmodifiedbyid==userinfo.getUserId())
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;    
                            }
                            else
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Integration User';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Refund_Order_Items__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                            
                        }
                        else
                        {
                            mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 1';
                            if(mapItm_Failed.ContainsKey(oi.ID__c))
                            {
                                mapDBLogs.get(oi.ID__c).Failure_Process__c = 'Done - No Date Match 2';
                                mapDBLogs.get(oi.ID__c).Lock_released__c = True;
                                Refund_Order_Items__c oit = mapItm_Failed.get(oi.ID__c);
                                updateFailedItems.add(oit);
                            }
                        }
                    }
                }
                if(!updateFailedItems.IsEmpty())
                {
                    Database.UpsertResult[] upsertResult = DataBase.Upsert(updateFailedItems,Refund_Order_Items__c.ID__c,false);
                    for(Integer i=0;i<upsertResult.size();i++)
                    {
                           if (upsertResult.get(i).isSuccess())
                           {
                               if(mapDBLogs.ContainsKey(updateFailedItems[i].id__c))
                               {
                                 //mapDBLogs.get(updateFailedItems[i].id__c).Lock_released__c = True;
                                 mapDBLogs.get(updateFailedItems[i].id__c).Lock_Released_Time__c = system.now();
                               }
                           }
                    }
                }
            }
//----------------------------------------
            if(!mapDBLogs.Values().IsEmpty())
            {
                DataBase.Update(mapDBLogs.Values());
            }
        }
        map<string,string> OrdersCustomerIdsMap = new map<string,string>();
        map<string,account> OrderItemCustomerMap = new map<string,account>();
        map<string,string> MapBusOrderItemDetailsids = new map<string,string>();
        System.debug('custList...'+custList);
        if(!custList.isEmpty())
        {
            list<account> acc = new list<account>();
            for(string ac: custList)
            {
                account a = new account();
                a = (account)JSON.deserialize(ac,account.class);
                acc.add(a);
            }
            list<contact> contacts = new list<contact>();
            set<string> accountids = new set<string>();
            map<string,account> updateCustomer = new map<string,account>();
            list<account> newCustomer = new list<account>();
            map<string,account> exCustomerDetails = new map<string,account>();
            map<string,account> exCustomerPhoneDetails = new map<string,account>();
            map<string,contact> exContacts = new map<string,contact>();
            list<contact> newContact = new list<contact>();
            System.debug('Fut customerIds..'+customerIds+'..Fut custPhoneNumbers..'+custPhoneNumbers);
            
            if(!customerIds.isEmpty() || !custPhoneNumbers.isEmpty())
            {
                for(account ac:  [select id,PersonMobilePhone, User_Id__c, PersonEmail,Parent_Account__c from account where User_Id__c IN: customerIds OR PersonMobilePhone IN: custPhoneNumbers ])
                {
                    System.debug('Account acc..'+ac);
                    if(!string.isBlank(ac.User_Id__c))
                    {
                        exCustomerDetails.put(ac.User_Id__c,ac);
                    }
                    if(!string.isBlank(ac.PersonMobilePhone))
                    {
                        exCustomerPhoneDetails.put(ac.PersonMobilePhone,ac);
                        accountids.add(ac.id);
                    }
                }
                System.debug('accountids...'+accountids+'..exCustomerDetails..'+exCustomerDetails.keySet()+'...exCustomerPhoneDetails..'+exCustomerPhoneDetails.keySet());
                if(!accountids.isEmpty())
                {
                    contacts = [select id, name, email, Account_name__c from contact where Account_name__c IN: accountids and email IN: primaryEmails ];
                    System.debug('contacts...'+contacts);
                    if(!contacts.isEmpty())
                    {
                        for(contact co: contacts)
                        {
                            exContacts.put(co.Account_name__c,co);
                        }
                        
                    }
                }
            }
            if(!acc.isEmpty())
            {
                for(account ac: acc)
                {
                    if(exCustomerDetails.KeySet().Contains(ac.User_Id__c))
                    {
                        ac.id = exCustomerDetails.get(ac.User_Id__c).id;
                        System.debug('Exi Phone..'+exCustomerDetails.get(ac.User_Id__c).PersonMobilePhone+'..'+ac.PersonMobilePhone);
                        if(exCustomerDetails.get(ac.User_Id__c).PersonMobilePhone!=ac.PersonMobilePhone)
                        {
                            account newAcc = new account();
                            newAcc.lastName = ac.lastname;
                            //newAcc.PersonMobilePhone = exCustomerDetails.get(ac.User_Id__c).PersonMobilePhone;
                newAcc.PersonMobilePhone = ac.PersonMobilePhone;
                newAcc.AccountSource = 'SignedIn Mobile Update';
                            newAcc.Parent_Account__c = ac.id;
                            newCustomer.add(newAcc);
                        }
                        updateCustomer.put(ac.id,ac);
                    }
                    else
                    if(exCustomerPhoneDetails.KeySet().Contains(ac.PersonMobilePhone))
                    {
                        ac.id = exCustomerPhoneDetails.get(ac.PersonMobilePhone).id;
                        if(ac.PersonEmail!=null && exCustomerPhoneDetails.get(ac.PersonMobilePhone).PersonEmail!=null && exCustomerPhoneDetails.get(ac.PersonMobilePhone).PersonEmail!=ac.PersonEmail)
                        {
                            if(exContacts.KeySet().Contains(ac.id) && exContacts.get(ac.id).email==ac.PersonEmail)
                            {
                                exContacts.get(ac.id).lastname = ac.lastname;
                            }
                            else
                            {
                                contact cc = new contact();
                                cc.lastname = ac.lastname;
                               // cc.email = exCustomerPhoneDetails.get(ac.PersonMobilePhone).PersonEmail;
                                cc.email = ac.PersonEmail;
                                cc.Account_name__c = ac.id;
                                newContact.add(cc);
                            }
                        }
                        updateCustomer.put(ac.id,ac);
                    }
                    else
                    {
                        newCustomer.add(ac);
                    }
                }
                if(!updateCustomer.isEmpty())
                {
                    database.update(updateCustomer.values(),false);
                }
                if(!newCustomer.isEmpty())
                {
                    database.insert(newCustomer,false);
                }
                if(!exContacts.isEmpty())
                {
                    database.update(exContacts.Values(),false);
                }
                if(!newContact.isEmpty())
                {
                    database.insert(newContact,false);
                }
            }
            if(!customerIds.isEmpty())
            {
                for(account ac:  [select id,PersonMobilePhone,User_Id__c from account where User_Id__c IN:customerIds ])
                {
                        OrdersCustomerIdsMap.put(ac.User_Id__c,ac.id);
                }
            } 
         }
         if(!orItemcustList.isEmpty())
         {
            list<account> acc = new list<account>();
            for(string ac: orItemcustList)
            {
                account a = new account();
                a = (account)JSON.deserialize(ac,account.class);
                acc.add(a);
            }   
              map<string,account> updateCustomer = new map<string,account>();
              list<account> newCustomer = new list<account>();
              map<string,account> exCustomerDetails = new map<string,account>();
              map<string,string> AddedList = new map<string,string>();
              list<contact> contacts = new list<contact>();
              map<string,contact> exContacts = new map<string,contact>();
              set<string> accountids = new set<string>();
              list<contact> newContact = new list<contact>();
                
                if(!primaryPhoneNumbers.isEmpty() )
                {
                    for(account ac:  [select id,lastname,PersonMobilePhone, User_Id__c, PersonEmail, Primary_Account__c,Parent_Account__c from account where PersonMobilePhone IN: primaryPhoneNumbers ])
                    {
                        if(!string.isBlank(ac.PersonMobilePhone))
                        {
                            exCustomerDetails.put(ac.PersonMobilePhone,ac);
                            accountids.add(ac.id);
                            if(!string.isBlank(string.valueof(ac.Parent_Account__c)))
                            {
                                accountids.add(ac.Parent_Account__c);
                            }
                        }
                    }
                    if(!accountids.isEmpty())
                    {
                        contacts = [select id, name, email, Account_name__c from contact where Account_name__c IN: accountids and email IN: orItemprimaryEmails];
                        if(!contacts.isEmpty())
                        {
                            for(contact co: contacts)
                            {
                                exContacts.put(co.Account_name__c,co);
                            }
                            
                        }
                    }
                }
                if(!acc.isEmpty())
                {
                    for(account ac: acc)
                    {
                        if(exCustomerDetails.KeySet().Contains(ac.PersonMobilePhone))
                        {
                            ac.id = exCustomerDetails.get(ac.PersonMobilePhone).id;
                            if(ac.PersonEmail!=null && exCustomerDetails.get(ac.PersonMobilePhone).PersonEmail!=null && exCustomerDetails.get(ac.PersonMobilePhone).PersonEmail!=ac.PersonEmail)
                            {
                                if(exContacts.KeySet().Contains(ac.id) && exContacts.get(ac.id).email==ac.PersonEmail)
                                {
                                    exContacts.get(ac.id).lastname = ac.lastname;
                                }
                                else
                                {
                                    contact cc = new contact();
                                    cc.lastname = ac.lastname;
                                    cc.email = ac.PersonEmail;
                                    if(!string.isBlank(string.valueof(exCustomerDetails.get(ac.PersonMobilePhone).User_Id__c)))
                                    {
                                        cc.Account_name__c = ac.id;
                                    }
                                    else
                                    if(!string.isBlank(string.valueof(exCustomerDetails.get(ac.PersonMobilePhone).Parent_Account__c)))
                                    {
                                        string ExEmail = string.valueof(exCustomerDetails.get(ac.PersonMobilePhone).Parent_Account__c);
                                        if(exContacts.KeySet().Contains(ExEmail) && exContacts.get(ExEmail).email==ac.PersonEmail)
                                        {
                                            exContacts.get(ExEmail).lastname = ac.lastname;
                                        }
                                        else
                                        {
                                            cc.Account_name__c = exCustomerDetails.get(ac.PersonMobilePhone).Parent_Account__c;
                                        }
                                    }
                                    else
                                    {
                                        cc.Account_name__c = ac.id;
                                    }
                                    newContact.add(cc);
                                }
                            }
                            else
                            if(ac.PersonEmail!=null && exCustomerDetails.get(ac.PersonMobilePhone).PersonEmail==null)
                            {
                                contact cc = new contact();
                                cc.lastname = ac.lastname;
                                cc.email = ac.PersonEmail;
                                if(!string.isBlank(string.valueof(exCustomerDetails.get(ac.PersonMobilePhone).User_Id__c)))
                                {
                                    string ExEmail = string.valueof(exCustomerDetails.get(ac.PersonMobilePhone).Parent_Account__c);
                                    if(exContacts.KeySet().Contains(ExEmail) && exContacts.get(ExEmail).email==ac.PersonEmail)
                                    {
                                        exContacts.get(ExEmail).lastname = ac.lastname;
                                    }
                                    else
                                    {
                                        cc.Account_name__c = ac.id;
                                    }
                                }
                                else
                                if(!string.isBlank(string.valueof(exCustomerDetails.get(ac.PersonMobilePhone).Parent_Account__c)))
                                {
                                    string ExEmail = string.valueof(exCustomerDetails.get(ac.PersonMobilePhone).Parent_Account__c);
                                    if(exContacts.KeySet().Contains(ExEmail) && exContacts.get(ExEmail).email==ac.PersonEmail)
                                    {
                                        exContacts.get(ExEmail).lastname = ac.lastname;
                                    }
                                    else
                                    {
                                        cc.Account_name__c = exCustomerDetails.get(ac.PersonMobilePhone).Parent_Account__c;
                                    }
                                }
                                else
                                {
                                    cc.Account_name__c = ac.id;
                                }
                                newContact.add(cc);
                            }
                            if(string.isBlank(string.valueof(exCustomerDetails.get(ac.PersonMobilePhone).User_Id__c)))
                            {
                                ac.id = exCustomerDetails.get(ac.PersonMobilePhone).id;
                                ac.PersonEmail = exCustomerDetails.get(ac.PersonMobilePhone).PersonEmail;
                                if(ac.lastName==ac.PersonMobilePhone && ac.lastname!= exCustomerDetails.get(ac.PersonMobilePhone).lastname)
                                {
                                    ac.lastname = exCustomerDetails.get(ac.PersonMobilePhone).lastname;
                                }
                                updateCustomer.put(ac.id,ac);
                            }
                        }
                        else
                        {
                            newCustomer.add(ac);
                        }
                    }
                }
                if(!updateCustomer.isEmpty())
                {
                     database.update(updateCustomer.values(),false);
                }
                if(!newCustomer.isEmpty())
                {
                      database.insert(newCustomer,false);
                }
                if(!exContacts.isEmpty())
                {
                    database.update(exContacts.Values(),false);
                }
                if(!newContact.isEmpty())
                {
                    database.insert(newContact,false);
                }
                if(!primaryPhoneNumbers.isEmpty())
                {
                    for(account ac:  [select id,PersonMobilePhone,User_Id__c,Parent_Account__c from account where PersonMobilePhone IN: primaryPhoneNumbers ])
                    {
                        OrderItemCustomerMap.put(ac.PersonMobilePhone,ac);
                    }
                }
        }

        map<string,Service_Provider__c> serviceProvider = new map<string,Service_Provider__c>();
        map<string,Location__c> busLocations = new map<string,Location__c>();
        map<string,Bus_Type__c> busType = new map<string,Bus_Type__c>();
        map<string,Orders__c> mapOrders = new map<string,Orders__c>();
        integer sTime = integer.valueof(System.Label.Order_Item_Faild_records_Start_Time);
        integer eTime = integer.valueof(System.Label.Order_Item_Failed_Records);
        set<string> allOrdersidsLink = new set<string>();
        set<string> allOrderItemidsLink = new set<string>();
 /*       for(Order_Items__c orItem: [select id, id__c,Seat_No__c, mobile__c,Service_Provider_Id__c,Service_Provider_Name__c,Refund_Status__c, Boarding_Point__c, Boarding_Time__c, Bus_Type__c, Destination__c, Dropping_Point__c, Source__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c,Order_Id__c, Business_Unit__c from Order_Items__c where Case_creation_time__c>=:sTime and Case_creation_time__c<=: eTime and Data_Link__c = false  and createdDate= TODAY])
        {
            allOrderItemidsLink.add(orItem.id__c);
            allOrdersidsLink.add(orItem.Order_Id__c);
        } */
        //for(Orders__c ors: [select id, id__c,User_Id__c,Customer_Name__c,Primary_Contact_Customer__c,Business_Unit__c from Orders__c where id__c IN: allOrdersids and createdDate = TODAY ])
        
        for(Orders__c ors: [select id, id__c,User_Id__c,Customer_Name__c,Primary_Contact_Customer__c,Business_Unit__c from Orders__c where id__c IN: filterOrderIds  OR id__c IN: allOrdersidsLink])
        {
            if(string.IsBlank(string.valueof(ors.Customer_Name__c)))
            {
                if(OrdersCustomerIdsMap.KeySet().Contains(ors.User_Id__c))
                {
                    ors.Customer_Name__c = OrdersCustomerIdsMap.get(ors.User_Id__c);
                }
            }
            mapOrders.put(ors.id__c,ors);
        }
        map<string,Order_Items__c> mapOrderItems = new map<string,Order_Items__c>();
        map<string,Order_Items__c> mapOrderOrderItems = new map<string,Order_Items__c>();
      //  for(Order_Items__c orItem: [select id, id__c,Seat_No__c, mobile__c,Service_Provider_Id__c,Service_Provider_Name__c,Refund_Status__c, Boarding_Point__c, Boarding_Time__c, Bus_Type__c, Destination__c, Dropping_Point__c, Source__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c,Order_Id__c, Business_Unit__c from Order_Items__c where (id__c IN: allOrderItemids OR Order_Id__c IN: allOrdersids) AND Order_Linkage__c = False])
        for(Order_Items__c orItem: [select id, id__c,status__c,Route_id__c,Primary_Boarding_Point_Time__c,Seat_No__c, mobile__c,Service_Provider_Id__c,Service_Provider_Name__c,Refund_Status__c, Boarding_Point__c, Boarding_Time__c, Bus_Type__c, Destination__c, Dropping_Point__c, Source__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c,Order_Id__c, Business_Unit__c from Order_Items__c where (id__c IN: allOrderItemids OR id__c IN: allOrderItemidsLink OR Order_Id__c IN: allOrdersids)])
        {
            System.debug('Transaction Status..'+orItem.status__c);
            //if(MaporderItemIds.KeySet().Contains(orItem.id__c) )
            {
                if(!string.isBlank(string.valueof(orItem.mobile__c)))
                {
                    if(OrderItemCustomerMap.KeySet().Contains(orItem.Mobile__c))
                    {
                        system.debug('------------process 1-------------');
                        if(!string.isBlank(string.valueof(OrderItemCustomerMap.get(orItem.Mobile__c).User_Id__c)))
                        {
                            system.debug('------------process 2-------------');
                            if(!string.isBlank(string.valueof(orItem.Order_Id__c)) && mapOrders.KeySet().contains(orItem.Order_Id__c) && !string.isBlank(string.valueof(mapOrders.get(orItem.Order_Id__c).Customer_Name__c)) && mapOrders.get(orItem.Order_Id__c).Customer_Name__c != OrderItemCustomerMap.get(orItem.Mobile__c).id)
                            {
                                system.debug('------------process 3-------------');
                                orItem.Primary_Contact_Customer__c = OrderItemCustomerMap.get(orItem.Mobile__c).id;
                            }
                            else
                            {
                                system.debug('------------process 4-------------');
                                orItem.Customer_Name__c = OrderItemCustomerMap.get(orItem.Mobile__c).id;
                            }
                        }
                        else
                        {
                            system.debug('------------process 5-------------');
                            orItem.Primary_Contact_Customer__c = OrderItemCustomerMap.get(orItem.Mobile__c).id;
                        }
                    }
                }
            }
            if(!string.isBlank(string.valueof(orItem.Order_Id__c)) && mapOrders.KeySet().contains(orItem.Order_Id__c))
            {
                //orItem.Order_Name__c = mapOrders.get(orItem.Order_Id__c).id; 
                if(!string.isBlank(string.valueof(mapOrders.get(orItem.Order_Id__c).Customer_Name__c)))
                {
                    orItem.Customer_Name__c = mapOrders.get(orItem.Order_Id__c).Customer_Name__c;
                    if(orItem.Customer_Name__c!=orItem.Primary_Contact_Customer__c)
                    {
                        mapOrders.get(orItem.Order_Id__c).Primary_Contact_Customer__c = orItem.Primary_Contact_Customer__c;
                    }
                }
                else
                if(!string.isBlank(string.valueof(orItem.Primary_Contact_Customer__c)))
                {
                    mapOrders.get(orItem.Order_Id__c).Primary_Contact_Customer__c = orItem.Primary_Contact_Customer__c;
                }
            }
            if(OrderItemCustomerMap.KeySet().Contains(orItem.Mobile__c))
            {
                if(!string.isBlank(string.valueof(orItem.Customer_Name__c)) && orItem.Customer_Name__c != OrderItemCustomerMap.get(orItem.Mobile__c).id )
                {
                    if(string.isBlank(string.valueof(OrderItemCustomerMap.get(orItem.Mobile__c).Parent_Account__c)))
                    {
                        OrderItemCustomerMap.get(orItem.mobile__c).Parent_Account__c = orItem.Customer_Name__c;
                    }
                }
            }
            mapOrderItems.put(orItem.id__c,orItem);
            mapOrderOrderItems.put(orItem.Order_Id__c,orItem);
       }
       
       if(!OrderItemFareComponentids.isEmpty() || !allOrderItemidsLink.isEmpty())
       {
           Map<string,Order_Item_Fare_Component__c> MapOIFCEx = new Map<string,Order_Item_Fare_Component__c>();
            for(Order_Item_Fare_Component__c OIFC: [select id,id__c,Creation_Time__c,Updated_Time__c, Item_ID__c,Order_ID__c, Order_Item_Name__c, Order_Name__c, createdDate from Order_Item_Fare_Component__c where (Item_ID__c IN: allOrderItemidsLink OR id__c IN: OrderItemFareComponentids) and  Linked__c=:false])
            {
                if(mapOrderItems.KeySet().contains(OIFC.Item_ID__c))
                {
                    if(!string.isBlank(string.valueof(mapOrderItems.get(OIFC.Item_ID__c).Customer_Name__c)))
                    {
                        OIFC.Customer_Name__c = mapOrderItems.get(OIFC.Item_ID__c).Customer_Name__c;
                    }
                    if(!string.isBlank(string.valueof(mapOrderItems.get(OIFC.Item_ID__c).Primary_Contact_Customer__c)))
                    {
                        OIFC.Primary_Contact_Customer__c = mapOrderItems.get(OIFC.Item_ID__c).Primary_Contact_Customer__c;
                    }
                }
                MapOIFCEx.put(OIFC.id__c,OIFC);
            }
            if(!MapOIFCEx.isEmpty())
            {
                database.update(MapOIFCEx.values(),false);
            }
        }

        if(!PaymentItemSessionIds.isEmpty())
        {
            Map<string,Payment_Session__c> MapPSEx = new Map<string,Payment_Session__c>();
            for(Payment_Session__c PS: [select id, id__c, Customer_Name__c,Primary_Contact_Customer__c,Creation_Time__c,Updated_Time__c, Order_ID__c, Order_Name__c, Order_Item_Name__c from Payment_Session__c where (Order_ID__c IN: allOrdersids OR id__c IN: PaymentItemSessionIds)])
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
                    if(string.IsBlank(string.valueof(PS.Order_Item_Name__c)))
                    {
                        PS.Order_Item_Name__c = mapOrderOrderItems.get(PS.Order_ID__c).id;
                    }
                }
                MapPSEx.put(PS.id__c,PS);
            }
            if(!MapPSEx.isEmpty())
            {
                database.update(MapPSEx.values(),false);
            }
        }
        if(!pgReferencePayItems.isEmpty() || !PaymentItemsIds.isEmpty())
        {
            Map<string,Payment_Items__c> MapPIEx = new Map<string,Payment_Items__c>();
            for(Payment_Items__c PS: [select id, id__c, Payment_Session_Name__c,Customer_Name__c,Primary_Contact_Customer__c,Order_Item_Name__c, Payment_Session_ID__c,Settlement_Time__c, Creation_Time__c,Updated_Time__c, Order_ID__c, Order_Name__c from Payment_Items__c where (Id__c IN: pgReferencePayItems OR Id__c IN: PaymentItemsIds)])
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
            for(PG_Payment_Items__c PS: [select id, id__c,Order_Name__c,Order_Item_Name__c, Payment_Items__c,PG_Name__c, PG_Reference_No__c,Customer_Name__c,Primary_Contact_Customer__c from PG_Payment_Items__c where id__c IN: PGPaymentItemsids OR id__c IN: pgReferencePayItems OR id__c IN: PaymentItemsIds])
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
        if(!BusOrderItemDetailsids.isEmpty() || !allOrderItemidsLink.isEmpty())
        {
            Map<string,Bus_Order_Item_Details__c> MapBOIDEx = new Map<string,Bus_Order_Item_Details__c>();
            //For(Bus_Order_Item_Details__c BOID: [select id, id__c,Dropping_Point__c,Source_City__c,Destination_City__c,Bus_Type_Details__c,Source_Location__c,Dropping_Point_Location__c,Boarding_Point_Location__c, Seat_No__c,Boarding_Point_ID__c,dropping_point_id__c,Source_ID__c,Bus_Type__c,Order_Item_Name__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c, Boarding_Time__c, Primary_Boarding_Time__c,Boarding_Point__c from Bus_Order_Item_Details__c where (id__c IN: allOrderItemids OR id__c IN: allOrderItemids) AND Order_Item_Linkage__c = False])
            For(Bus_Order_Item_Details__c BOID: [select id, id__c,Route_ID__c,Dropping_Point__c,Source_City__c,Destination_City__c,Bus_Type_Details__c,Source_Location__c,Dropping_Point_Location__c,Boarding_Point_Location__c, Seat_No__c,Boarding_Point_ID__c,dropping_point_id__c,Source_ID__c,Bus_Type__c,Order_Item_Name__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c, Boarding_Time__c, Primary_Boarding_Time__c,Boarding_Point__c from Bus_Order_Item_Details__c where id__c IN: BusOrderItemDetailsids OR id__c IN: allOrderItemidsLink ])
            {
                System.Debug('###==>> BOID: '+BOID.Seat_No__c);
                if(mapOrderItems.ContainsKey(BOID.id__c))
                {
                    if(!string.isBlank(string.valueof(BOID.Boarding_Point__c)) && string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Boarding_Point__c)))
                    {
                        mapOrderItems.get(BOID.id__c).Boarding_Point__c = BOID.Boarding_Point__c;
                    }
                    if(!string.isBlank(string.valueof(BOID.Bus_Type__c)) && string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Bus_Type__c)))
                    {
                        mapOrderItems.get(BOID.id__c).Bus_Type__c = BOID.Bus_Type__c;
                    }
                    if(!string.isBlank(string.valueof(BOID.Destination_City__c)) && string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Destination__c)))
                    {
                        mapOrderItems.get(BOID.id__c).Destination__c = BOID.Destination_City__c;
                    }
                    if(!string.isBlank(string.valueof(BOID.Source_City__c)) && string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Source__c)))
                    {
                        mapOrderItems.get(BOID.id__c).Source__c = BOID.Source_City__c;
                    }
                    if(!string.isBlank(string.valueof(BOID.Dropping_Point__c)) && string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Dropping_Point__c)))
                    {
                        mapOrderItems.get(BOID.id__c).Dropping_Point__c = BOID.Dropping_Point__c;
                    }
                    if(!string.isBlank(string.valueof(BOID.Boarding_Time__c)) && string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Boarding_Time__c)))
                    {
                        mapOrderItems.get(BOID.id__c).Boarding_Time__c = BOID.Boarding_Time__c;
                    }
                    if(!string.isBlank(string.valueof(BOID.Route_ID__c)) && string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Route_ID__c)))
                    {
                        mapOrderItems.get(BOID.id__c).Route_ID__c = BOID.Route_ID__c;
                    }
                    
                    if(string.isNotBlank(string.valueof(BOID.Primary_Boarding_Time__c)) && string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Primary_Boarding_Point_Time__c)))
                    {
                        mapOrderItems.get(BOID.id__c).Primary_Boarding_Point_Time__c = BOID.Primary_Boarding_Time__c;
                    }
                    
                    
                    System.Debug('@@==>> BOID.Seat_No__c: '+BOID.Seat_No__c);
                    if(!string.isBlank(string.valueof(BOID.Seat_No__c)) && string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Seat_No__c)))
                    {
                        System.Debug('@@==>> mapOrderItems.get(BOID.id__c).Seat_No__c: '+mapOrderItems.get(BOID.id__c).Seat_No__c);
                        mapOrderItems.get(BOID.id__c).Seat_No__c = BOID.Seat_No__c;
                    }
                }
                if(!string.isBlank(string.valueof(BOID.id__c)))
                {
                    if(mapOrderItems.KeySet().contains(BOID.id__c))
                    {
                        if(!string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Order_Name__c)))
                        {
                            BOID.Order_Name__c = mapOrderItems.get(BOID.id__c).Order_Name__c;
                        }
                        if(!string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Customer_Name__c)))
                        {
                            BOID.Customer_Name__c = mapOrderItems.get(BOID.id__c).Customer_Name__c;
                        }
                        if(!string.isBlank(string.valueof(mapOrderItems.get(BOID.id__c).Primary_Contact_Customer__c)))
                        {
                            BOID.Primary_Contact_Customer__c = mapOrderItems.get(BOID.id__c).Primary_Contact_Customer__c;
                        }
                    }
                }
                MapBOIDEx.put(BOID.id__c,BOID);
            }
            if(!MapBOIDEx.isEmpty())
            {
                database.update(MapBOIDEx.values(),false);
            }
        }
        if(!TravellerInfoIds.isEmpty())
        {
            Map<string,Traveller_Info__c> MapTIEx = new Map<string,Traveller_Info__c>();
            For(Traveller_Info__c TI: [select id, id__c,Bus_Order_Item_Details__c,Creation_Time__c,Updated_Time__c, DateOfBirth__c, Order_Item_Name__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c, Bus_Order_Item_Details_Id__c from Traveller_Info__c where id__c IN: TravellerInfoIds  AND Order_Item_Linkage__c =: False])
            {
                if(!string.isBlank(string.valueof(TI.Bus_Order_Item_Details_Id__c)))
                {
                    if(mapOrderItems.KeySet().contains(TI.Bus_Order_Item_Details_Id__c))
                    {
                        if(!string.isBlank(string.valueof(mapOrderItems.get(TI.Bus_Order_Item_Details_Id__c).Order_Name__c)))
                        {
                            TI.Order_Name__c = mapOrderItems.get(TI.Bus_Order_Item_Details_Id__c).Order_Name__c;
                        }
                        if(!string.isBlank(string.valueof(mapOrderItems.get(TI.Bus_Order_Item_Details_Id__c).Customer_Name__c)))
                        {
                            TI.Customer_Name__c = mapOrderItems.get(TI.Bus_Order_Item_Details_Id__c).Customer_Name__c;
                        }
                        if(!string.isBlank(string.valueof(mapOrderItems.get(TI.Bus_Order_Item_Details_Id__c).Primary_Contact_Customer__c)))
                        {
                            TI.Primary_Contact_Customer__c = mapOrderItems.get(TI.Bus_Order_Item_Details_Id__c).Primary_Contact_Customer__c;
                        }
                    }
                }
                MapTIEx.put(TI.id__c,TI);
            }
            if(!MapTIEx.isEmpty())
            {
                database.update(MapTIEx.values(),false);
            }
        }
        if(!refundIds.isEmpty() || !allOrderItemidsLink.isEmpty())
        {    
            Map<string,Refund_Order_Items__c> MapROIEx = new Map<string,Refund_Order_Items__c>();
            For(Refund_Order_Items__c ROI: [select id, id__c,Customer_Name_account__c,Status__c, Creation_Time__c,Updated_Time__c, Payment_Item_ID__c, Payment_Item_Name__c, Order_Item_Name__c, Customer_Name__c, Primary_Contact_Customer__c, Order_Item_ID__c from Refund_Order_Items__c where (Order_Item_ID__c IN: allOrderItemidsLink OR ID__c IN: refundIds)])
            {
               /* if(!string.isBlank(string.valueof(ROI.Order_Item_Name__c)))
                {
                    if(!string.isBlank(string.valueof(ROI.Status__c)))
                    {
                        mapOrderItems.get(ROI.Order_Item_ID__c).Refund_Status__c = string.valueof(ROI.Status__c);
                    }
                }*/
                if(!string.isBlank(string.valueof(ROI.Order_Item_ID__c)) )
                {
                    if(mapOrderItems.KeySet().contains(ROI.Order_Item_ID__c))
                    {
                        if(!string.isBlank(string.valueof(mapOrderItems.get(ROI.Order_Item_ID__c).Customer_Name__c)))
                        {
                            ROI.Customer_Name_account__c = mapOrderItems.get(ROI.Order_Item_ID__c).Customer_Name__c;
                        }
                        if(!string.isBlank(string.valueof(mapOrderItems.get(ROI.Order_Item_ID__c).Primary_Contact_Customer__c)))
                        {
                            ROI.Primary_Contact_Customer__c = mapOrderItems.get(ROI.Order_Item_ID__c).Primary_Contact_Customer__c;
                        }
                        if(!string.isBlank(string.valueof(ROI.Status__c)) && mapOrderItems.KeySet().Contains(ROI.Order_Item_ID__c))
                        {
                            mapOrderItems.get(ROI.Order_Item_ID__c).Refund_Status__c = string.valueof(ROI.Status__c);
                        }
                    }
                }
                MapROIEx.put(ROI.id__c,ROI);
            }
            if(!MapROIEx.isEmpty())
            {
                database.update(MapROIEx.values(),false);
            }
        }
        if(!cancelOrderItemIds.isEmpty())
        {
            Map<string,Cancelled_Order_Items__c> MapCOIEx = new Map<string,Cancelled_Order_Items__c>();
            For(Cancelled_Order_Items__c COI: [select id, id__c,Order_ID__c,Order_Name__c, Creation_Time__c,Updated_Time__c,Cancellation_Time__c, Date_Of_Purchase__c, Order_Item_Name__c, Customer_Name__c, Primary_Contact_Customer__c, Order_Item_ID__c from Cancelled_Order_Items__c where id__c IN: cancelOrderItemIds and Order_Item_Linkage__c=:false])
            {
                if(!string.isBlank(string.valueof(COI.Order_Item_ID__c)))
                {
                    if(mapOrderItems.KeySet().contains(COI.Order_Item_ID__c))
                    {
                        if(!string.isBlank(string.valueof(mapOrderItems.get(COI.Order_Item_ID__c).Customer_Name__c)))
                        {
                            COI.Customer_Name__c = mapOrderItems.get(COI.Order_Item_ID__c).Customer_Name__c;
                        }
                        if(!string.isBlank(string.valueof(mapOrderItems.get(COI.Order_Item_ID__c).Primary_Contact_Customer__c)))
                        {
                            COI.Primary_Contact_Customer__c = mapOrderItems.get(COI.Order_Item_ID__c).Primary_Contact_Customer__c;
                        }
                    } 
                }
                MapCOIEx.put(COI.id__c,COI);
            }
            if(!MapCOIEx.isEmpty())
            {
                database.update(MapCOIEx.values(),false);
            }
        }
        if(!mapOrders.isEmpty())
        {
            database.update(mapOrders.values(),false);
        }
        if(!mapOrderItems.isEmpty())
        {
            database.update(mapOrderItems.values(),false);
        }
        if(!OrderItemCustomerMap.isEmpty())
        {
            database.update(OrderItemCustomerMap.values(),false);
        }
        if(!string.isBlank(string.valueof(DBLoagID)))
        {
            dbl.id = DBLoagID;
            dbl.Linking_Process_Status__c = 'Completed';
            dbl.Linking_Process_Start_Time__c = starttime;
            dbl.Linking_Process_Complete_Time__c = system.now();
            database.update(dbl,false);
        }
      }
      catch(exception e)
      {
          if(!string.isBlank(string.valueof(DBLoagID)))
            {
                dbl.id = DBLoagID;
                dbl.Linking_Process_Status__c = 'Failed';
                dbl.Linking_Process_Complete_Time__c = system.now();
                dbl.Linking_Process_Error_Description__c = string.valueof(e);
                database.update(dbl,false);
            }
      } 
    }
}