@isTest
public class SaftyImageModerationTest {
    
    @istest static void methodToTest(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        map<string,string>  boIds = SaftyImageModeration.GetBOIds('IND');
        saftyImageModeration.getImages('1234');
        List<string> approveIdList= new List<string>();
        approveIdList.add('aBcDeF');
        approveIdList.add('gHiJkL');

        string rejData='[{"value":"ABCD","label":"Test Class"},{"value":"EFGH","label":"Test Class"}]';
        string result = SaftyImageModeration.UpdateImageInformation('1234','IND','2',approveIdList,rejData);
        test.stopTest();
    }
        public class ImageDetailsWrapper{
        public string ImageURL{get;set;}
        public string Status{get;set;}
        public string ImageTag{get;set;} 
        public string ImageId{get;set;}
        public string BusTypeId{get;set;}
        public string BusType{get;set;}
        public string selType{get;set;}
        
    }

}