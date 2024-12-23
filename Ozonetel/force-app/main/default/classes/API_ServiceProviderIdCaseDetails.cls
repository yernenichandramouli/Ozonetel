/*
* Name           : API_ServiceProviderIdCaseDetails
* Created Date   : 25 MARCH 2019
* Created By     : Mahendra K
* Purpose        : Returns the list cases related to particular ServiceProviderId
*/
@RestResource(urlMapping='/redBus/ServiceProviderIdCaseDetails/*')
global class API_ServiceProviderIdCaseDetails
{
  @HttpPost
  global static ResponseCaseDetails casedetails()
 {
      RestRequest req = RestContext.request;
      RestResponse res = RestContext.response;
      ResponseCaseDetails resp=new ResponseCaseDetails();
      list<ResponesCase> respcslst = new  list<ResponesCase>();
      System.debug('res s-->'+req.requestBody.toString());
      caseinformation  cd= (caseInformation)JSON.deserialize(req.requestBody.toString(),caseInformation.class); 
      
      String strQry ='select id,PNR__c,Service_Providerr_Id__c ,casenumber,TIN_No__c,Trip_Id_ct__c,Issue_Type__c,Issue_Sub_Category__c,status from case where status !=\'closed\' AND CreatedDate=Today AND';
      
      if(string.isBlank(cd.serviceproviderid))
      {
         res.statuscode = 417;
         resp.error='Failed To Process The Request.Invalid Input Received';
         resp.errorDescription = 'ServiceProviderId is Missing';             
         return resp;
      }
      
      else 
      {
          strQry = strQry+' Service_Providerr_Id__c =\''+cd.serviceproviderid+'\' AND ';
  
          if(String.isNotBlank(cd.issuetype))
             strQry = strQry+'Issue_Type__c=\''+cd.issuetype+'\' AND ';
     
          if(String.isNotBlank(cd.subissuetype))
             strQry = strQry+'Issue_Sub_Category__c=\''+cd.subissuetype+'\'';
         
          strQry = strQry.removeEnd('AND ');
          
          System.debug('Final Query..'+strQry);
          try
          {
              resp.listCases = new List<ResponesCase>();
              for( case cs:DataBase.query(strQry))
              {
                ResponesCase resCs = new ResponesCase();
                resCs.casenumber=cs.casenumber;
                resCs.serviceproviderId=cs.Service_Providerr_Id__c;
                resCs.tin=cs.TIN_No__c;
                resCs.tripId = cs.Trip_Id_ct__c;
                resCs.issuetype=cs.Issue_Type__c;
                resCs.subissuetype=cs.Issue_Sub_Category__c;
                resCs.status=cs.status;
                resCs.pnr=cs.PNR__c;
                resp.listCases.add(resCs);
              }
              
              res.statuscode = 200;
              resp.error = '';
              resp.errorDescription ='';
          }
          Catch(Exception e)
          {
              res.statuscode = 400;
              resp.error = 'An Error Occured While Processing';
              resp.errorDescription =String.valueOf(e);
          }
           
          return resp;
       }
 
   }         
    
    global class caseInformation
    {
        public string serviceproviderid;
        public string issuetype;
        public string subissuetype;
    }

    global Class ResponseCaseDetails
    {
        public String error;
        public String errorDescription;
        public List<ResponesCase> listCases;

    }
    
    global Class ResponesCase
    {
        public string casenumber;
        public string serviceproviderId;
        public string issuetype;
        public string subissuetype;
        public string pnr;
        public string tin;
        public string status;
        public string tripId;
    }
   
 }