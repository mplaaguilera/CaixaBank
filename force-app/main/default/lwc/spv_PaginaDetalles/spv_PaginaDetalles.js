import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import ESCALADO_OBJECT from '@salesforce/schema/SAC_Interaccion__c'; 


//Campos reclamación
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import IDFIELD from '@salesforce/schema/Case.Id';
import CASE_EXTENSION from '@salesforce/schema/Case.CBK_Case_Extension_Id__c';
import FECHA_ENVIO_ORGANISMOS_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_FechaEnvioOrganismos__c';
import FECHA_RESPUESTA_ORGANISMOS_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_FechaPteRespuestaOrganismo__c';
import CASO_NEGOCIADO_FIELD from '@salesforce/schema/Case.SAC_CasoNegociado__c';
import NEGOCIACION_FINALIZADA_FIELD from '@salesforce/schema/Case.SAC_NegociacionFinalizada__c';
import RESULTADO_NEGOCIACION_FIELD from '@salesforce/schema/Case.SAC_ResultadoNegociacion__c';
import NEGOCIACION_FINALIZADA_RECTIFICACION_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_NegociacionFinalizadaRectificacion__c';
import RESULTADO_NEGOCIACION_RECTIFICACION_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_ResultadoNegociacionRectificacion__c';
import FECHA_COMPLEMENTARIA_ENTIDAD_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_FechaComplementariaEntidad__c';
import FECHA_COMPLEMENTARIA_ORGANISMO_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_FechaComplementariaOrganismo__c';
import MOTIVO_PRORROGA_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_MotivoProrroga__c';
import MOTIVO_ANULACION_PRORROGA_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_MotivoAnulacionProrroga__c';
import MOTIVO_DEVOLUCION_ALTA_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_MotivoDevolucionAlta__c';
import MOTIVO_DESCARTE_FIELD from '@salesforce/schema/Case.SAC_MotivoDescarte__c';
import MOTIVO_DEVOLUCION_ENVIO_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_MotivoDevolucionEnvio__c';
import MOTIVO_DEVOLUCION_COMPLEMENTARIA_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_MotivoDevolucionComplementaria__c';
import MOTIVO_DEVOLUCION_RECTIFICACION_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_MotivoDevolucionRectificacion__c';
import MOTIVO_REAPERTURA_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_MotivoReapertura__c';
import CASO_RECTIFICADO_FIELD from '@salesforce/schema/Case.SPV_Rectificado__c';
import SENTIDO_RESOLUCION_FIELD from '@salesforce/schema/Case.SAC_SentidoResolucion__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import ORGANISMO_FIELD from '@salesforce/schema/Case.SPV_Organismo__c';
import DIAVENCIMIENTO_FIELD from '@salesforce/schema/Case.SAC_DiaVencimientoSLA__c';


//Llamadas Apex
import getNegociacionesReclamacion from '@salesforce/apex/SPV_LCMP_PaginaDetalles.getNegociacionesReclamacion';
import getComplementariasReclamacion from '@salesforce/apex/SPV_LCMP_PaginaDetalles.getComplementariasReclamacion';
import getRectificacionesReclamacion from '@salesforce/apex/SPV_LCMP_PaginaDetalles.getRectificacionesReclamacion';
import getDecisionesReclamacion from '@salesforce/apex/SPV_LCMP_PaginaDetalles.getDecisionesReclamacion';
import updateRecordsForm from '@salesforce/apex/SPV_LCMP_PaginaDetalles.updateRecordsForm';
import getRecordTypes from '@salesforce/apex/SPV_Utils.obtenerRecordTypes';

