/*eslint-disable @lwc/lwc/no-async-await*/
import registrarLlamadaEntranteApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.registrarLlamadaEntrante';
import registrarLlamadaSalienteApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.registrarLlamadaSaliente';
import registrarConsultaApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.registrarConsulta';
import registrarblindTransferApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.registrarblindTransfer';
import finalizarLlamadaApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.finalizarLlamada';
import registrarACWApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.registrarACW';
import finalizarConsultaApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.finalizarConsulta';
import finalizarConsultaExternaApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.finalizarConsultaExterna';
import iniciarTransferenciaCiegaApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.iniciarTransferenciaCiega';
import completarConsultaApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.completarConsulta';

import purecloudConversationApiApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.purecloudConversationApi';
import atributosLlamadaInicialApex from '@salesforce/apex/FRA_Genesys_Cloud_Eventos_Controller.atributosLlamadaInicial';

export const CATEGORIES_RELEVANTES = [
	'connect', 'consultTransfer', 'blindTransfer', 'disconnect', 'completeConsultTransfer', 'ConsultCall', 'CompleteConsultCall','acw'
];

export const METODOS_APEX = [
	{nombre: 'registrarLlamadaEntrante', label: 'Llamada entrante', metodoApex: registrarLlamadaEntranteApex, abrirTab: 'llamada'},
	{nombre: 'registrarLlamadaSaliente', label: 'Llamada saliente', metodoApex: registrarLlamadaSalienteApex},
	{nombre: 'registrarConsulta', label: 'Consulta', metodoApex: registrarConsultaApex, abrirTab: 'caso'},
	{nombre: 'registrarblindTransfer', label: 'blindTransfer', metodoApex: registrarblindTransferApex, abrirTab: 'caso'},
	{nombre: 'registrarACW', label: 'ACW', metodoApex: registrarACWApex},
	{nombre: 'finalizarLlamada', label: 'Finalizar llamada', metodoApex: finalizarLlamadaApex},
	{nombre: 'finalizarConsulta', label: 'Finalizar consulta', metodoApex: finalizarConsultaApex},
	{nombre: 'finalizarConsultaExterna', label: 'Finalizar cons. externa', metodoApex: finalizarConsultaExternaApex},
	{nombre: 'iniciarTransferenciaCiega', label: 'Inciar Transferencia Ciega', metodoApex: iniciarTransferenciaCiegaApex},
	{nombre: 'completarConsulta', label: 'Completar consulta', metodoApex: completarConsultaApex}
];

export const METODOS_APEX_TRIGGERS = {
	registrarLlamadaEntrante: {
		category: 'connect',
		direction: 'Inbound'
	},
	registrarLlamadaSaliente: {
		category: 'connect',
		direction: 'Outbound'
	},
	iniciarConsulta: {
		category: 'consultTransfer'
	},
	blindTransfer: {
		category: 'blindTransfer'
	},
	registrarblindTransfer: null,
	registrarConsulta: null,
	finalizarLlamada: {
		category: 'disconnect'
	},
	registrarACW: {
		category: 'acw'
	},
	finalizarConsulta: null,
	finalizarConsultaExterna: null,
	iniciarTransferenciaCiega: null,
	completarConsulta: {
		category: 'completeConsultTransfer'
	}

	/*
	PENDENTS
		category: 'completeConsultTransfer' //Pdte.ndiente sabio aclarar como diferenciar del finalizarconsulta
		category: 'completeConsultCall'
		category: 'blindTransfer'
		category: 'blindTransfer'
		category: 'ConsultCall'

	enviarInteraccion: {} <-- NO APLICA EN EL NUEVO WIDGET
	*/
};

