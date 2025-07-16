({
	recuperarPlantilla : function(component, event, helper) {
		var spinner = component.find('mySpinner');
        $A.util.removeClass(spinner, "slds-hide");

		var idCase = component.get("v.recordId");
		var idioma = this.idiomaPlantilla(component, event, helper);
		var motivo = component.get("v.motivoSeleccionado");
		var canal = component.get("v.metodoEnvio");


		var plantillaSubsanacion = component.get('c.getPlantillaSubsanacion');
		plantillaSubsanacion.setParams({'record': idCase,
										'idiomaPlantilla': idioma,
										'motivoSubsanacion': motivo,
										'canalRespuesta': canal});
		plantillaSubsanacion.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var wrapper = response.getReturnValue();
				component.set('v.idTemplateCliente', wrapper.idTemplate);
				//component.set('v.para', wrapper.paraTemplate);
				component.set('v.asunto', wrapper.subjectTemplate);
				component.set('v.cuerpo', wrapper.htmlValueTemplate);
			}
			else{
				component.set('v.asunto', '');
				component.set('v.cuerpo', '');
			}
			$A.util.addClass(spinner, "slds-hide");

		})
		$A.enqueueAction(plantillaSubsanacion);
	},
	idiomaPlantilla : function(component, event, helper) {
		var caso = component.get('v.caso');
		var idiomaPlantilla;
		switch (caso.CC_Idioma__c) {
			case 'es':
				idiomaPlantilla = 'ES';
				break;
			case 'ca':
				idiomaPlantilla = 'CAT';
				break;
				case 'en':
				idiomaPlantilla = 'ING';
				break;
				case 'eu':
				idiomaPlantilla = 'EUSK';
				break;
				case 'va':
				idiomaPlantilla = 'VAL';
				break;
				case 'ga':
				idiomaPlantilla = 'GAL';
				break;
			default:
				idiomaPlantilla = 'ES';

		}
		return idiomaPlantilla;
	},

	setFicherosBorrados: function(component, event){
		let idCase = component.get("v.recordId");
		let obtieneAdjuntos = component.get('c.obtieneAdjuntos');
		obtieneAdjuntos.setParams({'id': idCase});
		obtieneAdjuntos.setCallback(this, function(response) {
			let state = response.getState();
			if (state === "SUCCESS") {
				let ficherosBorrados = [];
				let adjuntos = response.getReturnValue();
				//Los archivos no deberian cargarse en la subsanación
				for(let i = 0; i < adjuntos.length; i++){
					ficherosBorrados.push(adjuntos[i].Id);
				}
				component.set('v.ficherosBorrados', ficherosBorrados);
			}
			else{
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": 'Se ha producido un error',
					"message": 'Se ha producido un error al abrir el componente de subsanación.',
					"type":'error'
				});
				toastEvent.fire();
			}
		})
		$A.enqueueAction(obtieneAdjuntos);
	},

	cargarTagsImgCuerpo: function(component){
        //El rich text borra los atributos 'alt' de las etiquetas img, por lo que cada vez que se actualiza tenemos que recorrer el map de tag de imagenes
        //y en caso de haber imagenes con tag, asignar el tag a cada una de estas

        //Recupero el contenido del cuerpo y el mapa de tag de imagenes
        var cuerpo = component.get("v.cuerpo");
        var imageMap = component.get("v.imageTagsMapPadre");
        
        //Encuentra todas las imagenes del cuerpo
        var parser = new DOMParser();
        var doc = parser.parseFromString(cuerpo, 'text/html');
        var images = Array.from(doc.querySelectorAll('img'));

        //Recorro las imagenes, y si tiene una entrada en el mapa de tags, le añado el atributo 'alt'
        images.forEach(function (image) {
			
            if(imageMap && imageMap.has(image.src)){
                var alt = imageMap.get(image.src);

                if (alt !== undefined && alt !== '') {
                    image.setAttribute('alt', alt);
                }else{
                    component.set('v.todasImgConTag', false);
                }
            }else{
                const baseUrl = doc.baseURI; 

                if(image.src !== baseUrl){
                    component.set('v.todasImgConTag', false);
                }
            }
        });       

        //Actualizo el valor del cuerpo con el contenido actualizado
        var updatedContent = doc.body.innerHTML;
		component.set("v.cuerpo", updatedContent);
    }
})