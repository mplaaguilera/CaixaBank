import { LightningElement, api, track } from 'lwc';
import retrieveRecords from '@salesforce/apex/EV_DataTablePO_Controller.getRecordsPO';
import retrieveActiveRecords from '@salesforce/apex/EV_DataTablePO_Controller.getRecordsPOActive';
import savePO from '@salesforce/apex/EV_DataTablePO_Controller.updateRecordsPO';
import volumenPO from '@salesforce/apex/EV_DataTablePO_Controller.callAPIVolumenPO';
import confirmationPO from '@salesforce/apex/EV_DataTablePO_Controller.callAPIConfirmationPO';
import retrieveStatePO from '@salesforce/apex/EV_DataTablePO_Controller.retrieveStatusPOCampaign';
import retrieveTypePO from '@salesforce/apex/EV_DataTablePO_Controller.getTypeOfEvent';
//DE75332	
import retrieveHasParent from '@salesforce/apex/EV_DataTablePO_Controller.getParent';
import getPicklistOptions from '@salesforce/apex/EV_DataTablePO_Controller.getPicklistValues';
import getCentroPromotorValues from '@salesforce/apex/EV_DataTablePO_Controller.getCentroPromotor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Labels
import EV_CALCULAR_PO from '@salesforce/label/c.EV_CalcularVolumenPO';
import EV_RECALCULAR_PO from '@salesforce/label/c.EV_RecalcularVolumenPO';
import EV_CONFIRMAR_PO from '@salesforce/label/c.EV_ConfirmarPO';
import EV_CANCEL from '@salesforce/label/c.EV_Cancel';
import EV_SAVE from '@salesforce/label/c.EV_Save';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

const actions = [
    { label: 'Edit', name: 'edit' }
];

const columns = [
    {label: '', fieldName: 'IdPO', type: 'text'},
    {label: '', fieldName: 'editableCriterioValue', type: 'boolean'},
    {label: 'Variable Adobe Campaign', fieldName: 'varPublicoObjetivo', type: 'text'},
    {label: 'Nombre de Variable', fieldName: 'variableName', type: 'text', typeAttributes:{label:{fieldName: 'variableName'}}},
    {label: 'Tipo de criterio', fieldName: 'criterioType', type: 'text'},
    {label: 'Valor del criterio', fieldName: 'criterioLabel', type: 'text'},
    {label: 'Valor del criterio', fieldName: 'criterioValue', type: 'text'},
    {label: 'Activo', fieldName: 'variableActive', type: 'boolean'},
    {type: "action", typeAttributes: {rowActions: actions}}
];

const columnsActive = [
    {label: '', fieldName: 'IdPO', type: 'text'},
    {label: '', fieldName: 'editableCriterioValue', type: 'boolean'},
    {label: 'Variable Adobe Campaign', fieldName: 'varPublicoObjetivo', type: 'text'},
    {label: 'Nombre de Variable', fieldName: 'variableNameURL', type: 'url', typeAttributes:{label:{fieldName: 'variableName'}}},
    {label: 'Tipo de criterio', fieldName: 'criterioType', type: 'text'},
    {label: 'Valor del criterio', fieldName: 'criterioLabel', type: 'text'},
    {label: 'Valor del criterio', fieldName: 'criterioValue', type: 'text'},
    {label: 'Activo', fieldName: 'variableActive', type: 'boolean'}
];

export default class Ev_dataPublicoObjetivo extends LightningElement {
    //recordId
    @api recid;

    //Columns for datatable
    @track showColumns;
    @track showColumnsActive;

    //Values PO for datatable
    @track recordsToDisplay;
    @track recordsToDisplayActive;

    //Others values
    @track recordIdRow; //Get Id row PO
    @track isTipoCriterio; //Get type of variable PO
    @track isValueCriterio; //Get value PO
    @track checked; //Get value checked if PO is active
    @track editValorCriterio; //It block input for IND
    @track isBankPrivate;
    @track removeValueWEALTH = 'BAI';
    @track removeValueBPR = 'BPR';

    
    //Control value and type list that you want send to API
    @track selectedValue;
    @track values = []; //Array list for multipicklist values
    @track labels = [];
    @track singleLabel;
    @track isValuesPicklist; //Variable for picklist values
    @track multiselect = true; //Get variable if PO is multipicklist
    @track selectedItemsToDisplay = '';
    @track isItemExists = false;
    @track arrayArgs;

