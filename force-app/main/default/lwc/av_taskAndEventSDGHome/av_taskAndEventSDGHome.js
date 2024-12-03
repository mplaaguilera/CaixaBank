import { LightningElement, api, track, wire } from 'lwc';

//apex methods
import getRecords from '@salesforce/apex/AV_TaskAndEventSDGHome_Controller.getRecords';

import { refreshApex } from '@salesforce/apex';

const PENDING = 'Pendiente';
const PENDING_NOT_LOCATED = 'Pediente no localizado';

export default class Av_taskAndEventSDGHome extends LightningElement{


	@api sdgApiName;
	
	@track columns;
	@track records = [];
	@track iconName;
	@track titleLabel;
	@track error;
	@track numRecords;
	@track loading = false;
	@track sortedBy;
	@track sortDirection = 'asc';
	@track defaultSortDirection = 'asc';
	@track showTable = false;
	@track showPagination = false;
	@track recordsToDisplay; //Records to be displayed on the page
	@track rowNumberOffset; //Row number
	@track pageNumber=1;
	//Paginación
	@track totalPage = 0;
	@track pageSize = 10; 
	@track page = 1; 
	@track isMultipagina = true;
	@track isMultiEntry2 = false;
	@track filterProduct;
	@track data;
	@track totalRecountCount;
	@track optionsPage= [];
	
	refresh(){
		this.loading = true;
		this.page=1;
		this.pageSize = 10;
		refreshApex(this.wiredResult).then(result => { this.loading = false});
	}
	
	connectedCallback() {
		this.loading = true;
	}

	@wire(getRecords, {sdgApiName: '$sdgApiName'})
	wiredGetRecords(result){

		this.wiredResult = result;
		
		var data = result.data;
		var error = result.error;

		if(data !== undefined) {

			this.columns = data.cols;
			let tempOppList = [];  
			for (var i = 0; i < data.data.length; i++) {  
			
				let tempRecord = Object.assign({}, data.data[i]); //cloning object  
				tempRecord.clientLink  =  "/" + tempRecord.WhatId;
				tempRecord.clientLabel =  tempRecord.What?.Name;
				tempRecord.subjectLink = "/" + tempRecord.Id;
				tempRecord.subjectLabel= tempRecord.Subject;    
				tempRecord.ownerLabel = tempRecord.Owner?.Name; 
				tempRecord.ownerLink = "/" + tempRecord.OwnerId; 
				tempRecord.clientLabel = tempRecord.What?.Name;
				if(tempRecord.Status == PENDING || tempRecord.Status == PENDING_NOT_LOCATED || tempRecord.CSBD_Evento_Estado__c == PENDING) {
					tempRecord.customClass = 'slds-text-title_bold';
				}
				tempOppList.push(tempRecord);
			}  

			this.records = tempOppList; 
			this.numRecords = data.data.length;
			this.iconName = data.icono;
			this.titleLabel = data.title;
			this.showTable = true;
			this.loading = false;
			this.recordsToDisplay = [];

			this.data=data.data;
			this.totalRecountCount = data.data.length;
			this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
			if (this.totalPage<=1) {
				this.isMultipagina= false;
			}else{
				for(let i=1; i < this.totalPage+1; i++){
					var aux= { label: i.toString() , value: i };
					this.optionsPage.push(aux);
				}
				this.isMultipagina= true;
			}

			for(let i=(this.pageNumber-1)*this.pageSize; i < this.pageNumber*this.pageSize; i++){
				if(this.records[i] != null ){
					this.recordsToDisplay.push(this.records[i]);
				}
			}
		}if(error){
			console.log(error);
		}
	}

	
	handleSortdata(event) {

		var { fieldName: sortedBy, sortDirection } = event.detail;
		var cloneData = [...this.recordsToDisplay];
		const sortFieldName = this.columns.find(field=>sortedBy===field.fieldName).sortBy; 
		cloneData.sort(this.sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1));
		this.recordsToDisplay = cloneData;
		this.sortDirection = sortDirection;
		this.sortedBy = sortedBy;

		refreshApex(this.wiredResult);
	}

	sortBy(field, reverse, primer) {
			
			const key = primer
				? function(x) {
					return primer(x[field]);
				}
				: function(x) {
					return x[field];
				};

			return function(a, b) {
				a = key(a);
				b = key(b);
				var result;
				if (a == null) {
					result= 1;
				}
				else if (b == null) {
					result= -1;
				}else{
					result=( reverse * ((a.toLowerCase()  > b.toLowerCase() ) - (b.toLowerCase()  > a.toLowerCase() )));
				};
				return result;
			}
		
	}

	displayRecordPerPage(page){
		this.recordsToDisplay = [];

		for(let i=(page-1)*this.pageSize; i < page*this.pageSize; i++){
			if(this.records[i] != null ){
				this.recordsToDisplay.push(this.records[i]);
			}
		}
	}

	handleChangePage(event) {
		this.page = event.detail.value;
        this.displayRecordPerPage(this.page);
	}

	get optionsPageSize() {
		return [
			{ label: '10', value: 10 },
			{ label: '20', value: 20 },
			{ label: '50', value: 50 },
			{ label: '100', value: 100 }
		];
	}
	handleChangePageSize(event) {
		this.pageSize = event.detail.value;
		this.page=1;
		this.optionsPage=[];
		this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
		for(let i=1; i < this.totalPage+1; i++){
			var aux= { label: i.toString() , value: i };
			this.optionsPage.push(aux);
		}
        this.displayRecordPerPage(this.pageNumber);
	}
}