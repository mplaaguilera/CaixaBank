import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getQueryRecordTypeProceso from '@salesforce/apex/SIRE_LCMP_AsignarAnalista.getQueryRecordTypeProceso';
import getOficinaGestorActual from '@salesforce/apex/SIRE_LCMP_AsignarAnalista.getOficinaGestorActual';
import buscarProcesos from '@salesforce/apex/SIRE_LCMP_AsignarAnalista.buscarProcesos';
import buscarProcesosSinAnalista from '@salesforce/apex/SIRE_LCMP_AsignarAnalista.buscarProcesosSinAnalista';
import changeAnalista from '@salesforce/apex/SIRE_LCMP_AsignarAnalista.changeAnalista';
import getDt from '@salesforce/apex/SIRE_LCMP_AsignarAnalista.getDt';
import getOficinas from '@salesforce/apex/SIRE_LCMP_AsignarAnalista.getOficinas';
import findRecords from '@salesforce/apex/SIRE_LCMP_AsignarAnalista.findRecords';
import USER_ID from '@salesforce/user/Id';
import LightningConfirm from 'lightning/confirm';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import SITUACION_FIELD from '@salesforce/schema/SIREC__SIREC_obj_proceso__c.SIR_fld_Situacion_SF__c';
import TIPOGESTION_FIELD from '@salesforce/schema/SIREC__SIREC_obj_proceso__c.SIR_TipoGestionPREVEMP__c';

const columnsProceso = [
	{label: 'Estrategia', fieldName: 'enlaceProceso', type: 'url',  typeAttributes: {label: { fieldName: 'estrategia' }, sortable: true}, sortable: true },
	{label: 'Cliente', fieldName: 'enlaceCliente', type: 'url', typeAttributes: {label: { fieldName: 'nombreCliente'}, sortable: true}, sortable: true },	
	{ type: 'text', fieldName: 'numDocumento', label: 'Núm. Documento', sortable: true, initialWidth: 115 }, //148
	{ type: 'text', fieldName: 'cnae', label: 'CNAE', sortable: true, initialWidth: 130 },	
	{ type: 'text', fieldName: 'tipoGestion', label: 'Tipo Gestión', sortable: true, initialWidth: 120 },	//130
	{ type: 'text', fieldName: 'stage', label: 'Stage', sortable: true, initialWidth: 93 },
    { type: 'date', fieldName: 'fechaInicio', label: 'Fecha Inicio', sortable: true, initialWidth: 115 },
    { type: 'text', fieldName: 'situacion', label: 'Situación', sortable: true },	
	{ label: 'Deuda Total', fieldName: 'deudaTotal', sortable: true, type: 'currency', typeAttributes: { currencyCode: 'EUR', step: '0.001' } },    
    { type: 'text', fieldName: 'oficina', label: 'Centro Principal', sortable: true },
    { type: 'text', fieldName: 'propietario', label: 'Empleado', sortable: true },
	{ type: 'text', fieldName: 'ofiEmpleado', label: 'Centro Empleado', sortable: true, initialWidth: 148 },
	{ type: 'text', fieldName: 'analista', label: 'Analista', sortable: true }
];
 
export default class Sire_lwc_AsignarAnalista extends LightningElement {

	@track optionSituacion = [];
	@track situaciones = '';
	@track valueSituacion;
	@track optionTipoProceso = [];
	@track valueTipoProceso;	
	@track optionTipoGestion = [];
	@track valueTipoGestion;
	@track valueAnalista = 'sinAnalista';
	@track valueStage = '';
	@track disabledBotonTodos = true;

	@track disabledBuscar = true;
	@track disabledButtonAsignar = true;
	@track tituloTabla;
    
	@track carGestorActual = [];
	@track valueCarGestorActual = '';
	@track oficinaIdRelacionada = '';
	@track nameUserActual = '';
	@track analistaRefi = '';

	@track data;
	@track columns;
	@track totalRecountCount;
	@track showSpinner = false;
	@track firstSearch = false;

	@track numRegistrosSeleccionados = 'Registros seleccionados: 0';	
	@track sortedBy;
	@track defaultSortDirection = 'asc';
	@track sortDirection = 'asc';
	@track showAssignment = true;
	@track procesosSeleccionados = [];
				
	@track selectedRows = [];    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
	@track selectedItems = 0;
	@track isModalOpen = false;
	//Paginación
	@track procesos;
	@track totalPage = 0;
	@track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 100; 
	@track page = 1; 
	@track isMultipagina = true;	

