/*eslint-disable @salesforce/aura/ecma-intrinsics */
import {getFieldValue} from 'lightning/uiRecordApi';
import currentUserId from '@salesforce/user/Id';

import {formatCalculo} from './utils';

import OPPTY_PRIORIDAD from '@salesforce/schema/Opportunity.CSBD_OC_Prioridad__c';
import OPPTY_CANAL_ENTRADA from '@salesforce/schema/Opportunity.CSBD_OC_Canal_Entrada__c';
import OPPTY_CIRBE_SOLICITADO from '@salesforce/schema/Opportunity.CSBD_OC_Cirbe_Solicitado__c';
import OPPTY_PRECIO_INMUEBLE from '@salesforce/schema/Opportunity.CSBD_PrecioInmueble__c';
import OPPTY_AMOUNT from '@salesforce/schema/Opportunity.Amount';
import OPPTY_NOW_PLAZO from '@salesforce/schema/Opportunity.CSBD_Now_Plazo__c';
import OPPTY_APORTACION_INICIAL from '@salesforce/schema/Opportunity.CSBD_AportacionInicial__c';
import OPPTY_DONACION from '@salesforce/schema/Opportunity.CSBD_OC_Donacion__c';
import OPPTY_TIN_INICIAL from '@salesforce/schema/Opportunity.CSBD_TIN_Inicial__c';
import OPPTY_PORCENTAJE_BONIFICACION from '@salesforce/schema/Opportunity.CSBD_PorcentajeBonificacion__c';
import OPPTY_TITULAR1_ID from '@salesforce/schema/Opportunity.CSBD_ContactoTitular1__c';
import OPPTY_TITULAR2_ID from '@salesforce/schema/Opportunity.CSBD_ContactoTitular2__c';

const VERSION_DATOS_GUARDADOS = '3';

class TitularItem {
	tipo;

	ingresos;

	numPagosImpuestos;

	get neto() {
		if (this.tipo === 'Ingresos netos IRPF') {
			return this.ingresos - this.numPagosImpuestos;
		} else if (this.tipo === 'Ingresos por alquiler') {
			//return this.ingresos * this.numPagosImpuestos / 2;
			return this.ingresos * this.numPagosImpuestos;
		} else {
			return this.ingresos * this.numPagosImpuestos;
		}
	}

	constructor(tipo = 'Nóminas netas', ingresos = 0, numPagosImpuestos = 0) {
		if (!tipo || !['Nóminas netas', 'Ingresos netos IRPF', 'Otros ingresos', 'Ingresos por alquiler'].includes(tipo)) {
			throw new Error('TitularItem: Tipo incorrecto');
		}
		this.tipo = tipo;
		this.ingresos = ingresos;
		this.numPagosImpuestos = numPagosImpuestos;
	}
}

class Titular {
	tipo;

	nominasNetas;

	ingresosNetosIrpf;

	otrosIngresos;

	ingresosAlquiler;

	get totalIngresosNomina() {
		return parseFloat(this.nominasNetas.ingresos) + parseFloat(this.otrosIngresos.ingresos) + parseFloat(this.ingresosAlquiler.ingresos);
	}

	get totalIngresosNominaProrrateado() {
		let retorno = 0;
		retorno += parseFloat(this.nominasNetas.ingresos) * parseFloat(this.nominasNetas.numPagosImpuestos) / 12;
		retorno += parseFloat(this.otrosIngresos.ingresos) * parseFloat(this.otrosIngresos.numPagosImpuestos) / 12;
		//Para los ingresos por alquiler el requerimiento es que al calcular el DTI solo se tenga en cuenta el 50%
		retorno += parseFloat(this.ingresosAlquiler.ingresos) * parseFloat(this.ingresosAlquiler.numPagosImpuestos) / 12 / 2;
		return retorno;
	}

	get totalNetoNomina() {
		return parseFloat(this.nominasNetas.neto) + parseFloat(this.otrosIngresos.neto) + parseFloat(this.ingresosAlquiler.neto);
	}

	get totalIngresosIrpf() {
		return parseFloat(this.ingresosNetosIrpf.ingresos) + parseFloat(this.otrosIngresos.ingresos) + parseFloat(this.ingresosAlquiler.ingresos);
	}

	get totalIngresosIrpfProrrateado() {
		let retorno = 0;
		retorno += (parseFloat(this.ingresosNetosIrpf.ingresos) - parseFloat(this.ingresosNetosIrpf.numPagosImpuestos)) / 12;
		retorno += parseFloat(this.otrosIngresos.ingresos) * parseFloat(this.otrosIngresos.numPagosImpuestos) / 12;
		//Para los ingresos por alquiler el requerimiento es que al calcular el DTI solo se tenga en cuenta el 50%
		retorno += parseFloat(this.ingresosAlquiler.ingresos) * parseFloat(this.ingresosAlquiler.numPagosImpuestos) / 12 / 2;
		return retorno;
	}

	get totalNetoIrpf() {
		return parseFloat(this.ingresosNetosIrpf.neto) + parseFloat(this.otrosIngresos.neto) + parseFloat(this.ingresosAlquiler.neto);
	}

