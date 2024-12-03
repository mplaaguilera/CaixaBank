import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import getTablaMaestraApex from '@salesforce/apex/CSBD_TiposOferta_Controller.getTablaMaestra';

import OPPTY_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';
import OPPTY_TIPOS_OFERTA_JSON from '@salesforce/schema/Opportunity.CSBD_TiposOfertaJson__c';
import OPPTY_PRODUCTO from '@salesforce/schema/Opportunity.CSBD_Producto__c';
import OPPTY_AMOUNT from '@salesforce/schema/Opportunity.Amount';
import OPPTY_PLAZO from '@salesforce/schema/Opportunity.CSBD_Now_Plazo__c';
//import OPPTY_CATEGORIA_TITULAR from '@salesforce/schema/Opportunity.CSBD_CategoriaTitular__c';
import OPPTY_TITULAR1_INGRESOS from '@salesforce/schema/Opportunity.CSBD_ContactoTitular1__r.CSBD_IngresosAnuales__c';
import OPPTY_TITULAR2_INGRESOS from '@salesforce/schema/Opportunity.CSBD_ContactoTitular2__r.CSBD_IngresosAnuales__c';
import TABLAPRECIOS_NOMBRE_LOV from '@salesforce/schema/CC_Lista_Valores__c.Name';
import TABLAPRECIOS_NOMBRE from '@salesforce/schema/CC_Lista_Valores__c.CSBD_TablaPrecios_Nombre__c';
import TABLAPRECIOS_JSON from '@salesforce/schema/CC_Lista_Valores__c.CSBD_TiposOfertaJson__c';

export default class csbdTiposOferta extends LightningElement {
	@api recordId;

	@api objectApiName;

	parametros = {
		'CC_Lista_Valores__c': {nombreObjeto: 'tabla de precios', objetoName: getFieldValue(this.listaValores, TABLAPRECIOS_NOMBRE)},
		'Opportunity': {nombreObjeto: 'oportunidad', objetoName: getFieldValue(this.oportunidad, OPPTY_IDENTIFICADOR)}
	};

	listaValores;

	oportunidad;

	listaPreciosMaestra; //lista maestra

	precios = {
		fijoNoBonificado: null,
		fijoBonificado: null,
		variableNoBonificado: null,
		variableBonificado: null,
		mixtoAñosTramoFijo: null,
		mixtoTramoFijoNoBonificado: null,
		mixtoTramoFijoBonificado: null,
		mixtoTramoVariableNoBonificado: null,
		mixtoTramoVariableBonificado: null
	};

	get editandoTablaMaestra() {
		return this.objectApiName === 'CC_Lista_Valores__c';
	}

	get listaPreciosMaestraNoDefinida() {
		return !this.listaPreciosMaestra;
	}

	get getRecordFields() {
		if (this.objectApiName === 'CC_Lista_Valores__c') {
			return [TABLAPRECIOS_NOMBRE_LOV, TABLAPRECIOS_NOMBRE, TABLAPRECIOS_JSON];
		} else {
			return [
				OPPTY_IDENTIFICADOR, OPPTY_TIPOS_OFERTA_JSON, OPPTY_PRODUCTO, OPPTY_AMOUNT,
				OPPTY_PLAZO, OPPTY_TITULAR1_INGRESOS, OPPTY_TITULAR2_INGRESOS //OPPTY_CATEGORIA_TITULAR
			];
		}
	}