	@track optionOficina = [];
	@track valueOficina;
	@track valueOficinaBuscar;
	@track disabledCentro;
	@track requiredCentro;
	@track requiredDt;
	@track dtComercial = [];
	@track valueDtComercial;	
	@track disabledDT;
	@track idRecordTypePreventivo = '';

	@track recordsList;  
	@track searchKey = "";  
	@track selectedValue;  
	@track selectedRecordId;  
	@track objectApiName = ''; 
	@track oficina = "";  
	@track lookupLabel = 'Asignar a:';  
	@track message;
	
	connectedCallback() { 		
        getQueryRecordTypeProceso({}).then(result => {
			this.idRecordTypePreventivo = result;
        })
        .catch(error => {
            this.mensajeError = error;
        }); 
    }

	@wire(getPicklistValues, { recordTypeId: '$idRecordTypePreventivo', fieldApiName: SITUACION_FIELD })
    situacionesPreventivo;

	@wire(getPicklistValues, { recordTypeId: '$idRecordTypePreventivo', fieldApiName: TIPOGESTION_FIELD })
    tipoGestion;

	@wire(getOficinaGestorActual, {situacionesPreventivo: '$situacionesPreventivo', tipoGestion: '$tipoGestion'})
    wiredData(result) {			
		if(result != null) {			
			var opcionesSituacion = [];
			var opcionesTipoGestion = [];
			// Se comprueba si ya se ha lanzado el wire de la picklist de situacion y tipoGestion, ya que si no se ha lanzado dara error
			if(this.situacionesPreventivo.data !== undefined && this.tipoGestion.data !== undefined ){				
				for(let i = 0; i < this.situacionesPreventivo.data.values.length; i++){ 
					if(this.situacionesPreventivo.data.values[i].value !== 'SF_FINALIZ'){
						opcionesSituacion.push({label: this.situacionesPreventivo.data.values[i].label, value:this.situacionesPreventivo.data.values[i].value});
						if(this.situaciones === ''){
							this.situaciones = this.situacionesPreventivo.data.values[i].value;
						} else {
							this.situaciones = this.situaciones + ',' + this.situacionesPreventivo.data.values[i].value;
						}						
					}                
				}
				for(let i = 0; i < this.tipoGestion.data.values.length; i++){ 
					if(this.tipoGestion.data.values[i].value !== '1'){
						opcionesTipoGestion.push({'label': this.tipoGestion.data.values[i].label, 'value':this.tipoGestion.data.values[i].value});
					}                
				}
				var infoOficina = result.data.split('*');
				var opcionCentro = [];
				opcionCentro.push({'label': infoOficina[0], 'value': infoOficina[0]});					
				this.carGestorActual = opcionCentro;
				this.valueCarGestorActual = infoOficina[0];									
				this.oficinaIdRelacionada = infoOficina[1];
				this.nameUserActual = infoOficina[3];
				this.selectedRecordId = USER_ID;
				this.selectedValue = this.nameUserActual;
				this.analistaRefi = infoOficina[4];						
				this.template.querySelector('.radSinAnalista').checked = true;				
				this.optionSituacion = opcionesSituacion;
				this.optionTipoGestion = opcionesTipoGestion;
				if(this.analistaRefi === 'Si'){
					// Buscamos todas las DT para informar el desplegable de DT's
					getDt({}).then(resultDt => {
						if(resultDt != null && resultDt.length > 0) {
							this.template.querySelector('.radStageSi').checked = true;
							this.valueStage = 'si';
							this.dtComercial = resultDt;	
							this.disabledDT	= false;
							this.requiredDt = true;
							this.disabledCentro = true;
							this.requiredCentro = false;
							this.disabledBotonTodos = false;																	
						}
					})
				} else {
					// Buscamos las oficinas que dependen de la DT fija
					if(this.oficinaIdRelacionada != null && this.oficinaIdRelacionada !== undefined && this.oficinaIdRelacionada !== ''){
						getOficinas({idOficina: this.oficinaIdRelacionada }).then(resultOficina => {
							if(resultOficina != null && resultOficina.length > 0) {
								let opcionCentroComercial = [];
								opcionCentroComercial.push({'label': infoOficina[2], 'value': infoOficina[2]});
								this.dtComercial = opcionCentroComercial;
								this.valueDtComercial = infoOficina[2];
								this.template.querySelector('.radStageNo').checked = true;
								this.valueStage = 'no';
								this.disabledDT	= true;
								this.requiredDt = false;
								this.disabledCentro = false;
								this.requiredCentro = true;
								this.optionOficina = resultOficina;	
								this.disabledBotonTodos = false;																	
							}
						})
					}
				}						
			}
		} 
	}
	
