({
    doInit: function (component, event, helper) {

        var caseId = component.get("v.recordId");
        console.log(':: case Id ::'+component.get("v.recordId"));
        var label = $A.get("$Label.c.YB_Support_Custom_Email_From");
        //var fromEmailAddresses = label.split(',');
        //component.set("v.picklistOptions", fromEmailAddresses);
        var fromEmailAddressesList = label.split(',');
        component.set("v.fromAddressList", fromEmailAddressesList);


        var action = component.get("c.getLeadRec");
        action.setParams({
            "caseId": caseId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != null && response.getReturnValue() != "" && response.getReturnValue() != undefined) {
                    console.log(':: response ::: '+response.getReturnValue());
                    component.set("v.email", response.getReturnValue().Email_Id_ct__c);
                }
            }
        });
        $A.enqueueAction(action);
        helper.getEmailTemplateHelper(component, event);

    },

    sendMail: function (component, event, helper) {
        // when user click on Send button 
        // First we get all 3 fields values 	
        var sendFrom = component.get("v.selectedFromEmail");
        var getEmail = component.get("v.email");
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.emailbody");
        var caseId = component.get("v.recordId");

        // check if Email field is Empty or not contains @ so display a alert message 
        // otherwise call call and pass the fields value to helper method    
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@")) {
            alert('Please Enter valid Email Address');
        } else {
            helper.sendHelper(component, getEmail, getSubject, getbody, caseId, sendFrom);
        }
    },

    // when user click on the close buttton on message popup ,
    // hide the Message box by set the mailStatus attribute to false
    // and clear all values of input fields.   
    closeMessage: function (component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.emailbody", null);
        //$A.get("e.force:closeQuickAction").fire();
        var caseId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": caseId
        });
        navEvt.fire();
    },

    onSelectEmailFolder: function (component, event, helper) {
        var folderId = event.target.value;
        console.log(':: Folder Id :::: ',+folderId);
        component.set("v.folderId1", folderId);
        if (folderId != null && folderId != '' && folderId != 'undefined') {
            var emailfolderVSTemplateList = component.get("v.emailfolderVSTemplateList");
            emailfolderVSTemplateList.forEach(function (element) {
                if (element.folderId == folderId) {
                    component.set("v.emailTemplateList", element.emailtemplatelist);
                }
            });
        } else {
            var temp = [];
            component.set("v.emailTemplateList", temp);
        }
    },

    onFromAddressSelect: function (component, event, helper) {
        let selectedPickListValue = event.target.value;
        console.log(':: selectedPickListValue ='+selectedPickListValue);
        component.set("v.selectedFromEmail", selectedPickListValue);
    },

    onSelectEmailTemplate: function (component, event, helper) {
        var emailTempId = event.target.value;
        var emailbody = '';
        var emailSubject = '';
        component.set("v.templateIDs", emailTempId);
        if (emailTempId != null && emailTempId != '' && emailTempId != 'undefined') {
            var emailTemplateList = component.get("v.emailTemplateList");
            emailTemplateList.forEach(function (element) {
                if (element.emailTemplateId == emailTempId && element.emailbody != null) {
                    emailbody = element.emailbody;
                    emailSubject = element.emailSubject;
                }
            });
        }
        component.set("v.emailbody", emailbody);
        component.set("v.subject", emailSubject);

    },

    closeModal: function (component, event, helper) {
        console.log('::: Inside Close Modal ::::');
        var caseId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": caseId
        });
        navEvt.fire();
    },
    openmodal: function (component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    }


})