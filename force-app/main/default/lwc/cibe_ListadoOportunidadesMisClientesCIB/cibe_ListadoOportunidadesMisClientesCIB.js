import { LightningElement, track, wire,api } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//call controller
import fetchData from '@salesforce/apex/CIBE_ListadoOportunidadesMisClientesCIB.getOppsFilter';
import getPicklistValues from '@salesforce/apex/CIBE_MassReassignOwner_Controller.picklistValues';
import getPicklistValuesDepen from '@salesforce/apex/CIBE_MassReassignOwner_Controller.picklistValuesDependency';
import getEmployeesValues from '@salesforce/apex/CIBE_MassReassignOwner_Controller.getEmployeesCIB';
import getParticipeValues from '@salesforce/apex/CIBE_ListadoOportunidadesMisClientesCIB.getOpportunityTeams';
import getIndustriaValues from '@salesforce/apex/CIBE_ListadoOportunidadesMisClientesCIB.getIndustriaInter';
import getPaises from '@salesforce/apex/CIBE_ListadoOportunidadesMisClientesCIB.getPaises';
import getExport from '@salesforce/apex/CIBE_ListadoOportunidadesMisClientesCIB.exportOpportunities';

//fields
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from'@salesforce/schema/User.Name';
import FUNCTION from '@salesforce/schema/User.AV_Funcion__c';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import REDES_FIELD from '@salesforce/schema/Account.CIBE_RedesSegmentos__c';
import SECTOR_FIELD from '@salesforce/schema/Account.CIBE_SectoresPaises__c';
import CENTROS_FIELD from '@salesforce/schema/Account.CIBE_CentrosCarteras__c';

//flow
import getActions   from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getActions';

//labels
import recordLimitLabel from '@salesforce/label/c.AV_BuscadorRecordLimit';
import pendiente from '@salesforce/label/c.CIBE_Pendiente';
import pendienteAsig from '@salesforce/label/c.CIBE_PendienteAsignacion';
import pendienteNoLoc from '@salesforce/label/c.CIBE_PendienteNoLocalizado';
import gestionPosi from '@salesforce/label/c.CIBE_GestionadaPositiva';
import gestionNeg from '@salesforce/label/c.CIBE_GestionadaNegativa';
import noGestion from '@salesforce/label/c.CIBE_No_Gestionada';
import gestionNoLoc from '@salesforce/label/c.CIBE_GestionadoNoLocalizado';
import cliente from '@salesforce/label/c.CIBE_Cliente';
import origen from '@salesforce/label/c.CIBE_Origen';
import asunto from '@salesforce/label/c.CIBE_Asunto';
import estado from '@salesforce/label/c.CIBE_Estado';
import prioridad from '@salesforce/label/c.CIBE_Prioridad';
import feschaVen from '@salesforce/label/c.CIBE_FechaDeVencimiento';
import empleadoAs from '@salesforce/label/c.CIBE_EmplAsig';
import oficina from '@salesforce/label/c.CIBE_Oficina';
import alertaCom from '@salesforce/label/c.CIBE_Alerta_Comercial';
import avisos from '@salesforce/label/c.CIBE_Avisos';
import experienciCli from '@salesforce/label/c.CIBE_Experiencia_Cliente';
import gestionaPrior from '@salesforce/label/c.CIBE_Gestionar_Priorizados';
import onboarding from '@salesforce/label/c.CIBE_Onboarding';
import iniciativaGes from '@salesforce/label/c.CIBE_Iniciativa_Ges';
import fechaMay from '@salesforce/label/c.CIBE_fechaMayor';
import reasigTar from '@salesforce/label/c.CIBE_reasignarTareas';
import noContact from '@salesforce/label/c.CIBE_NoContact';
import debeInfo from '@salesforce/label/c.CIBE_debeInformar';
import verMasF from '@salesforce/label/c.CIBE_debeInformar';
import negocio from '@salesforce/label/c.CIBE_Negocio';
import redeSeg from '@salesforce/label/c.CIBE_RedeSeg';
import sectorPai from '@salesforce/label/c.CIBE_SectorPais';
import centCar from '@salesforce/label/c.CIBE_CentroCartera';
import selecciona from '@salesforce/label/c.CIBE_SeleccionaOpcion';
import exportar from '@salesforce/label/c.CIBE_Exportar';
import grupoComercial from '@salesforce/label/c.CIBE_GrupoComercial';
import gruposEconomico from '@salesforce/label/c.CIBE_GrupoEconomico';
import producto from '@salesforce/label/c.CIBE_Producto';
import importe from '@salesforce/label/c.CIBE_Importe';
import divisa from '@salesforce/label/c.CIBE_Divisa';
import importeEuros from '@salesforce/label/c.CIBE_ImporteEuros';
import impactoBalance from '@salesforce/label/c.CIBE_ImpactoEnBalance';
import impactoComisiones from '@salesforce/label/c.CIBE_ImpactoComisiones';
import impactoBalanceEuros from '@salesforce/label/c.CIBE_ImpactoEnBalanceEuros';
import impactoComisionesEuros from '@salesforce/label/c.CIBE_ImpactoEnComisionesEuros';
import tipoOperacion from '@salesforce/label/c.CIBE_TipoOperacion';
import etapa from '@salesforce/label/c.CIBE_Stage';
import fechaCierre from '@salesforce/label/c.CIBE_FechaCierre';
import diasUltimaGestion from '@salesforce/label/c.CIBE_DiasUltimaGestion';
import owner from '@salesforce/label/c.CIBE_Owner';
import centroCarteras from '@salesforce/label/c.CIBE_CentroCartera';
import sectoresPaises from '@salesforce/label/c.CIBE_SectorPais';
import redesSegmentos from '@salesforce/label/c.CIBE_RedeSeg';
import negocios from '@salesforce/label/c.CIBE_Negocio';
import gestorCliente from '@salesforce/label/c.CIBE_GestorCliente';
import name from '@salesforce/label/c.CIBE_Name';
import anterior from '@salesforce/label/c.CIBE_Anterior';
import posterior from '@salesforce/label/c.CIBE_Posterior';
import newOppor from '@salesforce/label/c.CIBE_NuevaOportunidad';
import filtroB from '@salesforce/label/c.CIBE_FiltrosBusqueda';
import pais from '@salesforce/label/c.CIBE_PaisOppo';
import equipoOppo from '@salesforce/label/c.CIBE_equipoOppo';
import industriaInter from '@salesforce/label/c.CIBE_IndustriaInter';
import buscar from '@salesforce/label/c.CIBE_buscar';
import reset from '@salesforce/label/c.CIBE_Reiniciar';
import etapaOpo from '@salesforce/label/c.CIBE_EtapaOportunidad';
import misClientes from '@salesforce/label/c.CIBE_MisClientes';
import esg from '@salesforce/label/c.CIBE_FinanciacionSostenible';

