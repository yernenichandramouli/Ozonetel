public class LiveChatTranscriptController {
    @AuraEnabled
    public static List<Map<String, Object>> getCases(String chatTransId) {
        // Query LiveChatTranscript
        LiveChatTranscript transcript = [
            SELECT Status, Tin_Number__c, Order_Uuid__c,OrderItem_Uuid__c
            FROM LiveChatTranscript
            WHERE id = :chatTransId
            LIMIT 1
        ];

       if (transcript == null || String.isBlank(transcript.OrderItem_Uuid__c)) {
            throw new AuraHandledException('No OrdeUuid__c found for the provided Chat Session Key.');
        }

system.debug('>>uuid>>>'+transcript.OrderItem_Uuid__c);
        // Query related cases using OrdeUuid__c
        List<Case> lstCases = [
            SELECT Id,CaseNumber,Status,Issue_Type__c, Issue_Sub_Category__c
            FROM Case
            WHERE (OrderItem_Uuid__c = :transcript.OrderItem_Uuid__c)
        ];
 system.debug('>>lstCases>>>'+lstCases);
        // Prepare list of cases as Maps for Aura
        List<Map<String, Object>> caseData = new List<Map<String, Object>>();
        for (Case c : lstCases) {
            caseData.add(new Map<String, Object>{
               'CaseId' => '/' + c.Id, // URL for hyperlink
                'CaseNumber' => c.CaseNumber, // Display label
                'IssueType' => c.Issue_Type__c,
                'SubIssueType' => c.Issue_Sub_Category__c,
                'Status' => c.status

               
            });
        }

    return caseData.isEmpty() ? null : caseData; // Return null if no cases found
    }
}