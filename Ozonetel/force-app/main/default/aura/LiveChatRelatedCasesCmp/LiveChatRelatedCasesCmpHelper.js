({
    fetchCases: function (component, chatSessionKey) {
        let action = component.get("c.getCases");
        action.setParams({
            chatTransId: chatSessionKey
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let caseList = response.getReturnValue();
                component.set("v.caseList", caseList);
            } else {
                console.error("Error fetching cases: ", response.getError());
            }
        });

        $A.enqueueAction(action);
    }
})