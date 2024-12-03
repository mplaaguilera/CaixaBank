/*eslint-disable @salesforce/aura/ecma-intrinsics, @lwc/lwc/no-for-of, @lwc/lwc/no-async-await, arrow-body-style*/
import {LightningElement, api, wire, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import {loadStyle} from 'lightning/platformResourceLoader';
import currentUserId from '@salesforce/user/Id';

import loadCssFile from '@salesforce/resourceUrl/csbd_calculadora_dti_style';
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
export default class csbdCalculadoraDtiModal extends NavigationMixin(LightningElement) {
	@api recordId;

	cssLoaded = false;

	oportunidad;

	datatableColumns = DATATABLE_COLUMNS;

	@track datatableData = {};

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

	wireTimestamp = null;

	mensajesInfo = MENSAJES_INFO;

	camposCabecera;

	tiposBonificados;

	modalMapaAbierto = false;

	@track datatableTiposBonificados = {columns: DATATABLE_TIPOS_BONIFICADOS_COLUMNS, data: []};

	//textareaJsonDebugValue;

	@wire(getRecord, {recordId: '$recordId', fields: OPPTY_FIELDS, timestamp: '$wireTimestamp'})
	async wiredOpportunity({data: wiredData, errorGetRecord}) {
		try {
			if (wiredData) {
				this.oportunidad = JSON.parse(JSON.stringify(wiredData)); //parse + stringify para tener deep copy del objeto
				this.camposCabecera = camposCabecera(wiredData);
				this.datatableTiposBonificados.data = await this.tiposBonificadosDatatableData();

				//this.textareaJsonDebugValue = getFieldValue(wiredData, OPPTY_DATOS_CALCULO) ? JSON.stringify(JSON.parse(getFieldValue(wiredData, OPPTY_DATOS_CALCULO))) : null;

				if (this.data) {
					this.data.actualizarDatosOportunidad(wiredData);
				} else {
					let datosGuardados = getFieldValue(wiredData, OPPTY_DATOS_CALCULO);
					if (datosGuardados) {
						this.data = Data.cargarDatosGuardados(JSON.parse(datosGuardados), wiredData);
					} else {
						this.data = new Data(wiredData);
					}
				}

				await this.refrescarDatatableData(this.wireTimestamp);
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
		if (!this.cssLoaded) {
			loadStyle(this, loadCssFile)
				.then(async () => {
					this.cssLoaded = true;
					this.cardBodyVisible();
				}).catch(error => {
					console.error('Error cargando fichero CSS: ' + error.message);
					toast('error', 'Problema aplicando fichero CSS', error.body.message);
				});
		}
	}

	cardBodyVisible() {
		if (this.cssLoaded && this.data) {
			const spinnerContainer = this.template.querySelector('div.spinnerContainer');
			spinnerContainer.classList.add('transparente');
			window.setTimeout(() => {
				spinnerContainer.classList.add('slds-hide');
				const articles = this.template.querySelectorAll('article.cardCalculadoraDti, article.cardDebug');
				articles.forEach(c => c.classList.remove('noVisible'));
				articles.forEach(c => c.classList.remove('transparente'));
			}, 80);
		}
	}

	datatableOncellchange(event) {
		console.log('event.detail.draftValues');
		console.log(event.detail.draftValues);
		this.cambiosSinGuardar = true;
		const draftValue = event.detail.draftValues[0];
		//fieldName es el fieldName de la columna modificada
		let [fieldName, nuevoValor] = Object.entries(draftValue).find(([key]) => key !== 'id');
		nuevoValor = nuevoValor ? nuevoValor : 0;

		//Validaciones
		if (['interes', 'porcentajeGastosConstitucion'].includes(draftValue.id) && (nuevoValor < 0 || nuevoValor > 100)) {
			if (draftValue.id === 'interes') {
				toast('info', 'Valor no válido para "Interés (%)"', 'Indica un valor entre 0% y 100%.');
			} else if (draftValue.id === 'porcentajeGastosConstitucion') {
				toast('info', 'Valor no válido para "Gastos de constitución (%)"', 'Indica un valor entre 0% y 100%.');
			}
			event.target.draftValues = null;
			return;
		}

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

	async tiposBonificadosDatatableData() {
		const formatearTipo = t => parseFloat((t * 100).toFixed(2)).toString() + '%';

		!this.tiposBonificados && (this.tiposBonificados = await tiposBonificadosApex({}));
		let importeCompraventa = getFieldValue(this.oportunidad, OPPTY_PRECIO_INMUEBLE);
		importeCompraventa = importeCompraventa ? importeCompraventa : 0;
		let importeHipoteca = getFieldValue(this.oportunidad, OPPTY_AMOUNT);
		importeHipoteca = importeHipoteca ? importeHipoteca : 0;
		const importeBase = importeCompraventa - importeHipoteca;

		let tiposBonificadosData = [];
		for (let nombre in this.tiposBonificados) {
			if (Object.prototype.hasOwnProperty.call(this.tiposBonificados, nombre)) {
				if (nombre === 'General' || nombre === getFieldValue(this.oportunidad, OPPTY_COMUNIDAD_AUTONOMA)) {
					const tipos = this.tiposBonificados[nombre];
					tiposBonificadosData.push({
						nombre, columns: DATATABLE_TIPOS_BONIFICADOS_COLUMNS[nombre === 'General' ? 'general' : 'ccaa'],
						data: tipos.map(t => {
							const porcentajeGastos = nombre === 'General' ? 0 : 0.01;
							const importe = parseFloat((importeBase + importeCompraventa * (t.valor + porcentajeGastos)).toString());
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

		return tiposBonificadosData.sort((a, b) => {
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

	datatableTiposBonificadosOnrowaction(event) {
		if (event.detail.action.name === 'actionAplicar') {
			this.oportunidad.fields.CSBD_TipoBonificado__c.value = -1;
			this.refrescarDatatableData(false); //Sin resaltar cambios
			alert(JSON.stringify(event.detail.row, null, 3));
			alert(event.detail.row.valor);
			this.oportunidad.fields.CSBD_TipoBonificado__c.value = event.detail.row.valor;
			this.refrescarDatatableData();
			this.cambiosSinGuardar = true;
		}
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
		alert(this.data.porcentajeBonificacion);
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

	async botonCancelarOnclick() {
		if (await LightningConfirm.open({
			variant: 'header', theme: 'offline', label: 'Descartar cambios',
			message: '¿Quieres descartar los cambios? Se perderán todas las modificaciones realizadas desde el último guardado.'
		})) {
			this.template.querySelectorAll('.botonesFooter').forEach(b => {b.disabled = true});
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => this.reiniciarData(), 0);
		}
	}

	menuSettingsOnselect({detail: {value}}) {
		if (value === 'borrarDatosGuardados') {
			this.modalBorrarDatosGuardadosAbrir();
		} else if (value === 'debugger') {
			debugger;
		} else if (value === 'log') {
			//eslint-disable-next-line no-console
			console.log(this.oportunidad);
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
		}
		this.data = null;
		this.wireTimestamp = new Date();
		this.cambiosSinGuardar = false;
	}

	navegarDetalleRegistro({currentTarget: {dataset: {recordId}}}) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage', attributes: {recordId, actionName: 'view'}
		});
	}

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
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => abrir(), 1100);
		}
	}

	modalMapaCerrar() {
		this.template.querySelector('section.modalMapa').classList.remove('slds-fade-in-open');
		this.template.querySelector('div.slds-backdrop').classList.remove('slds-backdrop--open');
		this.template.querySelector('.botonModalMapaAbrir').variant = null;
	}

	modalOnkeydown(event) {
		event.keyCode === 27 && this.modalMapaCerrar(); //Tecla ESC
	}

	scrollToTop() {
		window.scrollTo({top: 350, behavior: 'smooth'});
	}

	modalBorrarDatosGuardadosAbrir() {
		this.template.querySelector('section.modalBorrarDatosGuardados').classList.add('slds-fade-in-open');
		this.template.querySelector('div.slds-backdrop').classList.add('slds-backdrop_open');

	}

	modalBorrarDatosGuardadosACerrar() {
		this.template.querySelector('section.modalBorrarDatosGuardados').classList.remove('slds-fade-in-open');
		this.template.querySelector('div.slds-backdrop').classList.remove('slds-backdrop_open');
	}

	async modalBorrarDatosGuardadosAceptar() {
		if (getFieldValue(this.oportunidad, OPPTY_OWNER_ID) !== currentUserId) {
			toast('info', 'No eres el propietario de la oportunidad', 'Solo el propietario de la oportunidad puede modificarla (propietario actual: ' + getFieldValue(this.oportunidad, OPPTY_OWNER_NAME) + ')');
		} else {
			if (await LightningConfirm.open({
				variant: 'header', theme: 'warning', label: 'Borrar datos guardados',
				message: '¿Quieres borrar los datos guardados? Se perderán todas las modificaciones realizadas desde la recepción de la oportunidad. Atención, los datos de campos modificables fuera de la pestaña "Entrevista" conservarán su valor.'
			})) {
				this.template.querySelectorAll('.botonesFooter').forEach(b => {b.disabled = true});
				await this.reiniciarData(true);
			}
		}
	}

	modalBorrarDatosGuardadosTeclaPulsada(event) {
		event.keyCode === 27 && this.modalBorrarDatosGuardadosACerrar(); //Tecla ESC
	}
}