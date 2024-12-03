import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import disponibilidadCitasApex from '@salesforce/apex/CC_WS_Disponibilidad_Cita.obtenerFechasDisponiblidadGestorPool';

export default class Cc_Disponibilidad_Cita extends LightningElement {
    @track opcionesDisponibles = [];
    @api numOficina;
    @api numPer;
    fechaDefault;
    fechaSelecionada;
    mostrarHoras = false;

    connectedCallback() {
        this.fechaDefault = new Date().toISOString().substring(0, 10);
    }

    disponibilidadCitas() {
        window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('activarspinner', {detail: {data: null}})), 400);
        window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('desactivarbotoncita', {detail: {data: null}})), 400);
        if(this.mostrarHoras) {
            this.franjaSeleccionada = this.template.querySelector('.franjaSeleccionada').value;
        }
        this.mostrarHoras = false;
        this.fechaSelecionada = this.template.querySelector('.fechaBuscar').value;
        disponibilidadCitasApex({numOficina: this.numOficina, fecha: this.fechaSelecionada})
        .then(retorno => {
            if(retorno && retorno.length > 0) {
                const uniqueHoras = Array.from(new Set(retorno));
                this.opcionesDisponibles = uniqueHoras.map(hora => ({ label: hora, value: hora }));
                this.mostrarHoras = true;
            } else {
                this.toast('error', 'Error', 'No se han encontrado franjas disponiblbes');
            }
		})
		.catch(error => {
            console.error('Error al cargar horarios:', error);
            this.toast('error', 'Problema al cargar los datos', error.body.message);
		}).finally(() => {
            window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('desactivarspinner', {detail: {data: null}})), 400);
        });
    }

    onChangeFranjaSeleccionada() {
        window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('activarbotoncita', {detail: {data: null}})), 400);
        const eventoFranja = new CustomEvent('franjaseleccionada', {
            detail: this.template.querySelector('.franjaSeleccionada').value
        });
        this.dispatchEvent(eventoFranja);

        const eventofecha = new CustomEvent('fechaseleccionada', {
            detail: this.template.querySelector('.fechaBuscar').value
        });
        this.dispatchEvent(eventofecha);
    }

    toast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({
			variant,
			title,
			message,
			mode: 'dismissable',
			duration: 6000
		}));
	}
}