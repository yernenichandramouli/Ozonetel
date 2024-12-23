import { LightningElement, api, track,wire } from 'lwc';
import updateCargoTrackingDetails from '@salesforce/apex/CargoservicesCntrl.UpdateTrackingDetails';
import getActivityDetailsInfo from '@salesforce/apex/CargoservicesCntrl.GetActivityDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
const CONTACT_FIELDS = [
    'Activities__c.Transaction_Status__c',
    'Activities__c.Final_Status__c',
    'Activities__c.First_Mile_Status__c',
    'Activities__c.Cargo_Tracking_status__c',
];


export default class CargoServicesTrackingUpdateCmp extends LightningElement {

  @track options = [
    { label: 'Primera milla', value: 'firstMileBtn' },
    { label: 'Carga', value: 'cargoBtn' },
  ];

 @track cargoStageOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Encomienda entregada al operador de transporte', value: 'Encomienda entregada al operador de transporte' },
    { label: 'Paquete en tránsito', value: 'Paquete en tránsito' },
    { label: 'Llegó al destino', value: 'Llegó al destino' },
    { label: 'Entregado', value: 'Entregado' },

  ];

   @track cargoPacDrpMidstatusOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Éxito', value: 'SUCCESS' },
    { label: 'Fallo', value: 'FAILURE' },
  ];

@track cargoPacIntrnsStatusOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Retraso', value: 'DELAYED' },
    { label: 'Éxito', value: 'SUCCESS' },
  ];

@track cargoReDesStatusOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Éxito', value: 'SUCCESS' },
    { label: 'Fallo', value: 'FAILURE' },
  ];
  @track cargoDelivStatusOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Éxito', value: 'SUCCESS' },
    { label: 'Fallo', value: 'FAILURE' },
  ];

@track pacDrpMidSucOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Paquete entregado al operador de transporte', value: 'Paquete entregado al operador de transporte' },
  ];
@track pacDrpMidFailOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Operador de transporte rechazó el paquete', value: 'Operador de transporte rechazó el paquete' },
  ];
@track pacIntrnsSucOptions = [
    { label: '--None--', value: 'none' },
    { label: 'El paquete llega a tiempo', value: 'El paquete llega a tiempo' },
  ];
@track pacIntrnsFailOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Retraso debido a cambios de horario del operador de transporte', value: 'Retraso debido a cambios de horario del operador de transporte' },
  ];

@track reDesSucOptions = [
    { label: '--None--', value: 'none' },
    { label: 'El paquete llegó al centro de destino final', value: 'El paquete llegó al centro de destino final' },
  ];

@track reDesFailOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Paquetes perdidos', value: 'Paquetes perdidos' },
    { label: 'paquete dañado', value: 'paquete dañado' },
  ];
@track delivSucOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Entrega del paquete al destinatario', value: 'Entrega del paquete al destinatario' },
  ];
@track delivFailOptions = [
    { label: '--None--', value: 'none' },
    { label: 'No se puede entregar al destinatario', value: 'No se puede entregar al destinatario' },
  ];

  @track statusOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Éxito', value: 'SUCCESS' },
    { label: 'Fallo', value: 'FAILURE' },
  ];

  @track picByAgentstatusOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Éxito', value: 'SUCCESS' },
    { label: 'Fallo', value: 'FAILURE' },
  ];


  @track stageOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Primer recojo programado', value: 'Primer recojo programado' },
    { label: 'Paquete recogido por el agente', value: 'Paquete recogido por el agente' },
  ];
  
  @track frMailSucOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Agente asignado y recojo programado', value: 'Agente asignado y recojo programado' },
  ];

   @track frMailFailOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Cancelado por el usuario', value: 'Cancelado por el usuario' },
    { label: 'Delivery no disponible', value: 'Delivery no disponible' },

  ];

  @track frMailPickedByAgntSucOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Paquete recogido exitosamente', value: 'Paquete recogido exitosamente' },
  ];

   @track frMailPickedByAgntFailOptions = [
    { label: '--None--', value: 'none' },
    { label: 'El agente se negó a recoger el paquete', value: 'El agente se negó a recoger el paquete' },
    { label: 'El cliente no fue localizado', value: 'El cliente no fue localizado' },
  ];
  
