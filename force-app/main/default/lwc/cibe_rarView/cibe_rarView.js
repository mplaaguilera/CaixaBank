import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

// Methods
import getSimulation from '@salesforce/apex/CIBE_RAR_Integration.getSimulation';
import saveOperation from '@salesforce/apex/CIBE_RAR_Integration.saveOperation';
import getUrl  from '@salesforce/apex/CIBE_RAR_Integration.getUrl';
import getSimulationId from '@salesforce/apex/CIBE_RAR_Integration.getSimulationId'
import getUrlPrecios  from '@salesforce/apex/CIBE_OpportunityComitePrecios.getUrl';
import sendEmailComitePrecio2  from '@salesforce/apex/CIBE_OpportunityEmail.sendEmailComitePrecio';
import getEmailSindicaciones  from '@salesforce/apex/CIBE_OpportunityEmail.getEmailSindicaciones';
import getEmailALM  from '@salesforce/apex/CIBE_OpportunityEmail.getEmailALM';
import getOpportunity from '@salesforce/apex/CIBE_OpportunityComite.getOpportunity';
import getLanguage from '@salesforce/apex/CIBE_OpportunityEmail.getLanguage';


// Fields
import SIMULATIONID from '@salesforce/schema/Opportunity.CIBE_Numero_de_Simulador__c';
import SIMULATIONTYPE from '@salesforce/schema/Opportunity.CIBE_Tipo_de_simulacion__c';
import CONJUNTO from '@salesforce/schema/Opportunity.CIBE_RARConjunto__c';
import PD from '@salesforce/schema/Opportunity.CIBE_RARPD__c';
import POST from '@salesforce/schema/Opportunity.CIBE_RARPost__c';
import SEVERIDAD from '@salesforce/schema/Opportunity.CIBE_RARSeveridad__c';
import MARGEN from '@salesforce/schema/Opportunity.CIBE_RARMargenDiario__c';
import COMISION from '@salesforce/schema/Opportunity.CIBE_RARComision12meses__c';
import PLAZO from '@salesforce/schema/Opportunity.CIBE_RARPlazoMeses__c';


import TIPO_SIMULA_OPP from '@salesforce/schema/Opportunity.CIBE_Tipo_de_simulacion__c';
import NUMBER_SIMULA_OPP from '@salesforce/schema/Opportunity.CIBE_Numero_de_Simulador__c';


import CREDITPORTFOLIORVW from '@salesforce/schema/Opportunity.CIBE_CreditPortAnalystReview__c';
import SYNDICATIONTEAMOPN from '@salesforce/schema/Opportunity.CIBE_SyndicationTeamOpinion__c';
import SYNDICATIONTEAM from '@salesforce/schema/Opportunity.CIBE_CredPortAnalystEmployee__c';
import CREDITPORTFOLIO from '@salesforce/schema/Opportunity.CIBE_SyndicationTeamEmployee__c';
import ALMEMPLOYEE from '@salesforce/schema/Opportunity.CIBE_DicALMEmployee__c';
import ALM from '@salesforce/schema/Opportunity.CIBE_DicALM__c';
import ALMCOMMENT from '@salesforce/schema/Opportunity.CIBE_DicALMComment__c';
import CREDITPORTFOLIODATE from '@salesforce/schema/Opportunity.CIBE_DateAnalystTeam__c';
import SYNDICATIONTEAMOPNDATE from '@salesforce/schema/Opportunity.CIBE_DateSyndicationTeam__c';
import ALMDATE from '@salesforce/schema/Opportunity.CIBE_DateALM__c';


//objects
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';

