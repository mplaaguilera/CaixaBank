({
	init : function(component, event, helper) {
        
        var getCaso = component.get('c.recuperarContrato');
        getCaso.setParam('contratoId', component.get('v.recordId'));
        
        getCaso.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
				
                component.set('v.caso', response.getReturnValue());
                //Get userId
                var getUser = component.get('c.recuperarUser');

                getUser.setCallback(this, function(response){
                
                	component.set('v.user', response.getReturnValue());
                });
				$A.enqueueAction(getUser); 
        	}            
        });
        
		$A.enqueueAction(getCaso); 
	},

	cargarResultados : function(component, event, helper){

		let getResultados = component.get('c.recuperarResultados');
		getResultados.setCallback(this, function(response){
        	var values=[];
            var result = response.getReturnValue();
            for(var key in result){
                values.push({
                    label:result[key],
                    value:key});
               
            }
            component.set('v.resultados', values);
            
        });
        
        $A.enqueueAction(getResultados);


	 },

	searchKeyChange: function(component, event) {
        var searchKey = component.find("searchKey").get("v.value");
        
        var action = component.get("c.findByName");
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(a) {
            component.set("v.gruposC", a.getReturnValue());
        });
		$A.enqueueAction(action);
		
	},   

	selectedRowsAnexos: function(component, event, helper){
		var selectedRows = event.getParam('selectedRows');
        
		var currentSelectedRows = [];
		
		//currentSelectedRows=component.get("v.currentSelectedRowsAnexos");
        selectedRows.forEach(function(selectedRow) {
			currentSelectedRows.push(selectedRow.ContentDocumentId);			
		});
		component.set("v.currentSelectedRowsAnexos", currentSelectedRows);
		
	},
    cerrarModalCasos: function(component){
		component.set("v.rendermostrarModalCasosHijos", false);
		component.set("v.rendermostrarModalCrearCasosEmailRec",false);
		component.set("v.rendermostrarModalImportacion",false);
		component.set("v.loadingUpdateFicheros",false);
		component.set("v.caseNumber","");
		component.set("v.caseId","");
	},
	cerrarModalCasos2: function(component){
		component.set("v.rendermostrarModalCasosHijos", false);
		component.set("v.rendermostrarCasoHijoCreado", false);
		component.set("v.loadingCreandoCaso", false);
		component.set("v.rendermostrarficherocreado",false);
	},  

	importarFicheros: function(component){
		component.set("v.rendermostrarModalImportacion", false);
		var toastficherosImportados = $A.get("e.force:showToast");
		var ficherosList = component.get("v.currentSelectedRowsAnexos");
		var contratoId = component.get("v.recordId");
		var idsFiles=new Array();
		for (var i= 0 ; i < ficherosList.length ; i++){
			idsFiles.push(ficherosList[i]);
		}

		var idListJSON=JSON.stringify(idsFiles);
		var idEmail = component.get("v.selectedEmailSR");
		var nullRows = component.get("v.defaultRows");
		var importarFicheros = component.get("c.importarAnexosSR");
		importarFicheros.setParams({'contratoID': contratoId, 'listFiles': idListJSON});
		importarFicheros.setCallback(this, function(response) {
			var state = response.getState();
			console.log(response.getState());
            if(response.getState() == "SUCCESS") {
				console.log(response.getReturnValue());
				var datosHijo = response.getReturnValue();
				component.set("v.currentSelectedRowsAnexos",nullRows);
				component.set("v.rendermostrarficherocreado", true);
				component.set("v.loadingUpdateFicheros", false);
				toastficherosImportados.setParams({
					"title": "¡Éxito!",
					"message": "Se han importado los ficheros del caso seleccionado",
					"type": "success"
					});
				
					toastficherosImportados.fire(); 
            }
            $A.get("e.force:refreshView").fire(); 
        });
        $A.enqueueAction(importarFicheros);  
		
	},
        
	abrirModalImportarFicheros: function (component, event, helper) {
		var actionEm = component.get('c.fetchContratoCaso');
		actionEm.setParam('contratoId', component.get('v.recordId'));
		actionEm.setCallback(this, function(response){
			var values=[];
			var result = response.getReturnValue();
			for(var key in result){
				values.push({
					label:result[key],
					value:key});
				
			}
			component.set('v.casNum', values);
			
		});
		
		$A.enqueueAction(actionEm);
		component.set("v.columnasAnexos", [
            //{label: "ID", fieldName: "Id", type: "text"},
			{label: "Título", fieldName: "Title", type: "text"},
			{label: "Extensión", fieldName: "FileExtension", type: "text"}
        ]);

        helper.setDataAnexos(component);
		component.set("v.rendermostrarModalImportacion", true);
		
	},
	abrirModalSeleccionarFicheros: function (component, event, helper) {
		
		//rellenar datos de tabla y renderizar posteriormente el modal
		var idcase = component.get("v.caseSelected");
		let getAnexos = component.get('c.getFilesCase');
		getAnexos.setParam('casoId', component.get('v.caseSelected'));
		getAnexos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.dataAnexos', response.getReturnValue());
			}
		});
		$A.enqueueAction(getAnexos);
		component.set("v.columnasAnexos", [
            //{label: "ID", fieldName: "Id", type: "text"},
			{label: "Título", fieldName: "Title", type: "text"},
			{label: "Extensión", fieldName: "FileExtension", type: "text"}
        ]);

        //helper.setDataAnexos(component);
		component.set("v.loadingUpdateFicheros", true);
		
	},

	getCases : function(component) {

        component.set('v.searchAvailable', false);
        component.set('v.contactName', '');
        component.set('v.contactId', '');

        let searchKey = component.find('casNum').get('v.value');
		console.log(searchKey);
         var delayMillis = 500;
         var timeoutId = component.get( 'v.searchTimeoutId' );
         clearTimeout( timeoutId );
         timeoutId = setTimeout( $A.getCallback( function() {
            var action = component.get('c.buscadorCases');
            action.setParams({'searchKey': searchKey});
            action.setCallback(this, function(response) {
                var values=[];
                var result = response.getReturnValue();	
                console.log(result + '   result');
                for(var key in result){
                    console.log(key + '    key')
                    values.push({
                        label:result[key].SEG_N_case_y_subject__c,
                        value:key});       
                        console.log(values);
                        console.log(result[key].SEG_N_case_y_subject__c);
                    }
                if(values[0] != null)
                {
                    component.set('v.mostrarCases', true);
                    component.set('v.cases', values);
                    
                }else{
                    component.set('v.mostrarCases', false);
                }
            });
            $A.enqueueAction(action);
         }), delayMillis );
            
         component.set( 'v.searchTimeoutId', timeoutId );
      
	},
    seleccionarCaso : function(component, event) {

        var selectedItem = event.currentTarget.outerText;
        var selectedId = event.target.id;
        component.set('v.caseNumber', selectedItem)    ;
        component.set('v.caseId', selectedId);
        component.set('v.mostrarCases', false);
        component.set('v.searchAvailable', true);

    }
});