	@wire(getRecord, {recordId: '$recordId', fields: '$getRecordFields'})
	async wiredRecord({data, error: errorGetRecord}) {
		try {
			if (data) {
				if (this.objectApiName === 'CC_Lista_Valores__c') { //Editando una lista maestra de precios
					this.listaValores = data;
					if (getFieldValue(data, TABLAPRECIOS_JSON)) {
						this.cargarJson(getFieldValue(data, TABLAPRECIOS_JSON));
					}

				} else if (this.objectApiName === 'Opportunity') { //Editando una oportunidad
					this.oportunidad = data;

					const ingresosAnualesTitular1 = getFieldValue(data, OPPTY_TITULAR1_INGRESOS) ?? 0;
					const ingresosAnualesTitular2 = getFieldValue(data, OPPTY_TITULAR2_INGRESOS) ?? 0;
					const ingresosAnualesTitulares = ingresosAnualesTitular1 + ingresosAnualesTitular2;

					let categoriaTitular;
					if (ingresosAnualesTitular1 >= 36000 || ingresosAnualesTitular2 >= 36000 || ingresosAnualesTitulares >= 48000) {
						categoriaTitular = 'Premium';
					} else if (ingresosAnualesTitulares >= 30000) {
						categoriaTitular = 'Alto valor +';
					} else {
						categoriaTitular = 'Alto valor';
					}
					const categoriaTitularTitle = `${categoriaTitular} (${ingresosAnualesTitular1} + ${ingresosAnualesTitular2})`;

					this.oportunidad = {...this.oportunidad,
						plazo: (getFieldValue(data, OPPTY_PLAZO) ?? 0) > 240 ? 'Largo' : 'Corto',
						categoriaTitular, categoriaTitularTooltip: categoriaTitularTitle, ingresosAnualesTitular1, ingresosAnualesTitular2,
						plazoMeses: `${getFieldValue(data, OPPTY_PLAZO) ?? 0} meses`
					};

					let tablaMaestraJson;
					//if (getFieldValue(data, OPPTY_PRODUCTO) && getFieldValue(data, OPPTY_CATEGORIA_TITULAR)) {
					if (getFieldValue(data, OPPTY_PRODUCTO)) {
						tablaMaestraJson = await getTablaMaestraApex({
							producto: getFieldValue(data, OPPTY_PRODUCTO),
							plazo: getFieldValue(data, OPPTY_PLAZO) ?? 0,
							categoriaTitular: categoriaTitular
						});
						this.listaPreciosMaestra = tablaMaestraJson ? JSON.parse(tablaMaestraJson) : null;
						this.template.querySelector('lightning-button.botonRestablecer').classList.toggle('slds-hide', !tablaMaestraJson);
					}

					if (getFieldValue(data, OPPTY_TIPOS_OFERTA_JSON)) {
						this.cargarJson(getFieldValue(data, OPPTY_TIPOS_OFERTA_JSON));
					} else if (tablaMaestraJson) {
						this.cargarJson(tablaMaestraJson);
					}

					this.template.querySelector('article.contenedor').classList.add('editandoOportunidad');
				}

			} else if (errorGetRecord) {
				throw errorGetRecord;
			}
		} catch (error) {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de la ' + this.parametros[this.objectApiName].nombreObjeto, error.message ?? error);
		}
	}

	cargarJson(json = '') {
		if (this.objectApiName === 'CC_Lista_Valores__c') {
			this.listaPreciosMaestra = JSON.parse(json);
			this.precios = {...this.listaPreciosMaestra};
		} else if (this.objectApiName === 'Opportunity') {
			if (!json) {
				this.precios = {...this.listaPreciosMaestra};
			} else {
				const datos = JSON.parse(json);
				if (Object.hasOwnProperty.call(datos, 'oportunidad')) {
					this.precios = datos.oportunidad;
				} else {
					this.precios = {...this.listaPreciosMaestra};
				}
			}
		}
		window.setTimeout(() => this.calcularCuotas(), 0);
	}

	campoOnchange({currentTarget: inputInteres, detail: {value: valor}}) {
		if (this.objectApiName === 'CC_Lista_Valores__c') {
			if (!this.listaPreciosMaestra) {
				this.listaPreciosMaestra = {};
			}
			this.listaPreciosMaestra[inputInteres.dataset.name] = inputInteres.validity.valid ? valor : null;
		}
		this.precios[inputInteres.dataset.name] = inputInteres.validity.valid ? valor : null;

		inputInteres.reportValidity();
		this.calcularCuotas();
		this.template.querySelectorAll('lightning-button.botonGuardar').forEach(b => b.variant = 'destructive');
	}

