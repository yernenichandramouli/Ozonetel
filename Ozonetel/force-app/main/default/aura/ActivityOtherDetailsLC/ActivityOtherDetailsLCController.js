({
	closeQA : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})
/*
({
    doInit: function(component,event,helper) {
        var getId = component.get( "v.entityId" );
        console.log('getId-->'+getId);
    }
})*/