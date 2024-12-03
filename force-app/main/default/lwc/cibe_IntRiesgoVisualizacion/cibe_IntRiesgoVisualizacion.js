import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getRiesgoProducts from '@salesforce/apex/CIBE_IntegracionRiesgo.getRiesgoProducts';

export default class Cibe_IntRiesgoVisualizacion extends LightningElement {
    @api recordId;
    @track cargando = true;
    @track datos = [];
    @track dataActivo = [];
    @track dataPasivo = [];
    @track dataServicio = [];
    initialExpandedRows = [
        'Riesgo Directo'
    ];
    @track error = '';
    @track bError = false;
    //initialExpandedRowsPasive = [];
    initialExpandedRowsProductos = [
        'Servicios con contratos',
        'Servicios derivados de operativa'
    ];
    bAgrupado = false;
    bDetalle = false;

    @track columnsActivo =[{ label: 'Productos', fieldName: 'producto', sortable: "true", type: "text"},
    { label: 'País', fieldName: 'countryCode', sortable: "true", type:"text", cellAttributes: { alignment: 'center' }},
    { label: 'Saldo', fieldName: 'saldo', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
    { label: 'Riesgo', fieldName: 'riesgo', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }}, 
    { label: 'Impagado', fieldName: 'impagado', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
    { label: 'Var. 12 meses', fieldName: 'var', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
    { label: 'Vencimiento', fieldName: 'vencimiento', sortable: "true", type: "date", cellAttributes: { alignment: 'center' }}];
    @track columnsPasivo =[{ label: 'Productos', fieldName: 'producto', sortable: "true"},
    { label: 'País', fieldName: 'countryCode', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
    { label: 'Saldo', fieldName: 'saldo', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
    { label: 'Retenido', fieldName: 'retenido', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
    { label: 'Var. 12 meses', fieldName: 'var', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
    { label: 'Vencimiento', fieldName: 'vencimiento', sortable: "true", type: "date", cellAttributes: { alignment: 'center' }}];
    @track columnsServicio =[{ label: 'Productos', fieldName: 'producto', sortable: "true"},
    { label: 'Detalle', fieldName: 'detalle', sortable: "true"},
    { label: 'Vencimiento', fieldName: 'vencimiento', sortable: "true", type: "date"}];

    tablaProductos(data) {

        let balanceActivo = data.responseAcumulado.totalBalance.filter(Activo => Activo.productType == "I");
        let balancePasivo = data.responseAcumulado.totalBalance.filter(Activo => Activo.productType == "R");
        let balanceServicio = data.responseAcumulado.totalBalance.filter(Activo => Activo.productType == "S");

        let datoActivoInt = {};
        let listDatoActivoInt = [];
        let listDatoPasivoInt = [];
        let datoServContratoInt = {};
        let listDatoServContratoChild = [];
        let listDatoServicioInt = [];
        let listDatoActivoChild = [];
        let DatoServOperativoInt = {};
        let listDatoServOperativoChild = [];
        let expandedRowsPasivo = [];

        //cabecera activo
        if(balanceActivo.length !== 0) {
            datoActivoInt.producto = 'Riesgo Directo';
            balanceActivo[0].balance.balance.forEach(balance => {
                this.seleccionarColumnaImporte(balance, datoActivoInt, this.columnsActivo);
            });
        //Activo
        
            listDatoActivoInt.push(datoActivoInt);
            balanceActivo[0].products.forEach(product => {
                let oProducto = {};
                oProducto.producto = product.productDescription;
                oProducto.productId = product.productId;
                product.balance.forEach(balance => {
                    this.seleccionarColumnaImporte(balance, oProducto, this.columnsActivo);
                });
                this.seleccionarContratos(data.responseDetalle.Products, oProducto, this.columnsActivo);
                listDatoActivoChild.push(oProducto);
            });
    
            listDatoActivoInt[0]._children = listDatoActivoChild;
            this.dataActivo = listDatoActivoInt;
        }
       
        //Pasivo
        if(balancePasivo.length !== 0) {
            balancePasivo[0].products.forEach(product => {
                let oProducto = {};
                oProducto.producto = product.productDescription;
                oProducto.productId = product.productId;
                expandedRowsPasivo.push(product.productDescription);
                product.balance.forEach(balance => {
                    this.seleccionarColumnaImporte(balance, oProducto, this.columnsPasivo);
                });
                this.seleccionarContratos(data.responseDetalle.Products, oProducto, this.columnsPasivo);
                listDatoPasivoInt.push(oProducto);
            });
            //this.initialExpandedRowsPasive = expandedRowsPasivo;
            this.dataPasivo = listDatoPasivoInt;
        }
        
        //servicios con contrato
        datoServContratoInt.producto = 'Servicios con contratos';
        if(balanceServicio.length !== 0) {
            balanceServicio[0].products.forEach(product => {
                let oProducto = {};
                oProducto.producto = product.productDescription;
                oProducto.productId = product.productId;
                this.seleccionarContratos(data.responseDetalle.Products, oProducto, this.columnsServicio);
                listDatoServContratoChild.push(oProducto);
            });
            datoServContratoInt._children = listDatoServContratoChild;
            listDatoServicioInt.push(datoServContratoInt);
        }

        //servicios sin contrato
        if(data.responseAcumulado.operativeServices) {
            DatoServOperativoInt.producto = 'Servicios derivados de operativa';
            data.responseAcumulado.operativeServices.forEach(product => {
                let oProducto = {};
                oProducto.producto = product.serviceDescription;
                oProducto.productId = product.id;
                oProducto.detalle = product.productDetail;
                listDatoServOperativoChild.push(oProducto);
            });
            
            DatoServOperativoInt._children = listDatoServOperativoChild;
            listDatoServicioInt.push(DatoServOperativoInt);
        }
        this.dataServicio = listDatoServicioInt;
        this.cargando = false;
    }

    connectedCallback() {
        
        getRiesgoProducts({recordId: this.recordId, tipoDeRiesgo: 'getProductsAgrupado'})
        .then(result => {

            this.bAgrupado = true;
            this.datos.responseAcumulado = result.responseAcumulado;
            this.datosCompletados();
        })
        .catch(error => {
          
            this.cargando = false;
            this.error = error.body.message;
            this.bError = true;
        });
        getRiesgoProducts({recordId: this.recordId, tipoDeRiesgo: 'getProductsDetalle'})
        .then(result => {

            this.bDetalle = true;
            this.datos.responseDetalle = result.responseDetalle;
            this.datosCompletados();
        })
        .catch(error => {
           
            this.cargando = false;
            this.error = error.body.message;
            this.bError = true;
        });
    }

    datosCompletados(){
        if(this.bAgrupado && this.bDetalle){
            this.tablaProductos(this.datos);
        }
    }

    seleccionarContratos(detalle, producto, columns) {

        let listCChild=[];
        let productoDetalle = detalle.filter(Activo => Activo.productId == producto.productId);
        productoDetalle[0].Contracts.forEach(contract => {
            let oContract = {};
            oContract.producto = contract.description;
            oContract.vencimiento = contract.expirationDate;
            oContract.countryCode = contract.country;
            oContract.type = 'url';
            contract.Balance.forEach(balance => {
                this.seleccionarColumnaImporte(balance, oContract, columns);
            });        
            listCChild.push(oContract);
        });
        if(listCChild.length > 0) {
            producto._children = listCChild;
        }
    }

    seleccionarColumnaImporte(balance, oProducto, columns) {
        let importe;
       try{
            importe = new Intl.NumberFormat('de-DE', { style: 'currency', currency: balance.ccy, minimumFractionDigits: 0,
            maximumFractionDigits: 0 }).format(balance.amount);    
        } catch {
            importe = new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR', minimumFractionDigits: 0,
            maximumFractionDigits: 0 }).format(balance.amount);
        }

        switch(balance.type) {  
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
                oProducto.var = importe;    
                break;
            case "Withheld":
                oProducto.retenido = importe;
                break;
        }
    }

   
}