    //Booleans for control type of variable PO(Opcional, Obligatorio, Obligatorio modificable...)
    @track isRequired = false;
    @track isChildCampaign = false;
    //DE75332
    @track hasParent = false;

    //Options for validation PO
    @track optionscanales = [];
    @track optionsidiomas = [];
    @track optionsClientType = [];
    @track optionsPerson = [];
    @track optionsCartera = [];
    @track optionsProvincia = [];
    
    
    
    //control windows Booleans
    @track showDT = true; //Boolean for show init PO in windows
    @track disabledButton = false; //Variable for control button
    @track casesSpinner; //Variable for active spinner
    @track successCalcPO; //Boolean for show PO active in windows
    @track openPopup = false; //Control edit windows in PO

    //Booleans for type of field PO
    @track channel = false;
    @track idioma = false;
    @track localOrgUnit_DES_DAN = false;
    @track localOrgUnit_DES_DT = false;
    @track location = false;
    @track recipient_Age_Minima = false;
    @track recipient_Age_Maxima = false;
    @track recipient_Client_ClientBusiness = false;
    @track recipient_Client_ClientSegment = false;
    @track recipient_client_cod_interlocutor = false;
    @track recipient_Client_COD_OFICINA_AVE = false;
    @track recipient_gender = false;
    @track recipient_person_personType = false;
    @track saturation = false;
    @track indicador = false;
    @track isOnlyValue = false;
    @track isMultiValue = false;
    @track isPickValue = false;

    //prueba
    @track isValueSelect = false;

    //fill labels
    label = {
        EV_CALCULAR_PO,
        EV_RECALCULAR_PO,
        EV_CONFIRMAR_PO,
        EV_CANCEL,
        EV_SAVE
    };

    connectedCallback() {
        let mycolumns = columns.filter(col => col.fieldName != 'IdPO' && col.fieldName != 'editableCriterioValue' && col.fieldName != 'varPublicoObjetivo' && col.fieldName != 'criterioValue');
        let mycolumnsActive = columnsActive.filter(col => col.fieldName != 'IdPO' && col.fieldName != 'editableCriterioValue' && col.fieldName != 'varPublicoObjetivo' && col.fieldName != 'criterioValue');
        this.showColumns = mycolumns;
        this.showColumnsActive = mycolumnsActive;
		this.retRecords();
        this.checkStatePO();
        this.checkCentroPromotor();
        this.checkTypePO();
        this.checkHasParent();
        this.getPicklist();
	}
    
    
    
    retRecords(){
		retrieveRecords({idEvento: this.recid})
        .then(result => {
            if(result != null && result.length > 0) {
                this.recordsToDisplay = result;
            }
	    })
    }

