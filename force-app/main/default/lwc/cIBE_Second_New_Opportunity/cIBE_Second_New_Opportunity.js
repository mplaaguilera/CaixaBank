import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

//Methods
import { getObjectInfo }        from 'lightning/uiObjectInfoApi';
import { getPicklistValues }    from 'lightning/uiObjectInfoApi';

import getExitoPicklist 	    from '@salesforce/apex/cibe_secondNewOpportunity_Controller.getExitoPicklist';
import getAppDefinition 	    from '@salesforce/apex/cibe_secondNewOpportunity_Controller.getAppDefinition';
import OPPORTUNITY_OBJECT       from '@salesforce/schema/Opportunity';
import DIVISA_FIELD             from '@salesforce/schema/Opportunity.CIBE_Divisa__c';

//Labels

import fechaCierreLabel from '@salesforce/label/c.CIBE_FechaCierre';
import fechaEstimadaCierre from '@salesforce/label/c.CIBE_FechaEstimadaCierre';
import divisaLabel from '@salesforce/label/c.CIBE_Divisa';
import importe from '@salesforce/label/c.CIBE_Importe';
import probabilidadExito from '@salesforce/label/c.CIBE_ProbabilidadExito';
import impactoBalance from '@salesforce/label/c.CIBE_ImpactoBalance';
import disposicionMesCierreOportunidad from '@salesforce/label/c.CIBE_DisposicionMesCierreOportunidad';
import comisionesLabel from '@salesforce/label/c.CIBE_Comisiones';
import comisionesEstimadasMesCierreOportunidad from '@salesforce/label/c.CIBE_ComisionesEstimadasMesCierreOportunidad';
import productoEnOtraEntidad from '@salesforce/label/c.CIBE_ProductoEnOtraEntidad';
import entidadLabel from '@salesforce/label/c.CIBE_Entidad';
import fechaVtoLabel from '@salesforce/label/c.CIBE_FechaVto';
import precioLabel from '@salesforce/label/c.CIBE_Precio';
import margenLabel from '@salesforce/label/c.CIBE_Margen';
import fechaProxGestionLabel from '@salesforce/label/c.CIBE_FechaProxGestion';
import incluirClienteLabel from '@salesforce/label/c.CIBE_IncluirCliPriorizados';

export default class CIBE_Second_New_Opportunity extends NavigationMixin(LightningElement) {

    @api pfId; 
    @api developerName;
    @api productoid;
    @api fechaCierre;
    @api exito;
    @api balance;
    @api comisiones;
    @api entidad;
    @api fechaVto;
    @api precio;
    @api margen;
    @api divisa;
    @api AppDefinition;
    @api fechaProxGestion;
    @api incluirCliente = false;

    @api importeSaldo;
    @api numeroUnidades;
    @api valor;

    @track optionsExito;
    @track otraentidad;
    @track otraentidadpick;
    @track optionsDivisa;
    @track RT=false;
    
    labels = {
        fechaCierreLabel,
        fechaEstimadaCierre,
        divisaLabel,
        importe,
        probabilidadExito,
        impactoBalance,
        disposicionMesCierreOportunidad,
        comisionesLabel,
        comisionesEstimadasMesCierreOportunidad,
        productoEnOtraEntidad,
        entidadLabel,
        fechaVtoLabel,
        precioLabel,
        margenLabel,
        fechaProxGestionLabel,
        incluirClienteLabel
    }

    @track show = false;   
    toggle(event) {
        this.show = event.target.checked;
    }

    connectedCallback(){
        if(this.exito!=undefined){
            this.exito=this.exito;
        }else{
            this.exito='Media';
        }
        
        if(this.otraentidad == 'S') {
            this.otraentidadpick = 'S';
            this.hasOtherEntity = true;
            this.show = true;
        } else{
            this.hasOtherEntity = false;
        }
    }

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    opportunityMetadata;

