import { LightningElement, wire, track, api } from 'lwc';
import getOpportunity from '@salesforce/apex/CIBE_TabListOppComiteDirectorCIB_Contr.getOpportunity';
import exportOpportunities from '@salesforce/apex/CIBE_TabListOppComiteDirectorCIB_Contr.exportOpportunities';
import getPicklistValues from '@salesforce/apex/CIBE_MassReassignOwner_Controller.picklistValues';
import getPicklistValuesDepen from '@salesforce/apex/CIBE_MassReassignOwner_Controller.picklistValuesDependency';

import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Labels
import cliente from '@salesforce/label/c.CIBE_Cliente';
import numeroDocumento from '@salesforce/label/c.CIBE_NumeroDocumento';
import grupoComercial from '@salesforce/label/c.CIBE_GrupoComercial';
import gruposEconomico from '@salesforce/label/c.CIBE_GrupoEconomico';
import name from '@salesforce/label/c.CIBE_Name';
import producto from '@salesforce/label/c.CIBE_Producto';
import importe from '@salesforce/label/c.CIBE_Importe';
import divisa from '@salesforce/label/c.CIBE_Divisa';
import importeEuros from '@salesforce/label/c.CIBE_ImporteEuros';
import impactoBalance from '@salesforce/label/c.CIBE_ImpactoBalance';
import impactoComisiones from '@salesforce/label/c.CIBE_ImpactoComisiones';
import impactoBalanceEuros from '@salesforce/label/c.CIBE_ImpactoEnBalanceEuros';
import impactoComisionesEuros from '@salesforce/label/c.CIBE_ImpactoEnComisionesEuros';
import tipoOperacion from '@salesforce/label/c.CIBE_TipoOperacion';
import etapa from '@salesforce/label/c.CIBE_Stage';
import fechaCierre from '@salesforce/label/c.CIBE_FechaCierre';
import owner from '@salesforce/label/c.CIBE_Owner';
import esg from '@salesforce/label/c.CIBE_ESG';
import fechaComiteRiesgo from '@salesforce/label/c.CIBE_FechaComiteRiesgo';
import fechaComitePrecios from '@salesforce/label/c.CIBE_FechaComitePrecios';
import centroLab from '@salesforce/label/c.CIBE_CentroCartera';
import sectoresLab from '@salesforce/label/c.CIBE_SectorPais';
import redesLab from '@salesforce/label/c.CIBE_RedeSeg';
import negociosLab from '@salesforce/label/c.CIBE_Negocio';
import reiniciar from '@salesforce/label/c.CIBE_Reiniciar';
import exportar from '@salesforce/label/c.CIBE_Exportar';
import fechaAprobacionPrecio from '@salesforce/label/c.CIBE_FechaAprobacionPrecio';
import anterior from '@salesforce/label/c.CIBE_Anterior';
import posterior from '@salesforce/label/c.CIBE_Posterior';
import oportunidades from '@salesforce/label/c.CIBE_Oportunidades';
import select from '@salesforce/label/c.CIBE_SeleccionaOpcion';
import confidencial from '@salesforce/label/c.CIBE_Confidencial';
import comiteDirectorL from '@salesforce/label/c.CIBE_ComiteDirector';
import linea from '@salesforce/label/c.CIBE_Linea';


export default class cibe_TabListOppComiteDirectorCIB extends LightningElement {

    label = {
        reiniciar,
        exportar,
        fechaAprobacionPrecio,
        anterior,
        posterior,
        oportunidades,
        select, 
        confidencial,
        comiteDirectorL,
        centroLab,
        sectoresLab,
        redesLab,
        negociosLab,
        linea
    }

    @api recordId;
    //Picklist Hier
    @track picklistValues = null;
	@track picklistValues2 = null;
	@track picklistValues3 = null;
    @track picklistValues4 = null;
	@track negocios = null;
    @track redesSegmentos = null;
	@track sectoresPaises = null;
    @track centroCartera = null;
    @api inputObj = 'Contact';
	//Precarga valores campos
	@track placeHol = select;
    comiteDirector;
	@track isLoading = true;
    errors;
    @track values = [];
    @track _wiredData;
    // Table
    @track data;
    @track page = 1;
    @track offSet = 0;

    //Export
    @track buttExp = true;
	@api element; 
    @api downloadElement;
    @track todayDate = new Date();
    @track exportDisabled = false;
    
    columnHeader = [cliente, numeroDocumento, importe, divisa, gruposEconomico, grupoComercial,  name, tipoOperacion, producto, 
        importeEuros, fechaCierre, impactoBalance, impactoComisiones, impactoBalanceEuros, impactoComisionesEuros, etapa, 
        fechaComitePrecios, fechaComiteRiesgo, negociosLab, redesLab, centroLab, sectoresLab, owner, esg, comiteDirectorL, confidencial, linea];

	@wire(getPicklistValues, {inputField:'Negocios', inputObj: '$inputObj'})
        wiredPicklist({ data,error }){
        if(data){
            this.picklistValues = data;
        }else if(error){ 
            this.picklistValues = undefined;
            console.log(error);
        }
    }

