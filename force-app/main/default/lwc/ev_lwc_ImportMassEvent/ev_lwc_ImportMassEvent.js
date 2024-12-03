/**
 *  VERSION         AUTHOR             USER_STORY       DATE               Description
 *   1.0            Carolina Lopez     US680535         04/08/2023         Init version
 *   1.1            Carolina Lopez     US680535         04/08/2023         Add field structure with data types, tooltips on name and howAsign fields,
										                                   progress indicator bar 
 *   1.2            Carolina Lopez     US680535         14/08/2023         Add confirmation popup.
 *   1.3            Carolina Lopez     US680535         23/08/2023         Add logic for sending data from child and parent component to method saveFieldRecord
 *                                                                         and logic creation of campaign and centros_objetivo
 *   1.4            Carolina Lopez     US680535         25/08/2023         Add logic handleDismiss and Toast to check assignment selection
 *   1.5            Carolina Lopez     US704873         09710/2023         Modify method saveFieldRecord to add campaign parameter.
 **/

import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi'; 
import CAMPAIGN_OBJECT from '@salesforce/schema/Campaign';
import getFieldCampaign from '@salesforce/apex/EV_ImportMassEvent_Controller.getCampaign';
import saveFieldRecord from '@salesforce/apex/EV_ImportMassEvent_Controller.saveRecords';
import createCampaign from '@salesforce/apex/EV_ImportMassEvent_Controller.createCamp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import altaMasiva from '@salesforce/apex/EV_ImportMassEvent_Controller.mtBatchAltaMasiva';
import centros from '@salesforce/apex/EV_ImportMassEvent_Controller.centros';

export default class Ev_lwc_ImportMassEvent extends LightningElement {
    @api recordId;
    isModalOpen = false;
    isModalInsertOpen = false;
    isFinish = false;
    @track isLoading = false;
    customSettingValue;
    insertCampaign;
    @track inserciones = '';
    @track campaignName = '';
    resultCampaign;
    totalCamp = 0;
    estadoFilter = '009';
    estadoFilterLabel = '';
    inputValue = 1;
    inputAforo = 1;
    valueAsign = '';
    isCentros = false;
    isIndividual = false;
    isResponsabilidad = false;
    campRestantes = 0;
    showButton = false;
    step = 1;
    currentStep = "1"; 
    showFirstPage = true;
    showSecondPage = false;
    showThirdPage = false;
    sumInsert = 0;
    quantity = 0;
    centrosInsert = 0;

    employeesFromChild = [];
    @track recordsList = [];

    connectedCallback(){
        this.handleGetCampaign();
        const selectedOption = this.optionsEstado.find(option => option.value === this.estadoFilter);
        this.estadoFilterLabel = selectedOption.label;
    }

    get optionsAsign() {
        return [
            {label:'Responsabilidad', value:'Responsabilidad'},
            {label:'Centros', value:'Centros'},
            {label:'Individual', value:'Individual'}
        ];
    }
    get optionsNegocio() {
		return [
            { label: 'Todos', value: 'TODOS' },
			{ label: 'Banca Empresas', value: 'EMP' },
            { label: 'Banca Corporativa', value: 'COR' },
            { label: 'Banca Privada', value: 'BPR' },
            { label: 'Banca Particulares', value: 'BPA' },
            { label: 'Negocios', value: 'NEG' },
            { label: 'Corporate Institutions Banking', value: 'CIB' },
            { label: 'Banca Emprendedores', value: 'MIC' },
            { label: 'Banca Promotores', value: 'PRO' },
            { label: 'Banca Premier', value: 'BPE' },
            { label: 'Internacional', value: 'INT' },
            { label: 'Seguros', value: 'SEG' },
            { label: 'Banca Privada. Oficina', value: 'BPO' },
            { label: 'Clientes Potenciales', value: 'POT' },
            { label: 'Banca Instituciones', value: 'INS' },
            { label: 'Pendiente de asignación', value: 'PDT' },
            { label: 'Gestionada por otros gestores', value: 'OTR' },
            { label: 'Gestionada por la oficina', value: 'OFI' },
            { label: 'Bancos Corresponsales', value: 'BCO' },
            { label: 'Analista de Riesgo', value: 'RIE' },
            { label: 'Especialista Morosidad', value: 'MOR' },
            { label: 'Especialista Financiación', value: 'FIN' },
            { label: 'Especialista Tesorería', value: 'TES' },
            { label: 'Especialista Comex', value: 'CMX' },
            { label: 'Banca Privada Asesoramiento independiete', value: 'BAI' },
            { label: 'Banca Privada Relacionada', value: 'BIR' },
            { label: 'Banca Privada Asesoramiento Independiente. Oficina', value: 'BIO' }
		];
	}

    get optionsEstado() {
        return [
            { label: 'Confirmado', value: '009' },
            { label: 'En estudio', value: '002' }
        ];
    }

    //capturar la lista de empleados desde el hijo
    handleEmployeeListChange(event) {
        this.employeesFromChild = JSON.stringify(event.detail);
        this.totalContact = parseInt('' + this.employeesFromChild.length ,this.employeesFromChild.length);
    }

    handleNameChange(event) {
        this.campaignName = event.target.value;
    }
 
    handleAsignChange(event){
        this.valueAsign = event.target.value;

        if(this.valueAsign === 'Centros'){
            this.isCentros = true;
            this.isIndividual = false;
            this.isResponsabilidad = false;
        }
        else if(this.valueAsign === 'Individual'){
            this.isIndividual = true;
            this.isCentros = false;
            this.isResponsabilidad = false;
        }else if(this.valueAsign === 'Responsabilidad'){
            this.isResponsabilidad = true;
            this.isCentros = false;
            this.isIndividual = false;
        }
    }

