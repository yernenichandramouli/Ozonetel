global class ZQPCaseAutoClosureBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    
    public string query;
      
    public ZQPCaseAutoClosureBatch (String strQuery)
    {
        if(String.isNotBlank(strQuery))
            Query = strQuery;
         else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='ZQPCaseAutoClosure'].QueryDetails__c;
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        DateTime now = System.now();
        System.Debug('query...'+Query);
        Query = Query+now.addMinutes(-30).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        System.Debug('query...'+Query);
        return Database.getQueryLocator(Query);
    }
    
    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){
        System.Debug('I am here...'+Query);
        List<DBLog_Summary__c> dblList=new List<DBLog_Summary__c>();
		map<id,case> caseMap = new map<id,case>();
        List<case> csUpList=new List<case>();
        List<casecomment> ccInsert = new List<casecomment>();
        for (Case cs : lstcases) {
            try{
      			casecomment cc=new casecomment();
        		cc.parentId=cs.Id;
                cc.commentbody='Closing ZQP Case As Second Valid Transaction Not Created Within 15 Minutes';
                cs.Status='Closed';
                ccInsert.add(cc);
                csUpList.add(cs);
         	}catch(Exception e){
                
            }

        }
        if (!ccInsert.isEmpty()){
            try {
                insert ccInsert;
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
        if (!csUpList.isEmpty()) {
            try {
                update csUpList;
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
    }
    
    global void finish(DataBase.BatchableContext bc){
        
    }
    
}