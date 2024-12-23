({
    init: function (cmp, event, helper) {
        cmp.set("v.errormsg",'' );
       var action = cmp.get("c.getShowDetails"); 
        action.setParams({
            "ordId" : cmp.get("v.recordId"),
        });
       action.setCallback(this, function(response) {
            var state = response.getState();
           if (state === "SUCCESS") {
            var res = response.getReturnValue(); 
               cmp.set("v.errormsg",res );
               console.log('res'+res);
           }
       });
        $A.enqueueAction(action);  

    }    
})