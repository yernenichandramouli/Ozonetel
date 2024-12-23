import { LightningElement, track } from 'lwc';
import GetBOIds from '@salesforce/apex/SaftyImageModeration.GetBOIds';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GetImages from '@salesforce/apex/SaftyImageModeration.getImages';
import updatedImage from '@salesforce/apex/SaftyImageModeration.UpdateImageInformation';
export default class SaftyImageModeration extends LightningElement {
@track RegionOptions=[
            {label:'India', value:'IND'}
          ];
@track newStsOpts=[
                  {label:'--None--', value:''},
                  {label:'Approve', value:'Approve'},
                  {label:'Reject', value:'Reject'}
                  ];
@track rejOpts=[
//                    {label:'--None--', value:''},
                    {label:'Duplicate', value:'Duplicate'},
                    {label:'similar', value:'similar'},
                    {label:'Does not match with the tag', value:'Does not match with the tag'},
                    {label:'Others', value:'Others'}
               ];                  
@track AppStsOpts=[
                  {label:'--None--', value:''},
                  {label:'Reject', value:'Reject'}
                  ];
@track RejStsOpts=[
                  {label:'--None--', value:''},
                  {label:'Approve', value:'Approve'}
                  ];  

@track statusOptns=[];
@track busOpIds=[];    
@track RejectedImages=[];  
@track selRegion='IND';  
@track MapOfIds=[];    
@track BoId=''; 
@track busTypes=[];  
@track busType='';
@track imageData= [];  
@track showimages=false; 
@track activeSection='New'; 
@track ApprovedImages=[];
@track NewImages=[];
@track approveIds=[];
@track rejectIds=[];
@track singleImage;
@track showSpinner = false;
@track error = false;
@track rejectOpts=[];
@track rejIdsMap =[];
connectedCallback() {
GetBOIds({
country:this.selRegion
})
.then(data=>{
  console.log('<<<boIds:'+JSON.stringify(data));
for(let key in data) {       
  if (data.hasOwnProperty(key)) { // Filtering the data in the loop
    this.MapOfIds.push({value:data[key]+'-'+key, key:key});
}   
}
this.busTypes = [...this.busTypes ,{value: '' , label: '--None--'} ];
this.busOpIds = [...this.busOpIds ,{value: '' , label: '--None--'} ];
if(this.MapOfIds != null && this.MapOfIds != []){
for(var i=0;i<this.MapOfIds.length;i++){
  this.busOpIds = [...this.busOpIds ,{value: this.MapOfIds[i].key , label: this.MapOfIds[i].value} ];
}  
}
})
}
handleBOIdChange(event){
this.BoId= event.target.value;
this.showimages = false;
this.busTypes=[];
this.busType='';
this.imageData =[];
this.singleImage='';
this.approveIds=[];
this.rejectIds=[];
this.ApprovedImages =[];
this.NewImages=[];
this.RejectedImages=[];
GetImages({
  boId:this.BoId
})
.then(data=>{
  console.log(JSON.stringify(data));
  this.busTypes=[];
  this.busType='';
  this.imageData = data;
  this.busTypes = [...this.busTypes ,{value: '' , label: '--None--'} ];
  if(data != null && data != []){
    for(var i=0; i<data.length; i++){
      if(this.busTypes != null && this.busTypes !=[]){
        var isExist = false;
        for(var j = 0; j<this.busTypes.length && j<=i; j++){
          if(this.busTypes[j].value == data[i].BusTypeId){
            isExist = true;
          }
        }
        if(isExist == false)
        this.busTypes = [...this.busTypes ,{value: data[i].BusTypeId , label: data[i].BusType} ];
      }  
    }
  } 
})
}
handleBusTypeChange(event){
this.busType = event.target.value;
this.singleImage='';
this.approveIds=[];
this.rejectIds=[];
this.ApprovedImages =[];
this.NewImages=[];
this.RejectedImages=[];
this.showimages= true;

if(this.busType != '' && this.imageData != null && this.imageData != []){
this.showimages = true;
  for(var i=0; i<this.imageData.length; i++){
if(this.imageData[i].BusTypeId == this.busType){
  this.singleImage = this.imageData[i];
  this.singleImage.selType ='';
  this.singleImage.isReject = false;
  this.singleImage.isOthers= false;
  if(this.singleImage.ImageTag == 'Sanitize')
    this.singleImage.ImageTag = 'Deep Clean - Spray';
  else if(this.singleImage.ImageTag == 'HanWip')
    this.singleImage.ImageTag = 'Handles Wiped';
  else if(this.singleImage.ImageTag == 'DrivMask')
    this.singleImage.ImageTag = 'Driver/Helper Mask & Temperature Check';
  else if(this.singleImage.ImageTag == 'HandSani')
    this.singleImage.ImageTag = 'Hand Sanitizer at Boarding';
  else if(this.singleImage.ImageTag == 'SDONBoard')
    this.singleImage.ImageTag = 'Social Distancing at Boarding';
  else if(this.singleImage.ImageTag == 'TempCheck')
    this.singleImage.ImageTag = 'Passenger Mask & Temperature Check';
  else if(this.singleImage.ImageTag == 'SDINBUS')
    this.singleImage.ImageTag == 'Social Distancing in Bus';
  else if(this.singleImage.ImageTag == 'SafePack') 
    this.singleImage.ImageTag == 'Safety Pack Amenity in Bus';

  
  if(this.imageData[i].Status == 'NEW'){
    this.singleImage.reason='Duplicate';
    this.NewImages.push(this.singleImage);
  }
  else if(this.imageData[i].Status == 'APPROVED'){
    this.singleImage.reason='Duplicate';
    this.ApprovedImages.push(this.singleImage);
  }
  else if(this.imageData[i].Status == 'REJECTED'){
    this.singleImage.isReject = true;
    this.singleImage.reason = this.imageData[i].RejectedReason;
    this.RejectedImages.push(this.singleImage);
  }
}
}
}
}
handleStatusChange(event){
/*
  for(var i=0; i<this.imageData.length;i++){
    if(this.imageData[i].ImageId == event.target.dataset.item){
      if(event.target.value ==''){
        this.imageData.isChanged = false;
        this.imageData.Status ='';
        this.imageData.isReject=false;
        this.imageData.isOthers=false;
      }
      else if(event.target.value =='Approve'){
        this.imageData.isChanged = true;
        this.imageData.Status= event.target.value;
      }
      else if(event.target.value=='Reject')
      this.imageData.isChanged = true;
      this.imageData.Status= event.target.value;
      }
  }*/
  for(var i=0;i<this.rejectIds.length;i++){
    if(this.rejectIds[i]== event.target.dataset.item){
      this.rejectIds[i]='';
      break;
    }
  }
  for(var i=0;i<this.approveIds.length;i++){
    if(this.approveIds[i]== event.target.dataset.item){
      this.approveIds[i]='';
      break;
    }
  }

  if(event.target.value == ''){
     
    if(this.activeSection == 'Approved'){
      for(var i =0 ;i<this.ApprovedImages.length;i++){
        if(this.ApprovedImages[i].ImageId == event.target.dataset.item){
          this.ApprovedImages[i].isReject = false;
          this.ApprovedImages[i].reason='Duplicate';
          this.ApprovedImages[i].isOthers= false;
           break;
        }
      } 
    }
    else if(this.activeSection =='New'){
      for(var i =0 ;i<this.NewImages.length;i++){
        if(this.NewImages[i].ImageId == event.target.dataset.item){
          this.NewImages[i].isReject = false;
          this.NewImages[i].reason='Duplicate';
          this.NewImages[i].isOthers=false;
          break;
        }
      }
    }  
  }  
  if(event.target.value == 'Approve'){ 
    if(this.approveIds != null && this.approveIds != []){
      var size = this.approveIds.length;
      this.approveIds[size]= event.target.dataset.item;    
    }
    else
      this.approveIds[0]= event.target.dataset.item;
    for(var i=0;i<this.rejectIds.length;i++){
      if(this.rejectIds[i]== event.target.dataset.item)
        this.rejectIds[i]='';
      break;
    }
    if(this.activeSection == 'Rejected'){
      for(var i =0 ;i<this.ApprovedImages.length;i++){
        if(this.ApprovedImages[i].ImageId == event.target.dataset.item){
          this.ApprovedImages[i].isReject = false;
          this.ApprovedImages[i].isOthers= false;
          this.ApprovedImages[i].reason='Duplicate';
           break;
        }
      } 
    }
    else if(this.activeSection =='New'){
      for(var i =0 ;i<this.NewImages.length;i++){
        if(this.NewImages[i].ImageId == event.target.dataset.item){
          this.NewImages[i].isReject = false;
          this.NewImages[i].isOthers=false;
          this.NewImages[i].reason='Duplicate';
          break;
        }
      }
    }
   }
  if(event.target.value == 'Reject'){
    if(this.rejectIds != null && this.rejectIds != []){
      var size = this.rejectIds.length;
      this.rejectIds[size]= event.target.dataset.item;    
    }
    else
      this.rejectIds[0]= event.target.dataset.item;
    for(var i=0;i<this.approveIds.length;i++){
      if(this.approveIds[i]== event.target.dataset.item)
        this.approveIds[i]='';
      break; 
    }
    if(this.activeSection == 'Approved'){
      for(var i =0 ;i<this.ApprovedImages.length;i++){
        if(this.ApprovedImages[i].ImageId == event.target.dataset.item){
          this.ApprovedImages[i].isReject = true;
          break;
        }
      } 
    }
    else if(this.activeSection =='New'){
      for(var i =0 ;i<this.NewImages.length;i++){
        if(this.NewImages[i].ImageId == event.target.dataset.item){
          this.NewImages[i].isReject = true;
          break;
        }
      } 
    }
  }
}
handleUpdate(event){
if(this.approveIds.length ==0 && this.rejectIds.length ==0){
const evt = new ShowToastEvent({
    message: 'Please select status',
    variant: 'error',
    mode: 'dismissable'
});
this.dispatchEvent(evt);
}
else{
  if(this.approveIds.length>0 || this.rejectIds.length>0 ){
    this.error = true;
    if(this.approveIds.length>0){
      for(var i =0; i<this.approveIds.length; i++){
        if(this.approveIds[i] != '' )
          this.error = false;
          break;  
      }
    }
    if(this.error == true){
      if(this.rejectIds.length>0){
        for(var j=0; j<this.rejectIds.length; j++){
          if(this.rejectIds[j] != ' ')
            this.error = false;
          break;  
        }
      }
    }
    if(this.error == true){
        const evt = new ShowToastEvent({
        message: 'Please select status',
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
  
    }
    else{
      this.showSpinner = true;
      var rejMap=JSON.stringify(this.rejIdsMap);
      updatedImage({ 
        boId:this.BoId,
        country:this.selRegion,
        bustypeId:this.busType,
        approveIds:this.approveIds,
        rejectIds1:rejMap
      }).then(data=>{
        if(data == 'success'){
          GetImages({
            boId:this.BoId
          })
        .then(data=>{
          console.log(JSON.stringify(data));
          if(data != null && data != []){
            this.imageData =[];
            this.imageData = data;
            this.singleImage='';
            this.approveIds=[];
            this.rejectIds=[];
            this.ApprovedImages =[];
            this.RejectedImages=[];
            this.NewImages=[];
            this.rejIdsMap=[];
            rejMap ='';
            for(var i=0; i<this.imageData.length; i++){
              if(this.imageData[i].BusTypeId == this.busType){
                this.singleImage = this.imageData[i];
                this.singleImage.selType ='';
                this.singleImage.isReject = false;
                this.singleImage.isOthers= false;              
                if(this.singleImage.ImageTag == 'Sanitize')
                this.singleImage.ImageTag = 'Deep Clean - Spray';
              else if(this.singleImage.ImageTag == 'HanWip')
                this.singleImage.ImageTag = 'Handles Wiped';
              else if(this.singleImage.ImageTag == 'DrivMask')
                this.singleImage.ImageTag = 'Driver/Helper Mask & Temperature Check';
              else if(this.singleImage.ImageTag == 'HandSani')
                this.singleImage.ImageTag = 'Hand Sanitizer at Boarding';
              else if(this.singleImage.ImageTag == 'SDONBoard')
                this.singleImage.ImageTag = 'Social Distancing at Boarding';
              else if(this.singleImage.ImageTag == 'TempCheck')
                this.singleImage.ImageTag = 'Passenger Mask & Temperature Check';
              else if(this.singleImage.ImageTag == 'SDINBUS')
                this.singleImage.ImageTag == 'Social Distancing in Bus';
              else if(this.singleImage.ImageTag == 'SafePack') 
                this.singleImage.ImageTag == 'Safety Pack Amenity in Bus';
 
                if(this.imageData[i].Status == 'NEW'){
                  this.singleImage.reason='Duplicate';
                  this.NewImages.push(this.singleImage);
                }
                else if(this.imageData[i].Status == 'APPROVED'){
                  this.singleImage.reason='Duplicate';
                  this.ApprovedImages.push(this.singleImage);
                }
                else if(this.imageData[i].Status == 'REJECTED'){
                  this.singleImage.isReject = true;
                  this.singleImage.reason = this.imageData[i].RejectedReason;
                  this.RejectedImages.push(this.singleImage);
                }
                }
            }
            this.showSpinner = false;
            const evt = new ShowToastEvent({
            message: 'Images are updated Successfully. Operator id->'+this.BoId,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    
        } 
        else{
          this.showSpinner = false;
          const evt = new ShowToastEvent({
            message: 'Images are updated Successfully. Operator id->'+this.BoId+'.Please relaod the page',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    
        }
      
        }) 
        }else{
          this.showSpinner = false;
          const evt = new ShowToastEvent({
            message: 'Update Failed!! Please try again/contact Admin',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        }
      })
    }  
  }
}
}
handleSectionToggle(event){
  this.activeSection = event.detail.openSections;
}
handleRejectOptChange(event){
 if(event.target.value == 'Others'){
  if(this.activeSection =='New' ){
    for(var i =0; i<this.NewImages.length; i++){
      if(event.target.dataset.item == this.NewImages[i].ImageId){
        this.NewImages[i].isOthers=true;
        break;
      }
    } 
  }
  else if(this.activeSection =='Approved'){
    for(var i =0; i<this.ApprovedImages.length; i++){
      if(event.target.dataset.item == this.ApprovedImages[i].ImageId){
        this.ApprovedImages[i].isOthers=true;
        break;
      }
    }  
  } 
 }
 else{
  if(this.activeSection =='New' ){
    for(var i =0; i<this.NewImages.length; i++){
      if(event.target.dataset.item == this.NewImages[i].ImageId){
        this.NewImages[i].reason=event.target.value;
        this.NewImages[i].isOthers = false;
        this.rejIdsMap = [...this.rejIdsMap ,{value: event.target.dataset.item , label: event.target.value} ];
        break;
      }
    }    
  }
  else if(this.activeSection =='Approved'){
    for(var i =0; i<this.ApprovedImages.length; i++){
      if(event.target.dataset.item == this.ApprovedImages[i].ImageId){
        this.ApprovedImages[i].reason=event.target.value;
        this.ApprovedImages[i].isOthers = false;
        this.rejIdsMap = [...this.rejIdsMap ,{value: event.target.dataset.item , label: event.target.value} ];
        break;
      }
    }  
  }
 } 
}
handleRejOtherReason(event){
  var isAdded = false;
  if(this.rejIdsMap.length <1){
    this.rejIdsMap = [...this.rejIdsMap ,{value: event.target.dataset.item , label: event.target.value} ];
  }
  else{
    for (var i =0; i<this.rejIdsMap.length ;i++){
      if(this.rejIdsMap[i].value == event.target.dataset.item){
        this.rejIdsMap[i].label= event.target.value;
        isAdded = true;
        break;
      }
    }
    if(isAdded != true){
      this.rejIdsMap = [...this.rejIdsMap ,{value: event.target.dataset.item , label: event.target.value} ];
    } 
  }
}
}