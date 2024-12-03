import {getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import OPPTY_TIPO_OPERACION from '@salesforce/schema/Opportunity.CSBD_TipoOperacion2__c';
import OPPTY_USO_VIVIENDA from '@salesforce/schema/Opportunity.CSBD_UsoVivienda2__c';
import OPPTY_TIPO_CONSTRUCCION from '@salesforce/schema/Opportunity.CSBD_TipoConstruccion2__c';
import OPPTY_CIRBE_SOLICITADO from '@salesforce/schema/Opportunity.CSBD_OC_Cirbe_Solicitado__c';
import OPPTY_PRECIO_INMUEBLE from '@salesforce/schema/Opportunity.CSBD_PrecioInmueble__c';
import OPPTY_AMOUNT from '@salesforce/schema/Opportunity.Amount';
import OPPTY_NOW_PLAZO from '@salesforce/schema/Opportunity.CSBD_Now_Plazo__c';
import OPPTY_APORTACION_INICIAL from '@salesforce/schema/Opportunity.CSBD_AportacionInicial__c';
import OPPTY_TIN_INICIAL from '@salesforce/schema/Opportunity.CSBD_TIN_Inicial__c';
//@@@import OPPTY_TIPO_BONIFICADO from '@salesforce/schema/Opportunity.CSBD_TipoBonificado__c';
import OPPTY_DONACION from '@salesforce/schema/Opportunity.CSBD_OC_Donacion__c';
import OPPTY_COMUNIDAD_AUTONOMA from '@salesforce/schema/Opportunity.CSBD_Comunidad_Autonoma_2__c';
//import OPPTY_PROVINCIA from '@salesforce/schema/Opportunity.CSBD_Provincia_2__c';
import OPPTY_CODIGO_POSTAL from '@salesforce/schema/Opportunity.CSBD_CodigoPostal__c';
import OPPTY_MUNICIPIO from '@salesforce/schema/Opportunity.CSBD_Municipio__c';
import OPPTY_VIA_TIPO from '@salesforce/schema/Opportunity.CSBD_TipoVia__c';
import OPPTY_VIA_NOMBRE from '@salesforce/schema/Opportunity.CSBD_CalleVivienda__c';
import OPPTY_VIA_NUMERO from '@salesforce/schema/Opportunity.CSBD_NumeroVivienda__c';
import OPPTY_VIA_PISO from '@salesforce/schema/Opportunity.CSBD_PisoVivienda__c';
import OPPTY_VIA_PUERTA from '@salesforce/schema/Opportunity.CSBD_PuertaVivienda__c';

export function toast(variant, title, message) {
	dispatchEvent(new ShowToastEvent({variant: variant, title: title, message: message, mode: 'dismissable', duration: 4000}));
}

export const MENSAJES_INFO = [
	{
		tipo: 'camposRequeridosInformados', mostrar: false, iconName: 'utility:edit', texto: 'Campos requeridos informados.',
		title: 'Importe del inmueble, importe de la hipoteca, interés y plazo.'
	},
	{
		tipo: 'camposRequeridosNoInformados', mostrar: false, iconName: 'utility:edit', iconoClass: 'iconoError', texto: 'Campos requeridos sin informar.',
		title: 'Importe del inmueble, importe de la hipoteca, interés y plazo.'
	},
	{tipo: 'cambiosGuardados', mostrar: true, iconName: 'utility:info_alt', texto: 'Modificaciones guardadas.'},
	{tipo: 'cambiosSinGuardar', mostrar: false, iconName: 'utility:warning', iconoClass: 'iconoWarning', texto: 'Hay modificaciones sin guardar.', textoStyle: 'color: #c13410;'}
];

export const CAMPOS_OPORTUNIDAD = [
	{ref: 'cirbeSolicitado', field: OPPTY_CIRBE_SOLICITADO, bool: true},
	{ref: 'importeCompraventa', field: OPPTY_PRECIO_INMUEBLE},
	{ref: 'importeHipoteca', field: OPPTY_AMOUNT},
	{ref: 'plazo', field: OPPTY_NOW_PLAZO},
	{ref: 'pagosACuenta', field: OPPTY_APORTACION_INICIAL},
	{ref: 'donacion', field: OPPTY_DONACION},
	{ref: 'interes', field: OPPTY_TIN_INICIAL},
	//@@@@{ref: 'tipoBonificado', field: OPPTY_TIPO_BONIFICADO}
];

export function camposCabecera(wiredOpportunity) {
	let tipoOperacion = getFieldValue(wiredOpportunity, OPPTY_TIPO_OPERACION)?.toUpperCase() ?? '(¿Tipo de operación?)';
	if (tipoOperacion === 'COMPRA DE VIVIENDA') {
		tipoOperacion = 'COMPRAVENTA';
	}
	const usoVivienda = getFieldValue(wiredOpportunity, OPPTY_USO_VIVIENDA)?.toUpperCase() ?? '(¿Uso de la vivienda?) ';
	const tipoConstruccion = getFieldValue(wiredOpportunity, OPPTY_TIPO_CONSTRUCCION)?.toUpperCase() ?? '(¿Tipo de construcción?)';

	let direccion = '';
	if (getFieldValue(wiredOpportunity, OPPTY_VIA_NOMBRE)) {
		if (getFieldValue(wiredOpportunity, OPPTY_VIA_TIPO)) {
			direccion += getFieldValue(wiredOpportunity, OPPTY_VIA_TIPO);
		}
		if (direccion) {
			direccion += ' ';
		}
		direccion += getFieldValue(wiredOpportunity, OPPTY_VIA_NOMBRE);
		if (getFieldValue(wiredOpportunity, OPPTY_VIA_NUMERO)) {
			direccion += ' ' + getFieldValue(wiredOpportunity, OPPTY_VIA_NUMERO);
		}
		if (getFieldValue(wiredOpportunity, OPPTY_VIA_PISO) || getFieldValue(wiredOpportunity, OPPTY_VIA_PUERTA)) {
			direccion += ' (';
			if (getFieldValue(wiredOpportunity, OPPTY_VIA_PISO)) {
				direccion += getFieldValue(wiredOpportunity, OPPTY_VIA_PISO);
			}
			if (getFieldValue(wiredOpportunity, OPPTY_VIA_PUERTA)) {
				if (getFieldValue(wiredOpportunity, OPPTY_VIA_PISO)) {
					direccion += ' ';
				}
				direccion += getFieldValue(wiredOpportunity, OPPTY_VIA_PUERTA);
			}
			direccion += ')';
		}
	}
	//const via = direccion;
	if (getFieldValue(wiredOpportunity, OPPTY_CODIGO_POSTAL)) {
		if (direccion) {
			direccion += ', ';
		}
		direccion += getFieldValue(wiredOpportunity, OPPTY_CODIGO_POSTAL);
	}
	if (getFieldValue(wiredOpportunity, OPPTY_MUNICIPIO)) {
		if (direccion) {
			direccion += ' ';
		}
		direccion += getFieldValue(wiredOpportunity, OPPTY_MUNICIPIO);
	}
	let comunidadAutonoma = getFieldValue(wiredOpportunity, OPPTY_COMUNIDAD_AUTONOMA);
	if (comunidadAutonoma) {
		if (direccion) {
			comunidadAutonoma = ' (' + comunidadAutonoma + ')';
		}
		direccion += comunidadAutonoma;
	}
	direccion = direccion.toUpperCase();

	return {
		tipoOperacion, usoVivienda, tipoConstruccion, direccion,
		tipoOperacionUsoVivienda: tipoOperacion + ' de ' + usoVivienda
		/*
		mapMarkers: [{
			title: via + ', ' + getFieldValue(wiredOpportunity, OPPTY_MUNICIPIO),
			description: '<p>' + tipoOperacion + ' de ' + usoVivienda + '.</p><p>' + tipoConstruccion + '.</p>',
			direccion, icon: 'standard:account', location: {
				value: 'inmueble',
				Country: 'Spain',
				State: getFieldValue(wiredOpportunity, OPPTY_COMUNIDAD_AUTONOMA),
				City: getFieldValue(wiredOpportunity, OPPTY_MUNICIPIO),
				PostalCode: getFieldValue(wiredOpportunity, OPPTY_CODIGO_POSTAL),
				Street: getFieldValue(wiredOpportunity, OPPTY_VIA_NOMBRE)
			}
		}],
		mapOptions: {disableDefaultUI: true}
		*/
	};
}

export const DATATABLE_TIPOS_BONIFICADOS_COLUMNS = {
	general: [
		{fieldName: 'tipoConGastos', fixedWidth: 96, cellAttributes: {class: 'gris negrita'}},
		{fieldName: 'importe', fixedWidth: 87, type: 'currency', typeAttributes: {maximumFractionDigits: 0}}
	],
	ccaa: [
		{fieldName: 'tipo', fixedWidth: 48, cellAttributes: {class: 'gris'}},
		{fieldName: 'tipoConGastos', fixedWidth: 48, cellAttributes: {class: 'gris negrita'}},
		{fieldName: 'importe', fixedWidth: 87, type: 'currency', typeAttributes: {maximumFractionDigits: 0}}
	]
};

export async function animarCambiosTablas(datatableData, datatableDataNew) {
	//Determinar tablas y cálculos con cambios
	const modificaciones = encontrarDiferencias(datatableData, datatableDataNew);
	let datatablesModificadas = [];
	let calculosModificados = [];
	for (let key in modificaciones) {
		if (Object.prototype.hasOwnProperty.call(modificaciones, key)) {
			//if (!isNaN(modificaciones[key].anterior) || !isNaN(modificaciones[key].nuevo)) {
			const ruta = key.split('.');
			if (ruta[0] === 'calculos') {
				calculosModificados.push(ruta[1]);
			} else {
				const dtColumns = this.template.querySelector('.datatableContainer > lightning-datatable[data-datatable="' + ruta[0] + '"]').columns;
				let aumento = 'Aumento' ;
				if (!isNaN(modificaciones[key].anterior) && !isNaN(modificaciones[key].nuevo)) {
					aumento = Math.sign(modificaciones[key].nuevo - modificaciones[key].anterior) === 1 ? 'Aumento' : 'Descenso';
				}
				datatablesModificadas.push({
					tabla: ruta[0], fila: ruta[1],
					aumento,
					columna: dtColumns.findIndex(c => c.fieldName === ruta[2])
				});
			}
			//}
		}
	}

	//Animar tablas que han cambiado
	let clasesAplicadas = [];
	[...new Set(datatablesModificadas)].forEach(({tabla, fila, columna, aumento}) => {
		this.template.querySelectorAll('.datatableContainer > lightning-datatable[data-datatable="' + tabla + '"]').forEach(dt => {
			const clase = 'animarCelda' + aumento + 'F' + fila + 'C' + columna;
			dt.classList.add(clase);
			clasesAplicadas.push({tabla: dt, clase});
		});
	});
	//eslint-disable-next-line @lwc/lwc/no-async-operation
	window.setTimeout(() => clasesAplicadas.forEach(cA => cA.tabla.classList.remove(cA.clase)), 2500);

	//Animar indicadores de viabilidad que han cambiado
	[...new Set(calculosModificados)].forEach(calculo => {
		const calculoItem = this.template.querySelector('div.divCalculos div.divCalculoItem[data-calculo="' + calculo + '"]');
		if (calculoItem) {
			calculoItem.classList.add('animarCalculo');
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => calculoItem.classList.remove('animarCalculo'), 1500);
		}
	});
}

