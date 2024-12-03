import {LightningElement, track, api, wire} from 'lwc';
import {log} from 'lightning/logger';
import {NavigationMixin} from 'lightning/navigation';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';

import mensajeIAResponsable from '@salesforce/label/c.CSBD_MensajeIAResponsable';

import IDPRODUCTO from '@salesforce/schema/Opportunity.CSBD_Producto__c';


//import obtenerProductoOportunidad from '@salesforce/apex/CSBD_ChatGPT_Controller.obtenerProductoOportunidad';
import obtenerMetadataPrompts from '@salesforce/apex/CSBD_ChatGPT_Controller.obtenerMetadataPrompts';

//habilitar el codigo para mixin navigation
export default class Csbd_resumenesAgrupados extends NavigationMixin(LightningElement) {

    @api recordId;

    @api planOpo;

    @api planAmpli;

    @api planProd;

    @api planArg;

    primerAcceso = true;

    //nombre del producto
    @wire(getRecord, {recordId: '$recordId', fields: [IDPRODUCTO]}) oportunidad;

    //wire para obtener el prompt a utilizar
    @wire(obtenerMetadataPrompts, {producto: '$producto'})
    wiredPrompts({error, data}) {
    	if (data) {
    		this.planArg = data[0].CSBD_PromptArgumentarioAUtilizar__c;
    		this.planOpo = data[0].CSBD_PromptOportunidadAUtilizar__c;
    		this.planAmpli = data[0].CSBD_PromptAmpliadaAUtilizar__c;
    		this.planProd = data[0].CSBD_PromptProductoAUtilizar__c;

    		console.log('this.planArg ' + this.planArg);
    	} else if (error) {
    		console.error('Error fetching prompts: ' + JSON.stringify(error));
    	}
    }

    //obtener el producto de la oportunidad
    get producto() {
    	return getFieldValue(this.oportunidad.data, IDPRODUCTO);
    }


    //navegar a la vista ampliada
    navigateToParentComponent() {

    	let msg = {
    		identifier: 'GPT Opportunity Tabs',
    		message: 'Click in \'Vista Completa\' button'
    	};
    	log(msg);
    	this[NavigationMixin.Navigate]({
    		type: 'standard__component',
    		attributes: {
    			componentName: 'c__csbd_gptAmpliado'
    		},
    		state: {
    			c__recordId: this.recordId
    		}
    	});
    }

    label = {
    	mensajeIAResponsable
    };

    //capturamos el click a la tab para cazar el evento y ponerlo en el lightning logger
    handleTabClick(event) {
    	//evitar contar el acceso de carga de la página
    	if (!this.primerAcceso) {
    		let msg = {
    			identifier: 'GPT Opportunity Tabs',
    			message: 'Click in ' + event.target.value + ' tab'
    		};
    		log(msg);
    	} else {
    		this.primerAcceso = false;
    	}
    }
}