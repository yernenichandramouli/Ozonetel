@RestResource(urlMapping='/redBus/redProdDashboard/*')
global without sharing class API_RedProDashboard{
    
    @HttpGet
    global static List<CaseDetails>  getDashboardDetails(){
        
        RestRequest req=RestContext.request;
        string boId=RestContext.request.params.get('boId');
        string channel=req.headers.get('channel');
        Set<String> rpwIRRefundTab = new Set<String>(System.label.RpwIRRefundTab.split(';'));
        List<case> caseList=new List<case>();
        List<CaseDetails> cdWrapList=new List<CaseDetails>();
        list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
        
        if(string.isNotBlank(boId) && channel=='RB+'){
            
            DataDeletionSetup__mdt ddObj=new DataDeletionSetup__mdt();
            ddObj=[select id,DeveloperName,QueryDetails__c FROM DataDeletionSetup__mdt where DeveloperName='RedProDashboard'];
            
            caseList=database.query(ddObj.QueryDetails__c);
            map<string,integer> totalOpneCases=new map<string,integer>();
            map<string,integer> topIssues=new map<string,integer>();
            CaseDetails cd=new CaseDetails();
            //double totalCases=0;
            double totalCases=0;
            // integer openCasesGret24=0;
            double openCasesGret24=0;
            integer boResponded=0;
            integer closedCases=0;
            double closedCsHours=0;
            double boActAgDisag=0;

            // Need to exclide for rpw
            for (Integer i = caseList.size() - 1; i >= 0; i--) {
                if((caseList[i].Channel_ct__c =='MMT'|| caseList[i].Channel_ct__c =='GOIBIBO') && (caseList[i].Case_Category__c!='Instant resolution-BOLT' ||(caseList[i].Case_Category__c=='Instant resolution-BOLT' && caseList[i].Refund_Type__c!='Instant resolution - BO contest Rejected' && !rpwIRRefundTab.contains(caseList[i].Refund_Type__c)))){
                    system.debug('::: RemovedCaseNumber= '+caseList[i].CaseNumber);
                    caseList.remove(i);
                }
            }
            
            for(case c:caseList){
                totalCases++;
                if(c.Case_Category__c == 'Instant resolution-BOLT'){
                    if(c.status == 'Open' || c.status =='Re-Open' || (c.Refund_Type__c=='Outlier case' && c.status != 'Closed') ||(c.status == 'Escalated to BD' && !rpwIRRefundTab.contains(c.Refund_Type__c) && c.Refund_Type__c!='Instant resolution - redBus Delight')){
                        cd.totalOpenCases++;
                        if(c.Creation_Age__c>24 && c.status!='Closed'){
                            openCasesGret24++;
                        }
                    }
                }else{
                    if(c.status!='Closed'){
                        cd.totalOpenCases++;
                        if(c.Creation_Age__c>24 && c.status!='Closed'){
                            openCasesGret24++;
                        }
                    }
                }
                
                if(string.isNotBlank(c.Issue_Sub_Category__c)){
                    if(topIssues.get(c.Issue_Sub_Category__c)!=null){
                        topIssues.put(c.Issue_Sub_Category__c,topIssues.get(c.Issue_Sub_Category__c)+1);
                    }else{
                        topIssues.put(c.Issue_Sub_Category__c,1);
                    }               
                }
                
                if(c.BO_Action__c>0){
                    cd.boResponded++;  
                    if(!c.IsClosedOnCreate){
                        boResponded++;
                    }                  
                }else{
                    cd.boNotResponded++;
                }
                if(c.BO_Agreed_RB__c=='agree'){
                    cd.boAgreed++;
                    boActAgDisag++;
                }else if(c.BO_Agreed_RB__c=='disagree'){
                    cd.boNotAgreed++;
                    boActAgDisag++;
                }
                
                if(c.status=='Closed' && !c.IsClosedOnCreate){
                    closedCases++;
                }
                if(c.status=='Closed'){
                    closedCsHours=closedCsHours+c.Closed_Duration_in_Hrs__c;
                }
                
            }

            Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
            if(instantRefundBoIds.contains(boId)){
                cd.isBolt = true;
            }

            Map<string,double> issuePer=new Map<string,double>();
            
            for(string ob:topIssues.keyset()){
                System.debug('topIs-->'+topIssues.get(ob));
                System.debug('totalCases--->'+totalCases);
                decimal topIsPer=totalCases!=0.0?(topIssues.get(ob)/totalCases)*100:0.0;
                System.debug('topIsPer-->'+topIsPer);  
                issuePer.put(ob,topIsPer.setScale(2));
            }
            
            system.debug('openCasesGret24-->'+openCasesGret24);
            system.debug('totalCases-->'+totalCases);
            // system.debug('div-->'+openCasesGret24/totalCases);
            cd.openCasesGret24=openCasesGret24;
            if(cd.totalOpenCases>0){
                cd.openCasesGret24Per=(openCasesGret24/cd.totalOpenCases)*100;
                cd.openCasesGret24Per=cd.openCasesGret24Per.setscale(2);
            }
            system.debug('cd.openCasesGret24Per-->'+cd.openCasesGret24Per);
            cd.boRespondedPer=totalCases!=0.0?(boResponded/totalCases)*100:0;
            cd.boRespondedPer=cd.boRespondedPer.setscale(2);
            // cd.closedCasesPer=closedCases/totalCases;
            if(boActAgDisag!=0){
                cd.boAgreedPer=(cd.boAgreed/boActAgDisag)*100;
                cd.boAgreedPer=cd.boAgreedPer.setscale(2);
                cd.boNotAgreedPer=(cd.boNotAgreed/boActAgDisag)*100;
                cd.boNotAgreedPer=cd.boNotAgreedPer.setscale(2);
            }
            cd.boAvgRespTime=totalCases!=0.0?closedCsHours/totalCases:0;
            cd.boAvgRespTime=cd.boAvgRespTime.setscale(2);
            //cd.topIssues=topIssues;
            cd.topIssuesPer=issuePer;
            cdWrapList.add(cd);
            
            
        }
        System.debug('cdWrapList->'+cdWrapList);
        return cdWrapList;
    }
    
    global class CaseDetails{
        public integer totalOpenCases=0;
        public double openCasesGret24=0;
        public decimal openCasesGret24Per=0;    
        public decimal boAvgRespTime;
        public integer boResponded=0;
        public integer boNotResponded=0;
        public decimal boRespondedPer=0;
        public decimal topBoRespondPer=80;
        public decimal boAgreedPer=0;
        public decimal boNotAgreedPer=0;
        public integer boIdealAvgTime=24;
        public integer topBoResolutionTime=10;
        public integer boRespCSAT=10;
        // public map<string,integer> topIssues;
        public map<string,double> topIssuesPer;
        // public integer last24hrs=0;
        public integer boAgreed=0;
        public integer boNotAgreed=0;   
        public Boolean isBolt = false;
        //public double closedCasesPer=0;
        
    }    
}