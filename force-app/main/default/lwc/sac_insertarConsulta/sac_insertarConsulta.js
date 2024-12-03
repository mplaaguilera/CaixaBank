import { LightningElement, api, wire, track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';

import insertConsulta from '@salesforce/apex/SAC_LCMP_InsertarConsulta.insertarConsulta';
import tienePermisos from '@salesforce/apex/SAC_LCMP_InsertarPretension.tienePermisos';
import tienePermisosGrupo from '@salesforce/apex/SAC_LCMP_InsertarConsulta.tienePermisosGrupo';
import finalizarConsultas from '@salesforce/apex/SAC_Interaccion.finalizarConsultasCaso';
import getConsultas from '@salesforce/apex/SAC_Interaccion.getConsultasCaso';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Id from '@salesforce/user/Id';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case';
import MOTIVODEFINALIZADO_FIELD from '@salesforce/schema/SAC_Interaccion__c.SAC_MotivoDeFinalizado__c';

const fields = [
    'Case.Status',
    'Case.OwnerId'
];


export default class Sac_insertarConsulta extends NavigationMixin(LightningElement) {

    @api recordId;
    @api consultaId;
    @api spinnerLoading = false;
    @api tienePermisosEditar = false;
    @api tienePermisosEditarGrupo = false;
    @api tienePermisosEditarAccion = false;
    @api tienePermisosCrearConsulta = false;
    casetInfo;
    ownerId;
    vSeleccionador;
    @track finalizar = false;
    @track modalFinalizarConsulta = false;
    @track botonFinalizarConsulta = false;
    @track motivo;
    @track error;
    @track consultas = [];
    @track selectedCons;
    @track wiredConsultasList = [];
    

    _wiredResult;  
    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getRecord, {recordId: '$recordId', fields})
    actualCase({data, error}){
        if(data){
            this.casetInfo = data;
            this.ownerId = this.casetInfo.fields.OwnerId.value; 
        }            
    };

    @wire(tienePermisos, { idCaso: '$recordId'}) 
    mapaPermisos(result){ 
        if(result.data){
            this.tienePermisosEditar = result.data;    
        }else{
            this.ownerId == Id ? this.tienePermisosEditar = true :  this.tienePermisosEditar = false;
        }
    };

    @wire(tienePermisosGrupo, { idCaso: '$recordId'}) 
    mapaPermisosGrupo(result){ 
        if(result.data){
            this.tienePermisosEditarGrupo = result.data.tienePermisosGrupo; 
            this.tienePermisosEditarAccion = result.data.tienePermisosAccion; 

            if(this.tienePermisosEditarGrupo === true || this.tienePermisosEditarAccion === true){
                this.tienePermisosCrearConsulta = true;
            }
        }
    };
    
    @wire(getConsultas, { caseId: '$recordId', tienePermisosEditar: '$tienePermisosEditar', tienePermisosGrupo: '$tienePermisosCrearConsulta'}) 
    consulta(result){ 
        this.wiredConsultasList = result;
        if(result.data){
            this.consultas = result.data;
            if(this.consultas == '') {
                this.botonFinalizarConsulta = false;
            } else  {
                this.botonFinalizarConsulta = true;
            }
            
            this.error = null;           
        }else if (result.error) {
            this.error = result.error;
            this.botonFinalizarConsulta = false;
            this.consultas = null;
        }
    };

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVODEFINALIZADO_FIELD })
    getMotivoValues;

    insertarConsulta(){
        this.spinnerLoading = true;

        insertConsulta({consultaId: this.recordId})
            .then(result => {
            let nuevaId = result;
            const evt = new ShowToastEvent({
                title: 'Consulta creada',
                message: 'Se ha creado la consulta con éxito',
                variant: 'success'
            });
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: nuevaId,
                    objectApiName: 'SAC_Interaccion__c',
                    actionName: 'view'
                }
            });
              
            this.spinnerLoading = false;
            this.dispatchEvent(new RefreshEvent());

            })
            .catch(error => {

                const evt = new ShowToastEvent({
                    title: 'Fallo al crear la consulta',
                    message: error.body.message,
                    variant: 'error'
                });

                this.dispatchEvent(evt);
                this.spinnerLoading = false;
            })
    }


    abrirModalFinalizarConsulta() {
        this.spinnerLoading = true;
        refreshApex(this.wiredConsultasList);
        this.finalizar = false;
        this.modalFinalizarConsulta = true;
        this.spinnerLoading = false;
    }

    cerrarModalFinalizarConsulta() {
        this.finalizar = false;
        this.modalFinalizarConsulta = false;
    }

    handleMotivoChange(event) {
        this.motivo = event.target.value;
    }

    siguiente() {
        this.selectedCons = [];

        this.seleccionador();
        for(let i = 1; i < this.vSeleccionador.length; i++) {
            if(this.vSeleccionador[i].checked && this.vSeleccionador[i].type === 'checkbox') {
                this.selectedCons.push(this.vSeleccionador[i].value);
            }
        }
        if(this.selectedCons.length === 0) {
            const evt = new ShowToastEvent({
                title: 'Precaución',
                message: 'Recuerde seleccionar alguna de las consultas.',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
        } else {
            this.finalizar = true;
        }
    }

    finalizarConsultas () {
        this.spinnerLoading = true;
        if (this.motivo == null || this.motivo == '') {
            const evt = new ShowToastEvent({
                title: 'Precaución',
                message: 'Recuerde completar el motivo de finalizado.',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            this.spinnerLoading = false;
        } else {
            finalizarConsultas({idConsultas: this.selectedCons, motivo: this.motivo}).then(result => {
                const evt = new ShowToastEvent({
                    title: 'Éxito!',
                    message: 'Las consultas han sido finalizadas con éxito.',
                    variant: 'success'
                });
    
                this.spinnerLoading = false;
                refreshApex(this.wiredConsultasList);
                this.dispatchEvent(evt);
            })
                .catch(error => {
    
                    const evt = new ShowToastEvent({
                        title: 'Fallo al finalizar las consultas',
                        message: error.body.message,
                        variant: 'error'
                    });
    
                    this.dispatchEvent(evt);
                    this.spinnerLoading = false;
                })
    
                this.cerrarModalFinalizarConsulta();
        }
    }


    allSelected(event) {
        this.seleccionador();
        
        for(let i = 0; i < this.vSeleccionador.length; i++) {
            if(this.vSeleccionador[i].type === 'checkbox') {
                this.vSeleccionador[i].checked = event.target.checked;
            }
        }
    }

    seleccionador() {
        this.vSeleccionador = this.template.querySelectorAll('lightning-input');
    }
}