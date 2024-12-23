({
    onChatEnded: function (component, event, helper) {
        // component.set('v.loaded',true);
        // Get the recordId from the component
        const recordId = component.get("v.recordId");

        // Call the helper function to fetch data from Apex
            helper.fetchChatData(component, recordId);
    },
    toggleEditMode: function(component, event, helper) {
        let isCurrentlyEditable = component.get("v.isEditable");
        component.set("v.isEditable", !isCurrentlyEditable);
        component.set("v.isButtonDisabled", isCurrentlyEditable); 
    },   
    createCase: function(component, event, helper) {
        let channel = component.get("v.channel");
        let summary = component.get("v.summary");
        let status = component.get("v.status");
        let issue = component.get("v.issue");
        let subIssue = component.get("v.subIssue");

        // Validate the required fields
        /*if (!summary || !status || !issue || !subIssue) {
            alert("Please ensure all fields are filled before creating the case.");
            return;
        }*/

        // Call Apex to create the case record
        let action = component.get("c.createCaseRecord");
        action.setParams({
            channel: channel,
            summary: summary,
            status: status,
            issue: issue,
            subIssue: subIssue
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let caseId = response.getReturnValue();
                console.log("Case created successfully with ID: " + caseId);
                alert("Case created successfully!");
                // Optionally reset to default state after creating case
                component.set("v.isEditable", false);
                component.set("v.isButtonDisabled", true);
            } else {
                console.error("Error creating case:", response.getError());
                alert("An error occurred while creating the case.");
            }
        });

        $A.enqueueAction(action);
    }
         
})