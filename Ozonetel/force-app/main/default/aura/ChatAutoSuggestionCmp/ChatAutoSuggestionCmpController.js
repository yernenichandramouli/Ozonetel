({
    prefillGPTMessage: function(component, event, helper) {
        const conversationToolkit = component.find("conversationToolkit");
        var recordId2 = component.get("v.recordId");
        console.log("RecordId:", recordId2);

        // Placeholder GPT Response (replace this with your actual API call to fetch GPT response)
        var gptResponse = component.get("v.gptPrompt");  // Example response

        // Set the GPT response as prefilled input for the agent
        conversationToolkit.setAgentInput({
            // message: gptResponse,
            message: {
                    text: gptResponse
                },
            recordId: recordId2,
            callback: function(result) {
                if (result.success) {
                    console.log('Message prefilled successfully.');
                } else {
                    console.error('Failed to prefill message:', result.errors);
                }
            }
        });
    },
    
    sendMessageToCustomer:function(component, event, helper) {
        var conversationToolkit = component.find("conversationToolkit");
        var workItemId = event.getParam('workItemId');
        var recId=component.get("v.recordId");
        console.log('workItemId-->'+workItemId);
        console.log('recordId-->'+recId);
		var messageToShow= component.get("v.gptPrompt");
        console.log('messageToShow-->'+messageToShow);
            conversationToolkit.sendMessage({
            // message: gptResponse,
            message: {
                    text: messageToShow
                },
            recordId: recId,
            callback: function(result) {
                if (result.success) {
                    console.log('Message prefilled successfully.');
                } else {
                    console.error('Failed to prefill message:', result.errors);
                }
            }
        });
    },
    onNewMessage: function(cmp, evt, helper) {
	    cmp.set('v.loaded',true);
        var recordId = evt.getParam('recordId');
        var content = evt.getParam('content');
        console.log("recordId:" + recordId + " userMessage:" + content);
        var action = cmp.get("c.getGptPrompt");
        action.setParams({'recordId':recordId, 'userMessage':content});
        action.setCallback(this, function(response) {
            // Hide spinner when response is received
        	cmp.set('v.loaded',false);
            var state = response.getState();  
			cmp.set("v.gptPrompt", response.getReturnValue());  
            // start to set as agent Input
            const conversationToolkitVar = cmp.find("conversationToolkit");
            var gptResponse = cmp.get("v.gptPrompt");
            if(gptResponse!='No suggestion found. Please go ahead with your reply!'){
                cmp.set("v.isButtonDisabled", false);
                conversationToolkitVar.setAgentInput({
            // message: gptResponse,
            message: {
                    text: gptResponse
                },
            recordId: recordId,
            callback: function(result) {
                if (result.success) {
                    console.log('Message prefilled successfully.');
                } else {
                    console.error('Failed to prefill message:', result.errors);
                }
            }
        	});
            }
            
            // End of agent input
          
        });
        $A.enqueueAction(action);
       
    }  
})