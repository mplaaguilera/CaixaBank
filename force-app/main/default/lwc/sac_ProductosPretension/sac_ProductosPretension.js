import { LightningElement, api, wire, track } from 'lwc';
import getProductosPretensiones from '@salesforce/apex/SAC_LCMP_ProductosPretension.getProductosPretensiones';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
//import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import createProductCase from '@salesforce/apex/SAC_LCMP_ProductosPretension.createProductCase';
import editProductCase from '@salesforce/apex/SAC_LCMP_ProductosPretension.editProductCase';
import eliminarProducto from '@salesforce/apex/SAC_LCMP_ProductosPretension.eliminarProducto';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['Case.CaseNumber', 'Case.Status'];

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
    { label: 'Disponemos de contrato', fieldName: 'SAC_DisponemosDeContrato__c', type: 'text', sortable: true },
    { label: 'Fecha Apertura', fieldName: 'SAC_FechaApertura__c', type: 'text', sortable: true },
    { label: 'Fecha Cancelación', fieldName: 'SAC_FechaCancelacion__c', type: 'text', sortable: true },
    { label: 'Procedencia del contrato', fieldName: 'SAC_ProcedenciaContrato__c', type: 'text', sortable: true},
    { label: 'Caja de procedencia', fieldName: 'SAC_CajaProcedencia__c', type: 'text', sortable: true}
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
    { label: 'Contrato a Remediar', fieldName: 'SAC_ContratoRemediarTexto__c', type: 'text', sortable: true },
    { label: 'Tae máximo aplicado', fieldName: 'SAC_TaeMaximoAplicado__c', type: 'number', sortable: true, cellAttributes: { iconName: 'utility:percent', iconPosition: 'right' }, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'Tae inicial contrato', fieldName: 'SAC_TaeInicialContrato__c', type: 'number', sortable: true, cellAttributes: { iconName: 'utility:percent', iconPosition: 'right' }, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'Negociar', fieldName: 'SAC_Negociar__c', type: 'text', sortable: true },
    { label: 'Disponemos de contrato', fieldName: 'SAC_DisponemosDeContrato__c', type: 'text', sortable: true },
    { label: 'Fecha Apertura', fieldName: 'SAC_FechaApertura__c', type: 'text', sortable: true },
    { label: 'Fecha Cancelación', fieldName: 'SAC_FechaCancelacion__c', type: 'text', sortable: true },
    { label: 'Procedencia del contrato', fieldName: 'SAC_ProcedenciaContrato__c', type: 'text', sortable: true},
    { label: 'Caja de procedencia', fieldName: 'SAC_CajaProcedencia__c', type: 'text', sortable: true},
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }
];


export default class Sac_ProductosPretension extends NavigationMixin(LightningElement) {
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

    productosAbiertos = false;
    createProductModalOpen = false;
    editProductModalOpen = false;
    
    sacDescripcion; 
    sacFechaApertura;
    sacFechaCancelacion;
    nContrato;
    sacTipo;
    sacTaeInicial;
    sacTaeMaximo;
    sacNegociar;
    sacDisponemosContrato;
    sacProcedenciaContrato;
    sacCajaProcedencia; //Campo solo visible si la procedencia del contrato es Banca Cívica
    sacOficina;
    sacContrato;
    sacModalidad;
    sacDigitoControl;
    @track caseNumber;
    @track mostrarCajaProcedencia = false;
    sacContratoRemediar = false;
    mostrarCamposAdicionales = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    case;

    getCaseNumber() {
        if (this.case.data) {
            this.caseNumber = this.case.data.fields.CaseNumber.value;
        }
    }

    renderedCallback() {
        this.getCaseNumber();
    }
    
