/*
* Name           : BpDpImagesCntrl
* Created Date   : 
* Created By     : 
* Purpose        : 
* Test class     : 
*/

public class BpDpImagesCntrl {   
  public API_EndPoints__mdt APIMData;
  public string cityIdsResp{get;set;}
  public string BpIdsResp{get;set;}
  public string BpImageResp{get;set;}
  public string BpImageUpdateResp{get;set;}
  public string selectedOperatorid{get;set;}
  public string region{get;set;}
  public string selectedCityid{get;set;}
  public string selectedBpId{get;set;}
  public string selectedStatus{get;set;}
  public set<string>  imageStatus{get;set;}
  public list<selectOption> totalCities{get;set;}
  public list<selectOption> totalOperatorids{get;set;}
  public list<selectOption> totalBpids{get;set;}
  public list<ImageUpdateRequestWrapper> listImagToUpdate{get;set;}
  public list<DisplayImageWrapper>  displayimageWrap{get;set;}
  public list<GetBpImages> bpImageResplist  {get;set;}
  public Map<Integer,Set<Integer>> mapOpIdToSetOfBpIds{get;set;}
  public Map<Integer,String> mapBpIdToBpName{get;set;}
  public bpdpImagesCntrl (){
   APIMData=new API_EndPoints__mdt();
   totalCities=new list<selectOption>();
   totalOperatorids = new list<selectOption>();
   totalBpids=new list<selectOption>();
   listImagToUpdate = new list<ImageUpdateRequestWrapper> ();
   displayimageWrap  = new  list<DisplayImageWrapper>();
   bpImageResplist  =  new  list<GetBpImages>();
   imageStatus= new  set<string>();
   mapOpIdToSetOfBpIds = new Map<Integer,Set<Integer>>();
   mapBpIdToBpName = new Map<Integer,String>();



   }
   public void GetStatusVal(){
     system.debug('--selectedStatus--'+selectedStatus);
    }
  
  public object fetchAllCities()
  {
    system.debug('--region--'+region);
    if(String.isBlank(region)){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select The Country'));
       return null;    
    }
    string endPoint =[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='bpdpCityNames'].Endpoint__c;   
    Http http = new Http();
    HttpResponse res = new HttpResponse();
    HttpRequest req = new HttpRequest();   
    req.setEndpoint(endPoint+'/'+region+'?status='+selectedStatus);
    req.setMethod('GET');
    Continuation con = new Continuation(60);
    con.continuationMethod='fetchAllCitiesResponse';
    this.cityIdsResp= con.addHttpRequest(req);
    //system.debug('--endPo--'+this.cityIdsResp);
    
    return con;
      
  }
   
  public object fetchAllCitiesResponse() 
  {
   try{ 
       
    HttpResponse response=Continuation.getResponse(this.cityIdsResp);
    string json=response.getbody();
   
    list<GetCities> resplist = new list<GetCities>();
    resplist = (list<GetCities>)system.JSON.deserialize(json, list<GetCities>.class);   
    totalCities.clear();
    totalCities.add(new selectOption('','--None--'));
    Set<String> setCityId = new Set<String>();
    
    for(GetCities res : resplist)
     {
        if(res.cityid!=NULL && !setCityId.contains(String.valueof(res.cityid)))
        {
            totalCities.add(new selectOption(string.Valueof(res.cityid),res.cityname));
            setCityId.add(String.valueof(res.cityid));
        }
        
     }
     }
    catch(Exception e){
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured, Please try again'));
      return null;
    }     
   
    return null;
  }
  
