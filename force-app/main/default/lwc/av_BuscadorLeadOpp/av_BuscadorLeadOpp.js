import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import fetchData from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.getBaseData';
import lookupSearchAccount from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.searchAccount';
import lookupSearchNoAccount from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.searchNoAccount';
import getEmployees from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.getEmployees';
import getResolutionValues from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.getResolutionValues';
import getStatusValues from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.getStatusValues';
import getProducto from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.getProducto';
import getOriginValues from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.getOriginValues';
import getEmpresaValues from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.getEmpresaValues';
import getStageValues from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.getStageValues';

import getPendingReasonValues from  '@salesforce/apex/AV_BuscadorLeadOpp_Controller.getPendingReasonValues';
import getOffice from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.getOffice';
import lookupSearch from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.search';
import assign from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.assign';
import nameContactAssign from '@salesforce/apex/AV_BuscadorLeadOpp_Controller.nameContactAssign';
/*import isBankTeller from '@salesforce/apex/AV_AppUtilities.isBankTeller';*/
import USER_ID from '@salesforce/user/Id';
import recordLimitLabel from '@salesforce/label/c.AV_BuscadorRecordLimit';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

const columnsLeadOpp = [
    { label: 'Fecha inicio', fieldName: 'AV_CreationDate__c', type: "date-local",typeAttributes:{ month: "2-digit", day: "2-digit" }, sortable: true, sortBy:'AV_CreationDate__c', width: "50px"},
	{ label: 'Nombre', fieldName: 'NameURL', type: 'url', typeAttributes:{ label: { fieldName: 'LeadOppName' } }, hideDefaultActions: true, wrapText:true, sortable: true, sortBy:'LeadOppName', width: "30px"},
	{ label: 'Titular', fieldName: 'Lead', type: 'string', hideDefaultActions: true,  wrapText:true, sortable: true,sortBy:'Lead'},
	{ label: 'Cliente', fieldName: 'ClientURL', type: 'url', typeAttributes:{ label: { fieldName: 'ClientName' } }, hideDefaultActions: true, wrapText:true, sortable: true, sortBy:'ClientName'},
    { label: 'Origen', fieldName: 'AV_PrescriberId__c', type: 'string', sortable: true, sortBy:'AV_PrescriberId__c'},
    //Producto no existe en LeadOpp
	{ label: 'Empresa', fieldName: 'AV_Empresa__c', type: 'string', sortable: true, sortBy:'AV_Empresa__c'},
	{ label: 'Producto', fieldName: 'Product2', type: 'string', sortable: true, sortBy:'Product2'},
    { label: 'Estado', fieldName: 'AV_Status__c', type: 'string', sortable: true, sortBy:'AV_Status__c'},
    { label: 'Etapa', fieldName: 'AV_StatusLeadOpp__c', type: 'string', sortable: true, sortBy:'AV_StatusLeadOpp__c'},
	{ label: 'Empleado asignado', fieldName: 'OwnerNameURL', type: 'url',	typeAttributes:{ label: { fieldName: 'OwnerName' } }, hideDefaultActions: true, wrapText:true, sortable: true, sortBy:'OwnerName'},
    { label: 'Motivo pendiente', fieldName: 'AV_PendingReason__c', type: 'string', sortable: true, sortBy:'AV_PendingReason__c'},
    { label: 'Resolución', fieldName: 'AV_Resolution__c', type: 'string', sortable: true, sortBy:'AV_Resolution__c'},
	{ label: 'Importe ingresos', fieldName: 'AV_IncomeAmount__c',type: 'currency',sortable:true, sortBy:'AV_IncomeAmount__c'},
    { label: 'Fecha de vencimiento', fieldName: 'AV_DueDate__c', type: "date-local", typeAttributes:{ month: "2-digit", day: "2-digit" }, sortable: true, sortBy:'AV_DueDate__c'},
    { label: 'Fecha cierre gestión', fieldName: 'AV_FechaCierreGestion__c', type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, sortable: true, sortBy:'AV_FechaCierreGestion__c'}
];

export default class Av_BuscadorLeadOpp extends LightningElement {

    @track data;
	@track items;
	//@track targetObjName;
	@track columns;
	@track totalPage = 0;
	@track iconName;
	@track totalRecountCount;
	@track showSpinner = false;
	@track firstSearch = false;
	@track isMultipagina = true;
	@track isMultiEntry2 = false;
    @track pageSize = 100; 
	@track rowNumberOffset; //Row number
	@track selectedItems = 0;
	@track startingRecord = 1;
	@track endingRecord = 0; 
	@track isModalOpen = false;
	@track filterList;
	@track contactName;
	@track todaysDate;




	@track creationDateFilterFrom = null;
	@track creationDateFilterUntil = null;
	@track stageFilter = '';
	@track statusFilter = 'Nuevo';
	@track productoFilter= '';
	@track altaClienteFilter=null;
	@track empresaFilter='';
	@track originFilter = '';
	@track clientFilter;
	@track noClientFilter;
	@track employeeFilter = '';
	@track pendingReasonFilter = '';
	@track resolutionFilter = '';
	@track dueDateFilterFrom = null;
	@track dueDateFilterUntil = null;
	@track closeDateFilterFrom = null;
	@track closeDateFilterUntil = null;
	@track incomeAmountFilterFrom = null;
	@track incomeAmountFilterUntil= null;

	@track footerDisplay = true;


	@track multiSelectionS=0;
	@track multiSelectionStatus=0;
	@track multiSelectionO=0;
	@track multiSelectionE=0;
	@track multiSelectionEmpresa=0;
	@track multiSelectionProducto=0;
	@track multiSelectionP=0;//status
	@track multiSelectionR=0;


	@track selectedStages = [];
	@track selectedStatus = [{ label: 'Nuevo', value: 'Nuevo' ,bucleId:this.multiSelectionStatus}];
	@track selectedProducto =[];
	@track selectedEmpresa=[];  //En produccion
	@track selectedOrigin=[];
	//selectedOrigin = [{ label: 'NO DATA', value: 'NO DATA' ,bucleId:this.multiSelectionO}];
	//selectedEmployees = [{ label: 'TODOS - CENTRO', value: 'TODOSCENTRO' ,bucleId:this.multiSelectionE}];
	@track selectedPendingReason = [];
	@track selectedResolution = [];

