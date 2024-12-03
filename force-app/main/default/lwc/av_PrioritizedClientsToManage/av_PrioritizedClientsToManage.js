import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin} from "lightning/navigation";
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTaskData from "@salesforce/apex/AV_TableGroupedByClient_Controller.getData";
import BPRPS from '@salesforce/customPermission/AV_PrivateBanking';
import OLDHOMETSK from '@salesforce/customPermission/AV_OldHomeTask';  
import lookupSearchOffice from '@salesforce/apex/AV_OppSearch_Controller.searchOffice';
import USER_ID from '@salesforce/user/Id';
import enanchedGetUserInfo from '@salesforce/apex/AV_OppSearch_Controller.enanchedGetUserInfo';
import getEmployees from '@salesforce/apex/AV_TableGroupedByClient_Controller.getEmployees';
import AV_NotAssigned from '@salesforce/label/c.AV_NotAssigned';
import  Only_three_at_time from '@salesforce/label/c.AV_Only_three_at_time';
import  Maximum_Employees from '@salesforce/label/c.AV_Maximum_Employees';
import  Inform_Office from '@salesforce/label/c.AV_Inform_Office';
import  Wrong_Filter from '@salesforce/label/c.AV_Wrong_Filter';
import  Banca_Privada from '@salesforce/label/c.AV_Banca_Privada';


const VALUEWIDTH = 70;
const VALUEWIDTH2 = 100;
const VALUEWIDTH3 = 160;
const VALUEWIDTH4 = 120;
const VALUEWIDTH5 = 220;


