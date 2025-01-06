({

    doInit: function (component, event, helper) {
        // Retrieve the event recordId
        let eventRecordId = event.getParam("recordId");
        console.log("eventRecordId is", eventRecordId);
        component.set("v.isOnDoInit", true);
        let workspaceAPI = component.find("workspace");
		        
        // Get the current record ID from the component
        let currentRecId = component.get("v.recordId").substr(0, 15);
        console.log("component RecordId is", currentRecId);
        
        helper.checkTimers(component,eventRecordId,currentRecId,true,workspaceAPI);
        
        helper.fetchCases(component, currentRecId);
        component.set("v.isOnDoInit", false);

        
    },
    
    handleMessageSentOrReceived: function (component, event, helper) {
        let eventRecordId = event.getParam("recordId");
        console.log("eventRecordId is", eventRecordId);
        
        let workspaceAPI = component.find("workspace");
        
        let currentRecId = component.get("v.recordId").substr(0, 15);
        console.log("component RecordId is", currentRecId);
        
        helper.checkTimers(component,eventRecordId,currentRecId,false,workspaceAPI); 
     },
    
onChatEndedTimer: function(component, event, helper) {
    console.log('Inside End Chat');

    // Get the event record ID from the event parameter
    let eventRecordId = event.getParam("recordId");
    console.log("eventRecordId is", eventRecordId);

    // Get the workspace API and current record ID
    let workspaceAPI = component.find("workspace");
    let currentRecId = component.get("v.recordId").substr(0, 15); // Ensure it's the first 15 characters (standard Salesforce ID format)

    // Check if the event record ID matches the current record ID
    if (eventRecordId === currentRecId) {
        // Get the existing interval ID from the component
        let existingAgentCxIntervalId = component.get("v.agentcxIntervalId");
        
        // Clear the interval if it exists
        if (existingAgentCxIntervalId) {
            window.clearInterval(existingAgentCxIntervalId);
        }

        // Reset the timer-related values
        component.set("v.agentCxTimer", ""); // Clear the timer display (if needed)
        component.set("v.minutes", ""); // Clear minutes value
        component.set("v.seconds", ""); // Clear seconds value

        // Reset tab highlight settings
        let vartabHighlighted = component.get("v.tabHighlighted");

        // Get the current tabId using the workspace API
        workspaceAPI.getEnclosingTabId().then((tabId) => {
            if (vartabHighlighted) {
                component.set("v.tabHighlighted", false); // Reset tab highlight state

                try {
                    // Unhighlight the tab if it was previously highlighted
                    workspaceAPI.setTabHighlighted({
                        tabId: tabId,
                        highlighted: false,
                        options: { pulse: false } // Optionally turn off the pulse effect
                    });
                } catch (error) {
                    console.warn("Error resetting tab settings or tab might not exist:", error);
                }
            }
        }).catch((error) => {
            console.warn("Error fetching tabId:", error);
        });

        console.log('End of End Chat');
    }
},



            
    handleRowAction: function (component, event, helper) {
        const workspaceAPI = component.find("workspace");
        const row = event.getParam("row"); // The row data of the clicked row
        const caseId = row.CaseId;

        // Open the clicked case in a new subtab
        workspaceAPI.openTab({
            recordId: caseId,
            focus: true
        }).catch(function (error) {
            console.error("Error opening subtab: ", error);
        });
     },
    
   handleHoldClick: function(component, event, helper) {
        const message = "Please stay connected for 2-3 minutes, while we check the information for you.";
        helper.sendMessageHelper(component, message);
    },

    handleResumeClick: function(component, event, helper) {
        const message = "Thank you for staying connected, I appreciate your time and patience.";
        helper.sendMessageHelper(component, message);
    },

    handleOnlineClick: function(component, event, helper) {
        const message = "Hi, please reply if you are online.";
        helper.sendMessageHelper(component, message);
    }
  
})