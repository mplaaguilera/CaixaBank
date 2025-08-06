import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getQueryRecordTypeProceso from '@salesforce/apex/SIRE_LCMP_ReassignOwner.getQueryRecordTypeProceso';
import getOficinaGestorActual from '@salesforce/apex/SIRE_LCMP_ReassignOwner.getOficinaGestorActual';
import getOficinaString from '@salesforce/apex/SIRE_LCMP_ReassignOwner.getOficinaString';
import getEmployees from '@salesforce/apex/SIRE_LCMP_ReassignOwner.getEmployees';
import buscarProcesos from '@salesforce/apex/SIRE_LCMP_ReassignOwner.buscarProcesos';
import changeGestor from '@salesforce/apex/SIRE_LCMP_ReassignOwner.changeGestor';
import getOficinas from '@salesforce/apex/SIRE_LCMP_ReassignOwner.getOficinas';
import findRecords  from '@salesforce/apex/SIRE_LCMP_ReassignOwner.findRecords';
import getEstrategiasNegocio  from '@salesforce/apex/SIR_cls_Utils.getEstrategiasNegocio';
import USER_ID from '@salesforce/user/Id';
import LightningConfirm from 'lightning/confirm';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
//import ESTRATEGIA_FIELD from '@salesforce/schema/SIREC__SIREC_obj_proceso__c.SIREC__SIREC_fld_estrategia__c';
import SITUACION_FIELD from '@salesforce/schema/SIREC__SIREC_obj_proceso__c.SIR_fld_Situacion_SF__c';

import { RefreshEvent } from "lightning/refresh";

const columnsProceso = [
	{label: 'Proceso', fieldName: 'enlaceProceso', type: 'url',  typeAttributes: {label: { fieldName: 'nombreProceso' }}, sortable: true },
	{label: 'Cliente', fieldName: 'enlaceCliente', type: 'url', typeAttributes: {label: { fieldName: 'nombreCliente' }}, sortable: true },	
	{ type: 'text', fieldName: 'numDocumento', label: 'Núm. Documento', sortable: true },
	{ type: 'text', fieldName: 'estrategia', label: 'Estrategia', sortable: true },
    { type: 'date', fieldName: 'fechaInicio', label: 'Fecha Inicio', sortable: true },
    { type: 'text', fieldName: 'situacion', label: 'Situación', sortable: true },	
	{ label: 'Deuda Total', fieldName: 'deudaTotal', sortable: true, type: 'currency', typeAttributes: { currencyCode: 'EUR', step: '0.001' } },    
    { type: 'text', fieldName: 'oficina', label: 'Centro Principal', sortable: true },
    { type: 'text', fieldName: 'propietario', label: 'Empleado', sortable: true },
	{ type: 'text', fieldName: 'ofiEmpleado', label: 'Centro Empleado', sortable: true },
	{ type: 'text', fieldName: 'eap', label: 'EAP/Gestor', sortable: true }
];
 
export default class Sire_lwc_ReassignOwner extends LightningElement {

	@track clienteId; 
	@track fechaInicio;
	@track optionSituacion = [];
	@track optionSituacionPreventivo = [];
	@track optionSituacionFlujo = [];
	@track optionEstrategiaPreventivo = [];
	@track optionEstrategiaFlujo = [];
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

	@track idRecordTypeFlujo = '';
	@track idRecordTypePreventivo = '';
	//@track todosRecordTypes = '';
	@track idProcesoImpagado = '';
	@track todasSituaciones = '';
	@track todasSituacionesPreventivo = '';
	@track todasSituacionesFlujo = '';
	@track negocioPreventivo = 'Preventivo';
	@track negocioFlujo = 'Flujo';
	
	connectedCallback() { 
        getQueryRecordTypeProceso({}).then(result => {
			this.idRecordTypePreventivo = result[0];            
            this.idRecordTypeFlujo = result[1]; 
			this.optionTipoProceso.push({'label': 'PREVEMP - Preventivo', 'value': result[0]});
			this.optionTipoProceso.push({'label': 'Flujo', 'value': result[1]});
			this.valueTipoProceso = result[1];
			this.idProcesoImpagado = result[1];
        })
        .catch(error => {
            this.mensajeError = error;
        }); 
    }

	
/*	@wire(getPicklistValues, { recordTypeId: '$idRecordTypePreventivo', fieldApiName: ESTRATEGIA_FIELD })
    estrategiasPreventivo;
	@wire(getPicklistValues, { recordTypeId: '$idRecordTypeFlujo', fieldApiName: ESTRATEGIA_FIELD })
    estrategiasFlujo;
*/	

