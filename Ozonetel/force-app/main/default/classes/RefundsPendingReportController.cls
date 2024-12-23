public class RefundsPendingReportController {
    public Boolean PaasAgeGrouping{get;set;}
    public Boolean GroupByPGType{get;set;}

    //To Store total record count for each breakup
    public Integer Age1BusCount{get;set;}
    public Integer Age1RailCount{get;set;}
    public Integer Age1TotalCount{get;set;}
    public Integer Age2BusCount{get;set;}
    public Integer Age2RailCount{get;set;}
    public Integer Age2TotalCount{get;set;}
    public Integer Age3BusCount{get;set;}
    public Integer Age3RailCount{get;set;}
    public Integer Age3TotalCount{get;set;}
    public Integer Age4BusCount{get;set;}
    public Integer Age4RailCount{get;set;}
    public Integer Age4TotalCount{get;set;}
    public Integer Age5BusCount{get;set;}
    public Integer Age5RailCount{get;set;}
    public Integer Age5TotalCount{get;set;}
    public Integer Age6BusCount{get;set;}
    public Integer Age6RailCount{get;set;}
    public Integer Age6TotalCount{get;set;}
    public Integer TotalCount{get;set;}
    public Integer totalBusCount{get;set;}
    public Integer totalRailsCount{get;set;}

    //Variables for Group by PaymentStatus
    public Integer payUBusCount{get;set;}
    public Integer payURailCount{get;set;}
    public Integer payUTotalCount{get;set;}
    public Integer ppeUBusCount{get;set;}
    public Integer ppeRailCount{get;set;}
    public Integer ppeTotalCount{get;set;}
    public Integer upiBusCount{get;set;}
    public Integer upiRailCount{get;set;}
    public Integer upiTotalCount{get;set;}
    public Integer jPayBusCount{get;set;}
    public Integer jPayRailCount{get;set;}
    public Integer jPayTotalCount{get;set;}
    public Integer rPayBusCount{get;set;}
    public Integer rPayRailCount{get;set;}
    public Integer rPayTotalCount{get;set;}
    public Integer pUpiBusCount{get;set;}
    public Integer pUpiRailCount{get;set;}
    public Integer pUpiTotalCount{get;set;}
    public Integer aPayBusCount{get;set;}
    public Integer aPayRailCount{get;set;}
    public Integer aPayTotalCount{get;set;}
    public Integer ptmUBusCount{get;set;}
    public Integer ptmRailCount{get;set;}
    public Integer ptmTotalCount{get;set;}
    public Integer gpayBusCount{get;set;}
    public Integer gpayRailCount{get;set;}
    public Integer gpayTotalCount{get;set;}
    public Integer airtelBusCount{get;set;}
    public Integer airtelRailCount{get;set;}
    public Integer airtelTotalCount{get;set;}
    public Integer SimplBusCount{get;set;}
    public Integer SimplRailCount{get;set;}
    public Integer SimplTotalCount{get;set;}
    public Integer CredPayBusCount{get;set;}
    public Integer CredPayRailCount{get;set;}
    public Integer CredPayTotalCount{get;set;}
    public Integer TechProcessBusCount{get;set;}
    public Integer TechProcessRailCount{get;set;}
    public Integer  TechProcessTotalCount{get;set;}
   
     public list<wrapperclass> getPaasEscalatedCases(){
        List<wrapperclass> finalMapList = New List<wrapperclass>();
        string strQuery = System.Label.RefundsPendingReportQuery;
        List<case> TotalCaseList  = Database.query(strQuery);
        TotalCount =0;
        if(!TotalCaseList.isEmpty()){
            TotalCount = Integer.valueOf(TotalCaseList.size());
        //Age 1: <= 24 HRS Records.
        List<case> Age1CaseList = Database.query(strQuery+' and Paas_Creation_Age__c<=24');
            Age1BusCount=0;Age1RailCount=0;Age1TotalCount=0;
            if(!Age1CaseList.isEmpty()){
                Age1TotalCount = Integer.valueOf(Age1CaseList.size());
                for(case c : Age1CaseList){
                    if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                        Age1BusCount =Age1BusCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                        Age1RailCount =Age1RailCount + 1;
                    }
                }
            }
        wrapperclass Age1Wrapper = New wrapperclass('0 - 24 Hrs',Age1BusCount,Age1RailCount,Age1TotalCount,((Decimal.valueOf(Age1TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age1Wrapper);

        //Age 2: 24 - 48 Hrs
        List<case> Age2CaseList = Database.query(strQuery+' and Paas_Creation_Age__c>24 and Paas_Creation_Age__c<=48');
            Age2BusCount=0;Age2RailCount=0;Age2TotalCount=0;
            if(!Age2CaseList.isEmpty()){
                Age2TotalCount = Integer.valueOf(Age2CaseList.size());
                for(case c : Age2CaseList){
                    if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                        Age2BusCount =Age2BusCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                        Age2RailCount =Age2RailCount + 1;
                    }
                }
            }
        wrapperclass Age2Wrapper = New wrapperclass('24 - 48 Hrs',Age2BusCount,Age2RailCount,Age2TotalCount,((Decimal.valueOf(Age2TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age2Wrapper);

        //Age 3: 2 - 7 Days
        List<case> Age3CaseList = Database.query(strQuery+' and Paas_Creation_Age__c>48 and Paas_Creation_Age__c<=168');
        Age3BusCount=0;Age3RailCount=0;Age3TotalCount=0;
        if(!Age3CaseList.isEmpty()){
            Age3TotalCount = Integer.valueOf(Age3CaseList.size());
            for(case c : Age3CaseList){
                if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                    Age3BusCount =Age3BusCount + 1;
                }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                    Age3RailCount =Age3RailCount+1;
                }
            }
        }
        wrapperclass Age3Wrapper = New wrapperclass('2 - 7 Days',Age3BusCount,Age3RailCount,Age3TotalCount,((Decimal.valueOf(Age3TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age3Wrapper);

        //Age 4: 7 - 15 Days
        List<case> Age4CaseList = Database.query(strQuery+' and Paas_Creation_Age__c>168 and Paas_Creation_Age__c<=360');
        Age4BusCount=0;Age4RailCount=0;Age4TotalCount=0;
        if(!Age4CaseList.isEmpty()){
            Age4TotalCount = Integer.valueOf(Age4CaseList.size());
            for(case c : Age4CaseList){
                if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                    Age4BusCount =Age4BusCount + 1;
                }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                    Age4RailCount =Age4RailCount+1;
                }
            }
        }
        wrapperclass Age4Wrapper = New wrapperclass('7 - 15 Days',Age4BusCount,Age4RailCount,Age4TotalCount,((Decimal.valueOf(Age4TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age4Wrapper);

        //Age 5: 15 - 30 Days
        List<case> Age5CaseList = Database.query(strQuery+' and Paas_Creation_Age__c>360 and Paas_Creation_Age__c<=720');
        Age5RailCount=0;Age5BusCount=0;Age5TotalCount=0;
        if(!Age5CaseList.isEmpty()){
            Age5TotalCount = Integer.valueOf(Age5CaseList.size());
            for(case c : Age5CaseList){
                if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                    Age5BusCount =Age5BusCount + 1;
                }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                    Age5RailCount =Age5RailCount+1;
                }
            }
        }
        wrapperclass Age5Wrapper = New wrapperclass('15 - 30 Days',Age5BusCount,Age5RailCount,Age5TotalCount,((Decimal.valueOf(Age5TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age5Wrapper);

        //Age 6: 1 Month +
        List<case> Age6CaseList = Database.query(strQuery+' and Paas_Creation_Age__c>720');
        Age6BusCount=0;Age6RailCount=0;Age6TotalCount=0;
        if(!Age6CaseList.isEmpty()){
            Age6TotalCount = Integer.valueOf(Age6CaseList.size());
            for(case c : Age6CaseList){
                if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                    Age6BusCount =Age6BusCount + 1;
                }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                    Age6RailCount =Age6RailCount+1;
                }
            }
        }
        wrapperclass Age6Wrapper = New wrapperclass('1 Month +',Age6BusCount,Age6RailCount,Age6TotalCount,((Decimal.valueOf(Age6TotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
        finalMapList.add(Age6Wrapper);

        totalBusCount = Age1BusCount + Age2BusCount + Age3BusCount + Age4BusCount + Age5BusCount + Age6BusCount;
        totalRailsCount = Age1RailCount + Age2RailCount + Age3RailCount + Age4RailCount + Age5RailCount + Age6RailCount;
        }
        System.debug(':::: Value of p ::: '+finalMapList);

        return finalMapList;
    }

    public list<PGTypeWrapper> getPGTypeGroup(){
        List<PGTypeWrapper> finalMapList = New List<PGTypeWrapper>();
        string strQuery = System.Label.RefundsPendingReportQuery;
        List<case> TotalCaseList  = Database.query(strQuery);
        TotalCount =0;
        if(!TotalCaseList.isEmpty()){
            TotalCount = Integer.valueOf(TotalCaseList.size());
            //PAYU
            List<case> payUList = Database.query(strQuery +' AND PG_Type_Select__c=\'PAYU\'');
            payUBusCount=0;payURailCount=0;payUTotalCount=0;
            if(!payUList.isEmpty()){
                payUTotalCount = Integer.valueOf(payUList.size());
                for(case c : payUList){
                    if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                        payUBusCount =payUBusCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                        payURailCount =payURailCount + 1;
                    }
                }
            }
            PGTypeWrapper payUWrapper = New PGTypeWrapper('PAYU',payUBusCount,payURailCount,payUTotalCount,((Decimal.valueOf(payUTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(payUWrapper);
             //PhonePe
            List<case> ppeList = Database.query(strQuery +' AND PG_Type_Select__c=\'PhonePe\'');
            ppeUBusCount=0;ppeRailCount=0;ppeTotalCount=0;
            if(!ppeList.isEmpty()){
                ppeTotalCount = Integer.valueOf(ppeList.size());
                for(case c : ppeList){
                    if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                        ppeUBusCount =ppeUBusCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                        ppeRailCount =ppeRailCount + 1;
                    }
                }
            }
            PGTypeWrapper ppeWrapper = New PGTypeWrapper('PhonePe',ppeUBusCount,ppeRailCount,ppeTotalCount,((Decimal.valueOf(ppeTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(ppeWrapper);
             //UPI
            List<case> upiList = Database.query(strQuery +' AND PG_Type_Select__c=\'UPI\'');
            upiBusCount=0;upiRailCount=0;upiTotalCount=0;
            if(!upiList.isEmpty()){
                upiTotalCount = Integer.valueOf(upiList.size());
                for(case c : upiList){
                    if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                        upiBusCount =upiBusCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                        upiRailCount =upiRailCount + 1;
                    }
                }
            }
            PGTypeWrapper upiWrapper = New PGTypeWrapper('UPI',upiBusCount,upiRailCount,upiTotalCount,((Decimal.valueOf(upiTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(upiWrapper);
              //JusPay
            List<case> jPayList = Database.query(strQuery +' AND PG_Type_Select__c=\'JusPay\'');
            jPayBusCount=0;jPayRailCount=0;jPayTotalCount=0;
            if(!jPayList.isEmpty()){
                jPayTotalCount = Integer.valueOf(jPayList.size());
                for(case c : jPayList){
                    if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                        jPayBusCount =jPayBusCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                        jPayRailCount =jPayRailCount + 1;
                    }
                }
            }
            PGTypeWrapper jPayWrapper = New PGTypeWrapper('JusPay',jPayBusCount,jPayRailCount,jPayTotalCount,((Decimal.valueOf(jPayTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(jPayWrapper);
             //Razorpay
            List<case> rPayList = Database.query(strQuery +' AND PG_Type_Select__c=\'Razorpay\'');
            rPayBusCount=0;rPayRailCount=0;rPayTotalCount=0;
            if(!rPayList.isEmpty()){
                rPayTotalCount = Integer.valueOf(rPayList.size());
                for(case c : rPayList){
                    if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                        rPayBusCount =rPayBusCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                        rPayRailCount =rPayRailCount + 1;
                    }
                }
            }
            PGTypeWrapper rPayWrapper = New PGTypeWrapper('Razorpay',rPayBusCount,rPayRailCount,rPayTotalCount,((Decimal.valueOf(rPayTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(rPayWrapper);
               //PayuUPI
            List<case> pUpiList = Database.query(strQuery +' AND PG_Type_Select__c=\'PayuUPI\'');
            pUpiBusCount=0;pUpiRailCount=0;pUpiTotalCount=0;
            if(!pUpiList.isEmpty()){
                pUpiTotalCount = Integer.valueOf(pUpiList.size());
                for(case c : pUpiList){
                    if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                        pUpiBusCount =pUpiBusCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                        pUpiRailCount =pUpiRailCount + 1;
                    }
                }
            }
            PGTypeWrapper pUpiWrapper = New PGTypeWrapper('PayuUPI',pUpiBusCount,pUpiRailCount,pUpiTotalCount,((Decimal.valueOf(pUpiTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(pUpiWrapper);
              //AmazonPay
            List<case> aPayList = Database.query(strQuery +' AND PG_Type_Select__c=\'AmazonPay\'');
            aPayBusCount=0;aPayRailCount=0;aPayTotalCount=0;
            if(!aPayList.isEmpty()){
                aPayTotalCount = Integer.valueOf(aPayList.size());
                for(case c : aPayList){
                    if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                        aPayBusCount =aPayBusCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                        aPayRailCount =aPayRailCount + 1;
                    }
                }
            }
            PGTypeWrapper aPayWrapper = New PGTypeWrapper('AmazonPay',aPayBusCount,aPayRailCount,aPayTotalCount,((Decimal.valueOf(aPayTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(aPayWrapper);
                //PayTm
            List<case> ptmList = Database.query(strQuery +' AND PG_Type_Select__c=\'PayTm\'');
            ptmUBusCount=0;ptmRailCount=0;ptmTotalCount=0;
            if(!ptmList.isEmpty()){
                ptmTotalCount = Integer.valueOf(ptmList.size());
                for(case c : ptmList){
                    if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                        ptmUBusCount =ptmUBusCount + 1;
                    }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                        ptmRailCount =ptmRailCount + 1;
                    }
                }
            }
            PGTypeWrapper ptmWrapper = New PGTypeWrapper('PayTm',ptmUBusCount,ptmRailCount,ptmTotalCount,((Decimal.valueOf(ptmTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
            finalMapList.add(ptmWrapper);

                //GPay
                List<case> gpayList = Database.query(strQuery +' AND PG_Type_Select__c=\'GPay\'');
                gpayBusCount=0;gpayRailCount=0;gpayTotalCount=0;
                if(!gpayList.isEmpty()){
                    gpayTotalCount = Integer.valueOf(gpayList.size());
                    for(case c : gpayList){
                        if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                            gpayBusCount =gpayBusCount + 1;
                        }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                            gpayRailCount =gpayRailCount + 1;
                        }
                    }
                }
                PGTypeWrapper gPayWrapper = New PGTypeWrapper('GPay',gpayBusCount,gpayRailCount,gpayTotalCount,((Decimal.valueOf(gpayTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
                finalMapList.add(gPayWrapper);

                //Airtel
                List<case> airtelList = Database.query(strQuery +' AND PG_Type_Select__c=\'Airtel\'');
                airtelBusCount=0;airtelRailCount=0;airtelTotalCount=0;
                if(!airtelList.isEmpty()){
                    airtelTotalCount = Integer.valueOf(airtelList.size());
                    for(case c : airtelList){
                        if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                            airtelBusCount =airtelBusCount + 1;
                        }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                            airtelRailCount =airtelRailCount + 1;
                        }
                    }
                }
                PGTypeWrapper airtelWrapper = New PGTypeWrapper('Airtel',airtelBusCount,airtelRailCount,airtelTotalCount,((Decimal.valueOf(airtelTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
                finalMapList.add(airtelWrapper);

                //Simpl
                List<case> simplList = Database.query(strQuery +' AND PG_Type_Select__c=\'Simpl\'');
                SimplBusCount=0;SimplRailCount=0;SimplTotalCount=0;
                if(!simplList.isEmpty()){
                    SimplTotalCount = Integer.valueOf(simplList.size());
                    for(case c : simplList){
                        if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                            SimplBusCount =SimplBusCount + 1;
                        }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                            SimplRailCount =SimplRailCount + 1;
                        }
                    }
                }
                PGTypeWrapper simplWrapper = New PGTypeWrapper('Simpl',SimplBusCount,SimplRailCount,SimplTotalCount,((Decimal.valueOf(SimplTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
                finalMapList.add(simplWrapper);
                
                //CredPay
                List<case> credPayList = Database.query(strQuery +' AND PG_Type_Select__c=\'CredPay\'');
                CredPayBusCount=0;CredPayRailCount=0;CredPayTotalCount=0;
                if(!credPayList .isEmpty()){
                    CredPayTotalCount = Integer.valueOf(credPayList .size());
                    for(case c : credPayList){
                        if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                            CredPayBusCount =CredPayBusCount + 1;
                        }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                            CredPayRailCount =CredPayRailCount + 1;
                        }
                    }
                }
                PGTypeWrapper credPayWrapper = New PGTypeWrapper('CredPay',CredPayBusCount,CredPayRailCount,CredPayTotalCount,((Decimal.valueOf(CredPayTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
                finalMapList.add(credPayWrapper);
                
                   //TechProcess
                List<case> TechProcessList = Database.query(strQuery +' AND PG_Type_Select__c=\'TechProcess\'');
                TechProcessBusCount=0;TechProcessRailCount=0;TechProcessTotalCount=0;
                if(!TechProcessList .isEmpty()){
                    TechProcessTotalCount = Integer.valueOf(TechProcessList.size());
                    for(case c : TechProcessList){
                        if(c.Business_Unit_ct__c == 'REDBUS_IN'){
                            TechProcessBusCount =TechProcessBusCount + 1;
                        }else if(c.Business_Unit_ct__c == 'REDBUS_RAILS_IN' || c.Business_Unit_ct__c == 'REDRAILS_IN'){
                            TechProcessRailCount =TechProcessRailCount + 1;
                        }
                    }
                }
                PGTypeWrapper techProcessWrapper = New PGTypeWrapper('TechProcess',TechProcessBusCount,TechProcessRailCount,TechProcessTotalCount,((Decimal.valueOf(TechProcessTotalCount)/Decimal.valueOf(TotalCount))*100).setScale(0));
                finalMapList.add(techProcessWrapper);
        }

        totalBusCount = payUBusCount + ppeUBusCount + upiBusCount + jPayBusCount + rPayBusCount + pUpiBusCount + aPayBusCount + ptmUBusCount+gpayBusCount+airtelBusCount+SimplBusCount+CredPayBusCount+TechProcessBusCount;
        totalRailsCount = payURailCount + ppeRailCount + upiRailCount + jPayRailCount + rPayRailCount + pUpiRailCount + aPayRailCount + ptmRailCount+gpayRailCount+airtelRailCount+SimplRailCount+CredPayRailCount+TechProcessRailCount;

        system.debug('Final Map List'+finalMapList);

        return finalMapList;
    }

    public class wrapperclass{
        public string Ageing {get; set;}
        public Integer busCount {get; set;}
        public Integer railCount {get; set;}
        public Integer totalContributon {get; set;}
        public Decimal percentageContributon {get;set;}
        

        public wrapperclass(String Age, Integer bCount, Integer rCount, Integer total, decimal percent){
            this.Ageing = Age;
            this.busCount = bCount;
            this.railCount = rCount;
            this.totalContributon = total;
            this.percentageContributon = percent;
        }
    }

    public class PGTypeWrapper{
        public string PGType {get; set;}
        public Integer busCount {get; set;}
        public Integer railCount {get; set;}
        public Integer totalContributon {get; set;}
        public Decimal percentageContributon {get;set;}
        

        public PGTypeWrapper(String pg, Integer bCount, Integer rCount, Integer total, decimal percent){
            this.PGType = pg;
            this.busCount = bCount;
            this.railCount = rCount;
            this.totalContributon = total;
            this.percentageContributon = percent;
        }
    }
}