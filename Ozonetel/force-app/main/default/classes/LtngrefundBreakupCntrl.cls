/**
* (c) 2018 RedBus
*
* Name           : LtngrefundBreakupCntrl
* Created Date   : 18 jul 2018
* Created By     : Mahendra K
* Purpose        : Controller class for Refundbreakup  Page
*
**/

public class LtngrefundBreakupCntrl {
    
    public string tinn{get;set;}
    public string emailid{get;set;}
    public string busnsunt{get;set;}
    public string orderUuid{get;set;}
    public Integer  travelTime{get;set;}
    public List<Order_Items__c> listOrIt{get;set;}
    public list<Refund_Order_Items__c> listRefundOrIt{get;set;}
    public Order_Items__c OrIt{get;set;}
    public RootObject refundl{get;set;}
    public wrapperclass wpprcls{get;set;}
    public string currencyType{get;set;}
    public string mints{get;set;}
    public String hrsBefore{get;set;}
    public integer sizeofRefundOrditms{get;set;}
    public LtngrefundBreakupCntrl(){
        String tId=Apexpages.currentpage().getparameters().get('Id');
        system.debug('tId===>>>'+tId);
        listOrIt= new list<Order_Items__c>();
        listRefundOrIt= new list<Refund_Order_Items__c>();
        OrIt= new Order_Items__c();
        listOrIt=[select id,name,Total_Fare_Currency__c,OrderUuid__c,Order_Item_Reference_No__c,Cancelled_Time__c,Primary_Boarding_Point_Time__c,Email__c,Cancellation_Time__c,Cancellation_Policy__c,Order_Uuid__c,Seat_No__c,No_Of_Seats__c,Business_Unit__c from Order_Items__c where ID=:tId];
       
       if(!listOrIt.isEmpty()){
            
            orIt = listOrIt[0];
            listRefundOrIt= [Select id,Refunded_Amount__c from Refund_Order_Items__c where Order_Item_Name__c =:orIt.id];
            sizeofRefundOrditms=listRefundOrIt.size();
            if(sizeofRefundOrditms>0){
            tinn = String.isNotBlank(orIt.Order_Item_Reference_No__c)?orIt.Order_Item_Reference_No__c:'';
            emailid=String.isNotBlank(orIt.Email__c)?orIt.Email__c:'';
            busnsunt=String.isNotBlank(orIt.Business_Unit__c)?orIt.Business_Unit__c:'';
            orderUuid=String.isNotBlank(orIt.OrderUuid__c)?orIt.OrderUuid__c:'';
            currencyType =String.isNotBlank(orIt.Total_Fare_Currency__c)&&'INR'.equalsIgnoreCase(orIt.Total_Fare_Currency__c)?'Rs.':orIt.Total_Fare_Currency__c+'.';
            Double bordingTime = 0;
            double cancelTime = 0;
            
           if(orIt.Primary_Boarding_Point_Time__c != null){
              bordingTime = orIt.Primary_Boarding_Point_Time__c.getTime();
           }
           
           if(orIt.Cancellation_Time__c != null){
             cancelTime = orIt.Cancellation_Time__c.getTime();
           }
           
           if(cancelTime>bordingTime)
           {
                Decimal  travelTime = cancelTime - bordingTime; 
                string inHours = string.valueof(travelTime / 3600000 );
                list<string> hoursMin =inHours.split('\\.'); 
                mints = string.valueof(Double.valueOf('.'+hoursMin[0]) * 60.0);
                system.debug('mints==>>'+mints);
                hrsBefore = hoursMin[0]+' Hrs '+mints.split('\\.')[0]+' Min After Travel';
           }
           else
           {
                Decimal  travelTime = bordingTime-cancelTime; 
                string inHours = string.valueof(travelTime / 3600000 );
                list<string> hoursMin =inHours.split('\\.'); 
                mints = string.valueof(Double.valueOf('.'+hoursMin[0]) * 60.0);
                system.debug('mints==>>'+mints);
                hrsBefore = hoursMin[0]+' Hrs '+mints.split('\\.')[0]+' Min Before Travel';
           }
      
        
        }
        }
    }
    
