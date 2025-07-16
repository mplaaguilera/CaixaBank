import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import currentUserId from '@salesforce/user/Id';

// Schema imports
import CASEID from '@salesforce/schema/Case.Id';
import CASERT from '@salesforce/schema/Case.RecordTypeId';
import CASENUMBER from '@salesforce/schema/Case.CaseNumber';
import OWNERID from '@salesforce/schema/Case.OwnerId';
import STATUS from '@salesforce/schema/Case.Status';
import SUBESTADO from '@salesforce/schema/Case.SEG_Subestado__c';
import CASORELACIONADO from '@salesforce/schema/Case.CC_CasoRelacionado__c';
import GRUPOSAC from '@salesforce/schema/Case.CC_CasoRelacionado__r.SEG_Grupo__c';
import CASE_EXTENSION_ID from '@salesforce/schema/Case.CBK_Case_Extension_Id__c';
import EXTENSION_DECISION from '@salesforce/schema/CBK_Case_Extension__c.SPV_DecisionPretensionLetrado__c';
import getNumeroContratos from '@salesforce/apex/SPV_LCMP_FormularioReclamaciones.getNumeroContratos';
// Apex imports
import getFormularioExistente from '@salesforce/apex/SPV_LCMP_FormularioReclamaciones.getFormularioExistente';
import getPretensionesReclamacion from '@salesforce/apex/SPV_LCMP_FormularioReclamaciones.getPretensionesReclamacion';
import notificarCambioFicha from '@salesforce/apex/SPV_LCMP_FormularioReclamaciones.notificarCambioFicha';
import crearNuevoFormularioReclamacion from '@salesforce/apex/SPV_LCMP_FormularioReclamaciones.crearNuevoFormularioReclamacion';

const FIELDS = [CASEID, CASERT, CASENUMBER, OWNERID, STATUS, SUBESTADO, CASORELACIONADO, GRUPOSAC, CASE_EXTENSION_ID];

export default class Spv_formularioReclamaciones extends LightningElement {
    /*─────────────────── PUBLIC/REACTIVE ───────────────────*/
    @api recordId;
    @api objectApiName;

    @track idFormularioCaso;
    @track estadoAlegaciones = false;
    @track estadoAllanamiento = false;
    @track estadoDesistimiento = false;
    @track estadoInadmision   = false;
    @track substatus;
    @track caseNumber;
    @track casoSAC;
    @track caseExtensionId;
    @track decisionPretensionLetrado = null;
    @track formularioNecesitaCrearse = false;
    /** true ⇒ se muestran output‑field, false ⇒ input‑field */
    @track camposReadOnly = true;
    @track tienePermisosEditar = false;

    @track pretensiones = [];
    @track spinnerLoading = false;
    @track mapaContratos = {};
    // Accordions
    @track toggleIconGeneral    = 'slds-section slds-is-open';
    @track toggleIconAntecentes = 'slds-section slds-is-open';
    @track toggleIconValoracion = 'slds-section slds-is-open';
    @track toggleIconComprobaciones = 'slds-section slds-is-open';
    @track toggleIconAlegaciones = 'slds-section slds-is-open';
    @track toggleIconAllanamiento = 'slds-section slds-is-open';
    @track toggleIconFondo      = 'slds-section slds-is-open';
    @track toggleIconPropuesta  = 'slds-section slds-is-open';
    @track toggleIconResolucion = 'slds-section slds-is-open';
    @track toggleIconObservaciones = 'slds-section slds-is-open';
    @track toggleIconAnalisisLetrado = 'slds-section slds-is-open';


