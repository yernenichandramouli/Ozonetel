trigger caseLinkTocZentrixInfo on Case (after insert,After Update) 
{
    list<string> TripIds = new list<string>();
    list<string> accids = new list<string>();
    list<string> owids = new list<string>();
    for(case cs: system.trigger.new)
    {
        if(!string.isBlank(cs.Transaction_ID__c))
        {
            TripIds.add(cs.Transaction_ID__c);
        }
        if(cs.lastmodifiedbyid==userinfo.getUserId())
        {
            owids.add(cs.lastmodifiedbyid);
            if(!string.isBlank(string.valueof(cs.Accountid)))
            {
                accids.add(cs.Accountid);
            }
            if(!string.isBlank(string.valueof(cs.Customer_Name__c)))
            {
                accids.add(cs.Customer_Name__c);
            }
        }
    }
    system.debug('-------------owids------------------------'+owids);
    system.debug('-------------accids------------------------'+accids);
    date todayinfo = system.today();
    system.debug('-------------todayinfo------------------------'+todayinfo);
    list<CZentrix_Info__c> Czentrix = new list<CZentrix_Info__c>();
    //for(CZentrix_Info__c cz: [select id, Account_Name__c, ownerid, Case__c from CZentrix_Info__c where Account_Name__c IN: accids and ownerid IN: owids and createddate=:system.today() and Linked__c=:false order by createddate ])
    for(CZentrix_Info__c cz: [select id, Account_Name__c, ownerid, Case__c, createddate from CZentrix_Info__c where ownerid IN: owids and Linked__c=:false and createddate = TODAY  order by createddate ])
    {
        for(case cs: system.trigger.new)
        {
            system.debug('-------------cz.ownerid------------------------'+cz.ownerid);
            system.debug('-------------cs.lastmodifiedbyid------------------------'+cs.lastmodifiedbyid);
            system.debug('-------------cz.Account_Name__c------------------------'+cz.Account_Name__c);
            system.debug('-------------cs.Accountid------------------------'+cs.Accountid);
            system.debug('-------------cs.Customer_Name__c------------------------'+cs.Customer_Name__c);
            system.debug('-------------cz.createddate------------------------'+cz.createddate);
            system.debug('-------------cs.today------------------------'+cs.lastmodifieddate);
            if(cz.ownerid==cs.lastmodifiedbyid)
            {
                system.debug('-------------cs.id------------------------'+cs.id);
                cz.Case__c = cs.id;
                
                if(cs.Accountid!=Null)
                {
                    cz.Account_Name__c = cs.Accountid;
                }
                else if(cs.Customer_Name__c!=Null)
                {
                    cz.Account_Name__c = cs.Customer_Name__c;
                }
                Czentrix.add(cz);
            }
        }
    }
    if(!Czentrix.isEmpty())
    {
        update Czentrix;
    }
    /*
    if(trigger.isInsert)
    {
        if(!TripIds.isEmpty() && StaticBooleans.CreateCase)
        {
           PaymentStatusUpdate.PaymentStatus(TripIds);        
        }
    }
    */
}