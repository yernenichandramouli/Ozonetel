trigger phone10digit on Account (before insert, before update) 
{
    string ISDcodes = System.Label.CountryISDCodes;
    for(account ac: system.trigger.new)
    {
            if(!string.IsBlank(string.valueof(ac.PersonMobilePhone)))
            {
                string phNo = string.valueof(ac.PersonMobilePhone);
                if(phNo.contains('+'))
                {
                    phNo = phNo.replace('+','');
                }
                if(ISDcodes.contains(phNo.substring(0,2)))
                {
                    ac.Phone_10_Digits__c = phNo.substring(2,phNo.length()); 
                }
                else
                {
                    ac.Phone_10_Digits__c = phNo; 
                }                
            }
    }
}