	get totalIngresos() {
		return this.totalNetoNomina ? this.totalNetoNomina : this.totalNetoIrpf;
	}

	constructor(tipo, nominasNetas, ingresosNetosIrpf, otrosIngresos, ingresosAlquiler) {
		this.tipo = tipo;
		this.nominasNetas = nominasNetas ?? new TitularItem('Nóminas netas');
		this.ingresosNetosIrpf = ingresosNetosIrpf ?? new TitularItem('Ingresos netos IRPF');
		this.otrosIngresos = otrosIngresos ?? new TitularItem('Otros ingresos');
		this.ingresosAlquiler = ingresosAlquiler ?? new TitularItem('Ingresos por alquiler');
	}

	generarDatatableData() {
		return [
			{id: this.tipo + '.nominasNetas', label: 'Nóminas netas', ingresos: this.nominasNetas.ingresos, numPagosImpuestos: this.nominasNetas.numPagosImpuestos, neto: this.nominasNetas.neto, conceptoClass: 'gris negrita', valorClass: 'amarillo', numPagosImpuestosClass: 'amarillo', netoClass: 'azul'},
			{id: this.tipo + '.ingresosNetosIrpf', label: 'IRPF neto', ingresos: this.ingresosNetosIrpf.ingresos, numPagosImpuestos: this.ingresosNetosIrpf.numPagosImpuestos, neto: this.ingresosNetosIrpf.neto, conceptoClass: 'gris negrita', valorClass: 'amarillo', numPagosImpuestosClass: 'amarillo', netoClass: 'azul'},
			{id: this.tipo + '.otrosIngresos', label: 'Otros', ingresos: this.otrosIngresos.ingresos, numPagosImpuestos: this.otrosIngresos.numPagosImpuestos, neto: this.otrosIngresos.neto, conceptoClass: 'gris negrita', valorClass: 'amarillo', numPagosImpuestosClass: 'amarillo', netoClass: 'azul'},
			{id: this.tipo + '.ingresosAlquiler', label: 'Alquileres', ingresos: this.ingresosAlquiler.ingresos, numPagosImpuestos: this.ingresosAlquiler.numPagosImpuestos, neto: this.ingresosAlquiler.neto, conceptoClass: 'gris negrita', valorClass: 'amarillo', numPagosImpuestosClass: 'amarillo', netoClass: 'azul'},
			{id: this.tipo + '.totalNomina', label: 'Total nóminas', ingresos: this.totalIngresosNomina, neto: this.totalNetoNomina, conceptoClass: 'verdeDisabled negrita', valorClass: 'verde noEdit negrita', numPagosImpuestosClass: 'verde noEdit', netoClass: 'verde negrita'},
			{id: this.tipo + '.totalIrpf', label: 'Total IRPF', ingresos: this.totalIngresosIrpf, neto: this.totalNetoIrpf, conceptoClass: 'verdeDisabled negrita', valorClass: 'verde noEdit negrita', numPagosImpuestosClass: 'verde noEdit', netoClass: 'verde negrita totalNetoIrpf_neto'}
		];
	}
}

class DeudaItem {
	primerTitular;

	segundoTitular;

	get total() {
		return parseFloat(this.primerTitular) + parseFloat(this.segundoTitular);
	}

	constructor(primerTitular = 0, segundoTitular = 0) {
		this.primerTitular = primerTitular;
		this.segundoTitular = segundoTitular;
	}
}

class Deuda {

	parent;

	//cuota;

	dosTitulares; //pasar a parent.dosTitulares !!!

	hipoteca;

	prestamo;

	tarjetas;

	alquiler;

	get cuota() {
		return this.parent.cuota;
	}

	get cuotaBonificada() {
		return this.parent.cuotaBonificada;
	}

	get sumaDeudasPrimerTitular() {
		let sumaDeudasPrimerTitular = parseFloat(this.hipoteca.primerTitular);
		sumaDeudasPrimerTitular += parseFloat(this.prestamo.primerTitular);
		sumaDeudasPrimerTitular += parseFloat(this.tarjetas.primerTitular);
		sumaDeudasPrimerTitular += parseFloat(this.alquiler.primerTitular);
		return Math.round((sumaDeudasPrimerTitular + Number.EPSILON) * 100) / 100;
	}

	get sumaDeudasSegundoTitular() {
		if (this.dosTitulares) {
			let sumaDeudasSegundoTitular = parseFloat(this.hipoteca.segundoTitular);
			sumaDeudasSegundoTitular += parseFloat(this.prestamo.segundoTitular);
			sumaDeudasSegundoTitular += parseFloat(this.tarjetas.segundoTitular);
			sumaDeudasSegundoTitular += parseFloat(this.alquiler.segundoTitular);
			return Math.round((sumaDeudasSegundoTitular + Number.EPSILON) * 100) / 100;
		} else {
			return 0;
		}
	}

	get sumaDeudas() {
		return Math.round((this.sumaDeudasPrimerTitular + this.sumaDeudasSegundoTitular + Number.EPSILON) * 100) / 100;
	}

