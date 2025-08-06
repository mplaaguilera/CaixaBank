import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import NUMPERSO from '@salesforce/schema/Account.AV_NumPerso__c';
import retrieveData from '@salesforce/apex/AV_DetailExpCliente_Controller.retrieveData';

const columns = [
    { label: 'Momento', fieldName: 'momento', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Fecha momento', fieldName: 'momentoDate', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }},
    { label: 'Valoración', fieldName: 'valoracion', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Centro encuesta', fieldName: 'center', type: 'number', sortable: true, cellAttributes: { alignment: 'left' }},
    { label: 'Estado tarea', fieldName: 'status', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Fecha gestión tarea', fieldName: 'managementDate', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }},
    { label: 'Segunda encuesta', fieldName: 'secondSurvey', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }, wrapText: true}
];

export default class Av_DetailExpCliente extends LightningElement {
    @api recordId;
    numPerso;
    columns = columns;
    data = [{
        momento: null,
        momentoDate: null,
        valoracion: null,
        center: null,
        status: null,
        managementDate: null,
        secondSurvey: null
    }];
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    showSpinner = false;

    @wire(getRecord, { recordId: '$recordId', fields: [NUMPERSO] })
    customerData({error, data}) {
        if (data) {
            try {
                this.numPerso = data.fields.AV_NumPerso__c.value;
                this.enableSpinner();
                this.getData(this.numPerso);
            } catch (e) {
                this.numPerso = null;
            }
        } 
        else if (error) {
            console.log('error ====> ' + JSON.stringify(error))
        } 
    }
    
    getData(num) {
        retrieveData({numPerso: num})
            .then(result => {
                if (result != null) {
                    let parsedData = JSON.parse(result);
                    this.data = [];
                    for (let i = 0; i < parsedData.length; i++) {
                        this.data.push({
                            momento: parsedData[i].momento,
                            momentoDate: parsedData[i].momentoDate,
                            valoracion: parsedData[i].valoracion,
                            center: parsedData[i].center,
                            status: parsedData[i].status,
                            managementDate: parsedData[i].managementDate,
                            secondSurvey: parsedData[i].secondSurvey
                        });
                    }
                }
                this.disableSpinner();
            })
            .catch(error => {
				console.log(error);
                this.disableSpinner();
			})
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
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    enableSpinner(){
        this.showSpinner=true;
    }

    disableSpinner(){
        this.showSpinner=false;
    }
}