	@wire(getEstrategiasNegocio, { negocio: '$negocioPreventivo' }) 
	estrategiasPreventivo;
	
	@wire(getEstrategiasNegocio, { negocio: '$negocioFlujo' })
	estrategiasFlujo;

	@wire(getPicklistValues, { recordTypeId: '$idRecordTypePreventivo', fieldApiName: SITUACION_FIELD })
    situacionesPreventivo;
	@wire(getPicklistValues, { recordTypeId: '$idRecordTypeFlujo', fieldApiName: SITUACION_FIELD })
    situacionesFlujo;

	@wire(getOficinaGestorActual, { estrategiasPreventivo: '$estrategiasPreventivo', estrategiasFlujo: '$estrategiasFlujo', situacionesPreventivo: '$situacionesPreventivo', situacionesFlujo: '$situacionesFlujo'})
    wiredData(result) {		
		if(result != null) { 
		
			if(this.estrategiasPreventivo.data !== undefined && this.estrategiasFlujo.data !== undefined && this.situacionesPreventivo.data !== undefined && this.situacionesFlujo.data !== undefined){
				for(let i = 0; i < this.estrategiasPreventivo.data.length; i++){ 
					this.optionEstrategiaPreventivo.push({'label': this.estrategiasPreventivo.data[i].SIREC__SIREC_fld_Descripcion__c, 'value':this.estrategiasPreventivo.data[i].SIREC__SIREC_fld_Codigo__c});
				}
				for(let i = 0; i < this.estrategiasFlujo.data.length; i++){ 	
					this.optionEstrategiaFlujo.push({'label': this.estrategiasFlujo.data[i].SIREC__SIREC_fld_Descripcion__c, 'value':this.estrategiasFlujo.data[i].SIREC__SIREC_fld_Codigo__c});					
				}
				this.optionEstrategia = this.optionEstrategiaFlujo;
				
				for(let i = 0; i < this.situacionesPreventivo.data.values.length; i++){ 
					if(this.situacionesPreventivo.data.values[i].value !== 'SF_FINALIZ'){
						this.optionSituacionPreventivo.push({'label': this.situacionesPreventivo.data.values[i].label, 'value':this.situacionesPreventivo.data.values[i].value});
						// Informamos la variable todasSituaciones con todas las situaciones de Preventivo
						if(this.todasSituacionesPreventivo === ''){
							this.todasSituacionesPreventivo = this.situacionesPreventivo.data.values[i].value;
						} else {
							this.todasSituacionesPreventivo = this.todasSituacionesPreventivo + ',' + this.situacionesPreventivo.data.values[i].value;
						}
					}                
				}
				for(let i = 0; i < this.situacionesFlujo.data.values.length; i++){ 					     
					if(this.situacionesFlujo.data.values[i].value !== 'SF_FINALIZ') {
						this.optionSituacionFlujo.push({'label': this.situacionesFlujo.data.values[i].label, 'value':this.situacionesFlujo.data.values[i].value});
						// Informamos la variable todasSituaciones con todas las situaciones de Flujo
						if(this.todasSituacionesFlujo === ''){
							this.todasSituacionesFlujo = this.situacionesFlujo.data.values[i].value;
						} else {
							this.todasSituacionesFlujo = this.todasSituacionesFlujo + ',' + this.situacionesFlujo.data.values[i].value;
						}
					}          
				}
				this.todasSituaciones = this.todasSituacionesFlujo;
				this.optionSituacion = this.optionSituacionFlujo;
				var infoOficina = result.data.split('*');
				this.oficinaGestorActual = infoOficina[0];
				this.oficina = infoOficina[0];
				this.oficinaId = infoOficina[1];
				this.oficinaIdOriginal = infoOficina[1];	
				getOficinas({idOficina: this.oficinaIdOriginal }).then(result => {
					if(result != null && result.length > 0) {
						this.optionOficina = result;
						this.valueOficina = this.oficinaIdOriginal;
						getEmployees({ idOficina: this.oficinaIdOriginal }).then(result => {
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
		if(this.clienteId === ''){
			this.clienteId = null;
		}
		this.data = null;	

		let oficinaParaQuery;
		if(this.valueOficina != null){
			oficinaParaQuery = this.valueOficina;
		} else {
			oficinaParaQuery = this.oficinaIdOriginal;
		}		
		var situacion = '';
		if(this.valueSituacion !== undefined && this.valueSituacion !== '' && this.valueSituacion != null){
			situacion = this.valueSituacion;
		} else {
			situacion = this.todasSituaciones;
		}
        buscarProcesos({
			clienteId: this.clienteId, 
			fechaInicio: this.fechaInicio, 
			valueSituacion: situacion, 
			valueEstrategia: this.valueEstrategia, 
			valueTipoProceso: this.valueTipoProceso, 
			valueEmpleado: this.valueEmpleado, 
			oficina: oficinaParaQuery
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
					if(row.SIREC__SIREC_fld_cliente__c != null && row.SIREC__SIREC_fld_cliente__c !== ''){
						rowData.enlaceCliente = '/lightning/r/Account/' + row.SIREC__SIREC_fld_cliente__r.Id+'/view';
						rowData.nombreCliente = row.SIREC__SIREC_fld_cliente__r.Name;
						rowData.numDocumento = row.SIREC__SIREC_fld_cliente__r.CC_Numero_Documento__c;
						if(row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c != null && row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c !== ''){
							rowData.oficina = row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.Name;
						}   
						if(row.SIREC__SIREC_fld_cliente__r.AV_EAPGestor__c != null && row.SIREC__SIREC_fld_cliente__r.AV_EAPGestor__c !== ''){  
							rowData.eap = row.SIREC__SIREC_fld_cliente__r.AV_EAPGestor__r.Name;
						}						
					}
					if(row.SIREC__SIREC_fld_descEstrategiaCatalogo__c != null && row.SIREC__SIREC_fld_descEstrategiaCatalogo__c !== '') {
						rowData.estrategia = row.SIREC__SIREC_fld_descEstrategiaCatalogo__c;
					} 
					if(row.SIREC__SIREC_fld_fechaInicio__c != null && row.SIREC__SIREC_fld_fechaInicio__c !== '') {
						rowData.fechaInicio = row.SIREC__SIREC_fld_fechaInicio__c;
					} 
					if(row.SIR_fld_Situacion_SF__c != null && row.SIR_fld_Situacion_SF__c !== '') {
						rowData.situacion = row.SIR_fld_Situacion_SF__c;
					}
					if(row.SIR_DeudaTotal__c != null && row.SIR_DeudaTotal__c !== '') {
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
        this.valueTipoProceso = this.idProcesoImpagado;
        this.valueEstrategia = null;
		this.optionEstrategia = this.optionEstrategiaFlujo;
		this.optionSituacion = this.optionSituacionFlujo;
		this.todasSituaciones = this.todasSituacionesFlujo;
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
		if(this.procesosSeleccionados != null && this.procesosSeleccionados.length > 0 && this.nuevoGestor != null && this.nuevoGestor !== '' && this.nuevoGestor !== undefined){
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
			if(a == null || a === undefined) {
				a = '';	
			} else if(b == null || b === undefined) {	
				b = '';			
			}
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.items];
        if(sortedBy === 'enlaceProceso'){
			cloneData.sort(this.sortBy('nombreProceso', sortDirection === 'asc' ? 1 : -1));
		} else if(sortedBy === 'enlaceCliente'){
			cloneData.sort(this.sortBy('nombreCliente', sortDirection === 'asc' ? 1 : -1));
		} else {
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		}
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
		let labelTipoProceso = event.target.options.find(opt => opt.value === event.detail.value).label;
		if(labelTipoProceso === 'Flujo'){
			this.optionEstrategia = this.optionEstrategiaFlujo;
			this.optionSituacion = this.optionSituacionFlujo;
			this.todasSituaciones = this.todasSituacionesFlujo;
		} else {
			this.optionEstrategia = this.optionEstrategiaPreventivo;
			this.optionSituacion = this.optionSituacionPreventivo;
			this.todasSituaciones = this.todasSituacionesPreventivo;
		}
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
		if(this.valueOficina != null){			
			getEmployees({ idOficina: this.valueOficina }).then(result => {
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
		if(event.target.value !== ''){			
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
		}else {
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
				if(result === 'OK') {					
					const evt = new ShowToastEvent({
						title: 'Operación correcta',
						message: 'Se han asignado correctamente',
						variant: 'success',
						mode: 'dismissable'
					});
					this.dispatchEvent(evt);
					this.dispatchEvent(new RefreshEvent());
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