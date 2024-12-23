@RestResource(urlMapping='/redBus/ComplaintTrackerPeru/*')
global without sharing class API_Complaint_Tracker_Peru
{
   
    @HttpPost
    global static response doPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        system.debug('-----------data-------'+req);
        response resp = new response();
        system.debug(LoggingLevel.ERROR, req.requestBody.toString());
        try
        {
            CaseInformation data = new CaseInformation();
            data = (CaseInformation)JSON.deserialize(req.requestBody.toString(),CaseInformation.class);
            List<Case> caselst = new List<Case>();
            if(!string.isBlank(string.valueof(data)))
            {
                case ct = new case();
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                Database.DMLOptions autoResponseOptions = new Database.DMLOptions(); 
                autoResponseOptions.EmailHeader.triggerAutoResponseEmail = true; 
                //Id recTypeId = Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosByName().get('Complaint Tracker').getRecordTypeId();
                //system.debug('---------recTypeId----------------'+recTypeId);
                ct.RecordTypeId = system.label.Complaint_Tracker_Peru_Record_Type_ID;
                ct.Origin = system.label.Complaint_Tracker_Peru_Origin;
                ct.setOptions(dmo);
                if(!string.isBlank(string.valueof(data.Type)))
                {
                    ct.Type_ctp__c = string.valueof(data.Type);
                }
                if(!string.isBlank(string.valueof(data.FullName)))
                {
                    ct.Name_ct__c = string.valueof(data.FullName);
                }
                if(!string.isBlank(string.valueof(data.ID)))
                {
                    ct.ID_ctp__c = string.valueof(data.ID);
                }
                if(!string.isBlank(string.valueof(data.Date_Incident)))
                {
                    if(string.valueof(data.Date_Incident).contains('T'))
                    {
                        ct.Date_Incident_ctp__c = datetime.valueof((string.valueof(data.Date_Incident)).replace('T',' '));
                    }
                    else
                    {
                        ct.Date_Incident_ctp__c = datetime.valueof(string.valueof(data.Date_Incident));
                    }
                }
                if(!string.isBlank(string.valueof(data.Registered_name)))
                {
                    ct.Registered_Name_ctp__c = string.valueof(data.Registered_name);
                }
                if(!string.isBlank(string.valueof(data.Document_number)))
                {
                    ct.Document_Number_ctp__c = string.valueof(data.Document_number);
                }
                if(!string.isBlank(string.valueof(data.Residence)))
                {
                    ct.Residence_ctp__c = string.valueof(data.Residence);
                }
                if(!string.isBlank(string.valueof(data.Phone)))
                {
                    ct.Phone_No_ct__c = string.valueof(data.Phone);
                }
                if(!string.isBlank(string.valueof(data.Department)))
                {
                    ct.Department_ctp__c = string.valueof(data.Department);
                }
                if(!string.isBlank(string.valueof(data.Department)))
                {
                    ct.Department_ctp__c = string.valueof(data.Department);
                }
                if(!string.isBlank(string.valueof(data.Email)))
                {
                    if(validateEmail(string.valueof(data.Email)))
                    { 
                        ct.Email_Id_ct__c = string.valueof(data.Email);
                        ct.SuppliedeMail = string.valueof(data.Email);
                    }
                    else
                    {
                        ct.Email_Id_ct__c = string.valueof(data.Email);
                    }
                }
                if(!string.isBlank(string.valueof(data.Province)))
                {
                    ct.Province_ctp__c = string.valueof(data.Province);
                }
                if(!string.isBlank(string.valueof(data.District)))
                {
                    ct.District_ctp__c = string.valueof(data.District);
                }
                if(!string.isBlank(string.valueof(data.IsMinor)))
                {
                    ct.Is_Minor_ctp__c = boolean.valueof(data.IsMinor);
                }
                if(!string.isBlank(string.valueof(data.Guardian_Fullname)))
                {
                    ct.Guardian_Full_Name_ctp__c = string.valueof(data.Guardian_Fullname);
                }
                if(!string.isBlank(string.valueof(data.Guardian_ID)))
                {
                    ct.Guardian_ID_ctp__c = string.valueof(data.Guardian_ID);
                }
                if(!string.isBlank(string.valueof(data.Guardian_Email)))
                {
                    if(validateEmail(string.valueof(data.Email)))
                    { 
                        ct.Guardian_Email_ctp__c = string.valueof(data.Guardian_Email);
                    }
                }
                if(!string.isBlank(string.valueof(data.Claim_Type)))
                {
                    ct.Claim_Type_ctp__c = string.valueof(data.Claim_Type);
                }
                if(!string.isBlank(string.valueof(data.ContractedGood)))
                {
                    ct.Contracted_Good_ctp__c = string.valueof(data.ContractedGood);
                }
                if(!string.isBlank(string.valueof(data.PricePaid)))
                {
                    ct.Price_Paid_ctp__c = double.valueof(data.PricePaid);
                }
                if(!string.isBlank(string.valueof(data.PricePaidCurrency)))
                {
                    ct.Price_Paid_Currency_ctp__c = string.valueof(data.PricePaidCurrency);
                }
                if(!string.isBlank(string.valueof(data.Answer_Received)))
                {
                    ct.Answer_Received_ctp__c = string.valueof(data.Answer_Received);
                }
                if(!string.isBlank(string.valueof(data.DetailOfService)))
                {
                    ct.Details_of_Service_ctp__c = string.valueof(data.DetailOfService);
                }
                if(!string.isBlank(string.valueof(data.DetailsOdComplaint)))
                {
                    ct.Details_of_Complaint_ctp__c = string.valueof(data.DetailsOdComplaint);
                }
                
                ct.Issue_Type__c='Book of complaints';
                ct.Issue_Sub_Category__c='I have a complaint';
                caselst.add(ct);
            }
            else
            {
                resp.error ='Not able to process request';
                resp.errorDescription = 'Case Information Missing..!!!';
            }
            Database.saveResult[] insertResult = Database.insert(caselst,false);
            system.debug('----------insertResult------------'+insertResult);
            String caseids;
            String errors;
            List<String> casenumbers = new List<String>();
            for(Integer i=0;i<insertResult.size();i++)
            {
                
                if(insertResult.get(i).isSuccess())
                {
                    caseids = insertResult.get(i).getId();
                    
                    resp.caseid = [Select CaseNumber FRom Case WHERE id=:caseids LIMIT 1].CaseNumber;
                }
                else
                {
                    resp.error ='Not able to process request';
                    resp.errorDescription = string.valueof(insertResult.get(i).getErrors());
                }
            }
     
        }
        catch(exception e)
        {
            resp.error ='Not able to process request';
            resp.errorDescription = string.valueof(e);
        }
        return resp;
    }
    global class CaseInformation
    {
        public string Type;
        public string FullName;
        public string ID;
        public string Registered_name;
        public string Document_number;
        public string Residence;
        public string Phone;
        public string Department;
        public string Province;
        public string District;
        public string Email;
        public string IsMinor;
        public string Guardian_Fullname;
        public string Guardian_ID;
        public string Guardian_Email;
        public string Claim_Type;
        public string ContractedGood;
        public string Date_Incident ;
        public string PricePaid;
        public string PricePaidCurrency;
        public string Answer_Received;
        public string DetailOfService;
        public string DetailsOdComplaint;
    }

    global class response
    {
        string caseid;
        string error;
        string errorDescription;
        public response()
        {


        }
    }
    global static Boolean validateEmail(String email) 
    {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches()) 
        res = false;
        return res; 
    } 
}