    /*─────────────────── PRIVADOS ───────────────────*/
    originalValues = {};   // snapshot para Cancelar
    notificado = false;
    guardandoCambios = false;
    /*─────────────────── W I R E S ───────────────────*/
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ data, error }) {
        if (data) {
            this.substatus   = data.fields.SEG_Subestado__c.value;
            this.casoSAC     = data.fields.CC_CasoRelacionado__c.value;
            this.caseNumber  = data.fields.CaseNumber.value;

            const ownerId    = data.fields.OwnerId.value;
            
            // Obtener el ID de Case Extension
            this.caseExtensionId = data.fields.CBK_Case_Extension_Id__c.value;
    
            // Permisos: solo propietario ⇒ puede editar
            this.tienePermisosEditar = ownerId === currentUserId;
            this.camposReadOnly      = true; // siempre se parte en solo‑lectura
        }
    }

    @wire(getFormularioExistente, { casoId: '$recordId'})
    getFormulario({ error, data }){
        if(data !== undefined) {
            if(data) {
                this.idFormularioCaso = data;
                this.formularioNecesitaCrearse = false;
            } else {
                this.formularioNecesitaCrearse = true;
            }
        }
    }

    @wire(getPretensionesReclamacion, { casoId: '$recordId' })
    wiredPretensiones({ error, data }) {
        if (data) {
            this.pretensiones = data;
            

            const pretensionIds = this.pretensiones.map(p => p.Id);
            if (pretensionIds.length > 0) {
                this.obtenerNumeroContratos(pretensionIds);
            }
        }
    }

    @wire(getRecord, { recordId: '$caseExtensionId', fields: [EXTENSION_DECISION] })
    wiredCaseExtension({ data, error }) {
        if (data) {
            try {
                // Obtener el valor
                const newValue = data.fields.SPV_DecisionPretensionLetrado__c.value;
                
                // Actualizar directamente
                this.decisionPretensionLetrado = newValue;
                
                // Forzar recálculo explícito de los estados
                this.estadoAllanamiento = this.decisionPretensionLetrado === 'Allanamiento';
                this.estadoAlegaciones = this.decisionPretensionLetrado === 'Alegaciones';
                this.estadoDesistimiento = this.decisionPretensionLetrado === 'Desistimiento';
                this.estadoInadmision = this.decisionPretensionLetrado === 'Inadmisión';
                
            } catch (e) {
                this.decisionPretensionLetrado = null;
            }
        } else if (error) {
            this.decisionPretensionLetrado = null;
        }
    }

    /*───────────────────  E D I C I Ó N  G L O B A L  ───────────────────*/

    /** Activa la edición global al pulsar un lápiz */
    handleOutputEditClick() {
        this.originalValues = {};
        this.template.querySelectorAll('lightning-output-field').forEach(o => {
            if (o.fieldName){ this.originalValues[o.fieldName] = o.value;}
        });
        
        // Si necesitamos crear un formulario, hacerlo antes de activar modo edición
        if (this.formularioNecesitaCrearse) {
            this.spinnerLoading = true;
            
            crearNuevoFormularioReclamacion({ casoId: this.recordId })
                .then(result => {
                    this.idFormularioCaso = result;
                    this.formularioNecesitaCrearse = false;
                    this.camposReadOnly = false; // Activar edición después de crear
                    this.spinnerLoading = false;
                })
                .catch(error => {
                    this.spinnerLoading = false;
                    this.showToast('Error', 'No se pudo crear el formulario: ' + 
                        (error.body?.message || error.message || 'Error desconocido'), 'error');
                });
        } else {
            // Si ya existe formulario, sólo activar edición
            this.camposReadOnly = false;
        }
    }

    /** Cancela cambios y vuelve a solo‑lectura */
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

    /** Envía todo el record‑edit‑form */
    saveAll = () => {
        if (this.camposReadOnly){
            return;
        }
        this.spinnerLoading = true;
        this.guardandoCambios = true; // Establecer la bandera antes de guardar
        
        // Verificar si necesitamos crear un formulario primero
        if (this.formularioNecesitaCrearse) {
            
            crearNuevoFormularioReclamacion({ casoId: this.recordId })
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

    /*───────────────────  R E C O R D   E D I T   F O R M  ───────────────────*/

    handleSubmit(event) {
        // Si estamos creando un nuevo formulario, prevenir el envío por defecto
        if (this.formularioNecesitaCrearse) {
            event.preventDefault();
        }
    }

    handleSuccess(event) {
        this.idFormularioCaso = event.detail.id;
        this.camposReadOnly = true;
        this.spinnerLoading = false;
        
        // Solo mostrar el toast si estábamos guardando cambios explícitamente
        if (this.guardandoCambios) {
            this.showToast('Formulario actualizado', 'Los cambios se guardaron correctamente.', 'success');
            this.guardandoCambios = false; // Resetear la bandera
        }
    
        if (!this.notificado) {
            notificarCambioFicha({ casoId: this.recordId, caseNumber: this.caseNumber })
                .then(() => { this.notificado = true; })
                .catch(() => { 
                    this.notificado = true;

                })
        }
    }

    obtenerNumeroContratos(pretensionIds) {
        if (!pretensionIds || pretensionIds.length === 0) {
            return;
        }
    
        
        // Llamar al método Apex
        getNumeroContratos({ pretensionIds: pretensionIds })
            .then(result => {
                this.mapaContratos = result || {};
                
                // Forzar actualización de la UI si es necesario
                this.dispatchEvent(new CustomEvent('contratoscargados'));
            })
            .catch(error => {
                this.mapaContratos = {}; // Inicializar como objeto vacío en caso de error
            });
    }

    /*───────────────────  C A M P O S   E S P E C Í F I C O S  ───────────────────*/




    handlePendienteRevisarChange(e) {
        if (e.detail.checked) {
            this.template.querySelectorAll('lightning-input-field').forEach(f => {
                if (f.fieldName === 'SPV_Revision_finalizada__c'){ 
                    f.value = false;
                }
            });
        }
    }

    handleRevisionFinalizadaChange(e) {
        if (e.detail.checked) {
            // Desmarcar "Pendiente revisar"
            this.template.querySelectorAll('lightning-input-field').forEach(f => {
                if (f.fieldName === 'SPV_Pendiente_revisar__c') {
                    f.value = false;
                }
                
                // Asignar el usuario actual como Letrado Revisor
                if (f.fieldName === 'SPV_LetradoRevisor__c') {
                    f.value = currentUserId;
                }
            });
        }
    }


    /*───────────────────  U T I L S  ───────────────────*/
    stripHtmlTags(html) {
        if (!html){
            return '';
        } 
        
        // Crear un elemento temporal
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = html;
        
        // Devolver solo el texto sin etiquetas
        return tempDiv.textContent || tempDiv.innerText || '';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    // Getter para el Resumen Reclamación (concatenación de números de pretensión + resúmenes)
    get resumenReclamacionAutomatico() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const resumenesFormateados = this.pretensiones
                .filter(p => p && p.CaseNumber)
                .map(p => {
                    const resumen = p.SAC_ResumenManual__c || 'Sin resumen';
                    return `${p.CaseNumber}: ${this.stripHtmlTags(resumen)}`;
                })
                .join('\n\n');
                
            return resumenesFormateados || 'No se encontró información de resumen';
        } catch (error) {
            return 'Error al procesar los datos de resumen';
        }
    }

    // Getter para el Importe Reclamado (sumatorio de los importes de las pretensiones)
    get importeTotalReclamado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return '0,00 €';
        }
        
        try {
            // Sumar todos los importes, tratando valores nulos/indefinidos como 0
            const total = this.pretensiones.reduce((suma, pretension) => {
                const importe = pretension.CC_Importe_Reclamado__c || 0;
                return suma + importe;
            }, 0);
            
            // Formatear como moneda en formato español
            return new Intl.NumberFormat('es-ES', { 
                style: 'currency', 
                currency: 'EUR' 
            }).format(total);
        } catch (error) {
            return '0,00 €';
        }
    }
    get isEditing() {
        return !this.camposReadOnly;
    }



    get noDecisionFound() {
        // Loguear para depuración
        
        // Comprobar explícitamente valores nulos o no válidos
        return !this.decisionPretensionLetrado || 
               !['Alegaciones', 'Allanamiento', 'Desistimiento', 'Inadmisión'].includes(this.decisionPretensionLetrado);
    }
    
    // También podemos añadir un getter para determinar si hay case extension
    get hasCaseExtension() {
        return !!this.caseExtensionId;
    }


    handleFieldChange(event) {
            // Obtener campo y valor
            const fieldName = event.target.fieldName;
            const fieldValue = event.target.value;
            
            // Manejo específico para checkboxes (como en las funciones originales)
            if (fieldName === 'SPV_Revision_finalizada__c' && fieldValue === true) {
                this.template.querySelectorAll('lightning-input-field').forEach(f => {
                    if (f.fieldName === 'SPV_Pendiente_revisar__c'){ 
                        f.value = false;
                    }
                });
            } else if (fieldName === 'SPV_Pendiente_revisar__c' && fieldValue === true) {
                this.template.querySelectorAll('lightning-input-field').forEach(f => {
                    if (f.fieldName === 'SPV_Revision_finalizada__c'){ 
                        f.value = false;
                    }
                });
            }
                        
            // Prevenir propagación innecesaria del evento
            event.stopPropagation();
    }

    get resumenResolucionSACAgregado() {
        // 1. Verificar que pretensiones sea un array
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            // 2. Filtrar y mapear solo si es un array
            const pretensionesConResumen = this.pretensiones
                .filter(p => {
                    // Verificar si el campo existe en Case Extension
                    return p && p.CBK_Case_Extension_Id__r && 
                           p.CBK_Case_Extension_Id__r.SPV_ResumenResolucionSAC__c;
                })
                .map(p => {
                    // Obtener el valor y eliminar etiquetas HTML
                    const resumenSAC = p.CBK_Case_Extension_Id__r.SPV_ResumenResolucionSAC__c || '';
                    const resumenSinHTML = this.stripHtmlTags(resumenSAC);
                    
                    // Formatear con el número de pretensión y MCC
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Resumen: ${resumenSinHTML}`;
                })
                .join('\n');
                
            return pretensionesConResumen || 'No se encontró información de Resumen Resolución SAC';
        } catch (error) {
            return 'Error al procesar los datos de pretensiones';
        }
    }
    

    procesarValorPicklist(valor) {
        if (!valor){ return '';}
        
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
    // 1. Emisión de respuesta del SAC
    get emisionRespuestaSACAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_EmisionSAC__c)
                .map(p => {
                    // Usar el método compartido
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_EmisionSAC__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Emisión de respuesta del SAC: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }
    
    // 2. Resolución SAC remitida dentro de plazo - CORREGIDO PARA PICKLIST
    get resolucionRemitidaEnPlazoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c)
                .map(p => {
                    // Procesar como picklist en lugar de booleano
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Resolución SAC remitida dentro de plazo: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 3. Congruencia de la respuesta del SAC - CORREGIDO PARA PICKLIST
    get congruenciaRespuestaSACAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c)
                .map(p => {
                    // Procesar como picklist, eliminando prefijo SPV_
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Congruencia respuesta SAC: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 4. Calidad de la respuesta - CORREGIDO PARA PICKLIST
    get calidadRespuestaAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c)
                .map(p => {
                    // Procesar como picklist, eliminando prefijo SPV_
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Calidad de la respuesta: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 5. Reclamación D.E.C mal funcionamiento - CORREGIDO PARA PICKLIST
    get reclamacionMalFuncionamientoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ReclamacionMalFuncionamiento__c)
                .map(p => {
                    // Procesar como picklist, eliminando prefijo SPV_
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_ReclamacionMalFuncionamiento__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Reclamación DEC mal funcionamiento: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }
    
    // 6. Observaciones mal funcionamiento SAC
    get observacionesMalFuncionamientoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ObservacionesMalFuncionamientoSAC__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_ObservacionesMalFuncionamientoSAC__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Observaciones mal funcionamiento SAC: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }
    
    // 7. La actuación SAC cumple criterios BdE

    get actuacionCumpleBdEAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ActuacionCumpleBdE__c)
                .map(p => {
                    // Procesar como picklist, eliminando prefijo SPV_
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_ActuacionCumpleBdE__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n La actuación SAC cumple criterios BdE ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }
    
    // 8. Observaciones actuación SAC
    get observacionesActuacionSACAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ObservacionesActuacionSAC__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_ObservacionesActuacionSAC__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Observaciones actuación SAC: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }


    /*───────────────────  DOCUMENTACION POSIBLE  ───────────────────*/


    // 1. Dispone de documentación 
    get disponeDocumentacionAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c)
                .map(p => {
                    // Procesar como picklist, eliminando prefijo SPV_
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c);
                    return `${p.CaseNumber} \n  ${this.getMCCCompleto(p)} \n Dispone de documentación: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 2. Observaciones documentación disponible 
    get observacionesDocumentacionAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ObservacionesDocumentacionDisponible__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_ObservacionesDocumentacionDisponible__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Observaciones documentación disponible: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 3. Documentación necesaria 
    get documentacionNecesariaAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_DocumentacionNecesaria__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_DocumentacionNecesaria__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Documentación necesaria: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }
    /*───────────────────  COMPROBACIONES REALIZAS  ───────────────────*/
    // 1. Información precontractual
    get informacionPrecontractualAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_InformacionPrecontractual__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_InformacionPrecontractual__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Información precontractual: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 2. Número Contrato (viene de Case)
    get numeroContratoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        // Si no se han cargado los contratos aún
        if (!this.mapaContratos) {
            this.mapaContratos = {};
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .map(p => {
                    // Obtener el número de contrato del mapa o mostrar un valor por defecto
                    const numeroContrato = this.mapaContratos[p.Id] || 'No disponible';
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Número Contrato: ${numeroContrato} \n`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información de contrato';
        } catch (error) {
            return 'Error al procesar los datos de contrato: ' + error.message;
        }
    }

    // 3. Comunicaciones cambios de condiciones
    get comunicacionesCambiosCondicionesAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ComunicacionesCambiosCondiciones__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_ComunicacionesCambiosCondiciones__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Comunicaciones cambios de condiciones: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 4. Comunicaciones con liquidaciones, extractos
    get comunicacionesLECAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ComunicacionesLEC__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_ComunicacionesLEC__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Comunicaciones con liquidaciones, extractos: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 5. Justificantes de operaciones
    get justificantesOperacionesAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_JustificantesOperaciones__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_JustificantesOperaciones__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Justificantes de operaciones: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 6. Comunicaciones entre oficina y cliente
    get comunicacionesOficinaClienteAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ComunicacionesOficinaCliente__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_ComunicacionesOficinaCliente__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Comunicaciones entre oficina y cliente: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 7. Antecedentes y cumplimiento de resoluciones
    get antecedentesCumplimientoResolAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_AntecedentesCumplimientoResol__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_AntecedentesCumplimientoResol__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Antecedentes y cumplimiento de resoluciones: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 8. Cumplimiento condiciones pactadas
    get cumplimientoCondicionesPactadasAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_CumplimientoCondicionesPactadas__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_CumplimientoCondicionesPactadas__c || '');
                    rreturn `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Cumplimiento de condiciones pactadas: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 9. Informe de la oficina
    get informeOficinaAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_InformeOficina__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_InformeOficina__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Informe de la oficina: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }
/*───────────────────  PROPUESTA DE LETRADO   ───────────────────*/

    // BLOQUE DE ALLANAMIENTO
    // 1. Tipo Allanamiento
    get tipoAllanamientoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_TipoAllanamiento__c)
                .map(p => {
                    // Procesar como picklist, eliminando prefijo SPV_
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_TipoAllanamiento__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Tipo allanamiento: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 2. Motivo de Allanamiento
    get motivoAllanamientoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_MotivoAllanamiento__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_MotivoAllanamiento__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Motivo de allanamiento: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 3. Análisis Allanamiento
    get analisisAllanamientoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_AnalisisAllanamiento__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_AnalisisAllanamiento__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Análisis de allanamiento: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 4. Importe Allanamiento Propuesto
    get importeAllanamientoPropuestoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ImporteAllanamientoPropuesto__c !== undefined)
                .map(p => {
                    const valor = p.CBK_Case_Extension_Id__r.SPV_ImporteAllanamientoPropuesto__c !== null 
                        ? new Intl.NumberFormat('es-ES', { style: 'currency', currency: 'EUR' }).format(p.CBK_Case_Extension_Id__r.SPV_ImporteAllanamientoPropuesto__c)
                        : '';
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Importe allanamiento propuesto: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 5. Imputable Allanamiento
    get imputableAllanamientoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ImputableAllanamiento__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_ImputableAllanamiento__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Imputable allanamiento: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // BLOQUE DE DESISTIMIENTO
    // 1. Motivo de Desistimiento
    get motivoDesistimientoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_MotivoDesistimiento__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_MotivoDesistimiento__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Motivo desistimiento: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 2. Análisis Desistimiento
    get analisisDesistimientoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_AnalisisDesistimiento__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_AnalisisDesistimiento__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Análisis desistimiento: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 3. Tipo actuación desistimiento
    get tipoActuacionDesistimientoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c)
                .map(p => {
                    // Procesar como picklist, eliminando prefijo SPV_
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Tipo actuación desistimiento: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 4. Importe desistimiento propuesto
    get importeDesistimientoPropuestoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ImporteDesistimientoPropuesto__c !== undefined)
                .map(p => {
                    const valor = p.CBK_Case_Extension_Id__r.SPV_ImporteDesistimientoPropuesto__c !== null 
                        ? new Intl.NumberFormat('es-ES', { style: 'currency', currency: 'EUR' }).format(p.CBK_Case_Extension_Id__r.SPV_ImporteDesistimientoPropuesto__c)
                        : '';
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Importe desistimiento propuesto: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 5. Imputable desistimiento
    get imputableDesistimientoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ImputableDesistimiento__c)
                .map(p => {
                    // Procesar como picklist, eliminando prefijo SPV_
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_ImputableDesistimiento__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Imputable desistimiento: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }
    /*───────────────────  BLOQUE PRETENSIONES  ───────────────────*/
    // 1. Mencionar el criterio del BdE
    get mencionarCriterioBdEAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_MencionarCriterioBdE__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_MencionarCriterioBdE__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Mencionar el criterio del BdE ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 2. Decisión de pretensión Letrado
    get decisionPretensionLetradoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c)
                .map(p => {
                    // Procesar como picklist
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Decisión de pretensión letrado: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 3. Observaciones Decisión pretensión Letrado
    get observacionesDecisionPretLetradoAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionPretLetrado__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionPretLetrado__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Observaciones decisión pretensión letrado: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // 4. Documentación
    get documentacionAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_Documentacion__c)
                .map(p => {
                    // Procesar como picklist
                    const valor = this.procesarValorPicklist(p.CBK_Case_Extension_Id__r.SPV_Documentacion__c);
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Documentación: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }
    /*───────────────────  DECISION FINAL  ───────────────────*/
    // Getter para Decisión de pretensión (AJ) - desde Case Extension
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
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Decisión final AJ: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }

    // Getter para Observaciones Decisión pretensión (AJ) - desde Case
    get observacionesDecisionPretAJAgregado() {
        if (!Array.isArray(this.pretensiones) || this.pretensiones.length === 0) {
            return 'No hay pretensiones disponibles';
        }
        
        try {
            const pretensionesConValor = this.pretensiones
                .filter(p => p && p.CBK_Case_Extension_Id__r && p.CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionPretLetrado__c)
                .map(p => {
                    const valor = this.stripHtmlTags(p.CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionPretLetrado__c || '');
                    return `${p.CaseNumber} \n ${this.getMCCCompleto(p)} \n Observaciones Decisión AJ: ${valor}`;
                })
                .join('\n');
                
            return pretensionesConValor || 'No se encontró información';
        } catch (error) {
            return 'Error al procesar los datos';
        }
    }
    // Función helper para obtener el MCC completo
    // Función helper para obtener el MCC completo con etiquetas
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
        
        // Si no hay ninguna parte del MCC, indicar que no está definido
        if (mccParts.length === 0) {
            return 'No definido';
        }
        
        // Unir las partes con " - " como separador
        return mccParts.join('\n');
    }


/*───────────────────  A C C O R D I O N S  ───────────────────*/
    toggle(state) { return state.includes('slds-is-open') ? 'slds-section' : 'slds-section slds-is-open'; }

    handleExpandableGeneral(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconGeneral = this.toggle(this.toggleIconGeneral);    
    }

    handleExpandableAntecentes(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconAntecentes = this.toggle(this.toggleIconAntecentes); 
    }

    handleExpandableValoracion(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconValoracion = this.toggle(this.toggleIconValoracion); 
    }

    handleExpandableComprobaciones(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconComprobaciones = this.toggle(this.toggleIconComprobaciones); 
    }

    handleExpandableAlegaciones(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconAlegaciones = this.toggle(this.toggleIconAlegaciones); 
    }

    handleExpandableAllanamiento(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconAllanamiento = this.toggle(this.toggleIconAllanamiento); 
    }

    handleExpandableFondo(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconFondo = this.toggle(this.toggleIconFondo); 
    }

    handleExpandablePropuesta(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconPropuesta = this.toggle(this.toggleIconPropuesta);  
    }

    handleExpandableResolucion(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconResolucion = this.toggle(this.toggleIconResolucion); 
    }

    handleExpandableObservaciones(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconObservaciones = this.toggle(this.toggleIconObservaciones); 
    }
    handleExpandableAnalisisLetrado(event) { 
        event.preventDefault();
        event.stopPropagation();
        this.toggleIconAnalisisLetrado = this.toggle(this.toggleIconAnalisisLetrado); 
    }
}