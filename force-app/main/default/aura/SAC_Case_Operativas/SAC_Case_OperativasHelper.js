({
	reinit : function(component) {
        var getCaso = component.get('c.recuperarCaso');
        getCaso.setParam('caseId', component.get('v.recordId'));
		getCaso.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.caso', response.getReturnValue());
                //Get userId
                var getUser = component.get('c.recuperarUser');
                getUser.setCallback(this, function(response){
                	component.set('v.user', response.getReturnValue().UserId);
                    component.set('v.esPropietario', component.get('v.user') === component.get('v.caso.OwnerId'));
					component.set('v.isLoading', false);
				});				
				$A.get('e.force:refreshView').fire();
				$A.enqueueAction(getUser); 
        	}            
        });
        
		$A.enqueueAction(getCaso); 
	},

	fetchMotivos: function(component, event) {
        var action = component.get("c.fetchMotivos");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({value: key, label: result[key]});
                }
                component.set("v.motivosDevolver", fieldMap);
            }
        });
			
        $A.enqueueAction(action);
    },

	fetchGruposLetrado: function(component, event){

        var action = component.get("c.getGruposLetrado");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({value: key, label: result[key]});
                }
                component.set("v.gruposLetrado", fieldMap);
            }
        });
			
        $A.enqueueAction(action);

	},
	
	closeLightningTab : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
       })
        .catch(function(error) {
            console.log(error);
        });
    
	 },

	getGruposClasificacion: function(component) {
		let getGruposMCC = component.get('c.getGruposMCC');
		getGruposMCC.setParam('recordId', component.get('v.recordId'));
		getGruposMCC.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.gruposClasificacionOptions', response.getReturnValue());
			}
			window.setTimeout($A.getCallback(() => component.find('gruposClasificacion').focus()), 25);
		});
		$A.enqueueAction(getGruposMCC);
	},

	getGruposBusqueda: function(component) {
		let buscarGruposColaboradores = component.get('c.buscarGruposColaboradores');
		buscarGruposColaboradores.setParam('cadenaBusqueda', component.get('v.literalBusquedaGrupo'));
		buscarGruposColaboradores.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.listOfSearchRecords', response.getReturnValue());
			}
		});
		$A.enqueueAction(buscarGruposColaboradores);
	},

	loadCarpetasIdioma: function(component) {
		let operativa = component.get('v.tipoOperativa');
		let idioma = component.get('v.caso.CC_Idioma__c');
		let carpetaOperativa;
		if (operativa === 'responderCliente') {
			/*if (component.get('v.caso.RecordType.DeveloperName') === 'OS_Empleado') {
				carpetaOperativa = 'OS_Responder_Empleado';
			} else {
				carpetaOperativa = 'OS_Responder';
			}*/
			carpetaOperativa = 'OS_Responder';
		} else if (operativa === 'solicitar') {
			/*if (component.get('v.caso.RecordType.DeveloperName') === 'OS_Empleado') {
				carpetaOperativa = 'OS_Solicitar_Empleado';
			} else {
				carpetaOperativa = 'OS_Solicitar';
			}*/
			carpetaOperativa = 'OS_Solicitar';
		}

		let getCarpetasIdioma = component.get('c.getCarpetas');
		getCarpetasIdioma.setParam('carpetaDeveloperName', carpetaOperativa);
		getCarpetasIdioma.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let opcionesIdiomaFolder = [];
				let opciones = response.getReturnValue();
				opciones.forEach(opcion => opcionesIdiomaFolder.push({'value': opcion.DeveloperName, 'label': opcion.Name}));
				component.set('v.opcionesIdiomaCarpeta', opcionesIdiomaFolder);
				if (operativa === 'responderCliente') {
					component.set('v.idiomaPlantilla', 'OS_Responder_' + idioma);
				} else if (operativa === 'solicitar') {
					component.set('v.idiomaPlantilla', 'OS_Solicitar_' + idioma);
				}
				$A.enqueueAction(component.get('c.handleCarpetaIdiomaSeleccionada'));
			}
		});
		$A.enqueueAction(getCarpetasIdioma);
	},

	loadCarpetasTratamiento: function(component) {
		let opcionesTratamientoFolder = [];
		let getCarpetasTratamiento = component.get('c.getCarpetas');
		getCarpetasTratamiento.setParam('carpetaDeveloperName', component.get('v.idiomaPlantilla'));
		getCarpetasTratamiento.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let arr = response.getReturnValue();
				arr.forEach(element => opcionesTratamientoFolder.push({'value': element.DeveloperName, 'label': element.Name}));
				component.set('v.opcionesTratamientoCarpeta', opcionesTratamientoFolder);
				if (opcionesTratamientoFolder.length === 1) {
					//Se selecciona automáticamente el único tratamiento disponible para el idioma seleccionado
					if (component.get('v.tipoOperativa') === 'solicitar') {
						component.find('selectItemTratamientoSol').set('v.value', opcionesTratamientoFolder[0].value);
					} else if (component.get('v.tipoOperativa') === 'responderCliente') {
						component.find('selectItemTratamiento').set('v.value', opcionesTratamientoFolder[0].value);
					}
					$A.enqueueAction(component.get('c.handleCarpetaTratamientoSeleccionada'));
				} else {
					//Se pone en el foco en el campo de tratamiento del modal correspondiente
					if (component.get('v.tipoOperativa') === 'solicitar') {
						window.setTimeout($A.getCallback(() => component.find('selectItemTratamientoSol').focus()), 20);
					} else {
						window.setTimeout($A.getCallback(() => component.find('selectItemTratamiento').focus()), 20);
					}
				}
			}
		});
		$A.enqueueAction(getCarpetasTratamiento);
	},

	buscarPlantillas: function(component) {
		let getPlantillas = component.get('c.buscarPlantillas');
		getPlantillas.setParam('cadenaBusqueda', component.get('v.literalBusquedaPlantilla'));
		getPlantillas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.listOfSearchRecordsPlantilla', response.getReturnValue());
			}
		});
		$A.enqueueAction(getPlantillas);
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissable', 'duration': 4000});
		toastEvent.fire();
	},

	abrirTab: function(component, tabRecordId) {
		component.find('workspace').openTab({'recordId': tabRecordId, 'focus': true});
		component.find('caseData').saveRecord($A.getCallback(() => {}));
	},
	setDataAnexos: function(component){
		var data;
		let getAnexos = component.get('c.getFilesCase');
		getAnexos.setParam('casoId', component.get('v.recordId'));
		getAnexos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.dataAnexos', response.getReturnValue());
			}
		});
		$A.enqueueAction(getAnexos);
		/*var data;

		data= [
            {id: 101, name: "First record"},
            {id: 202, name: "Second record"},
            {id: 303, name: "Third record"},
            {id: 404, name: "Fourth record"},
            {id: 505, name: "Fifth record"}
        ];
		component.set('v.dataAnexos', data);*/
	},
	fetchCR: function(component){
		
		var action = component.get('c.fetchCRsController');
		action.setCallback(this, function(response){
			var values=[];
			var result = response.getReturnValue();
			for(var key in result){
				values.push({
					label:result[key],
					value:key});
				
			}
			component.set('v.CRs', values);
			
		});
		
		$A.enqueueAction(action);
	},
	fetchCRSeguimiento: function(component){
		
		var action = component.get('c.fetchCRSeguimientoController');
		action.setCallback(this, function(response){
			var values=[];
			var result = response.getReturnValue();
			for(var key in result){
				values.push({
					label:result[key],
					value:key});
				
			}
			component.set('v.CRs', values);
			
		});
		
		$A.enqueueAction(action);
	},
	fetchEmail: function(component){
		
		var actionEm = component.get('c.fetchEmailsCaso');
		actionEm.setParam('caseId', component.get('v.recordId'));
		actionEm.setCallback(this, function(response){
			var values=[];
			var result = response.getReturnValue();
			for(var key in result){
				values.push({
					label:result[key],
					value:key});
				
			}
			component.set('v.Emailcaso', values);
			
		});
		
		$A.enqueueAction(actionEm);
	},

	fetchEmailcaso: function(component){
		
		var actionEm = component.get('c.fetchEmailsCaso');
		actionEm.setParam('caseId', component.get('v.caseId'));
		actionEm.setCallback(this, function(response){
			var values=[];
			var result = response.getReturnValue();
			for(var key in result){
				values.push({
					label:result[key],
					value:key});
				
			}
			component.set('v.Emailcaso', values);
			
		});
		
		$A.enqueueAction(actionEm);
	}	
	
});