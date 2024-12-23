// calendar.js
import { LightningElement, track,api,wire } from 'lwc';
import getAvailableSlots from '@salesforce/apex/CallbackSchedulerController.getAvailableSlots';
import bookTimeSlot from '@salesforce/apex/CallbackSchedulerController.bookTimeSlot';
//import callingAmeyoApi from '@salesforce/apex/CallbackSchedulerController.callBackAmeyoReqApi';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const CASE_FIELDS = [
    'Case.CaseNumber',
    'Case.Id',
    'Case.Phone_No_ct__c',
    'Case.Booking_Mobile_No__c'
];

export default class Calendar extends LightningElement {
    @api recordId; // Case record ID from the record page
    @track showCalendar = true;
    @track showDayView = false;
    @track selectedDate = '';
    @track timeSlots = [];
    @track selectedDateVal='';
    @track caseNumber;
    @track casePhoneNo;
    @track selectedSoltId=null;
    @track showModal = false;
    @track selectedSlotTime='';
    minDate =new Date().toISOString().split('T')[0];
    startHour = 9; // Start time in hours (9 AM)
    endHour = 22; // End time in hours (10 PM)
    maxBookingsPerSlot = 2; // Maximum number of bookings per slot

caseUrl;

constructor() {
    super();
    this.showAlert = this.showAlert.bind(this);
}

 @wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            this.caseNumber = data.fields.CaseNumber.value;
                console.log('>>>', this.caseNumber);
            //this.casePhoneNo = data.fields.Phone_No_ct__c.value;
           let phoneNo= data.fields.Phone_No_ct__c.value ?? data.fields.Booking_Mobile_No__c.value;
              if (phoneNo && phoneNo.length > 10) {
                      this.casePhoneNo = phoneNo.slice(-10);
                } else {
                    this.casePhoneNo = phoneNo; // If less than or equal to 10 digits, use the entire value
                }

            console.log('>>casePhoneNo>', this.casePhoneNo);
        } else if (error) {
            console.error('Error fetching case details:', error);
        }
    }

    showAlert(event) {
        this.selectedSlotId = event.currentTarget.dataset.id;
        this.showModal = true;
    }
    
    connectedCallback() {
        const today = new Date();
        this.minDate = today.toISOString().split('T')[0];
        console.log('>>this.minDate>>'+this.minDate);
        //this.fetchAvailableSlots();
        this.constructCaseUrl();
    }

    constructCaseUrl() {
        this.caseUrl = `https://${window.location.host}/lightning/r/Case/${this.recordId}/view`;
        console.log('>>url>>'+this.caseUrl);
    }


    handleDateChange(event) {
        const selectedDate = new Date(event.target.value);
        this.selectedDateVal =selectedDate; 
        const today = new Date();
        today.setHours(0, 0, 0, 0); // Reset time to compare only dates
    
        if (selectedDate < today) {
            this.showToast('Error', 'Cannot select a previous date', 'error');
        } else {
            this.selectedDate = event.target.value;
            this.showCalendar = false;
            this.showDayView = true;
            this.initializeTimeSlots();
        }
    }

    handleBackToCalendar() {
        this.showDayView = false;
        this.showCalendar = true;
        this.selectedDate =this.selectedDate;
        this.fetchAvailableSlots();

     }

    initializeTimeSlots() {
        console.log ('>>calling back>>>');
        this.timeSlots = [];
        const now = new Date();
        const startDate = new Date(this.selectedDate);
        
         // Set start time based on whether the selected date is today or not
        if (startDate.toISOString().split('T')[0] === now.toISOString().split('T')[0]) {
            // For today, start from the current time or from 9 AM if the current time is earlier
            const currentMinutes = now.getMinutes();
            const nextHalfHour = currentMinutes >= 30 ? now.getHours() + 1 : now.getHours();
            const nextMinutes = currentMinutes >= 30 ? 0 : 30;
            startDate.setHours(Math.max(nextHalfHour, this.startHour), nextMinutes, 0, 0);
           } else {
            // For other dates, start from 9 AM
            startDate.setHours(this.startHour, 0, 0, 0);
        }

        const endDate = new Date(this.selectedDate);
        endDate.setHours(this.endHour, 0, 0, 0);

        while (startDate < endDate) {
            const startTime = new Date(startDate);
            const endTime = new Date(startDate);
            endTime.setMinutes(endTime.getMinutes() + 30);

            this.timeSlots.push({
                id: startTime.getTime(),
                time: `${this.formatTime(startTime)} - ${this.formatTime(endTime)}`,
                class: 'available',
                bookings: 0
            });
            startDate.setMinutes(startDate.getMinutes() + 30);
             console.log('>>>>>>>>>>>67>>>>>>');
        }
        console.log('>>>>>>>>>>>69>>>>>>');
        this.fetchAvailableSlots();
    }

  fetchAvailableSlots() {
    getAvailableSlots({ subDate: this.selectedDate })
        .then(result => {
            const bookedSlots = result.reduce((acc, slot) => {
                const startTime = new Date(slot.StartTime__c).getTime();
                const endTime = new Date(slot.EndTime__c).getTime();

                // Track the start and end times for bookings
                for (let time = startTime; time < endTime; time += 15 * 60 * 1000) { // 15-minute intervals
                    acc[time] = (acc[time] || 0) + 1;
                }

                return acc;
            }, {});

            // Update slots with booking information
            this.timeSlots = this.timeSlots.map(slot => {
                const slotStartTime = new Date(slot.id).getTime();
                const slotEndTime = slotStartTime + 30 * 60 * 1000; // 30-minute slot

                // Count the number of bookings for this slot
                let bookings = 0;
                for (let time = slotStartTime; time < slotEndTime; time += 15 * 60 * 1000) {
                    bookings += bookedSlots[time] || 0;
                }

                slot.bookings = bookings;
                slot.class = this.getSlotClass(bookings, slotStartTime, slotEndTime);
                return slot;
                });
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        });
    console.log('>>>>>>>>>>888', this.selectedDate);
}