	get cuotaPrimerTitular() {
		return this.dosTitulares ? this.cuota / 2 : this.cuota;
	}

	get cuotaBonificadaPrimerTitular() {
		return this.dosTitulares ? this.cuotaBonificada / 2 : this.cuotaBonificada;
	}

	get cuotaSegundoTitular() {
		return this.dosTitulares ? this.cuota / 2 : null;
	}

	get cuotaBonificadaSegundoTitular() {
		return this.dosTitulares ? this.cuotaBonificada / 2 : null;
	}

	get totalCuota() {
		return this.cuotaPrimerTitular + this.cuotaSegundoTitular;
	}

	get totalCuotaBonificada() {
		return this.cuotaBonificadaPrimerTitular + this.cuotaBonificadaSegundoTitular;
	}

	get totalDeudaPrimerTitular() {
		return this.sumaDeudasPrimerTitular + this.cuotaPrimerTitular;
	}

	get totalDeudaPrimerTitularBonificacion() {
		return this.sumaDeudasPrimerTitular + this.cuotaBonificadaPrimerTitular;
	}

	get totalDeudaSegundoTitular() {
		return this.dosTitulares ? this.sumaDeudasSegundoTitular + this.cuotaSegundoTitular : 0;
	}

	get totalDeudaSegundoTitularBonificacion() {
		return this.dosTitulares ? this.sumaDeudasSegundoTitular + this.cuotaBonificadaSegundoTitular : 0;
	}

	get totalDeuda() {
		const totalDeuda = this.totalDeudaPrimerTitular + this.totalDeudaSegundoTitular;
		return Math.round((totalDeuda + Number.EPSILON) * 100) / 100;
	}

	get totalDeudaBonificacion() {
		const totalDeudaBonificacion = this.totalDeudaPrimerTitularBonificacion + this.totalDeudaSegundoTitularBonificacion;
		return Math.round((totalDeudaBonificacion + Number.EPSILON) * 100) / 100;
	}

	//constructor(parent, cuota, dosTitulares, hipoteca, prestamo, tarjetas, alquiler) {
	constructor(parent, dosTitulares, hipoteca, prestamo, tarjetas, alquiler) {
		this.parent = parent;
		//this.cuota = cuota;
		this.dosTitulares = dosTitulares;
		this.hipoteca = hipoteca ?? new DeudaItem();
		this.prestamo = prestamo ?? new DeudaItem();
		this.tarjetas = tarjetas ?? new DeudaItem();
		this.alquiler = alquiler ?? new DeudaItem();
	}

	//generarDatatableData(cuota) {
	generarDatatableData() {
		//this.cuota = cuota;
		return [
			{id: 'deuda.hipoteca', label: 'Hipoteca', primerTitular: this.hipoteca.primerTitular, segundoTitular: this.hipoteca.segundoTitular, total: this.hipoteca.total, conceptoClass: 'gris negrita', valorClass: 'amarillo', totalClass: 'azul'},
			{id: 'deuda.prestamo', label: 'Préstamo', primerTitular: this.prestamo.primerTitular, segundoTitular: this.prestamo.segundoTitular, total: this.prestamo.total, conceptoClass: 'gris negrita', valorClass: 'amarillo', totalClass: 'azul'},
			{id: 'deuda.tarjetas', label: 'Tarjetas', primerTitular: this.tarjetas.primerTitular, segundoTitular: this.tarjetas.segundoTitular, total: this.tarjetas.total, conceptoClass: 'gris negrita', valorClass: 'amarillo', totalClass: 'azul'},
			{id: 'deuda.alquiler', label: 'Alquiler', primerTitular: this.alquiler.primerTitular, segundoTitular: this.alquiler.segundoTitular, total: this.alquiler.total, conceptoClass: 'gris negrita', valorClass: 'amarillo', totalClass: 'azul'},
			//{id: 'deuda.sumaDeudas', label: 'Total de deudas', primerTitular: this.sumaDeudasPrimerTitular, segundoTitular: this.sumaDeudasSegundoTitular, total: this.sumaDeudas, conceptoClass: 'verde negrita', valorClass: 'verde noEdit', totalClass: 'verde'},
			{id: 'deuda.sumaDeudas', label: 'Deuda sin cuota', primerTitular: this.sumaDeudasPrimerTitular, segundoTitular: this.sumaDeudasSegundoTitular, total: this.sumaDeudas, conceptoClass: 'verdeDisabled negrita', valorClass: 'verdeDisabled noEdit', totalClass: 'verdeDisabled noEdit'},
			//{id: 'deuda.totalCuota', label: 'Cuota mensual CaixaBank', primerTitular: this.cuotaPrimerTitular, segundoTitular: this.cuotaSegundoTitular, total: this.totalCuota, conceptoClass: 'verde negrita', valorClass: 'verde noEdit', totalClass: 'verde'},
			{id: 'deuda.totalCuota', label: 'Cuota no bonificada', primerTitular: this.cuotaPrimerTitular, segundoTitular: this.cuotaSegundoTitular, total: this.totalCuota, conceptoClass: 'gris negrita', valorClass: 'azul noEdit', totalClass: 'azul noEdit'},
			{id: 'deuda.totalDeuda', label: 'Deuda + cuota no bonificada', primerTitular: this.totalDeudaPrimerTitular, segundoTitular: this.totalDeudaSegundoTitular, total: this.totalDeuda, conceptoClass: 'verdeDisabled negrita', valorClass: 'verde negrita noEdit', totalClass: 'verde negrita noEdit'},
			{id: 'deuda.totalCuota', label: 'Cuota bonificada', primerTitular: this.cuotaBonificadaPrimerTitular, segundoTitular: this.cuotaBonificadaSegundoTitular, total: this.totalCuotaBonificada, conceptoClass: 'gris negrita', valorClass: 'azul noEdit', totalClass: 'azul noEdit'},
			{id: 'deuda.totalDeuda', label: 'Deuda + cuota bonificada', primerTitular: this.totalDeudaPrimerTitularBonificacion, segundoTitular: this.totalDeudaSegundoTitularBonificacion, total: this.totalDeudaBonificacion, conceptoClass: 'verdeDisabled negrita', valorClass: 'verde negrita noEdit', totalClass: 'verde negrita noEdit'}
		];
	}
}