//eslint-disable-next-line complexity
export async function conversionApexInputs(nombreMetodoApex, message, interactionId, scope) {
	if (nombreMetodoApex === 'registrarLlamadaEntrante') {
		return ({
			llamadaJson: JSON.stringify({
				usuario: '', //!!!!
				extension: '', //!!!!
				connId: message.data.id ?? '',
				ani: message.data.ani ?? '',
				dnis: message.data.calledNumber ?? '',
				servicio: message.data.queueName ?? '',
				// asunto: message.data.attributes['Participant.asunto'] ?? '',
				// numPerso: message.data.attributes['Participant.numPerso'] ?? '',
				// idioma: message.data.attributes['Participant.idioma'] ?? '',
				// datos: message.data.attributes['Participant.datos'] ?? '',
				// connIdCognitivo: message.data.attributes['Participant.connIdCognitivo'] ?? '',
				 casoId: message.data.attributes['Participant.casoIdFRA'] ?? '',
				 salesforceParentId: message.data.attributes['Participant.salesforceParentId'] ?? '',
				 llamadaId: message.data.attributes['Participant.llamadaIdFRA'] ?? '',
				// //eslint-disable-next-line camelcase
				// CC_Canal_del_Empleado__c: message.data.attributes['Participant.CC_Canal_del_Empleado__c'] ?? '',
				urlGrabacion: message.data.attributes['Interaction.Url'] ?? ''
			})
		});

	} else if (nombreMetodoApex === 'registrarLlamadaSaliente') {
		return ({
			llamadaJson: JSON.stringify({
				usuario: '' ?? '', //!!!!
				extension: '' ?? '', //!!!!
				connId: message.data.id ?? '',
				ani: message.data.ani ?? '',
				dnis: message.data.calledNumber ?? '',
				servicio: message.data.queueName ?? '',
				//servicio: message.data.attributes['Participant.servicio'] ?? '',
				//asunto: message.data.attributes['Participant.asunto'] ?? '',
				//numPerso: message.data.attributes['Participant.numPerso'] ?? '',
				//idioma: message.data.attributes['Participant.idioma'] ?? '',
				//datos: message.data.attributes['Participant.datos'] ?? '',
				//connIdCognitivo: message.data.attributes['Participant.connIdCognitivo'] ?? '',

				//casoId: null
				casoId: await purecloudConversationApi(interactionId, 'casoIdFRA', scope)

				//salesforceParentId: message.data.attributes['Participant.salesforceParentId'] ?? '',
				//llamadaId: message.data.attributes['Participant.llamadaIdFRA'] ?? '',
				//eslint-disable-next-line camelcase
				//CC_Canal_del_Empleado__c: message.data.attributes['Participant.CC_Canal_del_Empleado__c'] ?? '',
			})
		});

	} else if (nombreMetodoApex === 'finalizarLlamada') {
		if (message.data) {
			return ({
				llamadaJson: JSON.stringify({
					connId: message.data.id ?? '',
					llamadaId: message.data.attributes['Participant.llamadaIdFRA'] ?? ''
				}),
				tipoCierre: 'Llamada finalizada'
			});
		} else {
			let atributos = await atributosLlamadaInicial(interactionId, scope);
			if (atributos) {
				return ({
					llamadaJson: JSON.stringify({
						usuario: atributos.usuario,
						extension: atributos.extension,
						connId: atributos.connId,
						ani: atributos.ani ?? '',
						dnis: atributos.dnis,
						servicio: message.data.attributes['Participant.servicio'] ?? '',
						asunto: message.data.attributes['Participant.asunto'] ?? '',
						numPerso: message.data.attributes['Participant.numPerso'] ?? '',
						idioma: atributos.idioma,
						datos: message.data.attributes['Participant.datos'] ?? '',
						connIdCognitivo: message.data.attributes['Participant.connIdCognitivo'] ?? '',
						casoId: message.data.attributes['Participant.casoIdFRA'] ?? '',
						salesforceParentId: message.data.attributes['Participant.salesforceParentId'] ?? '',
						llamadaId: message.data.attributes['Participant.llamadaIdFRA'] ?? '',
						//eslint-disable-next-line camelcase
						CC_Canal_del_Empleado__c: message.data.attributes['Participant.CC_Canal_del_Empleado__c'] ?? '',

						/*
						usuario: atributos.usuario,
						extension: atributos.extension,
						servicio: atributos.servicio,
						connId: atributos.connId,
						ani: atributos.ani ?? '',
						dnis: atributos.dnis,
						idioma: atributos.idioma,
						casoId: atributos.casoId,
						salesforceParentId: atributos.salesforceParentId
						*/
					})
				});
			} else {
				return null;
			}
		}
	} else if (nombreMetodoApex === 'registrarACW') {
		if (message.data) {
			return ({
				llamadaJson: JSON.stringify({
					connId: message.data.id ?? '',
					llamadaId: message.data.attributes['Participant.llamadaIdFRA'] ?? ''
				})
			});
		} else {
			let atributos = await atributosLlamadaInicial(interactionId, scope);
			if (atributos) {
				return ({
					llamadaJson: JSON.stringify({
						usuario: atributos.usuario
					})
				});
			} else {
				return null;
			}
		}
	} else if (nombreMetodoApex === 'registrarConsulta') {
		let atributos = await atributosLlamadaInicial(interactionId, scope);
		if (atributos) {
			return ({
				consultaJson: JSON.stringify({
					usuario: atributos.usuario,
					extension: atributos.extension,
					servicio: message.data.queueName ?? '',
					connId: atributos.connId,
					ani: atributos.ani ?? '',
					dnis: atributos.dnis,
					idioma: atributos.idioma,
					casoId: atributos.casoId,
					//salesforceParentId: atributos.salesforceParentId
					salesforceParentId: atributos.llamadaId
				})
			});

		} else {
			return null;
		}
	} else if (nombreMetodoApex === 'finalizarConsultaExterna') {
		let atributos = await atributosLlamadaInicial(interactionId, scope);
		if (atributos) {
			return ({
				consultaJson: JSON.stringify({
					usuario: atributos.usuario,
					extension: atributos.extension,
					servicio: message.data.queueName ?? '',
					connId: atributos.connId,
					ani: atributos.ani ?? '',
					dnis: atributos.dnis,
					idioma: atributos.idioma,
					casoId: atributos.casoId,
					//salesforceParentId: atributos.salesforceParentId
					salesforceParentId: atributos.llamadaId
				})
			});

		} else {
			return null;
		}
	} else if (nombreMetodoApex === 'iniciarTransferenciaCiega') {
		let atributos = await atributosLlamadaInicial(interactionId, scope);
		if (atributos) {
			return ({
				consultaJson: JSON.stringify({
					usuario: atributos.usuario,
					extension: atributos.extension,
					servicio: message.data.queueName ?? '',
					connId: atributos.connId,
					ani: atributos.ani ?? '',
					dnis: atributos.dnis,
					idioma: atributos.idioma,
					casoId: atributos.casoId,
					//salesforceParentId: atributos.salesforceParentId
					salesforceParentId: atributos.llamadaId
				})
			});

		} else {
			return null;
		}

	} else if (nombreMetodoApex === 'registrarblindTransfer') {
		let atributos = await atributosLlamadaInicial(interactionId, scope);
		if (atributos) {
			return ({
				consultaJson: JSON.stringify({
					usuario: atributos.usuario,
					extension: atributos.extension,
					servicio: message.data.queueName ?? '',
					connId: atributos.connId,
					ani: atributos.ani ?? '',
					dnis: atributos.dnis,
					idioma: atributos.idioma,
					casoId: atributos.casoId,
					//salesforceParentId: atributos.salesforceParentId
					salesforceParentId: atributos.llamadaId
				})
			});

		} else {
			return null;
		}
	} else if (nombreMetodoApex === 'finalizarConsulta') {
		let atributos = await atributosLlamadaInicial(interactionId, scope);
		if (atributos) {
			return ({
				consultaJson: JSON.stringify({
					usuario: atributos.usuario,
					extension: atributos.extension,
					//llamadaId: atributos.llamadaId,
					connId: atributos.connId,
					ani: atributos.ani ?? '',
					dnis: atributos.dnis,
					servicio: atributos.servicio,
					idioma: atributos.idioma,
					//salesforceParentId: atributos.salesforceParentId,
					casoId: atributos.casoId
				}),
				tipoCierre: 'Consulta cancelada' //(API Name: 'Consulta atendida'!!)
				// tipoCierre: 'Consulta completada'
			});
		} else {
			return null;
		}

	} else if (nombreMetodoApex === 'completarConsulta') {
		const interactioneventID=message.data ?? '';
		const agenteDestinoId = await purecloudConversationApi(interactioneventID, 'agenteDestinoId', scope);
		//const agenteDestinoId = '0053Y00000ALRTSQA5'; (PARA PRUEBAS)
		if (agenteDestinoId) {
			return ({
				connIdConsulta: interactioneventID,
				idNuevoOwner: agenteDestinoId
			});
		} else {
			return null;
		}

	} else {
		return null;
	}
}

