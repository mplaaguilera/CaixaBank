import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin} from "lightning/navigation";
import { CurrentPageReference } from 'lightning/navigation';

import getTaskData from "@salesforce/apex/AV_TableGroupedByClient_Controller.getData";
import BPRPS from '@salesforce/customPermission/AV_PrivateBanking';



const VALUEWIDTH = 70;
const VALUEWIDTH2 = 100;
const VALUEWIDTH3 = 160;
const VALUEWIDTH4 = 120;
const VALUEWIDTH5 = 220;


const columnsTask = [
	
    { label: 'Cliente', fieldName: 'accountIdURL',initialWidth: VALUEWIDTH5, type: 'url', typeAttributes: { label: { fieldName: 'name' },tooltip:{fieldName:'name'} } , sortBy: 'name',hideDefaultActions: true, wrapText: true, sortable: true },
	
    { label: 'Origen', fieldName: 'origen', type: 'text',initialWidth: 140, hideDefaultActions: true, sortable: true, sortBy: 'origen' },
	
    { label: 'Asunto', fieldName: 'taskIdURL', type: 'url', typeAttributes: { label: { fieldName: 'subject' } }, hideDefaultActions: true, sortable: true, sortBy: 'subject',minWidth:'5rem' },
	
    { label: 'Estado', fieldName: 'status', hideDefaultActions: true,initialWidth: 180, sortable: true, sortBy: 'status' },
    
    { label: 'Fecha vencimiento', fieldName: 'expirationDate', initialWidth: 140,type: "date-local", typeAttributes: { month: "2-digit", day: "2-digit"}, hideDefaultActions: true, sortable: true, sortBy: 'expirationDate' },
	
    { label: 'Edad', fieldName: 'age',initialWidth: VALUEWIDTH, type: 'number', hideDefaultActions: true, sortable: true, sortBy: 'age' },
	
    { label: 'Ahorro e inversion', fieldName: 'savingsAndInvestment',initialWidth: VALUEWIDTH3, type: 'currency', typeAttributes: { maximumSignificantDigits: '20',currencyCode:'EUR' }, hideDefaultActions: true, sortable: true, sortBy: 'savingsAndInvestment' },
	
    { label: 'Financiación', fieldName: 'financing',initialWidth: VALUEWIDTH4, type: 'currency', typeAttributes: {  maximumSignificantDigits: '20',currencyCode:'EUR' }, hideDefaultActions: true, sortable: true, sortBy: 'financing' },
	
    { label: 'Ingresos', fieldName: 'income',initialWidth: VALUEWIDTH4, type: 'currency', typeAttributes: { maximumSignificantDigits: '20',currencyCode:'EUR'}, hideDefaultActions: true, sortable: true, sortBy: 'income' },
	
    { label: 'Precondedido', fieldName: 'preApproved',initialWidth: VALUEWIDTH4, type: 'currency', typeAttributes:{maximumSignificantDigits: '20',currencyCode:'EUR'},hideDefaultActions: true, sortable: true, sortBy: 'preApproved' },
	
    { label: 'My Box', fieldName: 'mybox',initialWidth: VALUEWIDTH, type: 'picklist', hideDefaultActions: true, sortable: true, sortBy: 'mybox' },
	
    { label: 'Target Auto', fieldName: 'targetAuto',initialWidth:   VALUEWIDTH2, type: 'picklist', hideDefaultActions: true, sortable: true, sortBy: 'targetAuto' }
];

