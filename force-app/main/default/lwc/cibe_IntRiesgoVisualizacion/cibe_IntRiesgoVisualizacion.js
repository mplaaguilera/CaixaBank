import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRiesgoController from '@salesforce/apex/CIBE_IntegracionRiesgo.getRiesgoController';


export default class Cibe_IntRiesgoVisualizacion extends LightningElement {
    @api recordId;
    //Spinners de carga
    @track cargando = true;
    @track loadchildcontract = false;
    @track loadingMoreCont = false;

    @track datos = {
        responseAcumulado: {},
        responseDetalle: {}
    };
    //Array de datos por seccion
    @track dataActivo = [];
    @track dataPasivo = [];
    @track dataServicio = [];
    @track dataServicioOperativa = [];
    //errores
    @track error = '';
    @track bError = false;

    bAgrupado = false;
    //Visualización botones por sección
    @track showLoadMoreButtonActivo = false;
    @track showLoadMoreButtonPasivo = false;
    @track showLoadMoreButtonServicio = false;
    //Gestión de página actual para páginado
    @track currentPageActivo = 1;
    @track currentPagePasivo = 1;
    @track currentPageServicio = 1;
    //Gestión aislada de productId por sección
    @track currentProductIdActivo;
    @track currentProductIdPasivo;
    @track currentProductIdServicio;

