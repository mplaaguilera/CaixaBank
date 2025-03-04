import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import {NavigationMixin} from 'lightning/navigation';
import {toast, errorApex} from 'c/csbd_lwcUtils';

import getOtrasLlamadasApex from '@salesforce/apex/CSBD_MacRelatedListApex.getOtrasLlamadas';
import crearTareaVinculacionApex from '@salesforce/apex/CSBD_MacRelatedListApex.crearTareaVinculacion';

import OPP_PARENT_ID from '@salesforce/schema/Opportunity.CSBD_Parent_Id__c';
import OPP_TELEFONO from '@salesforce/schema/Opportunity.CSBD_Telefono_Solicitud__c';

//eslint-disable-next-line new-cap
export default class csbdMacRelatedList extends NavigationMixin(LightningElement) {
	@api recordId;

	spinner = false;

	datatableColumnas = [
		{label: 'Fecha', fieldName: 'CreatedDate', type: 'date', initialWidth: 111, sortable: true, hideDefaultActions: true,
			typeAttributes: {year: '2-digit', month: 'numeric', day: 'numeric', hour: 'numeric', minute: '2-digit'}},
		{label: 'Oportunidad', fieldName: '_oportunidadUrl', type: 'url', initialWidth: 109, hideDefaultActions: true,
			typeAttributes: {label: {fieldName: 'CSBD_Identificador__c'}}},
		{label: 'Estado', fieldName: 'CSBD_Estado__c', initialWidth: 90, hideDefaultActions: true},
		{label: 'Propietario', fieldName: '_ownerUrl', type: 'url', hideDefaultActions: true,
			typeAttributes: {label: {fieldName: '_ownerName'}}},
		{label: 'Vincular', type: 'button-icon', fixedWidth: 74, hideDefaultActions: true,
			typeAttributes: {title: 'Vincular', iconName: 'utility:link', variant: {fieldName: '_variant'}, disabled: {fieldName: '_vinculada'}}}
	];

	wireTimestamp = null;

	datatableData = [];

	telefono;

	parentId;

	@wire(getRecord, {recordId: '$recordId', fields: [OPP_TELEFONO, OPP_PARENT_ID]})
	async wiredOpportunity({data, error}) {
		if (data) {
			this.telefono = getFieldValue(data, OPP_TELEFONO);
			this.parentId = getFieldValue(data, OPP_PARENT_ID);
		} else if (error) {
			errorApex(this, error, 'Problema recuperando los datos de la oportunidad');
		}
	}

	@wire(getOtrasLlamadasApex, {recordId: '$recordId', telefono: '$telefono', wireTimestamp: '$wireTimestamp'})
	async wiredOtrasLlamadas({error, data}) {
		if (data) {
			this.datatableData = data.map(oportunidad => ({
				...oportunidad, _oportunidadUrl: '/' + oportunidad.Id,
				_ownerName: oportunidad.Owner.Name, _ownerUrl: oportunidad.OwnerId,
				_vinculada: oportunidad.Id === this.parentId,
				_variant: oportunidad.Id === this.parentId ? 'brand' : 'border-filled'
			}));
		} else if (error) {
			errorApex(this, error, 'Problema recuperando la lista de otras llamadas');
		}
	}

	async datatableOnrowaction({detail: {row: seleccionada}}) {
		if (await LightningConfirm.open({
			variant: 'header', theme: 'info', label: 'Vincular con oportunidad padre',
			message: `Se definirá la oportunidad seleccionada ${seleccionada.CSBD_Identificador__c} como padre de la actual. ¿Quieres continuar?`
		})) {
			this.spinner = true;
			const oportunidadPadre = {
				Id: this.recordId,
				[OPP_PARENT_ID.fieldApiName]: seleccionada.Id
			};
			updateRecord({fields: oportunidadPadre})
				.then(() => {
					crearTareaVinculacionApex({recordId: this.recordId, identificadorParent: seleccionada.CSBD_Identificador__c})
					.catch(error => errorApex(this, error, 'Problema creando la tarea de la oporunidad'));

					toast('success', 'Se vinculó la oportunidad', `Se vinculó correctamente la oportunidad con la ${seleccionada.CSBD_Identificador__c}`);
					this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {recordId: seleccionada.Id, actionName: 'view'}
					});
					this.wireTimestamp = new Date();
				}).catch(error => errorApex(this, error, 'Problema vinculando las oportunidades'))
				.finally(() => this.spinner = false);
		}
	}
}