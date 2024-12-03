({
	recordDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			//Se actualiza el atributo esPropietario para habilitar/deshabilitar el botón de guardado
			component.set('v.esPropietario', $A.get('$SObjectType.CurrentUser.Id') === component.get('v.caso.OwnerId'));
			
			if (event.getParams().changeType === 'CHANGED') {
				component.find('caseData').reloadRecord();
			}
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.ldsError'));
		}
	},

	abrirModalAsociarCaso: function(component) {
		component.set('v.renderModalFusionar', true);
		$A.util.addClass(component.find('backdrop'));
		$A.util.addClass(component.find('modalAsociarCaso'), 'slds-fade-in-open');
	},

	cerrarModalAsociarCaso: function(component) {
		$A.util.removeClass(component.find('modalAsociarCaso'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'));
		component.set('v.renderModalFusionar', false);
	},

	modalAsociarCasoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalAsociarCaso'));
		}
	},

	tomarPropiedad: function(component, event, helper) {
		component.set('v.caso.OwnerId', $A.get('$SObjectType.CurrentUser.Id'));
		component.find('caseData').saveRecord($A.getCallback(saveResult => {
			if (saveResult.state === 'SUCCESS') {
				helper.mostrarToast('success', 'Se reasignó Caso', 'Ahora es el propietario del caso ' + component.get('v.caso.CaseNumber'));
			} else if (saveResult.state === 'ERROR') {
				helper.mostrarToast('error', 'No se reasignó Caso', JSON.stringify(saveResult.error));
			}
		}));
	}
});