@track frMailDelStatusOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Llegando temprano', value: 'Llegando temprano' },
    { label: 'A tiempo', value: 'A tiempo' },
    { label: 'Demorado', value: 'Demorado' },

  ];

  @track cargoDelStatusOptions = [
    { label: '--None--', value: 'none' },
    { label: 'Llegando temprano', value: 'Llegando temprano' },
    { label: 'A tiempo', value: 'A tiempo' },
    { label: 'Demorado', value: 'Demorado' },

  ];

  @api recordId;
  objectData;

  @track wiredData;
  @track successMsg;
  @track isSuccessfulTrackingUpd = false;
  @track showRadioBtns = false;
  @track cargoStageOptionsVal;
  @track isPacDrpMidstatusOptions=false;
  @track cargoPacDrpMidstatusOptionsVal;
  @track isPacIntrnsStatusOptions=false;
  @track cargoPacIntrnsStatusOptionsVal;
  @track isReDesStatusOptions=false;
  @track cargoReDesStatusOptionsVal;
  @track isDelivStatusOptions=false;
  @track cargoDelivStatusOptionsVal;
  @track isPacDrpMidSucOptions=false;
  @track pacDrpMidSuccessOptionsVal;
  @track isPacDrpMidFailOptions=false;
  @track pacDrpMidFailOptionsVal
  @track isPacIntrnsSucOptions=false;
  @track pacIntrnsSuccessOptionsVal;
  @track isPacIntrnsFailOptions=false;
  @track pacIntrnsFailOptionsVal;
  @track isReDesSucOptions=false;
  @track reDesSuccessOptionsVal;
  @track isReDesFailOptions=false;
  @track reDesFailOptionsVal;
  @track isDelivSucOptions=false;
  @track delivSuccessOptionsVal;
  @track isDelivFailOptions=false;
  @track delivFailOptionsVal;
  @track stageOptionsVal;
  @track statusOptionsVal;
  @track frMailSuccessOptionsVal;
  @track frMailFailOptionsVal;
  @track isstatusOptionsVal = false;
  @track isFrMailSucOptions = false;
  @track isFrMailFailOptions = false;
  @track isButtons=false;
  @track isAgentNameNo=false;
  @track isPreviousBtn=false;
  @track isFrMailPicAgentSucOptions =false;
  @track frMailPickedByAgntSucOptionsVal;
  @track isPicAgstatusOptionsVal=false;
  @track picByAgentstatusOptionsVal;
  @track isFrMailPicAgentFailOptions=false;
  @track frMailPickedByAgntFailOptionsVal;
  @track phoneNumber;
  @track agentName;
  @track showCargoProcess = false;
  @track showFirstMailProcess = false;
  @track commentsVal;
  @track isfrsMailDelStatus=false;
  @track isInputDateTime=false;
  @track inputDateTimeVal;
  @track isCargoDelStatus=false;
  @track cargoinputDateTimeVal;
  @track iscargoInputDateTime = false;
  @track cargoagentName;
  @track cargoPhoneNumber;
  @track cargCommentsVal;
  @track isCargoAgentNameNo=false;
  @track isCargButtons=false;
  @track radioBtnVal;
  @track failMsg;
  @track firstMileUuids;
  @track cargoUuids;
  @track isFirstMileUuid=false;
  @track isCargoUuid=false;
  @track cargoDelStatusOptionsVal;
  @track frMailDelStatusOptionsVal;
 
  connectedCallback() {
    console.log('--test--');
    this.getActivityInfo();
  }
 getActivityInfo(){
    console.log('>>>214>>>');
    getActivityDetailsInfo({ ItemId: this.recordId })
      .then((result) => {
         console.log('>result>'+result);
            if (result !='No Cargo is found' ){ 
              const inputString = result;
              const pairs = inputString.split("/");
              console.log('>pairs>'+pairs);
                          pairs.forEach(pair => {
                // Split each pair using "-"
                const [key, value] = pair.split("-");

                // Check conditions for each key-value pair
                if (key === "firstMileUuid" && value === "null") {
                    console.log("Condition met for firstMileUuid");
                } else if (key === "cargoUuid" && value !== "null") {
                    console.log("Condition met for cargoUuid"+value);
                    this.cargoUuids=value;
                }
                
                if (key === "cargoUuid" && value === "null") {
                    console.log("Condition met for firstMileUuid");
                } else if (key === "firstMileUuid" && value !== "null") {
                    this.firstMileUuids=value;
                }

              });

               if(this.cargoUuids!=null && this.cargoUuids!='' && this.firstMileUuids!=null && this.firstMileUuids!=''){
                  this.showRadioBtns = true;
               }
               if(this.showRadioBtns===false && this.firstMileUuids!=null && this.firstMileUuids!=''){
                  this.showFirstMailProcess=true;
                  this.showCargoProcess=false;
                  this.showRadioBtns = false;
                  this.radioBtnVal ='firstMileBtn'
               }
               if(this.showRadioBtns===false && this.cargoUuids!=null && this.cargoUuids!=''){
                  this.showCargoProcess=true;
                  this.showFirstMailProcess=false;
                  this.showRadioBtns = false;
                  this.radioBtnVal ='cargoBtn'
               }
            }
         })
      .catch((error) => {
        this.isLoading = false;
        console.error('Error: \n ', error);
      });
 }

  handleRadioChange(event) {
    this.selectedValue = event.target.value;
    this.radioBtnVal = this.selectedValue;
    console.log('--selectRadio--' + this.radioBtnVal);
  }

  handleCommentsInput(event) {
    this.commentsVal = event.target.value;
  }

  handleAgentNameChange(event){
     this.agentName = event.target.value;
  }

   handlePhoneChange(event){
     this.phoneNumber = event.target.value;
     if (/^[0-9]*$/.test( this.phoneNumber)) {
            this.showError = false;
        } else {
            this.showError = true;
        }
  }


   handleCargoCommentsInput(event) {
    this.cargCommentsVal = event.target.value;
  }

  handleCargoAgentNameChange(event){
     this.cargoagentName = event.target.value;
  }

   handleCargoPhoneChange(event){
     this.cargoPhoneNumber = event.target.value;
  }

  handleToProcessed() {
    this.value = '';
    console.log('==this.selectedValue=' + this.selectedValue);
    if (this.selectedValue == 'cargoBtn') {
      this.showRadioBtns = false;
      this.showFirstMailProcess = false;
      this.showCargoProcess = true;
      this.isInputDateTime=false;
      this.selectedValue = '';
      this.isPreviousBtn=true
      this.iscargoInputDateTime =false;
      this.isCargoDelStatus=false;
      this.cargoDelStatusOptionsVal='none';
      this.cargoinputDateTimeVal='';
      this.isCargoAgentNameNo=false;
      this.isCargButtons=false;
      this.cargCommentsVal='';
      this.cargoPhoneNumber='';
      this.cargoagentName='';
    } else if (this.selectedValue == 'firstMileBtn') {
        this.showRadioBtns = false;
        this.showCargoProcess = false;
        this.showFirstMailProcess = true;
        this.isInputDateTime=false;
        this.selectedValue = '';
        this.isPreviousBtn=true;
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    } else {
      alert('Please select one item');
    }
  }

  handleGoBackTobtns() {
    this.value = undefined;
     if(this.cargoUuids!=null && this.cargoUuids!='' && this.firstMileUuids!=null && this.firstMileUuids!=''&& (this.stageOptionsVal==='none' || this.cargoStageOptionsVal==='none')){
          this.showRadioBtns = true;
          this.showCargoProcess = false;
          this.showFirstMailProcess = false;
       }
   //this.showRadioBtns = true;
    //this.showCargoProcess = false;
   // this.showFirstMailProcess = false;
    this.stageOptionsVal='none';
    this.cargoStageOptionsVal='none';
    this.statusOptionsVal='none';
    this.frMailSuccessOptionsVal='none';
    this.frMailFailOptionsVal='none';
    this.picByAgentstatusOptionsVal='none';
    this.frMailPickedByAgntSucOptionsVal='none';
    this.frMailPickedByAgntFailOptionsVal='none';
    this.isstatusOptionsVal=false;
    this.isPicAgstatusOptionsVal=false;
    this.isFrMailSucOptions = false;
    this.isFrMailFailOptions = false;
    this.isFrMailPicAgentSucOptions =false;
    this.isFrMailPicAgentFailOptions = false;
    this.isPacDrpMidstatusOptions=false;
    this.isPacIntrnsStatusOptions=false;
    this.isReDesStatusOptions=false;
    this.isDelivStatusOptions=false;
    this.isPacDrpMidSucOptions=false;
    this.isPacDrpMidFailOptions=false;
    this.isPacIntrnsSucOptions=false;
    this.isPacIntrnsFailOptions=false;
    this.isReDesSucOptions=false;
    this.isReDesFailOptions=false;
    this.isDelivSucOptions=false;
    this.isDelivFailOptions=false;
    this.cargoPacDrpMidstatusOptionsVal='none';
    this.cargoPacIntrnsStatusOptionsVal='none';
    this.cargoReDesStatusOptionsVal='none';
    this.cargoDelivStatusOptionsVal='none';
    this.pacDrpMidSuccessOptionsVal='none';
    this.pacDrpMidFailOptionsVal='none';
    this.pacIntrnsSuccessOptionsVal='none';
    this.pacIntrnsFailOptionsVal='none';
    this.reDesSuccessOptionsVal='none';
    this.reDesFailOptionsVal='none';
    this.delivSuccessOptionsVal='none';
    this.delivFailOptionsVal='none';
    this.isButtons = false;
    this.isAgentNameNo =false;
    this.phoneNumber='';
    this.agentName='';
    this.commentsVal='';
    this.isfrsMailDelStatus=false;
    this.isInputDateTime=false;
    this.inputDateTimeVal='';
    this.iscargoInputDateTime =false;
    this.isCargoDelStatus=false;
    this.cargoDelStatusOptionsVal='none';
    this.cargoinputDateTimeVal='';
    this.isCargoAgentNameNo=false;
    this.isCargButtons=false;
    this.cargCommentsVal='';
    this.cargoPhoneNumber='';
    this.cargoagentName='';
  }

  handlePhoneChange(event) {
    const inputValue = event.target.value;
    // Remove non-numeric characters from the input value
    this.phoneNumber = inputValue.replace(/[^0-9]/g, '');
  }

