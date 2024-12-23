({
    
    // Resets the timer on chat events
    onMessage: function (component, event, helper) {
        helper.resetTimer(component);
    },

    // Cleans up timer on component destroy
    cleanupTimer: function (component, event, helper) {
        helper.stopTimer(component);
    },

    // Ends the timer when the chat ends
    onChatEnd: function (component, event, helper) {
        helper.stopTimer(component);
    },

    onChatEnd: function (component, event, helper) {
        const recId = event.getParam("recordId");
        helper.clearTimer(component, recId);
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