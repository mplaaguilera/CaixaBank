import { LightningElement, api, wire } from 'lwc';
import esClienteDigital from '@salesforce/apex/CC_Operativa_Oficina_Controller.esClienteDigital';
import obtenerGestoresBackup from '@salesforce/apex/CC_Operativa_Oficina_Controller.obtenerGestoresBackup';
import obtenerFechasDisponiblidadGestor from '@salesforce/apex/CC_Operativa_Oficina_Controller.obtenerFechasDisponiblidadGestor';
import obtenerHorasDisponiblidadGestor from '@salesforce/apex/CC_Operativa_Oficina_Controller.obtenerHorasDisponiblidadGestor';

export default class Cc_Modal_Cita_Gestor extends LightningElement {

    @api recordId;
    esClienteDigital;
    tieneGestor;
    numeroGestor;
    nombreGestor;
    oficinaGestor;
    ocultarOpcionCitaGestor;
    gestorGenerico = false;
    nombreGestorAsignado;
    gestorAsignadoCoincide = true;
    numeroGestorKO = false;
    mensajeErrorInt;

    opcionesCitaDigital = [{label: 'Llamada telefónica', value: '43'}];
	
	opcionesCita = [
		{label: 'Entrevista', value: '42'},
		{label: 'Llamada telefónica', value: '43'}
	];

    connectedCallback() {
        console.log('VM CALL BACK');
        this.llamadaIntegracionClienteDigital();
        this.cargandoGestor = false;
    }

    async llamadaIntegracionClienteDigital() {
		this.cargandoGestor = true;
		try {
			const resultado = await esClienteDigital({recordId: this.recordId, tipoActividad: ''});
            console.log('VM RESULTADO ' + JSON.stringify(resultado));
			if (resultado.resultado === 'OK') {
				this.esClienteDigital = resultado.clienteDigital;
				if (resultado.empleado1) {
					this.tieneGestor = true;
					this.numeroGestor = resultado.empleado1;
					this.nombreGestor = resultado.gestorClienteName;
					this.oficinaGestor = resultado.oficina1;
					if (this.oficinaGestor === '3223' || this.oficinaGestor === '03223') {
						this.ocultarOpcionCitaGestor = true;
					}
				} else {
					if (resultado.gestorClienteName === 'Sin Gestor/EAP') {
						this.nombreGestor = resultado.gestorClienteName;
						this.gestorGenerico = true;
						this.nombreGestorAsignado = resultado.nombreGestorAsignado;
					}
				}
				if (resultado.gestorAsignadoCoincide === 'false') {
					this.gestorAsignadoCoincide = false;
					this.nombreGestorAsignado = resultado.nombreGestorAsignado;
				}
			} else if (resultado.resultado === 'KO') {
				this.numeroGestor = 'KO';
				this.numeroGestorKO = true;
				this.mensajeErrorInt = resultado.mensajeError;
			}
		} catch (error) {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos desde la integración', error.body.message);
			this.cerrarModal();
		} finally {
            console.log('VM FINALLY');
            console.log('VM cargando '+ this.cargandoGestor);
			this.cargandoGestor = false;
            console.log('VM cargando '+ this.cargandoGestor);
		}
	}

    toast(variant, title, message, messageData) {
		this.dispatchEvent(new ShowToastEvent({
			variant,
			title,
			message,
			mode: messageData ? 'sticky' : 'dismissable',
			duration: messageData ? null : 9000,
			messageData
		}));
	}

    resetDisponibilidadConsultada(event) {
		this.disponibilidadConsultada = false;
		this.ocultarBotonCita = true;
		this.tipoCita = event.detail.value;
	}

    mostrarGestorBackup() {
		if (gestorBackupActivo) {
			this.fechasDisponibilidad = null;
			this.horasDisponibilidad = null;
			this.disponibilidadConsultada = false;
			this.ocultarBotonCita = true;
			obtenerGestoresBackup({recordId: this.recordId, numeroGestor, numeroGestor, tipoCita})
			.then(resultado => {
				this.gestoresBackup = resultado;
				if (!resultado) {
					this.existeBackup = true;
				}
				this.gestorBackupActivoDos = true;
			})
			.catch(error => {
				console.error(error);
				this.toast('error', 'Problema recuperando los datos del gestor backup', error.body.message);
				this.cerrarModal();
			});
		} else {
			this.gestorBackupActivoDos = false;
			this.fechasDisponibilidad = null;
			this.horasDisponibilidad = null;
			this.disponibilidadConsultada = false;
			this.ocultarBotonCita = true;
		}
	}
	