//Labels 
import accesoInforme from '@salesforce/label/c.CIBE_AccesoInforme';
import calcPrecios from '@salesforce/label/c.CIBE_CalculadoraPrecios';
import operaciones from '@salesforce/label/c.CIBE_RAROperations';
import simulacion from '@salesforce/label/c.CIBE_RARSimulation';
import accSimulacion from '@salesforce/label/c.CIBE_RARAccSimulation';
import saveOp from '@salesforce/label/c.CIBE_RARSaveOp';
import simLoadedText from '@salesforce/label/c.CIBE_RARSimLoadedText';
import simLoaded from '@salesforce/label/c.CIBE_RARSimLoaded';
import simLoadedError from '@salesforce/label/c.CIBE_RARSimLoadedError';
import opSaved from '@salesforce/label/c.CIBE_RAROpSaved';
import opSavedText from '@salesforce/label/c.CIBE_RAROpSavedText';
import opSavedError from '@salesforce/label/c.CIBE_RAROpSavedError';
import refreshSimulation from '@salesforce/label/c.CIBE_RARRefreshSimulation';

export default class Cibe_rarView extends LightningElement {

    @api recordId;
    @api objectApiName;
    conjunto = CONJUNTO;
    pd = PD;
    post = POST;
    severidad = SEVERIDAD;
    margen = MARGEN;
    comision = COMISION;
    @track simulationId = '';
    @track simulationType;
    @track url;
    operacionGuardada = false;
    @track operacionSeleccionada;
    @track selectedRow = [];
    @track operaciones = [];
    @track simulaciones = [];
    @track bGrupo = false;
    @track bEmpresa = false;
    @track bOperacionGuardada = false;
    @track cargando = true;
    @track bMeses = false;
    @track bNuevoGuardado = false;
    bExpanse = true;
    @track columns = [];


    fields = [SIMULATIONID, SIMULATIONTYPE];
    fieldsBlank = [CREDITPORTFOLIO, SYNDICATIONTEAMOPN, SYNDICATIONTEAM, CREDITPORTFOLIORVW, ALM, ALMCOMMENT, ALMEMPLOYEE, CREDITPORTFOLIODATE, SYNDICATIONTEAMOPNDATE, ALMDATE];

    

    @track tipoSimula = null;
    @track nSimula = null;
    @track ref_ext = null;
    @track urlprecios; 
    @track toggleIcon = "slds-section slds-is-open";
    @track bExpanse = true;
    buttonActive = false;
    @api id;
    @api label;

    @track emailSindicaciones;
    @track emailALM;

    @track labelEmailSindicaciones = 'CIBE_EmailSyndicateSales';
    @track labelEmailALM = 'CIBE_EmailALM';

    @track syndicateSales;
    @track alm;
    @track syndicateSalesValue;
    @track almValue;
    @track almComment;

    @track language;

    labels = {
        accesoInforme,
        calcPrecios,
        operaciones,
        simulacion,
        accSimulacion,
        saveOp,
        simLoaded,
        simLoadedText,
        simLoadedError,
        opSaved,
        opSavedText,
        opSavedError,
        refreshSimulation
    };



    @wire(getLanguage)
    getLanguage({ error, data }){
        if(data){
            this.language = data;
        } else if(error){
            console.log(error);
        }
    }



    @wire(getEmailSindicaciones, {label : 'CIBE_EmailSyndicateSales'})
    getEmailSindicaciones({ error, data }){
        if(data){
            this.emailSindicaciones = data;
        } else if(error){
            console.log(error);
        }
    }
    