	@track stageDiv = false;
	@track originDiv = false;
	@track empresaDiv=false;
	@track statusDiv = true;
	@track productoDiv= false;
	@track altaClienteDiv=false;
	@track employeesDiv = true;
	@track pendingReasonDiv = false;
	@track pendingReasonReqDiv = false;
	@track resolutionReqDiv = false;
	@track resolutionDiv = false;
	

	@track buttonDisabled = false;


	@track initialSelection = [];
	@track errors = [];
	@track isMultiEntry = false;
	@track employeeLabel = 'Asignar a:';
	@track employeePlaceholder = 'Buscar empleado...';
	@track clientPlaceholder = 'Buscar cliente...';
	@track noClientPlaceholder = 'Buscar no cliente...';
	@track optionsEmployee = [];
	@track optionsOrigin = [];
	@track optionsEmpresa = [];
	@track optionsStage=[];
	@track optionsPendingReason=[];
	@track optionsProducto=[];
	@track optionsResolution=[];
	@track optionsStatus=[];
	
	

	@track employeeDefault = USER_ID;
	@track showDetail = false;
	sortedBy;
	@track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
	@track showAssignment = true;
	totalNumberOfRecords;
	@track size = 0;
	@track MAX_PAGE_NUM = 20; //Query offset limit = 2000 (100 records * 20 pages)
	@track helpMessage = false;
	@track recordLimit = recordLimitLabel;
	@track originMultiFilter = [];
	@track empresaMultiFilter=[];
	@track productoMultiFilter=[];
	@track statusMultiFilter = [];
	@track stageMultiFilter = [];
	@track pendingReasonMultiFilter = [];
	@track employeMultiFilter = [];
	@track resolutionMultiFilter = [];
	office;


    handleSearchData() {
		this.page = 1;
		this.size = 0;
		
		this.firstSearch = true;
		this.data = null;
		this.toggleSpinner();
		this.employeMultiFilter=[];
		this.originMultiFilter=[];
		this.empresaMultiFilter=[];
		this.productoMultiFilter=[];
		this.statusMultiFilter=[];
		this.stageMultiFilter=[];
		this.pendingReasonMultiFilter=[];
		this.resolutionMultiFilter=[];
		

		this.selectedEmployees.forEach(emp => {
			if(!this.employeMultiFilter.includes(emp.id)){
				this.employeMultiFilter.push(emp.id);
			}
		});

		this.selectedOrigin.forEach(ori => {
			if(!this.originMultiFilter.includes(ori.value)){
				this.originMultiFilter.push(ori.value);
			}
		});

		this.selectedEmpresa.forEach(emp => {
			if(!this.empresaMultiFilter.includes(emp.value)){
				this.empresaMultiFilter.push(emp.value);
			}
		});

		this.selectedProducto.forEach(prod => {
			if(!this.productoMultiFilter.includes(prod.value)){
				this.productoMultiFilter.push(prod.value);
			}				
		});

		
		
		this.selectedStatus.forEach(stat => {
			if(!this.statusMultiFilter.includes(stat.value)){
				this.statusMultiFilter.push(stat.value);
			}				
		});
		this.selectedStages.forEach(stag => {
			if(!this.stageMultiFilter.includes(stag.value)){
				this.stageMultiFilter.push(stag.value);
			}				
		});

		
		this.selectedPendingReason.forEach(pres => {
			if(!this.pendingReasonMultiFilter.includes(pres.value)){
				this.pendingReasonMultiFilter.push(pres.value);
			}				
		});
		this.selectedResolution.forEach(res => {
			if(!this.resolutionMultiFilter.includes(res.value)){
				this.resolutionMultiFilter.push(res.value);
			}				
		});
		
		this.getDataList(this.creationDateFilterFrom, this.creationDateFilterUntil, this.originMultiFilter, this.empresaMultiFilter, this.productoMultiFilter, this.altaClienteFilter, this.statusMultiFilter,this.stageMultiFilter, this.clientFilter, this.noClientFilter, this.employeMultiFilter, this.pendingReasonMultiFilter, this.resolutionMultiFilter, this.dueDateFilterFrom, this.dueDateFilterUntil, this.closeDateFilterFrom, this.closeDateFilterUntil,this.incomeAmountFilterFrom,this.incomeAmountFilterUntil ,this.page, this.office);
	}

