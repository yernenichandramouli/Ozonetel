/**
 * (c) 2018 RedBus
 *
 * Name           : API_Complaint_Tracker
 * Created Date   : 25 May 2017
 * Created By     : Sreenivas M
 * Purpose        : API to create cases from multiple sources.
 *
 **/
 
 @RestResource(urlMapping='/redBus/ComplaintTracker/*')
 global without sharing class API_Complaint_Tracker
 {
     @HttpPost
     global static response doPost()
     {
         Map<String, String> giMMTIssueAndSubIssueType = new Map<String, String>();
         DBLog_Summary__c dbl = new DBLog_Summary__c();
         dbl.Type__c ='Complaint Tracker';
         RestRequest req = RestContext.request;
         RestResponse res = RestContext.response;
         system.debug('-----------data--------'+req);
         response resp = new response();
         system.debug(LoggingLevel.ERROR, req.requestBody.toString());       
         string reqStr=String.valueOf(req.requestBody.toString());
         if(reqStr.length()<10000)
             dbl.Request_Data__c = reqStr;
           else
              dbl.Request_Data__c = reqStr.substring(0,10000);  
         try
         {
             
             CaseInformation data = new CaseInformation();
             data = (CaseInformation)JSON.deserialize(req.requestBody.toString(),CaseInformation.class);
             System.debug('data--->'+data);
             string phonenum;
             string emails;
             Map<String,Case> mapCase = new Map<String,Case>();
             list<Case> caselst = new list<Case>();
             if(!string.isBlank(string.valueof(data)))
             {
                 string tripid = string.valueof(data.tripId);
                 String tin = string.valueof(data.tin);
                 String emailId = string.valueof(data.emailId);
                 String phoneNo = string.valueof(data.phoneNo);
                 String busiType = string.valueof(data.businessType);
                 
                
                 case cs = new case();
                 Id recTypeId = Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosByName().get('Complaint Tracker').getRecordTypeId();
                 cs.RecordTypeId = recTypeId;
                 cs.Trip_Id_ct__c = String.isNotBlank(tripid)?tripId:'';
                 cs.TIN_No__c = String.isNotBlank(tin)?tin:'';
                 cs.Country__c='India';
                 cs.Business_Type__c='Domestic-Bus';
                 cs.BO_Mobile_Number__c=string.valueof(data.boNumber);
                 string trippid= cs.Trip_Id_ct__c;
                 cs.Session_Id__c=data.sessionId;
                 cs.Order_Item_Id__c=data.orderItemId;
                 cs.Transaction_UUID__c=data.orderItemUUid;
                 cs.Order_UUId__c=data.orderUUId;
                 cs.My_desk_id__c=data.myDeskId;
                 cs.Disbursal_Id__c = data.disbursalId;
                 cs.Category__c=data.categoryVal;
                 cs.hft__c=data.hft;
                 cs.Selected_Issues__c=data.selectedIssues;
                 cs.SH_Attachment_URLs__c=data.attachmentURLs;
                 cs.Related_Case_Details__c=data.relatedCaseDetails;
                 cs.Refund_Type__c=data.refundType;
                 cs.Department_ctp__c=data.busNumber;
                 if(string.isNotBlank(data.parentCasenumber)){
                     list<case> csParList=[select id from case where casenumber=:data.parentCasenumber];
                     if(!csParList.isEmpty())
                         cs.parentId=csParList[0].id;
                 }
                 
                 if(data.userHasTravelled!=null)
                   cs.User_Has_Travelled__c=data.userHasTravelled;
                 cs.Other_Issue__c=data.otherIssue;
                if(string.isNotBlank(data.bookingId)){
                     cs.TIN_No__c = data.bookingId;
                     cs.Details_of_Complaint_ctp__c=data.vendorResol;
                     cs.Details_of_Service_ctp__c=data.sopResol;
                     cs.ZM_Name__c=data.zmName;
                     cs.Bus_Operator_Namee__c=data.vendorName;
                } 
                
               
                if(string.isNotBlank(string.valueof(data.channel)))
                 {
                     cs.Channel_ct__c = string.valueof(data.channel);
                     dbl.Linking_Process_Status__c = cs.Channel_ct__c;
                     dbl.User_Id__c= cs.TIN_No__c;
                     
                     if('Acko'.equalsIgnoreCase(cs.Channel_ct__c) || 'ICICI'.equalsIgnoreCase(cs.Channel_ct__c))
                     {  
                             if(data.claimDetails!=null)  
                             { 
                                 cs.Claim_Details__c= string.valueof(json.serialize(data.ClaimDetails));
                                 cs.Policy_Id__c = string.valueof(data.ClaimDetails.policyId);
                                  
                                 if(string.isNotBlank(string.valueof(data.claimDetails.claim)) && !data.claimDetails.claim.isEmpty())  
                                     cs.Claim_id__c = string.valueof(data.claimDetails.claim[0].claimId);
                               
                             }
                             
                             cs.Insurance_Provider_Name__c=cs.Channel_ct__c.toUpperCase();
                                                     
                             
                             List<Case> listExistCs = new List<Case>();
                             listExistCs = [select id,casenumber,Issue_Type__c from case where Trip_ID__c=:trippid and Issue_Type__c='Bus Cancellation' limit 1];
                             if(!listExistCs.isEmpty())
                              {
                                 cs.id = listExistCs[0].id;
                                 res.statuscode = 200;           
                                 resp.caseid = listExistCs[0].caseNumber;
                                 resp.error = 'Claim details has updated successfully in Case';
                                 update cs;
                                 dbl.Complaint_Tracker_Error__c = resp.errorDescription;
                                 insert dbl;
                                 return resp;
                                 
                             }
                     }
                     
                     if('Simplify360'.equalsIgnoreCase(cs.Channel_ct__c)){
                         cs.Ticket_Link__c=data.ticketLink;
                         cs.CaseHistory_Link__c=data.caseHistoryLink;
                         cs.ownerId = [Select id from Group where type='Queue' AND developername='Social_Media_Queue'].id;

                        
                     }
                     
                 }
                 
                
                
                 if(string.isNotBlank(string.valueof(data.issue)))
                 {
                     cs.Issue_Type__c = string.valueof(data.issue).trim();
                     system.debug('----------category------------'+string.valueof(data.category));
                     
                     if(cs.Issue_Type__c =='Exceptional Refund' && cs.parentId==null){
                         resp.error ='You can not create Exceptional Refund case without correct parent case';
                         resp.errorDescription ='You can not create Exceptional Refund case without correct parent case,Please contact SF admin.';
                         return resp;
                     }
 
                     if(cs.Issue_Type__c=='New vehicle- GPS details needed' && cs.Channel_ct__c=='YourBus'){
                         cs.status='Open';
                     }
                 
                     
                     if('NEFT Refund'.equalsIgnoreCase(cs.Issue_Type__c))
                     {
                       cs.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('NEFT Refund').getRecordTypeId();
                       cs.ownerId = [Select id from Group where type='Queue' AND developername='NEFT_Refund_Queue'].id;
                       cs.Case_Index__c=data.paasRefundIndex;
                     }

                     if('NEFT Refund'.equalsIgnoreCase(cs.Issue_Type__c) && String.isNotBlank(string.valueof(data.paasRefundRequestID)))
                     {
                       cs.Request_Id__c= string.valueof(data.paasRefundRequestID);
                     }
                     
                     if('Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c))
                     {
                       cs.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();        
                     }

                     
                     
                     if('eDNC Failed Transaction'.equalsIgnoreCase(data.issue)){
                         resp.error ='You can not create eDNC case.';
                         resp.errorDescription ='You can not create eDNC case,Please contact SF admin.';
                         return resp;
 
                     }
                     
                     if(string.isNotBlank(string.valueof(data.category)))
                     {
                         system.debug('----------category------------'+string.valueof(data.category));
                         cs.Issue_Sub_Category__c = string.valueof(data.category).trim();
                         system.debug('----------category------------'+cs.Issue_Sub_Category__c);
                     }

                     if('Failed refunds'.equalsIgnoreCase(cs.Issue_Type__c) && 'Refund failed in the PaaS system'.equalsIgnoreCase(cs.Issue_Sub_Category__c))
                     {
                       cs.ownerId = [Select id from Group where type='Queue' AND developername='PaSS_Support_team'].id;
                     }
                 }

                 if(string.isNotBlank(cs.My_desk_id__c)){
                    List<String> pairs = system.label.GiMmt_Field_Label_and_Field_API_Mapping.split(',');
                    for (String pair : pairs) {
                        List<String> keyValue = pair.split('=>');
                        if (keyValue.size() == 2) {
                            String key = keyValue[0].trim();
                            String value = keyValue[1].trim();
                            giMMTIssueAndSubIssueType.put(key, value);
                        }
                    }
                    if(giMMTIssueAndSubIssueType.containsKey(data.issue)){
                        cs.Issue_Type__c = giMMTIssueAndSubIssueType.get(data.issue);
                    }
                    if(giMMTIssueAndSubIssueType.containsKey(data.category)){
                        cs.Issue_Sub_Category__c = giMMTIssueAndSubIssueType.get(data.category);
                    }
                    cs.SuppliedCompany=data.myDeskId;
                    cs.type='B2B';
                    cs.ownerId = [Select id from Group where type='Queue' AND developername='MMT_Queue'].id;
                    if(!'Bus Cancellation'.EqualsIgnoreCase(cs.Issue_Type__c)){
                        cs.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MMT').getRecordTypeId();
                    }
                  }
                  
                if(string.isNotBlank(string.valueof(data.country)))
                 {
                     cs.Country_ct__c = string.valueof(data.country);
                 }
                
                 if(string.isNotBlank(string.valueof(data.paasOrderId))){
                         cs.Paas_OrderId__c= data.paasOrderId;
                 }
                 
                 Set<String> setSkipChannels = new Set<String>(System.label.Channel.split(','));
                 List<Case> listExistCases = new List<Case>();
                 
                 if('Bus Cancellation'.EqualsIgnoreCase(cs.Issue_Type__c)&& String.isNotBlank(cs.Transaction_UUID__c))
                     listExistCases= [Select id,casenumber,TAT_Value__c from case where Transaction_UUID__c =:cs.Transaction_UUID__c AND Issue_Type__c=:cs.Issue_Type__c limit 1];
               
                 else if(!'NEFT Refund'.EqualsIgnoreCase(cs.Issue_Type__c) && !'BusHire'.equalsIgnoreCase(busiType) && String.isNotBlank(cs.Trip_Id_ct__c) && String.isNotBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Issue_Sub_Category__c) && !setSkipChannels.contains(cs.Channel_ct__c))
                 {
                     listExistCases= [Select id,casenumber,TAT_Value__c from case where Trip_Id_ct__c =:cs.Trip_Id_ct__c AND Issue_Type__c=:cs.Issue_Type__c AND Issue_Sub_Category__c=:cs.Issue_Sub_Category__c AND Channel_ct__c NOT IN:setSkipChannels limit 1];
                 }else if(cs.Channel_ct__c=='IAS' && 'Bus Cancellation'.EqualsIgnoreCase(cs.Issue_Type__c) && String.isNotBlank(cs.Transaction_UUID__c)){
                     listExistCases= [Select id,casenumber,TAT_Value__c from case where Transaction_UUID__c =:cs.Transaction_UUID__c AND Issue_Type__c=:cs.Issue_Type__c limit 1];
                 }
               else if(cs.Channel_ct__c=='Grievance Officer'){
                     listExistCases= [Select id,casenumber,TAT_Value__c,Issue_Type__c,Issue_Sub_Category__c from case where Issue_Type__c=:cs.Issue_Type__c AND Issue_Sub_Category__c=:cs.Issue_Sub_Category__c and Related_Case_Details__c=:cs.Related_Case_Details__c  limit 1];
                 }
                 else if(cs.Channel_ct__c=='YourBus'){
                     listExistCases= [Select id,casenumber,TAT_Value__c,Issue_Type__c,Issue_Sub_Category__c from case where Channel_ct__c='YourBus' and Vehicle_No__c =:string.valueof(data.busNumber)  limit 1];
                 }
                 else if(String.isNotBlank(cs.Channel_ct__c) && cs.Channel_ct__c=='MMT' || cs.Channel_ct__c=='GI'){
                    listExistCases= [Select id,casenumber,TAT_Value__c,Issue_Type__c,Issue_Sub_Category__c from case where Trip_Id_ct__c =:cs.Trip_Id_ct__c AND Issue_Type__c=:cs.Issue_Type__c AND Issue_Sub_Category__c=:cs.Issue_Sub_Category__c  limit 1];
                 }else if('NEFT Refund'.EqualsIgnoreCase(cs.Issue_Type__c) && String.isNotBlank(cs.Transaction_UUID__c) && String.isNotBlank(cs.Paas_OrderId__c)){
                    listExistCases= [Select id,casenumber,TAT_Value__c from case where Case_Index__c=:cs.Case_Index__c and Paas_OrderId__c=:cs.Paas_OrderId__c and Transaction_UUID__c =:cs.Transaction_UUID__c AND Issue_Type__c=:cs.Issue_Type__c limit 1];
                    if(string.isBlank(cs.Case_Index__c)){
                     listExistCases=[Select id,casenumber,TAT_Value__c from case where Country_ct__c=:cs.Country_ct__c and Issue_Type__c='NEFT Refund' and Transaction_UUID__c =:cs.Transaction_UUID__c ];
                     }
                 }  
                             
                 if(listExistCases.isEmpty())
                 {
                     if(string.isNotBlank(string.valueof(data.report)))
                       cs.Report__c= string.valueof(data.report);
                       
                     if(string.isNotBlank(string.valueof(data.reasonForReport)))
                       cs.Reason_For_Report__c= string.valueof(data.reasonForReport);
                       
                     if(string.isNotBlank(string.valueof(data.complaintMobileNo)))
                        cs.Complaint_Mobile_No__c= string.valueof(data.complaintMobileNo);
                       
                     if(string.isNotBlank(string.valueof(data.complaintEmailId)))
                        cs.Complaint_EmailId__c= string.valueof(data.complaintEmailId);
                     
                     if(string.isNotBlank(string.valueof(data.bookingUserEmail)))
                        cs.Booking_Email_ID__c = string.valueof(data.bookingUserEmail);
                     
                        cs.SourceT__c = string.valueof(data.sourceCity);
                        cs.DestinationT__c = string.valueof(data.destinationCity);   
                        cs.Bus_Operator_Namee__c = string.valueof(data.boName);
                        if(data.doj!=null){
                          cs.SS_DOJ__c =  DateTime.newInstance(data.doj * 1000);
                         } 
                        if(data.fare!=null)
                         cs.Total_Fare_Value__c = double.valueOf(data.fare); 
                     
                     if(string.isNotBlank(string.valueof(data.busNumber)))
                       cs.Vehicle_No__c = string.valueof(data.busNumber);
                     
                       if(string.isNotBlank(string.valueof(data.serviceProviderId)))
                       cs.Service_Providerr_Id__c = string.valueof(data.serviceProviderId);
                     
                     if(string.isNotBlank(string.valueof(data.appVersion)))
                         cs.App_Version__c=string.valueOf(data.appVersion);
                                          
                     if(string.isNotBlank(string.valueof(data.documentNumber)))
                         cs.Document_Number_ctp__c=string.valueOf(data.documentNumber);
                      
                     if(string.isNotBlank(string.valueof(data.bicCode)))
                         cs.BIC_Code__c=string.valueof(data.bicCode);
                         
                     if(string.isNotBlank(string.valueof(data.origin)))
                         cs.Origin = data.origin;
                     else
                         cs.Origin =system.label.Complaint_Tracker_Label;
                     
                     if(string.isNotBlank(string.valueof(data.name)))
                         cs.Name_ct__c = string.valueof(data.name);
                     
                     if(string.isNotBlank(string.valueof(data.pnr)))
                            cs.PNR__c= string.valueof(data.pnr);
                     
                     if(data.claimDetails!=null)  
                     { 
                         cs.Claim_Details__c= string.valueof(json.serialize(data.ClaimDetails));
                         cs.Policy_Id__c = string.valueof(data.ClaimDetails.policyId);
                         
                         if(string.isNotBlank(string.valueof(data.claimDetails.claim)) && !data.claimDetails.claim.isEmpty())  
                             cs.Claim_id__c = string.valueof(data.claimDetails.claim[0].claimId);
                       
                     }
                     
                                            
                     if(string.isNotBlank(string.valueof(data.currencyType)))
                         cs.Price_Paid_Currency_ctp__c=string.valueof(data.currencyType);
 
                         if(string.isNotBlank(string.valueof(data.complaintHistory)))
                         cs.Complaint_Tracker__c=string.valueof(data.complaintHistory);

                         if(string.isNotBlank(string.valueof(data.refundHistory)))
                         cs.Refund_History__c=string.valueof(data.refundHistory);

                         if(string.isNotBlank(string.valueof(data.userType)))
                         cs.User_Type__c=string.valueof(data.userType);
 
                     if(string.isNotBlank(string.valueof(data.tripDetails)))
                         cs.Trip_Details_ct__c = string.valueof(data.tripDetails);                           
 
                     if(string.isNotBlank(string.valueof(data.refundAmount)))
                         cs.Refund_Amount__c = Double.valueOf(data.refundAmount);

                         if(string.isNotBlank(string.valueof(data.giMmtmaxRefundAmount)))
                         cs.Max_Refund_Amount__c = Double.valueOf(data.giMmtmaxRefundAmount);

                        if('Bus Cancellation'.EqualsIgnoreCase(cs.Issue_Type__c)&& String.isNotBlank(cs.My_desk_id__c) && string.isNotBlank(string.valueof(data.giMmtmaxRefundAmount))){
                            cs.Amount__c =  Double.valueOf(data.giMmtmaxRefundAmount);
                        }
 
                     if(string.isNotBlank(string.valueof(data.paasOrderId)))
                         cs.Paas_OrderId__c= data.paasOrderId;
 
                     if(string.isNotBlank(phoneNo) && phoneNo!='null')
                         cs.Phone_No_ct__c = phoneNo;
                     
                      if(data.amount!=null)
                        {
                           cs.AmountD__c=data.amount;
                        }
                        
                      if(data.issue=='DBT'){
                         string amountVal;
                         if(string.isNotBlank(data.amount)){
                             amountVal =data.amount.replace('.','');
                             cs.amount__c=double.valueOf(amountVal);
                             }
                         cs.ID_ctp__c=data.dbtId;
                         cs.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('DBT').getRecordTypeId();
                      }
                      
                     
                        
                        if(string.isNotBlank(string.valueof(data.bankName))){
                          cs.Bank_Name__c=data.bankName;
                        }
                      
 
                     if(string.isNotBlank(emailId))
                     {
                         cs.Email_Complaint_Tracker__c = emailId;
                         if(validateEmail(emailId))
                         { 
                             cs.Email_Id_ct__c = emailId;
                             cs.SuppliedEmail = emailId;
                         }
                     }
 
                     if(string.isNotBlank(string.valueof(data.businessUnit)) && !'RDC'.equalsIgnoreCase(data.country))
                     {
                         cs.Business_Unit_ct__c = 'Bus'.equalsIgnoreCase(string.valueof(data.businessUnit))?String.isNotBlank(string.valueof(data.country))?'REDBUS_'+string.valueof(data.country).left(2):'REDBUS_IN':string.valueof(data.businessUnit);
                         cs.country__c=String.isNotBlank(OrderItemTransactionResource__c.getValues(cs.Business_Unit_ct__c).Case_Country__c)?OrderItemTransactionResource__c.getValues(cs.Business_Unit_ct__c).Case_Country__c:'';
                         cs.Business_Type__c=OrderItemTransactionResource__c.getValues(cs.Business_Unit_ct__c).Case_Business_Type__c;
                     }else if('RDC'.equalsIgnoreCase(data.country)){
                         string busUnit='REDBUS_COM';
                         cs.Business_Unit_ct__c=busUnit;
                         cs.country__c=OrderItemTransactionResource__c.getValues(busUnit).Case_Country__c;
                         cs.Business_Type__c=OrderItemTransactionResource__c.getValues(busUnit).Case_Business_Type__c;
                     }
                     
                     if(string.isNotBlank(string.valueof(data.channel)))
                     {
                        cs.Channel_ct__c = string.valueof(data.channel);
                        dbl.Linking_Process_Status__c = cs.Channel_ct__c;
                     }
                      if(string.isNotBlank(string.valueof(data.country)) && string.isNotBlank(string.valueof(data.channel)) && string.valueof(data.channel).contains('WHITE_LABEL_WEB') && !'RDC'.equalsIgnoreCase(data.country))
                     {                      
                          cs.country__c=string.valueOf(data.country);
                          System.debug('c-->'+cs.Business_Unit_ct__c);
                          cs.Business_Unit_ct__c =OrderItemTransactionResource__c.getValues(cs.Business_Unit_ct__c).Name;                     
                          cs.Business_Type__c=OrderItemTransactionResource__c.getValues(cs.Business_Unit_ct__c).Case_Business_Type__c;                    
                     }
                     
                     
                     if(string.isNotBlank(string.valueof(data.country)))
                     {
                         cs.Country_ct__c = string.valueof(data.country);
                     }
 
                     if(string.isNotBlank(string.valueof(data.complaint)))
                     {
                         if('NEFT Refund'.equalsIgnoreCase(data.issue) && string.valueof(data.complaint).contains('|'))
                         {
                             System.debug('data.complaint...'+data.complaint);
                             list<String> neftDet = string.valueof(data.complaint).split('\\|');
                             System.debug('data.neftDet ...'+neftDet );
                             cs.Account_Number__c = neftDet[0];
                             cs.Bank_Name__c = neftDet[1];
                             cs.IFSC_Code__c = neftDet[2];
                             cs.Account_Holder_Name__c = neftDet[3];                             
                         }
                         else
                          cs.Description = string.valueof(data.complaint);
                     }
 
                     if(string.isNotBlank(string.valueof(data.dateSubmitted)))
                     {
                         if(string.valueof(data.dateSubmitted).contains('T'))
                         {
                             cs.Date_Submitted_ct__c = datetime.valueof((string.valueof(data.dateSubmitted)).replace('T',' '));
                         }
                         else
                         {
                             cs.Date_Submitted_ct__c = datetime.valueof(string.valueof(data.dateSubmitted));
                         }
                     }
                     
                     if(string.isNotBlank(string.valueof(data.droppingTime))){
                        if(string.valueof(data.droppingTime).contains('T')){
                            cs.SH_Dropping_Time__c = datetime.valueof((string.valueof(data.droppingTime)).replace('T',' '));
                        }else{
                            cs.SH_Dropping_Time__c = datetime.valueof(string.valueof(data.droppingTime));
                        }

                     }
                     if(String.isNotBlank(busiType) && 'BusHire'.equalsIgnoreCase(busiType))
                     {
                         cs.Business_Type__c='BusHire';
                         if(String.isNotBlank(String.valueOf(data.tCode)))
                         {
                             cs.Lead_TCode__c = String.valueOf(data.tCode);
                             List<Lead> listLeads = new List<Lead>();
                             listLeads = [Select id,SrcCityName__c,DestCityName__c,DOJStart__c,Phone,email,Operator_Name__c,Region__c from Lead where TCode__c=:cs.Lead_TCode__c];
                             cs.Lead__c = listLeads.isEmpty()?null:listLeads[0].id;
                             cs.SourceT__c=listLeads.isEmpty()?null:listLeads[0].SrcCityName__c;
                             cs.DestinationT__c=listLeads.isEmpty()?null:listLeads[0].DestCityName__c;
                             cs.Bus_Operator_Namee__c=listLeads.isEmpty()?null:listLeads[0].Operator_Name__c;
                             cs.Email_Id_ct__c=listLeads.isEmpty()?null:listLeads[0].Email;
                             cs.Region__c=listLeads.isEmpty()?null:listLeads[0].Region__c;
                             cs.SS_DOJ__c=listLeads.isEmpty()?null:listLeads[0].DOJStart__c;
                             cs.Phone_No_ct__c =listLeads.isEmpty()?null:listLeads[0].Phone;
                            /* cs.Bus_Operator_Namee__c=listLeads.isEmpty()?null:listLeads[0].Operator_Name__c;      
                             cs.Did_you_have_a_hassle_free_journey__c =data.hasslefreejourney!=null?data.hasslefreejourney:false;
                             cs.Checked_at_borders_for_e_pas_social_Dist__c =data.epassandsocialdistancing!=null?data.epassandsocialdistancing:false;
                             cs.Driver_wear_a_mask_during_the_journey__c =data.driverwearmask!=null?data.driverwearmask:false;
                             cs.Vehicle_have_a_sanitizer_driver_provide__c =data.vehicledriversanitizer!=null?data.vehicledriversanitizer:false;
                             cs.Did_the_vehicle_look_clean_sanitized__c =data.vehiclelookcleansanitized!=null?data.vehiclelookcleansanitized:false;
                             cs.Customer_Rating__c = data.ratejourney;*/
                             cs.Bus_type_other_features_satisfactory__c =data.btypeSatisfactory!=null?data.btypeSatisfactory:false;
                             cs.Did_the_bus_arrived_on_time__c =data.arrivedOnTime!=null?data.arrivedOnTime:false;
                             cs.Did_the_bus_depart_on_time__c =data.deptOnTime!=null?data.deptOnTime:false;
                             cs.ownerId = [Select id from Group where type='Queue' AND developername='Bus_Hire_InTrip_FeedBack'].id;
                             if(cs.Bus_type_other_features_satisfactory__c && cs.Did_the_bus_arrived_on_time__c && cs.Did_the_bus_depart_on_time__c)
                             {
                                 cs.status = 'Closed';
                                 cs.ownerId = [Select id from Group where type='Queue' AND developername='Closed_Cases_Queue'].id;
                            }
                         }
                 
                     }
                     
                    if(String.isNotBlank(String.valueOf(data.status)) && String.valueOf(data.status)=='Closed'){
                       cs.status='Closed';
                    }
                    
                    /* if(string.isNotBlank(cs.ZM_Name__c) && 'MMT'.equalsIgnoreCase(data.channel)){
                        cs.status='Escalate to Support';
                        cs.ownerId=[Select id from Group where type='Queue' AND developername='Escalated_to_Fullfillment'].id;
                        cs.Business_Type__c='MMT_cab';
                     }*/
                     
                    if(String.valueOf(data.country)=='RDC'){
                        cs.ownerId = [Select id from Group where type='Queue' AND developername='Redbus_Com_Queue'].id;
                    }
                    
                    if(cs.Channel_ct__c=='Grievance Officer'){
                        cs.ownerId = [Select id from Group where type='Queue' AND developername='Grievance_Officer_queue'].id;
                    }
                    if(cs.Business_Unit_ct__c =='REDBUS_RAILS_IN' || cs.Business_Unit_ct__c =='REDRAILS_IN' || data.businessUnit=='REDBUS_RAILS_IN' || data.businessUnit=='REDRAILS_IN'){
                        cs.ownerId =[Select id from Group where type='Queue' AND developername='redrailsupport'].id;
                    }

                    if(cs.Business_Unit_ct__c =='REDBUS_ONDC_METRO' || data.businessUnit=='REDBUS_ONDC_METRO'){
                        Id metroRecTypeId = Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosByName().get('ONDC Metro').getRecordTypeId();
                        cs.RecordTypeId = metroRecTypeId;
                        cs.ownerId =[Select id from Group where type='Queue' AND developername='ONDC_Suppport'].id;
                    }
                    

                    if(data.businessUnit=='REDBUS_ONDC_MOBILITY'){
                        cs.ownerId =[Select id from Group where type='Queue' AND developername='ONDC_Suppport'].id;
                        Id autoRecTypeId = Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosByName().get('ONDC Mobility').getRecordTypeId();
                        cs.RecordTypeId = autoRecTypeId;
                    }
                    
                   if(String.valueOf(data.country)=='Vietnam' || String.valueOf(data.country)=='VNM'){
                        cs.ownerId = [Select id from Group where type='Queue' AND developername='Vietnam_Support_Queue'].id;
                    }
                    
                     map<string,Order_Items__c> tripMap = new map<string,Order_Items__c>();      
                     List<Order_Items__c> ListOI = new List<Order_Items__c>();
                     if(String.isNotBlank(tin))
                          ListOI = [Select id,Customer_Name__c,Primary_Contact_Customer__c,ID__c,Order_Id__c,Order_Item_Reference_No__c,Guid__c from Order_Items__c where Order_Item_Reference_No__c=:tin AND Flag__c = 0];
                     else if(String.isNotBlank(tripid))
                          ListOI = [Select id,Customer_Name__c,Primary_Contact_Customer__c,ID__c,Order_Id__c,Order_Item_Reference_No__c,Guid__c from Order_Items__c where Order_Id__c=:tripid AND Flag__c = 0];
                     else if(String.isNotBlank(cs.Transaction_UUID__c))
                          ListOI = [Select id,Customer_Name__c,Primary_Contact_Customer__c,ID__c,Order_Id__c,Order_Item_Reference_No__c,Guid__c from Order_Items__c where Guid__c=:cs.Transaction_UUID__c AND Flag__c = 0];
 
                     if(!ListOI.isEmpty())
                         {
                             tripMap.put(ListOI[0].Order_Item_Reference_No__c,ListOI[0]);
                             tripMap.put(ListOI[0].Order_Id__c,ListOI[0]);
                             tripMap.put(ListOI[0].Guid__c,ListOI[0]);
                         }    
                    if(!ListOI.isEmpty() && (tripMap.Keyset().Contains(tin) || tripMap.Keyset().Contains(tripid) || tripMap.Keyset().Contains(cs.Transaction_UUID__c) ))
                      {
                        String tinTripKey = tripMap.Keyset().Contains(tin)?tin:tripid;   
                        if(string.isBlank(tinTripKey))
                            tinTripKey=cs.Transaction_UUID__c;
                        cs.Transaction_ID__c = tripMap.get(tinTripKey).id; 
                      } 
                                          
                     Database.DMLOptions dmo = new Database.DMLOptions();
                     dmo.assignmentRuleHeader.useDefaultRule= true;
                     dmo.EmailHeader.triggerAutoResponseEmail = true;
                     cs.setOptions(dmo);
                   
                     Database.saveResult insertResult = Database.insert(cs,false);
                     system.debug('----------insertResult------------'+insertResult);
                   
                    list<attachment> attachmentToInsert = new list<attachment>();
                    String caseNumbersList;
                    String tinNumberList;
                    string insertedCaseId;
                   
                         if(insertResult.isSuccess())
                         {
                             dbl.Orders_Process_Status__c = 'Case Insert Success';
                             res.statuscode = 200;
                             case inserCs= [Select id,CaseNumber,TAT_Value__c,SS_DOJ__c,TIN_No__c,Transaction_ID__c,Trip_Id_ct__c,Issue_Type__c,Issue_Sub_Category__c,My_Desk_Id__c,PNR__c from Case Where id =:insertResult.getId()];
                             if('Bus Cancellation'.equalsIgnoreCase(inserCs.Issue_Type__c) && 'Initiate Bus Cancellation'.equalsIgnoreCase(inserCs.Issue_Sub_Category__c) && String.isNotBlank(inserCs.My_Desk_Id__c)){
                                giMmtCtrl.initiateSSBusCancellation(inserCs.Id);
                            }

                            if(String.isNotBlank(inserCs.My_Desk_Id__c) && String.isNotBlank(inserCs.PNR__c) && string.isBlank(inserCs.Transaction_ID__c)){
                                System.debug(':: To sync the transaction');
                                giMmtCtrl.pushToRedisB2b(inserCs.PNR__c);
                            }
                             insertedCaseId = string.valueOf(insertResult.getId());
                             caseNumbersList=String.valueOf(inserCs.CaseNumber);
                             tinNumberList=String.valueOf(inserCs.Trip_Id_ct__c);
                             resp.caseid = inserCs.CaseNumber;
                             resp.tatVal=string.valueOf(inserCs.TAT_Value__c);
                             resp.error ='';
                             resp.errorDescription ='';
                             dbl.Order_Items_Process_Status__c = resp.caseid;
                             if(string.isNotBlank(data.caseComment)){
                             casecomment cc=new casecomment();
                               cc.parentId=inserCs.id;
                               cc.commentbody=string.valueOf(data.caseComment);
                               insert cc;
                              }
                            // To create a exceptionalRefund case coming from SH //CRM-1381
                            if(String.isNotBlank(string.valueOf(data.shBoltInstantRefund)) && data.shBoltInstantRefund){
                                system.debug(':: DroppingTime ::: '+cs.SH_Dropping_Time__c);
                                if(!string.isBlank(string.valueOf(cs.SH_Dropping_Time__c))){
                                    if(cs.SH_Dropping_Time__c < system.now()){
                                        CreateExceptionalRefundCase(caseNumbersList,tinNumberList);
                                        //Query to verify exceptional refund case is created or not.
                                        List<case> CaseList = [SELECT Id FROM Case WHERE Issue_Type__c = 'Exceptional Refund' AND Issue_Sub_Category__c = 'Instant refund - Collectible from BO' AND (Channel_ct__c='SelfHelpBot' OR Channel_ct__c = 'IVR-Ameyo') AND Refund_Type__c = 'Instant resolution with refund' AND parentID=:insertedCaseId];
                                        if(!CaseList.isEmpty()){
                                            string Query =[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'selfHelpBoltAutomationCases'].QueryDetails__c + ' AND parentID = \''+insertedCaseId+ '\' limit 1';
                                            System.debug('::Query:: '+Query);
                                            approveSHExceptionalRefundClass.invokeApprovalAPI(Query);
                                        }
                                    }else{
                                        CreateExceptionalRefundCaseFuture.createSHExceptionCase(caseNumbersList,tinNumberList);
                                        
                                    }                                    
                                }
                            }
                             
                             linkToAccountContacts(insertResult.getId(),tin,tripid,cs.Phone_No_ct__c,cs.Email_Id_ct__c,cs.Email_Complaint_Tracker__c);
                           //  Attachment
                                 System.debug('Attachment Values:'+data.attachments);
                                 if(data.attachments!=null && data.attachments.size()>0 ){ 
                                     system.debug('dataattachments-->>'+data.attachments.size());
                                     for (Attach  att :data.attachments)                                   
                                          attachmentToInsert.add( new Attachment(parentId = insertResult.getId(), name = att.name, ContentType = att.ContentType,Body= EncodingUtil.base64Decode(att.body)));                                   
                                      }    
                                 insert  attachmentToInsert;  
                                 System.debug('attachmentToInsert:'+attachmentToInsert);
                               
                         }
                         else
                         {
                             dbl.Orders_Process_Status__c = 'Case Insert Failed';
                             res.statuscode = 417;
                             resp.error ='Unable to process the request';
                             resp.errorDescription = string.valueof(insertResult.getErrors());
                             dbl.Complaint_Tracker_Error__c = resp.errorDescription;
                         }
                   
                     } // Create a case when no case exists end
                     else
                     {
                          dbl.Orders_Process_Status__c = 'Duplicate Case Found With Same Details-'+listExistCases[0].casenumber;
                          res.statuscode = 417;
                          resp.error ='Case Is Already Exists With Same Details';
                          resp.errorDescription ='Case Is Already Exists With Same Details';
                          dbl.Complaint_Tracker_Error__c = resp.errorDescription+'-'+listExistCases[0].casenumber;
                          resp.oldCaseNumber = listExistCases[0].casenumber;
                          resp.tatVal=string.valueOf(listExistCases[0].TAT_Value__c);
                         
                     }
                     
                 } 
                else
                 {
                      dbl.Orders_Process_Status__c = 'Invalid Input Received';
                      res.statuscode = 400;
                      resp.error ='Invalid Input Received';
                      resp.errorDescription ='Invalid Input Received';
                      dbl.Complaint_Tracker_Error__c = resp.errorDescription;
                 }
         
         } // Try end
         catch(exception e)
         {
            System.debug('::Exception = '+e);
            System.debug('::Exception LineNumber = '+e.getLineNumber());
             res.statuscode = 400;           
             resp.error ='Not able to process request';
             resp.errorDescription = string.valueof(e);
             dbl.Complaint_Tracker_Error__c = resp.errorDescription;
         }
         
          
          if(string.valueof(resp).length()<10000)
             dbl.Response_Received__c = String.valueOf(resp);
           else
              dbl.Response_Received__c = String.valueOf(resp).substring(0,10000); 
              
         insert dbl;
         return resp;
     }
     public class Attach {
         String Body;
         String ContentType;
         String Name;
         String Type;
     }
     
     public class Claim{
       public string claimType;
       public string claimId;
     }
     
     public  class ClaimDetails{
       public string policyId;
       public list<Claim> claim;
       
     }
     global class CaseInformation
     {
         public string name;
         public string phoneNo;
         public string emailId;
         public string issue;
         public string category;
         public string categoryVal;
         public string tripId;
         public string orderItemId;
         public string orderUUId;
         public string orderItemUUId;
         public string tin;
         public string tripDetails;
         public string complaint;
         public string dateSubmitted;
         public string businessUnit;
         public string channel;
         public string country;        
         public string origin;
         public string currencyType;
         public string paasOrderId;
         public Double refundAmount;
         public string businessType;
         public Boolean arrivedOnTime;
         public Boolean deptOnTime;
         public Boolean btypeSatisfactory;
         public Boolean hasslefreejourney;
         public Boolean epassandsocialdistancing;
         public Boolean driverwearmask;
         public Boolean vehicledriversanitizer;
         public Boolean vehiclelookcleansanitized;
         public Boolean shBoltInstantRefund;
         public string droppingTime;
         public string ratejourney;
         public String tCode;
         public string amount;
         public string bankName;
         public string pnr;
         public string documentNumber;
        //  public string subIssue;
         public string bicCode;
         public string bookingUserEmail;
         public string appVersion;
         public string serviceProviderId;
         public string busNumber;
         public string report;
         public string reasonForReport;
         public string complaintMobileNo;
         public string complaintEmailId;
         public string boNumber;
         public string sessionId;
         public ClaimDetails claimDetails;
         Public  list<Attach> attachments;
         public string status;
         public string caseComment;
         public string myDeskId;
         public string giMmtmaxRefundAmount;
         public string paasRefundRequestID;
         public string dbtId;
         public string disbursalId;
         public string hft;
         public boolean userHasTravelled;
         public string selectedIssues;
         public string otherIssue;
         public string bookingId;
         public string vendorName;
         public string zmName;
         public string vendorResol;
         public string sopResol;
         public string attachmentURLs;
         public string relatedCaseDetails;
         public string refundType;
         public string parentCasenumber;
         public string sourceCity;
         public string destinationCity;
         public integer doj;
         public string busType;
         public double fare;
         public string boName;
         public string ticketLink;
         public string caseHistoryLink;
         public string complaintHistory;
         public string refundHistory;
         public string userType;
         public string paasRefundIndex;
     }
 
     global class response
     {
         string caseid;
         string error;
         string errorDescription;
         string oldCaseNumber;
         string tatVal;
         
         public response()
         {
 
         }
     }
     global static Boolean validateEmail(String email) 
     {
         Boolean res = true;
         //String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
         String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
         Pattern MyPattern = Pattern.compile(emailRegex);
         Matcher MyMatcher = MyPattern.matcher(email);
         if (!MyMatcher.matches()) 
         res = false;
         return res; 
     }
     
     @future
     private static void linkToAccountContacts(String csId,String tin,String tripid,String phoneNo,String emailId,String emailIdCT)
     {
         Case cs = new Case(Id=csId);
         map<string,Order_Items__c> tripMap = new map<string,Order_Items__c>();
         map<string,account> accMap = new map<string,account>();
         map<string,contact> cMap = new map<string,contact>();
         
         List<Order_Items__c> ListOI = new List<Order_Items__c>();
 
         if(String.isNotBlank(tin))
             ListOI = [Select id,Customer_Name__c,Primary_Contact_Customer__c,ID__c,Order_Id__c,Order_Item_Reference_No__c from Order_Items__c where Order_Item_Reference_No__c=:tin AND Flag__c = 0];
 
         else if(String.isNotBlank(tripid))
             ListOI = [Select id,Customer_Name__c,Primary_Contact_Customer__c,ID__c,Order_Id__c,Order_Item_Reference_No__c from Order_Items__c where Order_Id__c=:tripid AND Flag__c = 0];
 
         if(!ListOI.isEmpty())
         {
         tripMap.put(ListOI[0].Order_Item_Reference_No__c,ListOI[0]);
         tripMap.put(ListOI[0].Order_Id__c,ListOI[0]);
         }    
 
         if(!ListOI.isEmpty() && (tripMap.Keyset().Contains(tin) || tripMap.Keyset().Contains(tripid)))
         {
             String tinTripKey = tripMap.Keyset().Contains(tin)?tin:tripid;
             cs.Accountid = tripMap.get(tinTripKey).Customer_Name__c;
             cs.Customer_Name__c = tripMap.get(tinTripKey).Primary_Contact_Customer__c;
            // cs.Transaction_ID__c = tripMap.get(tinTripKey).id; 
         }
         
         else if(ListOI.isEmpty() && ((phoneNo!='null' && String.isNotBlank(phoneNo)) || String.isNotBlank(emailIdCT)))
         {
             String strQry = 'Select id,PersonMobilePhone, PersonEmail,User_Id__c from account where ';
             String strConQry = '';
             
             if(String.isNotBlank(phoneNo))
                 strQry = strQry+ ' PersonMobilePhone =\''+ phoneNo+'\'OR ';
             
             if(String.isNotBlank(emailIdCT))
             {
                 strQry = strQry+'PersonEmail=\''+emailIdCT+'\'';
                 strConQry = 'Select id, email, Account_name__c,Account_name__r.User_Id__c from contact where Email=\''+emailIdCT+'\' limit 1';
             }
             
             strQry = strQry.removeEnd('OR ').removeEnd('where ');
 
             System.debug(' strQry ...'+strQry); 
             
             for(account ac: DataBase.query(strQry))
             {
                 if(string.isNotBlank(ac.PersonMobilePhone))
                     accMap.put(ac.PersonMobilePhone,ac);
                 if(string.isNotBlank(ac.PersonEmail))
                     accMap.put(ac.PersonEmail,ac);
             }
 
             if(accMap.Keyset().Contains(phoneNo))
             {
                 system.debug('------------cs.Phone_No_ct__c---------------');
                 if(!string.IsBlank(string.valueof(accMap.get(phoneNo).User_Id__c)))
                     cs.Accountid = accMap.get(phoneNo).id; 
                 else
                     cs.Customer_Name__c = accMap.get(phoneNo).id; 
                 system.debug('------------cs.Accountid---------------'+cs.Accountid+'..'+cs.Customer_Name__c);
             }
             else if(accMap.Keyset().Contains(emailId))
             {
                 system.debug('------------emailId---------------');
                 if(!string.IsBlank(string.valueof(accMap.get(emailId).User_Id__c)))
                     cs.Accountid = accMap.get(emailId).id; 
                 else
                     cs.Customer_Name__c = accMap.get(emailId).id; 
                 system.debug('------------cs.Accountid---------------'+cs.Accountid); 
             }
             else
             {
                 System.debug('strConQry...'+strConQry);
                 if(String.isNotBlank(strConQry))
                 {
                     for(Contact c:DataBase.query(strConQry))
                     {
                         if(!string.isBlank(string.valueof(c.email)))
                             cMap.put(c.email,c);
                     }
                 }
                 
                 if(cMap.Keyset().Contains(emailId))
                 {
                     system.debug('------------emailId---------------');
                     if(!string.IsBlank(string.valueof(cMap.get(emailId).Account_name__r.User_Id__c)))
                         cs.Accountid = cMap.get(emailId).Account_name__c; 
                     else
                         cs.Customer_Name__c = cMap.get(emailId).Account_name__c; 
                 }   
                 system.debug('------------cs.Accountid---------------'+cs.Accountid);
             }
         }
         
         try
         {
             update cs;
         }
         Catch(Exception e)
         {
             System.debug('Case liniking has failed..'+e);
         }
     }
        //CRM-1381 Method to create Exceptional refund case called by slefhelp
        public static void CreateExceptionalRefundCase(string caseNumberList,string tinNumber){
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            List<CaseComment> caseCommentListToInsert = New List<CaseComment>();
            dbl.Type__c = 'SelfHel Exceptional Refund Case';
            List<Case> listCases = [SELECT id,Transaction_ID__c, Order_UUId__c, Date_Submitted_ct__c, SH_Dropping_Time__c,Business_Unit_ct__c, Booking_Email_ID__c, TIN_No__c, Trip_Id_ct__c, Refund_Type__c, Refund_Amount__c FROM Case WHERE caseNumber = :caseNumberList LIMIT 1];
            System.debug('::: listCases ::: ' + listCases);
            Case cs = new Case();
            cs.Issue_Type__c = 'Exceptional Refund';
            list<case> listExpRefndCase = [SELECT id, status, Booking_Email_ID__c, Date_Submitted_ct__c, createddate, Refund_status__c, Exceptional_Refund_Count__c, Transaction_ID__c,Trip_Id_ct__c,TIN_No__c FROM Case WHERE Issue_Type__c = 'Exceptional Refund' AND Refund_status__c = 'Exceptional Refund Approved' AND Trip_Id_ct__c = :tinNumber ORDER BY createddate DESC];
            List<user> userInfo = [SELECT id, Team__c FROM user WHERE id = :userinfo.getuserid() LIMIT 1];
            if (listExpRefndCase.size() == 0) {
                cs.Exceptional_Refund_Count__c = 1;
            }else if (!listExpRefndCase.isEmpty() && listExpRefndCase.size() == 1 && listExpRefndCase[0].Exceptional_Refund_Count__c == null){
                cs.Exceptional_Refund_Count__c = 2;
            } else if (!listExpRefndCase.isEmpty() && listExpRefndCase[0].Exceptional_Refund_Count__c != null){
                cs.Exceptional_Refund_Count__c = listExpRefndCase[0].Exceptional_Refund_Count__c + 1;
            }

            cs.Issue_Sub_Category__c = 'Instant refund - Collectible from BO';
            cs.Trip_Id_ct__c = listCases[0].Trip_Id_ct__c;
            cs.TIN_No__c = listCases[0].TIN_No__c;
            if(!Test.isRunningTest()){
                cs.Refund_Amount__c = listCases[0].Refund_Amount__c.setScale(2); 
            }
            cs.Transaction_ID__c = listCases[0].Transaction_ID__c;
            cs.status = 'Open';
            cs.Booking_Email_ID__c = listCases[0].Booking_Email_ID__c;
            cs.OwnerId = System.Label.ExceptionalRefundQueueId;
            cs.Origin = 'InBound Call';
            cs.Subject = 'Exceptional Refund- Self help BOLT Refund';
            cs.ParentId = listCases[0].id;
            cs.Business_Unit_ct__c = listCases[0].Business_Unit_ct__c;
            cs.User_Level_Team__c = userInfo[0].Team__c;
            cs.Refund_Type__c = 'Instant resolution with refund';
            cs.SH_Dropping_Time__c = listCases[0].SH_Dropping_Time__c;
            cs.Date_Submitted_ct__c = listCases[0].SH_Dropping_Time__c;
            cs.Channel_ct__c = 'SelfHelpBot';
            cs.Order_UUId__c = listCases[0].Order_UUId__c;
            listCases[0].Refund_Type__c = 'Instant resolution with refund';
            listCases[0].Channel_ct__c = 'SelfHelpBot';
            if ('REDBUS_COM'.equalsIgnoreCase(listCases[0].Business_Unit_ct__c)) {
                cs.country__c = OrderItemTransactionResource__c.getValues(listCases[0].Business_Unit_ct__c).Case_Country__c;
                cs.Business_Type__c = OrderItemTransactionResource__c.getValues(listCases[0].Business_Unit_ct__c).Case_Business_Type__c;
            }else{
                String conBusUnit ='REDBUS_' + listCases[0].Business_Unit_ct__c.split('_')[1];
                cs.Business_Type__c = OrderItemTransactionResource__c.getValues(conBusUnit).Case_Business_Type__c;
                cs.country__c = OrderItemTransactionResource__c.getValues(conBusUnit).Case_Country__c;
            }
            try {
                insert cs;

                CaseComment exceComment = new CaseComment();
                exceComment.ParentId = cs.id;
                exceComment.commentBody = 'Instant refund - exceptional refund case created by BOT';
                caseCommentListToInsert.add(exceComment);

                CaseComment parentCaseComment = new CaseComment();
                parentCaseComment.ParentId = listCases[0].id;
                parentCaseComment.commentBody = 'Instant refund - case created by BOT';
                caseCommentListToInsert.add(parentCaseComment);

                update listCases[0];
                dbl.Payment_Sessions_Success__c = 'Success';
            }catch(Exception de){
                dbl.Exception_Description__c = String.valueOf(de);
            }
            insert dbl;

            if(!caseCommentListToInsert.isEmpty()){
                insert caseCommentListToInsert;
            }
        }
}