import { LightningElement, wire, api, track } from 'lwc';
import fetchCaseIssues from '@salesforce/apex/CaseIssuesController.fetchIssues';
import fetchPastTransactions from '@salesforce/apex/CaseIssuesController.GetPastTransactionDetails';
import fetchPastCases from '@salesforce/apex/CaseIssuesController.GetPastCaseDetails';
import saveIssuesLWC from '@salesforce/apex/CaseIssuesController.saveIssues';
import userTrips from '@salesforce/apex/CaseIssuesController.userTrips';
//import userTrips2 from '@salesforce/apex/CaseIssuesController.userTrips2';

import { refreshApex } from '@salesforce/apex';



//import { getRecord } from 'lightning/uiRecordApi';
/*const FIELDS = [
    'Case.Selected_Issues__c'];*/

export default class SelectIssues extends LightningElement {

    @api recordId;
    issuesData;
    @track issuesAvailable = false;
    @track isValList = [];
    @track readOnlyIssues;
    @track pastTransData;
    @track pastCaseData = [];
    @track userTripsData = [];
    @track caseCount;
    @track userType;
    @track errorMsgPastCases;
    @track csfields = [
        { label: 'Case Number', fieldName: 'caseNumber' },
        { label: 'Issue Type', fieldName: 'issuetype' },
        { label: 'Sub Issue Type', fieldName: 'subIssueType' },
        { label: 'Status', fieldName: 'status' },
        { label: 'Created Date', fieldName: 'DateOfCreation' },
        { label: 'Tin', fieldName: 'tin' },
        { label: 'Trip Id', fieldName: 'tripId' },
    ];
    @track ustfields = [
        { label: 'Tin', fieldName: 'tin' },
        { label: 'Trip Id', fieldName: 'cartId' },
        { label: 'Status', fieldName: 'status' },
        { label: 'Source', fieldName: 'source' },
        { label: 'Destination', fieldName: 'destination' },
        { label: 'Travels', fieldName: 'travels' },
        { label: 'DOJ', fieldName: 'dateOfJourney' },
    ];
    @track activeSections = ["A", "B", "C"];
    @track showUpdMsg;
    @track notifType;
    @track notifMsg;
    @track saveSpinner;
    @track userTripsLoad;
    @track nextSpinner;
    fetchMoreLoad;

    /* @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
     case;
     
    get name() {
        console.log('val-->' + this.case.data.fields.Selected_Issues__c.value);
        if (this.case.data.fields.Selected_Issues__c.value != '')
            readOnlyIssues = true;
    }
    */

    @wire(fetchCaseIssues, { caseId: '$recordId' })
    wireMethod({ error, data }) {
        if (data) {
            console.log('case da-->' + JSON.stringify(data));
            this.issuesData = data;
            this.issuesAvailable = true;
            /*  this.phnNumbers = data;
              console.log(this.phnNumbers.length);
              for (var i = 0; i < this.phnNumbers.length; i++) {
                  console.log(this.phnNumbers[i]);
                  this.options = [...this.options, { value: this.phnNumbers[i], label: this.phnNumbers[i] }];
              }*/
            let alist = [];
            this.issuesData.forEach(function (element) {
                alist.push({ label: element["issueName"], value: element["issueNo"] });
            });
            this.isValList = alist;

            console.log('is ls--->' + this.isValList);

        }
    }

    @wire(fetchPastTransactions, { caseId: '$recordId' })
    wireTransMethod({ error, data }) {
        console.log('called t');
        if (data) {
            console.log('Trans da-->' + JSON.stringify(data));
            this.pastTransData = JSON.parse(data);
            console.log('obj da2-->' + this.pastTransData.rtc_bills);
            if (this.pastTransData.totalNoOfTrxns > 1) {
                this.userType = 'Old User';
            } else {
                this.userType = 'New User';
            }
        }
    }

    @wire(userTrips, { caseId: '$recordId', category: 'Single' })
    wireTransMethod({ error, data }) {
        console.log('called userTrips');
        this.userTripsLoad = true;
        if (data) {
            this.userTripsData = JSON.parse(data);
            console.log('usdt-->' + this.userTripsData);
            this.userTripsLoad = false;
        }
    }

    handleFetchMoreTrips() {
        console.log('called tripp');
        this.fetchMoreLoad = true;
        this.userTripsData = '';
        userTrips({ caseId: this.recordId, category: 'Multiple' }).then(data => {
            this.userTripsData = JSON.parse(data);
            console.log('hadFe-->' + this.userTripsData);
            this.fetchMoreLoad = false;
        }).catch(error => {

        })
    }

    @wire(fetchPastCases, { caseId: '$recordId' })
    wireCasesMethod({ error, data }) {
        console.log('called t');
        if (data) {
            console.log('past cases da-->' + JSON.stringify(data));
            this.pastCaseData = JSON.parse(data);
             if(Array.isArray(this.pastCaseData)){
                 console.log('----135---');
                this.caseCount = this.pastCaseData.length;
            }else{
               // this.errorMsgPastCases=JSON.parse(data);
                 this.caseCount=0;
               console.log('----138---');
            }
        }
    }

    /*   get issueOptions() {
           if (this.issuesAvailable) {
               console.log('called here');
               let alist = [];
               this.issuesData.forEach(function (element) {
                   alist.push({ label: element["MasterLabel"], value: element["Id"] });
               });
               return alist;
           }
    }*/


    handleChange(event) {
        let upIssuesData = JSON.parse(JSON.stringify(this.issuesData));
        console.log('log--->' + JSON.stringify(upIssuesData));
        upIssuesData[event.target.value].isChecked = event.target.checked;
        console.log('called' + event.target.checked);
        console.log('c iss-->' + JSON.stringify(upIssuesData));
        this.issuesData = upIssuesData;
    }

    handleSave2() {
        console.log('sdf 2-->' + JSON.stringify(this.issuesData));
        for (var i = 0; i < this.issuesData.length; i++) {
            console.log('it-->' + JSON.stringify(this.issuesData[i]));
        }

    }

    handleSave() {
        this.saveSpinner = true;
        console.log('ev-->' + JSON.stringify(this.issuesData));
        saveIssuesLWC({ caseId: this.recordId, upIssues: JSON.stringify(this.issuesData) }).then(data => {
            this.saveSpinner = false;
            console.log('ind rs-->' + data);
            this.showUpdMsg = true;
            this.notifType = 'success';
            this.notifMsg = 'Successfully updated';

        }).catch(error => {
            this.saveSpinner = false;
            this.showUpdMsg = true;
            this.notifType = 'error';
            this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code->' + error;

            console.log('ind error-->' + error);
        })

        //  console.log('event-->' + JSON.stringify(event));
        /*  this.issuesData = this.issuesData.map(element => {
              element.isChecked = event.target.checked;
              return element;
          });
          console.log('sss-->' + JSON.stringify(this.issuesData));*/
    }

    handleClose() {

    }
}