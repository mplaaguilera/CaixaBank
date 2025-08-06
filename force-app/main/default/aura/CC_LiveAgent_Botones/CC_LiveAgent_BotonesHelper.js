({
	//Displays the given toast message.
	displayToast: function(component, type, message) {
		const toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({type: type, message: message});
		toastEvent.fire();
	},

	saludo: function(idioma) {
		let Time1 = '06:00:10';
		let Time2 = '13:00:00';
		let Time3 = '20:00:00';

		let currentDate = new Date();

		let startTime1 = new Date(currentDate.getTime());
		startTime1.setHours(Time1.split(':')[0]);
		startTime1.setMinutes(Time1.split(':')[1]);
		startTime1.setSeconds(Time1.split(':')[2]);

		let startTime2 = new Date(currentDate.getTime());
		startTime2.setHours(Time2.split(':')[0]);
		startTime2.setMinutes(Time2.split(':')[1]);
		startTime2.setSeconds(Time2.split(':')[2]);

		let startTime3 = new Date(currentDate.getTime());
		startTime3.setHours(Time3.split(':')[0]);
		startTime3.setMinutes(Time3.split(':')[1]);
		startTime3.setSeconds(Time3.split(':')[2]);

		let saludo = '';
		let buenosDias = startTime1 < currentDate && startTime2 > currentDate;
		if (buenosDias) {
			saludo = idioma === 'ca' ? 'Bon dia' : 'Buenos días';
		} else {
			let buenasTardes = startTime2 < currentDate && startTime3 > currentDate;
			if (buenasTardes) {
				saludo = idioma === 'ca' ? 'Bona tarda' : 'Buenas tardes';
			} else {
				saludo = idioma === 'ca' ? 'Bona nit' : 'Buenas noches';
			}
		}
		return saludo;
	},

	franjaDia: function() {

		let franja = '';

		let Time1 = '06:00:10';
		let Time2 = '13:00:00';
		let Time3 = '20:00:00';

		let currentDate = new Date();

		let startTime1 = new Date(currentDate.getTime());
		startTime1.setHours(Time1.split(':')[0]);
		startTime1.setMinutes(Time1.split(':')[1]);
		startTime1.setSeconds(Time1.split(':')[2]);

		let startTime2 = new Date(currentDate.getTime());
		startTime2.setHours(Time2.split(':')[0]);
		startTime2.setMinutes(Time2.split(':')[1]);
		startTime2.setSeconds(Time2.split(':')[2]);

		let startTime3 = new Date(currentDate.getTime());
		startTime3.setHours(Time3.split(':')[0]);
		startTime3.setMinutes(Time3.split(':')[1]);
		startTime3.setSeconds(Time3.split(':')[2]);

		let buenosDias = startTime1 < currentDate && startTime2 > currentDate;
		if (buenosDias === true) {
			franja = 'Mañana';
		} else {
			let buenasTardes = startTime2 < currentDate && startTime3 > currentDate;
			if (buenasTardes === true) {
				franja = 'Tarde';
			} else {
				franja = 'Noche';
			}
		}
		return franja;
	},

	getPicklistEspacios: function(cmp) {
		let aplicacion = cmp.get('v.aplicacion');
		let idioma = cmp.get('v.radioValue');
		let espacio = cmp.get('v.espacio');
		let action = cmp.get('c.recuperarEspacios');
		action.setParams({
			'idioma': idioma,
			'espacio': espacio,
			'aplicacion': aplicacion
		});
		action.setCallback(this, response => {
			if (response.getState() == 'SUCCESS') {
				cmp.set('v.picklistFirstOptionsEspacio', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},

	getPicklistEspacio: function(cmp) {
		let espacio = cmp.get('v.espacio');
		let idioma = cmp.get('v.radioValue');
		let action = cmp.get('c.recuperarEspaciosFilter');
		action.setParams({
			'idioma': idioma,
			'espacio': espacio

		});
		action.setCallback(this, response => {
			if (response.getState() == 'SUCCESS') {
				let options = response.getReturnValue();
				cmp.set('v.picklistFirstOptionsEspacio', options);
			}
		});
		$A.enqueueAction(action);
	},

	getPicklistCategoria: function(cmp) {
		let espacio = cmp.get('v.espacio');
		let categoria = cmp.get('v.categoria');
		let aplicacion = cmp.get('v.aplicacion');		

		let action = cmp.get('c.recuperarCategorias');
		action.setParams({
			'espacio': espacio,
			'categoria': categoria,
			'aplicacion': aplicacion
		});
		action.setCallback(this, response => {
			if (response.getState() == 'SUCCESS') {
				cmp.set('v.picklistFirstOptionsCategoria', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},

	mostrarAlerta: function(cmp, mensaje) {
		let conversationKit = cmp.find('conversationKit');
		let recordId = cmp.get('v.recordId');
		recordId = recordId.substring(0, 15);
		conversationKit.sendMessage({
			recordId: recordId,
			message: {text: mensaje}
		});
	},

	reaundarChat: function(cmp, hlp, start, end) {

		let pausedTimeAux = (end.getTime() - start.getTime()) / 1000;
		let pausedTime = cmp.get('v.pausedTime') + pausedTimeAux;
		let contadorAux = cmp.get('v.retomarContador');
		let mensajesReanudar = cmp.get('v.mensajesRetomar');
		cmp.set('v.pausedTime', pausedTime);
		
		if(cmp.get('v.retomarContador') == 0){
			hlp.mostrarAlerta(cmp, mensajesReanudar[0]);
			contadorAux = contadorAux + 1; 
			cmp.set('v.retomarContador', contadorAux);
		}else if(cmp.get('v.retomarContador') == 1){
			hlp.mostrarAlerta(cmp, mensajesReanudar[1]);
			contadorAux = contadorAux + 1; 
			cmp.set('v.retomarContador', contadorAux);
		}else if(cmp.get('v.retomarContador') == 2){
			hlp.mostrarAlerta(cmp, mensajesReanudar[2]);
			contadorAux = 0; 
			cmp.set('v.retomarContador', contadorAux);
		}
		
		//Cerramos la actividad de pausa
		let action = cmp.get('c.CloseActivityPausa');
		action.setParams({
			recordId: cmp.get('v.taskId'),
			transcriptId: cmp.get('v.recordId'),
			pausaTotal: parseInt(pausedTime, 10),
			tiempoPausado: parseInt(pausedTimeAux, 10),
			motivo: 'Chat Retomado'
		});
		$A.enqueueAction(action);
	},

	buscarBotones: function(cmp) {
		let botones = [];
		if (cmp.find('botonFinalizar') != null) {
			botones.push(cmp.find('botonFinalizar'));
		}
		if (cmp.find('botonNoSoportada') != null) {
			botones.push(cmp.find('botonNoSoportada'));
		}
		if (cmp.find('botonBuscar') != null) {
			botones.push(cmp.find('botonBuscar'));
		}
		if (cmp.find('botonReformular') != null) {
			botones.push(cmp.find('botonReformular'));
		}
		if (cmp.find('botonEscalar') != null) {
			botones.push(cmp.find('botonEscalar'));
		}
		if (cmp.find('botonTransferir') != null) {
			botones.push(cmp.find('botonTransferir'));
		}
		cmp.set('v.botones', botones);
	},

	clearAgentTimer : function( component ) {

        let agentIntervalId = component.get( "v.agentIntervalId" );

        if ( agentIntervalId ) {

            window.clearInterval( agentIntervalId );

        }

    },
//US572043 - Contador tiempo S&G - start
	contadorFunction: function(component, helper){
		helper.clearAgentTimer( component );
		let mostrarContador = component.get( "v.mostrarContador" );
		let liveChatTranscript = component.get('v.liveChatTranscript');
		let livechatName = liveChatTranscript.Name;
		if (mostrarContador === true) {
        let totalMilliseconds = 0;
        let agentIntervalId = window.setInterval(
            $A.getCallback(function() {
                let totalSeconds = parseInt(
                    Math.floor( totalMilliseconds / 1000 ), 10
                );
                let totalMinutes = parseInt(
                    Math.floor( totalSeconds / 60 ), 10
					);
                let totalHours = parseInt(
                    Math.floor( totalMinutes / 60 ), 10
                );
                let seconds = parseInt(
                    totalSeconds % 60 , 10
                );
                let minutes = parseInt(
                    totalMinutes % 60 , 10
                );
                let hours = parseInt(
                    totalHours % 24 , 10
                );
                let agentTimer = String(hours).padStart(2, '0') + " : " + String(minutes).padStart(2, '0') + " : " + String(seconds).padStart(2, '0') ;
                totalMilliseconds += 100;
                component.set( "v.agentTimer", agentTimer );
				if(component.get("v.agentTimer") === '00 : 02 : 30'){
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({ 'title': '¡ATENCIÓN!', 'message': 'El chat ' + livechatName + ' está próximo a finalizar.', 'type': 'warning' });
					toastEvent.fire();
				}
            }), 100
        );
        component.set( "v.agentIntervalId", agentIntervalId );
		}
	},

	checkRecordId : function( component, varRecordId ) {
        let currentRecId = component.get(
            "v.recordId"
        ).substr(0, 15);
        return varRecordId === currentRecId;

    },
	//US572043 - Contador tiempo S&G - end

	//US572038 - Pausa agente: mensaje automático de disculpa cuando el agente retoma la conversación
	recuperarMensajesReanudar: function(cmp){
		 if (!cmp.get('v.mensajesRetomar')) {
			let getMensajesReanudarChat = cmp.get('c.getMensajesReanudarChat');
			getMensajesReanudarChat.setParams({
				areaChat: cmp.get('v.areaChat'),
				idioma: cmp.get('v.radioValue'),
				nombreEmpleado: cmp.get('v.agenteIniciaChat')
			});
			getMensajesReanudarChat.setCallback(this, responseGetMensajesReanudarChat => {
				if (responseGetMensajesReanudarChat.getState() === 'SUCCESS') {
					cmp.set('v.mensajesRetomar', responseGetMensajesReanudarChat.getReturnValue());
				} else {
					console.error(responseGetMensajesReanudarChat.getError());
				}
			});
			$A.enqueueAction(getMensajesReanudarChat);
		 }
	},

	recuperarMensajesPausa: function(cmp){
		return new Promise((resolve, reject) => {		
		//US395380 - Incorporar carrusel de mensajes de espera de pausa de agente
				//Recuperamos los mensajes para usar en caso de ser necesario en el boton de pausa.
			let getMensajesPausaChat = cmp.get('c.getMensajesPausaChat');
			getMensajesPausaChat.setParams({
				areaChat: cmp.get('v.areaChat'),
				idioma: cmp.get('v.radioValue')
			});
			getMensajesPausaChat.setCallback(this, responseGetMensajesPausaChat => {
				if (responseGetMensajesPausaChat.getState() === 'SUCCESS') {
						cmp.set('v.mensaje', responseGetMensajesPausaChat.getReturnValue());						
						resolve();
					} else if (responseGetMensajesPausaChat.getState() === "ERROR") {
						console.error(responseGetMensajesPausaChat.getError());
						reject(responseGetMensajesPausaChat.getError());
					}
			});
			$A.enqueueAction(getMensajesPausaChat);
		});
	}
});