import { LightningElement,api,wire,track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import NAME from '@salesforce/schema/User.Name';
import CENTER from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import {getRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ISBPR from '@salesforce/customPermission/AV_PrivateBanking';


import searchClients from '@salesforce/apex/AV_NewEvent_Controller.searchClients';
import searchEmployee from '@salesforce/apex/AV_NewEvent_Controller.searchEmployees';
import searchContact from '@salesforce/apex/AV_NewEvent_Controller.searchContact';
import searchAttende from '@salesforce/apex/AV_NewEvent_Controller.searchAttendees';
import searchOffice from '@salesforce/apex/AV_NewEvent_Controller.searchOffice';

export default class Av_NewEventReportDetail extends LightningElement {

    @api clientinfo;//Contiene el id y el bombre del cliente
    
    initialemployee;
    error;
    initialclient = null;
    //variables de input

    clientToSend;
    employeeToSend = USER_ID;
    centerToSend;
    contactToSend;
    attendesToSend = [];
    subjectToSend;
    comentaryToSend;
    selectedAttendesToSend = [];
    typeToSend;
    activityDateToSend = this.tomorrow;
    today = new Date().toJSON().slice(0,10);
    durationToSend;
    ubicationToSend;
    officeToSend;
    otherOfficeNumberToSend;
    memorableInterviewToSend = false;
    //
    //Variables de if:true
    attendes = false;
    isIntouch;
    showUbication;
    showOfficeInput;
    isPersonaJuridica;
    disabledContact=false;
    isBpr = ISBPR;
    //

    @track selectedAttendes = [];
    multiSelectionAttendee = 0;
    initialDuration;
    mapTypeDuration = {
            'CTO':'60',
            'CTF':'30',
            'VLD':'30',
            'CTOOC':'60',
            '001':'60'
    }

    get CTOLabel(){
        return 'Cita en mi oficina - '+this.centerToSend;
    }
    get tomorrow(){
        let msInADay = 24*60*60*1000;
        let msForTomorrow = (new Date().getTime()) + msInADay;
        return  new Date(msForTomorrow).toJSON().slice(0,10);
        
    }

    get optionsTime(){

        return [
            {label:'5 min',value:'5'},
            {label:'15 min',value:'15'},
            {label:'30 min',value:'30'},
            {label:'1 h',value:'60'},
            {label:'2 h',value:'120'}
            ]

    }
 
	@wire(getRecord, {recordId:USER_ID,fields:[NAME,CENTER]})
    wiredUser({error, data}) {    
        if (data && this.clientinfo != null && this.initialclient == null)  { 
            this.clientToSend = this.clientinfo.accountId;
            this.initialemployee = [{id:USER_ID,title:data.fields.Name.value,icon:'standard:account'}];
			this.initialclient = (this.clientToSend != null) ? [{id:this.clientinfo.accountId,title:this.clientinfo.name,icon:'standard:user'}] : null;
            this.isIntouch = (this.clientinfo.intouch == 'true')?true:false;
            this.typeToSend =(this.isIntouch) ? 'CTF' : 'CTO';
            this.initialDuration = (this.isIntouch) ? '30' : '60';
            this.durationToSend = parseInt(this.initialDuration,10);
            this.isPersonaJuridica = this.clientinfo.recordtype == 'CC_Cliente';
            this.centerToSend = data.fields.AV_NumeroOficinaEmpresa__c.value.split('-')[1];
            this.sendEventInfoToParent();
            
        } else if (error) {
            this.error = error ;
        }
    }

    handleSearchClient(e){
        searchClients({searchTerm:e.detail.searchTerm})
            .then(result => {
                if(result != null){
                    this.template.querySelector('[data-id="clientlookup"]').setSearchResults(result);
                }
            }).catch(error =>{
                console.log(error);
            })

    }

    handleSelectionClient(){
        let clientSelection = this.template.querySelector('[data-id="clientlookup"]').getSelection()[0];
        if( clientSelection != null && clientSelection != undefined){
            this.clientToSend= clientSelection.id;
            this.sendEventInfoToParent(true);
            this.disabledContact = false;
        }else{
            this.disabledContact = true;
            this.clientToSend = null;
            this.sendEventInfoToParent(true);
        }
    }

    handleSearchEmployee(e){
        searchEmployee({searchTerm:e.detail.searchTerm})
        .then(result => {
            if(result != null){
                this.template.querySelector('[data-id="employeelookup"]').setSearchResults(result);
            }
        }).catch(error =>{
            console.log(error);
        })
    }
    handleSelectionEmployee(){
        let employeeSelection = this.template.querySelector('[data-id="employeelookup"]').getSelection()[0];
        if(employeeSelection != null && employeeSelection != undefined ){
            this.employeeToSend= employeeSelection.id;
            this.centerToSend = employeeSelection.subtitle.split('-')[1]
            this.sendEventInfoToParent();
        }else{
            this.employeeToSend= null;
        }
        
    }
    handleSearchContactPerson(e){
        searchContact({searchTerm:e.detail.searchTerm,selectedIds:null,accountId:this.clientToSend})
        .then(result => {
            if(result != null){
                this.template.querySelector('[data-id="contactpersonlookup"]').setSearchResults(result);
            }
        }).catch(error =>{
            console.log(error);
        })
    }
    handleSelectionContactPerson(){
        let contactSelection = this.template.querySelector('[data-id="contactpersonlookup"]').getSelection()[0];
        if(contactSelection != null && contactSelection != undefined ){
            this.contactToSend= contactSelection.id;
            this.sendEventInfoToParent();
        }else{
            this.contactToSend= null;
        }
    }

    handleSearchAttendes(e){
        searchAttende({searchTerm:e.detail.searchTerm,selectedIds:this.selectedAttendesToSend})
        .then(result => {
            if(result != null){
                this.template.querySelector('[data-id="attendeeslookup"]').setSearchResults(result);
            }
        }).catch(error =>{
            console.log(error);
        })
        
    }
    
    handleSelectionAttendee(){
        let attendeeLookup = this.template.querySelector('[data-id="attendeeslookup"]');
        let attendeeSelection = attendeeLookup.getSelection()[0];
        if(attendeeSelection != null && attendeeSelection != undefined ){
            this.selectedAttendes.push(
                {
                    id:attendeeSelection.id,
                    label:attendeeSelection.title,
                    bucleId:++this.multiSelectionAttendee}
            );

            this.attendes = true;
            attendeeLookup.handleClearSelection();
            this.sendEventInfoToParent();
        }
            
    }
    handleRemoveAttende(e){
        let idToDel = e.target.name;
        for(let i=0; i < this.selectedAttendes.length ; i++){
            if(this.selectedAttendes[i].id === idToDel){
                this.selectedAttendes.splice(i,1);
                break;
            }
        }

        this.sendEventInfoToParent();
        this.attendes = this.selectedAttendesToSend.length > 0;
    }

    handleChangeSubject(e){
        this.subjectToSend = e.target.value;
        this.sendEventInfoToParent();
    }

    handleChangeComentary(e){
        this.comentaryToSend = e.target.value;
        this.sendEventInfoToParent();
    }

    handleMemorableInterview(e){
        this.memorableInterviewToSend = e.target.checked;
        this.sendEventInfoToParent();
    }
    
    hnadleChangeEventType(e){
        this.typeToSend = e.target.value;
        this.initialDuration = this.mapTypeDuration[this.typeToSend];
        this.showUbication = (this.typeToSend == '001' );
        this.showOfficeInput = this.typeToSend == 'CTOOC';
        this.ubicationToSend = null;
        this.officeToSend = null;
        this.otherOfficeNumberToSend = null;
        this.sendEventInfoToParent();
    }
    
    handleChangeActivityDate(e){
        this.template.querySelector('[data-id="activityDateInput"]').reportValidity();

        // let oldValue = this.activityDateToSend;
        // if(dateInput.reportValidity()){
            this.activityDateToSend = e.target.value;
            this.sendEventInfoToParent();
        // }else{
            // dateInput.value = oldValue;
        // }
    }

    handleChangeDuration(e){
            this.durationToSend = parseInt(e.target.value);
            this.sendEventInfoToParent();
    }
    
    handleChangeUbication(e){
        this.ubicationToSend = e.target.value;
        this.sendEventInfoToParent();


    }

    handleSearchOffice(e){
        searchOffice({searchTerm:e.detail.searchTerm,selectedIds:null})
        .then(result => {
            if(result != null){
                this.template.querySelector('[data-id="officelookup"]').setSearchResults(result);
            }
        }).catch(error =>{
            console.log(error);
        })
    }

    handleSelectionOffice(){
      let officeSelection = this.template.querySelector('[data-id="officelookup"]').getSelection()[0];
        if(officeSelection != null && officeSelection != undefined ){
            this.officeToSend= officeSelection.id;
            this.otherOfficeNumberToSend = officeSelection.subtitle.substring(officeSelection.subtitle.length -5);
            this.sendEventInfoToParent();
        }else{
            this.officeToSend= null;
        }
    }
   
    sendEventInfoToParent(changeClient){
        if(changeClient == undefined){
            changeClient = false;
        }
        this.selectedAttendesToSend = [];
        if(this.selectedAttendes.length > 0){
            this.selectedAttendes.forEach(att =>{
                this.selectedAttendesToSend.push(att.id);
            });
        }
        this.dispatchEvent(
        new CustomEvent('eventinfo',{
                detail:{
                    client:this.clientToSend,
                    owner:this.employeeToSend,
                    center:this.centerToSend,
                    personaContacto:this.contactToSend,
                    attendes:this.selectedAttendesToSend,
                    subject:this.subjectToSend,
                    comentary:this.comentaryToSend,
                    type:this.typeToSend,
                    activityDate:this.activityDateToSend,
                    duration:this.durationToSend,
                    ubication:this.ubicationToSend,
                    office:this.officeToSend,
                    otherOfficeNumber:this.otherOfficeNumberToSend,
                    memorableInterview:this.memorableInterviewToSend,
                    changeClient: changeClient
                }
            }
            )
        )
    }



    @api
    validateRequiredInputs(){
        if(this.clientToSend == null){
           this.scrollIntoElement('clientlookup');
           this.showToast('Faltan datos','Introduce un cliente para la cita','error')
           return false;
        }
        
        if(this.employeeToSend == null){
            this.showToast('Faltan datos','Introduce un empleado para la cita','error')
            this.scrollIntoElement('employeelookup');
            return false;
        }
        
        if(this.subjectToSend == null || !this.template.querySelector('[data-id="subjectinput"]').reportValidity()){ 
            this.showToast('Faltan datos','Porfavor, introduce un asunto para la cita','error')
            
            this.template.querySelector('[data-id="subjectinput"]').click();
            this.template.querySelector('[data-id="subjectinput"]').focus();
            this.scrollIntoElement('subjectinput');
            return false;
        }
        
        if(this.typeToSend == null){
            this.scrollIntoElement('radioButtonDiv');
            this.showToast('Faltan datos','Introduce un tipo para la cita','error')
            //Ya veremos
            
            return false;
        }
        
        if(this.activityDateToSend == null || !this.template.querySelector('[data-id="activityDateInput"]').reportValidity() ){
            //Ya veremos
            this.scrollIntoElement('activityDateInput');
            this.showToast('Faltan datos','Por favor, introduce una fecha futura','error')
            
            return false;
        }


        
        if(this.officeToSend == null && this.showOfficeInput){
            this.showToast('Faltan datos','Para este tipo de cita es necesario indicar una oficina','error')
            // this.template.querySelector('[data-id="officelookup"]').style.border = "2px solid red";
            this.scrollIntoElement('officelookup');
            return false;
        }
        return true;
    }

    scrollIntoElement(id){
        this.template.querySelector('[data-id="'+id+'"]').scrollIntoView({
            behavior: 'auto',
            block: 'center',
            inline: 'center'
        });;
    }

    showToast(title, message, variant) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: 'pester'
		});
		this.dispatchEvent(event);
	}



}