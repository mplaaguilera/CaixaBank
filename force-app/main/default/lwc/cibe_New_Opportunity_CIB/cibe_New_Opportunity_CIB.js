import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";

import NAME_FIELD from '@salesforce/schema/Product2.Name';
import PRODID_FIELD from '@salesforce/schema/AV_ProductExperience__c.AV_ProductoFicha__c';

//Methods
import getOperacionPicklist     from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.getTipoOperacionPicklist';
import getStatusValues          from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.getStatusValues';
import lookupSearch 	        from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.search';
import lookupSearchFamily 	    from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.searchFamily';
import getOpportunityFields     from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.getOpportunityFields';
import getCliente               from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.getCliente';
import searchCliente            from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.searchCliente';


//Labels translations
import estadoOportunidad from '@salesforce/label/c.CIBE_EstadoOportunidad';
import productoLabel from '@salesforce/label/c.CIBE_Producto';
import productoDebeSerMMPP from '@salesforce/label/c.CIBE_ProductoDebeSerMMPP';
import subProducto from '@salesforce/label/c.CIBE_SubProducto';
import productoNoMMPP from '@salesforce/label/c.CIBE_ProductoNoMMPP';
import confidencial from '@salesforce/label/c.CIBE_Confidencial';
import propietarioOportunidad from '@salesforce/label/c.CIBE_PropietarioOportunidad';
import tipoOperacion from '@salesforce/label/c.CIBE_TipoOperacion';
import nombreOportunidad from '@salesforce/label/c.CIBE_NombreOportunidad';
import familia from '@salesforce/label/c.CIBE_Familia';
import buscarProductos from '@salesforce/label/c.CIBE_BuscarProductos';
import anadirParticipante from '@salesforce/label/c.CIBE_AnadirParticipante';
import esg from '@salesforce/label/c.CIBE_ESG';
import buscarFamilia from '@salesforce/label/c.CIBE_BuscarFamilia';
import ecas from '@salesforce/label/c.CIBE_ECAs';
import sindicaciones from '@salesforce/label/c.CIBE_Sindicaciones';
import clienteLabel from '@salesforce/label/c.CIBE_Cliente';
import linea from '@salesforce/label/c.CIBE_Linea';


export default class CIBE_New_Opportunity_CIB extends NavigationMixin(LightningElement) {
    
    labels = {
        estadoOportunidad,
        productoLabel,
        productoDebeSerMMPP,
        subProducto,
        productoNoMMPP,
        confidencial,
        propietarioOportunidad,
        tipoOperacion,
        nombreOportunidad,
        familia,
        buscarProductos,
        anadirParticipante,
        esg,
        buscarFamilia,
        ecas,
        sindicaciones,
        clienteLabel, 
        linea
    }

    @api pfId; 
    @api developerName;
    @api producto;
    @api productoName;
    @api propietario;
    @api oportunidad;
    @api valueOperacion;
    @api valueSubProducto;
    @api stageName;
    @api confidencial;
    @api esg;
    @api sindicaciones;
    @api ecas;
    @api cliente;
    @api linea;
    @api anadirParticipantes;

    @track allStages = [];
    @track optionsTipoOpera;
    @track optionsExito;
    @track OportunidadValue;
    @track showErrorMMPP=false;
    @track family;

    @track placeholder = this.labels.buscarProductos;
    @track placeholderFamily = this.labels.buscarFamilia;
    @track initialSelection = [];
    @track initialCliente = [];
    @track errors = [];
    @track errorsFamily = [];
    @track buscar = '';
    @track searchFamily = '';
    @track _idResult;
    @track isTipoOpe = true;
    @track isEca = true;
    @track isSindi = true;
    @track isSinCliente = false;
    @track isLinea = true;


    
    @api
	get idResult(){
		return this._idResult;
	}

    @wire(getOperacionPicklist, {})
    getOptionsOperacion({error,data}) {
        if(data){
            this.optionsTipoOpera=JSON.parse(JSON.stringify(data));
        }else if(error) {
            console.log(error);
        }
    }