    @wire(getEmailALM, { label : 'CIBE_EmailALM'})
    getEmailALM({ error, data }){
        if(data){
            this.emailALM = data;
        } else if(error){
            console.log(error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [TIPO_SIMULA_OPP, PLAZO] })
    getInformePrecios({ error, data }){

        if(data ){

            if(data.fields.CIBE_Tipo_de_simulacion__c.value =='Empresa'){
                this.tipoSimula ='SC';
                this.setButtonVisibility();
            }
            else if(data.fields.CIBE_Tipo_de_simulacion__c.value =='Grupo'){
                this.tipoSimula ='SG';
                this.setButtonVisibility();
            }
            if(data.fields.CIBE_RARPlazoMeses__c.value !== null && data.fields.CIBE_RARPlazoMeses__c.value !== 0){
                this.bMeses = true;
            } else {
                this.bMeses = false;
            }

        } else if(error){
            console.log(error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NUMBER_SIMULA_OPP] })
    getInformePreciosC({ error, data }){
        if(data){
            this.nSimula = data.fields.CIBE_Numero_de_Simulador__c.value;
            this.ref_ext = this.tipoSimula+this.nSimula;

        } else if(error){
            console.log(error);
        }
    }

        @wire(getUrlPrecios, { ref_ext: '$ref_ext' })
    getUrlInforme({ error, data }){
        if(data){
            this.urlprecios = data;
        } else if(error){
            console.log('getUrlInforme ',error);
        }
    }

    setButtonVisibility() {
        this.buttonActive = true;
    }

    //@track simulationType;
    @wire(getUrl, { simulationId: '$simulationId', simulationType: '$simulationType'})
    getUrlTF({ error, data }){
        if(data){
            this.url = data;
        } else if(error){
            console.log('getUrlTF ',error);
        }
    }

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    oppInfo({ data, error }) {
        if (data) {

            this.columns =[{ label: 'Alias', fieldName: 'alias', type: "text"},
            { label: data.fields.CIBE_RAROperationNumber__c.label, fieldName: 'operationNumber', type: "text"},
            { label: data.fields.CIBE_RARTipoOperacion__c.label, fieldName: 'productTypeName', type:"text", cellAttributes: { alignment: 'left' }},
            { label: data.fields.CIBE_RARImporte__c.label, fieldName: 'awardedAmount', type:"currency", cellAttributes: { alignment: 'right' }, typeAttributes: { currencyCode: 'EUR',  minimumFractionDigits: 0, maximumFractionDigits: 0  }}, 
            { label: data.fields.CIBE_RARPlazoMeses__c.label, fieldName: 'period', type:"number", cellAttributes: { alignment: 'right' }},
            { label: data.fields.CIBE_RARPlazoFecha__c.label, type:"date", cellAttributes: { alignment: 'right' }},
            { label: data.fields.CIBE_RARInteresDiferencial__c.label, fieldName: 'differential', type:"number", cellAttributes: { alignment: 'right' }},
            { label: data.fields.CIBE_RARIndiceReferencia__c.label, fieldName: 'referenceIndex', type: "number", cellAttributes: { alignment: 'center' }},
            { label: data.fields.CIBE_RARFloorindice__c.label, fieldName: 'hasWithoutFloorIndicator', type: "text", cellAttributes: { alignment: 'center' }},
            { label: data.fields.CIBE_ComisionSaldoMedio__c.label, fieldName: 'studyCommission', type: "currency", cellAttributes: { alignment: 'right' }, typeAttributes: { currencyCode: 'EUR',  minimumFractionDigits: 0, maximumFractionDigits: 0  }},
            { label: data.fields.CIBE_RARComisionApertura__c.label, fieldName:  'openingCommission' , type: "percent",  typeAttributes: {  maximumFractionDigits: 2}, cellAttributes: { alignment: 'right' }},
            // , typeAttributes: { currencyCode: 'EUR',  minimumFractionDigits: 0, maximumFractionDigits: 0  }
            { label: data.fields.CIBE_RAROperacionRar__c.label, fieldName: 'rar', sortable: "true", type: "number", cellAttributes: { alignment: 'right' },  typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 2  }},
            { label: data.fields.CIBE_RARGarantias__c.label, fieldName: 'guaranteeName', type: "text", cellAttributes: { alignment: 'right' }},
            { label: data.fields.CIBE_VAOperacion__c.label, fieldName: 'valueAdded', type: "currency", cellAttributes: { alignment: 'right' }, typeAttributes: { currencyCode: 'EUR',  minimumFractionDigits: 0, maximumFractionDigits: 0  }}];
        } else {
            console.log(error);
        }
    }