	calcularCuotas() {
		const importeHipoteca = getFieldValue(this.oportunidad, OPPTY_AMOUNT);
		const plazo = getFieldValue(this.oportunidad, OPPTY_PLAZO);
		if (importeHipoteca && plazo) {
			this.template.querySelectorAll('lightning-input.inputCuota').forEach(inputCuota => {
				const interes = this.precios[inputCuota.dataset.name];
				inputCuota.value = interes ? this.interesToCuota(importeHipoteca, plazo, interes) : null;
			});
		}
	}

	interesToCuota(importeHipoteca, plazo, interes) {
		if (!interes) {
			return null;
		}
		const tasa = 1 + interes / 100 / 12 - 1;
		if (tasa === 0) {
			return importeHipoteca / (plazo * 12) / 12;
		}
		const factorPresenteValorFuturo = Math.pow(1 + tasa, plazo);
		return -tasa * (-importeHipoteca * factorPresenteValorFuturo) / (factorPresenteValorFuturo - 1);
	}

	botonGuardarOnclick() {
		const {nombreObjeto, objetoName} = this.parametros[this.objectApiName];
		const toastSuccess = {
			title: 'Se actualizó correctamente la ' + nombreObjeto,
			message: 'Se actualizó correctamente la ' + nombreObjeto + ' ' + objetoName
		};
		this.guardar(toastSuccess);
	}

	guardar(toastSuccess) {
		const botonesDisabledGuardar = this.template.querySelectorAll('lightning-button.botonDisabledGuardar');
		botonesDisabledGuardar.forEach(b => b.disabled = true);

		//Valor del JSON que se guardará
		let jsonTiposOferta;
		if (this.objectApiName === 'CC_Lista_Valores__c') {
			if (this.objetoVacio(this.listaPreciosMaestra)) {
				jsonTiposOferta = '';
			} else {
				jsonTiposOferta = JSON.stringify(this.listaPreciosMaestra, null, 3);
			}
		} else if (this.objectApiName === 'Opportunity') {
			if (this.objetoVacio(this.precios)) {
				jsonTiposOferta = '';
			} else {
				jsonTiposOferta = JSON.stringify({
					oportunidad: this.precios,
					listaPrecios: this.listaPreciosMaestra
				}, null, 3);
			}
		}

		//Guardado
		const campos = {};
		campos.Id = this.recordId;
		if (this.objectApiName === 'CC_Lista_Valores__c') {
			campos[TABLAPRECIOS_NOMBRE_LOV.fieldApiName] = getFieldValue(this.listaValores, TABLAPRECIOS_NOMBRE);
			campos[TABLAPRECIOS_JSON.fieldApiName] = jsonTiposOferta;
		} else if (this.objectApiName === 'Opportunity') {
			campos[OPPTY_TIPOS_OFERTA_JSON.fieldApiName] = jsonTiposOferta;
		}
		updateRecord({fields: campos})
		.then(() => {
			this.toast('success', toastSuccess.title, toastSuccess.message);
			this.template.querySelectorAll('lightning-button.botonGuardar').forEach(b => b.variant = 'brand');
		}).catch(error => {
			console.error(error);
			this.toast('error', 'Problema actualizando la ' + this.parametros[this.objectApiName].nombreObjeto, error.body?.message);
		}).finally(() => botonesDisabledGuardar.forEach(b => b.disabled = false));
	}

	async restablecer() {
		if (await LightningConfirm.open({
			variant: 'header', theme: 'warning', label: 'Restablecer',
			message: '¿Quieres restablecer los valores por defecto para todos los campos del formulario? Esta acción no se puede deshacer.'
		})) {
			this.cargarJson();
			const toastSuccess = {
				title: 'Se restableció Oportunidad',
				message: 'Se restablecieron los valores por defecto de la oportunidad ' + getFieldValue(this.oportunidad, OPPTY_IDENTIFICADOR)
			};
			this.guardar(toastSuccess);
		}
	}

	objetoVacio(objeto) {
		return !objeto || !Object.values(objeto).some(v => v !== null && v !== '');
	}

	toast(variant, title, message) {
		title && dispatchEvent(new ShowToastEvent({variant, title, message, mode: 'dismissable', duration: 4000}));
	}
}