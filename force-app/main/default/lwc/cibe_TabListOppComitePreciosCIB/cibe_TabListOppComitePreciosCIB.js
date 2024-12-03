import { LightningElement, wire, track, api } from 'lwc';

import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

import getOpportunity from '@salesforce/apex/CIBE_TabListOppComitePreciosCIBContr.getOpportunity';
import exportOpportunities from '@salesforce/apex/CIBE_TabListOppComitePreciosCIBContr.exportOpportunities';

//Fields
import visto_FIELD from '@salesforce/schema/Opportunity.CIBE_Visto__c'
import opportunity_Object from '@salesforce/schema/Opportunity'
import vigenciOferta_FIELD from '@salesforce/schema/Opportunity.CIBE_VigenciaOferta__c'

//Labels
import cliente from '@salesforce/label/c.CIBE_Cliente';
import numeroDocumento from '@salesforce/label/c.CIBE_NumeroDocumento';
import grupoComercial from '@salesforce/label/c.CIBE_GrupoComercial';
import gruposEconomico from '@salesforce/label/c.CIBE_GrupoEconomico';
import name from '@salesforce/label/c.CIBE_Name';
import familia from '@salesforce/label/c.CIBE_Familia';
import producto from '@salesforce/label/c.CIBE_Producto';
import importe from '@salesforce/label/c.CIBE_Importe';
import divisa from '@salesforce/label/c.CIBE_Divisa';
import importeEuros from '@salesforce/label/c.CIBE_ImporteEuros';
import impactoBalance from '@salesforce/label/c.CIBE_ImpactoBalance';
import impactoComisiones from '@salesforce/label/c.CIBE_ImpactoComisiones';
import impactoBalanceEuros from '@salesforce/label/c.CIBE_ImpactoEnBalanceEuros';
import impactoComisionesEuros from '@salesforce/label/c.CIBE_ImpactoEnComisionesEuros';
import tipoOperacion from '@salesforce/label/c.CIBE_TipoOperacion';
import probabilidadExito from '@salesforce/label/c.CIBE_ProbabilidadExito';
import etapa from '@salesforce/label/c.CIBE_Stage';
import motivoCerrada from '@salesforce/label/c.CIBE_MotivoCerradaNegativa';
import fechaCierre from '@salesforce/label/c.CIBE_FechaCierre';
import diasUltimaGestion from '@salesforce/label/c.CIBE_DiasUltimaGestion';
import fechaDeAlta from '@salesforce/label/c.CIBE_FechaDeAlta';
import primerPropietario from '@salesforce/label/c.CIBE_PrimerPropietario';
import owner from '@salesforce/label/c.CIBE_Owner';
import esg from '@salesforce/label/c.CIBE_ESG';
import ecas from '@salesforce/label/c.CIBE_ECAs';
import algunaOperacionRAR from '@salesforce/label/c.CIBE_AlgunaOper';
import dictamenALM from '@salesforce/label/c.CIBE_DictamenALM';
import visto from '@salesforce/label/c.CIBE_Visto';
import nivel from '@salesforce/label/c.CIBE_Nivel';
import sindicaciones from '@salesforce/label/c.CIBE_Sindicaciones';
import observaciones from '@salesforce/label/c.CIBE_Observaciones';
import vigenciaOferta from '@salesforce/label/c.CIBE_VigenciaOferta';
import gestorInternacional from '@salesforce/label/c.CIBE_GestorInternacional';
import fechaComiteRiesgo from '@salesforce/label/c.CIBE_FechaComiteRiesgo';
import fechaComitePrecios from '@salesforce/label/c.CIBE_FechaComitePrecios';
import comitePrecio from '@salesforce/label/c.CIBE_ComitePrecio';
import centroCarteras from '@salesforce/label/c.CIBE_CentroCartera';
import sectoresPaises from '@salesforce/label/c.CIBE_SectorPais';
import redesSegmentos from '@salesforce/label/c.CIBE_RedeSeg';
import negocios from '@salesforce/label/c.CIBE_Negocio';
import gestorCliente from '@salesforce/label/c.CIBE_GestorCliente';
import gestorClienteCC from '@salesforce/label/c.CIBE_GestorClienteCC';
import reiniciar from '@salesforce/label/c.CIBE_Reiniciar';
import exportar from '@salesforce/label/c.CIBE_Exportar';
import fechaAprobacionPrecio from '@salesforce/label/c.CIBE_FechaAprobacionPrecio';
import fechaAprobacionPrecioDesde from '@salesforce/label/c.CIBE_FechaAprobacionPrecioDesde';
import fechaAprobacionPrecioHasta from '@salesforce/label/c.CIBE_FechaAprobacionPrecioHasta';
import anterior from '@salesforce/label/c.CIBE_Anterior';
import posterior from '@salesforce/label/c.CIBE_Posterior';
import oportunidades from '@salesforce/label/c.CIBE_Oportunidades';
import select from '@salesforce/label/c.CIBE_SeleccionaOpcion';
import confidencial from '@salesforce/label/c.CIBE_Confidencial';
import linea from '@salesforce/label/c.CIBE_Linea';

