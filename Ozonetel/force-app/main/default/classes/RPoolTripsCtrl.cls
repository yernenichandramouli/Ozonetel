/*
* Name           : RPoolTripsCtrl
* Created Date   : 20 April 2019
* Created By     : Veeramanikanta R
* Purpose        : To show user trips of all rPool rides 
* Test class     : RPoolTripsCtrlTest
*/
public class RPoolTripsCtrl {
    // public TripsWrapper twr{get;set;}
    public List<TransactionHistoryWrapper> tWrapperList{get;set;}
    public decimal amount{get;set;}
    public string description{get;set;}
    public string email{get;set;}
    public string mobile{get;set;}
    public string tripId{get;set;}
    public string reason{get;set;}
    public string genericEndpoint;
    public boolean walletHistory{get;set;}
    public string redirectUrl{get;set;}
    public boolean creditBlock{get;set;}
    public boolean blockUser{get;set;}
    public string urlId{get;set;}
    public string userDetReq{get;set;}
    public string result{get;set;}
    public string expCreditReq;
    public string expCreditResp;
    public string walHistReq;
    public string walHistResp;
    public string blkUsrReq;
    public string blkUsrResp; 
    public string walBalReq;
    public string walBalResp;      
    public Map<string,object> walBalMap{get;set;}
    public API_EndPoints__mdt APIMData;
    public string testT{get;set;}
    public string type{get;set;}
    public boolean subExpCredBt{get;set;}
    public WalletBalance walBalWrap{get;set;}
    public List<UserDetailsWrapper> usLs{get;set;}
    public List<UserDetailsWrapper> FutUsLs{get;set;}
    public List<PassengerWrapper> psgLs{get;set;}
    public boolean pblock{get;set;}
    public case caseObj{get;set;}
    public boolean caseBt{get;set;}
    public boolean currBal{get;set;}
    
