/**********************************************************************************************
 * SECCIÓN 1: IMPORTACIONES
 **********************************************************************************************/
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import currentUserId from '@salesforce/user/Id';
import { refreshApex } from '@salesforce/apex';

// Importaciones de esquemas de campos
import CASEID from '@salesforce/schema/Case.Id';
import CASERT from '@salesforce/schema/Case.RecordTypeId';
import CASENUMBER from '@salesforce/schema/Case.CaseNumber';
import OWNERID from '@salesforce/schema/Case.OwnerId';
import STATUS from '@salesforce/schema/Case.Status';
import CASORELACIONADO from '@salesforce/schema/Case.CC_CasoRelacionado__c';

// Importaciones de métodos Apex
import getFormularioExistente from '@salesforce/apex/SPV_LCMP_FormularioRectificacion.getFormularioExistente';
import getRectificacionesAnteriores from '@salesforce/apex/SPV_LCMP_FormularioRectificacion.getRectificacionesAnteriores';
import getPretensiones from '@salesforce/apex/SPV_LCMP_FormularioRectificacion.getPretensiones';
import compruebaLetradoSPV from '@salesforce/apex/SPV_LCMP_FormularioRectificacion.compruebaLetradoSPV';
import getImporteAbonadoTotal from '@salesforce/apex/SPV_LCMP_FormularioRectificacion.getImporteAbonadoTotal';
import completarRectificacionAnterior from '@salesforce/apex/SPV_LCMP_FormularioRectificacion.completarRectificacionAnterior';
import crearNuevoFormularioRectificacion from '@salesforce/apex/SPV_LCMP_FormularioRectificacion.crearNuevoFormularioRectificacion';

/**********************************************************************************************
 * SECCIÓN 2: CONSTANTES
 **********************************************************************************************/
const FIELDS = [CASEID, CASERT, CASENUMBER, OWNERID, STATUS, CASORELACIONADO];
const columns = [
    { 
        label: 'Fecha', 
        fieldName: 'SPV_FechaRectificacion__c', 
        type: 'date',
        typeAttributes: {
            day: 'numeric',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        }
    },
    { label: 'Propuesta Rectificacion', fieldName: 'SPV_PropuestaRectificacion__c', type: 'text', wrapText: true },
    { label: 'Instrucciones', fieldName: 'SPV_InstruccionesRect__c', type: 'text', wrapText: true }
];

/**********************************************************************************************
 * SECCIÓN 3: DEFINICIÓN DE LA CLASE PRINCIPAL Y PROPIEDADES
 **********************************************************************************************/
export default class Spv_formularioRectificacion extends LightningElement {
    // Propiedades API expuestas
    @api recordId;
    @api objectApiName;

    // Propiedades reactivas (tracked)
    @track recordTypeId;
    @track idFormularioCaso;
    @track spinnerLoading;
    @track rectificaciones;
    @track tienePermisosEditar = false;
    @track pretensiones = [];
    @track formularioNecesitaCrearse = false;

    // Estados de expansión de secciones
    @track toggleIconAnalisisBDE = "slds-section slds-is-open";
    @track bExpanseAnalisisBDE = true;
    @track toggleIconFuncionamientoSAC = "slds-section slds-is-open";
    @track bExpanseFuncionamientoSAC = true;
    @track toggleIconInformeBDE = "slds-section slds-is-open";
    @track bExpanseInformeBDE = true;
    @track toggleIconListadoRectificaciones = "slds-section slds-is-open";
    @track bExpanseListadoRectificaciones = true;
    @track toggleIconDatosGenerales = "slds-section slds-is-open";
    @track bExpanseDatosGenerales = true;
    @track toggleIconMotivacionRiesgos = "slds-section slds-is-open";
    @track importeAbonadoTotal = 0;
    @track toggleIconResolucion = "slds-section slds-is-open";
    @track bExpanseResolucion = true;
    @track toggleIconDecisionRect = "slds-section slds-is-open";
    @track bExpanseDecisionRect = true;

