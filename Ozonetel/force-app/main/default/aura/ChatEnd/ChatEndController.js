({
    onChatEnded: function(cmp, evt, helper) {
        var recId = evt.getParam("recordId");
       // console.log('Event Record details: ' + recId);
        
        var workspaceAPI = cmp.find("workspace");
        
        workspaceAPI.getAllTabInfo().then(function(response) {
            var allTabs = response;
           // console.log("All Tabs Info: ", allTabs);
            
            // Find the first tab to close
            var tabToClose = allTabs.find(function(tab) {
                return tab.icon === "standard:live_chat" &&
                    tab.recordId.includes(recId) &&
                    tab.closeable &&
                    tab.iconAlt === "LiveChatTranscript";
            });
            
            if (tabToClose) {
              //  console.log('Tab Id to close the tab ' + tabToClose.tabId);
                window.setTimeout($A.getCallback(function() {
                    workspaceAPI.closeTab({ tabId: tabToClose.tabId });
                }), 360000);
            } else {
              //  console.log('No tab found to close.');
            }
            
            
            
        }).catch(function(error) {
            console.error('Error retrieving tab information:', error);
        });
    }
})