export class Data {

	oportunidad;

	_porcentajeGastosConstitucion = 0;

	ahorro = 0;

	get porcentajeGastosConstitucion() {
		return this._porcentajeGastosConstitucion * 100;
	}

	set porcentajeGastosConstitucion(valor) {
		this._porcentajeGastosConstitucion = valor / 100;
	}

	porcentajeBonificacion;

	get interesBonificado() {
		let interesBonificado = getFieldValue(this.oportunidad, OPPTY_TIN_INICIAL) - this.porcentajeBonificacion;
		return interesBonificado < 0 ? 0 : interesBonificado;
	}

	primerTitular;

	segundoTitular;

	get dosTitulares() {
		return getFieldValue(this.oportunidad, OPPTY_TITULAR1_ID) && getFieldValue(this.oportunidad, OPPTY_TITULAR2_ID);
	}

	deuda;

	get camposRequeridosInformados() {
		let retorno = true;
		const camposRequeridos = [OPPTY_PRECIO_INMUEBLE, OPPTY_AMOUNT, OPPTY_NOW_PLAZO, OPPTY_TIN_INICIAL];
		camposRequeridos.forEach(campoRequerido => retorno = retorno && Boolean(parseFloat(getFieldValue(this.oportunidad, campoRequerido))));
		return retorno;
	}

	get tasa() {
		//eslint-disable-next-line no-extra-parens
		return (1 + (getFieldValue(this.oportunidad, OPPTY_TIN_INICIAL) / 100) / 12) - 1;
	}

	get tasaBonificada() {
		//eslint-disable-next-line no-extra-parens
		return (1 + (this.interesBonificado / 100) / 12) - 1;
	}

	get cuota() {
		const plazo = getFieldValue(this.oportunidad, OPPTY_NOW_PLAZO) ?? 0;
		if (!plazo) {
			return null;
		} else {
			const importeHipoteca = getFieldValue(this.oportunidad, OPPTY_AMOUNT) ?? 0;
			if (this.tasa === 0) {
				return importeHipoteca / (plazo * 12) / 12;
			} else {
				const factorPresenteValorFuturo = Math.pow(1 + this.tasa, plazo);
				return -this.tasa * (-importeHipoteca * factorPresenteValorFuturo) / (factorPresenteValorFuturo - 1);
			}
		}
	}

	get cuotaBonificada() {
		const plazo = getFieldValue(this.oportunidad, OPPTY_NOW_PLAZO) ?? 0;
		if (!plazo) {
			return null;
		} else {
			const importeHipoteca = getFieldValue(this.oportunidad, OPPTY_AMOUNT) ?? 0;
			if (this.tasaBonificada === 0) {
				return importeHipoteca / (plazo * 12) / 12;
			} else {
				const factorPresenteValorFuturo = Math.pow(1 + this.tasaBonificada, plazo);
				return -this.tasaBonificada * (-importeHipoteca * factorPresenteValorFuturo) / (factorPresenteValorFuturo - 1);
			}
		}
	}

	get totalIngresosNominaTitulares() {
		let retorno = 0;
		retorno += getFieldValue(this.oportunidad, OPPTY_TITULAR1_ID) ? this.primerTitular?.nominasNetas.neto : 0;
		retorno += getFieldValue(this.oportunidad, OPPTY_TITULAR2_ID) ? this.segundoTitular?.nominasNetas.neto : 0;
		return retorno;
	}

