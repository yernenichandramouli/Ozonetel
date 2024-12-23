/**
 * (c) 2017 RedBus
 *
 * Name           : B2BCancellationPolicyCntr
 * Created Date   : 3 Aug 2019
 * Created By     : Mahendra k
 * Purpose        : To check cancellation Policy of b2b2 tickets
 *
 **/
 
public class B2BCancellationPolicyCntr {
public list<Wrapperclass> wrapperList{get;set;}
public Order_Items__c orItemId{get;set;}
public string inventoryItems{get;set;}
public string railItems{get;set;}
public list<InventoryWrapper> inventWrapper{get;set;}   
public list<railsWrapper> railDetailsWrapper {get;set;}
 public B2BCancellationPolicyCntr(ApexPages.StandardController controller){
    wrapperList=new list<Wrapperclass>();
    inventWrapper = new list<InventoryWrapper>();
    railDetailsWrapper = new list<railsWrapper>();
    this.orItemId=(Order_Items__c)controller.getRecord(); 
   if(string.isNotBlank(orItemId.id)){
    orItemId= [Select Primary_Boarding_Point_Time__c,B2B_Cancellation_Timestamp__c,Item_Type__c,Traveller_Details__c,Service_Start_Time__c,First_Boarding_Point_Time__c,Seatadditionaldetails__c,Order_Id__c,Cancellation_Policy__c from Order_Items__c Where id=:orItemId.id];
     system.debug('OrdeItems line 24--'+orItemId);
    if(string.isNotblank(orItemId.Seatadditionaldetails__c)){
      inventoryItems=orItemId.Seatadditionaldetails__c;
      inventoryDetails(inventoryItems);
    }
    else if(string.isNotblank(orItemId.Traveller_Details__c) && orItemId.Item_Type__c=='RAILS'){
      railItems=orItemId.Traveller_Details__c;
      system.debug('::::::: railItems ::::::::' +railItems);
      railsTravelDetails(railItems);
    }
    system.debug('ordItem-->'+orItemId );
    fetchCanclPolicyDetails();
    }
 } 
 
public void fetchCanclPolicyDetails()
  {
    datetime cdate;
    string cancelpolicytime;
    string cancellationpolicy;
    datetime PrimaryBoardingPointTime; 
    list<string> canclSplit;
    string timeofCancellation ;
    string cancellationPercent;
    string suffix1;
    string suffix2;
    
    system.debug('policy--->'+orItemId.Cancellation_Policy__c);
    
    if (string.isBlank(orItemId.Cancellation_Policy__c) || orItemId.Cancellation_Policy__c=='0:-1:-1:-1;')
    {
        timeofCancellation='Wrong cancellation Policy';
        cancellationPercent='0%';
        wrapperList.add(new Wrapperclass(timeofCancellation,cancellationPercent));
    }
    
    if(String.isNotBlank(string.valueof(orItemId.Cancellation_Policy__c)) && orItemId.Cancellation_Policy__c!='0:-1:-1:-1;')
    {
        PrimaryBoardingPointTime=orItemId.B2B_Cancellation_Timestamp__c;
        if(PrimaryBoardingPointTime==null)
        PrimaryBoardingPointTime=orItemId.Service_Start_Time__c;
        if(PrimaryBoardingPointTime==null)
        PrimaryBoardingPointTime=orItemId.First_Boarding_Point_Time__c;
        if(PrimaryBoardingPointTime==null)
        PrimaryBoardingPointTime=orItemId.Primary_Boarding_Point_Time__c;
        
        system.debug('PBPT-->>'+(PrimaryBoardingPointTime.format()));
        cancellationpolicy=string.valueof(orItemId.Cancellation_Policy__c );
        system.debug('cancelpolicytime-->>'+cancellationpolicy);
        canclSplit=cancellationpolicy.split(';');
        system.debug('cancpolicy-->>'+canclSplit);
        Integer counter = 0;
 
      for(String s:canclSplit)
      {
        counter++;
        system.debug('counter -->>'+counter);
        list<string> cancell = s.split(':');
       
        string percent=cancell[2];
        
         string hour1= cancell[0];
         string hour2=cancell[1];
         
         datetime primaryboarding1=PrimaryBoardingPointTime.addHours(-(integer.valueof(hour1)));
         datetime primaryboarding2=PrimaryBoardingPointTime.addHours(-(integer.valueof(hour2)));
         system.debug('primaryboarding2 Day-->>>'+primaryboarding2.day());
         system.debug('primaryboarding2-->>'+primaryboarding2+'primaryboarding1-->'+primaryboarding1);
         
         string time1=primaryboarding1.format('hh:mm a');
         string time2=primaryboarding2.format('hh:mm a');
         
         string va1=string.valueof(primaryboarding1.day());
         string va2=string.valueof(primaryboarding2.day());
         
         if(va1.endsWith(string.valueof(11)) || va1.endsWith(string.valueof(12)) || va1.endsWith(string.valueof(13))){
           suffix1='th';
          }else if(va1.endsWith(string.valueof(1))){
             suffix1='st';
          }else if(va1.endsWith(string.valueof(2))){
            suffix1='nd';
          }else if(va1.endsWith(string.valueof(3))){
            suffix1='rd';
          }else{
           suffix1='th';
          }
          
          if(va2.endsWith(string.valueof(11)) || va2.endsWith(string.valueof(12)) || va2.endsWith(string.valueof(13))){
           suffix2='th';
          }else if(va2.endsWith(string.valueof(1))){
             suffix2='st';
          }else if(va2.endsWith(string.valueof(2))){
            suffix2='nd';
          }else if(va2.endsWith(string.valueof(3))){
            suffix2='rd';
          }else{
           suffix2='th';
         }
          
          
         string d1=va1+suffix1+' '+primaryboarding1.format('MMM');
         string d2=va2+suffix2+' '+primaryboarding2.format('MMM');
         if(counter==1 && cancell[1]!='-1'&& cancell[2]== '100'){
          timeofCancellation ='After '+' '+time2+' '+' on '+' '+d2;
          cancellationPercent=percent+'%';
          wrapperList.add(new Wrapperclass(timeofCancellation,cancellationPercent));

       }else if(cancell[1]!='-1'){
          timeofCancellation ='Between '+' '+time2 +' '+'on '+ d2 +' - '+ time1 +' '+'on '+' '+ d1;
          cancellationPercent=percent+'%';
          wrapperList.add(new Wrapperclass(timeofCancellation,cancellationPercent));
        }
      if(cancell[1]=='-1'){
          timeofCancellation='Till'+' '+time1 +' '+'on '+ d1;
          cancellationPercent=percent+'%';
          wrapperList.add(new Wrapperclass(timeofCancellation,cancellationPercent));
 
        } 
      }     
    }
   
  }
  
  
public void inventoryDetails(string inveDtls){
  system.debug('inveDtls-->>'+inveDtls);
inventWrapper  = (list<InventoryWrapper>)JSON.deserialize(inveDtls, list<InventoryWrapper>.class);

system.debug('inven-->>'+inventWrapper[0].passenger);
     
}
public class Passenger
{
    public string age { get; set; }
    public string email { get; set; }
    public string gender { get; set; }
    public string idType { get; set; }
    public string mobile { get; set; }
    public string name { get; set; }
    public string primary { get; set; }
    public string singleLadies { get; set; }
    public string title { get; set; }
}

public class InventoryWrapper
{
    public string fare { get; set; }
    public string ladiesSeat { get; set; }
    public string malesSeat { get; set; }
    public string operatorServiceCharge { get; set; }
    public Passenger passenger { get; set; }
    public string seatName { get; set; }
    public string serviceTax { get; set; }
    public string status { get; set; }
    public string refundAmount{ get; set; }
}

Public class Wrapperclass
{
    public string cancellationTime{get; set;}
    public string percentofCancl{get; set;}
    
public Wrapperclass(string cancellationTime,string percentofCancl){
 this.cancellationTime=cancellationTime;
 this.percentofCancl=percentofCancl;
 
  }

  }

