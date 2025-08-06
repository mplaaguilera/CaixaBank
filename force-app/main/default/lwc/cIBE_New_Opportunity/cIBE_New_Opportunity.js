import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";

import NAME_FIELD from '@salesforce/schema/Product2.Name';
import PRODID_FIELD from '@salesforce/schema/AV_ProductExperience__c.AV_ProductoFicha__c';

//Methods
import getOperacionPicklist     from '@salesforce/apex/CIBE_NewOpportunity_Controller.getTipoOperacionPicklist';
import getStatusValues          from '@salesforce/apex/CIBE_NewOpportunity_Controller.getStatusValues';
import getCliente               from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.getCliente';
import search                   from '@salesforce/apex/CIBE_NewOpportunity_Controller.search';
import getPaisPicklist          from '@salesforce/apex/CIBE_NewOpportunity_Controller.getPaisPicklist';



//Labels
import estadoOportunidad from '@salesforce/label/c.CIBE_EstadoOportunidad';
import productoLabel from '@salesforce/label/c.CIBE_Producto';
import productoDebeSerMMPP from '@salesforce/label/c.CIBE_ProductoDebeSerMMPP';
import productoNoMMPP from '@salesforce/label/c.CIBE_ProductoNoMMPP';
import confidencial from '@salesforce/label/c.CIBE_Confidencial';
import propietarioOportunidad from '@salesforce/label/c.CIBE_PropietarioOportunidad';
import tipoOperacion from '@salesforce/label/c.CIBE_TipoOperacion';
import nombreOportunidad from '@salesforce/label/c.CIBE_NombreOportunidad';
import esg from '@salesforce/label/c.CIBE_FinanciacionSostenible';
import clienteLabel from '@salesforce/label/c.CIBE_Cliente';
import anadirParticipanteLabel from '@salesforce/label/c.CIBE_AddOppTM';
import buscarProductos from '@salesforce/label/c.CIBE_BuscarProductos';
import comentario_label from '@salesforce/label/c.CIBE_Comentario';
import pais from '@salesforce/label/c.CIBE_Pais';



export default class cIBE_New_Opportunity extends NavigationMixin(LightningElement) {
    
    @api pfId; 
    @api developerName;
    @api producto;
    @api productoName;
    @api propietario;
    @api oportunidad;
    @api valueOperacion;
    @api valueSubProducto;
    @api comentario;
    @api stageName;
    @api confidencial;
    @api esg;
    @api cliente;
    @api anadirParticipante;
    @api valuePais = 'España'


    @track allStages = [];
    @track optionsSubProducto;
    @track optionsTipoOpera;
    @track optionsPais;
    @track optionsExito;
    @track OportunidadValue;
    @track showErrorMMPP=false;
    @track isSinCliente = false;
    @track initialSelection = [];
    @track errors = [];
    @track _pais = [];


    labels = {
        estadoOportunidad,
        productoLabel,
        productoDebeSerMMPP,
        productoNoMMPP,
        confidencial,
        propietarioOportunidad,
        tipoOperacion,
        nombreOportunidad,
        esg,
        clienteLabel,
        anadirParticipanteLabel,
        comentario_label,
        buscarProductos,
        pais
    }

    @track placeholder = this.labels.buscarProductos;
    
    connectedCallback(){
        if(this.valuePais == 'España'){
            this._pais.push('España');
        }
        let aux = this.valuePais.toString();
        aux = aux.replaceAll(',', ';');
       
        if(aux.includes(';')){
            let arr = aux.split(';'); 
            arr.forEach(element => {
                this._pais.push(element);
            });
            let valorNoRepetido = [...new Set(this._pais)];
            this._pais = valorNoRepetido;

        }else{
            this._pais.push(aux);
            let valorNoRepetido = [...new Set(this._pais)];
            this._pais = valorNoRepetido;
        }
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
    handleComentario(event){
        this.comentario = event.target.value;
        this.sendData();
    }

    handleTipoOpera(event){
        this.valueOperacion=event.target.value;  
        this.sendData();
    }

    handlePais(event){
        this.anadirParticipante = true;
        if(!this._pais.includes(event.target.value)){
            this._pais.push(event.target.value);
        }
        let aux = this._pais.toString();
        aux = aux.replaceAll(',', ';');
        this.valuePais = aux;
        if(aux === 'España'){
            this.anadirParticipante = false;
        }else{
            this.anadirParticipante = true;
        }
        this.sendData();
    }

    handleRemove(event){
        const valueRemoved = event.target.name;
        this._pais.splice(this._pais.indexOf(valueRemoved), 1);
        let aux = this._pais.toString();
        aux = aux.replaceAll(',', ';');
        this.valuePais = aux;
        if(aux === 'España'){
            this.anadirParticipante = false;
        }else if (aux == ''){
            this.anadirParticipante = false;
        }else{
            this.anadirParticipante = true;
        }
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
            Console.log(error);
        }
    }

    handleCliente(event){
        this.cliente = event.target.value;
        if(this.cliente == undefined) {
            this.oportunidad = '';
        }
        this.sendData();
    }


    @wire(getOperacionPicklist, {})
    getOptionsOperacion({error,data}) {
        if(data){
            this.optionsTipoOpera=JSON.parse(JSON.stringify(data));
            
        }else if(error) {
            Console.log(error);
        }
    }

    @wire(getPaisPicklist, {})
    getPais({error,data}) {
        if(data){
            this.optionsPais=JSON.parse(JSON.stringify(data));
            
        }else if(error) {
            Console.log(error);
        }
    }

    @wire(getRecord, { recordId: '$producto', fields: [NAME_FIELD] })
    wiredProdName({ error, data }) {
        if (data) {
            this.oportunidad = data.fields.Name.value;
            this.stageName=data.fields.Name.value;
            this.productoName=data.fields.Name.value;
        } else if (error) {
            Console.log(error);
        }

    }

    @wire(getRecord, { recordId: '$pfId', fields: [PRODID_FIELD] })
    wiredProdId({ error, data }) {
        if (data) {
            this.producto = data.fields.AV_ProductoFicha__c.value;

        } else if(error) {
            Console.log(error);
        }
    }

    getStatus(){
        getStatusValues({objectName: 'Opportunity', fieldName: 'StageName'})
            .then(result => {
                this.valuesOpp= result;
                this.pathValues(this.valuesOpp);
            })
            .catch(error => {
                Console.log(error);
        });
    }
    pathValues(listValues) {
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
                Console.error('Lookup error', JSON.stringify(error));
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
                    Console.error('Lookup error', JSON.stringify(error));
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
            this.template.querySelector('[data-id="clookupProductEMP"]').selection = [];
            this.template.querySelector('[data-id="clookupProductEMP"]').handleBlur();
		}
        this.sendData();
    }

    
    sendData() {

        this.dispatchEvent(new CustomEvent('datareport', {
            detail: {
                producto: this.producto,
                valueOperacion: this.valueOperacion,
                oportunidad: this.oportunidad,
                propietario: this.propietario,
                stageName: this.stageName,
                confidencial: this.confidencial,
                esg: this.esg,
                cliente: this.cliente,
                anadirParticipante: this.anadirParticipante,
                comentario: this.comentario,
                valuePais: this.valuePais
            }
        }));
    }

}