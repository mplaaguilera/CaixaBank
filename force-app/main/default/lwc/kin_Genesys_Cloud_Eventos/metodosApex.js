/*eslint-disable no-else-return, @lwc/lwc/no-async-await */
import registrarLlamadaEntranteApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.registrarLlamadaEntrante';
import registrarLlamadaSalienteApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.registrarLlamadaSaliente';
import iniciarLlamadaSalienteClickToDialApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.iniciarLlamadaSalienteClickToDial';
import registrarConsultaApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.registrarConsulta';
//import registrarConsultaNoAtendidaApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.registrarConsultaNoAtendida';
import registrarEncuestaApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.registrarEncuesta';
import finalizarLlamadaApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.finalizarLlamada';
import finalizarConsultaApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.finalizarConsulta';
//import finalizarConsultaExternaApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.finalizarConsultaExterna';
//import cancelarConsultaApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.cancelarConsulta';
import completarConsultaApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.completarConsulta';
//import enviarInteraccionApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.enviarInteraccion';

import purecloudConversationApiApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.purecloudConversationApi';
import atributosLlamadaInicialApex from '@salesforce/apex/KIN_Genesys_Cloud_Eventos_Controller.atributosLlamadaInicial';

import {mostrarToast} from './utils';

export const CATEGORIES_RELEVANTES = [
	'connect',
	'consultTransfer',
	'blindTransfer',
	'disconnect',
	'completeConsultTransfer',
	'ConsultCall',
	'CompleteConsultCall',
	'acw'
];

export const METODOS_APEX = [
	{nombre: 'registrarLlamadaEntrante', label: 'Llamada entrante', metodoApex: registrarLlamadaEntranteApex, abrirTab: 'abrirTabId'},
	{nombre: 'registrarLlamadaSaliente', label: 'Llamada saliente', metodoApex: registrarLlamadaSalienteApex},
	{nombre: 'iniciarLlamadaSalienteClickToDial', label: 'Llamada saliente click-to-dial', metodoApex: iniciarLlamadaSalienteClickToDialApex},
	{nombre: 'registrarConsulta', label: 'Consulta', metodoApex: registrarConsultaApex, abrirTab: 'caso'},
	//{nombre: 'registrarConsultaNoAtendida', label: 'Consulta no atendida', metodoApex: registrarConsultaNoAtendidaApex},
	{nombre: 'registrarEncuesta', label: 'Encuesta', metodoApex: registrarEncuestaApex},
	{nombre: 'finalizarLlamada', label: 'Finalizar llamada', metodoApex: finalizarLlamadaApex},
	{nombre: 'finalizarConsulta', label: 'Finalizar consulta', metodoApex: finalizarConsultaApex},
	//{nombre: 'finalizarConsultaExterna', label: 'Finalizar cons. externa', metodoApex: finalizarConsultaExternaApex},
	//{nombre: 'cancelarConsulta', label: 'Cancelar consulta', metodoApex: cancelarConsultaApex},
	{nombre: 'completarConsulta', label: 'Completar consulta', metodoApex: completarConsultaApex}
	//{nombre: 'enviarInteraccion', label: 'Enviar interacción', metodoApex: enviarInteraccionApex},
];

export const METODOS_APEX_TRIGGERS = { //Los triggers se evalúan en este orden
	registrarConsulta: {
		category: 'connect',
		data: {
			attributes: {
				'Participant.estadoConsulta': 'iniciando'
			}
		}
	},
	registrarLlamadaEntrante: {
		category: 'connect',
		data: {
			direction: 'Inbound',
		}
	},
	registrarLlamadaSaliente: {
		category: 'connect',
		data: {
			direction: 'Outbound',
			attributes: {
				'Participant.clickToDial': 'false'
			}
		}
	},
	iniciarLlamadaSalienteClickToDial: {
		category: 'connect',
		data: {
			direction: 'Outbound',
			attributes: {
				'Participant.clickToDial': 'true',
				'Participant.llamadaId': '***' //Cualquier valor
			}
		}
	},
	iniciarConsulta: {
		category: 'consultTransfer'
	},
	finalizarConsulta: {
		category: 'disconnect',
		data: {
			attributes: {
				'Participant.estadoConsulta': 'consulta',
				'Participant.agenteOrigenId': '!*USER_ID*'
			}
		}
	},
	finalizarLlamada: {
		category: 'disconnect',
		data: {
			attributes: {
				'Participant.estadoConsulta': '!iniciando'
			}
		}
	},
	completarConsulta: {
		category: 'completeConsultTransfer'
	},
	registrarEncuesta: {
		category: 'acw',
		data: {
			attributes: {
				'Participant.encuestaEnviada': 'si'
			}
		}
	}
};