    @wire(getOpportunity, { offSet : '$offSet', negocios :'$negocios', redesSegmentos : '$redesSegmentos', sectoresPaises : '$sectoresPaises', centrosCarteras :'$centrosCarteras' })
    wiredOpportunity(wiredData) {
        this._wiredData = wiredData;
        const {data, error} = wiredData;
        this.isLoading = false;

        console.log('wiredOpportunity');
        console.log(wiredData);
        console.log(data);
        console.log(this.data);

        if(data!= undefined) {
            console.log('if '+data);
            this.data = data.map(
                record  => Object.assign(
                    {
                        "AccountLink": record.accountId !== undefined ? "/" + record.accountId : "",
                        "ownerLink": record.ownerId !== undefined ? "/" + record.ownerId : "",
                        "grupoComercialLink": record.grupoComercialId !== undefined ? "/" + record.grupoComercialId : "",
                        "OpportunityName": record.name,
                        "OpportunityLink": record.iden !== undefined ? "/" + record.iden : "",
                        "productoLink": record.pFId !== undefined ? "/" + record.pFId : ""
                    },
                    record
                ));
            this.isLoading = false;
        } else if(data === undefined) {
            this.resetFilters();
        }else if(error) {
            this.isLoading = false;
            console.log(error);
        }
    }

    getOpportunityList (offSet, negocios, redesSegmentos, sectoresPaises, centrosCarteras){
        getOpportunity({ offSet : this.offSet, negocios : this.negocios, redesSegmentos : this.redesSegmentos, sectoresPaises : this.sectoresPaises, centrosCarteras : this.centrosCarteras })
        .then(result => {
            if(result != null) {
                console.log('Result');
                console.log(result);

                this.data = result.map(
                    record  => Object.assign(
                        {
                            "AccountLink": record.accountId !== undefined ? "/" + record.accountId : "",
                            "ownerLink": record.ownerId !== undefined ? "/" + record.ownerId : "",
                            "grupoComercialLink": record.grupoComercialId !== undefined ? "/" + record.grupoComercialId : "",
                            "OpportunityName": record.name,
                            "OpportunityLink": record.iden !== undefined ? "/" + record.iden : "",
                            "productoLink": record.pFId !== undefined ? "/" + record.pFId : ""
                        },
                        record
                    ));
                this.isLoading = false;
            }else {
                this.resetFilters();
            }
        })
        .catch(error => {
            console.log(error);
            this.isLoading = false;
        })
    }

    getDependencyPicklist(inputFld, inputVal, inputObjt){
    getPicklistValuesDepen({inputField: inputFld, inputValue: inputVal, inputObj: inputObjt})
                    .then((data) => {
                        console.log('getPicklistValuesDepen');
                                console.log('inputVal');
                                console.log(inputVal);
                                console.log(this.negocios);
                                console.log(this.redesSegmentos);
                                console.log(this.sectoresPaises);
                            switch(inputVal){
                                case this.negocios:
                                    this.picklistValues2 = JSON.parse(JSON.stringify(data));
                                    if(data === null || data.length === 0 ) {
                                        this.picklistValues2 = JSON.parse(JSON.stringify(data));
                                    }									
                                break;
                                case this.redesSegmentos:
                                    this.picklistValues3 = JSON.parse(JSON.stringify(data));
                                    if(data === null || data.length === 0 ) {
                                        this.picklistValues3 = JSON.parse(JSON.stringify(data));
                                    }									
                                break;
                                case this.sectoresPaises:
                                    this.picklistValues4 = JSON.parse(JSON.stringify(data));
                                    break;
                            }
                        })
                        .catch(error => {
                            console.log('getPicklistValuesDepen');
                            console.log(error);
                        }
                    );
    }

    // Selección de valores
    handleValueChange(event){
        this.data = null;
        this.negocios = event.detail.value;
        this.redesSegmentos = null;
        this.centrosCarteras = null;
        this.sectoresPaises = null;
        this.picklistValues2 = null;
        this.picklistValues3 = null;
        this.picklistValues4 = null;
        this.getDependencyPicklist('Negocios', this.negocios, this.inputObj);
    }

    handleValueChange2(event){
        this.data = null;
        this.redesSegmentos = event.detail.value;
        this.centrosCarteras = null;
        this.sectoresPaises = null;
        this.picklistValues3 = null;
        this.picklistValues4 = null;
        this.getDependencyPicklist('Redes-Segmentos', this.redesSegmentos, this.inputObj);
    }

    handleValueChange3(event){
        this.data = null;
        this.sectoresPaises = event.detail.value;
        this.centrosCarteras = null;
        this.picklistValues4 = null;
        this.getDependencyPicklist('Sectores-Paises', this.sectoresPaises, this.inputObj);
    }

    handleValueChange4(event){
        this.centrosCarteras = event.detail.value;
        this.offSet = 0;
        console.log('handleValueChange4');
        console.log(this.centrosCarteras);
        this.data = null;
        this.getOpportunityList(this.offSet,this.negocios,this.redesSegmentos,this.sectoresPaises, this.centrosCarteras);
    }

