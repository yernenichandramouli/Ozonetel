/**
 * (c) 2017 RedBus
 *
 * Name           : DelBusOrItemandTravInfoSchedular
 * Created Date   : 25 Oct 2017
 * Created By     : Sreenivas M
 * Purpose        : Schedular class to delete Bus OrderItems,TravellerInfo,Accounts and Quotations
 *
 **/

 global class DelBusOrItemandTravInfoSchedular implements Schedulable 
 {
   global void execute(SchedulableContext sc) 
   {
      
     Map<String,DataDeletionSetup__mdt> mapDataDelSetup = new Map<String,DataDeletionSetup__mdt>();
      
      for(DataDeletionSetup__mdt datadel :[SELECT Id,updateQuery__c,FilterType__c,DeveloperName,Duration__c, QueryDetails__c, DistributionList__c,Batch_Size__c FROM DataDeletionSetup__mdt where isactive__c=true])
      {
        mapDataDelSetup.put(datadel.DeveloperName,datadel);
        
        if(!datadel.updateQuery__c)
        {
          database.executebatch(new GenericHardDeleteBatch(datadel.QueryDetails__c),Integer.valueOf(datadel.Batch_Size__c));
        }
        
        else
        {
            
            String finQry='';
            String queryDateStr='';

            if('Date'.equalsIgnoreCase(datadel.FilterType__c))
              queryDateStr=String.valueOf(System.today().addDays(-Integer.Valueof(datadel.Duration__c)));
            else
              queryDateStr=Datetime.now().addDays(-Integer.Valueof(datadel.Duration__c)).format('yyyy-MM-dd')+'T'+Datetime.now().addDays(-Integer.Valueof(datadel.Duration__c)).format('HH:mm')+':00.000Z';

            if('Account'.equalsIgnoreCase(datadel.DeveloperName) || 'Contact'.equalsIgnoreCase(datadel.DeveloperName))
                finQry = datadel.QueryDetails__c+queryDateStr+' AND (ID not In (SELECT AccountId FROM Case)) AND (ID not IN (SELECT Customer_Name__c FROM Case))';
            else
                finQry = datadel.QueryDetails__c+queryDateStr;
                
            database.executebatch(new GenericHardDeleteBatch(finQry),Integer.valueOf(datadel.Batch_Size__c));
        }
      }
      
     /* 
      Datetime d = Datetime.now();
      Datetime d2 = Datetime.now();
      d = d.addDays(-Integer.Valueof(Label.BusOrderItemDelDuration));
      d2 =d2.addDays(-Integer.Valueof(Label.AccountDeletionDuration));

      String busQuery = 'SELECT id FROM Bus_Order_Item_Details__c WHERE Createddate<'+d.format('yyyy-MM-dd')+'T'+d.format('HH:mm')+':00.000Z';
      String travQuery = 'SELECT id FROM Traveller_Info__c WHERE Createddate<'+d.format('yyyy-MM-dd')+'T'+d.format('HH:mm')+':00.000Z';
      String accountQuery = 'SELECT id FROM Account WHERE LastModifiedDate<'+d2.format('yyyy-MM-dd')+'T'+d2.format('HH:mm')+':00.000Z AND (ID not In (SELECT AccountId FROM Case)) AND (ID not IN (SELECT Customer_Name__c FROM Case))';
      String quotationQuery = 'SELECT id FROM Quotation__c WHERE Quote_Expiry_Date__c<Today';
      System.debug('---'+busQuery+'..'+travQuery+'..'+accountQuery+'..'+quotationQuery);
      
      // Delete Bus Order Items
       GenericHardDeleteBatch busOr = new GenericHardDeleteBatch(busQuery);
        database.executebatch(busOr,2000);
      
      // Delete Traveller Info
      GenericHardDeleteBatch travel = new GenericHardDeleteBatch(travQuery);
      database.executebatch(travel,2000);
      
      // Delete Accounts
       GenericHardDeleteBatch accnt = new GenericHardDeleteBatch(accountQuery);
       database.executebatch(accnt,2000);
       
      // Delete Quotations
       GenericHardDeleteBatch quot = new GenericHardDeleteBatch(quotationQuery);
       database.executebatch(quot,2000);
       */
   }
}