import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import ESCALADO_OBJECT from '@salesforce/schema/SAC_Interaccion__c'; 




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



//LLamadas Apex
import getEscaladosReclamacion from '@salesforce/apex/SPV_LCMP_CamposDesplegables.getEscaladosReclamacion';
import getRecordTypes from '@salesforce/apex/SPV_LCMP_CamposDesplegables.obtenerRecordTypes';

const fields = [IDFIELD, OWNERID_FIELD, FECHA_ENVIO_ORGANISMOS_FIELD, FECHA_RESPUESTA_ORGANISMOS_FIELD, CASO_NEGOCIADO_FIELD, NEGOCIACION_FINALIZADA_FIELD, RESULTADO_NEGOCIACION_FIELD, 
    NEGOCIACION_FINALIZADA_RECTIFICACION_FIELD, RESULTADO_NEGOCIACION_RECTIFICACION_FIELD, FECHA_COMPLEMENTARIA_ENTIDAD_FIELD, FECHA_COMPLEMENTARIA_ORGANISMO_FIELD, CASO_RECTIFICADO_FIELD,
    SENTIDO_RESOLUCION_FIELD
];

export default class Spv_camposDesplegables extends LightningElement {

    @api recordId;
    @api objectApiName;
    @track rtReclamacion;
    @track rtEscalado;

    @track fechaEnvioOrganismos;    //Fecha en la que la reclamación pasó al estado "Envío Organismos"
    @track fechaPteRespuestaOrganismos;     //Fecha en la que la reclamación pasó al estado "Pendiente Respuesta Organismos"
    @track fechaComplementariaEntidad;      //Fecha de apertura de la complementaria entidad
    @track fechaComplementariaOrganismo;      //Fecha de apertura de la complementaria organismo
    @track caso;
    @track idCaso;
    @track casoNegociado;
    @track casoNegociadoEnRectificacion;        //Se muestra cuando hay resultados de la negociación. Se puede crear un campo nuevo que se marque a true cuando se negocie en status rectificado,
    @track casoRectificado;                     //Se muestra la sección de Rectificación solo si el caso ha sido rectificado

    @track valoresPicklistTipoAllanamiento = [];
    @track valoresPicklistTipoRespuesta = [];
    @track valoresPicklistAnalisisSedeOrganismos = [];
    @track valoresPicklisResultadoNegociacion = [];
    @track valoresPicklisResultadoNegociacionRectificacion = [];

    //Controlar desplegable seccion: Decisión Análisis
    @track toggleSeccionDecisionAnalisis = "slds-section slds-is-open";
    @track expandirDecisionAnalisis = true;

    //Controlar subDesplegable: Alegaciones
    @track toggleSeccionAlegaciones = "slds-section slds-is-open";
    @track expandirAlegaciones = true;
    @track escaladoAlegacion;
    @track cargarAlegacion = false;     //Para que no intente mostrar los datos antes de haber recibido los valores
    @track esEscaladoAlegacionAJ = false;       //Se pone a true si el escalado es a Asesoría Jurídica
    @track tipoRespuestaMostrarAlegacion;        //Label del valor picklist a mostrar
    @track fechaEnvioEscaladoAlegacionMostrar;           //Fecha Date en la que se envío el escalado
    @track fechaRespuestaEscaladoAlegacionMostrar;       //Fecha Date en la que se respondió al escalado 

    //Controlar subDesplegable: Allanamientos
    @track toggleSeccionAllanamiento = "slds-section slds-is-open";
    @track expandirAllanamiento = true;
    @track escaladoAllanamiento;
    @track cargarAllanamiento = false;     //Para que no intente mostrar los datos antes de haber recibido los valores
    @track esEscaladoAllanamientoAJ = false;       //Se pone a true si el escalado es a Asesoría Jurídica
    @track importeAbonadoMostrar = '';
    @track importePropuestoMostrar = '';
    @track tipoAllanamientoMostrar;
    @track tipoRespuestaMostrarAllanamiento;       //Label del valor picklist a mostrar
    @track valorAnalisisSedeOrganismoAllanamientoMostrar;  //Label del valor picklist a mostrar
    @track fechaEnvioEscaladoAllanamientoMostrar;           //Fecha Date en la que se envío el escalado
    @track fechaRespuestaEscaladoAllanamientoMostrar;       //Fecha Date en la que se respondió al escalado    

    //Controlar subDesplegable: Desistimientos
    @track cargarDesistimientos = false;     //Para que no intente mostrar los datos antes de haber recibido los valores


