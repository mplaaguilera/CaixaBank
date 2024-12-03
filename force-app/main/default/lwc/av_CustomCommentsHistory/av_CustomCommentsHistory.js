import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getRecords from '@salesforce/apex/AV_CustomCommentsHistory_Controller.getRecords';

export default class av_CustomCommentsHistory extends LightningElement {
    @api recordId;
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
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track pageNumber = 1;
    //Paginación
    @track totalPage = 0;
    @track pageSize = 10;
    @track page = 1;
    @track isMultipagina = true;
    @track isMultiEntry2 = false;
    @track filterProduct;
    @track data;
    @track totalRecountCount;
    @track optionsPage = [];
    @track wiredResult;

    refresh() {
        this.loading = true;
        this.page = 1;
        this.pageSize = 10;
        refreshApex(this.wiredResult).then(result => {
            this.loading = false;
        });
    }

    connectedCallback() {
        this.loading = true;
        this.refresh();
    }

    @wire(getRecords, { recordId: '$recordId' })
    wiredGetRecords(result) {
        this.wiredResult = result;
        if (result.data) {
            this.columns = result.data.cols.map(col => {
                if (col.fieldName === 'AV_NewComment__c') {
                    return { ...col, wrapText: true };
                }
                return col;
            });

            let tempOppList = [];

            result.data.data.forEach(record => {
                let tempRecord = {
                    ...record,
                    subjectLink: "/" + record.Id,
                    subjectLabel: record.Subject,
                    ownerLabel: record.AV_AssignedEmployee__r?.Name,
                    ownerLink: "/" + record.AV_AssignedEmployee__c,
                    CreatedDate: this.formatDate(record.CreatedDate)
                };
                tempOppList.push(tempRecord);
            });

            this.records = tempOppList;
            this.numRecords = tempOppList.length;
            this.iconName = result.data.icono;
            this.titleLabel = result.data.title;
            this.showTable = true;
            this.loading = false;

            this.totalRecountCount = tempOppList.length;
            this.totalPage = Math.ceil(
                this.totalRecountCount / this.pageSize
            );

            if (this.totalPage <= 1) {
                this.isMultipagina = false;
            } else {
                for (let i = 1; i < this.totalPage + 1; i++) {
                    var aux = { label: i.toString(), value: i };
                    this.optionsPage.push(aux);
                }
                this.isMultipagina = true;
            }

            this.displayRecordPerPage(this.page);
        } else if (result.error) {
            console.error(result.error);
        }
    }

    formatDate(dateString) {
        const options = { day: '2-digit', month: 'short', year: 'numeric' };
        const date = new Date(dateString);
        return date.toLocaleDateString('es-ES', options);
    }

    handleSortdata(event) {
        const fieldName = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
    
        const sortFieldName = this.columns.find(
            field => fieldName === field.fieldName
        ).sortBy;
    
        this.recordsToDisplay.sort(this.sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1));
    
        this.sortDirection = sortDirection;
        this.sortedBy = fieldName;
    
        refreshApex(this.wiredResult);
    }
    

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            var result;
            if (a == null) {
                result = 1;
            } else if (b == null) {
                result = -1;
            } else {
                result = reverse * (
                    (a.toLowerCase() > b.toLowerCase()) - (b.toLowerCase() > a.toLowerCase())
                );
            };
            return result;
        }
    }

    displayRecordPerPage(page) {
        this.recordsToDisplay = [];

        for (let i = (page - 1) * this.pageSize; i < page * this.pageSize; i++) {
            if (this.records[i] != null) {
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
        this.page = 1;
        this.optionsPage = [];
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        for (let i = 1; i < this.totalPage + 1; i++) {
            var aux = { label: i.toString(), value: i };
            this.optionsPage.push(aux);
        }
        this.displayRecordPerPage(this.pageNumber);
    }
}