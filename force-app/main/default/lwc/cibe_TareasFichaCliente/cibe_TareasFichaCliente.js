import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";

//Labels
import tareas from '@salesforce/label/c.CIBE_Tareas';
import origen from '@salesforce/label/c.CIBE_Origen';
import asunto from '@salesforce/label/c.CIBE_Asunto';
import estado from '@salesforce/label/c.CIBE_Estado';
import fechaVencimiento from '@salesforce/label/c.CIBE_FechaDeVencimiento';
import asignadoA from '@salesforce/label/c.CIBE_AsignadoA';


//import
import tasksFichaCli from '@salesforce/apex/CIBE_TareasFichaCliente_Controller.tasksFichaCli';

export default class cibe_TareasFichaCliente extends NavigationMixin(LightningElement) {

    labels = {
        tareas,
        origen,
        asunto,
        estado,
        fechaVencimiento,
        asignadoA
    };

    @track columns = [

        { label: this.labels.origen, fieldName: 'origen', sortable: true, type: 'text', cellAttributes: { alignment: 'left' }, hideDefaultActions: true, initialWidth: 200 },
        { label: this.labels.asunto, fieldName: 'idTask', sortable: true, type: 'url', cellAttributes: { alignment: 'left' }, initialWidth: 250, hideDefaultActions: true, typeAttributes: { label: { fieldName: 'asunto' } } },
        { label: this.labels.estado, fieldName: 'estado', sortable: true, type: 'text', cellAttributes: { alignment: 'left' }, hideDefaultActions: true, initialWidth: 200 },
        { label: this.labels.fechaVencimiento, fieldName: 'fechaVencimiento', sortable: true, type: 'date', cellAttributes: { alignment: 'right' }, initialWidth: 300, hideDefaultActions: true, typeAttributes: { day: "2-digit", month: "2-digit", year: "numeric" } },
        { label: this.labels.asignadoA, fieldName: 'ownerId', sortable: true, type: 'url', cellAttributes: { alignment: 'left' }, initialWidth: 250, hideDefaultActions: true, typeAttributes: { label: { fieldName: 'ownerName' } } },


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
    @wire(tasksFichaCli, { recordId: '$recordId' })
    getValues(wireResult) {
        let dataWR = wireResult.data;
        let errorWR = wireResult.error;
        this._wiredData = wireResult;
        if (dataWR) {
            this.dataValues = dataWR;
            this.pageNumber = 0;
            this.totalPages = this.dataValues.length > 0 ? (Math.ceil(this.dataValues.length / 10) - 1) : 0;
            this.updatePage();
            this.isShowSpinner = false;
        } else if (errorWR) {
            this.isShowSpinner = false;
        }
    }

    handleSortData(event) {
        this.sortByFieldName = event.detail.fieldName;
        let sortField = event.detail.fieldName;
        for (let col of this.columns) {
            if (col.fieldName == this.sortByFieldName && col.type == 'url') {
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

        let isReverse = direction === 'asc' ? 1 : -1;
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
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            }; return function (a, b) {
                a = key(a);
                b = key(b);
                return reverse * ((a > b) - (b > a));
            };
    }

    updatePage() {
        this.pageData = this.dataValues.slice(this.pageNumber * 10, this.pageNumber * 10 + 10);
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
        if ((this.pageNumber + 1) <= this.totalPages) {
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
        return (this.pageNumber + 1);
    }

    get getTotalPageNumber() {
        return (this.totalPages + 1);
    }

}