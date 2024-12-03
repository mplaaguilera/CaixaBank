import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOppos from '@salesforce/apex/AV_OppBlockEventTask_Controller.retrieveAccountOpportunities';
import lookupSearchProduct from '@salesforce/apex/AV_OppBlockEventTask_Controller.searchProduct';
import getComboboxValues from '@salesforce/apex/AV_ReportAppointment_Controller.getPicklistValues';

export default class Av_OpportunityBlockEventTaskReport extends LightningElement {
    @api accountid;
	@api recordid;
	@api headerid;
	opposCount = 0;
	@track oppoList;
	@track oppoListRecord;
	@track oppoNewList = [];
	showNewOppo = false;
	labelButton = 'Nueva oportunidad';
	iconButton = 'utility:add';
	showSpinner = true;
	showOppoListRecord = false;
	showOppoList = false;
	oppoObj = {};//Guarda el conjunto de oportunidades que han sido editadas
	subProductInitial = [];
	errors = [];
	titleOppRecord = 'Oportunidades vinculadas';
	productToAdd = true;
	idProvisional= 0;
	@track resolutionList
	@track potentialList
	@track requiredClass;
	numAgendeds = 0;
	selectedIds = [];

	connectedCallback(){
		this.retriveOpps();
		if(this.recordid.includes('00U3')){
			this.titleOppRecord = 'Oportunidades vinculadas';
		}
		
	}
	
	retriveOpps() {
		getOppos({ accountId:this.accountid, recordId: this.headerid})
		.then(result=> {
			if (result != null) {
				if(result.listOppRecord != null && result.listOppRecord.length > 0) {
					this.oppoListRecord = result.listOppRecord;
					this.oppoListRecord.forEach(opp => {
						this.selectedIds.push(opp.ProductoMain);	
					});
					this.showOppoListRecord = true;
				}
				if(result.listOppAccounts != null && result.listOppAccounts.length > 0) {
					this.oppoList = result.listOppAccounts;
					this.oppoList.forEach(opp => {
						this.selectedIds.push(opp.ProductoMain);
					});
					this.showOppoList = true;
				}
				this.showSpinner = false;
			}else {
				this.showSpinner = false;
			}
		}).catch(error => {
			console.log(error);
			this.showSpinner = false;
		}).finally(() => {
			if(this.oppoListRecord != null && this.oppoListRecord.length > 0){
				this.oppoListRecord.forEach(opp => {
					this.template.querySelector("[data-id='"+ opp.Id +"']").handleVincular();
					if(opp.mainVinculed){
						this.template.querySelector("[data-id='"+ opp.Id +"']").handleMain();
					}
					this.template.querySelector("[data-id='"+ opp.Id +"']").sendDataToController();
				});
			}
		})
	}

	handleAddOppo(){
		let cmp = this.template.querySelector("[data-id='clookup1']");
		let selection = cmp.getSelection()[0];
		if(selection != null){
			this.selectedIds.push(selection.id);
			this.oppoNewList.push(
				{
					Id:'idProvisional'+this.idProvisional++,
					Name:selection.title,
					Stage:'En gestión/insistir',
					ProductoMain:selection.id,
					Fecha: new Date().toJSON().slice(0, 10),
					NotInserted:true,
					unFoldCmp:true
				}
			);
			cmp.handleClearSelection();
		}		
	}

	handleSearchProduct(event) {
		lookupSearchProduct({searchTerm:event.detail.searchTerm,selectedIds:this.selectedIds, accountId:this.accountid})
		.then((results) => {
			this.template.querySelector('[data-id="clookup1"]').setSearchResults(results);
		})
		.catch((error) => {
			this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
			console.error('Lookup error', JSON.stringify(error));
			this.errors = [error];
		});
	}

	handleSelectionChange(event) {
		this.productToAdd = this.template.querySelector("[data-id='clookup1']").getSelection().length == 0;
	}

