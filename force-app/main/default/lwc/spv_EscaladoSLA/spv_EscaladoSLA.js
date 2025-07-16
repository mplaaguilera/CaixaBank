import { LightningElement, api, wire, track } from 'lwc';
import recuperarSLAEscalado from '@salesforce/apex/SPV_LCMP_EscaladoSLA.recuperarSLAEscalado';

export default class Spv_EscaladoSLA extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track comenzado;
    @track sobrepasado;
    @track finalizado;
    @track fechaInicio;
    @track fechaFin;
    @track fechaActual;

    @track days;
    @track hours;
    @track minutes;
    @track seconds;
    @track tiempoRestante;

    @wire(recuperarSLAEscalado, {recordId: '$recordId'})
    fechaTiemposMilestone(result) {
        if(result.data){
            this.comenzado = result.data.comenzado;
            this.sobrepasado = result.data.sobrepasado;
            this.finalizado = result.data.finalizado;
            this.fechaInicio = result.data.fechaInicio;
            this.fechaInicio = new Date(result.data.fechaInicio);
            this.fechaFin = new Date(result.data.fechaFin);

            if(!this.comenzado) {
                this._interval = setInterval(() => {  
                    this.fechaActual = new Date();
                    var resta = this.fechaActual.getTime() - this.fechaInicio.getTime();
                    this.tiempoRestante = resta / (1000 * 3600 * 24);
                    this.days = parseInt((this.fechaInicio - this.fechaActual) / (1000 * 60 * 60 * 24), 10);
                    this.hours = parseInt(Math.abs(this.fechaInicio - this.fechaActual) / (1000 * 60 * 60) % 24, 10);
                    this.minutes = parseInt(Math.abs(this.fechaInicio.getTime() - this.fechaActual.getTime()) / (1000 * 60) % 60, 10);
                    this.seconds = parseInt(Math.abs(this.fechaInicio.getTime() - this.fechaActual.getTime()) / (1000) % 60, 10);   

                    let parts = [];
                    if (this.days > 0) {
                        parts.push(`${this.days} días`);
                    }
                    if (this.hours > 0) {
                        parts.push(`${this.hours} h`);
                    }
                    if (this.minutes > 0) {
                        parts.push(`${this.minutes} min`);
                    }
                    if (this.seconds > 0) {
                        parts.push(`${this.seconds} s`);
                    }
                    // Une las partes con una coma
                    this.tiempoRestante = parts.join(', ');
                    this.tiempoRestante = this.tiempoRestante + ' para comenzar';
                }, 200); 
            } else if(this.sobrepasado) {
                this._interval = setInterval(() => {  
                    this.fechaActual = new Date();
                    var resta = this.fechaFin.getTime() - this.fechaActual.getTime();
                    this.tiempoRestante = resta / (1000 * 3600 * 24);
                    this.days = parseInt((this.fechaFin - this.fechaActual) / (1000 * 60 * 60 * 24), 10);
                    this.hours = parseInt(Math.abs(this.fechaFin - this.fechaActual) / (1000 * 60 * 60) % 24, 10);
                    this.minutes = parseInt(Math.abs(this.fechaFin.getTime() - this.fechaActual.getTime()) / (1000 * 60) % 60, 10);
                    this.seconds = parseInt(Math.abs(this.fechaFin.getTime() - this.fechaActual.getTime()) / (1000) % 60, 10);  
                    
                    let parts = [];
                    if (this.days > 0) {
                        parts.push(`${this.days} días`);
                    }
                    if (this.hours > 0) {
                        parts.push(`${this.hours} h`);
                    }
                    if (this.minutes > 0) {
                        parts.push(`${this.minutes} min`);
                    }
                    if (this.seconds > 0) {
                        parts.push(`${this.seconds} s`);
                    }
                    // Une las partes con una coma
                    this.tiempoRestante = parts.join(', ');
                    this.tiempoRestante = this.tiempoRestante + ' sobrepasado';
                }, 200); 
            } else {
                this._interval = setInterval(() => {  
                    this.fechaActual = new Date();
                    var resta = this.fechaActual.getTime() - this.fechaFin.getTime();
                    this.tiempoRestante = resta / (1000 * 3600 * 24);
                    this.days = parseInt((this.fechaFin - this.fechaActual) / (1000 * 60 * 60 * 24), 10);
                    this.hours = parseInt(Math.abs(this.fechaFin - this.fechaActual) / (1000 * 60 * 60) % 24, 10);
                    this.minutes = parseInt(Math.abs(this.fechaFin.getTime() - this.fechaActual.getTime()) / (1000 * 60) % 60, 10);
                    this.seconds = parseInt(Math.abs(this.fechaFin.getTime() - this.fechaActual.getTime()) / (1000) % 60, 10);   

                    let parts = [];
                    if (this.days > 0) {
                        parts.push(`${this.days} días`);
                    }
                    if (this.hours > 0) {
                        parts.push(`${this.hours} h`);
                    }
                    if (this.minutes > 0) {
                        parts.push(`${this.minutes} min`);
                    }
                    if (this.seconds > 0) {
                        parts.push(`${this.seconds} s`);
                    }
                    // Une las partes con una coma
                    this.tiempoRestante = parts.join(', ');
                    this.tiempoRestante = this.tiempoRestante + ' restante';
                }, 200); 
            }  
        }
    }
}