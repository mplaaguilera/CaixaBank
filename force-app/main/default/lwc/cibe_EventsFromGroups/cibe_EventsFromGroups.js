import { LightningElement, api, wire, track } from 'lwc';

import getRecords from '@salesforce/apex/CIBE_EventsFromGroupController.getRecords';

const columns = [
    { label: 'Cliente', fieldName: 'accountIdUrl', type: 'url', typeAttributes: { label: { fieldName: 'accountName' }, target: '_self' } },
    { label: 'Nombre', fieldName: 'idUrl', type: 'url', typeAttributes: {label: { fieldName: 'name' }, target: '_self' }},
    { label: 'Tipo contacto', fieldName: 'type', type: 'text' },
    { label: 'Fecha contacto', fieldName: 'startDateTime',  type: 'date', sortable: 'true', cellAttributes: { alignment: 'right' }},
    { label: 'Asignado a', fieldName: 'ownerIdUrl', type: 'url', typeAttributes: { label: { fieldName: 'owner' }, target: '_self' } },
    { label: 'Nº oport. vinculadas', fieldName: 'numberOfOpps', type: 'text', cellAttributes: { alignment: 'right' }},
    { label: 'Nombre oport. principal', fieldName: 'mainOppIdUrl', type: 'url', typeAttributes: {label: { fieldName: 'mainOpp' }, target: '_self'}}
];

export default class Cibe_EventsFromGroups extends LightningElement {

    @api recordIds;

    @track events = [];
    @track columns = columns;
    @track isLoaded = false;
    @track offSet = 0;

    @wire(getRecords, { offSet : 0, recordIds : '$recordIds' })
    getRecordsData({ error, data }) {
        if (data) {
            this.offSet = 0;
            this.events = JSON.parse(JSON.stringify(data));

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
                const events = this.events;
                this.events = events.concat(data);
            })
            .catch(error => {
                console.log(error);
            })
            .finally(() => {
                this.isLoaded = true;
            });
    }

    get getViewMore() {
        return (this.offSet >= 2000 || (this.events !== null && this.events !== undefined && (this.events.length % 10 !== 0)));
    }

    get height() {
        return (this.events !== undefined && this.events !== null && this.events.length > 10) ? 'height: 295px' : '';
    }

    get empty() {
        return (this.events !== undefined && this.events !== null && this.events.length == 0);
    }

    throwRefreshEvent() {
        this.dispatchEvent(new CustomEvent('loaded', {}));
    }
}