handlegoBackHomeScreen(){
  console.log('--test--');
   this.isSuccessfulTrackingUpd = false;
   this.handleGoBackTobtns();
}

@wire(getRecord, { recordId: '$recordId', fields: [CONTACT_FIELDS] })
    wiredRecord({ error, data }) {
        if (data) {
            this.objectData = data;
        } else if (error) {
            console.error('Error loading record data', error);
        }
    }


handleRefresh(){
  this.isSuccessfulTrackingUpd = false;
  this.handleGoBackTobtns();
 location.reload();
  //return refreshApex(this.objectData);


}
handleCargoStageOptionChange(event){
  const inputValue = event.target.value;
    this.cargoStageOptionsVal=inputValue;
    if(this.cargoStageOptionsVal ==='Encomienda entregada al operador de transporte'){
          this.isPacDrpMidstatusOptions =true;
          this.isPacIntrnsStatusOptions =false;
          this.isPacDrpMidSucOptions =false;
          this.isPacDrpMidFailOptions =false;
          this.isPacIntrnsSucOptions=false;
          this.isPacIntrnsFailOptions =false;
          this.isReDesSucOptions = false;
          this.isReDesFailOptions = false;
          this.isDelivSucOptions= false;
          this.isDelivFailOptions = false;
          this.isReDesStatusOptions = false;
          this.isDelivStatusOptions = false;
          this.cargoPacDrpMidstatusOptionsVal ='none';
          this.cargoPacIntrnsStatusOptionsVal ='none';
          this.cargoReDesStatusOptionsVal='none';
          this.cargoDelivStatusOptionsVal='none';
          this.pacDrpMidSuccessOptionsVal='none';
          this.pacDrpMidFailOptionsVal='none';
          this.pacIntrnsSuccessOptionsVal='none';
          this.pacIntrnsFailOptionsVal='none';
          this.reDesSuccessOptionsVal='none';
          this.reDesFailOptionsVal='none';
          this.delivSuccessOptionsVal='none';
          this.delivFailOptionsVal='none';
          this.isPreviousBtn=true;
          this.isCargoDelStatus=false;
          this.cargoDelStatusOptionsVal='none';
          this.cargoinputDateTimeVal='';
          this.isCargoAgentNameNo=false;
          this.isCargButtons=false;
          this.cargCommentsVal='';
          this.cargoPhoneNumber='';
          this.cargoagentName='';
    }else if(this.cargoStageOptionsVal ==='Paquete en tránsito'){
          this.isPacDrpMidstatusOptions =false;
          this.isPacIntrnsStatusOptions =true;
          this.isPacDrpMidSucOptions= false;
          this.isReDesStatusOptions = false;
          this.isPreviousBtn=true;
          this.isDelivStatusOptions = false;
          this.isPacDrpMidFailOptions =false;
          this.isPacIntrnsSucOptions=false;
          this.isPacIntrnsFailOptions =false;
          this.isReDesSucOptions = false;
          this.isReDesFailOptions = false;
          this.isDelivSucOptions= false;
          this.isDelivFailOptions = false;
          this.cargoPacDrpMidstatusOptionsVal ='none';
          this.cargoPacIntrnsStatusOptionsVal ='none';
          this.cargoReDesStatusOptionsVal='none';
          this.cargoDelivStatusOptionsVal='none';
          this.pacDrpMidSuccessOptionsVal='none';
          this.pacDrpMidFailOptionsVal='none';
          this.pacIntrnsSuccessOptionsVal='none';
          this.pacIntrnsFailOptionsVal='none';
          this.reDesSuccessOptionsVal='none';
          this.reDesFailOptionsVal='none';
          this.delivSuccessOptionsVal='none';
          this.delivFailOptionsVal='none';
          this.iscargoInputDateTime =false;
          this.isCargoDelStatus=false;
          this.cargoDelStatusOptionsVal='none';
          this.cargoinputDateTimeVal='';
          this.isCargoAgentNameNo=false;
          this.isCargButtons=false;
          this.cargCommentsVal='';
          this.cargoPhoneNumber='';
          this.cargoagentName='';
    }else if(this.cargoStageOptionsVal ==='Llegó al destino'){
          this.isPacDrpMidstatusOptions =false;
          this.isPacIntrnsStatusOptions =false;
          this.isReDesStatusOptions = true;
          this.isDelivStatusOptions = false;
          this.isPacDrpMidSucOptions =false;
          this.isPacDrpMidFailOptions =false;
          this.isPacIntrnsSucOptions=false;
          this.isPacIntrnsFailOptions =false;
          this.isReDesSucOptions = false;
          this.isReDesFailOptions = false;
          this.isDelivSucOptions= false;
          this.isDelivFailOptions = false;
          this.cargoPacDrpMidstatusOptionsVal ='none';
          this.cargoPacIntrnsStatusOptionsVal ='none';
          this.cargoReDesStatusOptionsVal='none';
          this.cargoDelivStatusOptionsVal='none';
          this.pacDrpMidSuccessOptionsVal='none';
          this.pacDrpMidFailOptionsVal='none';
          this.pacIntrnsSuccessOptionsVal='none';
          this.pacIntrnsFailOptionsVal='none';
          this.reDesSuccessOptionsVal='none';
          this.reDesFailOptionsVal='none';
          this.delivSuccessOptionsVal='none';
          this.delivFailOptionsVal='none';
          this.isPreviousBtn=true;
          this.iscargoInputDateTime =false;
          this.isCargoDelStatus=false;
          this.cargoDelStatusOptionsVal='none';
          this.cargoinputDateTimeVal='';
          this.isCargoAgentNameNo=false;
          this.isCargButtons=false;
          this.cargCommentsVal='';
          this.cargoPhoneNumber='';
          this.cargoagentName='';
    }else if(this.cargoStageOptionsVal ==='Entregado'){
          this.isPacDrpMidstatusOptions =false;
          this.isPacIntrnsStatusOptions =false;
          this.isReDesStatusOptions = false;
          this.isDelivStatusOptions = true;
          this.isPacDrpMidSucOptions =false;
          this.isPacDrpMidFailOptions =false;
          this.isPacIntrnsSucOptions=false;
          this.isPacIntrnsFailOptions =false;
          this.isReDesSucOptions = false;
          this.isReDesFailOptions = false;
          this.isDelivSucOptions= false;
          this.isDelivFailOptions = false;
          this.cargoPacDrpMidstatusOptionsVal ='none';
          this.cargoPacIntrnsStatusOptionsVal ='none';
          this.cargoReDesStatusOptionsVal='none';
          this.cargoDelivStatusOptionsVal='none';
          this.pacDrpMidSuccessOptionsVal='none';
          this.pacDrpMidFailOptionsVal='none';
          this.pacIntrnsSuccessOptionsVal='none';
          this.pacIntrnsFailOptionsVal='none';
          this.reDesSuccessOptionsVal='none';
          this.reDesFailOptionsVal='none';
          this.delivSuccessOptionsVal='none';
          this.delivFailOptionsVal='none';
          this.isPreviousBtn=true;
          this.iscargoInputDateTime =false;
          this.isCargoDelStatus=false;
          this.cargoDelStatusOptionsVal='none';
          this.cargoinputDateTimeVal='';
          this.isCargoAgentNameNo=false;
          this.isCargButtons=false;
          this.cargCommentsVal='';
          this.cargoPhoneNumber='';
          this.cargoagentName='';
    }else if(this.cargoStageOptionsVal=='none'){
          this.isPacDrpMidstatusOptions =false;
          this.isPacIntrnsStatusOptions =false;
          this.isButtons=false;
          this.isReDesStatusOptions = false;
          this.isDelivStatusOptions = false;
          this.isPacDrpMidSucOptions =false;
          this.isPacDrpMidFailOptions =false;
          this.isPacIntrnsSucOptions=false;
          this.isPacIntrnsFailOptions =false;
          this.isReDesSucOptions = false;
          this.isReDesFailOptions = false;
          this.isDelivSucOptions= false;
          this.isDelivFailOptions = false;
          this.cargoPacDrpMidstatusOptionsVal ='none';
          this.cargoPacIntrnsStatusOptionsVal ='none';
          this.cargoReDesStatusOptionsVal='none';
          this.cargoDelivStatusOptionsVal='none';
          this.pacDrpMidSuccessOptionsVal='none';
          this.pacDrpMidFailOptionsVal='none';
          this.pacIntrnsSuccessOptionsVal='none';
          this.pacIntrnsFailOptionsVal='none';
          this.reDesSuccessOptionsVal='none';
          this.reDesFailOptionsVal='none';
          this.delivSuccessOptionsVal='none';
          this.delivFailOptionsVal='none';
          this.isPreviousBtn=false;
          this.iscargoInputDateTime =false;
          this.isCargoDelStatus=false;
          this.cargoDelStatusOptionsVal='none';
          this.cargoinputDateTimeVal='';
          this.isCargoAgentNameNo=false;
          this.isCargButtons=false;
          this.cargCommentsVal='';
          this.cargoPhoneNumber='';
          this.cargoagentName='';
    }
}
  
