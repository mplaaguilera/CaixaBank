import { LightningElement,api,track,wire } from 'lwc';
import getOppos from '@salesforce/apex/AV_ReportAppointment_Controller.retrieveAccountOpportunities';
import lookupSearchProduct from '@salesforce/apex/AV_ReportAppointment_Controller.searchProduct';
import getComboboxValues from '@salesforce/apex/AV_ReportAppointment_Controller.getPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID 						   						   from '@salesforce/user/Id';


export default class Av_OpportunityBlockAppointment extends LightningElement {
	@api accountid;
	@api recordid;
	@api isreport;
	opposCount = 0;
	@track oppoList;
	@track oppoNewList = [];
	otherOpposLabel;
	showNewOppo = false;
	labelButton = 'Nueva oportunidad';
	iconButton = 'utility:add';
	showSpinner = true;
	oppoObj = {};//Guarda el conjunto de oportunidades que han sido editadas
	subProductInitial = [];
	errors = [];
	productToAdd = true;
	idProvisional= 0;
	@track resolutionList
	@track potentialList
	@track requiredClass;
	numAgendeds = 0;
	selectedIds = [];
	@track particularOpportunity;
	@track showButtonDelete = false;
	@api nolocalizado; 
	

	connectedCallback(){
		this.retriveOpps();
	}
	@api
	sendInitialStates(){
		let mapInitialSates = {};

		for(let id in this.oppoObj){
			mapInitialSates[id] = this.template.querySelector('[data-id="'+id+'"]').initialState;
		}

		return mapInitialSates;
	}
	retriveOpps() {
		getOppos({ accountId:this.accountid})
		.then(result=> {
			if (result != null) {
				this.oppoList = (!this.isreport) ? result : [];
				this.valueOppoList();
				result.forEach(opp => {
					this.selectedIds.push(opp.ProductoMain);
					if(this.isreport){
						if(this.recordid === opp.Id){
							
							this.particularOpportunity = opp;
							this.valueOppoList();
							this.dispatchEvent(
								new CustomEvent('nameoppo',{
									detail:{
										reportingopp:opp
									}
								})
							)
						}else{
							this.oppoList.push(opp);
						}
					}
				})
				
				this.otherOpposLabel = this.isreport && this.oppoList.length > 0
				this.showSpinner = false;
			}else {
				this.showSpinner = false;
			}
		}).catch(error => {
			console.log('Error: '+error);
			this.showSpinner = false;
		}).finally( () =>{
			if(this.particularOpportunity != undefined){
				this.template.querySelector('[data-id="'+this.particularOpportunity.Id+'"]').sendDataToController();
				this.template.querySelector('[data-id="'+this.particularOpportunity.Id+'"]').handleVincular();
				this.template.querySelector('[data-id="'+this.particularOpportunity.Id+'"]').handleMain();
			}
		})
	}

	@wire(getComboboxValues,{ fields: ['AV_Resolucion__c','AV_Potencial__c']} )
	getComboboxValues(wireResult){
		let error = wireResult.error;
		let data = wireResult.data;
		if(data){
			this.resolutionList = data[0].filter(item => item.value !== 'VD' && item.value !== 'Vencida' && item.value !== 'No Apto');
			this.resolutionList.unshift(data[0].find(item => item.value=='No Apto'));			
			this.potentialList = data[1];
		}else if(error){
			console.log('Error => ',error);
		}
	}

	handleAddOppo(){
		this.showButtonDelete = true;
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
					unFoldCmp:true,
					IsNewProduct: selection.prodNewAction
					,owneridopp : USER_ID 
				}
			);
			cmp.handleClearSelection();
		}		
	}

	handleVinculation(e){
		(e.detail.sum)?this.opposCount++:this.opposCount--;
		var auxList = this.oppoList.concat(this.oppoNewList);
		if(this.particularOpportunity != null && this.particularOpportunity != undefined ){
			auxList.push(this.particularOpportunity);
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
		let auxList = this.oppoList.concat(this.oppoNewList); 
		if(this.particularOpportunity != null && this.particularOpportunity != undefined ){
			auxList.push(this.particularOpportunity);
		}
		auxList.forEach(opp => {
			this.template.querySelector('[data-id="'+opp.Id+'"]').mainVinculed = (opp.Id == itemOppId);
			if (this.oppoObj[opp.Id] != null) {
				this.oppoObj[opp.Id].mainVinculed = (opp.Id == itemOppId);
			}
		})
		

		this.dispatchEvent(
			new CustomEvent('setoppoforcontroller',{
				detail:this.oppoObj
			})
		)
	}

	handleSearchProduct(event) {
		lookupSearchProduct({searchTerm: event.detail.searchTerm, selectedIds: this.selectedIds, accountId: this.accountid})
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

	@api
	highlightOppo(id){
		let b =  this.template.querySelector('[data-id="'+id+'"]');
		let closedStatus = ['No interesado','Producto Rechazado'];
		if(this.oppoObj[id].newPath == 'En gestión/insistir'){
			this.showToast('Faltan datos','Indica una fecha de próxima gestión que sea mayor o igual a hoy.','error','pester');
		}else if(closedStatus.includes(this.oppoObj[id].newPath) &&  this.oppoObj[id].resolucion == 'O' &&  (this.oppoObj[id].comentario == null | this.oppoObj[id].comentario == '')){
			this.showToast('Faltan datos', 'Debes de rellenar el campo de comentario.', 'error', 'pester');
		}else if(closedStatus.includes(this.oppoObj[id].newPath) && this.oppoObj[id].resolucion == 'No Apto' && this.oppoObj[id].noofrecerhasta == null){
			this.showToast('Faltan datos', 'Por favor, rellena los campos obligatorios', 'error', 'pester');

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

	evaluateAgendeds(e){
		if(e.detail.sum){
			this.numAgendeds++;
		}else if((this.numAgendeds - 1) != -1 ){
			this.numAgendeds --;
		}
		this.dispatchEvent(
			new CustomEvent(
				'evaluateagendeds',{
					detail: (this.numAgendeds > 0)
				}
			)
		)
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

	handleOppoDelete(event) {   
		const oppoIdToDelete = event.detail;
		const deletedOppo = this.oppoNewList.find(oppo => oppo.Id === oppoIdToDelete);
		if (deletedOppo) {
			this.selectedIds = this.selectedIds.filter(id => id !== deletedOppo.ProductoMain);
		}
		this.oppoNewList = this.oppoNewList.filter(oppo => oppo.Id !== oppoIdToDelete);
		this.handleVinculation({ detail: { sum: false, oppoId: oppoIdToDelete } });
	
		if (this.oppoObj[oppoIdToDelete]) {
			delete this.oppoObj[oppoIdToDelete];
		}

		this.dispatchEvent(
			new CustomEvent('setoppoforcontroller',{
				detail:this.oppoObj	
			})
		)
	}

	valueOppoList(){
		this.dispatchEvent(
			new CustomEvent('sendvalueoppolist',
			{
				detail:{
					opportunitiesList: this.oppoList,
					opportunitiesVinculed: this.particularOpportunity
				}
			})
		)
	}
}