import pais from '@salesforce/label/c.CIBE_Pais';
import rating from '@salesforce/label/c.CIBE_Rating';
import RARSeveridad from '@salesforce/label/c.CIBE_RARSeveridad';
import RARPlazoVidaMediaMeses from '@salesforce/label/c.CIBE_RARPlazoVidaMediaMeses';
import RARIndiceReferencia from '@salesforce/label/c.CIBE_RARIndiceReferencia';
import RARInteresDiferencial from '@salesforce/label/c.CIBE_RARInteresDiferencial';
import RARPlazoVidaMediaFecha from '@salesforce/label/c.CIBE_RARPlazoVidaMediaFecha';
import RARPost from '@salesforce/label/c.CIBE_RARPost';
import comisionSaldoMedio from '@salesforce/label/c.CIBE_comisionSaldoMedio';
import RARComisionApertura from '@salesforce/label/c.CIBE_RARComisionApertura';
import RARGarantias from '@salesforce/label/c.CIBE_RARGarantias';
import impactoDivisaComisionesCierreAnio from '@salesforce/label/c.CIBE_impactoDivisaComisionesCierreAnio';
import impactoComisionesCierreAnio from '@salesforce/label/c.CIBE_impactoComisionesCierreAnio';
import RARConjunto from '@salesforce/label/c.CIBE_RAROperaciones';
import RAROperacionRar from '@salesforce/label/c.CIBE_RAR';
import VAOperacion from '@salesforce/label/c.CIBE_VAOperacion';
import RARMargenDiario from '@salesforce/label/c.CIBE_RARMargenDiario';
import RARComision12meses from '@salesforce/label/c.CIBE_RARComision12ultMeses';

export default class cibe_TabListOppComitePreciosCIB extends LightningElement {

    label = {
        comitePrecio,
        reiniciar,
        exportar,
        fechaAprobacionPrecio,
        fechaAprobacionPrecioDesde,
        fechaAprobacionPrecioHasta,
        anterior,
        posterior,
        oportunidades,
        select, 
        confidencial,
        linea, 
        fechaComitePrecios,
        owner,
        pais,
        gruposEconomico,
        grupoComercial,
        name,
        rating,
        RARSeveridad,
        RARPlazoVidaMediaMeses,
        tipoOperacion,
        producto,
        RARIndiceReferencia,
        RARInteresDiferencial,
        RARPlazoVidaMediaFecha,
        RARConjunto,
        RAROperacionRar,
        RARPost,
        comisionSaldoMedio,
        RARComisionApertura,
        RARGarantias,
        VAOperacion,
        RARMargenDiario,
        RARComision12meses,
        fechaCierre,
        impactoBalance,
        impactoDivisaComisionesCierreAnio,
        impactoComisiones,
        impactoComisionesCierreAnio,
        confidencial,
        ecas,
        algunaOperacionRAR,
        vigenciaOferta,
        dictamenALM,
        nivel,
        visto,
        sindicaciones,
        observaciones
    }

    @api recordId;

    oppVigencia = [];
    @track pickListOptions;
    oppVisto = [];
    @track pickListOptionsVisto;
    ecas;
	@track isLoading = true;
    
    errors;
    @track values = [];

    @track data;
	@track items = [];
	@track totalPage = 0;
    @track totalRecountCount = 0;
	@track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 20; 
	@track page = 1;
    @track rowOffset = 0;

    @track offSet = 0;
    @track fecha = null;
    @track fechaDesde = null;
    @track fechaHasta = null;

    @track exportDisabled = false;
    
columnHeader = [cliente, numeroDocumento, gruposEconomico, grupoComercial, name, fechaAprobacionPrecio, owner, 
        pais, rating, RARSeveridad, importe, divisa, RARPlazoVidaMediaMeses, RARPlazoVidaMediaFecha, tipoOperacion, producto, 
        RARIndiceReferencia, RARInteresDiferencial, RARConjunto, RAROperacionRar, RARPost, 
        comisionSaldoMedio, RARComisionApertura, RARGarantias, VAOperacion, RARMargenDiario, RARComision12meses, 
        fechaCierre, impactoBalance, impactoDivisaComisionesCierreAnio, impactoComisiones, impactoComisionesCierreAnio, 
        confidencial, ecas, algunaOperacionRAR, vigenciaOferta, dictamenALM, visto, nivel, sindicaciones, observaciones, linea];
    