handlecargoPacDrpMidstatusOptionsChange(event){
    const inputValue = event.target.value;
    this.cargoPacDrpMidstatusOptionsVal=inputValue;
    if(this.cargoPacDrpMidstatusOptionsVal ==='SUCCESS'){
        this.isPacDrpMidSucOptions=true;
        this.isPacDrpMidFailOptions=false;
        this.isPreviousBtn=true;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.reDesSuccessOptionsVal='none';
        this.reDesFailOptionsVal='none';
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    }else if(this.cargoPacDrpMidstatusOptionsVal ==='FAILURE'){
        this.isPacDrpMidSucOptions=false;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.reDesSuccessOptionsVal='none';
        this.reDesFailOptionsVal='none';
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.isPacDrpMidFailOptions=true;
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.isPreviousBtn=true;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    }else if(this.cargoPacDrpMidstatusOptionsVal ==='none'){
        this.isPacDrpMidSucOptions=false;
        this.isPacDrpMidFailOptions=false;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.reDesSuccessOptionsVal='none';
        this.isPreviousBtn=true;
        this.reDesFailOptionsVal='none';
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.isButtons=false;
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    }
}   

handlecargoIntrnsStatusOptionsChange(event){
    const inputValue = event.target.value;
    this.cargoPacIntrnsStatusOptionsVal=inputValue;
    if(this.cargoPacIntrnsStatusOptionsVal ==='DELAYED'){
        this.isPacIntrnsSucOptions=false;
        this.isPacIntrnsFailOptions=true;
        this.isPacDrpMidSucOptions=false;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.reDesSuccessOptionsVal='none';
        this.reDesFailOptionsVal='none';
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
        this.isPreviousBtn=true;
    }else if(this.cargoPacIntrnsStatusOptionsVal ==='SUCCESS'){
        this.isPacIntrnsSucOptions=true;
        this.isPacDrpMidSucOptions= false;
        this.isPacIntrnsFailOptions=false;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.isPreviousBtn=true;
        this.reDesSuccessOptionsVal='none';
        this.reDesFailOptionsVal='none';
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    }else if(this.cargoPacIntrnsStatusOptionsVal ==='none'){
        this.isPacIntrnsSucOptions=false;
        this.isPacIntrnsFailOptions=false;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.reDesSuccessOptionsVal='none';
        this.reDesFailOptionsVal='none';
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isPreviousBtn=true;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    }
} 

