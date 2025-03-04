({
	refrescarBotones: function(component) {
		const oportunidad = component.get('v.oportunidad');
		const esPropietario = oportunidad.OwnerId === $A.get('$SObjectType.CurrentUser.Id');
		const isClosed = oportunidad.IsClosed;
		const estado = oportunidad.CSBD_Estado__c;
		const imaginBank = oportunidad.CSBD_Empresa_Proveedora__c === 'imaginBank';
		const contactoInformado = Boolean(oportunidad.CSBD_Contact__c);
		let botonesActivos = {};
		component.set('v.esPropietario', esPropietario);
		if (esPropietario) {
			botonesActivos.botonTrasladoImagin = !isClosed && imaginBank && ['CMB', 'CMN'].includes(oportunidad.RecordType.Name);
			botonesActivos.botonPendienteInternoActivo = ['Activa', 'Pendiente Interno'].includes(estado);
			botonesActivos.botonCerrarActivo = estado === 'Activa';
			botonesActivos.botonReactivarActivo = isClosed && (component.get('v.esResponsable') && oportunidad.RecordType.Name !== 'Hipoteca' || oportunidad.RecordType.Name === 'Hipoteca' || oportunidad.RecordType.Name === 'Acción comercial');
			botonesActivos.botonAutenticarActivo = !isClosed && oportunidad.AccountId && oportunidad.CSBD_Contact__c;
			botonesActivos.botonAmpliarVencimiento = ['Activa', 'Pendiente Interno', 'Pendiente Cita', 'Pendiente Cliente'].includes(estado);
			botonesActivos.botonInformeSiaActivo = !isClosed && estado !== 'Nueva';

			if (contactoInformado || !contactoInformado && oportunidad.CSBD_No_Identificado__c) { //identificado
				botonesActivos.botonEnviarCorreoActivo = !isClosed && estado !== 'Nueva';
				botonesActivos.botonConvertirActivo = !isClosed;
				botonesActivos.botonEnviarNotificacionActivo = botonesActivos.botonEnviarCorreoActivo;
				botonesActivos.botonProgramarActivo = ['Activa', 'Pendiente Interno'].includes(estado);
				botonesActivos.botonDesprogramarActivo = estado === 'Pendiente Cita';
				botonesActivos.botonAgendarFirmaActivo = ['Activa', 'Pendiente Interno', 'Pendiente Cita', 'Pendiente Cliente'].includes(estado);
				botonesActivos.botonCancelarFirmaActivo = botonesActivos.botonAgendarFirmaActivo;
			}

			botonesActivos.botonTareaGestorActivo = contactoInformado && !isClosed && estado !== 'Nueva' ;
		}
		botonesActivos.botonCopiarNIFActivo = contactoInformado;
		botonesActivos.botonHistorialSolicitudesActivo = contactoInformado;
		botonesActivos.botonActualizarDatosRiesgoContactoActivo = contactoInformado;
		component.set('v.programarNuevoPropietarioSeleccionado', oportunidad.OwnerId);

		if (estado === 'Pendiente Cita') {
			component.set('v.fechaCitaFormateada', $A.localizationService.formatDateTime(oportunidad.CSBD_Fecha_Cita__c, 'd MMM HH:mm'));
		} else if (['Nueva', 'Activa'].includes(estado)) {
			botonesActivos.botonAsignacionAutoActivo = component.get('v.esAdministrador');
		}
		component.set('v.botonesActivos', botonesActivos);

		if (oportunidad.CSBD_Fecha_Firma__c) {
			component.set('v.fechaFirmaFormateada', $A.localizationService.formatDateTime(oportunidad.CSBD_Fecha_Firma__c, 'd MMM HH:mm'));
		}

		const familiaProducto = component.get('v.oportunidad.CSBD_Familia_Producto__c');
		if (familiaProducto === 'Hipotecas') {
			component.set('v.tipoOperativaConvertir', 'hipoteca');
		} else if (familiaProducto === 'Préstamos') {
			component.set('v.tipoOperativaConvertir', 'préstamo');
		}
	},

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

	/*
	formatearFechaTramo: function(startDateTime, endDateTime) {
		return $A.localizationService.formatDate(startDateTime.valueOf(), 'EEEE d') + ' de ' +
            $A.localizationService.formatDate(startDateTime.valueOf(), 'MMMM') + ' de ' +
            $A.localizationService.formatDate(startDateTime.valueOf(), 'yyyy') + ' entre las ' +
            $A.localizationService.formatDate(startDateTime.valueOf(), 'k:mm') + ' horas y las ' +
            $A.localizationService.formatDate(endDateTime.valueOf(), 'k:mm') + ' horas.';
	},
	*/

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
		const toLocaleStringOptions = {
			minimumFractionDigits: importe % 1 === 0 ? 0 : 2,
			maximumFractionDigits: importe % 1 === 0 ? 0 : 2
		};
		//eslint-disable-next-line no-undefined
		return importe ? importe.toLocaleString(undefined, toLocaleStringOptions) + '€' : '';
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

	informeSiaCuerpo: function(component) {
		let cuerpo = '';
		try {
			const opp = component.get('v.oportunidad');

			let ltv = null, dtiNomina = null, dtiNominaBonificado = null, dtiIrpf = null, dtiIrpfBonificado = null;
			let totalNominas = null, totalIrpf = null;
			let ingresosTotales;
			let deudasTotales = null;
			let sumaDeudasTit1 = 0, sumaDeudasTit2 = 0;
			let totalIngresosNomina = 0, totalIngresosIrpf = 0; //Sin multiplicar por las mensualidades.

			const importeCompraventa = opp.CSBD_PrecioInmueble__c ? parseFloat(opp.CSBD_PrecioInmueble__c) : null;
			const importeHipoteca = opp.Amount ? parseFloat(opp.Amount) : 0;
			const plazo = opp.CSBD_Now_Plazo__c ? opp.CSBD_Now_Plazo__c : 0;

			const tasa = 1 + opp.CSBD_TIN_Inicial__c / 100 / 12 - 1;
			let tasaBonificada;
			const interesBonificado = opp.CSBD_InteresBonificado__c >= 0 ? opp.CSBD_InteresBonificado__c : 0;
			if (interesBonificado) {
				//eslint-disable-next-line no-extra-parens
				tasaBonificada = (1 + (interesBonificado / 100) / 12) - 1;
			} else {
				tasaBonificada = tasa;
			}

			let cuotaBonificada = null, cuotaBonificadaTit = null, cuotaSinBonificar = null, cuotaSinBonificarTit = null;
			if (plazo) {
				if (tasa === 0) {
					cuotaSinBonificar = importeHipoteca / (plazo * 12) / 12;
					cuotaBonificada = importeHipoteca / (plazo * 12) / 12;
				} else {
					const factorPresenteValorFuturo = Math.pow(1 + tasa, plazo);
					const factorPresenteValorFuturoBonificado = Math.pow(1 + tasaBonificada, plazo);
					cuotaSinBonificar = -tasa * (-importeHipoteca * factorPresenteValorFuturo) / (factorPresenteValorFuturo - 1);
					cuotaBonificada = -tasaBonificada * (-importeHipoteca * factorPresenteValorFuturoBonificado) / (factorPresenteValorFuturoBonificado - 1);
				}
			}

			let datosCalculo;
			let fondosPropios = 0;
			let pdtsFondosPropios = 0;
			if (component.get('v.oportunidad.CSBD_Datos_Calculo_DTI__c')) {
				try {
					datosCalculo = JSON.parse(component.get('v.oportunidad.CSBD_Datos_Calculo_DTI__c'));
					const porcentajeGastosConstitucion = datosCalculo.porcentajeGastosConstitucion ? datosCalculo.porcentajeGastosConstitucion / 100 : 0;
					fondosPropios = importeCompraventa - importeHipoteca + importeCompraventa * porcentajeGastosConstitucion;
					const pagosACuenta = opp.CSBD_AportacionInicial__c ? parseFloat(opp.CSBD_AportacionInicial__c) : 0;
					const ahorro = datosCalculo.ahorro ? parseFloat(datosCalculo.ahorro) : 0;
					const donacion = opp.CSBD_OC_Donacion__c ? parseFloat(opp.CSBD_OC_Donacion__c) : 0;
					pdtsFondosPropios = fondosPropios - pagosACuenta - ahorro - donacion;

					if (Object.keys(datosCalculo.segundoTitular).length) {
						cuotaSinBonificarTit = cuotaSinBonificar / 2;
						cuotaBonificadaTit = cuotaBonificada / 2;
					} else {
						cuotaSinBonificarTit = cuotaSinBonificar;
						cuotaBonificadaTit = cuotaBonificada;
					}

					if (Object.keys(datosCalculo.primerTitular).length) {
						const t1 = datosCalculo.primerTitular;
						let ingresosTit1Nomina = parseFloat(t1.nominasNetas.ingresos) * parseFloat(t1.nominasNetas.numPagosImpuestos);
						ingresosTit1Nomina += parseFloat(t1.otrosIngresos.ingresos) * parseFloat(t1.otrosIngresos.numPagosImpuestos);
						ingresosTit1Nomina += parseFloat(t1.ingresosAlquiler.ingresos) * parseFloat(t1.ingresosAlquiler.numPagosImpuestos);

						let ingresosTit1Irpf = parseFloat(t1.ingresosNetosIrpf.ingresos) - parseFloat(t1.ingresosNetosIrpf.numPagosImpuestos);
						ingresosTit1Irpf += parseFloat(t1.otrosIngresos.ingresos) * parseFloat(t1.otrosIngresos.numPagosImpuestos);
						ingresosTit1Irpf += parseFloat(t1.ingresosAlquiler.ingresos) * parseFloat(t1.ingresosAlquiler.numPagosImpuestos);

						totalNominas = parseFloat(t1.nominasNetas.ingresos) * parseFloat(t1.nominasNetas.numPagosImpuestos);
						totalIrpf = parseFloat(t1.ingresosNetosIrpf.ingresos) - parseFloat(t1.ingresosNetosIrpf.numPagosImpuestos);
						ingresosTotales = ingresosTit1Nomina ? ingresosTit1Nomina : ingresosTit1Irpf;

						totalIngresosNomina += parseFloat(t1.nominasNetas.ingresos) * parseFloat(t1.nominasNetas.numPagosImpuestos) / 12;
						totalIngresosNomina += parseFloat(t1.otrosIngresos.ingresos) * parseFloat(t1.otrosIngresos.numPagosImpuestos) / 12;
						totalIngresosNomina += parseFloat(t1.ingresosAlquiler.ingresos) * parseFloat(t1.ingresosAlquiler.numPagosImpuestos) / 12 / 2;

						totalIngresosIrpf += (parseFloat(t1.ingresosNetosIrpf.ingresos) - parseFloat(t1.ingresosNetosIrpf.numPagosImpuestos)) / 12;
						totalIngresosIrpf += parseFloat(t1.otrosIngresos.ingresos) * parseFloat(t1.otrosIngresos.numPagosImpuestos) / 12;
						totalIngresosIrpf += parseFloat(t1.ingresosAlquiler.ingresos) * parseFloat(t1.ingresosAlquiler.numPagosImpuestos) / 12 / 2;
					}

					if (Object.keys(datosCalculo.segundoTitular).length) {
						const t2 = datosCalculo.segundoTitular;
						let ingresosTit2Nomina = parseFloat(t2.nominasNetas.ingresos) * parseFloat(t2.nominasNetas.numPagosImpuestos);
						ingresosTit2Nomina += parseFloat(t2.otrosIngresos.ingresos) * parseFloat(t2.otrosIngresos.numPagosImpuestos);
						ingresosTit2Nomina += parseFloat(t2.ingresosAlquiler.ingresos) * parseFloat(t2.ingresosAlquiler.numPagosImpuestos);

						let ingresosTit2Irpf = parseFloat(t2.ingresosNetosIrpf.ingresos) - parseFloat(t2.ingresosNetosIrpf.numPagosImpuestos);
						ingresosTit2Irpf += parseFloat(t2.otrosIngresos.ingresos) * parseFloat(t2.otrosIngresos.numPagosImpuestos);
						ingresosTit2Irpf += parseFloat(t2.ingresosAlquiler.ingresos) * parseFloat(t2.ingresosAlquiler.numPagosImpuestos);

						totalNominas += parseFloat(t2.nominasNetas.ingresos) * parseFloat(t2.nominasNetas.numPagosImpuestos);
						totalIrpf += parseFloat(t2.ingresosNetosIrpf.ingresos) - parseFloat(t2.ingresosNetosIrpf.numPagosImpuestos);
						ingresosTotales += ingresosTit2Nomina > 0 ? ingresosTit2Nomina : ingresosTit2Irpf;

						totalIngresosNomina += parseFloat(t2.nominasNetas.ingresos) * parseFloat(t2.nominasNetas.numPagosImpuestos) / 12;
						totalIngresosNomina += parseFloat(t2.otrosIngresos.ingresos) * parseFloat(t2.otrosIngresos.numPagosImpuestos) / 12;
						totalIngresosNomina += parseFloat(t2.ingresosAlquiler.ingresos) * parseFloat(t2.ingresosAlquiler.numPagosImpuestos) / 12 / 2;

						totalIngresosIrpf += (parseFloat(t2.ingresosNetosIrpf.ingresos) - parseFloat(t2.ingresosNetosIrpf.numPagosImpuestos)) / 12;
						totalIngresosIrpf += parseFloat(t2.otrosIngresos.ingresos) * parseFloat(t2.otrosIngresos.numPagosImpuestos) / 12;
						totalIngresosIrpf += parseFloat(t2.ingresosAlquiler.ingresos) * parseFloat(t2.ingresosAlquiler.numPagosImpuestos) / 12 / 2;
					}

					sumaDeudasTit1 = parseFloat(datosCalculo.deuda.hipoteca.primerTitular);
					sumaDeudasTit1 += parseFloat(datosCalculo.deuda.prestamo.primerTitular);
					sumaDeudasTit1 += parseFloat(datosCalculo.deuda.tarjetas.primerTitular);
					sumaDeudasTit1 += parseFloat(datosCalculo.deuda.alquiler.primerTitular);

					sumaDeudasTit2 = parseFloat(datosCalculo.deuda.hipoteca.segundoTitular);
					sumaDeudasTit2 += parseFloat(datosCalculo.deuda.prestamo.segundoTitular);
					sumaDeudasTit2 += parseFloat(datosCalculo.deuda.tarjetas.segundoTitular);
					sumaDeudasTit2 += parseFloat(datosCalculo.deuda.alquiler.segundoTitular);

					deudasTotales = sumaDeudasTit1 + sumaDeudasTit2;
					deudasTotales += parseFloat(cuotaSinBonificar);

					let deudasTotalesBonificacion = parseFloat(datosCalculo.deuda.hipoteca.primerTitular);
					deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.prestamo.primerTitular);
					deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.tarjetas.primerTitular);
					deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.alquiler.primerTitular);
					deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.hipoteca.segundoTitular);
					deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.prestamo.segundoTitular);
					deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.tarjetas.segundoTitular);
					deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.alquiler.segundoTitular);
					deudasTotalesBonificacion += parseFloat(cuotaBonificada);

					if (deudasTotales && plazo) {
						if (totalIngresosNomina) {
							dtiNomina = deudasTotales / totalIngresosNomina;
							dtiNominaBonificado = deudasTotalesBonificacion / totalIngresosNomina;
						}

						if (totalIngresosIrpf) {
							dtiIrpf = deudasTotales / totalIngresosIrpf;
							dtiIrpfBonificado = deudasTotalesBonificacion / totalIngresosIrpf;
						}
					}

				} catch (error) {
					console.error('Error parsing JSON (entrevista)', error);
					return;
				}
			}

			let datosFincas;
			if (component.get('v.oportunidad.CSBD_FincasJson__c')) {
				try {
					datosFincas = JSON.parse(component.get('v.oportunidad.CSBD_FincasJson__c'));
				} catch (error) {
					console.error('Error parsing JSON (fincas)', error);
					return;
				}
			}

			if (opp.Amount && opp.CSBD_PrecioInmueble__c) {
				ltv = opp.Amount / opp.CSBD_PrecioInmueble__c;
			}

			//indentRainbow:ignore-below
			cuerpo = `OPERACIÓN SOLICITADA

FINALIDAD. ARGUMENTADA Y ACREDITADA DOCUMENTALMENTE

Operación de cliente/s procedente/s de un LEAD generado por el canal ${opp.CSBD_OC_Canal_Entrada__c ? `${opp.CSBD_OC_Canal_Entrada__c} + ${opp.CSBD_Now_Origen__c}` : opp.CSBD_Now_Origen__c}

Finalidad: ${opp.CSBD_TipoOperacion2__c} ${opp.CSBD_UsoVivienda2__c} de ${opp.CSBD_TipoConstruccion2__c} en ${opp.CSBD_Comunidad_Autonoma_2__c ? opp.CSBD_Comunidad_Autonoma_2__c : ''}
Se han entregado arras por importe de: ${this.formatImporte(opp.CSBD_AportacionInicial__c)}

% sobre compra: ${this.formatPorcentaje(this.formatCalculo(ltv, 2, true))}
% sobre tasación: ${this.formatPorcentaje(opp.CSBD_PorcentajeTasacion__c)}

OPERACIÓN: RESUMEN Y COMENTARIOS SEGÚN TIPOLOGÍA

Línea: ${opp.CSBD_Linea__c ? opp.CSBD_Linea__c : ''}
Importe del préstamo: ${this.formatImporte(opp.Amount)}
Plazo: ${plazo}
Modalidad de tipo de interés: ${opp.CSBD_TipoInteres2__c ? opp.CSBD_TipoInteres2__c : ''}
Interés bonificado: ${this.formatPorcentaje(interesBonificado)}
Interés sin bonificar: ${this.formatPorcentaje(opp.CSBD_TIN_Inicial__c)}

Cuota bonificada: ${this.formatImporte(cuotaBonificada)}
Cuota sin bonificar: ${this.formatImporte(cuotaSinBonificar)}

GARANTÍAS

Valor de inversión COMPRAVENTA: ${this.formatImporte(opp.CSBD_PrecioInmueble__c)}
% sobre inversión: ${this.formatPorcentaje(this.formatCalculo(ltv, 2, true))}
Valor tasación ESTIMADA: ${this.formatImporte(opp.CSBD_Tasacion__c)}
% sobre tasación ESTIMADA: ${this.formatPorcentaje(opp.CSBD_PorcentajeTasacion__c)}

${this.informeSiaBloqueFincas(datosFincas)}

SOLICITANTES

Solicitantes CLIENTES CAIXABANK

${this.informeSiaDescripcionTitulares(opp, datosCalculo)}

Los ingresos anuales totales ascienden a ${this.formatImporte(ingresosTotales)}

Los compromisos de pago anuales totales ascienden a:
· Deuda sin cuota:
	1er titular: ${this.formatImporte(sumaDeudasTit1)} y 2do titular: ${this.formatImporte(sumaDeudasTit2)}, con un total de ${this.formatImporte(sumaDeudasTit1 + sumaDeudasTit2)}.

· Cuota no bonificada:
	1er titular: ${this.formatImporte(cuotaSinBonificarTit)} y 2do titular: ${this.formatImporte(cuotaSinBonificarTit)}, con un total de ${this.formatImporte(cuotaSinBonificar)}.

· Deuda + cuota no bonificada:
	1er titular: ${this.formatImporte(sumaDeudasTit1 + cuotaSinBonificarTit)} y 2do titular: ${this.formatImporte(sumaDeudasTit2 + cuotaSinBonificarTit)}, con un total de ${this.formatImporte(sumaDeudasTit1 + sumaDeudasTit2 + cuotaSinBonificar)}.

· Cuota bonificada:
	1er titular: ${this.formatImporte(cuotaBonificadaTit)} y 2do titular: ${this.formatImporte(cuotaBonificadaTit)}, con un total de ${this.formatImporte(cuotaBonificada)}.

· Deuda + cuota bonificada:
	1er titular: ${this.formatImporte(sumaDeudasTit1 + cuotaBonificadaTit)} y 2do titular: ${this.formatImporte(sumaDeudasTit2 + cuotaBonificadaTit)}, con un total de ${this.formatImporte(sumaDeudasTit1 + sumaDeudasTit2 + cuotaBonificada)}.

Origen de los fondos propios: ${this.formatImporte(fondosPropios)}

El importe estimado que debe aportar el cliente es de ${this.formatImporte(pdtsFondosPropios)}

Régimen de residencia actual: ${opp.CSBD_Residencia_Actual__c ? opp.CSBD_Residencia_Actual__c : ''}

CAPACIDAD DE DEVOLUCIÓN

Ingresos anuales netos según Nómina: ${this.formatImporte(totalNominas)}
Ingresos anuales netos según IRPF: ${this.formatImporte(totalIrpf)}
Compromisos anuales: ${this.formatImporte(deudasTotales)}
Cuota ptmo. anual: ${this.formatImporte(cuotaBonificada)}

DTI sin bonificar según nómina: ${this.formatPorcentaje(this.formatCalculo(dtiNomina, 2, true))}
DTI bonificado según nómina: ${this.formatPorcentaje(this.formatCalculo(dtiNominaBonificado, 2, true))}

DTI sin bonificar según IRPF: ${this.formatPorcentaje(this.formatCalculo(dtiIrpf, 2, true))}
DTI bonificado según IRPF: ${this.formatPorcentaje(this.formatCalculo(dtiIrpfBonificado, 2, true))}

DTI propuesta SIA: ...
PD propuesta SIA: ...

ANÁLISIS Y JUSTIFICACIÓN SCORING OPERACIÓN

El scoring de la operación es. El scoring cliente es: ...

En la consulta de alertas externas de RAI, ASNEF y Experian no constan incidencias ni tampoco en las internas en la consulta del CIM.

CIRBE EXTERNA

La CIRBE total asciende a. Origen: ...

SOLVENCIA

Patrimonio:...

RENTABILIDAD ACTUAL

La REN actual de: ...

Vinculación asociada a la operación: ...

CONCLUSIONES

Expongo mi opinión favorable a la aprobación de la presente operación en base a:
· Garantía hipotecaria de la vivienda habitual de los solicitantes, donde financiamos el XX% del valor de compraventa.
· Capacidad de devolución del XXX% respecto sus ingresos actuales.
· Estabilidad de ambos clientes, XXX es XXX con antigüedad de XXX y XXX es XXX con antigüedad XXX.
· Scoring operación XXX, con una probabilidad de mora del XXX%.
`;
			//indentRainbow:ignore-above
		} catch (error) {
			console.error('Problema preparando el cuerpo del informe SIA', error);
			this.mostrarToast('info', 'Problema preparando el cuerpo del informe SIA', error);
		}
		component.find('modalInformeSiaTextareaInfoSia').set('v.value', cuerpo.replace(/null(\n|\s)?/g, ''));
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
	},

	/*
	modalProgramarRedimensionar: function(component, segunDisponibilidad) {
		return new Promise(resolve => {
			const numCalendarios = component.find('modalProgramarCalendarioDisponibilidad').get('v.numCalendarios');

			//Canviar dimensiones del modal de programar cita
			const modalContainer = component.find('modalProgramarModalContainer');
			const modalContainerElement = modalContainer.getElement();
			//alert(JSON.stringify(modalContainerElement.classList, null, 3));
			const modalContainerStyle = modalContainerElement.style;
			//const modalContainerParentComputedStyle = window.getComputedStyle(modalContainer.parentElement);
			const modalContainerComputedStyle = window.getComputedStyle(modalContainerElement);
			const modalContainerParentComputedStyle = window.getComputedStyle(modalContainerElement.parentElement);
			const widthIni = parseFloat(modalContainerComputedStyle.width, 10);
			const widthFin = segunDisponibilidad ? parseFloat(modalContainerParentComputedStyle.width) / 2 + Math.max(numCalendarios - 3, 0) * 118 : 650;

			const modalContentElement = component.find('modalProgramarModalContent').getElement();
			const modalContentStyle = modalContentElement.style;
			const modalContentComputedStyle = window.getComputedStyle(modalContentElement);
			const heightIni = parseFloat(modalContentComputedStyle.height, 10);
			const heightFin = segunDisponibilidad ? 560 : 155;

			const calendarioContainer = component.find('modalProgramarCalendarioDisponibilidadContainer');
			const calendarioContainerElement = calendarioContainer.getElement();
			calendarioContainerElement.style.pointerEvents = 'none';
			//calendarioContainerElement.style.display = segunDisponibilidad ? 'block' : 'none';
			const calendarioContainerStyle = calendarioContainerElement.style;
			const calendarioContainerComputedStyle = window.getComputedStyle(calendarioContainerElement);
			const calendarioContainerHeightIni = parseFloat(calendarioContainerComputedStyle.height, 10);
			const calendarioContainerHeightFin = segunDisponibilidad ? 511 : 0;
			const calendarioContainerOpacityIni = parseFloat(calendarioContainerComputedStyle.opacity) || 0;
			const calendarioContainerOpacityFin = segunDisponibilidad ? 1 : 0;

			const ease = t => 1 - Math.pow(1 - t, 7);
			let start = null;
			const redimensionar = timestamp => {
				!start && (start = timestamp);
				let progress = (timestamp - start) / 320; //320ms de duración
				progress > 1 && (progress = 1);

				const easedProgress = ease(progress);
				modalContainerStyle.width = widthIni + (widthFin - widthIni) * easedProgress + 'px';
				modalContentStyle.height = heightIni + (heightFin - heightIni) * easedProgress + 'px';
				calendarioContainerStyle.height = calendarioContainerHeightIni + (calendarioContainerHeightFin - calendarioContainerHeightIni) * easedProgress + 'px';
				calendarioContainerStyle.opacity = (calendarioContainerOpacityIni + (calendarioContainerOpacityFin - calendarioContainerOpacityIni) * easedProgress).toString();
				if (progress < 1) {
					requestAnimationFrame(redimensionar);
				} else {
					if (segunDisponibilidad) {
						calendarioContainerElement.style.pointerEvents = 'auto';
						//calendarioContainerElement.style.display = 'block';
						const calendarioDisponibilidad = component.find('modalProgramarCalendarioDisponibilidad');
						calendarioDisponibilidad.scrollToHorarioLaboral();
					} else {
						//calendarioContainerElement.style.display = 'none';
					}
					resolve();
				}
			};
			//eslint-disable-next-line compat/compat
			window.requestAnimationFrame(redimensionar);
		});
	}
	*/

	cambiarSeccion: function(component, tipoActual, tipoNew) { //, acciones
		component.find('modalProgramarModalContainer').getElement().style.pointerEvents = 'none';

		const secciones = {
			'A gestor específico': {
				nombre: 'A gestor específico', display: 'flex',
				elemento: component.find('modalProgramarLookupGestor').getElement()
			},
			'Según disponibilidad': {
				nombre: 'Según disponibilidad', display: 'block',
				elemento: component.find('modalProgramarCalendarioDisponibilidadContainer').getElement()
			},
			'Automática': {
				nombre: 'Automática', display: 'flex',
				elemento: component.find('modalProgramarInfoAsignacionAuto').getElement()
			}
		};

		const seccionActual = secciones[tipoActual];
		const seccionNew = secciones[tipoNew];

		//Preparar listener para mostrar la nueva sección tras ocultar la actual
		const seccionActualElemento = seccionActual.elemento;
		const funcionesBind = component.get('v.funcionesBind');
		const seccionOcultarOntransitionendBind = this.seccionOcultarOntransitionend.bind(this, component, seccionActual, seccionNew);
		funcionesBind.seccionOcultarOntransitionend = seccionOcultarOntransitionendBind;
		component.set('v.funcionesBind', funcionesBind);

		const calendarioElement = component.find('modalProgramarCalendarioDisponibilidadContainer').getElement();
		if (tipoActual === 'Según disponibilidad') {
			calendarioElement.style.maxHeight = calendarioElement.getBoundingClientRect().height + 'px';
			window.setTimeout($A.getCallback(() => {
				calendarioElement.style.maxHeight = '0px';
				seccionActualElemento.style.opacity = 0;

				window.setTimeout($A.getCallback(() => {
					//Sección actual transparente
					seccionActualElemento.addEventListener('transitionend', component.get('v.funcionesBind').seccionOcultarOntransitionend);
					//seccionActualElemento.style.opacity = 0;
				}), 300);
			}), 0);

		//} else if (tipoNew === 'Según disponibilidad') {
			//calendarioElement.style.maxHeight = '0px';
			//window.setTimeout($A.getCallback(() => {
			//calendarioElement.style.maxHeight = calendarioElement.getBoundingClientRect().height + 'px';
			//window.setTimeout($A.getCallback(() => {
			//Sección actual transparente
			//seccionActualElemento.addEventListener('transitionend', component.get('v.funcionesBind').seccionOcultarOntransitionend);
			//seccionActualElemento.style.opacity = 1;
			//}), 190);//
		//}), 190);
		} else {
			window.setTimeout($A.getCallback(() => {
				//Sección actual transparente
				seccionActualElemento.addEventListener('transitionend', component.get('v.funcionesBind').seccionOcultarOntransitionend);
				seccionActualElemento.style.opacity = 0;
			}), 0);
		}





	},

	seccionOcultarOntransitionend: function(component, seccionActual, seccionNew) {
		//Eliminar listener
		const funcionesBind = component.get('v.funcionesBind');
		seccionActual.elemento.removeEventListener('transitionend', funcionesBind.seccionOcultarOntransitionend);
		funcionesBind.seccionOcultarOntransitionend = null;
		component.set('v.funcionesBind', funcionesBind);

		const modalContainerElement = component.find('modalProgramarModalContainer').getElement();
		const modalContainerWidthOld = modalContainerElement.scrollWidth || 0;
		const modalContentElement = component.find('modalProgramarModalContent').getElement();
		const modalContentHeightOld = modalContentElement.scrollHeight || 0;
		const calendarioElement = component.find('modalProgramarCalendarioDisponibilidad').getElement();
		const calendarioHeightOld = calendarioElement.scrollHeight || 0;

		//Sección actual oculta
		seccionActual.elemento.style.display = 'none';

		this.seccionMostrar(component, seccionActual, seccionNew, modalContainerWidthOld, modalContentHeightOld, calendarioHeightOld);
	},

	seccionMostrar: function(component, seccionActual, seccionNew, modalContainerWidthOld, modalContentHeightOld, calendarioHeightOld) {
		//Sección nueva visible (pero aún transparente)
		const seccionNewElemento = seccionNew.elemento;
		seccionNewElemento.style.display = seccionNew.display;

		window.setTimeout($A.getCallback(() => {
			//Sección nueva visible y opaca
			seccionNewElemento.style.opacity = 1;

			//Redimensionar modal para adaptarlo al contenido de la nueva sección
			//const segunDisponibilidad = component.get('v.programarCitaTipoAsignacion') === 'Según disponibilidad';

			const modalContainerElement = component.find('modalProgramarModalContainer').getElement();
			const modalContainerWidthNew = modalContainerElement.scrollWidth || 0;
			const modalContentElement = component.find('modalProgramarModalContent').getElement();
			const modalContentHeightNew = modalContentElement.scrollHeight || 0;
			const calendarioElement = component.find('modalProgramarCalendarioDisponibilidadContainer').getElement();
			const calendarioHeightNew = calendarioElement.scrollHeight || 0;

			//Posem com a valor inicial la max-height antiga
			modalContainerElement.style.width = modalContainerWidthOld + 'px';
			modalContentElement.style.maxHeight = modalContentHeightOld + 'px';
			calendarioElement.style.maxHeight = calendarioHeightOld + 'px';

			//Forcem reflow
			modalContainerElement.offsetWidth; //NO eliminar, provoca reflow
			modalContentElement.offsetHeight; //NO eliminar, provoca reflow
			calendarioElement.offsetHeight; //NO eliminar, provoca reflow

			//4) Assignem la max-height final
			//modalContentElement.style.transition = 'max-height 300ms ease';
			modalContainerElement.style.width = modalContainerWidthNew + 'px';
			modalContentElement.style.maxHeight = modalContentHeightNew + 'px';
			calendarioElement.style.maxHeight = calendarioHeightNew + 'px';

			//5) Al final de la transició, ressetegem si volem
			modalContentElement.addEventListener('transitionend', $A.getCallback(() => {
				//modalContainerElement.style.width = 'fit-content';
				modalContentElement.style.maxHeight = 'none';
				calendarioElement.style.maxHeight = 'none';
				//modalContentElement.style.transition = '';
				component.find('modalProgramarModalContainer').getElement().style.pointerEvents = 'auto';
			}), {once: true});
		}), 0);
	},

	/*
	seccionMostrar: function(component, seccionActual, seccionNew) {
		//Sección nueva visible (pero aún transparente)
		const seccionNewElemento = seccionNew.elemento;
		seccionNewElemento.style.display = seccionNew.display;

		window.setTimeout($A.getCallback(() => {
			//Sección nueva visible y opaca
			seccionNewElemento.style.opacity = 1;

			//Redimensionar modal para adaptarlo al contenido de la nueva sección
			const modalContainer = component.find('modalProgramarModalContainer').getElement();
			const modalContent = component.find('modalProgramarModalContent').getElement();
			const modalContainerWidth = modalContainer.scrollWidth;
			const modalContentHeight = modalContent.scrollHeight;

			//Forçar reflow per aplicar dimensions inicials
			modalContainer.offsetWidth;
			modalContent.offsetHeight;
			modalContainer.style.width = modalContainerWidth + 'px';
			modalContent.style.maxHeight = modalContentHeight + 'px';
			modalContainer.offsetWidth;
			modalContent.offsetHeight;

			//Configurar transicions
			modalContainer.style.willChange = 'width';
			modalContainer.style.transition = 'width 320ms ease-in-out';
			modalContent.style.willChange = 'max-height';
			modalContent.style.transition = 'max-height 320ms ease-in-out';

			//Aplicar noves dimensions
			const modalContainerWidthNew = modalContainer.scrollWidth;
			const modalContentHeightNew = modalContent.scrollHeight;
			modalContainer.style.width = modalContainerWidthNew + 'px';
			modalContent.style.maxHeight = modalContentHeightNew + 'px';

			//Netejar estils després de la transició
			const onTransitionEnd = () => {
				modalContainer.style.willChange = '';
				modalContainer.style.transition = '';
				modalContainer.style.width = '';
				modalContent.style.willChange = '';
				modalContent.style.transition = '';
				modalContent.style.maxHeight = '';
				modalContainer.removeEventListener('transitionend', onTransitionEnd);
			};

			modalContainer.addEventListener('transitionend', onTransitionEnd);
		}), 0);
	}
	*/
});