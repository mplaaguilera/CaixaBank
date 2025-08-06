import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import NUMPERSO from '@salesforce/schema/Account.AV_NumPerso__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveData from '@salesforce/apex/CIBE_DetailExpCliente_Controller.retrieveData';

const columns = [
    { label: 'Momento', fieldName: 'momento', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Fecha momento', fieldName: 'momentoDate', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }},
    { label: 'Valoración', fieldName: 'valoracion', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }, wrapText: true},
    { label: 'Centro encuesta', fieldName: 'center', type: 'number', sortable: true, cellAttributes: { alignment: 'left' }},   
    {
        label: 'Estado Tarea',
        type: 'url',
        fieldName: 'taskId',
        typeAttributes: {
            label: { fieldName: 'status' },
            target: '_blank',
            tooltip: 'Ver Tarea'
        },
        cellAttributes: { alignment: 'left' }
    },
    { label: 'Fecha gestión tarea', fieldName: 'managementDate', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }},
    { label: 'Segunda encuesta', fieldName: 'secondSurvey', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }, wrapText: true}
];

export default class cibe_DetailExpCliente extends LightningElement {
    @api recordId;
    @track numPerso;
    @track columns = columns;
    @track data = [{
        momento: null,
        momentoDate: null,
        valoracion: null,
        center: null,
        status: null,
        taskId: null,
        managementDate: null,
        secondSurvey: null
    }];
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    @track showSpinner = false;

    @wire(getRecord, { recordId: '$recordId', fields: [NUMPERSO] })
    customerData({error, data}) {
        if (data) {
                this.numPerso = data.fields.AV_NumPerso__c.value;
                this.enableSpinner();
                this.getData(this.numPerso, this.recordId);
        } 
        else if (error) {
            console.log('error ====> ' + JSON.stringify(error))
        } 
    }
    connectedCallback() {
        
    }
    getData(num, recordId) {
        retrieveData({numPerso: num, recordId: this.recordId})
            .then(result => {
                if (result != null) {
                    let parsedData = JSON.parse(result);
                    this.data = [];
                    for (let i = 0; i < parsedData.length; i++) {
                        const row = {
                            momento: parsedData[i].momento,
                            momentoDate: parsedData[i].momentoDate,
                            valoracion: parsedData[i].valoracion,
                            center: parsedData[i].center,
                            status: parsedData[i].status,
                            taskId: parsedData[i].taskId != null ? '/' + parsedData[i].taskId : null,
                            managementDate: parsedData[i].managementDate,
                            secondSurvey: parsedData[i].secondSurvey
                            
                        };
                        row['Estado Tarea'] = parsedData[i].taskId != null
                        ? { type: 'url', value: row.taskId , label: parsedData[i].status }
                        : { type: 'text', value: '' }; 
                        this.data.push(row);
                    }
                }
                this.disableSpinner();
            })
            .catch(error => {
                console.error(error);
                this.disableSpinner();
			})
    }
    enableSpinner(){
        this.showSpinner=true;
    }

    disableSpinner(){
        this.showSpinner=false;
    }
}