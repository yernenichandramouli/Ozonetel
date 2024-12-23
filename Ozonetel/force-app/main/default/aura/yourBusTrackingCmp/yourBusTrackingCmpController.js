({
    closePopUp : function(component, event, helper) {
        var urlI= event.getParam('ulrId');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: urlI,
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(tabInfo) {
                console.log("The recordId for this tab is: " + tabInfo.recordId);
            });
        }).catch(function(error) {
            console.log(error);
        });
		$A.get("e.force:closeQuickAction").fire();
    }
})