@isTest(SeeAllData=true)
public class RPoolTripsCtrlTest
{
    static testMethod void buspackagedtls() 
    {
        Test.startTest();
        string jsonBody='{ "trip": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555682038, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "3323121NMN1017" }, { "seatsRequested": 1, "ipocDate": 1555309349, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "91TKS01NMN1034" } ], "driverDetails": { "ipocDate": 1555682038, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "3f82e9b42004b371b914bc218c60b489" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1555222949, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "234ds342443234" } ], "driverDetails": { "ipocDate": 1555682038, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 0, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "sfdf23434gsd24se4s3" } } ], "ride": [{ "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1554357407, "srcAddress": "22, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Outer Ring Rd, Aicobo Nagar, 1st Stage, BTM 2nd Stage, Bengaluru, Karnataka 560029, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "sfsdfdhd23432dfds" } ], "driverDetails": { "ipocDate": 1553877005, "srcAddress": "Central Silk Board (Towards BSK), Central Silk Board Colony, Stage 2, BTM 2nd Stage, Bengaluru, Karnataka 560068, India", "destAddress": "1152, 26th Main Rd, 4th T Block East, Jayanagar, Bengaluru, Karnataka 560041, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "gjhj345fj544" } }, { "paxDetails": [{ "seatsRequested": 1, "ipocDate": 1553868245, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Gopalan Signature Mall, Swamy Vivekananda Rd, Rahat Bagh, Nagavarapalya, Bennigana Halli, Bengaluru, Karnataka 560093, India", "email": "phaneesh@gmail.com", "mobile": "9591230976", "name": "Phaneesh Gururaj", "fare": 20, "tripIdentifier": "sgdsd255675cvb" }, { "seatsRequested": 1, "ipocDate": 1553869486, "srcAddress": "Empire Restaurant Indiranagar", "destAddress": "Tin Factory", "email": "ankitaman2050@gmail.com", "mobile": "9035548758", "name": "ANKIT AMAN", "fare": 20, "tripIdentifier": "hgjrty34fd54r" } ], "driverDetails": { "ipocDate": 1553867944, "srcAddress": "23, HAL Old Airport Rd, HAL 2nd Stage, Kodihalli, Bengaluru, Karnataka 560008, India", "destAddress": "Hebron Enclave road, Hallehalli, Bengaluru, Karnataka 560049, India", "email": "karthik.rk18@gmail.com", "mobile": "7022000932", "name": "karthik r", "totalSeats": 4, "vehicleNo": "KA 05 1234", "vehicleName": "Honda Brio", "parentTripIdentifier": "ghjgh46dft4f" } } ] }';
        RPoolTripsCtrl r=new RPoolTripsCtrl();
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        r.walletHistory=true;
        r.creditBlock=true;
        r.blockUser=true;
        r.type='typeS';
        r.result='re';
        r.mobile='9898789878';
        r.getUserDetails();
        r.processUserDetailsResponse();
        r.getWalletHistory();  
        r.GetWalletHisotryResponse();
        r.getWalletBalance();
        r.GetWalletBalanceResponse();
        r.ProcessExceptionalCredit();
        r.ExceptionalCreditResponse();
        r.BlockUser();
        r.BlockUserResponse();
        r.ExceptionalCreditPage();
        r.BlockUserPage();
        r.WalletHistoryPage();
        r.CaseCreatePage();
        r.CaseCreate();
        
        Test.stopTest();   
    }
}