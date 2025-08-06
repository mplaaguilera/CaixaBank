import { api, LightningElement, track } from 'lwc';
import lookupSearch from '@salesforce/apex/CIBE_LookUpFlow_Controller.search';

export default class Cibe_LookUpFlow extends LightningElement {

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

	@api
	get idResult(){
		return this._idResult;
	}

	@track isConnected = false;

	connectedCallback() {
		if(!this.isConnected) {
			this.isConnected = true;
			lookupSearch ({searchTerm: 'null', selectedIds: [], condition: this.condition, title: this.title, subtitle: this.subtitle, objectName: this.objectName, icon: this.icon })
				.then((results) => {
					if(results !== null && results.length > 0) {
						this.errors = [];
						this._idResult  = String(results[0].id);
						this.template.querySelector('[data-id="clookup1"]').selection = results[0];
					}
				})
				.catch((error) => {
					console.error('Lookup error', JSON.stringify(error));
					this.errors = [error];
				});
		}
	}

	handleSearch(event) {
		this.buscar = event.detail.searchTerm;
		lookupSearch ({searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds, condition: this.condition, title: this.title, subtitle: this.subtitle, objectName: this.objectName, icon: this.icon })
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
			lookupSearch ({searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds, condition: this.condition, title: this.title, subtitle: this.subtitle, objectName: this.objectName, icon: this.icon })
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