    // Estados y banderas de control
    @track creandoNuevaRectificacion = false;
    @track mostrarHistorico = false;
    @track showImporteRequired = false;
    @track fieldValues = {};
    @track formSubmitDisabled = false;
    @track showObservacionesRequired = false;
    @track camposReadOnly = true; // Iniciar en modo solo-lectura
    
    // Propiedades no reactivas
    originalValues = {};          // Para restaurar valores al cancelar
    guardandoCambios = false;     // Bandera para controlar el toast de éxito

    /**********************************************************************************************
     * SECCIÓN 4: WIRE SERVICES Y CARGA DE DATOS
     **********************************************************************************************/
    
    /**
     * Carga los datos del caso principal
     */
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredGetRecord({data, error}){
        if(data){
            // Verificar permisos del letrado SPV
            compruebaLetradoSPV({'caseId': this.recordId}).then(result => {
                this.tienePermisosEditar = result;
            });
            
            // Verificación adicional para caso relacionado
            if (this.pretensiones && this.pretensiones.length > 0 && 
                this.pretensiones[0].CC_CasoRelacionado__c) {
                // Lógica adicional para casos relacionados si es necesaria
            }
        }
    }

    /**
     * Obtiene el importe abonado total para el caso
     */
    @wire(getImporteAbonadoTotal, { caseId: '$recordId' })
    wiredImporteAbonado({ error, data }) {
        if (data !== undefined) {
            this.importeAbonadoTotal = data;
        } else if (error) {
            this.importeAbonadoTotal = 0;
        }
    }

    /**
     * Carga las rectificaciones anteriores para este caso
     */
    @wire(getRectificacionesAnteriores, { casoId: '$recordId'})
    wiredRectificaciones({data, error}){
        if(data){
            this.rectificaciones = data;
        }
    }

    /**
     * Carga las pretensiones asociadas al caso
     */
    @wire(getPretensiones, { casoId: '$recordId' })
    wiredPretensiones({ error, data }) {
        if (data) {
            this.pretensiones = data;
        }
    }

    /**
     * Verifica si existe un formulario para este caso y establece las banderas correspondientes
     */
    @wire(getFormularioExistente, { casoId: '$recordId'})
    getFormulario({ error, data }){
        if(data !== undefined) {
            if(data) {
                this.idFormularioCaso = data;
                this.mostrarHistorico = true; // Ya existe un formulario previo
                this.formularioNecesitaCrearse = false;
            } else {
                this.mostrarHistorico = false;
                this.formularioNecesitaCrearse = true; // Indicador de que se debe crear
            }
        } else if (error) {
            // Error al consultar formulario existente
        }
    }

    /**********************************************************************************************
     * SECCIÓN 5: MANEJADORES DE EVENTOS DE UI
     **********************************************************************************************/
    
    /**
     * Controla la expansión/contracción de la sección de datos generales
     */
    handleExpandableDatosGenerales(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconDatosGenerales = this.toggle(this.toggleIconDatosGenerales);    
    }
    
    /**
     * Controla la expansión/contracción de la sección de decisión de rectificación
     */
    handleExpandableDecisionRect(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconDecisionRect = this.toggle(this.toggleIconDecisionRect);    
    }
    
    /**
     * Controla la expansión/contracción del listado de rectificaciones
     */
    handleExpandableListadoRectificaciones(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconListadoRectificaciones = this.toggle(this.toggleIconListadoRectificaciones);    
    }
    
    /**
     * Controla la expansión/contracción de la sección de motivación y riesgos
     */
    handleExpandableMotivacionRiesgos(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconMotivacionRiesgos = this.toggle(this.toggleIconMotivacionRiesgos);    
    }
    
    /**
     * Controla la expansión/contracción de la sección de informe BDE
     */
    handleExpandableInformeBDE(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconInformeBDE = this.toggle(this.toggleIconInformeBDE);    
    }

    /**
     * Controla la expansión/contracción de la sección de funcionamiento SAC
     */
    handleExpandableFuncionamientoSAC(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconFuncionamientoSAC = this.toggle(this.toggleIconFuncionamientoSAC);
    }
    
