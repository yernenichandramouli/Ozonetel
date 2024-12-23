import {
	LightningElement,
	api,
	wire,
	track
} from 'lwc';
import railsisTicketcancel from '@salesforce/apex/RailsTicketCancellationCntrl.GetRailsIsCancellable';
import railsV1Ticketcancel from '@salesforce/apex/RailsTicketCancellationCntrl.railsV1Cancel';

export default class RailsTicketCancellation extends LightningElement {

	@api recordId;
	@track apiRespBody;
	@track errorCod;
	@track success;
	@track message;
	@track apierrorResponse;
	@track totalAmountPaid;
	@track refundableAmount;
	@track selectedValue;
	@track cancellationType;
	@track passengerList = [];
	@track passengerDetails = [];
	@track serialNumber = [];
	@track showPartialCancellation = false;
	@track showCancelTicketButton = true;
	@track hidePartialCancellationValue = true;
	@track gstFee = [];
	@track isLoading = false;
	@track isError = false;
	@track isFinalresp;
	@track isFinalSuccess = false;
	@track finalResponse;
	@track showMsg;
	@track cancelReviewError;
	@track isCancelReviewError = false;

	@track responseFareBrkup;
	@api fareBrkupViewjsonData = [];
	@track isRefundBrkupView = false;

	@wire(railsisTicketcancel, {
		ordItemId: '$recordId'
	})
	wireMethod({
		error,
		data
	}) {
		console.log('data -->');
		this.isLoading = true;
		if (data) {
			this.isLoading = false;
			//this.isRefundBrkupView =false;
			console.log('data -->' + data);
			this.apiRespBody = JSON.parse(data);
			console.log('ccccccstringify -->' + JSON.stringify(this.apiRespBody));
			if (data != null && data != '') {
				this.apiRespBody = JSON.parse(data);
				this.errorCod = JSON.stringify(this.apiRespBody.errorcode);
				this.cancelReviewError = JSON.stringify(this.apiRespBody.cancelReviewError);
				console.log('---error--' + this.cancelReviewError);
				if (this.errorCod != null && this.errorCod != '') {
					this.success = false;
					this.isError = true;
					// this.isLoading = false;
					this.message = JSON.stringify(this.apiRespBody.detailedmsg);
					this.apierrorResponse = JSON.stringify(this.apiRespBody.errormsg);
					console.log('----if= -->');
				} else if (this.cancelReviewError != null && this.cancelReviewError != '') {
					this.isCancelReviewError = true;
					var respObj = JSON.parse(data);
					this.success = true;
					for (var i = 0; i < respObj.passengerInfo.length; i++) {
						var coacId = respObj.passengerInfo[i]['coachId'];
						var bertNo = respObj.passengerInfo[i]['berthNo'];
						var pasgnrname = respObj.passengerInfo[i]['name'];
						var berthcod = respObj.passengerInfo[i]['statusCode'];
						this.passengerList.push(coacId + '-' + bertNo + '-' + pasgnrname + '-' + statusCode);
					}
				} else {
					console.log('===else ===');
					this.success = true;
					// this.isLoading = false;
					this.message = 'Response Success';
					var respObj = JSON.parse(data);
					this.totalAmountPaid = respObj.amountPaid;
					this.refundableAmount = respObj.refundableAmount;
					var noofSeats = respObj.passengerWiseRefundables.length;
					console.log('==noofSeats==' + noofSeats);
					if (noofSeats === 1) {
						this.hidePartialCancellationValue = false;
					}
					var totalrefundamount;
					var arr = JSON.stringify(respObj.passengerWiseRefundables);
					console.log('====arr===' + arr);
					this.passengerDetails = JSON.stringify(respObj.passengerInfo);
					console.log('::: passengerDetails fetched from JSON :::' + this.passengerDetails);
					var amount = 0;

					for (var i = 0; i < respObj.passengerWiseRefundables.length; i++) {
						//console.log('====one=='+respObj.passengerWiseRefundables[i]['name']);
						var name = parseFloat(respObj.passengerWiseRefundables[i]['name']);
						var values = parseFloat(respObj.passengerWiseRefundables[i]['fare']);
						// this.passengerList.push(name);

					}

					/*  for(var i = 0; i < respObj.refundFareBreakup.length; i++){
					     var compname=respObj.refundFareBreakup[i]['componentName'];
					     console.log('====compname=='+compname);
					     if(compname.includes("Convenience Fee")){
					         var gstFare=respObj.refundFareBreakup[i]['value'];
					         console.log('====fee=='+gstFare);
					         this.gstFee.push(gstFare);
					     }
					  }*/

					for (var i = 0; i < respObj.passengerInfo.length; i++) {
						var coacId = respObj.passengerInfo[i]['coachId'];
						var bertNo = respObj.passengerInfo[i]['berthNo'];
						var pasgnrname = respObj.passengerInfo[i]['name'];
						var berthcod = respObj.passengerInfo[i]['berthCode'];
						this.passengerList.push(coacId + '-' + bertNo + '-' + pasgnrname + '-' + berthcod);
					}
				}
			}
		}
	}