	consultarFechasDisponibilidadGestor() {
		var codigoEvento;
		if(this.tipoCita == 'LLamada telefónica') {
			codigoEvento = '43';
		} else {
			codigoEvento = '42';
		}
		obtenerFechasDisponiblidadGestor({recordId: this.recordId, employeeId: this.numeroGestor, gestorElegidoId: this.numeroGestor, eventType: codigoEvento})
		.then(resultado => {
			this.disponibilidadConsultada = true;
			this.ocultarBotonCita = false;
			this.fechasDisponibilidad = resultado;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de disponibilidad de fechas del gestor', error.body.message);
			this.cerrarModal();
		});
	}
	
	consultarHorasDisponibilidadGestor() {
		var codigoEvento;
		if(this.tipoCita == 'LLamada telefónica') {
			codigoEvento = '43';
		} else {
			codigoEvento = '42';
		}
		let fechasDisponibilidad = this.template.querySelector('lightning-combobox').value;
		obtenerHorasDisponiblidadGestor({recordId: this.recordId, employeeId: this.numeroGestor, gestorElegidoId: this.numeroGestor, eventType: codigoEvento, fechaElegida: fechasDisponibilidad})
		.then(resultado => {
			this.horasDisponibilidad = resultado;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de disponibilidad de horas del gestor', error.body.message);
			this.cerrarModal();
		});
		this.gestorElegido =  this.numeroGestor;
		this.nombreGestorElegido = this.nombreGestor;
	}
	
	guardarHorasDisponibilidad(event) {
		this.horaCitaSelecionada = event.detail.value;
	}
	
	consultarFechasDisponibilidadBackup() {
		obtenerFechasDisponiblidadGestor({recordId, numeroGestor, numeroGestor, tipoCita})
		.then(resultado => {
			this.disponibilidadConsultada = true;
			this.ocultarBotonCita = false;
			this.fechasDisponibilidad = resultado;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de disponiblidad de fechas del gestor backup', error.body.message);
			this.cerrarModal();
		});
	}
	
	consultarHorasDisponibilidadBackup() {
		let fechasDisponibilidad = this.template.querySelector('lightning-combobox').value;
		obtenerHorasDisponiblidadGestor({recordId, numeroGestor, numeroGestor, tipoCita, fechasDisponibilidad})
		.then(resultado => {
			this.horasDisponibilidad = resultado;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de disponiblidad de horas del gestor backup', error.body.message);
			this.cerrarModal();
		});		
		component.set('v.gestorElegido', component.find('gestoresBackup').get('v.value'));
		let gestorSeleccionado = component.find('gestoresBackup').get('v.value');
		let labelGestoreleccionado = component.get('v.gestoresBackup').find(gestor => gestor.value === gestorSeleccionado).label;
		component.set('v.nombreGestorElegido', labelGestoreleccionado);
		
	}
	
	lookupDeseleccionar() {
		if(this.comentariosTarea) {
			const comentariosTareaReplace = this.comentariosTarea.replace(this.lookupOficinaResultadoSeleccionado.Name + '.', '[oficina destino]');
			if(comentariosTareaReplace.includes(this.lookupOficinaResultadoSeleccionado.Name)) {
				let t = 0;
				const regex = new RegExp(this.lookupOficinaResultadoSeleccionado.Name, 'g');
				this.comentariosTarea = this.comentariosTarea.replace(regex, match => ++t === 2 ? '[oficina destino]' : match);
			} else {
				this.comentariosTarea = comentariosTareaReplace;
			}
		}
		this.lookupOficinaResultadoSeleccionado = null;
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.lookupOficinaAbrir();
			this.template.querySelector('.lookupOficinaInput').focus();
		}, 200);
	}
}