const fields = [IDFIELD, OWNERID_FIELD,STATUS_FIELD, FECHA_ENVIO_ORGANISMOS_FIELD, FECHA_RESPUESTA_ORGANISMOS_FIELD, CASO_NEGOCIADO_FIELD, NEGOCIACION_FINALIZADA_FIELD, RESULTADO_NEGOCIACION_FIELD, 
    NEGOCIACION_FINALIZADA_RECTIFICACION_FIELD, RESULTADO_NEGOCIACION_RECTIFICACION_FIELD, FECHA_COMPLEMENTARIA_ENTIDAD_FIELD, FECHA_COMPLEMENTARIA_ORGANISMO_FIELD, CASO_RECTIFICADO_FIELD,
    SENTIDO_RESOLUCION_FIELD, CASE_EXTENSION, MOTIVO_PRORROGA_FIELD, MOTIVO_ANULACION_PRORROGA_FIELD, MOTIVO_DEVOLUCION_ALTA_FIELD, MOTIVO_DESCARTE_FIELD, MOTIVO_DEVOLUCION_ENVIO_FIELD, MOTIVO_DEVOLUCION_COMPLEMENTARIA_FIELD, MOTIVO_DEVOLUCION_RECTIFICACION_FIELD, MOTIVO_REAPERTURA_FIELD, ORGANISMO_FIELD, DIAVENCIMIENTO_FIELD
];

export default class Spv_PaginaDetalles extends LightningElement {

    @api recordId;
    @api objectApiName;
    @track rtReclamacion;
    @track rtEscalado;
    @track rtReclamacionExt;
    @track spinnerLoading = false;

    @track caso;
    @track idCaso;
    @track caseExtensionId;
    @track casoNegociado;
    @track casoNegociadoEnRectificacion = false;        //Se muestra cuando hay resultados de la negociación posterior al informe supervisor.
    @track casoNegociadoAntesRectificacion = false;        //Se muestra cuando hay resultados de la negociación previo al informe supervisor.
    @track casoComplementarias = false;        //Se muestra cuando hay complementarias.
    @track casoRectificaciones = false;        //Se muestra cuando hay rectificaciones.
    @track casoDecisionAnalisis = false;        //Se muestra cuando hay decisiones.
    @track casoRectificado;                     //Se muestra la sección de Rectificación solo si el caso ha sido rectificado

    @track mostrarObservacionesMotivoProrroga = false; // Controla la visibilidad del campo Observaciones del SPV_MotivoProrroga__c
    @track mostrarObservacionesAnulacionProrroga = false; // Controla la visibilidad del campo Observaciones del SPV_MotivoAnulacionProrroga__c
    @track mostrarObservacionesDevolucionEnvio = false; // Controla la visibilidad del campo Observaciones del SPV_MotivoDevolucionEnvio__c
    @track mostrarObservacionesDevolucionComplementarias = false; // Controla la visibilidad del campo Observaciones del SPV_MotivoDevolucionComplementaria__c
    @track mostrarObservacionesDevolucionRectificacion = false; // Controla la visibilidad del campo Observaciones del SPV_MotivoDevolucionRectificacion__c
    @track mostrarObservacionesReapertura = false; // Controla la visibilidad del campo Observaciones del SPV_MotivoReapertura__c
    @track mostrarObservacionesDevolucionAlta = false; // Controla la visibilidad del campo Observaciones del SPV_MotivoDevolucionAlta__c
    @track mostrarObservacionesDescarte = false; // Controla la visibilidad del campo Observaciones del SAC_MotivoDescarte__c
    @track mostrarInformeDesfavorable = false; // Controla la visibilidad de los campos SPV_Conclusion__c y SPV_TipoDesfavorable__c del SAC_SentidoResolucion__c
    @track mostrarComunidadAutonoma = false; // Controla la visibilidad del campo SPV_Organismo__c
    @track placeholderDiaVencimiento = '';
    @track selectedOptionDiaVencimiento;

    //Controlar desplegable: Datos del reclamante
    @track toggleSeccionDatosReclamantes = "slds-section slds-is-open";
    @track expandirDatosReclamantes = true;

    //Controlar desplegable: Datos del contacto
    @track toggleSeccionDatosContacto = "slds-section slds-is-open";
    @track expandirDatosContacto = true;

    //Controlar desplegable: Datos del representante
    @track toggleSeccionDatosRepresentante = "slds-section slds-is-open";
    @track expandirDatosRepresentante = true;

    //Controlar desplegable: Detalles
    @track toggleSeccionDetalles = "slds-section slds-is-open";
    @track expandirDetalles = true;

    //Controlar desplegable: Categorizacion MCC
    @track toggleSeccionCategorizacion = "slds-section slds-is-open";
    @track expandirCategorizacion = true;

