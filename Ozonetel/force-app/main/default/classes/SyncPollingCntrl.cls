/**
* (c) 2017 RedBus
*
* Name           : SyncPollingCntrl
* Created Date   : 23 Feb 2017
* Created By     : Sreenivas M
* Purpose        : Extension class for SyncPolling Page
*
**/

public class SyncPollingCntrl 
{
    String ordId;
    public string source;
    
    public SyncPollingCntrl()
    {
        ordId = ApexPages.currentpage().getParameters().get('id');
        source=ApexPages.currentpage().getParameters().get('source');
    }
    
    public PageReference searchOrder()
    {
        System.debug('.started..'+ordId);
        List<Orders__c> order = new List<Orders__c>();
        List<Order_Items__c> ordItms=new List<Order_Items__c>();
        
        if(source!='B2B'){     
         
             ordItms =[select id,Order_Id__c from Order_Items__c where OrderUuid__c=:ordId OR Order_Id__c=:ordId]; 
            if(!ordItms.isEmpty())
            {
                 Pagereference pg;
         if(ordItms.size()==1)
                    pg= new Pagereference('/'+ordItms[0].id);
                 else
                   pg = new Pagereference('/_ui/search/ui/UnifiedSearchResults?initialViewMode=summary&searchAll=true&str='+ordItms[0].Order_Id__c+'&isdtp=vw');
         
           pg.setRedirect(true);
               return pg;
            }
        }else{
            String strOrd = ordId.SubStringBefore('_');
            ordItms=[select id,name,Order_Item_Reference_No__c from Order_Items__c where Order_Item_Reference_No__c=:strOrd];
            if(!ordItms.isEmpty())
            {
                Pagereference  pg = new Pagereference('/_ui/search/ui/UnifiedSearchResults?initialViewMode=summary&searchAll=true&str='+ordItms[0].Name+'&isdtp=vw');
                pg.setRedirect(true);
                return pg;
            }
        }
        return null;
    }
}