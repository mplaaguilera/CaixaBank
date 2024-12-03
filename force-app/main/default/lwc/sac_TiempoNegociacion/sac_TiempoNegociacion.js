import { LightningElement, api, wire, track } from 'lwc';
import recuperarFechaNegociacion from '@salesforce/apex/SAC_LCMP_UpdateStatus.recuperarFechaNegociacion';
import recuperarSLAnegocio from '@salesforce/apex/SAC_LCMP_UpdateStatus.recuperarSLAnegocio';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Sac_TiempoNegociacion extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track tiempoNegociacion;
    @track negociacion;
    // @track fechaNegociacion;
    @track fechaFinal;
    @track tiempoRestante;
    @track fechaActual;
    @track fechaAhora;
    @track days;
    @track hours;
    @track minutes;
    @track seconds;
    @track porcentajeCompletado;


    @wire(recuperarFechaNegociacion, {recordId: '$recordId'})
    fechaTiempoNegociacion(result) {
        
        if(result.data){
            this.negociacion = result.data.fechaNegociacion;
            this.tiempoNegociacion = result.data.slaNegocio;
            
            //this.fechaNegociacion = new Date(this.negociacion);
            this.fechaFin = new Date(this.negociacion);
            this.fechaFin.setDate(this.fechaFin.getDate() + this.tiempoNegociacion);
            // Se indica la fecha de fin como las 23:59 del día de vencimiento por el cálculo de SLA con días completos US961684
            this.fechaFin.setHours(23, 59, 59, 0);
            //this.fechaAhora = new Date();

            //this.porcentajeCompletado = ((this.fechaAhora.getTime() - this.fechaNegociacion.getTime()) / (this.fechaFin.getTime() - this.fechaNegociacion.getTime())) * 100;

            this._interval = setInterval(() => {  

                this.fechaActual = new Date();
                var resta = this.fechaActual.getTime() - this.fechaFin.getTime();
                this.tiempoRestante = resta / (1000 * 3600 * 24);

                this.days = parseInt((this.fechaFin - this.fechaActual) / (1000 * 60 * 60 * 24), 10);
                this.hours = parseInt(Math.abs(this.fechaFin - this.fechaActual) / (1000 * 60 * 60) % 24, 10);
                this.minutes = parseInt(Math.abs(this.fechaFin.getTime() - this.fechaActual.getTime()) / (1000 * 60) % 60, 10);
                this.seconds = parseInt(Math.abs(this.fechaFin.getTime() - this.fechaActual.getTime()) / (1000) % 60, 10); 
                
            }, 200);   
        }
    }
}