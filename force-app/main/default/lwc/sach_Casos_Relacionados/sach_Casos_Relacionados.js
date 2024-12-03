import {LightningElement, api, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import getCasosRelacionados from '@salesforce/apex/SACH_Casos_Relacionados.getCasosRelacionados';

//eslint-disable-next-line camelcase
export default class sach_Casos_Relacionados extends LightningElement {
	@api recordId;

	datatableColumnas = [
		{label: 'Fecha de creación', fieldName: 'CreatedDate', type: 'date', initialWidth: 130, typeAttributes: {
			year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit'
		}},
		{label: 'Interviniente', fieldName: 'esInterviniente', type: 'boolean', initialWidth: 106, cellAttributes: {alignment: 'center'}},
		{label: 'Caso', fieldName: 'caseNumberUrl', type: 'url', initialWidth: 100, typeAttributes: {label: {fieldName: 'CaseNumber'}}},
		{label: 'Estado', fieldName: 'Status'},
		{label: 'Asunto', fieldName: 'Subject'},
		{label: 'Canal de entrada', fieldName: 'Origin', initialWidth: 154},
		{label: 'Propietario', fieldName: 'ownerUrl', type: 'url', initialWidth: 135, typeAttributes: {label: {fieldName: 'ownerName'}}},
		{label: 'Caso histórico', fieldName: 'SACH_Caso_Migrado__c', type: 'boolean', initialWidth: 110, cellAttributes: {alignment: 'center'}}
	];

	datatableData = [];

	@wire(getCasosRelacionados, {recordId: '$recordId'})
	wiredRecord({error, data}) {
		if (error) {
			console.error(JSON.stringify(error));
			this.dispatchEvent(new ShowToastEvent({
				variant: 'error',
				mode: 'dismissable',
				title: 'Error obteniendo los casos relacionados',
				message: JSON.stringify(error),
			}));
		} else if (data) {
			this.datatableData = data.map(caso => ({
				...caso,
				caseNumberUrl: '/' + caso.Id,
				esInterviniente: caso.SACH_Interviniente__c === this.recordId,
				ownerName: caso.Owner.Name,
				ownerUrl: '/' + caso.OwnerId
			}));
		}
	}
}