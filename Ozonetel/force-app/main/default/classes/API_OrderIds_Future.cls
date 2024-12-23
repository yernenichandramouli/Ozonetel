/*
* Name           : API_OrderIds_Future
* Created Date   : 20 Sep 2017
* Created By     : Veeramanikanta R
* Purpose        : API for insert mobile recharge items in SF 
* Test class     : API_OrderIdsTest
*/
public without sharing class API_OrderIds_Future
{
    @future(callout=true)
    public static void RechargeCreation(string jsonBody){
        
        Response r=new Response();
        List<Response> respWrapper= (List<Response>)System.JSON.deserialize(jsonBody,List<Response>.class);
        System.debug('respWrapper--->'+respWrapper);
        
        List<PostGres_Data__c> pgList=new List<PostGres_Data__c>();
        Set<string> pEmails=new Set<string>();
        Set<string> pMobiles=new Set<string>();
        
        for(Response re:respWrapper){        
            if(re.email!='')
                pEmails.add(re.email);
            
            if(re.mobile!='')
                pMobiles.add(re.mobile);
            
        }  
        set<string> emailAndMobile=new set<string>();
        Map<string,Account> accountMap=new Map<string,Account>();     
        
        for(Account acc:[select id,Email__c,PersonEmail,PersonMobilePhone,Phone_10_Digits__c from Account where  PersonEmail in: pEmails OR PersonMobilePhone in :pMobiles OR Phone_10_Digits__c in :pMobiles]){           
            
            if(acc.PersonEmail!='' && acc.PersonEmail!=null){
                emailAndMobile.add(acc.PersonEmail);
                accountMap.put(acc.PersonEmail,acc);
            }
            
            if(acc.PersonMobilePhone!='' && acc.PersonMobilePhone!=null){
                emailAndMobile.add(acc.PersonMobilePhone);
                accountMap.put(acc.PersonMobilePhone,acc);
            }
            
            if(acc.Phone_10_Digits__c !='' && acc.Phone_10_Digits__c !=null){
                emailAndMobile.add(acc.Phone_10_Digits__c );
                accountMap.put(acc.Phone_10_Digits__c ,acc);
            }
            
        }
        
        System.debug('emailAndMobile -->'+emailAndMobile );
        List<Account> newCustomer=new List<Account>();//Used for create new Customers
        set<string> setMobile=new set<string>();//Used for get unique mobile from response
        set<string> setEmail=new set<string>();// Used for get unique email from response
        
        for(Response re:respWrapper){
            String value = re.mobile;
            string sMobile='91'+value;
            // System.debug('f-->'+re.mobile);
            
            if(setEmail.contains(re.email)==FALSE && setMobile.contains(re.mobile)==FALSE && emailAndMobile.contains(re.email)==FALSE && emailAndMobile.contains(re.mobile)==FALSE && emailAndMobile.contains(sMobile)==FALSE){                         
                // System.debug('f a-->'+re.mobile);
                Account acc=new Account();
                acc.lastname=re.mobile;
                if(Pattern.matches('^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$', re.email)){
                acc.PersonEmail=re.email;
                }
                acc.Phone_10_Digits__c=re.mobile;
                acc.PersonMobilePhone=re.mobile;
                acc.AccountSource='Mobile Recharge';
                
                if(re.email!='') 
                    setEmail.add(re.email);
                if(re.mobile!='')
                    setMobile.add(re.mobile);      
                
                // System.debug('setEmail-->'+setEmail);
                // System.debug('setMobile-->'+setMobile);          
                newCustomer.add(acc);              
            }
        } 
        
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        
        if(jsonBody.length()>10000)
            dbl.Orders_Received_Data_Ids__c=jsonBody.substring(0,10000);
        else
            dbl.Orders_Received_Data_Ids__c=jsonBody;
        
        
        try{
            if(!newCustomer.isEmpty())
                insert newCustomer;
            
            set<id> acIds=new set<id>(); 
            for(Account a:newCustomer){
                if(a.PersonEmail!='')
                    accountMap.put(a.PersonEmail,a);
                
                if(a.PersonMobilePhone!='')
                    accountMap.put(a.PersonMobilePhone,a);
                
                acIds.add(a.id);
            }
            dbl.Type__c='Recharge - Success';
            string allAccIds=string.valueof(acIds);
            if(allAccIds.length()>10000){
                dbl.New_Customers_RC__c='Size-->'+newCustomer.size()+'-Ids-->'+allAccIds.substring(0,10000);
            }else{
                dbl.New_Customers_RC__c='Size-->'+newCustomer.size()+'-Ids-->'+allAccIds;
            }           
        }catch(Exception e){
            dbl.Type__c='Recharge - Fail';
            dbl.Exception_Description__c='Exception at Account Insertion-->'+e;                  
        } 
        
        System.debug('accountMap-->'+accountMap);
        list<string> orderIds = new list<string>();
        list<DB_Log__c> DBLog = new list<DB_Log__c>();
        
        
        for(Response re:respWrapper){
            PostGres_Data__c pg=new PostGres_Data__c();
            pg.order_id__c=re.id;
            System.debug('Check e45-->'+Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', re.email));
            if(Pattern.matches('^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$', re.email)){
            pg.email__c=re.email;
            }
            pg.mobile__c=re.mobile;            
            pg.type__c=re.type;
            pg.Status__c=re.status;
            pg.Created_Date_Time__c=datetime.valueOf(re.createddate).addminutes(330);           
            //pg.Created_Date_Time__c=pg.Created_Date_Time__c.addminutes(330);
            
            if(accountMap.containsKey(re.email)){
                pg.Account__c=accountMap.get(re.email).id;
            } else if(accountMap.containsKey(re.mobile)){
                pg.Account__c=accountMap.get(re.mobile).id;          
            } 
            orderIds.add(re.id);         
            pgList.add(pg);
        }              
        
        if(!pgList.isEmpty()){
            try{
                //upsert pgList order_id__c;
                Database.UpsertResult[] upsertResult = Database.upsert(pgList,PostGres_Data__c.order_id__c,false);
                System.debug('upsertResult --->'+upsertResult.size());
                
                list<string> SuccessList = new list<string>();
                list<string> FailedList = new list<string>();
                list<string> FailedDesscList = new list<string>();
                for(Integer i=0;i<upsertResult.size();i++)
                {
                    if (upsertResult.get(i).isSuccess())
                    {
                        SuccessList.add(orderIds[i]);
                    }
                    else if(!upsertResult.get(i).isSuccess())
                    {
                        DB_Log__c DB = new DB_Log__c();
                        DB.Object_Name__c = 'Recharge';                          
                        DB.ID__c = string.valueof(orderIds[i]);     
                        DB.Error_Description__c = string.valueof(upsertResult.get(i).getErrors());                          
                        DBLog.add(DB);
                        FailedList.add(orderIds[i]);
                        FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                    }
                }
                
                
            }catch(Exception e){
                dbl.Type__c='Recharge - Fail';
                dbl.Exception_Description__c='Exception at Recharge Insertion-->'+e;                
            }
        }
        insert dbl;        
        
        if(!DBLog.isEmpty())
        {
            for(integer i=0; i<DBLog.size(); i++)
            {
                DBLog[i].DBLog_Summary__c = dbl.id;
            }
            database.insert(DBLog);
        }
        
        System.debug('pgList-->'+pgList.size());        
        
    }
    public class Response{
        public string id{get;set;}
        public string email{get;set;}
        public string mobile{get;set;}
        public string type{get;set;}
        public string status{get;set;}
        public string createddate{get;set;}
    }
    
}