    //Controlar desplegable: Complementarias
    @track toggleSeccionComplementarias = "slds-section slds-is-open";
    @track expandirComplementarias = true;
    @track escaladoComplementarias;
    @track cargarComplementarias = false;     //Para que no intente mostrar los datos antes de haber recibido los valores
    @track esEscaladoComplementariasAJ = false;       //Se pone a true si el escalado es a Asesoría Jurídica
    @track mostrarComplementarias = false;

    //Controlar Desplegable: Negociación
    @track toggleSeccionNegociaciones = "slds-section slds-is-open";
    @track expandirNegociaciones = true;
    @track mostrarNegociaciones;


    //Controlar subdesplegable: negociación previa
    @track toggleSeccionNegociacionPrevia = "slds-section slds-is-open";
    @track expandirNegociacionePrevia = true;
    @track valorResultadoNegociacionPreviaMostrar;

    //Controlar subdesplegable: negociación posterior
    @track toggleSeccionNegociacionPosterior = "slds-section slds-is-open";
    @track expandirNegociacionePosterior = true;
    @track valorResultadoNegociacionPosteriorRectificacionMostrar;

    //Controlar desplegable: Resolución organismo
    @track toggleSeccionResolucionOrganismo = "slds-section slds-is-open";
    @track expandirResolucionOrganismo = true;
    @track resolucionDesfavorableEntidad = false;



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




   /* obtenerValoresPicklist(){
        getPicklistValues({recordTypeId: this.rtReclamacion, fieldApiName: RESULTADO_NEGOCIACION_FIELD})
            .then(data=>{
                this.valoresPicklisResultadoNegociacion = data.values;
                this.obtenerLabelResultadoNegociacion();
                console.log('pruebaa ' + this.valoresPicklisResultadoNegociacion);
            });

    }*/



