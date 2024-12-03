import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import ESCALADO_OBJECT from '@salesforce/schema/SAC_Interaccion__c'; 

//LLamadas Apex
import getEscaladosReclamacion from '@salesforce/apex/SPV_LCMP_CamposDesplegables.getEscaladosReclamacion';
import getRecordTypes from '@salesforce/apex/SPV_LCMP_CamposDesplegables.obtenerRecordTypes';

//Campos reclamación
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import IDFIELD from '@salesforce/schema/Case.Id';
import FECHA_ENVIO_ORGANISMOS_FIELD from '@salesforce/schema/Case.SPV_FechaEnvioOrganismos__c';
import FECHA_RESPUESTA_ORGANISMOS_FIELD from '@salesforce/schema/Case.SPV_FechaPteRespuestaOrganismo__c';
import CASO_NEGOCIADO_FIELD from '@salesforce/schema/Case.SAC_CasoNegociado__c';
import NEGOCIACION_FINALIZADA_FIELD from '@salesforce/schema/Case.SAC_NegociacionFinalizada__c';
import RESULTADO_NEGOCIACION_FIELD from '@salesforce/schema/Case.SAC_ResultadoNegociacion__c';
import NEGOCIACION_FINALIZADA_RECTIFICACION_FIELD from '@salesforce/schema/Case.SPV_NegociacionFinalizadaRectificacion__c';
import RESULTADO_NEGOCIACION_RECTIFICACION_FIELD from '@salesforce/schema/Case.SPV_ResultadoNegociacionRectificacion__c';
import FECHA_COMPLEMENTARIA_ENTIDAD_FIELD from '@salesforce/schema/Case.SPV_FechaComplementariaEntidad__c';
import FECHA_COMPLEMENTARIA_ORGANISMO_FIELD from '@salesforce/schema/Case.SPV_FechaComplementariaOrganismo__c';
import CASO_RECTIFICADO_FIELD from '@salesforce/schema/Case.SPV_Rectificado__c';
import SENTIDO_RESOLUCION_FIELD from '@salesforce/schema/Case.SAC_SentidoResolucion__c';

//Campos Escalado
import TIPO_ALLANAMIENTO_FIELD from '@salesforce/schema/SAC_Interaccion__c.SPV_TipoAllanamiento__c';
import TIPO_RESPUESTA_FIELD from '@salesforce/schema/SAC_Interaccion__c.SPV_TipoRespuesta__c';
import ANALISIS_SEDE_ORGANISMOS_FIELD from '@salesforce/schema/SAC_Interaccion__c.SPV_AnalisisSedeOrganismo__c';

const fields = [IDFIELD, OWNERID_FIELD, FECHA_ENVIO_ORGANISMOS_FIELD, FECHA_RESPUESTA_ORGANISMOS_FIELD, CASO_NEGOCIADO_FIELD, NEGOCIACION_FINALIZADA_FIELD, RESULTADO_NEGOCIACION_FIELD, 
    NEGOCIACION_FINALIZADA_RECTIFICACION_FIELD, RESULTADO_NEGOCIACION_RECTIFICACION_FIELD, FECHA_COMPLEMENTARIA_ENTIDAD_FIELD, FECHA_COMPLEMENTARIA_ORGANISMO_FIELD, CASO_RECTIFICADO_FIELD,
    SENTIDO_RESOLUCION_FIELD
];


export default class Spv_desplegableRectificacion extends LightningElement {

    @api recordId;
    @api objectApiName;
    @track rtReclamacion;
    @track rtEscalado;

    @track fechaEnvioOrganismos;    //Fecha en la que la reclamación pasó al estado "Envío Organismos"
    @track fechaPteRespuestaOrganismos;     //Fecha en la que la reclamación pasó al estado "Pendiente Respuesta Organismos"
    @track caso;
    @track idCaso;
    @track casoRectificado;                     //Se muestra la sección de Rectificación solo si el caso ha sido rectificado
    @track valoresPicklistTipoRespuesta = [];
    @track escaladoRectificacion;
    @track esEscaladoRectificacionAJ = false;       //Se pone a true si el escalado es a Asesoría Jurídica

