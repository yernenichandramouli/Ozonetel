/*
* Name           : LoginController
* Created Date   : 17 Oct 2017
* Created By     : Veeramanikanta R
* Purpose        : SF Site login functionality
* Test class     : LoginControllerTest
*/
public class LoginController {
    public string username{get;set;}
    public string password{get;set;}
    public boolean cp{get;set;}
    public boolean sp{get;set;}
    public string newPassword{get;set;}
    public string newPassword2{get;set;}
    public string button{get;set;}
    
    public LoginController(){
        
        sp=true;
        cp=false;
    }
    
    public pagereference signIn(){       
        System.debug('password -->'+password );       
        site_users__c sObj=new site_users__c();
        try{
            sObj=[select id,name,password__c,session_id__c,Country__c from site_users__c where name=:username and password__c=:password];
            
            if(sObj!=null){
                sObj.session_id__c='RB'+(integer)(Math.floor(Math.random() * (6000 - 100)) + 100);
                update sObj;
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Login Successfull'));               
                String pageName ;
                if(sObj.Country__c=='India')
                 pageName = [SELECT QueryDetails__c,DistributionList__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BDWorkflowAgent'].DistributionList__c;
                else
                pageName='BDIntldevQueuePage';
               
                PageReference pg = new PageReference('/apex/'+pageName+'?id='+sObj.id+'&session='+sObj.session_id__c);
                pg.setredirect(true);
                return pg;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Incorrect Username or Password, Please try again..'));
                return null;
            } 
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Incorrect Username or Password, Please try again!'));
            return null;            
        }
    }  
    public pagereference changePassword(){
        if(button=='cps'){
            cp=true;
            sp=false; 
        }else if(button=='sIns'){
            cp=false;
            sp=true; 
        }     
        return null;
    }
    public void updatePassword(){
        
        List<site_users__c> sList=new List<site_users__c>();
        System.debug('new pas-->'+newPassword);
        
        if(newPassword=='' && newPassword2==''&& password==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Password can not be empty'));
        }
        else if(newPassword!=newPassword2){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Incorrect Password'));            
        }else{            
            sList=[select id,name,password__c from site_users__c where name=:username and password__c=:password];
            if(!sList.isEmpty()){
                sList[0].password__c=newPassword;
                update sList;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Password has been changed successfully'));
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Invalid user name or password'));
            }
        }  
    }
}