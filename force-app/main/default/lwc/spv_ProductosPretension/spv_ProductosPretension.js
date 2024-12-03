import { LightningElement, api, wire, track } from 'lwc';
import getProductosPretensiones from '@salesforce/apex/SPV_LCMP_ProductosPretension.getProductosPretensiones';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

const actions = [
    { label: 'Editar', name: 'prod_editar', iconName: 'utility:edit' },
    { label: 'Eliminar', name: 'prod_eliminar', iconName: 'utility:delete' }
];

const columnsReclamacion = [
    { label: 'PRETENSIÓN', fieldName: 'NumeroPretension', type: 'text', sortable: true },
    { label: 'TIPO', fieldName: 'Tipo', type: 'text', sortable: true },
    { label: 'DESCRIPCIÓN', fieldName: 'Descripcion', type: 'text', sortable: true },
    { label: 'Nº CONTRATO', fieldName: 'NumeroContrato', type: 'text', sortable: true }
];

const columnsReclamacionExpandida = [
    { label: 'Pretensión', fieldName: 'NumeroPretension', type: 'text', sortable: true },
    { label: 'Tipo', fieldName: 'Tipo', type: 'text', sortable: true },
    { label: 'Descripción', fieldName: 'Descripcion', type: 'text', sortable: true },
    { label: 'Nº Contrato', fieldName: 'NumeroContrato', type: 'text', sortable: true },
    { label: 'Tae máximo aplicado', fieldName: 'SAC_TaeMaximoAplicado__c', type: 'number', sortable: true, cellAttributes: { iconName: 'utility:percent', iconPosition: 'right' }, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'Tae inicial contrato', fieldName: 'SAC_TaeInicialContrato__c', type: 'number', sortable: true, cellAttributes: { iconName: 'utility:percent', iconPosition: 'right' }, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'Negociar', fieldName: 'SAC_Negociar__c', type: 'text', sortable: true },
    { label: 'Disponemos de contrato', fieldName: 'SAC_DisponemosDeContrato__c', type: 'text', sortable: true }
];

const columnsPretension = [
    { label: 'TIPO', fieldName: 'SAC_Tipo__c', type: 'text', sortable: true },
    { label: 'DESCRIPCIÓN', fieldName: 'SAC_Descripcion__c', type: 'text', sortable: true },
    { label: 'Nº CONTRATO', fieldName: 'N_Contrato__c', type: 'text', sortable: true },
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }    
];

const columnsPretensionExpandida = [
    { label: 'Tipo', fieldName: 'SAC_Tipo__c', type: 'text', sortable: true },
    { label: 'Descripción', fieldName: 'SAC_Descripcion__c', type: 'text', sortable: true },
    { label: 'Nº Contrato', fieldName: 'N_Contrato__c', type: 'text', sortable: true },
    { label: 'Tae máximo aplicado', fieldName: 'SAC_TaeMaximoAplicado__c', type: 'number', sortable: true, cellAttributes: { iconName: 'utility:percent', iconPosition: 'right' }, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'Tae inicial contrato', fieldName: 'SAC_TaeInicialContrato__c', type: 'number', sortable: true, cellAttributes: { iconName: 'utility:percent', iconPosition: 'right' }, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'Negociar', fieldName: 'SAC_Negociar__c', type: 'text', sortable: true },
    { label: 'Disponemos de contrato', fieldName: 'SAC_DisponemosDeContrato__c', type: 'text', sortable: true },
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }
];


export default class Spv_ProductosPretension extends NavigationMixin(LightningElement) {
    @api recordId;
    listaProductos;
    tipoCaso;
    error;
    sortedBy;
    sortedDirection = 'asc';
    wiredProdPretensiones;
    productoSeleccionadoId;
    @track mostrarReclamacion = false;
	@track mostrarPretension = false;
    @track mostrarEliminar = false;
    @track tituloTabla;
    @track abrirModalListaProductos = false;
    @api spinnerLoading = false;

    productosAbiertos = false
    @wire(getProductosPretensiones, { recordId: '$recordId' })
    wiredProdPretensiones(result) {
        this.wiredProdPretensiones = result;

        if (result.data) {
            this.tipoCaso = result.data.caso;
            this.listaProductos = result.data.listaProductos;
            this.error = undefined;

            if(this.tipoCaso == 'SPV_Reclamacion'){
                this.mostrarReclamacion = true;
                this.mostrarPretension = false;
                this.tituloTabla = 'Productos de pretensiones (' +  this.listaProductos.length + ')';
            }else if(this.tipoCaso == 'SPV_Pretension'){
                this.mostrarReclamacion = false;
                this.mostrarPretension = true;
                this.tituloTabla = 'Productos de la pretensión (' +  this.listaProductos.length + ')';
            }
        } else if (result.error) {
            this.error = result.error;
            this.listaProductos = undefined;
            this.tipoCaso = undefined;
        }
    }

    handleRefreshClick() {
        this.spinnerLoading = !this.spinnerLoading;
        
        setTimeout(() => {
            this.spinnerLoading = !this.spinnerLoading;
            return refreshApex(this.wiredProdPretensiones);
        }, 2000);
    }