    handleRowActions(event){
        this.recordIdRow = event.detail.row.idPO;
        //this.editValorCriterio = event.detail.row.editableCriterioValue;
        this.openPopup = true;
        this.isTipoCriterio = event.detail.row.criterioType;
        if(event.detail.row.criterioType == 'Opcional'){
            this.isRequired = false;
        }else if(event.detail.row.criterioType == 'Obligatorio'){
            this.isRequired = true;
        }else if(event.detail.row.criterioType == 'Obligatorio modificable'){
            this.isRequired = true;
        }
        //DE75332
        if(this.isChildCampaign === true && this.hasParent === false && event.detail.row.criterioType == 'Obligatorio'){
            this.editValorCriterio= false;          
        }else if(this.isChildCampaign === true && this.hasParent === true && event.detail.row.criterioType == 'Obligatorio'){
            this.editValorCriterio= true;
            this.isRequired = false;
        }else if(this.isChildCampaign === true && event.detail.row.criterioType == 'Obligatorio modificable'){
            this.editValorCriterio= false;
            this.isRequired = true;
        }else if(this.isChildCampaign === true && event.detail.row.criterioType == 'Opcional'){
            this.editValorCriterio= false;
            this.isRequired = false;
        }else{
            this.editValorCriterio = event.detail.row.editableCriterioValue;
        }
        if(event.detail.row.varPublicoObjetivo == 'Channel'){
            this.channel = true;
            this.idioma = false;
            this.localOrgUnit_DES_DAN = false;
            this.localOrgUnit_DES_DT = false;
            this.location = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.recipient_gender = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = false;
            this.isMultiValue = true;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'Idioma'){
            this.idioma = true;
            this.channel = false;
            this.localOrgUnit_DES_DAN = false;
            this.localOrgUnit_DES_DT = false;
            this.location = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.recipient_gender = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = false;
            this.isMultiValue = true;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'LocalOrgUnit.DES_DAN'){
            this.localOrgUnit_DES_DAN = true;
            this.idioma = false;
            this.channel = false;
            this.localOrgUnit_DES_DT = false;
            this.location = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.recipient_gender = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = false;
            this.isMultiValue = true;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'LocalOrgUnit.DES_DT'){
            this.localOrgUnit_DES_DT = true;
            this.localOrgUnit_DES_DAN = false;
            this.location = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.recipient_gender = false;
            this.recipient_person_personType = false;
            this.channel = false;
            this.idioma = false;
            this.indicador = false;
            this.isOnlyValue = false;
            this.isMultiValue = true;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'Location'){
            this.location = true;
            this.channel = false;
            this.idioma = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.recipient_gender = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = false;
            this.isMultiValue = true;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'Recipient.Age.Minima'){
            this.recipient_Age_Minima = true;
            this.recipient_Age_Maxima = false;
            this.channel = false;
            this.idioma = false;
            this.location = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.recipient_gender = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = true;
            this.isMultiValue = false;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'Recipient.Age.Maxima'){
            this.recipient_Age_Maxima = true;
            this.channel = false;
            this.idioma = false;
            this.location = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.recipient_Age_Minima = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.recipient_gender = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = true;
            this.isMultiValue = false;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'Recipient.Client.ClientBusiness'){
            this.recipient_Client_ClientBusiness = true;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.channel = false;
            this.idioma = false;
            this.location = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.recipient_gender = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = false;
            this.isMultiValue = true;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'Recipient.Client.ClientSegment'){
            this.recipient_Client_ClientSegment = true;
            this.channel = false;
            this.idioma = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.location = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.recipient_gender = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = true;
            this.isMultiValue = false;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'Recipient.client.cod_interlocutor'){
            this.recipient_client_cod_interlocutor = true;
            this.recipient_Client_ClientSegment = false;
            this.channel = false;
            this.idioma = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.location = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.recipient_gender = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = true;
            this.isMultiValue = false;
            this.isPickValue = false;
            this.saturation = false;
            this.isValueSelect = true;
        }else if(event.detail.row.varPublicoObjetivo == 'Recipient.Client.COD_OFICINA_AVE'){
            this.recipient_Client_COD_OFICINA_AVE = true;
            this.channel = false;
            this.idioma = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.location = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.recipient_gender = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = false;
            this.isMultiValue = true;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'Recipient.gender'){
            this.recipient_gender = true;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.channel = false;
            this.idioma = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.location = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.recipient_person_personType = false;
            this.indicador = false;
            this.isOnlyValue = false;
            this.isMultiValue = true;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'Recipient.person.personType'){
            this.recipient_person_personType = true;
            this.recipient_gender = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.channel = false;
            this.idioma = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.location = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.indicador = false;
            this.isOnlyValue = false;
            this.isMultiValue = true;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo.startsWith('IND_')){
            this.indicador = true;
            this.recipient_person_personType = false;
            this.recipient_gender = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.channel = false;
            this.idioma = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.location = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.isOnlyValue = true;
            this.isMultiValue = false;
            this.isPickValue = false;
            this.saturation = false;
        }else if(event.detail.row.varPublicoObjetivo == 'Saturation_AC'){
            this.saturation = true;
            this.indicador = false;
            this.recipient_person_personType = false;
            this.recipient_gender = false;
            this.recipient_Client_COD_OFICINA_AVE = false;
            this.channel = false;
            this.idioma = false;
            this.recipient_client_cod_interlocutor = false;
            this.recipient_Client_ClientSegment = false;
            this.recipient_Client_ClientBusiness = false;
            this.recipient_Age_Minima = false;
            this.recipient_Age_Maxima = false;
            this.location = false;
            this.localOrgUnit_DES_DT = false;
            this.localOrgUnit_DES_DAN = false;
            this.isOnlyValue = true;
            this.isMultiValue = false;
            this.isPickValue = false;
            this.isValueSelect = true;
        }
    }

    handleFieldChangeActive(event) {
        this.checked = event.detail.checked;
        this.handleFieldChangeTipoCriterioChangeCheck();
        //prueba
        //this.isValueSelect = false;
    }