    @wire(getProductosPretensiones, { recordId: '$recordId' })
    wiredProdPretensiones(result) {
        this.wiredProdPretensiones = result;

        if (result.data) {
            this.tipoCaso = result.data.caso;
            this.listaProductos = result.data.listaProductos;
            this.error = undefined;

            if(this.tipoCaso == 'SAC_Reclamacion' || this.tipoCaso === 'SPV_Reclamacion'){
                this.mostrarReclamacion = true;
                this.mostrarPretension = false;
                this.tituloTabla = 'Productos de pretensiones (' +  this.listaProductos.length + ')';
            }else if(this.tipoCaso == 'SAC_Pretension' || this.tipoCaso === 'SPV_Pretension'){
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
        }else if(this.sortedBy === 'SAC_FechaApertura__c'){
            sortedBy = 'SAC_FechaApertura__c';
        }else if(this.sortedBy === 'SAC_FechaCancelacion__c'){
            sortedBy = 'SAC_FechaCancelacion__c';
        }else if(this.sortedBy === 'SAC_ProcedenciaContrato__c'){
            sortedBy = 'SAC_ProcedenciaContrato__c';
        }else if(this.sortedBy === 'SAC_CajaProcedencia__c'){
            sortedBy = 'SAC_CajaProcedencia__c';
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
                SAC_DisponemosDeContrato__c: prod.SAC_DisponemosDeContrato__c,
                SAC_FechaApertura__c: prod.SAC_FechaApertura__c,
                SAC_FechaCancelacion__c: prod.SAC_FechaApertura__c,
                SAC_ProcedenciaContrato__c: prod.SAC_ProcedenciaContrato__c,
                SAC_CajaProcedencia__c: prod.SAC_CajaProcedencia__c,
                SAC_ContratoRemediarTexto__c: prod.SAC_ContratoRemediarTexto__c
            };
        });
    }

    roundNumber(number) {
        let roundedNumber = parseFloat(number).toFixed(2);
        return roundedNumber;
    }

    handleNewProduct() {
        this.createProductModalOpen = true;
    }

    // Cerrar modal crear producto
    cerrarModalCreateProduct() {
        this.createProductModalOpen = false;
    }

    // Cerrar modal editar producto
    cerrarModalEditProduct() {

        this.vaciarDatos();
        this.editProductModalOpen = false;
    }

    // Manejar cambios en los campos
    handleInputChange(event) {
        const field = event.target.fieldName;
        if (field === 'SAC_Pretension__c') {
            this.sacPretension = event.target.value;
        } else if (field === 'SAC_Descripcion__c') {
            this.sacDescripcion = event.target.value;
        } else if (field === 'SAC_FechaApertura__c') {
            this.sacFechaApertura = event.target.value;
        } else if (field === 'SAC_FechaCancelacion__c') {
            this.sacFechaCancelacion = event.target.value;
        } else if (field === 'N_Contrato__c') { 
            this.nContrato = event.target.value;
        } else if (field === 'SAC_Tipo__c') {
            this.sacTipo = event.target.value;
            if(this.sacTipo == 'Contrato no aplica'){
                this.nContrato = '000';
            }else if(this.sacTipo == 'Contrato no localizado'){
                this.nContrato = '999';
            }
        } else if (field === 'SAC_TaeInicialContrato__c') { 
            this.sacTaeInicial = event.target.value;
        } else if (field === 'SAC_TaeMaximoAplicado__c') { 
            this.sacTaeMaximo = event.target.value;
        } else if (field === 'SAC_Negociar__c') { 
            this.sacNegociar = event.target.value;
        } else if (field === 'SAC_DisponemosDeContrato__c') { 
            this.sacDisponemosContrato = event.target.value;
        }else if (field === 'SAC_ProcedenciaContrato__c'){
            this.sacProcedenciaContrato = event.target.value;
            if(this.sacProcedenciaContrato === 'Banca Cívica'){
                this.mostrarCajaProcedencia = true;
            }else{
                this.sacCajaProcedencia = null;
                this.mostrarCajaProcedencia = false;
            }
        }else if (field === 'SAC_CajaProcedencia__c'){
            this.sacCajaProcedencia = event.target.value;
        }else if (field === 'SAC_ContratoRemediar__c') {
            this.sacContratoRemediar = event.target.value;
            console.log('🔍 Valor de sacContratoRemediar:', this.sacContratoRemediar);
            if (this.sacContratoRemediar) {
                this.mostrarCamposAdicionales = true;
            } else {
                this.mostrarCamposAdicionales = false;
            }
        } else if (field === 'SAC_Oficina__c') { 
            this.sacOficina = event.target.value;
        } else if (field === 'SAC_Modalidad__c') { 
            this.sacModalidad = event.target.value;
        } else if (field === 'SAC_Contrato__c') { 
            this.sacContrato = event.target.value;
        } else if (field === 'SAC_DigitoControl__c') { 
            this.sacDigitoControl = event.target.value;
        }
    }

    // Manejar éxito al guardar el registro
    handleSuccessCreateProduct(event) {
        const recordId = event.detail.id;
        
        this.cerrarModalCreateProduct();
    }

    // Manejar error al guardar el registro
    handleErrorCreateProduct(event) {
        this.showToast('Error', event.detail.message, 'error');
    }

    handleGuardarCreateProduct() {
        // Llamada a Apex para crear el registro
        if(this.sacDescripcion == '' || this.sacDescripcion == null || this.sacTipo == '' || this.sacTipo == null || this.nContrato == '' || this.nContrato == null){
            if((this.sacDescripcion == '' || this.sacDescripcion == null) && (this.sacTipo == '' || this.sacTipo == null) && (this.nContrato == '' || this.nContrato == null)){
                this.showToast('Error', 'Es necesario informar todos los campos obligatorios antes de guardar.', 'error');
            }else if(this.sacDescripcion == '' || this.sacDescripcion == null){
                this.showToast('Error', 'Es obligatorio informar el campo Descripción antes de guardar.', 'error');
            }else if(this.sacTipo == '' || this.sacTipo == null){
                this.showToast('Error', 'Es obligatorio informar el campo Tipo antes de guardar.', 'error');
            }else{
                this.showToast('Error', 'Es obligatorio informar el Nº de contrato antes de guardar.', 'error');
            }
        }else{
            this.spinnerLoading = true;
            createProductCase({ 
                descripcion: this.sacDescripcion,
                contrato: this.nContrato,
                tipo: this.sacTipo,
                fechaApertura: this.sacFechaApertura,
                fechaCancelacion: this.sacFechaCancelacion,
                pretensionId: this.recordId,
                taeInicial: this.sacTaeInicial,
                taeMaximo: this.sacTaeMaximo,
                negociar: this.sacNegociar,
                disponemosContrato: this.sacDisponemosContrato,
                procedenciaContrato: this.sacProcedenciaContrato,
                cajaProcedencia: this.sacCajaProcedencia,

                contratoR: this.sacContrato,
                oficina: this.sacOficina,
                modalidad: this.sacModalidad,
                digitoControl: this.sacDigitoControl,
                contratoRemediar: this.sacContratoRemediar

            })
            .then(result => {
                this.showToast('Éxito', 'Se ha creado el producto correctamente', 'success');
                this.spinnerLoading = false;
                this.vaciarDatos();
                this.cerrarModalCreateProduct();  // Cerrar el modal al guardar correctamente
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.showToast('Error', error.body.message, 'error');
            });
        }
    }

    vaciarDatos(){
        this.sacPretension = null;
        this.sacDescripcion = null;
        this.sacFechaApertura = null;
        this.sacFechaCancelacion = null;
        this.nContrato = null;
        this.sacTipo = null;
        this.sacTaeInicial = null;
        this.sacTaeMaximo = null;
        this.sacNegociar = null;
        this.sacDisponemosContrato = null;
        this.sacProcedenciaContrato = null;
        this.sacCajaProcedencia = null;
        this.mostrarCajaProcedencia = false;
        this.mostrarCamposAdicionales = false;
        this.sacContratoRemediar = false;
        this.sacOficina = null;
        this.sacContrato = null;
        this.sacModalidad = null;
        this.sacDigitoControl = null;
    }

    // Manejar éxito al guardar el registro
    handleSuccessEditProduct(event) {
        const recordId = event.detail.id;
        this.cerrarModalEditProduct();
    }

    // Manejar error al guardar el registro
    handleErrorEditProduct(event) {
        this.showToast('Error', event.detail.message, 'error');
    }

    handleGuardarEditProduct() {
        // Llamada a Apex para crear el registro
        if(this.sacDescripcion == '' || this.sacDescripcion == null || this.sacTipo == '' || this.sacTipo == null || this.nContrato == '' || this.nContrato == null){
            if((this.sacDescripcion == '' || this.sacDescripcion == null) && (this.sacTipo == '' || this.sacTipo == null) && (this.nContrato == '' || this.nContrato == null)){
                this.showToast('Error', 'Es necesario informar todos los campos obligatorios antes de guardar.', 'error');
            }else if(this.sacDescripcion == '' || this.sacDescripcion == null){
                this.showToast('Error', 'Es obligatorio informar el campo Descripción antes de guardar.', 'error');
            }else if(this.sacTipo == '' || this.sacTipo == null){
                this.showToast('Error', 'Es obligatorio informar el campo Tipo antes de guardar.', 'error');
            }else{
                this.showToast('Error', 'Es obligatorio informar el Nº de contrato antes de guardar.', 'error');
            }
        }else{
            this.spinnerLoading = true;
            editProductCase({ 
                productId: this.productoSeleccionadoId,
                descripcion: this.sacDescripcion,
                contrato: this.nContrato,
                tipo: this.sacTipo,
                fechaApertura: this.sacFechaApertura,
                fechaCancelacion: this.sacFechaCancelacion,
                pretensionId: this.recordId,
                taeInicial: this.sacTaeInicial,
                taeMaximo: this.sacTaeMaximo,
                negociar: this.sacNegociar,
                disponemosContrato: this.sacDisponemosContrato,
                procedenciaContrato: this.sacProcedenciaContrato,
                cajaProcedencia : this.sacCajaProcedencia,

                contratoR: this.sacContrato,
                oficina: this.sacOficina,
                modalidad: this.sacModalidad,
                digitoControl: this.sacDigitoControl,
                contratoRemediar: this.sacContratoRemediar

            })
            .then(result => {
                this.showToast('Éxito', 'Se ha editado el producto correctamente', 'success');
                this.spinnerLoading = false;
                this.cerrarModalEditProduct();  // Cerrar el modal al guardar correctamente
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.showToast('Error', error.body.message, 'error');
            });
        }
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
            const producto = event.detail.row;
        
        // Asignar los valores actuales del registro a las variables
            this.sacPretension = producto.SAC_Pretension__c;
            this.sacDescripcion = producto.SAC_Descripcion__c;
            this.sacFechaApertura = producto.SAC_FechaApertura__c;
            this.sacFechaCancelacion = producto.SAC_FechaCancelacion__c;
            this.nContrato = producto.N_Contrato__c;
            this.sacTipo = producto.SAC_Tipo__c;
            this.sacTaeInicial = producto.SAC_TaeInicialContrato__c;
            this.sacTaeMaximo = producto.SAC_TaeMaximoAplicado__c;
            this.sacNegociar = producto.SAC_Negociar__c;
            this.sacDisponemosContrato = producto.SAC_DisponemosDeContrato__c;
            this.sacProcedenciaContrato = producto.SAC_ProcedenciaContrato__c;
            this.sacCajaProcedencia = producto.SAC_CajaProcedencia__c;
            if(this.sacProcedenciaContrato === 'Banca Cívica'){
                this.mostrarCajaProcedencia = true;
            }else{
                this.mostrarCajaProcedencia = false;
            }

            this.editProductModalOpen = true;
            this.abrirModalListaProductos = false;
            this.sacOficina = producto.SAC_Oficina__c;
            this.sacModalidad = producto.SAC_Modalidad__c;
            this.sacContrato = producto.SAC_Contrato__c;
            this.sacDigitoControl = producto.SAC_DigitoControl__c;
            this.sacContratoRemediar = producto.SAC_ContratoRemediar__c;

            if (this.sacContratoRemediar) {
                this.mostrarCamposAdicionales = true;
            }
            
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
        this.spinnerLoading = true;
        eliminarProducto({idProducto: this.productoSeleccionadoId})
        .then(() => {
            this.showToast('Producto eliminado', 'Se ha eliminado el producto de pretensión correctamente', 'success');
            this.spinnerLoading = false;
            return refreshApex(this.wiredProdPretensiones);
        })
        .catch(error => {
            this.spinnerLoading = false;
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