    connectedCallback() {
        const selectedEvent = new CustomEvent("renametab");
		this.dispatchEvent(selectedEvent);
    }

    get height() {
        return this.data !== null && this.data !== undefined && this.data.length >= 10 ? 'height: 410px' : '';
    }

    get getHasPrevius() {
        return this.offSet <= 0;
    }

    get getHasNext() {
        return (this.offSet >= 2000 || (this.data !== null && this.data !== undefined && this.data.length < 10));
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
                downloadElement.download = 'Comite Director CIB ' + (this.todayDate.getDate() + '-' + (this.todayDate.getMonth()+1) + '-' + this.todayDate.getFullYear()) + '.csv';
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
        console.log('handleSave');
        console.log(event.detail.draftValues);

        this.values = event.detail.draftValues;
        const returnValues = {
            Id: {},
            CIBE_ComiteDirector__c:{}, 
            AV_ClienteConfidencial__c: {}
        };
        console.log(returnValues);

        const recordInputs = this.values.map(row => {
            var num = row.Id.replace('row-','');
            console.log(num);
            returnValues.Id = this.data[num].iden;
            returnValues.CIBE_ComiteDirector__c = row.comiteDirector !== undefined ? row.comiteDirector : this.data[num].comiteDirector;
            returnValues.AV_ClienteConfidencial__c = row.confidencial !== undefined ? row.confidencial : this.data[num].confidencial;
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
        console.log('resetFilters');

        this.isLoading = true;
        this.offSet = 0;
        this.picklistValues2 = null;
        this.picklistValues3 = null;
        this.picklistValues4 = null;
        this.negocios = null;
        this.redesSegmentos = null;
        this.centrosCarteras = null;
        this.sectoresPaises = null;
        this.isLoading = false;
    }

    previousHandler() {
        this.isLoading = true;
        this.offSet = this.offSet >= 10 ? (this.offSet - 10) : this.offSet;
    }

    nextHandler() {
        this.isLoading = true;
        this.offSet = (this.offSet <= 1990) ? (this.offSet + 10) : this.offSet;
    }

    staticColumns = [
        { label: cliente, fieldName: 'AccountLink', type: 'url', typeAttributes: { label: { fieldName: 'accountName' } } },
        { label: numeroDocumento, fieldName: 'accountCif' },
        { label: importe, fieldName: 'amountDivisa', cellAttributes: { alignment: 'right' }, initialWidth : 100 },
        { label: divisa, fieldName: 'divisa', initialWidth : 90 }
    ];

    columns = [
        { label: gruposEconomico, fieldName: 'grupoEconomico' },
        { label: grupoComercial, fieldName: 'grupoComercialLink', type: 'url', typeAttributes: {label: { fieldName: 'grupoComercialName' } }},
        { label: name, fieldName: 'OpportunityLink', type: 'url', typeAttributes: {label: { fieldName: 'OpportunityName' } }},
        { label: tipoOperacion, fieldName: 'tipoOperaciones' },
        { label: producto, fieldName: 'productoLink', type: 'url', typeAttributes: {label: { fieldName: 'pFName' } }},
        { label: importeEuros, fieldName: 'amountEuro', cellAttributes: { alignment: 'right' }},
        { label: fechaCierre, fieldName: 'closeDate', type : 'date', typeAttributes : { day : '2-digit' , month : '2-digit', year : 'numeric' } },
        { label: impactoBalance, fieldName: 'balanceDivisa', cellAttributes: { alignment: 'right' }},
        { label: impactoComisiones, fieldName: 'comisionesDivisa', cellAttributes: { alignment: 'right' }},
        { label: impactoBalanceEuros, fieldName: 'balance', cellAttributes: { alignment: 'right' }},
        { label: impactoComisionesEuros, fieldName: 'comisiones', cellAttributes: { alignment: 'right' }},
        { label: etapa, fieldName: 'stageName' },
        { label: fechaComitePrecios, fieldName: 'fechaAprobacionPrecio'},
        { label: fechaComiteRiesgo, fieldName: 'fechaComiteRiesgo'},
        { label: negociosLab, fieldName: 'negocios'},
        { label: redesLab, fieldName: 'redesSegmentos'},
        { label: centroLab, fieldName: 'centrosCarteras'},
        { label: sectoresLab, fieldName: 'sectoresPaises'},
        { label: owner, fieldName: 'ownerLink', type: 'url', typeAttributes: {label: { fieldName: 'ownerName' } }},
        { label: esg, fieldName: 'esg', type: 'boolean'},
        { label: comiteDirectorL, fieldName: 'comiteDirector', editable : true, type: 'boolean'}, 
        { label: confidencial, fieldName: 'confidencial', cellAttributes: { alignment: 'center' }, type: 'boolean'},
        { label: linea, fieldName: 'linea', cellAttributes: { alignment: 'center' }, type: 'boolean' }
    ];

}