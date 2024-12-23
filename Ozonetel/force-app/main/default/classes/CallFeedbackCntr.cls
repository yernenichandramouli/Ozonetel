public class CallFeedbackCntr {
public boolean showimage{get;set;}
public boolean ratingInsert{get;set;}
public string selRating{get;set;}
public boolean fdbck{get;set;}
public boolean errWhileUpdate{get;set;}
public string UCId;
public string errorMsg{get;set;}
public List<Call_Details__c> listCallDet{get;set;}
public CallFeedbackCntr(){
 showimage=false;
 ratingInsert=false;
 fdbck=false;
 errWhileUpdate = false;
 errorMsg ='';
 }
 
 public String insertfdbck(){

    UCId=apexpages.currentpage().getparameters().get('UCId');
    
    listCallDet = [SELECT id,Call_Duration__c,Rating__c,Call_Unique_Id__c FROM Call_Details__c WHERE Call_Unique_Id__c=:UCId];

If(listCallDet.isEmpty())
{

errWhileUpdate = true;
errorMsg = 'Invalid Call Details.So,you can not submit review for this Call';
return null;

}

else
  showimage=String.isNotBlank(listCallDet[0].Rating__c)?false:true;
   
   return null;
    
}

public void performUpdate()
{  
    system.debug('selRating-->'+selRating+'--showimage-'+showimage);

  if(selRating!=null && showimage==true)
  {
    Call_Details__c cd = new Call_Details__c(id=listCallDet[0].id);
    cd.Rating__c=selRating;
    cd.Channel__c='IVR';
    cd.Submited_DateTime__c=system.now();
    cd.Call_Unique_Id__c=UCId;
try
  {
    update cd;
    ratingInsert=true;
    showimage=false;
 if(ratingInsert)
   fdbck=true;
}
catch(Exception e)
{
  errWhileUpdate = true;
  errorMsg = 'Something went wrong.Please retry after some time';

}
     
 }
 
}


}