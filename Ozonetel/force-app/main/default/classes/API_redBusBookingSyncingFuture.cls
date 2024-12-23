global without sharing class API_redBusBookingSyncingFuture
{
    @future(callout=true)
    public static void ProcessBookingINfo(set<string> ordrItemPhoneNumbers, 
                                          set<string> ordrItemEmails, 
                                          string orderItemAccounts, 
                                          string DBLoagID,
                                          string strMapObjNametoRcvdIds,
                                          String strMapObjtoSavedResults,
                                          String strMapObjIdtoOrderId,
                                          String region,
                                          set<string> reschOrderIds,
                                          set<string> businessType,
                                          string syncedFrom
                                         )
    {
                
        List<DB_Log__c> listDBLog = new List<DB_Log__c>();
        DBLog_Summary__c dbl = new DBLog_Summary__c(id=Id.valueOf(DBLoagID));
        dbl.Linking_Process_Start_Time__c = system.now();
        Map<String,List<String>> mapObjNameApiName = new Map<String,List<String>>();
        Map<String,list<string>> mapObjNametoRcvdIds = new Map<String,list<String>>();
        Map<String,String> MapObjIdtoOrderId = new Map<String,String>();
        Map<String,List<Database.UpsertResult>> mapObjtoSavedResults = new Map<String,List<Database.UpsertResult>>();
        string redisNum = 'IND'.equalsIgnoreCase(region)?System.Label.RedisDBNum.split(',')[0]:System.Label.RedisDBNum.split(',')[1];
        if(!businessType.isEmpty() && businessType.contains('RAILS')){
        redisNum=System.Label.RedisDBNum.split(',')[2];
        }
        try
        {  
            for(SyncStatusUpdateFields__mdt mapper : [Select MasterLabel,DeveloperName,Field_API_Names__c from SyncStatusUpdateFields__mdt])
                mapObjNameApiName.put(mapper.DeveloperName,mapper.Field_API_Names__c.split(','));
            
            Set<String> ordItemIds = new Set<String>();
            map<string,string> OrdersCustomerIdsMap = new map<string,string>();
            map<string,account> OrderItemCustomerMap = new map<string,account>();
            
            mapObjNametoRcvdIds = (Map<String,list<string>>)JSON.deserializeStrict(strMapObjNametoRcvdIds,Map<String,list<string>>.class);
            mapObjtoSavedResults = (Map<String,List<Database.UpsertResult>>)JSON.deserializeStrict(strMapObjtoSavedResults,Map<String,List<Database.UpsertResult>>.class);
            MapObjIdtoOrderId  = (Map<String,String>)JSON.deserializeStrict(strMapObjIdtoOrderId,Map<String,String>.class);
            
            /* Start parse saved results and store it in db log summary*/
            Set<String> failedOrderForResync = new Set<String>();
            Set<String> setNonOrderRcds = new Set<String>{'TravellerInfo','RefundOrderItems'};
                for(String objName : mapObjtoSavedResults.keySet())
            {
                List<String> recordIds = new List<String>(mapObjNametoRcvdIds.get(objName));
                List<String> apiNames = new List<String>(mapObjNameApiName.get(objName));
                Integer savdResultsCnt = mapObjtoSavedResults.get(objName).size();
                List<Database.UpsertResult> upsertResult = new List<Database.UpsertResult>(mapObjtoSavedResults.get(objName));
                list<string> SuccessList = new list<string>();
                list<string> FailedList = new list<string>();
                list<string> FailedDesscList = new list<string>();
                Integer recCount = recordIds.size();
                String processStatus='';
                
                for(Integer i=0;i<savdResultsCnt;i++)
                {
                    if (upsertResult.get(i).isSuccess())
                        SuccessList.add(recordIds[i]);
                    
                    else if(!upsertResult.get(i).isSuccess())
                    {
                        string statusCode = string.valueof(upsertResult.get(i).getErrors()[0].getStatusCode());
                        if(!'INVALID_EMAIL_ADDRESS'.equalsIgnoreCase(statusCode)){
                            if(setNonOrderRcds.contains(objName))
                                failedOrderForResync.add(MapObjIdtoOrderId.get(recordIds[i].left(recordIds[i].length()-2)));
                            else
                                failedOrderForResync.add(MapObjIdtoOrderId.get(recordIds[i]));
                        }
                        FailedList.add(recordIds[i]);
                        FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                        DB_Log__c DB = new DB_Log__c();
                        DB.Object_Name__c = objName;
                        DB.Lock_type__c = 'redBus Data process';
                        DB.DBLog_Summary__c = dbl.id;
                        DB.ID__c = recordIds[i];     
                        DB.Error_Description__c = string.valueof(upsertResult.get(i).getErrors());
                        if(String.isNotBlank(DB.Error_Description__c))
                            DB.Error_Status_Code__c = statusCode;
                        if(DB.Error_Description__c.Contains('getStatusCode=INVALID_FIELD'))
                        {
                            DB.Locked_record__c = false;
                        }
                        listDBLog.add(DB);
                    }
                }
                
                processStatus = recCount==SuccessList.size()?'Success':recCount==FailedList.size()?'Fail':'Partial';
                dbl.put(apiNames[0],string.join(SuccessList,','));
                dbl.put(apiNames[1],SuccessList.size());
                dbl.put(apiNames[2],string.join(FailedList,','));
                dbl.put(apiNames[3],FailedList.size());
                dbl.put(apiNames[5],processStatus);
                
                if(!string.isBlank(string.valueof(string.join(FailedDesscList,','))) && string.valueof(string.join(FailedDesscList,',')).length()>25000)
                    dbl.put(apiNames[4],string.valueof(string.join(FailedDesscList,',')).substring(0,24000));
                else
                    dbl.put(apiNames[4],string.join(FailedDesscList,','));
                
                
            }
            if(!failedOrderForResync.isEmpty() && String.isNotBlank(syncedFrom) && syncedFrom!='SyncRedBusData' && syncedFrom!='UserTrips')
            {
                Http ht = new Http();
                HttpRequest shrtReq = new HttpRequest();
                HttpResponse shrtResp = new HttpResponse(); 
                shrtReq = HttpRequestUtil.populateHeaders(shrtReq);
                RedisPushRequest jsbody = new RedisPushRequest();
                jsbody.listOrdIds =new List<String>(failedOrderForResync);
                jsbody.dbNum =redisNum;
                jsbody.region =region;                                   
                shrtReq.setMethod('POST');   
                string finjsBody = JSON.serialize(jsBody);
                System.debug('jsBody...'+finjsBody );          
                shrtReq.setBody(finjsBody);
                shrtReq.setTimeout(120000);
                API_EndPoints__mdt config = new API_EndPoints__mdt();
                config = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='PushToRedis' limit 1];
                shrtReq.setendpoint(config.Endpoint__c);
                dbl.Payment_Request_Sent_Data__c= 'Request..'+shrtReq+'..'+shrtReq.getBody()+'..Response..'+shrtReq.getEndpoint();
                if(config.EnableLog__c)
                    shrtResp=ht.send(shrtReq);
                dbl.Payment_Request_Response_Data__c = String.valueOf(shrtResp+'...Body..'+shrtResp.getBody());
            } 
            
            if(!listDBLog.isEmpty())
                database.insert(listDBLog,false);
            
            //Fetch all orders to create a signedIn user accounts
            Set<String> setOrderIds = new Set<String>();
            map<string,Orders__c> mapOrders = new map<string,Orders__c>();
            list<account> orderSignedInAcclist = new list<account>();
            set<string> orderSignedInUserIds = new Set<String>();
            set<string> ordSignedInPhoneNumbers = new Set<String>(); 
            string orderSignedAccounts;// = new Set<String>();
            set<string> ordSignedInEmails = new Set<String>();
            String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
            Pattern MyPattern = Pattern.compile(emailRegex);
            
            if(mapObjNametoRcvdIds.containsKey('Orders'))
            {
                setOrderIds.addAll(mapObjNametoRcvdIds.get('Orders'));
                for(Orders__c ord: [select id, id__c,User_Id__c,Cust_Id__c,Cust_Details__c,Customer_Name__c,Primary_Contact_Customer__c,Business_Unit__c from Orders__c where id__c IN:setOrderIds])
                {
                    if(String.isNotBlank(ord.Cust_Details__c) && String.isNotBlank(ord.Cust_Id__c) && Integer.valueOf(ord.Cust_Id__c)>0)
                    {
                        SignedInUserRequest ordSignAcc = new SignedInUserRequest();
                        ordSignAcc =(SignedInUserRequest)JSON.deserialize(ord.Cust_Details__c,SignedInUserRequest.class);
                        Account cust = new Account();
                        cust.AccountSource = 'Signed In User';
                        cust.LastName = 'N/A';                          
                        cust.IsEmailIdVerified__c = ordSignAcc.IsEmailVerified;
                        cust.IsMobileVerified__c = ordSignAcc.IsMobileVerified;
                        cust.PasswordExists__c = ordSignAcc.PasswordExists;
                        cust.isWalletEnabled__c = ordSignAcc.isWalletEnabled;
                        cust.PreferredCurrency__c = ordSignAcc.PreferredCurrency;
                        cust.WalletId__c = ordSignAcc.WalletId;
                        cust.CountryCode__c = ordSignAcc.CountryCode;
                        cust.UpdatedOn__c = system.now();
                        
                        if(ordSignAcc.UserId!=null && ordSignAcc.UserId>0)
                        {
                            cust.User_Id__c = string.valueof(ordSignAcc.UserId);
                            orderSignedInUserIds.add(cust.User_Id__c);  
                        }
                        
                        if(string.isNotBlank(ordSignAcc.PEmail))
                        {
                            cust.Email_Copy__c = ordSignAcc.PEmail;
                            
                            if(MyPattern.matcher(cust.Email_Copy__c).matches())
                            {
                                cust.PersonEmail = cust.Email_Copy__c;
                                ordSignedInEmails.add(cust.PersonEmail);                                    
                            }
                        }
                        
                        if(string.isNotBlank(ordSignAcc.PMobile))
                        {
                            cust.PersonMobilePhone = ordSignAcc.PMobile;
                            cust.LastName = cust.PersonMobilePhone;
                            ordSignedInPhoneNumbers.add(cust.PersonMobilePhone);
                        }
                        if(string.isNotBlank(ordSignAcc.Dob))
                            //cust.Birthdate__c = datetime.valueof(ordSignAcc.Dob);
                            cust.Birthdate__c = String.isNotBlank(ordSignAcc.Dob)? datetime.valueof(ordSignAcc.Dob.replace('T',' ')):null;
                        
                        if(ordSignAcc.Gender!=null)
                            cust.Gender__c = string.valueof(ordSignAcc.Gender);
                        
                        if(ordSignAcc.PhoneCode!=null)
                            cust.PhoneCode__c = string.valueof(ordSignAcc.PhoneCode);
                        
                        if(String.isNotBlank(ordSignAcc.DisplayName))
                            cust.LastName = ordSignAcc.DisplayName;
                        orderSignedInAcclist.add(cust);
                        
                    }
                    mapOrders.put(ord.id,ord);
                }
            }
            
            //Start account creation for Signed In users came from orders
            if(!orderSignedInAcclist.isEmpty())
            {  
                set<string> accountids = new set<string>();
                list<account> newExistingCustomer = new list<account>();
                Map<id,Account> mapExstAccToUpdate = new Map<id,Account>();
                map<string,account> exCustomerDetails = new map<string,account>();
                map<string,account> exCustomerPhoneDetails = new map<string,account>();
                map<string,contact> exContacts = new map<string,contact>();
                list<contact> newContact = new list<contact>();
                
                //Fetch existing accounts matches with userids,phone numbers and related contacts matches with accounts and emails
                if(!orderSignedInUserIds.isEmpty() || !ordSignedInPhoneNumbers.isEmpty())
                {
                    for(account ac:  [select id,PersonMobilePhone, User_Id__c, PersonEmail,Parent_Account__c from account where User_Id__c IN: orderSignedInUserIds OR PersonMobilePhone IN: ordSignedInPhoneNumbers])
                    {
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
                    
                    if(!accountids.isEmpty())
                    {
                        for(contact co: [select id, name, email, Account_name__c from contact where Account_name__c IN: accountids and email IN: ordSignedInEmails ])
                        {
                            exContacts.put(co.Account_name__c,co);
                        }
                    }
                }
                
                
                for(account ac: orderSignedInAcclist)
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
                            newExistingCustomer.add(newAcc);
                        }
                        mapExstAccToUpdate.put(ac.id,ac);
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
                        mapExstAccToUpdate.put(ac.id,ac);
                    }
                    else
                    {
                        newExistingCustomer.add(ac);
                    }
                }
                if(!mapExstAccToUpdate.isEmpty())
                    newExistingCustomer.addAll(mapExstAccToUpdate.values());
                
                if(!newExistingCustomer.isEmpty())
                {
                    database.upsert(newExistingCustomer,false);
                }
                
                if(!exContacts.isEmpty())
                {
                    database.update(exContacts.Values(),false);
                }
                if(!newContact.isEmpty())
                {
                    database.insert(newContact,false);
                }
                
                if(!orderSignedInUserIds.isEmpty())
                {
                    for(account ac:  [select id,PersonMobilePhone,User_Id__c from account where User_Id__c IN:orderSignedInUserIds ])
                    {
                        OrdersCustomerIdsMap.put(ac.User_Id__c,ac.id);
                    }
                } 
            }
            
            
            //Start account creation for Users came from Order items and Traveller Info
            if(String.isNotBlank(orderItemAccounts))
            {
                list<account> listOrderItemAccounts = new list<account>();
                listOrderItemAccounts = (List<Account>)JSON.deserialize(orderItemAccounts,List<account>.class);
                
                map<string,account> updateCustomer = new map<string,account>();
                list<account> newCustomer = new list<account>();
                map<string,account> exCustomerDetails = new map<string,account>();
                map<string,string> AddedList = new map<string,string>();
                list<contact> contacts = new list<contact>();
                map<string,contact> exContacts = new map<string,contact>();
                set<string> accountids = new set<string>();
                list<contact> newContact = new list<contact>();
                
                if(!ordrItemPhoneNumbers.isEmpty() )
                {
                    for(account ac:  [select id,lastname,PersonMobilePhone, User_Id__c, PersonEmail, Primary_Account__c,Parent_Account__c from account where PersonMobilePhone IN: ordrItemPhoneNumbers])
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
                        contacts = [select id, name, email, Account_name__c from contact where Account_name__c IN: accountids and email IN: ordrItemEmails];
                        if(!contacts.isEmpty())
                        {
                            for(contact co: contacts)
                            {
                                exContacts.put(co.Account_name__c,co);
                            }
                            
                        }
                    }
                }
                if(!listOrderItemAccounts.isEmpty())
                {
                    for(account ac: listOrderItemAccounts)
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
                if(!ordrItemPhoneNumbers.isEmpty())
                {
                    for(account ac:  [select id,PersonMobilePhone,User_Id__c,Parent_Account__c from account where PersonMobilePhone IN: ordrItemPhoneNumbers ])
                    {
                        OrderItemCustomerMap.put(ac.PersonMobilePhone,ac);
                    }
                }
            }
            
            // Start Update the Signed In User in Orders
            map<string,Orders__c> mapOrdersToUpdate = new map<string,Orders__c>();
            
            
            if(mapObjNametoRcvdIds.containsKey('Orders'))
            {
                for(Orders__c ors: mapOrders.values())
                {
                    if(OrdersCustomerIdsMap.KeySet().Contains(ors.Cust_Id__c))
                    {
                        ors.User_Id__c = ors.Cust_Id__c;
                        ors.Customer_Name__c = OrdersCustomerIdsMap.get(ors.User_Id__c);
                    }                  
                    mapOrdersToUpdate.put(ors.id__c,ors);
                }
                
            }
            
            // Start Update the Signed In User/Primary Contact Customer/Refund Status in Orders Items
            map<string,Order_Items__c> mapOrderItems = new map<string,Order_Items__c>();
            map<string,Order_Items__c> mapOrderOrderItems = new map<string,Order_Items__c>();
            Set<String> setOrderitemIds = new Set<String>();
            list<WFT_GFT__c> listWFTGFT = new list<WFT_GFT__c>();
            map<string,Service_Provider__c> mapserviceProvider = new map<string,Service_Provider__c>();
            map<String,Transaction_Status_Category__c> mapTransStatus = new Map<String,Transaction_Status_Category__c>();
            List<Payment_Items__c> pitems=new List<Payment_Items__c>();
            Map<string,Payment_Items__c> piMap=new Map<string,Payment_Items__c>();
            if(!reschOrderIds.isEmpty()){
            list<String> paySystems= new list<String>();          
            paySystems.addAll(System.Label.Payment_Systems.split(','));     
            pItems=[select id,name,Payment_Status__c,Order_Id__c,Creation_Time__c from Payment_Items__c where Payment_Status__c='COMPLETED' and Payment_System__c in:paySystems and Order_Id__c in:reschOrderIds order by Creation_Time__c asc];
                    
            for(Payment_Items__c p:pItems){
                   piMap.put(p.Order_ID__c,p);
             }
            }
            
            if(mapObjNametoRcvdIds.containsKey('OrderItems'))
            {
                for(Transaction_Status_Category__c tsc : Transaction_Status_Category__c.getAll().Values())
                    mapTransStatus.put(tsc.Status__c,tsc);
                
                setOrderitemIds.addAll(mapObjNametoRcvdIds.get('OrderItems'));
                for(Order_Items__c orItem: [select id,Status__c,id__c,Discard_Reason__c,Rebooking_For__c,Rescheduling_For__c,Creation_Time__c,mobile__c,Item_Type__c,Refund_Status__c,Transaction_Status__c,Transaction_Status_WFT_GFT__c,Order_Name__c,Service_Provider_Id__c,Service_Provider_Name__c,Order_Item_Reference_No__c,Customer_Name__c,Primary_Contact_Customer__c,Order_Id__c,Cancellation_Reason__c,Business_Unit__c,Service_Provider_Reference_No__c from Order_Items__c where id__c IN: setOrderitemIds])
                {
                    if(string.isNotBlank(orItem.mobile__c) && OrderItemCustomerMap.KeySet().Contains(orItem.Mobile__c))
                    {
                        system.debug('------------process 1-------------');
                        if(string.isNotBlank(string.valueof(OrderItemCustomerMap.get(orItem.Mobile__c).User_Id__c)))
                        {
                            system.debug('------------process 2-------------');
                            if(string.isNotBlank(string.valueof(orItem.Order_Id__c)) && mapOrdersToUpdate.KeySet().contains(orItem.Order_Id__c) && !string.isBlank(string.valueof(mapOrdersToUpdate.get(orItem.Order_Id__c).Customer_Name__c)) && mapOrdersToUpdate.get(orItem.Order_Id__c).Customer_Name__c != OrderItemCustomerMap.get(orItem.Mobile__c).id)
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
                    
                    if(!string.isBlank(string.valueof(orItem.Order_Id__c)) && mapOrdersToUpdate.KeySet().contains(orItem.Order_Id__c))
                    {
                        if(!string.isBlank(string.valueof(mapOrdersToUpdate.get(orItem.Order_Id__c).Customer_Name__c)))
                        {
                            orItem.Customer_Name__c = mapOrdersToUpdate.get(orItem.Order_Id__c).Customer_Name__c;
                            if(orItem.Customer_Name__c!=orItem.Primary_Contact_Customer__c)
                            {
                                mapOrdersToUpdate.get(orItem.Order_Id__c).Primary_Contact_Customer__c = orItem.Primary_Contact_Customer__c;
                            }
                        }
                        else
                            if(!string.isBlank(string.valueof(orItem.Primary_Contact_Customer__c)))
                        {
                            mapOrdersToUpdate.get(orItem.Order_Id__c).Primary_Contact_Customer__c = orItem.Primary_Contact_Customer__c;
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
                    
                    if(String.isBlank(orItem.Order_Item_Reference_No__c))
                    {
                        WFT_GFT__c WG = new WFT_GFT__c();
                        WG.ID__c = orItem.id__c;
                        WG.Transaction_Name__r = new Order_Items__c(id__c=orItem.id__c);
                        listWFTGFT.add(WG);
                    }
                    
                    if(mapTransStatus.containsKey(orItem.Status__c))
                    {
                        orItem.Transaction_Status__c = mapTransStatus.get(orItem.Status__c).Transaction_Status__c;
                        orItem.Transaction_Status_WFT_GFT__c = mapTransStatus.get(orItem.Status__c).Transaction_FT_Status__c;
                        if(orItem.Transaction_Status__c.startsWithIgnoreCase('Ticket Cancelled') && 'BUS'.equalsIgnoreCase(orItem.Item_Type__c))
                            orItem.Transaction_Status__c = 'Ticket Cancelled'+' - '+orItem.Refund_Status__c;
                        
                        else if(orItem.Transaction_Status__c.startsWithIgnoreCase('Ticket Cancelled') && 'Coupon'.equalsIgnoreCase(orItem.Item_Type__c))
                        {
                            orItem.Transaction_Status__c = 'Coupon Cancelled'+' - '+orItem.Refund_Status__c;
                            
                            if(String.isNotBlank(orItem.Cancellation_Reason__c) && orItem.Cancellation_Reason__c.contains('REDEMPTION'))
                                orItem.Transaction_Status__c = 'Coupon Redeemed'+' - '+orItem.Refund_Status__c;
                            
                        }
                        
                        if(String.isNotBlank(orItem.Rescheduling_For__c)){
                            System.debug('pItemsG-->'+pItems);
                            
                            if((orItem.Status__c== 'TR_TENTATIVE_SUCCESSFUL_PO_COMPLETED' &&  piMap!=null && piMap.get(orItem.Order_Id__c).Creation_Time__c>=orItem.Creation_Time__c) || orItem.Status__c.contains('TR_CONFIRMATION_FAILURE')){
                                orItem.Transaction_Status__c = 'GFT - Payment Debited but Ticket not Generated';
                                orItem.Transaction_Status_WFT_GFT__c = 'GFT';
                            }else if(string.isBlank(orItem.Order_Item_Reference_No__c)){
                                orItem.Transaction_Status__c = 'WFT';
                                orItem.Transaction_Status_WFT_GFT__c = 'WFT';
                            }       
                        }
                        
                        if(String.isNotBlank(orItem.Rebooking_For__c)){
                            if(orItem.Status__c== 'TR_CONFIRMATION_FAILURE_PO_COMPLETED'){
                                orItem.Transaction_Status__c = 'GFT - Payment Debited but Ticket not Generated';
                                orItem.Transaction_Status_WFT_GFT__c = 'GFT';
                            }else if(orItem.Status__c== 'TR_TENTATIVE_SUCCESSFUL_PO_COMPLETED'){
                                orItem.Transaction_Status__c = 'WFT';
                                orItem.Transaction_Status_WFT_GFT__c = 'WFT';
                            }
                        }
                        if(orItem.Status__c.contains('TR_DISCARDED') && orItem.Discard_Reason__c=='multiple create attempt'){
                                orItem.Transaction_Status__c = 'WFT';
                                orItem.Transaction_Status_WFT_GFT__c = 'WFT';                        
                        }
                        
                    }
                    
                    if(String.IsNotBlank(orItem.Service_Provider_Reference_No__c) && String.IsBlank(orItem.Order_Item_Reference_No__c) && 'BUS'.equalsIgnoreCase(orItem.Item_Type__c))
                    {
                        orItem.Transaction_Status__c = 'Misbooking - PNR generated but ticket not confirmed';
                        orItem.Transaction_Status_WFT_GFT__c = 'GFT';
                    }
                    
                    if(String.isNotBlank(orItem.Service_Provider_Id__c))
                    {
                        Service_Provider__c serpro = new Service_Provider__c();   
                        serpro.Operator_Id__c = orItem.Service_Provider_Id__c;
                        
                        if(String.isNotBlank(orItem.Service_Provider_Name__c))
                        {
                            if(String.valueOf(orItem.Service_Provider_Name__c).length()>80)
                            {
                                serpro.name =  string.valueof(orItem.Service_Provider_Name__c).substring(0,80);
                            }
                            else
                            {
                                serpro.name =  orItem.Service_Provider_Name__c;
                            }
                            serpro.TravelsFullName__c = orItem.Service_Provider_Name__c;
                        }
                        else
                        {
                            serpro.name =  'NA';
                            serpro.TravelsFullName__c = 'NA';
                        }
                        mapserviceProvider.put(serpro.Operator_Id__c,serpro);
                        orItem.Service_Provider_Info__r = new Service_Provider__c(Operator_Id__c = orItem.Service_Provider_Id__c); 
                    }
                    
                    mapOrderItems.put(orItem.id__c,orItem);
                    mapOrderOrderItems.put(orItem.Order_Id__c,orItem);
                    
                }
                
                if(!mapserviceProvider.isempty())
                    Database.upsert(mapserviceProvider.values(),Service_Provider__c.Operator_Id__c,false);
                
                if(!listWFTGFT.isEmpty())
                    Database.upsert(listWFTGFT,WFT_GFT__c.ID__c,false);
                
            }
            
            
            if(!mapOrdersToUpdate.isEmpty())
                database.update(mapOrdersToUpdate.values(),false);
            
            
            //Start Update the Signed In User/Primary Contact Customer in Bus Orders Items
            Set<String> setBusOrderitemIds = new Set<String>();             
            if(mapObjNametoRcvdIds.containsKey('BusOrderItems'))
            {
                Map<string,Bus_Order_Item_Details__c> mapBusOrdItemsToUpdate = new Map<string,Bus_Order_Item_Details__c>();
                setBusOrderitemIds.addAll(mapObjNametoRcvdIds.get('BusOrderItems'));
                for(Bus_Order_Item_Details__c BOID: [select id,id__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c from Bus_Order_Item_Details__c where id__c IN: setBusOrderitemIds])
                {
                    if(string.isNotBlank(BOID.id__c) && mapOrderItems.KeySet().contains(BOID.id__c))
                    {
                        if(String.isBlank(BOID.Order_Name__c) && string.isNotBlank(string.valueof(mapOrderItems.get(BOID.id__c).Order_Name__c)))
                        {
                            BOID.Order_Name__c = mapOrderItems.get(BOID.id__c).Order_Name__c;
                        }
                        if(String.isBlank(BOID.Customer_Name__c) && !string.isNotBlank(string.valueof(mapOrderItems.get(BOID.id__c).Customer_Name__c)))
                        {
                            BOID.Customer_Name__c = mapOrderItems.get(BOID.id__c).Customer_Name__c;
                        }
                        if(String.isBlank(BOID.Primary_Contact_Customer__c) && string.isNotBlank(string.valueof(mapOrderItems.get(BOID.id__c).Primary_Contact_Customer__c)))
                        {
                            BOID.Primary_Contact_Customer__c = mapOrderItems.get(BOID.id__c).Primary_Contact_Customer__c;
                        }
                        mapBusOrdItemsToUpdate.put(BOID.id__c,BOID);
                    }
                    
                }
                if(!mapBusOrdItemsToUpdate.isEmpty())
                {
                    database.update(mapBusOrdItemsToUpdate.values(),false);
                }
            }
            
            //Start Update the Signed In User/Primary Contact Customer in Traveller Info 
            Set<String> setTravellerInfoIds = new Set<String>();
            if(mapObjNametoRcvdIds.containsKey('TravellerInfo'))
            {
                Map<string,Traveller_Info__c> mapTravellerInfoToUpdate = new Map<string,Traveller_Info__c>();
                setTravellerInfoIds.addAll(mapObjNametoRcvdIds.get('TravellerInfo'));
                for(Traveller_Info__c TI: [select id, id__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c, Bus_Order_Item_Details_Id__c from Traveller_Info__c where id__c IN: setTravellerInfoIds])
                {
                    if(string.isNotBlank(string.valueof(TI.Bus_Order_Item_Details_Id__c)) && mapOrderItems.KeySet().contains(TI.Bus_Order_Item_Details_Id__c))
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
                    mapTravellerInfoToUpdate.put(TI.id__c,TI);
                }
                if(!mapTravellerInfoToUpdate.isEmpty())
                {
                    database.update(mapTravellerInfoToUpdate.values(),false);
                }
            }
            
            //Start Update the Signed In User/Primary Contact Customer in Refund Orders Items
            Set<String> setRefundOrderItemIds = new Set<String>();
            if(mapObjNametoRcvdIds.containsKey('RefundOrderItems'))
            {
                setRefundOrderItemIds.addAll(mapObjNametoRcvdIds.get('RefundOrderItems'));
                Map<string,Refund_Order_Items__c> mapRefundOrderItemsUpdate = new Map<string,Refund_Order_Items__c>();
                for(Refund_Order_Items__c ROI: [select id, id__c,Customer_Name_account__c,Status__c, Customer_Name__c, Primary_Contact_Customer__c, Order_Item_ID__c from Refund_Order_Items__c where ID__c IN: setRefundOrderItemIds])
                {
                    
                    if(string.isNotBlank(string.valueof(ROI.Order_Item_ID__c)) && mapOrderItems.KeySet().contains(ROI.Order_Item_ID__c))
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
                            if(mapOrderItems.get(ROI.Order_Item_ID__c).Transaction_Status__c.startsWithIgnoreCase('Ticket Cancelled') && 'BUS'.equalsIgnoreCase(mapOrderItems.get(ROI.Order_Item_ID__c).Item_Type__c))
                            {
                                mapOrderItems.get(ROI.Order_Item_ID__c).Transaction_Status_WFT_GFT__c='';
                                mapOrderItems.get(ROI.Order_Item_ID__c).Transaction_Status__c = 'Ticket Cancelled - '+string.valueof(ROI.Status__c);
                            }
                            
                            if(mapOrderItems.get(ROI.Order_Item_ID__c).Transaction_Status__c.startsWithIgnoreCase('Coupon Cancelled') && 'Coupon'.equalsIgnoreCase(mapOrderItems.get(ROI.Order_Item_ID__c).Item_Type__c))
                            {
                                mapOrderItems.get(ROI.Order_Item_ID__c).Transaction_Status_WFT_GFT__c='';
                                mapOrderItems.get(ROI.Order_Item_ID__c).Transaction_Status__c = 'Coupon Cancelled - '+string.valueof(ROI.Status__c);
                                
                                if(String.isNotBlank(mapOrderItems.get(ROI.Order_Item_ID__c).Cancellation_Reason__c) && mapOrderItems.get(ROI.Order_Item_ID__c).Cancellation_Reason__c.contains('REDEMPTION'))
                                    mapOrderItems.get(ROI.Order_Item_ID__c).Transaction_Status__c = 'Coupon Redeemed'+' - '+string.valueof(ROI.Status__c);
                                
                            }
                            
                        }
                        mapRefundOrderItemsUpdate.put(ROI.id__c,ROI);
                    }
                    
                }
                if(!mapRefundOrderItemsUpdate.isEmpty())
                {
                    database.update(mapRefundOrderItemsUpdate.values(),false);
                }
            }
            
            //Start Update the Signed In User/Primary Contact Customer in Canceled Orders Items
            Set<String> setCancelledOrderItemIds = new Set<String>();
            if(mapObjNametoRcvdIds.containsKey('CancelOrderItems'))
            {
                Map<string,Cancelled_Order_Items__c> mapCancelOrdItmes = new Map<string,Cancelled_Order_Items__c>();
                setCancelledOrderItemIds.addAll(mapObjNametoRcvdIds.get('CancelOrderItems'));
                for(Cancelled_Order_Items__c COI: [select id, id__c, Customer_Name__c, Primary_Contact_Customer__c, Order_Item_ID__c from Cancelled_Order_Items__c where id__c IN: setCancelledOrderItemIds])
                {
                    if(string.isNotBlank(string.valueof(COI.Order_Item_ID__c)) && mapOrderItems.KeySet().contains(COI.Order_Item_ID__c))
                    {
                        if(string.isNotBlank(string.valueof(mapOrderItems.get(COI.Order_Item_ID__c).Customer_Name__c)))
                        {
                            COI.Customer_Name__c = mapOrderItems.get(COI.Order_Item_ID__c).Customer_Name__c;
                        }
                        if(string.isNotBlank(string.valueof(mapOrderItems.get(COI.Order_Item_ID__c).Primary_Contact_Customer__c)))
                        {
                            COI.Primary_Contact_Customer__c = mapOrderItems.get(COI.Order_Item_ID__c).Primary_Contact_Customer__c;
                        }
                        mapCancelOrdItmes.put(COI.id__c,COI);
                    }
                }
                if(!mapCancelOrdItmes.isEmpty())
                {
                    database.update(mapCancelOrdItmes.values(),false);
                }
            }
            
            //Update the all order items to update refund status and singedin and passnger accounts
            if(!mapOrderItems.isEmpty())
                database.update(mapOrderItems.values(),false);
            
            //Start Update the Signed In User/Primary Contact Customer in Payment Items
            Set<String> setPaymentOrderItemIds = new Set<String>();
            list<WFT_GFT_Payment__c> listWFTGFTPayments = new list<WFT_GFT_Payment__c>();
            if(mapObjNametoRcvdIds.containsKey('PaymentItems'))
            {
                Map<string,Payment_Items__c> mapPaymentItemsUpdate = new Map<string,Payment_Items__c>();
                setPaymentOrderItemIds.addAll(mapObjNametoRcvdIds.get('PaymentItems'));
                for(Payment_Items__c PS: [select id, id__c, Payment_Session_Name__c,Customer_Name__c,Primary_Contact_Customer__c,Order_Item_Name__c, Payment_Session_ID__c,Settlement_Time__c, Creation_Time__c,Updated_Time__c, Order_ID__c, Order_Name__c from Payment_Items__c where Id__c IN:setPaymentOrderItemIds])
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
                    
                    WFT_GFT_Payment__c wftGftPayment = new WFT_GFT_Payment__c();
                    wftGftPayment.ID__c = PS.id__c;
                    wftGftPayment.Payment_Items_Name__r = new Payment_Items__c(id__c=PS.id__c);
                    listWFTGFTPayments.add(wftGftPayment);
                    
                    mapPaymentItemsUpdate.put(PS.id__c,PS);
                }
                
                if(!listWFTGFTPayments.isEmpty())
                    Database.upsert(listWFTGFTPayments,WFT_GFT_Payment__c.ID__c,false);
                
                if(!mapPaymentItemsUpdate.isEmpty())
                    database.update(mapPaymentItemsUpdate.values(),false);
            }
            
            dbl.Linking_Process_Status__c = 'Completed';
            dbl.Linking_Process_Complete_Time__c = system.now();
            database.update(dbl,false);
            
        }
        catch(exception e)
        {
            dbl.Linking_Process_Status__c = 'Failed';
            dbl.Linking_Process_Complete_Time__c = system.now();
            dbl.Linking_Process_Error_Description__c = string.valueof(e);
            database.update(dbl,false);
            
        } 
    }
    
    public class RedisPushRequest
    {
        public List<string> listOrdIds { get; set; }
        public string dbNum { get; set; }
        public string region { get; set; }
    }
    
    public class SignedInUserRequest
    {
        public integer UserId { get; set; }
        public integer UMSUserId { get; set; }
        public string PEmail { get; set; }
        public string PMobile { get; set; }
        public string Password { get; set; }
        public string Dob { get; set; }
        public string DisplayName { get; set; }
        public integer Gender { get; set; }
        public boolean IsEmailVerified { get; set; }
        public boolean IsMobileVerified { get; set; }
        public boolean PasswordExists { get; set; }
        public boolean IsWalletEnabled { get; set; }
        public string WalletId { get; set; }
        public string CountryCode { get; set; }
        public integer PhoneCode { get; set; }
        public string PreferredCurrency { get; set; }
        
    }
    
}