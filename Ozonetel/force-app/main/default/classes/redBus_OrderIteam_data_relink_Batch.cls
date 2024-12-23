global class redBus_OrderIteam_data_relink_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts
{ 
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        List<DataProcessStages__c> DataStages = DataProcessStages__c.getall().values();
        list<string> BookingStatus = new list<string>();
        Map<String,DataReLinkInterval__c> mapintvl = DataReLinkInterval__c.getAll();
         //integer interval = integer.valueof(system.Label.Data_Re_link_time_interval);
         //integer EndInterval = integer.valueof(system.Label.Data_Re_link_Endtime_interval);
         integer interval = integer.valueof(mapintvl.get('Interval').Start_Time__c);
         integer EndInterval = integer.valueof(mapintvl.get('Interval').End_Time__c);
         
        for(DataProcessStages__c oi: DataStages)
        {
            BookingStatus.add(oi.Status_Name__c);
        }
        return Database.getQueryLocator([select id,status__c,Date_Of_Service__c, id__c,Seat_No__c, mobile__c,Service_Provider_Id__c,Service_Provider_Name__c,Refund_Status__c, Boarding_Point__c, Boarding_Time__c, Bus_Type__c, Destination__c, Dropping_Point__c, Source__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c,Order_Id__c, Business_Unit__c,Case_Creation_Time__c from Order_Items__c where (status__c IN:BookingStatus OR Date_Of_Service__c=TODAY) and Linked__c=:false and Case_Creation_Time__c>=:interval and Case_Creation_Time__c<=: EndInterval]);
    }
    global void execute(Database.BatchableContext BC, list<Order_Items__c> orItemData)
    {
            list<string> orderIds =new list<string>();
            list<string> orderItemIds = new list<string>();
            list<string> OrderItemPhone = new list<string>();
            list<string> userIds = new list<string>();
            for(Order_Items__c orIt: orItemData)
            {
                orderIds.add(orIt.Order_Id__c);
                orderItemIds.add(orIt.Id__c);
                if(!string.isBlank(string.valueof(orIt.mobile__c)))
                {
                    OrderItemPhone.add(orIt.mobile__c);
                }
                
            }
            set<string> customerIds = new set<string>();
            set<string> primaryEmails = new set<string>();
            set<string> custPhoneNumbers = new set<string>();
            list<account> acc = new list<account>();
            for(Orders__c ors: [select id, id__c,Cust_Details__c, User_Id__c,Customer_Name__c,Primary_Contact_Customer__c,Business_Unit__c from Orders__c where id__c IN: orderIds])
            {
                if(!string.isBlank(ors.User_Id__c) && ors.User_Id__c!='0')
                {
                    userIds.add(ors.User_Id__c);
                }
                if(!string.isBlank(ors.User_Id__c) && string.isBlank(ors.Customer_Name__c))
                {
                    if(!string.isBlank(ors.Cust_Details__c))
                    {
                               // ord.Cust_Details__c = string.valueof(ors.Cust_Details__c);
                               // if(!string.isBlank(string.valueof(ord.ID__c)) && orderitemOrdersMap.KeySet().Contains(ord.ID__c))
                                {
                                    string custDetails = string.valueof(ors.Cust_Details__c);
                                    map<string,object> custDetailsInfo = (map<string,object>)JSON.deserializeUntyped(custDetails);
                                    if(custDetailsInfo.KeySet().contains('UserId') && !string.isBlank(string.valueof(custDetailsInfo.get('UserId'))) && custDetailsInfo.get('UserId')!=0)
                                    {
                                         account cust = new account();
                                        //system.debug('------------ord.ID__c---------------------'+ord.ID__c);
                                        if(custDetailsInfo.get('UserId')!=0)
                                        {
                                            cust.User_Id__c = string.valueof(custDetailsInfo.get('UserId'));
                                            //ord.User_Id__c = cust.User_Id__c;
                                            customerIds.add(string.valueof(custDetailsInfo.get('UserId')));
                                        }
                                            //OrdersCustomerMap.put(cust.User_Id__c,string.valueof(order.get('id')));
                                        if(custDetailsInfo.KeySet().contains('PEmail') && !string.isBlank(string.valueof(custDetailsInfo.get('PEmail'))))
                                        {
                                            if(string.valueof(custDetailsInfo.get('PEmail')).length()<255)
                                            {
                                                cust.Email_Copy__c = string.valueof(custDetailsInfo.get('PEmail'));
                                            }
                                            else
                                            {
                                                cust.Email_Copy__c = string.valueof(custDetailsInfo.get('PEmail')).substring(0,255);
                                            }
                                            
                                            if(validateEmail(string.valueof(custDetailsInfo.get('PEmail')))==true)
                                            {
                                                 cust.PersonEmail = string.valueof(custDetailsInfo.get('PEmail'));
                                                 primaryEmails.add(string.valueof(custDetailsInfo.get('PEmail')));
                                            }
                                        }
                                        if(custDetailsInfo.KeySet().contains('PMobile') && !string.isBlank(string.valueof(custDetailsInfo.get('PMobile'))))
                                        {
                                            cust.PersonMobilePhone = string.valueof(custDetailsInfo.get('PMobile'));
                                            custPhoneNumbers.add(cust.PersonMobilePhone);
                                        }
                                      /*  if(custDetailsInfo.KeySet().contains('Dob') && !string.isBlank(string.valueof(custDetailsInfo.get('Dob'))))
                                        {
                                            cust.Birthdate__c = datetime.valueof(string.valueof(custDetailsInfo.get('Dob')));
                                        } */
                                        if(custDetailsInfo.KeySet().contains('DisplayName') && !string.isBlank(string.valueof(custDetailsInfo.get('DisplayName'))))
                                        {
                                            cust.LastName = string.valueof(custDetailsInfo.get('DisplayName'));
                                        }
                                        else
                                        if(custDetailsInfo.KeySet().contains('PMobile') && !string.isBlank(string.valueof(custDetailsInfo.get('PMobile'))))
                                        {
                                            cust.LastName = string.valueof(custDetailsInfo.get('PMobile'));
                                        }
                                        else
                                        {
                                            cust.LastName = 'N/A';
                                        }
                                        if(custDetailsInfo.KeySet().contains('Gender') && !string.isBlank(string.valueof(custDetailsInfo.get('Gender'))))
                                        {
                                            cust.Gender__c = string.valueof(custDetailsInfo.get('Gender'));
                                        }
                                        if(custDetailsInfo.KeySet().contains('IsEmailVerified') && !string.isBlank(string.valueof(custDetailsInfo.get('IsEmailVerified'))))
                                        {
                                            cust.IsEmailIdVerified__c = boolean.valueof(custDetailsInfo.get('IsEmailVerified'));
                                        }
                                        if(custDetailsInfo.KeySet().contains('IsMobileVerified') && !string.isBlank(string.valueof(custDetailsInfo.get('IsMobileVerified'))))
                                        {
                                            cust.IsMobileVerified__c = boolean.valueof(custDetailsInfo.get('IsMobileVerified'));
                                        }
                                        if(custDetailsInfo.KeySet().contains('PasswordExists') && !string.isBlank(string.valueof(custDetailsInfo.get('PasswordExists'))))
                                        {
                                            cust.PasswordExists__c = boolean.valueof(custDetailsInfo.get('PasswordExists'));
                                        }
                                        if(custDetailsInfo.KeySet().contains('isWalletEnabled') && !string.isBlank(string.valueof(custDetailsInfo.get('isWalletEnabled'))))
                                        {
                                            cust.isWalletEnabled__c = boolean.valueof(custDetailsInfo.get('isWalletEnabled'));
                                        }
                                        if(custDetailsInfo.KeySet().contains('WalletId') && !string.isBlank(string.valueof(custDetailsInfo.get('WalletId'))))
                                        {
                                            cust.WalletId__c = string.valueof(custDetailsInfo.get('WalletId'));
                                        }
                                        if(custDetailsInfo.KeySet().contains('CountryCode') && !string.isBlank(string.valueof(custDetailsInfo.get('CountryCode'))))
                                        {
                                            cust.CountryCode__c = string.valueof(custDetailsInfo.get('CountryCode'));
                                        }
                                        if(custDetailsInfo.KeySet().contains('PhoneCode') && !string.isBlank(string.valueof(custDetailsInfo.get('PhoneCode'))))
                                        {
                                            cust.PhoneCode__c = string.valueof(custDetailsInfo.get('PhoneCode'));
                                        }
                                        if(custDetailsInfo.KeySet().contains('PreferredCurrency') && !string.isBlank(string.valueof(custDetailsInfo.get('PreferredCurrency'))))
                                        {
                                            cust.PreferredCurrency__c = string.valueof(custDetailsInfo.get('PreferredCurrency'));
                                        }
                                        cust.UpdatedOn__c = system.now();
                                        acc.add(cust);
                                    }
                                }
                    }
                }
            }
            
            list<contact> contacts = new list<contact>();
            set<string> accountids = new set<string>();
            map<string,account> updateCustomer = new map<string,account>();
            map<string,account> newCustomer = new map<string,account>();
            map<string,account> exCustomerDetails = new map<string,account>();
            map<string,account> exCustomerPhoneDetails = new map<string,account>();
            map<string,contact> exContacts = new map<string,contact>();
            list<contact> newContact = new list<contact>();
            if(!customerIds.isEmpty() || !custPhoneNumbers.isEmpty())
            {
                for(account ac:  [select id,PersonMobilePhone, User_Id__c, PersonEmail,Parent_Account__c from account where User_Id__c IN: customerIds OR PersonMobilePhone IN: custPhoneNumbers ])
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
                    contacts = [select id, name, email, Account_name__c from contact where Account_name__c IN: accountids and email IN: primaryEmails ];
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
                        if(exCustomerDetails.get(ac.User_Id__c).PersonMobilePhone!=ac.PersonMobilePhone)
                        {
                            account newAcc = new account();
                            newAcc.lastName = ac.lastname;
                            newAcc.PersonMobilePhone = exCustomerDetails.get(ac.User_Id__c).PersonMobilePhone;
                            newAcc.Parent_Account__c = ac.id;
                            newCustomer.put(string.valueof(newAcc.PersonMobilePhone),newAcc);
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
                                cc.email = exCustomerPhoneDetails.get(ac.PersonMobilePhone).PersonEmail;
                                cc.Account_name__c = ac.id;
                                newContact.add(cc);
                            }
                        }
                        updateCustomer.put(ac.id,ac);
                    }
                    else
                    {
                        newCustomer.put(string.valueof(ac.user_id__c),ac);
                    }
                }
                if(!updateCustomer.isEmpty())
                {
                    //update updateCustomer.values();
                    database.update(updateCustomer.values(),false);
                }
                if(!newCustomer.isEmpty())
                {
                    //insert newCustomer.values();
                    database.insert(newCustomer.values(),false);
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
            
            map<string,string> customerName = new map<string,string>();
            map<string,account> primaryCustomerName = new map<string,account>();
            for(account ac:  [select id,PersonMobilePhone,User_Id__c,Parent_Account__c from account where (User_Id__c IN: userIds)])
            {
                if(!string.isBlank(ac.User_Id__c))
                {
                    customerName.put(ac.User_Id__c,ac.id);
                }
            }
            for(account ac:  [select id,PersonMobilePhone,User_Id__c,Parent_Account__c from account where (PersonMobilePhone IN: OrderItemPhone)])
            {
                    
                if(!string.isBlank(string.valueof(ac.PersonMobilePhone)))
                {
                    primaryCustomerName.put(ac.PersonMobilePhone,ac);
                }
                
            }
            map<string,Orders__c> mapOrders = new map<string,Orders__c>();
            map<string,Orders__c> mapOrdersUpdate = new map<string,Orders__c>();
            for(Orders__c ors: [select id, id__c,User_Id__c,Customer_Name__c,Primary_Contact_Customer__c,Business_Unit__c from Orders__c where id__c IN: orderIds])
            {
                if(!string.isBlank(ors.User_Id__c) )
                {
                    if(customerName.KeySet().Contains(ors.User_Id__c))
                    {
                        ors.Customer_Name__c = customerName.get(ors.User_Id__c);
                        //mapOrdersUpdate.put(ors.id__c,ors);
                    }
                }
                mapOrders.put(ors.id__c,ors);
            }
            map<string,Order_Items__c> mapOrderItems = new map<string,Order_Items__c>();
            for(Order_Items__c orItem: [select id, id__c,Seat_No__c, mobile__c,Service_Provider_Id__c,Service_Provider_Name__c,Refund_Status__c, Boarding_Point__c, Boarding_Time__c, Bus_Type__c, Destination__c, Dropping_Point__c, Source__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c,Order_Id__c, Business_Unit__c from Order_Items__c where (id__c IN: orderItemIds)])
            {
                if(!string.isBlank(string.valueof(orItem.mobile__c)))
                {
                    if(primaryCustomerName.KeySet().Contains(orItem.Mobile__c))
                    {
                        system.debug('------------process 1-------------');
                        if(!string.isBlank(string.valueof(primaryCustomerName.get(orItem.Mobile__c).User_Id__c)))
                        {
                            system.debug('------------process 2-------------');
                            if(!string.isBlank(string.valueof(orItem.Order_Id__c)) && mapOrders.KeySet().contains(orItem.Order_Id__c) && !string.isBlank(string.valueof(mapOrders.get(orItem.Order_Id__c).Customer_Name__c)) && mapOrders.get(orItem.Order_Id__c).Customer_Name__c != primaryCustomerName.get(orItem.Mobile__c).id)
                            {
                                system.debug('------------process 3-------------');
                                orItem.Primary_Contact_Customer__c = primaryCustomerName.get(orItem.Mobile__c).id;
                            }
                            else
                            {
                                system.debug('------------process 4-------------');
                                orItem.Customer_Name__c = primaryCustomerName.get(orItem.Mobile__c).id;
                            }
                        }
                        else
                        {
                            system.debug('------------process 5-------------');
                            orItem.Primary_Contact_Customer__c = primaryCustomerName.get(orItem.Mobile__c).id;
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
                if(primaryCustomerName.KeySet().Contains(orItem.Mobile__c))
                {
                    if(!string.isBlank(string.valueof(orItem.Customer_Name__c)) && orItem.Customer_Name__c != primaryCustomerName.get(orItem.Mobile__c).id )
                    {
                        if(string.isBlank(string.valueof(primaryCustomerName.get(orItem.Mobile__c).Parent_Account__c)))
                        {
                            primaryCustomerName.get(orItem.mobile__c).Parent_Account__c = orItem.Customer_Name__c;
                        }
                    }
                }
                mapOrderItems.put(orItem.id__c,orItem);
             }
            
            Map<string,Order_Item_Fare_Component__c> MapOIFCEx = new Map<string,Order_Item_Fare_Component__c>();
            for(Order_Item_Fare_Component__c OIFC: [select id,id__c,Creation_Time__c,Updated_Time__c, Item_ID__c,Order_ID__c, Order_Item_Name__c, Order_Name__c, createdDate from Order_Item_Fare_Component__c where Item_ID__c IN: orderItemIds])
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
            
            Map<string,Bus_Order_Item_Details__c> MapBOIDEx = new Map<string,Bus_Order_Item_Details__c>();
            For(Bus_Order_Item_Details__c BOID: [select id, id__c,Dropping_Point__c,Source_City__c,Destination_City__c,Bus_Type_Details__c,Source_Location__c,Dropping_Point_Location__c,Boarding_Point_Location__c, Seat_No__c,Boarding_Point_ID__c,dropping_point_id__c,Source_ID__c,Bus_Type__c,Order_Item_Name__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c, Boarding_Time__c, Primary_Boarding_Time__c,Boarding_Point__c from Bus_Order_Item_Details__c where Id__c IN: orderItemIds ])
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
            Map<string,Traveller_Info__c> MapTIEx = new Map<string,Traveller_Info__c>();
            For(Traveller_Info__c TI: [select id, id__c,Bus_Order_Item_Details__c,Creation_Time__c,Updated_Time__c, DateOfBirth__c, Order_Item_Name__c, Order_Name__c, Customer_Name__c, Primary_Contact_Customer__c, Bus_Order_Item_Details_Id__c from Traveller_Info__c where Bus_Order_Item_Details_Id__c IN: orderItemIds])
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
            
            Map<string,Refund_Order_Items__c> MapROIEx = new Map<string,Refund_Order_Items__c>();
            For(Refund_Order_Items__c ROI: [select id, id__c,Customer_Name_account__c,Status__c, Creation_Time__c,Updated_Time__c, Payment_Item_ID__c, Payment_Item_Name__c, Order_Item_Name__c, Customer_Name__c, Primary_Contact_Customer__c, Order_Item_ID__c from Refund_Order_Items__c where (Order_Item_ID__c IN: orderItemIds )])
            {
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
            
            Map<string,Cancelled_Order_Items__c> MapCOIEx = new Map<string,Cancelled_Order_Items__c>();
            For(Cancelled_Order_Items__c COI: [select id, id__c,Order_ID__c,Order_Name__c, Creation_Time__c,Updated_Time__c,Cancellation_Time__c, Date_Of_Purchase__c, Order_Item_Name__c, Customer_Name__c, Primary_Contact_Customer__c, Order_Item_ID__c from Cancelled_Order_Items__c where Order_Item_ID__c IN: orderItemIds])
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
            if(!mapOrders.isEmpty())
            {
                database.update(mapOrders.values(),false);
            }
            if(!mapOrderItems.isEmpty())
            {
                database.update(mapOrderItems.values(),false);
            }
            if(!primaryCustomerName.isEmpty())
            {
                database.update(primaryCustomerName.values(),false);
            }
    }
    global static Boolean validateEmail(String email) 
    {
        Boolean res = true;
    
        //String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    } 
    global void finish(Database.BatchableContext BC)
    {
       redBus_data_relink_Batch  batchJob = new redBus_data_relink_Batch();
       Database.executeBatch(batchJob);
    }
}