const columnsTaskBPR = [
	
    { label: 'Cliente', fieldName: 'accountIdURL',initialWidth: VALUEWIDTH5, type: 'url', typeAttributes: {  label: { fieldName: 'name' },tooltip:{fieldName:'name'} } , hideDefaultActions: true, wrapText: true,onmouseover:'{hoverOpenPop}' },
	
    { label: 'Grupo', fieldName: 'groupField', initialWidth: VALUEWIDTH2, type:'picklist', hideDefaultActions: true},

    { label: 'Interlocutor', fieldName: 'interlocNameURL', type: 'url', typeAttributes: { label: { fieldName: 'interlocName' },tooltip:{fieldName:'interlocName'} } , hideDefaultActions: true, sortable: true, sortBy:'interlocName' },

    { label: 'Origen', fieldName: 'origen', type: 'text',initialWidth: 140, hideDefaultActions: true, sortable: true, sortBy:'origen' },
	
    { label: 'Asunto', fieldName: 'taskIdURL', type: 'url', typeAttributes: { label: { fieldName: 'subject' },tooltip:{fieldName:'subject'} }, hideDefaultActions: true,minWidth:'5rem' },
	
    { label: 'Estado', fieldName: 'status', hideDefaultActions: true,initialWidth: 180 },
    
    { label: 'Fecha vencimiento', fieldName: 'expirationDate', initialWidth: 140,type: "date-local", typeAttributes: { month: "2-digit", day: "2-digit"}, hideDefaultActions: true},
	
    { label: 'Edad', fieldName: 'age',initialWidth: VALUEWIDTH, type: 'number', hideDefaultActions: true},
	
    { label: 'Ahorro e inversion', fieldName: 'savingsAndInvestment',initialWidth: VALUEWIDTH3, type: 'currency', typeAttributes: { maximumSignificantDigits: '20',currencyCode:'EUR' }, hideDefaultActions: true },
	
    { label: 'Financiación', fieldName: 'financing',initialWidth: VALUEWIDTH4, type: 'currency', typeAttributes: {  maximumSignificantDigits: '20',currencyCode:'EUR' }, hideDefaultActions: true},
	
    { label: 'Ingresos', fieldName: 'income',initialWidth: VALUEWIDTH4, type: 'currency', typeAttributes: { maximumSignificantDigits: '20',currencyCode:'EUR'}, hideDefaultActions: true},
	
    { label: 'Precondedido', fieldName: 'preApproved',initialWidth: VALUEWIDTH4, type: 'currency', typeAttributes:{maximumSignificantDigits: '20',currencyCode:'EUR'},hideDefaultActions: true},
	
    { label: 'My Box', fieldName: 'mybox',initialWidth: VALUEWIDTH, type: 'picklist', hideDefaultActions: true},
	
    { label: 'Target Auto', fieldName: 'targetAuto',initialWidth:   VALUEWIDTH2, type: 'picklist', hideDefaultActions: true }
];


export default class AV_PrioritizedClientsToManage extends NavigationMixin(LightningElement) {
    taskNumber;
    @track dataClient;
    renderComponent = false;
    buttonDisabled = true;
    subjectFilter = null; 
    preconcedidoFilter = null;
    myBoxFilter = null;
    targetAutoFilter = null;
    showSpinner = false;
    colorFondo = 'green';
    mainClickFilter;
    firstLoad = true;
    filterRt; 
    originalOptions = [];
    originalAuxOptions = [];
    originalLookupAuxOptions = [];
    auxData = [];
    originalLookUpOptions = [];
    @track subjectAndOriginSelect = [];
    @track originSelect = [];
    @track subjectSelect=[]; 
    multiSelectionDouble = 0;
                 rtLabelApiNameMap = new Map([
                ['Priorizador', 'AV_Priorizador'],
                ['Alertas Comerciales', 'AV_AlertaComercial'],
                ['Experiencia Cliente', 'AV_ExperienciaCliente'],
                ['Iniciativa Gestor/a', 'AV_Otros'],
                ['Onboarding', 'AV_Onboarding'],
                ['Onboarding Intouch', 'AV_Onboarding']
            ]);


    @api columns = columnsTask;
    sortedBy;
	sortDirection = 'asc';
	defaultSortDirection = 'asc';
    @track showTable = false;
    multiSelectionO = 0;
    @track selectedOrigen= [];
    origenDiv = false;
    origenMultiFilter = [];
    @track isMultiEntry= false;
    @track initialSelectionSubject = [];
    @track hasSubject = false;
    @track isBpr = (BPRPS != undefined);
    @track origenFilter;
    
    
    filterResults = {
        subjectFilterValue: null,
        preconcedidoFilterValue: null,
        myBoxFilterValue: null,
        targetAutoFilterValue: null,
        origenFilterValue : null
    };

