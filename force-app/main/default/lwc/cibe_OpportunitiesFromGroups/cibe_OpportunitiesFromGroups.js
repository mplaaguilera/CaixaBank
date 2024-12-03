import { LightningElement, api, wire, track } from 'lwc';

import getRecords from '@salesforce/apex/CIBE_OpportunitiesFromGroupsController.getRecords';

//labels
import cliente from '@salesforce/label/c.CIBE_Cliente';
import nombre from '@salesforce/label/c.CIBE_Nombre';
import etapa from '@salesforce/label/c.CIBE_Etapa';
import producto from '@salesforce/label/c.CIBE_Producto';
import importe from '@salesforce/label/c.CIBE_Importe';
import fechaCierre from '@salesforce/label/c.CIBE_FechaCierre';
import fechaProxGestion from '@salesforce/label/c.CIBE_FechaProximaGestion';
import probabilidadExito from '@salesforce/label/c.CIBE_ProbabilidadExito';
import propietario from '@salesforce/label/c.CIBE_Propietario';
import grupoOportunidades from '@salesforce/label/c.CIBE_OportunidadesGrupo';
import message from '@salesforce/label/c.CIBE_Message';


export default class Cibe_OpportunitiesFromGroups extends LightningElement {

    labels = {
        cliente,
        nombre,
        etapa,
        producto,
        importe,
        fechaCierre,
        fechaProxGestion,
        probabilidadExito,
        propietario,
        grupoOportunidades,
        message
    }

    columns = [
        { label: this.labels.cliente, fieldName: 'accountIdUrl', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'accountName' }, target: '_self' } },
        { label: this.labels.nombre, fieldName: 'idUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_self' }, hideDefaultActions: true },
        { label: this.labels.etapa, fieldName: 'stageName', type: 'text', hideDefaultActions: true },
        { label: this.labels.producto, fieldName: 'product', type: 'text', hideDefaultActions: true },
        { label: this.labels.importe, fieldName: 'amount', type: 'currency', typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 0 }, hideDefaultActions: true, cellAttributes: { alignment: 'right' } },
        { label: fechaCierre, fieldName: 'closeDate', type: 'date', sortable: 'true', hideDefaultActions: true, cellAttributes: { alignment: 'right' } },
        { label: this.labels.fechaProxGestion, fieldName: 'nextManagementDate', type: 'date', hideDefaultActions: true, cellAttributes: { alignment: 'right' } },
        { label: this.labels.probabilidadExito, fieldName: 'probability', type: 'text', hideDefaultActions: true, },
        { label: this.labels.propietario, fieldName: 'ownerIdUrl', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'owner' }, target: '_self' } }
    ];

    @api recordIds;

    @track opportunities = [];
    @track isLoaded = false;
    @track offSet = 0;

    @wire(getRecords, { offSet: 0, recordIds: '$recordIds' })
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

        getRecords({ offSet: this.offSet, recordIds: this.recordIds })
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