handlecargoReDesStatusOptionsChange(event){
    const inputValue = event.target.value;
    this.cargoReDesStatusOptionsVal=inputValue;
    if(this.cargoReDesStatusOptionsVal ==='SUCCESS'){
        this.isReDesSucOptions=true;
        this.isReDesFailOptions=false;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.reDesSuccessOptionsVal='none';
        this.reDesFailOptionsVal='none';
        this.isPreviousBtn=true;
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    }else if(this.cargoReDesStatusOptionsVal ==='FAILURE'){
        this.isReDesSucOptions=false;
        this.isReDesFailOptions=true;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.reDesSuccessOptionsVal='none';
        this.reDesFailOptionsVal='none';
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.isPreviousBtn=true;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    }else if(this.cargoReDesStatusOptionsVal ==='none'){
        this.isReDesSucOptions=false;
        this.isReDesFailOptions=false;
        this.reDesSuccessOptionsVal=false;
        this.reDesFailOptionsVal=false;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.isPreviousBtn=true;
        this.reDesSuccessOptionsVal='none';
        this.reDesFailOptionsVal='none';
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    }
} 

handlecargoDelivStatusOptionsChange(event){
    const inputValue = event.target.value;
    this.cargoDelivStatusOptionsVal=inputValue;
    if(this.cargoDelivStatusOptionsVal ==='SUCCESS'){
        this.isDelivSucOptions=true;
        this.isDelivFailOptions=false;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.reDesSuccessOptionsVal='none';
        this.isPreviousBtn=true;
        this.reDesFailOptionsVal='none';
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    }else if(this.cargoDelivStatusOptionsVal ==='FAILURE'){
        this.isDelivSucOptions=false;
        this.isDelivFailOptions=true;
        this.pacDrpMidSuccessOptionsVal='none';
        this.pacDrpMidFailOptionsVal='none';
        this.pacIntrnsSuccessOptionsVal='none';
        this.pacIntrnsFailOptionsVal='none';
        this.reDesSuccessOptionsVal='none';
        this.isPreviousBtn=true;
        this.reDesFailOptionsVal='none';
        this.delivSuccessOptionsVal='none';
        this.delivFailOptionsVal='none';
        this.iscargoInputDateTime =false;
        this.isCargoDelStatus=false;
        this.cargoDelStatusOptionsVal='none';
        this.cargoinputDateTimeVal='';
        this.isCargoAgentNameNo=false;
        this.isCargButtons=false;
        this.cargCommentsVal='';
        this.cargoPhoneNumber='';
        this.cargoagentName='';
    }else if(this.cargoDelivStatusOptionsVal ==='none'){
      this.isDelivSucOptions=false;
      this.isDelivFailOptions=false;
      this.delivSuccessOptionsVal=false;
      this.delivFailOptionsVal=false;
      this.pacDrpMidSuccessOptionsVal='none';
      this.pacDrpMidFailOptionsVal='none';
      this.pacIntrnsSuccessOptionsVal='none';
      this.pacIntrnsFailOptionsVal='none';
      this.isPreviousBtn=true;
      this.reDesSuccessOptionsVal='none';
      this.reDesFailOptionsVal='none';
      this.delivSuccessOptionsVal='none';
      this.delivFailOptionsVal='none';
      this.iscargoInputDateTime =false;
      this.isCargoDelStatus=false;
      this.cargoDelStatusOptionsVal='none';
      this.cargoinputDateTimeVal='';
      this.isCargoAgentNameNo=false;
      this.isCargButtons=false;
      this.cargCommentsVal='';
      this.cargoPhoneNumber='';
      this.cargoagentName='';
    }
} 
//
handlePacDrpMidSuccessOption(event){
    const inputValue = event.target.value;
    this.pacDrpMidSuccessOptionsVal=inputValue;
    if(this.pacDrpMidSuccessOptionsVal!=='none'){
          this.isCargButtons=true;
          this.isCargoAgentNameNo=true;
          this.iscargoInputDateTime=true;
          this.isPreviousBtn=false;
    }else if(this.pacDrpMidSuccessOptionsVal==='none'){
          this.isCargButtons=false;
          this.isCargoAgentNameNo=false;
          this.iscargoInputDateTime=false;
          this.isPreviousBtn=true;
    }
} 
handlePacDrpMidFailOption(event){
    const inputValue = event.target.value;
    this.pacDrpMidFailOptionsVal=inputValue;
    if(this.pacDrpMidFailOptionsVal!=='none'){
        this.isCargButtons=true;
        this.isPreviousBtn=false;
    }else if(this.pacDrpMidFailOptionsVal ==='none'){
        this.isCargButtons=false;
        this.isPreviousBtn=true;
    }
} 

handlePacIntrnsSuccessOption(event){
    const inputValue = event.target.value;
    this.pacIntrnsSuccessOptionsVal=inputValue;
    if(this.pacIntrnsSuccessOptionsVal!=='none'){
       this.isCargButtons=true;
       this.isCargoAgentNameNo=true;
       this.iscargoInputDateTime=true;
       this.isPreviousBtn=false;
    }else if(this.pacIntrnsSuccessOptionsVal ==='none'){
      this.isCargButtons=false;
      this.isCargoAgentNameNo=false;
      this.iscargoInputDateTime=false;
      this.isPreviousBtn=true;
    }
} 

handlePacIntrnsFailOption(event){
    const inputValue = event.target.value;
    this.pacIntrnsFailOptionsVal=inputValue;
    if(this.pacIntrnsFailOptionsVal!=='none'){
       this.isCargButtons=true;
       this.isPreviousBtn=false;
    }else if(this.pacIntrnsFailOptionsVal ==='none'){
      this.isCargButtons=false;
      this.isPreviousBtn=true;
    }
} 

