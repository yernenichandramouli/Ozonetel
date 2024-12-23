import { LightningElement, wire, track } from 'lwc';
import fatchPickListValue from '@salesforce/apex/SafetyImageApprovalController.getAllTransactions';
import fetchAllTransactions from '@salesforce/apex/SafetyImageApprovalController.getAllTransactions';
import updateStatus from '@salesforce/apex/SafetyImageApprovalController.updatestatus';
import getImages from '@salesforce/apex/SafetyImageApprovalController.GetImages';


export default class SafetyImageApproval extends LightningElement {
    @track imgLoad = false;
    @track trnsLoad = false;
    @track searchLoad = false;
    @track tranSelLoad = false;
    @track updateLoad = false;
    @track showUpdMsg = false;
    @track notifType;
    @track notifMsg;
    @track imageValues;
    @track doj;
    @track imageVal = 'https://ugc-dynamic-tags.s3-ap-southeast-1.amazonaws.com/CovidAudit/71e94fb2a76ff0055722993402020100_2_0_socialdistance.png';
    @track tranIds = [];
    @track selUpImages = [];
    @track locStrg;
    @track locVarb;
    @track imgMap = {};
    @track tranSize;
    //  @wire(fatchPickListValue) tranIds;
    onValueSelection(event) {
        // eslint-disable-next-line no-alert
        console.log('sel value-->' + event.target.value);
        this.imgMap = {};
        this.tranSelLoad = true;
        getImages({ uuId: event.target.value })
            .then(result => {
                console.log('type of result..' + result);
                console.log('type of result..dd' + JSON.stringify(result));
                this.imageValues = result;
                this.tranSelLoad = false;
                this.imgLoad = true;
                for (var trn in this.imageValues) {
                    console.log('trt-->' + this.imageValues[trn].imageId);
                    this.imgMap[this.imageValues[trn].imageId] = this.imageValues[trn].status;
                }

                console.log('img map sel-->' + JSON.stringify(this.imgMap));
            })
            .catch(error => {
                this.imgLoad = false;
                this.tranSelLoad = false;
                // eslint-disable-next-line no-console
                console.log('exception e..' + error);

            });
    }

    selectedDoj(event) {
        this.doj = event.target.value;
        console.log('sel doj-->' + this.doj);
        console.log('sel doj val-->' + event.target.value);
    }

    selDoj() {
        console.log('doj-->' + this.doj);
        this.searchLoad = true;
        fetchAllTransactions({ doj: this.doj })
            .then(result => {
                console.log('type of result..' + result);
                console.log('type of result..dd' + JSON.stringify(result));
                this.tranIds = result;
                console.log('tranIds-->' + this.tranIds);
                this.tranSize = this.tranIds.length;

                this.searchLoad = false;
                this.trnsLoad = true;
            })
            .catch(error => {
                this.trnsLoad = false;
                this.searchLoad = false;
                // eslint-disable-next-line no-console
                console.log('exception e..' + error);

            });
    }
    handleSelectedImage(event) {
        console.log('value-->' + event.target.value);
        console.log('key-->' + event.target.dataset.id);
        localStorage.setItem(event.target.dataset.id, event.target.value);
        console.log('localStorage-->' + JSON.stringify(localStorage));
        this.selUpImages.push(event.target.dataset.id + ':' + event.target.value);
        console.log('selUpImages-->' + this.selUpImages);
        this.imgMap[event.target.dataset.id] = event.target.value;
        this.locVarb = this.locVarb + '"' + event.target.dataset.id + '":"' + event.target.value + '",';
        //this.locVarb = this.locVarb + event.target.value;
        console.log('loc varb-->' + this.locVarb);
        console.log('img Map-->' + this.imgMap);
        console.log('img Map str-->' + JSON.stringify(this.imgMap));

    }
    handleUpdate(event) {
        console.log('this.locVarb-->' + this.locVarb);
        console.log('img Map Up-->' + this.imgMap);
        console.log('img Map str Up-->' + JSON.stringify(this.imgMap));
        this.updateLoad = true;
        var jsStr = JSON.stringify(this.imgMap);
        if (jsStr.includes("NEW")) {
            console.log('came new here');
            this.updateLoad = false;
            this.showUpdMsg = true;
            this.notifType = 'error';
            this.notifMsg = 'All Images has to be either Approved/Rejecte! Please update all Images status.';

        } else {

            /*  console.log('event-->' + JSON.stringify(event));
              console.log('event target-->' + JSON.stringify(event.target));
              console.log('det-->' + event.detail);
              console.log('det JS-->' + JSON.stringify(event.detail));
              console.log('chv-->' + event.target.value);
              console.log('chn-->' + event.target.key);
              console.log('key-->' + event.target.dataset.id);
      
              console.log('key-->' + JSON.stringify(event.target.dataset));
              console.log('imageValues-->' + this.imageValues);
              console.log('imageValues-->' + JSON.stringify(this.imageValues));*/

            updateStatus({ imgUpStr: jsStr })
                .then(result => {
                    console.log('type of result..' + result);
                    console.log('type of result..dd' + JSON.stringify(result));
                    this.updateLoad = false;
                    this.showUpdMsg = true;
                    this.imgMap = {};
                    if (result == 'New') {
                        this.notifType = 'error';
                        this.notifMsg = 'All Images has to be either Approved/Rejecte! Please update all Images status.';
                    }
                    else if (result == 'Success') {
                        this.notifType = 'success';
                        this.notifMsg = 'Successfully Images Updated';
                    } else {
                        this.notifType = 'error';
                        this.notifMsg = 'Something went wrong. Please try again!!';
                    }
                })
                .catch(error => {
                    // eslint-disable-next-line no-console
                    this.updateLoad = false;
                    this.notifType = 'error';
                    this.notifMsg = 'Failed to Update Images. Please try again!!';
                    console.log('exception e..' + error);

                });
        }
    }
    sendId(e) {
        console.log(e);
    }

}