    handleFieldChangeTipoCriterioChangeCheck() {
        //DE75332
        if(this.isChildCampaign === true && (this.isTipoCriterio == 'Obligatorio modificable' || this.isTipoCriterio == 'Obligatorio')){
            this.isRequired = true;
        }else{
            this.isRequired = false;
        }if(this.isChildCampaign === false && (this.isTipoCriterio == 'Obligatorio modificable' || this.isTipoCriterio == 'Obligatorio')){
            this.isRequired = true;
        }
    }

    handleFieldChangeTipoCriterio(event) {
        this.isTipoCriterio = event.detail.value;
        if(this.isTipoCriterio == 'Opcional'){
            this.isRequired = false;
        }else if(this.isTipoCriterio == 'Obligatorio'){
            this.isRequired = true;
        }else if(this.isTipoCriterio == 'Obligatorio modificable'){
            this.isRequired = true;
        }
    }

    handleFieldChangeValorCriterio(event) {
        this.isValueCriterio = event.detail.value;
    }

    hanldeProgressValueChange(event) {
        this.isValuesPicklist = event.detail.value;
        this.values = event.detail.values;
        this.singleLabel = event.detail.label;
        this.labels = event.detail.labels;
    }

    //captures the retrieve event propagated from lookup component
    selectItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);        
    }

    //captures the remove event propagated from lookup component
    deleteItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    //displays the items in comma-delimited way
    displayItem(args){
        this.arrayArgs = [];
        args.map(element=>{
            this.arrayArgs.push(element.label);
        });

        this.isItemExists = (args.length>0);
        this.selectedItemsToDisplay = this.arrayArgs.join(', ');
        this.values = this.selectedItemsToDisplay;
        this.labels = this.selectedItemsToDisplay;
    }

    saveRecords(){
        if(this.isRequired == true && ((this.values.length === 0) || this.isValueCriterio)){
            if((this.recipient_Age_Minima || this.recipient_Age_Maxima) && this.isValueCriterio && (this.isValueCriterio < 1 || this.isValueCriterio > 99)){
                const evt = new ShowToastEvent({
                    message: 'El valor no es correcto, la edad tiene que ser entre 1 y 99.',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }else if(this.values.length === 0 && !this.isValueCriterio && !this.isValueSelect){
            const evt = new ShowToastEvent({
                message: 'El campo es obligatorio',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            }else{
            savePO({recordIdPO: this.recordIdRow, checked: this.checked, isTipoCriterio: this.isTipoCriterio, isValorCriterio: this.isValueCriterio, isValuesPicklist: this.isValuesPicklist, isLabelPicklist: this.singleLabel, isValuesMultipicklist:  this.values, isLabelsMultipicklist:  this.labels, isOnlyValue:  this.isOnlyValue, isMultiValue:  this.isMultiValue, isPickValue:  this.isPickValue, isChildCampaign:  this.isChildCampaign})
            .then(result => {
                if(result == 'OK') {
                    const evt = new ShowToastEvent({
                        message: 'Se ha actualizado correctamente el registro.',
                        variant: 'success',
                        mode: 'dismissable'
                        
                    });
                    this.dispatchEvent(evt);
                
                    this.openPopup = false;
                    this.values = [];
                    this.labels = [];
                    this.isValueCriterio = '';
                    //prueba
                    this.isValueSelect = false;
                    this.retRecords();
                }
	        })
        }
    }else{
        savePO({recordIdPO: this.recordIdRow, checked: this.checked, isTipoCriterio: this.isTipoCriterio, isValorCriterio: this.isValueCriterio, isValuesPicklist: this.isValuesPicklist, isLabelPicklist: this.singleLabel, isValuesMultipicklist:  this.values, isLabelsMultipicklist:  this.labels, isOnlyValue:  this.isOnlyValue, isMultiValue:  this.isMultiValue, isPickValue:  this.isPickValue, isChildCampaign: this.isChildCampaign})
        .then(result => {
            if(result == 'OK') {
                const evt = new ShowToastEvent({
                    message: 'Se ha actualizado correctamente el registro.',
                    variant: 'success',
                    mode: 'dismissable'
                    
                });
                this.dispatchEvent(evt);
            
                this.openPopup = false;
                this.values = [];
                this.labels = [];
                this.isValueCriterio = '';
                //prueba
                this.isValueSelect = false;
                this.retRecords();
            }
        })


    }    
    this.values = [];
    this.labels = [];
    this.isValueCriterio = '';
    //prueba
    this.isValueSelect = false;
    this.retRecords();
    }


    callVolumenPO(){
        for(let key in this.recordsToDisplay) {
            // Preventing unexcepted data
            if (this.recordsToDisplay.hasOwnProperty(key)) { 
                // Filtering the data in the loop
                console.log(key);
            }
        }
        this.casesSpinner = true;
        setTimeout(function(){
            this.casesSpinner = false;
        }.bind(this), 6000);

        volumenPO({idEvento: this.recid})
        .then(result => {
            if(result == '002') {
                const evt = new ShowToastEvent({
                    message: 'Se ha solicitado correctamente el cálculo del volumen público objetivo.',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                
                this.openPopup = false;
                this.retRecords();
            }
	    })

        
    }

    recalcularPO(){
        this.casesSpinner = true;
        setTimeout(function(){
            this.casesSpinner = false;
            this.successCalcPO = false;
            this.showDT = true;
        }.bind(this), 3000);

        this.retRecords();
    }

    checkStatePO(){
        retrieveStatePO({idEvento: this.recid})
        .then(result => {
            if(result == '001') {
                this.disabledButton = false;
            }else if(result == '002'){
                this.disabledButton = true;
            }else if(result == '003'){
                this.showDT = false;
                this.successCalcPO = true;
                retrieveActiveRecords({idEvento: this.recid})
                .then(result => {
                    if(result != null && result.length > 0) {
                        this.recordsToDisplayActive = result;
                    }
	            })
            }else if(result == '004'){
                this.disabledButton = true;
                this.showDT = false;
                this.successCalcPO = true;
                retrieveActiveRecords({idEvento: this.recid})
                .then(result => {
                    if(result != null && result.length > 0) {
                        this.recordsToDisplayActive = result;
                    }
	            })
            }
	    })
    }

    checkTypePO(){
        retrieveTypePO({idEvento: this.recid})
        .then(result => {
            if(result) {
                this.isChildCampaign = true;
            }else{
                this.isChildCampaign = false;  
            }
	    })
    }
    checkHasParent(){
        retrieveHasParent({idEvento: this.recid})
        .then(result => {
            if(result) {
                this.hasParent = true;
            }else{
                this.hasParent = false;  
            }
	    })
    }

    

    checkPO(){
        this.casesSpinner = true;
        setTimeout(function(){
            this.casesSpinner = false;
        }.bind(this), 6000);
        confirmationPO({idEvento: this.recid})
        .then(result => {
            if(result == 'OK') {
                const evt = new ShowToastEvent({
                    message: 'Se ha confirmado correctamente el cálculo del volumen público objetivo.',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                
                this.openPopup = false;
                this.retRecords();
            }
	    })
    }

    getPicklist(){
        getPicklistOptions()
        .then(result => {
            for(let i=0; i<result.length; i++){
                if(result[i].EV_PicklistName__c == 'optionscanales'){
                    this.optionscanales.push({label:result[i].Name, value:result[i].EV_Value__c});
                }else if(result[i].EV_PicklistName__c == 'optionsidiomas'){
                    this.optionsidiomas.push({label:result[i].Name, value:result[i].EV_Value__c});
                }else if(result[i].EV_PicklistName__c == 'optionsClientType'){
                    this.optionsClientType.push({label:result[i].Name, value:result[i].EV_Value__c});
                }else if(result[i].EV_PicklistName__c == 'optionsPerson'){
                    this.optionsPerson.push({label:result[i].Name, value:result[i].EV_Value__c});
                }else if(result[i].EV_PicklistName__c == 'optionsCartera' && this.isBankPrivate){
                    this.optionsCartera.push({label:result[i].Name, value:result[i].EV_Value__c});
                }else if(result[i].EV_PicklistName__c == 'optionsCartera' && !this.isBankPrivate){
                    this.optionsCartera.push({label:result[i].Name, value:result[i].EV_Value__c});
                    this.optionsCartera = this.optionsCartera.filter(value => value != this.removeValueWEALTH);
                }else if(result[i].EV_PicklistName__c == 'optionsProvincia'){
                    this.optionsProvincia.push({label:result[i].Name, value:result[i].EV_Value__c});
                }
            }
        })
    }

    checkCentroPromotor(){
        getCentroPromotorValues({idEvento: this.recid})
        .then(result => {
            if(result == '9338' || result == '9664') {
                this.isBankPrivate = true;
            }else{
                this.isBankPrivate = false;
            }
	    })
    }
    

    closeModal(){
        this.openPopup = false;
        //prueba
        this.isValueSelect = false;
    }
}