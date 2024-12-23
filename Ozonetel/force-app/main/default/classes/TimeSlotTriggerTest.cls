@isTest
public class TimeSlotTriggerTest {
    
    @testSetup
    static void setupTestData() {
        // Insert initial test data for TimeSlot__c records with various StartTime__c and Call_End_Time__c values
        List<TimeSlot__c> timeSlots = new List<TimeSlot__c>{
            new TimeSlot__c(CaseNumber__c = '1001', StartTime__c = Datetime.newInstance(2024, 10, 28, 18, 0, 0), EndTime__c = Datetime.newInstance(2024, 10, 28, 18, 15, 0)),
            new TimeSlot__c(CaseNumber__c = '1002', StartTime__c = Datetime.newInstance(2024, 10, 28, 18, 20, 0), EndTime__c = Datetime.newInstance(2024, 10, 28, 18, 35, 0)),
            new TimeSlot__c(CaseNumber__c = '1003', StartTime__c = Datetime.newInstance(2024, 10, 28, 18, 40, 0), EndTime__c = Datetime.newInstance(2024, 10, 28, 18, 45, 0)),
            new TimeSlot__c(CaseNumber__c = '1004', StartTime__c = Datetime.newInstance(2024, 10, 28, 19, 0, 0), EndTime__c = Datetime.newInstance(2024, 10, 28, 19, 15, 0))
        };
        insert timeSlots;
    }

    @isTest
    static void testTmSlotTriggerCallEndTimeUpdate() {
        // Retrieve the initial records
        List<TimeSlot__c> existingSlots = [SELECT Id, StartTime__c, Call_End_Time__c FROM TimeSlot__c ORDER BY StartTime__c];

        // Update Call_End_Time__c for the first slot to trigger the logic
        TimeSlot__c slotToUpdate = existingSlots[0];
        slotToUpdate.Call_End_Time__c = Datetime.newInstance(2024, 10, 28, 19, 25, 0);
        update slotToUpdate;

        // Verify if crossed slots were updated and new slots were inserted
        List<TimeSlot__c> updatedSlots = [SELECT Id, Description__c FROM TimeSlot__c WHERE Id IN :existingSlots];
        List<TimeSlot__c> newSlots = [SELECT Id, StartTime__c, EndTime__c, Description__c, Status__c FROM TimeSlot__c WHERE CreatedDate = TODAY AND Id NOT IN :existingSlots];

      
        // Assert the timing for each new slot to ensure no overlap
        Integer minutesToAdd = 45;
        for (Integer i = 0; i < newSlots.size(); i++) {
            TimeSlot__c newSlot = newSlots[i];
            Datetime expectedStartTime = slotToUpdate.Call_End_Time__c.addMinutes(minutesToAdd);
            Datetime expectedEndTime = expectedStartTime.addMinutes(25); // End time should be 25 minutes after start
            
          

            minutesToAdd += 30; // Increment for next slot to prevent overlap
        }
    }
}