    handleSortData(event) {

        const fieldName = event.detail;
        const sortDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        const cloneData = [...this.listaProductos];

        cloneData.sort(this.sortBy(fieldName.fieldName, sortDirection === 'asc' ? 1 : -1));
        this.listaProductos = cloneData;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
    }

    handleSortDataRec(event) {

        const fieldName = event.detail;
        const sortDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';

        this.sortedBy = fieldName.fieldName;
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
        let listaProductosId = event.detail.row.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: listaProductosId,
                objectApiName: 'SAC_ProductCase__c',
                actionName: 'view'
            }
        });
    }

    abrirModalListaProductosClick() {
        this.abrirModalListaProductos = true;
        this.productosAbiertos = true
    }

    cerrarModalListaProductosClick() {
        this.abrirModalListaProductos = false;
        this.productosAbiertos = false
    }

    get columnsReclamacion() {
        return columnsReclamacion;
    }

    get columnsReclamacionExpandida() {
        return columnsReclamacionExpandida;
    }

    get columnsPretension() {
        return columnsPretension;
    }

    get columnsPretensionExpandida() {
        return columnsPretensionExpandida;
    }

    get productosPorColumnas() {
        let sortedData = [...this.listaProductos];
        const sortDirection = this.sortedDirection;
        let sortedBy = '';

        if(this.sortedBy === 'NumeroPretension'){
            sortedBy = 'SAC_Pretension__c';
        }else if(this.sortedBy === 'Tipo'){
            sortedBy = 'SAC_Tipo__c';
        }else if(this.sortedBy === 'Descripcion'){
            sortedBy = 'SAC_Descripcion__c';
        }else if(this.sortedBy === 'NumeroContrato'){
            sortedBy = 'N_Contrato__c';
        }else if(this.sortedBy === 'SAC_TaeMaximoAplicado__c'){
            sortedBy = 'SAC_TaeMaximoAplicado__c';
        }else if(this.sortedBy === 'SAC_TaeInicialContrato__c'){
            sortedBy = 'SAC_TaeInicialContrato__c';
        }else if(this.sortedBy === 'SAC_Negociar__c'){
            sortedBy = 'SAC_Negociar__c';
        }else if(this.sortedBy === 'SAC_DisponemosDeContrato__c'){
            sortedBy = 'SAC_DisponemosDeContrato__c';
        }

        sortedData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));

        // Asociar cada producto con las columnas correspondientes
        return sortedData.map(prod => {
            return {
                NumeroPretension: prod.SAC_Pretension__r.CaseNumber,
                Tipo: prod.SAC_Tipo__c,
                Descripcion: prod.SAC_Descripcion__c,
                NumeroContrato: prod.N_Contrato__c,
                SAC_TaeMaximoAplicado__c: this.roundNumber(prod.SAC_TaeMaximoAplicado__c),
                SAC_TaeInicialContrato__c: this.roundNumber(prod.SAC_TaeInicialContrato__c),
                SAC_Negociar__c: prod.SAC_Negociar__c,
                SAC_DisponemosDeContrato__c: prod.SAC_DisponemosDeContrato__c
            };
        });
    }

    roundNumber(number) {
        let roundedNumber = parseFloat(number).toFixed(2);
        return roundedNumber;
    }

    handleNewProduct() {

        const recordId = this.recordId;

        const defaultValues = encodeDefaultFieldValues({
            SAC_Pretension__c: recordId
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {    
                objectApiName: 'SAC_ProductCase__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    handleButtonClick(event) {

        const action = event.detail.action.name; // nombre de la acción del botón
        this.productoSeleccionadoId = event.detail.row.Id; // Id del registro asociado al botón

        if (action === 'prod_eliminar') {
            this.mostrarEliminar = true;
            if(this.productosAbiertos == true){
                this.abrirModalListaProductos = false
            }

        }else if (action === 'prod_editar') {            
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {    
                    recordId: this.productoSeleccionadoId,
                    objectApiName: 'SAC_ProductCase__c',
                    actionName: 'edit'
                }
            });
        }
    }

    cerrarModalEliminar() {
        this.mostrarEliminar = false;

        //Al cerrar el modal de eliminar, en caso de que ya estuviera abierto el modal de los productos, se vuelve a mostrar
        if(this.productosAbiertos == true){
            this.abrirModalListaProductos = true
        }
        
    }

    confirmarEliminar() {
        deleteRecord(this.productoSeleccionadoId)
        .then(() => {
            this.showToast('Producto eliminado', 'Se ha eliminado el producto de pretensión correctamente', 'success');
            return refreshApex(this.wiredProdPretensiones);
        })
        .catch(error => {
            this.showToast('Error', 'Error al eliminar el producto de pretensión seleccionado', 'error');
        }); 

        this.mostrarEliminar = false;
        //Al cerrar el modal de eliminar, en caso de que ya estuviera abierto el modal de los productos, se vuelve a mostrar
        if(this.productosAbiertos == true){
                this.abrirModalListaProductos = true
            }

    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}