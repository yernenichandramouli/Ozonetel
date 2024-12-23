public class NEFTcasesReportController {
     public Boolean NeftAgeGrouping{get;set;}
     public Boolean GroupByStatus{get;set;}

    public Integer Age1iDNcount{get;set;}
    public Integer Age1LatamCount{get;set;}
    public Integer Age1TotalCount{get;set;}
    public Integer Age2iDNcount{get;set;}
    public Integer Age2LatamCount{get;set;}
    public Integer Age2TotalCount{get;set;}
    public Integer Age3iDNcount{get;set;}
    public Integer Age3LatamCount{get;set;}
    public Integer Age3TotalCount{get;set;}
    public Integer Age4iDNcount{get;set;}
    public Integer Age4LatamCount{get;set;}
    public Integer Age4TotalCount{get;set;}
    public Integer Age5iDNcount{get;set;}
    public Integer Age5LatamCount{get;set;}
    public Integer Age5TotalCount{get;set;}
    public Integer Age6iDNcount{get;set;}
    public Integer Age6LatamCount{get;set;}
    public Integer Age6TotalCount{get;set;}
    public Integer TotalCount{get;set;}
    public Integer totaliDNcount{get;set;}
    public Integer totalLatamCount{get;set;}
    
    public Integer aprvdIdnCount{get;set;}
    public Integer aprvdLatamCount{get;set;}
    public Integer aprvdTotalCount{get;set;}
    public Integer aprvNeftIdnCount{get;set;}
    public Integer aprvNeftLatamCount{get;set;}
    public Integer aprvNeftTotalCount{get;set;}
    public Integer rejctNeftIdnCount{get;set;}
    public Integer rejctNeftLatamCount{get;set;}
    public Integer rejctNeftTotalCount{get;set;}
    public Integer aprExpRefdIdnCount{get;set;}
    public Integer aprExpRefdLatamCount{get;set;}
    public Integer aprExpRefdTotalCount{get;set;}
    public Integer rejctExpRefdIdnCount{get;set;}
    public Integer rejctExpRefdLatamCount{get;set;}
    public Integer rejctExpRefdTotalCount{get;set;}
    public Integer erorNeftIdnCount{get;set;}
    public Integer erorNeftLatamCount{get;set;}
    public Integer erorNeftTotalCount{get;set;}
     public Integer escIdnCount{get;set;}
    public Integer escLatamCount{get;set;}
    public Integer escTotalCount{get;set;}
    
    
    
   public list<wrapperclass> getNeftCases(){
        List<wrapperclass> finalMapList = New List<wrapperclass>();
        string strQuery = System.Label.NEFTcasesReportQuery;
        List<case> TotalCaseList  = Database.query(strQuery);
        TotalCount =0;
        if(!TotalCaseList.isEmpty()){
            TotalCount = Integer.valueOf(TotalCaseList.size());
        //Age 1: <= 24 HRS Records.
        List<case> Age1CaseList = Database.query(strQuery+' and Creation_Age__c<=24');
            Age1iDNcount=0;Age1LatamCount=0;Age1TotalCount=0;
            if(!Age1CaseList.isEmpty()){
                Age1TotalCount = Integer.valueOf(Age1CaseList.size());
                for(case c : Age1CaseList){
                    if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                        Age1iDNcount =Age1iDNcount + 1;
                   }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                        Age1LatamCount =Age1LatamCount + 1;
                   }
                }
            }
        wrapperclass Age1Wrapper = New wrapperclass('0 - 24 Hrs',Age1iDNcount,Age1LatamCount,Age1TotalCount,((Decimal.valueOf(Age1TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age1Wrapper);

        //Age 2: 24 - 48 Hrs
        List<case> Age2CaseList = Database.query(strQuery+' and Creation_Age__c>24 and Creation_Age__c<=48');
            Age2iDNcount=0;Age2LatamCount=0;Age2TotalCount=0;
            if(!Age2CaseList.isEmpty()){
                Age2TotalCount = Integer.valueOf(Age2CaseList.size());
                for(case c : Age2CaseList){
                    if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                        Age2iDNcount =Age2iDNcount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                        Age2LatamCount =Age2LatamCount + 1;
                    }
                }
            }
        wrapperclass Age2Wrapper = New wrapperclass('24 - 48 Hrs',Age2iDNcount,Age2LatamCount,Age2TotalCount,((Decimal.valueOf(Age2TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age2Wrapper);

        //Age 3: 2 - 7 Days
        List<case> Age3CaseList = Database.query(strQuery+' and Creation_Age__c>48 and Creation_Age__c<=168');
        Age3iDNcount=0;Age3LatamCount=0;Age3TotalCount=0;
        if(!Age3CaseList.isEmpty()){
            Age3TotalCount = Integer.valueOf(Age3CaseList.size());
            for(case c : Age3CaseList){
                if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                    Age3iDNcount =Age3iDNcount + 1;
                }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                    Age3LatamCount =Age3LatamCount + 1;
                }
            }
        }
        wrapperclass Age3Wrapper = New wrapperclass('2 - 7 Days',Age3iDNcount,Age3LatamCount,Age3TotalCount,((Decimal.valueOf(Age3TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age3Wrapper);

        //Age 4: 7 - 15 Days
        List<case> Age4CaseList = Database.query(strQuery+' and Creation_Age__c>168 and Creation_Age__c<=360');
        Age4iDNcount=0;Age4LatamCount=0;Age4TotalCount=0;
        if(!Age4CaseList.isEmpty()){
            Age4TotalCount = Integer.valueOf(Age4CaseList.size());
            for(case c : Age4CaseList){
                if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                    Age4iDNcount =Age4iDNcount + 1;
                }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                    Age4LatamCount =Age4LatamCount+1;
                }
            }
        }
        wrapperclass Age4Wrapper = New wrapperclass('7 - 15 Days',Age4iDNcount,Age4LatamCount,Age4TotalCount,((Decimal.valueOf(Age4TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age4Wrapper);

        //Age 5: 15 - 30 Days
        List<case> Age5CaseList = Database.query(strQuery+' and Creation_Age__c>360 and Creation_Age__c<=720');
        Age5LatamCount=0;Age5iDNcount=0;Age5TotalCount=0;
        if(!Age5CaseList.isEmpty()){
            Age5TotalCount = Integer.valueOf(Age5CaseList.size());
            for(case c : Age5CaseList){
                if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                    Age5iDNcount =Age5iDNcount + 1;
                }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                    Age5LatamCount =Age5LatamCount+1;
                }
            }
        }
        wrapperclass Age5Wrapper = New wrapperclass('15 - 30 Days',Age5iDNcount,Age5LatamCount,Age5TotalCount,((Decimal.valueOf(Age5TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age5Wrapper);

        //Age 6: 1 Month +
        List<case> Age6CaseList = Database.query(strQuery+' and Creation_Age__c>720');
        Age6iDNcount=0;Age6LatamCount=0;Age6TotalCount=0;
        if(!Age6CaseList.isEmpty()){
            Age6TotalCount = Integer.valueOf(Age6CaseList.size());
            for(case c : Age6CaseList){
                if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                    Age6iDNcount =Age6iDNcount + 1;
                }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                    Age6LatamCount =Age6LatamCount+1;
                }
            }
        }
        wrapperclass Age6Wrapper = New wrapperclass('1 Month +',Age6iDNcount,Age6LatamCount,Age6TotalCount,((Decimal.valueOf(Age6TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age6Wrapper);

        totaliDNcount = Age1iDNcount + Age2iDNcount + Age3iDNcount + Age4iDNcount + Age5iDNcount + Age6iDNcount;
        totalLatamCount = Age1LatamCount + Age2LatamCount + Age3LatamCount + Age4LatamCount + Age5LatamCount + Age6LatamCount;
        }
        System.debug(':::: Value of p ::: '+finalMapList);

        return finalMapList;
    }

 public list<StatuspeWrapper> getStatusGroup(){
        List<StatuspeWrapper> finalMapList = New List<StatuspeWrapper>();
        string strQuery = System.Label.NEFTStatuscasesReportQuery;
        List<case> TotalCaseList  = Database.query(strQuery);
        TotalCount =0;
        if(!TotalCaseList.isEmpty()){
            TotalCount = Integer.valueOf(TotalCaseList.size());
              //Approved
            List<case> approvedList = Database.query(strQuery +' AND status=\'Approved\'');
            aprvdIdnCount=0;aprvdLatamCount=0;aprvdTotalCount=0;
            if(!approvedList.isEmpty()){
                aprvdTotalCount = Integer.valueOf(approvedList.size());
                for(case c : approvedList){
                    if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                        aprvdIdnCount =aprvdIdnCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                        aprvdLatamCount =aprvdLatamCount + 1;
                    }
                }
            }
            StatuspeWrapper aPayWrapper = New StatuspeWrapper('Approved',aprvdIdnCount,aprvdLatamCount,aprvdTotalCount,((Decimal.valueOf(aprvdTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(aPayWrapper);
            
            //Approved for NEFT
            List<case> aprvNeftList = Database.query(strQuery +' AND status=\'Approved for NEFT\'');
            aprvNeftIdnCount=0;aprvNeftLatamCount=0;aprvNeftTotalCount=0;
            if(!aprvNeftList.isEmpty()){
                aprvNeftTotalCount = Integer.valueOf(aprvNeftList.size());
                for(case c : aprvNeftList){
                    if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                        aprvNeftIdnCount =aprvNeftIdnCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                        aprvNeftLatamCount =aprvNeftLatamCount + 1;
                    }
                }
            }
            StatuspeWrapper payUWrapper = New StatuspeWrapper('Approved for NEFT',aprvNeftIdnCount,aprvNeftLatamCount,aprvNeftTotalCount,((Decimal.valueOf(aprvNeftTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(payUWrapper);
            
             //Reject for NEFT 
            List<case> rejctNeftList = Database.query(strQuery +' AND status=\'Reject for NEFT\'');
            rejctNeftTotalCount=0;rejctNeftIdnCount=0;rejctNeftLatamCount=0;
            if(!rejctNeftList.isEmpty()){
                rejctNeftTotalCount = Integer.valueOf(rejctNeftList.size());
                for(case c : rejctNeftList){
                    if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                        rejctNeftIdnCount =rejctNeftIdnCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                        rejctNeftLatamCount =rejctNeftLatamCount + 1;
                    }
                }
            }
            StatuspeWrapper ppeWrapper = New StatuspeWrapper('Reject for NEFT',rejctNeftIdnCount,rejctNeftLatamCount,rejctNeftTotalCount,((Decimal.valueOf(rejctNeftTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(ppeWrapper);
            
             //Approved For Exceptional Refund aprExpRefd
            List<case> aprExpRefdList = Database.query(strQuery +' AND status=\'Approved For Exceptional Refund\'');
            aprExpRefdIdnCount=0;aprExpRefdLatamCount=0;aprExpRefdTotalCount=0;
            if(!aprExpRefdList.isEmpty()){
                aprExpRefdTotalCount = Integer.valueOf(aprExpRefdList.size());
                for(case c : aprExpRefdList){
                    if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                        aprExpRefdIdnCount =aprExpRefdIdnCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                        aprExpRefdLatamCount =aprExpRefdLatamCount + 1;
                    }
                }
            }
            StatuspeWrapper upiWrapper = New StatuspeWrapper('Approved Exceptional Refund',aprExpRefdIdnCount ,aprExpRefdLatamCount,aprExpRefdTotalCount,((Decimal.valueOf(aprExpRefdTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(upiWrapper);
            
              //Rejected For Exceptional Refund 
            List<case> rejctExpRefdList = Database.query(strQuery +' AND status=\'Rejected For Exceptional Refund\'');
            rejctExpRefdIdnCount=0;rejctExpRefdLatamCount=0;rejctExpRefdTotalCount=0;
            if(!rejctExpRefdList.isEmpty()){
                rejctExpRefdTotalCount = Integer.valueOf(rejctExpRefdList.size());
                for(case c : rejctExpRefdList){
                    if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                        rejctExpRefdIdnCount =rejctExpRefdIdnCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                        rejctExpRefdLatamCount =rejctExpRefdLatamCount + 1;
                    }
                }
            }
            StatuspeWrapper jPayWrapper = New StatuspeWrapper('Rejected Exceptional Refund',rejctExpRefdIdnCount,rejctExpRefdLatamCount,rejctExpRefdTotalCount,((Decimal.valueOf(rejctExpRefdTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(jPayWrapper);
            
             // Error in NEFT
            List<case> errorNeftList = Database.query(strQuery +' AND status=\'Error in NEFT\'');
            erorNeftIdnCount=0;erorNeftLatamCount=0;erorNeftTotalCount=0;
            if(!errorNeftList.isEmpty()){
                erorNeftTotalCount = Integer.valueOf(errorNeftList.size());
                for(case c : errorNeftList){
                    if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                        erorNeftIdnCount =erorNeftIdnCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                        erorNeftLatamCount =erorNeftLatamCount + 1;
                    }
                }
            }
            StatuspeWrapper rPayWrapper = New StatuspeWrapper('Error in NEFT',erorNeftIdnCount,erorNeftLatamCount,erorNeftTotalCount,((Decimal.valueOf(erorNeftTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(rPayWrapper);
            
               //Escalated
            List<case> EscalatedList = Database.query(strQuery +' AND status=\'Escalated\'');
            escIdnCount=0;escLatamCount=0;escTotalCount=0;
            if(!EscalatedList.isEmpty()){
                escTotalCount = Integer.valueOf(EscalatedList.size());
                for(case c : EscalatedList){
                    if(c.Business_Unit_ct__c == 'REDBUS_ID'){
                        escIdnCount =escIdnCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_PE' || c.Business_Unit_ct__c == 'REDBUS_CO'){
                        escLatamCount =escLatamCount + 1;
                    }
                }
            }
            StatuspeWrapper pUpiWrapper = New StatuspeWrapper('Escalated',escIdnCount,escLatamCount,escTotalCount,((Decimal.valueOf(escTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(pUpiWrapper);
            
        }

       totaliDNcount = aprvdIdnCount + aprvNeftIdnCount + rejctNeftIdnCount + aprExpRefdIdnCount + rejctExpRefdIdnCount + erorNeftIdnCount + escIdnCount;
       totalLatamCount = aprvdLatamCount + aprvNeftLatamCount + rejctNeftLatamCount + aprExpRefdLatamCount + rejctExpRefdLatamCount + erorNeftLatamCount + escLatamCount;
        
        system.debug('Final Map List'+finalMapList);

        return finalMapList;
    }



 public class wrapperclass{
        public string Ageing {get; set;}
        public Integer IDNCount {get; set;}
        public Integer LatamCount {get; set;}
        public Integer totalContributon {get; set;}
        public Decimal percentageContributon {get;set;}
        

        public wrapperclass(String Age, Integer idnCount, Integer latamCount, Integer total, decimal percent){
            this.Ageing = Age;
            this.IDNCount = idnCount;
            this.LatamCount = latamCount;
            this.totalContributon = total;
            this.percentageContributon = percent;
        }
    }
    
    public class StatuspeWrapper{
        public string status {get; set;}
        public Integer IDNCount {get; set;}
        public Integer LatamCount {get; set;}
        public Integer totalContributon {get; set;}
        public Decimal percentageContributon {get;set;}
        

        public StatuspeWrapper(String pg, Integer idnCount, Integer latamCount, Integer total, decimal percent){
            this.status = pg;
            this.IDNCount = idnCount;
            this.LatamCount = LatamCount;
            this.totalContributon = total;
            this.percentageContributon = percent;
        }
    }
}