handleReDesSuccessOption(event){
    const inputValue = event.target.value;
    this.reDesSuccessOptionsVal=inputValue;
    if(this.reDesSuccessOptionsVal!=='none'){
      this.isCargButtons=true;
      this.isCargoAgentNameNo=true;
      this.iscargoInputDateTime=true;
      this.isPreviousBtn=false;
    }else if(this.reDesSuccessOptionsVal ==='none'){
      this.isCargButtons=false;
      this.isCargoAgentNameNo=false;
      this.iscargoInputDateTime=false;
      this.isPreviousBtn=true;
    }
} 

handleReDesFailOption(event){
    const inputValue = event.target.value;
    this.reDesFailOptionsVal=inputValue;
    if(this.reDesFailOptionsVal!=='none'){
       this.isCargButtons=true;
       this.isPreviousBtn=false;
    }else if(this.reDesFailOptionsVal ==='none'){
       this.isCargButtons=false;
       this.isPreviousBtn=true;
    }
} 

handleDelivSuccessOption(event){
    const inputValue = event.target.value;
    this.delivSuccessOptionsVal=inputValue;
    if(this.delivSuccessOptionsVal!=='none'){
       this.isCargButtons=true;
       this.isCargoAgentNameNo=true;
       this.iscargoInputDateTime=true;
       this.isPreviousBtn=false;
    }else if(this.delivSuccessOptionsVal ==='none'){
       this.isCargoAgentNameNo=false;
       this.iscargoInputDateTime=false;
       this.isPreviousBtn=true;
    }
} 
handleDelivFailOption(event){
    const inputValue = event.target.value;
    this.delivFailOptionsVal=inputValue;
    if(this.delivFailOptionsVal!=='none'){
       this.isCargButtons=true;
       this.isPreviousBtn=false;
    }else if(this.delivFailOptionsVal ==='none'){
       this.isCargoAgentNameNo=false;
       this.iscargoInputDateTime=false;
       this.isPreviousBtn=true;
    }
} 

handlecargoDelStatus(event){
    const inputValue = event.target.value;
    this.cargoDelStatusOptionsVal=inputValue;
    if(this.cargoDelStatusOptionsVal!=='none'){
       this.isCargButtons=true;
       this.isPreviousBtn=false;
    }else if(this.cargoDelStatusOptionsVal ==='none'){
       this.isCargoAgentNameNo=false;
       this.iscargoInputDateTime=false;
       this.isPreviousBtn=true;
    }
}


/*---*/
  handleStageOptionChange(event){
    const inputValue = event.target.value;
    this.stageOptionsVal=inputValue;
    console.log('---al-'+this.stageOptionsVal);
      if (this.stageOptionsVal === 'Primer recojo programado'){
            this.isstatusOptionsVal = true;
            this.isFrMailPicAgentSucOptions =false;
            this.isPicAgstatusOptionsVal=false;
            this.isFrMailSucOptions =false;
            this.isFrMailFailOptions =false;
            this.isButtons = false;
            this.isAgentNameNo =false;
            this.statusOptionsVal ='none';
            this.isInputDateTime=false;
            this.isFrMailPicAgentFailOptions=false;
            this.isfrsMailDelStatus =false
            this.isPreviousBtn=true;
            this.frMailFailOptionsVal ='none';
            this.picByAgentstatusOptionsVal ='none';
      }else if( this.stageOptionsVal === 'Paquete recogido por el agente' ) {
            this.isstatusOptionsVal = false;
            this.isFrMailSucOptions=false;
            this.isPicAgstatusOptionsVal =true;
            this.isFrMailPicAgentFailOptions=false;
            this.isFrMailSucOptions =false;
            this.isFrMailFailOptions =false;
            this.isAgentNameNo =false;
            this.statusOptionsVal ='none';
            this.isButtons = false;
            this.isPreviousBtn=true; 
            this.isInputDateTime=false; 
            this.isfrsMailDelStatus =false 
            this.frMailFailOptionsVal ='none'; 
            this.picByAgentstatusOptionsVal ='none';       
      }else if (this.stageOptionsVal  ==='none') {
            this.isstatusOptionsVal = false;
            this.isButtons = false;
            this.isAgentNameNo =false;
            this.isPreviousBtn=false;
            this.isFrMailSucOptions = false;
            this.isFrMailFailOptions = false;
            this.isPicAgstatusOptionsVal =false;
             this.isFrMailPicAgentFailOptions=false;
            this.isFrMailPicAgentSucOptions =false;
            this.statusOptionsVal ='none';
            this.picByAgentstatusOptionsVal ='none';
            this.frMailSuccessOptionsVal = 'none';
            this.frMailFailOptionsVal ='none';
            this.frMailPickedByAgntSucOptionsVal='none';
            this.frMailPickedByAgntFailOptionsVal ='none';
            this.isPreviousBtn=true;
            this.isInputDateTime=false;
            this.isfrsMailDelStatus =false;
        }

  }

handleStatusOptionChange(event){
    const inputValue = event.target.value;
    this.statusOptionsVal=inputValue;
    console.log('>>statusOpVal>',this.statusOptionsVal);
      if (this.statusOptionsVal === 'SUCCESS') {
            this.isFrMailSucOptions = true;
            this.isFrMailFailOptions = false;
            this.isAgentNameNo =false;
            this.frMailSuccessOptionsVal='none';
            this.isPreviousBtn=true;
            this.isInputDateTime=false;
            this.isfrsMailDelStatus =false
        } else if (this.statusOptionsVal === 'FAILURE') {
            this.isFrMailSucOptions = false;
            this.isFrMailFailOptions = true;
            this.isButtons = false;
            this.frMailSuccessOptionsVal='none';
            this.isAgentNameNo =false;
            this.isPreviousBtn=true;
            this.isfrsMailDelStatus =false
            this.isInputDateTime=false;
        } else if (this.statusOptionsVal ==='none'){
            this.isFrMailSucOptions = false;
            this.isFrMailFailOptions = false;
            this.frMailSuccessOptionsVal='none';
            this.frMailFailOptionsVal='none';
            this.isButtons = false;
            this.isfrsMailDelStatus =false
            this.isAgentNameNo =false;
            this.isPreviousBtn=true;
            this.isInputDateTime=false;


        }
  }

  handlefrMailSuccessOption(event){
    const inputValue = event.target.value;
    this.frMailSuccessOptionsVal=inputValue;
      if (this.frMailSuccessOptionsVal!=='none') {
            this.isButtons = true;
            this.isAgentNameNo =true;
            this.isfrsMailDelStatus =true
            this.isPreviousBtn=false;
            this.isInputDateTime=true;
            this.frMailDelStatusOptionsVal ='none';

        } else if (this.frMailSuccessOptionsVal==='none') {
            this.isButtons = false;
            this.isAgentNameNo =false;
            this.frMailDelStatusOptionsVal ='none';
            this.isInputDateTime=false;
            this.isfrsMailDelStatus =false
            this.isPreviousBtn=true;
        }
  }

  handlefrMailFailOption(event){
    const inputValue = event.target.value;
    this.frMailFailOptionsVal=inputValue;
     if (this.frMailFailOptionsVal!=='none') {
            this.isButtons = true;
            this.isInputDateTime=false;
            this.isPreviousBtn=false;
        } if (this.frMailFailOptionsVal ==='none') {
            this.isButtons = true;
            this.isInputDateTime=false;
            this.isPreviousBtn=true;
        }
  }
  
