@isTest
private class LeadExtensionTest{
    public static testMethod void  testLead() 
    { 
      lead l=new lead();
        l.lastname='Test';
        insert l;
        ApexPages.currentPage().getParameters().put('id', l.id);
        
         ApexPages.StandardController sc = new ApexPages.StandardController(l);
        LeadExtension lex= new LeadExtension(sc);
        lex.busHireCall=true;
    }
    
    }