const columnsTask = [
	
    { label: 'Cliente', fieldName: 'accountIdURL',initialWidth: VALUEWIDTH5, type: 'url', typeAttributes: { label: { fieldName: 'name' },tooltip:{fieldName:'name'} } , sortBy: 'name',hideDefaultActions: true, wrapText: true, sortable: true },
	
    { label: 'Origen', fieldName: 'origen', type: 'text',initialWidth: 140, hideDefaultActions: true, sortable: true, sortBy: 'origen' },
	
    { label: 'Asunto', fieldName: 'taskIdURL', type: 'url', typeAttributes: { label: { fieldName: 'subject' },tooltip:{fieldName:'subject'} }, hideDefaultActions: true, sortable: true, sortBy: 'subject',minWidth:'5rem' },
	
    { label: 'Estado', fieldName: 'status', hideDefaultActions: true,initialWidth: 180, sortable: true, sortBy: 'status' },
    
    { label: 'Fecha vencimiento', fieldName: 'expirationDate', initialWidth: 140,type: "date-local", typeAttributes: { month: "2-digit", day: "2-digit"}, hideDefaultActions: true, sortable: true, sortBy: 'expirationDate' },
	
    { label: 'Edad', fieldName: 'age',initialWidth: VALUEWIDTH, type: 'number', hideDefaultActions: true, sortable: true, sortBy: 'age' },
	
    { label: 'Ahorro e inversion', fieldName: 'savingsAndInvestment',initialWidth: VALUEWIDTH3, type: 'currency', typeAttributes: { maximumSignificantDigits: '20',currencyCode:'EUR' }, hideDefaultActions: true, sortable: true, sortBy: 'savingsAndInvestment' },
	
    { label: 'Financiación', fieldName: 'financing',initialWidth: VALUEWIDTH4, type: 'currency', typeAttributes: {  maximumSignificantDigits: '20',currencyCode:'EUR' }, hideDefaultActions: true, sortable: true, sortBy: 'financing' },
	
    { label: 'Ingresos', fieldName: 'income',initialWidth: VALUEWIDTH4, type: 'currency', typeAttributes: { maximumSignificantDigits: '20',currencyCode:'EUR'}, hideDefaultActions: true, sortable: true, sortBy: 'income' },
	
    { label: 'Precondedido', fieldName: 'preApproved',initialWidth: VALUEWIDTH4, type: 'currency', typeAttributes:{maximumSignificantDigits: '20',currencyCode:'EUR'},hideDefaultActions: true, sortable: true, sortBy: 'preApproved' },
	
    { label: 'My Box', fieldName: 'mybox',initialWidth: VALUEWIDTH, type: 'picklist', hideDefaultActions: true, sortable: true, sortBy: 'mybox' },
	
    { label: 'Target Auto', fieldName: 'targetAuto',initialWidth:   VALUEWIDTH2, type: 'picklist', hideDefaultActions: true, sortable: true, sortBy: 'targetAuto' },

    { label: 'Empleado', fieldName: 'gestorName',initialWidth:   VALUEWIDTH2, type: 'text', typeAttributes:{label: {fieldName: 'gestorName'}},hideDefaultActions: true, sortable: true, sortBy: 'targetAuto' }
    
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
	
    { label: 'Target Auto', fieldName: 'targetAuto',initialWidth:   VALUEWIDTH2, type: 'picklist', hideDefaultActions: true },
    { label: 'Empleado', fieldName: 'gestorName',initialWidth:   VALUEWIDTH2, type:'text', typeAttributes:{label: {fieldName: 'gestorName'}},hideDefaultActions: true }
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
    firstLoad = true;
    gestor;
    multigestor;
	multiSelectionE=0;
	multiSelectionS=0;
    isDirector;
	directores = ['DC','DT','DAN','SSCC'];
    isMultiOffi = false;
    @track selectedEmployees = [];
    isAnotherOffice = false;
    initialSelectionOffice = [];
    errors = [];
    handleSearch;
	@track employeeLabel = 'Oficina';
	@track employeePlaceholder = 'Buscar empleado...';
    isMultiEntry = false;
    selectedEmployeesDefault = [];
    empleOfi;
    optionAll;
    employeesDiv = true;
    employeeDefault = USER_ID;
	@track employeeFilter = this.employeeDefault;
    multiSelectionDouble = 0;
    optionsEmployeeAux = [];
    selectedEmployeesDefault = [];
    defaultOffice;
    subjectDisabled = false;
    originDisabled = false;
    disabledCb = false;
    rtLabelApiNameMap = new Map([
        ['Priorizador', 'AV_Priorizador'],
        ['Alertas Comerciales', 'AV_AlertaComercial'],
        ['Alerta Comercial', 'AV_AlertaComercial'],
        ['Experiencia Cliente', 'AV_ExperienciaCliente'],
        ['Iniciativa Gestor/a', 'AV_Otros'],
        ['Onboarding', 'AV_Onboarding'],
        ['Onboarding Intouch', 'AV_Onboarding']
    ]);
 
    handleChangeEmployee(event) {
        if((this.selectedEmployees.length + 1 ) > 3){
            this.showToast(Maximum_Employees,Only_three_at_time,'warning','dismissable');
            this.employeeFilter = this.selectedEmployees[this.selectedEmployees.length -1 ].id;
            let comboboxEmp = this.template.querySelector("[data-id='employeesDropDown']");
            if(comboboxEmp != null){
                comboboxEmp.value = this.employeeFilter;
            }
            return;
        }
        this.multiSelectionE++;
        this.employeeFilter = event.target.value;
        let employeeName = '';
        for(let i=0;i<this.optionsEmployee.length;i++){
            if(this.optionsEmployee[i]['value']===event.target.value){
                employeeName=this.optionsEmployee[i]['label'];
                if (employeeName.includes('Todos')) {
                    this.selectedEmployees = [];
                }
                break;
            }
        }
        let insert = true;
        if(this.selectedEmployees.length > 0 ){
            if (this.selectedEmployees[0]['label'].includes('Todos')) {
                this.selectedEmployees.splice(0, 1);
            }
            for (let i = 0; i < this.selectedEmployees.length; i++) {
                if (this.selectedEmployees[i]['label']===employeeName) {
                    insert = false;
                    break;
                }				
            }
        }
        if (insert && employeeName != '') {
            this.buttonDisabled = false;
            this.selectedEmployees.push({label:employeeName,id:event.target.value,bucleId:this.multiSelectionE});
        }
        this.employeesDiv = true;
    }


    handleSearcOffice(event){
		lookupSearchOffice({searchTerm: event.detail.searchTerm, selectedIds: null})
		.then((results) => {
			this.template.querySelector('[data-id="clookup2"]').setSearchResults(results.listOfi);
			this.optionAll = results.optionAll;
			this.isMultiOffi = results.isMultiOffi;
		})
		.catch((error) => {
			console.error('Lookup error', JSON.stringify(error));
			this.errors = [error];
		});
    }

    handleSearchOfficeClick(event){
        if (this.find == '' && this.numOficinaEmpresa == null) {
			lookupSearchOffice({searchTerm: event.detail.searchTerm, selectedIds: null})
			.then((results) => {
				this.template.querySelector('[data-id="clookup2"]').setSearchResults(results.listOfi);
				this.optionAll = results.optionAll;
				this.isMultiOffi = results.isMultiOffi;
			})
			.catch((error) => {
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
		}
    }
    showToast(title, message, variant, mode) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}

    getOptionsOffice() {
		lookupSearchOffice({searchTerm: this.empleOfi.substring(4), selectedIds: null})
		.then(result => {
			if (result != null && result.listOfi != null) {
				if(this.template.querySelector('[data-id="clookup2"]') != null) {
					this.template.querySelector('[data-id="clookup2"]').setSearchResults(result.listOfi);
				}
				this.numOficinaEmpresa = this.empleOfi.substring(4);
				this.initialSelectionOffice = [{id: result.listOfi[0].id, icon:result.listOfi[0].icon, title: result.listOfi[0].title}];
				this.officeSelectedDefault = [{id: result.listOfi[0].id, icon:result.listOfi[0].icon, title: result.listOfi[0].title}];
				this.selectedOffice = this.selectedOffice === '' ? this.empleOfi.substring(4) : this.selectedOffice;
				this.optionAll = result.optionAll;
				this.getOptionsEmployee(this.empleOfi.substring(4));
                
             
			}
		}).catch(error => {
			console.log(error);
		});
	}

    loadingEmployee;
	getOptionsEmployee(data){
		this.loadingEmployee = true;
		this.multiSelectionE++;
		getEmployees({officeFilterData: data})
		.then(result => {
			if(result != null && result.length > 1) {
                result = result.filter(r => !(r.label.includes('Todos')));
				if((this.origenFilter === 'all') && result.length > 0 && result[0].label.includes('Todos')){
					result.shift();
				}
				this.optionsEmployee = result;
				if ((!this.isAnotherOffice && this.isDirector) || (!this.isDirector && this.isMultiOffi)) {
					if (!JSON.stringify(this.optionsEmployee).includes(USER_ID)) {
						this.optionsEmployee.push({value:USER_ID,label:this.empleName});
					}
				}
				this.optionsEmployee.push({value:'',label:''});
				if(this.isAnotherOffice === false){
					if (this.currentPageReference.state.c__singestor != null && this.currentPageReference.state.c__singestor[0] === AV_NotAssigned) {
                        this.employeeFilter = this.currentPageReference.state.c__singestor[1];
						this.selectedEmployees = [{label:this.currentPageReference.state.c__singestor[0],id:this.currentPageReference.state.c__singestor[1],bucleId:this.multiSelectionE}];
					}
					
				}
			} else if (result != null) {
				this.optionsEmployee = result;
				if (!this.isDirector && this.isMultiOffi) {
					if (!JSON.stringify(this.optionsEmployee).includes(USER_ID)) {
						this.optionsEmployee.push({value:USER_ID,label:this.empleName});	
					}
				}
				this.optionsEmployee.push({value:'',label:''});
				if (this.isMultiOffi) {
					if (this.currentPageReference.state.c__singestor != null && this.currentPageReference.state.c__singestor[0] === AV_NotAssigned) {
						this.employeeFilter = this.currentPageReference.state.c__singestor[1];
						this.selectedEmployees = [{label:this.currentPageReference.state.c__singestor[0],id:this.currentPageReference.state.c__singestor[1],bucleId:this.multiSelectionE}];
					}else{
						this.employeeFilter = this.employeeDefault;
						if(this.multigestor != undefined && this.multigestor != null){
							this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE},{label:Banca_Privada,id:this.multigestor,bucleId:++this.multiSelectionE}];
						}else{
							this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];
                            
						}
					}
				} else {
					this.employeeFilter = '';
					this.selectedEmployees = [];
				}
			}
            this.selectedEmployeesDefault = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];
            if(this.multigestor != undefined && this.multigestor != null){
                this.selectedEmployeesDefault.push({label:Banca_Privada,id:this.multigestor,bucleId:++this.multiSelectionE});
            }
			this.loadingEmployee = false;
            if(this.firstLoad){

                this.buildComponent();
                this.firstLoad = false;
            }
		}).catch(error => {
			this.loadingEmployee = false;
			console.log(error);
		});
	}
    handleSelectionChange(e){
        const selection = this.template.querySelector(`[data-id="clookup2"]`).getSelection();

        if(selection.length !== 0){
            for(let sel of selection) {
                this.buttonDisabled = this.employeeFilter == '';
                this.isDisabledEmployee = false;
                this.subjectDisabled = false;
                this.originDisabled = false;
                this.disabledCb = false;
                if (sel.title == 'Todas') {
                    this.numOficinaEmpresa = this.optionAll;
                    this.employeeFilter = this.employeeDefault;
                    this.selectedEmployees = [{label:this.empleName,id:this.employeeDefault,bucleId:this.multiSelectionE}];
                    this.isDisabledEmployee = true;
                    this.isAnotherOffice = false;
                    this.employeesDiv = true;
                } else {
                    this.find = '';
                    this.employeeFilter = '';
                    this.numOficinaEmpresa = sel.title.substring(0,5);
                    this.isDisabledEmployee = false;
                    this.getOptionsEmployee(this.numOficinaEmpresa);
                }
            }
        } else {
            this.selectedEmployees = []
            this.optionsEmployee = [];
            this.originSelect = [];
            this.isDisabledEmployee = true;
            this.buttonDisabled = true;
            this.subjectDisabled = true;
            this.originDisabled = true;
            this.disabledCb = true;
            this.numOficinaEmpresa = null;
            
            let comboboxEmp = this.template.querySelector("[data-id='employeesDropDown']");
            this.employeeFilter = '';
            if(comboboxEmp != null){
                comboboxEmp.value = this.employeeFilter;
            }
            this.template.querySelector('.another-office').checked = false;
        }
    }
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
    @track isOldHomeTsk = (OLDHOMETSK!= undefined);
    nameReport;
    
   
	unSelectEmployee(cmp){
		let divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedEmployees.length;i++){
			if(this.selectedEmployees[i].id === cmp.target.name){
				this.selectedEmployees.splice(i,1);
			}
		}
		divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedEmployees.length === 0) {
			this.employeesDiv = false;
			this.employeeFilter = '';
		}
        if(this.selectedEmployees.length > 0){
            this.buttonDisabled = false;
            this.employeeFilter = this.selectedEmployees[this.selectedEmployees.length -1].id;
        }else{
            this.buttonDisabled = true;

        }
	}
    getUserInfo(){
		enanchedGetUserInfo({userId:USER_ID})
		.then(data => {
            if(data){
                let gestor = data.gestor;
                this.empleFuncion = gestor.AV_Funcion__c;
                this.empleName = gestor.Name;
                this.empleOfi = gestor.AV_NumeroOficinaEmpresa__c === null ? '': gestor.AV_NumeroOficinaEmpresa__c;
                
                this.numOficinaEmpresa = this.empleOfi.split('-')[1];
                this.defaultOffice = this.empleOfi.split('-')[1];
                this.numOfficeDefault = this.empleOfi.split('-')[1];
                this.isDirector = this.directores.includes(this.empleFuncion);
                this.selectedEmployeesDefault = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];
                if(data.multigestor != undefined && data.multigestor != null){
					this.multigestor = data.multigestor.Id;
                    this.selectedEmployeesDefault.push({label:Banca_Privada,id:data.multigestor.Id,bucleId:++this.multiSelectionE});
                }
                this.selectedEmployees = [];
                this.selectedEmployeesDefault.forEach(emp =>{
                emp.bucleId = ++this.multiSelectionE;
                if(!this.employeesDiv){
                    this.employeesDiv = true;
                }
		        });
		        this.selectedEmployeesDefault.forEach( emp => {this.selectedEmployees.push(emp)});
                this.getOptionsOffice();
            }
        }).catch(error => {
            console.error(error);
        })
    }
    filterResults = {
        subjectFilterValue: null,
        preconcedidoFilterValue: null,
        myBoxFilterValue: null,
        targetAutoFilterValue: null,
        origenFilterValue : null,
        employeesFilter : [],
        officeFilter : null
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
		this.getUserInfo();

    }
    buildComponent() { 

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

        if(!this.isOldHomeTsk){
            this.nameReport = 'Tareas';
        }else{
            this.nameReport ='Clientes a gestionar priorizados';
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
        this.buttonDisabled = false;
        this.isDisabledEmployee = false;
        this.subjectDisabled = false;
        this.originDisabled = false;
        this.disabledCb = false;
        this.numOficinaEmpresa = this.defaultOffice;
        if(this.isAnotherOffice){
            this.handleAnotherOffice(new Object({'detail':{'checked':false}}));
        }
        this.employeeFilter = this.employeeDefault;
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
            origenFilterValue : null,
            employeesFilter : []
        };
        this.selectedEmployees = [];
        this.selectedEmployeesDefault.forEach(emp =>{
			emp.bucleId = ++this.multiSelectionE;
			if(!this.employeesDiv){
				this.employeesDiv = true;
			}
		});
		this.selectedEmployeesDefault.forEach( emp => {this.selectedEmployees.push(emp)});
        this.buttonDisabled = false;
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
        this.initialSelectionOffice = JSON.parse(JSON.stringify(this.officeSelectedDefault));
        this.getOptionsEmployee(this.numOficinaEmpresa);
        this.template.querySelector("[data-id='clookup2']").setSearchResults(this.originalLookUpOptions);
        this.callApexToGetDataFiltered();
        
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
        this.filterResults.employeesFilter = this.selectedEmployees.map(emp => emp.id);
        this.filterResults.officeFilter = this.numOficinaEmpresa;
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
                        d.gestorId = '/'+d.gestorId;

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

    

     
    handleAnotherOffice(event) {
		if (this.numOficinaEmpresa != null) {
			this.isAnotherOffice = event.detail.checked;
			this.selectedEmployees = [];
			if (event.detail.checked === true) {
				this.optionsEmployeeAux = this.optionsEmployee;
				this.employeeFilter = '';
				var data = this.numOficinaEmpresa+'{|}';
                if(this.originSelect != null && this.originSelect.length != 0){
                    this.originSelect.map(origin => origin.value).forEach(origenValue => {
                        data += (origenValue + ',');
                        })
                }else{
                    data += 'all';
                }
				this.getOptionsEmployee(data);
				this.employeesDiv = false;
			} else {
				this.optionsEmployee = this.optionsEmployeeAux;
                this.selectedEmployees = [];
				this.handleChangeEmployee(new Object({'target': {'value':USER_ID}}));
                if(this.multigestor != null){
                    this.handleChangeEmployee(new Object({'target': {'value':this.multigestor}}));

                }
				this.employeeFilter = this.employeeDefault;
				this.employeesDiv = true;
			}
		} else {
			const el = this.template.querySelector('.another-office');
			el.checked = false;
			this.optionsEmployee = this.optionsEmployeeAux;
			this.employeeFilter = this.employeeDefault;
			this.handleChangeEmployee(new Object({'target': {'value':this.employeeFilter}}));
			this.employeesDiv = true;
			this.isAnotherOffice = false;
			const evt = new ShowToastEvent({
				title: Wrong_Filter,
				message: Inform_Office,
				variant: 'info',
				mode: 'dismissable'
			});
			this.dispatchEvent(evt);
		}

	}

    
}