//eslint-disable-next-line complexity
export async function conversionApexInputs(nombreMetodoApex, message, interactionId, scope) {
	if (nombreMetodoApex === 'registrarLlamadaEntrante') {
		let dnis = '';
		if (message.data.attributes['Participant.dnisOriginal']) {
			dnis = message.data.attributes['Participant.dnisOriginal'];
		} else if (message.data.calledNumber) {
			dnis = message.data.calledNumber;
		}

		return {
			llamadaJson: JSON.stringify({
				usuario: '', //!!!!
				extension: '', //!!!!
				connId: message.data.id ?? '',
				ani: message.data.ani ?? '',
				dnis: dnis,
				servicio: message.data.attributes['Participant.servicio'] ?? '',
				asunto: message.data.attributes['Participant.asunto'] ?? '',
				numPerso: message.data.attributes['Participant.numPerso'] ?? '',
				idioma: message.data.attributes['Participant.idioma'] ?? '',
				datos: message.data.attributes['Participant.datos'] ?? '',
				connIdCognitivo: message.data.attributes['Participant.connIdCognitivo'] ?? '',
				casoId: message.data.attributes['Participant.casoId'] ?? '',
				salesforceParentId: message.data.attributes['Participant.salesforceParentId'] ?? '',
				llamadaId: message.data.attributes['Participant.llamadaId'] ?? '',
				//eslint-disable-next-line camelcase
				canalEmpleado: message.data.attributes['Participant.CCO_ORIGEN'] ?? '',
				urlGrabacion: message.data.attributes['Interaction.Url'] ?? '',
				perfil: message.data.attributes['Participant.perfil'] ?? '',
				statusAuto: message.data.attributes['Participant.StatusAuto'] ?? '',
				//Nuevo proyecto GENiaL
				sentiment: message.data.attributes['Participant.sentiment'] ?? '',
				summary: message.data.attributes['Participant.summary'] ?? '',
				assistantResponse: message.data.attributes['Participant.assistantResponse'] ?? '',
				userQuery: message.data.attributes['Participant.userQuery'] ?? '',
				telefonoUnico: message.data.attributes['Participant.telefonoUnico'] ?? ''
			})
		};

	} else if (nombreMetodoApex === 'registrarLlamadaSaliente') {
		const respuesta = await purecloudConversationApi(interactionId, null, scope);
		const atributos = respuesta.participants[0]?.attributes;
		return {
			llamadaJson: JSON.stringify({
				usuario: '' ?? '', //!!!!
				extension: '' ?? '', //!!!!
				connId: message.data.id ?? '',
				ani: message.data.ani ?? '',
				dnis: message.data.calledNumber ?? '',
				urlGrabacion: message.data.attributes['Interaction.Url'] ?? '',
				casoId: atributos.casoId
			})
		};

	} else if (nombreMetodoApex === 'iniciarLlamadaSalienteClickToDial') {
		const respuesta = await purecloudConversationApi(interactionId, null, scope);
		const atributos = respuesta.participants[0]?.attributes;
		return {
			llamadaJson: JSON.stringify({
				connId: message.data.id ?? '',
				ani: message.data.ani ?? '',
				dnis: message.data.calledNumber ?? '',
				urlGrabacion: message.data.attributes['Interaction.Url'] ?? '',
				casoId: atributos.casoId,
				llamadaId: atributos.llamadaId
			})
		};

	} else if (nombreMetodoApex === 'finalizarLlamada') {
		if (message.data) {
			return {
				llamadaJson: JSON.stringify({
					connId: message.data.id ?? '',
					llamadaId: message.data.attributes['Participant.llamadaId'] ?? ''
				}),
				tipoCierre: 'Llamada finalizada'
			};
		} else {
			let atributos = await atributosLlamadaInicial(interactionId, scope);
			if (atributos) {
				return {
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
						casoId: message.data.attributes['Participant.casoId'] ?? '',
						salesforceParentId: message.data.attributes['Participant.salesforceParentId'] ?? '',
						llamadaId: message.data.attributes['Participant.llamadaId'] ?? '',
						//eslint-disable-next-line camelcase
						// CC_Canal_del_Empleado__c: message.data.attributes['Participant.CC_Canal_del_Empleado__c'] ?? '',

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
				};
			} else {
				return null;
			}
		}

	} else if (nombreMetodoApex === 'registrarConsulta') {
		let atributos = await atributosLlamadaInicial(interactionId, scope);
		if (atributos) {
			return {
				consultaJson: JSON.stringify({
					usuario: atributos.usuario,
					extension: atributos.extension,
					//servicio: atributos.servicio,
					servicio: message.data.attributes['Participant.servicio'] ?? '',
					connId: atributos.connId,
					ani: atributos.ani ?? '',
					dnis: atributos.dnis,
					idioma: atributos.idioma,
					casoId: atributos.casoId,
					//salesforceParentId: atributos.salesforceParentId
					salesforceParentId: atributos.llamadaId,
					urlGrabacion: atributos.urlGrabacion
				})
			};
		} else {
			return null;
		}

	} else if (nombreMetodoApex === 'finalizarConsulta') {
		let atributos = await atributosLlamadaInicial(interactionId, scope);
		if (atributos) {
			return {
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
			};
		} else {
			return null;
		}

	/*{ else if (nombreMetodoApex === 'cancelarConsulta') {
		return {
			consultaJson: JSON.stringify({
				//usuario: atributos.usuario,
				//extension: atributos.extension,
				//llamadaId: atributos.llamadaId,
				connId: message.data.id ?? ''
				//ani: atributos.ani ?? '',
				//dnis: atributos.dnis,
				//servicio: atributos.servicio,
				//idioma: atributos.idioma,
				//salesforceParentId: atributos.salesforceParentId,
				//casoId: atributos.casoId,
			})
		};
	*/
	} else if (nombreMetodoApex === 'completarConsulta') {
		const respuesta = await purecloudConversationApi(interactionId, null, scope);
		const atributos = respuesta.participants[0]?.attributes;
		//const agenteDestinoId = '0053Y00000ALRTSQA5'; (PARA PRUEBAS)
		if (atributos) {
			return {
				connIdConsulta: interactionId,
				servicio: atributos.servicio,
				idNuevoOwner: atributos.agenteDestinoId
			};
		} else {
			return null;
		}

	} else if (nombreMetodoApex === 'registrarEncuesta') {
		let atributos = await atributosLlamadaInicial(interactionId, scope);
		if (atributos) {
			return {
				llamadaJson: JSON.stringify({
					llamadaId: atributos.llamadaId,
					connId: message.data.id ?? '',
					casoId: atributos.casoId
				})
			};
		} else {
			return null;
		}

	} else {
		return null;
	}
}

