import { LightningElement, api , wire, track}   from 'lwc';
import { getRecord }                            from 'lightning/uiRecordApi';
import { ShowToastEvent }                       from 'lightning/platformShowToastEvent';
import { NavigationMixin }                      from 'lightning/navigation';
import userId                                   from "@salesforce/user/Id";

import getStatusValues      from '@salesforce/apex/CIBE_NewOpportunity_Controller.getStatusValues';
import getOppFields         from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getOppFields';
import unlinkOpp            from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.unlinkOpp';
import updateMain           from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.updateMainRecord';
import linkOpp              from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.linkOpp';
import getOppTeamMember     from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getOppTeamMember';

//Label
import successLabel             from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successUnlinkMsgLabel    from '@salesforce/label/c.AV_CMP_SuccessUnlinkOpp';
import successMsgLabel          from '@salesforce/label/c.AV_CMP_SaveMsgSuccess';
import etapa                    from '@salesforce/label/c.CIBE_Etapa';
import vincularOportunidad      from '@salesforce/label/c.CIBE_VincularOportunidad';
import desvincularOportunidad   from '@salesforce/label/c.CIBE_DesvincularOportunidad';
import correcto                 from '@salesforce/label/c.CIBE_Correcto';
import oppVinEx                 from '@salesforce/label/c.CIBE_OportunidadVinculadaExito';
import error                    from '@salesforce/label/c.CIBE_Error';
import errorVinOpp              from '@salesforce/label/c.CIBE_ErrorVincularOportunidad';
import marcarPrincipal          from '@salesforce/label/c.CIBE_MarcarOppPrincipal';
import oppPrincipal             from '@salesforce/label/c.CIBE_OportunidadPrincipal';


export default class Cibe_DetailOppNewEvent extends NavigationMixin (LightningElement) {

    labels = {
        etapa, 
        vincularOportunidad,
        desvincularOportunidad,
        correcto,
        oppVinEx,
        error,
        errorVinOpp,
        marcarPrincipal,
        oppPrincipal
    };

    @api oppid;
    @api editable = false;
    @api principal;
    @api single;
    @api event;
    
    @track showSpinner = true;
    @track allStages = [];
    @track currentOpportunity;
    @track currentName;
    @track newLastComent;
    @track showDetail = false;

    @track encurso;
    @track aprobado;
    @track riesgos;
    @track cerradonegativo;
    @track status;
    @track exito;
    @track amount;
    @track closedate;
    @track lastcoment;

    @track isOppTeamMember;
    @track editMode;

    connectedCallback() {
        if(this.principal) {
            this.showDetail = true;
        }
        this.getOpportunityTeam();
    }

    @wire(getRecord, { recordId: '$oppid', fields: ['Opportunity.Id', 'Opportunity.Name', 'Opportunity.StageName'] })
    getOppFieldsWire( {data, error}) {
        if(data) {
            this.currentOpportunity = data;
            this.currentName = data.fields.Name.value;
            this.status = data.fields.StageName.value;
            this.showSpinner = false;
        } else if (error) {
            console.log(error);
        } 
    }

    @wire(getStatusValues, {objectName: 'Opportunity', fieldName: 'StageName'})
    getStatusValuesWire( {data, error}) {
        if(data) {
            this.pathValues(data);
        } else if (error) {
            console.log(error);
        }
    }

    getOpportunityTeam(){
        getOppTeamMember({opportunityId: this.oppid, currentUser: userId})
        .then(result => {
            console.log('### result ', result);
            this.isOppTeamMember = result;
            this.editMode = !result;
        })

    }

    pathValues(listValues) {
        var aux = [];
        for(var value of listValues) {
            aux.push({value: value.value, label: value.label});
        }
        this.allStages = this.allStages.concat(aux);
    }