    //Controlar desplegable seccion: Decisión Análisis
    @track toggleSeccionDecisionAnalisis = "slds-section slds-is-open";
    @track expandirDecisionAnalisis = true;
    @track mostrarAnalisisDecision = false;
    @track listDecisionAnalisis = [];

    //Controlar desplegable: Complementarias
    @track toggleSeccionComplementarias = "slds-section slds-is-open";
    @track expandirComplementarias = true;
    @track mostrarComplementarias = false;
    @track listComplementarias = [];

    //Controlar Desplegable: Negociación
    @track toggleSeccionNegociaciones = "slds-section slds-is-open";
    @track expandirNegociaciones = true;
    @track mostrarNegociaciones;
    @track listNegociacionPreviaInforme = [];
    @track listNegociacionPosteriorInforme = [];

    //Controlar desplegable: Resolución organismo
    @track toggleSeccionResolucionOrganismo = "slds-section slds-is-open";
    @track expandirResolucionOrganismo = true;
    @track mostrarResolucionOrganismo = false;

    //Controlar desplegable: Rectificación
    @track toggleSeccionRectificacion = "slds-section slds-is-open";
    @track expandirRectificacion = true;
    @track mostrarRectificacion = false;
    @track mostrarPrueba = false;
    @track editarCampos = false; //Se pone a true cuando quiere que los campos se muestren en modo formulario
    @track listRectificaciones = [];

    //Controlar desplegable: Resumen económico
    @track toggleSeccionResumenEconomico = "slds-section slds-is-open";
    @track expandirResumenEconomico = true;


