({
    onPageReferenceChange: function(cmp, evt, helper) {
        var action = cmp.get("c.getUIThemeDescription");
		action.setCallback(this, function(a) {
            //cmp.set("v.Name", a.getReturnValue());
            console.log('<<<<v.ShowCmp'+a.getReturnValue());
			if(a.getReturnValue()=='Theme4d' || a.getReturnValue()=='Theme4u'){
				var myPageRef = cmp.get("v.pageReference");
                var title = myPageRef.state.c__title;
                cmp.set("v.title", title);
                cmp.set("v.recordId", title);
                console.log('in aura'+cmp.get("v.recordId"));
            }else{
                console.log('<<<'+ cmp.get("v.ShowCmp"));
				cmp.set("v.ShowCmp", true);
            }
      	 	
            if(cmp.get("v.recordId") != null)
            {
                cmp.set("v.ShowCmp", true);
            }
        });
        $A.enqueueAction(action);
        
    }
})