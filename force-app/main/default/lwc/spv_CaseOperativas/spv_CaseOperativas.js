import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues  } from 'lightning/uiObjectInfoApi';
import USER_ID from '@salesforce/user/Id';
import tomarPropiedadCaso from '@salesforce/apex/SPV_CaseOperativas_Controller.tomarPropiedadCaso';
import recuperarUser from '@salesforce/apex/SPV_CaseOperativas_Controller.recuperarUser';
import devolverCaso from '@salesforce/apex/SPV_CaseOperativas_Controller.devolverCaso';
import volverAnalisisCaso from '@salesforce/apex/SPV_CaseOperativas_Controller.volverAnalisis';
import metodoDescartarReclamacion from '@salesforce/apex/SPV_CaseOperativas_Controller.descartarReclamacion';
import verSiGestorLetrado from '@salesforce/apex/SPV_CaseOperativas_Controller.verSiGestorLetrado';
import establecerPretPpal from '@salesforce/apex/SPV_CaseOperativas_Controller.establecerPretPpal';
import recuperarGruposLetrado from '@salesforce/apex/SPV_CaseOperativas_Controller.recuperarGruposLetrado';
import reasignarGrupoLetrado from '@salesforce/apex/SPV_CaseOperativas_Controller.reasignarGrupoLetrado';
import activarComplementariaEntidad from '@salesforce/apex/SPV_CaseOperativas_Controller.activarComplementariaEntidad';
import activarRectificacion from '@salesforce/apex/SPV_CaseOperativas_Controller.activarRectificacion';
import reabrirReclamacion from '@salesforce/apex/SPV_CaseOperativas_Controller.reabrirReclamacion';
import devolverReclamacionAlta from '@salesforce/apex/SPV_CaseOperativas_Controller.devolverReclamacionAlta';
import prorrogarReclamacion from '@salesforce/apex/SPV_CaseOperativas_Controller.prorrogarReclamacion';
import comprobarSLAGeneralActivo from '@salesforce/apex/SPV_CaseOperativas_Controller.comprobarSLAGeneralActivo';
import clasificarDocumentoProrroga from '@salesforce/apex/SPV_CaseOperativas_Controller.clasificarDocumentoProrroga';
import activarComplementariaOrganismo from '@salesforce/apex/SPV_CaseOperativas_Controller.activarComplementariaOrganismo';
import MOTIVODEVOLUCION_FIELD from '@salesforce/schema/Case.SAC_Motivo__c';
import MOTIVORECHAZO_FIELD from '@salesforce/schema/Case.SAC_MotivoRechazo__c';
import MOTIVOCOMPLORGANISMO_FIELD from '@salesforce/schema/Case.SPV_MotivoComplementariaOrganismo__c';



const FIELDS = ['Case.OwnerId', 'Case.Status', 'Case.SAC_MotivoRechazo__c', 'Case.RecordType.DeveloperName', 'Case.SEG_Grupo__c', 'Case.SEG_Subestado__c', 'Case.SAC_EsPrincipal__c', 'Case.SPV_Complementaria_Entidad__c', 'Case.SAC_Prorrogado__c', 'Case.SPV_Rectificado__c', 'Case.SPV_ComplementariaOrganismo__c', 'Case.SPV_Organismo__c'];

export default class Spv_CaseOperativas extends LightningElement {
    @api recordId;
    @api selectedOptionGrupoLet = '';

