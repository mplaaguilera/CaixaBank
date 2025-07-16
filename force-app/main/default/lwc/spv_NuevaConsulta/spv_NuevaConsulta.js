import { LightningElement, api, wire, track } from 'lwc';
import tienePermisos from '@salesforce/apex/SPV_LCMP_NuevaConsulta.tienePermisos';
import insertarConsulta from '@salesforce/apex/SPV_LCMP_NuevaConsulta.insertarConsulta';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { RefreshEvent } from 'lightning/refresh';
import INTERACCION_OBJECT from '@salesforce/schema/SAC_Interaccion__c'; 
import getConsultas from '@salesforce/apex/SPV_LCMP_NuevaConsulta.getConsultas';
import OWNERID_FIELD from "@salesforce/schema/Case.OwnerId";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import MOTIVODEFINALIZADO_FIELD from '@salesforce/schema/SAC_Interaccion__c.SAC_MotivoDeFinalizado__c';
import finalizarConsultas from '@salesforce/apex/SPV_LCMP_NuevaConsulta.finalizarConsultasCaso';
import comprobarPosibleOficina from '@salesforce/apex/SPV_LCMP_NuevaConsulta.comprobarPosibleOficina';


export default class Spv_NuevaConsulta extends NavigationMixin(LightningElement)  {

    @api recordId;
    @api objectApiName;
    @api required = false;

    //Variables generales
    @api tienePermisosInsertar = false;
    @track modalNuevaConsulta = false;
    @track grupoId = '';
    @track spinnerLoading = false;
    @track botonFinalizarConsulta = false;
    @track consultas = [];
    @track selectedCons;
    @track error;
    @track finalizar = false;
    @track modalFinalizarConsulta = false;
    @track motivo;
    @track propietario;
    @track tipoRegistro;
    @track idOficinaSeleccionada = '';
    @track listOficinasMostrar = [];
    @track mostrarOficinas = false;
    @track selectOficina;

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

    @wire(getObjectInfo, {objectApiName: INTERACCION_OBJECT})
    objectInfo;

    @wire(getRecord, {
        recordId: "$recordId",
        fields: '$fieldsObtener'
    })
    wiredCase({data, error}){        
        if(data){
            this.propietario = data.fields.OwnerId.value;

            const objeto = data.apiName; //Api name del objeto que es el registro actual
            const recordTypeRegistro = data.fields.RecordType.value.fields.DeveloperName.value;     //Rt del registro

            if(objeto === 'Case' && recordTypeRegistro === 'SPV_Reclamacion'){
                this.tipoRegistro = 'Case';
            }else if(objeto === 'SAC_Accion__c' && (recordTypeRegistro === 'SPV_Acciones' || recordTypeRegistro === 'SPV_MaestroDeTareas')){
                this.tipoRegistro = 'SAC_Accion__c';
            }            

            tienePermisos({idRegistro: this.recordId, tipoRegistro: this.tipoRegistro})
                .then(result => {
                    this.tienePermisosInsertar = result;

                    if(this.tienePermisosInsertar){
                        getConsultas({idRegistro: this.recordId, ownerId: this.propietario})
                            .then(result => {
                                if(result){
                                    this.consultas = result;                                    
                                    
                                    if(this.consultas.length  === 0) {                                        
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
                            })
                            .catch(error => {
                                this.showToast('Fallo al recuperar las consultas', error.body.message, 'error');
                            })
                    }
                })
                .catch(error => {
                    this.showToast('Fallo al comprobar los permisos de creación de consultas', error.body.message, 'error');
                })
        }
    }

    get fieldsObtener(){
        return [this.objectApiName + '.RecordType.DeveloperName', OWNERID_FIELD];
    } 

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

        if(this.tipoRegistro === 'Case'){

            var oficinasReclamacion = [];

            comprobarPosibleOficina({idGrupo: this.grupoId, idRegistro: this.recordId})
                .then(result => {
                    oficinasReclamacion = result;

                    if(oficinasReclamacion.length > 0){
                        if(oficinasReclamacion.length === 1){
                            this.idOficinaSeleccionada = oficinasReclamacion[0].SPV_OficinaAfectada_Lookup__r.Id;
                            this.mostrarOficinas = false;
                        }else{
                            this.mostrarOficinas = true;

                            this.listOficinasMostrar = oficinasReclamacion.map(item => ({                                
                                label: item.SPV_OficinaAfectada_Lookup__r.Name,
                                value: item.SPV_OficinaAfectada_Lookup__r.Id
                            }));
                        }
                    }else{
                        this.mostrarOficinas = false;
                        this.idOficinaSeleccionada = '';
                    }               
                })
                .catch(error => {
                    this.showToast('Fallo al seleccionar el grupo de la consulta', error.body.message, 'error');
                })
        }
    }

    handleChangeOficina(event){
        this.idOficinaSeleccionada = event.detail.value
    }

    handleClickCrear(){
        if(this.grupoId === '' || this.grupoId === null){
            this.showToast('Advertencia!', 'Debe seleccionar un grupo asociado a la consulta', 'warning');
        }else if(this.mostrarOficinas && this.idOficinaSeleccionada === ''){
            this.showToast('Advertencia!', 'Debe seleccionar una oficina asociada a la consulta', 'warning');
        }else{
            this.modalNuevaConsulta = false;
            this.spinnerLoading = true;

            insertarConsulta({idRegistro: this.recordId, grupoId: this.grupoId, idOficina: this.idOficinaSeleccionada, tipoRegistro: this.tipoRegistro})
                .then(result => {
                    this.spinnerLoading = false;
                    this.grupoId = '';
                    this.idOficinaSeleccionada = '';
                    this.mostrarOficinas = false;

                    getConsultas({idRegistro: this.recordId, ownerId: this.propietario})
                    .then(result => {
                        if(result){
                            this.consultas = result;
                            
                            if(this.consultas.length === 0) {
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
                    })
                    .catch(error => {
                        this.showToast('Fallo al recuperar las consultas', error.body.message, 'error');
                    })

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

        getConsultas({idRegistro: this.recordId, ownerId: this.propietario})
            .then(result => {
                if(result){
                    this.consultas = result;
                    this.error = null;

                    this.finalizar = false;
                    this.modalFinalizarConsulta = true;
                    this.spinnerLoading = false;
                }else if (result.error) {
                    this.error = result.error;
                    this.consultas = null;
                }
            })
            .catch(error => {
                this.showToast('Fallo al recuperar las consultas', error.body.message, 'error');
            })
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

                getConsultas({idRegistro: this.recordId, ownerId: this.propietario})
                    .then(result => {
                        if(result){
                            this.consultas = result;
                            
                            if(this.consultas.length === 0) {
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
                    })
                    .catch(error => {
                        this.showToast('Fallo al recuperar las consultas', error.body.message, 'error');
                    })


                this.refreshView();
                this.showToast('Éxito!', 'Las consultas han sido finalizadas con éxito.', 'success');    
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
    }

    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }
}