  public void railsTravelDetails(string inveDtls){
    system.debug('::: railDetails :::::'+inveDtls);
    railDetailsWrapper  = (list<railsWrapper>)JSON.deserialize(inveDtls, list<railsWrapper>.class);
  
  system.debug('::::: railDetailsWrapper:::::'+railDetailsWrapper[0]);
       
  }
  public class travellerDetails
{
    public string title { get; set; }
    public string seniorCitizenApplicable { get; set; }
    public string passengerICardFlag { get; set; }
    public string nationality { get; set; }
    public string name { get; set; }
    public string gender { get; set; }
    public string foodPreference { get; set; }
    public string berthPreference { get; set; }
    public string age { get; set; }
}

public class bookingSeatDetails
{
    public string bookingStatusIndex { get; set; }
    public string bookingStatus { get; set; }
    public string bookingCoachId { get; set; }
    public string bookingBerthNo { get; set; }
    public string bookingBerthCode { get; set; }
    public string bookingBerthChoice { get; set; }
}

public class currentSeatDetails{

  public String currentStatusIndex { get; set; }
  public String currentStatus { get; set; }
  public String currentCoachId { get; set; }
  public String currentBerthNo { get; set; }
  public String currentBerthCode { get; set; }
  public String currentBerthChoice { get; set; }

}

public class railsWrapper
{
    public string passengerNetFare { get; set; }
    public travellerDetails travellerDetails { get; set; }
    public bookingSeatDetails bookingSeatDetails { get; set; }
    public currentSeatDetails currentSeatDetails { get; set; }
}


}