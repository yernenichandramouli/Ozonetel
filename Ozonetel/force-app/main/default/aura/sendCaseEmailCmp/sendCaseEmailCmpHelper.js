({
    sendHelper: function (component, getEmail, getSubject, getbody, caseId, sendFrom) {
        var spinner = component.find("mySpinner");
        console.log(':: getEmail ::: '+getEmail);
        console.log(':: getSubject ::: '+getSubject);
        console.log(':: getbody ::: '+getbody);
        console.log(':: caseId ::: '+caseId);
        $A.util.removeClass(spinner, "slds-hide");
       // showSpinner(component)
        // call the server side controller method 	
        var action = component.get("c.sendMailMethod");
        var templateId = component.get("v.templateIDs");
        // set the 3 params to sendMailMethod method   
        action.setParams({
            'mMail': getEmail,
            'mSubject': getSubject,
            'mbody': getbody,
            'caseId': caseId,
            'fromEmailAdd': sendFrom,
            'folderId': component.get("v.folderId1"),
            'templateId': component.get("v.templateIDs")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.util.addClass(spinner, "slds-hide");
               // hideSpinner(component);
                var storeResponse = response.getReturnValue();
                // if state of server response is comes "SUCCESS",
                // display the success message box by set mailStatus attribute to true
                component.set("v.mailStatus", true);
            }

        });
        $A.enqueueAction(action);
    },

    getEmailTemplateHelper: function (component, event) {

        var action = component.get("c.getEmailTempaltes");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                component.set("v.emailfolderVSTemplateList", response.getReturnValue());
                component.set('v.loaded', !component.get('v.loaded'));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);

    },

    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})