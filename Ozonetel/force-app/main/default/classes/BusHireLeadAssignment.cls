public class BusHireLeadAssignment {
    
    public List<Lead> hotList{get;set;}
    public List<Lead> cbList{get;set;}
    public List<Lead> newList{get;set;}
    public List<Lead> newList2{get;set;}
    public List<Lead> newList3{get;set;}
    public List<Lead> newList4{get;set;}
    public List<Lead> newList5{get;set;}
    public List<Lead> newList6{get;set;}
    public List<Lead> newList7{get;set;}
    public List<Lead> newList8{get;set;}
    public List<Lead> newList9{get;set;}
    public List<Lead> newList10{get;set;}
    public List<Lead> newList11{get;set;}
    public List<Lead> newRnRList{get;set;}
    public List<Lead> reOpenList{get;set;}
    public List<Lead> folwList{get;set;}
    public List<Lead> rnrList{get;set;}
    public List<Lead> inProgressList{get;set;}
    public lead ldObj{get;set;}
    public boolean showBlk{get;set;}
    public Map<String,String> mapQueries;

    public BusHireLeadAssignment(ApexPages.StandardController controller){
        ldObj=new lead();
        
        inProgressList=new list<lead>();
        
        showBlk=false;
        mapQueries = new Map<String,String>();

    }
    public void ShowLeads(){
       hotList=new list<lead>();
        cbList=new list<lead>();
        newList=new list<lead>();
        newList2=new list<lead>();
        newList3=new list<lead>();
        newList4=new list<lead>();
        newList5=new list<lead>();
        newList6=new list<lead>();
        newList7=new list<lead>();
        newList8=new list<lead>();
        newList9=new list<lead>();
        newList10=new list<lead>();
        newList11=new list<lead>();
        newRnRList=new list<lead>();
        reOpenList=new List<lead>();
        folwList=new list<lead>();   
        rnrList=new list<lead>();
        showBlk=true;
        System.debug('sel user'+ldObj.ownerId);
      //where DeveloperName IN('Group1CallBack','Group1NewRnR','Group1Hot','Group1New','Group1NewP2','Group1NewP3','Group1NewP4','Group1NewP5','Group1NewP6','Group1NewP7','Group1NewP8','Group1NewP9','Group1NewP10','Group1NewP11','Group1NewP12','Group1ReOpen','Group1Followup','Group2CallBack','Group2Followup','Group2Hot','Group2In_progress','Group2ReOpen','Group2RnR','LeadGenericQuery','Group2CallBack','Group2Followup','Group2Hot','Group2In_progress','Group2ReOpen','Group2RnR')  
        for(BusHire_Assignment__mdt dd:[SELECT Id,DeveloperName,Query__c FROM BusHire_Assignment__mdt ])
        {
               mapQueries.put(dd.DeveloperName,dd.Query__c);
        }
       try{
            user uObj=[select id,username,Group__c,Primary__c,Secondary__c,CZentrix_Agent_Id__c from user where id=:ldObj.ownerId and isactive=true limit 1]; 
            datetime currentTime=System.now();
            string primRegion=uObj.Primary__c;
            string secRegion=uObj.Secondary__c;
            datetime currentLocalTime=system.now();
            string leadQuery = [SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='LeadGenericQuery'].query__c;
           

            if(uObj.Group__c=='Group 1'){
                hotList= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1Hot'));
                cbList= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1CallBack'));
                newList= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1New'));
                newList2= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewP2'));
                newList3= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewP3'));
                newList4= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewP4'));
                newList5= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewP5'));
                newList6= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewP6'));
                newList7= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewP7'));
                newList8= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewP8'));
                newList9= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewP9'));
                newList10= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewP10'));
                newList11= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewP11'));     
                newRnRList=(List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1NewRnR'));          
                reOpenList= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1ReOpen'));
                folwList= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group1Followup'));
            }else{ 
                hotList= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group2Hot'));
                cbList= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group2CallBack'));
                rnrList=(List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group2RnR'));    
                inProgressList=(List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group2In_progress')); 
                reOpenList= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group2ReOpen'));   
                folwList= (List<lead>)Database.query(leadQuery+' '+mapQueries.get('Group2Followup'));
           
            } 
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Something went wrong!!'+e));
        } 
    }
}