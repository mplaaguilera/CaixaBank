import { api, LightningElement, track,wire } from 'lwc';
import lookupSearch from '@salesforce/apex/AV_LookUpFlow_Controller.search';

import { CurrentPageReference } from 'lightning/navigation';

export default class AV_LookUpFlow extends LightningElement {

	@track initialSelection = [];
	@track errors = [];
	@track _idResult;
	@track buscar='';

	@api condition;
	@api title;
	@api subtitle;
	@api objectName;
	@api icon;
	@api fieldlabel;
	@api placeholder;
	@api required;
	
	@api recordId; 

	@wire(CurrentPageReference)
    currPage(pageRef) {
        this.recordId = pageRef.attributes.recordId;
        this.currentPageReference = pageRef;
    }

	@api
	get idResult(){
		return this._idResult;
	}

	handleSearch(event) {
		this.buscar=event.detail.searchTerm;
		lookupSearch ({searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds,idAcc: this.recordId})
			.then((results) => {
				this.template.querySelector('[data-id="clookup1"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup1"]').scrollIntoView();
			})
			.catch((error) => {
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSearchClick(event) {
		if (this._idResult == null  && this.buscar == '') {
			lookupSearch ({searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds,idAcc: this.recordId})
				.then((results) => {
					this.template.querySelector('[data-id="clookup1"]').setSearchResults(results);
					this.template.querySelector('[data-id="clookup1"]').scrollIntoView();
				})
				.catch((error) => {
					console.error('Lookup error', JSON.stringify(error));
					this.errors = [error];
				});
		}
	}

	handleSelectionChange(event) {
		this.errors = [];
		let targetId = event.target.dataset.id;
		const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
		if(selection.length !== 0){
				for(let sel of selection) {
					this._idResult  = String(sel.id);
				}
		} else {
			this._idResult = null;
		}
	}
}