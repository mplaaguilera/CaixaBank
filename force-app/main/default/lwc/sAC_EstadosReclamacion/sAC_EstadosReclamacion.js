import { LightningElement, api, wire, track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateRecordStatus from '@salesforce/apex/SAC_LCMP_UpdateStatus.updateRecordStatus';
import updateRecordLastStatus from '@salesforce/apex/SAC_LCMP_UpdateStatus.updateRecordLastStatus';
import updateRecordStatusRechazado from '@salesforce/apex/SAC_LCMP_UpdateStatus.updateRecordStatusRechazado';
import updateRecordStatusReclamacion from '@salesforce/apex/SAC_LCMP_UpdateStatus.updateRecordStatusReclamacion';
import updateRecordStatusNegociacionReclamacion from '@salesforce/apex/SAC_LCMP_UpdateStatus.updateRecordStatusNegociacionReclamacion';
import reclamacionHuerfana from '@salesforce/apex/SAC_LCMP_UpdateStatus.reclamacionHuerfana';
import tieneReclamacionesVinculadas from '@salesforce/apex/SAC_LCMP_UpdateStatus.tieneReclamacionesVinculadas';
import esPrincipal from '@salesforce/apex/SAC_LCMP_UpdateStatus.esPrincipal';
import vieneAlta from '@salesforce/apex/SAC_LCMP_UpdateStatus.vieneDeAlta';
import esPropietario from '@salesforce/apex/SAC_LCMP_UpdateStatus.esPropietario';
import reclamacionConPretension from '@salesforce/apex/SAC_LCMP_UpdateStatus.reclamacionConPretension';
import insertarComentario from '@salesforce/apex/SAC_LCMP_UpdateStatus.insertarComentario';
//import insertCommentRechazo from '@salesforce/apex/SAC_LCMP_UpdateStatus.insertCommentRechazo';
import tienePretensiones from '@salesforce/apex/SAC_LCMP_UpdateStatus.tienePretensiones';
import prorroga from '@salesforce/apex/SAC_LCMP_UpdateStatus.prorroga';
import esPSD2YNoJunta from '@salesforce/apex/SAC_LCMP_UpdateStatus.esPSD2YNoJunta';
import recuperarPlantillaProrrogas from '@salesforce/apex/SAC_LCMP_UpdateStatus.recuperarPlantillaProrrogas';
import controladorEnvioEmail from '@salesforce/apex/SAC_LCMP_UpdateStatus.controladorEnvioEmail';
import haProrrogado from '@salesforce/apex/SAC_LCMP_UpdateStatus.haProrrogado';
import recuperarTiposFastTrack from '@salesforce/apex/SAC_LCMP_UpdateStatus.recuperarTiposFastTrack';
import fastTrack from '@salesforce/apex/SAC_LCMP_UpdateStatus.fastTrack';
import getListoFinalizarNegociacion from '@salesforce/apex/SAC_LCMP_UpdateStatus.getListoFinalizarNegociacion';
import finalizarNegociacionReclamacion from '@salesforce/apex/SAC_LCMP_UpdateStatus.finalizarNegociacion';
import { getPicklistValues  } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import MOTIVOINADMISION_FIELD from '@salesforce/schema/Case.SAC_MotivoInadmision__c';
import MOTIVORECHAZO_FIELD from '@salesforce/schema/Case.SAC_MotivoRechazo__c';
import TIPOSUBSANACION_FIELD from '@salesforce/schema/Case.SAC_TipoSubsanacion__c';
import updateRecordStatusInadmision from '@salesforce/apex/SAC_LCMP_UpdateStatus.updateRecordStatusInadmision';
import ANTECEDENTESREVISADOSNEGOCIACION_FIELD from '@salesforce/schema/Case.SAC_Reclamacion__r.SAC_Antecedentes_Revisados_Negociacion__c';
import RECLAMANTECONFORMENEGOCIACION_FIELD from '@salesforce/schema/Case.SAC_Reclamacion__r.SAC_ReclamanteConformeNegociacion__c';
import STATUSRECLAMACION_FIELD from '@salesforce/schema/Case.SAC_Reclamacion__r.Status';
import FASTTRACK_FIELD from '@salesforce/schema/Case.SAC_FastTrack__c';

const fields = [
    'Case.Status',
    'Case.SAC_Reclamacion__c',
    'Case.OS_Email__c',
    'Case.CaseNumber',
    'Case.SAC_SentidoResolucion__c',
    'Case.SAC_AltaAutomatica__c',
    'Case.SAC_Entidad_Afectada__c',
    'Case.SAC_EntidadProductora__c',
    'Case.OS_Fecha_Resolucion__c',
    'Case.SAC_Reclamacion__r.SAC_Antecedentes_Revisados_Negociacion__c',
    'Case.SAC_Reclamacion__r.SAC_ReclamanteConformeNegociacion__c',
    'Case.SAC_Reclamacion__r.Status',
    'Case.SAC_FastTrack__c',
    'Case.CC_Idioma__c',
    'Case.CC_AcuseRecibo__c'
];

export default class SAC_EstadosReclamacion extends LightningElement {

    my_error = 'Las reclamaciones no están al alcance de su ejecución.';
    mensaje = 'Se ha actualizado el estado de la reclamación.';  
    value = '';  
    valueMotivoRechazo = '';

    @api bol;
    @api isLoading = false;
    @api recordId;
    @api escritura;
    @track textoParaChatter;
    @track textoParaChatterRechazar;
    @track resultado;
    @track propietario;
    @track pretConMcc;
    @track finalizarNegociacion = false;
    @track tieneFechaResolucion = false;
    @track isModalOpen = false;
    @track isModalUltimaPretension = false;
    @track puedeProrrogar;
    @track tieneProrroga;
    @track isModalOpenProrroga = false;
    @track isModalOpenInadmision = false;
    @track isModalOpenSubsanacion = false;
    @track isModalOpenRechazar = false;
    @track avisoFinNegociacion = false;
    @track otros = false;
    @track picklistValues;
    @track altaAutomatica;
    @track esFastTrack = false;
    @track listaMarcasFT = [];
    @track marcaSeleccionada;
    @track avisoInfoCualitativa = false;
    @track avisoIdioma = false;
    @track checkConfirmacionValidacion = false;
    @track variableAuxiliarBoton;
    isLoadingFT = false;
 
    //@track plantillaProrroga;
    @track existenDatos;
    @track caseNumber;
    @track subject;
    @track toSend;
    @track textoPlantilla;
    @track HtmlPlantilla;
    @track motivoProrroga;
    @track sentidoResolucion;
    @track fechaResolucion;
    @track idioma;
    @track acuseReciboEnviado = false;

    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getRecord, {recordId: '$recordId', fields})
    actualCase({data, error}){
        if(data){
            this.existenDatos = data;
            this.toSend = this.existenDatos.fields.OS_Email__c.value; 
            this.caseNumber = this.existenDatos.fields.CaseNumber.value;
            this.sentidoResolucion = this.existenDatos.fields.SAC_SentidoResolucion__c.value;
            this.subject = 'El caso con numero: ' + this.caseNumber +' ha sido prorrogado'; 
            this.altaAutomatica = this.existenDatos.fields.SAC_AltaAutomatica__c.value; 
            this.fechaResolucion = this.existenDatos.fields.OS_Fecha_Resolucion__c.value; 
            this.idioma = this.existenDatos.fields.CC_Idioma__c.value; 
            this.estado;

            if(this.existenDatos.fields.CC_AcuseRecibo__c.value === '2'){
                this.acuseReciboEnviado = true;
            }
        }
            
    };

    @wire(getRecord, { recordId: '$recordId', fields})
    case;

    get antecedentesRevisadosNegociacion() {
        return getFieldValue(this.case.data, ANTECEDENTESREVISADOSNEGOCIACION_FIELD);
    }

    get reclamanteConformeNegociacion() {
        return getFieldValue(this.case.data, RECLAMANTECONFORMENEGOCIACION_FIELD);
    }

    get statusReclamacion() {
        return getFieldValue(this.case.data, STATUSRECLAMACION_FIELD);
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVOINADMISION_FIELD })
    listaOpcionesInadmision;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TIPOSUBSANACION_FIELD })
    listaTipoSubsanacion;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVORECHAZO_FIELD })
    listaMotivoRechazo;

    get fastTrack() {
        return getFieldValue(this.case.data, FASTTRACK_FIELD);
    }

    get email(){
        return undefined;
    }

    @wire(esPropietario, {record: '$recordId'})
    propietarioRegistro({data, error}){
        if(data){
            this.propietario = data;
        }            
    };

    @wire(reclamacionConPretension, {record: '$recordId'})
    reclamacionConPretensionMCC({data, error}){
        if(data){
            this.pretConMcc = data;
        }            
    };

    
    @wire(getListoFinalizarNegociacion, {record: '$recordId'})
    listoFinalizarNegociacion(result){
        if(result.data){
            this.finalizarNegociacion = result.data.listoFinalizarNegociacion;
            this.tieneFechaResolucion = result.data.tieneFechaResolucion;
        }            
    };


    /*get esPropietarioCaso(){
        esPropietario({record: this.recordId})
            .then(result => {
                alert('Resultado es propietario: ' + result);
                this.propietario = result;
            })
            .catch(error => {
                this.error = error;
            });
        
        return this.propietario;
    }*/

    get esAlta(){
        vieneAlta({record: this.recordId})
            .then(result => {
                this.resultado = result;
            })
            .catch(error => {
                this.error = error;
            });
        
        return this.resultado;
    }

    get alta(){
        if(this.existenDatos.fields.Status.value=='SAC_001'){
            return 'Alta';
        } 
        return undefined;
    }
    get analisis(){
        if(this.existenDatos.fields.Status.value=='SAC_002'){
            return 'Análisis';
        } 
        return undefined;
    }
    get redaccion(){
        if(this.existenDatos.fields.Status.value=='SAC_003' && this.sentidoResolucion != 'SAC_004'){
            return 'Redacción';
        }  
        return undefined;
    }

    get inadmision(){
        if(this.existenDatos.fields.Status.value=='SAC_005'  && this.sentidoResolucion == 'SAC_004'){
            return 'Inadmisión';
        }   
        return undefined;
    }
    get subsanacion(){
        if(this.existenDatos.fields.Status.value=='SAC_006'){
            return 'Subsanación';
        }
        return undefined;
    }
    get negociacion(){
        if(this.existenDatos.fields.Status.value=='SAC_007'){
            return 'Subsanación';
        }       
        return undefined;
    }
    get negociacionReclamacion(){
        if(this.statusReclamacion=='SAC_007'){
            return 'Negociacion';
        }
        return undefined;
    }
    get ejecucion(){
        if(this.existenDatos.fields.Status.value=='SAC_004'){
            return 'Ejecución';
        }
        return undefined;
    }
    get derivacion(){
        if(this.existenDatos.fields.Status.value=='SAC_008'){
            return 'Derivación';
        }   
        return undefined;
    }
    get baja(){
        if(this.existenDatos.fields.Status.value=='SAC_009'){
            return 'Baja';
        } 
        return undefined;
    }

    get estadoCerrado(){
        if(this.existenDatos.fields.Status.value=='Cerrado'){
            return 'Cerrado';
        }
        return undefined;
    }
    
    get recordType(){
        const rtNombre = this.existenDatos.recordTypeInfo.name;
        if(rtNombre=='Reclamacion'){
            return true;
        }
        if(rtNombre=='Pretension'){
            return false;
        }
        return undefined;
    }

    get esPSD2YNoJunta(){
        esPSD2YNoJunta({record: this.recordId})
            .then(result => {
                this.puedeProrrogar = result;
            })
            .catch(error => {
                this.error = error;
            });
        return this.puedeProrrogar;
    }

    get haProrrogado(){
        haProrrogado({record: this.recordId})
        .then(result =>{
            this.tieneProrroga = result;
        })
        .catch(error =>{
            this.error = error;
        });
        return this.tieneProrroga;
    }

    get opcionesMotivosInadmision() {
        haProrrogado({record: this.recordId})
        .then(result =>{
            this.tieneProrroga = result;
        })
        .catch(error =>{
            this.error = error;
        });
        return this.tieneProrroga;
    }

    get esAltaAutomatica(){
        return this.altaAutomatica;
    }
    clickReclamacion(evt){        
        //var variableAuxiliarCodigoboton = evt.currentTarget.id;
        this.estadoActual = this.existenDatos.fields.Status.value;
        
        this.isLoading = true;
        // for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
        //     if (variableAuxiliarCodigoboton.charAt(i) == '-') {
        //         this.estado = variableAuxiliarCodigoboton.substring(0, i);
        //     }
        // }
        this.estado = this.variableAuxiliarBoton;

        if(this.estado == 'SAC_005'){ 
            this.isModalOpenInadmision = true;

        }else{

        tienePretensiones({record: this.recordId}).then(result =>{
            if (result === true){
                if (this.fastTrack != null) {
                    //Cargar del maestro de temas los tipos de fast track y abrir pop up fast track
                    this.marcaSeleccionada = null;
                    this.esFastTrack = true;
                    recuperarTiposFastTrack({ tipoFastTrack: this.fastTrack }).then(result => {
                        this.listaMarcasFT = result.map(item => ({
                            label: item.Name,
                            value: item.Id
                        }));
                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.errorMsg = error;
    
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Fallo al recuperar los tipos de fast track',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    })
                } else {
                    //Se hace el cambio a Análisis de manera normal
                    updateRecordStatus({ record: this.recordId, newStatus: this.estado }).then(result => {
                        this.isLoading = false;
                        this.dispatchEvent(
    
                            new ShowToastEvent({
                                title: 'Estado actualizado',
                                message: this.mensaje,
                                variant: 'success'
                            })
                        );
                        
                        this.dispatchEvent(new RefreshEvent());
    
                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.errorMsg = error;
    
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Fallo al actualizar',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    })
                }
            }

            if(result === false){
                
                this.isLoading = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'No tiene pretension',
                        message: 'No se puede cambiar de estado si no hay pretensiones activas',
                        variant: 'error'
                    })
                );
            }
        })
        .catch(error => {
            
            this.isLoading = false;
            this.errorMsg = error;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        })

        }
    }

    clickPretension(evt){    
        this.isLoading = true;
        if (this.avisoInfoCualitativa) {
            this.avisoInfoCualitativa = false;
        }
        var variableAuxiliarCodigoboton = evt.currentTarget.id;
        this.estadoActual = this.existenDatos.fields.Status.value;
        
        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.estado = variableAuxiliarCodigoboton.substring(0, i);
            }
        }

        if(this.estado == 'SAC_007' && (this.existenDatos.fields.SAC_Entidad_Afectada__c.value == null || this.existenDatos.fields.SAC_EntidadProductora__c.value == null)) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: 'Debe rellenar los campos Entidad productora y Entidad afectada de la reclamación.',
                    variant: 'error'
                })
            );
        } else if (this.estado === 'SAC_007' && this.antecedentesRevisadosNegociacion === false) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: 'Debe refrescar los antecedentes y marcar el check Antecedentes Revisados Negociacion antes de pasar a la negociación.',
                    variant: 'error'
                })
            );
            
        } else if (this.estado === 'SAC_007' && this.reclamanteConformeNegociacion === false) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: 'Debe marcar el check Reclamante conforme para negociación antes de pasar a la negociación.',
                    variant: 'error'
                })
            );
            
        } else {
            updateRecordStatus({ record: this.recordId, newStatus: this.estado }).then(result => {
                this.isLoading = false;
                this.dispatchEvent(
    
                    new ShowToastEvent({
                        title: 'Estado actualizado',
                        message: this.mensaje,
                        variant: 'success'
                    })
                );
                
				this.dispatchEvent(new RefreshEvent());
    
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMsg = error;
                if (this.avisoInfoCualitativa) {
                    this.avisoInfoCualitativa = false;
                }
    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al actualizar',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })    
        }      
    }

    setSubsanacion(){

        this.isModalOpenSubsanacion = false;
        this.isLoading = true;
        this.estado = 'SAC_006';
        this.estadoActual = this.existenDatos.fields.Status.value;

        updateRecordStatus({ record: this.recordId, newStatus: this.estado }).then(result => {

            this.isLoading = false;
            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message: this.mensaje,
                    variant: 'success'
                })
            );
            
            this.dispatchEvent(new RefreshEvent());
        })
            .catch(error => {
                this.isLoading = false;
                this.errorMsg = error;

                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                }));

            })

    }

    setInadmision(){
        this.isLoading = true;
        this.estado = 'SAC_005';
        this.estadoActual = this.existenDatos.fields.Status.value;

        
        }    

        setBaja(){

            this.isModalUltimaPretension = false;
            this.isLoading = true;
            this.estado = 'SAC_009';
            this.estadoActual = this.existenDatos.fields.Status.value;
            updateRecordStatus({ record: this.recordId, newStatus: this.estado }).then(result => {
            this.isLoading = false;
            this.dispatchEvent(
    
            new ShowToastEvent({
                title: 'Estado actualizado',
                message: this.mensaje,
                variant: 'success'
            })
            );
        
            this.dispatchEvent(new RefreshEvent());
    
        })
            .catch(error => {
            this.isLoading = false;
            this.errorMsg = error;
    
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Fallo al actualizar',
                message: error.body.message,
                variant: 'error'
            }));
        })
            
        }

    bajaPretensionAlta(){

        esPrincipal({record: this.recordId}).then(result =>{
            

            if(result=='mas'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'No se puede dar de baja',
                        message: 'Para dar de baja esta pretensión se necesita asignar como "Pretensión principal" otra pretensión.',
                        variant: 'error'
                    }));
                
            } else if (result == 'una') {
                if (this.estado == 'SAC_001') {
                    reclamacionHuerfana({ record: this.recordId }).then(result => {    
                        if(result === true){        
                            this.isModalUltimaPretension = true;        
                        }            
                    })
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'No se puede dar de baja',
                            message: 'Para dar de baja esta pretensión se necesita asignar otra pretensión como "Pretensión principal".',
                            variant: 'error'
                        }));
                }
                

            }else if(result == 'no'){
                this.setBaja();
            }

        })
    }

    mantenerPretension(){
        this.isModalUltimaPretension = false;
    }

    setAlta(){
        this.isLoading = true;
        this.estado = 'SAC_001';
        this.estadoActual = this.existenDatos.fields.Status.value;
        updateRecordStatus({ record: this.recordId, newStatus: this.estado }).then(result => {
            this.isLoading = false;
            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message: this.mensaje,
                    variant: 'success'
                })
            );
            
            this.dispatchEvent(new RefreshEvent());

        })
            .catch(error => {
                this.isLoading = false;
                this.errorMsg = error;


                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: 'Revise el estado de las pretensiones antes de pasar a "Alta" la reclamación actual.',
                    variant: 'error'
                }));

            })

    }

    setRedaccion(){
        this.isLoading = true;
        this.estado = 'SAC_003';
        this.estadoActual = this.existenDatos.fields.Status.value;
        updateRecordStatus({ record: this.recordId, newStatus: this.estado }).then(result => {
            this.isLoading = false;
            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message: this.mensaje,
                    variant: 'success'
                })
            );
            
            this.dispatchEvent(new RefreshEvent());

        })
            .catch(error => {
                this.isLoading = false;
                this.errorMsg = error;


                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                }));

            })

    }

    // setRedaccionReclamacion(){
    //     this.isLoading = true;
    //     this.estado = 'SAC_003';
    //     this.estadoActual = this.existenDatos.fields.Status.value;
    //     updateRecordStatusReclamacion({ record: this.recordId, estado : this.estado}).then(result => {
    //         this.isLoading = false;
    //         this.dispatchEvent(

    //             new ShowToastEvent({
    //                 title: 'Estado actualizado',
    //                 message: this.mensaje,
    //                 variant: 'success'
    //             })
    //         );
            
    //          this.dispatchEvent(new RefreshEvent());

    //     })
    //         .catch(error => {
    //             this.isLoading = false;
    //             this.errorMsg = error;


    //             this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Fallo al actualizar',
    //                 message: error.body.message,
    //                 variant: 'error'
    //             }));

    //         })

    // }

    setNegociacion(){
        this.isLoading = true;
        this.estado = 'SAC_007';
        this.estadoActual = this.existenDatos.fields.Status.value;
        updateRecordStatus({ record: this.recordId, newStatus: this.estado }).then(result => {
            this.isLoading = false;
            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message: this.mensaje,
                    variant: 'success'
                })
            );
            
            this.dispatchEvent(new RefreshEvent());

        })
            .catch(error => {
                this.isLoading = false;
                this.errorMsg = error;


                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                }));

            })

    }

    setNegociacionReclamacion(){
        this.isLoading = true;
        this.estado = 'SAC_007';
        this.estadoActual = this.existenDatos.fields.Status.value;
        updateRecordStatusNegociacionReclamacion({ record: this.recordId}).then(result => {
            this.isLoading = false;
            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message: this.mensaje,
                    variant: 'success'
                })
            );
            
            this.dispatchEvent(new RefreshEvent());

        })
            .catch(error => {
                this.isLoading = false;
                this.errorMsg = error;


                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                }));

            })

    }

    setAnalisis(){

        this.isLoading = true;
        this.estado = 'SAC_002';
        this.estadoActual = this.existenDatos.fields.Status.value;
        updateRecordStatus({ record: this.recordId, newStatus: this.estado }).then(result => {
            this.isLoading = false;
            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message: this.mensaje,
                    variant: 'success'
                })
            );
            
            this.dispatchEvent(new RefreshEvent());

        })
            .catch(error => {
                this.isLoading = false;
                this.errorMsg = error;


                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                }));

            })

    }

    setAnalisisReclamacion(){
        this.isLoading = true;
        this.estado = 'SAC_002';
        this.estadoActual = this.existenDatos.fields.Status.value;
        if(this.fechaResolucion != null) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: 'Por favor, refresque la página',
                    variant: 'error'
                })
            );
        } else {
            updateRecordStatusReclamacion({ record: this.recordId, estado : this.estado}).then(result => {
                this.isLoading = false;
                this.dispatchEvent(
    
                    new ShowToastEvent({
                        title: 'Estado actualizado',
                        message: this.mensaje,
                        variant: 'success'
                    })
                );
                
				this.dispatchEvent(new RefreshEvent());
    
            })
                .catch(error => {
                    this.isLoading = false;
                    this.errorMsg = error;
    
    
                    this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al actualizar',
                        message: error.body.message,
                        variant: 'error'
                    }));
    
                })
        }
    }


    setBack(){
        this.isLoading = true;
        updateRecordLastStatus({ record: this.recordId}).then(result => {
            this.isLoading = false;
            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message: this.mensaje,
                    variant: 'success'
                })
            );
            
            this.dispatchEvent(new RefreshEvent());

        })
            .catch(error => {
                this.isLoading = false;
                if(error.body.message != null) {
                    this.errorMsg = error.body.message;
                } else {
                    this.errorMsg = error.body.pageErrors[0].message;
                }

                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: this.errorMsg,
                    variant: 'error'
                }));

            })

    }

    openModalRechazar(){
        this.isModalOpenRechazar = true;
    }

    closeModalRechazar(){
        this.isModalOpenRechazar = false;
    }

    openModalSubsanacion(){
        this.isModalOpenSubsanacion = true;
    }

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;

    }

    closeModalSub(){
        this.isModalOpenSubsanacion = false;
    }

    closeModalFastTrack() {
        this.esFastTrack = false;
        this.isLoading = false;
    }

    comprobarTexto(){
       var inp = this.template.querySelector("lightning-textarea[data-my-id=textoParaChatter]");
       var comentario = inp.value;
        
       insertarComentario({ record: this.recordId, mensaje: comentario}).then(result => {
            this.setAlta();
            this.closeModal();
        });     
    }

    clickProrroga(evt){
        this.isLoading = true;
        this.closeModalProrroga();

        prorroga({record: this.recordId}).then(result => {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Prorroga realizada correctamente',
                    message: this.mensaje,
                    variant: 'success'
                })
            );    
            this.dispatchEvent(new RefreshEvent());
        })
        .catch(error => {
            this.isLoading = false;
            this.errorMsg = error;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        })     

        const recordInput = {motivoProrroga: this.motivoProrroga, toSend: this.toSend, subject: this.subject} 
        controladorEnvioEmail(recordInput)
        .then( () => {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Prorroga realizada correctamente',
                    message: this.mensaje,
                    variant: 'success'
                })
            );    
            this.dispatchEvent(new RefreshEvent());
        }).catch( error => {
            this.isLoading = false;
            this.errorMsg = error;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }) 
    }
    
    handleChangeRechazo(event){
        this.valueMotivoRechazo = event.detail.value;

        if(this.valueMotivoRechazo == 'Otros'){

            this.otros = true;

        }else{

            this.otros = false;

        }
    }

    clickRechazar(evt){
        if(this.valueMotivoRechazo != ''){

            if(this.otros){
   
                var inp = this.template.querySelector("lightning-textarea[data-my-id=textoParaChatterRechazar]");
                var comentario = inp.value;;

                if(comentario != ''){
                    
                    var mensajeChatter = 'Se ha rechazado el caso por el motivo: ' + this.valueMotivoRechazo + '\nObservación: ' + comentario;
                    this.estado = 'Rechazado';
                    this.isLoading = true;
                    this.closeModalRechazar();

                    updateRecordStatusRechazado({record: this.recordId, motivo: this.valueMotivoRechazo }).then(result => {    
                        this.isLoading = false;
        
                        insertarComentario({ record: this.recordId, mensaje: mensajeChatter}).then(result => {
                        })
                        .catch(error => {
                            this.isLoading = false;
                            this.errorMsg = error;
                            this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Falta un comentario',
                                message: error.body.message,
                                variant: 'error'
                                })
                            );
                        });  
        
                        this.dispatchEvent(
                        new ShowToastEvent({
                                title: 'Estado actualizado',
                                message: this.mensaje,
                                variant: 'success'
                            })
                        );
                            
                        this.dispatchEvent(new RefreshEvent());
            
                        })
                        .catch(error => {
                            this.isLoading = false;
                            this.errorMsg = error;
            
                            this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Fallo al actualizar.',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    })

                }else{

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error al actualizar el estado',
                            message: 'Debe escribir un comentario',
                            variant: 'error'
                        })
                    );
                }

            }else if(this.valueMotivoRechazo == 'Rechazada por vinculacion'){

                var mensajeChatter = 'Se ha rechazado el caso por el motivo: ' + this.valueMotivoRechazo;

                tieneReclamacionesVinculadas({ record: this.recordId}).then(result => {
                    if(result){

                        this.estado = 'Rechazado';
                        this.isLoading = true;
                        this.closeModalRechazar();

                        updateRecordStatusRechazado({record: this.recordId, motivo: this.valueMotivoRechazo }).then(result => {  
                              
                            insertarComentario({ record: this.recordId, mensaje: mensajeChatter}).then(result => {
                            })
                            .catch(error => {
                                this.isLoading = false;
                                this.errorMsg = error;
                                this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Falta un comentario',
                                    message: error.body.message,
                                    variant: 'error'
                                    })
                                );
                            }); 

                            this.isLoading = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                        title: 'Estado actualizado',
                                        message: this.mensaje,
                                        variant: 'success'
                                    })
                                );
                                
                                this.dispatchEvent(new RefreshEvent());
                
                            })
                            .catch(error => {
                                this.isLoading = false;
                                this.errorMsg = error;
                
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Fallo al actualizar',
                                        message: error.body.message,
                                        variant: 'error'
                                    })
                                );
                            })



                    }else{

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'No puede seleccionar este motivo',
                                message: 'La reclamación no cuenta con reclamaciones vinculadas',
                                variant: 'error'
                            })
                        );
                    }
                })
                .catch(error => {
                    this.isLoading = false;
                    this.errorMsg = error;
                    this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al actualizar.',
                        message: error.body.message,
                        variant: 'error'
                        })
                    );
                });  



            }else{

                this.estado = 'Rechazado';
                this.isLoading = true;
                this.closeModalRechazar();
                var mensajeChatter = 'Se ha rechazado el caso por el motivo: ' + this.valueMotivoRechazo;
                
                updateRecordStatusRechazado({record: this.recordId, motivo: this.valueMotivoRechazo }).then(result => {    
                    
                    insertarComentario({ record: this.recordId, mensaje: mensajeChatter}).then(result => {
                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.errorMsg = error;
                        this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Falta un comentario',
                            message: error.body.message,
                            variant: 'error'
                            })
                        );
                    }); 
                    
                    this.isLoading = false;
                    this.dispatchEvent(
                    new ShowToastEvent({
                            title: 'Estado actualizado',
                            message: this.mensaje,
                            variant: 'success'
                        })
                    );
                        
                    this.dispatchEvent(new RefreshEvent());
        
                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.errorMsg = error;
        
                        this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Fallo al actualizar.',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                })
            }

        }else{

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No ha seleccionado un motivo',
                    message: 'Debe seleccionar un motivo',
                    variant: 'error',
                }),
            );
        }  
    }

    handleMotivoProrroga(event){
        this.motivoProrroga = event.target.value;
    }

    openModalProrroga() {
        this.spinnerLoading = true;
        recuperarPlantillaProrrogas({record: this.recordId}).then(result=>{
            this.motivoProrroga = result;
            this.spinnerLoading = false;
            this.isModalOpenProrroga = true;
        })
        .catch(error =>{
            this.errorMsg = error;
            this.spinnerLoading = false;
        });          
    }

    openModalInadmision() {
        this.isModalOpenInadmision = true; 
    }
    closeModalInadmision() {
        this.isModalOpenInadmision = false;
        this.isLoading = false;
    }   

    handleChange(event) {
        this.value = event.detail.value;
    }

    guardarInadmision(){
        this.isLoading = true; 
        if(this.value != ''){ 
            this.isModalOpenInadmision = false;
                    
            updateRecordStatusInadmision({ record: this.recordId, motivo: this.value }).then(result => {       
                this.dispatchEvent(

                    new ShowToastEvent({
                        title: 'Estado actualizado',
                        message: this.mensaje,
                        variant: 'success'
                    })
                );
                this.isLoading = false;
				this.dispatchEvent(new RefreshEvent());

            })
            .catch(error => {
                this.isLoading = false;
                if(error.body.message != null) {
                    this.errorMsg = error.body.message;
                } else {
                    this.errorMsg = error.body.pageErrors[0].message;
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al actualizar',
                        message: this.errorMsg,
                        variant: 'error'
                    })
                );
            })
        } 
        this.isLoading = false;
    }

    handlePicklistMarcaFTChange(event) {
        this.marcaSeleccionada = event.target.value;
        // Realiza acciones adicionales según el cambio de selección del combobox
    }

    lanzarFastTrack() {
        if (this.marcaSeleccionada == null || this.marcaSeleccionada == undefined) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Seleccionar un valor',
                    message: 'Debe seleccionar una marca de fast track',
                    variant: 'warning'
                })
            );
        } else {
            this.isLoadingFT = true;
            fastTrack({ caseId: this.recordId, marcaSeleccionada: this.marcaSeleccionada }).then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Estado actualizado',
                        message: this.mensaje,
                        variant: 'success'
                    })
                );
                this.isLoadingFT = false;
                this.closeModalFastTrack();
				this.dispatchEvent(new RefreshEvent());
    
            })
            .catch(error => {
                this.isLoadingFT = false;
                this.errorMsg = error;
    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al actualizar',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
        }
    }


    mostrarAvisoFinNegociacion() {
        this.avisoFinNegociacion = true; 
    }

    closeAvisoFinNegociacion() {
        this.avisoFinNegociacion = false; 
    }

    resolverNegociacion() {      
        this.isLoading = true;
        this.closeAvisoFinNegociacion();

        finalizarNegociacionReclamacion({ record: this.recordId}).then(result => {

            this.isLoading = false;
            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message: this.mensaje,
                    variant: 'success'
                })
            );
            
            this.dispatchEvent(new RefreshEvent());
        })
            .catch(error => {
                this.isLoading = false;
                
                if(error.body.message != null) {
                    this.errorMsg = error.body.message;
                } else {
                    this.errorMsg = error.body.pageErrors[0].message;
                }
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo finalizar la negociación',
                    message: this.errorMsg,
                    variant: 'error'
                }));

            })
    }

    mostrarAvisoInfoCualitativa() {
        this.avisoInfoCualitativa = true;
    }

    closeAvisoInfoCualitativa() {
        this.avisoInfoCualitativa = false;
    }

    mostrarAvisoIdioma(evt) {
        var variableAuxiliarCodigoboton = evt.currentTarget.id;
        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.variableAuxiliarBoton = variableAuxiliarCodigoboton.substring(0, i);
            }
        }
        this.avisoIdioma = true;
    }

    closeAvisoIdioma() {
        this.avisoIdioma = false;
    }

    handleChangeIdioma(event) {
        this.checkConfirmacionValidacion = event.target.checked;
    }

    aceptarAvisoIdioma() {
        if(this.idioma == null) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Advertencia',
                    message: 'Debe completar el idioma de la reclamación',
                    variant: 'warning'
                }));
        } else {
            if(this.checkConfirmacionValidacion) {
                this.avisoIdioma = false;
                if(this.variableAuxiliarBoton == 'SAC_002') {
                    this.clickReclamacion();
                } else if(this.variableAuxiliarBoton =='Inadmisión') {
                    this.openModalInadmision();
                }
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Advertencia',
                        message: 'Debe confirmar que ha validado el idioma de la reclamación',
                        variant: 'warning'
                    }));
            }
        }
    }

}