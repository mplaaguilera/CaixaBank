import { LightningElement, api, wire, track } from 'lwc';
import insertarEscalado from '@salesforce/apex/SAC_LCMP_InsertarEscalado.insertarEscalado';
import esPropietario from '@salesforce/apex/SAC_LCMP_InsertarEscalado.esPropietario';
import hayEscaladosAbiertos from '@salesforce/apex/SAC_LCMP_InsertarEscalado.hayEscaladosAbiertos';
import insertarAdjuntoCaso from '@salesforce/apex/SAC_LCMP_InsertarEscalado.insertarAdjuntoCaso';
import recogerGruposParaEscalados from '@salesforce/apex/SAC_LCMP_InsertarEscalado.recogerGruposParaEscalados';
import validacionesEscalados from '@salesforce/apex/SAC_Interaccion.validacionesEscalados';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import STATUS from '@salesforce/schema/Case.Status';
import CASOESPECIAL from '@salesforce/schema/Case.SAC_CasoEspecial__c';
import SAC_MotivoEscalado__c from '@salesforce/schema/SAC_Interaccion__c.SAC_MotivoEscalado__c';
import ENTIDADAFECTADA from '@salesforce/schema/Case.SAC_Entidad_Afectada__c';
import AV_ChartJsV391 from '@salesforce/resourceUrl/AV_ChartJsV391';
import { RefreshEvent } from 'lightning/refresh';

export default class Sac_InsertarEscalado extends LightningElement {

    @api recordId;
    @api caseId;
    @api spinnerLoading = false;
    @track isRedaccionNegociacion = false;
    @track propuesta;
    @track titulo;
    @track observaciones;
    @track motivo;
    @track isModalOpen = false;
    @track isModalAdjuntos = false;
    @track isModalWarningOpen = false;
    @track propietario;
    @track hayEscaladoAbierto;
    @track necesitaEscalado = false;
    @track valueEquipo = 'COPS';  
    @track mensaje = '';
    @track options = [];
    @track grupoDestino;