	get calculos() {
		let ltv = null;
		let dtiNominaSinBonificacion = null;
		let dtiNominaBonificacion = null;
		let dtiIrpfSinBonificacion = null;
		let dtiIrpfBonificacion = null;
		const importeCompraventa = getFieldValue(this.oportunidad, OPPTY_PRECIO_INMUEBLE);
		const importeHipoteca = getFieldValue(this.oportunidad, OPPTY_AMOUNT);

		//LTV
		if (importeCompraventa && importeHipoteca) {
			ltv = importeCompraventa && importeHipoteca ? importeHipoteca / importeCompraventa : null;
		}

		if (this.deuda.totalDeuda && getFieldValue(this.oportunidad, OPPTY_NOW_PLAZO)) {
			//DTI Nómina
			let totalIngresosNominaProrrateadoTitulares = this.primerTitular?.totalIngresosNominaProrrateado;
			totalIngresosNominaProrrateadoTitulares += this.segundoTitular?.totalIngresosNominaProrrateado ?? 0;
			if (totalIngresosNominaProrrateadoTitulares) {
				dtiNominaSinBonificacion = this.deuda.totalDeuda / totalIngresosNominaProrrateadoTitulares;
				dtiNominaBonificacion = this.deuda.totalDeudaBonificacion / totalIngresosNominaProrrateadoTitulares;
			}

			//DTI IRPF
			let totalIngresosIrpfProrrateadoTitulares = this.primerTitular?.totalIngresosIrpfProrrateado ?? 0;
			totalIngresosIrpfProrrateadoTitulares += this.segundoTitular?.totalIngresosIrpfProrrateado ?? 0;
			if (totalIngresosIrpfProrrateadoTitulares) {
				dtiIrpfSinBonificacion = this.deuda.totalDeuda / totalIngresosIrpfProrrateadoTitulares;
				dtiIrpfBonificacion = this.deuda.totalDeudaBonificacion / totalIngresosIrpfProrrateadoTitulares;
			}
		}

		return {
			ltv: {
				valor: formatCalculo(ltv, 2, true),
				//viable: Boolean(ltv && ltv >= 0 && ltv <= this.ltvViableHasta.value)
				viable: true
			},
			dtiNomina: {
				valor: formatCalculo(dtiNominaSinBonificacion, 2, true),
				//viable: Boolean(dtiNominaSinBonificacion && dtiNominaSinBonificacion >= 0 && dtiNominaSinBonificacion <= 0.35)
				viable: true
			},
			dtiNominaBonificado: {
				valor: formatCalculo(dtiNominaBonificacion, 2, true),
				//viable: Boolean(dtiNominaBonificacion && dtiNominaBonificacion >= 0 && dtiNominaBonificacion <= 0.35)
				viable: true
			},
			dtiIrpf: {
				valor: formatCalculo(dtiIrpfSinBonificacion, 2, true),
				//viable: Boolean(dtiIrpfSinBonificacion && dtiIrpfSinBonificacion >= 0 && dtiIrpfSinBonificacion <= 0.35)
				viable: true
			},
			dtiIrpfBonificado: {
				valor: formatCalculo(dtiIrpfBonificacion, 2, true),
				//viable: Boolean(dtiIrpfBonificacion && dtiIrpfBonificacion >= 0 && dtiIrpfBonificacion <= 0.35)
				viable: true
			}
		};
	}

	get ltvViableHasta() {
		if (this.tipoOperacion === 'Compra de vivienda') {
			if (this.usoVivienda === 'Primera residencia') {
				return {value: 0.8, mensajeNoViable: 'No viable. Debe de estar dentro del rango 0%-80%.'};
			} else if (this.usoVivienda === 'Segunda residencia') {
				return {value: 0.7, mensajeNoViable: 'No viable. Debe de estar dentro del rango 0%-70%.'};
			}
		} else if (this.tipoOperacion === 'Subrogación') {
			if (this.usoVivienda === 'Primera residencia') {
				return {value: 0.75, mensajeNoViable: 'No viable. Debe de estar dentro del rango 0%-75%.'};
			} else if (this.usoVivienda === 'Segunda residencia') {
				return {value: 0.6, mensajeNoViable: 'No viable. Debe de estar dentro del rango 0%-60%.'};
			}
		}
		return {value: 0, mensajeNoViable: 'Rango de viabilidad no disponible.'};
	}

	get hipotecaViable() {
		const calculos = {...this.calculos};
		if (calculos.ltv && calculos.ltv && calculos.ltv) {
			return calculos.ltv.viable && calculos.dtiNomina.viable && calculos.dtiIrpf.viable;
		} else {
			return '?';
		}
	}

	constructor(oportunidad) {
		this.oportunidad = oportunidad;
		this.porcentajeBonificacion = getFieldValue(this.oportunidad, OPPTY_PORCENTAJE_BONIFICACION) ?? 0;

		if (getFieldValue(oportunidad, OPPTY_TITULAR1_ID)) {
			this.primerTitular = new Titular('primerTitular');
		}
		const segundoTitularId = getFieldValue(oportunidad, OPPTY_TITULAR2_ID);
		if (segundoTitularId) {
			this.segundoTitular = new Titular('segundoTitular');
		}
		this.deuda = new Deuda(this, Boolean(segundoTitularId));
	}

