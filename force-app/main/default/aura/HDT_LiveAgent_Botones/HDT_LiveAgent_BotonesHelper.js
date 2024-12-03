({
	//Displays the given toast message.
	displayToast: function(component, type, message) {
		const toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({type: type, message: message});
		toastEvent.fire();
	},

	saludo: function(idioma) {
		let currentDate = new Date();

		let startTime1 = new Date(currentDate.getTime());
		let Time1 = '06:00:10';
		startTime1.setHours(Time1.split(':')[0]);
		startTime1.setMinutes(Time1.split(':')[1]);
		startTime1.setSeconds(Time1.split(':')[2]);

		let startTime2 = new Date(currentDate.getTime());
		let Time2 = '13:00:00';
		startTime2.setHours(Time2.split(':')[0]);
		startTime2.setMinutes(Time2.split(':')[1]);
		startTime2.setSeconds(Time2.split(':')[2]);

		let startTime3 = new Date(currentDate.getTime());
		let Time3 = '20:00:00';
		startTime3.setHours(Time3.split(':')[0]);
		startTime3.setMinutes(Time3.split(':')[1]);
		startTime3.setSeconds(Time3.split(':')[2]);

		let mensaje;

		if (startTime1 < currentDate && startTime2 > currentDate) {
			mensaje = idioma === 'ca' ? 'Bon dia' : 'Buenos días';
		} else if (startTime2 < currentDate && startTime3 > currentDate) {
			mensaje = idioma === 'ca' ? 'Bona tarda' : 'Buenas tardes';
		} else {
			mensaje = idioma === 'ca' ? 'Bona nit' : 'Buenas noches';
		}
		return mensaje;
	},

	franjaDia: function() {
		let currentDate = new Date();

		let startTime1 = new Date(currentDate.getTime());
		let Time1 = '06:00:10';
		startTime1.setHours(Time1.split(':')[0]);
		startTime1.setMinutes(Time1.split(':')[1]);
		startTime1.setSeconds(Time1.split(':')[2]);

		let startTime2 = new Date(currentDate.getTime());
		let Time2 = '13:00:00';
		startTime2.setHours(Time2.split(':')[0]);
		startTime2.setMinutes(Time2.split(':')[1]);
		startTime2.setSeconds(Time2.split(':')[2]);

		let startTime3 = new Date(currentDate.getTime());
		let Time3 = '20:00:00';
		startTime3.setHours(Time3.split(':')[0]);
		startTime3.setMinutes(Time3.split(':')[1]);
		startTime3.setSeconds(Time3.split(':')[2]);

		let mensaje2;

		if (startTime1 < currentDate && startTime2 > currentDate) {
			mensaje2 =  'Mañana';
		} else if (startTime2 < currentDate && startTime3 > currentDate) {
			mensaje2 = 'Tarde';
		} else {
			mensaje2 =  'Noche';
		}
		return mensaje2;
	},

	getPicklistEspacios: function(component) {
		let recuperarEspacios = component.get('c.recuperarEspacios');
		recuperarEspacios.setParams({
			idioma: component.get('v.radioValue'),
			espacio: component.get('v.espacio'),
			aplicacion: component.get('v.aplicacion')
		});
		recuperarEspacios.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.picklistFirstOptionsEspacio', response.getReturnValue());
			}
		});
		$A.enqueueAction(recuperarEspacios);
	},

	getPicklistEspacio: function(component) {
		let recuperarEspaciosFilter = component.get('c.recuperarEspaciosFilter');
		recuperarEspaciosFilter.setParams({
			idioma: component.get('v.radioValue'),
			espacio: component.get('v.espacio')
		});
		recuperarEspaciosFilter.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.picklistFirstOptionsEspacio', response.getReturnValue());
			}
		});
		$A.enqueueAction(recuperarEspaciosFilter);
	},

	getPicklistCategoria: function(component) {
		let recuperarCategorias = component.get('c.recuperarCategorias');
		recuperarCategorias.setParams({
			espacio: component.get('v.espacio'),
			categoria: component.get('v.categoria'),
			aplicacion: component.get('v.aplicacion')
		});
		recuperarCategorias.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.picklistFirstOptionsCategoria', response.getReturnValue());
			}
		});
		$A.enqueueAction(recuperarCategorias);
	},

	mostrarAlerta: function(cmp, mensaje) {
		/*component.find('conversationKit').sendMessage({
			recordId: component.get('v.recordId').recordId.substring(0, 15),
			message: {text: mensaje}
		});*/
        
        let conversationKit = cmp.find('conversationKit');
		let recordId = cmp.get('v.recordId');
		recordId = recordId.substring(0, 15);
		conversationKit.sendMessage({
			recordId: recordId,
			message: {text: mensaje}
		});
		console.log(mensaje);
	},

	reaundarChat: function(component, start, end) {
		//disabledButtons(botones,true);
		//Calculamos el tiempo que el chat a estado pausado y lo sumamos al total
		let pausedTimeAux = (end.getTime() - start.getTime()) / 1000;
		let pausedTime = component.get('v.pausedTime') + pausedTimeAux;
		component.set('v.pausedTime', pausedTime);

		//Cerramos la actividad de pausa
		let closeActivityPausa = component.get('c.CloseActivityPausa');
		closeActivityPausa.setParams({
			recordId: component.get('v.taskId'),
			transcriptId: component.get('v.recordId'),
			pausaTotal: parseInt(pausedTime, 10),
			tiempoPausado: parseInt(pausedTimeAux, 10),
			motivo: 'Chat Retomado'
		});
		$A.enqueueAction(closeActivityPausa);
	},

	buscarBotones: function(component) {
		let botones = [];
		if (component.find('botonFinalizar')) {
			botones.push(component.find('botonFinalizar'));
		}
		if (component.find('botonNoSoportada')) {
			botones.push(component.find('botonNoSoportada'));
		}
		if (component.find('botonBuscar')) {
			botones.push(component.find('botonBuscar'));
		}
		if (component.find('botonReformular')) {
			botones.push(component.find('botonReformular'));
		}
		if (component.find('botonEscalar')) {
			botones.push(component.find('botonEscalar'));
		}
		if (component.find('botonTransferir')) {
			botones.push(component.find('botonTransferir'));
		}
		component.set('v.botones', botones);
	}
});