    @track esPropietario;
    @track owner;
    @track recordType;
    @track status; 
    @track subestado;
    @track isLoading;
    @track esGestor;
    @track esLetrado;
    @track esAdministrador;
    @track habilitarDevolver;
    @track habilitarVolverAnalisis = false;
    @track grupo;
    @track modalDevolver;
    @track modalVolverAnalisis = false;
    @track options = [];
    @track selectedMotivo;
    @track observacion;
    @track motivo;
    @track esPretPpal = false;
    @track esPretension = false;
    @track esReclamacion = false;
    @track modalReasignar = false;
    @track inputMotivoReasignar;
    @track observacionesVolverAnalisis = '';     //Aquí se almacenan las observaciones escritas al pulsar sobre el botón "volver a análisis"
    @track esComplementariaEntidad;
    @track esComplementariaOrganismo = false;
    @track prorrogado;
    @track esRectificado;
    @track mostrarBotonComplementariaEntidad = false;
    @track mostrarBotonComplementariaOrganismo = false;
    @track mostrarBotonRectificacion = false;
    @track deshabilitarBotonDescartar = true;   //Controla si se muestra el botón de "Descartar", solo si es una reclamación en estado de alta
    @track abrirModalDescartar = false;       //Controla si se muestra el modal de "Descartar" al pulsar el botón correspondiente
    @track selectedMotivoDescarte;            //Se actualiza según se seleccione el motivo de descartado
    @track esGestorLetrado = false;           //Variable para controlar si el user es owner de la reclamación o de las pretensiones
    @track mostrarBotonReapertura = false;
    @track modalReapertura = false;
    @track modalConfirmarReapertura = false;
    @track mensajeConfReapertura = '';
    @track reaperturaRectificacion = false;
    @track reaperturaComplementariaOrganismo = false;
    @track motivoReapertura = '';
    @track mostrarDevolverAlta = false;       //Variable que controla cuándo se mostrará el botón para volver al estado de Alta
    @track modalDevolverAlta = false;         //Variable que controla cuándo se muestra el modal para volver a alta
    @track modalProrroga = false;
    @track modalCompleOrganismo = false;
    @track selectedMotivoComplOrganismo = ''; 
    @track organismo = '';

    optionsGruposLet = [];