	generarDatatableData(oportunidad, nombreDatatable) {
		let datatableData = {};

		if (!nombreDatatable || nombreDatatable === 'general') {
			datatableData.general1 = [
				{id: 'prioridad', label: 'Prioridad / Canal de entrada', value: (getFieldValue(oportunidad, OPPTY_PRIORIDAD) ?? '?') + ' / ' + (getFieldValue(oportunidad, OPPTY_CANAL_ENTRADA) ?? '?'), conceptoClass: 'gris negrita', valorClass: 'noEditable noEdit'},
			];
			datatableData.general2 = [
				{id: 'cirbeSolicitado', label: 'CIRBE solicitado', value: getFieldValue(oportunidad, OPPTY_CIRBE_SOLICITADO), conceptoClass: 'gris negrita', valorClass: 'amarillo'}
			];
		}

		if (!nombreDatatable || nombreDatatable === 'importe') {
			datatableData.importe = [
				{id: 'importeCompraventa', label: 'Importe de compraventa', value: getFieldValue(oportunidad, OPPTY_PRECIO_INMUEBLE) ?? 0, conceptoClass: 'gris negrita', valorClass: 'amarillo'},
				{id: 'importeHipoteca', label: 'Importe de la hipoteca', value: getFieldValue(oportunidad, OPPTY_AMOUNT) ?? 0, conceptoClass: 'gris negrita', valorClass: 'amarillo'}
			];
		}

		if (!nombreDatatable || nombreDatatable === 'cuotaMensual') {
			const tasaDisponible = this.tasa || this.tasa === 0;
			datatableData.cuotaMensual1 = [
				{id: 'importeHipoteca', label: 'Importe hipoteca', value: getFieldValue(oportunidad, OPPTY_AMOUNT) ?? null, conceptoClass: 'gris negrita', valorClass: 'azul noEdit'}
			];
			datatableData.cuotaMensual2 = [
				{id: 'interes', label: 'Interés', value: getFieldValue(oportunidad, OPPTY_TIN_INICIAL) ?? 0, conceptoClass: 'gris negrita', valorClass: 'amarillo'},
				{id: 'porcentajeBonificacion', label: '% de bonificación', value: this.porcentajeBonificacion ?? 0, conceptoClass: 'gris negrita', valorClass: 'amarillo'},
				{id: 'interesBonificado', label: 'Interés bonificado', value: this.interesBonificado ?? 0, conceptoClass: 'gris negrita', valorClass: 'azul noEdit'}
			];
			datatableData.cuotaMensual3 = [
				{id: 'plazo', label: 'Plazo en meses', value: getFieldValue(oportunidad, OPPTY_NOW_PLAZO) ?? 0, conceptoClass: 'gris negrita', valorClass: 'amarillo'}
			];
			datatableData.cuotaMensual4 = [
				{id: 'monedaIngresos', label: 'Moneda de ingresos', value: 'EUR (€)', conceptoClass: 'gris negrita', valorClass: 'noEdit noEditable'}
			];
			datatableData.cuotaMensual5 = [
				{id: 'tasa', label: 'Tasa / Tasa bonificada', value: tasaDisponible ? formatCalculo(this.tasa) + ' % / ' + formatCalculo(this.tasaBonificada) + ' %' : null, conceptoClass: 'gris negrita', valorClass: 'azul noEdit'}
			];
			datatableData.cuotaMensual6 = [
				{id: 'cuota', label: 'Cuota', value: this.cuota, conceptoClass: 'verdeDisabled negrita', valorClass: 'verde noEdit negrita'},
				{id: 'cuotaBonificada', label: 'Cuota bonificada', value: this.cuotaBonificada, conceptoClass: 'verdeDisabled negrita', valorClass: 'verde noEdit negrita'}
			];
		}

		if (!nombreDatatable || nombreDatatable === 'fondosPropios') {
			const importeCompraventa = getFieldValue(oportunidad, OPPTY_PRECIO_INMUEBLE) ? parseFloat(getFieldValue(oportunidad, OPPTY_PRECIO_INMUEBLE)) : null;
			const importeHipoteca = getFieldValue(oportunidad, OPPTY_AMOUNT) ? parseFloat(getFieldValue(oportunidad, OPPTY_AMOUNT)) : null;
			const pagosACuenta = getFieldValue(oportunidad, OPPTY_APORTACION_INICIAL) ? parseFloat(getFieldValue(oportunidad, OPPTY_APORTACION_INICIAL)) : 0;
			const donacion = getFieldValue(oportunidad, OPPTY_DONACION) ? parseFloat(getFieldValue(oportunidad, OPPTY_DONACION)) : 0;
			const totalOperacion = importeCompraventa ? importeCompraventa + importeCompraventa * this._porcentajeGastosConstitucion : null;
			const fondosPropios = importeCompraventa - importeHipoteca + importeCompraventa * this._porcentajeGastosConstitucion;
			const pdtsFondosPropios = fondosPropios - pagosACuenta - this.ahorro - donacion;
			datatableData.fondosPropios1 = [
				{id: 'porcentajeGastosConstitucion', label: '% de gastos de constitución', value: this.porcentajeGastosConstitucion, conceptoClass: 'gris negrita', valorClass: 'amarillo'}
			];
			datatableData.fondosPropios2 = [
				//{id: 'gastosConstitucion', label: 'Gastos de constitución', value: importeCompraventa * this._porcentajeGastosConstitucion, conceptoClass: 'gris negrita', valorClass: 'azul noEdit'},
				{id: 'totalOperacion', label: 'Total de la operación', value: totalOperacion, conceptoClass: 'gris negrita', valorClass: 'azul noEdit'},
				{id: 'importeHipoteca', label: 'Importe hipoteca', value: importeHipoteca, conceptoClass: 'gris negrita', valorClass: 'azul noEdit'},
				{id: 'fondosPropios', label: 'Fondos propios', value: fondosPropios, conceptoClass: 'verdeDisabled negrita', valorClass: 'verdeDisabled noEdit'},
				{id: 'pagosACuenta', label: 'Pagos a cuenta/Arras', value: pagosACuenta, conceptoClass: 'gris negrita', valorClass: 'amarillo'},
				{id: 'ahorro', label: 'Ahorro', value: this.ahorro, conceptoClass: 'gris negrita', valorClass: 'amarillo'},
				{id: 'donacion', label: 'Donación/Préstamo', value: donacion, conceptoClass: 'gris negrita', valorClass: 'amarillo'},
				{id: 'pdtsFondosPropios', label: 'Pdts. fondos propios', value: pdtsFondosPropios, conceptoClass: 'verdeDisabled negrita', valorClass: 'verde noEdit negrita'}
			];
		}

		if (!nombreDatatable || nombreDatatable === 'primerTitular') {
			datatableData.primerTitular = this.primerTitular ? this.primerTitular.generarDatatableData() : [];
		}

		if (!nombreDatatable || nombreDatatable === 'segundoTitular') {
			datatableData.segundoTitular = this.segundoTitular ? this.segundoTitular.generarDatatableData() : [];
		}

		if (!nombreDatatable || nombreDatatable === 'deuda') {
			//datatableData.deuda = this.deuda.generarDatatableData(this.cuota);
			datatableData.deuda = this.deuda.generarDatatableData();
		}

		if (!nombreDatatable || nombreDatatable === 'calculos') {
			datatableData.calculos = this.calculos;
		}

		return datatableData;
	}

