import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getQueryRecordTypeProceso from '@salesforce/apex/SIR_LCMP_ReassignOwner.getQueryRecordTypeProceso';
import getOficinaGestorActual from '@salesforce/apex/SIR_LCMP_ReassignOwner.getOficinaGestorActual';
import getOficinaString from '@salesforce/apex/SIR_LCMP_ReassignOwner.getOficinaString';
import getEmployees from '@salesforce/apex/SIR_LCMP_ReassignOwner.getEmployees';
import buscarProcesos from '@salesforce/apex/SIR_LCMP_ReassignOwner.buscarProcesos';
import changeGestor from '@salesforce/apex/SIR_LCMP_ReassignOwner.changeGestor';
import getOficinas from '@salesforce/apex/SIR_LCMP_ReassignOwner.getOficinas';
import findRecords  from '@salesforce/apex/SIR_LCMP_ReassignOwner.findRecords';
import USER_ID from '@salesforce/user/Id';
import LightningConfirm from 'lightning/confirm';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ESTRATEGIA_FIELD from '@salesforce/schema/SIREC__SIREC_obj_proceso__c.SIREC__SIREC_fld_estrategia__c';
import SITUACION_FIELD from '@salesforce/schema/SIREC__SIREC_obj_proceso__c.SIR_fld_Situacion_SF__c';

const columnsProceso = [
	{label: 'Proceso', fieldName: 'enlaceProceso', type: 'url',  typeAttributes: {label: { fieldName: 'nombreProceso' }}, sortable: true },
	{label: 'Cliente', fieldName: 'enlaceCliente', type: 'url', typeAttributes: {label: { fieldName: 'nombreCliente' }}, sortable: true },	
	{ type: 'text', fieldName: 'numDocumento', label: 'Núm. Documento', sortable: true },
	{ type: 'text', fieldName: 'estrategia', label: 'Estrategia', sortable: true },
    { type: 'date', fieldName: 'fechaInicio', label: 'Fecha Inicio', sortable: true },
    { type: 'text', fieldName: 'situacion', label: 'Situación', sortable: true },	
	{ label: 'Deuda Total', fieldName: 'deudaTotal', sortable: true, type: 'currency', typeAttributes: { currencyCode: 'EUR', step: '0.001' } },    
    { type: 'text', fieldName: 'oficina', label: 'Oficina Principal', sortable: true },
    { type: 'text', fieldName: 'propietario', label: 'Empleado', sortable: true },
	{ type: 'text', fieldName: 'ofiEmpleado', label: 'Oficina Empleado', sortable: true },
	{ type: 'text', fieldName: 'eap', label: 'EAP/Gestor', sortable: true }
];
 
export default class Sir_lwc_ReassignOwner extends LightningElement {

	@track clienteId; 
	@track fechaInicio;
	@track optionSituacion = [];
	@track valueSituacion;
	@track optionEstrategia = [];
	@track valueEstrategia;
	@track optionTipoProceso = [];
	@track valueTipoProceso;
	@track optionsEmpleado = [];
	@track valueEmpleado;

	@track disabledBuscar = true;
	@track disabledButtonAsignar = true;
	@track tituloTabla;

	@track recordsList;  
	@track searchKey = "";  
	@track selectedValue;  
	@track selectedRecordId;  
	@track objectApiName = ''; 
	@track oficina = "";  
	@track lookupLabel = 'Asignar a:';  
	@track message;

	@track oficinaGestorActual ='';
	@track nuevoGestor = '';
	@track oficinaIdOriginal = '';

	@track sel;
	@track data;
	@track columns;
	@track totalRecountCount;
	@track showSpinner = false;
	@track firstSearch = false;

   @track numRegistrosSeleccionados = 'Registros seleccionados: 0';
		
   @track showDetail = false;
   @track sortedBy;
   @track defaultSortDirection = 'asc';
   @track sortDirection = 'asc';
   @track showAssignment = true;
   @track procesosSeleccionados = [];
			
	@track filterList;
	@track contactName;
	@track selectedRows = [];
	@track opps; //All opportunities available for data table    
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
	@track selectedItems = 0;
	@track isModalOpen = false;
	@track actionType;
	//Paginación
	@track items;
	@track totalPage = 0;
	@track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 100; 
	@track page = 1; 
	@track isMultipagina = true;
	
	@track filterProduct;