    @wire(getRecord, { recordId: '$recordId' , fields: [STATUS, CASOESPECIAL, ENTIDADAFECTADA] })
    caso;
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: SAC_MotivoEscalado__c })
    getMotivoValues;

    @wire(recogerGruposParaEscalados, {idCase: '$recordId'})
    gruposParaEscalar(result) {
        if (result.data) { 
            result.data.forEach(element => {
                let opcAux = { label: element.Name, value: element.Id };
                this.options = [...this.options, opcAux];                    
            });
        } 
        else if (result.error) {
            this.error = result.error;
        }
    }

    getStatus() {
        return getFieldValue(this.caso.data, STATUS);
    }

    getCasoEspecial() {
        return getFieldValue(this.caso.data, CASOESPECIAL);
    }

    getEntidadAfectada(){
        return getFieldValue(this.caso.data, ENTIDADAFECTADA);
    }

    get acceptedFormats() {
        return ['.pdf','.png','.jpg', '.jpeg'];
    }

    get statusRedaccionNegociacion() {
        if(this.getStatus() == 'SAC_003' || this.getStatus() == 'SAC_007') {
            this.isRedaccionNegociacion = true;
        } else {
            this.isRedaccionNegociacion = false;
        }
        
        return this.isRedaccionNegociacion;
    }

    get necesiEscalado() {
        validacionesEscalados({ caseId: this.recordId }).then(result => {             
            this.necesitaEscalado = result.escalado;
            this.mensaje = result.mensaje;  

            let grupoDestino = result.mapaGrupoDestino; 
                        
            if (grupoDestino != null && grupoDestino != undefined && Object.entries(grupoDestino).length > 0) { 
                this.options = [];
                for (var ideGrupo in grupoDestino) {  
                    let contenidoGrupo = grupoDestino[ideGrupo];
                    let opcAux = { label: contenidoGrupo, value: ideGrupo };
                    this.options = [...this.options, opcAux];
                } 
            } 
        })
        return this.necesitaEscalado;
    }

    handleUploadFinished(event) {
        let uploadedFiles = event.detail.files;
        insertarAdjuntoCaso({caseId: this.recordId, numFicheros: uploadedFiles.length}).then(() => {

            const evt = new ShowToastEvent({
                title: 'Éxito!',
                message: 'Los archivos se han subido con éxito.',
                variant: 'success'
            });

            this.dispatchEvent(evt);

        }).catch(error => {

                const evt = new ShowToastEvent({
                    title: 'Fallo al subir los archivos',
                    message: error.body.message,
                    variant: 'error'
                });

                this.dispatchEvent(evt);
            })
    }

    handlePropuestaChange(event) {
        this.propuesta = event.target.value;
    }

    handleTituloChange(event) {
        this.titulo = event.target.value;
    }

    handleObservacionesChange(event) {
        this.observaciones = event.target.value;
    }

    handleMotivoChange(event) {
        this.motivo = event.target.value;
    }

    openModal() {
        this.spinnerLoading = true;
        this.isModalOpen = true;
        this.spinnerLoading = false;
    }

    openModalWarning() {
        this.spinnerLoading = true;
        this.isModalWarningOpen = true;
        this.spinnerLoading = false;
    }

    closeModalAdjuntos(){
        this.isModalAdjuntos = false;
        const evt = new ShowToastEvent({
            title: 'Escalado creado',
            message: 'Se ha creado el escalado con éxito',
            variant: 'success'
        });

        this.dispatchEvent(evt);
        this.dispatchEvent(new RefreshEvent());
    }

    closeModal() {
        this.isModalOpen = false;
    }

    closeModalWarning() {
        this.isModalWarningOpen = false;
    }

    comprobarPropietario() {
        this.spinnerLoading = true;
        esPropietario({caseId: this.recordId}).then(result => {
            this.propietario = result;
            if(this.propietario){
                //Si es propietario, llamo al método que comprueba si ya hay escalados que estén abiertos
                hayEscaladosAbiertos({caseId: this.recordId}).then(result => {
                    this.hayEscaladoAbierto = result;
                    if(this.hayEscaladoAbierto){
                        const evt = new ShowToastEvent({
                            title: 'La reclamación ya ha sido escalada',
                            message: 'Ya existe un escalado pendiente de respuesta en esta reclamación',
                            variant: 'error'
                        });
                        this.dispatchEvent(evt);
                    } else {
                        this.openModal();
                    }
                }

                ).catch(error => {

                    const evt = new ShowToastEvent({
                        title: 'Fallo al crear el escalado',
                        message: error.body.message,
                        variant: 'error'
                    });

                    this.dispatchEvent(evt);
                    this.spinnerLoading = false;
                })
            } else {
                this.openModalWarning();
            }
            this.spinnerLoading = false;
        })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Fallo al crear el escalado',
                    message: error.body.message,
                    variant: 'error'
                });

                this.dispatchEvent(evt);
                this.spinnerLoading = false;
            })
    }

    insertEscalado() {
        this.spinnerLoading = true;
        if ((this.titulo == null || this.titulo == '') || (this.propuesta == null || this.propuesta == '') || (this.motivo == null || this.motivo == '')) {
            const evt = new ShowToastEvent({
                title: 'Precaución',
                message: 'Recuerde completar el título, la propuesta y el motivo.',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            this.spinnerLoading = false;
        } else {
            insertarEscalado({caseId: this.recordId, propuesta: this.propuesta, titulo: this.titulo, motivo: this.motivo, observaciones: this.observaciones, equipoId: this.valueEquipo}).then(result => {

                this.spinnerLoading = false;
                this.isModalAdjuntos = true;
            })
                .catch(error => {
    
                    const evt = new ShowToastEvent({
                        title: 'Fallo al crear el escalado',
                        message: error.body.message,
                        variant: 'error'
                    });
    
                    this.dispatchEvent(evt);
                    this.spinnerLoading = false;
                })
    
                this.closeModal();
        }
        
    }
    
    handleChangeEquipo(event) { 
        this.valueEquipo = event.detail.value; 
    }


}