	static cargarDatosGuardados(datos, oportunidad) {
		let newData = new Data(oportunidad);

		newData.porcentajeGastosConstitucion = datos?.porcentajeGastosConstitucion ?? 0;
		newData.ahorro = datos?.ahorro ?? 0;

		const primerTitularId = getFieldValue(oportunidad, OPPTY_TITULAR1_ID);
		if (primerTitularId) {
			newData.primerTitular = new Titular(
				'primerTitular',
				new TitularItem('Nóminas netas', datos.primerTitular?.nominasNetas?.ingresos, datos.primerTitular?.nominasNetas?.numPagosImpuestos),
				new TitularItem('Ingresos netos IRPF', datos.primerTitular?.ingresosNetosIrpf?.ingresos, datos.primerTitular?.ingresosNetosIrpf?.numPagosImpuestos),
				new TitularItem('Otros ingresos', datos.primerTitular?.otrosIngresos?.ingresos, datos.primerTitular?.otrosIngresos?.numPagosImpuestos),
				new TitularItem('Ingresos por alquiler', datos.primerTitular?.ingresosAlquiler?.ingresos, datos.primerTitular?.ingresosAlquiler?.numPagosImpuestos)
			);
		} else {
			delete newData.primerTitular;
		}

		const segundoTitularId = getFieldValue(oportunidad, OPPTY_TITULAR2_ID);
		if (segundoTitularId) {
			newData.segundoTitular = new Titular(
				'segundoTitular',
				new TitularItem('Nóminas netas', datos.segundoTitular?.nominasNetas?.ingresos, datos.segundoTitular?.nominasNetas?.numPagosImpuestos),
				new TitularItem('Ingresos netos IRPF', datos.segundoTitular?.ingresosNetosIrpf?.ingresos, datos.segundoTitular?.ingresosNetosIrpf?.numPagosImpuestos),
				new TitularItem('Otros ingresos', datos.segundoTitular?.otrosIngresos?.ingresos, datos.segundoTitular?.otrosIngresos?.numPagosImpuestos),
				new TitularItem('Ingresos por alquiler', datos.segundoTitular?.ingresosAlquiler?.ingresos, datos.segundoTitular?.ingresosAlquiler?.numPagosImpuestos)
			);
		} else {
			delete newData.segundoTitular;
		}

		newData.deuda = new Deuda(
			newData,
			//newData.cuota,
			Boolean(segundoTitularId),
			new DeudaItem(datos.deuda.hipoteca.primerTitular, datos.deuda.hipoteca.segundoTitular),
			new DeudaItem(datos.deuda.prestamo.primerTitular, datos.deuda.prestamo.segundoTitular),
			new DeudaItem(datos.deuda.tarjetas.primerTitular, datos.deuda.tarjetas.segundoTitular),
			new DeudaItem(datos.deuda.alquiler.primerTitular, datos.deuda.alquiler.segundoTitular)
		);
		return newData;
	}