async function atributosLlamadaInicial(interactionId, scope) {
	let atributos;
	try {
		atributos = await atributosLlamadaInicialApex({interactionId: interactionId});
		if (!atributos) {
			throw new Error('Retorno sin datos');
		}
		scope.logHistorial('info', 'Datos recuperados de la llamada origen', JSON.stringify(atributos, null, 3));
	} catch (e) {
		console.error(e);
		scope.logHistorial('error', 'Error obteniendo los datos de la llamada origen', e);
	}
	return atributos;
}

export async function purecloudConversationApi(interactionId, atributo, scope) {
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
				mostrarToast('error', 'Error API Genesys Cloud', JSON.stringify(error, null, 3));
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
	registrarConsultaNoAtendida: null,
	registrarEncuesta: null,
	finalizarLlamada: null,
	finalizarConsulta: null,
	finalizarConsultaExterna: null,
	//cancelarConsulta: null,
	completarConsulta: null
	//enviarInteraccion: null
};

export const PLANTILLAS_MODAL_SIMULAR_OPCIONES = [
	{value: 'registrarLlamadaEntranteCc', label: 'registrarLlamadaEntrante CC', default: true},
	{value: 'registrarLlamadaEntranteHdt', label: 'registrarLlamadaEntrante HDT'},
	{value: 'registrarLlamadaEntranteCsbd', label: 'registrarLlamadaEntrante CSBD'},
	{value: 'registrarLlamadaSaliente', label: 'registrarLlamadaSaliente'},
	{value: 'iniciarLlamadaSalienteClickToDial', label: 'iniciarLlamadaSalienteClickToDial'},
	{value: 'finalizarLlamada', label: 'finalizarLlamada'},
	{value: 'iniciarConsulta', label: 'iniciarConsulta'},
	{value: 'registrarConsulta', label: 'registrarConsulta'},
	{value: 'finalizarConsulta', label: 'finalizarConsulta'},
	//{value: 'cancelarConsulta', label: 'cancelarConsulta'},
	{value: 'completarConsulta', label: 'completarConsulta'},
	{value: 'registrarEncuesta', label: 'registrarEncuesta'}
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
				'Participant.dnisOriginal': '+34911042992',
				'Interaction.Url': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bff',
				'Participant.connIdCognitivo': '87654321',
				'Participant.datos': 'Datos',
				'Participant.idioma': 'Castellano',
				'Participant.numPerso': '111111',
				'Participant.asunto': 'Asunto',
				'Participant.servicio': 'TEST_SABIO',
				'Participant.URL_Interaction': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bf',
				//Nuevo proyecto GENiaL
				'Participant.sentiment': '0',
				'Participant.summary': 'Hola',
				'Participant.assistantResponse': 'Hola assistantResponse',
				'Participant.userQuery': 'Hola userQuery'
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

	registrarLlamadaEntranteCsbd: {
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
				'Participant.servicio': 'HIPOTECAS',
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
	iniciarLlamadaSalienteClickToDial: {
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
				'Participant.clickToDial': true,
				'Participant.llamadaId': 'a0d5r0000029G9IAAU',
				'Participant.Url': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/7444b852-77b4-41d5-973c-47483f8be6b'
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
		data: '9359d1f7-713b-4ba3-ba90-148b54b548e4',
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
				'Participant.estadoConsulta': 'iniciando',
				'Participant.agenteOrigenId': '???',
				'Participant.agenteDestinoId': null,
				'Interaction.Url': 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/3318ac29-b202-4ca9-909c-ffcc263b5bff',
				'Participant.connIdCognitivo': '87654321',
				'Participant.datos': 'Datos',
				'Participant.idioma': 'Castellano',
				'Participant.numPerso': '111111',
				'Participant.asunto': 'Asunto',
				'Participant.servicio': 'TEST_SABIO',
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
				'Participant.estadoConsulta': 'consulta',
				'Participant.agenteOrigenId': '0053Y00000ALRTSQA9',
				'Participant.servicio': 'TEST_SABIO'
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

	/*
	cancelarConsulta: {
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
				'Participant.estadoConsulta': 'consulta',
				'Participant.agenteOrigenId': '123123123123123',
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
	*/

	completarConsulta: {
		category: 'completeConsultTransfer',
		data: {
			id: '16ec989f-8ba2-42f8-bb84-be2a57192248',
		}
	},

	registrarEncuesta: {
		category: 'acw',
		data: {
			id: 'e3df091a-2b93-4bf0-a788-9dd35382a714',
			connectedTime: '2023-08-01T09:26:31.040Z',
			endTime: '2023-08-01T09:26:45.164Z',
			phone: '+34618418844',
			name: 'Mobile Number, Spain',
			attributes: {
				'Participant.encuestaEnviada': 'si'
			},
			queueName: 'TARJETAS_OESIA_CAS',
			ani: '+34618418844',
			calledNumber: '+34004000000',
			interactionDurationSeconds: 14,
			totalIvrDurationSeconds: 9,
			totalAcdDurationSeconds: 48,
			disposition: 'Default Wrap-up Code',
			dispositionDurationSeconds: 8,
			direction: 'Inbound',
			isInternal: false,
			startTime: '2023-08-01T09:25:33.717Z'
		},
		type: 'Interaction'
	}
};

export const PLANTILLA_MODAL_SIMULAR_API = JSON.stringify({
	participants: [
		{
			attributes: {
				casoId: '5005E00000HdCPFQA3',
				agenteDestinoId: '0053Y00000ALRTSQA5'
			}
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