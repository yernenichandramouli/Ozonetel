import { LightningElement, track, wire, api} from 'lwc';
import GetCases from '@salesforce/apex/BoltAppValidationCntrl.getCases';  
import CreateCaseComment from '@salesforce/apex/BoltAppValidationCntrl.InsertComments';
import GetBoltVlidationLevel from '@salesforce/apex/BoltAppValidationCntrl.getBoltValidationLevels';
import GetMaxRefundAmount from '@salesforce/apex/BoltAppValidationCntrl.getMaxRefundAmountApi';
import insertCommentsCall from '@salesforce/apex/BoltAppValidationCntrl.InsertQuestionValuesComments';
import driverDetails from '@salesforce/apex/BoltAppValidationCntrl.getDriverDetails';
import updateBoltStatusinCase from '@salesforce/apex/BoltAppValidationCntrl.updateRecordwithBoltValidationStatus';
import getListCaseComments from '@salesforce/apex/BoltAppValidationCntrl.getCaseCommentsList';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';


export default class BoltAppValidation extends LightningElement {
    //@api sfrecordId;
    @api recordId;
    @track outputText;
    @track boStafName;
    @track boStafComments;
    @track boStafNo;
    @track isValid = true;
    @track firstScreen=true;
    @track secondScreen=false;
    @track boltQuesLevellst;
    @track wiredCommentsList = [];
    @track respResult =[];
    @track respWrapper=[];
    @track pickValue;
    @track displayedQuestions = [];
    @track mapOfValues = [];
    @track selectedPickListValues = [];
    @track selectedCommentValues = [];
    @track fetchLoad = false;
    @track paidAmount;
    @track btnDisable=false;
    @track drvRespResult=[];
    @track tempData =[];
    @track driverName;
    @track driverNumber;
    @track maxRefundAmnt;
    @track errorMsg;
    @track isMaxRefundAmnt=false;
    @track isDriverNo=false;
    @track isdriverName=false;
    @track errorScreen=false;
    @track isNoMaxRefundAmnt=false;
    @track isNoDriverNo=false;
    @track isNoDriverName=false;
    @track noIssueTypeMapped=false;
    @track boltStatusResult;


@track columns = [
    { label: 'Level', fieldName: 'levelQues'},
    {
        label: 'Type', fieldName: 'Type', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Choose Type', options: { fieldName: 'pickListOptions' }, 
            value: { fieldName: 'Type' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
  },
      { label: 'Comments', fieldName: 'comment'},

]
    
    @wire(GetCases, { caseId: '$recordId' })
    wireMethod({ error, data }) {
        if (data) {
        }
    }

    @wire(getListCaseComments,{ caseId: '$recordId'}) 
    commentRec(result) {
        this.wiredCommentsList = result;
        if (result.data) {
        } else if (result.error) {
        }
    }

handleChangePickval(event){
    let upd_obj ;
    let pickedValue=event.detail.value;
    let selectedKey = event.target.dataset.targetId;
    upd_obj = this.selectedPickListValues.findIndex((obj => obj.key === selectedKey));
    this.selectedPickListValues[upd_obj].value = pickedValue;
}

handleChangeComment(event){
        let upd_obj ;
        let pickedValue=event.detail.value;
        let selectedKey = event.target.dataset.targetId;
        upd_obj = this.selectedCommentValues.findIndex((obj => obj.key === selectedKey));
        this.selectedCommentValues[upd_obj].value = pickedValue;
}

handleChangeTicketAmount(event){
   this.paidAmount=event.detail.value;
}

handleCancel(){
   this.firstScreen=true;
   this.secondScreen =false;  
}
connectedCallback() {
    driverDetails({
     caseId:this.recordId
    })
      .then((result) => {
        this.drvRespResult=result;
        this.driverName = (this.drvRespResult!==null && this.drvRespResult[0].driverName!==undefined)?this.drvRespResult[0].driverName:'No Data';
        this.driverNumber = (this.drvRespResult!==null && this.drvRespResult[0].phoneNo!==undefined)?this.drvRespResult[0].phoneNo:'No Data';
        this.errorMsg = (this.drvRespResult!==null && this.drvRespResult[0].ErrorMsg!==undefined)?this.drvRespResult[0].ErrorMsg:'';
    console.log('--errorMsg--'+this.errorMsg);
        if(this.errorMsg=='No IssueType Mapped'){
            this.secondScreen =false;
            this.noIssueTypeMapped=true;
        }

        if(this.driverName=='No Data' || this.driverName=='' || this.driverName=='null'){
            this.isNoDriverName=true;
            this.isDriverName=false;
        }else{
            this.isNoDriverName=false;
            this.isDriverName=true;
        }

        if(this.driverNumber=='No Data' || this.driverNumber=='' ||  this.driverNumber=='null'){
            this.isNoDriverNo=true;
            this.isDriverNo=false;  
        }else{
            this.isNoDriverNo=false;  
            this.isDriverNo=true;  
        }

      })
      .catch((error) => {
        this.isNoDriverNo=true;
        this.isNoMaxRefundAmnt=true;  
        this.isNoDriverName=true
      });
  }

//Added By VR
handleClickSecondScreen(event){
    this.fetchLoad = true;  
    if(this.isMaxRefundAmnt){
     this.paidAmount=this.maxRefundAmnt;
    }
    insertCommentsCall({
        caseId:this.recordId,
        selType:JSON.stringify(this.selectedPickListValues),
        csComments:JSON.stringify(this.selectedCommentValues),
        ticketAmount:this.paidAmount
    })
    .then(result=>{
        if(result.Error){
            this.fetchLoad = false; 
            const evt = new ShowToastEvent({
            message: 'No Data Avialable',
            variant: 'error',
            mode: 'dismissable'
            });
                this.dispatchEvent(evt); 
        }else{
            this.boltStatusResult=result;
            if(result=='Failed'){
               const evt = new ShowToastEvent({
                    message: 'Please check the data is missing in COMMENTS or TYPE or AMOUNT',
                    variant: 'error',
                    mode: 'dismissable'
                    });
                     this.fetchLoad = false; 
                     this.dispatchEvent(evt); 
            }else if(result=='Bolt Validation Failed'){
                const evt = new ShowToastEvent({
                    message: 'Bolt Validation Failed',
                    variant: 'error',
                    mode: 'dismissable'
                    });
                    this.btnDisable=true;
                     this.fetchLoad = false; 
                     this.dispatchEvent(evt); 
            }else{
            const evt = new ShowToastEvent({
                    message: result,
                    variant: 'success',
                    mode: 'dismissable'
                    });
                    this.btnDisable=true;
                     this.fetchLoad = false; 
                     this.dispatchEvent(evt); 
            }   
             
          this.refreshHandler();
      
        }
    })
    .catch(error => {
              this.fetchLoad = false; 
    });
}

async refreshHandler() {
    await updateBoltStatusinCase({
        caseId:this.recordId,
        finalboltStatus:this.boltStatusResult

    }).then((result) => { 
    })
    .catch((error) => {
    });

   getRecordNotifyChange([{ recordId: this.recordId }]);
   //eval("$A.get('e.force:refreshView').fire();");

    refreshApex(this.wiredCommentsList);

}

handleClickFirstScreen() {
      this.fetchLoad = true; 
    if(this.noIssueTypeMapped==false){
    var inp=this.template.querySelectorAll("lightning-input,lightning-textarea");

        inp.forEach(function(element){
            if(element.name=="input1")
                this.boStafName=element.value;

            else if(element.name=="input2")
                this.boStafNo=element.value;

             else if(element.name=="input3")
                this.boStafComments=element.value;

        },this)
    
    if(this.isDriverName){
        this.boStafName=this.driverName;
    }
   
    if(this.isDriverNo){
        this.boStafNo=this.driverNumber;
    }

    if( this.isNoDriverName && (this.boStafName==null || this.boStafName==undefined || this.boStafName =='')){
         this.isValid=false;
        this.fetchLoad =false;
        const evt = new ShowToastEvent({ message: 'Please Enter BO Staff Name', variant: 'error', mode: 'dismissable'});
         this.dispatchEvent(evt);   
    }else if(this.isNoDriverNo && (this.boStafNo==null || this.boStafNo==undefined || this.boStafNo =='')){
         this.isValid=false;
         this.fetchLoad =false;
          const evt = new ShowToastEvent({ message: 'Please Enter BO Staff Number', variant: 'error', mode: 'dismissable'});
         this.dispatchEvent(evt);   
    }else if( this.boStafComments==null || this.boStafComments==undefined || this.boStafComments ==''){
         this.isValid=false;
        this.fetchLoad =false;
          const evt = new ShowToastEvent({ message: 'Please Enter Comments', variant: 'error', mode: 'dismissable'});
         this.dispatchEvent(evt);   
   }else{
        CreateCaseComment({
            caseId:this.recordId,
            stafName:this.boStafName,
            stafNo:this.boStafNo,
            comments:this.boStafComments
        })
        .then(data=>{     
            if(data==='Failed'){
                const evt = new ShowToastEvent({
                    message: 'Failed Please check again',
                    variant: 'error',
                    mode: 'dismissable'
                    });
                    this.fetchLoad =false;
                    this.dispatchEvent(evt);                 
            } else{
                const evt = new ShowToastEvent({
                    message: data,
                    variant: 'success',
                    mode: 'dismissable'
                    });
                    this.fetchLoad =false;
                     this.dispatchEvent(evt); 
                     this.firstScreen=false;
                     this.secondScreen =true;
            }    
                if(this.noIssueTypeMapped){
                    this.secondScreen =false;
                }

                if(this.secondScreen){
                  this.fetchLoad =false;
                  this.fetchBoltVlidationLevel();
                  this.fetchMaxRefundAmount(); 
               } 
        })  
    } 
}else{
    this.fetchLoad =false;
    this.errorScreen=true;
}
}

fetchMaxRefundAmount(){
    GetMaxRefundAmount({
          caseId:this.recordId
      })
      .then(result=>{
          if(result.Error){

          }else{
            this.maxRefundAmnt =result;
            if(this.maxRefundAmnt=='No Data' || this.maxRefundAmnt=='' || this.maxRefundAmnt=='0'){
                this.isNoMaxRefundAmnt=true;  
                this.isMaxRefundAmnt=false; 
            }else{
                this.isNoMaxRefundAmnt=false;  
                this.isMaxRefundAmnt=true;  
            }
          }
              
    })
    .catch(error => {
    });

}
     fetchBoltVlidationLevel(){
        GetBoltVlidationLevel({
            caseId:this.recordId
        })
        .then(result=>{
            if(result.Error){
            }else{
                this.boltQuesLevellst=result;
                this.respResult=JSON.stringify(result);              
                for(let i=0; i<this.boltQuesLevellst.length; i++){
                    let pickListOptions = [];
                    const questions = new Object();
                    questions.questionNumber=this.boltQuesLevellst[i].Question_Number__c;
                    questions.question=this.boltQuesLevellst[i].Question__c;
                    questions.serialNumber=i+1;
                  // questions.pickValues=this.boltQuesLevellst[i].Type_Values__c;
                    var nameArray = this.boltQuesLevellst[i].Type_Values__c.split(',');
                    nameArray.forEach(function (item) {
                        pickListOptions.push({ label: item, value: item});
                    });
                questions.pickValues=pickListOptions;
                    questions.comment='';
                    this.displayedQuestions.push((this.boltQuesLevellst[i].Question_Number__c).toString());
                    this.respWrapper.push(questions);
                 }
                 for( let i=0; i<this.displayedQuestions.length; i++){
                    this.selectedPickListValues.push({"value":" ","key":this.displayedQuestions[i]})
                    this.selectedCommentValues.push({"value":" ","key":this.displayedQuestions[i]})
                 }
                
            }
            
        })
        .catch(error => {
        });
    }
    
    handleClickSave(){
    }

}