  public object fetchCityRelatedBpIds()
  {
    if(String.isBlank(selectedCityid)){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select The City Name'));
       return null;    
    }
    Http http = new Http();
    HttpResponse res = new HttpResponse();
    HttpRequest req = new HttpRequest();   
    req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='bpdpCityIds'].Endpoint__c+selectedCityid+'/'+region+'?status='+selectedStatus);
    
    req.setMethod('GET');
    Continuation con = new Continuation(60);
    con.continuationMethod='fetchCityRelatedBpIdResponse';
    this.BpIdsResp= con.addHttpRequest(req);
  system.debug('--reqsetEndpoint--'+req);
    return con;
   }
   
  public object fetchCityRelatedBpIdResponse() 
  {
   try
   {
     system.debug('--reqsetEndpoint--'+ this.BpIdsResp);
    HttpResponse response=Continuation.getResponse(BpIdsResp);
    list<GetBpids> bpresplist = new list<GetBpids>();
    bpresplist= (list<GetBpids>)system.JSON.deserialize(response.getbody(), list<GetBpids>.class);  
    totalOperatorids.clear();
    mapOpIdToSetOfBpIds.clear();
    mapBpIdToBpName.clear();
    totalOperatorids.add(new selectOption('','--None--'));
    Map<Integer,String> mapBPIds = new Map<Integer,String>();
    Map<Integer,String> mapOpIds = new Map<Integer,String>();
    
    map<integer,list<string>> mapOperIdwithBpnames= new map<integer,list<string>>();
    map<string,string> mapBpnamewithBpid = new map<string,string>();
    for(GetBpids res : bpresplist)
     {
       if(res.operatorid!=NULL)
       {
             if(!mapOpIds.containsKey(res.operatorid))
             {
                 totalOperatorids.add(new selectOption(string.Valueof(res.operatorid),res.operatorname));
                 mapOpIds.put(res.operatorid,res.operatorname);
             }
             
             if(res.bpid!=NULL && mapOpIdToSetOfBpIds.containsKey(res.operatorid))
             {
               mapOpIdToSetOfBpIds.get(res.operatorid).add(res.bpid);
               mapBpIdToBpName.put(res.bpid,res.bpname);
             }
             
             else if(res.bpid!=NULL)
             {
                 mapOpIdToSetOfBpIds.put(res.operatorid,new Set<Integer>{res.bpid});
                 mapBpIdToBpName.put(res.bpid,res.bpname);
             }
             
       }

     } 
    }catch(Exception e){
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured, Please try again'+e));
       return null;
    }           
   
    return null;
  }
  
  public void fetchBpNames()
  {
    totalBpids.clear();
    Integer selOpId;
    System.debug('Selected OpId..'+selectedOperatorid);
    if(string.isNotBlank(selectedOperatorid)){
    selOpId = Integer.valueOf(selectedOperatorid);
    }
     totalBpids.add(new selectOption('','--None--'));
    if(mapOpIdToSetOfBpIds.containskey(selOpId))
    {
     for(Integer bpId:mapOpIdToSetOfBpIds.get(selOpId))
     {
       if(mapBpIdToBpName.containsKey(bpId))
         totalBpids.add(new SelectOption(String.valueOf(bpId),mapBpIdToBpName.get(bpId)));
     
     }
    }
  
  
  }
 