    get optionsPreconcedido() {
        return [
            { label: "Sí", value: "true" },
            { label: "No", value: "false" },
            { label: "", value: null }
        ];
    }

    get optionsYesOrNo() {
        return [
            { label: "Sí", value: "S" },
            { label: "No", value: "N" },
            { label: "", value: null }
        ];
    }

    get optionsSubject() {
        return this.optionsSubject;
    }

    get productArray() {

        let groupedDataMap = new Map();
        let previousAccount;
        let bgColor = 'bgColor';

        this.dataClient.forEach((product) => {
            if (groupedDataMap.has(product.name)) {
                //entra aquí si YA ESTABA ESE CLIENTE
                groupedDataMap.get(product.name).products.push(product);
                let newProduct = {};
                newProduct.name = product.name;
                newProduct.taskNumber = groupedDataMap.get(
                    product.name
                ).products.length;
                newProduct.products = groupedDataMap.get(product.name).products;
                if (previousAccount == null) {
                    previousAccount = product.accountId;
                } else if (previousAccount != null && previousAccount != product.accountId) {
                    if (bgColor === 'bgColor') {
                        bgColor = 'bgcWhite';
                    } else {
                        bgColor = 'bgColor';
                    }
                }

                newProduct.colour = bgColor;
                groupedDataMap.set(product.name, newProduct);
                previousAccount = product.accountId;

            } else {
                //ENTRA AQUÍ SI NO ESTABA ESE CLIENTE
                let newProduct = {};
                newProduct.name = product.name;

                newProduct.taskNumber = 1;
                newProduct.products = [product];
                if (previousAccount == null) {
                    previousAccount = product.accountId;
                } else if (previousAccount !== null && previousAccount !== product.accountId) {
                    if (bgColor === 'bgColor') {
                        bgColor = 'bgcWhite';
                    } else {
                        bgColor = 'bgColor';
                    }
                }

                newProduct.colour = bgColor;
                previousAccount = product.accountId;
                groupedDataMap.set(product.name, newProduct);

            }
        });

        let itr = groupedDataMap.values();
        let productArray = [];
        let result = itr.next();
        while (!result.done) {
            result.value.rowspan = result.value.products.length + 1;
            productArray.push(result.value);
            result = itr.next();
        }
        return productArray;
    }

