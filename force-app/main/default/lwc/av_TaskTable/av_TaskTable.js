import { LightningElement, api, track, wire } from 'lwc';

//apex methods
import getRecords from '@salesforce/apex/AV_TaskTable_Controller.getRecords';

import { refreshApex } from '@salesforce/apex';

 
export default class av_TaskTable extends LightningElement{
    @api recordId;
    @api objectType;

    @track columns;
    @track recordsToDisplay = [];
    @track iconName;
    @track titleLabel;
    @track error;
    @track numRecords;
    @track loading = false;
    @track sortedBy;
    @track sortDirection = 'asc';
    @track defaultSortDirection = 'asc';
    @track showTable = false;
    @track isMultipagina = false;
    @track page = 1;
    @track pageSize = 10;
    @track optionsPage = [];

    wiredResult;

    @wire(getRecords, { recordId: '$recordId', objectType: '$objectType' })
    wiredGetRecords(result) {
        this.wiredResult = result;
    if (result.data) {
        const data = result.data;
        const error = result.error;
        if (data) {
            // Manipulaciones de datos
            this.columns = data.cols;
            const tempOppList = data.data.map(record => {
                const tempRecord = { ...record };
                tempRecord.subjectLink = `/${tempRecord.Id}`;
                tempRecord.subjectLabel = tempRecord.Subject;
                tempRecord.ownerLabel = tempRecord.Owner.Name;
                tempRecord.ownerLink = `/${tempRecord.OwnerId}`;
                if (tempRecord.Status === 'Pendiente' || tempRecord.Status === 'Pendiente no localizado' || tempRecord.CSBD_Evento_Estado__c === 'Pendiente') {
                    tempRecord.customClass = 'slds-text-title_bold';
                }
                return tempRecord;
            });
            this.records = tempOppList;
            this.numRecords = tempOppList.length;
            this.iconName = data.icono;
            this.titleLabel = data.title;
            this.showTable = true;
            this.loading = false;
            this.recordsToDisplay = [];
            this.totalRecountCount = tempOppList.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

            if (this.totalPage <= 1) {
                this.isMultipagina = false;
            } else {
                for (let i = 1; i <= this.totalPage; i++) {
                    this.optionsPage.push({ label: i.toString(), value: i });
                }
                this.isMultipagina = true;
            }

            this.displayRecordPerPage();
        }
        if (error) {
            console.error(error);
        }
    }
    }

    refresh() {
        this.loading = true;
        this.page = 1;
        this.pageSize = 10;
        refreshApex(this.wiredResult).then(() => {
            this.loading = false;
        });
    }

    handleSortdata({ detail: { fieldName, sortDirection } }) {
        const cloneData = [...this.recordsToDisplay];
        const sortFieldName = this.columns.find(col => col.fieldName === fieldName)?.sortBy;
        cloneData.sort(this.sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1));
        this.recordsToDisplay = cloneData;
        this.sortedBy = fieldName;
        this.sortDirection = sortDirection;
    }

    sortBy(field, reverse) {
        return function (a, b) {
            const aValue = a[field] || '';
            const bValue = b[field] || '';
            return (aValue.toLowerCase() > bValue.toLowerCase() ? 1 : -1) * reverse;
        };
    }

    handleChangePage(event) {
        this.page = event.detail.value;
        this.displayRecordPerPage();
    }

    displayRecordPerPage() {
        const startIndex = (this.page - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        this.recordsToDisplay = this.records.slice(startIndex, endIndex);
    }

    handleChangePageSize(event) {
        this.pageSize = event.detail.value;
        this.page = 1;
        this.displayRecordPerPage();
    }

    get optionsPageSize() {
        return [
            { label: '10', value: 10 },
            { label: '20', value: 20 },
            { label: '50', value: 50 },
            { label: '100', value: 100 }
        ];
    }
}