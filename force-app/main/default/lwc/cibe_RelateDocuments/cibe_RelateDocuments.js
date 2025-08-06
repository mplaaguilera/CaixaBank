import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getDocuments from '@salesforce/apex/CIBE_DocumentsToOpportunityCIBCnt.getDocuments';
import getOpportunities from '@salesforce/apex/CIBE_DocumentsToOpportunityCIBCnt.getOpportunities';
import vincDocusOpp from '@salesforce/apex/CIBE_DocumentsToOpportunityCIBCnt.vincDocusOpp';
import updateState from '@salesforce/apex/CIBE_DocumentsToOpportunityCIBCnt.updateState';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import docSelect from '@salesforce/label/c.CIBE_DocuSelect';
import docPendRela from '@salesforce/label/c.CIBE_DocuPendRelacionar';
import docArch from '@salesforce/label/c.CIBE_DocuArchivos';
import docAsoOpp from '@salesforce/label/c.CIBE_DocuAsoOpp';
import docDescar from '@salesforce/label/c.CIBE_DocuDescartar';
import docuIdentOppVin from '@salesforce/label/c.CIBE_DocuIdentOppVin';
import docuConfirmaAso from '@salesforce/label/c.CIBE_DocuConfirmaAso';
import docuBusClient from '@salesforce/label/c.CIBE_DocuBusClient';
import docuBusOpp from '@salesforce/label/c.CIBE_DocuBusOpp';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import buscar from '@salesforce/label/c.CIBE_buscar';
import docuVolver from '@salesforce/label/c.CIBE_DocuVolver';
import docuConfir from '@salesforce/label/c.CIBE_DocuConfir';
import docuConfiAsoOpp from '@salesforce/label/c.CIBE_DocuConfiAsoOpp';
import nameOpp from '@salesforce/label/c.CIBE_Name';
import name from '@salesforce/label/c.CIBE_NombreSimple';
import fechaCreacion from '@salesforce/label/c.CIBE_DocuFechaCreacion';
import tipo from '@salesforce/label/c.CIBE_Tipo';
import cliente from '@salesforce/label/c.CIBE_Cliente';
import estado from '@salesforce/label/c.CIBE_Estado';
import producto from '@salesforce/label/c.CIBE_Producto';
import pais from '@salesforce/label/c.CIBE_Pais';
import propietario from '@salesforce/label/c.CIBE_Propietario';
import oportunidad from '@salesforce/label/c.CIBE_Oportunidad';
import archivo from '@salesforce/label/c.CIBE_DocuTableArchivo';
import correcto from '@salesforce/label/c.CIBE_Correcto';
import error1 from '@salesforce/label/c.CIBE_DocuErrorUpdate';
import correcto1 from '@salesforce/label/c.CIBE_DocuCorrecUpdate';
import error2 from '@salesforce/label/c.CIBE_DocuErrorVin';
import correcto2 from '@salesforce/label/c.CIBE_DocuCorrecVin';
import atencion from '@salesforce/label/c.CIBE_DocuAtencion';
import atenciontexto from '@salesforce/label/c.CIBE_DocuAtencionTexto';
import ver from '@salesforce/label/c.CIBE_Ver';

const columns = [
	{ label: name, fieldName: 'Title', hideDefaultActions: true },
	{ label: fechaCreacion, fieldName: 'CreatedDate', type: 'date', hideDefaultActions: true },
	{ label: tipo, fieldName: 'FileType', hideDefaultActions: true },
	{ label: '', fieldName: 'URL', type: 'url', typeAttributes: { label: ver }, hideDefaultActions: true }
];
const columnsOpp = [
	{ label: nameOpp, fieldName: 'Name', hideDefaultActions: true },
	{ label: cliente, fieldName: 'AccountName', hideDefaultActions: true },
	{ label: estado, fieldName: 'StageName', hideDefaultActions: true },
	{ label: producto, fieldName: 'AV_ProductName__c', hideDefaultActions: true },
	{ label: pais, fieldName: 'CIBE_Pais__c', hideDefaultActions: true },
	{ label: propietario, fieldName: 'OwnerName', hideDefaultActions: true }
];

const columnsDocumentSelected = [
	{ label: name, fieldName: 'Title', hideDefaultActions: true },
	{ label: tipo, fieldName: 'FileType', hideDefaultActions: true }
];

const columnsConfirmTable = [
	{ label: archivo, fieldName: 'documentName', hideDefaultActions: true },
	{ label: oportunidad, fieldName: 'opportunityName', hideDefaultActions: true },
	{ label: cliente, fieldName: 'accountName', hideDefaultActions: true }
];

export default class Cibe_RelateDocuments extends LightningElement {

	label = {
		docSelect,
		docPendRela,
		docArch,
		docAsoOpp,
		docDescar,
		docuIdentOppVin,
		docuConfirmaAso,
		docuBusClient,
		docuBusOpp,
		cancelar,
		buscar,
		docuVolver,
		docuConfir,
		docuConfiAsoOpp
	};

