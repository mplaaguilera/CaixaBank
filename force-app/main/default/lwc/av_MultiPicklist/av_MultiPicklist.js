import { LightningElement, track, api } from 'lwc';

export default class Av_MultiPicklist extends LightningElement {

	@api values;
	@api selectedvalues = [];
	@api selectedlabels = [];
	@api picklistlabel = ' Buscar';
	@track valueAll = false;
	@track search = false;
	listValueSearch;
	@track labelOptions = null;
	@api showdropdown;

	handleleave() {
		let sddcheck= this.showdropdown;
		if(sddcheck){
			this.showdropdown = false;
			this.fetchSelectedValues();
		}
	}

	searchOptions(e){
		this.labelOptions = e.target.value;
		if(this.labelOptions != null) {
			this.search = true;
		} else {
			this.search = false;
		}
		this.listValueSearch = [];
		const picklistvalues = this.values.map(eachvalue => ({...eachvalue}));
		picklistvalues.forEach((element, index) => {
			var label = picklistvalues[index].label.toUpperCase();
			var fil = this.labelOptions.toUpperCase();
			if(label.includes(fil)){
				this.listValueSearch.push(picklistvalues[index]);
			}
		});
	}

	handleAll() {
		this.valueAll = !this.valueAll;
		this.listValueSearch = [];
		const picklistvalues = this.values.map(eachvalue => ({...eachvalue}));
		if (this.valueAll) {
			picklistvalues.forEach((element, index) => {
				var label = picklistvalues[index].label.toUpperCase();
				var fil;
				if(this.labelOptions != null) {
					fil = this.labelOptions.toUpperCase();
				}
				if(label.includes(fil) || fil == null){
					picklistvalues[index].selected = true;
					this.listValueSearch.push(picklistvalues[index]);
				}
			});
		} else {
			picklistvalues.forEach((element, index) => {
				var label = picklistvalues[index].label.toUpperCase();
				var fil;
				if(this.labelOptions != null) {
					fil = this.labelOptions.toUpperCase();
				}
				if(label.includes(fil) || fil == null){
					picklistvalues[index].selected = false;
					this.listValueSearch.push(picklistvalues[index]);
				}
			});
		}
		this.values = picklistvalues;
	}

	connectedCallback(){
		this.values.forEach(element => element.selected ? this.selectedvalues.push(element.value) : '');
		this.values.forEach(element => element.selected ? this.selectedlabels.push(element.label) : '');
	}

	fetchSelectedValues() {
		this.selectedvalues = [];
		this.selectedlabels = [];
		this.template.querySelectorAll('c-av_-value-multi-picklist').forEach(
			element => {
				if(element.selected && element.label != 'Todos'){
					this.selectedvalues.push(element.value);
					this.selectedlabels.push(element.label);
				}
			}
		);
		this.refreshOrginalList();
		var sendData = new CustomEvent('getvalues', {
			detail: {
				selectedvalues: this.selectedvalues,
				selectedlabels: this.selectedlabels
			}
		});
		this.dispatchEvent(sendData);
	}

	@api
	refreshOrginalList() {
		const picklistvalues = this.values.map(eachvalue => ({...eachvalue}));
		picklistvalues.forEach((element, index) => {
			if(this.selectedvalues.includes(element.value)){
				picklistvalues[index].selected = true;
			}else{
				picklistvalues[index].selected = false;
			}
		});
		this.values = picklistvalues;
	}

	@api
	refreshAll() {
		const picklistvalues = this.values.map(eachvalue => ({...eachvalue}));
		picklistvalues.forEach((element, index) => {
			picklistvalues[index].selected = false;
		});
		this.values = picklistvalues;
		this.valueAll = false;
		this.listValueSearch = [];
		this.search = false;
		this.labelOptions = null;
		this.selectedvalues = [];
		this.selectedlabels = [];
		this.template.querySelector('input').value = this.picklistlabel;
	}

	handleShowdropdown(){
		let sdd = this.showdropdown;
		if(sdd){
			this.showdropdown = false;
			this.fetchSelectedValues();
		}else{
			this.showdropdown = true;
		}
	}

	get selectedmessage() {
		var message = this.picklistlabel;
		if(this.selectedvalues.length !== 0) {
			message = ' '+this.selectedvalues.length + ' valores seleccionados';
		}
		return message;
	}
}