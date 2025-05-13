import {LightningElement, api, wire} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';

const FIELDS = ['Opportunity.CSBD_Datos_Calculo_DTI__c'];

export default class CsbdDatosDTI extends LightningElement {
    @api recordId;

    datosDTI = '';

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    wiredOpportunity({error, data}) {
    	if (data) {
    		const datosCalculo = data.fields.CSBD_Datos_Calculo_DTI__c.value;
    		if (datosCalculo) {
    			try {
    				//Intentar formatear el JSON para mejor visualización
    				const jsonObj = JSON.parse(datosCalculo);
    				this.datosDTI = JSON.stringify(jsonObj, null, 2);
    			} catch (e) {
    				//Si no es un JSON válido, mostrar el texto tal cual
    				this.datosDTI = datosCalculo;
    			}
    		}
    	} else if (error) {
    		console.error('Error obteniendo datos de la oportunidad:', error);
    	}
    }
}