    public  void refund(){
        
        //String jsonBody = '{"tin":"'+tinn+'","email":"'+emailid+'","businessUnit":"'+busnsunt+'"}';
        String jsonBody = '';
        if(String.isNotBlank(tinn)){
            jsonBody = '{"tin":"'+tinn+'","email":"'+emailid+'","businessUnit":"'+busnsunt+'"}';
        }else{
            jsonBody = '{"tinn":"","uuid":"'+orderUuid+'","email":"'+emailid+'","businessUnit":"'+busnsunt+'"}';
        }
        
        
        system.debug('jsonBody==>>'+jsonBody);
        refundl = new RootObject();
        Map<string,OrderItemTransactionResource__c > mapOrdrtrsc = OrderItemTransactionResource__c.getAll();
        string countryCode = '';
        if(mapOrdrtrsc.containskey(busnsunt)){   
            
            countryCode = mapOrdrtrsc.get(busnsunt).Auth_Key__c;
        }
        
        HTTP ht = new HTTP();  
        HttpRequest req= new HttpRequest();
        HTTPResponse resp=new HTTPResponse();
        req.setHeader('Content-Type','application/json');  
        req.setHeader('Country_Name',countryCode);
        req.setMethod('POST');
        String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='RefundBreakup'].Endpoint__c;
        req.setEndpoint(endPoint);
        system.debug('setbody==>>'+jsonBody);
        req.setbody(jsonBody);
        //req.setbody('{"tin":"TM4488317483", "email":"eesha.karanwal@redbus.in", "businessUnit":"REDBUS_IN"}');
        resp=ht.send(req);
        system.debug('resp==>>'+resp.getbody());
        