    //Definición de columnas por sección
    @track columnsActivo =[
        { label: 'Productos Riesgo Directo', fieldName: 'producto', sortable: "true", type: "text", initialWidth: 200, wrap:true},
        { label: 'País', fieldName: 'countryCode', sortable: "true", type:"text", cellAttributes: { alignment: 'center' }},
        { label: 'Saldo', fieldName: 'saldo', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
        { label: 'Riesgo', fieldName: 'riesgo', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }}, 
        { label: 'Impagado', fieldName: 'impagado', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
        { label: 'Var. 12 meses', fieldName: 'var', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
        { label: 'Vencimiento', fieldName: 'vencimiento', sortable: "true", type: "date", cellAttributes: { alignment: 'center' }}
    ];

    @track columnsPasivo =[
        { label: 'Productos', fieldName: 'producto', sortable: "true"},
        { label: 'País', fieldName: 'countryCode', sortable: "true", type:"text", cellAttributes: { alignment: 'center' }},
        { label: 'Saldo', fieldName: 'saldo', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
        { label: 'Retenido', fieldName: 'retenido', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
        { label: 'Var. 12 meses', fieldName: 'var', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
        { label: 'Vencimiento', fieldName: 'vencimiento', sortable: "true", type: "date", cellAttributes: { alignment: 'center' }}
    ];

    @track columnsServicio =[
        { label: 'Productos', fieldName: 'producto', sortable: "true"},
        { label: 'Vencimiento', fieldName: 'vencimiento', sortable: "true", type: "date"}
    ];

    @track columnsServicioOperativa =[
        { label: 'Servicio', fieldName: 'producto', sortable: "true"},
        { label: 'Detalle', fieldName: 'detalle', sortable: "true"}
    ];
    //Carga Inicial de Agrupados en la tabla
    connectedCallback() {
        getRiesgoController({ recordId: this.recordId, tipoDeRiesgo: 'getProductsAgrupado', productId: null})
            .then(result => {
                console.log('Resultado (Agrupado):', result);
                this.bAgrupado = true;
                this.datos.responseAcumulado = result.responseAcumulado;
                this.datosCompletados();
            })
            .catch(error => {
                console.log('Error (Agrupado):', error);
                this.cargando = false;
                this.error = error;
                if(error.message){
                    this.error = error.message;
                }
                this.bError = true;
            });
    }
    datosCompletados() {
        if (this.bAgrupado) {
            this.tablaProductos(this.datos);
        }
    }
    //Visualización inicial de Agrupados en la tabla
    tablaProductos(data) {
        let balanceActivo = data.responseAcumulado.totalBalance.filter(Activo => Activo.productType == "I");
        let balancePasivo = data.responseAcumulado.totalBalance.filter(Activo => Activo.productType == "R");
        let balanceServicio = data.responseAcumulado.totalBalance.filter(Activo => Activo.productType == "S");
        let listDatoActivoInt = [];
        let listDatoPasivoInt = [];
        let listDatoServicioInt = [];
        let listDatoServContratoChild = [];
        let listDatoServOperativoChild = [];

        // Agrupado Activo
        if (balanceActivo.length !== 0) {
            balanceActivo[0].products.forEach(product => {
                let oProducto = {};
                oProducto.producto = product.productDescription;
                oProducto.productId = product.productId;
                product.balance.forEach(balance => {
                    this.seleccionarColumnaImporteGenerico(balance, oProducto, this.columnsActivo, true);
                });
                listDatoActivoInt.push(oProducto);
            });
            this.dataActivo = listDatoActivoInt;
        }

        // Agrupado Pasivo
        if (balancePasivo.length !== 0) {
            balancePasivo[0].products.forEach(product => {
                let oProducto = {};
                oProducto.producto = product.productDescription;
                oProducto.productId = product.productId;
                product.balance.forEach(balance => {
                    this.seleccionarColumnaImporteGenerico(balance, oProducto, this.columnsPasivo, false);
                });
                listDatoPasivoInt.push(oProducto);
            });
            this.dataPasivo = listDatoPasivoInt;
        }

        // Agrupado Servicios con contrato
        if (balanceServicio.length !== 0) {
            balanceServicio[0].products.forEach(product => {
                let oProducto = {};
                oProducto.producto = product.productDescription;
                oProducto.productId = product.productId;
                listDatoServicioInt.push(oProducto);
            });
            this.dataServicio = listDatoServicioInt;
        }
        this.cargando = false;//Quitamos spinner de carga general
    }
    handleRowSelection = event => {
        var selectedRows=event.detail.selectedRows;
        // Identificar el tipo de grid basado en la fila seleccionada
        let gridClass = '';
        if (selectedRows.length > 0) {
            const row = selectedRows[0];
            if (this.dataActivo.some(item => item.productId === row.productId)) {
                gridClass = 'activo-tree-grid';
            } else if (this.dataPasivo.some(item => item.productId === row.productId)) {
                gridClass = 'pasivo-tree-grid';
            } else if (this.dataServicio.some(item => item.productId === row.productId)) {
                gridClass = 'serviciocontract-tree-grid';
            }
        }
        //Prevenimos que seleccionen mas de un checkbox para cargar contratos
        if(selectedRows.length > 1)
            {
                var el = this.template.querySelector(`.${gridClass}`);
                selectedRows=el.selectedRows=el.selectedRows.slice(1);
                event.preventDefault();
                return;
            }
        // Llama a handleRowAction para manejar la acción de fila
        if (selectedRows.length === 1) {
            const row = selectedRows[0];
            this.handleRowAction({ detail: { action: { name: 'show_child_records' }, row: row, gridClass: gridClass} });
        }
    }
    //Gestión del lanzamiento de contratos
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const section = event.detail.gridClass;

        switch (actionName) {
            case 'show_child_records':
                this.handleRowExpand(row,section);
                break;
            default:
                break;
        }
    }
    //Gestión aislada por fila para integrar contracts (Detalle)
    handleRowExpand(row, section) {
        if (row && row.productId){
            row.isExpanded = true;
            if (section === 'activo-tree-grid') {
                this.currentProductIdActivo = row.productId;
            } else if (section === 'pasivo-tree-grid') {
                this.currentProductIdPasivo = row.productId;
            } else if (section === 'serviciocontract-tree-grid') {
                this.currentProductIdServicio = row.productId;
            }
            this.loadContracts(row.productId, section);//Lanzamos integración contratos por producto y sección
            this.loadchildcontract = true;//Habilitamos spinner mientras se cargan contratos
        }
    }
    //Carga del detalle de contratos por productId en cada fila desplegada
    loadContracts(productId, section, pageKey = 1) {
        this.currentProductId = productId;
        if(pageKey > 1) {
            this.loadingMoreCont = true; // Mostramos el spinner mientras se cargan contatos
        }
        getRiesgoController({ recordId: this.recordId, tipoDeRiesgo: 'getProductsDetalle', productId, pageKey })
            .then(result => {
                const data = result.responseDetalle.Products.find(prod => prod.productId === productId);
                const contracts = data ? data.Contracts : [];

                const updatedDataActivo = this.dataActivo.map(product => {
                    if (product.productId === productId) {
                        let oProducto = { ...product };
                        this.seleccionarContratos(contracts, oProducto, this.columnsActivo);
                        return oProducto;
                    }
                    return product;
                });
                
                const updatedDataPasivo = this.dataPasivo.map(product => {
                    if (product.productId === productId) {
                        let oProducto = { ...product };
                        this.seleccionarContratos(contracts, oProducto, this.columnsPasivo);
                        return oProducto;
                    }
                    return product;
                });

                const updatedDataServicio = this.dataServicio.map(product => {
                    if (product.productId === productId) {
                        let oProducto = { ...product };
                        this.seleccionarContratos(contracts, oProducto, this.columnsServicio);
                        return oProducto;
                    }
                    return product;
                });
                
                // Actualiza los servicios derivados de operativa en el primer detalle obtenido
                let updatedDataServicioOperativa = [];
                if (result.responseDetalle.operativeServices) {
                    updatedDataServicioOperativa = result.responseDetalle.operativeServices.map(service => {
                        return {
                            producto: service.serviceDescription,
                            detalle: service.detail
                        };
                    });
                }

                this.dataActivo = [...updatedDataActivo];
                this.dataPasivo = [...updatedDataPasivo];
                this.dataServicio = [...updatedDataServicio];
                this.dataServicioOperativa = [...updatedDataServicioOperativa];
                
                //Visibilidad del botón Cargar Más cuando el array de detalle trae 200
                if (contracts.length === 200) {
                    if (section === 'activo-tree-grid') {
                        this.showLoadMoreButtonActivo = true;
                        this.currentPageActivo = pageKey;
                    } else if (section === 'pasivo-tree-grid') {
                        this.showLoadMoreButtonPasivo = true;
                        this.currentPagePasivo = pageKey;
                    } else if (section === 'serviciocontract-tree-grid') {
                        this.showLoadMoreButtonServicio = true;
                        this.currentPageServicio = pageKey;
                    }
                } else {
                    if (section === 'activo-tree-grid') {
                        this.showLoadMoreButtonActivo = false;
                    } else if (section === 'pasivo-tree-grid') {
                        this.showLoadMoreButtonPasivo = false;
                    } else if (section === 'serviciocontract-tree-grid') {
                        this.showLoadMoreButtonServicio = false;
                    }
                }

                this.loadingMoreCont = false; //Quitamos spinner de carga para detalle
                this.loadchildcontract = false;//Quitamos spinner de carga para componente

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: error.body.message,
                        variant: 'error'
                    }),
                );
                this.loadchildcontract = false;  // Ocultamos spinner en caso de error
                this.loadingMoreCont = false; 
            });
    }
    //Gestión de carga de contratos específica por Grid
    loadMoreContractsActivo() {
        this.loadContracts(this.currentProductIdActivo, 'activo-tree-grid', this.currentPageActivo + 1);
    }
    
    loadMoreContractsPasivo() {
        this.loadContracts(this.currentProductIdPasivo, 'pasivo-tree-grid', this.currentPagePasivo + 1);
    }
    
    loadMoreContractsServicio() {
        this.loadContracts(this.currentProductIdServicio, 'serviciocontract-tree-grid', this.currentPageServicio + 1);
    }
    //Carga de contratos específica por productId

    seleccionarContratos(contracts, producto, columns) {
        if (!contracts) {
            console.warn('Detalles no disponibles para el producto:', producto.productId);
            return;
        }
            let listCChild = [];
            contracts.forEach(contract => {
                try {
                    let oContract = {};
                    oContract.producto = contract.contractId + ' ' + contract.contractDescription;
                    oContract.vencimiento = contract.expirationDate;
                    oContract.countryCode = contract.country;
                    oContract.type = 'url';
    
                    if (!Array.isArray(contract.Balance)) {
                        throw new Error('El contrato con contractId ' + contract.contractId + ' no tiene un array de Balance.');
                    }
    
                    contract.Balance.forEach(balance => {
                        try {
                            this.seleccionarColumnaImporteGenerico(balance, oContract, columns, false);
                        } catch (error) {
                            console.error('Error en seleccionarColumnaImporte para balance', balance, ':', error);
                        }
                    });
    
                    listCChild.push(oContract);
                } catch (error) {
                    console.error('Error procesando el contrato:', contract, ':', error);
                }
            });
    
            if (listCChild.length > 0) {
                producto._children = listCChild;
            }
    }
    seleccionarColumnaImporteGenerico(balance, oProducto, columns, isCabecera) {
        let importe;
        try {
            importe = new Intl.NumberFormat('de-DE', {
                style: 'currency',
                currency: balance.ccy,
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
            }).format(balance.amount);
        } catch {
            importe = new Intl.NumberFormat('de-DE', {
                style: 'currency',
                currency: 'EUR',
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
            }).format(balance.amount);
        }
        if (isCabecera) {
            switch (balance.type) {
                case "Risk":
                    oProducto.riesgo = importe;
                    break;
                case "Unpaid":
                    oProducto.impagado = importe;
                    break;
                case "Balance":
                case "Disposed":
                    oProducto.saldo = importe;
                    break;
                case "Var":
                    oProducto.var = importe; // Actualiza para indicar que es de cabecera
                    break;
                case "Withheld":
                    oProducto.retenido = importe;
                    break;
            }
        } else {
            switch (balance.type) {
                case "Risk":
                    oProducto.riesgo = importe;
                    break;
                case "Unpaid":
                    oProducto.impagado = importe;
                    break;
                case "Balance":
                case "Avaiable":
                    oProducto.saldo = importe;
                    break;
                case "Withheld":
                    oProducto.retenido = importe;
                    break;
            }
        }
    }
}