import { LightningElement, track, api, wire } from 'lwc';
import validacionRedaccion from '@salesforce/apex/SAC_LCMP_RedaccionReclamacion.validacionRedaccion';
import getBodyRedaccion from '@salesforce/apex/SAC_LCMP_RedaccionReclamacion.getBodyRedaccion';
import guardarRedaccion from '@salesforce/apex/SAC_LCMP_RedaccionReclamacion.guardarRedaccion';
import finalizarRedaccion from '@salesforce/apex/SAC_LCMP_RedaccionReclamacion.finalizarRedaccion';
import gestionTareas from '@salesforce/apex/SAC_LCMP_RedaccionReclamacion.gestionTareas';
import getPickListValuesIntoList from '@salesforce/apex/SAC_LCMP_RedaccionReclamacion.getPickListValuesIntoList';
import guardarSentidoResolucion from '@salesforce/apex/SAC_LCMP_RedaccionReclamacion.guardarSentidoResolucion';
import validacionesEscalados from '@salesforce/apex/SAC_Interaccion.validacionesEscalados';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getRecord} from 'lightning/uiRecordApi';

const myFields=[
    'Case.SAC_SentidoResolucion__c',
    'Case.SAC_MotivoSentidoResolucion__c',
    'Case.SAC_Redaccion__c',
    'Case.OS_Fecha_Resolucion__c'
];

export default class Sac_RedaccionReclamacion extends LightningElement {

    @track isLoading;
    @api recordId;

    @track argRes;
    @track senRes;
    @track myVal;
    @track modal = false;
    @track options = [];

    @track aplicaTareas;
    @track fechaRes;

    @track necesitaEscalado = false;

    caso;

    @wire(getRecord, { recordId: '$recordId', fields: myFields })
    actualCase({data, error}){
        if(data){
            this.caso = data;
            this.myVal = this.caso.fields.SAC_Redaccion__c.value;
            this.fechaRes = this.caso.fields.OS_Fecha_Resolucion__c.value;
            this.senRes = this.caso.fields.SAC_SentidoResolucion__c.value;
            this.argRes = this.caso.fields.SAC_MotivoSentidoResolucion__c.value;
            getPickListValuesIntoList().then(result => {
                let titulos = result;
                for (var miTitulo in titulos) {
                    let titulo = titulos[miTitulo];
                    this.options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
                }            
                this.options = JSON.parse(JSON.stringify(this.options));
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error.',
                    message: 'Fallo al obtener el Sentido de la Resolución.',
                    variant: 'error'
                }),);
    
            })
        }
    }

    handleClickValicion(){
        this.isLoading = true;
        validacionRedaccion({id: this.recordId}).then(result => {
            this.isLoading = false;
            if(result == false){
                const evt = new ShowToastEvent({
                    title: 'Error al importar redacciones',
                    message: 'No todas las pretensiones están listas para la redacción final.',
                    variant: 'error'
                });
                
                this.dispatchEvent(evt);
            }
            else{
                getBodyRedaccion({id: this.recordId}).then(result => {
                    let body = result;
                    this.myVal = body;
                    const evt = new ShowToastEvent({
                        title: 'Éxito al importar redacciones',
                        message: 'El contenido de la redacción de cada pretensión ha sido cargado.',
                        variant: 'success'
                    });
                    
                    this.dispatchEvent(evt);

                    const editor = this.template.querySelector('lightning-input-rich-text');
                    editor.focus();

                })
                    .catch(error => {
                        this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Fallo al obtener plantillas',
                            message: error.body.message,
                            variant: 'error'
                        }),);
        
                    })
            }

        })
            .catch(error => {
                this.isLoading = false;
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al guardar la redacción',
                    message: error.body.message,
                    variant: 'error'
                }),);

            })
    }

    setModal(){
        this.isLoading = true;
        //validacion desde apex
        if(this.modal == false ){
            if(this.senRes != null && this.myVal != null){
                    validacionesEscalados({caseId: this.recordId}).then(result => {
                        if(result == true){
                            this.necesitaEscalado = true;
                            this.modal = !this.modal; 
                        }
                        else{
                            this.necesitaEscalado = false;

                            gestionTareas({id: this.recordId}).then(result => {
                                if(result == true){
                                    this.aplicaTareas = true;
                                }
                                else{
                                    this.aplicaTareas = false;
                                }
                                this.modal = !this.modal; 
                            }).catch(error => {
                                    this.isLoading = false;
                                    this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Fallo al comprobar las tareas de la reclamación.',
                                        message: error.body.message,
                                        variant: 'error'
                                    }),);
                    
                                })

                        }
            
                    }).catch(error => {
                            this.isLoading = false;
                            this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Fallo al comprobar las validaciones de escalado',
                                message: error.body.message,
                                variant: 'error'
                            }),);
            
                        })                    
                    this.isLoading = false;
            }
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al resolver la Redacción',
                        message: 'No están cumplimentados todos los campos.',
                        variant: 'error'
                }),);
                
                this.isLoading = false;
            }
        }
        else{
            this.modal = !this.modal;
            this.isLoading = false;
        }
    }

    escritura(event){
        this.myVal = event.target.value;
    }

    argumentoRes(event){
        this.argRes = event.target.value;
    }

    sentidoRes(event){
        this.senRes = event.target.value;
        //llamada a apex con el nuevo sentido res y hacer update
    }

    guardarRed(){
        this.isLoading = true;
        guardarRedaccion({id: this.recordId, texto: this.myVal}).then(result => {

            const evt = new ShowToastEvent({
                title: 'Éxito al guardar la redacción de la reclamación.',
                message: 'El contenido ha sido almacenado.',
                variant: 'success'
            });
            
            this.isLoading = false;
            this.dispatchEvent(evt);


        }).catch(error => {
                this.isLoading = false;
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al guardar la redacción',
                    message: error.body.message,
                    variant: 'error'
                }),);

            })
    }

    submitModal(){
        this.modal = !this.modal; 
        this.isLoading = true;
        finalizarRedaccion({id: this.recordId}).then(result => {
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Redacción resuelta.',
                    message: 'Se ha enviado un email al cliente con la redacción, cerrado el SLA y notificado al equipo responsable.',
                    variant: 'success'
                }),);

            this.fechaRes = result;
            this.isLoading = false;
            
        }).catch(error => {
                this.isLoading = false;
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al enviar la redacción',
                    message: error.body.message,
                    variant: 'error'
                }),);

            })
    }

    guardarResolucion(){
        this.isLoading = true;
        guardarSentidoResolucion({id: this.recordId, sentido: this.senRes, argumento: this.argRes}).then(result => {
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sentido de resolución guardado.',
                    message: 'Se ha guardado el contenido del sentido de resolutivo.',
                    variant: 'success'
                }),);
            this.isLoading = false;
            }).catch(error => {
                this.isLoading = false;
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al guardar el sentido resolución',
                    message: error.body.message,
                    variant: 'error'
                }),);
                this.isLoading = false;
            })
    }
}