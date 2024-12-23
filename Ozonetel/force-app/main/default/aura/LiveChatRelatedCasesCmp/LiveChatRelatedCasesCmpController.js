({
    onWorkAccepted: function (component, event, helper) {
        // Fetch work details from the event
        let workItemId = event.getParam("workItemId");
        console.log("Work Item ID: ", workItemId);

        // Call Apex method to fetch cases
        helper.fetchCases(component, workItemId);
    }
})