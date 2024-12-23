public class BusPackageDetails{   
    public busCWrapper bwr{get;set;}
    public string packageId{get;set;}
    public string packageResponse{get;set;}
    
    public BusPackageDetails(){
        packageId = ApexPages.currentPage().getParameters().get('pkId'); 
         bwr=new busCWrapper();
    }    
    public object getDetails(){     
        string endpointT=[SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='BusPackage'].Endpoint__c+packageId;
        string genericJson='{"action":"GET","body":"","endPoint":"'+endpointT+'","headers":""}';
        HttpRequest httpReq= new HttpRequest();
        httpReq = HttpRequestUtil.populateHeaders(httpReq);           
        httpReq.setMethod('POST');
        httpReq.setBody(genericJson);
        httpReq.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c);
        Continuation con = new Continuation(120);         
        con.continuationMethod='GetPackageResponse'; 
        System.debug('httpReq....'+httpReq);
        packageResponse= con.addHttpRequest(httpReq);           
        return con;        
    }
    public Object GetPackageResponse()
    {       
        try
        {
            System.debug('calling here');
            HttpResponse response = Continuation.getResponse(packageResponse);
            System.debug('response...'+response);  
            string jsonBody;
            if(Test.isRunningTest()){
                jsonBody ='{ "data": { "bo_name": "Test Itineray Package", "durationDays": 1, "durationNights": 1, "details": [ [ { "time": 2145, "title": "Onward Bus from Bangalore to Tirupati", "description": "", "tag": "travel", "data": { "arrival_time": "2018-12-22 05:00:00", "bo_name": "Redbus Sevenhills Quick Darshan", "bus_rating": 3.1, "bus_type": "Scania AC Multi Axle Semi Sleeper(2+2)", "departure_time": "2018-12-21 21:45:00", "review_count": "56" } }, { "time": 500, "title": "Hotel Check In", "description": "Check into Hotel for quick freshen up ", "tag": "stay", "data": { "ac": true, "amenities": [ "Toileteries", "Bathroom", "hot / cold water", "Wi-Fi Available", "Air-condition", "Air conditioning (controlled in the room)", "Free Wi-Fi access", "Elevator", "Charging points", "Complimentary Wi-Fi", "ceiling fans", "Air Conditioning", "Basic Room Amenities", "ceiling fan", "Front Desk", "Onsite Parking", "Intercom", "Cable and Satellite TV", "Parking (Complimentary)", "Lobby", "Bathroom Amenities", "Major Credit Cards Accepted", "FREE PARKING FACILITIES", "Free Wifi", "Payment by Credit Card accepted", "Room Service(Limited Hours)", "Lift / Elevator", "Doctor on Call", "Parking", "CCTV", "Hot Water", "Room Service", "Daily Housekeeping", "Breakfast", "Parking Facilities Available", "Free WiFi", "Internet Access ", "Television ", "Reception ", "Free Internet Access ", "Complimentary Breakfast", "Power Backup" ], "hotWater": true, "hotelAddress": "247, No 247/1, Tirupati", "hotelName": "OYO 19985 Seven Hills Inn", "images": [ { "title": "1 Classic-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-1-classic-room-151692481421-orijgp.jpg" }, { "title": "2 Classic-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-2-classic-room-151692488972-orijgp.jpg" }, { "title": "3 Classic-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-3-classic-room-151692499562-orijgp.jpg" }, { "title": "4 Classic-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-4-classic-room-152375114340-orijgp.jpg" }, { "title": "5 Classic-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-5-classic-room-152375125005-orijgp.jpg" }, { "title": "6 Classic-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-6-classic-room-151692509566-orijgp.jpg" }, { "title": "7 Deluxe-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-7-deluxe-room-151692422418-orijgp.jpg" }, { "title": "8 Deluxe-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-8-deluxe-room-152375136415-orijgp.jpg" }, { "title": "9 Deluxe-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-9-deluxe-room-151692522467-orijgp.jpg" }, { "title": "10 Deluxe-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-10-deluxe-room-152375148527-orijgp.jpg" }, { "title": "11 Deluxe-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-11-deluxe-room-151692428369-orijgp.jpg" }, { "title": "12 Deluxe-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-12-deluxe-room-151692432078-orijgp.jpg" }, { "title": "13 Saver Double-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-13-saver-double-room-152375158538-orijgp.jpg" }, { "title": "14 Saver Double-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-14-saver-double-room-152377550075-orijgp.jpg" }, { "title": "15 Saver Double-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-15-saver-double-room-151692530477-orijgp.jpg" }, { "title": "16 Saver Double-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-16-saver-double-room-151692440848-orijgp.jpg" }, { "title": "19 Reception", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-19-reception-152377565157-orijgp.jpg" }, { "title": "22 Lobby", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-22-lobby-152377578464-orijgp.jpg" }, { "title": "24 Corridor", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-24-corridor-152377584993-orijgp.jpg" }, { "title": "25 Lift", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-25-lift-152377595398-orijgp.jpg" }, { "title": "23__Food", "url": "https://cdn1.goibibo.com/t_g/oyo-19985-seven-hills-inn-tirupati-23__food-152377576019-orijgp.jpg" }, { "title": "18 Facade", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-18-facade-152377558132-orijgp.jpg" }, { "title": "17 Facade", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-17-facade-152377555296-orijgp.jpg" }, { "title": "26 Washroom", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-26-washroom-151692448060-orijgp.jpg" }, { "title": "27 Washroom", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-27-washroom-152377605870-orijgp.jpg" }, { "title": "28 Washroom", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-28-washroom-151692457473-orijgp.jpg" }, { "title": "29 Washroom", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-29-washroom-151692463955-orijgp.jpg" }, { "title": "1 Classic-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-1-classic-room-151692540445-orijgp.jpg" }, { "title": "2 Classic-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-2-classic-room-151692550107-orijgp.jpg" }, { "title": "5 Classic-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-5-classic-room-152375168150-orijgp.jpg" }, { "title": "6 Classic-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-6-classic-room-151692470717-orijgp.jpg" }, { "title": "27 Washroom", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-27-washroom-152375175375-orijgp.jpg" }, { "title": "9 Deluxe-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-9-deluxe-room-152450215117-orijgp.jpg" }, { "title": "8 Deluxe-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-8-deluxe-room-153508304246-orijgp.jpg" }, { "title": "7 Deluxe-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-7-deluxe-room-152452737202-orijgp.jpg" }, { "title": "10 Deluxe-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-10-deluxe-room-153508311252-orijgp.jpg" }, { "title": "28 Washroom", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-28-washroom-152450225818-orijgp.jpg" }, { "title": "15 Saver Double-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-15-saver-double-room-152450234105-orijgp.jpg" }, { "title": "14 Saver Double-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-14-saver-double-room-153508316835-orijgp.jpg" }, { "title": "13 Saver Double-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-13-saver-double-room-153508323575-orijgp.jpg" }, { "title": "16 Saver Double-Room", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-16-saver-double-room-152450241037-orijgp.jpg" }, { "title": "28 Washroom", "url": "https://cdn1.goibibo.com/t_fs/oyo-19985-seven-hills-inn-tirupati-28-washroom-152450111785-orijgp.jpg" } ], "reviewCount": 52, "roomType": "Shared Room", "star": 3, "userRating": 3.6 } }, { "time": 630, "title": "Breakfast", "description": "Have breakfast at the hotel restaurant", "tag": "food", "data": { "food_incl_package": "Yes", "meal_desc": "Buffet breakfast comprising Idli, Wada, Upma, Kesari Bhath, Chutney, Sambhar, Tea & Coffee", "meal_serve_type": "Buffet", "meal_timing_end": 700, "meal_timing_start": 600, "meal_type": "Breakfast" } }, { "time": 730, "title": "Padmavathi Temple and Balaji Temple Darshan", "description": "Proceed for darshan at Padmavathi Temple followed by Balaji Temple Darshan at Tirumala", "tag": "activity", "data": { "activity_desc": "", "activity_incl_package": "", "activity_timing_end": 1300, "activity_timing_start": 730, "activity_title": "", "activity_type": "" } } ] ], "inclusions": [ { "key": 4, "value": "Porter Not covered" } ], "exclusions": [ { "key": 1, "value": "Wifi" } ], "termsAndCondition": [ "t1", "t2" ], "dressCode": [ "formal", "ethnic" ], "tripRoute": [ { "city": "Bangalore", "offset": 0 }, { "city": "Tirupathi", "offset": 1 }, { "city": "Bangalore", "offset": 1 } ] }, "message": "Record Fetched", "success": true }';
            }else{
                jsonBody = response.getBody();
            }
            jsonBody=jsonBody.replace('"time":', '"time_x":');
            bwr = (busCWrapper)JSON.deserialize(jsonBody, busCWrapper.class); 
            System.debug('bwr 3-->'+bwr.data.bo_name);
        }
        Catch(Exception e)
        {
        } 
        return null;        
    }
    public class busCWrapper{      
        public data_warpper data{get;set;}
        public busCWrapper(){
            
        }
    }
    public class data_warpper{
        public string bo_name{get;set;}
        public string durationNights{get;set;}
        public List<List<details_wrapper>> details{get;set;}
        public List<Inclusions_wrapper> inclusions{get;set;}
        public List<Exclusions_wrapper> exclusions{get;set;}
        public List<string>  termsAndCondition{get;set;}
        public List<string> dressCode{get;set;}
    }
    public class details_wrapper{
        public string time_x{get;set;}
        public string title{get;set;}
        public string description{get;set;}
        public string tag{get;set;}
        public data_dw data{get;set;}
    }
    public class data_dw{
        public string arrival_time{get;set;}
        public string bo_name{get;set;}
        public string bus_type{get;set;}
        public string departure_time{get;set;}
        public string ac{get;set;}
        public string hotelAddress{get;set;}
        public string hotelName{get;set;}
        public string roomType{get;set;}
        public string star{get;set;}
        public string userRating{get;set;}
        public string food_incl_package{get;set;}
        public string meal_desc{get;set;}
        public string meal_serve_type{get;set;}
        public string meal_timing_end{get;set;}
        public string meal_timing_start{get;set;}
        public string meal_type{get;set;}
        public string activity_desc{get;set;}
        public string activity_incl_package{get;set;}
        public string activity_timing_end{get;set;}
        public string activity_timing_start{get;set;}
        public string activity_title{get;set;}
        public string activity_type{get;set;}   
    }
    public class Inclusions_wrapper{
        public string key{get;set;}
        public string value{get;set;}
    }
    public class Exclusions_wrapper{
        public string key{get;set;}
        public string value{get;set;}
    }
}