	@track idProceso;
	@track funcionUsuario;
	@track esIntouch;
	@track esDan;
	@track centroSuperiorUserActual;

	@track optionOficina = [];
	@track valueOficina;
	@track valorInicialCampoEmpleados = null;

	@track idRecordTypeImpa = '';
	@track idRecordTypePresol = '';
	@track todosRecordTypes = '';

	connectedCallback() { 
        getQueryRecordTypeProceso({}).then(result => { 
			this.idRecordTypePresol = result[0].Id;            
            this.idRecordTypeImpa = result[1].Id; 
			this.optionTipoProceso.push({'label': 'PRESOL - Preventivo', 'value': result[0].Id});
			this.optionTipoProceso.push({'label': 'Impagados 1-90', 'value': result[1].Id});
			this.todosRecordTypes = result[0].Id + ',' + result[1].Id ;
        })
        .catch(error => {
            this.mensajeError = error;
        }); 
    }

	@wire(getPicklistValues, { recordTypeId: '$idRecordTypePresol', fieldApiName: ESTRATEGIA_FIELD })
    estrategiasPresol;
	@wire(getPicklistValues, { recordTypeId: '$idRecordTypeImpa', fieldApiName: ESTRATEGIA_FIELD })
    estrategiasImpa;

	@wire(getPicklistValues, { recordTypeId: '$idRecordTypePresol', fieldApiName: SITUACION_FIELD })
    situacionesPresol;
	@wire(getPicklistValues, { recordTypeId: '$idRecordTypeImpa', fieldApiName: SITUACION_FIELD })
    situacionesImpa;

	@wire(getOficinaGestorActual, {estrategiasPresol: '$estrategiasPresol', estrategiasImpa: '$estrategiasImpa', situacionesPresol: '$situacionesPresol', situacionesImpa: '$situacionesImpa'})
    wiredData(result) {
		if(result != null) {      
			// Se comprueba si ya se ha lanzado el wire de la picklist de estrategia y de situaciones, ya que si no se ha lanzado dara error
			if(this.estrategiasPresol.data != undefined && this.estrategiasImpa.data != undefined && this.situacionesPresol.data != undefined && this.situacionesImpa.data != undefined){
				for(let i = 0; i < this.estrategiasPresol.data.values.length; i++){ 
					this.optionEstrategia.push({'label': this.estrategiasPresol.data.values[i].label, 'value':this.estrategiasPresol.data.values[i].value});
				}
				for(let i = 0; i < this.estrategiasImpa.data.values.length; i++){ 
					if(this.estrategiasImpa.data.values[i].value != '30014' && this.estrategiasImpa.data.values[i].value != '10000' && this.estrategiasImpa.data.values[i].value != '10007'){
						this.optionEstrategia.push({'label': this.estrategiasImpa.data.values[i].label, 'value':this.estrategiasImpa.data.values[i].value});
					}
				}
				for(let i = 0; i < this.situacionesPresol.data.values.length; i++){ 
					if(this.situacionesPresol.data.values[i].value != 'SF_FINALIZ'){
						this.optionSituacion.push({'label': this.situacionesPresol.data.values[i].label, 'value':this.situacionesPresol.data.values[i].value});
					}                
				}
				for(let i = 0; i < this.situacionesImpa.data.values.length; i++){ 
					var existe = false;
					for(var j = 0; j < this.optionSituacion.length; j++) {
						if (this.optionSituacion[j].value == this.situacionesImpa.data.values[i].value) {
							existe = true;
							break;
						} 					
					}     
					if(!existe && this.situacionesImpa.data.values[i].value != 'SF_FINALIZ') {
						this.optionSituacion.push({'label': this.situacionesImpa.data.values[i].label, 'value':this.situacionesImpa.data.values[i].value});
					}          
				}
				var infoOficina = result.data.split('*');
				this.oficinaGestorActual = infoOficina[0];
				this.oficina = infoOficina[0];
				this.funcionUsuario = infoOficina[1];
				this.oficinaId = infoOficina[2];
				this.oficinaIdOriginal = infoOficina[2];
				this.esIntouch = infoOficina[3];
				this.esDan = infoOficina[4];
				this.centroSuperiorUserActual = infoOficina[5];		
				getOficinas({funcionUsuario: this.funcionUsuario, esIntouch: this.esIntouch, esDan: this.esDan, centroSuperiorUserActual: this.centroSuperiorUserActual, idOficina: this.oficinaIdOriginal }).then(result => {
					if(result != null && result.length > 0) {
						this.optionOficina = result;
						this.valueOficina = this.oficinaIdOriginal;
						getEmployees({													
							idOficina: this.oficinaIdOriginal, 													
							opcionTodasOficinas: false								
						}).then(result => {
							if(result != null && result.length > 0) {
								this.optionsEmpleado = result;
								this.valorInicialCampoEmpleados = result;
								this.valueEmpleado = USER_ID;
								this.showDetail = true; 
								this.disabledBuscar = false;
							}
						})												
					}
				})
			}
        }  
		           
    }	
	