	current = '1';
	error = false;
	numDocs = 3;

	columns = columns;
	columnsOpp = columnsOpp;
	columnsDocumentSelected = columnsDocumentSelected;
	columnsConfirmTable = columnsConfirmTable;

	data = [];
	dataDocument = [];
	dataOpp = [];
	dataDocumentSelected = [];
	dataConfirmTable = [];
	documentsIdsList = [];

	record = {};
	firstStep = true;
	secondStep = false;
	thirdStep = false;
	opportunityName;
	accountName;
	infoMessage;
	showActionButtons = true;
	renderFirstTable = false;
	showInfoTable = false;
	showBackButton = false;
	disabledAssociateAndDiscardButton = true;
	disableSearchButton = true;
	wireDocuments;

	/**
	 * Recover all documents
	 * @param {*} documents 
	 */
	@wire(getDocuments)
	wiredDocuments(documents) {
		this.wireDocuments = documents;
		this.wireDocumentsSpinner = documents;
		if (documents.data) {
			this.numDocs = documents.data.length;
			this.infoMessage = docPendRela + ` (${this.numDocs} ` + docArch + `)`;
			this.data = documents.data;
			this.data.forEach(element => {
				this.dataDocument.push({ //Id, Title, FileType, CreatedDate
					Id: element.Id,
					Title: element.Title,
					FileType: element.FileType,
					CreatedDate: element.CreatedDate,
					URL: window.location.origin + '/' + element.Id
				});
			});
			this.renderFirstTable = true;
		} else {
			console.log('error recuperando los documentos ', documents.error);
		}
	}

	get isLoading() {
		return !this.wireDocumentsSpinner.data && !this.wireDocumentsSpinner.error;
	}

	set isLoading(value) {
		this.wireDocumentsSpinner.data = value;
		this.wireDocumentsSpinner.error = value;
	}

	/**
	 * Clicking advances to the next step in the progress barClicking advances to the next step in the progress bar
	 */
	nextStep() {
		if (parseInt(this.current) < 3) {
			this.current = (parseInt(this.current) + 1).toString();
		}
		this.checkStepPostion();
	}

	/**
	 * Clicking goes back to the previous step in the progress bar
	 */
	lastStep() {
		this.accountName = '';
		this.opportunityName = '';
		this.disabledAssociateAndDiscardButton = true;
		if (parseInt(this.current, 10) > 1) {
			this.current = (parseInt(this.current, 10) - 1).toString();
		}
		this.checkStepPostion();
	}

	/**
	 * Checks against a list passed as a parameter whether the associate and discard buttons should be enabled or not.
	 * @param {*} list 
	 */
	checkButtonsStatus(list) {
		this.disabledAssociateAndDiscardButton = list.length < 1 ? true : false;
	}

	/**
	 * Check the position you want to reach to display the corresponding tables.
	 */
	checkStepPostion() {
		if (parseInt(this.current) === 1) {
			this.showInfoTable = false;
			this.dataDocumentSelected = [];
			this.infoMessage = docPendRela + ` (${this.numDocs} ` + docArch + `)`;
			this.firstStep = true;
			this.secondStep = false;
			this.thirdStep = false;
		}
		else if (parseInt(this.current, 10) === 2) {
			this.checkButtonsStatus(this.dataOpp);
			this.showInfoTable = true;
			this.infoMessage = docuIdentOppVin;
			this.firstStep = false;
			this.secondStep = true;
			this.thirdStep = false;
		}
		else if (parseInt(this.current, 10) === 3) {
			this.showInfoTable = false;
			this.showActionButtons = false;
			this.infoMessage = docuConfiAsoOpp;
			this.firstStep = false;
			this.secondStep = false;
			this.thirdStep = true;
		}
		this.showBackButton = this.current > 1 ? true : false;
	}

	/**
	 * Updates the status of the selected document to "discarded".
	 */
	discard() {
		this.updateDocumentStatus();
	}

	/**
	 * Checks that the verifications are correct and if not, adds an icon showing an error to the progress bar indicator.
	 */
	addError() {
		this.error = true;
	}


	/**
	 * It is triggered every time you select a row from the first table.
	 * It adds the ids of the selected documents to an array (documentsIdsList) that will later be passed to Apex to associate the opp with the documents.
	 * @param {*} event 
	 */
	getSelectedRow(event) {
		this.documentsIdsList = [];
		this.dataDocumentSelected = event.detail.selectedRows;
		event.detail.selectedRows.forEach(element => {
			this.documentsIdsList.push(element.Id)
		});
		this.checkButtonsStatus(this.dataDocumentSelected);
	}