	handleCancelButton(event) {
		this.cancellationType = this.template.querySelector("[name='group']").value;
		if (this.cancellationType === 'Partilal Cancl') {
			/* this.selectedValue = this.template.querySelector("[name='passengerList']").value;
			 let passangerName = this.selectedValue.split("-")[2];
			 let passengerInfo = JSON.parse(this.passengerDetails);
			 for (let name in passengerInfo) {
			     if (passengerInfo.hasOwnProperty(name)) {
			         if(passengerInfo[name].name===passangerName){
			             this.serialNumber.push(passengerInfo[name].serialNo);
			         }
			     }
			 }*/

			const selectElement = this.template.querySelector("[name='passengerList']");

			// Initialize an array to store selected values
			const selectedOptions = [];

			// Loop through each option of the select element
			Array.from(selectElement.options).forEach(option => {
				// Check if the option is selected
				if (option.selected) {
					// If selected, add its value to the selectedOptions array
					selectedOptions.push(option.value);
				}
			});

			// Process each selected option to extract passenger details
			selectedOptions.forEach(selectedValue => {
				let passangerName = selectedValue.split("-")[2];
				let passengerInfo = JSON.parse(this.passengerDetails);
				for (let name in passengerInfo) {
					if (passengerInfo.hasOwnProperty(name)) {
						if (passengerInfo[name].name === passangerName) {
							this.serialNumber.push(passengerInfo[name].serialNo);
						}
					}
				}
			});
		} else {
			this.serialNumber = [];
		}
		console.log(':::: SerialNo Array ::::' + this.serialNumber);
		//Calling ApexMethod 
		railsV1Ticketcancel({
				orderItemId: this.recordId,
				selSeats: this.serialNumber
			})
			.then((result) => {
				console.log(':::: called Apex ::::' + result);
				this.isFinalresp = JSON.parse(result);
				if (result != '' && result != null) {
					this.finalResponse = this.isFinalresp.status;
					console.log('finalResponse===' + this.finalResponse);
					if (this.finalResponse == 'CANCELLATION_COMPLETED') {
						this.success = false;
						this.isFinalSuccess = true;
						this.showMsg = 'CANCELLATION COMPLETED SUCCESSFULLY.';
						console.log('===showMsg==' + this.showMsg);
					} else {
						console.log('==error==' + this.isFinalresp.detailedmsg);
						this.success = false;
						this.isFinalSuccess = true;
						this.showMsg = this.isFinalresp.detailedmsg;
					}
				}
			})
			.catch((error) => {
				this.success = false;
				this.isFinalSuccess = false;
				console.log(':::: calling Failed ::::');
				this.showMsg = 'Cancellation Failed';
			});

	}

	hadleCancellationChange(event) {
		let pickListValue = event.target.value;
		if (pickListValue === 'Partilal Cancl') {
			this.showPartialCancellation = true;
			this.showCancelTicketButton = false;
		} else if (pickListValue === 'Full Cancl') {
			this.showPartialCancellation = false;
			this.showCancelTicketButton = false;
		} else {
			this.showCancelTicketButton = true;
			this.showPartialCancellation = false;
		}
	}

	// fare BreakUp 

	closeFareBrkUp(event) {
		this.isRefundBrkupView = false;
		this.fareBrkupViewjsonData = [];
	}
	handleLinkClickFareBrkUp(event) {
		this.callingFaretailsView();

	}
	callingFaretailsView() {
		// Call the Apex method with the parameter
		//this.isRefundBrkupView = true;
		railsisTicketcancel({
				ordItemId: this.recordId
			})
			.then(result => {
				this.isRefundBrkupView = true;

				console.log('--Apex method result:', result);
				// Parse the result and extract the breakDownTable
				this.responseFareBrkup = JSON.parse(result);
				let totalDeductionsProcessed = false;

				this.responseFareBrkup.breakDownTable.forEach(breakDown => {
					if (breakDown.componentName === 'Total Deductions' && !totalDeductionsProcessed) {
						breakDown.amount = '-' + ' ' + breakDown.amount;
						this.fareBrkupViewjsonData.push(breakDown);
						totalDeductionsProcessed = true;

						if (breakDown.detailedBreakDown && breakDown.detailedBreakDown.length > 0) {
							breakDown.detailedBreakDown.forEach(detailedBreakDownItem => {
								detailedBreakDownItem.amount = '-' + ' ' + detailedBreakDownItem.amount;
								//this.fareBrkupViewjsonData.push(detailedBreakDownItem);
							});
						}
					} else if (breakDown.componentName === 'Total Refund') {
						// Skip this entry, don't add it to responseData
						// If you want to remove detailedBreakDown list for Total Refund, set it to an empty array
						breakDown.detailedBreakDown = [];
						this.fareBrkupViewjsonData.push(breakDown);
					} else if (breakDown.componentName !== 'Total Deductions') {
						this.fareBrkupViewjsonData.push(breakDown);

					}

				});
			})
			.catch(error => {
				// Handle any errors
				console.error('Error calling Apex method:', error);
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Error',
						message: 'Error calling Apex method',
						variant: 'error',
					})
				);
		});
	}
	
}