	handleSearchAccount(event) {
		lookupSearchAccount(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup4"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup4"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSearchNoAccount(event) {
		lookupSearchNoAccount(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup2"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup2"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSearch(event) {
		lookupSearch(event.detail)
			.then((results) => {
				if (event.detail.myOffice == 'true') {
					this.template.querySelector('[data-id="lookup1"] > c-av_-lookup').setSearchResults(results);
				} else {
					this.template.querySelector('[data-id="lookup6"] > c-av_-lookup').setSearchResults(results);
				}
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleModal(event) {
		if(this.filterList != null && this.selectedItems > 0){
			if (event.target.className === 'my-office-true') {
				this.actionType = 'leadOppAsignar';
			} else {
				this.actionType = 'leadOppAsignarOtraOficina';
			}
			this.isModalOpen = true;
		}else if(this.filterList  == null){
			this.actionType = 'noEmpleado';
			this.isModalOpen = true;
		}else if(this.selectedItems === 0 || this.selectedItems === null) {
			this.actionType = 'noLeadOppos';
			this.isModalOpen = true;
		}
		
    }

	handleCloseModal() {
		this.isModalOpen = false;
	}

	doAction(event) {
        var actionType = event.detail.action;
		if (actionType == 'oppoAsignar' || actionType =='leadOppAsignar') {
			this.handleSave();
			this.template.querySelector('[data-id="lookup1"] > c-av_-lookup').handleClearSelection();
			this.selectedItems=null;
			this.filterList = null;
		} else if (actionType == 'oppoAsignarOtraOficina' || actionType == 'leadOppAsignarOtraOficina') {
			this.handleSave();
			this.template.querySelector('[data-id="lookup6"] > c-av_-lookup').handleClearSelection();
			this.selectedItems=null;
			this.filterList = null;
		} else {
			this.handleCloseModal();
		}
    }

	handleSave(){
		this.toggleSpinner();
		var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();
		// pop up de confirmacion
		if(selected != null && selected.length > 0){
			//Selected es 0 que no se ejecuted
			assign({contactId : this.filterList ,selectedRows : selected})
			.then(result => {
				if(result != null && result > 0) {
					const evt = new ShowToastEvent({
						title: 'Operación correcta',
						message: 'Se reasignarán ' + result + ' empleados a '+this.contactName+'. Esta operación puede tardar varios segundos.',
						variant: 'success',
						mode: 'dismissable'
					});
					this.dispatchEvent(evt);
				} else {
					const evt = new ShowToastEvent({
						title: 'Operación incorrecta',
						message: 'El usuario ' + this.contactName + ' no tiene un contacto asociado.',
						variant: 'error',
						mode: 'dismissable'
					});
					this.dispatchEvent(evt);
				}
				this.handleSearchData();
				this.toggleSpinner();
				this.handleCloseModal();
			})
			.catch(error => {
				console.log(error);
				this.toggleSpinner();
				this.handleCloseModal();
			});
		}else{
			this.handleCloseModal();
		}
		
	}

	onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.items];
		const sortFieldName = this.columns.find(field=>sortedBy===field.fieldName).sortBy; 
        cloneData.sort(this.sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1));
        this.items = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
						
	sortBy(field, reverse, primer) {

		if(field== 'AV_IncomeAmount__c'){

			const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

			return function(a, b) {
				a = key(a);
				b = key(b);
				var result;
				if (a == null) {
					result = 1;
				}
				else if (b == null) {
					result = -1;
				}else{
					result = (reverse * ((a  > b) - (b  > a )));
				};
				return result;
			}
		}else{
			
			const key = primer
				? function(x) {
					return primer(x[field]);
				}
				: function(x) {
					return x[field];
				};

			return function(a, b) {
				a = key(a);
				b = key(b);
				var result;
				if (a == null) {
					result= 1;
				}
				else if (b == null) {
					result= -1;
				}else{
					result=( reverse * ((a.toLowerCase()  > b.toLowerCase() ) - (b.toLowerCase()  > a.toLowerCase() )));
				};
				return result;
			}
		}
	}

	handleSelectionChange(event) {
		this.checkForErrors(event);
	}

	handleChangeCreationDateFrom(event) {
		this.creationDateFilterFrom = event.target.value;
	}

	handleChangeCreationDateUntil(event) {
		this.creationDateFilterUntil = event.target.value;
	}

	handleChangeDueDateFrom(event) {
		this.dueDateFilterFrom = event.target.value;
	}

	handleChangeDueDateUntil(event) {
		this.dueDateFilterUntil = event.target.value;
	}

	handleChangeCloseDateFrom(event) {
		this.closeDateFilterFrom = event.target.value;
	}

	handleChangeCloseDateUntil(event) {
		this.closeDateFilterUntil = event.target.value;
	}

	

	handleChangeIncomeAmountFrom(event){
		if(event.target.value==''){
			this.incomeAmountFilterFrom= null;							
		}else if(event.target.value!=''){
			this.incomeAmountFilterFrom= event.target.value;
		}
	}

	handleChangeIncomeAmountUntil(event){
		if(event.target.value==''){
			this.incomeAmountFilterUntil= null;
		}else if(event.target.value!=''){
			this.incomeAmountFilterUntil= event.target.value;
		}
			
	}

	


	checkForErrors(event) {
		this.errors = [];
		let targetId = event.target.dataset.id;
		if(targetId === 'clookup1'){
		  targetId = 'lookup1';
		}else if (targetId === 'clookup6') {
			targetId = 'lookup6';
		}
		if (targetId=='lookup1' || targetId == 'lookup6'){
			const selection = this.template.querySelector(`[data-id="${targetId}"] > c-av_-lookup`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.filterList  = String(sel.id);
				}
				this.contactNameA(this.filterList);
			} else {
				this.filterList = null;
			}
		} else if (targetId=='clookup4'){
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.clientFilter  = String(sel.id);
				}
			} else {
				this.clientFilter = null;
			}
		}else if(targetId=='clookup2'){
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.noClientFilter  = String(sel.id);
				}
			} else {
				this.noClientFilter = null;
			}
		}
	}

	/*get todaysDate() {
		var today = new Date();
		return today.getFullYear() + '-' + (today.getMonth()+1) + '-' + today.getDate();
	}*/

