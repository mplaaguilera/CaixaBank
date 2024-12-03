import { LightningElement, api, track, wire } from 'lwc';

import { refreshApex } from '@salesforce/apex';

import getPicklistValues from '@salesforce/apex/CIBE_CustomPicklistController.picklistValues';
import getPicklistValuesDepen from '@salesforce/apex/CIBE_CustomPicklistController.picklistValuesDependency';
import getHierarchies from '@salesforce/apex/CIBE_CustomPicklistController.getHierarchies';
import isEditable from '@salesforce/apex/CIBE_CustomPicklistController.isEditable';
import insertHierarchy from '@salesforce/apex/CIBE_CustomPicklistController.insertHierarchy';
import deleteHierarchy from '@salesforce/apex/CIBE_DeleteHierarchy.deleteHierarchy';
import getEmpleados from '@salesforce/apex/CIBE_CustomPicklistController.getEmpleados';

//Labels
import guardar from '@salesforce/label/c.CIBE_Guardar';
import negocio from '@salesforce/label/c.CIBE_Negocio';
import redeSeg from '@salesforce/label/c.CIBE_RedeSeg';
import sectorPai from '@salesforce/label/c.CIBE_SectorPais';
import centCar from '@salesforce/label/c.CIBE_CentroCartera';
import jerarCIB from '@salesforce/label/c.CIBE_jerarquiaCIB';
import selecciona from '@salesforce/label/c.CIBE_SeleccionaOpcion';
import cancel from '@salesforce/label/c.CIBE_Cancelar';
import save from '@salesforce/label/c.CIBE_Guardar';
import add from '@salesforce/label/c.CIBE_Add';

import fieldManager from '@salesforce/schema/Contact.CIBE_Manager__c';


export default class cibe_picklistJerarquiaContact_CIB extends LightningElement {

	labels = {
		guardar, 
		negocio, 
		redeSeg, 
		sectorPai, 
		centCar, 
		jerarCIB, 
		selecciona,
		cancel,
		save,
		add
	}

	fields1 = [ fieldManager ];
	

	inputObj = 'Contact';
	inputField = 'Negocios';
	inputField2  = 'Redes-Segmentos';
	inputField3  = 'Sectores-Paises';
    inputField4  = 'Centros-Carteras';

	@api recordId;

	@track editMode = false;
	@track editModeManager = false;
	@track isLoading = false;
    @track showHierarchy = true;

	@track hierarchies = [];
	@track toCreate = [];
	@track toRemove = [];
	
	@track selected = [];
	@track selected2 = [];
	@track selected3 = [];
	@track selected4 = [];

	@track picklistValues = [];
	@track picklistValues2 = [];
	@track picklistValues3 = [];
    @track picklistValues4 = [];

	@track picklistValue1 = '';
	@track picklistValue2 = '';
	@track picklistValue3 = '';
    @track picklistValue4 = '';

	@track isShowEditButton = false;

	@track initialSelection = [];
	@track errors = [];
	@track buscar = '';

	@track manager;
	@track contactId = false;

	@wire(isEditable, {})
	isEditable({data, error}) {
		if(data) {
			this.isShowEditButton = data;
		} else if(error) {
			console.log(error);
		}
    }
	
	@wire(getPicklistValues, { inputField : '$inputField', inputObj : '$inputObj' })
	wiredPicklist({data, error}) {
		if(data) {
			this.picklistValues = JSON.parse(JSON.stringify(data));
			this.picklistValues = this.picklistValues.sort((a, b) => (a.label > b.label) ? 1 : -1);
		} else if(error) {
			console.log(error);
		}
    }
	
