({
    fetchChatData: function (component, recordId) {
        component.set('v.loaded',true);
        // Ensure recordId is available
        if (!recordId) {
             component.set('v.loaded',false);
            console.error("RecordId is not available.");
            return;
        }

        // Call the Apex method to fetch data
         setTimeout(() => {
        const action = component.get("c.handleChatEnd");
        action.setParams({ recordId: recordId });

        console.log(':: isloadedValue = '+component.get("v.loaded"));
        // Set up the callback for the Apex response
        action.setCallback(this, function (response) {
            component.set('v.loaded',false);
            const state = response.getState();
            if (state === "SUCCESS") {
                const caseData = response.getReturnValue();
                
                // Set the attributes with the returned values
                component.set("v.channel", caseData.channel);
                component.set("v.summary", caseData.summary);
                component.set("v.status", caseData.status);
                component.set("v.issue", caseData.issue);
                component.set("v.subIssue", caseData.subIssue);

                console.log("Chat End Data:", caseData);
            } else if (state === "ERROR") {
                const errors = response.getError();
                console.error("Error fetching chat data:", errors);
            }
        });

        // Enqueue the action
        $A.enqueueAction(action);
		},9000);
    }
})