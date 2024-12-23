/**
* (c) 2019 RedBus
*
* Name           : BusHireCallingErrorResetScheduler
* Created Date   : 05 Jan 2019
* Created By     : Mahendra K
* Purpose        : Scheduler to reset the is error fields in User Details
*
**/

global class BusHireCallingErrorResetScheduler implements Schedulable{
 global void execute(SchedulableContext sc) 
 {
        
          System.abortJob(sc.getTriggerId());
      Integer nextIntervalHour = DateTime.now().addMinutes(Integer.valueOf(Label.Error_Reset_Intervel)).hour();
        system.debug('nextIntervalHour-->>'+nextIntervalHour);
       if(nextIntervalHour>=21)
       {
            Datetime sysNextDate = System.now().addDays(1);
            String chron_exp = '0 0 8'+ ' ' + sysNextDate.day() + ' ' + sysNextDate.month() + ' ? ' + sysNextDate.year();
            System.schedule('BusHireCallingErrorResetScheduler - '+String.valueOf(DateTime.now()),chron_exp, this);
       }
       else if(nextIntervalHour<=7)
            System.schedule('BusHireCallingErrorResetScheduler - '+String.valueOf(DateTime.now()), '0 0 8'+ ' ' + System.now().day() + ' ' + System.now().month() + ' ? ' + System.now().year(),this);

       else
        {
           System.schedule('BusHireCallingErrorResetScheduler - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(Label.Error_Reset_Intervel)).minute()+' */1 ? * *', this);
        }
       
        DateTime curTime = System.now();
        list<User_Details__c> listusrd = new  list<User_Details__c>();
        
        for(User_Details__c ust :[SELECT is_Error_Occurred__c,Error_Description__c,Error_Time__c from User_Details__c where X2_Mins_From_Error_Time__c<:curTime and CreatedDate=Today and is_Error_Occurred__c=True])
        {
               ust.is_Error_Occurred__c =False;
               ust.Error_Description__c = '';
               ust.Error_Time__c =null;
               ust.Next_Call_Time__c = System.now();
               listusrd.add(ust);
        }
        
        if(!listusrd.isEmpty())
            update listusrd;
    }

}