	buscar() {
		this.toggleSpinner();
		this.firstSearch = true;
		this.items = null;
		this.totalPage = 0;
		this.startingRecord = 1;
		this.endingRecord = 0; 
		this.pageSize = 100; 
		this.page = 1; 
		this.isMultipagina = true;	
		this.nuevoGestor = '';
		this.disabledButtonAsignar = true;
		this.selectedRecordId = '';
		this.selectedValue = '';
		this.totalRecountCount  = 0;
		if(this.clienteId == ''){
			this.clienteId = null;
		}
		this.data = null;		
	
		var especial = '';
		if(this.esIntouch == 'siIntouch' && this.funcionUsuario == 'Oficina'){
			especial = 'siIntouch/Oficina';
		}else if(this.esDan == 'siDan'){
			especial = 'siDan';
		} else {
			especial = 'No';
		}
		let oficinaParaQuery;
		if(this.valueOficina != null){
			oficinaParaQuery = this.valueOficina;
		} else {
			oficinaParaQuery = this.oficinaIdOriginal;
		}
		var opcionTodasOficinas = '';
		if(this.valueOficina.includes(',')){ // Si contiene una coma significa que ha seleccionado la opcion de todas las oficinas y vienen en un string separado con asterisco
			opcionTodasOficinas = true;
		} else {
			opcionTodasOficinas = false;
		}
		var recordTypeQuery = '';
		if(this.valueTipoProceso != undefined && this.valueTipoProceso != ''){
			recordTypeQuery = this.valueTipoProceso;
		} else {
			recordTypeQuery = this.todosRecordTypes;
		}
        buscarProcesos({
			clienteId: this.clienteId, 
			fechaInicio: this.fechaInicio, 
			valueSituacion: this.valueSituacion, 
			valueEstrategia: this.valueEstrategia, 
			valueTipoProceso: recordTypeQuery, 
			valueEmpleado: this.valueEmpleado, 
			oficina: oficinaParaQuery,			
			opcionTodasOficinas: opcionTodasOficinas
		}).then(result => {
			if(result != null && result.length > 0) {
				var rows = result;	
				let currentData = [];
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
					let rowData = {};									
					if(row.Id){
						rowData.enlaceProceso = '/' + row.Id ;
						rowData.nombreProceso = row.Name;
					} 
					if(row.SIREC__SIREC_fld_cliente__c != null && row.SIREC__SIREC_fld_cliente__c != ''){
						rowData.enlaceCliente = '/lightning/r/Account/' + row.SIREC__SIREC_fld_cliente__r.Id+'/view';
						rowData.nombreCliente = row.SIREC__SIREC_fld_cliente__r.Name;
						rowData.numDocumento = row.SIREC__SIREC_fld_cliente__r.CC_Numero_Documento__c;
						if(row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c != null && row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c != ''){
							rowData.oficina = row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.Name;
						}   
						if(row.SIREC__SIREC_fld_cliente__r.AV_EAPGestor__c != null && row.SIREC__SIREC_fld_cliente__r.AV_EAPGestor__c != ''){  
							rowData.eap = row.SIREC__SIREC_fld_cliente__r.AV_EAPGestor__r.Name;
						}						
					}
					if(row.SIREC__SIREC_fld_estrategia__c != null && row.SIREC__SIREC_fld_estrategia__c != '') {
						rowData.estrategia = row.SIREC__SIREC_fld_estrategia__c;
					} 
					if(row.SIREC__SIREC_fld_fechaInicio__c != null && row.SIREC__SIREC_fld_fechaInicio__c != '') {
						rowData.fechaInicio = row.SIREC__SIREC_fld_fechaInicio__c;
					} 
					if(row.SIR_fld_Situacion_SF__c != null && row.SIR_fld_Situacion_SF__c != '') {
						rowData.situacion = row.SIR_fld_Situacion_SF__c;
					}
					if(row.SIR_DeudaTotal__c != null && row.SIR_DeudaTotal__c != '') {
						rowData.deudaTotal = row.SIR_DeudaTotal__c;
					}  
					if(row.OwnerId) {
						rowData.propietario = row.Owner.Name;												
						rowData.ofiEmpleado = row.Owner.AV_NumeroOficinaEmpresa__c;						
					}					
					currentData.push(rowData);							
                }
				this.columns = columnsProceso;				
				this.data = currentData;
				this.totalRecountCount = this.data.length;	
				this.tituloTabla = 'Resultados de la búsqueda: ' + this.totalRecountCount;			
				this.totalPage = Math.ceil(this.data.length / this.pageSize); 				
				if (this.totalPage<=1) {
					this.isMultipagina= false;
				}else{
					this.isMultipagina= true;
				}				
				this.items = this.data.slice(0,this.pageSize);		
				this.endingRecord = this.pageSize;
				this.firstSearch = true;
				this.toggleSpinner();
			} else {
				this.totalRecountCount = 0;
				this.tituloTabla = 'Resultados de la búsqueda: ' + this.totalRecountCount;				
				this.firstSearch = true;
				this.toggleSpinner();
			}			
		}).catch(error => {
			this.toggleSpinner();
		})		
	}

	toggleSpinner() {
        this.showSpinner = !this.showSpinner;
    }	

	//Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
    }

	resetFilters(){
        this.clienteId = null;
		this.fechaInicio = null;
        this.valueSituacion = null;
        this.valueTipoProceso = null;
        this.valueEstrategia = null;
		this.optionsEmpleado = this.valorInicialCampoEmpleados;	
        this.valueEmpleado = USER_ID;
		this.firstSearch = false;
		this.items = null;
		this.totalPage = 0;
		this.startingRecord = 1;
		this.endingRecord = 0; 
		this.pageSize = 100; 
		this.page = 1; 
		this.isMultipagina = true;	
		this.totalRecountCount = 0;	
		this.valueOficina = this.oficinaIdOriginal;
		this.disabledBuscar = false;  	
	}

	toggleShow() {
        if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
    }

	getSelectedName(event) {
		this.procesosSeleccionados = [];		
		const selectedRows = event.detail.selectedRows;	
		this.selectedItems = selectedRows.length;		
		for(let i = 0; i < selectedRows.length; i++){
			this.procesosSeleccionados.push(selectedRows[i].enlaceProceso);
		}		
		if(this.procesosSeleccionados != null && this.procesosSeleccionados.length > 0){			
			this.numRegistrosSeleccionados = 'Registros seleccionados: '+ this.procesosSeleccionados.length;
		} else {
			this.numRegistrosSeleccionados = 'Registros seleccionados: 0';
			this.procesosSeleccionados = [];
		}
		if(this.procesosSeleccionados != null && this.procesosSeleccionados.length > 0 && this.nuevoGestor != null && this.nuevoGestor != '' && this.nuevoGestor != undefined){
			this.disabledButtonAsignar = false; 
		} else {
			this.disabledButtonAsignar = true; 
		}	
	}

	handleCloseModal() {
		this.isModalOpen = false;		
	}

	//clicking on previous button this method will be called
    previousHandler() {	
		this.procesosSeleccionados = [];
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
	}

    //clicking on next button this method will be called
    nextHandler(event) {		
		this.procesosSeleccionados = [];
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }  	          
    }

    //this method displays records page by page
    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 
        this.items = this.data.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }

    sortBy(field, reverse, primer) {
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
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.items];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.items = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
 
    changeCliente(event){
        this.clienteId = event.target.value;        
    }

    changeFechaInicio(event){
        this.fechaInicio = event.target.value;        
    }

    changeSituacion(event){
        this.valueSituacion = event.target.value;        
    }

    changeTipoProceso(event){
        this.valueTipoProceso = event.target.value;  
    }

    changeEmpleado(event){
        this.valueEmpleado = event.target.value; 
		this.disabledBuscar = false;    
    }

    changeEstrategia(event){
        this.valueEstrategia = event.target.value;        
    }

	changeFiltroOficina(event){
		this.disabledBuscar = true;
        this.valueOficina = event.target.value; 
		var opcionTodasOficinas = false;
		var idOficina = '';
		if(this.valueOficina.includes(',')){ // Si contiene una coma significa que ha seleccionado la opcion de todas las oficinas y vienen en un string separado con asterisco
			opcionTodasOficinas = true;			
			idOficina = this.valueOficina;
		} else {		
			idOficina = this.valueOficina;
		}			
		if(this.valueOficina != null){			
			getEmployees({ 
				idOficina: idOficina,				
				opcionTodasOficinas: opcionTodasOficinas
			}).then(result => {
				if(result != null && result.length > 0) {
					this.valueEmpleado = null;
					this.optionsEmpleado = result;															
				}
			})
		}      
    }	

	changeOficina(event){
		this.nuevoGestor = '';
		this.disabledButtonAsignar = true;
		this.selectedRecordId = '';
		this.selectedValue = '';
		this.oficina = '';        
		if(event.target.value != ''){			
			this.oficinaId = event.target.value;
			if(this.oficinaId != null){
				getOficinaString({oficina: this.oficinaId}).then(result => {
					if(result != null) {
						this.oficina = result;
					}
				})
			}   
		}		   
    }
    
	onLeave(event) {  
		setTimeout(() => {  
		 this.searchKey = "";  
		 this.recordsList = null;  
		}, 300);  
	}  
		 
	onRecordSelection(event) {  
		this.selectedRecordId = event.target.dataset.key;  
		this.selectedValue = event.target.dataset.name;  
		this.searchKey = "";  
		this.onSeletedRecordUpdate();  
	}  
	
	handleKeyChange(event) {  
		this.disabledButtonAsignar = true; 	
		this.searchKey = event.target.value;
		this.getLookupResult();		
	}  
	
	removeRecordOnLookup(event) { 
		this.disabledButtonAsignar = true; 
		this.searchKey = "";  
		this.selectedValue = null;  
		this.selectedRecordId = null;  
		this.recordsList = null;  		 
		//this.onSeletedRecordUpdate();  
	}  

	getLookupResult() {
		findRecords({ searchKey: this.searchKey, oficina: this.oficina})  
		.then((result) => {  
		if (result.length===0) {  
			this.recordsList = [];  
			this.message = "No se han encontrado resultados"; 
			this.disabledButtonAsignar = true;  
		} else {  				
			this.recordsList = result;  
			this.message = "";  
		}  
		this.error = undefined;  
		})  
		.catch((error) => {  
			this.error = error;  
			this.recordsList = undefined;  
		});  
	}  
	
	onSeletedRecordUpdate(){  
	const passEventr = new CustomEvent('recordselection', {  
		detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
		});  
		this.dispatchEvent(passEventr); 
		this.nuevoGestor = this.selectedRecordId;		
		if(this.procesosSeleccionados != null && this.procesosSeleccionados.length > 0){
			this.disabledButtonAsignar = false; 
		}	else {
			this.disabledButtonAsignar = true; 
		}	
	} 	

	async handleConfirmClick() {
        const result = await LightningConfirm.open({
            message: '¿Deseas cambiar el responsable de este proceso?',
            variant: 'headerless',
            label: 'this is the aria-label value',
        });
		if(result === true){
			this.cambiarGestor();
		}
    }

	cambiarGestor(){	
		this.toggleSpinner();
		let procesosId = [];
		for (let i = 0; i < this.procesosSeleccionados.length; i++){
			let result = this.procesosSeleccionados[i].replace("/", "");
			procesosId.push(result);
		}
		if(procesosId != null && procesosId.length > 0){
			changeGestor({nuevoGestor: this.nuevoGestor, procesos: procesosId})  
			.then((result) => {  
				if(result == 'OK') {					
					const evt = new ShowToastEvent({
						title: 'Operación correcta',
						message: 'Se han asignado correctamente',
						variant: 'success',
						mode: 'dismissable'
					});
					this.dispatchEvent(evt);
					this.buscar();
					this.toggleSpinner();					
				}				
			})  
			.catch((error) => {  
				this.error = error;  
				this.recordsList = undefined;
				const evt = new ShowToastEvent({
					title: 'Operación incorrecta',
					message: 'Ha ocurrido un error: '+ this.error,
					variant: 'error',
					mode: 'dismissable'
				});
				this.dispatchEvent(evt);  
			});
		}
	}

}