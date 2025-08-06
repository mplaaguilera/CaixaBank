import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getAuditoriasHijas from '@salesforce/apex/SAC_LCMP_AuditoriasController.getAuditoriasHijas';

const columns = [
    { label: 'Caso', fieldName: 'NumeroCaso', type: 'button', typeAttributes: { label: { fieldName: 'NumeroCaso' }, variant:'base'}, sortable: true },
    { label: 'Asunto', fieldName: 'AsuntoCaso', type: 'text', sortable: true },
    { label: 'Ent. Afectada', fieldName: 'NombreEntidad', type: 'text', sortable: true },
    { label: 'Temática', fieldName: 'NombreTematica', type: 'text', sortable: true },
    { label: 'Producto', fieldName: 'NombreProducto', type: 'text', sortable: true },
    { label: 'Motivo', fieldName: 'NombreMotivo', type: 'text', sortable: true },
    { label: 'Detalle', fieldName: 'NombreDetalle', type: 'text', sortable: true },
    { label: 'Estado', fieldName: 'Estado', type: 'text', sortable: true }
];

const columnsAutomaticas = [
    { label: 'Auditoría', fieldName: 'NumeroAuditoria', type: 'button', typeAttributes: { label: { fieldName: 'NumeroAuditoria' }, variant:'base'}, sortable: true },
    { label: 'Fecha creación', fieldName: 'FechaCreacionAuditoria', type: 'date', sortable: true },
    { label: 'Nombre', fieldName: 'NombreAuditoria', type: 'text', sortable: true },
    { label: 'Total reclamaciones', fieldName: 'TotalReclamaciones', type: 'text', sortable: true },
    { label: 'Total OK', fieldName: 'TotalOK', type: 'text', sortable: true },
    { label: '% OKs', fieldName: 'PorcentajeOK', type: 'text', sortable: true },
    { label: 'Total KO', fieldName: 'TotalKO', type: 'text', sortable: true },
    { label: 'Total N/A', fieldName: 'TotalNoAplica', type: 'text', sortable: true },
    { label: 'Total Ptes', fieldName: 'TotalPte', type: 'text', sortable: true },
    { label: 'Estado', fieldName: 'EstadoAuditoria', type: 'text', sortable: true }
];

export default class Sac_MostrarReclamacionesAuditadas extends NavigationMixin(LightningElement) {
    @api recordId;
    @track titulotabla;
    @track auditorias;
    @track mostrarAuditorias;
    @track wiredAuditoriasHijas;
    @track error;
    @track sortedBy;
    @track sortedDirection = 'asc';
    @track auditoriasAutomaticas = true;


    @wire(getAuditoriasHijas, {recordId: '$recordId'})
    wiredAuditoriasHijas(result) {
        this.wiredAuditoriasHijas = result;
        if (result.data) {
            this.auditorias = result.data;
            if(this.auditorias != '' && this.auditorias != undefined){
                let sortedData = [...this.auditorias];
           
                this.mostrarAuditorias = sortedData.map(audi => {
                    if(audi.RecordType.DeveloperName === 'SAC_Auditoria'){
                        this.auditoriasAutomaticas = false;
                        return {
                            idCaso: audi.SAC_Reclamacion__c || '',
                            NumeroCaso: (audi.SAC_Reclamacion__r && audi.SAC_Reclamacion__r.CaseNumber) || '',
                            AsuntoCaso: (audi.SAC_Reclamacion__r && audi.SAC_Reclamacion__r.Subject) || '',
                            NombreEntidad: (audi.SAC_Reclamacion__r && audi.SAC_Reclamacion__r.SAC_Entidad_Afectada__c) || '',
                            NombreTematica: (audi.SAC_Reclamacion__r && audi.SAC_Reclamacion__r.CC_MCC_Tematica__r && audi.SAC_Reclamacion__r.CC_MCC_Tematica__r.Name) || '',
                            NombreProducto: (audi.SAC_Reclamacion__r && audi.SAC_Reclamacion__r.CC_MCC_ProdServ__r && audi.SAC_Reclamacion__r.CC_MCC_ProdServ__r.Name) || '',
                            NombreMotivo: (audi.SAC_Reclamacion__r && audi.SAC_Reclamacion__r.CC_MCC_Motivo__r && audi.SAC_Reclamacion__r.CC_MCC_Motivo__r.Name) || '',
                            NombreDetalle: (audi.SAC_Reclamacion__r && audi.SAC_Reclamacion__r.SEG_Detalle__r && audi.SAC_Reclamacion__r.SEG_Detalle__r.Name) || '',
                            Estado: audi.SAC_DictamenManual__c || ''
                        };
                    }
                    if(audi.RecordType.DeveloperName === 'SAC_AuditoriaGeneral'){
                        this.auditoriasAutomaticas = true;
                        return {
                            idAuditoria: audi.Id || '',
                            NumeroAuditoria: audi.Name || '',
                            FechaCreacionAuditoria: audi.CreatedDate || '',
                            NombreAuditoria: audi.SAC_NombreAuditoria__c || '',
                            TotalReclamaciones: audi.SAC_TotalReclamacionesAuditadas__c || '',
                            TotalOK: audi.SAC_TotalOk__c || '0',
                            PorcentajeOK: audi.SAC_PorcentajeAcierto__c || '',
                            TotalKO: audi.SAC_TotalKo__c || '0',
                            TotalNoAplica: audi.SAC_TotalNoAplica__c || '0',
                            TotalPte: audi.SAC_TotalPendientes__c || '0',
                            EstadoAuditoria: audi.SAC_Estado__c || ''
                            
                        };
                    }
                });
            }  

            this.error = undefined;
            if(this.auditoriasAutomaticas === false){
                this.titulotabla = 'Reclamaciones Auditadas '+ '(' + this.auditorias.length +  ')';
            }else if(this.auditoriasAutomaticas === true){
                this.titulotabla = 'Auditorías Generadas '+ '(' + this.auditorias.length +  ')';
            }
            
        } else if (result.error) {
            this.error = result.error;
            this.auditorias = undefined;
        }
    }

    navigateToRecord(objectId, object) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: objectId,
                objectApiName: object,
                actionName: 'view'
            }
        });
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.navigateToRecord(row.idCaso, 'Case');
    }

    handleRowActionAuditoria(event){
        const row = event.detail.row;
        this.navigateToRecord(row.idAuditoria, 'SEG_Auditoria__c');
    }
 
    get columns() {
        return columns;
    }

    get columnsAutomaticas() {
        return columnsAutomaticas;
    }

    handleRefreshClick() {
        return refreshApex(this.wiredAuditoriasHijas);
    }

    handleSortData(event) {
        const fieldName = event.detail.fieldName;
        const sortDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        const cloneData = [...this.mostrarAuditorias];

        cloneData.sort(this.sortBy(fieldName, sortDirection === 'asc' ? 1 : -1));
        this.mostrarAuditorias = cloneData;
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
}