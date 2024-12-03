import { LightningElement, api, wire, track } from 'lwc';

import getRecords from '@salesforce/apex/CIBE_EventsFromGroupController.getRecords';



//labels
import cliente from '@salesforce/label/c.CIBE_Cliente';
import nombre from '@salesforce/label/c.CIBE_Nombre';
import tipoContacto from '@salesforce/label/c.CIBE_TipoContacto';
import fechaContacto from '@salesforce/label/c.CIBE_FechaContacto';
import asignado from '@salesforce/label/c.CIBE_Asignado';
import nOpoVinculadas from '@salesforce/label/c.CIBE_NOportunidadesVinculadas';
import nombreOppPrincipal from '@salesforce/label/c.CIBE_NombreOppPrincipal';
import citasGrupo from '@salesforce/label/c.CIBE_CitasGrupo';
import message from '@salesforce/label/c.CIBE_MesageEventFromGroup';
import verMas from '@salesforce/label/c.CIBE_VerMas';



export default class Cibe_EventsFromGroups extends LightningElement {

    labels = {
        cliente,
        nombre,
        tipoContacto,
        fechaContacto,
        asignado,
        nOpoVinculadas,
        nombreOppPrincipal,
        citasGrupo,
        message,
        verMas

    }

    columns = [
        { label: this.labels.cliente, fieldName: 'accountIdUrl', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'accountName' }, target: '_self' } },
        { label: this.labels.nombre, fieldName: 'idUrl', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'name' }, target: '_self' } },
        { label: this.labels.tipoContacto, fieldName: 'type', hideDefaultActions: true, type: 'text' },
        { label: this.labels.fechaContacto, fieldName: 'startDateTime', type: 'date', hideDefaultActions: true, sortable: 'true', cellAttributes: { alignment: 'right' } },
        { label: this.labels.asignado, fieldName: 'ownerIdUrl', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'owner' }, target: '_self' } },
        { label: this.labels.nOpoVinculadas, fieldName: 'numberOfOpps', type: 'text', hideDefaultActions: true, cellAttributes: { alignment: 'right' } },
        { label: this.labels.nombreOppPrincipal, fieldName: 'mainOppIdUrl', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'mainOpp' }, target: '_self' } }
    ];

    @api recordIds;

    @track events = [];
    @track isLoaded = false;
    @track offSet = 0;

    @wire(getRecords, { offSet: 0, recordIds: '$recordIds' })
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

        getRecords({ offSet: this.offSet, recordIds: this.recordIds })
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