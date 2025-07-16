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
//import volverAnalisisCaso from '@salesforce/apex/SPV_CaseOperativas_Controller.volverAnalisis';
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
import anularProrrogaReclamacion from '@salesforce/apex/SPV_CaseOperativas_Controller.anularProrrogaReclamacion';
import comprobarSLAGeneralActivo from '@salesforce/apex/SPV_CaseOperativas_Controller.comprobarSLAGeneralActivo';
import clasificarDocumentoProrroga from '@salesforce/apex/SPV_CaseOperativas_Controller.clasificarDocumentoProrroga';
import activarComplementariaOrganismo from '@salesforce/apex/SPV_CaseOperativas_Controller.activarComplementariaOrganismo';
import desactivarComplementariaOrganismo from '@salesforce/apex/SPV_CaseOperativas_Controller.desactivarComplementariaOrganismo';
import activarNegociacionReclamacion from '@salesforce/apex/SPV_CaseOperativas_Controller.activarNegociacionReclamacion';
import finalizarNegociacionReclamacion from '@salesforce/apex/SPV_CaseOperativas_Controller.finalizarNegociacionReclamacion';
import comprobarTareasPtes from '@salesforce/apex/SPV_CaseOperativas_Controller.comprobarTareasPtes';
import comprobarCamposNegociacionInformados from '@salesforce/apex/SPV_CaseOperativas_Controller.comprobarCamposNegociacionInformados';
import comprobarSLAPlazoRegCompOrgCompletado from '@salesforce/apex/SPV_CaseOperativas_Controller.comprobarSLAPlazoRegCompOrgCompletado';
import comprobarCamposPasarEnvio from '@salesforce/apex/SPV_CaseOperativas_Controller.comprobarCamposPasarEnvio';
import getPretensiones from '@salesforce/apex/SPV_CaseOperativas_Controller.getPretensiones';
import devolverALetrado from '@salesforce/apex/SPV_CaseOperativas_Controller.devolverALetrado';
import MOTIVODEVOLUCION_FIELD from '@salesforce/schema/Case.SAC_Motivo__c';
import MOTIVORECHAZO_FIELD from '@salesforce/schema/Case.SAC_MotivoRechazo__c';
import MOTIVODESCARTE_FIELD from '@salesforce/schema/Case.SAC_MotivoDescarte__c';
import MOTIVOCOMPLORGANISMO_FIELD from '@salesforce/schema/Case.SPV_MotivoComplementariaOrganismo__c';
import cambioEstado from '@salesforce/apex/SPV_CaseOperativas_Controller.cambioEstado';
import getRecordTypes from '@salesforce/apex/SPV_Utils.obtenerRecordTypes';
import esPrincipal from '@salesforce/apex/SPV_CaseOperativas_Controller.esPrincipal';
import convertirReclamacion from '@salesforce/apex/SPV_CaseOperativas_Controller.convertirReclamacion';
//Campos Case Extensión
import MOTIVOREABRIR_FIELD from '@salesforce/schema/CBK_Case_Extension__c.SPV_MotivoReapertura__c';
import MOTIVODEVOLUCIONALTA_FIELD from '@salesforce/schema/CBK_Case_Extension__c.SPV_MotivoDevolucionAlta__c';
import MOTIVOPRORROGA_FIELD from '@salesforce/schema/CBK_Case_Extension__c.SPV_MotivoProrroga__c';
import MOTIVOANULARPRORROGA_FIELD from '@salesforce/schema/CBK_Case_Extension__c.SPV_MotivoAnulacionProrroga__c';
import MOTIVODEVOLUCIONENVIO_FIELD from '@salesforce/schema/CBK_Case_Extension__c.SPV_MotivoDevolucionEnvio__c';
import MOTIVODEVOLUCIONENVIOCOMPLEMENTARIA_FIELD from '@salesforce/schema/CBK_Case_Extension__c.SPV_MotivoDevolucionComplementaria__c';
import MOTIVODEVOLUCIONENVIORECTIFICACION_FIELD from '@salesforce/schema/CBK_Case_Extension__c.SPV_MotivoDevolucionRectificacion__c';

const FIELDS = ['Case.OwnerId', 'Case.Status', 'Case.SAC_MotivoRechazo__c', 'Case.SAC_MotivoDescarte__c' ,'Case.RecordType.DeveloperName', 'Case.SEG_Grupo__c', 'Case.SEG_Subestado__c', 'Case.SAC_EsPrincipal__c', 'Case.SPV_Complementaria_Entidad__c', 'Case.SAC_Prorrogado__c', 'Case.SPV_Rectificado__c', 'Case.SPV_ComplementariaOrganismo__c', 'Case.SPV_Organismo__c', 'Case.CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c', 'Case.SAC_PretensionPrincipal__c', 'Case.SAC_PretensionPrincipal__r.OS_Propietario__c'];

