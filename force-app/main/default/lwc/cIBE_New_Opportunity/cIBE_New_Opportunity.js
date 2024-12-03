import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";

import NAME_FIELD from '@salesforce/schema/Product2.Name';
import PRODID_FIELD from '@salesforce/schema/AV_ProductExperience__c.AV_ProductoFicha__c';

//Methods
import getSubProductoValues 	from '@salesforce/apex/CIBE_NewOpportunity_Controller.getSubProductoPicklist';
import getOperacionPicklist     from '@salesforce/apex/CIBE_NewOpportunity_Controller.getTipoOperacionPicklist';
import getStatusValues          from '@salesforce/apex/CIBE_NewOpportunity_Controller.getStatusValues';
import getCliente               from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.getCliente';
import search                   from '@salesforce/apex/CIBE_NewOpportunity_Controller.search';


//Labels
import estadoOportunidad from '@salesforce/label/c.CIBE_EstadoOportunidad';
import productoLabel from '@salesforce/label/c.CIBE_Producto';
import productoDebeSerMMPP from '@salesforce/label/c.CIBE_ProductoDebeSerMMPP';
import subProducto from '@salesforce/label/c.CIBE_SubProducto';
import productoNoMMPP from '@salesforce/label/c.CIBE_ProductoNoMMPP';
import confidencial from '@salesforce/label/c.CIBE_Confidencial';
import propietarioOportunidad from '@salesforce/label/c.CIBE_PropietarioOportunidad';
import tipoOperacion from '@salesforce/label/c.CIBE_TipoOperacion';
import nombreOportunidad from '@salesforce/label/c.CIBE_NombreOportunidad';
import esg from '@salesforce/label/c.CIBE_ESG';
import clienteLabel from '@salesforce/label/c.CIBE_Cliente';
import anadirParticipanteLabel from '@salesforce/label/c.CIBE_AddOppTM';
import buscarProductos from '@salesforce/label/c.CIBE_BuscarProductos';




export default class cIBE_New_Opportunity extends NavigationMixin(LightningElement) {
    
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
    @api cliente;
    @api anadirParticipante;

    @track allStages = [];
    @track optionsSubProducto;
    @track optionsTipoOpera;
    @track optionsExito;
    @track OportunidadValue;
    @track showErrorMMPP=false;
    @track isSinCliente = false;

    @track initialSelection = [];
    @track errors = [];

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
        esg,
        clienteLabel,
        anadirParticipanteLabel,
        buscarProductos
    }

    @track placeholder = this.labels.buscarProductos;
    
    connectedCallback(){
        if(this.valueOperacion!=undefined){
            this.valueOperacion=this.valueOperacion;
        }else{
            this.valueOperacion='Nueva';
        }
        
        this.getStatus();
    }

    handleProducto(event){
        this.producto=event.target.value;
        if(this.producto == undefined) {
            this.oportunidad = '';
        }

        this.sendData();
    }
    handleSubProducto(event){
        if(this.productoName!='MMPP'){
            this.showErrorMMPP=true;
            this.valueSubProducto=null;
            event.target.value=null;
        }else{
            this.showErrorMMPP=false;
            this.valueSubProducto=event.target.value;  
        }
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

    handleESG(event){
        this.esg=event.target.checked;  
        this.sendData();
    }

    handleAnadirParticipante(event){
        this.anadirParticipante=event.target.checked;  
        this.sendData();
    }

    @wire(getCliente, {})
    getCliente({error,data}) {
        if(data){
            if(JSON.parse(JSON.stringify(data)) === this.cliente){this.isSinCliente = true}
        }else if(error) {
            console.log(error);
        }
    }

    handleCliente(event){
        this.cliente = event.target.value;

        if(this.cliente == undefined) {
            this.oportunidad = '';
        }

        this.sendData();
    }

    @wire(getSubProductoValues, {})
    getOptionsSubProducto({error,data}) {
        
        if(data){
            this.optionsSubProducto=JSON.parse(JSON.stringify(data));
            
        }else if(error) {
            console.log(error);
        }
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
    pathValues(listValues) { //pasándole lista estados y se guarda en allStage
        var aux = [];
        for(var value of listValues) {
            aux.push({value: value.value, label: value.label});
        }
        this.allStages = this.allStages.concat(aux);
    }

    handleSearch(event) {
        search ({searchTerm: event.detail.searchTerm})
            .then((results) => {
                this.template.querySelector('[data-id="clookupProductEMP"]').setSearchResults(results);
            })
            .catch((error) => {
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
        
	}

    handleSearchClick(event) {
        if (this.producto == null) {
            search ({searchTerm: event.detail.searchTerm})
                .then((results) => {
                    this.template.querySelector('[data-id="clookupProductEMP"]').setSearchResults(results);
                })
                .catch((error) => {
                    console.error('Lookup error', JSON.stringify(error));
                    this.errors = [error];
                });
        }
		      
    }

    handleSelect(event){
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
            this.template.querySelector('[data-id="clookupProductEMP"]').selection = [];
            this.template.querySelector('[data-id="clookupProductEMP"]').handleBlur();
		}
        this.sendData();
    }

    
    sendData() {
        this.dispatchEvent(new CustomEvent('datareport', {
            detail: {
                producto: this.producto,
                valueSubProducto: this.valueSubProducto,
                valueOperacion: this.valueOperacion,
                oportunidad: this.oportunidad,
                propietario: this.propietario,
                stageName: this.stageName,
                confidencial: this.confidencial,
                esg: this.esg,
                cliente: this.cliente,
                anadirParticipante: this.anadirParticipante
            }
        }));
    }
    
}