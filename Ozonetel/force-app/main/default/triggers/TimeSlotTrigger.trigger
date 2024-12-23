trigger TimeSlotTrigger on TimeSlot__c (after update) {
    List<TimeSlot__c> timeSlotsToUpdate = new List<TimeSlot__c>();
    List<TimeSlot__c> newTimeSlotsToInsert = new List<TimeSlot__c>();
    
    // Step 1: Collect updated Call_End_Time__c values only when Call_End_Time__c is updated
    Map<Id, Datetime> updatedCallEndTimes = new Map<Id, Datetime>();
    for (TimeSlot__c ts : Trigger.new) {
        TimeSlot__c oldTs = Trigger.oldMap.get(ts.Id);
        if (ts.Call_End_Time__c != oldTs.Call_End_Time__c && ts.Call_End_Time__c != null) {
            updatedCallEndTimes.put(ts.Id, ts.Call_End_Time__c);
        }
    }

    // Step 2: Query next slots with StartTime__c less than the updated Call_End_Time__c values
    if (!updatedCallEndTimes.isEmpty()) {
        List<TimeSlot__c> crossedTimeSlots = [
            SELECT Id, caseId__c, CaseNumber__c, isSchedule__c, Name, StartTime__c, Phone__c, EndTime__c, Call_End_Time__c, Description__c, Status__c
            FROM TimeSlot__c 
            WHERE Call_End_Time__c = null AND CreatedDate = TODAY
            AND StartTime__c < :updatedCallEndTimes.values()
            ORDER BY StartTime__c DESC
        ];

        // Step 3: Process each Call_End_Time__c in a single pass
        Set<Datetime> existingStartTimes = new Set<Datetime>();
        Integer minutesToAdd = 45; // Initial time increment for new slots

        for (Datetime callEndTime : updatedCallEndTimes.values()) {
            for (TimeSlot__c crossedSlot : crossedTimeSlots) {
                // If Call_End_Time__c crosses the StartTime__c of the slot
                if (callEndTime > crossedSlot.StartTime__c) {
                    crossedSlot.Description__c = 'Updated due to Call_End_Time__c crossing StartTime__c';
                    timeSlotsToUpdate.add(crossedSlot);

                    // Calculate new StartTime based on the incremented minutes
                    Datetime newStartTime = callEndTime.addMinutes(minutesToAdd);
                    
                    // Ensure new slot does not overlap existing ones
                    if (!existingStartTimes.contains(newStartTime)) {
                        // Check if the new slot crosses 10 PM
                        if (newStartTime.hour() >= 22) { // If it's 10 PM or later
                            Date nextDay = newStartTime.date().addDays(1); // Get next day's date
                            newStartTime = Datetime.newInstance(nextDay, Time.newInstance(9, 0, 0, 0)); // Set to next day at 9 AM
                        }
                        
                        TimeSlot__c newSlot = new TimeSlot__c();
                        newSlot.CaseNumber__c = crossedSlot.CaseNumber__c;
                        newSlot.Phone__c = crossedSlot.Phone__c;
                        newSlot.caseId__c = crossedSlot.caseId__c;
                        newSlot.StartTime__c = newStartTime;
                        newSlot.isSchedule__c = true;
                        newSlot.EndTime__c = newSlot.StartTime__c.addMinutes(25); // New slot duration
                        newSlot.Description__c = 'New slot created due to time crossing ' + crossedSlot.Name;
                        newSlot.Status__c = 'Open';

                        newTimeSlotsToInsert.add(newSlot);
                        existingStartTimes.add(newStartTime); // Track the new StartTime to avoid duplicates
                    }
                    minutesToAdd += 30; // Increment for the next slot to prevent overlapping
                }
            }
        }

        // Step 4: Perform bulk DML operations
        if (!timeSlotsToUpdate.isEmpty()) {
            update timeSlotsToUpdate;
        }
        if (!newTimeSlotsToInsert.isEmpty()) {
            insert newTimeSlotsToInsert;
        }
    }
}