const columns = [
    { label: 'Temática', fieldName: 'CC_MCC_Tematica' }, 
    { label: 'Producto/Servicio', fieldName: 'CC_MCC_ProdServ'},
    { label: 'Motivo', fieldName: 'CC_MCC_Motivo'},
    { label: 'Detalle', fieldName: 'SEG_Detalle'}
];

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
    @track noEsGestor;
    @track noEsLetrado;
    @track noEsGestorLetrado;
    //@track habilitarDevolver;
    //@track habilitarVolverAnalisis = false;
    @track grupo;
    @track tienePretensionPrincipal;
    @track pretPrincipalTieneLetrado;
    @track modalDevolver;
    @track modalVolverAnalisis = false;
    @track modalNegociacion = false;
    @track modalFinalizarNegociacion = false;
    @track options = [];
    @track selectedMotivo;
    @track observacion;
    @track motivo;
    @track esPretPpal = false;
    @track esPretension = false;
    @track modalReasignar = false;
    @track inputMotivoReasignar;
    @track observacionesVolverAnalisis = '';     //Aquí se almacenan las observaciones escritas al pulsar sobre el botón "volver a análisis"
    @track esComplementariaEntidad = false;
    @track esComplementariaOrganismo = false;
    @track prorrogado;
    @track esRectificado;
    @track mostrarComplementariaEntidad = false;
    @track mostrarComplementariaOrganismo = false;
    @track mostrarRectificacion = false;
    @track mostrarDerivar = false;
    @track mostrarConvertir = false;
    @track deshabilitarDescartar = true;   //Controla si se muestra el botón de "Descartar", solo si es una reclamación en estado de alta
    @track abrirModalDescartar = false;       //Controla si se muestra el modal de "Descartar" al pulsar el botón correspondiente
    @track selectedMotivoDescarte;            //Se actualiza según se seleccione el motivo de descartado
    @track esGestor = false;           //Variable para controlar si el user es owner de la reclamación
    @track esLetrado = false;           //Variable para controlar si el user es owner de las pretensiones
    @track esCOPSAJ = false;           //Variable para controlar si el user es usuario COPS o AJ
    @track noPuedeNegociar = true;           //Variable para si puede negociar la reclamación si el user es usuario letrado o COPS
    @track mostrarReapertura = false;
    @track modalReaperturaNoConsumo = false;
    @track modalReaperturaConsumo = false;
    @track mensajeConfReapertura = '';
    @track reaperturaRectificacion = false;
    @track reaperturaComplementariaOrganismo = false;
    @track observacionesMotivoReapertura = '';
    @track mostrarDevolverAlta = false;       //Variable que controla cuándo se mostrará el botón para volver al estado de Alta
    @track modalDevolverAlta = false;         //Variable que controla cuándo se muestra el modal para volver a alta
    @track modalProrroga = false;
    @track modalCompleOrganismo = false;
    @track modalNegociacionActiva = false;
    @track selectedMotivoComplOrganismo = ''; 
    @track organismo = '';
    @track mostrarAnalisis = false;
    @track mostrarReasignarLetrado = false;
    @track mostrarDescartar = false;
    @track deshabilitarReasignar = false;
    @track mostrarNegociacion = false;
    @track mostrarFinalizarNegociacion = false;
    @track mostrarEnvioComplementaria = false;
    @track mostrarDevolverCaso = false;
    @track negociacionEnCurso = false;
    @track hayTareasPtes = false;
    @track mostrarEnvio = false;
    @track mostrarCerrar = false;
    @track mostrarResolucion = false;
    @track mostrarDesactivarComplementariaOrganismo = false;
    @track mostrarDesactivarComplementariaEntidad = false;
    @track mostrarRecepcionResolucion = false;
    @track mostrarEnvioRectificacion = false;
    @track mostrarDevolverLetrado = false;
    @track mostrarEnvioOrganismo = false;
    @track mostrarBotonSeleccionPretensiones = true;
    @track mostrarModalDevolverLetrado = false;
    @track mostrarPendienteRespOrganismo = false;
    @track statusAlta = 'SAC_001';
    @track statusAnalisisDecision = 'SPV_AnalisisDecision';
    @track statusEnvio = 'SPV_Envio';
    @track statusPendienteRespuestaOrganismo = 'SPV_PendienteRespuestaOrganismo';
    @track statusAnalisisComplementariaOrganismo = 'SPV_AnalisisComplementariaOrganismo'
    @track statusEnvioComplementaria = 'SPV_EnvioComplementaria';
    @track statusRecepcionResolucion = 'SPV_RecepcionResolucion';
    @track statusRectificacion = 'SPV_Rectificacion';
    @track statusEnvioRectificacion = 'SPV_EnvioRectificacion';
    @track statusResolucion = 'SAC_003';
    @track statusDescartado = 'Descartado';
    @track statusCerrar = 'Cerrado';
    @track statusBaja= 'SAC_009';
    @track deshabilitarBaja = false;
    @track esBaja = false;
    @track mensajeNegociacion = 'Reclamación en negociación';
    @track mensajeTareasPtes = 'Tienes tareas de ejecución pendientes';
    @track rtReclamacion;
    @track rtReclamacionExt;
    @track valoresPicklisMotivoReapertura = [];
    @track valueMotivoReapertura = '';
    @track mostrarObservacionesReapertura = false;
    @track camposPendientesNegociacion = '';
    @track hayCamposPendientesNegociacion = false;
    @track deshabilitarPretPrincipal = false;
    @track organismoConsumo = 'SPV_Consumo';
    @track modalDerivar = false;
    
    @track valoresPickListDevolucionAlta = [];
    @track valueMotivoDevolucionAlta = '';
    @track mostrarObservacionesDevolucionAlta = false;
    @track observacionesDevolucionAlta = '';

    @track valoresPicklistDescartar = [];
    @track valoresPicklistDescartarOrdenados = [];
    @track mostrarObservacionesDescartar = false;
    @track observacionesDescartar = '';

    @track valoresPicklistMotivoProrroga = [];
    @track valueMotivoProrroga = '';
    @track mostrarObservacionesProrroga = false;
    @track observacionesProrroga = '';
    @track mostrarModalProrroga = false;

    @track mostrarAnularProrroga = false;
    @track valoresPicklistMotivoAnularProrroga = [];
    @track valueMotivoAnularProrroga = '';
    @track mostrarObservacionesAnularProrroga = false;
    @track observacionesAnularProrroga = '';
    @track mostrarModalAnularProrroga = false;

    @track mostrarMotivoDevolucionEnvio = false;
    @track mostrarMotivoDevolucionEnvioComplementaria = false;
    @track mostrarMotivoDevolucionEnvioRectificacion = false;
    @track valoresPicklistMotivoDevoEnvio = [];
    @track valoresPicklistMotivoDevoEnvioComplementaria = [];
    @track valoresPicklistMotivoDevoEnvioRectificacion = [];
    @track valueMotivoDevolucionALetrado = '';
    @track mostrarObservacionesDevolverLetrado = false;
    @track observacionesDevolverLetrado = '';

    @track mostrarObservacionesComplementariaOrganismo = false;
    @track observacionesMotivoComplementariasOrganismo = '';

    @track mostrarModalPasoEstadoEnvio = false;
    @track camposPendientesParaEnvio = '';

    @track fechaVencimientoPlazoRegCompOrganismo = '';
    @track fechaPlazoRegCorrecta = false;
    @track tinePlazoRegOrgCompletado = false;

    @track confirmarConvertir = false;
    @track convertir = false;

    optionsGruposLet = [];
    pretensiones = [];
    columns = columns;
    lstSelectedRecords = [];


    @wire(getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

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
                    }                    
                }
            });
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVODEVOLUCION_FIELD })
    getMotivo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVORECHAZO_FIELD })
    getMotivoRechazo;

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacion', fieldApiName: MOTIVODESCARTE_FIELD })
    wiredPicklistMotivoDescarte({error, data}){
        if(data){
            this.valoresPicklistDescartar = data.values;
            this.valoresPicklistDescartarOrdenados = this.valoresPicklistDescartar.slice().reverse();
        }
    }

    /*@wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVOCOMPLORGANISMO_FIELD })
    getMotivoComplOrganismo;*/

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacion', fieldApiName: MOTIVOCOMPLORGANISMO_FIELD })
    getMotivoComplOrganismo;

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacionExt', fieldApiName: MOTIVOREABRIR_FIELD })
    wiredPicklistMotivoReabrir({error, data}){
        if(data){
            this.valoresPicklisMotivoReapertura = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacionExt', fieldApiName: MOTIVODEVOLUCIONALTA_FIELD })
    wiredPicklistMotivoDevolverAlta({error, data}){
        if(data){
            this.valoresPickListDevolucionAlta = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacionExt', fieldApiName: MOTIVOPRORROGA_FIELD })
    wiredPicklistMotivoProrroga({error, data}){
        if(data){
            this.valoresPicklistMotivoProrroga = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacionExt', fieldApiName: MOTIVOANULARPRORROGA_FIELD })
    wiredPicklistMotivoAnularProrroga({error, data}){
        if(data){
            this.valoresPicklistMotivoAnularProrroga = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacionExt', fieldApiName: MOTIVODEVOLUCIONENVIO_FIELD })
    wiredPicklistMotivoDevolucionEnvio({error, data}){
        if(data){
            this.valoresPicklistMotivoDevoEnvio = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacionExt', fieldApiName: MOTIVODEVOLUCIONENVIOCOMPLEMENTARIA_FIELD })
    wiredPicklistMotivoDevolucionEnvioComplementaria({error, data}){
        if(data){
            this.valoresPicklistMotivoDevoEnvioComplementaria = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacionExt', fieldApiName: MOTIVODEVOLUCIONENVIORECTIFICACION_FIELD })
    wiredPicklistMotivoDevolucionEnvioRectificacion({error, data}){
        if(data){
            this.valoresPicklistMotivoDevoEnvioRectificacion = data.values;
        }
    }
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredGetRecord({data, error}){
        if(data){
            
            //Iniciar a false todos los botones al recargar
            this.esPretension = false;
            //this.habilitarDevolver = false;
            //this.habilitarVolverAnalisis = false;
            this.mostrarTomarPropiedad = false;
            this.mostrarDevolverLetrado = false;
            this.mostrarEnvioOrganismo = false;
            this.mostrarComplementariaEntidad = false;
            this.mostrarComplementariaOrganismo = false;
            this.mostrarRectificacion = false;
            this.mostrarProrroga = false;
            this.mostrarReapertura = false;
            this.mostrarDevolverAlta = false;
            this.mostrarAnalisis = false;
            this.mostrarReasignarLetrado = false;
            this.mostrarDescartar = false;
            this.mostrarNegociacion = false;
            this.mostrarEnvioComplementaria = false;
            this.mostrarDevolverCaso = false;
            this.mostrarEnvio = false;
            this.mostrarCerrar = false;
            this.mostrarResolucion = false;
            this.mostrarDesactivarComplementariaOrganismo = false;
            this.mostrarDesactivarComplementariaEntidad = false;
            this.mostrarRecepcionResolucion = false;
            this.mostrarEnvioRectificacion = false;
            this.mostrarPendienteRespOrganismo = false;
            this.mostrarMotivoDevolucionEnvio = false;
            this.mostrarMotivoDevolucionEnvioComplementaria = false;
            this.mostrarMotivoDevolucionEnvioRectificacion = false;
            this.mostrarAnularProrroga = false;
            this.deshabilitarPretPrincipal = false;
            this.esPretPpal = false;
            this.deshabilitarBaja = false;
            this.esBaja = false;
            this.mostrarDerivar = false;
            this.mostrarConvertir = false;
            this.confirmarConvertir = false;
            this.convertir = false;
            this.modalDerivar = false;
            this.noEsGestor = false;
            this.noEsLetrado = false;
            this.noEsGestorLetrado = false;

            this.recordType = data.fields.RecordType.value.fields.DeveloperName.value;
            if(this.recordType === 'SPV_Pretension'){
                this.esPretension = true;
            }
            this.owner = data.fields.OwnerId.value;

            if(USER_ID === this.owner){
                this.esPropietario = true;
            }else{
                this.esPropietario = false;
            }

            this.status = data.fields.Status.value;
            this.subestado = data.fields.SEG_Subestado__c.value;
            this.esComplementariaEntidad = data.fields.SPV_Complementaria_Entidad__c.value;
            this.esComplementariaOrganismo = data.fields.SPV_ComplementariaOrganismo__c.value;
            this.negociacionEnCurso = data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_CasoEnNegociacion__c.value;
            this.esRectificado = data.fields.SPV_Rectificado__c.value;
            this.prorrogado = data.fields.SAC_Prorrogado__c.value;
            this.organismo = data.fields.SPV_Organismo__c.value;
            
            this.filtrarMotivosReapertura();
            
            this.botonLabelEntidad = this.esComplementariaEntidad ? 'Desactivar complementaria entidad' : 'Activar Complementaria entidad';
            this.mostrarReapertura = false;
            this.mostrarComplementariaOrganismo = false;

            if(data.fields.SAC_PretensionPrincipal__c.value == null || data.fields.SAC_PretensionPrincipal__c.value == undefined){
                this.tienePretensionPrincipal = false;
            }else{
                if(data.fields.SAC_PretensionPrincipal__r.value.fields.OS_Propietario__c.value == 'Pte. Asignar (SPV)'){
                    this.pretPrincipalTieneLetrado = false;
                }else{
                    this.pretPrincipalTieneLetrado = true;
                }
                this.tienePretensionPrincipal = true;
            }


            this.esPretPpal = data.fields.SAC_EsPrincipal__c.value;
            // Comprobar si el botón de Pretensión principal debe mostrarse
            if(this.esPretPpal || (this.noEsPropietario && !this.esCOPSAJ)){
                this.deshabilitarPretPrincipal = true;
            }

            // Comprobar si el botón de Baja debe mostrarse
            if(this.status == this.statusBaja){
                this.esBaja = true;
            }
            if(this.status == this.statusBaja || (this.noEsPropietario && !this.esCOPSAJ)){
                this.deshabilitarBaja = true;
            }

            // Botones Pretensiones 
            if(this.esPretension && this.status != this.statusAlta && this.status != this.statusRecepcionResolucion && this.status != this.statusEnvioRectificacion && this.status != this.statusCerrar){
                this.mostrarTomarPropiedad = true;
                this.mostrarDevolverCaso = true;
            }

            // Botones Reclamaciones
            if(!this.esPretension){

                if(this.status == this.statusAlta){
                    this.mostrarTomarPropiedad = true;
                    this.mostrarDevolverCaso = true;
                    this.mostrarAnalisis = true;
                    this.mostrarDescartar = true;
                    this.mostrarDerivar = true;
                    this.mostrarConvertir = true;
                }

                if(this.status == this.statusAnalisisDecision){
                    this.mostrarDevolverAlta = true;
                    this.mostrarReasignarLetrado = true;
                    this.mostrarTomarPropiedad = true;
                    this.mostrarDevolverCaso = true;
                    this.mostrarNegociacion = true;
                    this.mostrarProrroga = true;
                    this.mostrarEnvio = true;
                if(this.prorrogado == true){
                    this.mostrarAnularProrroga = true;
                }
                }

                if(this.status == this.statusEnvio){
                    this.mostrarDevolverLetrado = true;
                    this.mostrarNegociacion = true;
                    //this.mostrarEnvioOrganismo = true;
                    this.mostrarMotivoDevolucionEnvio = true;
                    if(this.organismo != this.organismoConsumo){
                        this.mostrarPendienteRespOrganismo = true;
                    }
                    this.modalReaperturaConsumo = false;
                }

                if(this.status == this.statusPendienteRespuestaOrganismo){
                    this.mostrarReasignarLetrado = true;
                    this.mostrarComplementariaEntidad = true;
                    this.mostrarComplementariaOrganismo = true;
                    this.mostrarNegociacion = true;
                    this.mostrarRecepcionResolucion = true;
                    this.mostrarDesactivarComplementariaEntidad = true;
                    //this.mostrarEnvioOrganismo = true;
                }

                if(this.status == this.statusAnalisisComplementariaOrganismo){
                    this.mostrarReasignarLetrado = true;
                    this.mostrarEnvioComplementaria = true;
                    this.mostrarNegociacion = true;
                    this.modalReaperturaConsumo = false;
                    if(this.organismo != this.organismoConsumo){
                        this.mostrarDesactivarComplementariaOrganismo = true;
                    }else{
                        this.mostrarCerrar = true;
                    }
                }

                if(this.status == this.statusEnvioComplementaria){
                    // this.mostrarEnvioOrganismo = true;
                    this.mostrarDevolverLetrado = true;
                    this.mostrarMotivoDevolucionEnvioComplementaria = true;
                }

                if(this.status == this.statusRecepcionResolucion){
                    this.mostrarRectificacion = true;
                    this.mostrarCerrar = true;
                    this.mostrarPendienteRespOrganismo = true;
                }

                if(this.status == this.statusRectificacion){
                    this.mostrarReasignarLetrado = true;
                    this.mostrarRecepcionResolucion = true;
                    this.mostrarEnvioRectificacion = true;
                    this.mostrarNegociacion = true;
                }

                if(this.status == this.statusEnvioRectificacion){
                    // this.mostrarEnvioOrganismo = true;
                    this.mostrarDevolverLetrado = true;
                    //this.mostrarPendienteRespOrganismo = true;
                this.mostrarMotivoDevolucionEnvioRectificacion = true;
                }

                if(this.status == this.statusCerrar || this.status == this.statusDescartado){
                    this.mostrarReapertura = true;
                }

                if(this.status == this.statusCerrar){
                    if(this.organismo === this.organismoConsumo){
                        this.mostrarComplementariaEntidad = true;
                    }else{
                        this.mostrarNegociacion = true;
                    }
                }
            }

            // Logica mostrar botón desactivar negociación
            if(this.negociacionEnCurso){
                if(this.esPretension == true) {
                    this.negociacionEnCurso = false;
                }
                this.mostrarNegociacion = false;
                this.mostrarFinalizarNegociacion = true;
                if(this.status == this.statusRectificacion) {
                    this.mensajeNegociacion = "Rectificación en Negociación";
                }
            }
            
            // Botón Prorrogar
            /*if(!this.prorrogado && (this.status == 'SAC_002' || this.SPV_ComplementariaOrganismo__c == true)){
                comprobarSLAGeneralActivo({'idCaso': this.recordId}).then(result=>{
                    if(result == true || result == false){
                        this.mostrarProrroga = result;
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
            }*/
            this.grupo = data.fields?.SEG_Grupo__c?.value;
            
            recuperarUser({ 'grupoCaso': this.grupo, 'idCaso': this.recordId, 'ownerCaso': this.owner}).then(result=>{
                if(result){
                    this.esGestor = result.SPV_Gestor !== undefined;
                    this.esLetrado = result.SPV_Letrado !== undefined;
                    this.esAdministrador = result.SPV_Administrador !== undefined;
                    /*if(this.esAdministrador === false){
                        this.deshabilitarReasignar = true;
                    }*/

                    /*if(this.esGestor === true && (this.status === 'SAC_001' || this.status === 'SAC_002')){
                        this.habilitarDevolver = true;
                    }else{
                        this.habilitarDevolver = false;
                    }*/

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
                if(resultado){
                    this.esLetrado = resultado.esUsuarioLetrado;
                    this.esGestor = resultado.esUsuarioGestor;
                    this.esCOPSAJ = resultado.esUsuarioCOPSAJ;
                    // Si el usuario el letrado o COPS puede iniciar o finalizar la negociación
                    if(this.esCOPSAJ || this.esLetrado) {
                        this.noPuedeNegociar = false;
                    }
                }
                if(this.esLetrado || this.esGestor){
                    this.esGestorLetrado = true;
                }     
                if(this.esCOPSAJ){
                    this.esLetrado = true;
                    this.esGestor = true;
                    this.esGestorLetrado = true;
                }
                // Deshabilitar botones
                if(!this.esGestor && !this.esCOPSAJ){
                    this.noEsGestor = true;
                }
                if(!this.esLetrado && !this.esCOPSAJ){
                    this.noEsLetrado = true;
                }
                if(!this.esLetrado && !this.esGestor && !this.esCOPSAJ){
                    this.noEsGestorLetrado = true;
                }  
                // if(resultado == true || resultado == false){
                //     this.esGestorLetrado = resultado;
                 
                    /*
                    //El gestor/letrado, en estado de alta o análisis, puede ver el botón de descartar
                    if(this.esGestorLetrado == true && (this.status === 'SAC_001' || this.status === 'SAC_002')){
                        this.deshabilitarDescartar = false;
                    }else{
                        this.deshabilitarDescartar = true;
                    }

                    //Solo se mostrará el botón para devolver a alta en caso de una reclamación en estado de análisis
                    if(this.esGestorLetrado == true && this.status == 'SAC_002'){
                        this.mostrarDevolverAlta = true;
                        this.mostrarReasignarLetrado = true;
                        this.mostrarTomarPropiedad = true;
                        this.mostrarProrroga = true;
                        this.mostrarNegociacion = true;
                        this.mostrarEnvio = true;
                    }else{
                        this.mostrarDevolverAlta = false;
                        this.mostrarReasignarLetrado = false;
                        this.mostrarProrroga = false;
                        this.mostrarNegociacion = false;
                        this.mostrarEnvio = false;
                    }*/

                //}
            }).catch(error =>{
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error'
                    }),);
            });

            
            if(!this.esPretension && this.status === this.statusCerrar){

                
                comprobarTareasPtes({ 'idCaso': this.recordId }).then(result=>{
                    if(result){
                        this.hayTareasPtes = result;    
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
    }

    filtrarMotivosReapertura(){        
        if(this.valoresPicklisMotivoReapertura.length > 0){
            if(this.organismo == 'SPV_Consumo'){               
                this.valoresPicklisMotivoReapertura = this.valoresPicklisMotivoReapertura.filter(item => item.value !== 'SPV_SegundaRectificacion' && item.value !== 'SPV_CambioResolucion' && item.value !== 'SPV_ActivarComplementariaOrganismo');
            }else{
                this.valoresPicklisMotivoReapertura = this.valoresPicklisMotivoReapertura.filter(item => item.value !== 'SPV_NuevoRequerimientoConsumo');
            }
        }
    }

    /*get mostrarReasignar() {
        return !this.esAdministrador;
    }*/

    onClickTomarPropiedad(){         
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
    onClickDerivar(){
        const event = new CustomEvent('derivarclick');
        this.dispatchEvent(event);
    }

    onClickConvertir() {
        this.convertir = true;
    }

    cerrarModalConvertir() {
        this.convertir = false;
        this.confirmarConvertir = false;
    }
    
    /*confirmarConsultaCOPS() {
        this.confirmarConvertir = true;
    }*/
    
    convertirAConsultaCOPS(){
    this.isLoading = true;
    this.convertir = false;
    convertirReclamacion({'caseId': this.recordId, 'naturaleza' : 'ConsultaCOPS'}).then(()=>{
        this.isLoading = false;
        //this.mostrarModalDevolverLetrado = false;
        //this.valueMotivoDevolucionALetrado = '';
        this.refreshView();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Éxito',
                message: 'La reclamación se ha convertido a una Consulta COPS',
                variant: 'success'
            }));          
        
        }).catch(error =>{
            this.isLoading = false;
            //this.mostrarModalDevolverLetrado = false;
            this.lanzarToast('Error', 'Error al convertir reclamación: ' + this.extractErrorMessage(error), 'error');
        });
    }

    convertirAReclamacionSAC(){
        this.isLoading = true;
        this.convertir = false;
        convertirReclamacion({'caseId': this.recordId, 'naturaleza' : 'ReclamacionSAC'}).then(()=>{
            this.isLoading = false;
            //this.mostrarModalDevolverLetrado = false;
            //this.valueMotivoDevolucionALetrado = '';
            this.refreshView();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'La reclamación se ha convertido a una Reclamación SAC',
                    variant: 'success'
                }));          
            
            }).catch(error =>{
                this.isLoading = false;
                //this.mostrarModalDevolverLetrado = false;
                this.lanzarToast('Error', 'Error al convertir reclamación: ' + this.extractErrorMessage(error), 'error');
            });
        }

        convertirAConsultaSPV(){
            this.isLoading = true;
            this.convertir = false;
            convertirReclamacion({'caseId': this.recordId, 'naturaleza' : 'ConsultaSPV'}).then(()=>{
                this.isLoading = false;
                //this.mostrarModalDevolverLetrado = false;
                //this.valueMotivoDevolucionALetrado = '';
                this.refreshView();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'La reclamación se ha convertido a una Consulta SPV',
                        variant: 'success'
                    }));          
                
                }).catch(error =>{
                    this.isLoading = false;
                    //this.mostrarModalDevolverLetrado = false;
                    this.lanzarToast('Error', 'Error al convertir reclamación: ' + this.extractErrorMessage(error), 'error');
                });
            }
    /*
      convertirAConsultaSAC :  function(component, event, helper){
            component.set("v.isLoading", true);
        component.set("v.convertir", false);
        component.set("v.confirmarConvertir", false);
            let idCase = component.get("v.recordId");
            let resolucion = component.get("c.convertirReclamacion");
            resolucion.setParams({'caseId': idCase, 'naturaleza' : 'Consulta'});
            resolucion.setCallback(this, function (response) {
                var state = response.getState();
                
                if (state == "SUCCESS") {
            component.set("v.isLoading", false);
                    var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Éxito!",
              message: "Se ha convertido la reclamación a una Consulta SAC",
              type: "success"
            });
            toastEvent.fire();
            $A.get("e.force:refreshView").fire();
                }
                else{
                    component.set("v.isLoading", false);
            var errors = response.getError();
            let toastParams = {
              title: "Error",
              message: errors[0].message, 
              type: "error"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
                }
                
            });
            $A.enqueueAction(resolucion);
        }*/
    
    onClickDevolverCaso(){
        this.selectedMotivo = null;
        return this.modalDevolver = true;
    }

    onClickDevolverALetrado(){
        this.mostrarModalDevolverLetrado = true;
    }

    closeModalDevolverLetrado(){
        this.mostrarModalDevolverLetrado = false;
        this.valueMotivoDevolucionALetrado = '';
        this.mostrarObservacionesDevolverLetrado = false;
        this.observacionesDevolverLetrado = '';
    }

    handleChangeMotivoDevolucionALetrado(event){
        this.valueMotivoDevolucionALetrado = event.target.value;
        if(this.valueMotivoDevolucionALetrado == 'SPV_010'){
            this.mostrarObservacionesDevolverLetrado = true;
        }else{
            this.mostrarObservacionesDevolverLetrado = false;
        }
    }

    handleChangeObservacionesDevolverLetrado(event){
        this.observacionesDevolverLetrado = event.target.value;
    }

    confirmarDevolverLetrado(){
        if(this.tienePretensionPrincipal == true && this.pretPrincipalTieneLetrado == true && ((this.valueMotivoDevolucionALetrado != '' && this.valueMotivoDevolucionALetrado != null && this.valueMotivoDevolucionALetrado != 'SPV_010') || (this.valueMotivoDevolucionALetrado == 'SPV_010' && this.observacionesDevolverLetrado !== ''))){
            this.isLoading = true;
            this.mostrarModalDevolverLetrado = false;
            devolverALetrado({'caseId': this.recordId, 'motivo': this.valueMotivoDevolucionALetrado, 'observaciones': this.observacionesDevolverLetrado}).then(()=>{
                this.isLoading = false;
                this.valueMotivoDevolucionALetrado = '';
                this.mostrarObservacionesDevolverLetrado = false;
                this.observacionesDevolverLetrado = '';

                this.refreshView();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'La reclamación ha sido devuelta al letrado.',
                        variant: 'success'
                    }),);          
                
                }).catch(error =>{
                    this.isLoading = false;
                    this.mostrarModalDevolverLetrado = false;
                    this.lanzarToast('Error', 'Error al devolver al letrado: ' + this.extractErrorMessage(error), 'error');
                });
        }else{
            if(this.valueMotivoDevolucionALetrado == ''){
                this.lanzarToast('Adventercia!', 'Debes completar el campo Motivo de devolución a letrado antes de continuar.', 'warning');
            }else if(this.valueMotivoDevolucionALetrado == 'SPV_010' && (this.observacionesDevolverLetrado == '' || this.observacionesDevolverLetrado == null)){
                this.lanzarToast('Adventercia!', 'Debes completar el campo Observaciones de devolución a letrado antes de continuar.', 'warning');
            }else if(this.tienePretensionPrincipal == true && this.pretPrincipalTieneLetrado == false){
                this.lanzarToast('Error', 'Es necesario que la pretensión principal tenga Owner para poder devolver la reclamación al letrado.', 'error');
                this.mostrarModalDevolverLetrado = false;
                this.valueMotivoDevolucionALetrado = '';
            }else{
                this.lanzarToast('Error', 'No es posible devolver a letrado sin informar una pretensión principal.', 'error');
                this.mostrarModalDevolverLetrado = false;
                this.valueMotivoDevolucionALetrado = '';
            }
            this.isLoading = false;
            
        }

    }

    devolverACola(){
        this.isLoading=true;
        if(this.observacion != null){
            this.modalDevolver=false;
                devolverCaso({'caseId': this.recordId, /*'motivo': this.motivo,*/ 'comentario': this.observacion}).then(()=>{
                    this.isLoading=false;
                    this.observacion = undefined;   //Se vuelve a establecer el comentario a vacío
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
        }else{
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Es obligatorio informar comentarios',
                    variant: 'error'
                }),);
        }
        /*this.motivo = this.selectedMotivo
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
                this.modalDevolver=false;
                devolverCaso({'caseId': this.recordId, 'motivo': this.motivo, 'comentario': this.observacion}).then(()=>{
                    this.isLoading=false;
                    this.observacion = undefined;   //Se vuelve a establecer el comentario a vacío
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
        }else{
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No hay motivo',
                    variant: 'error'
                }),);
        }*/
    }


    handleChangeMotivo(event){
        this.selectedMotivo = event.target.value;
    }

    handleChangeObs(event){
        this.observacion = event.target.value;
        if(this.observacion == ''){
            this.observacion = undefined;
        }
    }

    closeModal(){
        this.observacion = undefined;
        return this.modalDevolver = false;
    }

    get noEsPropietario(){
        if(this.esCOPSAJ){
            return this.esPropietario;
        }else{
            return !this.esPropietario;
        }
    }

    

    onClickAbrirModalDescartar(){
        this.abrirModalDescartar = true;
        this.selectedMotivoDescarte = null;
    }

    cerrarModalDescartar(){
        this.abrirModalDescartar = false;
        this.selectedMotivoDescarte = '';
        this.mostrarObservacionesDescartar = false;
        this.observacionesDescartar = '';
    }

    handleChangeMotivoDescartar(event){
        this.selectedMotivoDescarte = event.target.value;
        if(this.selectedMotivoDescarte == 'SAC_Otros'){
            this.mostrarObservacionesDescartar = true;
        }else{
            this.mostrarObservacionesDescartar = false;
        }
    }

    handleChangeObservacionesDescartar(event){
        this.observacionesDescartar = event.target.value;
    }

    descartarReclamacion(){
            if((this.selectedMotivoDescarte != '' && this.selectedMotivoDescarte != null && this.selectedMotivoDescarte != 'SAC_Otros') || (this.selectedMotivoDescarte == 'SAC_Otros' && this.observacionesDescartar !== '')){
                this.isLoading= true;
                this.abrirModalDescartar = false;
                metodoDescartarReclamacion({'caseId': this.recordId, 'motivo': this.selectedMotivoDescarte, 'observaciones': this.observacionesDescartar}).then(()=>{
                    this.isLoading = false;
                    this.deshabilitarBotonDescartar = true;
                    this.observacionesDescartar = '';
                    this.selectedMotivoDescarte = '';
                    this.mostrarObservacionesDescartar = false;
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
            }else{
                if(this.selectedMotivoDescarte != 'SAC_Otros'){
                    this.lanzarToast('Advertencia!', 'Por favor, seleccione el motivo de descarte para descartar el caso.', 'warning');
                }else{
                    this.lanzarToast('Advertencia!', 'Debe completar el campo de observaciones.', 'warning');
                }
            }
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

    onclickAbrirModalAnularProrroga(){
        this.mostrarModalAnularProrroga = true;
    }

    cerrarModalAnularProrroga(){
        this.mostrarModalAnularProrroga = false;
        this.valueMotivoAnularProrroga = '';
        this.mostrarObservacionesAnularProrroga = false;
        this.observacionesAnularProrroga = '';
    }

    handleChangeMotivoAnularProrroga(event){
        this.valueMotivoAnularProrroga = event.target.value;
        if(this.valueMotivoAnularProrroga == 'SPV_003'){
            this.mostrarObservacionesAnularProrroga = true;
        }else{
            this.mostrarObservacionesAnularProrroga = false;
        }
    }

    handleChangeObservacionesAnularProrroga(event){
        this.observacionesAnularProrroga = event.target.value;
    }

    onClickAnularProrroga(){
        if((this.valueMotivoAnularProrroga != '' && this.valueMotivoAnularProrroga != 'SPV_003') || (this.valueMotivoAnularProrroga == 'SPV_003' && this.observacionesAnularProrroga !== '')){
            this.isLoading= true;
            this.mostrarModalAnularProrroga = false;
            anularProrrogaReclamacion({'idCaso': this.recordId, 'motivo': this.valueMotivoAnularProrroga, 'observaciones': this.observacionesAnularProrroga}).then(()=>{
                this.isLoading = false;
                this.valueMotivoAnularProrroga = '';
                this.observacionesAnularProrroga = '';
                this.mostrarObservacionesAnularProrroga = false;
                this.mostrarAnularProrroga = false;
                this.refreshView();
                
                //De momento este método no está desarrollado.
                /*this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'Se ha prorrogado la reclamación.',
                        variant: 'success'
                    })
                );*/          
            
            }).catch(error =>{
                this.isLoading = false;
                this.lanzarToast('Error', 'Error al anular la prórroga ' + this.extractErrorMessage(error), 'error');
            });
        }else{
            if(this.valueMotivoAnularProrroga != 'SPV_003'){
                this.lanzarToast('Advertencia!', 'Debe completar el motivo por el que se anula la prórroga.', 'warning');
            }else{
                this.lanzarToast('Advertencia!', 'Debe completar el campo de observaciones.', 'warning');
            }  
        }
    }

    onClickProrrogar() {
        // this.modalProrroga = true;
        this.prorrogarReclamacion();
    }

    onclickAbrirModalProrroga(){
        this.mostrarModalProrroga = true;
    }

    cerrarModalProrroga(){
        this.mostrarModalProrroga = false;
        this.valueMotivoProrroga = '';
        this.mostrarObservacionesProrroga = false;
        this.observacionesProrroga = '';
    }

    handleChangeMotivoProrroga(event){
        this.valueMotivoProrroga = event.target.value;
        if(this.valueMotivoProrroga == 'SPV_004'){
            this.mostrarObservacionesProrroga = true;
        }else{
            this.mostrarObservacionesProrroga = false;
        }
    }

    handleChangeObservacionesProrroga(event){
        this.observacionesProrroga = event.target.value;
    }

    prorrogarReclamacion() {

        if((this.valueMotivoProrroga != '' && this.valueMotivoProrroga != 'SPV_004') || (this.valueMotivoProrroga == 'SPV_004' && this.observacionesProrroga !== '')){
            this.isLoading= true;
            this.mostrarModalProrroga = false;
            prorrogarReclamacion({'idCaso': this.recordId, 'motivo': this.valueMotivoProrroga, 'observaciones': this.observacionesProrroga}).then(()=>{
                this.isLoading = false;
                this.valueMotivoProrroga = '';
                this.observacionesProrroga = '';
                this.mostrarObservacionesProrroga = false;
                this.mostrarAnularProrroga = true;  //Si se completa la prórroga correctamente, se muestra el botón de anular prórroga
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
        }else{
            if(this.valueMotivoProrroga != 'SPV_004'){
                this.lanzarToast('Advertencia!', 'Debe completar el motivo de Prórroga.', 'warning');
            }else{
                this.lanzarToast('Advertencia!', 'Debe completar el campo de observaciones.', 'warning');
            }  
        }

    }


    onClickAbrirModalDevolverAlta(){
        this.modalDevolverAlta = true;
    }

    cerrarModalDevolverAlta(){
        this.modalDevolverAlta = false;
        this.valueMotivoDevolucionAlta = '';
        this.observacionesDevolucionAlta = '';
        this.mostrarObservacionesDevolucionAlta = false;
    }

    handleChangeDevolverAlta(){
        if((this.valueMotivoDevolucionAlta != '' && this.valueMotivoDevolucionAlta != 'SPV_004') || (this.valueMotivoDevolucionAlta == 'SPV_004' && this.observacionesDevolucionAlta !== '')){
            this.isLoading = true;
            this.modalDevolverAlta = false;
            devolverReclamacionAlta({'caseId': this.recordId, 'motivoDevolucion': this.valueMotivoDevolucionAlta, 'observacionesDevolucion': this.observacionesDevolucionAlta}).then(()=>{
                this.isLoading = false;
                this.valueMotivoDevolucionAlta = '';
                this.observacionesDevolucionAlta = '';
                this.mostrarObservacionesDevolucionAlta = false;
                //this.mostrarDevolverAlta = false;
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
        }else{
            if(this.valueMotivoDevolucionAlta != 'SPV_004'){
                this.lanzarToast('Advertencia!', 'Debe completar el motivo de devolución a alta.', 'warning');
            }else{
                this.lanzarToast('Advertencia!', 'Debe completar el campo de observaciones.', 'warning');
            }
        }
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


    /*volverAnalisis(){

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
 
    }*/

    onClickAnalisis(){
        this.isLoading = true;
        cambioEstado({'caseId': this.recordId, 'status': this.statusAnalisisDecision})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'La reclamación ha pasado a "Análisis y Decisión"', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        });
        this.refreshView();
    }

    onClickPendienteRespOrganismo(){
        this.isLoading = true;
        cambioEstado({'caseId': this.recordId, 'status': this.statusPendienteRespuestaOrganismo})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'La reclamación ha pasado a "Pendiente Respuesta Organismo"', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        });
        this.refreshView();
    }

    onClickDesactivarComplementariaOrganismo(){
        this.isLoading = true;
        desactivarComplementariaOrganismo({'caseId': this.recordId})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'Se ha desactivado la complementaria organismo y el estado es "Envío"', 'success'); 

        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        }); 
        this.refreshView();
    }

    onClickEnvioComplementaria(){
        this.isLoading = true;
        cambioEstado({'caseId': this.recordId, 'status': this.statusEnvioComplementaria})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'Reclamación ha pasado a "Envío Complementaria"', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        }); 
        this.refreshView();
    }

    onClickEnvioRectificacion(){
        this.isLoading = true;
        cambioEstado({'caseId': this.recordId, 'status': this.statusEnvioRectificacion})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'Reclamación ha pasado a "Envío Rectificación"', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        }); 
        this.refreshView();
    }

    onClickRecepcionResolucion(){
        this.isLoading = true;
        cambioEstado({'caseId': this.recordId, 'status': this.statusRecepcionResolucion})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'Reclamación ha pasado a "Recepción Resolución"', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        }); 
        this.refreshView();
    }

    onClickBaja(){
        esPrincipal({record: this.recordId}).then(result =>{
            if(result=='KO'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'No se puede dar de baja',
                        message: 'Para dar de baja esta pretensión se necesita asignar como "Pretensión principal" otra pretensión.',
                        variant: 'error'
                    }));
                
            }else if(result == 'OK'){
                this.setBaja();
            }
        })
    }

    setBaja(){
        
        this.isLoading = true;
        cambioEstado({'caseId': this.recordId, 'status': this.statusBaja})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'Pretensión ha pasado a "Baja"', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        }); 
        this.refreshView();
    }

    onClickNegociacion(){
        getPretensiones({'idCaso': this.recordId})
        .then(data=>{
            this.pretensiones = data;
            if(this.pretensiones) {
                let casos = [];
                this.pretensiones.forEach(pretensionRecuperada => {
                    let pretension = {};
                    pretension.Id = pretensionRecuperada.Id;
                    pretension.CC_MCC_Tematica = pretensionRecuperada.CC_MCC_Tematica__r.Name;
                    pretension.CC_MCC_ProdServ = pretensionRecuperada.CC_MCC_ProdServ__r.Name;
                    pretension.CC_MCC_Motivo = pretensionRecuperada.CC_MCC_Motivo__r.Name;
                    pretension.SEG_Detalle = pretensionRecuperada.SEG_Detalle__r.Name;
                    casos.push(pretension);
                });
                this.pretensiones = casos;
            } 
            this.modalNegociacion = true;
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        }); 
        this.refreshView();
    }

    handleRowSelection() {
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRecords.length > 0){
            this.mostrarBotonSeleccionPretensiones = false;
            this.lstSelectedRecords = selectedRecords;
        } else {
            this.mostrarBotonSeleccionPretensiones = true;
        }  
    }

    negociarPretensiones() {
        this.isLoading = true;

		activarNegociacionReclamacion({caseId: this.recordId, pretensionesNegociacion: this.lstSelectedRecords}).then(result =>{
            this.isLoading = false;
            this.modalNegociacion = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'La reclamación ha entrado en negociación', 'success');    
        })
        .catch(error => {
            this.modalNegociacion = false;
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        });
    }

    closeModalNegociacion(){
        this.mostrarBotonSeleccionPretensiones = true;
        this.modalNegociacion = false;
    }

    onClickFinalizarNegociacion(){
        this.modalNegociacionActiva = false;
        this.hayCamposPendientesNegociacion = false;
        comprobarCamposNegociacionInformados({'caseId': this.recordId})
        .then(data=>{
            this.camposPendientesNegociacion = data;
            if(this.camposPendientesNegociacion) {
                this.hayCamposPendientesNegociacion = true;
            } 
            this.modalFinalizarNegociacion = true;
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        }); 
    }

    finalizarNegociacion(){
        finalizarNegociacionReclamacion({'caseId': this.recordId})
        .then(() =>{
            this.negociacionEnCurso = false;
            this.mostrarNegociacion = true;
            this.modalFinalizarNegociacion = false;
            this.mostrarFinalizarNegociacion = false;
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'Se ha finalizado la negociación de la reclamación', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        }); 
    }

    closeModalFinalizarNegociacion(){
        this.modalFinalizarNegociacion = false;
    }

    /*onClickEnvioOrganismo(){
         this.isLoading = true;
         cambioEstado({'caseId': this.recordId, 'status': this.statusPendienteRespuestaOrganismo})
         .then(() => {
             this.isLoading = false;
             this.refreshView();
             this.lanzarToast('Éxito!', 'Reclamación ha pasado a "Pendiente Respuesta Organismo"', 'success');    
         })
         .catch(error => {
             this.isLoading = false;
             this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
         }); 
        this.refreshView();
     }*/
 


    
    onClickEnvio(){
        this.isLoading = true;
        // Si hay una negociación en curso y se quiere enviar la reclamación se debe mostrar un modal indicando la negoaciación
        if(this.negociacionEnCurso == true) {
            this.isLoading = false;
            this.modalNegociacionActiva = true;
        } else {
            cambioEstado({'caseId': this.recordId, 'status': this.statusEnvio})
            .then(() => {
                this.isLoading = false;
                this.refreshView();
                this.lanzarToast('Éxito!', 'Reclamación ha pasado a "Envío"', 'success');    
            })
            .catch(error => {
                this.isLoading = false;
                this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
            });
            this.refreshView();
        }   
    }

    onclickComprobarCamposEnvio(){
        this.isLoading = true;
        if(this.negociacionEnCurso == true) {
            this.isLoading = false;
            this.modalNegociacionActiva = true;
        } else {
            comprobarCamposPasarEnvio({'caseId': this.recordId})
            .then(data=>{
                this.camposPendientesParaEnvio = data;
                if(this.camposPendientesParaEnvio) {
                    this.isLoading = false;
                    this.mostrarModalPasoEstadoEnvio = true;
                }else{
                    this.onClickEnvio();
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
            }); 
        }
    }

    closeModalCamposPasarEnvio(){
        this.mostrarModalPasoEstadoEnvio = false;
        this.camposPendientesParaEnvio = '';
    }


    closeModalNegociacionEnCurso(){
        this.modalNegociacionActiva = false;
    }

    continuarCambioEstado(){
        this.modalNegociacionActiva = false;
        this.isLoading = true;
        cambioEstado({'caseId': this.recordId, 'status': this.statusEnvio})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'Reclamación ha pasado a "Envío"', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        });
        this.refreshView();
    }

    /*onClickResolucion(){
        this.isLoading = true;
        cambioEstado({'caseId': this.recordId, 'status': this.statusRecepcionResolucion})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'Reclamación ha pasado a "Resolución"', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        });
    }*/
    get diaActual() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        return today
    }

    onClickCerrar(){
        this.isLoading = true;
        cambioEstado({'caseId': this.recordId, 'status': this.statusCerrar})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'Reclamación ha pasado a "Cerrado"', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        });
        this.refreshView();
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

    deshacerBajaPretension(){
        this.isLoading = true;
        cambioEstado({'caseId': this.recordId, 'status': null})
        .then(() => {
            this.isLoading = false;
            this.refreshView();
            this.lanzarToast('Éxito!', 'La pretensión ha salido de Baja', 'success');    
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        });
        this.refreshView();
    }
        
    onClickReasignarLetrado(){
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
        this.isLoading = true;

        if(this.selectedOptionGrupoLet != '' && this.inputMotivoReasignar != '' && this.inputMotivoReasignar != undefined){
            this.modalReasignar = false;
            reasignarGrupoLetrado({'caseId': this.recordId, 'idGrupo': this.selectedOptionGrupoLet, 'motivo': this.inputMotivoReasignar}).then(()=>{
                this.isLoading = false;
                this.inputMotivoReasignar = '';             //Se vacía el motivo para una posible posterior reasignación
                this.selectedOptionGrupoLet = '';
                this.refreshView();
                this.lanzarToast('Éxito!', 'Se ha actualizado el grupo de trabajo de las pretensiones e informado el motivo de reasignación.', 'success');        
                
            }).catch(error =>{
                this.isLoading = false;
                this.lanzarToast('Error', 'Error al asignar el nuevo grupo letrado: ' + this.extractErrorMessage(error), 'error');
            });
        }else{
            this.isLoading = false;
            this.lanzarToast('Cuidado!', 'Debe completar todos los campos para finalizar la reasignación.', 'warning');
        }
    }

    onClickActivarComplementariaEntidad(event) {
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
            this.lanzarToast('Error', 'Error al activar. ' + this.extractErrorMessage(error), 'error');
        });
    }

    onClickActivarRectificacion(event) {
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
            this.lanzarToast('Error', 'Error al activar. ' + this.extractErrorMessage(error), 'error');
        });
    }

    // closeModalProrroga() {
    //     this.modalProrroga = false;
    // }

    // get acceptedFormats() {
    //     return ['.pdf','.png','.jpg', '.jpeg'];
    // }

    // handleUploadFinished(event) {
    //     let uploadedFiles = event.detail.files;

    //     clasificarDocumentoProrroga({caseId: this.recordId, numFicheros: uploadedFiles.length}).then(() => {
    //         this.refreshView();
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Éxito',
    //                 message: 'Se ha subido el archivo.',
    //                 variant: 'success'
    //             }),);          
        
    //     }).catch(error =>{
    //         this.isLoading = false;
    //         this.lanzarToast('Error', 'Error al subir el archivo ' + this.extractErrorMessage(error), 'error');
    //     });
    // }


    onClickAbrirModalReapertura(){
        if(this.organismo === this.organismoConsumo){
            this.modalReaperturaConsumo = true;
        }else{
            this.modalReaperturaNoConsumo = true;
        }
    }

    closeModalReapertura(){
        this.modalReaperturaNoConsumo = false;
        this.modalReaperturaConsumo = false;
        this.observacionesMotivoReapertura = '';
        this.valueMotivoReapertura = '';
        this.mostrarObservacionesReapertura = false;
    }

    handleChangeMotivoReap(event){
        this.observacionesMotivoReapertura = event.target.value;
    }

    handleChangeObservacionesDevolucionAlta(event){
        this.observacionesDevolucionAlta = event.target.value;
    }

    confirmarReapertura(){

        if(this.valueMotivoReapertura != '' && this.valueMotivoReapertura != 'SPV_Otros' || (this.valueMotivoReapertura == 'SPV_Otros' && this.observacionesMotivoReapertura !== '')){
            this.isLoading = true;
            this.modalReaperturaNoConsumo = false;
            this.modalReaperturaConsumo = false;
            reabrirReclamacion({'idCaso': this.recordId, 'reaperturaRectificacion': this.esRectificado, 'motivoReapertura': this.valueMotivoReapertura, 'observacionesMotivoReapertura': this.observacionesMotivoReapertura}).then(()=>{
                this.isLoading = false;
                this.observacionesMotivoReapertura = '';
                this.valueMotivoReapertura = '';
                this.mostrarObservacionesReapertura = false;
                this.refreshView();
                this.lanzarToast('Éxito', 'Se ha reabierto la reclamación.', 'success');        
                
            }).catch(error =>{
                this.isLoading = false;
                this.lanzarToast('Error', 'Error al reabrir la reclamación: ' + this.extractErrorMessage(error), 'error');
            });
        }else{
            if(this.valueMotivoReapertura != 'SPV_Otros'){
                this.lanzarToast('Advertencia!', 'Debe completar el motivo de reapertura de la reclamación.', 'warning');
            }else{
                this.lanzarToast('Advertencia!', 'Debe completar el campo de observaciones.', 'warning');
            }
        }
    }


    /*@wire(comprobarSLAPlazoRegCompOrgCompletado, {casoId: '$recordId'})
    comprobarSLAPlazoRegCompOrgCompletado(result){
        this.tinePlazoRegOrgCompletado = result.data;
    }*/

    onClickComplementariaOrganismo(){
        this.isLoading = true;
    comprobarSLAPlazoRegCompOrgCompletado({'casoId': this.recordId}).then((result)=>{
        this.tinePlazoRegOrgCompletado = result;
        this.modalCompleOrganismo = true;
        this.isLoading = false;
    }).catch(error =>{
        this.isLoading = false;
        this.lanzarToast('Error', 'Error al cargar complementaria organismo ' + this.extractErrorMessage(error), 'error');
    });
    }

    closeModalComplOrganismo(){
        this.modalCompleOrganismo = false;
        this.selectedMotivoComplOrganismo = '';
        this.mostrarObservacionesComplementariaOrganismo = false;
        this.observacionesMotivoComplementariasOrganismo = '';
        this.fechaVencimientoPlazoRegCompOrganismo = '';
        this.fechaPlazoRegCorrecta = false;
    }

    handleOptionChangeComplOrganismo(event){
        this.selectedMotivoComplOrganismo = event.target.value;
        if(this.selectedMotivoComplOrganismo == 'SPV_Otros'){
            this.mostrarObservacionesComplementariaOrganismo = true;
        }else{
            this.mostrarObservacionesComplementariaOrganismo = false;
        }
    }

    handleChangeObservComplementariaOrganismo(event){
        this.observacionesMotivoComplementariasOrganismo = event.target.value;
    }

    handleChangeFechaVencimientoPlazoRegCompOrganismo(event){
        this.fechaVencimientoPlazoRegCompOrganismo = event.target.value;
        const formatoFecha = /^\d{4}-\d{2}-\d{2}$/;
        if(this.fechaVencimientoPlazoRegCompOrganismo < this.fechaActual() || this.fechaVencimientoPlazoRegCompOrganismo == '' || !formatoFecha.test(this.fechaVencimientoPlazoRegCompOrganismo)){
            this.fechaPlazoRegCorrecta = false;
        }else{
            this.fechaPlazoRegCorrecta = true;
        }
    }


    fechaActual() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        return today
    }

    activarComplementariaOrganismoBtn(){
        if((this.selectedMotivoComplOrganismo != '' && this.selectedMotivoComplOrganismo != 'SPV_Otros' && (this.fechaPlazoRegCorrecta == true || this.tinePlazoRegOrgCompletado == true)) || (this.selectedMotivoComplOrganismo == 'SPV_Otros' && this.observacionesMotivoComplementariasOrganismo !== '' && (this.fechaPlazoRegCorrecta == true || this.tinePlazoRegOrgCompletado == true))){
            this.isLoading = true;
            this.modalCompleOrganismo = false;
            if(this.tinePlazoRegOrgCompletado == true){
                this.fechaVencimientoPlazoRegCompOrganismo = null;
            }
            activarComplementariaOrganismo({'caseId': this.recordId, 'motivoComplementaria': this.selectedMotivoComplOrganismo, 'observaciones': this.observacionesMotivoComplementariasOrganismo, 'fechaVencimientoPlazoRegOrganismo': this.fechaVencimientoPlazoRegCompOrganismo}).then(()=>{
                this.isLoading = false;
                this.selectedMotivoComplOrganismo = '';
                this.mostrarObservacionesComplementariaOrganismo = false;
                this.observacionesMotivoComplementariasOrganismo = '';
                this.fechaVencimientoPlazoRegCompOrganismo = '';
                this.fechaPlazoRegCorrecta = false;
                this.refreshView();
                this.lanzarToast('Éxito', 'Se ha activado la complementaria organismo y cambiado de estado la reclamación.', 'success');
                
                }).catch(error =>{
                    this.isLoading = false;
                    this.fechaVencimientoPlazoRegCompOrganismo = '';
                    this.fechaPlazoRegCorrecta = false;
                    this.selectedMotivoComplOrganismo = '';
                    this.mostrarObservacionesComplementariaOrganismo = false;
                    this.observacionesMotivoComplementariasOrganismo = '';
                    this.lanzarToast('Error', 'Error al activar la complementaria organismo: ' + this.extractErrorMessage(error), 'error');
                });
        }else{
            if(this.selectedMotivoComplOrganismo == ''){
                this.lanzarToast('Advertencia!', 'Debe completar el motivo de la activación.', 'warning');
            }else{
                if(this.observacionesMotivoComplementariasOrganismo == '' && this.selectedMotivoComplOrganismo == 'SPV_Otros'){
                    this.lanzarToast('Advertencia!', 'Debe completar el campo de observaciones.', 'warning');
                }else{
                    if(this.fechaPlazoRegCorrecta == false && this.tinePlazoRegOrgCompletado == false){
                        this.lanzarToast('Advertencia!', 'Debe completar e introducir una fecha correcta para el vencimiento de SLA Plazo Regulatorio Complementaria Organismo', 'warning');
                    }
                }

            }
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

    handleChangeMotivoReapertura(event){
        this.valueMotivoReapertura = event.detail.value;
        
        if(this.valueMotivoReapertura == 'SPV_Otros'){
            this.mostrarObservacionesReapertura = true;
        }else{
            this.mostrarObservacionesReapertura = false;
        }
    }

    handleChangeMotivoDevolucionAlta(event){
        this.valueMotivoDevolucionAlta = event.detail.value;
        
        if(this.valueMotivoDevolucionAlta == 'SPV_004'){
            this.mostrarObservacionesDevolucionAlta = true;
        }else{
            this.mostrarObservacionesDevolucionAlta = false;
        }
    }
}