public class RedProReport{
    
    @future
    public static void CaseDetails(){
        list<case> csList;
        DataDeletionSetup__mdt redProQuery=new DataDeletionSetup__mdt();
        List<Messaging.EmailFileAttachment> email_attachments = new List<Messaging.EmailFileAttachment>();
         set<string> repStr=new set<string>();
       repStr.add('last30days');
       repStr.add('MTD');
       
       for(string srep:repStr){
       if(srep=='last30days'){
        redProQuery=[SELECT QueryDetails__c,DistributionList__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='redProReport'];
        }else{
        redProQuery=[SELECT QueryDetails__c,DistributionList__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='redProReport_MTD'];
        }
        
        csList= (List<case>)Database.query(redProQuery.QueryDetails__c);
        //csList=[select id,casenumber,status,Service_Provider_Id__c,Service_Provider_Name__c,BD_Location2__c,BD_Location__c,Case_Age__c,BO_Action__c,Closed_Date_and_Time__c,Closed_Duration_in_Hrs__c,createddate from case where Service_Provider_Id__c!=null ];
        Map<string,integer> openCases=new Map<string,integer>();
        Map<string,integer> ageOne=new Map<string,integer>();
        Map<string,integer> ageTwo=new Map<string,integer>();
        Map<string,integer> ageThree=new Map<string,integer>();
        Map<string,integer> closedAgeOne=new Map<string,integer>();
        Map<string,integer> closedAgetwo=new Map<string,integer>();
        Map<string,integer> closedAgeThree=new Map<string,integer>();
        
        Map<string,integer> closedByAgents=new Map<string,integer>();
        Map<string,integer> closedWithredPro=new Map<string,integer>();
        Map<string,string> boName=new Map<string,string>();
        Map<string,string> boLocation=new Map<string,string>();
        Map<string,decimal> agentTAT=new Map<string,decimal>();
        Map<string,decimal> boTAT=new Map<string,decimal>();
        Map<string,integer> totalClosed=new Map<string,integer>();
        Map<string,integer> totalCases=new Map<string,integer>();
        
        Map<string,integer> openRedProActioned=new Map<string,integer>();
        Map<string,decimal> openRedProTAT=new Map<string,decimal>();
        Map<string,integer> openRedProActAgreed=new Map<string,integer>();
        Map<string,integer> openRedProActDisAgreed=new Map<string,integer>();
        Map<string,integer> openRedProActInfoReq=new Map<string,integer>();
        
        Map<string,integer> closedRedProActAgreed=new Map<string,integer>();
        Map<string,integer> closedRedProActDisAgreed=new Map<string,integer>();
        Map<string,integer> closedRedProActInfoReq=new Map<string,integer>();
        Map<string,integer> closedOnCreate=new Map<string,integer>();

        List<string> allBoList=new List<string>();
        
        for(case c:csList){
            
            if(!allBoList.contains(c.Service_Provider_Id__c)){
                allBoList.add(c.Service_Provider_Id__c);
                boName.put(c.Service_Provider_Id__c,c.Service_Provider_Name__c);
                if(string.isNotBlank(c.BD_Location2__c))
                    boLocation.put(c.Service_Provider_Id__c,c.BD_Location2__c);
                else
                    boLocation.put(c.Service_Provider_Id__c,c.BD_Location__c);    
            }
            
            if(totalCases.get(c.Service_Provider_Id__c)!=null){
                totalCases.put(c.Service_Provider_Id__c,totalCases.get(c.Service_Provider_Id__c)+1);
            }else{
                totalCases.put(c.Service_Provider_Id__c,1);
            }  
            
            if(c.status!='Closed'){
                if(openCases.get(c.Service_Provider_Id__c)!=null){
                    openCases.put(c.Service_Provider_Id__c,openCases.get(c.Service_Provider_Id__c)+1);
                }else{
                    openCases.put(c.Service_Provider_Id__c,1);
                }               
            }
            
            if(c.status=='Closed'){
                if(totalClosed.get(c.Service_Provider_Id__c)!=null){
                    totalClosed.put(c.Service_Provider_Id__c,totalClosed.get(c.Service_Provider_Id__c)+1);
                }else{
                    totalClosed.put(c.Service_Provider_Id__c,1);
                }               
            }

            if(c.status!='Closed' && c.Creation_Age__c<=24){
                if(ageOne.get(c.Service_Provider_Id__c)!=null){
                    ageOne.put(c.Service_Provider_Id__c,ageOne.get(c.Service_Provider_Id__c)+1);
                }else{
                    ageOne.put(c.Service_Provider_Id__c,1);
                }
            }
            
            if(c.status!='Closed' && c.Creation_Age__c>24 && c.Creation_Age__c<=48){
                if(ageTwo.get(c.Service_Provider_Id__c)!=null){
                    ageTwo.put(c.Service_Provider_Id__c,ageTwo.get(c.Service_Provider_Id__c)+1);
                }else{
                    ageTwo.put(c.Service_Provider_Id__c,1);
                }
            }
            
            if(c.status!='Closed' && c.Creation_Age__c>48){
                if(ageThree.get(c.Service_Provider_Id__c)!=null){
                    ageThree.put(c.Service_Provider_Id__c,ageThree.get(c.Service_Provider_Id__c)+1);
                }else{
                    ageThree.put(c.Service_Provider_Id__c,1);
                }
            }
            
            if(c.status!='Closed' && c.BO_Action__c>0){
                if(openRedProActioned.get(c.Service_Provider_Id__c)!=null){
                    openRedProActioned.put(c.Service_Provider_Id__c,openRedProActioned.get(c.Service_Provider_Id__c)+1);
                    openRedProTAT.put(c.Service_Provider_Id__c,openRedProTAT.get(c.Service_Provider_Id__c)+c.First_BO_Action_Duration__c);                     
                }else{
                    openRedProActioned.put(c.Service_Provider_Id__c,1);
                    openRedProTAT.put(c.Service_Provider_Id__c,c.First_BO_Action_Duration__c);                    
                }  
            }
            
            if(c.status!='Closed' && c.BO_Action__c>0 && c.BO_Agreed_RB__c=='agree'){
                if(openRedProActAgreed.get(c.Service_Provider_Id__c)!=null ){
                   openRedProActAgreed.put(c.Service_Provider_Id__c,openRedProActAgreed.get(c.Service_Provider_Id__c)+1);
                }else{
                    openRedProActAgreed.put(c.Service_Provider_Id__c,1); 
                }
            }
            
            if(c.status!='Closed' && c.BO_Action__c>0 && c.BO_Agreed_RB__c=='disagree'){
                if(openRedProActDisAgreed.get(c.Service_Provider_Id__c)!=null ){
                   openRedProActDisAgreed.put(c.Service_Provider_Id__c,openRedProActDisAgreed.get(c.Service_Provider_Id__c)+1);
                }else{
                    openRedProActDisAgreed.put(c.Service_Provider_Id__c,1); 
                }
            }
            
            if(c.status!='Closed' && c.BO_Action__c>0 && c.BO_Agreed_RB__c=='info required'){
                if(openRedProActInfoReq.get(c.Service_Provider_Id__c)!=null ){
                   openRedProActInfoReq.put(c.Service_Provider_Id__c,openRedProActInfoReq.get(c.Service_Provider_Id__c)+1);
                }else{
                    openRedProActInfoReq.put(c.Service_Provider_Id__c,1); 
                }
            }
            
            
            
            if(c.status=='Closed' && c.Closed_Duration_in_Hrs__c<=24){
                if(closedAgeOne.get(c.Service_Provider_Id__c)!=null){
                    closedAgeOne.put(c.Service_Provider_Id__c,closedAgeOne.get(c.Service_Provider_Id__c)+1);
                }else{
                    closedAgeOne.put(c.Service_Provider_Id__c,1);
                }
            }
            
            if(c.status=='Closed' && c.Closed_Duration_in_Hrs__c>24 && c.Closed_Duration_in_Hrs__c<=48){
                if(closedAgetwo.get(c.Service_Provider_Id__c)!=null){
                    closedAgetwo.put(c.Service_Provider_Id__c,closedAgetwo.get(c.Service_Provider_Id__c)+1);
                }else{
                    closedAgetwo.put(c.Service_Provider_Id__c,1);
                }
            }
            
            if(c.status=='Closed' && c.Closed_Duration_in_Hrs__c>48){
                if(closedAgeThree.get(c.Service_Provider_Id__c)!=null){
                    closedAgeThree.put(c.Service_Provider_Id__c,closedAgeThree.get(c.Service_Provider_Id__c)+1);
                }else{
                    closedAgeThree.put(c.Service_Provider_Id__c,1);
                }
            }
            
            
            
            if(c.status=='Closed'){
                if(closedByAgents.get(c.Service_Provider_Id__c)!=null){
                    closedByAgents.put(c.Service_Provider_Id__c,closedByAgents.get(c.Service_Provider_Id__c)+1);
                    agentTAT.put(c.Service_Provider_Id__c,agentTAT.get(c.Service_Provider_Id__c)+c.Closed_Duration_in_Hrs__c);                                        
                    
                }else{
                    closedByAgents.put(c.Service_Provider_Id__c,1);
                    agentTAT.put(c.Service_Provider_Id__c,c.Closed_Duration_in_Hrs__c);
                }
            }
            
            if(c.status=='Closed' && c.BO_Action__c>0 ){
                if(closedWithredPro.get(c.Service_Provider_Id__c)!=null){
                    closedWithredPro.put(c.Service_Provider_Id__c,closedWithredPro.get(c.Service_Provider_Id__c)+1);                    
                    boTAT.put(c.Service_Provider_Id__c,boTAT.get(c.Service_Provider_Id__c)+c.First_BO_Action_Duration__c);                  
                }else{
                    closedWithredPro.put(c.Service_Provider_Id__c,1);
                    boTAT.put(c.Service_Provider_Id__c,c.First_BO_Action_Duration__c);                                       
                }
            }
            
            if(c.status=='Closed' && c.BO_Action__c>0 && c.BO_Agreed_RB__c=='agree'){
                if(closedRedProActAgreed.get(c.Service_Provider_Id__c)!=null){
                  closedRedProActAgreed.put(c.Service_Provider_Id__c,closedRedProActAgreed.get(c.Service_Provider_Id__c)+1);
                }else{
                  closedRedProActAgreed.put(c.Service_Provider_Id__c,1);
                }                
             } 
             if(c.status=='Closed' && c.BO_Action__c>0 && c.BO_Agreed_RB__c=='disagree'){
                if(closedRedProActDisAgreed.get(c.Service_Provider_Id__c)!=null){
                  closedRedProActDisAgreed.put(c.Service_Provider_Id__c,closedRedProActDisAgreed.get(c.Service_Provider_Id__c)+1);
                }else{
                  closedRedProActDisAgreed.put(c.Service_Provider_Id__c,1);
                }                
             } 
             if(c.status=='Closed' && c.BO_Action__c>0 && c.BO_Agreed_RB__c=='info required'){
                if(closedRedProActInfoReq.get(c.Service_Provider_Id__c)!=null){
                  closedRedProActInfoReq.put(c.Service_Provider_Id__c,closedRedProActInfoReq.get(c.Service_Provider_Id__c)+1);
                }else{
                  closedRedProActInfoReq.put(c.Service_Provider_Id__c,1);
                }                
             } 
             
             if(c.status=='Closed' && c.IsClosedOnCreate){
                if(closedOnCreate.get(c.Service_Provider_Id__c)!=null){
                    closedOnCreate.put(c.Service_Provider_Id__c,closedOnCreate.get(c.Service_Provider_Id__c)+1);                    
                }else{
                    closedOnCreate.put(c.Service_Provider_Id__c,1);
                }      
             }   
            
        }
        string fileStr='BO Id,BO Name, Region, Total Cases, Open Cases, Closed Cases, Open:<24 hrs, Open:24-48 hrs,Open:>48 hrs, Open redPro Actioned,Open redPro Agreed,Open redPro Disagreed,Open redPro Info Required, Open redPro TAT{Hrs},Closed:<24 hrs,Closed:24-48 hrs,Closed:>48 hrs, Total Closed,Overall Closed TAT{Hrs}, Closed with redPro,Closed redPro Agreed,Closed redPro Disagreed,Closed redPro Info Required,redPro TAT{Hrs},Closed On Create\n';
        
        for(string str:allBoList){
            decimal ageTATVal;
            decimal boTATVal;
            decimal openRedProTATVal;
            if(agentTAT.get(str)!=null && closedByAgents.get(str)!=null)
                ageTATVal=agentTAT.get(str)/closedByAgents.get(str);
            if(boTAT.get(str)!=null && closedWithredPro.get(str)!=null )
                boTATVal=boTAT.get(str)/closedWithredPro.get(str);
                
             if(openRedProTAT.get(str)!=null && openRedProActioned.get(str)!=null)
                 openRedProTATVal=openRedProTAT.get(str)/openRedProActioned.get(str);
     
           
          string boLocationVal=boLocation.get(str)==null?'':boLocation.get(str);
          decimal openCasesVal = openCases.get(str)==null?0:openCases.get(str);
          decimal closedCaseVal= totalClosed.get(str)==null?0:totalClosed.get(str);
          decimal ageOneVal= ageOne.get(str)==null?0:ageOne.get(str);
          decimal ageTwoVal= ageTwo.get(str)==null?0:ageTwo.get(str);
          decimal ageThreeVal= ageThree.get(str)==null?0:ageThree.get(str);
          decimal openRedProActionedVal= openRedProActioned.get(str)==null?0:openRedProActioned.get(str);
          decimal closedAgeOneVal=closedAgeOne.get(str)==null?0:closedAgeOne.get(str);
          decimal closedAgetwoVal=closedAgetwo.get(str)==null?0:closedAgetwo.get(str);
          decimal closedAgeThreeVal=closedAgeThree.get(str)==null?0:closedAgeThree.get(str);
          decimal closedByAgentsVal=closedByAgents.get(str)==null?0:closedByAgents.get(str);
          decimal closedWithredProVal=closedWithredPro.get(str)==null?0:closedWithredPro.get(str);
       
          decimal openRedProActAgreedVal=openRedProActAgreed.get(str)==null?0:openRedProActAgreed.get(str);
          decimal openRedProActDisAgreedVal=openRedProActDisAgreed.get(str)==null?0:openRedProActDisAgreed.get(str);
          decimal openRedProActInfoReqVal=openRedProActInfoReq.get(str)==null?0:openRedProActInfoReq.get(str);
          decimal closedRedProActAgreedVal=closedRedProActAgreed.get(str)==null?0:closedRedProActAgreed.get(str);
          decimal closedRedProActDisAgreedVal=closedRedProActDisAgreed.get(str)==null?0:closedRedProActDisAgreed.get(str);
          decimal closedRedProActInfoReqVal=closedRedProActInfoReq.get(str)==null?0:closedRedProActInfoReq.get(str);
          decimal closedOnCreateVal=closedOnCreate.get(str)==null?0:closedOnCreate.get(str);

         
          ageTATVal=ageTATVal==null?0:Math.Round(ageTATVal); 
          boTATVal=boTATVal==null?0:Math.Round(boTATVal); 
          openRedProTATVal=openRedProTATVal==null?0:Math.Round(openRedProTATVal);

           decimal openCS=openCases.get(str);
           if(openCS==null)
           openCS=0;
            string recordString = '"'+str+'","'+boName.get(str)+'","'+boLocationVal+'","'+totalCases.get(str)+'","'+openCasesVal+'","'+closedCaseVal+'","'+ageOneVal+'","'+ageTwoVal+'","'+ageThreeVal+'","'+openRedProActionedVal+'","'+openRedProActAgreedVal+'","'+openRedProActDisAgreedVal+'","'+openRedProActInfoReqVal+'","'+openRedProTATVal+'","'+closedAgeOneVal+'","'+closedAgetwoVal+'","'+closedAgeThreeVal+'","'+closedByAgentsVal+'","'+ageTATVal+'","'+closedWithredProVal+'","'+closedRedProActAgreedVal+'","'+closedRedProActDisAgreedVal+'","'+closedRedProActInfoReqVal+'","'+boTATVal+'","'+closedOnCreateVal+'" \n';
           // string recordString = '"'+str+'","'+boName.get(str)+'","'+boLocationVal+'","'+totalCases.get(str)+'","'+openCasesVal+'","'+closedCaseVal+'","'+ageOneVal+'","'+ageTwoVal+'","'+ageThreeVal+'","'+openRedProActionedVal+'","'+openRedProTATVal+'","'+closedAgeOneVal+'","'+closedAgetwoVal+'","'+closedAgeThreeVal+'","'+closedByAgentsVal+'","'+ageTATVal+'","'+closedWithredProVal+'","'+boTATVal+'" \n';
           // string recordString = '"'+str+'","'+boName.get(str)+'","'+boLocation.get(str)+'","'+totalCases.get(str)+'","'+openCS+'","'+totalClosed.get(str)+'","'+ageOne.get(str)+'","'+ageTwo.get(str)+'","'+ageThree.get(str)+'","'+openRedProActioned.get(str)+'","'+openRedProTAT.get(str)+'","'+closedAgeOne.get(str)+'","'+closedAgetwo.get(str)+'","'+closedAgeThree.get(str)+'","'+closedByAgents.get(str)+'","'+ageTATVal+'","'+closedWithredPro.get(str)+'","'+boTATVal+'" \n';
            //string recordString = '"'+str+'","'+openCases.get(str)+'","'+ageOne.get(str)+'"\n';
            fileStr= fileStr+recordString;
        }
        System.debug('heap size-->'+Limits.getHeapSize());
        System.debug('fileStr--->'+fileStr);
       
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('RedPro_Report.csv');
        if(srep=='last30days'){
        efa.setFileName('BO_Cases_Analysis_last_30_Days_Report.csv');
        }else{
        efa.setFileName('BO_Cases_Analysis_MTD_Report.csv');
        }
        efa.setBody(Blob.valueOf(fileStr));
        efa.setContentType('text/csv');
        efa.setinline(false); 
        email_attachments.add(efa);
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setSubject('BO Cases Analysis Reports');
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(redProQuery.DistributionList__c.Split(','));
        email.setToAddresses(toAddresses);    
        //email.setToAddresses( new String[] {'veeramanikanta.r@redbus.com'} );
        email.setHtmlBody('Hi,<br/><br/> Please find attached BO Case analysis reports. <br/><br/>Thanks,<br/>CRM Team');
        email.setFileAttachments(email_attachments);
       // email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});                  
    }
}