    @track fechaEnvioEscaladoRectificacionMostrar;           //Fecha Date en la que se envío el escalado
    @track fechaRespuestaEscaladoRectificacionMostrar;       //Fecha Date en la que se respondió al escalado 


    //Controlar desplegable: Rectificación
    @track toggleSeccionRectificacion = "slds-section slds-is-open";
    @track expandirRectificacion = true;


    @wire(getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfoCase;

    @wire(getObjectInfo, {objectApiName: ESCALADO_OBJECT})
    objectInfoEscalado;

        //Se obtienen los RecordType de reclamación y escalados de SPV
        @wire(getRecordTypes)
        getRecordTypesResult(result){
            if(result.data){
                console.log('Datos recibidos ' + JSON.stringify(result.data));
                result.data.forEach(element => {
                    if(element.DeveloperName == 'SPV_Reclamacion'){
                        this.rtReclamacion = element.Id;
                    }else{
                        this.rtEscalado = element.Id;
                    }
                });
            }
        }

        //Obtener el registro (La reclamación)
        @wire(getRecord, { recordId: '$recordId', fields })
        wiredCase({error, data}){
            if(data){
                this.caso = data;
                this.idCaso = data.fields.Id.value;

           
                if(data.fields.SPV_FechaEnvioOrganismos__c.value != null){
                    this.fechaEnvioOrganismos = new Date(data.fields.SPV_FechaEnvioOrganismos__c.value).toLocaleDateString();
                }
                if(data.fields.SPV_FechaPteRespuestaOrganismo__c.value != null){
                    this.fechaPteRespuestaOrganismos = new Date(data.fields.SPV_FechaPteRespuestaOrganismo__c.value).toLocaleDateString();
                }

                //Solo se muestra la sección de Rectificación si el caso se ha rectificado
                if(data.fields.SPV_Rectificado__c.value == true){
                    this.casoRectificado = true;
                }else{
                    this.casoRectificado = false;
                }
    
            }
        }


        //Obtener los escalados
        @wire(getEscaladosReclamacion, { casoId: '$recordId'})
        getEscaladosReclamacion(result){
            if(result.data){
             /*   this.escaladoRectificacion = result.data.escaladoRectificacion;
                
    
                //Info subdesplegable rectificación
                if(Object.keys(this.escaladoRectificacion) != 0){   //Esto comprueba que no esté vacío, es decir, que solo muestra su info si hay escalado de rectificación
                   
                    this.obtenerLabelTipoRespuestaAlegacion();
                    //Comprobar si es de AJ:
                    if(this.escaladoAlegacion.SAC_GrupoColaborador__r.Name == 'Asesoría Jurídica'){
                        this.esEscaladoRectificacionAJ = true;
                    }
    
                    //Formato correcto a las fechas:
                    if(this.escaladoRectificacion.SPV_FechaEscalado__c != null){
                        this.fechaEnvioEscaladoRectificacionMostrar = new Date(this.escaladoRectificacion.SPV_FechaEscalado__c).toLocaleDateString();
                    }
                    if(this.escaladoRectificacion.SAC_FechaRespuesta__c  != null){
                        this.fechaRespuestaEscaladoRectificacionMostrar = new Date(this.escaladoRectificacion.SAC_FechaRespuesta__c ).toLocaleDateString();
                    }
    
                }*/
            }
        } 

        @wire(getPicklistValues, { recordTypeId: '$rtEscalado', fieldApiName: TIPO_RESPUESTA_FIELD })
        wiredPicklistTipoRespuesta({error, data}){
            if(data){
                this.valoresPicklistTipoRespuesta = data.values;
                this.obtenerLabelTipoRespuesta();
            }
        }

        obtenerLabelTipoRespuesta(){
            //Se llamará desde los dos wire, y solo cumplirá el if cuando se hayan ejecutado los dos wire y se tengan tanto los valores de la picklist como el escalado
            if(this.escaladoRectificacion != null && Object.keys(this.escaladoRectificacion) != 0 && this.valoresPicklistTipoRespuesta.length > 0){
                const valor = this.valoresPicklistTipoRespuesta.find(element => element.value == this.escaladoRectificacion.SPV_TipoRespuesta__c);
                this.tipoRespuestaMostrarAlegacion = valor ? valor.label : '';
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
    

}