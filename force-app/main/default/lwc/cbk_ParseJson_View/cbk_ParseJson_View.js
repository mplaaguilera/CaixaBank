import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getStringComment from '@salesforce/apex/CBK_LWC_Controller_ParseJson.getStringbyRecordId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
 
export default class Cbk_ParseJson_View extends LightningElement { 
    @api recordId;
    @track vFieldName;
    @track data = [];
    @track isdata = [];
    @track result = [];
    @track launchModal = true;
    @track mapData= [];
    @api inputField;
	@track filteredData = [];
	@track sortBy;
	@track sortDirection;
	result;

	@api inputPageSize;
	@track page = 1; 
    @track items = []; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize;
    @track totalRecountCount = 0;
    @track totalPage = 0;

	@api searchKey = '';

	@track columns =[{ label: 'Name', fieldName: 'key', sortable: "true"},{ label: 'Value', fieldName: 'value', sortable: "true"}];

	@wire(getStringComment, { recordId: '$recordId', vFieldName: '$inputField', searchKey: '$searchKey'})
	userbegetStringComment({ data }) {
		var conts = [];
		this.vFieldName = this.inputField;
		this.pageSize = this.inputPageSize;
		this.mapData = [];

        if (data != null) {

			this.result = data;
			this.conts = this.result;
                    
            if (this.conts != null)
            {
                this.isdata.push(this.conts);
                if (this.isdata.length > 0)
                {
                    for(var key in this.conts){   
                        this.mapData.push({value:this.conts[key], key:key});
                    }
					this.data = this.mapData;
					this.items = this.data;
					this.totalRecountCount = this.data.length;
					this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 

					this.data = this.items.slice(0,this.pageSize); 
					this.endingRecord = this.pageSize;
					this.columns = this.columns;

					if (this.data.length <= 0) {this.launchModal = false;}else {this.launchModal = true}
				
                }else{
					this.launchModal = false;
				}
            }
        }
	 }
    
	 handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
	sortData(fieldname, direction) {
		if(fieldname != undefined && direction !=undefined)
		{
			let parseData = JSON.parse(JSON.stringify(this.data));

			// Return the value stored in the field
			let keyValue = (a) => {
				return a[fieldname];
			};

			let isReverse = direction === 'asc' ? 1: -1;

			// sorting data 
			parseData.sort((x, y) => {
				x = keyValue(x) ? keyValue(x) : ''; // handling null values
				y = keyValue(y) ? keyValue(y) : '';

				return isReverse * ((x > y) - (y > x));
			});

			this.data = parseData;
		}
    }

	//clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }
	//clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

	//this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }    

	 handleKeyChange(event) {
        this.searchKey = event.target.value;
        return refreshApex(this.result);

    }

/* handleSelect(event){	
		this.selectedRecords = this.template.querySelector('lightning-datatable').selectedRows;
		const passEvent = new CustomEvent('selection', {
            detail:{seletedRows:this.selectedRecords} 
        });
       this.dispatchEvent(passEvent);
	}*/
 
}