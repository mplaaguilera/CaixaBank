import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import findCases from '@salesforce/apex/CC_Busqueda_ALF_Controller.buscarCasos';

// Declaring the columns in the datatable
const columns = [/*{
    label: 'Ver',
    type: 'button-icon',
    initialWidth: 75,
    typeAttributes: {
        iconName: 'action:preview',
        title: 'Preview',
        variant: 'border-filled',
        alternativeText: 'View'
        }
    },*/
    {
        label: 'Caso',
        fieldName: 'caseNumberUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {label: {fieldName: "caseNumber"}, }//target: '_blank'
    },
    {
        label: 'Estado',
        fieldName: 'status',
        sortable: true
    },
    {
        label: 'Canal entrada',
        fieldName: 'origin',
        sortable: true
    },
    {
        label: 'Asunto',
        fieldName: 'subject',
        sortable: true
    }
];
 
// declare class to expose the component
//export default class DataTableComponent extends NavigationMixin(LightningElement) {
export default class DataTableComponent extends LightningElement {
    @api recordId;
    @track columns = columns;
    @track record = {};
    @track rowOffset = 0;
    @track data = [];
    @track bShowModal = false;
    @wire (findCases, {personId: '$recordId' }) parameters;

    
    
    // Row Action event to show the details of the record
    handleRowAction(event) {
        const row = event.detail.row;
        this.record = row;
        //this.bShowModal = true; // display modal window
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Case',
                actionName: 'view',
            }
        });
    }
    /*handleRowAction(event) {
        const row = event.detail.row;
        this.record = row;
        this.bShowModal = true; // display modal window
    }
 
    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    }

    handleContactView(event) {
        // Navigate to case record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Case',
                actionName: 'view',
            },
        });
    }*/
    
}