import potencial from '@salesforce/label/c.CIBE_Potencial';
import enCurso from '@salesforce/label/c.CIBE_EnCurso';
import pendFirma from '@salesforce/label/c.CIBE_PendienteFirma';
import cerradaPosi from '@salesforce/label/c.CIBE_CerradaPositiva';
import cerradaNeg from '@salesforce/label/c.CIBE_CerradaNegativa';
import vencida from '@salesforce/label/c.CIBE_Vencida';

import redsegSele from '@salesforce/label/c.CIBE_RedesSegSelec';
import sectPaisesSele from '@salesforce/label/c.CIBE_Sectpaisselec';
import centrosCartSele from '@salesforce/label/c.CIBE_Centrcarteraselec';
import equipoOprSele from '@salesforce/label/c.CIBE_Equipoportselec';
import etapasSele from '@salesforce/label/c.CIBE_Etapselec';
import paisesSele from '@salesforce/label/c.CIBE_Paisesselec';
import fechaCirreSele from '@salesforce/label/c.CIBE_FechaCierreselec';
import indInterSele from '@salesforce/label/c.CIBE_IndustriaInternselec';






export default class Cibe_ListadoOportunidadesMisClientesCIB extends LightningElement {

	labels = {
		negocio,
		redeSeg,
		sectorPai,
		centCar,
		pendiente,
		pendienteAsig,
		pendienteNoLoc,
		gestionPosi,
		gestionNeg,
		noGestion,
		gestionNoLoc,
		cliente,
		origen,
		asunto,
		estado,
		prioridad,
		feschaVen, 
		empleadoAs,
		oficina,
		alertaCom,
		avisos,
		experienciCli,
		gestionaPrior,
		onboarding,
		iniciativaGes,
		fechaMay,
		reasigTar,
		noContact,
		debeInfo,
        exportar,
		anterior,
        posterior,
		newOppor,
		filtroB,
		pais,
		equipoOppo,
		fechaCierre,
		industriaInter,
		reset,
		buscar,
		etapaOpo,
		misClientes,
		esg,
		potencial,
		enCurso,
		pendFirma,
		cerradaPosi,
		cerradaNeg,
		vencida,
		redsegSele,
		sectPaisesSele,
		centrosCartSele,
		equipoOprSele,
		etapasSele,
		paisesSele,
		fechaCirreSele,
		indInterSele
		
	}


	@track data;
	//@track columns;
	@track iconName;
	@track totalRecountCount;
	@track showSpinner = false;
	@track firstSearch = false;
	@track isFirst = true;
	labelUserId;
	@track initialSelection = [];
	@track errors = [];
	@track isMultiEntry = false;
	@track seeFiltersLabel = verMasF;
	@track optionsParticipe = [];
	@track optionsIndustria = [];
	@track optionsPais = [];
	@track optionsFecha = [];
	@api employeeDefault = USER_ID;
	@track showDetail = false;
	// table
	@api size = 0;
	@api MAX_PAGE_NUM = 20; //Query offset limit = 2000 (100 records * 20 pages)
	@track helpMessage = false;
	@api recordLimit = recordLimitLabel;
	//
	@api multiSelectionE = 0;
	@api multiSelectionS = 0;
	@api multiSelectionRds = 0;
	@api multiSelectionSect = 0;
	@api multiSelectionCent = 0;
	@api multiSelectionPais = 0;
	@api multiSelectionFech = 0;
	@api multiSelectionInds = 0;
	@api multiSelectionParticipe = 0;
	@track selectedParticipe = [];
	@track selectedStatus = [];
	@track selectedRedes = [];
	@api selectedRedes2 = [];
	@track selectedSect = [];
	@track selectedCent = [];
	@track selectedPais = [];
	@track selectedFech = [];
	@track selectedInd = [];
	@api participeMultiFilter = [];
	@api statusMultiFilter = [];
	@api redesMultiFilter = [];
	@api sectorMultiFilter = [];
	@api centroMultiFilter = [];
	@api paisMultiFilter = [];
	@api fechaMultiFilter = [];
	@api industriaMultiFilter = [];
	empleFuncion;
	@track isESG = false;
    @track isMisClientes = true;
	@track isIndustria = true;
	@track participeFilter;
	@track statusFilter = 'Open';
	@track paisFilter = '';
	@track industriaFilter;
	//@track selectedRows = [];
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track offset = 0; //Row number
	//Paginación
	@track items;
	@track totalPage = 0;
	@track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 20; 
	@track page = 1; 
	appOrigin;
	numOficinaEmpresa;
	//lookup
	@track inputValue;
    @track inputValue2;
    @track inputValue3;
    @track inputValue4;
	@track picklistValues;
	@track picklistValues2;
	@track picklistValues3;
    @track picklistValues4;
	@track centroCartera = null;
	@track redesSegmentos = null;
	@track negocios = null;
	@track sectoresSegmentos= null;
	@track centrosCarteras;
	@track initialSelectionRedes = [];
	@track initialSelectionNegocios = [];
	@track initialSelectionSectores = [];
	@track initialSelectionCentros = [];
	@api inputObj = 'Contact';
	@api inputField = 'Negocios';
	@api inputField2  = 'Redes-Segmentos';
	@api inputField3  = 'Sectores-Paises';
    @api inputField4  = 'Centros-Carteras';
	//Precarga valores campos
	@track negociosValue = selecciona;
	@track redesValue = selecciona;
	@track sectorValue = selecciona;
	@track centrosValue = selecciona;