    @wire(getRecord, { recordId: '$producto', fields: [NAME_FIELD] })
    wiredProdName({ error, data }) {
        if (data) {
            this.oportunidad = data.fields.Name.value;
            this.stageName=data.fields.Name.value;
            this.productoName=data.fields.Name.value;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getRecord, { recordId: '$pfId', fields: [PRODID_FIELD] })
    wiredProdId({ error, data }) {
        if (data) {
            this.producto = data.fields.AV_ProductoFicha__c.value;
        } else if(error) {
            console.log(error);
        }
    }

    connectedCallback(){
        if(this.valueOperacion!=undefined){
            this.valueOperacion=this.valueOperacion;
        }else{
            this.valueOperacion='Nueva';
        }
        this.getStatus();
    }

    getStatus(){
        getStatusValues({objectName: 'Opportunity', fieldName: 'StageName'})
            .then(result => {
                this.valuesOpp= result; //El resultado lo instanciamos en valuesOpp. la lista de los estados del path.
                this.pathValues(this.valuesOpp); //llamamos pathvalue 
            })
            .catch(error => {
                console.log(error);
        });
    }
    
    pathValues(listValues) { //pasandole lista estados y se guarda en allStage
        var aux = [];
        for(var value of listValues) {
            aux.push({value: value.value, label: value.label});
        }
        this.allStages = this.allStages.concat(aux);
    }

    handleFamilia(event){
        this.searchFamily = event.detail.searchTerm;
        lookupSearchFamily ({searchTerm: event.detail.searchTerm, producto: this.valueSubProducto })
        .then((results) => {
            this.template.querySelector('[data-id="clookupFamilyCIB"]').setSearchResults(results);
        })
        .catch((error) => {
            console.error('Lookup error', JSON.stringify(error));
            this.errorsFamily = [error];
        });
    }

    handleSelectFamily(event){
        this.errors = [];
		let targetId = event.target.dataset.id;
		const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
		if(selection.length !== 0){
				for(let sel of selection) {
					this.producto  = String(sel.id);
				}
		} else {
			this.producto = null;
            this.valueSubProducto =  null;
            this.template.querySelector('[data-id="clookupOpCIB"]').selection = [];
            this.template.querySelector('[data-id="clookupFamilyCIB"]').handleBlur();
		}
        this.sendData();
    }

    handleSearchFamilyClick(event) {
        if (this.producto == null) {
        lookupSearchFamily ({searchTerm: event.detail.searchTerm, producto: this.valueSubProducto })
            .then((results) => {
                this.template.querySelector('[data-id="clookupFamilyCIB"]').setSearchResults(results);
            })
            .catch((error) => {
                console.error('Lookup error', JSON.stringify(error));
                this.errorsFamily = [error];
            });            
        }
	}

    autoSelectFamily(valueProducto){
        lookupSearchFamily ({searchTerm: '', producto: valueProducto})
            .then((results) => {
                    let targetId = results[0].id;           
                    this.producto  = targetId;       
                    this.template.querySelector('[data-id="clookupFamilyCIB"]').selection = results[0];
            })
            .catch((error) => {
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleSearch(event) {
        if(this.producto !== null){
            lookupSearch ({searchTerm: event.detail.searchTerm, familia: this.producto })
                .then((results) => {
                    this.template.querySelector('[data-id="clookupOpCIB"]').setSearchResults(results);
                })
                .catch((error) => {
                    console.error('Lookup error', JSON.stringify(error));
                    this.errors = [error];
                });
        }
	}

    handleSubProducto(event){
        this.errors = [];
		let targetId = event.target.dataset.id;
		const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
		if(selection.length !== 0){
				for(let sel of selection) {
					this.valueSubProducto  = String(sel.id);
				}
                this.autoSelectFamily(this.valueSubProducto);
		} else {
			this.valueSubProducto = null;
            this.template.querySelector('[data-id="clookupOpCIB"]').handleBlur();
		}
        this.sendData();
    }

	handleSearchClick(event) {
		if (this.valueSubProducto == null) {
			lookupSearch ({searchTerm: event.detail.searchTerm, familia: this.producto })
				.then((results) => {
					this.template.querySelector('[data-id="clookupOpCIB"]').setSearchResults(results);
				})
				.catch((error) => {
					console.error('Lookup error', JSON.stringify(error));
					this.errors = [error];
				});
		}        
    }

    @wire(getCliente, {})
    getCliente({error,data}) {
        if(data){
            this.initialCliente=[{id: data, icon:'standard:account', title: 'Sin Cliente'}];  
                if(JSON.parse(JSON.stringify(data)) === this.cliente){
                    this.isSinCliente = true;
                }
        }else if(error) {
            console.log(error);
        }
    }

    handleSearchCliente(event) {
        searchCliente ({searchTerm: event.detail.searchTerm })
            .then((results) => {
                this.template.querySelector('[data-id="lookupCliente"]').setSearchResults(results);
                this.initialCliente=[{id: result[0].id, icon:result[0].icon, title: result[0].title}];
                this.sendData();

            })
            .catch((error) => {
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
	}

	handleSearchClienteClick(event) {
        searchCliente ({searchTerm: event.detail.searchTerm })
            .then((results) => {
                console.log('handleSearchCliente');
                console.log('searchTerm: '+ searchTerm);
                console.log(results);
                this.template.querySelector('[data-id="lookupCliente"]').setSearchResults(results);
                this.sendData();
                this.template.querySelector('c-av_-lookup').scrollIntoView();

            })
            .catch((error) => {
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }
    handleSelectCliente(event){
        this.errors = [];
		let targetId = event.target.dataset.id;
		const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
		if(selection.length !== 0){
				for(let sel of selection) {
					this.cliente  = String(sel.id);
				}
		} else {
			this.cliente = null;
            this.template.querySelector('[data-id="lookupCliente"]').selection = [];
            this.template.querySelector('[data-id="lookupCliente"]').handleBlur();
		}
        this.sendData();
        this.template.querySelector('[data-id="lookupCliente"]').handleBlur();
    }
    handleClienteLoseFocus(){
        this.template.querySelector('c-av_-lookup').scrollIntoView();
    }
    handleFamilyLoseFocus(){
        this.template.querySelector('c-av_-lookup').scrollIntoView();
    }
    handProductLoseFocus(){
        this.template.querySelector('c-av_-lookup').scrollIntoView();
    }

    handleESG(event){
        this.esg=event.target.checked;  
        this.sendData();
    }
    
    handleTipoOpera(event){
        this.valueOperacion=event.target.value;  
        this.sendData();
    }
    handleOportunidad(event){
        this.oportunidad=event.target.value;  
        this.sendData();
    }

    handlePropietario(event){
        this.propietario=event.target.value;  
        this.sendData();
    }

    handleConfidencial(event){
        this.confidencial=event.target.checked;  
        this.sendData();
    }

    handleECAs(event){
        this.ecas = event.target.checked;  
        this.sendData();
    }

    handleSindicaciones(event){
        this.sindicaciones = event.target.checked;  
        this.sendData();
    }

    handleLinea(event){
        this.linea = event.target.checked;  
        this.sendData();
    }

    @wire(getOpportunityFields, {productoName: '$valueSubProducto'})
    getOpportunityFields({error,data}) {
        this.isTipoOpe = true;
        this.isEca = true;
        this.isSindi = true;
        this.isLinea = true;   
        if(data){
            data.forEach(d => {
                    if(d == 'CIBE_TipoOperacion__c') {
                        this.isTipoOpe = false;
                    }
                    if(d == 'CIBE_ECAs__c') {
                        this.isEca = false;            
                    }
                    if(d == 'CIBE_Sindicaciones__c') {
                        this.isSindi = false;            
                    }
                    if(d == 'CIBE_Linea__c') {
                        this.isLinea = false;            
                    }
                });
        }else if(error) {
            console.log(error);
        }
    }
    


    handleCliente(event){
        this.cliente = event.target.value;
        this.sendData();
    }

    sendData() {
        this.dispatchEvent(
            new CustomEvent('datareport', {
                detail: {
                    producto: this.producto,
                    valueSubProducto: this.valueSubProducto,
                    valueOperacion: this.valueOperacion,
                    oportunidad: this.oportunidad,
                    propietario: this.propietario,
                    stageName: this.stageName,
                    confidencial: this.confidencial,
                    ecas: this.ecas,
                    sindicaciones: this.sindicaciones,
                    cliente : this.cliente, 
                    linea: this.linea
                }
            })
        );
    }
    
}