    public RPoolTripsCtrl(){ 
        currBal=false;
        pblock=false;
        caseBt=false;
        caseObj=new case();
        psgLs=new List<PassengerWrapper>();
        usLs=new List<UserDetailsWrapper>();
        FutUsLs=new List<UserDetailsWrapper>();
        walBalMap=new Map<string,object>(); 
        walBalWrap=new WalletBalance();
        subExpCredBt=false;   
        testT='testMani';
        APIMData=new API_EndPoints__mdt();
        user u=[SELECT id,name,Country,Business_Type__c from User WHERE Id=:UserInfo.getUserId()];
        caseObj.Country__c=u.Country;
        caseObj.Business_Type__c=u.Business_Type__c;
        genericEndpoint= [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c;    
        urlId= ApexPages.currentPage().getParameters().get('type'); 
        if(urlId=='expCredit'){
            creditBlock=true;
        } if(urlId=='blkUsr'){
            blockUser=true;
        } 
        email=ApexPages.currentPage().getParameters().get('email');
        mobile=ApexPages.currentPage().getParameters().get('mobile');
        
    } 
    
    public object getUserDetails(){
        // mobile='7022000932';
        // mobile='9591230976';
        result='';
        psgLs.clear();
        FutUsLs.clear();
        usLs.clear();
        if(mobile=='' && email==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter atleast mobile or email id'));
        }else{
            pblock=true;
            // mobile='7022000932';
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='rPoolTrips'];
            string jsonB='{"action":"GET","body":"","endPoint":"'+APIMData.Endpoint__c+mobile+'&email='+email+'","headers":""}';
            System.debug('josnB-->'+jsonB);
            HttpRequest httpReq= new HttpRequest();
            httpReq.setMethod('GET');
            httpReq.setEndpoint(APIMData.Endpoint__c+mobile+'&email='+email);
			system.debug('<<endpoint'+APIMData.Endpoint__c+mobile+'&email='+email);
            httpReq.setBody(jsonB);
            system.debug('<<jsonB'+jsonB);
            Continuation con = new Continuation(120);         
            con.continuationMethod='processUserDetailsResponse'; 
            System.debug('httpReq....'+httpReq);
            // dbl.Request_Data__c = 'Request headers--auth_key:'+httpReq.getHeader('auth_key')+',Country_Name:'+httpReq.getHeader('Country_Name')+',Content-Type:'+httpReq.getHeader('Content-Type')+',Channel_Name:'+httpReq.getHeader('Channel_Name')+',BusinessUnit:'+httpReq.getHeader('BusinessUnit')+',SelectedCurrency:'+httpReq.getHeader('SelectedCurrency')+'..End Point..'+httpReq.getEndpoint();          
            this.userDetReq= con.addHttpRequest(httpReq);
            system.debug('<<con'+con);
            return con;
        }
        return null;
    }  
    public Object processUserDetailsResponse()
    {
        try{
            HttpResponse response = Continuation.getResponse(this.userDetReq);
            //System.debug('response-->'+this.result);
            string respnBody;
            if(Test.isRunningTest()){
                respnBody='{ "trip": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555426607, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "3323121NMN1017" }, { "seatsRequested": 1, "ipocDate": 1555102070, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "91TKS01NMN1034" } ], "driverDetails": { "ipocDate": 1555426607, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "3f82e9b42004b371b914bc218c60b489" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555102070, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "234ds342443234" } ], "driverDetails": { "ipocDate": 1555102070, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "sfdf23434gsd24se4s3" } } ], "ride": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1554357407, "srcAddress": "22, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Outer Ring Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "sfsdfdhd23432dfds" } ], "driverDetails": { "ipocDate": 1553877005, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "gjhj345fj544" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1553868245, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "sgdsd255675cvb" }, { "seatsRequested": 1, "ipocDate": 1553869486, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "hgjrty34fd54r" } ], "driverDetails": { "ipocDate": 1553867944, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "ghjgh46dft4f" } } ] }';
            }else{
                this.result = response.getBody();
                respnBody=this.result; 
            }
             System.debug('respnBody-->'+respnBody);
            if(respnBody=='null'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'No Rides available with given email id/mobile.'));
            }else{   
                //string jsonBody='{ "trip": [ { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20 }, { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20 } ], "driverDetails": { "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20 } ], "driverDetails": { "ipocDate": 0, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio" } } ], "ride": [ { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554357407, "srcAddress": "22, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Outer Ring Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20 } ], "driverDetails": { "ipocDate": 1553877005, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1553868245, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20 }, { "seatsRequested": 1, "ipocDate": 1553869486, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20 } ], "driverDetails": { "ipocDate": 1553867944, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio" } } ] } 2. Block API (POST) EndPoint: http://ridespp.redbus.in:5229/sf/blockUser Request: { "email" : "karthik.rk18@gmail.com", "mobile":"7022000932", "reason" : "Too many complaints" }';
                //string jsonBody='{"trip": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555426607, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "3323121NMN1017" }, { "seatsRequested": 1, "ipocDate": 1555102070, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "91TKS01NMN1034" } ], "driverDetails": { "ipocDate": 1555102070, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "3f82e9b42004b371b914bc218c60b489" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555102070, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "234ds342443234" } ], "driverDetails": { "ipocDate": 1555102070, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "sfdf23434gsd24se4s3" } } ], "ride": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1554357407, "srcAddress": "22, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Outer Ring Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "sfsdfdhd23432dfds" } ], "driverDetails": { "ipocDate": 1553877005, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "gjhj345fj544" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1553868245, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "sgdsd255675cvb" }, { "seatsRequested": 1, "ipocDate": 1553869486, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "hgjrty34fd54r" } ], "driverDetails": { "ipocDate": 1553867944, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "ghjgh46dft4f" } } ] }';
                string jsonBody='{ "trip": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555426607, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "3323121NMN1017" }, { "seatsRequested": 1, "ipocDate": 1555102070, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "91TKS01NMN1034" } ], "driverDetails": { "ipocDate": 1555426607, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "3f82e9b42004b371b914bc218c60b489" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555102070, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "234ds342443234" } ], "driverDetails": { "ipocDate": 1555102070, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "sfdf23434gsd24se4s3" } } ], "ride": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1554357407, "srcAddress": "22, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Outer Ring Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "sfsdfdhd23432dfds" } ], "driverDetails": { "ipocDate": 1553877005, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "gjhj345fj544" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1553868245, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "sgdsd255675cvb" }, { "seatsRequested": 1, "ipocDate": 1553869486, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "hgjrty34fd54r" } ], "driverDetails": { "ipocDate": 1553867944, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "ghjgh46dft4f" } } ] }';
                //string jsonBody='{ "trip": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555682038, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "3323121NMN1017" }, { "seatsRequested": 1, "ipocDate": 1555309349, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "91TKS01NMN1034" } ], "driverDetails": { "ipocDate": 1555682038, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "3f82e9b42004b371b914bc218c60b489" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555222949, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "234ds342443234" } ], "driverDetails": { "ipocDate": 1555682038, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "sfdf23434gsd24se4s3" } } ], "ride": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1554357407, "srcAddress": "22, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Outer Ring Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "sfsdfdhd23432dfds" } ], "driverDetails": { "ipocDate": 1553877005, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "gjhj345fj544" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1553868245, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "sgdsd255675cvb" }, { "seatsRequested": 1, "ipocDate": 1553869486, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "hgjrty34fd54r" } ], "driverDetails": { "ipocDate": 1553867944, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "ghjgh46dft4f" } } ] }';
                string tripB='{ "trip": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555682038, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "3323121NMN1017" }, { "seatsRequested": 1, "ipocDate": 1555309349, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "91TKS01NMN1034" } ], "driverDetails": { "ipocDate": 1555682038, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "3f82e9b42004b371b914bc218c60b489" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555222949, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "234ds342443234" } ], "driverDetails": { "ipocDate": 1555682038, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "sfdf23434gsd24se4s3" } } ] }';
                //string jsonBody='{ "trip": [ { "paxDetails": [ { "seatsRequested": 0, "ipocDate": 0, "srcAddress": "22, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "82, Koramangala 4th Block, Koramangala, Bengaluru, Karnataka 560034, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "fare": 0, "tripIdentifier": "91TKS01NMN1017" } ], "driverDetails": { "ipocDate": 0, "srcAddress": "", "destAddress": "", "email": "", "mobile": "", "name": "", "totalSeats": 0, "vehicleNo": "", "vehicleName": "", "parentTripIdentifier": "" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Yemalur", "email": "remanansuseela@gmail.com", "mobile": "8129966749", "name": "sara", "fare": 0, "tripIdentifier": "8LAHMTTFIQ10013" } ], "driverDetails": { "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Yemalur", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 ML 1234", "vehicleName": "Mahindra Xuv300", "parentTripIdentifier": "3f82e9b42004b371b914bc218c60b489" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "The Leela Palace", "destAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "fare": 20, "tripIdentifier": "CQL8OT6R7J9914" } ], "driverDetails": { "ipocDate": 0, "srcAddress": "The Leela Palace", "destAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "email": "amarjeetanandsingh@gmail.com", "mobile": "8797312939", "name": "Amarjeet", "totalSeats": 0, "vehicleNo": "KA 05 AZ 7685", "vehicleName": "Honda City", "parentTripIdentifier": "4131d94af90236b9f7bbcb8dff8cd4cf" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "62, 2nd Phase, JP Nagar, Bengaluru, Karnataka 560062, India", "destAddress": "16th Main Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "ZVDCTUIKJE1018" } ], "driverDetails": { "ipocDate": 0, "srcAddress": "62, 2nd Phase, JP Nagar, Bengaluru, Karnataka 560062, India", "destAddress": "16th Main Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 ML 1234", "vehicleName": "Mahindra Xuv300", "parentTripIdentifier": "635f6e549fb163a75f42b8c5c9b101e9" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "ZQU87GNVSH8813" }, { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "XWVTOMT6EO8813" } ], "driverDetails": { "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "ATEXND88813" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "UHWANZKFK18811" } ], "driverDetails": { "ipocDate": 0, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "BRE6ZQY8811" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "7th Cross Road, Yemalur, Bellandur, Bengaluru, Karnataka 560037, India", "destAddress": "106, Intermediate Ring Rd, AK Colony, Domlur I Stage, Amarjyoti Layout, Domlur, Bengaluru, Karnataka 560071, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "fare": 0, "tripIdentifier": "JAJ73QZLPF1017" } ], "driverDetails": { "ipocDate": 0, "srcAddress": "Yemalur", "destAddress": "Domlur", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Mercedes Benz", "parentTripIdentifier": "cfe4edde4c1f66cf947d7448259ebc0a" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "172, Koramangala 4th Block, Koramangala, Bengaluru, Karnataka 560034, India", "email": "remanansuseela@gmail.com", "mobile": "8129966749", "name": "sara", "fare": 0, "tripIdentifier": "RUPBQD4UTE10012" } ], "driverDetails": { "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "82, Koramangala 4th Block, Koramangala, Bengaluru, Karnataka 560034, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 ML 1234", "vehicleName": "Mahindra Xuv300", "parentTripIdentifier": "d02db9ee1b5191050939c953b5fd8b7d" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "16th Main Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "fare": 0, "tripIdentifier": "K55XHONGBS1019" } ], "driverDetails": { "ipocDate": 0, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "16th Main Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Mercedes Benz", "parentTripIdentifier": "d9f20d2980dd74645a53c92ef2fce6be" } } ], "ride": [ { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554357407, "srcAddress": "22, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Outer Ring Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20 } ], "driverDetails": { "ipocDate": 1553877005, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1553868245, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20 }, { "seatsRequested": 1, "ipocDate": 1553869486, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20 } ], "driverDetails": { "ipocDate": 1553867944, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 3, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio" } }, { "paxDetails": [ { "seatsRequested": 0, "ipocDate": 1554733837, "srcAddress": "MG Road Metro Station", "destAddress": "Majestic", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "fare": 0 } ], "driverDetails": { "ipocDate": 1554733813, "srcAddress": "Mahatma Gandhi Road, Mahatma Gandhi Road, Shivajinagar, Bengaluru, Karnataka 560001, India", "destAddress": "Majestic Bus Stand, Bus Station Underpass, Majestic, Bengaluru, Karnataka 560009, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "totalSeats": 0, "vehicleNo": "", "vehicleName": "" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554738916, "srcAddress": "Gati packers and movers bangalore,packers and movers#535 snankar Nagar Main road movers and packers bangalore,Near presidency school, Bommanahalli, Bengaluru, Karnataka 560068, India", "destAddress": "Car Transport In Bangalore, Car Transport Bangalore, Car Movers In Bangalore, Car Movers Bangalore, Car Relocation In Bangalore, Car Relocation Bangalore, Car Transport From Bangalore To Delhi, Electronic City, Bengaluru, Karnataka 560100, India", "email": "amarjeetanandsingh@gmail.com", "mobile": "8797312939", "name": "Amarjeet", "fare": 0 } ], "driverDetails": { "ipocDate": 1554738951, "srcAddress": "Gati packers and movers bangalore,packers and movers#535 snankar Nagar Main road movers and packers bangalore,Near presidency school, Bommanahalli, Bengaluru, Karnataka 560068, India", "destAddress": "Car Transport In Bangalore, Car Transport Bangalore, Car Movers In Bangalore, Car Movers Bangalore, Car Relocation In Bangalore, Car Relocation Bangalore, Car Transport From Bangalore To Delhi, Electronic City, Bengaluru, Karnataka 560100, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 3, "vehicleNo": "KA 05 1231", "vehicleName": "Honda Brio" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554742828, "srcAddress": "28/29, Kempegowda, Majestic, Bengaluru, Karnataka 560009, India", "destAddress": "449, Yesvantpur Industrial Suburb, Yeshwanthpur, Bengaluru, Karnataka 560022, India", "email": "amarjeetanandsingh@gmail.com", "mobile": "8797312939", "name": "Amarjeet", "fare": 20 } ], "driverDetails": { "ipocDate": 1554742851, "srcAddress": "Majestic Bus Stand", "destAddress": "Yesvantpur Railway Station", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 3, "vehicleNo": "KA 05 1231", "vehicleName": "Honda Brio" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554792059, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "507, Sri Tirumala Splendor, Bengaluru, Karnataka 560068, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 0 } ], "driverDetails": { "ipocDate": 1554792100, "srcAddress": "The Leela Palace", "destAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 3, "vehicleNo": "KA 05 ML 1234", "vehicleName": "Mahindra Xuv300" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554898806, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "172, Koramangala 4th Block, Koramangala, Bengaluru, Karnataka 560034, India", "email": "remanansuseela@gmail.com", "mobile": "8129966749", "name": "sara", "fare": 0 } ], "driverDetails": { "ipocDate": 1554900289, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "82, Koramangala 4th Block, Koramangala, Bengaluru, Karnataka 560034, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 1, "vehicleNo": "KA 05 ML 1234", "vehicleName": "Mahindra Xuv300" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554817459, "srcAddress": "The Leela Palace", "destAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "fare": 20 } ], "driverDetails": { "ipocDate": 1554817549, "srcAddress": "The Leela Palace", "destAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "email": "amarjeetanandsingh@gmail.com", "mobile": "8797312939", "name": "Amarjeet", "totalSeats": 1, "vehicleNo": "KA 05 AZ 7685", "vehicleName": "Honda City" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554828949, "srcAddress": "xerox 1st floor devarabisanahalli near passport seva kendra marathahalli, Bengaluru, Karnataka 560037, India", "destAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "fare": 0 } ], "driverDetails": { "ipocDate": 1554829242, "srcAddress": "xerox 1st floor devarabisanahalli near passport seva kendra marathahalli, Bengaluru, Karnataka 560037, India", "destAddress": "Outer Ring Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "amarjeetanandsingh@gmail.com", "mobile": "8797312939", "name": "Amarjeet", "totalSeats": 3, "vehicleNo": "KA 05 AZ 7685", "vehicleName": "Honda City" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554902551, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Yemalur", "email": "remanansuseela@gmail.com", "mobile": "8129966749", "name": "sara", "fare": 0 } ], "driverDetails": { "ipocDate": 1554901097, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Yemalur", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 1, "vehicleNo": "KA 05 ML 1234", "vehicleName": "Mahindra Xuv300" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554968263, "srcAddress": "7th Cross Road, Yemalur, Bellandur, Bengaluru, Karnataka 560037, India", "destAddress": "106, Intermediate Ring Rd, AK Colony, Domlur I Stage, Amarjyoti Layout, Domlur, Bengaluru, Karnataka 560071, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "fare": 0 } ], "driverDetails": { "ipocDate": 1554967660, "srcAddress": "Yemalur", "destAddress": "Domlur", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "totalSeats": 1, "vehicleNo": "KA 05 1234", "vehicleName": "Mercedes Benz" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554971398, "srcAddress": "62, 2nd Phase, JP Nagar, Bengaluru, Karnataka 560062, India", "destAddress": "16th Main Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20 } ], "driverDetails": { "ipocDate": 1554971301, "srcAddress": "62, 2nd Phase, JP Nagar, Bengaluru, Karnataka 560062, India", "destAddress": "16th Main Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 1, "vehicleNo": "KA 05 ML 1234", "vehicleName": "Mahindra Xuv300" } }, { "paxDetails": [ { "seatsRequested": 1, "ipocDate": 1554976582, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "16th Main Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "fare": 0 } ], "driverDetails": { "ipocDate": 1554976566, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "16th Main Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "totalSeats": 1, "vehicleNo": "KA 05 1234", "vehicleName": "Mercedes Benz" } } ] }';
                // twr = (TripsWrapper)JSON.deserialize(this.result, TripsWrapper.class); 
                
                map<string,object> usMap= (map<string,object>)JSON.deserializeUntyped(respnBody);
                List<object> lsTrip= (List<Object>)usMap.get('trip');
                List<object> lsRide= (List<Object>)usMap.get('ride');
                system.debug('<<s1'+lsTrip.size());
                system.debug('<<s2'+lsRide.size());
                GenericRides(lsTrip,'past');
                GenericRides(lsRide,'future');                        
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please try again.'));
        }
        return null;
    }     
    
    public void GenericRides(list<object> lsObj,string whenR){
        for(object o:lsObj){
            UserDetailsWrapper uW=new UserDetailsWrapper();
            map<string, object> uobMap= (map<string,object>)o;
            Map<String,Object> driMap=new  Map<String,Object>();
            driMap= (map<string,object>)uobMap.get('driverDetails');
            List<object> lsPsgr= (List<Object>)uobMap.get('paxDetails');
            uW.driDetails.srcAddress=String.valueOf(driMap.get('srcAddress'));
            uW.driDetails.destAddress=String.valueOf(driMap.get('destAddress'));
            uW.driDetails.email=String.valueOf(driMap.get('email'));
            uW.driDetails.mobile=String.valueOf(driMap.get('mobile'));
            uW.driDetails.name=String.valueOf(driMap.get('name'));
            uW.driDetails.totalSeats=String.valueOf(driMap.get('totalSeats'));
            uW.driDetails.vehicleNo=String.valueOf(driMap.get('vehicleNo'));
            uW.driDetails.vehicleName=String.valueOf(driMap.get('vehicleName'));
            uW.driDetails.parentTripIdentifier=String.valueOf(driMap.get('parentTripIdentifier'));   
            uW.driDetails.rideId=String.valueOf(driMap.get('rideId')); 
            if(string.ValueOf(driMap.get('ipocDate'))!='' && string.ValueOf(driMap.get('ipocDate'))!=null ){
                if(string.ValueOf(driMap.get('ipocDate')) == '0'){
                 uW.driDetails.ipocDate  = 'Cancelled';  
                }
                else{
                string utcEp=string.ValueOf(driMap.get('ipocDate'));
                utcEp=utcEp+'000';
                datetime ddri= datetime.newinstance(long.valueOf(utcEp)).addminutes(330);
                uW.driDetails.ipocDate=string.ValueOf(ddri);                  
                }
            }
            for(object psgr:lsPsgr){ 
                PassengerWrapper pW=new PassengerWrapper();
                Map<String,Object> pobMap=(Map<String,Object>)psgr;
                pW.seatsRequested=String.valueOf(pobMap.get('seatsRequested'));                     
                pW.srcAddress=String.valueOf(pobMap.get('srcAddress'));
                pW.destAddress=String.valueOf(pobMap.get('destAddress'));
                pW.email=String.valueOf(pobMap.get('email'));
                pW.mobile=String.valueOf(pobMap.get('mobile'));
                pW.name=String.valueOf(pobMap.get('name'));
                pW.fare=String.valueOf(pobMap.get('fare'));
                pW.tripIdentifier=String.valueOf(pobMap.get('tripIdentifier'));
                pW.rideId=String.valueOf(pobMap.get('rideId'));
                if(String.valueOf(pobMap.get('ipocDate'))!=null && String.valueOf(pobMap.get('ipocDate'))!=null && String.valueOf(pobMap.get('ipocDate'))!= '0'){
                    string utcUpPsg;
                    utcUpPsg=String.valueOf(pobMap.get('ipocDate'));
                    system.debug('<<utcUpPsg'+utcUpPsg);
                    utcUpPsg=utcUpPsg+'000';
                    datetime dpsg= datetime.newinstance(long.valueOf(utcUpPsg)).addminutes(330);
                    system.debug('dpsg'+dpsg);             
                    pW.ipocDate=string.valueOf(dpsg);  
                    system.debug('<<next record');
                }                    
                uW.paxDetails.add(pW);
            }
            if(whenR=='future')
                FutUsLs.add(uW);
            else if(whenR=='past')
                usLs.add(uW); 
            system.debug('<<date '+uw.driDetails.ipocDate);
        }
    }           
    public object getWalletHistory(){
        //mobile='7022000932';
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='rPoolWalletHistory'];
        string jsonB='{"action":"GET","body":"","endPoint":"'+APIMData.Endpoint__c+mobile+'","headers":""}';
        System.debug('josnB-->'+jsonB);
        HttpRequest httpReq= new HttpRequest();
        httpReq = HttpRequestUtil.populateHeaders(httpReq);          
        httpReq.setMethod('POST');
        httpReq.setBody(jsonB);
        httpReq.setEndpoint(genericEndpoint);
        Continuation con = new Continuation(120);         
        con.continuationMethod='GetWalletHisotryResponse'; 
        System.debug('httpReq....'+httpReq);
        // dbl.Request_Data__c = 'Request headers--auth_key:'+httpReq.getHeader('auth_key')+',Country_Name:'+httpReq.getHeader('Country_Name')+',Content-Type:'+httpReq.getHeader('Content-Type')+',Channel_Name:'+httpReq.getHeader('Channel_Name')+',BusinessUnit:'+httpReq.getHeader('BusinessUnit')+',SelectedCurrency:'+httpReq.getHeader('SelectedCurrency')+'..End Point..'+httpReq.getEndpoint();          
        this.walHistReq= con.addHttpRequest(httpReq);
        return con;
        
    }
    public Object GetWalletHisotryResponse()
    {
        try{
            HttpResponse response = Continuation.getResponse(this.walHistReq);
            this.walHistResp= response.getBody();
            System.debug('wall Resp'+this.walHistResp);
            string jsonT='[ { "ID": 309, "rideTripId": "62036034", "account": "61733875", "amount": -20, "billingGroup": "PAX_RIDE", "billingCode": 401, "transactionId": "GYUGZQS9416", "description": "point debited from pax wallet", "notes": "billing for pax ride trip", "createdTime": "2019-04-04T16:30:55Z" } ]';
            system.debug('hist resp-->'+this.walHistResp);
            tWrapperList= (List<TransactionHistoryWrapper>)JSON.deserialize(this.walHistResp,List<TransactionHistoryWrapper>.class);
            // getWalletBalance();
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please try again.'));
        }
        return null;
    } 
    
    public object getWalletBalance(){
        currBal=true;
        System.debug('bal calling');
        //mobile='7022000932';
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='rPoolWalletBalance'];
        string jsonB='{"action":"GET","body":"","endPoint":"'+APIMData.Endpoint__c+mobile+'&email='+email+'","headers":""}';
        System.debug('josnB-->'+jsonB);
        HttpRequest httpReq= new HttpRequest();
        httpReq = HttpRequestUtil.populateHeaders(httpReq);          
        httpReq.setMethod('POST');
        httpReq.setBody(jsonB);
        httpReq.setEndpoint(genericEndpoint);
        Continuation con = new Continuation(120);         
        con.continuationMethod='GetWalletBalanceResponse'; 
        System.debug('httpReq....'+httpReq);
        // dbl.Request_Data__c = 'Request headers--auth_key:'+httpReq.getHeader('auth_key')+',Country_Name:'+httpReq.getHeader('Country_Name')+',Content-Type:'+httpReq.getHeader('Content-Type')+',Channel_Name:'+httpReq.getHeader('Channel_Name')+',BusinessUnit:'+httpReq.getHeader('BusinessUnit')+',SelectedCurrency:'+httpReq.getHeader('SelectedCurrency')+'..End Point..'+httpReq.getEndpoint();          
        this.walBalReq= con.addHttpRequest(httpReq);
        return con;
        
    }
    
    public Object GetWalletBalanceResponse()
    {
        try{
            HttpResponse response = Continuation.getResponse(this.walBalReq);
            this.walBalResp= response.getBody();
            System.debug('wall Resp'+this.walBalResp);
            string jsonT='{ "rideUserId": "1232322", "coreCash": 38.53, "offerCash": 80, "earnedCash": 0, "totalCash": 118.53 }';           
            walBalWrap= (WalletBalance)JSON.deserialize(this.walBalResp,WalletBalance.class);
            System.debug('walBalMap-->'+walBalWrap);
            // getWalletHistory();
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please try again.'));
        }
        return null;
    } 
    
    
    public object ProcessExceptionalCredit(){
        // mobile='7022000932';
        CreditWrapper cw=new CreditWrapper(email,mobile,amount,description,tripId);
        string jsonBody =json.serialize(cw); 
        System.debug('jsonBody -->'+jsonBody );
        jsonBody=json.serialize(jsonBody); 
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='rPoolExceptionalCredit'];
        string jsonB='{"action":"post","body":'+jsonBody+',"endPoint":"'+APIMData.Endpoint__c+'","headers":""}';
        System.debug('jsonB-->'+jsonB);
        HttpRequest httpReq= new HttpRequest();
        httpReq = HttpRequestUtil.populateHeaders(httpReq);          
        httpReq.setMethod('POST');
        httpReq.setBody(jsonB);
        httpReq.setEndpoint(genericEndpoint);
        Continuation con = new Continuation(120);         
        con.continuationMethod='ExceptionalCreditResponse'; 
        System.debug('httpReq....'+httpReq);
        // dbl.Request_Data__c = 'Request headers--auth_key:'+httpReq.getHeader('auth_key')+',Country_Name:'+httpReq.getHeader('Country_Name')+',Content-Type:'+httpReq.getHeader('Content-Type')+',Channel_Name:'+httpReq.getHeader('Channel_Name')+',BusinessUnit:'+httpReq.getHeader('BusinessUnit')+',SelectedCurrency:'+httpReq.getHeader('SelectedCurrency')+'..End Point..'+httpReq.getEndpoint();          
        this.expCreditReq= con.addHttpRequest(httpReq);
        return con;
        
    }
    public Object ExceptionalCreditResponse()
    {
        DBLog_Summary__c dbLog=new DBLog_Summary__c();
        dbLog.type__c='rPool-Exceptoinal Credit';
        try{
            dbLog.Request_Data__c=string.valueOf(this.expCreditReq);
            HttpResponse response = Continuation.getResponse(this.expCreditReq);          
            this.expCreditResp= response.getBody();
            System.debug('exp resp-->'+this.expCreditResp);
            dbLog.Response_Received__c=this.expCreditResp;
            if(dbLog.Response_Received__c==null){ 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please try again.'));       
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Successfully credited.'));
                subExpCredBt=true;
            }
            
        }catch(Exception e){
            dbLog.Exception_Description__c=string.valueOf(e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please try again.'));
        }
        insert dbLog;
        return null;
    } 
    
    
    public object BlockUser(){
        // mobile='7022000932';
        BlockUserWrapper bu=new BlockUserWrapper(email,mobile,reason);
        string jsonBody =json.serialize(bu); 
        System.debug('jsonBody -->'+jsonBody );
        jsonBody=json.serialize(jsonBody); 
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='rPoolBlockUser'];
        string jsonB='{"action":"post","body":'+jsonBody+',"endPoint":"'+APIMData.Endpoint__c+'","headers":""}';
        
        HttpRequest httpReq= new HttpRequest();
        httpReq = HttpRequestUtil.populateHeaders(httpReq);          
        httpReq.setMethod('POST');
        httpReq.setBody(jsonB);
        httpReq.setEndpoint(genericEndpoint);
        Continuation con = new Continuation(120);         
        con.continuationMethod='BlockUserResponse'; 
        System.debug('httpReq....'+httpReq);
        // dbl.Request_Data__c = 'Request headers--auth_key:'+httpReq.getHeader('auth_key')+',Country_Name:'+httpReq.getHeader('Country_Name')+',Content-Type:'+httpReq.getHeader('Content-Type')+',Channel_Name:'+httpReq.getHeader('Channel_Name')+',BusinessUnit:'+httpReq.getHeader('BusinessUnit')+',SelectedCurrency:'+httpReq.getHeader('SelectedCurrency')+'..End Point..'+httpReq.getEndpoint();          
        this.blkUsrReq= con.addHttpRequest(httpReq);
        return con;
        
    }
    public Object BlockUserResponse()
    {
        DBLog_Summary__c dbLog=new DBLog_Summary__c();
        dbLog.type__c='rPool-Block User';
        try{
            dbLog.Request_Data__c=string.valueOf(this.blkUsrReq);
            HttpResponse response = Continuation.getResponse(this.blkUsrReq);
            this.blkUsrResp= response.getBody();
            dbLog.Response_Received__c=this.blkUsrResp; 
        }catch(Exception e){
            dbLog.Exception_Description__c=string.valueOf(e);
        }
        insert dbLog;
        return null;
    } 
    
    public void CaseCreate(){
        try{
            caseBt=true;
        Id recTypeId = Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosByName().get('RPool').getRecordTypeId();
            caseObj.RecordTypeId=recTypeId;
            caseObj.Origin='InBound Call';
            insert caseObj;
            case c=[select id,casenumber from case where id=:caseObj.id];
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Case created Successfully!! Case Id->'+c.CaseNumber));
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please try again.'));
        }
    }
    
    public PageReference ExceptionalCreditPage() {        
        PageReference myVFPage;
        myVFPage = new PageReference('/apex/rPoolCredit?type=expCredit');
        myVFPage.setRedirect(true);
        myVFPage.getParameters().put('email', email);
        myVFPage.getParameters().put('mobile', mobile);
        return myVFPage;
    }
    public PageReference BlockUserPage() { 
        PageReference myVFPage;
        myVFPage = new PageReference('/apex/rPoolCredit?type=blkUsr');
        myVFPage.setRedirect(true);
        myVFPage.getParameters().put('email', email);
        myVFPage.getParameters().put('mobile', mobile);
        return myVFPage;
    }
    public PageReference WalletHistoryPage() { 
        PageReference myVFPage;
        myVFPage = new PageReference('/apex/rPoolTransactionHistory?type=walletHist');
        myVFPage.setRedirect(true);
        myVFPage.getParameters().put('email', email);
        myVFPage.getParameters().put('mobile', mobile);
    	system.debug('<<<myVFPage'+myVFPage);
        return myVFPage;
    }
    public PageReference CaseCreatePage() { 
        PageReference myVFPage;
        myVFPage = new PageReference('/apex/rPoolCaseCreation');
        myVFPage.setRedirect(true);
        // myVFPage.getParameters().put('email', email);
        // myVFPage.getParameters().put('mobile', mobile);
        return myVFPage;
    }
    
    //  public List<UserDetailsWrapper> usLs{get;set;}
    //   public List<PassengerWrapper> psgLs{get;set;}
    
    public class UserDetailsWrapper{
        public List<PassengerWrapper> paxDetails{get;set;}
        public DriverWrapper driDetails{get;set;}
        public UserDetailsWrapper(){
            paxDetails=new List<PassengerWrapper>();
            driDetails=new DriverWrapper();
        }
    }
    
    public class PassengerWrapper{
        public string seatsRequested{get;set;}
        public string ipocDate{get;set;}
        public string srcAddress{get;set;}
        public string destAddress{get;set;}
        public string email{get;set;}
        public string mobile{get;set;}
        public string name{get;set;}
        public string fare{get;set;}
        public string tripIdentifier{get;set;}  
        public string rideId{get;set;}
    }
    
    public class DriverWrapper {
        public string ipocDate{get;set;}
        public datetime ipocDate2{get;set;}
        public string srcAddress{get;set;}
        public string destAddress{get;set;}
        public string email{get;set;}
        public string mobile{get;set;}
        public string name{get;set;}
        public string totalSeats{get;set;}
        public string vehicleNo{get;set;}
        public string vehicleName{get;set;}
        public string parentTripIdentifier{get;set;}
        public string rideId{get;set;}
        
    }
    public class BlockUserWrapper{
        public string email{get;set;}
        public string mobile{get;set;}
        public string reason{get;set;}
        public BlockUserWrapper(string email,string mobile,string reason){
            this.email=email;
            this.mobile=mobile;
            this.reason=reason;
        }
    }
    public class CreditWrapper{
        public string email{get;set;}
        public string mobile{get;set;}
        public decimal amount{get;set;}
        public string description{get;set;}
        public string uniqueId{get;set;}
        public CreditWrapper(string email,string mobile,decimal amount,string description,string uniqueId){
            this.email=email;
            this.mobile=mobile;
            this.amount=amount;
            this.description=description;
            this.uniqueId=uniqueId;
        }
        
    }
    
    public class TransactionHistoryWrapper{
        public string Id{get;set;}
        public string rideTripId{get;set;}
        public string account{get;set;}
        public string amount{get;set;}
        public string billingGroup{get;set;}
        public string billingCode{get;set;}
        public string transactionId{get;set;}
        public string description{get;set;}
        public string notes{get;set;}
        public string createdTime{get;set;}
        
    }
    
    /*  public class TripsWrapper{
public List<RideData> ride{get;set;}
public List<TripData> trip{get;set;}
}
public class RideData{
public List<PaxDetailsData> paxDetails{get;set;}
public DriverDetailsData driverDetails{get;set;}
}
public class PaxDetailsData{
public string seatsRequested{get;set;}
public string ipocDate{get;set;}
public string srcAddress{get;set;}
public string destAddress{get;set;}
public string email{get;set;}
public string mobile{get;set;}
public string name{get;set;}
public string fare{get;set;}
public string tripIdentifier{get;set;}  
}
public class DriverDetailsData {
public integer ipocDate{get;set;}
public datetime ipocDate2{get;set;}
public string srcAddress{get;set;}
public string destAddress{get;set;}
public string email{get;set;}
public string mobile{get;set;}
public string name{get;set;}
public string totalSeats{get;set;}
public string vehicleNo{get;set;}
public string vehicleName{get;set;}
public string parentTripIdentifier{get;set;}
public DriverDetailsData(){
System.debug('calling');
ipocDate2=DateTime.newInstance(1553868245);
} 
}
public class TripData{
public List<PaxDetailsData> paxDetails{get;set;}
public DriverDetailsData driverDetails{get;set;}
}  */
    public class WalletBalance{
        public string rideUserId{get;set;}
        public string coreCash{get;set;}
        public string offerCash{get;set;}
        public string earnedCash{get;set;}
        public string totalCash{get;set;}
        
    }
}