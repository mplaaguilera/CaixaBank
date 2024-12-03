import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

//Methods
import { getObjectInfo }        from 'lightning/uiObjectInfoApi';
import { getPicklistValues }    from 'lightning/uiObjectInfoApi';

import getExitoPicklist 	    from '@salesforce/apex/cibe_secondNewOpportunity_CIB_Controller.getExitoPicklist';
import getAppDefinition 	    from '@salesforce/apex/cibe_secondNewOpportunity_CIB_Controller.getAppDefinition';
import OPPORTUNITY_OBJECT       from '@salesforce/schema/Opportunity';
import DIVISA_FIELD             from '@salesforce/schema/Opportunity.CIBE_Divisa__c';
import getOpportunityFields     from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.getOpportunityFields';


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
import impactFinAn from '@salesforce/label/c.CIBE_ImpactoFinAnio';	
import impactoBalFinAnio from '@salesforce/label/c.CIBE_ImpactoBalFinAnio';	
import fechaProxGestionLabel from '@salesforce/label/c.CIBE_FechaProxGestion';
import incluirClienteLabel from '@salesforce/label/c.CIBE_IncluirCliPriorizados';

    export default class CIBE_Second_New_Opportunity_CIB extends NavigationMixin(LightningElement) {
        
        @api pfId; 
        @api developerName;
        @api productoid;

        @api impactoComFinA;
        @api impactoBalFinA;
        @api fechaCierre;
        @api exito;
        @api importeSaldo;
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

        @track optionsExito;
        @track otraentidad;
        @track otraentidadpick;
        @track optionsDivisa;
        @track RT=false;

        @track isComDivisa = true;
        @track isImpComisiones = true;
        @track isBalance = true;
        @track isImporte = true;
        @track isDivisa = true;
        @track isImpBalance = true;   

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
            impactFinAn,
            impactoBalFinAnio,
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
        handleImporteSaldo(event){
            this.importeSaldo=event.target.value;  
            this.sendData();
        }
        handleComisiones(event){
            this.comisiones=event.target.value;  
            this.sendData();
        }
        handleExito(event){
            this.exito=event.target.value;  
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
        handleImpactoFinAn(event){
            this.impactoComFinA=event.target.value;  
            this.sendData();
        }
        handleImpactoBalFinAn(event){
            this.impactoBalFinA=event.target.value;  
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

        @wire(getOpportunityFields, {productoName: '$productoid'})
        getOpportunityFields({error,data}) {
            this.isComDivisa = true;
            // this.isImpComisiones = true;
            this.isBalance = true;
            this.isImporte = true;
            this.isDivisa = true;  
            //this.isImpBalance = true; 

            if(data){
                data.forEach(d => {
                        if(d == 'CIBE_Divisa__c') {
                            this.isDivisa = false; 
                        }
                        if(d == 'CIBE_AmountDivisa__c') {
                            this.isImporte = false; 
                        }
                        if(d == 'CIBE_ComisionesDivisa__c') {
                            this.isComDivisa = false;            
                        }
                        /* if(d == 'CIBE_ImpactoDivisaComisionesCierreAnio__c') {
                            this.isImpComisiones = false;            
                        }
                        if(d == 'CIBE_ImpactoDivisaBalanceCierreAnio__c') {
                            this.isImpBalance = false;            
                        }*/
                        if(d == 'CIBE_BalanceDivisa__c') {
                            this.isBalance = false;
                        }
                    });
                    if(this.isComDivisa){
                        this.comisiones = 0;           
                    }
                    if(this.isBalance){
                        this.balance = 0;           
                    }
                    /*
                    if(this.isImpComisiones){
                        this.impactoComFinA = 0;           
                    }
                    if(this.isImpBalance){
                        this.impactoBalFinA = 0;           
                    }*/
                    if(this.isImporte){
                        this.importeSaldo = 0;           
                    }
            }else if(error) {
                console.log(error);
            }
        }

        sendData() {
            this.dispatchEvent(new CustomEvent('datareport', {
                detail: {
                    fechaCierre: this.fechaCierre,
                    exito: this.exito,
                    importeSaldo: this.importeSaldo,
                    balance: this.balance,
                    comisiones: this.comisiones,
                    entidad: this.entidad,
                    fechaVto: this.fechaVto,
                    precio: this.precio,
                    margen: this.margen,
                    AppDefinition: this.AppDefinition,
                    divisa: this.divisa,
                    impactoComFinA: this.impactoComFinA,
                    fechaProxGestion: this.fechaProxGestion,
                    incluirCliente: this.incluirCliente
                }
            }));
        }
    
    }