    //Obtención de valores de picklist y su label correspondiente al valor del escalado a mostrar
    @wire(getPicklistValues, { recordTypeId: '$rtEscalado', fieldApiName: TIPO_ALLANAMIENTO_FIELD })
    wiredPicklistTipoAllanamiento({error, data}){
        if(data){
            this.valoresPicklistTipoAllanamiento = data.values;
            this.obtenerLabelTipoAllanamiento();
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtEscalado', fieldApiName: TIPO_RESPUESTA_FIELD })
    wiredPicklistTipoRespuesta({error, data}){
        if(data){
            this.valoresPicklistTipoRespuesta = data.values;
            this.obtenerLabelTipoRespuestaAlegacion();
            this.obtenerLabelTipoRespuestaAllanamiento();
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtEscalado', fieldApiName: ANALISIS_SEDE_ORGANISMOS_FIELD })
    wiredPicklistAnalisisSedeOrganismos({error, data}){
        if(data){
            this.valoresPicklistAnalisisSedeOrganismos = data.values;
            this.obtenerLabelAnalisisSedeOrganismosAllanamiento();
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacion', fieldApiName: RESULTADO_NEGOCIACION_FIELD })
    wiredPicklistResultadoNegociacion({error, data}){
        if(data){
            this.valoresPicklisResultadoNegociacion = data.values;
            this.obtenerLabelResultadoNegociacion();
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacion', fieldApiName: RESULTADO_NEGOCIACION_RECTIFICACION_FIELD })
    wiredPicklistResultadoNegociacioRectificacion({error, data}){
        if(data){
            this.valoresPicklisResultadoNegociacionRectificacion = data.values;
            this.obtenerLabelResultadoNegociacionRectificacion();
        }
    }

    



    //----------------

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCase({error, data}){
        if(data){
            this.caso = data;
            this.idCaso = data.fields.Id.value;
            this.casoNegociado = data.fields.SAC_CasoNegociado__c.value;


            //Si algún campo relacionado con la negociación en rectificación está relleno, es que ha habido negociación en rectificación
            //Si no sirve-> Se puede crear campo en Case y ponerlo a true si se negocia estando en estado de rectificación
            if(data.fields.SPV_NegociacionFinalizadaRectificacion__c.value == true || (data.fields.SPV_ResultadoNegociacionRectificacion__c.value != null && data.fields.SPV_ResultadoNegociacionRectificacion__c.value != '')){
                this.casoNegociadoEnRectificacion = true;
            }
       
            if(data.fields.SPV_FechaEnvioOrganismos__c.value != null){
                this.fechaEnvioOrganismos = new Date(data.fields.SPV_FechaEnvioOrganismos__c.value).toLocaleDateString();
            }
            if(data.fields.SPV_FechaPteRespuestaOrganismo__c.value != null){
                this.fechaPteRespuestaOrganismos = new Date(data.fields.SPV_FechaPteRespuestaOrganismo__c.value).toLocaleDateString();
            }
            if(data.fields.SPV_FechaComplementariaEntidad__c.value != null){
                this.fechaComplementariaEntidad = new Date(data.fields.SPV_FechaComplementariaEntidad__c.value).toLocaleDateString();
            }
            if(data.fields.SPV_FechaComplementariaOrganismo__c.value != null){
                this.fechaComplementariaOrganismo = new Date(data.fields.SPV_FechaComplementariaOrganismo__c.value).toLocaleDateString();
            }

            //Solo se muestra la complementaria si hay info que mostrar
            if(data.fields.SPV_FechaComplementariaEntidad__c.value != null || data.fields.SPV_FechaComplementariaOrganismo__c.value != null){
                this.mostrarComplementarias = true;
            }else{
                this.mostrarComplementarias = false;
            }

            //Solo se muestra la sección de Negociación si alguna de las subsecciones tiene info que mostrar
            if(this.casoNegociado == true || this.casoNegociadoEnRectificacion == true){
                this.mostrarNegociaciones = true;
            }else{
                this.mostrarNegociaciones = false;
            }

            //Solo se muestra la sección de Rectificación si el caso se ha rectificado
            if(data.fields.SPV_Rectificado__c.value == true){
                this.casoRectificado = true;
            }else{
                this.casoRectificado = false;
            }


            //Comprobar si el sentido resolución es desfavorable a la entidad
            if(data.fields.SAC_SentidoResolucion__c.value == 'SAC_003'){
                this.resolucionDesfavorableEntidad = true;
            }else{
                this.resolucionDesfavorableEntidad = false;
            }

            //Obtener valores picklist a mostrar
            if(this.casoNegociado == true){
                this.obtenerLabelResultadoNegociacion();
            }
            if(this.casoNegociadoEnRectificacion == true){
                this.obtenerLabelResultadoNegociacionRectificacion();
            }

        }
    }


    @wire(getEscaladosReclamacion, { casoId: '$recordId'})
    getEscaladosReclamacion(result){
        if(result.data){
            this.escaladoAlegacion = result.data.escaladoAlegacion;
            this.escaladoAllanamiento = result.data.escaladoAllanamiento;

            //Info subdesplegable Alegación
            if(Object.keys(this.escaladoAlegacion) != 0){   //Esto comprueba que no esté vacío, es decir, que solo muestra su info si hay escalado de alegación
                this.cargarAlegacion = true;
                this.obtenerLabelTipoRespuestaAlegacion();
                //Comprobar si es de AJ:
                if(this.escaladoAlegacion.SAC_GrupoColaborador__r.Name == 'Asesoría Jurídica'){
                    this.esEscaladoAlegacionAJ = true;
                }

                //Formato correcto a las fechas:
                if(this.escaladoAlegacion.SPV_FechaEscalado__c != null){
                    this.fechaEnvioEscaladoAlegacionMostrar = new Date(this.escaladoAlegacion.SPV_FechaEscalado__c).toLocaleDateString();
                }
                if(this.escaladoAlegacion.SAC_FechaRespuesta__c  != null){
                    this.fechaRespuestaEscaladoAlegacionMostrar = new Date(this.escaladoAlegacion.SAC_FechaRespuesta__c ).toLocaleDateString();
                }

            }

            //Info subdesplegable Allanamiento
            if(Object.keys(this.escaladoAllanamiento) != 0){   //Esto comprueba que no esté vacío, es decir, que solo muestra su info si hay escalado de allanamiento
                this.cargarAllanamiento = true;
                //Obtener la label para el valor de las picklist de tipo de allanamiento
                this.obtenerLabelTipoRespuestaAllanamiento();
                this.obtenerLabelTipoAllanamiento()
                this.obtenerLabelAnalisisSedeOrganismosAllanamiento();
                //Comprobar si es de AJ:
                if(this.escaladoAllanamiento.SAC_GrupoColaborador__r.Name == 'Asesoría Jurídica'){
                    this.esEscaladoAllanamientoAJ = true;

                }
                //Poner los importes en formato de texto para que se puedan mostrar
                if(this.escaladoAllanamiento.SPV_Importe__c != null){
                    this.importeAbonadoMostrar = this.formatoImportes(this.escaladoAllanamiento.SPV_Importe__c.toString());
                }else{
                    this.importeAbonadoMostrar = '';
                }
                
                //QUEDA EL IMPORTE SOLICITADO
                if(this.escaladoAllanamiento.SAC_CasoEscalado__r.CC_Importe_Reclamado__c != null){
                    this.importePropuestoMostrar = this.formatoImportes(this.escaladoAllanamiento.SAC_CasoEscalado__r.CC_Importe_Reclamado__c.toString());
                }else{
                    this.importePropuestoMostrar = '';
                }

                //Formato correcto a las fechas:
                if(this.escaladoAllanamiento.SPV_FechaEscalado__c != null){
                    this.fechaEnvioEscaladoAllanamientoMostrar = new Date(this.escaladoAllanamiento.SPV_FechaEscalado__c).toLocaleDateString();
                }
                if(this.escaladoAllanamiento.SAC_FechaRespuesta__c  != null){
                    this.fechaRespuestaEscaladoAllanamientoMostrar = new Date(this.escaladoAllanamiento.SAC_FechaRespuesta__c ).toLocaleDateString();
                }

            }


            //Info subdesplegable Desistimiento

        }
    } 

    //Solo se muestra si hay alguno de sus subdesplegables a mostrar
    get mostrarDecisionAnalisis(){
        return (this.cargarAlegacion || this.cargarAllanamiento || this.cargarDesistimientos);
    }

    formatoImportes(importe){
       if(importe.split('.')[1] != null && importe.split('.')[1].length == 1){       //Si solo tiene un decimal, se añade el 0 final:
            return importe.split(".")[0] + '.' + importe.split(".")[1] + '0' + '€';
       }else if(importe.split('.')[1] != null){            
            //Si tiene dos decimales, simplemente se añade € al final:
            return importe.split(".")[0] + '.' + importe.split(".")[1] + '€';
       }else{   //Si no tiene decimales:
        return importe.split(".")[0] + '€';
       }
    }

    obtenerLabelTipoAllanamiento(){
        //Se llamará desde los dos wire, y solo cumplirá el if cuando se hayan ejecutado los dos wire y se tengan tanto los valores de la picklist como el escalado
        if(this.escaladoAllanamiento != null && Object.keys(this.escaladoAllanamiento) != 0 && this.valoresPicklistTipoAllanamiento.length > 0){
            const valor = this.valoresPicklistTipoAllanamiento.find(element => element.value == this.escaladoAllanamiento.SPV_TipoAllanamiento__c);
            this.tipoAllanamientoMostrar = valor ? valor.label : '';
        }
    }

    obtenerLabelTipoRespuestaAlegacion(){
        //Se llamará desde los dos wire, y solo cumplirá el if cuando se hayan ejecutado los dos wire y se tengan tanto los valores de la picklist como el escalado
        if(this.escaladoAlegacion != null && Object.keys(this.escaladoAlegacion) != 0 && this.valoresPicklistTipoRespuesta.length > 0){
            const valor = this.valoresPicklistTipoRespuesta.find(element => element.value == this.escaladoAlegacion.SPV_TipoRespuesta__c);
            this.tipoRespuestaMostrarAlegacion = valor ? valor.label : '';
        }
    }

    obtenerLabelTipoRespuestaAllanamiento(){
        //Se llamará desde los dos wire, y solo cumplirá el if cuando se hayan ejecutado los dos wire y se tengan tanto los valores de la picklist como el escalado
        if(this.escaladoAllanamiento != null && Object.keys(this.escaladoAllanamiento) != 0 && this.valoresPicklistTipoRespuesta.length > 0){
            const valor = this.valoresPicklistTipoRespuesta.find(element => element.value == this.escaladoAllanamiento.SPV_TipoRespuesta__c);
            this.tipoRespuestaMostrarAllanamiento = valor ? valor.label : '';
        }
    }

    obtenerLabelAnalisisSedeOrganismosAllanamiento(){
        //Se llamará desde los dos wire, y solo cumplirá el if cuando se hayan ejecutado los dos wire y se tengan tanto los valores de la picklist como el escalado
        if(this.escaladoAllanamiento != null && Object.keys(this.escaladoAllanamiento) != 0 && this.valoresPicklistAnalisisSedeOrganismos.length > 0){
            if(this.escaladoAllanamiento.SPV_AnalisisSedeOrganismo__c != null){
                const valor = this.valoresPicklistAnalisisSedeOrganismos.find(element => element.value == this.escaladoAllanamiento.SPV_AnalisisSedeOrganismo__c);
                this.valorAnalisisSedeOrganismoAllanamientoMostrar = valor ? valor.label : '';
            }else{
                this.valorAnalisisSedeOrganismoAllanamientoMostrar = '';
            }

        }
    }

    obtenerLabelAnalisisSedeOrganismosDesistimiento(){

    }

    obtenerLabelResultadoNegociacion(){

        if(this.caso != null && Object.keys(this.caso) != 0 && this.valoresPicklisResultadoNegociacion.length > 0){
            if(this.caso.fields.SAC_ResultadoNegociacion__c.value != null){
                const valor = this.valoresPicklisResultadoNegociacion.find(element => element.value == this.caso.fields.SAC_ResultadoNegociacion__c.value);
                this.valorResultadoNegociacionPreviaMostrar = valor ? valor.label : '';
            }else{
                this.valorResultadoNegociacionPreviaMostrar = '';
            }
        }

    }

    obtenerLabelResultadoNegociacionRectificacion(){

        if(this.caso != null && Object.keys(this.caso) != 0 && this.valoresPicklisResultadoNegociacionRectificacion.length > 0){
            if(this.caso.fields.SPV_ResultadoNegociacionRectificacion__c.value != null){
                const valor = this.valoresPicklisResultadoNegociacionRectificacion.find(element => element.value == this.caso.fields.SPV_ResultadoNegociacionRectificacion__c.value);
                this.valorResultadoNegociacionPosteriorRectificacionMostrar = valor ? valor.label : '';
            }else{
                this.valorResultadoNegociacionPosteriorRectificacionMostrar = '';
            }
        }
    }

    //Controlar el abirir y cerrar desplegables
    handleExpandirDecisionAnalisis(){
        if(this.expandirDecisionAnalisis){
            this.expandirDecisionAnalisis = false;
            this.toggleSeccionDecisionAnalisis = "slds-section"; 
        }else{
            this.expandirDecisionAnalisis = true;
            this.toggleSeccionDecisionAnalisis = "slds-section slds-is-open";
        }
    }

    handleExpandirAlegaciones(){
        if(this.expandirAlegaciones){
            this.expandirAlegaciones = false;
            this.toggleSeccionAlegaciones = "slds-section";
        }else{
            this.expandirAlegaciones = true;
            this.toggleSeccionAlegaciones = "slds-section slds-is-open";
        }
    }

    handleExpandirAllanamientos(){
        if(this.expandirAllanamiento){
            this.expandirAllanamiento = false;
            this.toggleSeccionAllanamiento = "slds-section";
        }else{
            this.expandirAllanamiento = true;
            this.toggleSeccionAllanamiento = "slds-section slds-is-open";
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

    handleExpandirNegociaciones(){
        if(this.expandirNegociaciones){
            this.expandirNegociaciones = false;
            this.toggleSeccionNegociaciones = "slds-section"; 
        }else{
            this.expandirNegociaciones = true;
            this.toggleSeccionNegociaciones = "slds-section slds-is-open";
        }
    }

    handleExpandirNegociacionPrevia(){
        if(this.expandirNegociacionePrevia){
            this.expandirNegociacionePrevia = false;
            this.toggleSeccionNegociacionPrevia = "slds-section"; 
        }else{
            this.expandirNegociacionePrevia = true;
            this.toggleSeccionNegociacionPrevia = "slds-section slds-is-open";
        }
    }

    handleExpandirNegociacionPosterior(){
        if(this.expandirNegociacionePosterior){
            this.expandirNegociacionePosterior = false;
            this.toggleSeccionNegociacionPosterior = "slds-section"; 
        }else{
            this.expandirNegociacionePosterior = true;
            this.toggleSeccionNegociacionPosterior = "slds-section slds-is-open";
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


    //Controlar el cambio de valor de los campos de Resolución Organismo
    handleSuccess(event){
        const updatedRecord = event.detail.id;
        const toast = new ShowToastEvent({
            title: 'Exito',
            message: 'Se han actualizado campos de la resolución.',
            variant: 'success'
        });
        this.dispatchEvent(toast);
    }

    handleSubmit(event){
        this.template.querySelectorAll('lightning-record-edit-form').forEach((form) => {form.submit()});
    }

}