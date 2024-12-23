({    
    init: function (cmp, event, helper) {
        var options = [];
        var adList = [];
        var action = cmp.get("c.getBoardingPoints"); 
        action.setParams({
            "bp" : cmp.get("v.bp"),
            "dp" : cmp.get("v.dp"),
            "doj" : cmp.get("v.doj")           
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res= [];
                if(response.getReturnValue() != null && response.getReturnValue().length > 0){
                    res = response.getReturnValue();   
                    for (var step = 0; step<res.length; step++){
                        var option = {"value":res[step].locationId.toString(), "label":res[step].locationName };                 
                        options.push(option);
                        var bp = {"locationId":res[step].locationId.toString(),"locationName":res[step].locationName,"BpAddress":res[step].BpAddress};
						adList.push(bp);
                    }                    
                    cmp.set("v.boardingPoints", options);
                    cmp.set("v.bpList",adList);
                    
                    
                }else{
                    cmp.set("v.showErrors",true);
                    cmp.set("v.errorMessage",'No Boarding Points Found ');
                }

            }else{
                var errors = response.getError();                       
                cmp.set("v.showErrors",true);
                cmp.set("v.errorMessage",errors[0].message);
            }            
        });        
        $A.enqueueAction(action);  
    },
    onChange: function (cmp, evt, helper) {
        var selectedvalue = evt.getParam("value");
        if (selectedvalue != cmp.get("v.selectedBp")){
            cmp.set("v.showErrors",false);
            cmp.set("v.errorMessage",' ');
            cmp.set("v.buses", []);
        }
        cmp.set("v.selectedBp", selectedvalue);
        var resData = cmp.get("v.bpList");
		var bplen = resData.length;
		for(var count = 0; count<bplen; count++){
            if(selectedvalue == resData[count].locationId.toString() ){
               	cmp.set("v.boardingAddress",resData[count].BpAddress); 	
				break;
            }
        }
        var action = cmp.get("c.getBusesDetails"); 
        action.setParams({
            "bp" : cmp.get("v.bp"),
            "dp" : cmp.get("v.dp"),
            "selectedbp" :cmp.get("v.selectedBp"),
            "doj" : cmp.get("v.doj")
        });
        action.setCallback(this, function(response) {
            console.log('response...'+JSON.stringify(response));
            var state = response.getState();
            console.log('State...'+state);
            if (state === "SUCCESS") {
                var res= [];
                if(response.getReturnValue() != null && response.getReturnValue().length > 0 ){
                    res = response.getReturnValue();   
                    var buses = [];
                    for (var count = 0; count<res.length; count++){
                      //  if(res[count].p42.FlexiTicket && res[count].p42.BpDp == "Exact" && res[count].p42.Eta != -1 )
                         if(res[count].p42.FlexiTicket)
                        
                        {
                            buses.push(res[count]);
                        }	

                    }
                    if(buses.length<1){
                            cmp.set("v.showErrors",true);
                            cmp.set("v.errorMessage",'No Buses Found on Mentioned Selections');         
                    }
                    cmp.set("v.buses", buses);
                }
                else{
                    cmp.set("v.showErrors",true);
                    cmp.set("v.errorMessage",'No Buses Found on Mentioned Selections');                    
                }
            }
            else{
                var errors = response.getError();                       
                cmp.set("v.showErrors",true);
                cmp.set("v.errorMessage",errors[0].message);
                system.debug("<<errors"+response.getError());
            }            
        });        
        $A.enqueueAction(action);  
    },
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
   },
    
    hideSpinner : function(component,event,helper){
       component.set("v.Spinner", false);
    }
})