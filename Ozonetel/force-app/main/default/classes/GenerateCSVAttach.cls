/**
 * (c) 2017 RedBus
 *
 * Name           : GenerateCSVAttach 
 * Created Date   : 3 May 2017
 * Created By     : Sreenivas M
 * Purpose        : Apex class for Attach the report body as Attachment
 * Test Class     : CaseReportCSVSchedulerTest
 *
 **/
 
public class GenerateCSVAttach {
    public static String strOut;
    public String strRptname{get;set;}
    
    public GenerateCSVAttach () {
        strOut = '';        
        }
 
   public String getGenerateCSVAttach() {
        executeRpt();
        return strOut;
        }
  
    public void executeRpt() {
        String requestURL;
        
        requestURL = '/' + strRptname + '?csv=1&exp=1&enc=UTF-8';
        if(Test.isRunningTest())
              strOut =String.valueOf('UNIT.TEST');
        else
            strOut = new PageReference(requestURL).getContent().toString();
        System.debug('CALLING executeRpt:  output= ' + strOut );
    }
 
}