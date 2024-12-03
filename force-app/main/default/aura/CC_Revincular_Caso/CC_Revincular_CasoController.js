/* eslint-disable no-undef */
({
	doInit: function(component) {
    
		let getCaso = component.get('c.getCaso');
		getCaso.setParams({'recordId': component.get('v.recordId')});
		getCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				component.set('v.oCaso', retorno.CASO);
				component.set('v.CC_ContactoRelacionado', retorno.CASO.CC_ContactoRelacionado__c);
				component.set('v.CaseNumber', retorno.CASO.CaseNumber);
				component.set('v.bHabilitado', retorno.HABILITADO);
				component.set('v.bMensaje', retorno.MENSAJE);
				component.set('v.oCasosContacto', retorno.CASOSCONTACTO);
            	component.set('v.esRecType', retorno.RECORDTYPECC);
                
				component.find('CC_ContactoRelacionado').set('v.value', retorno.CASO.CC_ContactoRelacionado__c);
				$A.enqueueAction(component.get('c.contactoSelect'));
				//window.setTimeout($A.getCallback(() => $A.enqueueAction(component.get('c.contactoSelect'))), );
			}
		});
		$A.enqueueAction(getCaso);
        
		component.set('v.oColumnas', [{label: 'Caso', fieldName: 'CaseNumber', initialWidth: 95, type: 'text'},
			{label: 'Título', fieldName: 'Subject', type: 'text', initialWidth: 405},
			{label: 'Fecha creación', fieldName: 'CreatedDate', initialWidth: 145, type: 'date'},
			{label: 'Ver', type: 'button', initialWidth: 75, typeAttributes:
                                            {label: { fieldName: 'vercasoLabel'}, title: 'Visualizar', name: 'view_case', iconName: 'utility:preview', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}},
			{label: 'Fusionar', type: 'button', initialWidth: 75, typeAttributes:
                                            {label: {fieldName: 'asociarLabel'}, title: 'Asociar', name: 'asociar_case', iconName: 'utility:merge', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}}]);
	
    
    },
    
	handleRowAction: function(component, event, helper) {
		switch (event.getParam('action').name) {
			case 'view_case':
				helper.verCaso(event.getParam('row').Id);
				break;

			case 'asociar_case':
				component.set('v.vcaso', event.getParam('row').Id);
				$A.util.addClass(component.find('modalConfirmacion'), 'slds-fade-in-open');
				$A.util.addClass(component.find('backdropConfirmacion'), 'slds-backdrop_open');
				break;
		}
	},
    
	verCaso: function(component, event, helper) {
		let idCaso = component.get('v.vcaso') + '';
		helper.verCaso(idCaso);
	},
    
	abrirModalConfirmacion: function(component) {
		$A.util.addClass(component.find('modalConfirmacion'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdropConfirmacion'), 'slds-backdrop_open');
	},
    
	contactoSelect: function(component) {
		let getCasosContacto = component.get('c.getCasosContacto');
		getCasosContacto.setParams({
			//'contactId': event.getParam('value') + '',
			'contactId': component.find('CC_ContactoRelacionado').get('v.value'),
			'recordId': component.get('v.recordId') + '',
			'proyecto': component.get('v.proyecto')
		});
		getCasosContacto.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.oCasosContacto', response.getReturnValue());
			}
		});
		$A.enqueueAction(getCasosContacto);
	},

	casoSelect: function(component, event) {
		component.set('v.vcaso', String(event.getParam('value')));
	},

	asociarCaso: function(component, event, helper) {
		helper.asociarCaso(component);
		$A.util.removeClass(component.find('modalConfirmacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdropConfirmacion'), 'slds-backdrop_open');
	},

	cancelModal: function(component) {
		$A.util.removeClass(component.find('modalConfirmacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdropConfirmacion'), 'slds-backdrop_open');
	},

	finCargando: function(component) {
		component.set('v.cargando', false);
	}
    
    
});