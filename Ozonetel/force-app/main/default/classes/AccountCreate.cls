/**
* Name           : AccountCreate 
* Created Date   : 16 Oct 2017
* Created By     : Veeramanikanta R
* Purpose        : Account creation 
*
**/

public class AccountCreate {
    public Account acc{get;set;}
    public ID accRecTypeId;
    public boolean accbt{get;set;}
    
    public AccountCreate(ApexPages.StandardController controller) {
        acc=new Account();
        accbt=false;
    }
    
    public pagereference save(){
        PageReference pg;
        List<Account> acList=new List<Account>();
        try{            
            acList=[select id,PersonEmail,PersonMobilePhone from Account where PersonMobilePhone = :acc.PersonMobilePhone limit 1];
            if(acList.isEmpty()){
                 accbt=true;
                acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();                     
                System.debug('acc create-->'+acc);
                insert acc;
                pg = new PageReference('/'+acc.id);
                pg.setredirect(true);
                return pg;
            }else{              
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Account alredy exist with this mobile number'));              
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Some error Occured Please contact Admin! Error-->'+e));
        }
        return null;
    }
    
}