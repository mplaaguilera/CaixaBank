({
	recordDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {

			var alternateDisplayFields = ['CC_Tematica_Formula__c', 'CC_Producto_Servicio_Formula__c', 'SEG_Motivo_Formula__c','SEG_Detalle_Formula__c'];
			component.set('v.alternateDisplayField', alternateDisplayFields);
			component.set('v.showDetalle', true);
			//Se muestra el campo de búsqueda si el caso no tiene clasificación
			/*
			if (!component.get('v.caso.CC_MCC_Tematica__r.Name')) {
				component.set('v.mostrarBuscador', true);
			}*/
			if (event.getParams().changeType === 'CHANGED') {
				/*Refrescar los datos del LC. */
				component.find('caseData').reloadRecord();
			}
			
			let campos = component.get('v.campos');
			let add = true; 
			campos.forEach(campo => {
				if(campo === 'SEG_Detalle__r.Name'){
					add = false;
				}
			});
			
			if(add){
				campos.push('SEG_Detalle__r.Name');
				component.set('v.campos', campos);
				component.find('caseData').reloadRecord(true);				
			}
			
			if(component.get('v.caso.SEG_Detalle__c')){
				component.set('v.lookupId', component.get('v.caso.SEG_Detalle__c'));
				component.set('v.mostrarBuscador', false);
			}else if(component.get('v.caso.CC_MCC_Motivo__c')){
				component.set('v.mostrarBuscador', false);
				component.set('v.lookupId', component.get('v.caso.CC_MCC_Motivo__c'));
			}else if(component.get('v.caso.CC_MCC_ProdServ__c')){
				component.set('v.lookupId', component.get('v.caso.CC_MCC_ProdServ__c'));
				component.set('v.mostrarBuscador', false);
			}else if(component.get('v.caso.CC_MCC_Tematica__c')){
				component.set('v.lookupId', component.get('v.caso.CC_MCC_Tematica__c'));
				component.set('v.mostrarBuscador', false);
			}else{
				component.set('v.mostrarBuscador', true);
			}
			
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.ldsError'));
		}
	}, 
	
	searchRecords: function(component, event, helper) {
		let enteredValue = component.get('v.enteredValue');
		let objectList = component.get('v.objectList');
		let selectedObjectIndex = component.get('v.selectedIndex');

		switch (event.which) {
			case 38: //up key
				if (objectList.length > 0) {
					if (selectedObjectIndex !== null && selectedObjectIndex - 1 >= 0) {
						selectedObjectIndex--;
					} else if (selectedObjectIndex !== null && selectedObjectIndex - 1 < 0 || selectedObjectIndex === null) {
						selectedObjectIndex = objectList.length - 1;
					}
					component.set('v.selectedIndex', selectedObjectIndex);
				}
				break;

			case 40: //down key
				if (objectList.length > 0) {
					if (selectedObjectIndex !== null && selectedObjectIndex + 1 < objectList.length) {
						selectedObjectIndex++;
					} else if (selectedObjectIndex !== null && selectedObjectIndex + 1 === objectList.length || selectedObjectIndex === null) {
						selectedObjectIndex = 0;
					}
					component.set('v.selectedIndex', selectedObjectIndex);
				}
				break;

			case 27: //escape key
				component.set('v.objectList', []);
				component.set('v.lookupInputFocused', false);
				break;

			case 13: //enterKey
				helper.onValueSelect(component);
				break;

			case 39: //Right Key
			case 37: //Left Key
			case 35: //home
			case 36: //End
			case 16: //Shift
			case 17: //Control
			case 18: //Alt
				//Sin acciones
				break;

			default: //cualquier otra tecla
				//Reseteo de los atributos de los resultados antes de hacer una nueva consulta
				component.set('v.selectedObject', null);
				component.set('v.selectedObjectDisplayName', '');
				component.set('v.queryErrorMessage', '');
				component.set('v.queryErrorFound', false);

				if (enteredValue.length >= 3) {
					//Se cancela la búsqueda pendiente anterior
					clearTimeout(component.get('v.idTimeout'));

					//Se programa la búsqueda para al cabo de unos ms (reduce el nombre de
					//consultas lanzadas mientras el usuario escribe los términos de búsqueda)
					component.set('v.idTimeout', setTimeout($A.getCallback(() => {
						component.set('v.searching', true);
						component.set('v.objectList', []);
						
						let queryString = '';						
						queryString = 'SELECT CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, SEG_Motivo_Formula__c,SEG_Detalle_Formula__c, CC_Detalle__c, Name FROM CC_MCC__c WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%' + enteredValue.replace(/ /g, '%') + '%\'';
						queryString += ' AND RecordType.DeveloperName IN (\'CC_Motivo\',\'SEG_Detalle\') AND CC_Tipo_Cliente__c IN (\'Segmentos\') AND CC_Activo__c = true AND SEG_Organizacion__c INCLUDES(\'' + component.get('v.caso.SEG_Organizacion__c') + '\')';
						
						// Force cache.
						var fecha = new Date();
						var timeCacheValid = fecha.getFullYear().toString(10) + '_' + fecha.getMonth().toString(10) + '_' + fecha.getDay().toString(10) + '_' + fecha.getHours().toString(10);
						var minutos = fecha.getMinutes();
						if (minutos <= 20){
							timeCacheValid = timeCacheValid + '_20';
						}else if (minutos <= 40){
							timeCacheValid = timeCacheValid + '_40';
						}else{
							timeCacheValid = timeCacheValid + '_60';
						} 
	
						let querySalesforceRecord = component.get('c.querySalesforceRecord');
						querySalesforceRecord.setParams({
							'queryString': queryString
						});
						querySalesforceRecord.setCallback(this, response => {
							if (response.getState() === 'SUCCESS') {
								component.set('v.objectList', response.getReturnValue());
								component.set('v.searching', false);
								component.set('v.selectedIndex', 0); 
							} else {
								console.error(response.getError()[0].message);
								component.set('v.queryErrorMessage', response.getError()[0].message);
								component.set('v.queryErrorFound', true);
								//component.set('v.objectList', []);
								component.set('v.selectedIndex', null);
								component.set('v.searching', false);
							}
						});
						$A.enqueueAction(querySalesforceRecord);
					}), 400));
				} else {
					component.set('v.objectList', []);
					component.set('v.selectedIndex', null);
					component.set('v.searching', false);
				}
		} 
	},
	
	showColorOnMouseEnter: function(component, event) {
		$A.util.addClass(event.currentTarget, 'highlight');
	},

	hideColorOnMouseLeave: function(component, event) {
		$A.util.removeClass(event.currentTarget, 'highlight');
	},
	/*
	inputBlurred: function(component) {
		if (component.get('v.objectList').length === 0) {
			$A.util.removeClass(component.find('sinResultadosBusqueda'), 'cc-fade-in');
			$A.util.addClass(component.find('sinResultadosBusqueda'), 'cc-fade-out');
		} else {
			$A.util.removeClass(component.find('resultadosBusqueda'), 'cc-fade-in');
			$A.util.addClass(component.find('resultadosBusqueda'), 'cc-fade-out');
		}
		component.set(
			'v.idTimeoutFade',
			window.setTimeout($A.getCallback(() => component.set('v.lookupInputFocused', false)), 500)
		);
	},
	*/
	
	inputInFocus: function(component) {
		clearTimeout(component.get('v.idTimeoutFade'));
		component.set('v.lookupInputFocused', true);
		if (component.get('v.objectList').length === 0) {
			$A.util.removeClass(component.find('sinResultadosBusqueda'), 'cc-fade-out');
			$A.util.addClass(component.find('sinResultadosBusqueda'), 'cc-fade-in');
		} else {
			$A.util.removeClass(component.find('resultadosBusqueda'), 'cc-fade-out');
			$A.util.addClass(component.find('resultadosBusqueda'), 'cc-fade-in');
		}
	},
	
	removeSelectedOption: function(component) {
		component.set('v.selectedIndex', null);
		component.set('v.selectedObject', null);
		component.set('v.selectedObjectDisplayName', '');
		component.set('v.value', null);
		//component.set('v.lookupId', '');
	},

	onRowSelected: function(component, event, helper) {
		component.set('v.selectedIndex', parseInt(event.currentTarget.dataset.currentIndex, 10));
		helper.onValueSelect(component);
	},
	
	mostrarBuscador: function(component) {
		// Fix reset variables. Error de pintado de componente.
		component.set('v.selectedIndex', null);
		component.set('v.selectedObject', null);
		component.set('v.selectedObjectDisplayName', '');
		component.set('v.value', null);
		//component.set('v.lookupId', ''); 

		if (component.get('v.mostrarBuscador')) { 
			component.set('v.mostrarBuscador', false);
		} else { 
			component.set('v.mostrarBuscador', true);
			window.setTimeout($A.getCallback(() => component.find('lookUpInputElement').focus()), 15);
		}
	}
	
});