({
	recordDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			let recordTypeDevName = component.get('v.llamadaRecord.RecordType.DeveloperName');
			let negocio = recordTypeDevName.substring(0, recordTypeDevName.indexOf('_') + 1);

			if (negocio === 'OS_') {
				component.set('v.botonLlamadaDeshabilitado', !component.get('v.llamadaRecord.OS_Nombre_Fichero_Grabacion__c'));
				component.set('v.botonConsultaDeshabilitado', true);
			} else {
				component.set('v.botonLlamadaDeshabilitado', !component.get('v.llamadaRecord.CC_ConnId__c'));
				component.set('v.botonConsultaDeshabilitado', !component.get('v.llamadaRecord.CC_ConnId_Consulta__c'));
			}
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorRecordData'));
		}
	},

	obtenerGrabacion: function(component, event, helper) {
		let connId;
		if (event.getSource().getLocalId() === 'botonEscucharLlamada') {
			component.set('v.botonLlamadaDeshabilitado', true);
			connId = component.get('v.llamadaRecord.CC_ConnId__c');
		} else if (event.getSource().getLocalId() === 'botonEscucharConsulta') {
			component.set('v.botonConsultaDeshabilitado', true);
			connId = component.get('v.llamadaRecord.CC_ConnId_Consulta__c');
		}

		if (!component.get('v.llamadaRecord.RecordType.DeveloperName').startsWith('OS_')) {
			//Llamada CC
			let grabacionEnOcp = component.get('c.grabacionEnOcp');
			grabacionEnOcp.setParam('fechaLlamada', component.get('v.llamadaRecord.CC_Fecha_Inicio__c'));
			grabacionEnOcp.setCallback(this, responseGrabacionEnOcp => {
				if (!responseGrabacionEnOcp.getReturnValue()) {
					//Grabación en HCP
					let obtenerUrl = component.get('c.obtenerUrl');
					obtenerUrl.setParams({
						'fechaNice': component.get('v.llamadaRecord.CC_Fecha_Grabacion__c'),
						'extension': component.get('v.llamadaRecord.CC_Extension__c'),
						'connId': connId});
					obtenerUrl.setCallback(this, responseObtenerUrl => {
						if (responseObtenerUrl.getState() === 'SUCCESS' && responseObtenerUrl.getReturnValue()) {
							let urlEvent = $A.get('e.force:navigateToURL');
							urlEvent.setParam('url', responseObtenerUrl.getReturnValue());
							//urlEvent.setParam('url', 'https://cccontent-pre1.multipre.objst1cd1.lacaixa.es/rest/2019-10-22_007402E92A5F6A80_6917000.mp3');
							urlEvent.fire();
						} else {
							helper.mostrarToast('error', 'Grabación no disponible', 'Ha habido un problema descargando la grabación.');
						}
					});
					$A.enqueueAction(obtenerUrl);
				} else {
					//Grabación en OCP
					$A.enqueueAction(component.get('c.abrirOcp'));
				}
			});
			$A.enqueueAction(grabacionEnOcp);
		} else {
			//Llamada COPS
			let obtenerUrlCOPS = component.get('c.obtenerUrlCOPS');
			obtenerUrlCOPS.setParam('nombreFicheroGrabacion', component.get('v.llamadaRecord.OS_Nombre_Fichero_Grabacion__c'));
			obtenerUrlCOPS.setCallback(this, response => {
				if (response.getState() === 'SUCCESS' && response.getReturnValue()) {
					let urlEvent = $A.get('e.force:navigateToURL');
					urlEvent.setParam('url', response.getReturnValue());
					urlEvent.fire();
				} else {
					helper.mostrarToast('error', 'Grabación no disponible', 'Ha habido un problema descargando la grabación.');
				}
			});
			$A.enqueueAction(obtenerUrlCOPS);
		}
	},

	abrirOcp: function(component, event, helper) {
		let datosUrlGrabacion = component.get('c.datosUrlGrabacion');
		datosUrlGrabacion.setParam('idLlamada', component.get('v.recordId'));
		datosUrlGrabacion.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let resp = response.getReturnValue();

				//Verificar si es una URL de Genesys Cloud
				if (resp.genesysCloudUrl) {
					//Si es una URL de Genesys Cloud, abrirla directamente
					let urlEvent = $A.get('e.force:navigateToURL');
					urlEvent.setParam('url', resp.genesysCloudUrl);
					urlEvent.fire();
				} else {
					//Si no, seguir con el flujo tradicional de OCP
					let validacion = 'idDoc:' + resp.tiquet + ';appId:' + resp.appid + ';username:' + resp.username + ';timestamp:' + resp.timestamp;
					//eslint-disable-next-line no-undef
					let crypt = new JSEncrypt();
					crypt.setPublicKey(resp.publicKey);
					let validacionb64 = encodeURIComponent(crypt.encrypt(validacion));
					let authb64 = encodeURIComponent(btoa(resp.appid + ':' + resp.username + ':' + resp.canal));
					let url = resp.baseUrl + '/?auth=' + authb64 + '&validacion=' + validacionb64;
					window.open(url, '_blank');
				}
			} else if (response.getState() === 'ERROR') {
				//Mostrar el mensaje de error si no tiene permisos para acceder a la grabación MIFID
				let errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
					helper.mostrarToast('error', 'Acceso denegado', errors[0].message);
				} else {
					helper.mostrarToast('error', 'Grabación no disponible', 'Ha ocurrido un error al intentar acceder a la grabación.');
				}
			}
		});
		$A.enqueueAction(datosUrlGrabacion);
	}
});