	handleVinculation(e){
		(e.detail.sum)?this.opposCount++:this.opposCount--;
		var auxList = [];
		if(this.oppoList != null && this.oppoList.length > 0) {
			auxList = auxList.concat(this.oppoList);
		}
		if (this.oppoNewList != null && this.oppoNewList.length > 0) {
			auxList = auxList.concat(this.oppoNewList);
		} 
		if (this.oppoListRecord != null && this.oppoListRecord.length > 0) {
			auxList = auxList.concat(this.oppoListRecord);
		}
		var oppoDetail = this.template.querySelector('[data-id="'+e.detail.oppoId+'"]');
		if (e.detail.sum) {
			if (this.opposCount <= 1) {
				oppoDetail.mainVinculed = true;
			}
		} else {
			if (this.opposCount < 1) {
				oppoDetail.mainVinculed = false;
			} else {
				if (oppoDetail.mainVinculed) {
					var cont = true;
					auxList.forEach(opp => {
						var oppoDetailToMain = this.template.querySelector('[data-id="'+opp.Id+'"]');
						if(opp.Id != e.detail.oppoId && cont && oppoDetailToMain.vinculed){
							oppoDetailToMain.mainVinculed = true;
							cont = false;
						}
					})
					oppoDetail.mainVinculed = false;
				}
			}
		}
	}

	handleMainOpp(e){
		let itemOppId = e.detail.oppoId;
		let auxList = [];
		if(this.oppoList != null && this.oppoList.length > 0) {
			auxList = auxList.concat(this.oppoList);
		} 
		if (this.oppoNewList != null && this.oppoNewList.length > 0) {
			auxList = auxList.concat(this.oppoNewList);
		}
		if (this.oppoListRecord != null && this.oppoListRecord.length > 0) {
			auxList = auxList.concat(this.oppoListRecord);
		}
		if (auxList != null && auxList.length > 0) {
			auxList.forEach(opp => {
				this.template.querySelector('[data-id="'+opp.Id+'"]').mainVinculed = (opp.Id == itemOppId);
				if (this.oppoObj[opp.Id] != null) {
					this.oppoObj[opp.Id].mainVinculed = (opp.Id == itemOppId);
				}
			});
		}
		this.dispatchEvent(
			new CustomEvent('setoppoforcontroller',{
				detail:this.oppoObj
			})
		);
	}

	buildOppoObj(e){
		let nextOppo = (e.detail != null) ? e.detail : e 
		let id = (e.detail != null) ? e.detail.id : e.Id;
		let vinculed = (e.detail != null) ? e.detail.isVinculed : e.isVinculed;
		if(Object.keys(this.oppoObj).includes(id) && !vinculed){
			delete this.oppoObj[id]
		}else{
			this.oppoObj[id] = nextOppo;
		}
		this.dispatchEvent(
			new CustomEvent('setoppoforcontroller',{
				detail:this.oppoObj
			})
		)
	}

	evaluateAgendeds(e){
		e.detail.sum ? this.numAgendeds++ : this.numAgendeds--;
		this.dispatchEvent(
			new CustomEvent(
				'evaluateagendeds',{
					detail: (this.numAgendeds > 0)
				}
			)
		)
	}

	@api
	highlightOppo(id){
		let b =  this.template.querySelector('[data-id="'+id+'"]');
		if(this.oppoObj[id].newPath == 'No apto'){
			this.showToast('Faltan datos','Indica una fecha de no ofrecer hasta que sea mayor o igual a hoy.','error','pester');
		}else if(this.oppoObj[id].newPath == 'En gestión/insistir'){
			this.showToast('Faltan datos','Indica una fecha de próxima gestión que sea mayor o igual a hoy.','error','pester');
		}else if(this.oppoObj[id].newPath == 'No interesado' && this.oppoObj[id].resolucion == null){
			this.showToast('Faltan datos','Debes de rellenar el campo de resolución.','error','pester');
		}else if(this.oppoObj[id].newPath == 'No interesado' &&  this.oppoObj[id].resolucion == 'O' &&  (this.oppoObj[id].comentario == null | this.oppoObj[id].comentario == '')){
			this.showToast('Faltan datos', 'Debes de rellenar el campo de comentario.', 'error', 'pester');
		}
		b.scrollIntoView({
			behavior: 'auto',
			block: 'center',
			inline: 'center'
		});
		b.highlightBadInput();
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

	@wire(getComboboxValues,{ fields: ['AV_Resolucion__c','AV_Potencial__c']} )
	getComboboxValues(wireResult){
		let error = wireResult.error;
		let data = wireResult.data;
		if(data){
			this.resolutionList = data[0].filter(item => item.value !== 'VD');
			this.potentialList = data[1];
		}else if(error){
			console.log('Error => ',error);
		}
	}
}