/*eslint-disable @salesforce/aura/ecma-intrinsics, @lwc/lwc/no-for-of, @lwc/lwc/no-async-await, arrow-body-style*/
import {LightningElement, api, wire, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import {loadStyle} from 'lightning/platformResourceLoader';
import currentUserId from '@salesforce/user/Id';

import staticResourceEstilos from '@salesforce/resourceUrl/csbd_calculadora_dti_style';
import {Data, DATATABLE_COLUMNS} from './data';
import {CAMPOS_OPORTUNIDAD, toast, MENSAJES_INFO, camposCabecera, DATATABLE_TIPOS_BONIFICADOS_COLUMNS, animarCambiosTablas} from './utils';

import tiposBonificadosApex from '@salesforce/apex/CSBD_Calculadora_Dti_Controller.tiposBonificados';

import OPPTY_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';
import OPPTY_OWNER_ID from '@salesforce/schema/Opportunity.OwnerId';
import OPPTY_OWNER_NAME from '@salesforce/schema/Opportunity.Owner.Name';
import OPPTY_DATOS_CALCULO from '@salesforce/schema/Opportunity.CSBD_Datos_Calculo_DTI__c';
import OPPTY_TIPO_OPERACION from '@salesforce/schema/Opportunity.CSBD_TipoOperacion2__c';
import OPPTY_USO_VIVIENDA from '@salesforce/schema/Opportunity.CSBD_UsoVivienda2__c';
import OPPTY_TIPO_CONSTRUCCION from '@salesforce/schema/Opportunity.CSBD_TipoConstruccion2__c';
import OPPTY_PRIORIDAD from '@salesforce/schema/Opportunity.CSBD_OC_Prioridad__c';
import OPPTY_CANAL_ENTRADA from '@salesforce/schema/Opportunity.CSBD_OC_Canal_Entrada__c';
import OPPTY_CIRBE_SOLICITADO from '@salesforce/schema/Opportunity.CSBD_OC_Cirbe_Solicitado__c';
import OPPTY_COMUNIDAD_AUTONOMA from '@salesforce/schema/Opportunity.CSBD_Comunidad_Autonoma_2__c';
import OPPTY_PROVINCIA from '@salesforce/schema/Opportunity.CSBD_Provincia_2__c';
import OPPTY_CODIGO_POSTAL from '@salesforce/schema/Opportunity.CSBD_CodigoPostal__c';
import OPPTY_MUNICIPIO from '@salesforce/schema/Opportunity.CSBD_Municipio__c';
import OPPTY_VIA_TIPO from '@salesforce/schema/Opportunity.CSBD_TipoVia__c';
import OPPTY_VIA_NOMBRE from '@salesforce/schema/Opportunity.CSBD_CalleVivienda__c';
import OPPTY_VIA_NUMERO from '@salesforce/schema/Opportunity.CSBD_NumeroVivienda__c';
import OPPTY_VIA_PISO from '@salesforce/schema/Opportunity.CSBD_PisoVivienda__c';
import OPPTY_VIA_PUERTA from '@salesforce/schema/Opportunity.CSBD_PuertaVivienda__c';
import OPPTY_PRECIO_INMUEBLE from '@salesforce/schema/Opportunity.CSBD_PrecioInmueble__c';
import OPPTY_AMOUNT from '@salesforce/schema/Opportunity.Amount';
import OPPTY_NOW_PLAZO from '@salesforce/schema/Opportunity.CSBD_Now_Plazo__c';
import OPPTY_APORTACION_INICIAL from '@salesforce/schema/Opportunity.CSBD_AportacionInicial__c';
import OPPTY_DONACION from '@salesforce/schema/Opportunity.CSBD_OC_Donacion__c';
import OPPTY_TIN_INICIAL from '@salesforce/schema/Opportunity.CSBD_TIN_Inicial__c';
import OPPTY_PORCENTAJE_BONIFICACION from '@salesforce/schema/Opportunity.CSBD_PorcentajeBonificacion__c';
import OPPTY_CONTACT1_ID from '@salesforce/schema/Opportunity.CSBD_Contact__c';
import OPPTY_TITULAR1_ID from '@salesforce/schema/Opportunity.CSBD_ContactoTitular1__c';
import OPPTY_TITULAR1_NAME from '@salesforce/schema/Opportunity.CSBD_ContactoTitular1__r.Name';
import OPPTY_TITULAR1_ESCALA_MAESTRA from '@salesforce/schema/Opportunity.CSBD_Contact__r.CSBD_Escala_Maestra__c';
import OPPTY_TITULAR1_EDAD from '@salesforce/schema/Opportunity.CSBD_ContactoTitular1__r.CSBD_Edad__c';
import OPPTY_TITULAR1_ESTADO_CIVIL from '@salesforce/schema/Opportunity.CSBD_ContactoTitular1__r.CSBD_Estado_Civil__c';
import OPPTY_TITULAR1_NUM_HIJOS from '@salesforce/schema/Opportunity.CSBD_ContactoTitular1__r.CSBD_Numero_Hijos__c';
import OPPTY_CONTACT2_ID from '@salesforce/schema/Opportunity.CSBD_Contact_2__c';
import OPPTY_TITULAR2_ID from '@salesforce/schema/Opportunity.CSBD_ContactoTitular2__c';
import OPPTY_TITULAR2_NAME from '@salesforce/schema/Opportunity.CSBD_ContactoTitular2__r.Name';
import OPPTY_TITULAR2_ESCALA_MAESTRA from '@salesforce/schema/Opportunity.CSBD_Contact_2__r.CSBD_Escala_Maestra__c';
import OPPTY_TITULAR2_EDAD from '@salesforce/schema/Opportunity.CSBD_ContactoTitular2__r.CSBD_Edad__c';
import OPPTY_TITULAR2_ESTADO_CIVIL from '@salesforce/schema/Opportunity.CSBD_ContactoTitular2__r.CSBD_Estado_Civil__c';
import OPPTY_TITULAR2_NUM_HIJOS from '@salesforce/schema/Opportunity.CSBD_ContactoTitular2__r.CSBD_Numero_Hijos__c';

const OPPTY_FIELDS = [
	OPPTY_IDENTIFICADOR, OPPTY_OWNER_ID, OPPTY_OWNER_NAME, OPPTY_DATOS_CALCULO, OPPTY_TIPO_OPERACION, OPPTY_USO_VIVIENDA,
	OPPTY_TIPO_CONSTRUCCION, OPPTY_PRIORIDAD, OPPTY_CANAL_ENTRADA, OPPTY_CIRBE_SOLICITADO, OPPTY_COMUNIDAD_AUTONOMA,
	OPPTY_PROVINCIA, OPPTY_CODIGO_POSTAL, OPPTY_MUNICIPIO, OPPTY_VIA_TIPO, OPPTY_VIA_NOMBRE, OPPTY_VIA_NUMERO, OPPTY_VIA_PISO,
	OPPTY_VIA_PUERTA, OPPTY_PRECIO_INMUEBLE, OPPTY_AMOUNT, OPPTY_NOW_PLAZO, OPPTY_APORTACION_INICIAL, OPPTY_PORCENTAJE_BONIFICACION,
	OPPTY_DONACION, OPPTY_TIN_INICIAL, OPPTY_CONTACT1_ID, OPPTY_TITULAR1_ID, OPPTY_TITULAR1_NAME, OPPTY_TITULAR1_ESCALA_MAESTRA,
	OPPTY_TITULAR1_EDAD, OPPTY_TITULAR1_ESTADO_CIVIL, OPPTY_TITULAR1_NUM_HIJOS, OPPTY_CONTACT2_ID, OPPTY_TITULAR2_ID,
	OPPTY_TITULAR2_NAME, OPPTY_TITULAR2_ESCALA_MAESTRA, OPPTY_TITULAR2_EDAD, OPPTY_TITULAR2_ESTADO_CIVIL, OPPTY_TITULAR2_NUM_HIJOS
];

//eslint-disable-next-line new-cap
export default class csbdCalculadoraDti extends NavigationMixin(LightningElement) {
	@api recordId;

	componente = {
		cargado: false,
		renderInicial: true,
		//getRecordTimestamp: null,
		idTimeoutCerrarTooltipCalculos: null,
		idTimeoutCerrarPopoverTiposBonificados: null,
		funcionesBind: []
	};

	getRecordTimestamp;

	oportunidad;

	datatableColumns = DATATABLE_COLUMNS;

	@track datatableData = {calculos: {
		ltv: {},
		dtiNomina: {}, dtiNominaBonificado: {},
		dtiIrpf: {}, dtiIrpfBonificado: {}
	}};

	data;

	set cambiosSinGuardar(valor) {
		this._cambiosSinGuardar = valor;
		this.mensajesInfo.find(m => m.tipo === 'cambiosSinGuardar').mostrar = valor;
		this.mensajesInfo.find(m => m.tipo === 'cambiosGuardados').mostrar = !valor;
		this.template.querySelectorAll('lightning-button.botonGuardar').forEach(boton => boton.variant = valor ? 'destructive' : 'brand');
	}

	_cambiosRequeridosSinInformar = false;

	get cambiosRequeridosSinInformar() {
		return this._cambiosRequeridosSinInformar;
	}

	set cambiosRequeridosSinInformar(valor) {
		this._cambiosRequeridosSinInformar = valor;
		this.mensajesInfo.find(m => m.tipo === 'camposRequeridosNoInformados').mostrar = valor;
		this.mensajesInfo.find(m => m.tipo === 'camposRequeridosInformados').mostrar = !valor;
	}

	mensajesInfo = MENSAJES_INFO;

	camposCabecera = {
		tipoOperacion: '(¿Tipo de operación?)',
		usoVivienda: '(¿Uso de la vivienda?)',
		tipoConstruccion: '(¿Tipo de construcción?)'
	};

	tiposBonificados;

	//modalMapaAbierto = false;

	@track datatableTiposBonificados = {columns: DATATABLE_TIPOS_BONIFICADOS_COLUMNS, data: []};

	@wire(getRecord, {recordId: '$recordId', fields: OPPTY_FIELDS, timestamp: '$getRecordTimestamp'})
	async wiredRecord({data: wiredOpportunity, error: errorGetRecord}) {
		try {
			if (wiredOpportunity) {
				this.oportunidad = JSON.parse(JSON.stringify(wiredOpportunity)); //parse + stringify para hacer deep copy
				this.camposCabecera = camposCabecera(wiredOpportunity); //uso principal, tipo de construcción, dirección, etc. del inmueble

				if (this.data) {
					//Modificación de datos de la oportunidad mientras el lwc está cargado
					this.data.actualizarDatosOportunidad(wiredOpportunity);
				} else {
					//Carga inicial del LWC
					let datosGuardados = getFieldValue(wiredOpportunity, OPPTY_DATOS_CALCULO);
					if (datosGuardados) {
						this.data = Data.cargarDatosGuardados(JSON.parse(datosGuardados), wiredOpportunity);
					} else {
						this.data = new Data(wiredOpportunity);
					}
				}

				await this.refrescarDatatableData(false); //En la primera carga no se resaltan los cambios
				this.getTiposBonificadosDatatableData();

				this.cambiosSinGuardar = false;
				this.template.querySelectorAll('.botonesFooter').forEach(b => {b.disabled = false});
				this.cardBodyVisible();
			} else if (errorGetRecord) {
				throw errorGetRecord;
			}
		} catch (error) {
			console.error(error);
			toast('error', 'Problema recuperando los datos de la oportunidad', error.message ?? error);
		}
	}

	renderedCallback() {
		if (this.componente.renderInicial) {
			loadStyle(this, staticResourceEstilos)
			.then(async () => {
				this.componente.renderInicial = false;
				this.cardBodyVisible();
			}).catch(error => {
				console.error('Error cargando fichero CSS: ' + error.message);
				toast('error', 'Problema aplicando fichero CSS', error.body.message);
			});
		}
	}

	cardBodyVisible() {
		if (!this.componente.cargado) {
			if (!this.componente.renderInicial && this.data) {//todo: !
				this.template.querySelector('article.cardCalculadoraDti').classList.remove('cargando');//todo: !

				const stencils = this.template.querySelectorAll('div.datatableContainer > c-lwc-labs-loading-stencil');
				stencils.forEach(s => s.classList.add('transparente'));
				window.setTimeout(() => {
					const datatables = this.template.querySelectorAll('div.datatableContainer > lightning-datatable');
					stencils.forEach(s => s.classList.add('slds-hide'));
					datatables.forEach(d => d.classList.remove('slds-hide'));
					window.setTimeout(() => datatables.forEach(d => d.classList.remove('transparente')), 15);
					//window.setTimeout(() => this.scrollToTop(), 120);
					this.componente.cargado = true;
				}, 50);
			}
		}
	}

	datatableOncellchange(event) {
		const draftValue = event.detail.draftValues[0];
		//fieldName es el fieldName de la columna modificada
		let [fieldName, nuevoValor] = Object.entries(draftValue).find(([key]) => key !== 'id');
		nuevoValor = nuevoValor ? nuevoValor : 0;

		//Validaciones
		const camposPorcentajeEditables = ['interes', 'porcentajeGastosConstitucion', 'porcentajeBonificacion'];
		if (camposPorcentajeEditables.includes(draftValue.id) && (nuevoValor < 0 || nuevoValor > 100)) {
			if (draftValue.id === 'interes') {
				toast('info', 'Valor no válido para "Interés"', 'Indica un valor entre 0% y 100%');
			} else if (draftValue.id === 'porcentajeGastosConstitucion') {
				toast('info', 'Valor no válido para "% de gastos de constitución"', 'Indica un valor entre 0% y 100%');
			} else if (draftValue.id === 'porcentajeBonificacion') {
				toast('info', 'Valor no válido para "% de bonificación"', 'Indica un valor entre 0% y 100%');
			}
			event.target.draftValues = null;
			return;
		}
		if (draftValue.id === 'importeCompraventa') {
			if (parseInt(nuevoValor, 10) < parseInt(getFieldValue(this.oportunidad, OPPTY_AMOUNT), 10) ?? 0) {
				toast('info', 'Valor no válido para "Importe de compraventa"', 'Indica un valor superior al importe de la hipoteca');
				event.target.draftValues = null;
				return;
			}
		}
		if (draftValue.id === 'importeHipoteca') {
			if (parseInt(nuevoValor, 10) > parseInt(getFieldValue(this.oportunidad, OPPTY_PRECIO_INMUEBLE), 10) ?? 0) {
				toast('info', 'Valor no válido para "Importe de la hipoteca"', 'Indica un valor inferior al importe de compraventa');
				event.target.draftValues = null;
				return;
			}
		}

		//Validaciones OK
		this.cambiosSinGuardar = true;
		const rutaCampo = draftValue.id.split('.');
		//rutaCampo es un array con los objetos padre del campo modificado, por ejemplo si se
		//modifica el importe o el número de pagas de los ingresos por alquiler del primer
		//titular, rutaCampo: ['primerTitular', 'ingresosAlquiler']
		if (rutaCampo.length === 1) {
			const campo = CAMPOS_OPORTUNIDAD.find(c => c.ref === rutaCampo[0]);
			if (campo) {
				campo.bool && (nuevoValor = Boolean(nuevoValor));
				this.oportunidad.fields[campo.field.fieldApiName].value = nuevoValor;
				this.data.actualizarDatosOportunidad(this.oportunidad);
			} else {
				this.data[rutaCampo[0]] = nuevoValor;
			}
		} else if (rutaCampo.length === 2) {
			this.data[rutaCampo[0]][rutaCampo[1]][fieldName] = nuevoValor;
		}

		event.target.draftValues = null;
		this.refrescarDatatableData();
		if (draftValue.id === 'importeCompraventa') {
			this.getTiposBonificadosDatatableData();
		}
	}

	async refrescarDatatableData(resaltarModificaciones = true) {
		try {
			if (this.data) {
				//Evaluar disabled de las tablas de titular
				const idPrimerTitular = getFieldValue(this.oportunidad, OPPTY_TITULAR1_ID);
				if (!idPrimerTitular) {
					this.datatableData.primerTitular = [];
				}
				const gridColTitular1 = this.template.querySelector('div.gridColDatatable.primerTitular');
				if (gridColTitular1) {
					gridColTitular1.classList.toggle('disabled', !idPrimerTitular);
				}
				const idSegundoTitular = getFieldValue(this.oportunidad, OPPTY_TITULAR2_ID);
				if (!idSegundoTitular) {
					this.datatableData.segundoTitular = [];
				}
				const gridColTitular2 = this.template.querySelector('div.gridColDatatable.segundoTitular');
				if (gridColTitular2) {
					gridColTitular2.classList.toggle('disabled', !idSegundoTitular);
				}

				//Regenerar datos de las tablas
				const datatableDataOld = JSON.parse(JSON.stringify(this.datatableData));
				const datatableDataNew = this.data.generarDatatableData(this.oportunidad);
				let mensajes = [...this.mensajesInfo];
				this.cambiosRequeridosSinInformar = !this.data.camposRequeridosInformados;

				this.mensajes = [...mensajes]; //?????

				//Resaltar cambios en los campos autocalculados respecto a los valores anteriores al refresco
				resaltarModificaciones && animarCambiosTablas.bind(this, datatableDataOld, datatableDataNew)();

				//Se guardan los nuevos datos
				this.datatableData = {...datatableDataNew};

				this.template.querySelectorAll('div.divCalculoItem').forEach(ci => {
					const calculo = this.datatableData.calculos[ci.dataset.calculo];
					ci.classList.toggle('noViable', calculo.valor && !calculo.viable);
				});
			}
		} catch (error) {
			console.error(error);
			toast('error', 'Problema actualizando los datos', JSON.stringify(error));
		}
	}

	async getTiposBonificadosDatatableData() {
		const formatearTipo = t => parseFloat((t * 100).toFixed(2)).toString() + '%';

		!this.tiposBonificados && (this.tiposBonificados = await tiposBonificadosApex({}));
		let importeCompraventa = getFieldValue(this.data.oportunidad, OPPTY_PRECIO_INMUEBLE);
		importeCompraventa = importeCompraventa ? importeCompraventa : 0;

		let tiposBonificadosData = [];
		for (let nombre in this.tiposBonificados) {
			if (Object.prototype.hasOwnProperty.call(this.tiposBonificados, nombre)) {
				const tiposGenerales = nombre === 'General';
				if (tiposGenerales || nombre === getFieldValue(this.oportunidad, OPPTY_COMUNIDAD_AUTONOMA)) {
					const tipos = this.tiposBonificados[nombre];
					tiposBonificadosData.push({
						nombre, iconName: tiposGenerales ? 'utility:metrics' : 'utility:checkin',
						columns: DATATABLE_TIPOS_BONIFICADOS_COLUMNS[tiposGenerales ? 'general' : 'ccaa'],
						data: tipos.map(t => {
							const porcentajeGastos = tiposGenerales ? 0 : 0.01;
							const importe = parseFloat((importeCompraventa * (t.valor + porcentajeGastos)).toString());
							return {
								tipo: formatearTipo(t.valor),
								tipoConGastos: formatearTipo(t.valor + porcentajeGastos),
								valor: Math.round((t.valor + porcentajeGastos + Number.EPSILON) * 100).toFixed(3),
								importe
							};
						}).sort((a, b) => a.tipo.localeCompare(b.tipo))
					});
				}
			}
		}
		tiposBonificadosData.mostrarFooter = tiposBonificadosData.some(tipo => tipo.nombre !== 'General');

		this.datatableTiposBonificados.data = tiposBonificadosData.sort((a, b) => {
			let retorno;
			if (a.nombre === 'General') {
				retorno = -1;
			} else if (b.nombre === 'General') {
				retorno = 1;
			} else {
				retorno = a.nombre.localeCompare(b.nombre);
			}
			return retorno;
		});
	}

	async botonGuardarOnclick() {
		if (getFieldValue(this.oportunidad, OPPTY_OWNER_ID) !== currentUserId) {
			toast('info', 'No eres el propietario de la oportunidad', 'Solo el propietario de la oportunidad puede modificarla (propietario actual: ' + getFieldValue(this.oportunidad, OPPTY_OWNER_NAME) + ')');
		} else if (!getFieldValue(this.oportunidad, OPPTY_TITULAR1_ID)) {
			toast('info', 'La oportunidad no tiene titulares', 'Para guardar los datos de la entrevista, la oportunidad debe tener al menos el primer titular informado');
		} else {
			if (await LightningConfirm.open({
				variant: 'header', theme: 'alt-inverse', label: 'Guardar',
				message: '¿Quieres guardar el estado actual del formulario?'
			})) {
				await this.guardar(() => toast('success', 'Se actualizó Oportunidad', 'Se actualizaron correctamente los datos de la oportunidad ' + getFieldValue(this.oportunidad, OPPTY_IDENTIFICADOR)));
			}
		}
	}

	async guardar(callback = null) {
		const botonesFooter = this.template.querySelectorAll('.botonesFooter');
		botonesFooter.forEach(b => {b.disabled = true});

		const fieldsOportunidad = {};
		fieldsOportunidad.Id = this.recordId;
		fieldsOportunidad[OPPTY_DATOS_CALCULO.fieldApiName] = this.data.serializarDatosGuardados();
		fieldsOportunidad[OPPTY_PRECIO_INMUEBLE.fieldApiName] = getFieldValue(this.oportunidad, OPPTY_PRECIO_INMUEBLE);
		fieldsOportunidad[OPPTY_AMOUNT.fieldApiName] = getFieldValue(this.oportunidad, OPPTY_AMOUNT);
		fieldsOportunidad[OPPTY_TIN_INICIAL.fieldApiName] = getFieldValue(this.oportunidad, OPPTY_TIN_INICIAL);
		fieldsOportunidad[OPPTY_NOW_PLAZO.fieldApiName] = getFieldValue(this.oportunidad, OPPTY_NOW_PLAZO);
		fieldsOportunidad[OPPTY_APORTACION_INICIAL.fieldApiName] = getFieldValue(this.oportunidad, OPPTY_APORTACION_INICIAL);
		fieldsOportunidad[OPPTY_PORCENTAJE_BONIFICACION.fieldApiName] = this.data.porcentajeBonificacion;
		fieldsOportunidad[OPPTY_DONACION.fieldApiName] = getFieldValue(this.oportunidad, OPPTY_DONACION);
		fieldsOportunidad[OPPTY_CIRBE_SOLICITADO.fieldApiName] = getFieldValue(this.oportunidad, OPPTY_CIRBE_SOLICITADO);
		updateRecord({fields: fieldsOportunidad})
			.then(() => {
				this.cambiosSinGuardar = false;
				callback && callback();
			}).catch(error => {
				console.error(error);
				toast('error', 'Problema actualizando Oportunidad', error.body?.message);
			}).finally(() => botonesFooter.forEach(b => {b.disabled = false}));
	}

	async botonDescartarOnclick() {
		if (await LightningConfirm.open({
			variant: 'header', theme: 'offline', label: 'Descartar cambios',
			message: '¿Quieres descartar los cambios? Se perderán todas las modificaciones realizadas desde el último guardado.'
		})) {
			this.template.querySelectorAll('.botonesFooter').forEach(b => {b.disabled = true});
			window.setTimeout(() => this.reiniciarData(), 0);
		}
	}

	menuSettingsOnselect({detail: {value}}) {
		if (value === 'borrarDatosGuardados') {
			this.modalBorrarDatosGuardadosAbrir();
		} else if (value === 'debugger') {
			window.setTimeout(() => {debugger}, 1500);
		} else if (value === 'log') {
			//eslint-disable-next-line no-console
			//console.log(this.data.deuda.cuota);
		}
	}

	async reiniciarData(borrarDatosGuardados = false) {
		if (borrarDatosGuardados) {
			try {
				await updateRecord({fields: {Id: this.recordId, [OPPTY_DATOS_CALCULO.fieldApiName]: null}});
				this.cambiosSinGuardar = false;
				toast('warning', 'Se eliminaron los datos guardados', 'Se eliminaron correctamente los datos anteriormente guardados');
			} catch (error) {
				console.error(error);
				toast('error', 'Problema borrando los datos guardados');
				return;
			}
		} else {
			this.cambiosSinGuardar = false;
			toast('info', 'Se descartaron los cambios sin guardar', 'Se descartaron correctamente las modificaciones realizadas desde el último guardado');
		}
		this.data = null;
		this.getRecordTimestamp = new Date();
		this.cambiosSinGuardar = false;
	}

	navegarDetalleRegistro({currentTarget: {dataset: {recordId}}}) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage', attributes: {recordId, actionName: 'view'}
		});
	}

	/*
	modalMapaAbrir() {
		this.template.querySelector('.botonModalMapaAbrir').variant = 'brand';
		const abrir = () => {
			const modalMapa = this.template.querySelector('section.modalMapa');
			modalMapa.classList.add('slds-fade-in-open');
			this.template.querySelector('div.slds-backdrop').classList.add('slds-backdrop--open');
			modalMapa.querySelector('.botonModalMapaCerrar').focus();
		};
		if (this.modalMapaAbierto) {
			abrir();
		} else {
			this.modalMapaAbierto = true;
			window.setTimeout(() => abrir(), 1100);
		}
	}

	modalMapaCerrar() {
		this.template.querySelector('section.modalMapa').classList.remove('slds-fade-in-open');
		this.template.querySelector('div.slds-backdrop').classList.remove('slds-backdrop--open');
		this.template.querySelector('.botonModalMapaAbrir').variant = null;
	}
	*/

	scrollToTop() {
		window.scrollTo({top: 335, behavior: 'smooth'});
	}

	modalBorrarDatosGuardadosAbrir() {
		if (getFieldValue(this.oportunidad, OPPTY_OWNER_ID) !== currentUserId) {
			toast('info', 'No eres el propietario de la oportunidad', 'Solo el propietario de la oportunidad puede modificarla (propietario actual: ' + getFieldValue(this.oportunidad, OPPTY_OWNER_NAME) + ')');
		} else {
			const modalBorrarDatosGuardados = this.template.querySelector('section.modalBorrarDatosGuardados');
			modalBorrarDatosGuardados.classList.add('slds-fade-in-open');
			this.template.querySelector('div.slds-backdrop').classList.add('slds-backdrop_open');
			modalBorrarDatosGuardados.querySelector('.modalBorrarDatosGuardadosCancelar').focus();
		}
	}

	modalCerrar(elemento) {
		'currentTarget' in elemento && (elemento = elemento.currentTarget);
		if (elemento.nodeName !== 'SECTION') {
			elemento = elemento.closest('section');
		}
		elemento.classList.remove('slds-fade-in-open');
		this.template.querySelector('div.slds-backdrop').classList.remove('slds-backdrop_open');
	}

	modalBorrarDatosGuardadosCerrar() {
		this.template.querySelector('section.modalBorrarDatosGuardados').classList.remove('slds-fade-in-open');
		this.template.querySelector('div.slds-backdrop').classList.remove('slds-backdrop_open');
	}

	async modalBorrarDatosGuardadosAceptar(event) {
		const botonAceptar = event.currentTarget;
		botonAceptar.disabled = true;
		this.template.querySelectorAll('.botonesFooter').forEach(b => {b.disabled = true});
		await this.reiniciarData(true);
		//this.modalBorrarDatosGuardadosCerrar();
		this.modalCerrar(botonAceptar);
		botonAceptar.disabled = false;
	}

	modalOnkeydown(event) {
		event.keyCode === 27 && this.modalCerrar(event);
	}

	popoverTiposBonificadosContainerOnmouseenter(event) {
		if (this.datatableTiposBonificados.data.length) {
			window.clearTimeout(this.idTimeoutCerrarPopoverTiposBonificados);
			const popover = event.currentTarget.querySelector('section.popoverTiposBonificados');
			popover.classList.add('visible');
		}
	}

	popoverTiposBonificadosContainerOnmouseleave(event) {
		const popoverTiposBonificadosContainer = event.currentTarget;
		this.idTimeoutCerrarPopoverTiposBonificados = window.setTimeout(() => {
			popoverTiposBonificadosContainer.style.pointerEvents = 'none';
			const popoverTiposBonificados = popoverTiposBonificadosContainer.querySelector('section.popoverTiposBonificados');
			this.componente.funcionesBind.cerrarPopoverTiposBonificados = this.cerrarPopoverTiposBonificados.bind(this, popoverTiposBonificadosContainer, popoverTiposBonificados);
			popoverTiposBonificados.addEventListener('transitionend', this.componente.funcionesBind.cerrarPopoverTiposBonificados);
			popoverTiposBonificados.classList.remove('visible');
		}, 190);
	}

	cerrarPopoverTiposBonificados(popoverTiposBonificadosContainer, popoverTiposBonificados) {
		popoverTiposBonificados.removeEventListener('transitionend', this.componente.funcionesBind.cerrarPopoverTiposBonificados);
		popoverTiposBonificadosContainer.style.pointerEvents = 'auto';
	}

	divTooltipCalculosOnmouseenter(event) {
		window.clearTimeout(this.componente.idTimeoutCerrarTooltipCalculos);
		event.currentTarget.querySelector('.tooltipCalculos').classList.add('visible');
	}

	divTooltipCalculosOnmouseleave(event) {
		const tooltipCalculos = event.currentTarget.querySelector('.tooltipCalculos');
		this.componente.idTimeoutCerrarTooltipCalculos = window.setTimeout(() => this.cerrarTooltipCalculos(tooltipCalculos), 190);
	}

	cerrarTooltipCalculos(tooltipCalculos = this.template.querySelector('.tooltipCalculos')) {
		tooltipCalculos.classList.remove('visible');
	}
}