	contactNameA(contactId) {
		nameContactAssign({contactId : contactId})
			.then(result => {
				if(result != null) {
					this.contactName=result;
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

    getDataList(creationDateFilterFrom, creationDateFilterUntil, originMultiFilter, empresaMultiFilter, productoMultiFilter,altaClienteFilter,statusMultiFilter,stageMultiFilter, clientFilter, noClientFilter, employeMultiFilter, pendingReasonMultiFilter, resolutionMultiFilter, dueDateFilterFrom, dueDateFilterUntil, closeDateFilterFrom, closeDateFilterUntil, incomeAmountFilterFrom,incomeAmountFilterUntil,page, office){
		fetchData({creationDateFilterFrom : creationDateFilterFrom, creationDateFilterUntil : creationDateFilterUntil, originMultiFilter : originMultiFilter, empresaMultiFilter : empresaMultiFilter, productoMultiFilter : productoMultiFilter,altaClienteFilter : altaClienteFilter,statusMultiFilter : statusMultiFilter,stageMultiFilter : stageMultiFilter, clientFilter : clientFilter, noClientFilter : noClientFilter, employeMultiFilter : employeMultiFilter, pendingReasonMultiFilter : pendingReasonMultiFilter, resolutionMultiFilter : resolutionMultiFilter, dueDateFilterFrom : dueDateFilterFrom, dueDateFilterUntil : dueDateFilterUntil, closeDateFilterFrom : closeDateFilterFrom, closeDateFilterUntil : closeDateFilterUntil, incomeAmountFilterFrom : incomeAmountFilterFrom,incomeAmountFilterUntil : incomeAmountFilterUntil,page : page, office : office})
			.then(result => {
				this.iconName = 'standard:lead';
				this.helpMessage = false;
				this.columns = columnsLeadOpp;
				if(result.recordList != null && result.recordList.length > 0) {
					var rows = result.recordList;


					for (var i = 0; i < rows.length; i++) {
						var row = rows[i];
						if(row.Owner){
							row.OwnerName = row.Owner.Name;
							row.OwnerNameURL = '/'+row.OwnerId;
						}
						/*if(row.RecordType.Name){
							row.RecordType = row.RecordType.Name;
						}*/
						if(row.AV_Lead__c!=null && row.AV_Lead__c!=undefined){
							if(row.AV_Lead__r.AV_numperso__c!=null && row.AV_Lead__r.AV_numperso__c!=undefined){
								row.ClientName = row.AV_Lead__r.AV_numperso__r.Name;
								row.ClientURL = '/'+row.AV_Lead__r.AV_numperso__c;
							}/*else{
								row.ClientName = '';
								row.ClientURL = '';
							}*/
						}/*else{
							row.ClientName = '';
							row.ClientURL = '';
						}*/
						if(row.Name){
							row.LeadOppName = row.Name;
							row.NameURL = '/'+row.Id;
						}
						if (row.AV_Lead__c!=null && row.AV_Lead__c!=undefined) {
							if(row.AV_Lead__r.Name!=null){
								row.Lead=row.AV_Lead__r.Name;
							}else{
								//row.Lead='';
							}
						
						}else{
							//row.Lead='';
						}

						if(row.AV_Producto__c!=null && row.AV_Producto__c!=undefined){
							if(row.AV_Producto__r.Name!=null){
								row.Product2=row.AV_Producto__r.Name;
							}else{
								//row.Product2='';
							}
						}

						if(row.AV_Lead__c!=null && row.AV_Lead__c!=undefined){
							if(row.AV_Lead__r.AV_IsClient__c!=null){
								row.altaCliente=row.AV_Lead__c.AV_IsClient__c;
							}else{
								//row.altaCliente='';
							}
						}


					}

					if (this.page > 1) {
						this.data = this.data.concat(rows);
					} else {
						this.data = [];
						this.data = rows;
					}
					if (result.totalSize != -1) {
						this.size = result.totalSize;
					}
					if (this.size > 2000) {
						if (this.size === 100000) {
							this.totalRecountCount = 'Total 2000/' + this.size + '+';
						} else {
							this.totalRecountCount = 'Total 2000/' + this.size;
						}
						this.helpMessage = true;
						this.totalPage = this.MAX_PAGE_NUM;
					} else {
						this.totalRecountCount = 'Total ' + this.size;
						this.totalPage = Math.ceil(this.size / this.pageSize);
					}
					if (this.totalPage<=1) {
						this.isMultipagina= false;
					}else{
						this.isMultipagina= true;
					}

					this.items = this.data.slice((this.page-1)*100,this.pageSize*this.page); 
					this.endingRecord = this.pageSize;
					this.toggleSpinner();
				} else {
					this.totalRecountCount  = 'Total 0';
					this.toggleSpinner();
				}
			})
			.catch(error => {
				console.log(error)
				this.toggleSpinner();
			})
	} 

	handleChangePendingReason(event) {
		this.pendingReasonFilter = event.target.value;
		let pendingReasonPick;
		this.multiSelectionP++;
		
		for(let i=0;i<this.optionsPendingReason.length;i++){
			if(this.optionsPendingReason[i]['value']===event.target.value){
				pendingReasonPick=this.optionsPendingReason[i];
				pendingReasonPick['bucleId']=this.multiSelectionP;
				break;
			}
		}
		let insert = true;	
		if(this.selectedPendingReason.length > 0){
			for (let i = 0; i < this.selectedPendingReason.length; i++) {
				if (this.selectedPendingReason[i].value==pendingReasonPick.value) {
					insert = false;
					break;
				}
			}
		}	
		if (insert && pendingReasonPick['value']!=null) {
			this.selectedPendingReason.push(pendingReasonPick);
			this.pendingReasonDiv=true;
		}
		
		
		this.setButtonVisibility();
	}

	handleChangeStage(event) {
		this.stageFilter = event.target.value;
		let stagePick;
		this.multiSelectionS++;

		//Validar etapa para poner los distintos campos requeridos o no
		if(this.stageFilter === 'En gestión/insistir'){
			this.pendingReasonReqDiv = true;
		}else if(this.stageFilter === 'Cerrada Negativa'){
			this.resolutionReqDiv = true;
		}

		
		for(let i=0;i<this.optionsStage.length;i++){
			if(this.optionsStage[i]['value']===event.target.value){
				stagePick=this.optionsStage[i];
				stagePick['bucleId']=this.multiSelectionS;
				break;
			}
		}
		let insert = true;	
		if(this.selectedStages.length > 0){
			for (let i = 0; i < this.selectedStages.length; i++) {
				if (this.selectedStages[i].value==stagePick.value) {
					insert = false;
					break;
				}
			}
		}	
		if (insert && stagePick['value']!=null) {
			this.selectedStages.push(stagePick);	
			this.stageDiv=true;
		}
		
		
		this.setButtonVisibility();
	}

	handleChangeProducto(event) {  
		this.productoFilter = event.target.value;
		let productoPick;
		this.multiSelectionProducto++;

		for(let i=0;i<this.optionsLeadOppProducto.length;i++){ 
			if(this.optionsLeadOppProducto[i]['value']===event.target.value){
				productoPick=this.optionsLeadOppProducto[i];
				productoPick['bucleId']=this.multiSelectionProducto;
				break;
			}
		}
		let insert = true;	
		if(this.selectedProducto.length > 0){
			for (let i = 0; i < this.selectedProducto.length; i++) {
				if (this.selectedProducto[i].value==productoPick.value) {
					insert = false;
					break;
				}
			}
		}
		
		if (insert && productoPick['value']!=null) {
			this.selectedProducto.push(productoPick);
			this.productoDiv=true;
		}
		
		this.setButtonVisibility();
	}

	handleChangeAltaCliente(event){
		this.altaClienteFilter = event.target.value;
		
		this.setButtonVisibility();
	}

	handleChangeOrigin(event) {
		this.originFilter = event.target.value;
		let originPick;
		this.multiSelectionO++;
		for(let i=0;i<this.optionsOrigin.length;i++){
			if(this.optionsOrigin[i]['value']===event.target.value){
				originPick=this.optionsOrigin[i];
				originPick['bucleId']=this.multiSelectionO;
				break;
			}
		}
		let insert = true;	
		if(this.selectedOrigin.length > 0){
			for (let i = 0; i < this.selectedOrigin.length; i++) {
				if (this.selectedOrigin[i].value===originPick.value) {
					insert = false;
					break;
				}
			}
		}	
		if (insert && originPick['value']!=null) {
			this.selectedOrigin.push(originPick);
			this.originDiv=true;
		}
		this.setButtonVisibility();
	}


	handleChangeEmpresa(event) {
		this.empresaFilter = event.target.value;
		let empresaPick;
		this.multiSelectionEmpresa++;
		for(let i=0;i<this.optionsEmpresa.length;i++){
			if(this.optionsEmpresa[i]['value']===event.target.value){
				empresaPick=this.optionsEmpresa[i];
				empresaPick['bucleId']=this.multiSelectionEmpresa;
				break;
			}
		}
		let insert = true;	
		if(this.selectedEmpresa.length > 0){
			for (let i = 0; i < this.selectedEmpresa.length; i++) {
				if (this.selectedEmpresa[i].value===empresaPick.value) {
					insert = false;
					break;
				}
			}
		}	
		if (insert && empresaPick['value']!=null) {
			this.selectedEmpresa.push(empresaPick);
			this.empresaDiv=true;
		}
		this.setButtonVisibility();
	}


	
	
	handleChangeStatus(event) {
		this.statusFilter = event.target.value;
		let statusPick;
		this.multiSelectionStatus++;
		for(let i=0;i<this.optionsStatus.length;i++){
			if(this.optionsStatus[i]['value']===event.target.value){
				statusPick=this.optionsStatus[i];
				statusPick['bucleId']=this.multiSelectionStatus;
				break;
			}
		}
		let insert = true;	
		if(this.selectedStatus.length > 0){
			for (let i = 0; i < this.selectedStatus.length; i++) {
				if (this.selectedStatus[i].value==statusPick.value) {
					insert = false;
					break;
				}
			}
		}	
		if (insert && statusPick['value']!=null) {
			this.selectedStatus.push(statusPick);
			this.statusDiv=true;
		}
			
		this.setButtonVisibility();
	}

	


	handleChangeEmployee(event) {
		this.multiSelectionE++;
		this.employeeFilter = event.target.value;
		let employeeName="";
		for(let i=0;i<this.optionsEmployee.length;i++){
			if(this.optionsEmployee[i]['value']===event.target.value){
				employeeName=this.optionsEmployee[i]['label'];
				// if TODOS selected, remove everyone from selected list
				if (employeeName.includes('TODOS')) {
					this.selectedEmployees = [];
				}
				break;
			}
		}
		let insert = true;
		if(this.selectedEmployees.length > 0 ){
			// if TODOS selected, remove TODOS when someone gets added to selected list
			if (this.selectedEmployees[0]['label'].includes('TODOS')) {
				this.selectedEmployees.splice(0, 1); // 0 == TODOS
			}
			for (let i = 0; i < this.selectedEmployees.length; i++) {
				if (this.selectedEmployees[i]['label']===employeeName) {
					insert = false;
					break;
				}				
			}
		}			
		if (insert) {
			this.selectedEmployees.push({label:employeeName,id:event.target.value,bucleId:this.multiSelectionE});	
		}
		this.employeesDiv = true;
		this.setButtonVisibility();
	}
	
	handleChangeResolution(event) {
		this.resolutionFilter = event.target.value;
		let resolutionPick;
		this.multiSelectionR++;

		for(let i=0;i<this.optionsResolution.length;i++){
			if(this.optionsResolution[i]['value']===event.target.value){
				resolutionPick=this.optionsResolution[i];
				resolutionPick['bucleId']=this.multiSelectionR;
				break;
			}
		}
		let insert = true;	
		if(this.selectedResolution.length > 0){
			for (let i = 0; i < this.selectedResolution.length; i++) {
				if (this.selectedResolution[i].value==resolutionPick.value) {
					insert = false;
					break;
				}
			}
		}	
		if (insert && resolutionPick['value']!=null) {
			this.selectedResolution.push(resolutionPick);	
			this.resolutionDiv=true;
		}
		
		//this.resolutionDiv=true;
		this.setButtonVisibility();
	}

	//this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalNumberOfRecords) 
                            ? this.totalNumberOfRecords : this.endingRecord; 
        this.items = this.data.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }

	//clicking on previous button this method will be called
    previousHandler() {
		this.toggleSpinner();
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
		this.toggleSpinner();
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
			if (this.page*100 > this.data.length) {
				this.getDataList(this.creationDateFilterFrom, this.creationDateFilterUntil, this.originMultiFilter, this.empresaMultiFilter,this.productoMultiFilter,this.altaClienteFilter,this.statusMultiFilter,this.stageMultiFilter, this.clientFilter, this.noClientFilter, this.employeMultiFilter, this.pendingReasonMultiFilter, this.resolutionMultiFilter, this.dueDateFilterFrom, this.dueDateFilterUntil, this.closeDateFilterFrom, this.closeDateFilterUntil, this.incomeAmountFilterFrom,this.incomeAmountFilterUntil,this.page);
				this.toggleSpinner();
			}
			this.toggleSpinner();
            this.displayRecordPerPage(this.page);
			this.toggleSpinner();
        }             
    }

	unSelectStage(cmp){
		//Si quitan la etapa En gestion/insistir que no sea requerido Motivo Pendiente
		if(cmp.target.name === 'En gestión/insistir'){
			this.pendingReasonReqDiv = false;
		}
		
		if(cmp.target.name === 'Cerrada Negativa'){
			this.resolutionReqDiv = false;
		}
		for(let i=0;i<this.selectedStages.length;i++){
			if(this.selectedStages[i].value === cmp.target.name){
				this.selectedStages.splice(i,1);
				break;
			}
		}
		cmp.target.remove();
		if (this.selectedStages != null || typeof this.selectedStages != 'undefined') {
			if (this.selectedStages.length > 0) {
				this.stageFilter = this.selectedStages[this.selectedStages.length-1].value;
			} else if (this.selectedStages.length === 0) {
				this.stageFilter = null;
				this.stageDiv=false;
			}
		}
		this.setButtonVisibility();
	}

	
	unSelectProducto(cmp){
		for(let i=0;i<this.selectedProducto.length;i++){
			if(this.selectedProducto[i].value === cmp.target.name){
				this.selectedProducto.splice(i,1);
				break;
			}
		}
		cmp.target.remove();
		if (this.selectedProducto != null || typeof this.selectedProducto != 'undefined') {
			if (this.selectedProducto.length > 0) {
				this.productoFilter = this.selectedProducto[this.selectedProducto.length-1].value;
			} else if (this.selectedProducto.length === 0) {
				this.productoFilter = null;
				this.productoDiv=false;
			}
		}
		this.setButtonVisibility();
	}

	

	unSelectStatus(cmp){
		for(let i=0;i<this.selectedStatus.length;i++){
			if(this.selectedStatus[i].value === cmp.target.name){
				this.selectedStatus.splice(i,1);
				break;
			}
		}
		cmp.target.remove();
		if (this.selectedStatus != null || typeof this.selectedStatus != 'undefined') {
			if (this.selectedStatus.length > 0) {
				this.statusFilter = this.selectedStatus[this.selectedStatus.length-1].value;
			} else if (this.selectedStatus.length === 0) {
				this.statusFilter = null;
				this.statusDiv=false;
			}
		}
		this.setButtonVisibility();
	}

	unSelectOrigin(cmp){
		for(let i=0;i<this.selectedOrigin.length;i++){
			if(this.selectedOrigin[i].value === cmp.target.name){
				this.selectedOrigin.splice(i,1);
				break;
			}
		}
		cmp.target.remove();
		if (this.selectedOrigin != null || typeof this.selectedOrigin != 'undefined') {
			if (this.selectedOrigin.length > 0) {
				this.originFilter = this.selectedOrigin[this.selectedOrigin.length-1].value;
			} else if (this.selectedOrigin.length === 0) {
				this.originFilter = null;
				this.originDiv=false;
			}
		}
		this.setButtonVisibility();
	}

	
	unSelectEmpresa(cmp){
		for(let i=0;i<this.selectedEmpresa.length;i++){
			if(this.selectedEmpresa[i].value === cmp.target.name){
				this.selectedEmpresa.splice(i,1);
				break;
			}
		}
		cmp.target.remove();
		if (this.selectedEmpresa != null || typeof this.selectedEmpresa != 'undefined') {
			if (this.selectedEmpresa.length > 0) {
				this.empresaFilter = this.selectedEmpresa[this.selectedEmpresa.length-1].value;
			} else if (this.selectedEmpresa.length === 0) {
				this.empresaFilter = null;
				this.empresaDiv=false;
			}
		}
		this.setButtonVisibility();
	}

	unSelectEmployee(cmp){
		for(let i=0;i<this.selectedEmployees.length;i++){
			if(this.selectedEmployees[i].id === cmp.target.name){
				this.selectedEmployees.splice(i,1);
				break;
			}
		}
		cmp.target.remove();
		if (this.selectedEmployees != null || typeof this.selectedEmployees != 'undefined') {
			if (this.selectedEmployees.length > 0) {
				this.employeeFilter = this.selectedEmployees[this.selectedEmployees.length-1].id;
			} else if (this.selectedEmployees.length === 0) {
				this.employeeFilter = null;
				this.employeesDiv = false;
			}
		}
		this.setButtonVisibility();
	}

	unSelectPendingReason(cmp){
		for(let i=0;i<this.selectedPendingReason.length;i++){

			if(this.selectedPendingReason[i].value === cmp.target.name){
				this.selectedPendingReason.splice(i,1);
				break;
			}
		}
		cmp.target.remove();
		
		
		if (this.selectedPendingReason != null || typeof this.selectedPendingReason != 'undefined') {
			if (this.selectedPendingReason.length > 0) {
				this.pendingReasonFilter = this.selectedPendingReason[this.selectedPendingReason.length-1].value;
			} else if (this.selectedPendingReason.length === 0) {
				this.pendingReasonFilter = null;
				this.pendingReasonDiv = false;
			}
		}
		this.setButtonVisibility();
	}

	unSelectResolution(cmp){
		for(let i=0;i<this.selectedResolution.length;i++){
			if(this.selectedResolution[i].value === cmp.target.name){
				this.selectedResolution.splice(i,1);
				break;
			}
		}
		cmp.target.remove();
		if (this.selectedResolution != null || typeof this.selectedResolution != 'undefined') {
			if (this.selectedResolution.length > 0) {
				this.resolutionFilter = this.selectedResolution[this.selectedResolution.length-1].value;
			} else if (this.selectedResolution.length === 0) {
				this.resolutionFilter = null;
				this.resolutionDiv = false;
			}
		}
		this.setButtonVisibility();
	}

	/*get optionsLeadOppStage() {
		return [
			{ label: '', value: null },
			{ label: 'Potencial', value: 'Potencial' },
			{ label: 'En gestión/insistir', value: 'En gestión/insistir' },
			{ label: 'Cerrada Negativa', value: 'Cerrada Negativa' },
			{ label: 'Cerrada Positiva', value: 'Cerrada Positiva' },
			{ label: 'No apto', value: 'No apto' },
			{ label: 'Vencida', value: 'Vencida' },
			{ label: 'Con venta', value: 'Con venta' }
		];
	}*/
      
	get optionsLeadOppProducto() {
		return [
			{ label: '', value: null },
			{ label: 'Hipoteca', value: 'Hipoteca' }
		];
	}

	get optionsLeadOppAltaCliente(){
		return[
			{ label:'',value:null},
			{ label: 'Si',value : 'true'},
			{ label: 'No', value: 'false'}
		];
	}

	/*get optionsLeadOppOrigin() {
		return [
			{ label: '', value: null },
			{ label: 'Idealista', value: 'Idealista' },
			{ label: 'Rastreator', value: 'Rastreator' },
			{ label: 'iAhorro', value: 'iAhorro' },
			{ label: 'Helloteca', value: 'Helloteca' },
			{ label: 'Trioteca', value: 'Trioteca' }
		];
	}*/

	
	/*get optionsLeadOppEmpresa(){
		return[
			{label:'',value: null},
			{label: 'CaixaBank', value: 'CaixaBank'}
		]
	}*/



	
	/*get optionsLeadOppStatus() {
		return [
			{ label: '', value: null },
			{ label: 'Nuevo', value: 'Nuevo' },
			{ label: 'Enviada oferta comercial', value: 'Enviada oferta comercial' },
			{ label: 'Activo', value: 'Activo' },
			{ label: 'Cerrado', value: 'Cerrado' },
			{ label: 'Rechazado', value: '02' }
		];
	}*/

	/*get optionsPendingReason() {
		return [
			{ label: '', value: null },
			{ label: 'Propuesta: Enviada', value: 'Propuesta: Enviada' },
			{ label: 'Documentación: Cliente no localizado', value: 'Documentación: Cliente no localizado' },
			{ label: 'Documentación: Pendiente OK cliente', value: 'Documentación: Pendiente OK cliente' },
			{ label: 'Documentación: Pendiente de documentación', value: 'Documentación: Pendiente de documentación' },
			{ label: 'Documentación: Solicitada CIRBE/Nota Simple', value: 'Documentación: Solicitada CIRBE/Nota Simple' },
			{ label: 'Estudio Econ.: Traslado CARP', value: 'Estudio Econ.: Traslado CARP' },
			{ label: 'Estudio Econ.: Traslado Tarifa', value: 'Estudio Econ.: Traslado Tarifa' },
			{ label: 'Estudio Econ.: Tasación', value: 'Estudio Econ.: Tasación' },
			{ label: 'Estudio Econ.: Homologación Tasación', value: 'Estudio Econ.: Homologación Tasación' },
			{ label: 'Firma: Pendiente FEIN', value: 'Firma: Pendiente FEIN' },
			{ label: 'Firma: Provis. Fondos', value: 'Firma: Provis. Fondos' },
			{ label: 'Firma: Acta Notarial', value: 'Firma: Acta Notarial' },
			{ label: 'Firma: Pendiente Escriturar', value: 'Firma: Pendiente Escriturar' }
		];
	}*/

	/*get optionsResolution() {
		return [
			{ label: '', value: null },
			{ label: 'Lead PHD No Viable', value: 'Lead PHD No Viable' },
			{ label: 'Traspasada Consumo', value: 'Traspasada Consumo' },
			{ label: 'Traspasada HolaBank', value: 'Traspasada HolaBank' },
			{ label: 'Denegada/Automáticamente por Now', value: 'Denegada/Automáticamente por Now' },
			{ label: 'Denegada/Endeudamiento', value: 'Denegada/Endeudamiento' },
			{ label: 'Denegada/Finalidad no acreditable', value: 'Denegada/Finalidad no acreditable' },
			{ label: 'Denegada/Ingresos Inestables', value: 'Denegada/Ingresos Inestables' },
			{ label: 'Denegada/Morosidad', value: 'Denegada/Morosidad' },
			{ label: 'Denegada/No contratable por Now', value: 'Denegada/No contratable por Now' },
			{ label: 'Denegada/Operativa inadecuada', value: 'Denegada/Operativa inadecuada' },
			{ label: 'Denegada/Perfil de Riesgo', value: 'Denegada/Perfil de Riesgo' },
			{ label: 'Denegada/Reestructuración de deudas vigentes', value: 'Denegada/Reestructuración de deudas vigentes' },
			{ label: 'Denegada/Sin ahorros', value: 'Denegada/Sin ahorros' },
			{ label: 'Desistido cliente/Competencia, Precio', value: 'Desistido cliente/Competencia, Precio' },
			{ label: 'Desistido cliente/Documentación no recibida', value: 'Desistido cliente/Documentación no recibida' },
			{ label: 'Desistido cliente/En trámite o Decide ir a oficina', value: 'Desistido cliente/En trámite o Decide ir a oficina' },
			{ label: 'Desistido cliente/No localizado', value: 'Desistido cliente/No localizado' },
			{ label: 'Desistido cliente/Por el cliente en Now', value: 'Desistido cliente/Por el cliente en Now' },
			{ label: 'Desistido cliente/Sin vivienda', value: 'Desistido cliente/Sin vivienda' },
			{ label: 'Desistido cliente/Solicitud pospuesta', value: 'Desistido cliente/Solicitud pospuesta' },
			{ label: 'Desistido cliente/Sondeo concesión o Sol. información', value: 'Desistido cliente/Sondeo concesión o Sol. información' }
		];
	}*/

	


	getOptionsEmployee(){
		getEmployees().then(result => {
			if(result != null && result.length > 0) {
				this.optionsEmployee = result;
				this.employeeFilter = result[0].value;
				//this.selectedEmployees={}
				this.selectedEmployees=[{label:result[0].label,id:result[0].value,bucleId:this.multiSelectionE}]; 
			}
		}).catch(error => {
			console.log(error);
		})
	}

	
	getOptionsProducto(){
		getProducto().then(result => {
				if(result != null && result.length > 0) {
					this.optionsProducto = result;
				}
			}).catch(error => {
				console.log(error);
		})
	}

	getOriginPicklistValues(){
		getOriginValues().then(result => {
			if(result != null && result.length > 0) {
				this.optionsOrigin = result;
				
			}
		}).catch(error => {
			console.log(error);
		})
	}


	getStagePicklistValues(){
		getStageValues().then(result => {
			if(result != null && result.length > 0) {
				this.optionsStage = result;
				
			}
		}).catch(error => {
			console.log(error);
		})
	}

	getEmpresaPicklistValues(){
		getEmpresaValues().then(result => {
			if(result != null && result.length > 0) {
				this.optionsEmpresa = result;
				 
			}
		}).catch(error => {
			console.log(error);
		})
	}


	getPendingReasonPicklistValues(){
		getPendingReasonValues().then(result => {
			if(result != null && result.length > 0) {
				this.optionsPendingReason = result;
				 
			}
		}).catch(error => {
			console.log(error);
		})
	}

	getResolutionPicklistValues(){
		getResolutionValues().then(result =>{
			if(result!=null && result.length > 0){
				this.optionsResolution=result;
			}
		}).catch(error => {
			console.log(error);
		})

	}

	getAltaClientePicklistValues(){
		getAltaCliente().then(result => {
			if(result != null && result.length > 0) {
				this.optionsAltaCliente = result;
				 
			}
		}).catch(error => {
			console.log(error);
		})
	}


	getStatusPicklistValues(){
		getStatusValues().then(result => {
			if(result != null && result.length > 0) {
				this.optionsStatus = result;
				 
			}
		}).catch(error => {
			console.log(error);
		})
	}

	getSelectedName(event) {
		const selectedRows = event.detail.selectedRows;
		// Display that fieldName of the selected rows
		this.selectedItems = selectedRows.length;
	}

	setButtonVisibility() {
		//Estado si falta se desactiva el botón
		if (this.selectedStatus.length > 0) {
			this.buttonDisabled = false;
		}else{
			this.buttonDisabled = true;
		}
		//Comprobar si los campos requeridos son necesarios
		if(this.resolutionReqDiv===true){
			//Comprobar los array para ver si hay filtros puestos
			if(this.selectedStatus.length>0 && this.selectedResolution.length>0){
				this.buttonDisabled = false;
			}else{
				this.buttonDisabled = true;
			}
		}

			
		if(this.pendingReasonReqDiv===true && this.resolutionReqDiv===true){
			//Comprobar los array para ver si hay filtros puestos
			if(this.selectedStatus.length>0 && this.selectedResolution.length>0 && this.selectedPendingReason.length>0){
				this.buttonDisabled = false;
			}else{
				this.buttonDisabled = true;
			}
		}else if(this.pendingReasonReqDiv===true){
			//Comprobar los array para ver si hay filtros puestos
			if(this.selectedStatus.length>0 && this.selectedPendingReason.length>0){
				this.buttonDisabled = false;
			}else{
				this.buttonDisabled = true;
			}
		}
	}

    toggleShow() {
        if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
    }

    toggleSpinner() {
        this.showSpinner = !this.showSpinner;
    }

	//Equivale al init
	connectedCallback() {
		var today = new Date();
		var mes =today.getMonth()+1;
		if (mes<=9) {
			mes='0'.concat(mes);
		}
		var dia=today.getDate();
		if (dia<=9) {
			dia='0'.concat(dia);
		}
		var fecha=today.getFullYear() + '-' + mes + '-' + dia;
		this.todaysDate= fecha;
		this.creationDateFilterFrom=fecha;
		this.getCurrentOffice()
		this.getOptionsEmployee();
		this.getOriginPicklistValues();
		this.getEmpresaPicklistValues();
		this.getStagePicklistValues();
		this.getResolutionPicklistValues();
		this.getPendingReasonPicklistValues();
		this.getStatusPicklistValues();
		
		this.showDetail = true;
	}

	getCurrentOffice(){
		getOffice().then(result => {
			if(result != null && result.length > 0) {
				this.office = result;
			}
		}).catch(error => {
			console.log(error);
		})
	}

	resetFilters(){
		this.template.querySelectorAll('lightning-input').forEach(each => {
			each.value = '';
		});

		this.selectedStages = [];
		this.selectedStatus = [];
		this.selectedProducto=[];
		this.selectedOrigin = [];
		this.selectedEmpresa=[];
		this.selectedEmployees = [];
		this.selectedPendingReason = [];
		this.selectedResolution = [];

		try {
			const lookup4 = this.template.querySelector('[data-id="clookup4"]');
			const lookup2 = this.template.querySelector('[data-id="clookup2"]');
			if (lookup4 != null || typeof lookup4 != 'undefined') {
				lookup4.handleClearSelection()
			}
			if (lookup2 != null || typeof lookup2 != 'undefined') {
				lookup2.handleClearSelection()
			}
		} catch (e) {
			console.log('e1',e);
		}
		
		this.creationDateFilterFrom = null;
		this.creationDateFilterUntil = null;
		this.stageFilter = '';
		this.statusFilter = '';
		this.productoFilter='';
		this.altaClienteFilter=null;
		this.empresaFilter='';
		this.originFilter = '';
		this.clientFilter = null;
		this.noClientFilter = null;
		this.employeeFilter = null;
		this.pendingReasonFilter = '';
		this.resolutionFilter = '';
		this.dueDateFilterFrom = null;
		this.dueDateFilterUntil = null;
		this.closeDateFilterFrom = null;
		this.closeDateFilterUntil = null;
		this.incomeAmountFilterFrom = null;
		this.incomeAmountFilterUntil = null;

		this.pendingReasonReqDiv = false;
		this.resolutionReqDiv = false;

		this.stageDiv = false;
		this.originDiv = false;
		this.empresaDiv=false;
		this.productoDiv=false;
        this.altaClienteDiv=false;
		this.statusDiv = false;
		this.employeesDiv = false;
		this.resolutionDiv = false;
		this.pendingReasonDiv = false;

		this.setButtonVisibility();
	}

	
}