	buscar() {
		this.toggleSpinner();
		this.firstSearch = true;		
		this.columns = columnsProceso;
		this.procesos = null;
		this.totalPage = 0;
		this.startingRecord = 1;
		this.endingRecord = 0; 
		this.pageSize = 100; 
		this.page = 1; 
		this.isMultipagina = true;	
		this.disabledButtonAsignar = true;
		this.disabledBotonTodos = false;
		this.totalRecountCount = 0;		
		this.data = null;	

		let idsOficinas = '';
		if(this.analistaRefi === 'Si'){			
			idsOficinas = this.valueDtComercial;
		} else {
			idsOficinas = this.valueOficinaBuscar;
		}
		let situacion;
		if(this.valueSituacion == null || this.valueSituacion === ''){
			situacion = this.situaciones;
		} else {
			situacion = this.valueSituacion;
		}
        buscarProcesos({
			valueSituacion: situacion, 			
			valueTipoGestion: this.valueTipoGestion,
			oficina: idsOficinas,
			valueTipoProceso: this.idRecordTypePreventivo,
			valueAnalista: this.valueAnalista,
			analistaRefi: this.analistaRefi,
			stageTres: this.valueStage
		}).then(result => {
			if(result != null && result.length > 0) {
				var rows = result;	
				let currentData = [];
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
					let rowData = {};									
					if(row.Id){
						rowData.enlaceProceso = '/' + row.Id ;
						//rowData.nombreProceso = row.Name;
					} 
					if(row.SIREC__SIREC_fld_cliente__c != null && row.SIREC__SIREC_fld_cliente__c !== ''){
						rowData.enlaceCliente = '/lightning/r/Account/' + row.SIREC__SIREC_fld_cliente__r.Id+'/view';
						rowData.nombreCliente = row.SIREC__SIREC_fld_cliente__r.Name;
						rowData.numDocumento = row.SIREC__SIREC_fld_cliente__r.CC_Numero_Documento__c;
						if(row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c != null && row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c !== ''){
							rowData.oficina = row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.Name;
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
					if(row.SIR_AnalistaRiesgo__c != null && row.SIR_AnalistaRiesgo__c !== ''){  
						rowData.analista = row.SIR_AnalistaRiesgo__r.Name;
					}
					if(row.SIR_TipoGestionPREVEMP__c != null && row.SIR_TipoGestionPREVEMP__c !== ''){  
						rowData.tipoGestion = row.SIR_TipoGestionPREVEMP__c;
					}	
					if(row.SIR_Stage__c != null && row.SIR_Stage__c !== ''){  
						rowData.stage = row.SIR_Stage__c;
					}
					if(row.SIREC__SIREC_fld_informacionCliente__c != null && row.SIREC__SIREC_fld_informacionCliente__c !== ''){
						if(row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__c != null && row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__c !== ''){
							let cnaeProvisional = '';
							if(row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Codigo__c != null && row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Codigo__c !== ''){  
								cnaeProvisional = row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Codigo__c.substring(4, 9);
							}
							if(row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Descripcion__c != null && row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Descripcion__c !== ''){  
								cnaeProvisional = cnaeProvisional + ' - ' + row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Descripcion__c;
							}
							if(cnaeProvisional !== ''){
								rowData.cnae = cnaeProvisional;
							}	
						}
					}		
					currentData.push(rowData);							
                }
								
				this.data = currentData;
				this.totalRecountCount = this.data.length;	
				this.tituloTabla = 'Resultados de la búsqueda: ' + this.totalRecountCount;			
				this.totalPage = Math.ceil(this.data.length / this.pageSize); 				
				if (this.totalPage<=1) {
					this.isMultipagina= false;
				}else{
					this.isMultipagina= true;
				}				
				this.procesos = this.data.slice(0,this.pageSize);		
				this.endingRecord = this.pageSize;
				this.firstSearch = true;
				this.toggleSpinner();
				// Nos posiciona en la parte de resultados
				let element = this.template.querySelectorAll('lightning-card');
				element[1].scrollIntoView();
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

	buscarSinAnalista(){
		this.toggleSpinner();
		this.firstSearch = true;		
		this.columns = columnsProceso;
		this.procesos = null;
		this.totalPage = 0;
		this.startingRecord = 1;
		this.endingRecord = 0; 
		this.pageSize = 100; 
		this.page = 1; 
		this.isMultipagina = true;	
		this.disabledButtonAsignar = true;
		this.totalRecountCount = 0;		
		this.data = null;
		
		let idsOficinas = '';
		if(this.analistaRefi === 'No'){			
			for (let i = 0; i < this.optionOficina.length; i++) {
				if(idsOficinas === ''){
					let labelOficina = this.optionOficina[i].label;
					let splitOfi = labelOficina.split('-');
					idsOficinas = splitOfi[0].trim();
				} else {
					let labelOficina = this.optionOficina[i].label;
					labelOficina.split('-');
					let splitOfi = labelOficina.split('-');
					idsOficinas = idsOficinas + "," + splitOfi[0].trim();
				}
			}
		}	
		let situacion;
		if(this.valueSituacion == null || this.valueSituacion === ''){
			situacion = this.situaciones;
		} else {
			situacion = this.valueSituacion;
		}
        buscarProcesosSinAnalista({ 
			valueSituacion: situacion,
			oficinasDt: idsOficinas,
			valueTipoProceso: this.idRecordTypePreventivo,
			analistaRefi: this.analistaRefi
		}).then(result => {
			if(result != null && result.length > 0) {
				var rows = result;	
				let currentData = [];
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
					let rowData = {};									
					if(row.Id){
						rowData.enlaceProceso = '/' + row.Id ;
					} 
					if(row.SIREC__SIREC_fld_cliente__c != null && row.SIREC__SIREC_fld_cliente__c !== ''){
						rowData.enlaceCliente = '/lightning/r/Account/' + row.SIREC__SIREC_fld_cliente__r.Id+'/view';
						rowData.nombreCliente = row.SIREC__SIREC_fld_cliente__r.Name;
						rowData.numDocumento = row.SIREC__SIREC_fld_cliente__r.CC_Numero_Documento__c;
						if(row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c != null && row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c !== ''){
							rowData.oficina = row.SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.Name;
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
					if(row.SIR_AnalistaRiesgo__c != null && row.SIR_AnalistaRiesgo__c !== ''){  
						rowData.analista = row.SIR_AnalistaRiesgo__r.Name;
					}
					if(row.SIR_TipoGestionPREVEMP__c != null && row.SIR_TipoGestionPREVEMP__c !== ''){  
						rowData.tipoGestion = row.SIR_TipoGestionPREVEMP__c;
					}	
					if(row.SIR_Stage__c != null && row.SIR_Stage__c !== ''){  
						rowData.stage = row.SIR_Stage__c;
					}
					if(row.SIREC__SIREC_fld_informacionCliente__c != null && row.SIREC__SIREC_fld_informacionCliente__c !== ''){
						if(row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__c != null && row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__c !== ''){
							let cnaeProvisional = '';
							if(row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Codigo__c != null && row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Codigo__c !== ''){  
								cnaeProvisional = row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Codigo__c.substring(4, 9);
							}
							if(row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Descripcion__c != null && row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Descripcion__c !== ''){  
								cnaeProvisional = cnaeProvisional + ' - ' + row.SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Descripcion__c;
							}
							if(cnaeProvisional !== ''){
								rowData.cnae = cnaeProvisional;
							}	
						}
					}					
					currentData.push(rowData);							
                }
								
				this.data = currentData;
				this.totalRecountCount = this.data.length;	
				this.tituloTabla = 'Resultados de la búsqueda: ' + this.totalRecountCount;			
				this.totalPage = Math.ceil(this.data.length / this.pageSize); 				
				if (this.totalPage<=1) {
					this.isMultipagina= false;
				}else{
					this.isMultipagina= true;
				}				
				this.procesos = this.data.slice(0,this.pageSize);		
				this.endingRecord = this.pageSize;
				this.firstSearch = true;
				this.toggleSpinner();
				// Nos posiciona en la parte de resultados
				let element = this.template.querySelectorAll('lightning-card');
				element[1].scrollIntoView();
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
        this.valueSituacion = null;
        this.valueTipoProceso = null;
		this.valueTipoGestion = null;		
		this.valueAnalista = 'sinAnalista';
		this.template.querySelector('.radSinAnalista').checked = true;
		if(this.analistaRefi === 'Si'){
			this.template.querySelector('.radStageSi').checked = true;
			this.valueDtComercial = null;
			this.valueStage = 'si';
		} else {
			this.template.querySelector('.radStageNo').checked = true;
			this.valueStage = 'no';
		}
		this.firstSearch = false;
		this.procesos = null;
		this.totalPage = 0;
		this.startingRecord = 1;
		this.endingRecord = 0; 
		this.pageSize = 100; 
		this.page = 1; 
		this.isMultipagina = true;	
		this.totalRecountCount = 0;	
		this.valueOficina = null;
		this.valueOficinaBuscar = null;
		this.disabledBuscar = true;  	
		this.selectedRecordId = USER_ID;
		this.selectedValue = this.nameUserActual;
	}


	getSelectedName(event) {
		this.procesosSeleccionados = [];		
		const selectedRows = event.detail.selectedRows;	
		this.selectedItems = selectedRows.length;		
		for (let i = 0; i < selectedRows.length; i++){
			this.procesosSeleccionados.push(selectedRows[i].enlaceProceso);
		}		
		if(this.procesosSeleccionados != null && this.procesosSeleccionados.length > 0){			
			this.numRegistrosSeleccionados = 'Registros seleccionados: '+ this.procesosSeleccionados.length;
		}	else {
			this.numRegistrosSeleccionados = 'Registros seleccionados: 0';
			this.procesosSeleccionados = [];
		}	
		if(this.procesosSeleccionados != null && this.procesosSeleccionados.length > 0 && this.selectedRecordId != null && this.selectedValue != null){			
			this.disabledButtonAsignar = false; 
		}	else {
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
    nextHandler() {		
		this.procesosSeleccionados = [];		
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }  	          
    }

    //this method displays records page by page
    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 
		this.procesos = this.data.slice(this.startingRecord, this.endingRecord);
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
		const cloneData = [...this.procesos];
		if(sortedBy === 'enlaceProceso'){
			cloneData.sort(this.sortBy('estrategia', sortDirection === 'asc' ? 1 : -1));
		} else if(sortedBy === 'enlaceCliente'){
			cloneData.sort(this.sortBy('nombreCliente', sortDirection === 'asc' ? 1 : -1));
		} else {
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		}        
        this.procesos = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
 
	changeAnalista(event){		
        this.valueAnalista = event.target.value; 
    }

    changeSituacion(event){
        this.valueSituacion = event.target.value;        
    }

    changeTipoGestion(event){
        this.valueTipoGestion = event.target.value;  
    }	

	changeFiltroOficina(event){	
		this.valueOficina = event.detail.value;
        this.valueOficinaBuscar = event.target.options.find(opt => opt.value === event.detail.value).label.substring(0,5);		
		this.disabledBuscar = false;
    }
	
	changeDT(event){		
        this.valueDtComercial = event.target.value;			
		this.disabledBuscar = false;
    }
	
	changeStage(event){
        this.valueStage = event.target.value;
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

	onSeletedRecordUpdate(){  
		const passEventr = new CustomEvent('recordselection', {  
			detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
		});  
		this.dispatchEvent(passEventr); 		
		if(this.procesosSeleccionados != null && this.procesosSeleccionados.length > 0){
			this.disabledButtonAsignar = false; 
		}else {
			this.disabledButtonAsignar = true; 
		}	
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
	}

	getLookupResult() {
		findRecords({ searchKey: this.searchKey})  
		.then((result) => {  
		if (result.length === 0) {  
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

	async handleConfirmClick() {
        const result = await LightningConfirm.open({
            message: '¿Confirma el cambio de Analista de Riesgo?',
            variant: 'headerless',
            label: 'this is the aria-label value',
        });
		if(result === true){
			this.cambiarAnalista();
		}
    }

	cambiarAnalista(){	
		this.toggleSpinner();
		let procesosId = [];
		for (let i = 0; i < this.procesosSeleccionados.length; i++){
			let result = this.procesosSeleccionados[i].replace("/", "");
			procesosId.push(result);
		}
		if(procesosId != null && procesosId.length > 0){
			changeAnalista({nuevoAnalista: this.selectedRecordId, procesos: procesosId})  
			.then((result) => {  
				if(result === 'OK') {					
					const evt = new ShowToastEvent({
						title: 'Operación correcta',
						message: 'Se han asignado correctamente',
						variant: 'success',
						mode: 'dismissable'
					});
					this.dispatchEvent(evt);
					window.location.reload();			
				}				
			})  
			.catch((error) => {  
				this.error = error;  
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