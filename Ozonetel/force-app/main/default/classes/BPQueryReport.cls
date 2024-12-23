public class BPQueryReport{

public date fromDate{get;set;}
public date toDate{get;set;}
public integer  diffDate;
    
    public BPQueryReport(){
        bList=new List<BPWrapper>();
       // countRecords(); 
        diffDate=0;       
    }
    public DateTime setStringToDateFormat(String myDate,string check) {
        String[] myDateOnly = myDate.split(' ');
        String[] strDate = myDateOnly[0].split('-');
        Integer myIntDate;
        
        if(check=='fd'){
            myIntDate = integer.valueOf(strDate[2])-1;
        }else{
            myIntDate = integer.valueOf(strDate[2]);
        }        
        Integer myIntMonth = integer.valueOf(strDate[1]);
        Integer myIntYear = integer.valueOf(strDate[0]);
        DateTime d = DateTime.newInstanceGMT(myIntYear, myIntMonth, myIntDate);
        return d;
    }
    
    public List<date> dList=new List<date>();
    public List<BPWrapper> bList{get;set;}
    
    public void countRecords(){
   //    for(date d:fromDate){
    //   dList.add(System.today().addDays(-i));
     //  }
     bList.clear();
     dList.clear();
     System.debug('bList-->'+bList);
       diffDate = fromDate.daysBetween(toDate) ;

        for(integer i=0;i<=diffDate ;i++){
            dList.add(toDate.addDays(-i));
        }
        
        for(date d:dList){
           
            BPWrapper b=new BPWrapper();
            Integer intCount = 0;
            b.caseCount=0;
            b.tCount=0;
            
            DateTime mf=setStringToDateFormat(string.valueof(d),'fD');
            DateTime mt=setStringToDateFormat(string.valueof(d),'tD');
            
         //   System.debug('mf-->'+mf+'<--mt--->'+mt);
            
            mf=DateTime.newInstanceGMT(d.year(),d.month(),d.day(),18,30,00).addDays(-1);
            mt=DateTime.newInstanceGMT(d.year(),d.month(),d.day(),18,29,59).addDays(-1);
            
                        System.debug('mf2-->'+mf+'<--mt2--->'+mt.addDays(1));

            
            for(AggregateResult result :[SELECT COUNT(Id) cVal FROM case where Issue_Sub_Category__c=:label.BP_Queries.split(',') AND CreatedDate>=:mf AND CreatedDate<=:mt.addDays(1) ])
            {
                b.caseCount+=(Integer)result.get('cVal');
            }  
            for(AggregateResult result :[SELECT COUNT(Id) tVal FROM order_items__c where CreatedDate>=:mf AND CreatedDate<=:mt.addDays(1)])
            {
                b.tCount+=(Integer)result.get('tVal');
            }
            b.datev= mf.day() + '/' + mf.month() + '/' + mf.year();
            if(b.caseCount!=0)
            b.percentage=b.tCount/b.caseCount;
            bList.add(b);
                 
        }   
        System.debug('bList Af--->'+ bList);
         // bList.sort();      
    }
    
    public PageReference exportToExcel() {
   return Page.BPQueryReportCSV;
 }
    
    public class BPWrapper{
        public string datev{get;set;}
        public Integer caseCount{get;set;}
        public Integer tCount{get;set;}
        public decimal percentage{get;set;}
    } 
}