    @wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
	}
    
    connectedCallback() { 
        this.filterRt = this.currentPageReference.state.c__fv9;

        if(this.filterRt != null){
            this.filterRt = this.filterRt.replace(/[']+/g,'').trim();
            
            this.mainClickFilter  = this.rtLabelApiNameMap.get(this.filterRt);
            this.origenMultiFilter  = this.rtLabelApiNameMap.get(this.filterRt);
        }
        this.isBpr = BPRPS;
        this.callApexToGetDataFiltered();
        if(this.isBpr){
            this.columns = columnsTaskBPR;
        }else{
            this.columns = columnsTask;
        }

    }

    
    
    redirectToClient(event) {
        let id = this.getId(event.target.name);

        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                objectApiName: "Account",
                recordId: id,
                actionName: "view"
            }
        });
    }

    redirectToTask(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                objectApiName: "Task",
                recordId: event.target.name,
                actionName: "view"
            }
        });
    }

    getId(name) {
        let id;
        this.dataClient.forEach((d) => {
            if (d.name.toUpperCase() === name.toUpperCase()) {
                id = d.accountId;
            }
        });
        return id;
    }

    handleChangeSubject(event) {
		this.subjectFilter = event.target.value;
        if(this.subjectFilter != null){
            this.filterResults.subjectFilterValue = this.subjectFilter;
            this.setButtonVisibility();
                 
        }else{
            this.filterResults.subjectFilterValue = null;
        }
	}

    handleChangePreconcedido(event) {
        this.preconcedidoFilter = event.target.checked;
        if(this.preconcedidoFilter){
            this.filterResults.preconcedidoFilterValue = this.preconcedidoFilter;
            this.checkButtonStatus();
        }else{
            this.filterResults.preconcedidoFilterValue = null;
        }
        
    }

    handleChangeMyBox(event) { 
        if(event.target.checked){
            this.myBoxFilter = 'S'
            this.filterResults.myBoxFilterValue =this.myBoxFilter;
            this.checkButtonStatus();
        }else{
            this.myBoxFilter = null;
            this.filterResults.myBoxFilterValue= this.myBoxFilter;
        }
    }

    handleChangeTargetAuto(event) {
        if(event.target.checked){
            this.targetAutoFilter = 'S';
            this.filterResults.targetAutoFilterValue = this.targetAutoFilter;
            this.checkButtonStatus();
        }else{
            this.filterResults.targetAutoFilterValue= null;
        }
    }

    handleChangeOrigen(event) {
        this.origenDiv = true; 
        this.origenFilter= event.target.value;
        this.filterResults.origenFilterValue = this.origenFilter;
        this.mainClickFilter = this.filterResults.origenFilterValue;
		let origenPick;
		this.multiSelectionDouble++;
		for (let i = 0; i < this.optionsOrigen.length; i++) {
            if (this.optionsOrigen[i]['value'] === event.target.value) {
                origenPick = this.optionsOrigen[i];
				origenPick['bucleId'] = this.multiSelectionDouble;
                origenPick['type'] = 'origen';
                origenPick['typeLabel'] = 'Origen: '
				break;
			}
		}
		let insert = true;
		if (this.originSelect.length > 0) {
            for (let i = 0; i < this.originSelect.length; i++) {
                if (this.originSelect[i].value == origenPick.value) {
                    insert = false;
					break;
				}
			}
		}
		if (insert) {
            this.originSelect.push(origenPick);
		}
        this.setButtonVisibility();
        
	}
    
    unSelectOrigen(cmp) {
        let divToDel = cmp.target.parentNode;
        this.originalLookupCopy = this.originalLookUpOptions;
		for (let i = 0; i < this.originSelect.length; i++) {
            let origin = this.originSelect[i];
			if (origin.value === cmp.target.name) {
                let a = this.originSelect.splice(i, 1);
                break;
            }
                
        }
        let arrLength = this.originSelect.length;
        this.origenFilter = (arrLength != 0 ) ? this.originSelect[arrLength - 1].value : null;
		divToDel.classList.add('delete');
		cmp.target.remove();
        if(this.originSelect.length == 0){
            this.origenDiv = false;
        }
	}

    setButtonVisibility() {
        if (this.origenFilter != null || this.filterResults.subjectFilterValue!= null ) {
			this.buttonDisabled = false;
		} else {
			this.buttonDisabled = true;
		}
		
	}

    get optionsOrigen() {

		return [
			{ label: 'Alerta Comercial', value: 'AV_AlertaComercial' },
            { label: 'Experiencia Cliente', value: 'AV_ExperienciaCliente' },
            { label: 'Iniciativa Gestor/a', value: 'AV_Otros' },
            { label: 'Priorizador', value: 'AV_Priorizador'},
			{ label: 'Onboarding Intouch', value: 'AV_Onboarding' }
			
		];
	}

    resetFilters() {
        this.template.querySelectorAll("lightning-input").forEach((each) => {
            each.value = "";
        });
        this.targetAutoFilter = null;
        this.myBoxFilter = null;
        this.preconcedidoFilter = null;
        this.origenFilter = null;
        this.filterResults = {
            subjectFilterValue: null,
            preconcedidoFilterValue: null,
            myBoxFilterValue: null,
            targetAutoFilterValue: null,
            origenFilterValue : null
        };
        this.buttonDisabled = true;
        this.mainClickFilter = null;
        this.selectedOrigen = [];
        this.origenMultiFilter = [];
        this.originSelect = [];
        this.origenDiv = false;
        this.originalOptions = [];
        this.dataClient = this.auxData;
        this.originalAuxOptions.forEach(org => {
            this.originalOptions.push(org);
        })
        this.originalLookUpOptions = [];
        this.originalLookupAuxOptions.forEach(org => {
            this.originalLookUpOptions.push(org);
        })
        this.template.querySelector("[data-id='clookup5']").setSearchResults(this.originalLookUpOptions);
        
    }

    handleSearchData() {
        this.firstLoad = false; 
        this.origenMultiFilter = [];
        this.originSelect.forEach(org => {
            if (org.type == 'origen' && !this.origenMultiFilter.includes(org.value)) {
                this.origenMultiFilter.push(  org.value );
            }

            if(org.type == 'subject' && !this.filterResults.subjectFilterValue.includes(org.value)){
                this.filterResults.subjectFilterValue.push(org.value);
            }
        });
        
        this.callApexToGetDataFiltered();
    }

    handleSortData(event){
        let sortedBy = event.detail.fieldName;
		let sortDirection = event.detail.sortDirection;
		const sortFieldName = this.columns.find(field=>sortedBy===field.fieldName).sortBy; 

        const cloneData = [...this.dataClient];
        cloneData.sort(this.sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1));
		
        this.dataClient = cloneData;
		this.sortDirection = sortDirection;
		this.sortedBy = sortedBy;
    }

    sortBy(field, reverse, primer) {
		if (field == 'age' || field == 'savingsAndInvestment' || field == 'financing' || field == 'income' || field == 'preApproved') {

			const key = primer
				? function (x) {
					return primer(x[field]);
				}
				: function (x) {
					return x[field];
				};

			return function (a, b) {
				a = key(a);
				b = key(b);
				var result;
				if (a == null) {
					result = 1;
				}
				else if (b == null) {
					result = -1;
				} else {
					result = (reverse * ((a > b) - (b > a)));
				};
				return result;
			}
		} else {

			const key = primer
				? function (x) {
					return primer(x[field]);
				}
				: function (x) {
					return x[field];
				};
            
			return function (a, b) {
				a = key(a);
				b = key(b);
				var result;
				if (a == null) {
					result = 1;
				}
				else if (b == null) {
					result = -1;
				} else {
					result = (reverse * ((a.toLowerCase() > b.toLowerCase()) - (b.toLowerCase() > a.toLowerCase())));
				};
				return result;
			}
		}
	}


    callApexToGetDataFiltered() {
        getTaskData({ filterResults: this.filterResults, origenFilter: this.origenMultiFilter })
            .then((result) => {
                this.showTable = true;
                if(result != null){
                    this.dataClient = result;
                    if(this.firstLoad){ 
                        this.originalOptions = result;
                        this.originalAuxOptions = result;
                        this.auxData = result;            
                    }
                    this.firstLoad = false;
                    result.forEach((d)=>{
                        d.accountIdURL = '/'+d.accountId;
                        d.taskIdURL = '/'+d.taskId ;

                        if(d.groupField == 'Sin grupo'){

                            d.interlocName = d.name;
                            d.interlocNameURL = '/' + d.accountId;

                        }else if(d.interlocutionGroup != undefined){

                            if(d.interlocName != undefined){
                                d.interlocNameURL = '/'+d.interlocutionGroup.Id;

                            }
                        }

                    })

                }else{
                    this.dataClient = [];  
                }
           
                this.hasSubject = true
                this.showSpinner = false;
                this.renderComponent = true; 
            })
            .catch((error) => {
                console.log("error ", error);
            });
    }

    checkButtonStatus() {
        if (
            (this.filterResults.preconcedidoFilterValue === null ||
                this.filterResults.preconcedidoFilterValue === "") &&
            (this.filterResults.myBoxFilterValue === null ||
                this.filterResults.myBoxFilterValue === "") &&
            (this.filterResults.targetAutoFilterValue === null ||
                this.filterResults.targetAutoFilterValue === "") &&
            (this.filterResults.subjectFilterValue === null ||
                this.filterResults.subjectFilterValue === "") &&
            (this.filterResults.origenFilterValue === null || 
                this.filterResults.origenFilterValue === "" )
        ) {
            this.buttonDisabled = true;
        } else {
            this.buttonDisabled = false;
        }
    }


    
    navigateToMassReassignOwnerOpps(){

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName : "AV_MassReassignOwnerOpps"
            }
           
        });
    }

    

     


    
}