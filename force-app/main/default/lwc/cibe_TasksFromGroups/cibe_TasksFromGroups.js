import { LightningElement , api, wire, track} from 'lwc';

import getRecords from '@salesforce/apex/CIBE_TasksFromGroupsController.getRecords';

const columns = [
    { label: 'Cliente', fieldName: 'accountIdUrl', type: 'url', typeAttributes: { label: { fieldName: 'accountName' }, target: '_self' } },
    { label: 'Nombre', fieldName: 'idUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_self' } },
    { label: 'Estado', fieldName: 'status', type: 'text' },
    { label: 'Fecha de vencimiento', fieldName: 'activityDate',  type: 'date', sortable: 'true', cellAttributes: { alignment: 'right' } },
    { label: 'Asignado a', fieldName: 'ownerIdUrl', type: 'url', typeAttributes: { label: { fieldName: 'owner' }, target: '_self' } },
    { label: 'Origen', fieldName: 'recordType', type: 'text' }
];

export default class cibe_TasksFromGroups extends LightningElement {

    @api recordIds;

    @track tasks = [];
    @track columns = columns;
    @track isLoaded = false;
    @track offSet = 0;

    @wire(getRecords, { offSet : 0, recordIds : '$recordIds' })
    getRecordsData({ error, data }) {
        if (data) {
            this.offSet = 0;
            this.tasks = JSON.parse(JSON.stringify(data));
            
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
                const tasks = this.tasks;
                this.tasks = tasks.concat(data);
            })
            .catch(error => {
                console.log(error);
            })
            .finally(() => {
                this.isLoaded = true;
            });
    }

    get getViewMore() {
        return (this.offSet >= 2000 || (this.tasks !== null && this.tasks !== undefined && (this.tasks.length % 10 !== 0)));
    }

    get height() {
        return (this.tasks !== undefined && this.tasks !== null && this.tasks.length > 10) ? 'height: 295px' : '';
    }

    get empty() {
        return (this.tasks !== undefined && this.tasks !== null && this.tasks.length == 0);
    }

    throwRefreshEvent() {
        this.dispatchEvent(new CustomEvent('loaded', {}));
    }
}