    @wire(getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVODEVOLUCION_FIELD })
    getMotivo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVORECHAZO_FIELD })
    getMotivoRechazo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVOCOMPLORGANISMO_FIELD })
    getMotivoComplOrganismo;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredGetRecord({data, error}){
        if(data){

            //Iniciar a false todos los botones al recargar
            this.esPretension = false;
            this.habilitarDevolver = false;
            this.esReclamacion = false;
            this.habilitarVolverAnalisis = false;
            this.mostrarBotonComplementariaEntidad = false;
            this.mostrarBotonComplementariaOrganismo = false;
            this.mostrarBotonRectificacion = false;
            this.mostrarBotonProrroga = false;
            this.mostrarBotonReapertura = false;
            this.mostrarDevolverAlta = false;

            this.recordType = data.fields.RecordType.value.fields.DeveloperName.value;
            if(this.recordType === 'SPV_Pretension'){
                this.esPretension = true;
            }else if(this.recordType === 'SPV_Reclamacion'){
                this.esReclamacion = true;
            }
            this.owner =  data.fields.OwnerId.value;

            if(USER_ID === this.owner){
                this.esPropietario = true;
            }else{
                this.esPropietario = false;
            }

            this.status = data.fields.Status.value;
            this.subestado = data.fields.SEG_Subestado__c.value;
            this.esComplementariaEntidad = data.fields.SPV_Complementaria_Entidad__c.value;
            this.esComplementariaOrganismo = data.fields.SPV_ComplementariaOrganismo__c.value;
            this.esRectificado = data.fields.SPV_Rectificado__c.value;
            this.prorrogado = data.fields.SAC_Prorrogado__c.value;
            this.organismo = data.fields.SPV_Organismo__c.value;
            this.botonLabel = this.esComplementariaEntidad ? 'Desactivar complementaria entidad' : 'Activar complementaria entidad';
            this.mostrarBotonReapertura = false;
            this.mostrarBotonComplementariaOrganismo = false;
            if(this.status == 'SPV_EnvioOrganismos'  && this.subestado == 'Revision') {
                this.habilitarVolverAnalisis = true;
            }
            if(this.status == 'Cerrado'){
                if(this.esReclamacion){
                    this.mostrarBotonReapertura = true;
                }
            }


            if(this.status == 'SPV_PendienteRespuestaOrganismos'){

                if(this.esComplementariaOrganismo === false){
                    this.mostrarBotonComplementariaOrganismo = true;
                }

                if((this.subestado == 'Pendiente respuesta Organismos' || this.subestado == 'Ejecucion y Pendiente Respuesta Organismo') && this.organismo != 'SPV_Consumo'){
                    this.mostrarBotonComplementariaEntidad = true;
                    this.mostrarBotonRectificacion = true;
                }
            }
            if(this.esReclamacion && !this.prorrogado && (this.status == 'SAC_002' || this.SPV_ComplementariaOrganismo__c == true)){
                comprobarSLAGeneralActivo({'idCaso': this.recordId}).then(result=>{
                    if(result == true || result == false){
                        this.mostrarBotonProrroga = result;
                    }
                }).catch(error =>{
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: JSON.stringify(error),
                            variant: 'error'
                        }),);
                });
            }
            this.grupo = data.fields?.SEG_Grupo__c?.value;
            
            
            this.esPretPpal = data.fields.SAC_EsPrincipal__c.value;

            recuperarUser({ 'grupoCaso': this.grupo, 'idCaso': this.recordId, 'ownerCaso': this.owner}).then(result=>{
                if(result){
                    
                    this.esGestor = result.SPV_Gestor !== undefined;
                    this.esLetrado = result.SPV_Letrado !== undefined;
                    this.esAdministrador = result.SPV_Administrador !== undefined;

                    if(this.esGestor === true && this.status === 'SAC_001'){
                        this.habilitarDevolver = true;
                    }else{
                        this.habilitarDevolver = false;
                    }

                }
            }).catch(error =>{
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error'
                    }),);
            });


            verSiGestorLetrado({'idCaso': this.recordId, 'ownerCaso': this.owner}).then(resultado=>{
               
                if(resultado == true || resultado == false){
                    this.esGestorLetrado = resultado;
                 

                    //El gestor/letrado, en estado de alta o análisis, puede ver el botón de descartar
                    if(this.esGestorLetrado == true && (this.status === 'SAC_001' || this.status === 'SAC_002') && this.esReclamacion == true){
                        this.deshabilitarBotonDescartar = false;
                    }else{
                        this.deshabilitarBotonDescartar = true;
                    }

                    //Solo se mostrará el botón para devolver a alta en caso de una reclamación en estado de análisis
                    if(this.esGestorLetrado == true && this.status == 'SAC_002' && this.esReclamacion == true){
                        this.mostrarDevolverAlta = true;
                    }else{
                        this.mostrarDevolverAlta = false;
                    }

                }
            }).catch(error =>{
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error'
                    }),);
            });



          
        }
    }

    get mostrarReasignar() {
        return !this.esAdministrador;
    }

    get getDisabledRectificacion(){
        if(this.esRectificado && this.organismo != 'SPV_Consumo'){
            return false;
        }else{
            return true;
        }
    }

    tomarPropiedad(){         
        this.isLoading= true;
        this.recordId;
        tomarPropiedadCaso({'caseId': this.recordId, 'ownerId': USER_ID}).then(()=>{
        this.isLoading = false;
        this.refreshView();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Éxito',
                message: 'Se ha cambiado el propietario correctamente.',
                variant: 'success'
            }),);          
        
        }).catch(error =>{
            this.isLoading = false;
            this.lanzarToast('Error', 'Error al tomar la propiedad: ' + this.extractErrorMessage(error), 'error');
        });
        
    }


    
    devolverCasoBoton(){
        this.selectedMotivo = null;
        return this.modalDevolver = true;
    }


    devolverACola(){
        this.isLoading=true;
        this.motivo = this.selectedMotivo
        if(this.motivo !=null){
            if(this.motivo == 'SAC_Otros' && this.observacion == undefined){
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:  "Si el motivo es 'Otros' debes informar una observación.",
                        variant: 'error'
                    }),);
            }else{
                devolverCaso({'caseId': this.recordId, 'motivo': this.motivo}).then(()=>{
                    this.isLoading=false;
                    this.modalDevolver=false;
                    this.refreshView();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Caso devuelto',
                            message:  "El caso se ha devuelto a la cola genérica",
                            variant: 'success'
                        }),);
                }).catch(error=>{
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: JSON.stringify(error),
                            variant: 'error'
                        }),);
                });
            }
        }else if(this.motivo == null){
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No hay motivo',
                    variant: 'error'
                }),);
        }
    }


    handleChangeMotivo(event){
        this.selectedMotivo = event.target.value;
    }

    handleChangeObs(event){
        this.observacion = event.target.value;
    }

    closeModal(){
        return this.modalDevolver = false;
    }

    get noEsPropietario(){
        return !this.esPropietario;
    }

    

    onClickAbrirModalDescartar(){
        this.abrirModalDescartar = true;
        this.selectedMotivoDescarte = null;
    }

    cerrarModalDescartar(){
        this.abrirModalDescartar = false;
    }

    handleChangeMotivoDescartar(event){
        this.selectedMotivoDescarte = event.target.value;
    }

    descartarReclamacion(){
        

        if(this.selectedMotivoDescarte == null){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: "Por favor, seleccione el motivo de rechazo para descartar el caso.",
                    variant: 'error'
                }),);
        }else{
            this.isLoading= true;
            this.abrirModalDescartar = false;
            metodoDescartarReclamacion({'caseId': this.recordId, 'motivo': this.selectedMotivoDescarte}).then(()=>{
                this.isLoading = false;
                this.deshabilitarBotonDescartar = true;
                this.refreshView();
    
                this.dispatchEvent(
                    new ShowToastEvent({
                        tittle: 'Estado actualizado',
                        message: "El estado del caso ha pasado a Descartado.",
                        variant: 'success'
                    }),);
    
            }).catch(error=>{
                this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: JSON.stringify(error.body.message),
                            variant: 'error'
                    }),);
            });

           /* generarAdjunto({'binaryData': "1QACwAAAAADAAMAAAFLCAgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs=", 'nombreDocumento': 'test', 'parentId': this.recordId}).then(resultado2=>{
                console.log('generado');
            }).catch(error =>{
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error'
                    }),);
            });*/

        }
    }
 
 
    onClickAbrirModalDevolverAlta(){
        this.modalDevolverAlta = true;
    }

    cerrarModalDevolverAlta(){
        this.modalDevolverAlta = false;
    }

    handleChangeDevolverAlta(){
        this.isLoading = true;
        this.modalDevolverAlta = false;

        devolverReclamacionAlta({'caseId': this.recordId}).then(()=>{
            this.isLoading = false;
            this.mostrarDevolverAlta = false;
            this.refreshView();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message:  "El caso se ha devuelto al estado de Alta.",
                    variant: 'success'
                }),);
        }).catch(error=>{
            this.isLoading = false;
            this.lanzarToast('Error', 'Error al devolver la reclamación a alta: ' + this.extractErrorMessage(error), 'error');
        });

    }




    volverAnalisisBoton(){
        this.modalVolverAnalisis = true;
        this.observacionesVolverAnalisis= '';
    }

    closeModalVolverAnalisis(){
        this.modalVolverAnalisis = false;
    }

    handleChangeVolvAnalisis(event){
        this.observacionesVolverAnalisis = event.target.value;
    }


    volverAnalisis(){

        if(this.observacionesVolverAnalisis == ''){
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: "Por favor, complete las observaciones para volver a análisis.",
                    variant: 'error'
                }),);
        }else{
      
            this.isLoading = true;
            this.modalVolverAnalisis = false;
     
            volverAnalisisCaso({'caseId': this.recordId, 'observaciones': this.observacionesVolverAnalisis}).then(()=>{
                this.isLoading = false;
                this.habilitarVolverAnalisis = false;
                this.refreshView();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Caso devuelto',
                        message:  "El caso se ha devuelto a la fase de análisis",
                        variant: 'success'
                    }),);
            }).catch(error=>{
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error'
                    }),);
            });
        }
 
    }

    setPretPpal(){
        this.isLoading = true;

        establecerPretPpal({'caseId': this.recordId}).then(()=>{
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'Se ha actualizado la pretensión actual como pretensión principal de la reclamación.', 'success');        
            
        }).catch(error =>{
            this.isLoading = false;
            this.lanzarToast('Error', 'Error al establecer la pretensión como principal: ' + this.extractErrorMessage(error), 'error');
        });
    }

    abrirReasignarLetrado(){
        recuperarGruposLetrado({}).then(result=>{
            if(result){
                this.modalReasignar = true;

                this.optionsGruposLet = result.map(item => ({
                                                    label: item.Name,
                                                    value: item.Id
                                                }));
            }
        }).catch(error =>{
            this.lanzarToast('Error', 'Error al recuperar los grupos letrado: ' + this.extractErrorMessage(error), 'error');
        });
    }

    handleOptionChangeGrupoLet(event){
        this.selectedOptionGrupoLet = event.detail.value;
    }

    closeModalReasignar(){
        this.modalReasignar = false;
        this.selectedOptionGrupoLet = '';
        this.inputMotivoReasignar = '';
    }

    onChangeMotivoReasignar(event){
        this.inputMotivoReasignar = event.target.value;
    }

    confirmarReasigGrupLet(){
        this.modalReasignar = false;
        this.isLoading = true;

        if(this.selectedOptionGrupoLet != '' && this.inputMotivoReasignar != '' && this.inputMotivoReasignar != undefined){
            reasignarGrupoLetrado({'caseId': this.recordId, 'idGrupo': this.selectedOptionGrupoLet, 'motivo': this.inputMotivoReasignar}).then(()=>{
                this.isLoading = false;
                this.refreshView();
                this.lanzarToast('Éxito!', 'Se ha actualizado el grupo de trabajo de las pretensiones e informado el motivo de reasignación.', 'success');        
                
            }).catch(error =>{
                this.isLoading = false;
                this.lanzarToast('Error', 'Error al asignar el nuevo grupo letrado: ' + this.extractErrorMessage(error), 'error');
            });
        }else{
            this.lanzarToast('Cuidado!', 'Debe completar todos los campos para finalizar la reasignación.', 'warning');
        }
    }

    activarComplementariaEntidadBoton(event) {
        this.isLoading= true;
        this.recordId;        
        activarComplementariaEntidad({'idCaso': this.recordId}).then(()=>{
        this.isLoading = false;
        this.refreshView();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Éxito',
                message: 'Se ha activado la complementaria.',
                variant: 'success'
            }),);          
        
        }).catch(error =>{
            this.isLoading = false;
            this.lanzarToast('Error', 'Error al activar ' + this.extractErrorMessage(error), 'error');
        });
    }

    activarRectificacionBoton(event) {
        this.isLoading= true;
        this.recordId;        
        activarRectificacion({'idCaso': this.recordId}).then(()=>{
        this.isLoading = false;
        this.refreshView();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Éxito',
                message: 'Se ha iniciado la rectificación.',
                variant: 'success'
            }),);          
        
        }).catch(error =>{
            this.isLoading = false;
            this.lanzarToast('Error', 'Error al activar ' + this.extractErrorMessage(error), 'error');
        });
    }

    onClickProrrogar() {
        this.modalProrroga = true;
    }

    closeModalProrroga() {
        this.modalProrroga = false;
    }

    get acceptedFormats() {
        return ['.pdf','.png','.jpg', '.jpeg'];
    }

    handleUploadFinished(event) {
        let uploadedFiles = event.detail.files;

        clasificarDocumentoProrroga({caseId: this.recordId, numFicheros: uploadedFiles.length}).then(() => {
            this.refreshView();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Se ha subido el archivo.',
                    variant: 'success'
                }),);          
        
        }).catch(error =>{
            this.isLoading = false;
            this.lanzarToast('Error', 'Error al subir el archivo ' + this.extractErrorMessage(error), 'error');
        });
    }

    prorrogarReclamacion(event) {
        this.isLoading= true;
        this.modalProrroga = false;

        prorrogarReclamacion({'idCaso': this.recordId}).then(()=>{
            this.isLoading = false;
            this.refreshView();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Se ha prorrogado la reclamación.',
                    variant: 'success'
                })
            );          
        
        }).catch(error =>{
            this.isLoading = false;
            this.lanzarToast('Error', 'Error al prorrogar: ' + this.extractErrorMessage(error), 'error');
        });
    }

    onClickAbrirModalReapertura(){
        this.modalReapertura = true;
    }

    closeModalReapertura(){
        this.modalReapertura = false;
        this.motivoReapertura = '';
    }

    abrirModalConfirmacion(event){

        this.modalReapertura = false;
        const idBoton = event.target.dataset.id;

        if(idBoton === 'complementariaOrganismo'){
            this.reaperturaComplementariaOrganismo = true;
            this.reaperturaRectificacion = false;
        }else if(idBoton === 'rectificacion'){
            this.reaperturaComplementariaOrganismo = false;
            this.reaperturaRectificacion = true;
        }

        this.modalConfirmarReapertura = true;
    }

    closeModalConfReapertura(){
        this.modalConfirmarReapertura = false;
        this.modalReapertura = true;
    }

    handleChangeMotivoReap(event){
        this.motivoReapertura = event.target.value;
    }

    confirmarReapertura(){

        if(this.motivoReapertura !== ''){
            this.modalConfirmarReapertura = false;
            this.isLoading = true;

            reabrirReclamacion({'idCaso': this.recordId, 'reaperturaComplementariaOrganismo': this.reaperturaComplementariaOrganismo, 'reaperturaRectificacion': this.reaperturaRectificacion, 'motivoReapertura': this.motivoReapertura}).then(()=>{
                this.isLoading = false;
                this.motivoReapertura = '';
                this.refreshView();
                this.lanzarToast('Éxito', 'Se ha reabierto la reclamación.', 'success');        
                
            }).catch(error =>{
                this.isLoading = false;
                this.lanzarToast('Error', 'Error al reabrir la reclamación: ' + this.extractErrorMessage(error), 'error');
            });
        }else{
            this.lanzarToast('Advertencia!', 'Debe completar el motivo de reapertura de la reclamación.', 'warning');
        }
    }

    abrirModalComplOrganismo(){
        this.modalCompleOrganismo = true;
    }

    closeModalComplOrganismo(){
        this.modalCompleOrganismo = false;
        this.selectedMotivoComplOrganismo = '';
    }

    handleOptionChangeComplOrganismo(event){
        this.selectedMotivoComplOrganismo = event.target.value;
    }

    activarComplementariaOrganismoBtn(){
        
        if(this.selectedMotivoComplOrganismo != ''){

            this.isLoading = true;
            this.modalCompleOrganismo = false;

            activarComplementariaOrganismo({'caseId': this.recordId, 'motivoComplementaria': this.selectedMotivoComplOrganismo}).then(()=>{
                this.isLoading = false;
                this.refreshView();
                this.lanzarToast('Éxito', 'Se ha activado la complementaria organismo y cambiado de estado la reclamación.', 'success');
                
                }).catch(error =>{
                    this.isLoading = false;
                    this.lanzarToast('Error', 'Error al activar la complementaria organismo: ' + this.extractErrorMessage(error), 'error');
                });
        }else{
            this.lanzarToast('Advertencia!', 'Debe completar el motivo de la activación.', 'warning');
        }
    }

    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }

    lanzarToast(titulo, mensaje, variante) {
        const toastEvent = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: variante
        });
        this.dispatchEvent(toastEvent);
    }

    // Método para extraer el mensaje de error de la regla de validación
    extractErrorMessage(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0) {
            return error.body.pageErrors[0].message;
        } else {
            return 'Error desconocido';
        }
    }
}