getSlotClass(bookings, slotStartTime, slotEndTime) {
    // If there are two bookings or more in the 30-minute slot, consider it fully booked
    if (bookings >= 2) {
        return 'fully-booked';
    } else if (bookings > 0) {
        return 'partially-booked';
    } else {
        return 'available';
    }
}
    formatTime(date) {
        return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }

    handleConfirm(event) {
        const confirmed = event.detail;
        if (confirmed) {
            this.handleSlotClick();
        }
        this.showModal = false;
    }

  handleSlotClick(){
        const slotId = this.selectedSlotId;
        console.log('>>>slotId>>>',slotId);
        const selectedSlot = this.timeSlots.find(slot => slot.id === parseInt(slotId, 10));
        if (selectedSlot.class === 'available' || selectedSlot.class === 'partially-booked') {
            console.log('>>>selectedSlot-class>>>',selectedSlot.class);
            this.bookSlot(slotId);
        } else {
            this.showToast('Error', 'Slot is fully booked.', 'error');
        }
}

bookSlot(slotId) {
    console.log('>>>>172>>>');
    const slot = this.timeSlots.find(slot => slot.id === parseInt(slotId, 10));
    this.selectedSlotTime = new Date(slot.id);
    console.log('++++Time+++'+this.selectedSlotTime);
    console.log('++++caseno+++'+ this.caseNumber,'>>>phone>>>'+this.casePhoneNo,'>>>id>'+this.recordId);

    bookTimeSlot({ startTime: new Date(slot.id), caseNumber: this.caseNumber, casePhoneNo : this.casePhoneNo ,caseId : this.recordId,caseURlView :  this.caseUrl})
        .then(() => {
             slot.bookings += 1;
                slot.class = this.getSlotClass(slot.bookings);
                this.timeSlots = [...this.timeSlots];
                console.log('++++++timeSlots+++',this.timeSlots);
               // this.sendCallbackDetailsToAmeyo();
                this.showToast('Success', 'Slot booked successfully', 'success');

        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        });
}



  /*sendCallbackDetailsToAmeyo() {
   
      callingAmeyoApi({startTime: this.selectedSlotTime,casId:this.recordId,phone: this.casePhoneNo,caseURlView :  this.caseUrl})
            .then(() => {
                this.showToast('Success', 'Slot booked successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
  }*/

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}