handlePicAgntStatusOptionChange(event){
 const inputValue = event.target.value;
    this.picByAgentstatusOptionsVal=inputValue;
      if (this.picByAgentstatusOptionsVal === 'SUCCESS') {
            this.isFrMailPicAgentSucOptions = true;
            this.isFrMailPicAgentFailOptions = false;
            this.isInputDateTime=false;
            this.isfrsMailDelStatus =false;
            this.frMailPickedByAgntSucOptionsVal='none';
            this.frMailPickedByAgntFailOptionsVal='none';
            this.isAgentNameNo =false;
            this.isPreviousBtn=true;
            this.frMailDelStatusOptionsVal='none';
        } else if (this.picByAgentstatusOptionsVal === 'FAILURE') {
            this.isFrMailPicAgentFailOptions = true;
            this.isFrMailPicAgentSucOptions =false;
            this.isButtons = false;
            this.isInputDateTime=false;
            this.isfrsMailDelStatus =false;
            this.frMailDelStatusOptionsVal='none';
            this.frMailPickedByAgntSucOptionsVal='none';
            this.frMailPickedByAgntFailOptionsVal='none';
            this.isAgentNameNo =false;
            this.frMailDelStatusOptionsVal='none';
            this.isPreviousBtn=true;
        } else if (this.picByAgentstatusOptionsVal ==='none'){
            this.isFrMailPicAgentFailOptions = false;
            this.isFrMailPicAgentSucOptions =false;
            this.frMailPickedByAgntSucOptionsVal='none';
            this.isInputDateTime=false;
            this.frMailPickedByAgntFailOptionsVal='none';
            this.frMailDelStatusOptionsVal='none';
            this.isButtons = false;
            this.isAgentNameNo =false;
            this.frMailDelStatusOptionsVal='none';
            this.isfrsMailDelStatus =false;
            this.isPreviousBtn=true;
        }   
}

handlefrMailDelStatus(event){
  const inputValue = event.target.value;
        this.frMailDelStatusOptionsVal = event.detail.value;
       if (this.frMailDelStatusOptionsVal!=='none') {
            
        } else if (this.frMailDelStatusOptionsVal==='none') {
          
        }
}

handleDatetimeChange(event) {
  this.inputDateTimeVal = event.target.value;
  console.log('Selected Datetime:', this.inputDateTimeVal);
}

handleCargoDatetimeChange(event) {
     this.cargoinputDateTimeVal = event.target.value;
  console.log('Cargo Selected Datetime:', this.cargoinputDateTimeVal);
}

handlefrMailPickedByAgntSuc(event) {
        const inputValue = event.target.value;
        this.frMailPickedByAgntSucOptionsVal = event.detail.value;
        console.log('><'+this.frMailPickedByAgntSucOptionsVal);
       if (this.frMailPickedByAgntSucOptionsVal!=='none') {
            this.isButtons = true;
            this.isfrsMailDelStatus =true;
            this.isInputDateTime=true;
            this.isAgentNameNo =true;
            this.isPreviousBtn=false;
            this.frMailDelStatusOptionsVal='none';
        } else if (this.frMailPickedByAgntSucOptionsVal==='none') {
            this.isButtons = false;
            this.isfrsMailDelStatus =false;
            this.isInputDateTime = false;
            this.isfrsMailDelStatus =false;
            this.isAgentNameNo =false;
            this.frMailDelStatusOptionsVal='none';
        }
    }

handlefrMailPickedByAgntFail(event){
         const inputValue = event.target.value;
       this.frMailPickedByAgntFailOptionsVal = event.detail.value;
        if (this.frMailPickedByAgntFailOptionsVal!=='none') {
            this.isButtons = true;
            this.isAgentNameNo =false;
            this.isInputDateTime=false;
            this.isPreviousBtn=false;
        } else if (this.frMailPickedByAgntFailOptionsVal==='none') {
            this.isButtons = false;
            this.isAgentNameNo =false;
            this.isInputDateTime=false;
            this.isPreviousBtn=true;
        }
    }

