import { LightningElement, api, wire, track } from 'lwc';

import getRecords from '@salesforce/apex/CIBE_TasksFromGroupsController.getRecords';




//labels
import cliente from '@salesforce/label/c.CIBE_Cliente';
import nombre from '@salesforce/label/c.CIBE_Nombre';
import estado from '@salesforce/label/c.CIBE_Estado';
import fechaVencimiento from '@salesforce/label/c.CIBE_FechaDeVencimiento';
import asignado from '@salesforce/label/c.CIBE_Asignado';
import origen from '@salesforce/label/c.CIBE_Origen';
import message from '@salesforce/label/c.CIBE_MessageTaskFromGroups';
import verMas from '@salesforce/label/c.CIBE_VerMas';
import tareasGrupo from '@salesforce/label/c.CIBE_TareasGrupo';


export default class cibe_TasksFromGroups extends LightningElement {

    labels = {
        cliente,
        nombre,
        estado,
        fechaVencimiento,
        asignado,
        origen,
        message,
        verMas,
        tareasGrupo
    }


    columns = [
        { label: this.labels.cliente, fieldName: 'accountIdUrl', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'accountName' }, target: '_self' } },
        { label: this.labels.nombre, fieldName: 'idUrl', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'name' }, target: '_self' } },
        { label: this.labels.estado, fieldName: 'status', type: 'text', hideDefaultActions: true, },
        { label: this.labels.fechaVencimiento, fieldName: 'activityDate', type: 'date', hideDefaultActions: true, sortable: 'true', cellAttributes: { alignment: 'right' } },
        { label: this.labels.asignado, fieldName: 'ownerIdUrl', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'owner' }, target: '_self' } },
        { label: this.labels.origen, fieldName: 'recordType', type: 'text', hideDefaultActions: true, }
    ];

    @api recordIds;

    @track tasks = [];
    @track isLoaded = false;
    @track offSet = 0;

    @wire(getRecords, { offSet: 0, recordIds: '$recordIds' })
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

        getRecords({ offSet: this.offSet, recordIds: this.recordIds })
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