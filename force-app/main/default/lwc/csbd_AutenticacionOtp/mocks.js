import {createRecord, updateRecord, getFieldValue} from 'lightning/uiRecordApi';

import OPP_ACCOUNT_ID from '@salesforce/schema/Opportunity.AccountId';
import OPP_AUT_FECHA from '@salesforce/schema/Opportunity.CSBD_UltimaAutenticacionFecha__c';
import OPP_AUT_OK from '@salesforce/schema/Opportunity.CSBD_UltimaAutenticacionOk__c';
import OPP_AUT_ESTADO from '@salesforce/schema/Opportunity.CSBD_EstadoAutenticacion__c';
//import OPP_INTENTOS from '@salesforce/schema/Opportunity.CSBD_IntentosAutenticacion__c';
import AUT from '@salesforce/schema/CC_Comunicaciones__c';
import AUT_RT_ID from '@salesforce/schema/CC_Comunicaciones__c.RecordTypeId';
import AUT_OPP_ID from '@salesforce/schema/CC_Comunicaciones__c.CSBD_Opportunity__c';
import AUT_CLIENTE_ID from '@salesforce/schema/CC_Comunicaciones__c.CC_Cliente__c';
import AUT_NIVEL from '@salesforce/schema/CC_Comunicaciones__c.CC_Nivel__c';
import AUT_FECHA from '@salesforce/schema/CC_Comunicaciones__c.CC_Fecha_Validacion__c';
import AUT_ESTADO from '@salesforce/schema/CC_Comunicaciones__c.CC_Estado__c';
import AUT_COD_ERROR from '@salesforce/schema/CC_Comunicaciones__c.CC_Codigo_Error__c';
import AUT_COD_PREGUNTA1 from '@salesforce/schema/CC_Comunicaciones__c.CC_Pregunta_1__c';
import AUT_COD_RESPUESTA1 from '@salesforce/schema/CC_Comunicaciones__c.CC_Respuesta_1__c';
import AUT_COD_VALIDACION1 from '@salesforce/schema/CC_Comunicaciones__c.CC_Validacion_1__c';
import AUT_COD_PREGUNTA2 from '@salesforce/schema/CC_Comunicaciones__c.CC_Pregunta_2__c';
import AUT_COD_RESPUESTA2 from '@salesforce/schema/CC_Comunicaciones__c.CC_Respuesta_2__c';
import AUT_COD_VALIDACION2 from '@salesforce/schema/CC_Comunicaciones__c.CC_Validacion_2__c';
import AUT_CODIGO from '@salesforce/schema/CC_Comunicaciones__c.CC_Codigo_OTPSMS__c';
import AUT_RESULTADO from '@salesforce/schema/CC_Comunicaciones__c.CC_Resultado_Validacion__c';
import AUT_RESPUESTA from '@salesforce/schema/CC_Comunicaciones__c.CC_Respuesta_OTP__c';
import AUT_TIPO_LLAMADA from '@salesforce/schema/CC_Comunicaciones__c.CC_Tipo_Llamada__c';


export async function n2ValidarRespuestasPreguntasMockOk(idRtAutenticacion, oportunidad) {
	const fields = {};
	fields[AUT_RT_ID.fieldApiName] = idRtAutenticacion;
	fields[AUT_OPP_ID.fieldApiName] = oportunidad.id;
	fields[AUT_CLIENTE_ID.fieldApiName] = getFieldValue(oportunidad, OPP_ACCOUNT_ID);
	fields[AUT_NIVEL.fieldApiName] = 'Nivel 2';
	fields[AUT_FECHA.fieldApiName] = new Date().toISOString();
	fields[AUT_TIPO_LLAMADA.fieldApiName] = 'Entrante';
	fields[AUT_COD_PREGUNTA1.fieldApiName] = '¿1?';
	fields[AUT_COD_RESPUESTA1.fieldApiName] = '¡1!';
	fields[AUT_COD_VALIDACION1.fieldApiName] = 'OK';
	fields[AUT_COD_PREGUNTA2.fieldApiName] = '¿2?';
	fields[AUT_COD_RESPUESTA2.fieldApiName] = '¡2!';
	fields[AUT_COD_VALIDACION2.fieldApiName] = 'OK';
	fields[AUT_ESTADO.fieldApiName] = 'Pdte. Envío';
	try {
		const aut = await createRecord({apiName: AUT.objectApiName, fields});
		await new Promise(resolve => setTimeout(resolve, 1500));
		return {ok: true, idAutenticacion: aut.id};
	} catch (error) {
		console.error(error);
		return {ok: false, idAutenticacion: null};
	}
}