    @wire(getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfoCase;

    @wire(getObjectInfo, {objectApiName: ESCALADO_OBJECT})
    objectInfoEscalado;

    //Se obtienen los RecordType de reclamación y escalados de SPV
    @wire(getRecordTypes)
    getRecordTypesResult(result){
        if(result.data){    
            result.data.forEach(element => {
                if(element.DeveloperName == 'SPV_Reclamacion'){
                    this.rtReclamacion = element.Id;
                }else{
                    if(element.DeveloperName == 'SPV_ReclamacionCaseExt'){
                        this.rtReclamacionExt = element.Id;
                    }else{
                        this.rtEscalado = element.Id;
                    }
                    
                }
            });
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCase({error, data}){
        if(data){
            this.caso = data;
            this.idCaso = data.fields.Id.value;
            this.casoNegociado = data.fields.SAC_CasoNegociado__c.value;
            this.caseExtensionId = data.fields.CBK_Case_Extension_Id__c.value;

            this.mostrarPrueba = true;

            if(data.fields.Status.value == 'SPV_RecepcionResolucion' || data.fields.Status.value == 'Cerrado' || data.fields.Status.value == 'Descartado'){
                this.mostrarResolucionOrganismo = true;
            }else{
                this.mostrarResolucionOrganismo = false;
            }

            if(data.fields.Status.value != 'SAC_001'){
                this.mostrarAnalisisDecision = true;
            }else{
                this.mostrarAnalisisDecision = false;
            }

            //Solo se muestra la complementaria si hay info que mostrar
            if(data.fields.CBK_Case_Extension_Id__c.value != null && (data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_FechaComplementariaEntidad__c.value != null || data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_FechaComplementariaOrganismo__c.value != null)){
                this.mostrarComplementarias = true;
            }else{
                this.mostrarComplementarias = false;
            }            

            //Solo se muestra la sección de Negociación si alguna de las subsecciones tiene info que mostrar
            if(this.casoNegociado === true){
                this.mostrarNegociaciones = true;
            }else{
                this.mostrarNegociaciones = false;
            }

            //Solo se muestra la sección de Rectificación si el caso se ha rectificado
            if(data.fields.SPV_Rectificado__c.value === true){
                this.casoRectificado = true;
            }else{
                this.casoRectificado = false;
            }

            // Comprobar si se tienen que mostrar los campos de observaciones
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoProrroga__c.value === 'SPV_004'){
                this.mostrarObservacionesMotivoProrroga = true;
            }
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoAnulacionProrroga__c.value === 'SPV_003'){
                this.mostrarObservacionesAnulacionProrroga = true;
            }
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoDevolucionEnvio__c.value === 'SPV_010'){
                this.mostrarObservacionesDevolucionEnvio = true;
            }
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoDevolucionComplementaria__c.value === 'SPV_010'){
                this.mostrarObservacionesDevolucionComplementarias = true;
            }
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoDevolucionRectificacion__c.value === 'SPV_010'){
                this.mostrarObservacionesDevolucionRectificacion = true;
            }
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoReapertura__c.value === 'SPV_Otros'){
                this.mostrarObservacionesReapertura = true;
            }
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoDevolucionAlta__c.value === 'SPV_004'){
                this.mostrarObservacionesDevolucionAlta = true;
            }
            if(data.fields.SAC_MotivoDescarte__c.value === 'SAC_Otros'){
                this.mostrarObservacionesDescarte = true;
            }

            //Comprobar si el sentido resolución es desfavorable a la entidad
            if(data.fields.SAC_SentidoResolucion__c.value == 'SPV_DesfavorableEntidadTotal' || data.fields.SAC_SentidoResolucion__c.value == 'SPV_DesfavorableEntidadParcial'){
                this.mostrarInformeDesfavorable = true;
            }

            //Comprobar si la comunidad autónoma se tiene que mostrar
            if(data.fields.SPV_Organismo__c.value == 'SPV_Consumo'){
                this.mostrarComunidadAutonoma = true;
            }

            if(data.fields.SAC_DiaVencimientoSLA__c.value != null) {
                this.placeholderDiaVencimiento = data.fields.SAC_DiaVencimientoSLA__c.value;
            }

            // if(this.casoRectificado === true){
                getDecisionesReclamacion({'casoId': this.recordId}).then(result=>{
                    if(result){
                        this.listDecisionAnalisis= result.listDecisionAnalisis;
                        this.casoDecisionAnalisis = result.existeDecisionAnalisis;                     
                    }
                }).catch(error =>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: JSON.stringify(error),
                            variant: 'error'
                        })
                    );
                });
            // }

            if(this.mostrarComplementarias === true){
                getComplementariasReclamacion({'casoId': this.recordId}).then(result=>{
                    if(result){
                        this.listComplementarias = result.listComplementarias;
                        this.casoComplementarias = result.existeComplementarias;                        
                    }
                }).catch(error =>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: JSON.stringify(error),
                            variant: 'error'
                        })
                    );
                });
            }

            if(this.casoRectificado === true){
                getRectificacionesReclamacion({'casoId': this.recordId}).then(result=>{
                    if(result){
                        this.listRectificaciones= result.listRectificaciones;
                        this.casoRectificaciones = result.existeRectificaciones;                     
                    }
                }).catch(error =>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: JSON.stringify(error),
                            variant: 'error'
                        })
                    );
                });
            }

            if(this.casoNegociado === true){
                getNegociacionesReclamacion({'casoId': this.recordId}).then(result=>{
                    if(result){
                        this.listNegociacionPreviaInforme = result.listNegociacionPreviaInforme;
                        this.casoNegociadoAntesRectificacion = result.existeNegociacionPreviaInforme;
                        this.listNegociacionPosteriorInforme = result.listNegociacionPosteriorInforme;
                        this.casoNegociadoEnRectificacion = result.existeNegociacionPosteriorInforme;
                    }
                }).catch(error =>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: JSON.stringify(error),
                            variant: 'error'
                        })
                    );
                });
            }
        }
    }

    //Controlar cuando se pulsa en el lapiz de editar
    handleEditarCampos(event){
        if(this.editarCampos == false){
            this.editarCampos = true;
        }else{
            this.editarCampos = false;
        } 
    }

    handleSubmit(event){    
        event.preventDefault(); 
        
        const recordsMap = new Map(); 

        // Recorrer todos los lightning-record-edit-form en el componente
        this.template.querySelectorAll('lightning-record-edit-form').forEach((form) => {
            const recordId = form.dataset.recordId; // Extraer el recordId del atributo data-record-id
            
            // Si el recordId ya existe en el Map, usamos el objeto existente; si no, creamos uno nuevo
            let record = recordsMap.get(recordId) || { Id: recordId };

            const inputs = form.querySelectorAll('lightning-input-field');
            inputs.forEach((input) => {
                record[input.fieldName] = input.value; 
            });

            recordsMap.set(recordId, record);
            
        });

        if (recordsMap.has(this.idCaso)) {
            let caso = recordsMap.get(this.idCaso);
    
            // Añadir los cambios hechos en las picklist parametrizables si se han realizados cambios
            if(this.selectedOptionDiaVencimiento != '') {
                caso.SAC_FechaVencimientoSLA__c = this.selectedOptionDiaVencimiento;
            }
    
            recordsMap.set(this.idCaso, caso);
        } 


        // Convertir el Map en una lista de objetos
        const recordsToUpdate = Array.from(recordsMap.values());
        // Llamar al método Apex para actualizar los registros
        this.spinnerLoading = true;
        updateRecordsForm({'recordsToUpdate': recordsToUpdate})
            .then(() => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'Se han actualizado los campos correctamente.',
                        variant: 'success'
                    })
                );
                this.editarCampos = false;  //Se cierran los campos de modo edición
                this.dispatchEvent(new RefreshEvent());
            })
            .catch((error) => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al actualizar los campos.',
                        variant: 'error'
                    })
                );
                this.editarCampos = false;  //Se cierran los campos de modo edición
            });
    }

    //Controlar el abrir y cerrar desplegables
    handleExpandirDatosReclamantes(){
        if(this.expandirDatosReclamantes){
            this.expandirDatosReclamantes = false;
            this.toggleSeccionDatosReclamantes = "slds-section"; 
        }else{
            this.expandirDatosReclamantes = true;
            this.toggleSeccionDatosReclamantes = "slds-section slds-is-open";
        }
    }

    handleExpandirDatosContacto(){
        if(this.expandirDatosContacto){
            this.expandirDatosContacto = false;
            this.toggleSeccionDatosContacto = "slds-section"; 
        }else{
            this.expandirDatosContacto = true;
            this.toggleSeccionDatosContacto = "slds-section slds-is-open";
        }
    }

    handleExpandirDatosRepresentante(){
        if(this.expandirDatosRepresentante){
            this.expandirDatosRepresentante = false;
            this.toggleSeccionDatosRepresentante = "slds-section"; 
        }else{
            this.expandirDatosRepresentante = true;
            this.toggleSeccionDatosRepresentante = "slds-section slds-is-open";
        }
    }

    handleExpandirDetalles(){
        if(this.expandirDetalles){
            this.expandirDetalles = false;
            this.toggleSeccionDetalles = "slds-section"; 
        }else{
            this.expandirDetalles = true;
            this.toggleSeccionDetalles = "slds-section slds-is-open";
        }
    }

    handleExpandirCategorizacion(){
        if(this.expandirCategorizacion){
            this.expandirCategorizacion = false;
            this.toggleSeccionCategorizacion = "slds-section"; 
        }else{
            this.expandirCategorizacion = true;
            this.toggleSeccionCategorizacion = "slds-section slds-is-open";
        }
    }

    handleExpandirDecisionAnalisis(){
        if(this.expandirDecisionAnalisis){
            this.expandirDecisionAnalisis = false;
            this.toggleSeccionDecisionAnalisis = "slds-section"; 
        }else{
            this.expandirDecisionAnalisis = true;
            this.toggleSeccionDecisionAnalisis = "slds-section slds-is-open";
        }
    }

    handleExpandirListDecisionAnalisis(event){
        let buttonid = event.currentTarget.dataset.name;
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section';
        }
    }

    handleExpandirComplementarias(){
        if(this.expandirComplementarias){
            this.expandirComplementarias = false;
            this.toggleSeccionComplementarias = "slds-section";
        }else{
            this.expandirComplementarias = true;
            this.toggleSeccionComplementarias = "slds-section slds-is-open";
        }
    }

    handleExpandirComplementariasEntidad(event){
        let buttonid = event.currentTarget.dataset.name;
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section';
        }
    }

    handleExpandirComplementariasOrganismo(event){
        let buttonid = event.currentTarget.dataset.name;
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section';
        }
    }

    handleExpandirNegociaciones(){
        if(this.expandirNegociaciones){
            this.expandirNegociaciones = false;
            this.toggleSeccionNegociaciones = "slds-section"; 
        }else{
            this.expandirNegociaciones = true;
            this.toggleSeccionNegociaciones = "slds-section slds-is-open";
        }
    }

    handleExpandirNegociacionPrevia(event){
        let buttonid = event.currentTarget.dataset.name;
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section';
        }
    }

    handleExpandirNegociacionPosterior(event){
        let buttonid = event.currentTarget.dataset.name;
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section';
        }
    }


    handleExpandirResolucionOrganismo(){
        if(this.expandirResolucionOrganismo){
            this.expandirResolucionOrganismo = false;
            this.toggleSeccionResolucionOrganismo = "slds-section"; 
        }else{
            this.expandirResolucionOrganismo = true;
            this.toggleSeccionResolucionOrganismo = "slds-section slds-is-open";
        }
    }

    handleExpandirRectificacion(){
        if(this.expandirRectificacion){
            this.expandirRectificacion = false;
            this.toggleSeccionRectificacion = "slds-section"; 
        }else{
            this.expandirRectificacion = true;
            this.toggleSeccionRectificacion = "slds-section slds-is-open";
        }
    }

    handleExpandirListRectificacion(event){
        let buttonid = event.currentTarget.dataset.name;
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section';
        }
    }

    handleExpandirResumenEconomico(){
        if(this.expandirResumenEconomico){
            this.expandirResumenEconomico = false;
            this.toggleSeccionResumenEconomico = "slds-section"; 
        }else{
            this.expandirResumenEconomico = true;
            this.toggleSeccionResumenEconomico = "slds-section slds-is-open";
        }
    }


    // Controlar los campos picklist para mostrar los campos de observaciones solo en los casos requeridos
    handleMotivoProrrogaChange(event) {
        // Obtén el valor del campo SPV_MotivoProrroga__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'SPV_004') {
            this.mostrarObservacionesMotivoProrroga = true;
        }
    }

    handleMotivoAnulacionProrrogaChange(event) {
        // Obtén el valor del campo SPV_MotivoAnulacionProrroga__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'SPV_003') {
            this.mostrarObservacionesAnulacionProrroga = true;
        }
    }

    handleMotivoDevolucionEnvioChange(event) {
        // Obtén el valor del campo SPV_MotivoDevolucionEnvio__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'SPV_010') {
            this.mostrarObservacionesDevolucionEnvio = true;
        }
    }

    handleMotivoDevolucionComplementariasChange(event) {
        // Obtén el valor del campo SPV_MotivoDevolucionComplementaria__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'SPV_010') {
            this.mostrarObservacionesDevolucionComplementarias = true;
        }
    }

    handleMotivoDevolucionRectificacionChange(event) {
        // Obtén el valor del campo SPV_MotivoDevolucionRectificacion__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'SPV_010') {
            this.mostrarObservacionesDevolucionRectificacion = true;
        }
    }

    handleMotivoReaperturaChange(event) {
        // Obtén el valor del campo SPV_MotivoReapertura__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'SPV_Otros') {
            this.mostrarObservacionesReapertura = true;
        }
    }

    handleMotivoDevolucionAltaChange(event) {
        // Obtén el valor del campo SPV_MotivoDevolucionAlta__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'SPV_004') {
            this.mostrarObservacionesDevolucionAlta = true;
        }
    }

    handleMotivoDescarteChange(event) {
        // Obtén el valor del campo SAC_MotivoDescarte__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'SAC_Otros') {
            this.mostrarObservacionesDescarte = true;
        }
    }

    handleSentidoResolucionChange(event) {
        // Obtén el valor del campo SAC_SentidoResolucion__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'SPV_DesfavorableEntidadTotal' || selectedValue == 'SPV_DesfavorableEntidadParcial') {
            this.mostrarInformeDesfavorable = true;
        }
    }

    handleOrganismoChange(event) {
        // Obtén el valor del campo SPV_Organismo__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'SPV_Consumo') {
            this.mostrarComunidadAutonoma = true;
        } else {
            this.mostrarComunidadAutonoma = false;
        }
    }

    handleOptionChangeDiaVencimiento(event) {
        this.selectedOptionDiaVencimiento = event.detail.value;
    }

}