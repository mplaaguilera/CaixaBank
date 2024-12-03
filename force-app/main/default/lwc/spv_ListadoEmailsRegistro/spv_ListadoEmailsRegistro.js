import { LightningElement ,wire,track,api} from 'lwc';
import getAllEmails from '@salesforce/apex/SPV_LCMP_ListadoEmailsRegistro.getEmails';
import { refreshApex } from '@salesforce/apex';


export default class Spv_ListadoEmailsRegistro extends LightningElement {

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
    wiredEmails

    @wire(getAllEmails, {recordId: '$recordId'})
    wiredEmails(result) {
        this.wiredEmails =  result;

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

    handleRefreshClick() {        

        return refreshApex(this.wiredEmails);
    }
}