	@track update = false;
	@track _wiredData = [];
	@wire(getHierarchies, { recordId : '$recordId', forceUpdate : '$update' })
	wiredContact(wiredData) {
		this._wiredData = wiredData;
		const {data, error} = wiredData;
		if(data) {
			this.hierarchies = JSON.parse(JSON.stringify(data));
			this.selected = [];
			this.selected2 = [];
			this.selected3 = [];
			this.selected4 = [];
			
			this.hierarchies.forEach(hierarchy => {
				hierarchy["Ids"] = hierarchy.CIBE_Negocios__c + '_' + hierarchy.CIBE_RedesSegmentos__c + '_' + hierarchy.CIBE_SectoresPaises__c + '_' + hierarchy.CIBE_CentrosCarteras__c;
				hierarchy["hierarchyNames"] = [];
				if(hierarchy.CIBE_Negocios__c) {
					if(!this.selected.includes(hierarchy.CIBE_Negocios__r.Name)) {
						this.selected.push(hierarchy.CIBE_Negocios__r.Name);
					}
					hierarchy.hierarchyNames.push(hierarchy.CIBE_Negocios__r.Name);
				}
				if(hierarchy.CIBE_RedesSegmentos__c) {
					if(!this.selected2.includes(hierarchy.CIBE_RedesSegmentos__r.Name)) {
						this.selected2.push(hierarchy.CIBE_RedesSegmentos__r.Name);
					}
					hierarchy.hierarchyNames.push(hierarchy.CIBE_RedesSegmentos__r.Name);
				}
				if(hierarchy.CIBE_SectoresPaises__c) {
					if(!this.selected3.includes(hierarchy.CIBE_SectoresPaises__r.Name)) {
						this.selected3.push(hierarchy.CIBE_SectoresPaises__r.Name);
					}
					hierarchy.hierarchyNames.push(hierarchy.CIBE_SectoresPaises__r.Name);
				}
				if(hierarchy.CIBE_CentrosCarteras__c) {
					if(!this.selected4.includes(hierarchy.CIBE_CentrosCarteras__r.Name)) {
						this.selected4.push(hierarchy.CIBE_CentrosCarteras__r.Name);
					}
					hierarchy.hierarchyNames.push(hierarchy.CIBE_CentrosCarteras__r.Name);
				}
			});

			this.update = false;
		} else if(error) {
			console.log(error);
		}
	}
	@wire(getEmpleados, { recordId : '$recordId' })
    wiredEmpleados({ error, data }) {
        if (data) {
			this.manager = JSON.parse(JSON.stringify(data));
			this.contactId = this.manager[0].Id;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.manager = undefined;
        }
    }

	handleEditManager(event){
		this.contactId = event.target.checked;
	}
	handleAddHierarchy(event) {		
		let hierarchy = {
			Ids : this.picklistValue1 + '_' + this.picklistValue2 + '_' + this.picklistValue3 + '_' + this.picklistValue4,
			hierarchyNames : [],
			CIBE_Contact__c : this.recordId,
			CIBE_Negocios__c : this.picklistValue1,
			CIBE_RedesSegmentos__c : this.picklistValue2,
			CIBE_SectoresPaises__c : this.picklistValue3,
			CIBE_CentrosCarteras__c : this.picklistValue4
		}

		if(this.picklistValues && this.picklistValues.length > 0) {
			const name = this.picklistValues.find(o => o.value === this.picklistValue1).label;
			hierarchy.hierarchyNames.push(name);
		}

		if(this.picklistValues2 && this.picklistValues2.length > 0 && this.picklistValues2.find(o => o.value === this.picklistValue2)) {
			const name = this.picklistValues2.find(o => o.value === this.picklistValue2).label;
			hierarchy.hierarchyNames.push(name);
		}

		if(this.picklistValues3 && this.picklistValues3.length > 0 && this.picklistValues3.find(o => o.value === this.picklistValue3)) {
			const name = this.picklistValues3.find(o => o.value === this.picklistValue3).label;
			hierarchy.hierarchyNames.push(name);
		}

		if(this.picklistValues4 && this.picklistValues4.length > 0 && this.picklistValues4.find(o => o.value === this.picklistValue4)) {
			const name = this.picklistValues4.find(o => o.value === this.picklistValue4).label;
			hierarchy.hierarchyNames.push(name);
		}
		

		this.hierarchies.push(hierarchy);
		this.toCreate.push(hierarchy);
	}

	handleRemoveHierarchy(event) {
		const ids = event.target.dataset.id;
		
		let toRemove = [];
		this.hierarchies.forEach(hierarchy => {
			if(hierarchy["Id"] && hierarchy["Ids"] === ids) {
				toRemove.push(hierarchy);
			}
		});

		if(toRemove.length > 0) {
			this.toRemove = [...this.toRemove, ...toRemove];
		}
	
		this.toCreate = this.toCreate.filter(hierarchy => hierarchy.Ids !== ids);
		this.hierarchies = this.hierarchies.filter(hierarchy => hierarchy.Ids !== ids);
	}