    /**
     * Controla la expansión/contracción de la sección de resolución
     */
    handleExpandableResolucion(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconResolucion = this.toggle(this.toggleIconResolucion);    
    }

    /**
     * Maneja el cambio de valor en los campos del formulario
     */
    handleFieldChange(event) {
        const fieldName = event.target.fieldName;
        const fieldValue = event.target.value;
        
        // Almacenar valores para validación
        this.fieldValues[fieldName] = fieldValue;
        
        // Validación para el campo de Importe
        if (fieldName === 'SPV_PropuestaRectificacionLetrado__c') {
            const requiresAmount = 
                fieldValue === 'SI Rectificar Sin Negociación con pago' || 
                fieldValue === 'SI Rectificar Con Negociación con pago';
            
            this.showImporteRequired = requiresAmount;
        }
        
        // Validación para el campo de Observaciones Riesgos con feedback visual
        if (fieldName === 'SPV_Riesgos__c') {
            // Observaciones Riesgos es obligatorio para todos los valores excepto "No aplica"
            const wasRequired = this.showObservacionesRequired;
            this.showObservacionesRequired = (fieldValue && fieldValue !== 'No aplica');
            
            // Si cambió a obligatorio, dar feedback visual
            if (!wasRequired && this.showObservacionesRequired) {
                // Programar un resaltado temporal del campo relacionado
                setTimeout(() => {
                    const observacionesField = this.template.querySelector('lightning-input-field[field-name="SPV_ObservacionesRiesgos__c"]');
                    if (observacionesField) {
                        // Hacer focus para mostrar al usuario que debe completarlo
                        observacionesField.focus();
                    }
                }, 100);
            }
        }
        
        // Validar formulario para habilitación/deshabilitación del botón de envío
        this.validateForm();
    }

    /**********************************************************************************************
     * SECCIÓN 6: MANIPULACIÓN DE FORMULARIOS
     **********************************************************************************************/
    
    /**
     * Gestiona la creación de una nueva rectificación
     */
    handleNuevaRectificacion() {
        this.creandoNuevaRectificacion = true;
        this.spinnerLoading = true;
        
        if (this.idFormularioCaso) {
            // Primero completar la rectificación actual
            completarRectificacionAnterior({ formularioId: this.idFormularioCaso })
                .then(success => {
                    if (!success) {
                        throw new Error('No se pudo marcar la rectificación como completada');
                    }
                    
                    // Reset del ID del formulario y establecer bandera para crear uno nuevo
                    this.idFormularioCaso = null;
                    this.formularioNecesitaCrearse = true;
                    
                    // Crear el nuevo formulario de rectificación
                    return crearNuevoFormularioRectificacion({ casoId: this.recordId });
                })
                .then(nuevoFormularioId => {
                    // Asignar el ID del nuevo formulario
                    this.idFormularioCaso = nuevoFormularioId;
                    this.formularioNecesitaCrearse = false;
                    
                    // Actualizar la lista de rectificaciones anteriores
                    return getRectificacionesAnteriores({ casoId: this.recordId });
                })
                .then(rectificacionesData => {
                    this.rectificaciones = rectificacionesData;
                    
                    // Activar modo de edición y actualizar UI
                    this.camposReadOnly = false;
                    this.mostrarHistorico = true;
                    this.spinnerLoading = false;
                    this.creandoNuevaRectificacion = false;
                    
                    // Mostrar mensaje de éxito
                    this.showToast('Nueva rectificación', 'Puede editar los campos para la nueva rectificación', 'success');
                    
                    // Inicializar los valores del formulario para validación
                    this.inicializarValoresFormulario();
                })
                .catch(error => {
                    this.spinnerLoading = false;
                    this.creandoNuevaRectificacion = false;
                    this.showToast('Error', 'No se pudo iniciar la nueva rectificación: ' + 
                        (error.body?.message || error.message || 'Error desconocido'), 'error');
                });
        } else {
            // Si no hay rectificación previa, crear una nueva directamente
            crearNuevoFormularioRectificacion({ casoId: this.recordId })
                .then(nuevoFormularioId => {
                    // Asignar el ID del nuevo formulario
                    this.idFormularioCaso = nuevoFormularioId;
                    this.formularioNecesitaCrearse = false;
                    this.camposReadOnly = false;
                    this.spinnerLoading = false;
                    this.creandoNuevaRectificacion = false;
                    
                    // Mostrar mensaje de éxito
                    this.showToast('Nueva rectificación', 'Se ha creado la primera rectificación', 'success');
                    
                    // Inicializar los valores del formulario para validación
                    this.inicializarValoresFormulario();
                })
                .catch(error => {
                    this.spinnerLoading = false;
                    this.creandoNuevaRectificacion = false;
                    this.showToast('Error', 'No se pudo crear la rectificación: ' + 
                        (error.body?.message || error.message || 'Error desconocido'), 'error');
                });
        }
    }