	serializarDatosGuardados() {
		const eliminarPropiedad = (key, value) => {
			//eslint-disable-next-line no-undefined
			const retorno = key === 'parent' ? undefined : value;
			return retorno;
		};

		return JSON.stringify({
			metadata: {
				version: VERSION_DATOS_GUARDADOS,
				fechaGuardado: new Date(),
				usuario: currentUserId
			},
			porcentajeGastosConstitucion: this._porcentajeGastosConstitucion * 100,
			ahorro: this.ahorro,
			primerTitular: {
				nominasNetas: this.primerTitular?.nominasNetas,
				ingresosNetosIrpf: this.primerTitular?.ingresosNetosIrpf,
				otrosIngresos: this.primerTitular?.otrosIngresos,
				ingresosAlquiler: this.primerTitular?.ingresosAlquiler
			},
			segundoTitular: {
				nominasNetas: this.segundoTitular?.nominasNetas,
				ingresosNetosIrpf: this.segundoTitular?.ingresosNetosIrpf,
				otrosIngresos: this.segundoTitular?.otrosIngresos,
				ingresosAlquiler: this.segundoTitular?.ingresosAlquiler
			},
			deuda: JSON.parse(JSON.stringify(this.deuda, eliminarPropiedad, null, 3))
		});
	}

	actualizarDatosOportunidad(oportunidad) {
		this.oportunidad = oportunidad;

		const primerTitularId = getFieldValue(oportunidad, OPPTY_TITULAR1_ID);
		if (!this.primerTitular && primerTitularId) {
			this.primerTitular = new Titular('primerTitular');
		} else if (this.primerTitular && !primerTitularId) {
			delete this.primerTitular;
		}

		const segundoTitularId = getFieldValue(oportunidad, OPPTY_TITULAR2_ID);
		if (!this.segundoTitular && segundoTitularId) {
			this.segundoTitular = new Titular('segundoTitular');
		} else if (this.segundoTitular && !segundoTitularId) {
			delete this.segundoTitular;
		}

		this.deuda.dosTitulares = Boolean(segundoTitularId);
	}
}

export const DATATABLE_COLUMNS = {
	general1: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', type: 'text', editable: true, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}, alignment: 'right'}
		}
	],
	general2: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', type: 'boolean', editable: true, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}, alignment: 'right'}
		}
	],
	importe: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', type: 'currency', editable: true, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}}
		}
	],
	cuotaMensual1: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', type: 'currency', editable: true, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}}
		}
	],
	cuotaMensual2: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', type: 'number', editable: true, hideDefaultActions: true,
			typeAttributes: {minimumFractionDigits: 3, maximumFractionDigits: 6},
			cellAttributes: {class: {fieldName: 'valorClass'}}
		}
	],
	cuotaMensual3: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', type: 'number', editable: true, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}}
		}
	],
	cuotaMensual4: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', type: 'text', editable: true, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}, alignment: 'right'}
		}
	],
	cuotaMensual5: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', editable: true, hideDefaultActions: true,
			//typeAttributes: {minimumFractionDigits: 3, maximumFractionDigits: 6},
			cellAttributes: {class: {fieldName: 'valorClass'}, alignment: 'right'}
		}
	],
	cuotaMensual6: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', type: 'currency', editable: true, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}}
		}
	],
	fondosPropios1: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', type: 'number', editable: true, hideDefaultActions: true,
			typeAttributes: {minimumFractionDigits: 3, maximumFractionDigits: 6},
			cellAttributes: {class: {fieldName: 'valorClass'}}
		}
	],
	fondosPropios2: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 194, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Valor', fieldName: 'value', type: 'currency', editable: true, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}}
		}
	],
	titular: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 115, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Ingresos', fieldName: 'ingresos', type: 'currency', editable: true, fixedWidth: 130, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}}
		},
		{label: 'Pagas/IRPF', fieldName: 'numPagosImpuestos', type: 'number', editable: true, fixedWidth: 90, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'numPagosImpuestosClass'}, alignment: 'right'}
		},
		{label: 'Neto', iconName: 'utility:advanced_function', fieldName: 'neto', type: 'currency', hideDefaultActions: true, wrapText: false,
			cellAttributes: {class: {fieldName: 'netoClass'}}
		}
	],
	deuda: [
		{label: 'Concepto', fieldName: 'label', fixedWidth: 220, hideDefaultActions: true, wrapText: true,
			cellAttributes: {class: {fieldName: 'conceptoClass'}}
		},
		{label: 'Primer titular', fieldName: 'primerTitular', type: 'currency', editable: true, fixedWidth: 220, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}}
		},
		{label: 'Segundo titular', fieldName: 'segundoTitular', type: 'currency', editable: true, fixedWidth: 220, hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'valorClass'}}
		},
		{label: 'Total', iconName: 'utility:advanced_function', fieldName: 'total', type: 'currency', hideDefaultActions: true,
			cellAttributes: {class: {fieldName: 'totalClass'}}
		}
	]
};