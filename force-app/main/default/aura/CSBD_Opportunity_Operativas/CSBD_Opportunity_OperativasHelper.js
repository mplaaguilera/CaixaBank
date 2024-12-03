({
	apex: function(component, apexMethodName, args) {
		return new Promise($A.getCallback((resolve, reject) => {
			try {
				let apex = component.get('c.' + apexMethodName);
				apex.setParams(args ? args : {});
				apex.setCallback(this, response => {
					try {
						const state = response.getState();
						if (state === 'SUCCESS') {
							resolve(response.getReturnValue());
						} else if (state === 'ERROR') {
							const errors = apex.getError();
							console.error(errors);
							if (errors && errors[0] && errors[0].message) {
								reject(errors[0].message);
							} else {
								console.error(errors);
								reject(errors);
							}
						}
					} catch (errorCallback) {
						console.error(errorCallback);
						reject(errorCallback);
					}
				});
				$A.enqueueAction(apex);
			} catch (error) {
				console.error(error);
				reject(error);
			}
		}));
	},

	copiarTextoAlPortapapeles: function(texto, mensajeToast) {
		const textarea = document.createElement('textarea');
		textarea.value = texto;
		document.body.appendChild(textarea);
		textarea.select();
		document.execCommand('copy');
		document.body.removeChild(textarea);

		if (mensajeToast) {
			this.mostrarToast('NIF copiado al portapapeles', mensajeToast, 'info');
		}
	},

	mostrarToast: function(titulo, mensaje, tipo) {
		if (mensaje.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
			mensaje = mensaje.substring(mensaje.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35, mensaje.lastIndexOf(': ['));
		}
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({title: titulo, message: mensaje, type: tipo, mode: 'dismissable', duration: 4000});
		toastEvent.fire();
	},

	mostrarToastSticky: function(titulo, mensaje, tipo) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({title: titulo, message: mensaje, type: tipo, mode: 'sticky'});
		toastEvent.fire();
	},

	seleccionarControl: function(component, nombreControl, delay) {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find(nombreControl).focus()), delay);
	},

	formatearFecha: function(startDateTime) {
		return $A.localizationService.formatDate(startDateTime, 'EEEE d') + ' de ' +
        $A.localizationService.formatDate(startDateTime, 'MMMM') + ' de ' +
        $A.localizationService.formatDate(startDateTime, 'yyyy') + ' a las ' +
        $A.localizationService.formatDate(startDateTime, 'k:mm') + ' horas.';
	},

	formatearFechaTramo: function(startDateTime, endDateTime) {
		return $A.localizationService.formatDate(startDateTime.valueOf(), 'EEEE d') + ' de ' +
            $A.localizationService.formatDate(startDateTime.valueOf(), 'MMMM') + ' de ' +
            $A.localizationService.formatDate(startDateTime.valueOf(), 'yyyy') + ' entre las ' +
            $A.localizationService.formatDate(startDateTime.valueOf(), 'k:mm') + ' horas y las ' +
            $A.localizationService.formatDate(endDateTime.valueOf(), 'k:mm') + ' horas.';
	},

	abrirTab: function(component, tabRecordId) {
		component.find('workspace').openTab({recordId: tabRecordId, focus: true});
	},

	modalSiaFormatearFecha: function(fecha) {
		const fechaHora = new Date(fecha);
		const dia = fechaHora.getDate();
		const mes = fechaHora.getMonth() + 1;
		const anyo = fechaHora.getFullYear();
		return (dia < 10 ? '0' : '') + dia + '/' + (mes < 10 ? '0' : '') + mes + '/' + anyo;
	},

	modalSiaAnimarBotonCopiar: function(component, idBoton) {
		let boton = component.find(idBoton);
		$A.util.addClass(boton, 'copiarOk');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => $A.util.removeClass(boton, 'copiarOk')), 600);
	},

	formatImporte: function(importe) {
		return importe ? importe.toLocaleString() + '€' : '';
	},

	formatPorcentaje: function(porcentaje) {
		return porcentaje ? porcentaje.toLocaleString() + '%' : '';
	},

	formatCalculo: function(valor, decimales, sinDecimalesExtra) {
		if (valor) {
			let valorFormateado = (Math.round((valor * 100 + Number.EPSILON) * 1000) / 1000).toFixed(decimales);
			sinDecimalesExtra && (valorFormateado = parseFloat(valorFormateado));
			return valorFormateado;
		}
		return null;
	},

	informeSiaDescripcionTitulares: function(opp, datosCalculo) {
		let retorno = '(?)';
		if (opp.Account || opp.CSBD_ContactoTitular1__c) {
			const hayPrimerTitular = datosCalculo && Object.keys(datosCalculo.primerTitular).length;
			const haySegundoTitular = datosCalculo && Object.keys(datosCalculo.segundoTitular).length;
			const t1Nomina = hayPrimerTitular ? parseFloat(datosCalculo.primerTitular.nominasNetas.ingresos) : '';
			const t1pagas = hayPrimerTitular ? parseInt(datosCalculo.primerTitular.nominasNetas.numPagosImpuestos, 10) : '';
			const t2Nomina = haySegundoTitular ? parseFloat(datosCalculo.segundoTitular.nominasNetas.ingresos) : '';
			const t2Pagas = haySegundoTitular ? parseInt(datosCalculo.segundoTitular.nominasNetas.numPagosImpuestos, 10) : '';

			const formatDato = dato => dato ? dato : '(?)';
			retorno = `${opp.Account ? opp.Account.Name : opp.CSBD_ContactoTitular1__r.Name} trabaja en ${formatDato(opp.CSBD_ContactoTitular1__r.CSBD_Datos_Empresa__c)}`;
			retorno += ` como ${formatDato(opp.CSBD_ContactoTitular1__r.CSBD_Profesion__c)} con una antigüedad de ${formatDato(opp.CSBD_ContactoTitular1__r.CSBD_OC_Anyos_Empresa_Actual__c)} años,`;
			retorno += ` percibiendo unos ingresos mensuales de ${this.formatImporte(t1Nomina)} en ${t1pagas} mensualidades.`;
			retorno += ` Su contrato es de tipo ${formatDato(opp.CSBD_ContactoTitular1__r.CSBD_TipoContrato2__c)}. La vida laboral es de ${formatDato(opp.CSBD_ContactoTitular1__r.CSBD_Anyos_Vida_Laboral__c)} años.`;
			if (opp.CSBD_ContactoTitular2__c) {
				retorno += '\n\n';
				retorno += `${opp.CSBD_ContactoTitular2__r.Name} trabaja en ${formatDato(opp.CSBD_ContactoTitular2__r.CSBD_Datos_Empresa__c)}`;
				retorno += ` como ${formatDato(opp.CSBD_ContactoTitular2__r.CSBD_Profesion__c)} con una antigüedad de ${formatDato(opp.CSBD_ContactoTitular2__r.CSBD_OC_Anyos_Empresa_Actual__c)} años,`;
				retorno += ` percibiendo unos ingresos mensuales de ${this.formatImporte(t2Nomina)} en ${t2Pagas} mensualidades.`;
				retorno += ` Su contrato es de tipo ${formatDato(opp.CSBD_ContactoTitular2__r.CSBD_TipoContrato2__c)}. La vida laboral es de ${formatDato(opp.CSBD_ContactoTitular2__r.CSBD_Anyos_Vida_Laboral__c)} años.`;
			}
		}
		return retorno;
	},

	informeSiaBloqueFincas: function(datosFincas) {
		let retorno = 'Fincas implicadas:';
		if (datosFincas) {
			datosFincas.forEach((finca, i) => {
				retorno += `\n${String.fromCharCode(97 + i)}) ${finca.tipoFinca}: nº ${finca.numeroFinca} del RP nº ${finca.numeroRp} de ${finca.localidad}`;
			});
			retorno += '\n\nPresentamos esta operación con garantía provisional a la espera de la aprobación de la presente operación, momento en que tasaríamos las fincas. Cuadro de distribución hipotecaria con tasación ESTIMADA:\n';
			datosFincas.forEach((finca, i) => {
				retorno += `\nFinca ${String.fromCharCode(97 + i)}) Compraventa: ${this.formatImporte(finca.importeCompraventa)} · Hipoteca: ${this.formatImporte(finca.importeHipoteca)}.`;
			});
		}
		return retorno;
	}
});