    /**
     * Guarda todos los cambios del formulario
     */
    saveAll = () => {
        if (this.camposReadOnly) {
            return;
        }
        
        // Validar antes de guardar
        this.validateForm();
        
        // Si no pasa validación, mostrar error y detener
        if (this.formSubmitDisabled) {
            this.showToast('Error', 'Hay campos requeridos que debe completar antes de guardar', 'error');
            return;
        }
        
        this.spinnerLoading = true;
        this.guardandoCambios = true;
        
        // Verificar si necesitamos crear un formulario primero
        if (this.formularioNecesitaCrearse) {
            crearNuevoFormularioRectificacion({ casoId: this.recordId })
                .then(result => {
                    this.idFormularioCaso = result;
                    this.formularioNecesitaCrearse = false;
                    
                    // Ahora que tenemos ID, enviar el formulario
                    const form = this.template.querySelector('lightning-record-edit-form');
                    if (form) {
                        form.recordId = result;
                        form.submit();
                    }
                })
                .catch(error => {
                    this.spinnerLoading = false;
                    this.guardandoCambios = false;
                    this.showToast('Error', 'No se pudo crear el formulario: ' + 
                        (error.body?.message || error.message || 'Error desconocido'), 'error');
                });
        } else {
            // Ya existe un formulario, proceder normalmente
            const form = this.template.querySelector('lightning-record-edit-form');
            if (form) {
                form.submit();
            }
        }
    };
    
    /**
     * Maneja el evento submit del formulario
     */
    handleSubmit(event) {
        event.preventDefault();
        
        // Si no existe un formulario, crearlo primero
        if (!this.idFormularioCaso) {
            this.spinnerLoading = true;
            
            // Crear el formulario
            crearNuevoFormularioRectificacion({ casoId: this.recordId })
                .then(result => {
                    this.idFormularioCaso = result;
                    
                    // Una vez creado el formulario, continuar con la validación y el envío
                    this.validarYEnviar(event);
                })
                .catch(error => {
                    this.spinnerLoading = false;
                    this.showToast('Error', 'No se pudo crear el formulario: ' + error.message, 'error');
                });
        } else {
            // Si ya existe un formulario, solo validar y enviar
            this.validarYEnviar(event);
        }
    }

