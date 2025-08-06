import { LightningElement, api,track, wire } from 'lwc';
import getRecordSObject from '@salesforce/apex/SEG_dataTable_Controller.retriveRecords';

export default class DataTable extends LightningElement {
    data = [];
    @api columns = [];
	@api recordId;
	@api query;
	@api preSelectedIds = [];
	@api selectedRecords = [];
	@api selectedAll = false;
	@track sortBy;
	@track sortDirection;


	@wire(getRecordSObject,{sQuery: '$query',recordId: '$recordId'})
    wiredRecords({ error, data }) {
		let x =  this.query;
        if (data) {
			this.data = JSON.parse(JSON.stringify(data));
			this.columns = eval(this.columns);
			this.data.forEach(row => {
				for(const col in row){
					const curCol = row[col];
					if(typeof curCol === 'object'){
						const newVal = curCol.Id ? ('/' + curCol.Id) : null;
						this.flattenStructure(row, col + '_', curCol);
						if(newVal === null){
							delete row[col];
						}else {
							row[col] = newVal;
						}
					}
				}
			});
			this.data = this.data.map(row => { 
                row.Id_r = `/${row.Id}`;
                return {...row} 
            });
			this.selectedRecords = this.preSelectedIds;
			if(this.selectedAll){
				this.selectedRecords = this.data.map(record=>record.Id);
				const passEvent = new CustomEvent('selection', {
					detail:{seletedRows:this.selectedRecords} 
				});
			   this.dispatchEvent(passEvent);
			}
            this.allData = this.data;
        } else if (error) {
			console.log(JSON.stringify(error));
            this.error = error;
            this.data = undefined;
        }
    }

	flattenStructure(topObject, prefix, toBeFlattened) {
		for (const prop in toBeFlattened) {
			const curVal = toBeFlattened[prop];
			if (typeof curVal === 'object') {
				this.flattenStructure(topObject, prefix + prop + '_', curVal);
			} else {
				topObject[prefix + prop] = curVal;
			}
		}
	}
	handleSelect(event){	
		this.selectedRecords = this.template.querySelector('lightning-datatable').selectedRows;
		const passEvent = new CustomEvent('selection', {
            detail:{seletedRows:this.selectedRecords} 
        });
       this.dispatchEvent(passEvent);
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
}