clickTrackingUpdateMethod(){
  console.log('--Upade--');
  console.log('--btn--'+this.radioBtnVal);
  console.log('--stage--'+this.stageOptionsVal);
  if(this.radioBtnVal === 'cargoBtn'){
          this.radioBtnVal='CARGO';
       if(this.cargoStageOptionsVal ==='Encomienda entregada al operador de transporte'){
          if(this.cargoPacDrpMidstatusOptionsVal==='SUCCESS'){
            this.updateTrackingStatus(this.radioBtnVal,this.cargoStageOptionsVal,this.cargoPacDrpMidstatusOptionsVal,this.pacDrpMidSuccessOptionsVal,this.cargoDelStatusOptionsVal,this.cargoinputDateTimeVal,this.cargoagentName,this.cargoPhoneNumber,this.cargCommentsVal);
          }else if(this.cargoPacDrpMidstatusOptionsVal==='FAILURE'){
            this.updateTrackingStatus(this.radioBtnVal,this.cargoStageOptionsVal,this.cargoPacDrpMidstatusOptionsVal,this.pacDrpMidFailOptionsVal,this.cargoDelStatusOptionsVal,this.cargoinputDateTimeVal,this.cargoagentName,this.cargoPhoneNumber,this.cargCommentsVal);
          }
       }else if(this.cargoStageOptionsVal ==='Paquete en tránsito'){
          if(this.cargoPacIntrnsStatusOptionsVal==='SUCCESS'){
            this.updateTrackingStatus(this.radioBtnVal,this.cargoStageOptionsVal,this.cargoPacIntrnsStatusOptionsVal,this.pacIntrnsSuccessOptionsVal,this.cargoDelStatusOptionsVal,this.cargoinputDateTimeVal,this.cargoagentName,this.cargoPhoneNumber,this.cargCommentsVal);
          }else if(this.cargoPacIntrnsStatusOptionsVal==='DELAYED'){
            this.updateTrackingStatus(this.radioBtnVal,this.cargoStageOptionsVal,this.cargoPacIntrnsStatusOptionsVal,this.pacIntrnsFailOptionsVal,this.cargoDelStatusOptionsVal,this.cargoinputDateTimeVal,this.cargoagentName,this.cargoPhoneNumber,this.cargCommentsVal);
          }
       } else if(this.cargoStageOptionsVal ==='Llegó al destino'){
          if(this.cargoReDesStatusOptionsVal==='SUCCESS'){
            this.updateTrackingStatus(this.radioBtnVal,this.cargoStageOptionsVal,this.cargoReDesStatusOptionsVal,this.reDesSuccessOptionsVal,this.cargoDelStatusOptionsVal,this.cargoinputDateTimeVal,this.cargoagentName,this.cargoPhoneNumber,this.cargCommentsVal);
          }else if(this.cargoReDesStatusOptionsVal==='FAILURE'){
            this.updateTrackingStatus(this.radioBtnVal,this.cargoStageOptionsVal,this.cargoReDesStatusOptionsVal,this.reDesFailOptionsVal,this.cargoDelStatusOptionsVal,this.cargoinputDateTimeVal,this.cargoagentName,this.cargoPhoneNumber,this.cargCommentsVal);
          }
       }else if(this.cargoStageOptionsVal ==='Entregado'){
          if(this.cargoDelivStatusOptionsVal==='SUCCESS'){
            this.updateTrackingStatus(this.radioBtnVal,this.cargoStageOptionsVal,this.cargoDelivStatusOptionsVal,this.delivSuccessOptionsVal,this.cargoDelStatusOptionsVal,this.cargoinputDateTimeVal,this.cargoagentName,this.cargoPhoneNumber,this.cargCommentsVal);
          }else if(this.cargoDelivStatusOptionsVal==='FAILURE'){
            this.updateTrackingStatus(this.radioBtnVal,this.cargoStageOptionsVal,this.cargoDelivStatusOptionsVal,this.delivFailOptionsVal,this.cargoDelStatusOptionsVal,this.cargoinputDateTimeVal,this.cargoagentName,this.cargoPhoneNumber,this.cargCommentsVal);
          }
       }
  }else if(this.radioBtnVal==='firstMileBtn'){
     this.radioBtnVal='FIRST_MILE';
      console.log('----firstMileBtn--');
      if(this.stageOptionsVal ==='Primer recojo programado'){
          if(this.statusOptionsVal==='SUCCESS'){
             this.updateTrackingStatus(this.radioBtnVal,this.stageOptionsVal,this.statusOptionsVal,this.frMailSuccessOptionsVal,this.frMailDelStatusOptionsVal,this.inputDateTimeVal,this.agentName,this.phoneNumber,this.commentsVal);
          }else if(this.statusOptionsVal==='FAILURE'){
             console.log('--this.statusOptionsVal---'+this.statusOptionsVal);
             this.updateTrackingStatus(this.radioBtnVal,this.stageOptionsVal,this.statusOptionsVal,this.frMailFailOptionsVal,this.frMailDelStatusOptionsVal,this.inputDateTimeVal,this.agentName,this.phoneNumber,this.commentsVal);
          }
       }else if(this.stageOptionsVal ==='Paquete recogido por el agente'){
          if(this.picByAgentstatusOptionsVal==='SUCCESS'){
             this.updateTrackingStatus(this.radioBtnVal,this.stageOptionsVal,this.picByAgentstatusOptionsVal,this.frMailPickedByAgntSucOptionsVal,this.frMailDelStatusOptionsVal,this.inputDateTimeVal,this.agentName,this.phoneNumber,this.commentsVal);
          }else if(this.picByAgentstatusOptionsVal==='FAILURE'){
             this.updateTrackingStatus(this.radioBtnVal,this.stageOptionsVal,this.picByAgentstatusOptionsVal,this.frMailPickedByAgntFailOptionsVal,this.frMailDelStatusOptionsVal,this.inputDateTimeVal,this.agentName,this.phoneNumber,this.commentsVal);
          }
       } 
  }
}

updateTrackingStatus(stageTypeVal,stageVal,stageStatusVal,reasonVal,deliveryStatusVal,stageDateVal,agentNameVal,phoneNoVal,commentsVall) {
    console.log('>>>>>this.recordId>>>' + this.recordId+'--stage--'+stageTypeVal);
    updateCargoTrackingDetails({
      ItemId: this.recordId,tracStageType:stageTypeVal,tracStage:stageVal,tracStageStatus:stageStatusVal,tracReason:reasonVal,
      tracDelStatus:deliveryStatusVal,tracStageDate:stageDateVal,tracAgentName:agentNameVal,
      tracPhoneNo:phoneNoVal,tracComments:commentsVall
      })
      .then((result) => {
        console.log('>>result>>'+result);
         if (result != '' && result != null && result==='Tracking Updated Successfully'){
            this.successMsg = 'Successfully Tracking Updated';
            this.displayToastMessage(this.successMsg, 'success');
            this.showFirstMailProcess =false;
            this.showCargoProcess  = false;
            this.isSuccessfulTrackingUpd =true;
            //this.isPreviousBtn = true;
         }else{
            this.successMsg = result;
            this.displayToastMessage(this.successMsg, 'Error');
            this.isSuccessfulTrackingUpd =true;
            this.showFirstMailProcess =false;
            this.showCargoProcess  = false;
            //this.isPreviousBtn = true;
         }
      })
      .catch((error) => {
        console.log('>>result>>'+error);
      });

  }

   displayToastMessage(msg, type) {
    const toastEvt = new ShowToastEvent({
      title: type,
      message: msg,
      variant: type,
      mode: 'dismissable'
    });
    this.dispatchEvent(toastEvt);
  }

}