    /**
     * Valida y envía el formulario después de verificar campos requeridos
     */
    validarYEnviar(event) {
        // Validación existente para importe
        const propuestaValue = this.fieldValues['SPV_PropuestaRectificacionLetrado__c'];
        const importeValue = this.fieldValues['SPV_ImporteRectificacionPropuesto__c'];
        
        const requiresAmount = 
            propuestaValue === 'SI Rectificar Sin Negociación con pago' || 
            propuestaValue === 'SI Rectificar Con Negociación con pago';
        
        // Nueva validación para observaciones
        const riesgosValue = this.fieldValues['SPV_Riesgos__c'];
        const observacionesValue = this.fieldValues['SPV_ObservacionesRiesgos__c'];
        const requiresObservaciones = riesgosValue && riesgosValue !== 'No aplica';
        
        // Validar importe
        if (requiresAmount && (importeValue === undefined || importeValue === null || importeValue === '' || importeValue === 0)) {
            this.spinnerLoading = false;
            this.showToast('Error', 
                'El campo "Importe Rectificación Propuesto" es obligatorio cuando selecciona "SI Rectificar Sin Negociación con pago" o "SI Rectificar Con Negociación con pago"', 
                'error');
            return;
        }
        
        // Validar observaciones
        if (requiresObservaciones && (!observacionesValue || observacionesValue === '')) {
            this.spinnerLoading = false;
            this.showToast('Error', 
                'El campo "Observaciones Riesgos" es obligatorio cuando se selecciona cualquier opción en Riesgos excepto "No aplica"', 
                'error');
            return;
        }
        
        // Si pasa las validaciones, permitir que el formulario se envíe normalmente
        const form = this.template.querySelector('lightning-record-edit-form');
        if (form) {
            // Asegurarse de que el formulario tenga el ID correcto
            form.recordId = this.idFormularioCaso;
            form.submit();
        }
    }

    /**
     * Maneja el evento success cuando el formulario se guarda correctamente
     */
    handleSuccess(event) {
        this.idFormularioCaso = event.detail.id;
        this.camposReadOnly = true;
        this.spinnerLoading = false;
        
        // Si estamos creando una nueva rectificación, mostrar mensaje adecuado
        if (!this.guardandoCambios) {
            this.showToast('Nueva rectificación', 'La nueva rectificación se ha creado correctamente', 'success');
            // Actualizar la lista de rectificaciones anteriores
            refreshApex(this.wiredRectificaciones);
            // Actualizar el estado de la interfaz
            this.mostrarHistorico = true;
        } else if (this.guardandoCambios) {
            this.showToast('Formulario actualizado', 'Los cambios se guardaron correctamente.', 'success');
            this.guardandoCambios = false; // Resetear la bandera
        }
    }

    /**
     * Cambia de modo vista a modo edición
     */
    handleOutputEditClick() {
        // Guardar valores originales antes de entrar en modo edición
        this.originalValues = {};
        this.template.querySelectorAll('lightning-output-field').forEach(o => {
            if (o.fieldName) {
                this.originalValues[o.fieldName] = o.value;
            }
        });
        
        // Si necesitamos crear un formulario, hacerlo antes de activar modo edición
        if (this.formularioNecesitaCrearse) {
            this.spinnerLoading = true;
            
            crearNuevoFormularioRectificacion({ casoId: this.recordId })
                .then(result => {
                    this.idFormularioCaso = result;
                    this.formularioNecesitaCrearse = false;
                    this.camposReadOnly = false; // Activar edición después de crear
                    this.spinnerLoading = false;
                    
                    // Inicializar valores para validación después de crear
                    this.inicializarValoresFormulario();
                })
                .catch(error => {
                    this.spinnerLoading = false;
                    this.showToast('Error', 'No se pudo crear el formulario: ' + 
                        (error.body?.message || error.message || 'Error desconocido'), 'error');
                });
        } else {
            // Si ya existe formulario, sólo activar edición
            this.camposReadOnly = false;
            
            // Inicializar valores para validación
            this.inicializarValoresFormulario();
        }
    }

    /**
     * Cancela la edición y restaura valores originales
     */
    cancelEdit = () => {
        if (this.camposReadOnly) {
            return;
        }
        this.template.querySelectorAll('lightning-input-field').forEach(i => {
            if (this.originalValues[i.fieldName] !== undefined) {
                i.value = this.originalValues[i.fieldName];
            }
        });
        this.camposReadOnly = true;
        this.showToast('Edición cancelada', 'No se guardaron los cambios.', 'info');
    };

    /**********************************************************************************************
     * SECCIÓN 7: VALIDACIÓN DE DATOS
     **********************************************************************************************/
    
