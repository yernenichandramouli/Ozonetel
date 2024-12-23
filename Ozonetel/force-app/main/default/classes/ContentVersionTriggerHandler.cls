public class ContentVersionTriggerHandler{
    
    @future(callout=true)
    public static void sendToS3(Id id){
        AWSS3_PutAttachments putAttachment = new AWSS3_PutAttachments();
        putAttachment.recordId = id;
        putAttachment.init();
    }
}