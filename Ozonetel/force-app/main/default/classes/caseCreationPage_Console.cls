public class caseCreationPage_Console 
{
    Public Case newCase{get;set;}
    public List<SelectOption> transactions{get;set;}
    public String selectedTransaction{get;set;}
    public String accId;
    public string popupDescription{get;set;}
    public caseCreationPage_Console(ApexPages.StandardController controller) 
    {
        accId = ApexPages.CurrentPage().getParameters().get('accId');
        selectedTransaction = '';
        transactions = new List<SelectOption>();
        transactions.add(new SelectOption('','--None--'));
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('InBound Call').getRecordTypeId();
        newCase = new Case(RecordTypeId = recTypeId);
        newCase.Country__c = [SELECT id,name,Country from User WHERE Id=:UserInfo.getUserId()].Country;
        newCase.Business_Type__c = [SELECT id,name,Business_Type__c from User WHERE Id=:UserInfo.getUserId()].Business_Type__c;
        if(!String.IsBlank(accId))
        {
            newCase.AccountId = accId;
            for(Order_Items__c t : [SELECT Id,Name,Source__c,Destination__c,Date_Of_Service__c,Order_Id__c FROM Order_Items__c WHERE (Customer_Name__c =: accId OR Primary_Contact_Customer__c =: accId)])
            {
                String datess = 'NA';
                String source = 'NA';
                String dest = 'NA';
                String tripId = 'NA';
                if(t.Date_Of_Service__c!=Null)
                {
                    datess = String.Valueof(Date.Valueof(t.Date_Of_Service__c));
                }
                if(!String.IsBlank(t.Order_Id__c))
                {
                    tripId = t.Order_Id__c;
                }
                if(!String.IsBlank(t.Source__c))
                {
                    source = t.Source__c.left(5);
                }
                if(!String.IsBlank(t.Destination__c))
                {
                    dest = t.Destination__c.left(5);
                }
                transactions.add(new SelectOption(t.Id,tripId+'-'+source+'-'+dest+'-('+datess+')'));
            }
        }
        
    }
    public pageReference saveAll()
    {
        try{
            if(newCase.Does_Customer_Require_CallBack__c)
                newCase.CallBack_Requested_Time__c = System.now().addHours(Integer.valueOf(newCase.Call_Back_Time__c));
                
            if(!String.IsBlank(selectedTransaction))
            {
                Order_Items__c tObj=[select id,Business_Unit__c from Order_Items__c where id=:selectedTransaction];
                newCase.Transaction_ID__c = selectedTransaction;
                newCase.Business_Unit_ct__c=tObj.Business_Unit__c;
                insert newCase;
                return new PageReference('/'+newCase.Id);
            }
            else //if(transactions.IsEmpty())
            {
                insert newCase;
                return new PageReference('/'+newCase.Id);
            }
            /*else if(String.IsBlank(selectedTransaction) && !transactions.IsEmpty())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select Trip Id..!!'));
                return null;
            }*/
            return null;
            
        }catch(exception e){ApexPages.addMessages(e); return null;}
        return null;
    }
    
     }