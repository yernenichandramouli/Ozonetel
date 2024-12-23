trigger UpdateObjectInfo on Site_Helper__c (After insert) {
    
    public List<case> cList=new List<case>();
    
    for(Site_Helper__c s:Trigger.new){
        case c=new case();
        c.id=s.case_Id__c;
        c.status=s.Status__c;
        c.BD_user__c=s.BD_user__c;
        c.Correct_BP_Number__c=s.Correct_BP_Number__c;
        c.isExisting_BPnumber__c=s.BP_Number__c;
       // c.BP_Address__c=s.BP_Address__c;
        c.Correct_BP_Address__c=s.Correct_BP_Address__c;
        System.debug('assi-->'+s.Assigned_By__c);
        
        if(string.isNotBlank(s.Assigned_By__c)){
            list<user> usrLs=new list<user>();
            usrLs=[select id,username,isactive from user where id=:s.Assigned_By__c]; 
            
            if(!usrLs.isEmpty() && usrLs[0].isactive){
                c.ownerid=s.Assigned_By__c;
            }else if(s.Assigned_By__c=='BP verfiication'){
                Id BPQid = [Select id from Group where type='Queue' AND developername='BP_Verification_Queue'].id; 
                c.ownerid=BPQid;
            }else if(s.Assigned_By__c=='Invalid BP Queue'){
                Group invalBPqu=[select id from Group where type='Queue' AND developername='Invalid_BP_Queue']; 
                c.ownerid=invalBPqu.id;
            }else if(s.Assigned_By__c=='YourBus'){
                Group ybSupport=[select id from Group where type='Queue' AND developername='YB_Support_Queue']; 
                c.ownerid=ybSupport.id;
            }else if(s.Assigned_By__c=='Non callble scheduler' || s.Assigned_By__c=='Non callble BD' || s.Assigned_By__c=='RPW Queue'){
                   c.ownerid=System.Label.L2_Support_Queue_Id; 
            }else{
                c.ownerid=s.Assigned_By__c;
            }
        }else if(string.isBlank(s.Assigned_By__c)){
            
           c.ownerid=System.Label.L2_Support_Queue_Id; 
        }else{
           c.ownerid=System.Label.L2_Support_Queue_Id; 
        }
        
        c.Resolved_By__c=s.Resolved_By__c;
        cList.add(c);
        System.debug('cList-->'+cList);
    }
    
    if(!cList.isEmpty()){       
        update cList;
    }
    
}