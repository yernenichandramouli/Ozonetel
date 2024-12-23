/*
* Name           : LeadExtension
* Created Date   : 26 Oct 2018
* Created By     : Veeramanikanta R
* Purpose        : Standard controller for lead obj
* Test class     : LeadExtensionTest
*/
public with sharing class LeadExtension {  
    public boolean busHireCall{get;set;}
    public lead leadObj{get;set;}
    public LeadExtension(ApexPages.StandardController controller) {
        leadObj=[select id,lastname from lead where id=:Apexpages.currentpage().getparameters().get('id')];
    } 
    
    
}