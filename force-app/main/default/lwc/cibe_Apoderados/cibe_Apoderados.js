import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";

//Labels
import apoderados from '@salesforce/label/c.CIBE_Apoderados';
import identificador from '@salesforce/label/c.CIBE_Identificador';
import cargo from '@salesforce/label/c.CIBE_Cargo';
import fechaVencimiento from '@salesforce/label/c.CIBE_FechaDeVencimiento';
import datosEscritura from '@salesforce/label/c.CIBE_DatosEscritura';

//import
import getRecords 	    from '@salesforce/apex/CIBE_Apoderados_Controller.getRecords';
import getRecordType    from '@salesforce/apex/CIBE_Apoderados_Controller.getRecordType';

export default class Cibe_Apoderados extends LightningElement {
    
    labels = {
        apoderados,
        identificador,
        cargo,
        fechaVencimiento,
        datosEscritura
    }

    @track columns = [
        { label: this.labels.apoderados,        fieldName: 'showContactRecord',     type: 'url',    sortable: true,     initialWidth : 350,     typeAttributes: { label: { fieldName: "name" } }, target: '_blank' },
        { label: this.labels.identificador,     fieldName: 'identificador',         type: 'text'    },
        { label: this.labels.cargo,             fieldName: 'rol',                   type: 'text'    },
        { label: this.labels.fechaVencimiento,  fieldName: 'vencimiento',           type: 'date'    },
        { label: this.labels.datosEscritura,    fieldName: 'escritura',             type: 'text'    }
    ];

    @api recordId;
    @track dataValues = [];

    @track pageNumber = 0;
    @track totalPages = 0;
    @track pageData = [];

    @track isShowSpinner = true;

    @track sortBy;
    @track sortDirection;
    @track defaultSort = 'asc';

    @track recordTypeId;
    @wire(getRecordType)
    getRecordTypes(wireResult) {
        const { data, error } = wireResult;
        if(data){
            this.recordTypeId = data;
        }else if(error) {
            console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
        }
    }

    @track _wiredDataButton;


    @track _wiredData;
    @wire(getRecords, { recordId : '$recordId' })
    getValues(wireResult) {
        const { data, error } = wireResult;
        this._wiredData = wireResult;
        console.log(this.recordId);
        console.log(data);
        if(data){
            this.dataValues = this.sortData(data, 'name', 'asc');
            this.pageNumber = 0;
            this.totalPages = this.dataValues.length > 0 ? (Math.ceil(this.dataValues.length/10)-1) : 0;
            this.updatePage();
        }else if(error) {
            console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
        }
        this.isShowSpinner = false;
    }

    handleSortData(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.dataValues = this.sortData(this.dataValues, event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(data, field, direction) {
        let fieldName = field;
        let dataToSort = [...data];
        let keyValue = (a) => {
            return a[fieldName];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        dataToSort.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        return dataToSort;
    }

    updatePage() {
        this.pageData = this.dataValues.slice(this.pageNumber*10, this.pageNumber*10+10);
    }
    
    previous() {
        this.pageNumber = Math.max(0, this.pageNumber - 1);
        this.updatePage();
    }
    
    first() {
        this.pageNumber = 0;
        this.updatePage();
    }
    
    next() {
        if((this.pageNumber+1)<=this.totalPages) {
            this.pageNumber = this.pageNumber + 1;
            this.updatePage();
        }
    }
    
    last() {
        this.pageNumber = this.pageNumber = this.totalPages;
        this.updatePage();
    }

    refresh(event) {
        this.isShowSpinner = true;
        refreshApex(this._wiredData)
            .finally(() => {
                this.isShowSpinner = false;
            });
    }

    get getPageNumber() {
        return (this.pageNumber+1);
    }

    get getTotalPageNumber() {
        return (this.totalPages+1);
    }

}