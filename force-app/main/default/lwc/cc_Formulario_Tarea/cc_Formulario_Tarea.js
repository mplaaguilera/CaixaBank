import {LightningElement, api, wire} from 'lwc';

import getActivityExtensionIdApex from '@salesforce/apex/CC_Formulario_Tarea_Controller.getActivityExtensionId';
import TIPO_CITA from '@salesforce/schema/CBK_Activity_Extension__c.CC_Tipo_de_cita__c';
import GRUPO_COLABORADOR from '@salesforce/schema/CBK_Activity_Extension__c.CC_Grupo_Colaborador_Name__c';
import REAPERTURA_VALIDA from '@salesforce/schema/CBK_Activity_Extension__c.CC_Reapertura_Valida_Task__c';

export default class Cc_Formulario_Tarea extends LightningElement {

	campos = [TIPO_CITA, GRUPO_COLABORADOR, REAPERTURA_VALIDA];

	@api recordId;

	activityExtensionId;

	@wire(getActivityExtensionIdApex, {recordId: '$recordId'})
	wiredActivityExtension({data, error}) {
		if (data) {
			console.log(data);
			this.activityExtensionId = data;
		} else if (error) {
			console.error(error);
		}
	}
}