	//instanciando variables globales
	@api statusPick;
	@api equipoPick;
	@api redesPick;
	@api sectoresPick;
	@api centrosPick;
	@api paisPick;
	@api fechaPick;
	@api industriaPick;
	@api insert;
	@api divToDel;
	@api industriaName;

    //Controladores Valores Selecionados
    @track redesDiv = false;
    @track sectoresDiv = false;
    @track centrosDiv = false;
    @track equiposDiv = false;
    @track statusDiv = false;
    @track paisesDiv = false;
    @track fechaDiv = false;
    @track industriaDiv = false;

	//flow
	actionSetting = 'CIBE_New_Opportunity_CIB';
	@track flowlabel;
	@track flowName;
	@track flowOutput;
	@track redirectId;
	@track objectAPIName;
	@track isShowFlowAction = false;

     //Export
    @track buttExp = true;
	@api element; 
    @api downloadElement;
    @track todayDate = new Date();
	@api columnHeader=[grupoComercial,gruposEconomico,cliente,name,etapa,importe,divisa,fechaCierre,tipoOperacion,producto,importeEuros,impactoBalance, 
		impactoComisiones, impactoBalanceEuros,impactoComisionesEuros,diasUltimaGestion,owner,negocios,redesSegmentos,sectoresPaises,centroCarteras,gestorCliente];

	columns = [
        { label: grupoComercial, fieldName: 'grupoComercialLink', type: 'url', typeAttributes: {label: { fieldName: 'grupoComercialName' } }},
		{ label: gruposEconomico, fieldName: 'grupoEconomico' },
        { label: cliente, fieldName: 'AccountLink', type: 'url', typeAttributes: {label: { fieldName: 'accountName' } }},
        { label: name, fieldName: 'OpportunityLink', type: 'url', typeAttributes: {label: { fieldName: 'OpportunityName' } }}, 
        { label: etapa, fieldName: 'stageName' },
        { label: importe, fieldName: 'amountDivisa', cellAttributes: { alignment: 'right' }},
        { label: divisa, fieldName: 'divisa'},
        { label: fechaCierre, fieldName: 'closeDate', type : 'date', typeAttributes : { day : '2-digit' , month : '2-digit', year : 'numeric' }},
        { label: tipoOperacion, fieldName: 'tipoOperaciones' },
        { label: producto, fieldName: 'productoLink', type: 'url', typeAttributes: {label: { fieldName: 'pFName' } }},
        { label: importeEuros, fieldName: 'amountEuro', cellAttributes: { alignment: 'right' }},
        { label: impactoBalance, fieldName: 'balanceDivisa', cellAttributes: { alignment: 'right' }},
        { label: impactoComisiones, fieldName: 'comisionesDivisa', cellAttributes: { alignment: 'right' }},
        { label: impactoBalanceEuros, fieldName: 'balance', cellAttributes: { alignment: 'right' }},
        { label: impactoComisionesEuros, fieldName: 'comisiones', cellAttributes: { alignment: 'right' }},
        { label: diasUltimaGestion, fieldName: 'diasUltimaGestion'},
        { label: owner, fieldName: 'ownerLink', type: 'url', typeAttributes: {label: { fieldName: 'ownerName' } }},
        { label: negocios, fieldName: 'negocios'},
        { label: redesSegmentos, fieldName: 'redesSegmentos'},
        { label: sectoresPaises, fieldName: 'sectoresPaises'},
        { label: centroCarteras, fieldName: 'centrosCarteras'},
        { label: gestorCliente, fieldName: 'eapGestorName' }
	];

