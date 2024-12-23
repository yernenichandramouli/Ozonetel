({
    highlightTabFun: function (workspaceAPI, tabId) {
        
    },
    
    checkTimers: function (component,eventRecId,currentRecId,isfromDoInit,workspaceAPI) {
        
        if(currentRecId!=undefined && (eventRecId === currentRecId || isfromDoInit)) {
            let existingAgentCxIntervalId = component.get("v.agentcxIntervalId");
            if (existingAgentCxIntervalId) {
                window.clearInterval(existingAgentCxIntervalId);
                component.set("v.minutes", "00");
                component.set("v.seconds", "00");
            }
            let totalSeconds = 0;
            // workspaceAPI = component.find("workspace");
            
            
            // Fetch the current tabId and store it in a component attribute
            workspaceAPI.getEnclosingTabId().then((tabId) => {
                //component.set("v.currentTabId", tabId);
                
                let agentCustomerIntervalId = window.setInterval(
                $A.getCallback(function () {
                let seconds = String(parseInt(totalSeconds % 60)).padStart(2, "0");
                let minutes = String(parseInt(totalSeconds / 60)).padStart(2, "0");
                
                component.set("v.minutes", minutes);
                component.set("v.seconds", seconds);
                
                let vartabHighlighted = component.get("v.tabHighlighted");
                
                if (!vartabHighlighted && parseInt(minutes) >= 1) {
                component.set("v.tabHighlighted", true);
                workspaceAPI.setTabHighlighted({
                tabId: tabId,
                highlighted: true,
                options: { pulse: true, state: "error" },
                                                  }) .catch((error) => {
                console.error("Error highlighting tab or tab might not exist:", error);
            });
            } else if (vartabHighlighted && parseInt(minutes) < 1) {
                component.set("v.tabHighlighted", false);
                workspaceAPI
                .setTabHighlighted({
                tabId: tabId,
                highlighted: false,
                options: { pulse: false },
            })
            .catch((error) => {
                console.warn("Error resetting tab settings or tab might not exist:", error);
            });
            }
                
                totalSeconds += 1;
            }),
                1000
                );
                
                component.set("v.agentcxIntervalId", agentCustomerIntervalId);
            });
            }
                
                
            },
                
                
                resetTabSettings: function (workspaceAPI, tabId) {
                    
                },
                initializeTimer: function (component, tabId) {
                    // Store timers in a Map
                    if (!window.tabTimers) {
                        window.tabTimers = new Map();
                    }
                    
                    // Initialize a timer for this tab
                    this.resetTimer(tabId,component);
                },
                
                resetTimer: function (tabId,component) {
                    // Clear existing timer if any
                    if (window.tabTimers.has(tabId)) {
                        clearInterval(window.tabTimers.get(tabId));
                    }
                    
                    // Start a new timer
                    let timer = 0;
                    let intervalId = setInterval(() => {
                        timer++;
                        console.log(`Tab ID: ${tabId}, Timer: ${timer}s`);
                    component.set("v.timeVar", timer);
                }, 1000);
                
                // Store the new timer's interval ID
                window.tabTimers.set(tabId, intervalId);
            },
                
                clearTimer: function (tabId) {
                    // Clear the timer when the tab is closed or the component is destroyed
                    if (window.tabTimers.has(tabId)) {
                        clearInterval(window.tabTimers.get(tabId));
                        window.tabTimers.delete(tabId);
                    }
                },
                fetchCases: function (component, chatSessionKey) {
                    console.log('>>>get cases id>>'+chatSessionKey);
                    let action = component.get("c.getCases");
                    action.setParams({
                        chatTransId: chatSessionKey
                    });
                    
                    action.setCallback(this, function (response) {
                        let state = response.getState();
                        if (state === "SUCCESS") {
                            console.log('>>>cases>>');
                            const caseData = response.getReturnValue();
                            if (caseData) {
                                component.set("v.caseList", caseData);
                            } else {
                                component.set("v.caseList", []); // Set empty list if no cases
                            } 
                        }else {
                            console.error("Error fetching cases: ", response.getError());
                        }
                    });
                    
                    $A.enqueueAction(action);
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