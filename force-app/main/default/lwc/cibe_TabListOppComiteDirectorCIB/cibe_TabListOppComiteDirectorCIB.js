import { LightningElement, wire, track, api } from 'lwc';
import getOpportunity from '@salesforce/apex/CIBE_TabListOppComiteDirectorCIB_Contr.getOpportunity';
import exportOpportunities from '@salesforce/apex/CIBE_TabListOppComiteDirectorCIB_Contr.exportOpportunities';
import countOpp from '@salesforce/apex/CIBE_TabListOppComiteDirectorCIB_Contr.countOpp';
import getContactName from '@salesforce/apex/CIBE_TabListOppComiteDirectorCIB_Contr.getContactName';
import getContactId from '@salesforce/apex/CIBE_TabListOppComiteDirectorCIB_Contr.getContactIds';
import getPicklistValues from '@salesforce/apex/CIBE_MassReassignOwner_Controller.picklistValues';
import getPicklistValuesDepen from '@salesforce/apex/CIBE_MassReassignOwner_Controller.picklistValuesDependency';

import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LWC_DATATABLE_CSS from '@salesforce/resourceUrl/CIBE_ComiteDirectorIcon'
import { loadStyle } from 'lightning/platformResourceLoader';

import USER_ID from '@salesforce/user/Id';

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
import pais from '@salesforce/label/c.CIBE_Pais';
import rar from '@salesforce/label/c.CIBE_RAR';
import rating from '@salesforce/label/c.CIBE_Rating';
import sindicaciones from '@salesforce/label/c.CIBE_Sindicaciones';
import segmentoRentabilidadEA from '@salesforce/label/c.CIBE_SegmentoRentabilidadEA';
import segmentoRentabilidadER from '@salesforce/label/c.CIBE_SegmentoRentabilidadER';
import segmentoRentabilidadGA from '@salesforce/label/c.CIBE_SegmentoRentabilidadGA';
import segmentoRentabilidadGR from '@salesforce/label/c.CIBE_SegmentoRentabilidadGR';



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
        linea,
        pais,
        rar,
        rating,
        sindicaciones,
        segmentoRentabilidadEA,
        segmentoRentabilidadER,
        segmentoRentabilidadGA,
        segmentoRentabilidadGR
    }

    @api recordId;
    //Picklist Hier
    @track picklistValues = null;
	@track picklistValues2 = null;
	@track picklistValues3 = null;
    @track picklistValues4 = null;

    @api userId = USER_ID;
    // Ids
	@track negocios = null;
    @track redesSegmentos = null;
	@track sectoresPaises = null;
    @track centrosCarteras = null;
    // Nombres placeholder
    @track negociosName = null;
    @track redesSegmentosName = null;
	@track sectoresPaisesName = null;
    @track centrosCarterasName = null;
    
    
    @track selectedItem = 'todas';
    @track checkedAll = true;

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
    @track rowOffset = 0;
    @track totalPage = 1;

    //Export
    @track buttExp = true;
	@api element; 
    @api downloadElement;
    @track todayDate = new Date();
    @track exportDisabled = false;
    
    columnHeader = [comiteDirectorL, cliente, grupoComercial, name, producto,  importe, divisa, tipoOperacion,  
        fechaCierre, impactoComisiones, impactoBalance, etapa,  pais, rating, rar, sindicaciones, confidencial, segmentoRentabilidadEA,segmentoRentabilidadER, segmentoRentabilidadGA, segmentoRentabilidadGR];

    getContactIds() {
        getContactId({ userId:USER_ID })
        .then(data => {
            if(data != null) {

                if (data.negocios && data.negocios.length > 0) {
                    this.negocios = data.negocios[0];
                    this.getDependencyPicklist('Negocios', data.negocios[0], this.inputObj);
                }
                if (data.redesSegmentos && data.redesSegmentos.length > 0) {
                    this.redesSegmentos = data.redesSegmentos[0];
                    this.getDependencyPicklist('Redes-Segmentos', data.redesSegmentos[0], this.inputObj);
                }
                if (data.sectoresPaises && data.sectoresPaises.length > 0) {
                    this.sectoresPaises = data.sectoresPaises[0];
                    this.getDependencyPicklist('Sectores-Paises', data.sectoresPaises[0], this.inputObj);
                }
                if (data.centrosCarteras && data.centrosCarteras.length > 0) {
                    this.centrosCarteras = data.centrosCarteras[0];
                }
            }

        })
        .catch(error => {
            console.log(error);
        })
    }
    
    getContactNames() {
        getContactName({ userId:USER_ID })
        .then(data => {
            if(data != null) {
                if (data.negocios && data.negocios.length > 0) {
                    this.negociosName = data.negocios[0];
                }
                if (data.redesSegmentos && data.redesSegmentos.length > 0) {
                    this.redesSegmentosName = data.redesSegmentos[0];
                }
                if (data.sectoresPaises && data.sectoresPaises.length > 0) {
                    this.sectoresPaisesName = data.sectoresPaises[0];
                }
                if (data.centrosCarteras && data.centrosCarteras.length > 0) {
                    this.centrosCarterasName = data.centrosCarteras[0];
                }
            }
        })
        .catch(error => {
            console.log(error);
        })
    }
    
	@wire(getPicklistValues, {inputField:'Negocios', inputObj: '$inputObj'})
    wiredPicklist({ data,error }){
        if(data){
            this.picklistValues = data;
        }else if(error){ 
            this.picklistValues = undefined;
            console.log(error);
        }
    }

    @wire(getOpportunity, { userId:USER_ID, offSet : '$offSet', negocios :'$negocios', redesSegmentos : '$redesSegmentos', sectoresPaises : '$sectoresPaises', centrosCarteras :'$centrosCarteras', comiteDirector : '$selectedItem' })
    wiredOpportunity(wiredData) {
        this._wiredData = wiredData;
        const {data, error} = wiredData;    
        this.isLoading = false;
        if(data!= undefined) {
                this.data = data.map((item) => {
                    const iconObj = {...item};
    
                    //empresa absoluta
                    if(item.empresaAbsoluta === 'Alta' || item.empresaAbsoluta === 'High'){
                        iconObj.priorityiconEA = "utility:record" ;
                        iconObj.classEstadoEA = 'classAlta'
                    }else if(item.empresaAbsoluta === 'Media Alta' || item.empresaAbsoluta === 'Medium High'){
                        iconObj.priorityiconEA = "utility:record" ;
                        iconObj.classEstadoEA = 'classMediaAlta'
                    }else if(item.empresaAbsoluta === 'Media' || item.empresaAbsoluta === 'Medium'){
                        iconObj.priorityiconEA = "utility:record" ;
                        iconObj.classEstadoEA = 'classMedia'
                    }else if(item.empresaAbsoluta === 'Media Baja' || item.empresaAbsoluta === 'Medium Low'){
                        iconObj.priorityiconEA = "utility:record" ;
                        iconObj.classEstadoEA = 'classMediaBaja'
                    }else if(item.empresaAbsoluta === 'Baja' || item.empresaAbsoluta === 'Low'){
                        iconObj.priorityiconEA = "utility:record" ;
                        iconObj.classEstadoEA = 'classBaja'
                    }else if(item.empresaAbsoluta === 'Morosos' || item.empresaAbsoluta === 'Default'){
                        iconObj.priorityiconEA = "utility:record" ;
                        iconObj.classEstadoEA = 'classBaMorosos'
                    }else if(item.empresaAbsoluta === 'Inactivos' || item.empresaAbsoluta === 'Inactive'){
                        iconObj.priorityiconEA = "utility:record" ;
                        iconObj.classEstadoEA = 'classInactivos'
                    }else if(item.empresaAbsoluta === 'Project Finance'){
                        iconObj.priorityiconEA = "utility:record" ;
                        iconObj.classEstadoEA = 'classFinanciacionProyecto'
                    }
    
                    //empresa relativa
    
                    if(item.empresaRelativa === 'Alta' || item.empresaRelativa === 'High'){
                        iconObj.priorityiconER = "utility:record" ;
                        iconObj.classEstadoER = 'classAlta'
                    }else if(item.empresaRelativa === 'Media Alta' || item.empresaRelativa === 'Medium High'){
                        iconObj.priorityiconER = "utility:record" ;
                        iconObj.classEstadoER = 'classMediaAlta'
                    }else if(item.empresaRelativa === 'Media' || item.empresaRelativa === 'Medium'){
                        iconObj.priorityiconER = "utility:record" ;
                        iconObj.classEstadoER = 'classMedia'
                    }else if(item.empresaRelativa === 'Media Baja' || item.empresaRelativa === 'Medium Low'){
                        iconObj.priorityiconER = "utility:record" ;
                        iconObj.classEstadoER = 'classMediaBaja'
                    }else if(item.empresaRelativa === 'Baja' || item.empresaRelativa === 'Low'){
                        iconObj.priorityiconER = "utility:record" ;
                        iconObj.classEstadoER = 'classBaja'
                    }else if(item.empresaRelativa === 'Morosos' || item.empresaRelativa === 'Default'){
                        iconObj.priorityiconER = "utility:record" ;
                        iconObj.classEstadoER = 'classBaMorosos'
                    }else if(item.empresaRelativa === 'Inactivos' || item.empresaRelativa === 'Inactive'){
                        iconObj.priorityiconER = "utility:record" ;
                        iconObj.classEstadoER = 'classInactivos'
                    }else if(item.empresaRelativa === 'Project Finance'){
                        iconObj.priorityiconER = "utility:record" ;
                        iconObj.classEstadoER = 'classFinanciacionProyecto'
                    }
    
    
                    //grupo absoluta
                    if(item.grupoAbsoluta === 'Alta' || item.grupoAbsoluta === 'High'){
                        iconObj.priorityiconGA = "utility:record" ;
                        iconObj.classEstadoGA = 'classAlta'
                    }else if(item.grupoAbsoluta === 'Media Alta' || item.grupoAbsoluta === 'Medium High'){
                        iconObj.priorityiconGA = "utility:record" ;
                        iconObj.classEstadoGA = 'classMediaAlta'
                    }else if(item.grupoAbsoluta === 'Media' || item.grupoAbsoluta === 'Medium'){
                        iconObj.priorityiconGA = "utility:record" ;
                        iconObj.classEstadoGA = 'classMedia'
                    }else if(item.grupoAbsoluta === 'Media Baja' || item.grupoAbsoluta === 'Medium Low'){
                        iconObj.priorityiconGA = "utility:record" ;
                        iconObj.classEstadoGA = 'classMediaBaja'
                    }else if(item.grupoAbsoluta === 'Baja' || item.grupoAbsoluta === 'Low'){
                        iconObj.priorityiconGA = "utility:record" ;
                        iconObj.classEstadoGA = 'classBaja'
                    }else if(item.grupoAbsoluta === 'Morosos' || item.grupoAbsoluta === 'Default'){
                        iconObj.priorityiconGA = "utility:record" ;
                        iconObj.classEstadoGA = 'classBaMorosos'
                    }else if(item.grupoAbsoluta === 'Inactivos' || item.grupoAbsoluta === 'Inactive'){
                        iconObj.priorityiconGA = "utility:record" ;
                        iconObj.classEstadoGA = 'classInactivos'
                    }else if(item.grupoAbsoluta === 'Project Finance'){
                        iconObj.priorityiconGA = "utility:record" ;
                        iconObj.classEstadoGA = 'classFinanciacionProyecto'
                    }
    
                    //grupo relativa
                    if(item.grupoRelativa === 'Alta' || item.grupoRelativa === 'High'){
                        iconObj.priorityiconGR = "utility:record" ;
                        iconObj.classEstadoGR = 'classAlta'
                    }else if(item.grupoRelativa === 'Media Alta' || item.grupoRelativa === 'Medium High'){
                        iconObj.priorityiconGR = "utility:record" ;
                        iconObj.classEstadoGR = 'classMediaAlta'
                    }else if(item.grupoRelativa === 'Media' || item.grupoRelativa === 'Medium'){
                        iconObj.priorityiconGR = "utility:record" ;
                        iconObj.classEstadoGR = 'classMedia'
                    }else if(item.grupoRelativa === 'Media Baja' || item.grupoRelativa === 'Medium Low'){
                        iconObj.priorityiconGR = "utility:record" ;
                        iconObj.classEstadoGR = 'classMediaBaja'
                    }else if(item.grupoRelativa === 'Baja' || item.grupoRelativa === 'Low'){
                        iconObj.priorityiconGR = "utility:record" ;
                        iconObj.classEstadoGR = 'classBaja'
                    }else if(item.grupoRelativa === 'Morosos' || item.grupoRelativa === 'Default'){
                        iconObj.priorityiconGR = "utility:record" ;
                        iconObj.classEstadoGR = 'classBaMorosos'
                    }else if(item.grupoRelativa === 'Inactivos' || item.grupoRelativa === 'Inactive'){
                        iconObj.priorityiconGR = "utility:record" ;
                        iconObj.classEstadoGR = 'classInactivos'
                    }else if(item.grupoRelativa === 'Project Finance'){
                        iconObj.priorityiconGR = "utility:record" ;
                        iconObj.classEstadoGR = 'classFinanciacionProyecto'
                    }
    
                    
                    return iconObj;
                    
                });
                if(this.data.length === 0 && this.totalPage !=1){
                    this.totalPage =  1;
                }
            this.isLoading = false;
        } else if(data === undefined) {
            this.resetFilters();
        }else if(error) {
            this.isLoading = false;
            console.log(error);
        }
    }

    @wire(countOpp, {  negocios :'$negocios', redesSegmentos : '$redesSegmentos', sectoresPaises : '$sectoresPaises', centrosCarteras :'$centrosCarteras', comiteDirector : '$selectedItem' })
        opportunityCount({ data,error }){
        if(data){
            this.totalPage = data != 0 ? Math.ceil(data / 10) : 1;
        }else if(error){ 
            console.log(error);
        }
        this.page = 1;
    }

    getOpportunityList (offSet, negocios, redesSegmentos, sectoresPaises, centrosCarteras){
        getOpportunity({ offSet : this.offSet, negocios : this.negocios, redesSegmentos : this.redesSegmentos, sectoresPaises : this.sectoresPaises, centrosCarteras : this.centrosCarteras })
        .then(result => {
            if(result != null) {
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
        // this.negociosName = this.placeHol;
        this.redesSegmentosName = this.placeHol;
        this.sectoresPaisesName = this.placeHol;
        this.centrosCarterasName = this.placeHol;
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
        this.data = null;
        this.getOpportunityList(this.offSet,this.negocios,this.redesSegmentos,this.sectoresPaises, this.centrosCarteras);
    }


    handleRadioChange(event){
        this.selectedItem = event.target.value;
        if(this.selectedItem == 'todas'){
            this.checkedAll  = true;
        }else {
            this.checkedAll  = false;
        }
        this.page = 1;
        this.offSet = 0;
        this.rowOffset = 0;
        refreshApex(this._wiredData);
    }

    resetRedesSegmentos(event){

        if(this.redesSegmentos == event.target.value){
            this.getDependencyPicklist('Redes-Segmentos', this.redesSegmentos, this.inputObj);
        }
    }

    connectedCallback() {
        loadStyle(this, LWC_DATATABLE_CSS);
        this.getContactIds();
        this.getContactNames();
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
        this.exportDisabled = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Exportacion',
                message : 'Su excel se está preparando para ser descargado.',
                variant : 'info',
                mode : 'sticky'
            }));

        exportOpportunities({negocios : this.negocios, redesSegmentos : this.redesSegmentos, sectoresPaises : this.sectoresPaises, centrosCarteras : this.centrosCarteras, comiteDirector : this.selectedItem})
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
                downloadElement.download = this.label.comiteDirectorL + ' CIB ' + (this.todayDate.getDate() + '-' + (this.todayDate.getMonth()+1) + '-' + this.todayDate.getFullYear()) + '.csv';
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
            CIBE_ComiteDirector__c:{}
        };

        const recordInputs = this.values.map(row => {
            var num = row.Id.replace('row-','');
            returnValues.Id = this.data[num].iden;
            returnValues.CIBE_ComiteDirector__c = row.comiteDirector !== undefined ? row.comiteDirector : this.data[num].comiteDirector;
            const fields = Object.assign({},returnValues);
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
        this.picklistValues2 = null;
        this.picklistValues3 = null;
        this.picklistValues4 = null;
        this.isLoading = false;
        this.page = 1;
        this.rowOffset = 0;
        this.negocios = null;
        this.redesSegmentos = null;
        this.sectoresPaises = null;
        this.centrosCarteras = null;
        this.negociosName = this.placeHol;
        this.redesSegmentosName = this.placeHol;
        this.sectoresPaisesName = this.placeHol;
        this.centrosCarterasName = this.placeHol;
        this.checkedAll  = true;
        this.selectedItem = 'todas';
        this.totalPage = 1;
    }

    previousHandler() {
        this.isLoading = true;
        this.page = this.page -1;
        this.offSet = this.offSet >= 10 ? (this.offSet - 10) : this.offSet;
        this.rowOffset = this.rowOffset - 10;
    }

    nextHandler() {
        this.isLoading = true;
        this.page = this.page +1;
        this.offSet = (this.offSet <= 1990) ? (this.offSet + 10) : this.offSet;
        this.rowOffset = this.rowOffset + 10;
    }

    staticColumns = [
        { label: comiteDirectorL, fieldName: 'comiteDirector', editable : true, type: 'boolean', cellAttributes: { alignment: 'center' }, initialWidth : 100}, 
        { label: cliente, fieldName: 'accountId', type: 'url', typeAttributes: { label: { fieldName: 'accountName' } } }


        // { label: numeroDocumento, fieldName: 'accountCif' }
        
    ];

    columns = [
        { label: grupoComercial, fieldName: 'grupoComercialId', type: 'url', typeAttributes: {label: { fieldName: 'grupoComercialName' } }},
        { label: name, fieldName: 'iden', type: 'url', typeAttributes: {label: { fieldName: 'name' } }},
        { label: producto, fieldName: 'pFId', type: 'url', typeAttributes: {label: { fieldName: 'pFName' } }},
        { label: importe, fieldName: 'amountDivisa', cellAttributes: { alignment: 'right' } },
        { label: divisa, fieldName: 'divisa' },
        { label: tipoOperacion, fieldName: 'tipoOperaciones' },
        { label: fechaCierre, fieldName: 'closeDate', type : 'date', typeAttributes : { day : '2-digit' , month : '2-digit', year : 'numeric' } },
        { label: impactoComisiones, fieldName: 'comisionesDivisa', cellAttributes: { alignment: 'right' }},
        { label: impactoBalance, fieldName: 'balanceDivisa', cellAttributes: { alignment: 'right' }},
        { label: etapa, fieldName: 'stageName' },
        { label: pais, fieldName: 'pais' },
        { label: rating, fieldName: 'rating', cellAttributes: { alignment: 'right' } },
        { label: rar, fieldName: 'rar', cellAttributes: { alignment: 'right' } },
        { label: sindicaciones, fieldName: 'sindicaciones', type: 'boolean', cellAttributes: { alignment: 'center' } },
        { label: confidencial, fieldName: 'confidencial', cellAttributes: { alignment: 'center' }, type: 'boolean'},
        { label: this.label.segmentoRentabilidadEA, fieldName : 'empresaAbsoluta',  type: 'text', cellAttributes: { iconName: { fieldName: 'priorityiconEA' }, class: {fieldName: 'classEstadoEA'}}},
        { label: this.label.segmentoRentabilidadER, fieldName : 'empresaRelativa',  type: 'text', cellAttributes: { iconName: { fieldName: 'priorityiconER' }, class: {fieldName: 'classEstadoER'}}},
        { label: this.label.segmentoRentabilidadGA, fieldName : 'grupoAbsoluta',  type: 'text', cellAttributes: { iconName: { fieldName: 'priorityiconGA' }, class: {fieldName: 'classEstadoGA'}}},
        { label: this.label.segmentoRentabilidadGR, fieldName : 'grupoRelativa',  type: 'text', cellAttributes: { iconName: { fieldName: 'priorityiconGR' }, class: {fieldName: 'classEstadoGR'}}}
    ];
    

}