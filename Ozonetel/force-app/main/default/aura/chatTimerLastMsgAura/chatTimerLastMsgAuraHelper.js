({
    // Resets and restarts the timer
    resetTimer: function (component) {
        this.stopTimer(component); // Stop any existing timer
        this.startTimer(component); // Start a new timer
    },
    
    // Starts the timer
    startTimer: function (component) {
        let workspaceAPI = component.find("workspaceAPI");
        
        // Timer logic
        let seconds = 0;
        let timer = setInterval(() => {
            seconds++;
            let minutesDisplay = String(Math.floor(seconds / 60)).padStart(2, '0');
            let secondsDisplay = String(seconds % 60).padStart(2, '0');
            
            component.set("v.minutes", minutesDisplay);
            component.set("v.seconds", secondsDisplay);
            
            // If 1 minute has passed, highlight the tab
            if (seconds === 60) {
           // this.highlightTab(workspaceAPI);
        }
        }, 1000);
            
            component.set("v.timer", timer);
        },
            
            // Stops the timer
            stopTimer: function (component) {
                let timer = component.get("v.timer");
                if (timer) {
                    clearInterval(timer);
                    component.set("v.timer", null);
                }
                // Reset the timer display
                component.set("v.minutes", "00");
                component.set("v.seconds", "00");
            },
            
            // Highlights the tab when inactivity is detected
            highlightTab: function (workspaceAPI) {
                // Highlight the tab
                workspaceAPI.getFocusedTabInfo()
                .then((response) => {
                    let focusedTabId = response.tabId;
                    
                    // Set the tab to be highlighted
                    workspaceAPI.setTabHighlighted({
                    tabId: focusedTabId,
                    highlighted: true,
                    options: {
                    pulse: true, // Pulsing animation for highlight
                    state: 'error' // Set highlight state to 'error'
                }
                      }).then(() => {
                    // After a short delay, reset the tab to normal
                    setTimeout(() => {
                    workspaceAPI.setTabHighlighted({
                    tabId: focusedTabId,
                    highlighted: false, // Reset the highlight
                    options: {}
                }).catch((error) => {
                    console.error("Error resetting tab highlight: ", error);
                });
                }, 5000); // Change the timeout duration (e.g., 5 seconds) as needed
                });
                })
                    .catch((error) => {
                    console.error("Error highlighting tab: ", error);
                });
                },
                    
                    sendMessageHelper: function(component, message) {
                        const conversationToolkit = component.find("conversationKit");
                        const recId = component.get("v.recordId");
                        
                        if (!conversationToolkit || !recId) {
                            console.error("Conversation toolkit or recordId is not defined.");
                            return;
                        }
                        
                        conversationToolkit.sendMessage({
                            message: {
                                text: message
                            },
                            recordId: recId,
                            callback: function(result) {
                                if (result.success) {
                                    console.log("Message sent successfully:", message);
                                } else {
                                    console.error("Failed to send message:", result.errors);
                                }
                            }
                        });
                    }
                })