    @wire(getPicklistValues, {'recordTypeId': '$opportunityMetadata.data.defaultRecordTypeId', 'fieldApiName': DIVISA_FIELD})
    getDivisaValues({error, data}) {
        if (data) {
            this.optionsDivisa = data.values;
        }
    }

    @wire(getExitoPicklist, {})
    getOptionsExito({error,data}) {
        if(data){
            this.optionsExito=JSON.parse(JSON.stringify(data));
        }else if(error) {
            console.log(error);
        }
    }

    @wire(getAppDefinition, {})
    getAppDefinition({error,data}) {
        if(data){
            if(data=='CIBE_MisClientesCIB'){
                this.RT=true;
            }else{
                this.RT=false
            }
            this.AppDefinition=data;
        }else if(error) {
            console.log(error);
        }
    }

    handleOtraEntidad(event){
        if(event.target.checked == true) {
            this.otraentidadpick = 'S';
        } else {
            this.otraentidadpick = 'N';
        }
        this.otraentidad = event.target.checked;
        this.toggle(event);
    }

    handleFechaGestion(event){
        this.fechaCierre=event.target.value;  
        this.sendData();
    }

    handleComisiones(event){
        this.comisiones=event.target.value;  
        this.sendData();
    }

    handleBalance(event){
        this.balance=event.target.value;  
        this.sendData();
    }
    
    handleEntidad(event){
        this.entidad=event.target.value;  
        this.sendData();
    }

    handleFechavto(event){
        this.fechaVto=event.target.value;  
        this.sendData();
    }

    handlePrecio(event){
        this.precio=event.target.value;  
        this.sendData();
    }

    handleMargen(event){
        this.margen=event.target.value;  
        this.sendData();
    }
    
    handleDivisa(event){
        this.divisa=event.target.value;  
        this.sendData();
    }

    handleExito(event){
        this.exito=event.target.value;  
        this.sendData();
    }

    handleFechaProxGestion(event){
        this.fechaProxGestion=event.target.value;  
        this.sendData();
    }

    handleIncluirCliente(event){
        this.incluirCliente=event.target.checked;
        this.sendData();
    }

    handleDataHijo(event){
    const returnValue = {
            detail: {
                fechaCierre: this.fechaCierre,
                balance: this.balance,
                comisiones: this.comisiones,
                entidad: this.entidad,
                fechaVto: this.fechaVto,
                precio: this.precio,
                margen: this.margen,
                AppDefinition: this.AppDefinition,
                divisa: this.divisa,
                exito: this.exito,
                importeSaldo:this.importeSaldo,
                numeroUnidades:this.numeroUnidades,
                fechaProxGestion: this.fechaProxGestion,
                incluirCliente: this.incluirCliente
                }
        };
        if(event.detail) {
            Object.keys(event.detail).forEach(key => {
                returnValue.detail[key] = event.detail[key];
                this[key] = event.detail[key];
            });
        }

        if(event.req) {
            Object.keys(event.req).forEach(key => {
                returnValue.req[key] = event.req[key];
                this[key] = event.req[key];
                if(this[req]){               
                    if(event.detail[key] === undefined){
                        returnValue.detail[key] = null;
                    }
                }
            });
        }
        this.sendDataToFlow(returnValue);
    }
    
    sendData() {
        this.importeSaldo = this.importeSaldo;
        this.sendDataToFlow({
            detail: {
                fechaCierre: this.fechaCierre,
                balance: this.balance,
                comisiones: this.comisiones,
                entidad: this.entidad,
                fechaVto: this.fechaVto,
                precio: this.precio,
                margen: this.margen,
                AppDefinition: this.AppDefinition,
                divisa: this.divisa,
                exito: this.exito,
                importeSaldo:this.importeSaldo,
                numeroUnidades:this.numeroUnidades,
                fechaProxGestion: this.fechaProxGestion,
                incluirCliente: this.incluirCliente
            }
        });
    }

    sendDataToFlow(returnValue) {
        this.dispatchEvent(new CustomEvent('datareport', returnValue));
    }

}