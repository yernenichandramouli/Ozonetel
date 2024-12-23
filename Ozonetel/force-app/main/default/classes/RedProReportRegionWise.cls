public class RedProReportRegionWise{
    
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
        
        Map<string,integer> closedOnCreate=new Map<string,integer>();
        List<string> allBoList=new List<string>();
        List<string> allRegions=new List<string>();
        Map<string,integer> totalBos=new Map<string,integer>();
        for(case c:csList){
            string region=c.BD_Location2__c==''?c.BD_Location__c:c.BD_Location2__c;
            if(!allRegions.contains(region))
                allRegions.add(region);
            
            if(totalBos.get(region)!=null){
                totalBos.put(region,totalBos.get(region)+1);            
            }else{
                totalBos.put(region,1);
            }
            
            
            if(totalCases.get(region)!=null){
                totalCases.put(region,totalCases.get(region)+1);
            }else{
                totalCases.put(region,1);
            }  
            
            if(c.status!='Closed'){
                if(openCases.get(region)!=null){
                    openCases.put(region,openCases.get(region)+1);
                }else{
                    openCases.put(region,1);
                }               
            }
            
            if(c.status=='Closed'){
                if(totalClosed.get(region)!=null){
                    totalClosed.put(region,totalClosed.get(region)+1);
                }else{
                    totalClosed.put(region,1);
                }               
            }
            
            if(c.status!='Closed' && c.Creation_Age__c<=24){
                if(ageOne.get(region)!=null){
                    ageOne.put(region,ageOne.get(region)+1);
                }else{
                    ageOne.put(region,1);
                }
            }
            
            if(c.status!='Closed' && c.Creation_Age__c>24 && c.Creation_Age__c<=48){
                if(ageTwo.get(region)!=null){
                    ageTwo.put(region,ageTwo.get(region)+1);
                }else{
                    ageTwo.put(region,1);
                }
            }
            
            if(c.status!='Closed' && c.Creation_Age__c>48){
                if(ageThree.get(region)!=null){
                    ageThree.put(region,ageThree.get(region)+1);
                }else{
                    ageThree.put(region,1);
                }
            }
            
            if(c.status!='Closed' && c.BO_Action__c>0){
                if(openRedProActioned.get(region)!=null){
                    openRedProActioned.put(region,openRedProActioned.get(region)+1);
                    openRedProTAT.put(region,openRedProTAT.get(region)+c.First_BO_Action_Duration__c);
                }else{
                    openRedProActioned.put(region,1);
                    openRedProTAT.put(region,c.First_BO_Action_Duration__c);
                }
            }
            
            if(c.status=='Closed' && c.Closed_Duration_in_Hrs__c<=24){
                if(closedAgeOne.get(region)!=null){
                    closedAgeOne.put(region,closedAgeOne.get(region)+1);
                }else{
                    closedAgeOne.put(region,1);
                }
            }
            
            if(c.status=='Closed' && c.Closed_Duration_in_Hrs__c>24 && c.Closed_Duration_in_Hrs__c<=48){
                if(closedAgetwo.get(region)!=null){
                    closedAgetwo.put(region,closedAgetwo.get(region)+1);
                }else{
                    closedAgetwo.put(region,1);
                }
            }
            
            if(c.status=='Closed' && c.Closed_Duration_in_Hrs__c>48){
                if(closedAgeThree.get(region)!=null){
                    closedAgeThree.put(region,closedAgeThree.get(region)+1);
                }else{
                    closedAgeThree.put(region,1);
                }
            }
            
            
            
            if(c.status=='Closed'){
                if(closedByAgents.get(region)!=null){
                    closedByAgents.put(region,closedByAgents.get(region)+1);
                    agentTAT.put(region,agentTAT.get(region)+c.Closed_Duration_in_Hrs__c);
                }else{
                    closedByAgents.put(region,1);
                    agentTAT.put(region,c.Closed_Duration_in_Hrs__c);
                }
            }
            
            if(c.status=='Closed' && c.BO_Action__c>0 ){
                if(closedWithredPro.get(region)!=null){
                    closedWithredPro.put(region,closedWithredPro.get(region)+1);                    
                    boTAT.put(region,boTAT.get(region)+c.First_BO_Action_Duration__c);
                }else{
                    closedWithredPro.put(region,1);
                    boTAT.put(region,c.First_BO_Action_Duration__c);
                }
            }
            
            if(c.status=='Closed' && c.IsClosedOnCreate){
                if(closedOnCreate.get(region)!=null){
                    closedOnCreate.put(region,closedOnCreate.get(region)+1);                    
                }else{
                    closedOnCreate.put(region,1);
                }
            }
            
        }
        string fileStr='Region, Total Cases, Open Cases, Closed Cases, Open:<24 hrs, Open:24-48 hrs,Open:>48 hrs, Open redPro Actioned, Open redPro TAT{Hrs},Closed:<24 hrs,Closed:24-48 hrs,Closed:>48 hrs, Overall Closed TAT{Hrs}, Closed with redPro, redPro TAT{Hrs}, Closed On Create\n';
        string allRegionVal;
        // string allRegionVal='India,'+totalCases.size()+','+openCases.values().size()+','+totalClosed.values().size()+'\n';
        string fileStrVal='';
        decimal rgTotalCs=0;decimal rgTotalOpen=0;decimal rgTotalCloseds=0;decimal rgTotalOpenAge1=0;decimal rgTotalOpenAge2=0;decimal rgTotalOpenAge3=0;decimal rgTotalRedProActioned=0;decimal rgTotalRedProOpenTAT=0;decimal rgTotalClosedAge1=0;decimal rgTotalClosedAge2=0;decimal rgTotalClosedAge3=0;decimal rgTotalClosedTAT=0;decimal rgTotalClosedWithRedPro=0;decimal rgTotalRedProClosedTAT=0;
        decimal rgTotalClosedByAgents=0;
        decimal rgTotalTAT=0;
        decimal rgTotalBOTAT=0;
        decimal rgTotalOpenRedProTAT=0;
        decimal rgClosedOnCreate=0;
        for(string str:allRegions){
            decimal ageTATVal;
            decimal boTATVal;
            decimal openRedProTATVal;
            
            if(agentTAT.get(str)!=null)
                rgTotalTAT=rgTotalTAT+agentTAT.get(str);
            if(boTAT.get(str)!=null)
                rgTotalBOTAT=rgTotalBOTAT+boTAT.get(str);
            if(openRedProTAT.get(str)!=null)
                rgTotalOpenRedProTAT=rgTotalOpenRedProTAT+openRedProTAT.get(str);
            
            if(agentTAT.get(str)!=null && closedByAgents.get(str)!=null)
                ageTATVal=agentTAT.get(str)/closedByAgents.get(str);
            if(boTAT.get(str)!=null && closedWithredPro.get(str)!=null )
                boTATVal=boTAT.get(str)/closedWithredPro.get(str);
            
            if(openRedProTAT.get(str)!=null && openRedProActioned.get(str)!=null)
                openRedProTATVal=openRedProTAT.get(str)/openRedProActioned.get(str);
            
            
            string boLocationVal=boLocation.get(str)==null?'':boLocation.get(str);
            decimal totalCasesVal=totalCases.get(str);
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
            decimal closedOnCreateVal=closedOnCreate.get(str)==null?0:closedOnCreate.get(str);
            
            ageTATVal=ageTATVal==null?0:Math.Round(ageTATVal); 
            boTATVal=boTATVal==null?0:Math.Round(boTATVal); 
            openRedProTATVal=openRedProTATVal==null?0:Math.Round(openRedProTATVal);
            
            decimal openCS=openCases.get(str);
            if(openCS==null)
                openCS=0;
            string recordString = '"'+str+'","'+totalCasesVal+'","'+openCasesVal+'","'+closedCaseVal+'","'+ageOneVal+'","'+ageTwoVal+'","'+ageThreeVal+'","'+openRedProActionedVal+'","'+openRedProTATVal+'","'+closedAgeOneVal+'","'+closedAgetwoVal+'","'+closedAgeThreeVal+'","'+ageTATVal+'","'+closedWithredProVal+'","'+boTATVal+'","'+closedOnCreateVal+'" \n'; 
            // string recordString = '"'+str+'","'+boName.get(str)+'","'+boLocation.get(str)+'","'+totalCases.get(str)+'","'+openCS+'","'+totalClosed.get(str)+'","'+ageOne.get(str)+'","'+ageTwo.get(str)+'","'+ageThree.get(str)+'","'+openRedProActioned.get(str)+'","'+openRedProTAT.get(str)+'","'+closedAgeOne.get(str)+'","'+closedAgetwo.get(str)+'","'+closedAgeThree.get(str)+'","'+closedByAgents.get(str)+'","'+ageTATVal+'","'+closedWithredPro.get(str)+'","'+boTATVal+'" \n';
            //string recordString = '"'+str+'","'+openCases.get(str)+'","'+ageOne.get(str)+'"\n';
            // fileStr= fileStr+allRegionVal+recordString;
            rgTotalCs=rgTotalCs+totalCasesVal;
            rgTotalOpen=rgTotalOpen+openCasesVal;
            rgTotalCloseds=rgTotalCloseds+closedCaseVal;
            rgTotalOpenAge1=rgTotalOpenAge1+ageOneVal;
            rgTotalOpenAge2=rgTotalOpenAge2+ageTwoVal;
            rgTotalOpenAge3=rgTotalOpenAge3+ageThreeVal;
            rgTotalRedProActioned=rgTotalRedProActioned+openRedProActionedVal;
            rgTotalClosedAge1=rgTotalClosedAge1+closedAgeOneVal;
            rgTotalClosedAge2=rgTotalClosedAge2+closedAgetwoVal;
            rgTotalClosedAge3=rgTotalClosedAge3+closedAgeThreeVal;
            rgTotalClosedWithRedPro=rgTotalClosedWithRedPro+closedWithredProVal;
            rgTotalClosedByAgents=rgTotalClosedByAgents+closedByAgentsVal;
            rgClosedOnCreate=rgClosedOnCreate+closedOnCreateVal;
            fileStrVal=fileStrVal+recordString;
            
        }
        if(rgTotalClosedByAgents!=0)
            rgTotalTAT=rgTotalTAT/rgTotalClosedByAgents;
        if(rgTotalClosedWithRedPro!=0)
            rgTotalBOTAT=rgTotalBOTAT/rgTotalClosedWithRedPro;
        if(rgTotalRedProActioned!=0)
            rgTotalOpenRedProTAT=rgTotalOpenRedProTAT/rgTotalRedProActioned;
        
        rgTotalTAT=Math.Round(rgTotalTAT); 
        rgTotalBOTAT=Math.Round(rgTotalBOTAT); 
        rgTotalOpenRedProTAT=Math.Round(rgTotalOpenRedProTAT); 
        
        allRegionVal='India,'+rgTotalCs+','+rgTotalOpen+','+rgTotalCloseds+','+rgTotalOpenAge1+','+rgTotalOpenAge2+','+rgTotalOpenAge3+','+rgTotalRedProActioned+','+rgTotalOpenRedProTAT+','+rgTotalClosedAge1+','+rgTotalClosedAge2+','+rgTotalClosedAge3+','+rgTotalTAT+','+rgTotalClosedWithRedPro+','+rgTotalBOTAT+','+rgClosedOnCreate+' \n';
        fileStr= fileStr+allRegionVal+fileStrVal;
        System.debug('heap size-->'+Limits.getHeapSize());
        System.debug('fileStr--->'+fileStr);

         
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        if(srep=='last30days'){
        efa.setFileName('Region_Wise_Last_30_Days_Summary_Report.csv');
        }else{
        efa.setFileName('Region_Wise_MTD_Summary_Report.csv');
        }
        efa.setBody(Blob.valueOf(fileStr));
        efa.setContentType('text/csv');  
        efa.setinline(false);      
        email_attachments.add(efa);
       } 
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(redProQuery.DistributionList__c.Split(','));
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);   
        email.setSubject('BO Region Wise Summary Reports');
        email.setHtmlBody('Hi,<br/><br/> Please find attached BO Wise Case Summary reports. <br/><br/>Thanks,<br/>CRM Team');
      
       /* if(type=='last30days'){
        email.setSubject('Region Wise Summary Report');
        email.setHtmlBody('Hi,<br/><br/> Please find attached last 30 days of BO Wise Case Summary report. <br/><br/>Thanks,<br/>CRM Team');
        }else{
        email.setSubject('Region Wise Summary MTD Report');
        email.setHtmlBody('Hi,<br/><br/> Please find attached current month of BO Wise Case Summary report. <br/><br/>Thanks,<br/>CRM Team');
        }*/
        
        email.setFileAttachments(email_attachments);
       // email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});          
    }
}