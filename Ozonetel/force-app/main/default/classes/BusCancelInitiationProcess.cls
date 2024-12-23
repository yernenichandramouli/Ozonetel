/**
 * (c) 2016 RedBus
 *
 * Name           : BusCancelInitiationProcess 
 * Created Date   : 29 Jan 2017
 * Created By     : Sreenivas M
 * Purpose        : Extension class for ProcessBuilder to insert BusCancellation Record in Trex
 *
 **/
 
public class BusCancelInitiationProcess {

  @InvocableMethod
   public static void busCancellationInsert(List<String> reqBody)
   {
     /* sample expected value from reqBody
     tin_status_dateofJouney_routeId_creationTime
     TJD954779847_Initiated_2016-12-12 18:30:00Z_9137917_2016-12-13 07:28:10Z */ 
     
     System.debug('reqBody..'+reqBody+reqBody[0]);
     String[] paramList = new List<String>();
     paramList = String.valueOf(reqBody).removeStart('(').removeEnd(')').split('_');
     System.debug('Tin number for bus cancellation insert..'+paramList[0]);
     Integer tempRouteId;
     
     for(Integer i = paramList.size();i<9;i++)
         paramList.add('');
     
     if(String.isNotBlank(paramList[3]))
         tempRouteId = Integer.valueOf(paramList[3]);
         
     System.debug('..paramList ..'+paramList);
     
     JsonWrapper jsonWrap = new JsonWrapper(paramList[0],paramList[1],paramList[2],tempRouteId,paramList[4],paramList[5],paramList[6],paramList[7],paramList[8],'');
     System.debug('jsonWrap...'+jsonWrap);
     if(!System.isFuture() && !System.isBatch())
         BusCancellationHandler.insertCancelItems(JSON.serialize(jsonWrap));  
   }
   
  public class JsonWrapper
  {
       public string tin{get;set;}
       public string status{get;set;}
       public string doj{get;set;}
       public integer routeId{get;set;}
       public string cancellationStatus{get;set;}
       public string createdTime{get;set;}
       public string initiatedBy{get;set;}
       public string boAgentNameByCSE{get;set;}
       public string boAgentContactByCSE{get;set;}
       public string SPOCNameByCSE{get;set;}
       public string updatedTime{get;set;}
       public string boAgentNameBySPOC{get;set;}
       public string boAgentContactBySPOC{get;set;}
       public string notes{get;set;}
       public string approvedBy{get;set;}
       public string orderItemUuid{get;set;}
       
       public JsonWrapper(){
       }
       public JsonWrapper(String ptin,String pStatus,String pdoj,Integer pRouteId,String pUuId,String pDate,String pAgentName,String pSpocName,String pAgentContact,String pNotes)
       {
         cancellationStatus= '0';
         initiatedBy = UserInfo.getName()+'('+UserInfo.getUserName()+')';
         tin = ptin;
         status =pstatus;
         notes = pNotes;
         orderItemUuid = pUuId;
         
         if(String.isNotBlank(pdoj))
         {
           System.debug('...pdoj....'+pdoj);
           Datetime dtStr = Datetime.valueOfGMT(pdoj).addDays(1);
           System.debug('dts....'+dtStr);
          /// List<String> datelist = pdoj.split(' ')[0].split('-');
          // DateTime tempDOJ = DateTime.newInstanceGMT(Integer.valueOf(dtStr.year()),Integer.valueOf(dtStr.month()),Integer.valueOf(dtStr.day()),00,00,00);     
           //doj = datelist[0]+'-'+datelist[1]+'-'+String.valueOf(Integer.valueOf(datelist[2])+1)+' 00:00:00';
         //  doj = String.valueOf(dtStr).split(' ')[0]+' 00:00:00'; 
            //doj= dtStr.formatGMT('yyyy-MM-dd 00:00:00');
            System.debug('GMT Time..'+Datetime.valueOfGMT(pdoj).format());
            doj = Datetime.valueOfGMT(pdoj).format('YYYY-MM-dd HH:mm:ss');
           System.debug('...doj ....'+doj);
            
         }
        
         routeId =pRouteId;     
         createdTime=String.valueOf(pDate);
         updatedTime = String.valueOf(pDate);
         boAgentNameByCSE = pAgentName;
         SPOCNameByCSE =UserInfo.getName()+'('+UserInfo.getUserName()+')';
         boAgentContactByCSE = pAgentContact;
         
       }
   
   }
       

}