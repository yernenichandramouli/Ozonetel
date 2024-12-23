import { LightningElement,api, track,wire } from 'lwc';
import getAdditionDtlsInfo from '@salesforce/apex/CargoservicesCntrl.GetAdditionalDetails';
export default class ExtraDetailsCargo extends LightningElement {
  @api recordId;
  objectData;

  @track senderDetailsObject;
  @track receiverDetailsObject;
  @track parcelDetailsOject;
  @track bpDetailsObject;
  @track dpDetailsObject;

 connectedCallback() {
    console.log('--test--');
    this.getAdditionalDetail();
  }

getAdditionalDetail(){
    console.log('>>>additionalDetails>>>');
    getAdditionDtlsInfo({ ItemId: this.recordId })
      .then((result) => {
     console.log('>result>'+result);
        if (result ==='No Additional Details found' ){ 
            }else{
              const jsonDat = JSON.parse(result);
             // this.jsonString = jsonData.senderDetails;
              this.senderDetailsObject = JSON.stringify(jsonDat.senderDetails);
              this.receiverDetailsObject = JSON.stringify(jsonDat.receiverDetails);
              this.parcelDetailsObject  =  JSON.stringify(jsonDat.parcelDetails);
              this.dpDetailsObject  = JSON.stringify(jsonDat.dp);
              this.bpDetailsObject  = JSON.stringify(jsonDat.bp);
              console.log('>>snderJson>>>'+this.senderDetailsObject);

            } 
    })
    .catch((error) => {
      this.isLoading = false;
      console.error('Error: \n ', error);
    });
}

}