	/**
	 * It is triggered every time you select or deselect an opportunity from the second table.
	 * It checks that no more than one opportunity is selected and if so, it displays a message to the user.
	 * If the selection is correct, it adds to the list that the last table will display the "summary" of the documents with the selected opportunity to associate.
	 * @param {*} event 
	 */
	getSelectedRowDataOpp(event) {
		if (event.detail.selectedRows.length > 1) {
			this.disabledAssociateAndDiscardButton = true;
			this.showToast(atencion, atenciontexto, 'warning')
		} else if (event.detail.selectedRows.length === 1) {
			this.disabledAssociateAndDiscardButton = false;
			if (this.dataConfirmTable.length === 0) {
				this.dataDocumentSelected.forEach(element => {
					let obj = {};
					obj.opportunityName = event.detail.selectedRows[0].Name;
					obj.documentName = element.Title;
					obj.accountName = event.detail.selectedRows[0].AccountName;
					obj.oppId = event.detail.selectedRows[0].Id;
					this.dataConfirmTable.push(obj)
				});
			}
		} else {
			this.disabledAssociateAndDiscardButton = true;
			this.dataConfirmTable = [];
		}
	}

	/**
	 * It is triggered by clicking the search button and calls the getOpportunitiesByClientNameOrOppName() method to search for opportunities 
	 * filtered by the client name and opportunity name information contained in the inputs.
	 */
	handleClickSearchOpp() {
		this.getOpportunitiesByClientNameOrOppName();
	}

	/**
	 * Fires every time information is entered into the input. Enables and disables the search button to prevent searching without data in the inputs.
	 * @param {*} e 
	 */
	changeNameAccount(e) {
		this.accountName = e.detail.value;
		this.disableSearchButton = this.accountName.length > 0 ? false : true;
	}

	/**
	 * Fires every time information is entered into the input. Enables and disables the search button to prevent searching without data in the inputs.
	 * @param {*} e 
	 */
	changeNameOpportunity(e) {
		this.opportunityName = e.detail.value;
		this.disableSearchButton = this.opportunityName.length > 0 ? false : true;
	}

	/**
	 * It will be triggered from the confirm button and will call Apex to link the documents to the selected opportunity.
	 */
	confirmAssociate() {
		this.vinculateOpportunity();
	}

	/**
	 * Reset all variables and the process will start from 0
	 */
	cancel() {
		this.current = '1';
		this.checkStepPostion();
		this.accountName = '';
		this.opportunityName = '';
		this.disabledAssociateAndDiscardButton = true;
		this.showActionButtons = true;
		this.dataOpp = [];
		this.dataConfirmTable = [];
		this.dataDocumentSelected = [];
	}


	/**
	 * Calls Apex to filter the list of opportunities by customer name or opportunity name.
	 * Returns a list of opportunities to be associated with the array that will be displayed by the table.
	 */
	getOpportunitiesByClientNameOrOppName() {
		getOpportunities({ accountName: this.accountName, opportunityName: this.opportunityName })
			.then(result => {
				if (result) {
					this.dataOpp = this.formatData(result);
					this.accountName = '';
					this.opportunityName = '';
					this.disableSearchButton = true;
				}
			})
			.cacht(error => {
				console.log('Error ', error);
			})
	}

	/**
	 * Cambia el estado de los documentos y los vincula con la oportunidad
	 */
	vinculateOpportunity() {
		vincDocusOpp({ lstDocumentId: this.documentsIdsList, opportunityId: this.dataConfirmTable[0].oppId })
			.then(result => {
				if (result == '') {
					this.showToast(correcto, correcto2, 'success');
					this.cancel();
				} else {
					this.showToast('Error', error2, 'error');
					console.log('Errores: ', result);
				}
			})
			.cacht(error => {
				console.log('vinculateOpportunity error ', error);
			});
	}

	/**
	 * Descarta los documentos seleccionados cambiandolos de estado a descartados
	 */
	updateDocumentStatus() {
		updateState({ documentId: this.documentsIdsList })
			.then(result => {
				if (result == '') {
					this.showToast(correcto, correcto1, 'success');
					this.dataDocument = [];
					this.renderFirstTable = false;
					this.isLoading = false;
					refreshApex(this.wireDocuments);
				} else {
					this.showToast('Error', error1, 'error');
				}
			}).cacht(error => {
				console.log('Error: ', error);
			});
	}

	/**
	 * Displays a message to the user.
	 * @param {*} title (Required) The title of the toast, displayed as a heading.
	 * @param {*} message (Required) A string representing the body of the message.
	 * @param {*} variant Changes the appearance of the notice. Valid values are: info (default), success, warning, and error.
	 */
	showToast(title, message, variant) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
	}

	/**
	 * Since we are using a datatable, we need to indicate the direct path of the fieldName in the columns.
	 * This method will put the information in the list that is passed as a parameter at the same level in order to inform the columns of the dataOpp table.
	 * @param {*} data 
	 * @returns 
	 */
	formatData(data) {
		const flattenedData = data.map(item => ({
			...item,
			AccountName: item.Account?.Name,
			AccountId: item.Account?.Id,
			OwnerName: item.Owner?.Name,
			OwnerId: item.Owner?.Id
		}));

		flattenedData.forEach(item => {
			delete item.Account;
			delete item.Owner;
		});
		return flattenedData;
	}
}