async function atributosLlamadaInicial(interactionId, scope) {
	const atributos = await atributosLlamadaInicialApex({interactionId: interactionId});
	scope.logHistorial('info', 'Datos recuperados de la llamada origen', JSON.stringify(atributos, null, 3));
	return atributos;
}

async function purecloudConversationApi(interactionId, atributo, scope) {
	let retorno;
	if (!interactionId || interactionId === 'N/A') {
		console.error('Error API Genesys Cloud: Id de la interacción desconocido');
		scope.logHistorial('error', 'Error API Genesys Cloud', 'Id de la interacción desconocido');
	} else {
		if (scope.simularRespuestaApiPurecloud) {
			const plantillaSimularRespuestaApiPurecloud = scope.template.querySelector('.textareaJsonSimularApiPurecloud').value;
			retorno = JSON.parse(plantillaSimularRespuestaApiPurecloud);
			scope.logHistorial('API Purecloud', 'Respuesta PureCloud Conversation API (SIMULADA)', plantillaSimularRespuestaApiPurecloud);
			if (atributo) {
				retorno = retorno.participants[0]?.attributes[atributo];
			}
		} else {
			try {
				const timestampInicioLlamadaApi = performance.now();
				let response = await purecloudConversationApiApex({interactionId: interactionId});
				if (response.statusCode === 200) {
					const duracion = Math.round((performance.now() - timestampInicioLlamadaApi) / 100) / 10;
					retorno = response?.body;
					if (atributo) {
						retorno = retorno.participants[0]?.attributes[atributo];
					}
					scope.logHistorial('API Purecloud', 'Respuesta PureCloud Conversation API (' + duracion + 's)', JSON.stringify(response.body, null, 3));
				} else {
					console.error('Error API Genesys Cloud: ' + response.statusCode + ' ' + response.status);
					scope.logHistorial('error', 'Error API Genesys Cloud', response.statusCode + ' ' + response.status);
				}
			} catch (error) {
				console.error('Error API Genesys Cloud:' + error);
				scope.logHistorial('error', 'Error API Genesys Cloud', JSON.stringify(error, null, 3));
			}
		}
	}
	return retorno;
}