    handleUnlink() {
        this.showSpinner = true;
		unlinkOpp({oppTask: this.oppid, recordId: this.event})
			.then(() => {
                this.showSpinner = false;
				this.showToast(successLabel, successUnlinkMsgLabel, 'success', 'pester');
                this.refreshParentLink();
			})
			.catch(error => {
                this.showSpinner = false;
				this.showToast('Error', error.body.message, 'error', 'pester');
                this.refreshParentLink();
		});
	}

    showToast(title, message, variant, mode) {
		this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
		}));
	}

    handleNavigateOpp() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.oppid,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

    toggleShowOpp() {
        if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
    }

    refreshParentLink() {
        this.dispatchEvent(new CustomEvent('refreshlinkrelated'));
    }
	
    updateMainOppTask() {
        this.showSpinner = true;
        updateMain({event: this.event, opp: this.oppid})
            .then(() => {
                this.showSpinner = false;
                this.showToast(successLabel, successMsgLabel, 'success', 'pester');
                this.refreshParentLink();
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('Error', error.body.message, 'error', 'pester');
                this.refreshParentLink();
        });
    }

    handlelink() {
        this.showSpinner = true;
        linkOpp({recordId: this.event, opp: this.oppid})
            .then(result => {
                this.showSpinner = false;
                if(result === 'OK') {
                    this.showToast(this.labels.correcto, this.labels.oppVinEx, 'success');
                } else if(result === 'KO') {
        errorVinOpp
                    this.showToast(this.labels.error, this.labels.errorVinOpp, 'error');
                }
                this.refreshParentLink();
            })
            .catch(error => {
                this.showToast(this.labels.error, this.labels.errorVinOpp, 'error');
                this.refreshParentLink();
            });
            
    }

    get showVincular () {
        return ((this.single && this.principal) || !this.principal);
    }

    get isEnCurso () {
        return this.status == 'En curso';
    }

    get isCerradoNegativo () {
        return this.status == 'Cerrado negativo';
    }

    handleDataPadre(){
        this.dispatchEvent(
            new CustomEvent('datareport', {
                detail: {
                    Id: this.oppid,
                    CIBE_EnCurso__c: this.encurso,
                    CIBE_Aprobadoprecio__c: this.aprobado,
                    CIBE_Aprobadoriesgos__c: this.riesgos,
                    CIBE_CerradoNegativo__c: this.cerradonegativo,
                    StageName: this.status,
                    CIBE_ProbabilidadExito__c: this.exito,
                    Amount: this.amount,
                    CloseDate: this.closedate,
                    AV_Comentarios__c: this.lastcoment
                }
        }));
    }
    
    handleStageName(event){
        this.status=event.detail.newValue;
        this.handleDataPadre();
    }

    handleEnCurso(event){
        this.encurso=event.target.value;
        this.handleDataPadre();
    }

    handleAprobado(event){
        this.aprobado=event.target.value;
        this.handleDataPadre();
    }

    handleRiesgos(event){
        this.riesgos=event.target.value;
        this.handleDataPadre();
    }

    handleCerradoNegativo(event){
        this.cerradonegativo=event.target.value;
        this.handleDataPadre();
    }

    handleExito(event){
        this.exito=event.target.value;
        this.handleDataPadre();
    }

    handleAmount(event){
        this.amount=event.target.value;
        this.handleDataPadre();
    }

    handleCloseDate(event){
        this.closedate=event.target.value;
        this.handleDataPadre();
    }

    handlelastComent(event){
        this.lastcoment=event.target.value;
        this.handleDataPadre();
    }

    handleOppSuccess(){
        this.showToast(successLabel, 'La oportunidad se ha guardado con exito', 'success', 'pester');
        /*this.currentStage = this.status;
        this.cambioStage = !this.cambioStage;
        this.handleDataPadre();
        console.log('### this.currentStage ', this.currentStage);
        console.log('### this.cambioStage ', this.cambioStage);*/
    }

    handleOppError(error){
        this.showToast('Error', error.body.message, 'error', 'pester');
    }
}