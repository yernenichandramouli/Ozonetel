global class DBTScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        System.abortJob(sc.getTriggerId());
        System.schedule('DBTScheduler '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(Label.DBT_Scheduler_Time)).minute()+' */1 ? * *', this);
        DBTTtrips();
    }
    
    public static void DBTTtrips()
    {
        list<case> caseUpList=new list<case>();
        list<case> cList=new list<case>();
        cList=[select id,trip_id_ct__c,transaction_id__c from case where issue_type__c='DBT' and createddate=today];
        Map<string,case> caseMap=new Map<string,case>();
        for(case c:cList){
            caseMap.put(c.trip_id_ct__c,c);
        }  
        
        list<Payment_Items__c> pList=new list<Payment_Items__c>();
        Map<string,list<Payment_Items__c>> pMap=new Map<string,list<Payment_Items__c>>();
        
        for(Payment_Items__c p:[select id,Order_Name__r.name,Amount_Payable_Value__c,Business_Amount__c,Order_Item_Name__c,Order_Item_Name__r.name,Business_Unit__c from Payment_Items__c where Creation_Time__c=TODAY and Bank_Account_Number__c!='' and Payment_System__c='ONLINE' and Business_Unit__c='REDBUS_ID' order by Creation_Time__c DESC ]){
            
            if(pMap.containsKey(p.Order_Name__r.name )){            
                pMap.get(p.Order_Name__r.name).add(p);            
            }else{            
                pMap.put(p.Order_Name__r.name,new list<Payment_Items__c>{p});            
            }       
        }
        System.debug('pMap-->'+pMap);
        
        list<string> tList=new list<string>();
        set<string> tripSet=new set<string>();
        Map<string,DBT_Bank__mdt> dbMap=new Map<string,DBT_Bank__mdt>();
        for(DBT_Bank__mdt d:[select id,MasterLabel,Bank_Number__c from DBT_Bank__mdt]){
            dbMap.put(d.Bank_Number__c, d);
        }
        
        for(order_items__c oi:[select id,name,Order_Name__c,Order_Name__r.name,Bank_Account_Number__c from order_items__c where Corrected_Date_of_Issue__c=TODAY and  Bank_Account_Number__c!='' and Business_Unit__c='REDBUS_ID' ]){                                 
            System.debug('tripSet-->'+tripSet);
            if(caseMap.get(oi.Order_Name__r.name)==null && !tripSet.contains(oi.Order_Name__r.name)){
                tripSet.add(oi.Order_Name__r.name);
                case c=new case();
                tripSet.add(oi.Order_Name__r.name);
                c.issue_type__c='DBT';
                System.debug('oi-->'+oi.Order_Name__r.name);
                c.trip_id_ct__c=oi.Order_Name__r.name;
                c.origin='Complaint Tracker';
                c.description='DBT Payment';
                c.transaction_id__c=oi.id;
                c.DBTScheduler__c=true;
                c.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('DBT').getRecordTypeId();
                if(dbMap.get(oi.Bank_Account_Number__c)!=null)
                c.Bank_Name__c=dbMap.get(oi.Bank_Account_Number__c).MasterLabel;
                if(pMap!=null && pMap.get(oi.Order_Name__r.name)!=null){
                    c.amountd__c=string.valueof(pMap.get(oi.Order_Name__r.name)[0].Business_Amount__c);  
                    if(c.amountd__c!=null || c.amountd__c!=''){
                    c.amountd__c=c.amountd__c.replaceAll('IDR','');
                    c.amountd__c=c.amountd__c.trim();
                    c.amountd__c=DBTScheduler.amountFormat(c.amountd__c);
                    }
                    }          
                caseUpList.add(c);
                
            }else if(caseMap.get(oi.Order_Name__r.name)!=null && caseMap.get(oi.Order_Name__r.name).transaction_id__c==null && !tripSet.contains(oi.Order_Name__r.name)){
                tripSet.add(oi.Order_Name__r.name);
                case c2=new case();
                c2.id=caseMap.get(oi.Order_Name__r.name).id;
                c2.transaction_id__c=oi.id;           
                caseUpList.add(c2);
            }
        } 
        System.debug('caseUpList-->'+caseUpList);
        if(!caseUpList.isEmpty())
            upsert caseUpList;
        
    }
    
    public static String amountFormat(string amount){
    String data=amount;
   // String data ;
    amount=amount.replaceAll(',','');
    System.debug('amount-->'+amount);
    if(amount.contains('.')){
        data = amount.split('\\.')[0];
    }
    String[] convertStringtochar = data.split('');
    String output = '';
    Integer count = convertStringtochar.size()-3;
    for(Integer i = convertStringtochar.size()-1; i>=0; i--){
        output = convertStringtochar[i]+output;
        if (count == i && i!=0) {
            output = '.'+output;
            count = count - 3;
        }
    }
    return output;
   }  
}