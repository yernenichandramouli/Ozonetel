import { LightningElement, api, wire, track } from 'lwc';
import GetboListm from '@salesforce/apex/GetTransactionDetails.getFareBifurcation'

export default class GetFareDetails extends LightningElement {
    @api recId;
    @track priceDetails=[];
    @track addOnDetails = [];
    basicFare=0; 
    gst=0; 
    insurance=0; 
    discount=0;
    loaded=false;
    currency;
    totalFare=0;
    ticketFare;
    serviceTax=0;
    resFee=0;
    leviesCharges=0;
    tollFee=0;
    serviceFee=0; 
    travelProtectPlan=0;
    otherCharges=0;
    assuranceAddon = 0;
    insuranceeAddon=0;
    foodAddon=0;
    activityAddon=0;
    boardingPassAddon=0;
    showMessage=true;
    messsge;
    @wire(GetboListm, {ordId:'$recId' })
    wireMethod({error,data}){
        this.loaded = true;
        if(data){ 
            this.showMessage=false;
            this.messsge='';    
            this.priceDetails = data.customerPriceBreakUp;
            this.addOnDetails = data.Addons;
            console.log('::: addOnDetails :::',this.addOnDetails);
            console.log('::: priceDetails :::',this.priceDetails);
            if(data.errorMsg != null){
                this.showMessage=true;
                this.message=data.errorMsg;
            }
            else{
                this.discount=data.Discount;
                this.ticketFare = data.TicketFare;
                this.totalFare = this.ticketFare.amount;
                this.currency = this.ticketFare.currencyType;
                for(var i=0; i<this.priceDetails.length;i++){
                    if(this.priceDetails[i].componentName == "BASIC_FARE")
                    this.basicFare=this.priceDetails[i].value;
                    if(this.priceDetails[i].componentName == "BUS_OPERATOR_GST")
                    this.gst=this.priceDetails[i].value;
                    if(this.priceDetails[i].componentName == 'INSURANCE_CHARGES')
                    this.insurance=this.priceDetails[i].value;
                    if(this.priceDetails[i].componentName == 'SERVICE_TAX')
                    this.serviceTax=this.priceDetails[i].value;
                    if(this.priceDetails[i].componentName == 'RESERVATION_FEE')
                    this.resFee=this.priceDetails[i].value;
                    if(this.priceDetails[i].componentName == 'LEVIES_CHARGES')
                    this.leviesCharges=this.priceDetails[i].value;
                    if(this.priceDetails[i].componentName == 'TOLL_FEE')
                    this.tollFee=this.priceDetails[i].value;
                    if(this.priceDetails[i].componentName == 'OTHER_CHARGES')
                    this.otherCharges=this.priceDetails[i].value;
                    if(this.priceDetails[i].componentName == 'SERVICE_FEE')
                    this.serviceFee=this.priceDetails[i].value;
                    if(this.priceDetails[i].componentName == 'TRAVEL_PROTECT_PLAN')
                    this.travelProtectPlan=this.priceDetails[i].value;
                }
                console.log('::: AddonDetails :::'+this.addOnDetails);
                if(this.addOnDetails !== undefined){
                    for(var i=0; i<this.addOnDetails.length;i++){
                        console.log('::: Inside addOnDetailsForLoop :::::',this.addOnDetails[i].fareBreakup.totalAmount);
                        if(this.addOnDetails[i].addonType == 'ASSURANCE_SERVICE')
                        this.assuranceAddon = this.addOnDetails[i].fareBreakup.totalAmount;
                        if(this.addOnDetails[i].addonType == 'INSURANCE')
                        this.insuranceeAddon = this.addOnDetails[i].fareBreakup.totalAmount;
                        if(this.addOnDetails[i].addonType == 'FOOD')
                        this.foodAddon = this.addOnDetails[i].fareBreakup.totalAmount;
                        if(this.addOnDetails[i].addonType == 'ACTIVITY')
                        this.activityAddon = this.addOnDetails[i].fareBreakup.totalAmount;
                        if(this.addOnDetails[i].addonType == 'BOARDING_PASS')
                        this.boardingPassAddon = this.addOnDetails[i].fareBreakup.totalAmount;
                    }
                }
            }
        }
    }  
}