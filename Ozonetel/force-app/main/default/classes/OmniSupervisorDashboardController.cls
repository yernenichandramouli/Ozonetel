public class OmniSupervisorDashboardController {

    @AuraEnabled (cacheable=true)
    public static User_Details__c fetchUserDetails(){
        List<User_Details__c> usd = new List<User_Details__c>();
        String uid = UserInfo.getUserid();
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'OmniUserDetails'].QueryDetails__c;
        usd = Database.Query(Query);
        if (usd.isEmpty())
        {
            return null;
        }
        return usd[0];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<User_Details__c> getTotChatAgentsLoggedInSF(String refreshKey) {
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'OmniChatAgentsLoggedInSF'].QueryDetails__c;
        return Database.Query(Query);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<UserServicePresence> getTotAgentsLoggedInOmni(String refreshKey) {
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'AgentsLoggedInOmni'].QueryDetails__c;
        return Database.Query(Query);
    }

    @AuraEnabled(cacheable=true)
    public static List<UserServicePresence> getTotOnlineAgents(String refreshKey) {
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'OmniOnlineAgents'].QueryDetails__c;
        return Database.Query(Query);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<UserServicePresence> getTotBreakAwayAgents(String refreshKey) {
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'OmniBreakAwayAgents'].QueryDetails__c;
        return Database.Query(Query);        
    }

    @AuraEnabled(cacheable=true)
    public static List<UserServicePresence> getTotBreakWithChatAgents(String refreshKey) {
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'OmniBreakWithChats'].QueryDetails__c;
        return Database.Query(Query);        
    }

    @AuraEnabled(cacheable=true)
    public static List<UserServicePresence> getTotBreakWithoutChatAgents(String refreshKey) {
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'OmniBreakWithoutChats'].QueryDetails__c;
        return Database.Query(Query);        
    }

    @AuraEnabled(cacheable=true)
    public static List<User_Details__c> getTotOfflineAgents(String refreshKey) {
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'TotalOmniOfflineAgents'].QueryDetails__c;
        return Database.Query(Query);  
    }
    
    @AuraEnabled(cacheable=true)
    public static List<LiveChatTranscript> getWaitingChats(String refreshKey) {
        
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'OmniWaitingChats'].QueryDetails__c;
        return Database.Query(Query);  
    }
    
    @AuraEnabled(cacheable=true)
    public static List<LiveChatTranscript> getOngoingChats(String refreshKey) {
        
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'OmniOngoingChats'].QueryDetails__c;
        return Database.Query(Query);  
    }

    @AuraEnabled(cacheable=true)
    public static List<LiveChatTranscript> getMissChats(String refreshKey) {
        
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'OmniMissedChats'].QueryDetails__c;
        return Database.Query(Query);  
    }
    
    @AuraEnabled (cacheable=true)
    public static List<AggregateResult> fetchAllTodayChats(String refreshKey){
        string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'OmniTodayChatsStatusBreakup'].QueryDetails__c;
        return Database.Query(Query);
    }

}