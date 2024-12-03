import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";

//Labels
import gc from '@salesforce/label/c.CIBE_GrupoComercial';
import nombre from '@salesforce/label/c.CIBE_NombreSimple';

//import
import gruposComerciales 	    from '@salesforce/apex/CIBE_GCFichaCli_Controller.gruposComerciales';

export default class cibe_GCFichaCli extends NavigationMixin(LightningElement) {
    
    labels = {
        gc,
        nombre
    };
   
    @track columns = [

        { label: this.labels.nombre,       fieldName: 'idGC',    sortable: true,       type: 'url',       cellAttributes: { alignment: 'left'},       typeAttributes: {label: {fieldName: 'nameGC'}, class:'slds-line-height_reset'}}
    ];
    

    @api recordId;
    @track dataValues = [];
    @track sortedBy;
    @track pageNumber = 0;
    @track totalPages = 0;
    @track pageData = [];

    @track isShowSpinner = true;

    @track sortByFieldName;
    @track sortByLabel;
    @track sortDirection;
    @track defaultSort = 'asc';

    @track _wiredData;
    @wire(gruposComerciales, { recordId : '$recordId' })
    getValues(wireResult) {
        const { data, error } = wireResult;
        this._wiredData = wireResult;
        if(data) {
            this.dataValues = data;
            this.pageNumber = 0;
            this.totalPages = this.dataValues.length > 0 ? (Math.ceil(this.dataValues.length/10)-1) : 0;
            this.updatePage();
            this.isShowSpinner = false;
        }else if(error) {
            this.isShowSpinner = false;
        }
    }

    handleSortData(event) {
        this.sortByFieldName = event.detail.fieldName;
        let sortField = event.detail.fieldName;
        for (let col of this.columns) {
            if (col.fieldName == this.sortByFieldName && col.type == 'url'){
                sortField = col.typeAttributes.label.fieldName;
            }
        }

        this.sortDirection = event.detail.sortDirection;

        this.sortData(sortField, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.dataValues));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;
        this.dataValues = parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });

        this.dataValues.forEach(e => {
            console.log(e.nameProduct);
        })

        this.updatePage();
    }    

    sortBy(field, reverse, primer) {
        const key = primer
        ? function(x) {
        return primer(x[field]);
        }
        : function(x) {
        return x[field];
        };return function(a, b) {
        a = key(a);
        b = key(b);
         return reverse * ((a > b) - (b > a));
        };
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