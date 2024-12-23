/**
* (c) 2018 RedBus
*
* Name           : RandomGeneric
* Created Date   : 19 Feb 2023
* Created By     : Sreenivas M
* Purpose        : Generic class to get random number/records etc
* Githublink     : https://github.com/bruce-tollefson/listrandomizer
**/

public class RandomGeneric {

    private List<Object> startingList;
    private List<Object> placementList = new List<Object>();//list of randomized object records
    
    public RandomGeneric(List<Object> listToRandomize){
        this.startingList = listToRandomize;
    }
    
    public object getRandomRecord(){
        Integer sizeOfList = this.startingList.size();
        Integer randomIndex = getRandomInteger(sizeOfList-1);//index starts at 0 size needs to be decreased then get the random number
        return startingList[randomIndex];
    }
    
    public List<Object> getNumberOfRandomRecords(Integer i){
        //check for dirty list
        checkPlacementList();
        
        List<Integer> randomRecordIndexes = new List<Integer>();
        checkIntegerGreaterThanZero(i);
        for(Integer x = 0; x < i; x++){
            Integer startingListMaxIndex = this.startingList.size() - 1;
            Integer randomIndex = getRandomInteger(startingListMaxIndex);//get Integer
            randomIndex = checkIntegerInList(randomRecordIndexes, randomIndex, startingListMaxIndex);//Check integer
            placementList.add(startingList[randomIndex]);
            randomRecordIndexes.add(randomIndex);
        }
        return placementList;
    }
    
    public List<Object> getNumberOfRandomRecordsWithinInterval(Integer i){
        //check for dirty list
        checkPlacementList();
        
        checkIntegerGreaterThanZero(i);
        Decimal sizeOfList = startingList.size();
        Integer intervalSize = Integer.valueOf((sizeOfList / Decimal.ValueOf(i)).round(System.RoundingMode.CEILING));//this is the celing but could also be the DOWN or in that case INT / INT gets the whole number after the division
        for(Integer x = i;x-- > 0; ){

            Integer randomIndex;
            if(x != 0){
                randomIndex = getRandomInteger(intervalSize) + (Integer.ValueOf(sizeOfList) - intervalSize*x);//segment
            }else{
                randomIndex = getRandomInteger(Integer.ValueOf(sizeOfList) - intervalSize*(i-1));//remaining segment
            }
            system.debug(randomIndex);
            placementList.add(startingList[randomIndex]);
        }
        
        return placementList;
    }
    
    private void checkPlacementList(){
        if(this.placementList.size() > 0) this.placementList.clear(); //if placement list was already used clear it
    }
    
    private Integer getRandomInteger(Integer i){
        checkIntegerGreaterThanZero(i);
        return Integer.valueOf(i*Math.random());//Math.random gets a random number from 0-1 multiplied by a number and you get a random number with the multiplied number as the Max value
    }
    
    private Integer checkIntegerInList(List<Integer> intList, Integer checkInt, Integer maxInt){ //checks to see if the integer is in the list, if not then returns the Integer, if it is then create a new one ***RECURSIVE***
        if(intList.contains(checkInt)){
            Integer newRandomInt = getRandomInteger(maxInt);
            checkIntegerInList(intList, newRandomInt, maxInt);
        }
        
        return checkInt;
    }
    
    private void checkIntegerGreaterThanZero(Integer i){
        if(i <= 0) throw new RandomizedListException('Integer must be greater than 0');
    }
    
    private class RandomizedListException extends Exception{}
}