public object fetchBpImages()
  {
   system.debug('--------image---');
    if(String.isBlank(selectedOperatorid) || String.isBlank(selectedBpId)){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select The Boarding Point and Operator Name'));
       return null;    
    }
    system.debug('---selectedOperatorid--'+selectedOperatorid+'--selectedBpId-'+selectedBpId);
    Http http = new Http();
    HttpResponse res = new HttpResponse();
    HttpRequest req = new HttpRequest();   
    req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='ImagesBpids'].Endpoint__c+selectedBpId+'/'+selectedOperatorid+'/'+region);
    req.setMethod('GET');
    Continuation con = new Continuation(60);
    con.continuationMethod='fetchBpImagesResponse';
    this.BpImageResp= con.addHttpRequest(req);
    return con;
    
      
   }
   
  public object fetchBpImagesResponse() 
  {
  
    try{
    HttpResponse response=Continuation.getResponse(BpImageResp);
    bpImageResplist = (list<GetBpImages>)system.JSON.deserialize(response.getbody(), list<GetBpImages>.class);
    displayimageWrap.clear();
    imageStatus.clear();
    
    for(GetBpImages res : bpImageResplist)
     {
         DisplayImageWrapper wr = new DisplayImageWrapper(res);
         wr.displayStatus = res.approvalstatus == 1?'APPROVE':res.approvalstatus == 0?'NEW':'DISCARD'; 
         imageStatus.add(wr.displayStatus);
         displayimageWrap.add(wr);   
     }
     System.debug('displayimageWrap...'+displayimageWrap.isEmpty()+'...'+displayimageWrap.size());
     if(displayimageWrap.isEmpty())
     {
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Images Found For Moderation.'));
      return null;
     }
   

    }catch(Exception e){
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured, Please try again'));
      return null;
    }           
   
    return null;
  }
  
  public Object UpdateBpImageStatus()
  {
     listImagToUpdate.clear();
    for(DisplayImageWrapper dsp:displayimageWrap)
    {
     
      if(String.isNotBlank(dsp.selStatus))
        { 
        system.debug('--dspselStatus--'+dsp.selStatus+'--imgRght-'+dsp.bpImages.imgright+'--imgLght--'+dsp.bpImages.imgleft);
        system.debug(''+dsp.bpImages.imgright);
        ImageUpdateRequestWrapper reqWrap = new ImageUpdateRequestWrapper();
        reqWrap.id =string.valueof(dsp.bpImages.id);
        reqWrap.daynight =dsp.bpImages.daynight;
        reqWrap.approvalstatus='Approve'.equalsIgnoreCase(dsp.selStatus)?1:'ImgNtclr'.equalsIgnoreCase(dsp.selStatus)?2:'ImgNtRelvnt'.equalsIgnoreCase(dsp.selStatus)?3:'DuplImg'.equalsIgnoreCase(dsp.selStatus)?4:0;
        reqWrap.side = dsp.bpImages.side;
        reqWrap.approvedby=UserInfo.getName()+'('+UserInfo.getUserName()+')';
        reqWrap.imgleft = dsp.bpImages.imgleft;
        reqWrap.imgright = dsp.bpImages.imgright;         
        listImagToUpdate.add(reqWrap);
      
       }
       
    }
    
    if(listImagToUpdate.isEmpty())
    {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Approve/Discard For At Least For One Image'));
        return null;
    }
    
    string finaljsonbdy=JSON.serialize(listImagToUpdate);
    system.debug('finaljsonbdy--->>'+finaljsonbdy);
    
    if(String.isNotBlank(finaljsonbdy))
    {
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();   
        req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='bpdpImagesUpdate'].Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setBody(finaljsonbdy);
        Continuation con = new Continuation(60);
        con.continuationMethod='UpdateBpImageStatusResponse';
        this.BpImageUpdateResp = con.addHttpRequest(req);
        system.debug('--update Req-->>'+req);
        return con;
    }
    else{
      return null;
    }
     
  }
  
  public object UpdateBpImageStatusResponse() 
  {
       
    HttpResponse response=Continuation.getResponse(this.BpImageUpdateResp);
    string respStr=response.getbody();
    System.debug('update respStr...'+respStr);
    if('Success'.equalsIgnoreCase(respStr))
    {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
      selectedOperatorid='';
      selectedBpId='';
      displayimageWrap.clear();
      system.debug('-final--'+selectedOperatorid+'--final--'+selectedBpId);
      return null;
    }
    else
    {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Has Occured While Updating.Please Retry'));
      return null;
    }   
    
    
  }
 
  
  public class ImageUpdateRequestWrapper
   {
    public string id { get; set; }
    public string imgleft { get; set; }
    public string imgright { get; set; }
    public string side { get; set; }
    public string daynight { get; set; }
    public Integer approvalstatus { get; set; }
    public string approvedby { get; set; }
   }

  public class GetCities
   {
     public integer cityid { get; set; }
     public string cityname { get; set; }
   }
   
  public class GetBpids
    {
      public integer operatorid{get; set;}
      public string operatorname{get; set;}
      public integer cityid { get; set; }
      public string bpname { get; set; }
      public integer bpid { get; set; }
   }
  public class GetBpImages
    {
    public string image { get; set; }
    public string bpname { get; set; }
    public integer bpid { get; set; }
    public string side { get; set; }
    public string imgright { get; set; }
    public integer cityid { get; set; }
    public integer approvalstatus { get; set; }
    public integer id { get; set; }
    public integer operatorid { get; set; }
    public string daynight { get; set; }
    public string cityname { get; set; }
    public string imgleft { get; set; }
 
    
  }
  
  public class DisplayImageWrapper
  {
    public GetBpImages bpImages{get;set;}
    public String selStatus{get;set;}
    public String displayStatus{get;set;}
    
    
    public DisplayImageWrapper(GetBpImages im){
     this.bpImages=im;
     this.selStatus='';
    }
  }
}