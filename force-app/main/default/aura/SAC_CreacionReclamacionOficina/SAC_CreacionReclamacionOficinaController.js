({
    doInit: function(component) {
       
    },
    load: function(component) {
		//Finalización de la carga del formulario mediante Lightning Data Service
		component.set('v.spinner', false);
		component.set('v.canalEntrada', '');


        let checkRol = component.get('c.getCaseRecordTypeId');
        checkRol.setCallback(this, function(response) {
			var state = response.getState();
			
            if(state == "SUCCESS") {
				var recordTypeId = response.getReturnValue();
				component.set('v.recordTypeRec', recordTypeId);
			}
		});
		$A.enqueueAction(checkRol);

	},

	handleError: function(component, event) {
        var errors = event.getParams();
        //console.log("response", JSON.stringify(errors));
    },

	success: function(component, event, helper) {
		let retorno = event.getParams();
		component.set('v.caseId', retorno.response.id);

	},

	submit: function(component, event) {
		//Envío de la petición de creación
		//event.preventDefault();       // stop the form from submitting
		component.set('v.spinner', true);
	},
	eliminaRepresentante: function(component, event, helper) {
	},
	eliminaCliente: function(component, event, helper) {
		component.set('v.cuentaId', null);
		component.set('v.contactoId', null);
	},



	newCase: function(component, event, helper) {
		component.set('v.viewForm', true);
	},
	closeModal: function(component, event, helper) {
		component.set('v.viewForm', false);
		component.set('v.canalProcedencia');
		component.set('v.canalEntrada');
		component.set('v.canalRespuesta');
		component.set('v.recordTypeRec');

		component.set('v.caseId');
		component.set('v.contactoId');
		component.set('v.cuentaId');
		component.set('v.TipoDeRepresentante');
		component.set('v.TipoDeDocumentoRepresentante');
		component.set('v.NombreRepresentante');
		component.set('v.EmailRepresentante');
		component.set('v.DespachoRepresentante');
		component.set('v.NumeroDelDocumentoRepresentante');
		component.set('v.DireccionPostalRepresentante');
		component.set('v.TelefonoRepresentante');

		component.set('v.verRepresentante',true);
		component.set('v.step','step1');
		component.set('v.mensajeError');
		component.set('v.errorStep',false);
		component.set('v.files');

		$A.get('e.force:refreshView').fire();
	},
	nextStep: function(component, event, helper) {
		let actualStep = component.get('v.step', true);
		switch (actualStep) {
			case "step1":
				helper.validarReclamante(component, event, helper);
				if(!component.get('v.errorStep'))
				{
					component.set('v.step', "step3");
				}
				break;
			case "step2":
				helper.validarRepresentante(component, event, helper);
				if(!component.get('v.errorStep'))
				{
					component.set('v.step', "step3");
				}
				break;
			case "step3":
			/*	component.set('v.step', "step4");
				break;
			case "step4":*/
				component.set('v.step', "step5");
				
				//Añadir permiso editar caso para poder crearlo
				let idCuenta = component.get('v.cuentaId');
				let modificarPermiso = component.get('c.modificarPermisosAccount');
				modificarPermiso.setParams({'cuenta': idCuenta});
				modificarPermiso.setCallback(this, function(response) {
					var state = response.getState();
					if(state == "SUCCESS") {
						//console.log('succes');
					}

					component.find("formularioCaso").submit();
				});
				$A.enqueueAction(modificarPermiso);

				break;
			case "step5":
				//Añadir permiso editar caso para poder crearlo
				let idCuenta2 = component.get('v.cuentaId');
				let modificarPermiso2 = component.get('c.modificarPermisosReadAccount');
				modificarPermiso2.setParams({'cuenta': idCuenta2});
				modificarPermiso2.setCallback(this, function(response) {
					var state = response.getState();
					if(state == "SUCCESS") {
						//console.log('succes');
					}
				});
				$A.enqueueAction(modificarPermiso2);
				
				component.set('v.step', "step6");
				break;
			default:
				console.log('fuera rango');
		}
	},
	previusStep: function(component, event, helper) {
		let actualStep = component.get('v.step', true);
		switch (actualStep) {
			case "step1":
				component.set('v.viewForm', false);
				break;
			case "step2":
				helper.validarRepresentante(component, event, helper);
				if(!component.get('v.errorStep'))
				{
					component.set('v.step', "step1");
				}
				break;
			case "step3":
				component.set('v.step', "step1");
				break;
			case "step4":
				component.set('v.step', "step3");
				break;
			case "step5":
				component.set('v.step', "step3");
				break;
			case "step6":
				component.set('v.step', "step5");
				break;
			default:
				console.log('fuera rango');
		}
	},
	handleUploadFilesFinished: function (component, event) {
		let files = component.get('v.files');

		let uploadedFiles = event.getParam("files");

        for(let i = 0; i < uploadedFiles.length; i++){

            files.push({
                type: 'icon',
                id: uploadedFiles[i].documentId,
                label: uploadedFiles[i].name,
                iconName: 'doctype:attachment'
            });
        }

        component.set('v.files', files);





    }

})