	@wire(getRecord,{recordId:USER_ID,fields:[NAME_FIELD,FUNCTION,OFICINA]})
	wiredUser({error,data}){
		if(data){
			this.empleName=data.fields.Name.value;
			this.selectedEmployees = [];
			this.empleFuncion=data.fields.AV_Funcion__c.value;
			this.empleOfi = data.fields.AV_NumeroOficinaEmpresa__c.value;
			this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];
		}else if(error){
			console.log(error)
		}
	}
	connectedCallback() {
		this.showDetail = true;
	}

    get optionsOppoStatus() {
		return [
			{ label: this.labels.potencial, value: 'Potencial' },
            { label: this.labels.enCurso, value: 'En curso' },
			{ label: this.labels.pendFirma, value: 'CIBE_Pendiente_Firma' },
			{ label: this.labels.cerradaPosi, value: 'Cerrado negativo'},
			{ label: this.labels.cerradaNeg, value: 'CIBE_Cerrado positivo'},
			{ label: this.labels.vencida, value: 'CIBE_Vencido'}
		];
	}


	getDataList(redesFilter, sectoresFilter, centrosFilter, participeFilter, statusFilter, paisFilter, fechaCierreFilter, industriaFilter, isMisClientes, isESG, offset) {
		fetchData({redesFilter : redesFilter, sectoresFilter : sectoresFilter ,centrosFilter : centrosFilter ,participeFilter : participeFilter , statusFilter : statusFilter, 
			paisFilter : paisFilter, fechaCierreFilter : fechaCierreFilter, industriaFilter : industriaFilter, isMisClientes : this.isMisClientes, isESG : this.isESG,  offset : offset})
			.then(result => {
				this.helpMessage = false;
				this.iconName = 'standard:Opportunity';
				if(result != null && result.length > 0) {
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
						)
					)

					this.size = result.length;
					if (this.size > 20) {
						this.totalRecountCount = 'Total 2000/' + this.size;
					} else {
						this.totalRecountCount = 'Total ' + this.size;
						this.totalPage = Math.ceil(this.size / this.pageSize);
					}
					this.endnigRecord = this.pageSize;
					this.toggleSpinner();
					this.buttExp = false;
				} else {
					this.totalRecountCount  = 'Total 0';
					this.toggleSpinner();
				}

			})
			.catch(error => {
				console.log(error);
				this.toggleSpinner();
			})
	} 


	handleClear() {
		this.initialSelection = [];
		this.errors = [];
	}

	notifyUser(title, message, variant) {
		if (this.notifyViaAlerts) {
			alert(`${title}\n${message}`);
		} else {
			const toastEvent = new ShowToastEvent({ title, message, variant });
			this.dispatchEvent(toastEvent);
		}
	}

	handleSearchData() {
		//if(this.inputValue!=null){
			this.page = 1;
			this.size = 0;
			this.today = new Date();
				this.employeMultiFilter=[];
				this.statusMultiFilter=[];
				this.redesMultiFilter=[];
				this.sectorMultiFilter=[];
				this.centroMultiFilter=[];
				this.participeMultiFilter=[];
				this.industriaFilter=[];
				this.fechaCierreFilter=[];
				this.paisMultiFilter=[];
				this.selectedRedes.forEach(red => {
				if(!this.redesMultiFilter.includes(red.value)){
					this.redesMultiFilter.push(red.value);
				}
				});
				this.selectedSect.forEach(sel => {
					if(!this.sectorMultiFilter.includes(sel.value)){
						this.sectorMultiFilter.push(sel.value);
					}
				});
				this.selectedCent.forEach(sel => {
					if(!this.centroMultiFilter.includes(sel.value)){
						this.centroMultiFilter.push(sel.value);
					}
				});
				this.selectedParticipe.forEach(sel => {
					if(!this.participeMultiFilter.includes(sel.value)){
						this.participeMultiFilter.push(sel.value);
					}
				});
				this.selectedPais.forEach(sel => {
					if(!this.paisMultiFilter.includes(sel.value)){
						this.paisMultiFilter.push(sel.value);
					}
				});
				this.selectedFech.forEach(sel => {
					if(!this.fechaCierreFilter.includes(sel.value)){
						this.fechaCierreFilter.push(sel.value);
					}
				});
				this.selectedInd.forEach(sel => {
					if(!this.industriaFilter.includes(sel.value)){
						this.industriaFilter.push(sel.value);
					}
				});
				this.selectedStatus.forEach(stat => {
					if(!this.statusMultiFilter.includes(stat.value)){
						this.statusMultiFilter.push(stat.value);
					}				
				});
			if (this.isMisClientes || (!this.isMisClientes && this.selectedRedes != '')) {
				this.firstSearch = true;
				this.data = null;
				this.toggleSpinner();
				this.getDataList(this.redesMultiFilter, this.sectorMultiFilter, this.centroMultiFilter, this.participeMultiFilter, this.statusMultiFilter, this.paisMultiFilter, this.fechaCierreFilter, this.industriaFilter, this.isMisClientes, this.isESG, this.offset);			
			}else {
				const evt = new ShowToastEvent({
					title: 'Filtro incorrecto',
					message: 'Es necesario selecionar la jerarquia si no es un cliente que gestione',
					variant: 'error',
					mode: 'dismissable'
				});
				this.dispatchEvent(evt);
			}
		
	}

	toggleSpinner() {
        this.showSpinner = !this.showSpinner;
    }

	handleChangeEtapa(event) {
		this.statusFilter = event.target.value;
		this.multiSelectionS++;
		for(let i=0;i<this.optionsOppoStatus.length;i++){
			if(this.optionsOppoStatus[i]['value']===event.target.value){
				this.statusPick = this.optionsOppoStatus[i];
				this.statusPick['bucleId']=this.multiSelectionS;
				break;
			}
		}
		this.insert = true;
		if(this.selectedStatus.length > 0){
			for (let i = 0; i < this.selectedStatus.length; i++) {
				if (this.selectedStatus[i].value==this.statusPick.value) {
					this.insert = false;
					break;
				}
			}
		}	
		if (this.insert) {
			this.selectedStatus.push(this.statusPick);
		}
		this.statusDiv=true;
	}

	handleChangePais(event) {
		this.paisFilter = event.target.value;
		this.multiSelectionPais++;
		for(let i=0;i<this.optionsPais.length;i++){
			if(this.optionsPais[i]['value']===event.target.value){
				this.paisPick = this.optionsPais[i];
				//this.paisPick['bucleId']=this.multiSelectionPais;
				break;
			}
		}
		this.insert = true;
		if(this.selectedPais.length > 0){
			for (let i = 0; i < this.selectedPais.length; i++) {
				if (this.selectedPais[i].value==this.paisPick.value) {
					this.insert = false;
					break;
				}
			}
		}	
		if (this.insert) {
			this.selectedPais.push(this.paisPick);
		}
		this.paisesDiv=true;
	}

	unSelectStatus(cmp){
		this.divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedStatus.length;i++){
			if(this.selectedStatus[i].value === cmp.target.name){
				this.selectedStatus.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedStatus != null || typeof this.selectedStatus != 'undefined') {
			if (this.selectedStatus.length > 0) {
				this.statusFilter = this.selectedStatus[this.selectedStatus.length-1].value;
			} else if (this.selectedStatus.length === 0) {
				this.statusFilter = null;
				this.statusDiv = false;
			}
		}
	}

	unSelectPais(cmp){
		this.divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedPais.length;i++){
			if(this.selectedPais[i].value === cmp.target.name){
				this.selectedPais.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedPais != null || typeof this.selectedPais != 'undefined') {
			if (this.selectedPais.length > 0) {
				this.paisMultiFilter = this.selectedPais[this.selectedPais.length-1].value;
			} else if (this.selectedPais.length === 0) {
				this.paisFilter = null;
				this.paisMultiFilter = null;
				this.paisesDiv = false;
			}
		}
	}

	unSelectEquipo(cmp){
		this.divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedParticipe.length;i++){
			if(this.selectedParticipe[i].value === cmp.target.name){
				this.selectedParticipe.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedParticipe != null || typeof this.selectedParticipe != 'undefined') {
			if (this.selectedParticipe.length > 0) {
				this.participeFilter = this.selectedParticipe[this.selectedParticipe.length-1].value;
			} else if (this.selectedParticipe.length === 0) {
				this.participeFilter = null;
				this.equiposDiv = false;
			}
		}
		//this.setButtonVisibility();
	}

	unSelectRedes(cmp){
		this.divToDel = cmp.target.parentNode;
		
		for(let i=0;i<this.selectedRedes.length;i++){
			if(this.selectedRedes[i].value === cmp.target.name){
				this.selectedRedes.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		//cmp.target.remove();
		if (this.selectedRedes != null || typeof this.selectedRedes != 'undefined') {
			if (this.selectedRedes.length > 0) {
				this.inputValue2 = this.selectedRedes[this.selectedRedes.length-1].value;
				
			} else if (this.selectedRedes.length === 0) {
				this.inputValue2 = null;
				this.redesDiv = false;
			}
		}
		//this.setButtonVisibility();
	}


	unSelectSector(cmp){
		this.divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedSect.length;i++){
			if(this.selectedSect[i].value === cmp.target.name){
				this.selectedSect.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		//cmp.target.remove();
		if (this.selectedSect != null || typeof this.selectedSect != 'undefined') {
			if (this.selectedSect.length > 0) {
				this.inputValue3 = this.selectedSect[this.selectedSect.length-1].value;
			} else if (this.selectedSect.length === 0) {
				this.inputValue3 = null;
				this.sectoresDiv = false;
			}
		}
		//this.disabledIndustria();
	}

	unSelectCentro(cmp){
		this.divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedCent.length;i++){
			if(this.selectedCent[i].value === cmp.target.name){
				this.selectedCent.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedCent != null || typeof this.selectedCent != 'undefined') {
			if (this.selectedCent.length > 0) {
				this.inputValue4 = this.selectedCent[this.selectedCent.length-1].value;
			} else if (this.selectedCent.length === 0) {
				this.inputValue4 = null;
				this.centrosDiv = false;
			}
		}
	}

	unSelectFecha(cmp){
		this.divToDel = cmp.target.parentNode;
		for(let i=0;i<=this.selectedFech.length;i++){
			if(this.selectedFech[i].value === cmp.target.name){
				this.selectedFech.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedFech != null || typeof this.selectedFech != 'undefined') {
			if (this.selectedFech.length > 0) {
				this.fechaCierreFilter = this.selectedFech[this.selectedFech.length-1].value;
			} else if (this.selectedFech.length === 0) {
				this.fechaCierreFilter = null;
				this.fechaDiv = false;
			}
		}
		//this.setButtonVisibility();
	}

	unSelectIndustria(cmp){
		this.divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedInd.length;i++){
			if(this.selectedInd[i].value === cmp.target.name){
				this.selectedInd.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedInd != null || typeof this.selectedInd != 'undefined') {
			if (this.selectedInd.length > 0) {
				this.industriaFilter = this.selectedInd[this.selectedInd.length-1].value;
			} else if (this.selectedInd.length === 0) {
				this.industriaFilter = null;
				this.industriaDiv = false;
			}
		}
	}

	handleChangeDueDate2(event) {
		this.fechaCierreFilter = event.detail.value;
		this.multiSelectionFech++;
		this.optionsFecha.push({
			'label' : this.fechaCierreFilter,
			'value' : this.fechaCierreFilter
		});
		for(let i=0;i<this.optionsFecha.length;i++){
			if(this.optionsFecha[i]['value'] === event.detail.value){
				this.fechaPick = this.optionsFecha[i];
				this.fechaPick['bucleId'] = this.multiSelectionFech;
				break;
			}
		}
		this.insert = true;
		if(this.selectedFech.length > 0 ){
			for (let i = 0; i < this.selectedFech.length; i++) {
				if (this.selectedFech[i]===this.fechaPick) {
					this.insert = false;
					break;
				}				
			}
		}			
		if (this.insert) {
			this.selectedFech.push(this.fechaPick);	
		}
		this.fechaDiv = true;
	}
	
	handleValueChangeEquipoOpo(event) {
		this.multiSelectionParticipe++;
		this.participeFilter = event.detail.value;
		for(let i=0;i<this.optionsParticipe.length;i++){
			if(this.optionsParticipe[i]['value'] === event.detail.value){
				this.equipoPick = this.optionsParticipe[i];
				this.equipoPick['bucleId']=this.multiSelectionParticipe;
				this.participeName = this.optionsParticipe[i]['label'];
				// if TODOS selected, remove everyone from selected list
				if (this.participeName.includes('TODOS')) {
					this.selectedParticipe = [];
				}
				break;
			}
		}
		this.insert = true;
		if(this.selectedParticipe.length > 0 ){
			// if TODOS selected, remove TODOS when someone gets added to selected list
			if (this.selectedParticipe[0]['label'].includes('TODOS')) {
				this.selectedParticipe.splice(0, 1); // 0 == TODOS
			}
			for (let i = 0; i < this.selectedParticipe.length; i++) {
				if (this.selectedParticipe[i].value===this.equipoPick.value) {
					this.insert = false;
					break;
				}				
			}
		}			
		if (this.insert) {
			this.selectedParticipe.push(this.equipoPick);	
		}
		this.equiposDiv = true;
	}

	handleValueChangeIndustria(event) {
		this.multiSelectionInds++;
		this.industriaFilter = event.detail.value;
		for(let i=0;i<this.optionsIndustria.length;i++){
			if(this.optionsIndustria[i]['value'] === event.detail.value){
				this.industriaPick = this.optionsIndustria[i];
				this.industriaPick['bucleId']=this.multiSelectionInds;
				this.industriaName = this.optionsIndustria[i]['label'];
				break;
			}
		}
		this.insert = true;
		if(this.selectedInd.length > 0 ){
			for (let i = 0; i < this.selectedInd.length; i++) {
				if (this.selectedInd[i].value===this.industriaPick.value) {
					this.insert = false;
					break;
				}				
			}
		}			
		if (this.insert) {
			this.selectedInd.push(this.industriaPick);	
		}
		this.industriaDiv = true;
	}

	unSelectEmployee(cmp){
		this.divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedEmployees.length;i++){
			if(this.selectedEmployees[i].id === cmp.target.name){
				this.selectedEmployees.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedEmployees != null || typeof this.selectedEmployees != 'undefined') {
			if (this.selectedEmployees.length > 0) {
				this.employeeFilter = this.selectedEmployees[this.selectedEmployees.length-1].id;
			} else if (this.selectedEmployees.length === 0) {
				this.employeeFilter = null;
			}
		}
		this.setButtonVisibility();
	}

	//Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
    }

	resetFilters(){
		this.template.querySelectorAll('lightning-input').forEach(each => {
			each.value = '';
		});
		this.template.querySelectorAll('lightning-combobox').forEach(each => {
			each.value = '';
		});
		this.offset = 0;
		this.fechaCierreFilter = null;
		this.industriaFilter = null;
		this.statusFilter = null;
		this.paisFilter = null;
		this.participeFilter = null;
		this.employeeFilter = null;
		this.redesDiv = false;
		this.sectoresDiv = false;
		this.centrosDiv = false;
		this.equiposDiv = false;
		this.statusDiv = false;
		this.paisesDiv = false;
		this.fechaDiv = false;
		this.industriaDiv = false;
		this.equiposDiv = false;
		this.resetHierrarchy();
		this.selectedEmployees = [];
		this.selectedStatus = [];
		this.selectedPais= [];
		this.selectedFech= [];
		this.selectedInd = [];
		this.selectedRedes = [];
		this.selectedCent = [];
		this.selectedSect = [];
		this.selectedParticipe = [];
		this.statusMultiFilter = [];
		this.employeMultiFilter = [];
		this.isESG = false;
		this.firstSearch = false;
		this.isMisClientes = true;
		this.isIndustria = true;
		this.buttExp = true;

	}

	toggleShow() {
        if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
    }

    get getHasPrevious() {
        return this.offset <= 0;
    }

    get getHasNext() {
        return (this.offset >= 2000 || (this.data !== null && this.data !== undefined && this.data.length < 10));
    }
previousHandler() {
	this.toggleSpinner();
	this.offset = this.offset >= 10 ? (this.offset - 10) : this.offset;
	this.getDataList(this.redesMultiFilter, this.sectorMultiFilter, this.centroMultiFilter, this.participeMultiFilter, this.statusMultiFilter, this.paisMultiFilter, this.fechaCierreFilter, this.industriaFilter, this.isMisClientes, this.isESG, this.offset);
}

nextHandler() {
	this.toggleSpinner();
	this.offset = (this.offset <= 1990) ? (this.offset + 10) : this.offset;
	this.getDataList(this.redesMultiFilter, this.sectorMultiFilter, this.centroMultiFilter, this.participeMultiFilter, this.statusMultiFilter, this.paisMultiFilter, this.fechaCierreFilter, this.industriaFilter, this.isMisClientes, this.isESG, this.offset);			
}

// Selección de valores
	handleValueChange2(event){
		this.picklistValues3 = null;
		this.picklistValues4 = null;
        this.isMisClientes = false;
		this.inputValue2 = event.detail.value;
		this.inputValue3 = null;
		this.inputValue4 = null;
		this.getDependencyPicklist(this.inputField2, this.inputValue2, this.inputObj);
		this.getEmployees(this.inputValue2, false);
		this.redesMultiFilter = event.detail.value;
		this.multiSelectionRds++;
		for(let i=0;i<this.picklistValues2.length;i++){
			if(this.picklistValues2[i]['value'] === event.detail.value){
				this.redesPick = this.picklistValues2[i];
				this.redesPick['bucleId'] == this.multiSelectionRds;
				break;
			}
		}
		this.insert = true;
		if(this.selectedRedes.length > 0){
			for (let i = 0; i < this.selectedRedes.length; i++) {
				if (this.selectedRedes[i].value==this.redesPick.value) {
					this.insert = false;
					break;
				}
			}
		}	
		if (this.insert) {
			this.selectedRedes.push(this.redesPick);
		}
		this.selectedRedes.forEach(red => {
			if(!this.selectedRedes2.includes(red.label)){
				this.selectedRedes2.push(red.label);
			}
		});
		this.getIndustria(this.selectedRedes2);
		this.redesDiv=true;
    }

	handleValueChange3(event){
		this.picklistValues4 = null;
		this.inputValue3 = event.detail.value;
		this.inputValue4 = null;
		this.getDependencyPicklist(this.inputField3, this.inputValue3, this.inputObj);
		this.getEmployees(this.inputValue3, false);
		this.sectorMultiFilter = event.detail.value;
		this.multiSelectionSect++;
		for(let i=0;i<this.picklistValues3.length;i++){
			if(this.picklistValues3[i]['value'] === event.detail.value){
				this.sectoresPick = this.picklistValues3[i];
				this.sectoresPick['bucleId'] = this.multiSelectionSect;
				break;
			}
		}
		this.insert = true;
		if(this.selectedSect.length > 0){
			for (let i = 0; i < this.selectedSect.length; i++) {
				if (this.selectedSect[i].value==this.sectoresPick.value) {
					this.insert = false;
					break;
				}
			}
		}	
		if (this.insert) {
			this.selectedSect.push(this.sectoresPick);
		}
		this.sectoresDiv=true;
    }

	handleValueChange4(event){
		this.inputValue4 = event.detail.value;
		this.getEmployees(this.inputValue4, false);
		this.centroMultiFilter = event.detail.value;
		this.multiSelectionCent++;
		for(let i=0;i<this.picklistValues4.length;i++){
			if(this.picklistValues4[i]['value'] === event.detail.value){
				this.centrosPick = this.picklistValues4[i];
				this.centrosPick['bucleId'] = this.multiSelectionCent;
				break;
			}
		}
		this.insert = true;
		if(this.selectedCent.length > 0){
			for (let i = 0; i < this.selectedCent.length; i++) {
				if (this.selectedCent[i].value==this.centrosPick.value) {
					this.insert = false;
					break;
				}
			}
		}	
		if (this.insert) {
			this.selectedCent.push(this.centrosPick);
		}
		this.centrosDiv=true;
	}

	resetHierrarchy(){
		this.picklistValues2 = null;
		this.picklistValues3 = null;
		this.picklistValues4 = null;
		this.inputValue2 = null;
		this.inputValue3 = null;
		this.inputValue4 = null;
		this.selectedRedes = [];
		this.selectedCent = [];
		this.selectedSect = [];
		this.selectedParticipe = [];
		this.redesDiv = false;
		this.sectoresDiv = false;
		this.centrosDiv = false;
		this.equiposDiv = false;
		getPicklistValues({inputField:'Redes-Segmentos', inputObj: 'Contact'})
			.then((result) => {
				if(result != null && result.length > 0 ) {
					this.picklistValues2 = result;
				}
			})
			.catch(error => {
				this.picklistValues2 = undefined;
				console.log(error);
			}
			);
	}

	@wire(getPicklistValues, {inputField:'Redes-Segmentos', inputObj: 'Contact'})
		wiredPicklist({ data,error }){
        if(data){
			this.picklistValues2 = data;
        }else if(error){ 
            this.picklistValues2 = undefined;
			console.log(error);
        }
    }
	//traer todos los valores de picklistvalues
	@wire(getRecord,{recordId:'$recordId', fields:[REDES_FIELD,SECTOR_FIELD,CENTROS_FIELD]})
	wiredCentro({error,data}){
		if(data){
			if(data.fields.CIBE_RedesSegmentos__c.value != '' && data.fields.CIBE_RedesSegmentos__c.value != null){
				this.redesValue = data.fields.CIBE_RedesSegmentos__c.value;
			}
			if(data.fields.CIBE_SectoresPaises__c.value != '' && data.fields.CIBE_SectoresPaises__c.value != null){
				this.sectorValue = data.fields.CIBE_SectoresPaises__c.value;
			}
			if(data.fields.CIBE_CentrosCarteras__c.value != '' && data.fields.CIBE_CentrosCarteras__c.value != null){
				this.centrosValue = data.fields.CIBE_CentrosCarteras__c.value;
			}
		}else if(error){
			console.log(error);
		}
	}

	//Obetener dependencias del valor de la picklist en función de su inputField
	getDependencyPicklist(inputFld, inputVal, inputObjt){
		getPicklistValuesDepen({inputField: inputFld, inputValue: inputVal, inputObj: inputObjt})
						.then((data) => {
								switch(inputVal){
									case this.inputValue2:
										this.picklistValues3 = JSON.parse(JSON.stringify(data));
										if(data === null || data.length === 0 ) {
											this.picklistValues3 = JSON.parse(JSON.stringify(data));
										}									
									break;
                                    case this.inputValue3:
										this.picklistValues4 = JSON.parse(JSON.stringify(data));
										break;
								}
							})
							.catch(error => {
								console.log(error);
							}
						);
	}	

	getEmployees(idValue,allQuery){
		getEmployeesValues({searchTerm: this.employeeFilter, valueId: idValue, userLogin: USER_ID, userName: this.empleName, allQuery: allQuery})
			.then((result) => {
				if(result != null && result.length > 0 ) {
					this.optionsEmployee = JSON.parse(JSON.stringify(result));
				}
			})
			.catch(error => {
				console.log(error);
			}
		);
	}

	@wire(getParticipeValues,{isMisClientes: '$isMisClientes', redesSegmentos: '$inputValue2', sectoresPaises: '$inputValue3', centrosCarteras: '$inputValue4' })
	wiredParticipe({error,data}){
		if(data){
			if(data != null && data.length > 0 ) {
				this.optionsParticipe = JSON.parse(JSON.stringify(data));
			}else{
				this.optionsParticipe = [];
			}
		}else if(error){
			console.log(error);
		}
	}
	
	getIndustria(redesSegmentos){
		getIndustriaValues({redesSegmentos: redesSegmentos })
			.then((result) => {
				if(result != null && result.length > 0 ) {
					this.optionsIndustria= JSON.parse(JSON.stringify(result));
				}
			})
			.catch(error => {
				console.log(error);
			}
		);
	}

	@wire(getIndustriaValues,{redesSegmentos: '$selectedRedes2' })
	wiredIndustria({error,data}){
		if(data){
			if(data != null && data.length > 0 ) {
				this.optionsIndustria= JSON.parse(JSON.stringify(data));
			}
		}else if(error){
			console.log(error);
		}
	}
	
	@wire(getPaises)
		wiredPaises({ error,data }){
        if(data){
			this.optionsPais = data;
		}else if(error){ 
            this.optionsPais = undefined;
			console.log(error);
        }
    }
	
	handleESG(event) {
		this.isESG = event.detail.checked;
	}

    handleMisClientes(event) {
		this.isMisClientes = event.detail.checked;
        if(this.isMisClientes){
            this.resetHierrarchy();
        }
	}

    get height() {
        if(this.record === null || this.record === undefined || this.record.length === 0 ){
            return '';
        }
			var returnHeight = this.record.length;
			returnHeight = returnHeight * 32;
        return 'height: '+returnHeight;
        
    }

	get disabledIndustria() {
		this.isIndustria = true;
		if(this.selectedRedes.length > 0){
			for (let i = 0; i < this.selectedRedes.length; i++) {
				if (this.selectedRedes[i].label=='Sucursales' || this.selectedRedes[i].label=='ORS'  ) {
					this.isIndustria = false;
					break;
				}
			}
		}	
        return this.isIndustria;
    }

	exportData() {
		getExport({redesFilter : this.redesMultiFilter, sectoresFilter : this.sectorMultiFilter ,centrosFilter : this.centroMultiFilter ,participeFilter : this.participeMultiFilter , statusFilter : this.statusMultiFilter, 
				paisFilter : this.paisMultiFilter, fechaCierreFilter : this.fechaCierreFilter, industriaFilter : this.industriaFilter, isMisClientes : this.isMisClientes, isESG : this.isESG})
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
					downloadElement.download = 'Listado Oportunidades ' + (this.todayDate.getDate() + '-' + (this.todayDate.getMonth()+1) + '-' + this.todayDate.getFullYear()) + '.csv';
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
	//flow
	handleClickOppo() {
        getActions({ actionSetting: this.actionSetting })
        .then(data=>{
            this.isLoaded = false;
            this.flowlabel = data[0].label;
            this.flowName = data[0].name;
            this.flowOutput = data[0].output;
            this.redirectId = null;
            this.isShowFlowAction = true;
        }) .catch(error => {
            this.showToast(this.labels.error, this.labels.errorActualizandoEvento, 'error', 'pester');
            this.isLoaded = false;
        });
    }

    handleStatusChange(event) {
        const status = event.detail.status;
        const outputVariables = event.detail.outputVariables;
        if(outputVariables) {
            outputVariables.forEach(e => {
                this.flowOutput.split(',').forEach(v => {
                    if(e.name == v && e.value) {
                        this.redirectId = e.value;
                    }
                });
            });       
        }
        if(status === 'FINISHED') {
            this.isShowFlowAction = false;
            const selectedEvent = new CustomEvent('closetab', {detail: {recordId: this.redirectId}});
            this.dispatchEvent(selectedEvent);
            eval('$A.get("e.force:refreshView").fire();');
            if(this.redirectId) {
                var redirect = eval('$A.get("e.force:navigateToURL");');
                redirect.setParams({
                    "url": "/" + this.redirectId
                });
                redirect.fire();
            }
        }
    }

    hideFlowAction() {
        this.isShowFlowAction = false;
    }
}