export const METODOS_APEX_TEST_INPUTS = {
	registrarLlamadaEntrante: null,
	registrarLlamadaSaliente: {
		llamadaJson: JSON.stringify({
			usuario: '1218',
			extension: '1118',
			connId: '12345678',
			ani: '666666666',
			dnis: '666666666',
			servicio: 'TARJETAS_TARJETAS',
			asunto: 'Asunto',
			numPerso: '111111',
			idioma: 'Castellano',
			datos: 'Datos',
			connIdCognitivo: '87654321',
			casoId: null,
			salesforceParentId: 'ul',
			statusAuto: 'APPROVED',
			perfil: 'EMPLEADOS',
			llamadaId: ''
		})
	},
	registrarConsulta: null,
	registrarblindTransfer: null,
	finalizarLlamada: null,
	finalizarConsulta: null,
	finalizarConsultaExterna: null,
	iniciarTransferenciaCiega: null,
	completarConsulta: null
};

export const PLANTILLAS_MODAL_SIMULAR_OPCIONES = [
	{value: 'registrarLlamadaEntranteCc', label: 'registrarLlamadaEntrante CC', default: true},
	{value: 'registrarLlamadaEntranteHdt', label: 'registrarLlamadaEntrante HDT'},
	{value: 'registrarLlamadaSaliente', label: 'registrarLlamadaSaliente'},
	{value: 'finalizarLlamada', label: 'finalizarLlamada'},
	{value: 'iniciarConsulta', label: 'iniciarConsulta'},
	{value: 'registrarConsulta', label: 'registrarConsulta'},
	{value: 'registrarblindTransfer', label: 'registrarblindTransfer'},
	{value: 'finalizarConsulta', label: 'finalizarConsulta'},
	{value: 'completarConsulta', label: 'completarConsulta'}
];

