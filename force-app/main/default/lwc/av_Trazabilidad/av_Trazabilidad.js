import { LightningElement, api, track} from 'lwc';

import retrieveCustomerTrackings from '@salesforce/apex/AV_Trazabilidad_Controller.retrieveCustomerTrackings';

const active = [
    { label: 'Fecha inicio', fieldName: 'startPetitionDate', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Fecha última act.', fieldName: 'endDatePetition', type: 'text', sortable: false, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Petición/proceso', fieldName: 'processUrl', type: 'button', typeAttributes: { label: { fieldName: 'process' }, wrapText: true, variant: 'base'}},
    { label: 'Ámbito', fieldName: 'ambit', type: 'text', sortable: false, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Paso', fieldName: 'step', type: 'text', sortable: false, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Estado', fieldName: 'state', type: 'text', sortable: false, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Empleado/a', fieldName: 'employee', type: 'text', sortable: false, cellAttributes: { alignment: 'left' }, wrapText: true}
];

const background = [
    { label: 'Fecha inicio', fieldName: 'startPetitionDate', type: 'text', sortable: false, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Fecha cierre', fieldName: 'endDatePetition', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Petición/proceso', fieldName: 'process', type: 'text', sortable: false, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Gestor', fieldName: 'manager', type: 'text', sortable: false, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Estado', fieldName: 'state', type: 'text', sortable: false, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Ámbito', fieldName: 'ambit', type: 'text', sortable: false, cellAttributes: { alignment: 'left' }, wrapText: true}
];

export default class av_Trazabilidad extends LightningElement {
	error;
	@api recordId;  
    @api tipoTabla;

    @track pagekey = 1;
    @track moreElements;
    @track items;
    @track key;
    @track columns = active;
    @track data = [{
        startPetitionDate: null ,
        endDatePetition: null,
        endDatePetition: null,
        process: null,
        processUrl: null,
        ambit: null,
        step: null,
        state: null,
        employee: null,
        manager: null
    }];
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    @track showSpinner = false;
    @track isMultipagina = false;
    @track pageLoggin = [];
    @track nextPage = true;
    @track goBack = true;
    @track nPage;
    @track lastPage = 1;
	
	connectedCallback() {
        this.enableSpinner();
        this.getTableType();
		this.getData();
	}

    getTableType(){
        if (this.tipoTabla  == 'A') {
            this.columns = active;
        } else if (this.tipoTabla == 'H') {
            this.columns = background;
        }
    }
   

	getData() {
		retrieveCustomerTrackings({tableType: this.tipoTabla, recordId: this.recordId, pagekey: this.pagekey})
			.then(result => {
				if (result != null){
                    this.moreElements = result.moreElements;
                    let parsedData = JSON.parse(result.response);

                    this.pageLoggin.push(this.pagekey);

                    for (let i = 0; i < parsedData.length; i++) {
                        this.data.push({
                            startPetitionDate: parsedData[i].startPetitionDate,
                            endDatePetition: parsedData[i].endDatePetition,
                            endDatePetition: parsedData[i].endDatePetition,
                            process: parsedData[i].process,
                            processUrl: parsedData[i].processUrl,
                            ambit: parsedData[i].ambit,
                            step: parsedData[i].step,
                            state: parsedData[i].state,
                            employee: parsedData[i].employee,
                            manager: parsedData[i].manager
                        });
                    }
                    if (this.tipoTabla == 'A') {
                        this.data.sort((a, b) => {
                            let da = new Date(a.startPetitionDate),
                            db = new Date(b.startPetitionDate);
                            return db - da; 
                        });
                    } else if (this.tipoTabla == 'H') {
                        this.data.sort((a, b) => {
                            let da = new Date(a.endDatePetition),
                            db = new Date(b.endDatePetition);
                            return db - da; 
                        });
                    } 

                    this.items = this.data.slice((this.pagekey-1)*25,25*this.pagekey);

                    if (this.moreElements.equals('S') && this.pagekey.equals(1)) {
                        this.isMultipagina = true;
                    } 

                    if (this.moreElements == 'N') {

                        if (this.lastPage.equals(1)) {
                            this.nPage = this.pagekey;
                            this.lastPage = this.lastPage + 1;
                        }
                        if (this.nPage == this.pagekey) {
                            this.nextPage = false;
                        } else {
                            this.nextPage = true;
                        }
                    } else {
                        this.nextPage = true;
                    }
                    
                    if (this.pagekey.equals(1)) {
                        this.goBack = false;
                    } else {
                        this.goBack = true;
                    }

					this.disableSpinner();
				} 
			})
			.catch(error => {
				console.log(error);
                this.disableSpinner();
			});
	}

    sortBy(field, reverse, first) {
         key = first
            ? function (x) {
                  return first(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort() {
        const cloneData = [...this.data];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = this.cloneData;
        this.sortDirection = this.sortDirection;
        this.sortedBy = this.sortedBy;
    }

    enableSpinner(){
        this.showSpinner=true;
    }

    disableSpinner(){
        this.showSpinner=false;
    }

    nextHandler(){
        this.pagekey = this.pagekey + 1 ;
        if (this.pageLoggin.includes(this.pagekey)) {
            if (this.moreElements == 'N') {
                if (this.nPage == this.pagekey) {
                    this.nextPage = false;
                } else {
                    this.nextPage = true;
                }
            } else {
                this.nextPage = true;
            }
            if (this.pagekey.equals(1)) {
                this.goBack = false;
            } else {
                this.goBack = true;
            }
            this.items = this.data.slice((this.pagekey-1)*25,25*this.pagekey);
        } else {
            this.enableSpinner();
            this.getData();
        }
    }

    previousHandler(){
        this.pagekey = this.pagekey - 1 ;
        if (this.pageLoggin.includes(this.pagekey)) {
            if (this.moreElements == 'N') {
                if (this.nPage == this.pagekey) {
                    this.nextPage = false;
                } else {
                    this.nextPage = true;
                }
            } else {
                this.nextPage = true;
            }
            if (this.pagekey.equals(1)) {
                this.goBack = false;
            } else {
                this.goBack = true;
            }
            this.items = this.data.slice((this.pagekey-1)*25,25*this.pagekey);
        } else {
            this.enableSpinner();
            this.getData();
        }
    }

    callRowAction(event) {  
        const selectedRow = event.detail.row.processUrl;
        window.location.assign(selectedRow);
    }  
}