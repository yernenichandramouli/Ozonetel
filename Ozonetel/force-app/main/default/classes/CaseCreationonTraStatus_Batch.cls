global class CaseCreationonTraStatus_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts
{ 
    Set<String> wftbsunits = new Set<String>();
    Set<String> gftbsunits = new Set<String>();
    Map<String,RecTypesAndStatus__c> mpcus = new Map<String,RecTypesAndStatus__c>();
    Set<String> mapwftgft = new Set<String>();
    
    public CaseCreationonTraStatus_Batch()
    {
        for(WFT_GFT_Business_Units__c bs: WFT_GFT_Business_Units__c.getAll().Values())
        {
            if(bs.Create_WFT__c)
                  wftbsunits.add(bs.Name);         
            if(bs.Create_GFT__c)
                  gftbsunits.add(bs.Name);
                  
            if(bs.Account_DOJ_Check__c)
                  mapwftgft.add(bs.Name);
           
        }
        
        for(RecTypesAndStatus__c r: RecTypesAndStatus__c.getAll().Values())
        {
            mpcus.put(r.Transaction_Status__c,r);
        }
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Map<String,Case_Creation_Interval__c> mapintvl = Case_Creation_Interval__c.getAll();
        Set<String> wftbsunits = new Set<String>();
        Set<String> gftbsunits = new Set<String>();
        Integer a =Integer.Valueof(mapintvl.get('Interval').Start_time__c);
        Integer b =Integer.Valueof(mapintvl.get('Interval').End_time__c);
        list<String> busnUnitLst= new list<String>();
        busnUnitLst.addAll(System.Label.Business_Unit.split(','));
        
        return Database.getQueryLocator([select id,Name,Date_Of_Journey__c,Transaction_Name__c,Status__c,Transaction_Name__r.Customer_Name__r.Name,Business_Unit__c,Transaction_Latest_status__c,
                                                Already_Processed__c,Transaction_Status_WFT_GFT__c,Primary_Contact_Customer__c,Customer_Name__c,Case_creation_time__c,
                                                Transaction_Name__r.Transaction_Status__c,Transaction_Name__r.Order_Item_Reference_No__c,Transaction_Name__r.Service_Provider_Reference_PNR_No__c FROM WFT_GFT__c 
                                                where Transaction_Name__c!=Null AND Date_Of_Journey__c!=NULL AND Case_creation_time__c>=:a AND Case_creation_time__c <:b AND Business_Unit__c!=Null AND Business_Unit__c NOT IN:busnUnitLst AND
                                                Already_Processed__c=False AND ((Transaction_Status_WFT_GFT__c = 'WFT') OR (Transaction_Status_WFT_GFT__c='GFT') OR (Transaction_Name__r.Transaction_Status__c='Booked' AND (Transaction_Name__r.Order_Item_Reference_No__c=Null OR Transaction_Name__r.Service_Provider_Reference_PNR_No__c=Null)))]);
    }
    
    global void execute(Database.BatchableContext BC, list<WFT_GFT__c> listOI)
    {
        
        Set<String> Transids = new Set<String>();
        Set<string> tripids = new Set<string>();
        Set<string> trids = new Set<string>();
        Map<String,WFT_GFT__c> maptrans = new Map<String,WFT_GFT__c>();
        Set<id> transaids = new Set<id>();
        Map<id,WFT_GFT__c> tmapwgids = new Map<id,WFT_GFT__c>();
        List<WFT_GFT__c> liswfgf = new List<WFT_GFT__c>();      
        
        Map<String,Case> caselst = new Map<String,Case>();
        List<WFT_GFT__c> listup = new List<WFT_GFT__c>();
        Set<String> cusids = new Set<String>();
        Map<String,List<Order_Items__c>> mapoitms = new Map<String,List<Order_Items__c>>();
        Map<String,Case> CaseMaP = new Map<String,Case>();
        Map<String,Case> Mapcasesins = new Map<String,Case>();
        
        for(WFT_GFT__c o: listOI)
        {
            if(String.isNotBlank(o.Business_Unit__c) && gftbsunits.contains('REDBUS_'+o.Business_Unit__c.right(2)))
            {
                tripids.add(String.valueOf(o.Transaction_Name__c).substring(0, 15));
                maptrans.put(String.valueOf(o.Transaction_Name__c).substring(0, 15),o);
                if((o.Transaction_Status_WFT_GFT__c == 'WFT' || o.Transaction_Status_WFT_GFT__c == 'GFT') && o.Transaction_Latest_status__c == null)
                {
                    trids.add(String.valueOf(o.Transaction_Name__c).substring(0, 15));
                    liswfgf.add(o);
                }
                
                if(o.Customer_Name__c!=Null)
                {
                    String cusid = String.valueOf(o.Customer_Name__c).substring(0, 15);
                    cusids.add(cusid);
                }
                if(o.Primary_Contact_Customer__c!=Null)
                {
                    String cusid = String.valueOf(o.Primary_Contact_Customer__c).substring(0, 15);
                    cusids.add(cusid);
                }
            }
        }
        
        PaymentStatusUpdonCasecrt.PaymentStatus(trids,liswfgf);
         
        for(case cs : [Select id, Transaction_ID__c,RecordType.Name FROM Case where Transaction_ID__c IN: tripids AND (RecordType.Name='White Failed Transaction (WFT)' OR RecordType.Name='Green Failed Transaction (GFT)')])
        {
            String tripid = String.valueOf(cs.Transaction_ID__c).substring(0, 15);
            CaseMaP.put(tripid ,cs);
        }
        
        for(Order_Items__c o:[Select id,Name,Customer_Name__c,Primary_Contact_Customer__c  FROM Order_Items__c WHERE Customer_Name__c IN: cusids OR Primary_Contact_Customer__c IN: cusids])
        {
            if(o.Customer_Name__c!=null)
            {
                String cusid = String.valueOf(o.Customer_Name__c).substring(0, 15);
                if(!mapoitms.containskey(cusid))
                {
                    List<Order_Items__c> innerlist = new List<Order_Items__c>();
                    innerlist.add(o);
                    mapoitms.put(cusid,innerlist);
                }
                else
                {
                    mapoitms.get(cusid).add(o);
                }
            }
            if(o.Primary_Contact_Customer__c!=null)
            {
                String priid = String.valueOf(o.Primary_Contact_Customer__c).substring(0, 15);
                if(!mapoitms.containskey(priid))
                {
                    List<Order_Items__c> innerlist = new List<Order_Items__c>();
                    innerlist.add(o);
                    mapoitms.put(priid,innerlist);
                }
                else
                {
                    mapoitms.get(priid).add(o);
                }
            }
        }
        
        System.debug('------mapoitms---------'+mapoitms);
        System.debug('------CaseMap---------'+CaseMap);
        for(WFT_GFT__c o: [SELECT id,Name,Date_Of_Journey__c,Transaction_Name__c,Status__c,Transaction_Name__r.Transaction_Status__c,Transaction_Name__r.Customer_Name__r.Name,Business_Unit__c,Transaction_Latest_Status__c,
                            Already_Processed__c,Transaction_Name__r.Order_Item_Reference_No__c,Transaction_Name__r.Service_Provider_Reference_PNR_No__c,Transaction_Status_WFT_GFT__c,Primary_Contact_Customer__c,Customer_Name__c,Case_creation_time__c from WFT_GFT__c 
                            WHERE Transaction_Name__c IN: tripids])
        {
            system.debug('-------Each Transaction------'+o); 
            String tripid = String.valueOf(o.Transaction_Name__c).substring(0, 15);       
            if(!CaseMaP.Keyset().Contains(tripid))
            {
                system.debug('-----1-----');
                if(!String.IsBlank(o.status__c) && mpcus.containsKey(o.status__c))
                {
                    system.debug('-----2-----');
                    if(mpcus.get(o.status__c).Case_Type__c=='White Failed Transaction (WFT)')
                    {
                        system.debug('-----3-----');
                        if(o.Transaction_Latest_Status__c == 'FAIL')
                        {
                            system.debug('-----4-----');
                            if(mapwftgft.contains(o.Business_Unit__c))
                            {
                                system.debug('-----5-----');
                                if(o.Date_Of_Journey__c==system.today())
                                {
                                    system.debug('-----6-----');
                                    if(o.Primary_Contact_Customer__c!=Null && o.Customer_Name__c!=null)
                                    {
                                        system.debug('-----1st Criteria: 1-----');
                                        if(o.Transaction_Name__r.Customer_Name__r.Name!='N/A')
                                        {
                                            system.debug('-----1st Criteria: 2-----');
                                            if(mapoitms.containskey(o.Customer_Name__c) && mapoitms.containskey(o.Primary_Contact_Customer__c))
                                            {
                                                system.debug('-----1st Criteria: 3-----');
                                                if(mapoitms.get(o.Customer_Name__c).size()==1 && mapoitms.get(o.Primary_Contact_Customer__c).size()==1)
                                                {
                                                    system.debug('-----1st Criteria: 4-----');
                                                    if(mapoitms.get(o.Customer_Name__c)[0].id==o.Transaction_Name__c && mapoitms.get(o.Primary_Contact_Customer__c)[0].id==o.Transaction_Name__c)
                                                    {
                                                        system.debug('-----1st Criteria: 5-----');
                                                        Case c=new Case();
                                                        c.Transaction_ID__c=o.Transaction_Name__c;
                                                        c.AccountId=o.Primary_Contact_Customer__c;
                                                        c.Customer_Name__c=o.Customer_Name__c;
                                                        c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                        Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(mpcus.get(o.status__c).Case_Type__c).getRecordTypeId();
                                                        c.RecordTypeId=recordTypeId;
                                                        caselst.put(c.Transaction_ID__c,c);
                                                        o.Already_Processed__c = TRUE; 
                                                        listup.add(o);           
                                                    }
                                                }
                                            }
                                        }
                                        if(o.Primary_Contact_Customer__c!=Null && o.Transaction_Name__r.Customer_Name__r.Name=='N/A')
                                        {
                                            system.debug('-----2nd Criteria: 1------');
                                            if(mapoitms.containskey(o.Primary_Contact_Customer__c))
                                            {
                                                system.debug('-----2nd Criteria: 2------');
                                                if(mapoitms.get(o.Primary_Contact_Customer__c).size()==1)
                                                {
                                                    system.debug('-----2nd Criteria: 3------');
                                                    if(mapoitms.get(o.Primary_Contact_Customer__c)[0].id==o.Transaction_Name__c)
                                                    {
                                                        system.debug('-----2nd Criteria: 4------');
                                                        Case c=new Case();
                                                        c.Transaction_ID__c=o.Transaction_Name__c;
                                                        c.AccountId=o.Primary_Contact_Customer__c;
                                                        c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                        Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(mpcus.get(o.status__c).Case_Type__c).getRecordTypeId();
                                                        c.RecordTypeId=recordTypeId;
                                                        caselst.put(c.Transaction_ID__c,c);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else if(o.Primary_Contact_Customer__c==Null && o.Customer_Name__c!=null)
                                    {
                                        system.debug('-----3rd Criteria: 1------');
                                        if(mapoitms.containskey(o.Customer_Name__c))
                                        {
                                            system.debug('-----3rd Criteria: 2------');
                                            if(mapoitms.get(o.Customer_Name__c).size()==1)
                                            {
                                                system.debug('-----3rd Criteria: 3------');
                                                if(mapoitms.get(o.Customer_Name__c)[0].id==o.Transaction_Name__c)
                                                {
                                                    system.debug('-----3rd Criteria: 4------');
                                                    Case c=new Case();
                                                    c.Transaction_ID__c=o.Transaction_Name__c;
                                                    c.Customer_Name__c=o.Customer_Name__c;
                                                    c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                    Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(mpcus.get(o.status__c).Case_Type__c).getRecordTypeId();
                                                    system.debug('@@@@=====>>>>>>'+recordTypeId);
                                                    c.RecordTypeId=recordTypeId;
                                                    caselst.put(c.Transaction_ID__c,c);
                                                }
                                            }
                                        }
                                    }
                                    else if(o.Primary_Contact_Customer__c!=Null && o.Customer_Name__c==null)
                                    {
                                        system.debug('-----4th Criteria: 1------');
                                        if(mapoitms.containskey(o.Primary_Contact_Customer__c))
                                        {
                                            system.debug('-----4th Criteria: 2------');
                                            if(mapoitms.get(o.Primary_Contact_Customer__c).size()==1)
                                            {
                                                system.debug('-----4th Criteria: 3------');
                                                if(mapoitms.get(o.Primary_Contact_Customer__c)[0].id==o.Transaction_Name__c)
                                                {
                                                    system.debug('-----4th Criteria: 4------');
                                                    system.debug('3rd criteriacase'+o);
                                                    Case c=new Case();
                                                    c.Transaction_ID__c=o.Transaction_Name__c;
                                                    c.AccountId=o.Primary_Contact_Customer__c;
                                                    c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                    Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(mpcus.get(o.status__c).Case_Type__c).getRecordTypeId();
                                                    c.RecordTypeId=recordTypeId;
                                                    caselst.put(c.Transaction_ID__c,c);
                                                }
                                            }
                                        }
                                    }
        
                                }
                            }
                            else
                            {
                                system.debug('-----5th Criteria: 1------');
                                Case c=new Case();
                                c.Transaction_ID__c=o.Transaction_Name__c;
                                c.AccountId=o.Primary_Contact_Customer__c;
                                c.Customer_Name__c=o.Customer_Name__c;
                                c.Origin = System.Label.WFT_GFT_Case_Origin;
                                Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(mpcus.get(o.status__c).Case_Type__c).getRecordTypeId();
                                c.RecordTypeId=recordTypeId;
                                caselst.put(c.Transaction_ID__c,c);
                            }
                        }
                        else if(o.Transaction_Latest_Status__c == 'SUCCESS')
                        {
                            system.debug('-----6th Criteria: 1------');
                            Case c=new Case();
                            c.Transaction_ID__c=o.Transaction_Name__c;
                            c.AccountId=o.Primary_Contact_Customer__c;
                            c.Customer_Name__c=o.Customer_Name__c;
                            c.Origin = System.Label.WFT_GFT_Case_Origin;
                            Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();
                            c.RecordTypeId=recordTypeId;
                            caselst.put(c.Transaction_ID__c,c);
                        }
                    }
                    else if(mpcus.get(o.status__c).Case_Type__c=='Green Failed Transaction (GFT)')
                    {
                        system.debug('-----7th Criteria: 1------');
                        Case c=new Case();
                        c.Transaction_ID__c=o.Transaction_Name__c;
                        c.AccountId=o.Primary_Contact_Customer__c;
                        c.Customer_Name__c=o.Customer_Name__c;
                        c.Origin = System.Label.WFT_GFT_Case_Origin;
                        Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(mpcus.get(o.status__c).Case_Type__c).getRecordTypeId();
                        c.RecordTypeId=recordTypeId;
                        caselst.put(c.Transaction_ID__c,c);
                    }
                }
                else if(o.Transaction_Name__r.Transaction_Status__c=='Booked' && (o.Transaction_Name__r.Service_Provider_Reference_PNR_No__c == Null || o.Transaction_Name__r.Order_Item_Reference_No__c==Null))
                {
                    system.debug('-----8th Criteria: 1------');
                    Case c=new Case();
                    c.Transaction_ID__c=o.Transaction_Name__c;
                    c.AccountId=o.Primary_Contact_Customer__c;
                    c.Customer_Name__c=o.Customer_Name__c;
                    c.Origin = System.Label.WFT_GFT_Case_Origin;
                    Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();
                    c.RecordTypeId=recordTypeId;
                    caselst.put(c.Transaction_ID__c,c);
                }
            } 
        }
        
        System.debug('-----wftbsunits------'+wftbsunits);
        System.debug('-----gftbsunits------'+gftbsunits);
        
        if(!caselst.isEmpty())
        {
            String wfrecid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
            String gfrecid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();
            for(Case c: caselst.Values())
            {
                String tid = String.valueOf(c.Transaction_Id__c).substring(0, 15);                
                String businessUnitTemp=maptrans.get(tid).Business_Unit__c;
                if(!maptrans.get(tid).Business_Unit__c.contains('REDBUS')){
                   businessUnitTemp='REDBUS'+businessUnitTemp.right(3);
                 }
                if((c.RecordTypeid == wfrecid && maptrans.ContainsKey(tid) && wftbsunits.contains(businessUnitTemp)) || (c.RecordTypeid==gfrecid && maptrans.ContainsKey(tid) && gftbsunits.contains(businessUnitTemp)))
                 {
                    System.debug('------CasesWIthSwitch------');
                    MapCasesins.put(c.Transaction_Id__c,c);
                 }
            }
        }
       
        if(!MapCasesins.Values().isEmpty())
        {
            List<WFT_GFT__c> listwftgft = new List<WFT_GFT__c>();
            List<String> ErrorMsgs = new List<String>();
            Set<String> caseids = new Set<String>();
            System.debug('------MapCasesins.Values()----'+MapCasesins.Values());
            StaticBooleans.CreateCase = False;
            Database.SaveResult[] insertResult = Database.insert(MapCasesins.Values(),false);
            for(Integer i=0;i<insertResult.size();i++)
            {
                if(insertResult.get(i).isSuccess())
                {
                    system.debug('-----success-------'+insertResult.get(i).getId());
                    caseids.add(insertResult.get(i).getId());
                }
                else
                {
                    system.debug('----fail--'+string.valueof(insertResult.get(i).getErrors()));
                    ErrorMsgs.add(String.Valueof(insertResult.get(i).getErrors()));
                }
            }
            if(!ErrorMsgs.isEmpty())
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> toAddresses = new List<String>();
                toAddresses.addAll(Label.Delete_Logs_Mail.split(','));
                mail.setToAddresses(toAddresses);
                mail.setSubject('Cases Errors - WFT/GFT');
                mail.setPlainTextBody(JSON.Serialize(ErrorMsgs));
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            List<Case> lstcases = [SELECT id,Transaction_ID__c FROM Case WHERE id IN:caseids];
            System.debug('-----lstcases-----'+lstcases);
            for(Case c : lstcases)
            {
                System.debug('-----Each Case----'+c);
                transaids.add(c.Transaction_ID__c);
            }
            System.debug('-----transaids----'+transaids);
            List<WFT_GFT__C> wftGFTs = new List<WFT_GFT__C>();
            for(WFT_GFT__C w : [SELECT id,Name,Transaction_Name__c,Already_Processed__c FROM WFT_GFT__c WHERE Transaction_Name__c IN:transaids])
            {
                System.debug('-----Each WFT/GFT-----'+w);
                wftGFTs.add(w);
            }
            for(WFT_GFT__C w : wftGFTs)
            {
                System.debug('-----Each WFT/GFT 1-----'+w);
                if(!tmapwgids.containskey(w.Transaction_Name__c))
                {
                    tmapwgids.put(w.Transaction_Name__c,w);
                }
            }
            System.debug('-----tmapwgids-----'+tmapwgids);
            for(Case c : lstcases)
            {
                System.debug('-----Each Case 1-----'+c);
                if(tmapwgids.containskey(c.Transaction_ID__c))
                {
                    tmapwgids.get(c.Transaction_ID__c).Already_Processed__c = True;
                    listwftgft.add(tmapwgids.get(c.Transaction_ID__c));
                }
            }
           
            if(!listwftgft.isEmpty())
            {   
                update listwftgft;
            }
        }        
    }
    Global void finish(Database.BatchableContext BC)
    {

    }
}