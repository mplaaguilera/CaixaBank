import { LightningElement, api , wire, track}   from 'lwc';
import { ShowToastEvent }                       from 'lightning/platformShowToastEvent';
import { NavigationMixin }                      from 'lightning/navigation';
import userId                                   from "@salesforce/user/Id";

import OPPORTUNITY_STAGENAME_FIELD  from '@salesforce/schema/Opportunity.StageName';
import OPPORTUNITY_OWNERID          from '@salesforce/schema/Opportunity.OwnerId';
import getStatusValues              from '@salesforce/apex/CIBE_NewOpportunity_Controller.getStatusValues';
import getOppFields                 from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getOppFields';
import unlinkOpp                    from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.unlinkOpp';
import updateMain                   from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.updateMainRecord';
import getOppTeamMember             from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getOppTeamMember';

//Label
import successLabel             from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successUnlinkMsgLabel    from '@salesforce/label/c.AV_CMP_SuccessUnlinkOpp';
import successMsgLabel          from '@salesforce/label/c.AV_CMP_SaveMsgSuccess';
import etapa                    from '@salesforce/label/c.CIBE_Etapa';
import vincularOportunidad      from '@salesforce/label/c.CIBE_VincularOportunidad';
import desvincularOportunidad   from '@salesforce/label/c.CIBE_DesvincularOportunidad';
import marcarPrincipal          from '@salesforce/label/c.CIBE_MarcarOppPrincipal';
import oppPrincipal             from '@salesforce/label/c.CIBE_OportunidadPrincipal';
import incluirClienteLabel from '@salesforce/label/c.CIBE_IncluirCliPriorizados';

export default class Cibe_DetailOppRelated extends NavigationMixin (LightningElement) {

    labels = {
        etapa, 
        vincularOportunidad,
        desvincularOportunidad,
        marcarPrincipal,
        oppPrincipal,
        incluirClienteLabel
    };

    @api recordId;
    @api customactivityopp;
    @api editable;
    @api principal;
    @api single;
    @api event;
    
    @track showSpinner = true;
    @track allStages = [];
    @track currentStage;
    @track currentOpportunity;
    @track currentName;
    @track lastComment;

    @track encurso;
    @track aprobado;
    @track riesgos;
    @track cerradonegativo;
    @track status;
    @track exito;
    @track amount;
    @track closedate;
    @track lastcoment;
    @track includePrior;
    @track proximoRecord;
    @track showDetail = false;

    @track isOppTeamMember;
    @track editMode;

    connectedCallback(){
        this.getStatus();
        this.getOppField();

        if(this.principal) {
            this.showDetail = true;
        }
        this.getOpportunityTeam();
     }

    getStatus(){
        getStatusValues({objectName: 'Opportunity', fieldName: 'StageName'})
            .then(result => {
                this.pathValues(result);
            })
            .catch(error => {
                console.log(error);
        });
    }
    pathValues(listValues) {
        var aux = [];
        for(var value of listValues) {
            aux.push({value: value.value, label: value.label});
        }
       
        this.allStages = this.allStages.concat(aux);
    }
    getOppField(){
        getOppFields({oppoId: this.customactivityopp})
            .then(result => {
                    if(result!=undefined || result!=null){
                        this.currentOpportunity = result;
                        this.currentStage = this.currentStage != null ? this.currentStage : this.currentOpportunity.StageName;
                        this.status      = this.status != null ? this.status : this.currentOpportunity.StageName;
                        this.currentName = this.currentOpportunity.Name;
                        this.lastComment = this.currentOpportunity.AV_Comentarios__c;
                        this.cerradonegativo = this.currentOpportunity.CIBE_CerradoNegativo__c;
                        this.exito       = this.currentOpportunity.CIBE_ProbabilidadExito__c;
                        this.amount      = this.currentOpportunity.CIBE_AmountDivisa__c;
                        this.closedate   = this.currentOpportunity.CloseDate;
                        this.includePrior = this.currentOpportunity.AV_IncludeInPrioritizingCustomers__c;
                        this.proximoRecord = this.currentOpportunity.AV_FechaProximoRecordatorio__c;

                    }
                this.showSpinner = false;
            })
            .catch(error => {
                console.log(error);
        });
    }

    getOpportunityTeam(){
        getOppTeamMember({opportunityId: this.customactivityopp, currentUser: userId})
        .then(result => {
            this.isOppTeamMember = result;
            this.editMode = !result;
        })

    }

    handleUnlink() {
        this.showSpinner = true;
		unlinkOpp({oppTask: this.customactivityopp, recordId: this.event})
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
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}

    handleNavigateOpp() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.customactivityopp,
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
        updateMain({event: this.event, opp: this.customactivityopp})
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

    get showVincular () {
        return ((this.single && this.principal) || !this.principal);
    }
    
    handleDataPadre(){
        const sendData = new CustomEvent('datareport', {
            detail: {
                id: this.customactivityopp,
                encurso: this.encurso,
                aprobado: this.aprobado,
                riesgos: this.riesgos,
                cerradonegativo: this.cerradonegativo,
                status: this.status,
                exito: this.exito,
                amount: this.amount,
                closedate: this.closedate,
                lastcoment: this.lastcoment,
                includePrior: this.includePrior,
                proximoRecord: this.proximoRecord
            }
        });
        this.dispatchEvent(sendData);
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
    handleStageName(event){
        this.status=event.detail.newValue;
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
    handleIncludePrior(event){
        this.includePrior=event.target.checked;
        this.handleDataPadre();
    }
    handleProximoRecord(event){
        this.proximoRecord=event.target.value;
        this.handleDataPadre();
    }

    // PATH DE LA OPORTUNIDAD
    get isEnCurso () {
        return this.status == 'En curso';
    }

    get isCerradoNegativo () {
        return this.status == 'Cerrado negativo';
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