        if(resp!=null && resp.getStatusCode()==200 && String.isNotBlank(resp.getBody()))
        {
            refundl= (RootObject)JSON.deserialize(resp.getBody(),RootObject.class);
            system.debug('refundl===>>>'+refundl);
            
            Response refResponse = refundl.response;
            system.debug('Response==>'+refResponse);
            List<Datum> resData = refResponse.data;
            system.debug('resData==>>'+resData);
            List<SeatWiseRefundable> seatwseRefundlist  = new  List<SeatWiseRefundable> ();
            for(Datum dat : resData){
                
                seatwseRefundlist.addAll(dat.seatWiseRefundables);
                
            } 
            system.debug('seatwseRefundlist==>>'+seatwseRefundlist);
            List<PriceBreakUp> pricekBrkuplist = new List<PriceBreakUp>();
            for(SeatWiseRefundable setrfund  : seatwseRefundlist){
                
                pricekBrkuplist.addAll(setrfund.priceBreakUp);
                
            }  
            system.debug('pricekBrkuplist==>>'+pricekBrkuplist);
            Double totalBasicFare = 0;
            Double totalBasicRefund = 0;
            Double totalServicetax = 0;
            Double totalRefundServiceTax = 0;
            Double totalInsurance = 0;
            Double totalRefundInsurance = 0; 
            
            for(PriceBreakUp pb:pricekBrkuplist){
                //Calculate Total Basic fare and refund amount
                if(pb.componentName == 'BASIC_FARE'){
                    totalBasicFare = totalBasicFare + pb.value;
                    totalBasicRefund = totalBasicRefund + pb.refundableValue;
                }
                //Calculate Total Service tax and refund amount
                if(pb.componentName == 'SERVICE_TAX'){
                    totalServicetax = totalServicetax + pb.value;
                    totalRefundServiceTax = totalRefundServiceTax + pb.refundableValue;
                }
                //Calculate Total Insurance chareges and refund
                if(pb.componentName == 'INSURANCE_CHARGES'){
                    totalInsurance = totalInsurance + pb.value;
                    totalRefundInsurance = totalRefundInsurance + pb.refundableValue;
                }
            }  
            
       
            System.debug('totalRefundInsurance===>>>>'+totalRefundInsurance);  
            system.debug('otherRefundables1==>>'+refundl.response.data[0].otherRefundables[0].value);
            system.debug('otherRefundables2==>>'+refundl.response.data[0].otherRefundables[0].refundableValue);
            Double totalconNonrefund = refundl.response.data[0].otherRefundables[0].value - refundl.response.data[0].otherRefundables[0].refundableValue;
            Double nonRefundamount = totalconNonrefund+refundl.response.data[0].discount + refundl.response.data[0].cancellationCharges;

          
            system.debug('totalconNonrefund==>>'+totalconNonrefund);
            wpprcls = new wrapperclass(refundl.response.data[0].seatWiseRefundables[0].seatFare,
                                       refundl.response.data[0].otherRefundables[0].value,
                                       refundl.response.data[0].cancellationCharges,
                                       refundl.response.data[0].totalFare,
                                       refundl.response.data[0].refundAmount,
                                       refundl.response.data[0].discount,
                                       Double.valueof(refundl.response.data[0].cancellationPercent),
                                       refundl.response.data[0].otherRefundables[0].refundableValue,  
                                       totalBasicFare,
                                       totalBasicRefund,
                                       totalServicetax,
                                       totalRefundServiceTax,
                                       totalInsurance,
                                       totalRefundInsurance,
                                       nonRefundamount,
                                       totalconNonrefund,
                                       Double.valueof(seatwseRefundlist.size())
                                      );  
        }  
        else 
        {
            map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(resp.getBody());
              system.debug('resbody==>>'+resp.getBody());
            String errMsg = '';
            if(resMap.get('errorMessage') != null){
                errMsg  = (String)resMap.get('errorMessage');
            }
            system.debug('errMsg==>>'+errMsg);
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errMsg);
            ApexPages.addMessage(errorMsg);
        }
    }    
    public class PriceBreakUp
    {
        public double value { get; set; }
        public string type { get; set; }
        public double refundableValue { get; set; }
        public Boolean isCancellationPolicyApplicable { get; set; }
        public string componentName { get; set; }
    }
    
    public class SeatWiseRefundable
    {
        public string seatName { get; set; }
        public double seatFare { get; set; }
        public double refundAmount { get; set; }
        public double cancellationCharge { get; set; }
        public List<PriceBreakUp> priceBreakUp { get; set; }
        public object componentName { get; set; }
    }
    
    public class OtherRefundable
    {
        public double value { get; set; }
        public double refundableValue { get; set; }
        public string componentName { get; set; }
    }
    
    public class Datum
    {
        public double totalFare { get; set; }
        public string tin { get; set; }
        public List<SeatWiseRefundable> seatWiseRefundables { get; set; }
        public string refundFor { get; set; }
        public double refundAmount { get; set; }
        public List<OtherRefundable> otherRefundables { get; set; }
        public string itemUuid { get; set; }
        public double discount { get; set; }
        public string cancellationPercent { get; set; }
        public double cancellationCharges { get; set; }
    }
    
    public class Response
    {
        public string status { get; set; }
        public List<object> errors { get; set; }
        public List<Datum> data { get; set; }
    }
    
    public class RootObject
    {
        public double status { get; set; }
        public object errorMessage { get; set; }
        public string successMessage { get; set; }
        public Response response { get; set; }
        
    }
    
    public class wrapperclass{
        public Double discountval{get;set;}
        public Double seatfareval{get;set;}
        public Double convenienceFee{get;set;}
        public Double totalamount{get;set;}
        public Double totalRefund{get;set;}
        public Double noOfSeats{get;set;}
        public Double totalBFare{get;set;}
        public Double totalRefundBfare{get;set;}
        Public Double totalStax{get;set;}
        public Double totalRefundStax{get;set;}
        public Double totalInsurance{get;set;}
        public Double totalInsurRefund{get;set;}
        public Double cancelationcharge{get;set;}
        public Double cancelstionPercentage{get;set;}
        public Double nonRefundamount{get;set;}
        public Double coveNonrefundval{get;set;}
        public Double totalconNonrefund{get;set;}
        public Double discount{get;set;}
        public wrapperclass(Double setFare,Double covnFee,Double canclcrge,Double totalamnt,Double totalrfnd,Double disc,Double canclprctng,Double convrefnd,Double totalBasicfare,Double totalRefAmt,Double totStax,Double totReftax,Double totInsur,Double totInsuRefu,Double nonRefund,Double totlconvrefund,Double noOfst)
        {
          system.debug('totalconNonrefund==>>'+totalconNonrefund);
            seatfareval = setFare;
            cancelationcharge=canclcrge;
            totalamount = totalamnt;
            discount = disc;
            nonRefundamount= nonRefund;
            totalRefund =totalrfnd;
            convenienceFee=covnFee;
            coveNonrefundval=convrefnd;
            totalconNonrefund=totlconvrefund;
            cancelstionPercentage=canclprctng;
            totalBFare = totalBasicfare;
            totalRefundBfare = totalRefAmt;
            totalStax = totStax;
            totalRefundStax = totReftax;
            totalInsurance = totInsur;
            totalInsurRefund = totInsuRefu;
            noOfSeats = noOfst;
        }
        
    }
    
}