    handleEstadoChange(event) {
        this.estadoFilter = event.target.value;
        this.estadoFilterLabel = event.target.options.find(option => option.value === this.estadoFilter).label;
    }

    // Método para obtener los campos de la campaña
    get campaignName() {
        return this.wiredCampaign.data ? getFieldValue(this.wiredCampaign.data, CAMPAIGN_OBJECT.Name) : undefined;
    }

    //Método para quitar catalogo del nombre
    removeCatalogo(inputString) {
        const catalogoVariants = ['Catalogo', 'Catálogo', 'catalogo', 'catálogo', 'CATÁLOGO', 'CATALOGO'];
        for (const variant of catalogoVariants) {
            const index = inputString.indexOf(variant); 
            if (index !== -1) {
                inputString = inputString.substring(0, index) + inputString.substring(index + variant.length);
            }
        }
        return inputString;
    }

    handleGetCampaign() {
		getFieldCampaign({ recordId: this.recordId })
			.then(result => {
				if (result != null) {
                    this.resultCampaign = result;
                    this.campaignName = result.Name;
                    this.campaignName = this.removeCatalogo(this.campaignName);
                }
            });
    } 

    //Método para poder cambiar y continuar con el proceso de creación en las próximas pestañas
    handleNext(event) {
        if (this.step != 3) {
            if(this.valueAsign === null || this.valueAsign === ''){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Se debe seleccionar un tipo de asignación.',
                        variant: 'error'
                    }) 
                );
            }else{
                this.step++;
            }
        }
        if(this.step > 1){
            this.showButton = true;
        }
        this.handleSetUpSteps();
    }

    //Muestra el popup de confirmación
    handleDone(event){
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    handleCheckboxChange(event) {
        this.isFinish = event.target.checked;
    }
    backCampaign() {
        var redirect = eval('$A.get("e.force:navigateToURL");');
                            redirect.setParams({
                                "url": "/" + this.recordId
                            });
                            redirect.fire();
    }
    errorProcces(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Hubo un problema al guardar los datos.',
                variant: 'error'
            })
        );
        this.isLoading = false;
        
        setTimeout(() => {
            if(this.dispatchEvent){
                var redirect = eval('$A.get("e.force:navigateToURL");');
                redirect.setParams({
                    "url": "/" + this.recordId
                });
                redirect.fire();
            }
        },1000);
    }

    //Manda los datos para procesarlos
    submitDetails(event) {
        this.isLoading = true;
        this.isModalOpen = false;
        this.isModalInsertOpen = false;
        this.isFinish = false;
        this.totalCamp = this.totalContact * this.numSe;
        
        altaMasiva()
        .then(result => {
            if (result != null) {
                this.quantity = result;
                centros({camp: this.resultCampaign})
                        .then(result => {
                            if (result  != null) {
                                this.centrosInsert = result; 
                                createCampaign({ lstContact: this.employeesFromChild, camp: this.resultCampaign, numSe: this.inputValue, aforo: this.inputAforo, estado: this.estadoFilter, name : this.campaignName })
                                .then(result => {
                                    if (result  != null) {
                                        const listCamp = JSON.stringify(result);
                                        this.insertCampaign = JSON.parse(listCamp);
                                        const trozos = [];
                                    
                                        for (let i = 0; i < this.insertCampaign.length; i += this.quantity) {
                                            trozos.push(this.insertCampaign.slice(i, i + this.quantity));
                                        }
                                        this.trozos = JSON.stringify(trozos);
                                        for (let i = 0; i < trozos.length; i++) {
                                            const trozo = trozos[i];
                                            //trozo = JSON.stringify(trozo);
                                            //trozo = JSON.parse(trozo);

                                            this.save(trozo, this.centrosInsert, this.resultCampaign);
                                        }
                                    }else{
                                        this.errorProcces();
                                    } 
                                    });
                            }else{
                                this.errorProcces();
                            } 
                    });
            }else{
                this.errorProcces();
            } 
        });
    }

    save(trozo, centrosAdd, campPadre) {
        saveFieldRecord({ listCampaign: trozo, centrosAdd : centrosAdd, campPadre: campPadre})
                .then(result => {
                    this.sumInsert = this.sumInsert + result;
                    if(this.sumInsert === this.insertCampaign.length){
                        this.isFinish = true;
                    }
                    if (result  != null) {
                        this.inserciones = 'Eventos cargados: ' + JSON.stringify(this.sumInsert) + ' de ' + this.insertCampaign.length;
                    }else{
                        this.insercciones = 'Error';
                    }
                    this.isModalOpen = false;
                    this.isLoading = false;
                    this.isModalInsertOpen = true;
                });
    }
                
 
    

    handleDismiss(event){
        var redirect = eval('$A.get("e.force:navigateToURL");');
        redirect.setParams({
            "url": "/" + this.recordId
        });
        redirect.fire();
    }

    handlePrevious(){
        if (this.currentStep > 1) { 
            this.step--;
        }
        this.handleSetUpSteps();
    }
    
    handleSetUpSteps() {
        this.showFirstPage = this.step == 1;
        this.showSecondPage = this.step == 2;
        this.showThirdPage = this.step == 3;
        this.currentStep = "" + this.step;

        if(this.step === 1){
            this.showButton = false;
        }
        if (this.step === 2) {

        }
    }

    handleAforoChange(event) {
        this.inputAforo = event.target.value;
    }
    
    handleValueChange(event) {
        this.inputValue = event.target.value;
    }
    
    incrementValue() {
        this.inputValue++;
    }

    decrementValue() {
        if (this.inputValue > 1) {
            this.inputValue--;
        }
    }

    incrementValueAforo() {
        this.inputAforo++;
    }

    decrementValueAforo() {
        if(this.inputAforo > 1){
            this.inputAforo--;
        }
    }
}