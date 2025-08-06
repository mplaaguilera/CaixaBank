import {updateRecord} from 'lightning/uiRecordApi';

import OPP_AUT_FECHA from '@salesforce/schema/Opportunity.CSBD_UltimaAutenticacionFecha__c';
import OPP_AUT_OK from '@salesforce/schema/Opportunity.CSBD_UltimaAutenticacionOk__c';
import OPP_AUT_ESTADO from '@salesforce/schema/Opportunity.CSBD_EstadoAutenticacion__c';
import AUT_FECHA from '@salesforce/schema/CC_Comunicaciones__c.CC_Fecha_Validacion__c';
import AUT_ESTADO from '@salesforce/schema/CC_Comunicaciones__c.CC_Estado__c';
import AUT_COD_ERROR from '@salesforce/schema/CC_Comunicaciones__c.CC_Codigo_Error__c';
import AUT_MSG_ERROR from '@salesforce/schema/CC_Comunicaciones__c.CC_Mensaje_Error__c';
import AUT_DETALLE from '@salesforce/schema/CC_Comunicaciones__c.CC_Detalle__c';
import AUT_CODIGO from '@salesforce/schema/CC_Comunicaciones__c.CC_Codigo_OTPSMS__c';
import AUT_RESULTADO from '@salesforce/schema/CC_Comunicaciones__c.CC_Resultado_Validacion__c';
import AUT_RESPUESTA from '@salesforce/schema/CC_Comunicaciones__c.CC_Respuesta_OTP__c';

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