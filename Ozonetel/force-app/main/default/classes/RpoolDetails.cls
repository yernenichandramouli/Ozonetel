public class RpoolDetails{
    
    public date startDate{get;set;}
    public date endDate{get;set;}
    
    public list<campaign> cmpLs=new list<campaign>();
    public list<Object_Info__c> objNewLs{get;set;}
    public list<Object_Info__c> objLatLs{get;set;}
    
    public map<string,string> oldMap{get;set;}
    public map<string,string> LatMap{get;set;}
    public map<string,integer> combMap{get;set;}
    public set<string> statusRows{get;set;}
    public set<string> statusColumns{get;set;}
    public list<string> statusRowsLs{get;set;}
    public list<string> statusColumnsLs{get;set;}
    public list<TableWrapper> twList{get;set;}
    
    public RpoolDetails(){
        statusRowsLs=new list<string>{'P1','P2','P3','P4','P5','P6'};
        statusColumnsLs=new list<string>{'P1','P2','P3','P4','P5','P6'};
    }

    
    public void RpoolData(){
        objNewLs=new list<Object_Info__c>();
        objLatLs=new list<Object_Info__c>();
        oldMap=new map<string,string>();
        LatMap=new map<string,string>();
        combMap=new map<string,integer>();
        statusRows=new set<string>();
        statusColumns=new set<string>();
        statusRowsLs=new list<string>();
        statusColumnsLs=new list<string>();
        twList=new list<TableWrapper>();
         statusRowsLs=new list<string>{'P1','P2','P3','P4','P5','P6'};
        statusColumnsLs=new list<string>{'P1','P2','P3','P4','P5','P6'};      
        //where createddate=:startDate
        // where createddate>=:startDate and createddate<=:endDate order by createddate asc
        System.debug('st->'+startDate);
         System.debug('et->'+endDate);
        
        objNewLs=[select id,name,Campaign__c,Old_Status__c,New_Status__c,Campaign_Number__c,Created_Date__c from Object_Info__c where Created_Date__c=:startDate];
        objLatLs=[select id,name,Campaign__c,Old_Status__c,New_Status__c,Campaign_Number__c,Created_Date__c from Object_Info__c where Created_Date__c>=:startDate and Created_Date__c<=:endDate  order by createddate asc];
       
        for(Object_Info__c o:objNewLs){
            oldMap.put(o.Campaign_Number__c,o.Old_Status__c);
        }
        
        for(Object_Info__c o:objLatLs){
            LatMap.put(o.Campaign_Number__c,o.New_Status__c);
        }
        
        System.debug('oldMap-->'+oldMap);
        System.debug('LatMap-->'+LatMap);
        set<string> ss=new set<string>();
        
        for(Object_Info__c o:objNewLs){           
            if(!ss.contains(o.Campaign_Number__c)){
                ss.add(o.Campaign_Number__c);
                string fs=oldMap.get(o.Campaign_Number__c);
                string ls=LatMap.get(o.Campaign_Number__c);
                statusRows.add(fs);
                statusColumns.add(ls);            
                
                TableWrapper tw=new TableWrapper();
                if(combMap.get(fs+'-'+ls)==null){
                    combMap.put(fs+'-'+ls,1);                                    
                }else{
                    combMap.put(fs+'-'+ls,combMap.get(fs+'-'+ls)+1);  
                }
            }  
            System.debug('combMap-->'+combMap);
        }
        list<string> stLs=new list<string>();
        list<string> stRs=new list<string>();
        list<string> stCols=new list<string>();
        
        for(string sc:statusColumnsLs){
            if(!stCols.contains(sc)){
                TableWrapper tw=new TableWrapper();
                tw.oldstatus=sc;
                System.debug('scol-->'+sc);
                stCols.add(sc);
                for(string sr:statusRowsLs){
                    if(!stRs.contains(sc+sr)){
                        stRs.add(sc+sr);
                        System.debug('sc-->'+sc+'--sr-->'+sr);                       
                        System.debug('comb p-->'+combMap.get(sc+'-'+sr));  
                        if(sr=='P1')
                            tw.p1=combMap.get(sc+'-'+sr);
                        if(sr=='P2')
                            tw.p2=combMap.get(sc+'-'+sr);
                        if(sr=='P3')
                            tw.p3=combMap.get(sc+'-'+sr);
                        if(sr=='P4')
                            tw.p4=combMap.get(sc+'-'+sr);
                        if(sr=='P5')
                            tw.p5=combMap.get(sc+'-'+sr);
                        if(sr=='P6')
                            tw.p6=combMap.get(sc+'-'+sr);
                        
                    }                  
                }
                twList.add(tw);
            }
        }
        
        System.debug('twList-->'+twList);        
        for(object o:combMap.keyset()){
            System.debug('or-->'+o);
            
        }        
    }
    
    public class TableWrapper{
        public integer p1{get;set;}
        public integer p2{get;set;}
        public integer p3{get;set;}
        public integer p4{get;set;}
        public integer p5{get;set;}
        public integer p6{get;set;}
        public string oldStatus{get;set;}
    }
}