    /**
     * Inicializa los valores del formulario para validación
     */
    inicializarValoresFormulario() {
        setTimeout(() => {
            const inputFields = this.template.querySelectorAll('lightning-input-field');
            if (inputFields) {
                inputFields.forEach(field => {
                    if (!this.fieldValues[field.fieldName] && field.value !== undefined && field.value !== null) {
                        this.fieldValues[field.fieldName] = field.value;
                    }
                });
                
                // Validar campos después de inicializar
                this.validateForm();
            }
        }, 100);
    }

    /**
     * Valida el formulario para determinar si puede enviarse
     */
    validateForm() {
        const propuestaValue = this.fieldValues['SPV_PropuestaRectificacionLetrado__c'];
        const importeValue = this.fieldValues['SPV_ImporteRectificacionPropuesto__c'];
        const riesgosValue = this.fieldValues['SPV_Riesgos__c'];
        const observacionesValue = this.fieldValues['SPV_ObservacionesRiesgos__c'];
        
        // Validación para importe
        const requiresAmount = 
            propuestaValue === 'SI Rectificar Sin Negociación con pago' || 
            propuestaValue === 'SI Rectificar Con Negociación con pago';
        
        // Validación para observaciones
        const requiresObservaciones = riesgosValue && riesgosValue !== 'No aplica';
        
        // Validar ambas reglas
        if ((requiresAmount && (importeValue === undefined || importeValue === null || importeValue === '' || importeValue === 0)) ||
            (requiresObservaciones && (!observacionesValue || observacionesValue === ''))) {
            this.formSubmitDisabled = true;
        } else {
            this.formSubmitDisabled = false;
        }
    }

    /**
     * Marca una rectificación como completada
     */
    marcarRectificacionComoCompletada(formularioId) {
        return completarRectificacionAnterior({ formularioId: formularioId })
            .then(() => {
                // Actualizar la lista de rectificaciones anteriores
                return refreshApex(this.wiredRectificaciones);
            });
    }

    /**********************************************************************************************
     * SECCIÓN 8: FUNCIONES AUXILIARES Y GETTERS
     **********************************************************************************************/
    
    /**
     * Muestra un mensaje toast
     */
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    /**
     * Alterna el estado de expansión/contracción de una sección
     */
    toggle(state) {
        return state.includes('slds-is-open') ? 'slds-section' : 'slds-section slds-is-open';
    }

    /**
     * Elimina etiquetas HTML de un texto
     */
    stripHtmlTags(html) {
        if (!html) return '';
        
        // Crear un elemento temporal
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = html;
        
        // Devolver solo el texto sin etiquetas
        return tempDiv.textContent || tempDiv.innerText || '';
    }

    /**
     * Procesa valores de picklist para mostrarlos correctamente
     */
    procesarValorPicklist(valor) {
        if (!valor) return '';
        
        // Si el valor empieza con SPV_, eliminar el prefijo
        if (typeof valor === 'string' && valor.startsWith('SPV_')) {
            valor = valor.substring(4);
            
            // Convertir "Si" a "Sí" (con acento)
            if (valor === 'Si') {
                valor = 'Sí';
            }
        }
        return valor;
    }

    /**
     * Obtiene una representación completa del MCC para una pretensión
     */
    getMCCCompleto(pretension) {
        if (!pretension) {
            return 'No definido';
        }
        
        // Array para almacenar los componentes del MCC
        const mccParts = [];
        
        // Agregar cada componente con su etiqueta, si existe
        if (pretension.CC_MCC_Tematica__r && pretension.CC_MCC_Tematica__r.Name) {
            mccParts.push(`Temática: ${pretension.CC_MCC_Tematica__r.Name}`);
        }
        
        if (pretension.CC_MCC_ProdServ__r && pretension.CC_MCC_ProdServ__r.Name) {
            mccParts.push(`Prod/Serv: ${pretension.CC_MCC_ProdServ__r.Name}`);
        }
        
        if (pretension.CC_MCC_Motivo__r && pretension.CC_MCC_Motivo__r.Name) {
            mccParts.push(`Motivo: ${pretension.CC_MCC_Motivo__r.Name}`);
        }
        
        if (pretension.SEG_Detalle__r && pretension.SEG_Detalle__r.Name) {
            mccParts.push(`Detalle: ${pretension.SEG_Detalle__r.Name}`);
        }
        
        if (mccParts.length === 0) {
            return 'No definido';
        }
        
        return mccParts.join('\n');
    }

