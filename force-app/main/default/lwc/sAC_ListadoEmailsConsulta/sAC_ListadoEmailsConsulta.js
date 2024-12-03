import { LightningElement ,wire,track,api} from 'lwc';
import getAllemails from '@salesforce/apex/SAC_LCMP_ListadoEmailsConsulta.getEmailsConsulta';

export default class SAC_ListadoEmailsConsulta extends LightningElement {

    @api recordId
    @track columns = [
        {
            label: 'Asunto',
            fieldName: 'nameUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Subject' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'De',
            fieldName: 'FromAddress',
            type: 'text',
            sortable: true
        },
        {
            label: 'Para',
            fieldName: 'ToAddress',
            type: 'text',
            sortable: true
        },
        {
            label: 'Fecha de Creación',
            fieldName: 'CreatedDate',
            type: 'date',
            sortable: true
        }
    ];

    @track error;
    @track emails = [];

    @wire(getAllemails, {recordId: '$recordId'})
    wiredEmails(result) {
        const {data, error } = result;
        if(data) {
            let nameUrl;
            this.emails = data.map(row => { 
                nameUrl = `/${row.Id}`;
                return {...row , nameUrl} 
            })
            this.error = null;
        }
        if(error) {
            this.error = error;
            this.emails = [];
        }
    }
}