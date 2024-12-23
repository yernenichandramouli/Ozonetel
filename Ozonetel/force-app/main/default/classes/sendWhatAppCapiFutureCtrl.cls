/**
* (c) 2024 RedBus
*
* Name           : sendWhatAppCapiCtrl
* Created Date   : 16 Sep 2024
* Created By     : VR Sudarshan
* Purpose        : Future method to send the whatsApp Notification.
* Test Class     : sendWhatAppCapiCtrlTest 
* Jira Id        : CRM-1926
**/
public class sendWhatAppCapiFutureCtrl {
    @future(callout=true)
    public static void asyncSendWhatsAppMessage(Map<id,String> caseMap){
        system.debug('::: caseMap = '+caseMap);
        sendWhatAppCapiCtrl.sendWhatsAppMessage(caseMap);
    }
}