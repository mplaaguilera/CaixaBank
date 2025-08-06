import { LightningElement, api, wire, track } from 'lwc';
import getEmailMessagesByAuditoriaId from '@salesforce/apex/SAC_LCMP_AuditoriasController.getEmailMessagesByAuditoriaId';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

const columns = [
    { label: 'Fecha Creación', fieldName: 'CreatedDate', type: 'date',
        typeAttributes: {
            day: 'numeric',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        },
       sortable: true },
    { label: 'Asunto', fieldName: 'Subject', type: 'text', sortable: true },
    { label: 'Destinatario', fieldName: 'ToAddress', type: 'email', sortable: true },
    {
        type: "button", initialWidth: 120, typeAttributes: {
            label: 'Ver detalles',
            name: 'Ver detalles',
            title: 'Ver detalles',
            disabled: false,
            value: 'Ver detalles'
        }
    }
];

export default class Sac_AlertaEmails extends NavigationMixin(LightningElement) {
    @api recordId;
    @track emailMessages;
    @track error;
    @track sortedBy;
    @track sortedDirection;
    @track wiredEmailMessagesResult;

    @wire(getEmailMessagesByAuditoriaId, { recordId: '$recordId' })
    wiredEmailMessages(result) {
        this.wiredEmailMessagesResult = result;
        if (result.data) {
            this.emailMessages = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.emailMessages = undefined;
        }
    }

    handleSortData(event) {
        const fieldName = event.detail.fieldName;
        const sortDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        const cloneData = [...this.emailMessages];

        cloneData.sort(this.sortBy(fieldName, sortDirection === 'asc' ? 1 : -1));
        this.emailMessages = cloneData;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            const A = key(a) ? key(a).toUpperCase() : '';
            const B = key(b) ? key(b).toUpperCase() : '';
            let comparison = 0;

            if (A > B) {
                comparison = 1;
            } else if (A < B) {
                comparison = -1;
            }
            return reverse * comparison;
        };
    }

    handleRowClick(event) {
        let emailMessageId = event.detail.row.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: emailMessageId,
                objectApiName: 'EmailMessage',
                actionName: 'view'
            }
        });
    }

    handleRefreshClick() {
        return refreshApex(this.wiredEmailMessagesResult);
    }

    get columns() {
        return columns;
    }
}