function encontrarDiferencias(anterior, nuevo) {
	const diff = {};
	const comparar = (objA, objB, ruta = '') => {
		for (let key in objA) {
			if (Object.prototype.hasOwnProperty.call(objA, key)) {
				const nuevaRuta = ruta ? `${ruta}.${key}` : key;

				if (Object.prototype.hasOwnProperty.call(objB, key)) {
					if (typeof objA[key] === 'object' && typeof objB[key] === 'object') {
						comparar(objA[key], objB[key], nuevaRuta);
					} else {
						if (objA[key] !== objB[key]) {
							diff[nuevaRuta] = {anterior: objA[key], nuevo: objB[key]};
						}
					}
				} else {
					diff[nuevaRuta] = {anterior: objA[key], nuevo: null};
				}
			}
		}
		for (let key in objB) {
			if (Object.prototype.hasOwnProperty.call(objB, key) && !Object.prototype.hasOwnProperty.call(objA, key)) {
				const nuevaRuta = ruta ? `${ruta}.${key}` : key;
				diff[nuevaRuta] = {anterior: null, nuevo: objB[key]};
			}
		}
	};
	comparar(anterior, nuevo);
	return diff;
}

export function formatCalculo(valor, decimales = 3, sinDecimalesExtra = false) {
	if (valor || valor === 0) {
		valor *= 100;
		if (!Number.isInteger(valor)) {
			valor = (Math.round(valor * 1000) / 1000).toFixed(decimales);
			sinDecimalesExtra && (valor = parseFloat(valor).toFixed(decimales));
		}
		return valor;
	}
	return null;
}