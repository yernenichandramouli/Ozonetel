public with sharing class TransactionStatusMssg_cls
{
    public Order_Items__c orders{get;set;}
    public Account acc{get;set;}
    public String message{get;set;}
    public string accId{get;set;}
    //public Date Today { get { return System.Now()-; }}
    public TransactionStatusMssg_cls(ApexPages.StandardController controller)
    {
        accId =ApexPages.CurrentPage().getParameters().get('Id');
        Date dt=System.Today()-10;
       
        
        try{
        orders = [Select Id,Name,status__c, Boarding_Time__c, Date_of_Boarding_Time__c, Corrected_Boarding_Time__c, Updated_Time__c,Refund_Status__c,Primary_Contact_Customer__c,Order_Item_Reference_No__c,Order_Id__c, Date_Of_Service__c,Source__c,Destination__c,(Select Id,Name,Refund_Status__c,Primary_Boarding_Time__c From Bus_Order_Item_Details__r),(SELECT Id,Updated_Time__c FROM Refund_Order_Items__r LIMIT 1) From Order_Items__c Where (Primary_Contact_Customer__c =:accId OR Customer_Name__c =: accId)  AND CreatedDate >=:dt LIMIT 1];
        }catch(exception e){}
        
        
        
        if(orders!=Null)
        {
            System.Debug('@@==>> orders: '+orders);
            Map<String,String> mapStatus = new Map<String,String>();
            for(Transaction_Status_Category__c transStatus : Transaction_Status_Category__c.getAll().Values())
            {          
                mapStatus.put(transStatus.Status__c,transStatus.Category__c);
            }
            System.Debug('@@==>> After for loop: '+orders);
            if(mapStatus.ContainsKey(orders.status__c) && mapStatus.get(orders.status__c)!='Confirmed')
            {
                System.Debug('@@==>> Status: '+orders);
                if(mapStatus.get(orders.status__c)=='WFT')
                {
                    message='Customer had a WFT with TRIP ID '+orders.Order_Id__c+' to travel from '+orders.Source__c+' to '+orders.Destination__c+' on '+ orders.Date_of_Boarding_Time__c +'.Please assist the customer for booking';
                }
                else
                if(mapStatus.get(orders.status__c)=='GFT')
                {
                    message ='Customer is calling for GFT. Please check if it is misbooking or confirmation failure and help for refund/rebooking';
                }
                else
                if(mapStatus.get(orders.status__c)=='Cancelled')
                {
                    if(!orders.Refund_Order_Items__r.IsEmpty())
                    {
                        String ss = String.Valueof(orders.Refund_Order_Items__r[0].Updated_Time__c!=Null ? orders.Refund_Order_Items__r[0].Updated_Time__c : orders.Refund_Order_Items__r[0].Updated_Time__c);
                        /*if(orders.Refund_Order_Items__r[0].Updated_Time__c!=Null)
                        {
                            message='Customer might be calling for refund. Refund status is '+orders.Refund_Status__c+' since '+orders.Refund_Order_Items__r[0].Updated_Time__c.addMinutes(330);
                        }
                        else
                        {
                            message='Customer might be calling for refund. Refund status is '+orders.Refund_Status__c+' since '+orders.Refund_Order_Items__r[0].Updated_Time__c;
                        }*/
                        message='Customer might be calling for refund. Refund status is '+orders.Refund_Status__c+' since '+ss;
                    }
                    else
                    {
                        message='Customer might be calling for refund. Refund status is '+orders.Refund_Status__c+' since null';
                    }
                }
            }   
            else
            {
                System.Debug('@@==>> Time: '+orders);
                Long Diff;
                if(!orders.Bus_Order_Item_Details__r.IsEmpty() && orders.Bus_Order_Item_Details__r[0].Primary_Boarding_Time__c!=Null)
                {
                     System.Debug('@@==>> orders.Bus_Order_Item_Details__r[0]: '+orders.Bus_Order_Item_Details__r[0]);
                    Diff = ((orders.Bus_Order_Item_Details__r[0].Primary_Boarding_Time__c.getTime())/1000/60/60-((DateTime.now().getTime())/1000/60/60));
                }
                if(Diff!=null)
                {
                    System.Debug('@@==>> Time Dff: '+orders);
                    if(Diff>5)
                    {
                        message='Customer might be calling for query on '+orders.Order_Item_Reference_No__c+' for cancellation or e/M ticket not received';
                    }
                    else
                    if(Diff<5 &&Diff>0 )
                    {
                        message='Customer could be calling for help in boarding point or for bus cancellation related issues';
                    }
                    else
                    if(Diff<0 &&Diff>-2 )
                    {
                        message='Customer is travelling currently for booking '+orders.Order_Item_Reference_No__c+'. This could be a service related issue/ bus getting delayed or cancelled';
                    }
                    else
                    if(Diff<-2 )
                    {
                        message='Customer recently travelled on '+orders.Order_Item_Reference_No__c+' from '+orders.Source__c+' to '+orders.Destination__c+'. This could a BO service related call';
                    }
                }
            }    
        }
        else
        {
            message='Customer could be calling for booking challenges. Please assist with searching for bus/ offer application/ any payment related queries';
        }
    }
    
  
}