import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import NAME_FIELDUSER from '@salesforce/schema/User.Name';
import NAME_FIELDPROD from '@salesforce/schema/Product2.Name';
import PRODID_FIELD from '@salesforce/schema/AV_ProductExperience__c.AV_ProductoFicha__c';
import lookupSearchProduct from '@salesforce/apex/AV_NewOpportunity_Controller.searchProduct';
import lookupSearchByProduct from '@salesforce/apex/AV_NewOpportunity_Controller.searchByProduct';
import getStatusValues from '@salesforce/apex/AV_NewOpportunity_Controller.getStatusValues';
import getStatusValuesNewOpp from '@salesforce/apex/AV_NewOpportunity_Controller.getStatusValuesNewOpp';
import getEntityFields from '@salesforce/apex/AV_NewOpportunity_Controller.getEntityFields';
import unlinkOpp from '@salesforce/apex/AV_DetailOppTask_Controller.unlinkOpp';
import updateMain from '@salesforce/apex/AV_DetailOppTask_Controller.updateMainRecord';
import searchEmployees from '@salesforce/apex/AV_NewOpportunity_Controller.getEmployees';
import getContacto from '@salesforce/apex/AV_NewOpportunity_Controller.getContact';
import USER_ID from '@salesforce/user/Id';

//Labels
import successLabel from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successMsgLabel from '@salesforce/label/c.AV_CMP_SaveMsgSuccess';
import errorMsgLabel from '@salesforce/label/c.AV_CMP_SaveMsgError';
import errorLabel from '@salesforce/label/c.AV_CMP_ErrorEvent';
import successUnlinkMsgLabel from '@salesforce/label/c.AV_CMP_SuccessUnlinkOpp';

