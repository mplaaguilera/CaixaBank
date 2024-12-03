import { LightningElement, api, wire, track } from 'lwc';
import tienePermisos from '@salesforce/apex/SPV_LCMP_NuevaConsulta.tienePermisos';
import insertarConsulta from '@salesforce/apex/SPV_LCMP_NuevaConsulta.insertarConsulta';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case';
import { RefreshEvent } from 'lightning/refresh';
import getConsultas from '@salesforce/apex/SPV_LCMP_NuevaConsulta.getConsultasCaso';
import OWNERID_FIELD from "@salesforce/schema/Case.OwnerId";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import MOTIVODEFINALIZADO_FIELD from '@salesforce/schema/SAC_Interaccion__c.SAC_MotivoDeFinalizado__c';
import finalizarConsultas from '@salesforce/apex/SPV_LCMP_NuevaConsulta.finalizarConsultasCaso';


const fieldsCase = [
    OWNERID_FIELD
];


export default class Spv_NuevaConsulta extends NavigationMixin(LightningElement)  {
    @api recordId;
    @api required = false;

    //Variables generales
    @api tienePermisosInsertar = false;
    @track modalNuevaConsulta = false;
    @track grupoId = '';
    @track spinnerLoading = false;
    @track botonFinalizarConsulta = false;
    @track consultas = [];
    @track selectedCons;
    @track wiredConsultasList = [];
    @track error;
    @track finalizar = false;
    @track modalFinalizarConsulta = false;
    @track motivo;


    filter = {
        criteria: [
            {
                fieldPath: 'RecordType.DeveloperName',
                operator: 'eq',
                value: 'SPV_GrupoDeTareas'
            },
            {
                fieldPath: 'SAC_PermiteConsultas__c',
                operator: 'eq',
                value: true
            }
        ],
        filterLogic: '1 AND 2'
    };

    _wiredResult;  
    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getRecord, {
        recordId: "$recordId",
        fields: fieldsCase
    })
    record;

    get casoOwnerId() {
        return getFieldValue(this.record.data, OWNERID_FIELD);
    }

    @wire(tienePermisos, { idCaso: '$recordId'})
    mapaPermisos(result){
        if(result.data){
            this.tienePermisosInsertar = result.data;
        }
    };

    @wire(getConsultas, { caseId: '$recordId', tienePermisosInsertar: '$tienePermisosInsertar', caseOwner: '$casoOwnerId'})
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

    abrirModalNuevaConsulta() {
        this.modalNuevaConsulta = true;
    }

    cerrarModalNuevaConsulta(){
        this.modalNuevaConsulta = false;
    }

    handleChange(event) {
        this.grupoId = event.detail.recordId;
    }

    handleClickCrear(){
        if(this.grupoId === '' || this.grupoId === null){
            this.showToast('Advertencia!', 'Debe seleccionar un grupo asociado a la consulta', 'warning');
        }else{
            this.modalNuevaConsulta = false;
            this.spinnerLoading = true;

            insertarConsulta({casoId: this.recordId, grupoId: this.grupoId})
                .then(result => {
                    this.spinnerLoading = false;
                    this.grupoId = '';

                    let nuevaId = result;

                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: nuevaId,
                            objectApiName: 'SAC_Interaccion__c',
                            actionName: 'view'
                        }
                    });

                    this.refreshView();

                    this.showToast('Consulta creada', 'Se ha creado la consulta con éxito', 'success');
                })
                .catch(error => {
                    this.showToast('Fallo al crear la consulta', error.body.message, 'error');
                })
        }
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

    handleMotivoChange(event) {
        this.motivo = event.target.value;
    }

    siguiente() {
        this.selectedCons = [];

        this.seleccionador();
        for(let i = 1; i < this.vSeleccionador.length; i++) {
            if(this.vSeleccionador[i].checked && this.vSeleccionador[i].type === 'checkbox') {
                let idConsulta = this.vSeleccionador[i].value;
                this.selectedCons.push(idConsulta);
            }
        }
        if(this.selectedCons.length === 0) {
            this.showToast('Precaución', 'Recuerde seleccionar alguna de las consultas.', 'warning');
        } else {
            this.finalizar = true;
        }
    }

    finalizarConsultas () {
        this.spinnerLoading = true;
        if (this.motivo == null || this.motivo == '') {
            this.showToast('Precaución', 'Recuerde completar el motivo de finalizado.', 'warning');
            this.spinnerLoading = false;
        } else {
            finalizarConsultas({idConsultas: this.selectedCons, motivo: this.motivo}).then(result => {
                this.spinnerLoading = false;
                this.motivo = '';
                refreshApex(this.wiredConsultasList);
                this.refreshView();
                this.showToast('Éxito!', 'Las consultas han sido finalizadas con éxito.', 'success');    

                // this.dispatchEvent(evt);
            })
            .catch(error => {
                this.showToast('Fallo al finalizar las consultas', error.body.message, 'error');    
                this.spinnerLoading = false;
            })

            this.cerrarModalFinalizarConsulta();
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );

        // this.dispatchEvent(evt);
    }

    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }
}