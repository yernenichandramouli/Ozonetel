/*
* Name           : MMTTransactionSync
* Created Date   : 07 Oct 2020
* Created By     : Veeramanikanta R
* Purpose        : Syncing MMT cases
* Test class     : MMTTransactionSyncTest
*/
public class MMTTransactionSync{
    
    // @future(callout=true)
    public static void postDetails(set<string> bookingIds){
        System.debug('bookingIds-->'+bookingIds);
        List<CaseSyncWrapper> csSyncLs=new List<CaseSyncWrapper>();
        Map<string,CaseSyncWrapper> csMap=new Map<string,CaseSyncWrapper>();
        for(string bkId:bookingIds){
            SyncWrapper tData=new SyncWrapper();  
            tData=TransactionSync(bkId);
            System.debug('tData-->'+tData); 
               
            string lineNos;
            if(tData!=null && tData.busBookingInfo!=null){
                for(PassengerInfoWrapper ob:tData.busBookingInfo.passengerDetails){
                    System.debug('name-->'+ob.name);
                    if(string.isNotBlank(lineNos)){
                        lineNos=lineNos+','+ob.lineno;
                    }else{
                        lineNos=ob.lineno;
                    }
                }
            }
            CaseSyncWrapper csy=new CaseSyncWrapper();
            //csy.doi=DateTime.newInstance(tData.bookingDateTime);   
            if(tData!=null){             
            csy.tinNo=tData.bookingId;
            }
            csy.noOfSeats=lineNos;
            if(tData!=null && tData.busBookingInfo!=null){
                csy.operatorName=tData.busBookingInfo.busDetail.operator;
                csy.operatorId=tData.busBookingInfo.busDetail.operatorid;
                csy.pnr=tData.busBookingInfo.busDetail.operatorPnr;
                csy.source=tData.busBookingInfo.busDetail.fromCity;
                csy.destination=tData.busBookingInfo.busDetail.toCity;
            }
            if(tData!=null && tData.busAdditionalInfo!=null && tData.busAdditionalInfo.departureDetail!=null){                            
                long dojLong=long.valueOf(tData.busAdditionalInfo.departureDetail.departureTime);
                csy.doj=DateTime.newInstance(dojLong).addMinutes(330);
            }
            csSyncLs.add(csy);
            csMap.put(bkId,csy);            
        }
        list<case> caseLs=new list<case>();
        caseLs=[select id,casenumber,tin_no__c from case where tin_no__c!='' and tin_no__c in:bookingIds];
        List<case> csUpList=new List<case>();
        for(case cs:caseLs){
            case cObj=new case();
            cObj.id=cs.id;
            cObj.TIN_No__c=csMap.get(cs.tin_no__c).tinNo;
            cObj.No_of_Seats__c=csMap.get(cs.tin_no__c).noOfSeats;
            cObj.Bus_Operator_Namee__c=csMap.get(cs.tin_no__c).operatorName;
            cObj.Service_Providerr_Id__c=csMap.get(cs.tin_no__c).operatorId;
            cObj.PNR__c=csMap.get(cs.tin_no__c).pnr;
            cObj.SS_DOJ__c=csMap.get(cs.tin_no__c).doj;
            
            cObj.SourceT__c=csMap.get(cs.tin_no__c).source;
            cObj.DestinationT__c=csMap.get(cs.tin_no__c).destination;
            
            csUpList.add(cObj);
        }
        if(!csUpList.isEmpty())
            database.update(csUpList);
        //update csUpList;
    }
    
    
    public static SyncWrapper TransactionSync(string bookingId){  
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();  
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName ='MMT_BookingDetails'];
        Map<String, String> headers = new Map<String, String>();
        headers.put('key','Content-Type');
        headers.put('value', 'application/json');
        list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
        for(string o:headers.keyset()){
            hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o)));
        }
        String headerJson=json.serialize(hlist);
        String headerJson2=json.serialize(headerJson); 
        string jsonBody='{"action":"GET","body":"","endPoint":"'+APIMData.Endpoint__c+bookingId+'","headers":'+headerJson2+',"isIncreasedTimeout":true}';        
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName ='Generic_CMAPI'];
        
        req = HttpRequestUtil.populateHeaders(req);               
        req.setMethod('POST');
        req.setBody(jsonBody);
        req.setEndpoint(APIMData.Endpoint__c); 
        res=h.send(req); 
        string jsBody=res.getBody();
        system.debug('jsBody-->'+jsBody);
        //  string jsBody='{ "isAuthenticate": true, "errorMessages": null, "bookingId": "GOBUS377F490752", "busBookingInfo": { "noOfPassengers": 3, "passengerDetails": [ { "name": "Sheikh Test", "seatNumber": "16", "seatType": "", "status": "Cancelled", "fare": 600, "lineno": 10000, "age": "27", "gender": "Male" }, { "name": "Two Test", "seatNumber": "18", "seatType": "", "status": "Confirmed", "fare": 600, "lineno": 20000, "age": "30", "gender": "Female" } ] } }';
        SyncWrapper tData=new SyncWrapper();
        tData = (SyncWrapper)JSON.deserialize(jsBody,SyncWrapper.class);
        return tData;
    }
    
    public class SyncWrapper{
        public string bookingId;
        public string bookingDateTime;
        public BusBookingInfoWrapper busBookingInfo;     
        public BusAdditionalInfoWrapper busAdditionalInfo;   
    }
    
    public class BusBookingInfoWrapper{
        public integer noOfPassengers;
        public BusDetailWrapper busDetail;
        public List<PassengerInfoWrapper> passengerDetails;
    }
    
    public class BusDetailWrapper{
        public string operator;
        public string operatorid;
        public string operatorPnr;
        public string toCity;
        public string fromCity;
    }
    
    public class BusAdditionalInfoWrapper{
        public DepartureDetailWrapper departureDetail;
        public ArrivalDetailWrapper arrivalDetail;
    }
    
    public class DepartureDetailWrapper{
        public string departureTime;
    }
    public class ArrivalDetailWrapper{
        public string arrivalTime;
    }
    
    public class PassengerInfoWrapper{        
        public string name;
        public string lineno;
    }  
    public class CaseSyncWrapper{        
        public string caseId;
        public datetime doi;
        public datetime doj;
        public string source;
        public string destination;
        public string tinNo;
        public string noOfSeats;
        public string pnr;
        public string operatorId;
        public string operatorName;
    }
}