   connectedCallback(){

        getSimulationId({recordId: this.recordId})
        .then(result => {

            if(result !== null && result.CIBE_Numero_de_Simulador__c !== null && result.CIBE_Numero_de_Simulador__c !== undefined){
                
                this.simulationId = result.CIBE_Numero_de_Simulador__c;
                this.simulationType = result.CIBE_Tipo_de_simulacion__c;
                let simulationType = result.CIBE_Tipo_de_simulacion__c === 'Empresa' ? "CIBE_GetRARSimulation" : "CIBE_getRARSimuGroup";
                this.simulationCall(result.CIBE_Numero_de_Simulador__c, simulationType, null);
                //this.selectedRow.push(result.CIBE_RAROperationNumber__c);
            }
        })
        .catch(error => {
            console.log(error);
        });
        this.cargando = false;
    }

    handleExpandable() {
        
        if(this.bExpanse){
            this.bExpanse = false;
            this.toggleIcon = "slds-section"; 
        } else {
            this.bExpanse = true;
            this.toggleIcon = "slds-section slds-is-open";
        }
    }
    handleSubmit(event) {
        this.cargando = true;
        event.preventDefault();
        
        let fields = event.detail.fields;
        
        let simulationType = event.detail.fields.CIBE_Tipo_de_simulacion__c === 'Empresa' ? "CIBE_GetRARSimulation" : "CIBE_getRARSimuGroup";
        this.bNuevoGuardado = true;
        let validaCarga = this.simulationCall(fields.CIBE_Numero_de_Simulador__c, simulationType, fields);
        if(validaCarga === 'OK') {
            this.notifyUser(this.labels.simLoaded, this.labels.simLoadedText, 'success');
        }
    }

