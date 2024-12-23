/**
 * (c) 2023 RedBus
 *
 * Name           : FetchAmenitiesScheduler
 * Created Date   : 28 MAY 2023
 * Created By     : VR Sudarshan
 * Purpose        : Scheduler to invoke FetchAmenitiesController. To fetch amenites list values.
 * JiraId         : CRM - 1420
 * Test class     : FetchAmenitiesControllerTest
 *
 **/
global class FetchAmenitiesScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        FetchAmenitiesController.invokegetAllAmenitiesAPI();
    }
}