	handleSaveHierarchy() {
		let toInsert = [];
		if(this.toCreate && this.toCreate.length > 0) {
			toInsert = JSON.parse(JSON.stringify(this.toCreate));
			toInsert.forEach(obj => { 
				delete obj.Ids;
				delete obj.hierarchyNames;
			});
		}

		let toDelete = [];
		if(this.toRemove && this.toRemove.length > 0) {
			toDelete = JSON.parse(JSON.stringify(this.toRemove));
			toDelete.forEach(obj => { 
				delete obj.Ids;
				delete obj.hierarchyNames;
			});
		}

		this.isLoading = true;
		const promises = [insertHierarchy({ listaInsert : toInsert }), deleteHierarchy({ deleteList : toDelete })];
		Promise.allSettled(promises).then(results => {
            this.editMode = false;
        }).finally(() => {
			this.toCreate = [];
            this.toRemove = [];
			this.picklistValue1 = '';
			this.picklistValue2 = '';
			this.picklistValue3 = '';
			this.picklistValue4 = '';
			
			this.isLoading = false;
			refreshApex(this._wiredData);
        });
	}

	handleValueChange(event) {
		const selected = event.detail.value;
		this.picklistValue1 = selected;
		
		let currentOption = this.picklistValues.find(o => o.value === selected).label;
		if(selected) {
			this.getDependencyPicklist(this.inputField, currentOption);
		}
    }

	handleValueChange2(event){
		const selected = event.detail.value;
		this.picklistValue2 = selected;

		let currentOption = this.picklistValues2.find(o => o.value === selected).label;
		if(selected) {
			this.getDependencyPicklist(this.inputField2, currentOption);
		}
    }

	handleValueChange3(event){
		const selected = event.detail.value;
		this.picklistValue3 = selected;

		let currentOption = this.picklistValues3.find(o => o.value === selected).label;
		if(selected) {
			this.getDependencyPicklist(this.inputField3, currentOption);
		}
    }

    handleValueChange4(event){
		const selected = event.detail.value;
		this.picklistValue4 = selected;
    }

	handleClick() {
		this.editMode = true;
	}

	handleCancel(){
		this.toCreate = [];
		this.toRemove = [];
		this.picklistValue1 = '';
		this.picklistValue2 = '';
		this.picklistValue3 = '';
		this.picklistValue4 = '';
		this.update = true;
		this.editMode = false;
	}

	getDependencyPicklist(inputFld, selected) {
		getPicklistValuesDepen({ inputField : inputFld, inputValue : selected, inputObj : this.inputObj })
			.then((data) => {
				console.log(data);
				switch(inputFld) {
					case this.inputField:
						this.picklistValues2 = JSON.parse(JSON.stringify(data));
						this.picklistValue2 = this.picklistValue2.sort((a, b) => (a.label > b.label) ? 1 : -1);
						this.picklistValue2 = '';
						this.picklistValue3 = '';
						this.picklistValue4 = '';
						break;
					case this.inputField2:
						this.picklistValues3 = JSON.parse(JSON.stringify(data));
						this.picklistValues3 = this.picklistValues3.sort((a, b) => (a.label > b.label) ? 1 : -1);
						this.picklistValue3 = '';
						this.picklistValue4 = '';			
						break;
					case this.inputField3:
						this.picklistValues4 = JSON.parse(JSON.stringify(data));
						this.picklistValues4 = this.picklistValues4.sort((a, b) => (a.label > b.label) ? 1 : -1);
						this.picklistValue4 = '';
						break;
				}
			}).catch(error => {
				console.log(error);
			});
	}

	toggleShowHierarchy() {
		this.showHierarchy = !this.showHierarchy;
    }

	get isDisabled1(){
		return (this.picklistValues && this.picklistValues.length == 0);
	}

	get isDisabled2(){
		return (this.picklistValue1 && this.picklistValue1.length == 0);
	}

	get isDisabled3(){
		return (this.picklistValue2 && this.picklistValue2.length == 0);
	} 

	get isDisabled4(){
		return (this.picklistValue3 && this.picklistValue3.length == 0);
	}
	handleEnableEdit() {
        this.editModeManager = true;
    }

    handleSubmit() {
        this.showSpinner = true;
		this.isLoading = true;
    }

    handleSuccess() {
        this.editModeManager = false;
        this.showSpinner = false;
		this.isLoading = false;

    }

    handleError(event) {
        this.showSpinner = false;
		this.isLoading = false;
    }
    
    handleCancel(){
        this.editMode = false;
		this.editModeManager = false;
    }


}