    @track minDate = new Date();
    @track todayDate = new Date();

    @wire(getObjectInfo, {objectApiName: opportunity_Object})
    opportunityObjectMetadata;

    //fetch picklist options
    @wire(getPicklistValues, {recordTypeId: "$opportunityObjectMetadata.data.defaultRecordTypeId", fieldApiName: vigenciOferta_FIELD})
    wirePickList({ error, data }) {
        if (data) {
            this.oppVigencia = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, {recordTypeId: "$opportunityObjectMetadata.data.defaultRecordTypeId", fieldApiName: visto_FIELD})
    wirePickList2({ error, data }) {
        if (data) {
            this.oppVisto = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @track _wiredData;

    @wire(getOpportunity, { offSet : '$offSet', fecha : '$fecha', desde : '$fechaDesde', hasta : '$fechaHasta' })
    wiredOpportunity(wiredData) {
        this._wiredData = wiredData;
        const {data, error} = wiredData;
        
        if(data) {
            var options = [];
            var options2 = [];
            for(var key in this.oppVigencia){
                options.push({label : this.oppVigencia[key].label, value: this.oppVigencia[key].value})
            }

            for(var key in this.oppVisto){
                options2.push({label : this.oppVisto[key].label, value: this.oppVisto[key].value})
            }
            
            this.data = data.map(
                record  => Object.assign(
                    {
                        "AccountLink": record.accountId !== undefined ? "/" + record.accountId : "",
                        "ownerLink": record.ownerId !== undefined ? "/" + record.ownerId : "",
                        "firstOwnerLink": record.firstOwnerId !== undefined ? "/" + record.firstOwnerId : "",
                        "grupoComercialLink": record.grupoComercialId !== undefined ? "/" + record.grupoComercialId : "",
                        "OpportunityName": record.name,
                        "OpportunityLink": record.iden !== undefined ? "/" + record.iden : "",
                        "familiaLink": record.familiaId !== undefined ? "/" + record.familiaId : "",
                        "productoLink": record.pFId !== undefined ? "/" + record.pFId : "",
                        "pickListOptions" : options,
                        "pickListOptionsVisto": options2
                    },
                    record
                    ));
                    console.log('data Comite Precios');
        console.log(this.data);
            this.isLoading = false;
        } else if(error) {
            this.isLoading = false;
            console.log(error);
        }
    }

    connectedCallback() {
        const selectedEvent = new CustomEvent("renametab");
		this.dispatchEvent(selectedEvent);
    }

    get height() {
        return this.data !== null && this.data !== undefined && this.data.length >= 20 ? 'height: 410px' : '';
    }

    get disabledDate() {
        return this.fecha !== null;
    }

    get disabledDates() {
        return this.fechaDesde !== null || this.fechaHasta !== null;
    }
    
    get validateDate() {
		return (this.minDate.getFullYear()-2) + '-' + (this.minDate.getMonth()) + '-' + this.minDate.getDate();
	}

    get getHasPrevius() {
        return this.offSet <= 0;
    }

    get getHasNext() {
        return (this.offSet >= 2000 || (this.data !== null && this.data !== undefined && this.data.length < 20));
    }

    handleChangeDate(event){
        this.isLoading = true;
        this.offSet = 0;
        this.fecha = event.target.value;
    }
    
    handleChangeDateDesde(event){
        this.isLoading = true;
        this.offSet = 0;
        this.fechaDesde = event.target.value;
    }

    handleChangeDateHasta(event){
        this.isLoading = true;
        this.offSet = 0;
        this.fechaHasta = event.target.value;
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.values];
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.values = [...copyDraftValues];
        } else {
            this.values = [...copyDraftValues, updateItem];
        }
    }

    exportData() {
        console.log('Button click!');
        this.exportDisabled = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Exportacion',
                message : 'Su excel se está preparando para ser descargado.',
                variant : 'info',
                mode : 'sticky'
            }));

        exportOpportunities()
            .then(data => {
                let doc = '';
                this.columnHeader.forEach(element => {  
                    doc += element +';';        
                });
                doc += '\n';

                doc += data.join('');

                let downloadElement = document.createElement('a');
                downloadElement.href = 'data:application/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(doc);
                downloadElement.target = '_self';
                downloadElement.download = this.label.comitePrecio + ' ' + (this.todayDate.getDate() + '-' + (this.todayDate.getMonth()+1) + '-' + this.todayDate.getFullYear()) + '.csv';
                document.body.appendChild(downloadElement);
                downloadElement.click();
            })
            .catch(error => {
                console.log(error);
            })
            .finally(() => {
                this.exportDisabled = false;
            });
    }

    handleSave(event) {
        this.values = event.detail.draftValues;
        const returnValues = {
            Id: {},
            CIBE_Observaciones__c: {},
            CIBE_Sindicaciones__c : {},
            CIBE_Visto__c: {},
            CIBE_DictamenALM__c : {},
            CIBE_AlgunaOperRAR__c : {},
            CIBE_ECAs__c : {},
            CIBE_Nivel__c: {},
            CIBE_VigenciaOferta__c: {},
            AV_ClienteConfidencial__c: {},
            CIBE_Linea__c: {}
        };

        const recordInputs = this.values.map(row => {
            var num = row.Id.replace('row-','');
            returnValues.Id = this.data[num].iden;
            returnValues.CIBE_Observaciones__c = row.observaciones !== undefined ? row.observaciones : this.data[num].observaciones !== undefined ? this.data[num].observaciones : '',
            returnValues.AV_ClienteConfidencial__c = row.confidencial !== undefined ? row.confidencial : this.data[num].confidencial,
            returnValues.CIBE_Linea__c = row.linea !== undefined ? row.linea : this.data[num].linea,
            returnValues.CIBE_Sindicaciones__c = row.sindicaciones !== undefined ? row.sindicaciones : this.data[num].sindicaciones,
            returnValues.CIBE_ECAs__c = row.ecas !== undefined ? row.ecas : this.data[num].ecas,
            returnValues.CIBE_Visto__c = row.visto !== undefined ? row.visto : this.data[num].visto !== undefined ? this.data[num].visto : '',
            returnValues.CIBE_DictamenALM__c = row.dictamenALM !== undefined ? row.dictamenALM : this.data[num].dictamenALM,
            returnValues.CIBE_AlgunaOperRAR__c = row.algunaOperacionRAR !== undefined ? row.algunaOperacionRAR : this.data[num].algunaOperacionRAR,
            returnValues.CIBE_Nivel__c = row.nivel !== undefined ? row.nivel : this.data[num].nivel,
            returnValues.CIBE_VigenciaOferta__c = row.vigenciaOferta !== undefined ? row.vigenciaOferta : this.data[num].vigenciaOferta
            const fields = Object.assign({},returnValues);
            console.log(fields);
            return {fields} 
        });

        this.isLoading = true;
        this.errors = { rows: { } };
        const promises = recordInputs.map(iden => updateRecord(iden));
        Promise.allSettled(promises).then(results => {
            results.forEach((res, i) => {
                if(res.status === 'rejected') {
                    if(res.reason.body.output.errors[0].message) {
                        const key = event.detail.draftValues[i].Id;
                        this.errors.rows[key] = {
                            title : ' ',
                            messages : [res.reason.body.output.errors[0].message],
                            fieldNames : [...Object.keys(event.detail.draftValues[i]), 'AccountLink']
                        }
                    }
                }
            });
        }).finally(() => {
            this.values = [];

            refreshApex(this._wiredData).then(() => {
                this.isLoading = false;
            });
        });

    }

    handleCancel(){
        this.values = [];
    }

    resetFilters() {
        this.isLoading = true;
        this.offSet = 0;
        this.fecha = null;
        this.fechaDesde = null;
        this.fechaHasta = null;
        this.page = 1;
        this.rowOffset = 0;
    }

    previousHandler() {
        this.isLoading = true;
        this.page = this.page -1;
        this.offSet = this.offSet >= 20 ? (this.offSet - 20) : this.offSet;
        this.rowOffset = this.rowOffset - 20;
    }

    nextHandler() {
        this.isLoading = true;
        this.offSet = (this.offSet <= 1980) ? (this.offSet + 20) : this.offSet;
        this.page = this.page +1;
        this.rowOffset = this.rowOffset + 20;
    }

    staticColumns = [
        { label: cliente, fieldName: 'AccountLink', type: 'url', typeAttributes: { label: { fieldName: 'accountName' } } },
        { label: numeroDocumento, fieldName: 'accountCif' },
    { label: importe, fieldName: 'amountDivisa', cellAttributes: { alignment: 'right' }, initialWidth : 100 },
        { label: divisa, fieldName: 'divisa', initialWidth : 90 }
    ];

    columns = [
        { label: this.label.fechaComitePrecios, fieldName: 'fechaAprobacionPrecio', type : 'date', typeAttributes : { day : '2-digit' , month : '2-digit', year : 'numeric' } },
        { label: this.label.owner, fieldName: 'ownerLink', type: 'url', typeAttributes: {label: { fieldName: 'ownerName' } }},
        { label: this.label.pais, fieldName: 'pais', cellAttributes: { alignment: 'right' }},
        { label: this.label.gruposEconomico, fieldName: 'grupoEconomico' },
        { label: this.label.grupoComercial, fieldName: 'grupoComercialLink', type: 'url', typeAttributes: {label: { fieldName: 'grupoComercialName' } }},
        { label: this.label.name, fieldName: 'OpportunityLink', type: 'url', typeAttributes: {label: { fieldName: 'OpportunityName' } }},
        { label: this.label.rating, fieldName: 'rating' },
        { label: this.label.RARSeveridad, fieldName: 'RARSeveridad' },
        { label: this.label.RARPlazoVidaMediaMeses, fieldName: 'RARPlazoVidaMediaMeses' },
        { label: this.label.RARPlazoVidaMediaFecha, fieldName: 'RARPlazoVidaMediaFecha', type : 'date', typeAttributes : { day : '2-digit' , month : '2-digit', year : 'numeric' } },
        { label: this.label.tipoOperacion, fieldName: 'tipoOperaciones' },
        { label: this.label.producto, fieldName: 'productoLink', type: 'url', typeAttributes: {label: { fieldName: 'pFName' } }},
        { label: this.label.RARIndiceReferencia, fieldName: 'RARIndiceReferencia' },
        { label: this.label.RARInteresDiferencial, fieldName: 'RARInteresDiferencial' },
            { label: this.label.RARConjunto, fieldName: 'RARConjunto' },
            { label: this.label.RAROperacionRar, fieldName: 'RAROperacionRar' },
            { label: this.label.RARPost, fieldName: 'RARPost' },
    { label: this.label.comisionSaldoMedio, fieldName: 'comisionSaldoMedio' },
    { label: this.label.RARComisionApertura, fieldName: 'RARComisionApertura' },
        { label: this.label.RARGarantias, fieldName: 'RARGarantias' },
    { label: this.label.VAOperacion, fieldName: 'VAOperacion' },
    { label: this.label.RARMargenDiario, fieldName: 'RARMargenDiario' },
        { label: this.label.RARComision12meses, fieldName: 'RARComision12meses' },
        { label: this.label.fechaCierre, fieldName: 'closeDate', type : 'date', typeAttributes : { day : '2-digit' , month : '2-digit', year : 'numeric' } },
    { label: this.label.impactoBalance, fieldName: 'balanceDivisa', cellAttributes: { alignment: 'right' }},
    { label: this.label.impactoDivisaComisionesCierreAnio, fieldName: 'impactoDivisaComisionesCierreAnio' },
    { label: this.label.impactoComisiones, fieldName: 'comisionesDivisa', cellAttributes: { alignment: 'right' }},
    { label: this.label.impactoComisionesCierreAnio, fieldName: 'impactoComisionesCierreAnio'},
        { label: this.label.confidencial, fieldName: 'confidencial', cellAttributes: { alignment: 'center' }, type: 'boolean' },
        { label: this.label.ecas, fieldName: 'ecas', editable : true, type: 'boolean'},
        { label: this.label.algunaOperacionRAR, fieldName: 'algunaOperacionRAR', editable : true, type: 'boolean' },
        { label: this.label.vigenciaOferta, fieldName: 'vigenciaOferta', editable : true, type: 'picklistColumn', wrapText: true, typeAttributes: { options: { fieldName: 'pickListOptions' }, value: { fieldName: 'vigenciaOferta' }, placeholder: this.label.select } } ,
        { label: this.label.dictamenALM, fieldName: 'dictamenALM', editable : true, type: 'boolean' },
        { label: this.label.visto, fieldName: 'visto', editable : true, type: 'picklistColumnVisto', wrapText: true, typeAttributes: { options: { fieldName: 'pickListOptionsVisto' }, value: { fieldName: 'visto' }, placeholder: this.label.select } },
        { label: this.label.nivel, fieldName: 'nivel', editable : true },
        { label: this.label.sindicaciones, fieldName: 'sindicaciones', editable : true, type: 'boolean' },
        { label: this.label.observaciones, fieldName: 'observaciones', editable : true },
        { label: this.label.linea, fieldName: 'linea', cellAttributes: { alignment: 'center' }, type: 'boolean' }
    ];

}