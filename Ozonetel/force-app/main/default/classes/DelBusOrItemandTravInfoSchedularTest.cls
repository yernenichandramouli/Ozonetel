/**
 * (c) 2017 RedBus
 *
 * Name           : DelBusOrItemandTravInfoSchedularTest
 * Created Date   : 25 Oct 2017
 * Created By     : Sreenivas M
 * Purpose        : Test class for DelBusOrItemandTravInfoSchedular
 *
 **/
 
@istest
class DelBusOrItemandTravInfoSchedularTest{

   static testmethod void test() {
   Test.startTest();
     DelBusOrItemandTravInfoSchedular  p= new DelBusOrItemandTravInfoSchedular();
     String sch = '0 0 8 13 2 ?';
     system.schedule('One Time Pro', sch, p);
    Test.stopTest();
   
   }
 }