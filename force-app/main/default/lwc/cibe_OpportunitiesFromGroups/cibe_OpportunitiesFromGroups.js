import { LightningElement , api, wire, track} from 'lwc';

import getRecords from '@salesforce/apex/CIBE_OpportunitiesFromGroupsController.getRecords';

const columns = [
    { label: 'Cliente', fieldName: 'accountIdUrl', type: 'url', typeAttributes: { label: { fieldName: 'accountName' }, target: '_self' } },
    { label: 'Nombre', fieldName: 'idUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_self' } },
    { label: 'Etapa', fieldName: 'stageName', type: 'text' },
    { label: 'Producto', fieldName: 'product', type: 'text' },
    { label: 'Importe', fieldName: 'amount', type: 'currency' , typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 0 }, cellAttributes: { alignment: 'right' }},
    { label: 'Fecha cierre', fieldName: 'closeDate', type: 'date', sortable: 'true', cellAttributes: { alignment: 'right' } },
    { label: 'Fecha próxima gestión', fieldName: 'nextManagementDate', type: 'date', cellAttributes: { alignment: 'right' } },
    { label: 'Probabilidad de éxito', fieldName: 'probability', type: 'text'},
    { label: 'Propietario', fieldName: 'ownerIdUrl', type: 'url', typeAttributes: { label: { fieldName: 'owner' }, target: '_self' } }
];

export default class Cibe_OpportunitiesFromGroups extends LightningElement {
    
    @api recordIds;
    
    @track opportunities = [];
    @track columns = columns;
    @track isLoaded = false;
    @track offSet = 0;

    @wire(getRecords, { offSet : 0, recordIds : '$recordIds' })
    getRecordsData({ error, data }) {
        if (data) {
            this.offSet = 0;
            this.opportunities = JSON.parse(JSON.stringify(data));

            this.isLoaded = true;
            this.throwRefreshEvent();
        } else if (error) {
            console.log(error);
        }
    }

    viewMore() {
        this.isLoaded = false;
        this.offSet = (this.offSet <= 1990) ? (this.offSet + 10) : this.offSet;

        getRecords({ offSet : this.offSet, recordIds : this.recordIds })
            .then((data) => {
                const opportunities = this.opportunities;
                this.opportunities = opportunities.concat(data);
            })
            .catch(error => {
                console.log(error);
            })
            .finally(() => {
                this.isLoaded = true;
            });
    }

    get getViewMore() {
        return (this.offSet >= 2000 || (this.opportunities !== null && this.opportunities !== undefined && (this.opportunities.length % 10 !== 0)));
    }

    get height() {
        return (this.opportunities !== undefined && this.opportunities !== null && this.opportunities.length > 10) ? 'height: 295px' : '';
    }

    get empty() {
        return (this.opportunities !== undefined && this.opportunities !== null && this.opportunities.length == 0);
    }

    throwRefreshEvent() {
        this.dispatchEvent(new CustomEvent('loaded', {}));
    }
}