import { LightningElement, api, track, wire} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import recuperarCorreo from '@salesforce/apex/OS_CorreosElectronicos_Controller.recuperarCampos';


const columns = [
    //{ label: 'Asunto', fieldName: 'asunto', type: 'text', sortable: true},
    {label: 'Asunto', fieldName: 'nameUrl', type: 'url', sortable: true,
            typeAttributes: {label: { fieldName: 'asunto' }, target: '_self', tooltip: { fieldName: 'asunto' }}},
    { label: 'Dirección De', fieldName: 'de', type: 'text', sortable: true},
    { label: 'Dirección Para', fieldName: 'para', type: 'text', sortable: true},
    { label: 'Fecha del mensaje', fieldName: 'fecha', type: 'text', sortable: true},
    { label: 'Estado', fieldName: 'estado', type: 'text', sortable: true},
    {
        fieldName: 'HasAttachment',
        label: 'Adjuntos',
        sortable: true,
        cellAttributes: { alignment: 'center' ,iconName: { fieldName: 'iconoAdjuntos', iconPosition: 'center'},
        width: 105 }
    }
];



export default class OS_Correos_Electronicos extends LightningElement {
    @track error;


    @api recordId;
    @track correos;
    @track tieneCorreos = false;

    

    @track sorted_by = 'fecha';
    @track sorted_direction = 'desc';
    result;

    @wire(recuperarCorreo, {
        caseId: '$recordId' ,
        campo: '$sorted_by',
        orden: '$sorted_direction'       
    })wiredAccounts({ error, data }) {
        if (data) {
            this.correos = data;
            this.columns = columns;
            this.error = undefined;
            if (data.length > 0) {
                this.tieneCorreos = true;
            }
           
        } else if (error) {
            this.error = error;
            this.correos = undefined;
        }
    }


    sortColumns( event ) {
        this.sorted_by = event.detail.fieldName;
        this.sorted_direction = event.detail.sortDirection;
        return refreshApex(this.result);
    }

    
    
    

    
}