export async function n2ValidarRespuestasPreguntasMockKo(idRtAutenticacion, oportunidad) {
	//fields[AUT_INTENTOS.fieldApiName] = 0;


	const fields = {};
	fields[AUT_RT_ID.fieldApiName] = idRtAutenticacion;
	fields[AUT_OPP_ID.fieldApiName] = oportunidad.id;
	fields[AUT_CLIENTE_ID.fieldApiName] = getFieldValue(oportunidad, OPP_ACCOUNT_ID);
	fields[AUT_NIVEL.fieldApiName] = 'Nivel 2';
	fields[AUT_FECHA.fieldApiName] = new Date().toISOString();
	fields[AUT_TIPO_LLAMADA.fieldApiName] = 'Entrante';
	fields[AUT_COD_PREGUNTA1.fieldApiName] = '¿1?';
	fields[AUT_COD_RESPUESTA1.fieldApiName] = '¡1!';
	fields[AUT_COD_VALIDACION1.fieldApiName] = 'NOK';
	fields[AUT_COD_PREGUNTA2.fieldApiName] = '¿2?';
	fields[AUT_COD_RESPUESTA2.fieldApiName] = '¡2!';
	fields[AUT_COD_VALIDACION2.fieldApiName] = 'NOK';
	fields[AUT_ESTADO.fieldApiName] = 'Cerrado';
	fields[AUT_RESULTADO.fieldApiName] = 'Identificación NOK';
	try {
		const aut = await createRecord({apiName: AUT.objectApiName, fields});
		await new Promise(resolve => setTimeout(resolve, 1500));
		return {ok: false, idAutenticacion: aut.id};
	} catch (error) {
		console.error(error);
		return {ok: false, idAutenticacion: null};
	}
}

export async function n2ValidarOtpMockOk({recordId, idAutenticacion, codigo}) {
	const oportunidad = {};
	oportunidad.Id = recordId;
	oportunidad[OPP_AUT_FECHA.fieldApiName] = new Date().toISOString();
	oportunidad[OPP_AUT_OK.fieldApiName] = true;
	oportunidad[OPP_AUT_ESTADO.fieldApiName] = 'APPROVED';
	updateRecord({fields: oportunidad});

	const autenticacion = {};
	autenticacion.Id = idAutenticacion;
	autenticacion[AUT_FECHA.fieldApiName] = new Date().toISOString();
	autenticacion[AUT_CODIGO.fieldApiName] = codigo;
	autenticacion[AUT_RESULTADO.fieldApiName] = 'OTP validada correctamente';
	autenticacion[AUT_ESTADO.fieldApiName] = 'Cerrado';
	autenticacion[AUT_COD_ERROR.fieldApiName] = '00000';
	//autenticacion[AUT_RESPUESTA.fieldApiName] = ;
	updateRecord({fields: autenticacion});

	await new Promise(resolve => setTimeout(resolve, 4000));
	return true;
}

export async function n2ValidarOtpMockKo({recordId, idAutenticacion, codigo}) {
	const oportunidad = {};
	oportunidad.Id = recordId;
	oportunidad[OPP_AUT_FECHA.fieldApiName] = new Date().toISOString();
	oportunidad[OPP_AUT_OK.fieldApiName] = false;
	oportunidad[OPP_AUT_ESTADO.fieldApiName] = 'ERROR';
	updateRecord({fields: oportunidad});

	const autenticacion = {};
	autenticacion.Id = idAutenticacion;
	autenticacion[AUT_FECHA.fieldApiName] = new Date().toISOString();
	autenticacion[AUT_CODIGO.fieldApiName] = codigo;
	autenticacion[AUT_RESULTADO.fieldApiName] = 'OTP errónea';
	autenticacion[AUT_ESTADO.fieldApiName] = 'Rechazado';
	autenticacion[AUT_COD_ERROR.fieldApiName] = '00004';
	autenticacion[AUT_RESPUESTA.fieldApiName] = '{"ErrorData":{"errorCode":"00004","errorMessage":"ERROR EN PARÁMETROS DE ENTRADA"}}';
	updateRecord({fields: autenticacion});

	await new Promise(resolve => setTimeout(resolve, 4000));
	return false;
}