import AV_CMP_ErrorMessage from '@salesforce/label/c.AV_CMP_ErrorMessage';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class Av_NewOpportunityEditable extends LightningElement {

	@api layoutHorizontal = 'space'; //layout item horizontal...
	@api isone = false;
	@api defaultStage;
	@api opptask;
	@api isreport = false;
	@api pfexp;
	@api taskid;
	@api oldFechaGestion;
	@api oldComentario;
	@api oldEntidad;
	@api successfulsaving = false;
	@track reqFechaGestion = false;
	@track asterisk = true;
	@track showDetail = false;
	@track showDetailMain;
	@track path = "En gestión/insistir";
	@track fechagestion;
	@track comentario;
	@track entidad;
	@track fechavencimiento;
	@track importe = null;
	@track interes = null;
	@track cuota = null;
	@track matricula;
	@track otraentidad;
	@track otraentidadpick;
	@track hasOtherEntity;
	@track incluir = false;
	@track oportunidad;
	@track valuesOpp;
	@track producto = '';
	@track allStages = [];
	@track listEntFields;
	@track loading = false;
	@track origenapp;
	@track fechaActivacion;
	@track potencial;
	@track owner = USER_ID;
	@track ownerContact;
	@track resolucion;
	@track expeVenta = false;
	@track margin = null;
	@track amount = null;
	@track byProduct = null;
	@track validationError = null;
	@track find = '';
	@track initialPotencial = "S";
	@track errors = [];
	@track isMultiEntry = false;
	@track show = false;
	@track nombreProducto;
	@track initialSelection = [];
	@track initialSelectionEmployee = [];
	@track initialSelectionByProduct = [];
	@track isclosed = false; //Para mostrar el campo resolución o no
	@track otros;//Para hacer obligatorio el comentario si la resolucion es "otros"
	@track showDateAndCli = true;
	@track requiredComment = false;
	@track nombreSubProducto;
	@track hasProduct = false;
	@track checkNotAllowed = false;

	toggle(event) {
		this.show = event.target.checked;
	}

	handleIncluir(event) {
		this.incluir = event.target.checked;
		this.sendData();
	}

	get optionsPotencial() {
		return [
			{ label: 'Venta programada', value: 'VP' },
			{ label: 'Muy alta', value: 'A' },
			{ label: 'Alta', value: 'S' },
			{ label: 'Media', value: 'M' },
			{ label: 'Baja', value: 'B' }
		];
	}

	get optionsResolucion() {
		return [
			{ label: 'Elige otra entidad por precio', value: 'Elige otra entidad por precio' },
			{ label: 'Elige otra entidad características por producto', value: 'Elige otra entidad características por producto' },
			{ label: 'No le interesa por precio', value: 'No le interesa por precio' },
			{ label: 'No le interesa por las características del producto', value: 'No le interesa por las características del producto' },
			{ label: 'Perfil cliente inadecuado', value: 'PCI' },
			{ label: 'Otros', value: 'O' }

		]
	}

	showExpectativaVenta() {
		this.expeVenta = (this.path === "En gestión/insistir");
	}

	handleChangeResolucion(event) {
		this.resolucion = event.detail.value;
		this.evaluateResolution();
		this.sendData();
	}

	evaluateResolution() {
		this.otros = this.resolucion == 'O' && (this.comentario === null || this.comentario?.trim().length === 0) && this.path == 'No interesado';
		this.requiredComment = this.resolucion == 'O';
	}

	@wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELDUSER] })
	wiredUser({ error, data }) {
		if (data) {
			this.initialSelectionEmployee = { id: USER_ID, icon: "standard:user", title: data.fields.Name.value }
		} else if (error) {
			console.log(error);
		}
	}

	sendData() {
		if (this.isreport) {
			var sendData = new CustomEvent('datareport', {
				detail: {
					oppRecordType: this.opptask.AV_Opportunity__r?.RecordTypeId,
					id: this.opptask.Id,
					taskid: this.taskid,
					path: this.path,
					fechagestion: this.fechagestion,
					comentario: this.comentario,
					entidad: this.entidad,
					fechavencimiento: this.fechavencimiento,
					importe: this.importe,
					interes: this.interes,
					incluir: this.incluir,
					producto: this.producto,
					oportunidad: this.opptask.Name,
					cuota: this.cuota,
					matricula: this.matricula,
					otraentidadpick: this.otraentidadpick,
					origenapp: this.origenapp,
					fechaActivacion: this.fechaActivacion,
					potencial: this.potencial,
					resolucion: this.resolucion,
					margin: this.margin,
					amount: this.amount,
					byProduct: this.byProduct
				}
			});
			this.dispatchEvent(sendData);

		} else {
			var validateDecimal = /^[0-9]*(\,?)[0-9]+$/;
			if (this.importe != null && this.importe != '') {
				if (!this.importe.match(validateDecimal)) {
					this.showToast('Error', 'El campo de Importe es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
					this.validationError = 'El campo es de tipo decimal. El formato correcto es: 123,12';
				}
			}
			if (this.cuota != null && this.cuota != '') {
				if (!this.cuota.match(validateDecimal)) {
					this.showToast('Error', 'El campo de Importe Cuota es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
					this.validationError = 'El campo es de tipo decimal. El formato correcto es: 123,12';
				}
			}
			if (this.interes != null && this.interes != '') {
				if (!this.interes.match(validateDecimal)) {
					this.showToast('Error', 'El campo de Interes Cuota es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
					this.validationError = 'El campo es de tipo decimal. El formato correcto es: 123,12';
				}
			}
			if (this.margin != null && this.margin != '') {
				if (!this.margin.match(validateDecimal)) {
					this.showToast('Error', 'El campo de Margen Previsto es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
					this.validationError = 'El campo es de tipo decimal. El formato correcto es: 123,12';
				}
			}
			if (this.amount != null && this.amount != '') {
				if (!this.amount.match(validateDecimal)) {
					this.showToast('Error', 'El campo de Importe es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
					this.validationError = 'El campo es de tipo decimal. El formato correcto es: 123,12';
				}
			}
			const sendDataOpp = new CustomEvent('data', {
				detail: {
					id: '',
					taskid: this.taskid,
					path: this.path,
					fechagestion: this.fechagestion,
					comentario: this.comentario,
					entidad: this.entidad,
					fechavencimiento: this.fechavencimiento,
					importe: this.importe,
					interes: this.interes,
					incluir: this.incluir,
					producto: this.producto,
					oportunidad: this.oportunidad,
					cuota: this.cuota,
					matricula: this.matricula,
					otraentidadpick: this.otraentidadpick,
					fechaActivacion: this.fechaActivacion,
					potencial: this.potencial,
					owner: this.owner,
					contact: this.ownerContact,
					resolucion: this.resolucion,
					margin: this.margin,
					amount: this.amount,
					byProduct: this.byProduct,
					validationError: this.validationError
				}
			});
			this.dispatchEvent(sendDataOpp);
		}
	}

	handlePath(event) {
		var oldPath = this.path
		this.path = event.detail.newValue;
		this.evaluateResolution();
		var today = new Date();
		var year = today.getFullYear() + 2;
		if (this.path == 'No interesado') {
			this.isclosed = true;
		} else {
			this.isclosed = false;
			this.resolucion = '';
		}
		this.showDateAndCli = !(this.path === 'Cerrado positivo' || this.isclosed === true);
		this.checkNotAllowed = (this.path === 'Cerrado positivo' || this.isclosed === true || this.path == 'No apto');
		if (oldPath == 'Potencial') {
			this.fechaActivacion = today.toISOString().substring(0, 10);
		}
		if (this.path == 'Potencial') {
			this.fechaActivacion = null;
		}
		if (this.path == "No apto") {
			today.setFullYear(year);
			this.fechagestion = today.toISOString().substring(0, 10);
		} else {
			var today = new Date();
			var year = today.getFullYear() + 1;
			today.setFullYear(year);
		}
		this.isFechaRequired();
		this.showExpectativaVenta();
		if (!this.expeVenta) {
			this.potencial = "S";
		}
		this.sendData();
	}

	isFechaRequired() {
		if (this.path == "Potencial" || this.path == "No apto" || this.path == "En gestión/insistir") {
			this.asterisk = true;
			if (typeof this.fechagestion == 'undefined' || this.fechagestion == null) {
				this.reqFechaGestion = true;
			} else {
				this.reqFechaGestion = false;
			}
		} else {
			this.asterisk = false;
			this.reqFechaGestion = false;
		}
	}

	handleFechaGestion(event) {
		this.reqFechaGestion = false;
		this.fechagestion = event.target.value;
		this.isFechaRequired();
		this.sendData();
	}

	handleComentario(event) {
		this.comentario = event.target.value;
		this.evaluateResolution();
		this.sendData();
	}

	handleEntidad(event) {
		this.entidad = event.target.value;
		this.sendData();
	}

	handleFechaVencimiento(event) {
		this.fechavencimiento = event.target.value;
		this.sendData();
	}

	handleImporte(event) {
		this.importe = event.target.value;
		this.sendData();
	}

	handleInteres(event) {
		this.interes = event.target.value;
		this.sendData();
	}

	handleProducto(event) {
		this.producto = event.target.value;
		this.sendData();
		if (this.producto == undefined) {
			this.oportunidad = '';
			this.listEntFields = [];
		}
	}

	handleOportunidad(event) {
		this.oportunidad = event.target.value;
		this.sendData();
	}

	handleOtraEntidad(event) {
		if (event.target.checked == true) {
			this.otraentidadpick = 'S';
		} else {
			this.otraentidadpick = 'N';
		}
		this.otraentidad = event.target.checked;
		this.sendData();
		this.toggle(event);
	}

	handleAmount(event) {
		if (event.target.value == '') {
			this.amount = null;
		} else {
			this.amount = event.target.value;
		}
		this.validationError = null;
		this.sendData();
	}

	handleMargin(event) {
		if (event.target.value == '') {
			this.margin = null;
		} else {
			this.margin = event.target.value;
		}
		this.validationError = null;
		this.sendData();
	}





	handleEntityFields(event) {
		switch (event.target.label) {
			case 'Fecha vencimiento':
				this.fechavencimiento = event.target.value;
				this.sendData();
				break;
			case 'Importe':
				if (event.target.value == '') {
					this.importe = null;
				} else {
					this.importe = event.target.value;
				}
				this.validationError = null;
				this.sendData();
				break;
			case 'Importe Cuota':
				this.cuota = event.target.value;
				if (event.target.value == '') {
					this.cuota = null;
				} else {
					this.cuota = event.target.value;
				}
				this.validationError = null;
				this.sendData();
				break;
			case 'Tipo de Interés':
				if (event.target.value == '') {
					this.interes = null;
				} else {
					this.interes = event.target.value;
				}
				this.sendData();
				break;
			case 'Matrícula':
				this.matricula = event.target.value;
				this.sendData();
				break;
		}
	}

	@wire(getRecord, { recordId: '$producto', fields: [NAME_FIELDPROD] })
	wiredProdName({ error, data }) {
		if (data) {
			this.oportunidad = data.fields.Name.value;
			this.nombreProducto = data.fields.Name.value;
			this.getFields(this.producto);
			this.sendData();
			this.initialSelection = [{ id: this.producto, icon: 'standard:product', title: this.nombreProducto }];
		} else if (error) {
			console.log(error);
		}
	}

	@wire(getRecord, { recordId: '$byProduct', fields: [NAME_FIELDPROD] })
	wiredByProdName({ error, data }) {
		if (data) {
			if (this.isreport) {
				this.nombreSubProducto = data.fields.Name.value;
				this.sendData();
				this.initialSelectionByProduct = [{ id: this.byProduct, icon: 'standard:product', title: this.nombreSubProducto }];
			}
		} else if (error) {
			console.log(error);
		}
	}

	@wire(getRecord, { recordId: '$pfexp', fields: [PRODID_FIELD] })
	wiredProdId({ error, data }) {
		if (data) {
			this.producto = data.fields.AV_ProductoFicha__c.value;
		} else if (error) {
			console.log(error);
		}
	}

	connectedCallback() { //al accionar cmp, se hace automáticamente.
		this.path = this.defaultStage;
		var today = new Date();
		var year = today.getFullYear();
		today.setFullYear(year);
		this.potencial = this.initialPotencial;
		if (this.isreport && this.opptask != undefined) {
			this.getStatus();
			this.path = this.opptask.AV_Stage__c;
			this.asterisk = this.path == "No apto" || this.path == "En gestión/insistir";
			this.fechagestion = this.opptask.AV_ReviewDate__c;
			this.comentario = this.opptask.AV_Commentary__c;
			this.entidad = this.opptask.AV_Entity__c;
			this.fechavencimiento = this.opptask.AV_DueDate__c;
			this.origenapp = 'AV_SalesforceReport';
			this.importe = this.opptask.AV_Amount__c;
			this.fechaActivacion = this.opptask.AV_Opportunity__r.AV_FechaActivacion__c;
			this.potencial = this.opptask.AV_Priority__c;
			this.resolucion = this.opptask.AV_Resolucion__c;
			this.amount = this.opptask.AV_AmountEuro__c;
			this.margin = this.opptask.AV_MarginEuro__c;

			if (this.margin != null) {
				let marginEuro = this.margin.toString().replace('.', ',');
				this.margin = marginEuro;
			}
			if (this.amount != null) {
				let amountEuro = this.amount.toString().replace('.', ',');
				this.amount = amountEuro;
			}
			if (this.importe != null) {
				let impor = this.importe.toString().replace('.', ',');
				this.importe = impor;
			}
			this.cuota = this.opptask.AV_FeeAmount__c;
			if (this.cuota != null) {
				let cuo = this.cuota.toString().replace('.', ',');
				this.cuota = cuo;
			}
			this.matricula = this.opptask.AV_LicensePlate__c;
			this.interes = this.opptask.AV_TypeOfInterest__c;
			if (this.interes != null) {
				let inter = this.interes.toString().replace('.', ',');
				this.interes = inter;
			}
			this.incluir = this.opptask.AV_IncludeInPrioritizingCustomers__c;

			this.producto = this.opptask.AV_Product__c;
			if (this.producto != null) {
				this.byProduct = this.opptask.AV_ByProduct__c;
				this.hasProduct = true;
			}
			this.otraentidad = this.opptask.AV_HoldingAnotherEntity__c;
			if (this.otraentidad == 'S') {
				this.otraentidadpick = 'S';
				this.hasOtherEntity = true;
				this.show = true;
			} else {
				this.hasOtherEntity = false;
			}
			if (this.opptask && this.opptask.AV_IsMain__c) {
				this.showDetailMain = true;
			}
			this.evaluateResolution();
			this.isclosed = (this.path == 'No interesado');
			this.showDateAndCli = !(this.path == 'Cerrado positivo' || this.isclosed);
			this.checkNotAllowed = (this.path === 'Cerrado positivo' || this.isclosed === true || this.path == 'No apto');

		} else {
			if (this.path != 'Potencial') {
				this.fechaActivacion = today.toISOString().substring(0, 10);
			}
			this.getStatusNewOpp();
			this.showDetail = true;
		}

		this.showExpectativaVenta();
	}


	renderedCallback() {//Al cargar todos los elementos del cmp
		if (!this.isreport) {
			this.template.querySelector('[data-id="clookup1"]').focus();
		}
	}

	pathValues(listValues) { //pasándole lista estados y se guarda en allStage
		var aux = [];
		for (var value of listValues) {
			aux.push({ value: value.value, label: value.label });
		}

		this.allStages = this.allStages.concat(aux);
	}

	getStatus() {
		getStatusValues({ objectName: 'Opportunity', fieldName: 'StageName' })
			.then(result => {
				this.valuesOpp = result; //El resultado lo instanciamos en valuesOpp. la lista de los estados del path.
				this.pathValues(this.valuesOpp); //llamamos pathvalue 
			})
			.catch(error => {
				console.log(error);
			});
	}

	getStatusNewOpp() {
		getStatusValuesNewOpp({ objectName: 'Opportunity', fieldName: 'StageName' })
			.then(result => {
				this.valuesOpp = result; //El resultado lo instanciamos en valuesOpp. la lista de los estados del path.
				this.pathValues(this.valuesOpp); //llamamos pathvalue 
			})
			.catch(error => {
				console.log(error);
			});
	}

	getFields(prod) {
		getEntityFields({ prodId: prod })
			.then(result => {
				if (result.length > 0) {
					this.listEntFields = result;
					for (let item of this.listEntFields) {
						if (this.listEntFields.length > 3) {
							item.divClass = 'slds-col slds-size_1-of-' + this.listEntFields.length;
						} else {
							item.divClass = 'slds-col slds-size_1-of-3';
						}
						switch (item.label) {
							case 'Fecha vencimiento':
								item.value = this.fechavencimiento;
								this.sendData();
								break;
							case 'Importe':
								item.value = this.importe;
								this.sendData();
								break;
							case 'Importe Cuota':
								item.value = this.cuota;
								this.sendData();
								break;
							case 'Tipo de Interés':
								item.value = this.interes;
								this.sendData();
								break;
							case 'Matrícula':
								item.value = this.matricula;
								this.sendData();
								break;
						}
					}
				} else {
					this.listEntFields = undefined;
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

	toggleShowOppTask() {
		if (this.showDetail === true) {
			this.showDetail = false;
		} else {
			this.showDetail = true;
		}
	}

	toggleShowOppTaskMain() {
		if (this.showDetailMain === true) {
			this.showDetailMain = false;
		} else {
			this.showDetailMain = true;
		}
	}

	handleUnlink() {
		this.dispatchEvent(new CustomEvent("enablespin"))

		this.unlinkOpp();
	}

	unlinkOpp() {
		this.template.querySelector('lightning-layout[data-id="' + this.opptask.Id + '"]').focus();
		unlinkOpp({ oppTask: this.opptask })
			.then(() => {
				this.refreshParentUnlink();
				this.showToast(successLabel, successUnlinkMsgLabel, 'success', 'pester');
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error', 'pester');
			});
	}

	showToast(title, message, variant, mode) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}

	refreshParentUnlink() {
		this.dispatchEvent(new CustomEvent('refreshunlink'));
	}

	handleMain() {
		this.updateMainOppTask(this.opptask);
	}

	updateMainOppTask(oppTaskId) {
		updateMain({ oppTask: oppTaskId })
			.then(() => {
				this.refreshParentMain();
				this.showToast(successLabel, successMsgLabel, 'success', 'pester');
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error', 'pester');
			});
	}

	refreshParentMain() {
		this.dispatchEvent(new CustomEvent('refreshmain'));
	}

	handleSearchProduct(event) {
		lookupSearchProduct(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup1"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup1"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				// eslint-disable-next-line no-console
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSearchByProduct(event) {
		console.log('searchterm1-------->' + event.detail.searchTerm);
		this.find = event.detail.searchTerm;
		lookupSearchByProduct({ searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds, product: this.producto })
			.then((results) => {
				this.template.querySelector('[data-id="clookup2"]').setSearchResults(results);
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}




	handleSearchClick(event) {
		if (this.find == '' && this.byProduct == null) {
			lookupSearchByProduct({ searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds, product: this.producto })
				.then((results) => {
					if (results != null) {
						this.template.querySelector('[data-id="clookup2"]').setSearchResults(results);
					}
				})
				.catch((error) => {
					console.error('Lookup error', JSON.stringify(error));
					this.errors = [error];
				});
		}
	}


	handleSelectionChange(event) {
		this.checkForErrors(event);
	}

	checkForErrors(event) {
		this.errors = [];
		var targetId = event.target.dataset.id;
		if (targetId === 'clookup1') {
			targetId = 'lookup1';
		}
		if (targetId == 'lookup1') {
			// const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			const selection = this.template.querySelector(`[data-id="${targetId}"] > c-av_-lookup`).getSelection();
			if (selection.length !== 0) {
				this.hasProduct = true;
				for (let sel of selection) {
					this.producto = String(sel.id);
				}
			} else {
				this.producto = null;
				this.find = '';
				this.byProduct = null;
				try {
					const lookup5 = this.template.querySelector('[data-id="lookup2"] > c-av_-lookup');
					if (lookup5 != null || typeof lookup5 != 'undefined') {
						lookup5.handleClearSelection();
					}
				} catch (e) {
					console.log('Lookup Error ==> ', e);
				}
				this.hasProduct = false;
			}
		}
	}

	handleSelectionChangeByProduct(event) {
		this.checkForErrorsByProduct(event);
		this.sendData();
	}

	checkForErrorsByProduct(event) {
		this.errors = [];
		var targetId = event.target.dataset.id;
		if (targetId === 'clookup2') {
			targetId = 'lookup2';
		}
		if (targetId == 'lookup2') {
			const selection = this.template.querySelector(`[data-id="${targetId}"] > c-av_-lookup`).getSelection();
			if (selection.length !== 0) {
				for (let sel of selection) {
					this.byProduct = String(sel.id);
				}
			} else {
				this.byProduct = null;
			}
		}
	}

	handleFocus() {
		// Prevent action if selection is not allowed
		if (!this.isSelectionAllowed()) {
			return;
		}
		this._hasFocus = true;
		this._focusedResultIndex = null;
	}

	handleChangePotencial(event) {
		this.potencial = event.target.value;
		this.sendData();
	}

	handleSearchEmployee(event) {
		searchEmployees(event.detail)
			.then(result => {
				this.template.querySelector('[data-id="clookup5"]').setSearchResults(result);
				this.template.querySelector('[data-id="clookup5"]').scrollIntoView();
			}).catch(error => {
				console.log(error);
			})
	}

	handleSelectionEmployee(event) {
		this.owner = event.detail;
		var idUser = String(event.detail[0])
		getContacto({ idUser: idUser })
			.then(result => {
				this.ownerContact = result;
				this.sendData();
			}).catch(error => {
				console.log(error)
			})
	}
}