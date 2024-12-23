({	
    init : function(component, event, helper) {
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__viewAllCaseCommentCmp',
            },
            state: {
                "c__title": component.get("v.recordId")
            }
        };
        component.set("v.pageReference", pageReference);
        console.log('CC cmp init')
    },
    ViewAll: function(component, event, helper) {
        console.log('caseCommentsCmpController');
        if(event.getParam('evnt') == 'viewAll')
        {
            var action = component.get("c.getUIThemeDescription");
            
            action.setCallback(this, function(a) {
                component.set("v.Name", a.getReturnValue());
				if(a.getReturnValue()=='Theme4d' || a.getReturnValue()=='Theme4u'){
                    var navService = component.find("navService");
                    var pageReference = component.get("v.pageReference");
                    event.preventDefault();
                    console.log('pageReference'+pageReference);
                    navService.navigate(pageReference);                          
                }
                else{
					var recordId = component.get("v.recordId");
                    console.log('<<<recordid'+recordId);
                    window.open('/apex/ViewAllCaseComments?Id='+recordId,'_self');
                    /*var urlI = 'https://redbus--dev2.my.salesforce.com/apex/ViewAllCaseComments?Id='+recordId;
                    alert(urlI);
                    var urlEvent = $A.get("e.force:navigateToURL"); 
                    urlEvent.setParams({ 
                        "url": urlI 
                    }); 
                    urlEvent.fire();*/
                }
            });
            $A.enqueueAction(action);
        }  
    }
})