/**
* Name           : RequestWrapper
* Created Date   : 13-03-2018
* Created By     : Veeramanikanta R  
* Purpose        : This controller maintains all the wrappers for different functionalities 
**/
public class RequestWrapper{
    
    public class SendNotificationWrapper{
        public List<string> type=new List<string>{'smsdata'};
            public smsdata smsdata;
        public SendNotificationWrapper(string pNo,string jsonBody,string templateName,string message,boolean isTempUsed){
            smsdata=new smsdata(pNo,jsonBody,templateName,message,isTempUsed);
        }
        
    }
    public class smsdata{
        public string NotificationType='SMS';
        public string Language='en';
        public boolean IsTemplateUsedForMessage;
        public List<SMSRequest> SMSRequest;
        public smsdata(string pNo,string jsonBody,string templateName,string message,boolean isTempUsed){
            this.IsTemplateUsedForMessage=isTempUsed;
            SMSRequest=new List<SMSRequest>{new SMSRequest(pNo,jsonBody,templateName,message)};
                }
        
    }    
    public class SMSRequest{
        public SMSMessage SMSMessage;
        public SMSRequest(string pNo,string jsonBody,string templateName,string message){
            SMSMessage=new SMSMessage(pNo,jsonBody,templateName,message);
        }
        
    }
    public class SMSMessage{
        public string mobileNo;
        public string senderId='REDBUS';
        public boolean isUnicodeSms=false;
        public string message;
        public CustomMessageDetails CustomMessageDetails=new CustomMessageDetails();
        public SMSMessage(string pNo,string jsonBody,string templateName,string message){
            this.mobileNo=pNo;
            this.CustomMessageDetails.DataJsonStr=jsonBody;
            this.CustomMessageDetails.TemplateName=templateName;
            this.message=message;
        }                
    }
    public class CustomMessageDetails{
        public string TemplateName='CaseClosed_SMS';
        public string DataComplexity='KVP';
        public string DataJsonStr;
        
    }
    
    
    public class BOCallWrapper{
      public string tin;
      public string OperatiorId;
      public string OperatorName;
      public string caller;
      public string receiver;
      public boolean primary;
      public String doj;
      public string routeId;
      public string agentId;
      public BOCallWrapper(string boPhoneNo,string agentPhoneNo,Case cs,String agntId){
         this.tin=cs.TIN_No__c;
         this.OperatiorId=cs.Service_Provider_Id__c;
         this.OperatorName=cs.Bus_Operator_Name__c;
         this.agentId =agntId;
         caller=agentPhoneNo;
         receiver=boPhoneNo;
         this.primary=cs.Is_Primary__c;
            
           if(cs.Date_Of_Journey_New__c!=null)
                this.doj = String.valueOf(cs.Date_Of_Journey_New__c.format('yyyy-MM-dd 00:00:00','Asia/Kolkata'));
            else if(cs.SS_DOJ__c!=null)
                 this.doj = String.valueOf(cs.SS_DOJ__c.format('yyyy-MM-dd 00:00:00','Asia/Kolkata'));
                 
         this.routeId=String.isNotBlank(cs.Route_Id__c)?cs.Route_Id__c:cs.SS_Route_Id__c;
         
       }
       
         public BOCallWrapper(string boPhoneNo,string agentPhoneNo,Case cs){
         this.tin=cs.TIN_No__c;
         this.OperatiorId=cs.Service_Provider_Id__c;
         this.OperatorName=cs.Bus_Operator_Name__c;
         caller=agentPhoneNo;
         receiver=boPhoneNo;
         this.primary=cs.Is_Primary__c;
         this.doj= String.valueOf(cs.Date_Of_Journey_New__c.format('dd-MM-yyyy h:mm a','Asia/Kolkata'));
         this.routeId=String.isNotBlank(cs.Route_Id__c)?cs.Route_Id__c:cs.SS_Route_Id__c;
         
       }
    }
    
    public class BOSponcerWrapper{
    
    public string channel;
    public string refundedBy;
    public string notes;
    public list<orders> orders;
    public BOSponcerWrapper(string channel,string refundedBy,string notes,list<orders> orders){
        this.channel=channel;
        this.refundedBy=refundedBy;
        this.orders=orders; 
        this.notes=notes;     
    }
     }
public class orders{
    public string orderItemUUID;
    public string tin;
}
}