    toggleSection(event) {
        let buttonid = event.currentTarget.dataset.buttonid;
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section slds-is-close';
        }
    }

    simulationCall(simulationId, simulationType, fields){
        getSimulation({simulationId: simulationId, simulationType: simulationType, recordId: this.recordId})
        .then(result => {
            this.simulaciones = [];
            if(result.empresaResponse !== undefined){

                let oSimulacion = {};
                let simulacionesInt = [];
                let operacionesInt = [];

                operacionesInt = this.montarOperaciones(result.empresaResponse.operations, null);

                this.operaciones = operacionesInt;
                this.bEmpresa = true;
                this.bGrupo = false;

                oSimulacion.nombre = this.labels.simulacion + ' ' + result.empresaResponse.simulationId + ' ' + result.empresaResponse.customerId + ' ' + result.empresaResponse.customerName;
                oSimulacion.numero = result.empresaResponse.simulationId;
                oSimulacion.operaciones = operacionesInt;

                simulacionesInt.push(oSimulacion);
                this.simulaciones = simulacionesInt;
                let accordion = this.template.querySelector('lightning-accordion');
                accordion.activeSectionName = result.empresaResponse.simulationId;         
                this.selectedRow.push(result.empresaResponse.operationNumber);
                
            } else {
                let simulacionesInt = [];
                result.grupoResponse.simulations.forEach(simulacion => {
                    let oSimulacion = {};
                    let operacionesPorSim = [];
                    operacionesPorSim = this.montarOperaciones(simulacion.operations, simulacion);
                    oSimulacion.nombre = this.labels.simulacion + ' ' + simulacion.simulationId + ' ' + simulacion.customerId + ' ' + simulacion.customerName;
                
                    oSimulacion.operaciones = operacionesPorSim;
                    
                    oSimulacion.numero = simulacion.simulationId;

                    oSimulacion.pd = simulacion.pd;
                    oSimulacion.rating = simulacion.ratingInt;

                    oSimulacion.lgd = simulacion.lgd;
                    
                    if(simulacion.simulationOperationsProfitabilities !== undefined) {
                        oSimulacion.netProfitability = simulacion.simulationOperationsProfitabilities.netProfitability;
                    } else {
                        oSimulacion.netProfitability = null;
                    }

                    if(simulacion.priceNote !== undefined) {
                        oSimulacion.commissions = simulacion.priceNote.commissions;
                    } else {
                        oSimulacion.commissions = null;
                    }   
                    this.marcarSimulacion(result.grupoResponse, oSimulacion, simulacion);
                    simulacionesInt.push(oSimulacion);
                });
                this.simulaciones = simulacionesInt;
                this.bGrupo= true;
                this.bEmpresa = false;
            }
            this.cargando = false;

            if(this.bNuevoGuardado) {
                this.notifyUser(this.labels.simLoaded, this.labels.simLoadedText, 'success');
                this.fieldsBlank.CIBE_CreditPortAnalystReview__c = 'NO';
                this.fieldsBlank.CIBE_DateAnalystTeam__c = null;
                this.fieldsBlank.CIBE_CredPortAnalystEmployee__c = null;

                getOpportunity({recordId: this.recordId})
                .then(result => {


                    this.syndicateSales = result[0].CIBE_LoanSyndicateSales__c;
                    this.alm = result[0].CIBE_ALM__c;
                    this.syndicateSalesValue = result[0].CIBE_SyndicationTeamOpinion__c;
                    this.almValue = result[0].CIBE_DicALM__c;
                    this.almComment = result[0].CIBE_DicALMComment__c;

                    

                    if(this.syndicateSales && this.syndicateSalesValue != undefined){
                        this.fieldsBlank.CIBE_SyndicationTeamOpinion__c = null;
                        this.fieldsBlank.CIBE_SyndicationTeamEmployee__c = null;
                        this.fieldsBlank.CIBE_DateSyndicationTeam__c = null;
                        if(this.language === 'es'){
                            sendEmailComitePrecio2({templateDevName: 'CIBE_OppNotificacionRequerimentoNuevaActuacion_es', oportunidad: this.recordId, correo: this.emailSindicaciones})
                            .then((result) =>{
                            }).catch((error) =>{
                                console.log(error);
                            })
                        }else if(this.language === 'en_US'){
                            sendEmailComitePrecio2({templateDevName: 'CIBE_OppNotificacionRequerimentoNuevaActuacion_en', oportunidad: this.recordId, correo: this.emailSindicaciones})
                            .then((result) =>{
                            }).catch((error) =>{
                                console.log(error);
                            })
                        }
                    }
    
                    if(this.alm && (this.almValue != undefined || this.almComment != undefined)){
                        this.fieldsBlank.CIBE_DateALM__c = null;
                        this.fieldsBlank.CIBE_DicALMComment__c = null;
                        this.fieldsBlank.CIBE_DicALM__c = null;
                        this.fieldsBlank.CIBE_DicALMEmployee__c = null;
                        if(this.language === 'es'){
                            sendEmailComitePrecio2({templateDevName: 'CIBE_OppNotificacionRequerimentoNuevaActuacion_es', oportunidad: this.recordId, correo: this.emailALM})
                            .then((result) =>{
                            }).catch((error) =>{
                                console.log(error);
                            })
                        }else if(this.language === 'en_US'){
                            sendEmailComitePrecio2({templateDevName: 'CIBE_OppNotificacionRequerimentoNuevaActuacion_en', oportunidad: this.recordId, correo: this.emailALM})
                            .then((result) =>{
                            }).catch((error) =>{
                                console.log(error);
                            })
                        }
                        
                    }

                    this.template.querySelector('lightning-record-form').submit(fields);
                    this.template.querySelector('lightning-record-form').submit(this.fieldsBlank);
                    this.simulationId = this.fields.CIBE_Numero_de_Simulador__c;
                    this.simulationType = this.fields.CIBE_Tipo_de_simulacion__c;

                })
                .catch(error => {
                    console.log(error);
                });                
            }
            this.bNuevoGuardado = false;
            return 1;          

        })
        .catch(error => {
            this.cargando = false;
            this.notifyUser('Error', this.labels.simLoadedError + ' ' + error.body.message, 'error');
            return 'KO';
        })

    }

    montarOperaciones(operaciones, simulacion){
        let operacionesInt = [];
        operaciones.forEach(operacion => {
            let oOperacion = {};
            oOperacion.operationNumber = operacion.operationNumber;
            oOperacion.productTypeName = operacion.productTypeName;
            oOperacion.awardedAmount = operacion.amountPeriod.awardedAmount;
            oOperacion.period = operacion.amountPeriod.period;
            oOperacion.expirationDate = operacion.amountPeriod.expirationDate;
            oOperacion.differential = operacion.interest.differential;
            oOperacion.referenceIndex = operacion.interest.referenceIndex;
            oOperacion.hasWithoutFloorIndicator = operacion.interest.hasWithoutFloorIndicator;
            oOperacion.rar = operacion.profitability.rar;
            oOperacion.alias = operacion.description;
            oOperacion.studyCommission = operacion.studyCommission;
            oOperacion.openingCommission = operacion.openingCommission / 100; // Se divide entre 100 para que en la tabla se muestren bien los decimales ya que salesforce interpreta el tipo porcentaje como un decimal (si llega 12.1 y no se divide entre 100 sacará 1201, y no 12,1)           
            oOperacion.guaranteeName = "";
            operacion.guarantees.forEach(garantia =>{

                oOperacion.guaranteeName += garantia.guaranteeName + ', ';
                
            });
            if(oOperacion.guaranteeName !== "") {
                oOperacion.guaranteeName = oOperacion.guaranteeName.substring(0, oOperacion.guaranteeName.length - 2);
            }

            oOperacion.valueAdded = operacion.profitability.valueAdded;
            oOperacion.operacionGuardada = false;
            if(simulacion !== null) {

                oOperacion.simulationId = simulacion.simulationId;
                oOperacion.pd = simulacion.pd;
                oOperacion.lgd = simulacion.lgd;
                oOperacion.rating = simulacion.ratingInt;
                if(simulacion.simulationOperationsProfitabilities !== undefined) {
                    oOperacion.netProfitability = simulacion.simulationOperationsProfitabilities.netProfitability;
                } else {
                    oOperacion.netProfitability = null;
                }
                if(simulacion.priceNote !== undefined) {
                    oOperacion.commissions = simulacion.priceNote.commissions;
                } else {
                    oOperacion.commissions = null;
                }
                

            }
            
            operacionesInt.push(oOperacion);   
        });
        return operacionesInt;
    }

    marcarSimulacion(objetoSimulacion, oSimulacion, simulacion) {
        if(objetoSimulacion.simulationId === simulacion.simulationId){
            oSimulacion.operacionGuardada = true;
            this.selectedRow.push(objetoSimulacion.operationNumber);
            oSimulacion.nombre += ' ✅';
            const accordion = this.template.querySelector('lightning-accordion');
            accordion.activeSectionName = oSimulacion.numero;
        } else {
            oSimulacion.operacionGuardada = false;
        }
    }

    handleRowSelection(event) {

        let selectedRows=event.detail.selectedRows;
        let tablas = this.template.querySelectorAll('lightning-datatable');

        for(const tabla of tablas) {

            if(tabla.getSelectedRows().length === 0) {
                continue;
            }

            if((tabla.data.length > 1 && selectedRows.length === tabla.data.length && selectedRows[0].simulationId === tabla.getSelectedRows()[0].simulationId) 
            || selectedRows[0].simulationId !== tabla.getSelectedRows()[0].simulationId) {
                tabla.selectedRows = [];    
            } else if(selectedRows[0].simulationId === tabla.getSelectedRows()[0].simulationId) {

                if (selectedRows.length > 1) {
                    if(selectedRows.length === tabla.data.length){
                        selectedRows = tabla.selectedRows = [];
                    }else{

                        selectedRows = selectedRows.slice(1);
                        tabla.selectedRows = tabla.selectedRows.slice(1);

                    }
                    
                }
            }

            if(selectedRows.length === 1 && tabla.getSelectedRows().length > 0 
            && (selectedRows[0].simulationId === tabla.getSelectedRows()[0].simulationId || selectedRows[0] === tabla.getSelectedRows()[0].simulationId)){

                this.operacionSeleccionada = JSON.stringify(tabla.getSelectedRows());
            }
        }
        if(selectedRows.length === 0){

            this.operacionSeleccionada = [];
        }
        event.preventDefault();
    }

    handleSelect() {
        
        this.cargando = true;
        let operacion = JSON.parse(this.operacionSeleccionada);
        let oOperacion = [{
            operationNumber: operacion[0].operationNumber,
            description: operacion[0].alias,
            productTypeName: operacion[0].productTypeName,
            studyCommission: operacion[0].studyCommission,
            openingCommission: operacion[0].openingCommission,
            amountPeriod: {
                awardedAmount: operacion[0].awardedAmount,
                expirationDate: operacion[0].expirationDate,
                period: operacion[0].period
            },
            interest: {
                differential: operacion[0].differential,
                referenceIndex: operacion[0].referenceIndex,
                hasWithoutFloorIndicator: operacion[0].hasWithoutFloorIndicator === null || operacion[0].hasWithoutFloorIndicator === undefined ? false : operacion[0].hasWithoutFloorIndicator
            },
            profitability: {
                rar: operacion[0].rar,
                valueAdded: operacion[0].valueAdded
            },
            guarantees: [{
                guaranteeName: operacion[0].guaranteeName
            }]
        }];
        let simulacion = {};
        if(this.bGrupo) {
            simulacion = {
                simulationId: operacion[0].simulationId,
                pd: operacion[0].pd,
                ratingInt: operacion[0].rating,
                lgd: operacion[0].lgd,
                simulationOperationsProfitabilities: {
                    netProfitability: operacion[0].netProfitability
                },
                priceNote: {
                    commissions: operacion[0].commissions
                },
                operations: oOperacion
            };
        } else {
            simulacion = {
                simulationId: null,
                operations: oOperacion
            }
        }
        let intSimulaciones = this.simulaciones;
        saveOperation({jSONop: JSON.stringify(simulacion), recordId: this.recordId})
        .then(result => {
            this.bOperacionGuardada = true;
            for(const x in intSimulaciones){
                if(intSimulaciones[x].numero === operacion[0].simulationId || simulacion.simulationId === null){
                    if(!intSimulaciones[x].operacionGuardada){
                        intSimulaciones[x].operacionGuardada = true;
                        intSimulaciones[x].nombre = intSimulaciones[x].nombre + ' ✅';
                    }
                } else {
                    if(intSimulaciones[x].operacionGuardada){
                        intSimulaciones[x].nombre = intSimulaciones[x].nombre.substring(0, intSimulaciones[x].nombre.length - 2);
                        intSimulaciones[x].operacionGuardada = false;
                    }
                }
            }
            //para hacer saltar el track
            this.simulaciones = intSimulaciones;
            this.dispatchEvent(new RefreshEvent());
            this.cargando = false;
            this.notifyUser(this.labels.opSaved, this.labels.opSavedText, 'success');
        })
        .catch(error => {
            console.log(error);
            this.cargando = false;
            this.notifyUser('Se ha producido un error', this.labels.opSavedError + ' ' + error.body.message, 'error');
        })
    }
    handleRefresh() {
        this.cargando = true;
        this.bNuevoGuardado = true;
        let validaCarga = this.simulationCall(this.simulationId, 'refrescar', null);
        if(validaCarga === 'OK') {
            this.notifyUser(this.labels.simLoaded, this.labels.simLoadedText, 'success');
        }
        
    }
    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }

    notifyUser(title, message, variant) {
		if (this.notifyViaAlerts) {
			// Notify via alert
			// eslint-disable-next-line no-alert
			alert(`${title}\n${message}`);
		} else {
			// Notify via toast
			const toastEvent = new ShowToastEvent({ title, message, variant });
			this.dispatchEvent(toastEvent);
		}
	}
}