public class MultipleLeadsExtension {
public list<lead> leadList{get;set;}
public lead selLead{get;set;}
    public MultipleLeadsExtension(ApexPages.StandardController ctrl) {
    selLead=new lead();
        Lead ld=[select id,status,doj__c,lastname,phone,SrcCityName__c,DestCityName__c,DOJStart__c,DOJEnd__c from lead where id=:ctrl.getRecord().Id];
         leadList=new list<lead>();
         string leadQuery=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='MultipleLeads'].query__c;
         string phone=ld.phone;        
         datetime sourceDt=ld.DOJStart__c;
         datetime destDt=ld.DOJEnd__c;
         date doj=ld.doj__c;
         string source=ld.SrcCityName__c;
         string destination=ld.DestCityName__c;
         leadList= (List<lead>)Database.query(leadQuery);

         //leadList=[select id,status,lastname,Phone,SrcCityName__c,DestCityName__c,DOJStart__c,DOJEnd__c from lead where Phone=:ld.Phone and SrcCityName__c=:ld.SrcCityName__c and DestCityName__c=:ld.DestCityName__c and DOJStart__c=:ld.DOJStart__c and DOJEnd__c=:ld.DOJEnd__c];
        // leadList=[select id,status,lastname,Phone,SrcCityName__c,DestCityName__c,DOJStart__c,DOJEnd__c from lead limit 5];
        //select id,status,lastname,Phone,SrcCityName__c,DestCityName__c,DOJStart__c,DOJEnd__c from lead where Phone=:ld.Phone and SrcCityName__c=:ld.SrcCityName__c and DestCityName__c=:ld.DestCityName__c and DOJStart__c=:ld.DOJStart__c and DOJEnd__c=:ld.DOJEnd__c
    }
    
    public void AssignToMe(){
      
     System.debug('selLead-->'+selLead); 
    }
}