    /**********************************************************************************************
     * SECCIÓN 9: GETTERS
     **********************************************************************************************/
    
    /**
     * Determina si hay rectificaciones anteriores
     */
    get hayRectificacionesAnteriores() {
        return Array.isArray(this.rectificaciones) && this.rectificaciones.length > 0;
    }

    /**
     * Retorna las columnas para la tabla de rectificaciones
     */
    get columns() {
        return columns;
    }

    /**
     * Indica si estamos en modo edición
     */
    get isEditing() {
        return !this.camposReadOnly;
    }

    /**
     * Determina si el campo de importe abonado es de solo lectura
     */
    get isImporteAbonadoReadOnly() {
        // Este campo siempre es de solo lectura
        return true;
    }

    /**
     * Clase CSS para mostrar error en el campo importe
     */
    get errorClassName() {
        return this.showImporteRequired ? "slds-has-error" : "";
    }

    /**
     * Clase CSS para mostrar error en el campo observaciones
     */
    get observacionesErrorClassName() {
        return this.showObservacionesRequired ? "slds-has-error" : "";
    }

    /**
     * Clases CSS para el campo de observaciones
     */
    get observacionesFieldClass() {
        const observacionesValue = this.fieldValues['SPV_ObservacionesRiesgos__c'] || '';
        const isEmpty = observacionesValue.trim() === '';
        
        // Clases condicionales basadas en requerido y vacío
        let className = this.showObservacionesRequired ? 'campo-requerido slds-has-error' : '';
        if (this.showObservacionesRequired && isEmpty) {
            className += ' campo-requerido-vacio';
        }
        
        return className;
    }

    /**
     * Formatea el importe abonado como moneda
     */
    get importeAbonadoFormatted() {
        return new Intl.NumberFormat('es-ES', { 
            style: 'currency', 
            currency: 'EUR',
            minimumFractionDigits: 2,
            maximumFractionDigits: 2 
        }).format(this.importeAbonadoTotal || 0);
    }

    // GETTERS PARA CAMPOS AGREGADOS
    
    /**
     * Obtiene el resumen de reclamación automático
     */
    get resumenReclamacionAutomatico() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            return this.pretensiones
                .filter(p => p && p.CaseNumber)
                .map(p => {
                    const resumen = p.SAC_ResumenManual__c || 'Sin resumen';
                    return `${p.CaseNumber}: ${this.stripHtmlTags(resumen)}`;
                })
                .join('\n\n');
        } catch (error) {
            return 'Error al procesar los datos de resumen';
        }
    }

    /**
     * Obtiene información agregada sobre emisión de respuesta SAC
     */
    get emisionRespuestaSACAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_EmisionSAC__c)
                .map(p => {
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_EmisionSAC__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Emisión Respuesta SAC: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    /**
     * Obtiene información agregada sobre resolución remitida en plazo
     */
    get resolucionRemitidaEnPlazoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c)
                .map(p => {
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Resolución remitida en plazo: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    /**
     * Obtiene información agregada sobre congruencia de respuesta SAC
     */
    get congruenciaRespuestaSACAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c)
                .map(p => {
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Congruencia de respuesta SAC: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    /**
     * Obtiene información agregada sobre calidad de respuesta
     */
    get calidadRespuestaAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c)
                .map(p => {
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Calidad de respuesta: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    /**
     * Obtiene información agregada sobre decisión de pretensión AJ
     */
    get decisionPretensionAJAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c)
                .map(p => {
                    // Procesar como picklist
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Decisión pretensión: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    /**
     * Obtiene información agregada sobre observaciones de decisión de pretensión AJ
     */
    get observacionesDecisionPretAJAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionPretLetrado__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionPretLetrado__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Observaciones decisión pretensión: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }
}