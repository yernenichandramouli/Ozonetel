({
    onWorkAccepted : function(component, event, helper) {
        console.log(">>Work accepted.");
        var workItemId = event.getParam('workItemId');
        console.log(workItemId);
        var action = component.get("c.onChatAccepted");
        action.setParams({'sessionKey':workItemId});
        action.setCallback(this, function(response) {
            var state = response.getState();
        });
        $A.enqueueAction(action);
    },
    
    onAgentSend: function(cmp, evt, helper) {
        var recordId = evt.getParam("recordId");
        var content = evt.getParam("content");
        var name = evt.getParam("name");
        var type = evt.getParam("type");
        var timestamp = evt.getParam("timestamp");
        console.log('on Agent send');
        console.log("recordId:" + recordId + " content:" + content + " name:" + name + " timestamp:" + timestamp);
        var autoGreet=$A.get("$Label.c.Live_Chat_Auto_greeting");
        console.log('<<<auto greet'+autoGreet);
        if(!content.includes(autoGreet)){
            var action = cmp.get("c.onAgentMsg");
            action.setParams({'sessionKey':recordId , 'content':content, 'name':name, 'timestamp':timestamp});
            action.setCallback(this, function(response) {
                var state = response.getState();
            });
            $A.enqueueAction(action);            
        }
        
    },
    onChatEnded: function(cmp, evt, helper) {
        var action = cmp.get("c.onChatEndMsg");
        
        console.log('<<< chat ended');
        var conversation = cmp.find("conversationKit");
        console.log('<'+ conversation);    
        var recordId = evt.getParam("recordId");
        console.log("recordId:" + recordId);
        action.setParams({'sessionKey':recordId});
        console.log('after session key assignment');
        action.setCallback(this, function(response) {
            var state = response.getState();   
            console.log('<<'+state+'<<<response'+JSON.stringify(response));
            
        });
        
        $A.enqueueAction(action);
        console.log('after on chat end');
    },
    onNewMessage: function(cmp, evt, helper) {
        var recordId = evt.getParam('recordId');
        var content = evt.getParam('content');
        var name = evt.getParam('name');
        var type = evt.getParam('type');
        var timestamp = evt.getParam('timestamp');
        console.log('on new message');
        console.log("recordId:" + recordId + " content:" + content + " name:" + name + " timestamp:" + timestamp);
        var action = cmp.get("c.onUsermessageSent");
        action.setParams({'sessionKey':recordId, 'content':content, 'name':name, 'timestamp':timestamp});
        action.setCallback(this, function(response) {
            var state = response.getState();
        });
        $A.enqueueAction(action);
    }  
})