export const PLANTILLAS_MODAL_SIMULAR = {
	registrarLlamadaEntranteCc: {
		category: 'connect',
		data: {
			id: '35e038b6-7f86-4d0c-b879-95a61adb43ef',
			connectedTime: '2023-05-03T15:03:12.185Z',
			phone: 'tel:+34646626371',
			name: 'Mobile Number, Spain',
			isConnected: true,
			isDisconnected: false,
			isDone: false,
			state: 'CONNECTED',
			attributes: {
				'Interaction.Url': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bff',
				'Participant.connIdCognitivo': '87654321',
				'Participant.datos': 'Datos',
				'Participant.idioma': 'Castellano',
				'Participant.numPerso': '111111',
				'Participant.asunto': 'Asunto',
				'Participant.servicio': 'TARJETAS_TARJETAS',
				'Participant.URL_Interaction': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bf'
			},
			isCallback: false,
			isDialer: false,
			isChat: false,
			isEmail: false,
			isMessage: false,
			isVoicemail: false,
			remoteName: 'Mobile Number, Spain',
			recordingState: 'active',
			displayAddress: '+34646626371',
			queueName: 'Test_ColaSFC',
			ani: '+34646626371',
			calledNumber: '+34911042991',
			totalIvrDurationSeconds: 1,
			direction: 'Inbound',
			isInternal: false,
			startTime: '2023-05-03T15:02:19.612Z'
		},
		type: 'Interaction'
	},

	registrarLlamadaEntranteHdt: {
		category: 'connect',
		data: {
			id: '35e038b6-7f86-4d0c-b879-95a61adb43ef',
			connectedTime: '2023-05-03T15:03:12.185Z',
			phone: 'tel:+34646626371',
			name: 'Mobile Number, Spain',
			isConnected: true,
			isDisconnected: false,
			isDone: false,
			state: 'CONNECTED',
			attributes: {
				'Interaction.Url': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bff',
				'Participant.connIdCognitivo': '87654321',
				'Participant.datos': 'Datos',
				'Participant.idioma': 'Castellano',
				'Participant.numPerso': '111111',
				'Participant.asunto': 'Asunto',
				'Participant.servicio': 'TARJETAS_TARJETAS_HDT',
				'Participant.URL_Interaction': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bf'
			},
			isCallback: false,
			isDialer: false,
			isChat: false,
			isEmail: false,
			isMessage: false,
			isVoicemail: false,
			remoteName: 'Mobile Number, Spain',
			recordingState: 'active',
			displayAddress: '+34646626371',
			queueName: 'Test_ColaSFC',
			ani: '+34646626371',
			calledNumber: '+34911042991',
			totalIvrDurationSeconds: 1,
			direction: 'Inbound',
			isInternal: false,
			startTime: '2023-05-03T15:02:19.612Z'
		},
		type: 'Interaction'
	},

	registrarLlamadaSaliente: {
		category: 'connect',
		data: {
			id: '7444b852-77b4-41d5-973c-47483f8be6b9',
			connectedTime: '2023-05-19T11:06:59.885Z',
			phone: '+34918658365',
			name: 'Madrid, Spain',
			isConnected: true,
			isDisconnected: false,
			isDone: false,
			state: 'CONNECTED',
			attributes: {
				'Interaction.Url': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/7444b852-77b4-41d5-973c-47483f8be6b'
			},
			isCallback: false,
			isDialer: false,
			isChat: false,
			isEmail: false,
			isMessage: false,
			isVoicemail: false,
			remoteName: 'Madrid, Spain',
			recordingState: 'none',
			displayAddress: '+34918658365',
			ani: 'ConsueloCacheiroRemoto_1',
			calledNumber: '+34918658365',
			direction: 'Outbound',
			isInternal: false,
			startTime: '2023-05-19T11:06:46.627Z'
		},
		type: 'Interaction'
	},

	finalizarLlamada: {
		category: 'disconnect',
		data: {
			id: '16ec989f-8ba2-42f8-bb84-be2a57192248',
			connectedTime: '2023-04-27T14:22:13.348Z',
			endTime: '2023-04-27T14:22:59.126Z',
			phone: '916796045',
			name: '34 916796045',
			isConnected: false,
			isDisconnected: true,
			isDone: false,
			state: 'DISCONNECTED',
			attributes: {
				'Participant.servicio': '(IRRELEVANTE)'
			},
			isCallback: false,
			isDialer: false,
			isChat: false,
			isEmail: false,
			isMessage: false,
			isVoicemail: false,
			remoteName: '34 916796045',
			recordingState: 'active',
			displayAddress: '+34916796045',
			queueName: 'Cola-Everis',
			ani: '+34916796045',
			calledNumber: '+34919041746',
			interactionDurationSeconds: '',
			totalIvrDurationSeconds: '',
			totalAcdDurationSeconds: '',
			direction: 'Inbound',
			isInternal: false,
			startTime: '2023-04-27T14:21:41.069'
		},
		type: 'Interaction'
	},

	iniciarConsulta: {
		category: 'consultTransfer',
		data: {
			id: 'e004898b-408f-44e1-a9ec-955c1df048ad'
		}
	},
	registrarblindTransfer: {
		category: 'connect',
		data: {
			id: '14911faf-6290-4c8f-871e-3399519ce041',
			connectedTime: '2023-05-03T15:03:12.185Z',
			phone: 'tel:+34646626371',
			name: 'Mobile Number, Spain',
			isConnected: true,
			isDisconnected: false,
			isDone: false,
			state: 'CONNECTED',
			attributes: {
				'Participant.estadoConsultaFRA': 'iniciando',
				'Interaction.Url': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bff',
				'Participant.connIdCognitivo': '87654321',
				'Participant.datos': 'Datos',
				'Participant.idioma': 'Castellano',
				'Participant.numPerso': '111111',
				'Participant.asunto': 'Asunto',
				'Participant.servicio': 'TARJETAS_TARJETAS',
				'Participant.URL_Interaction': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bf'
			},
			isCallback: false,
			isDialer: false,
			isChat: false,
			isEmail: false,
			isMessage: false,
			isVoicemail: false,
			remoteName: 'Mobile Number, Spain',
			recordingState: 'active',
			displayAddress: '+34646626371',
			queueName: 'Test_ColaSFC',
			ani: '+34646626371',
			calledNumber: '+34911042991',
			totalIvrDurationSeconds: 1,
			direction: 'Inbound',
			isInternal: false,
			startTime: '2023-05-03T15:02:19.612Z'
		},
		type: 'Interaction'
	},
	registrarConsulta: {
		category: 'connect',
		data: {
			id: '14911faf-6290-4c8f-871e-3399519ce041',
			connectedTime: '2023-05-03T15:03:12.185Z',
			phone: 'tel:+34646626371',
			name: 'Mobile Number, Spain',
			isConnected: true,
			isDisconnected: false,
			isDone: false,
			state: 'CONNECTED',
			attributes: {
				'Participant.estadoConsultaFRA': 'iniciando',
				'Interaction.Url': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bff',
				'Participant.connIdCognitivo': '87654321',
				'Participant.datos': 'Datos',
				'Participant.idioma': 'Castellano',
				'Participant.numPerso': '111111',
				'Participant.asunto': 'Asunto',
				'Participant.servicio': 'TARJETAS_TARJETAS',
				'Participant.URL_Interaction': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bf'
			},
			isCallback: false,
			isDialer: false,
			isChat: false,
			isEmail: false,
			isMessage: false,
			isVoicemail: false,
			remoteName: 'Mobile Number, Spain',
			recordingState: 'active',
			displayAddress: '+34646626371',
			queueName: 'Test_ColaSFC',
			ani: '+34646626371',
			calledNumber: '+34911042991',
			totalIvrDurationSeconds: 1,
			direction: 'Inbound',
			isInternal: false,
			startTime: '2023-05-03T15:02:19.612Z'
		},
		type: 'Interaction'
	},

	finalizarConsulta: {
		category: 'disconnect',
		data: {
			id: '16ec989f-8ba2-42f8-bb84-be2a57192248',
			connectedTime: '2023-04-27T14:22:13.348Z',
			endTime: '2023-04-27T14:22:59.126Z',
			phone: '916796045',
			name: '34 916796045',
			isConnected: false,
			isDisconnected: true,
			isDone: false,
			state: 'DISCONNECTED',
			attributes: {
				'Participant.estadoConsultaFRA': 'consulta',
				'Participant.agenteOrigenId': '0053Y00000ALRTSQA9',
				'Participant.servicio': 'TARJETAS_TARJETAS'
			},
			isCallback: false,
			isDialer: false,
			isChat: false,
			isEmail: false,
			isMessage: false,
			isVoicemail: false,
			remoteName: '34 916796045',
			recordingState: 'active',
			displayAddress: '+34916796045',
			queueName: 'Cola-Everis',
			ani: '+34916796045',
			calledNumber: '+34919041746',
			interactionDurationSeconds: '',
			totalIvrDurationSeconds: '',
			totalAcdDurationSeconds: '',
			direction: 'Inbound',
			isInternal: false,
			startTime: '2023-04-27T14:21:41.069'
		},
		type: 'Interaction'
	},

	completarConsulta: {
		category: 'completeConsultTransfer',
		data: {
			id: '16ec989f-8ba2-42f8-bb84-be2a57192248',
		}
	}
};

export const PLANTILLA_MODAL_SIMULAR_API = JSON.stringify({
	participants: [
		{
			attributes: ({
				casoId: '5005E00000HdCPFQA3',
				agenteDestinoId: '0053Y00000ALRTSQA5'
			})
		}
	]
}, null, 3);

export function formatearApexInput(apexInput) {
	if (!apexInput) {
		return null;
	}
	if (apexInput.llamadaJson) {
		apexInput = {...apexInput, llamadaJson: JSON.parse(apexInput.llamadaJson)};
	}
	if (apexInput.consultaJson) {
		apexInput = {...apexInput, consultaJson: JSON.parse(apexInput.consultaJson)};
	}
	return JSON.stringify(apexInput, null, 3);
}