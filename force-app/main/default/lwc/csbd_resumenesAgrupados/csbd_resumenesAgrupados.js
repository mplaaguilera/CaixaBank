import {LightningElement, track, api, wire} from 'lwc';

import {NavigationMixin} from 'lightning/navigation';

import mensajeIAResponsable from '@salesforce/label/c.CSBD_MensajeIAResponsable';
import {log} from 'lightning/logger';


//habilitar el codigo para mixin navigation
export default class Csbd_resumenesAgrupados extends NavigationMixin(LightningElement) {

    @api recordId;

    @api planOpo;

    @api planAmpli;

    @api planProd;

    @api planArg;

    primerAcceso = true;

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