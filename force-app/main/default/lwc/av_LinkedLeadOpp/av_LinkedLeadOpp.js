import { LightningElement, api, track, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getLeadOpp from '@salesforce/apex/AV_LinkedLeadOpp_Controller.getLeadOpp';
import { refreshApex } from '@salesforce/apex';


export default class Av_LinkedLeadOpp extends NavigationMixin(LightningElement){

    @api recordId;
    @api filterObject;
	@api filterField;
	@track leadOpp=[];
	@track showLink=false;
	
	@track columns;
	@track records = [];
	@track iconName;
	@track titleLabel;
	@track error;
	@track numRecords;
	@track loading = false;
	@track showComponent = true;
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
	@track wiredResult = [];

	refresh(){
		this.loading = true;
		this.page=1;
		this.pageSize = 10;
		refreshApex(this.wiredResult).then(result => {
			this.loading = false;
		});
		//this.getLeadOpp();
	}
	
	connectedCallback(){
		this.loading = true;
		this.refresh();
		//this.getLeadOpp();
	}

	@wire(getLeadOpp, {recordId: '$recordId', objectName: '$filterObject', valid: '$filterField'})
	wiredGetRecords(result){
		this.wiredResult = result;
		let data = result.data;
		let error = result.error;
		if(data !== undefined) {
			this.columns = data.cols;
			let tempOppList = [];  
			for (var i = 0; i < data.data.length; i++) {
				let tempRecord = Object.assign({}, data.data[i]); //cloning object 
				tempRecord.leadoppLink = "/" + tempRecord.Id;
				tempRecord.leadoppLabel= tempRecord.Name;    
				tempRecord.ownerLabel = tempRecord.Owner.Name; 
				tempRecord.ownerLink = "/" + tempRecord.OwnerId;
				if(tempRecord.AV_Producto__c!=undefined && tempRecord.AV_Producto__c!=null){
					if(tempRecord.AV_Producto__r.Name!=null){
						tempRecord.Product2 = tempRecord.AV_Producto__r.Name; 
					}else{
						tempRecord.Product2 = ''; 
					}
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

			this.data=result.data;
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
			this.error = error;
			console.log(error);
		}
	}

	getLeadOppCopy(){
		getLeadOpp({id : this.recordId})
		.then(leadOpp => {
			if(leadOpp!=null){
				this.leadOpp=leadOpp;
				this.showLink=true;
			}
		})
	}

	/*getLeadOpp(){
		getLeadOpp({recordId: this.recordId, objectName: this.filterObject, valid: this.filterField})
			.then(result => {				
				if(result !== null) {
					this.columns = result.cols;
					let tempOppList = [];  
					for (var i = 0; i < result.data.length; i++) {
						let tempRecord = Object.assign({}, result.data[i]); //cloning object 
						tempRecord.leadoppLink = "/" + tempRecord.Id;
						tempRecord.leadoppLabel= tempRecord.Name;    
						tempRecord.ownerLabel = tempRecord.Owner.Name; 
						tempRecord.ownerLink = "/" + tempRecord.OwnerId;
						if(tempRecord.AV_Producto__c!=undefined && tempRecord.AV_Producto__c!=null){
							if(tempRecord.AV_Producto__r.Name!=null){
								tempRecord.Product2 = tempRecord.AV_Producto__r.Name; 
							}else{
								tempRecord.Product2 = ''; 
							}
						}

						/*if(tempRecord.AV_Lead__c!=undefined && tempRecord.AV_Lead__c!=null){
							if(tempRecord.AV_Lead__r.Name!=null){
								tempRecord.Lead = tempRecord.AV_Lead__r.Name; 
							}else{
								tempRecord.Lead = ''; 
							}
						}*//*

												
						tempOppList.push(tempRecord);
					}  
					this.records = tempOppList; 
					this.numRecords = result.data.length;
					this.iconName = result.icono;
					this.titleLabel = result.title;
					this.showTable = true;
					this.loading = false;
					this.recordsToDisplay = [];

					this.data=result.data;
					this.totalRecountCount = result.data.length;
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
				}
			})
			.then(/*this.highlightRow()*//*)
			.catch(error => {
				this.error = error;
				this.showComponent=false;
				console.log(error);
			});
	}*/
	

	handleSortdata(event) {
		const { fieldName: sortedBy, sortDirection } = event.detail;
		const cloneData = [...this.recordsToDisplay];
		const sortFieldName = this.columns.find(field=>sortedBy===field.fieldName).sortBy; 
		cloneData.sort(this.sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1));
		this.recordsToDisplay = cloneData;
		this.sortDirection = sortDirection;
		this.sortedBy = sortedBy;
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