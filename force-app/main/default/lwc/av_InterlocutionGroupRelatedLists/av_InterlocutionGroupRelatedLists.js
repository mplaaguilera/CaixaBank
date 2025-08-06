import { LightningElement,track,wire,api } from 'lwc';

import getRecordsCurrentObject from '@salesforce/apex/AV_InterlocutionGroup_Controller.getRecordsCurrentObject';


import { getRecord} from 'lightning/uiRecordApi';

import NAME from '@salesforce/schema/AV_GrupoInterlocucion__c.Name';
import MEMBER from '@salesforce/schema/AV_GrupoInterlocucion__c.AV_Numper__c';
const columnsTsk=[
	{ label: 'Origen', fieldName: 'origin', type: 'text' ,hideDefaultActions: true,sortBy:'origin', wrapText:false,sortable:true,initialWidth:110},
	{ label: 'Miembro', fieldName:'account',type: 'miembro' ,typeAttributes:{isInterloc:{fieldName:'isInterloc'},nameAccount:{fieldName:'account'}},sortBy:'account',hideDefaultActions: true, wrapText:false,sortable:true,initialWidth:280},
	{ label: 'Asunto', fieldName: 'tskId', type: 'url',typeAttributes:{label:{fieldName:'subject'},tooltip:{fieldName:'subject'}},sortBy:'subject',hideDefaultActions: true, wrapText:false,sortable:true },
	{ label: 'Estado', fieldName: 'status', type: 'text' ,sortBy:'status',hideDefaultActions: true, wrapText:false,sortable:true,initialWidth:160},
	{ label: 'Fecha de vencimiento', fieldName: 'activityDate', type: 'date' ,sortBy:'activityDate',typeAttributes:{day:"2-digit",month:"short",year:"numeric"},hideDefaultActions: true, wrapText:false,sortable:true,initialWidth:120},
	{ label: 'Asignado a', fieldName: 'ownerUrlName', type: 'url',typeAttributes:{label:{fieldName:'ownerName'},tooltip:{fieldName:'ownerName'}},sortBy:'ownerName' ,hideDefaultActions: true, wrapText:false,sortable:true}
 ];

 const columnsEvt=[
	{ label: 'Tipo', fieldName: 'origin', type: 'text' ,sortBy:'origin',hideDefaultActions: true, wrapText:false,sortable:true},
	{ label: 'Miembro', fieldName:'account',type: 'miembro' ,sortBy:'account',typeAttributes:{isInterloc:{fieldName:'isInterloc'},nameAccount:{fieldName:'account'}},hideDefaultActions: true, wrapText:false,sortable:true},
	{ label: 'Asunto', fieldName: 'tskId', type: 'url',typeAttributes:{label:{fieldName:'subject'},tooltip:{fieldName:'subject'}},sortBy:'subject',hideDefaultActions: true, wrapText:false,sortable:true },
	{ label: 'Estado', fieldName: 'status', type: 'text' ,sortBy:'status',hideDefaultActions: true, wrapText:false,sortable:true,fixedWidth:90},
	{ label: 'Fecha y hora', fieldName: 'startdatetime', type: 'date',sortBy:'startdatetime',
	typeAttributes:{day:"2-digit",month:"short",year:"numeric",hour:"2-digit",minute:"2-digit"},
	hideDefaultActions: true, wrapText:false,sortable:true},
	{ label: 'Asignado a', fieldName: 'ownerUrlName', type: 'url',typeAttributes:{label:{fieldName:'ownerName'},tooltip:{fieldName:'ownerName'}} ,sortBy:'ownerName',hideDefaultActions: true, wrapText:false,sortable:true}
];


 const columnsOppo = [
	
	{ label: 'Oportunidades', fieldName: 'oppoId', type: 'url' ,typeAttributes:{label:{fieldName:'name'},tooltip:{fieldName:'name'}},sortBy:'name',hideDefaultActions: true, wrapText:false,sortable:true},
	{ label: 'Miembro', fieldName:'account',type: 'miembro' ,sortBy:'account',typeAttributes:{isInterloc:{fieldName:'isInterloc'},nameAccount:{fieldName:'account'}},hideDefaultActions: true, wrapText:false,sortable:true},
	{ label: 'Producto', fieldName: 'productId', type: 'url' ,typeAttributes:{label:{fieldName:'product'},tooltip:{fieldName:'name'}},hideDefaultActions: true,sortBy:'product', wrapText:false,sortable:true},
	{ label: 'Estado', fieldName: 'stage', type: 'text' ,sortBy:'stage',hideDefaultActions: true, wrapText:false,sortable:true},
	{ label: 'Otra entidad', fieldName: 'otraEntidad', type: 'text' ,sortBy:'otraEntidad',hideDefaultActions: true, wrapText:false,sortable:true},
	{ label: 'Última modificación', fieldName: 'ultimaModi', type: 'date' ,sortBy:'ultimaModi',hideDefaultActions: true,typeAttributes:{day:"2-digit",month:"short",year:"numeric"}, wrapText:false,sortable:true},
	{ label: 'Próxima gestión', fieldName: 'proximaGest', type: 'date' ,sortBy:'proximaGest',typeAttributes:{day:"2-digit",month:"short",year:"numeric"},hideDefaultActions: true, wrapText:false,sortable:true},
	{ label: 'Fecha de cierre', fieldName: 'fechaCierre', type: 'date' ,sortBy:'fechaCierre',typeAttributes:{day:"2-digit",month:"short",year:"numeric"},hideDefaultActions: true, wrapText:false,sortable:true},
	{ label: 'Oficina', fieldName: 'oficina', type: 'text' ,sortBy:'oficina',hideDefaultActions: true, wrapText:false,sortable:true},
	{ label: 'Empleado/a', fieldName: 'gestorId', type: 'url' ,typeAttributes:{label:{fieldName:'gestorName'},tooltip:{fieldName:'name'}},hideDefaultActions: true,sortBy:'gestorName', wrapText:false,sortable:true}
	

 ];
export default class AV_grupoInterlocutorSDG extends LightningElement{

	
@api recordId;
@api sdgApiName;
@api currentObject;
@api typeOfQueryOppo;
@track isOppo;
@track minWidthColOppo;
//Variables de la paginación
@track isMultipagina;
@track totalPage = 0;
@track pageSize = 10; 
@track page = 1; 
@track pageNumber = 1; 
@track numRecords=0;
@track optionsPage= [];
@track recordsToDisplay = [];

//Variables de ordenación
@track sortedBy;
@track sortDirection = 'asc';
@track defaultSortDirection = 'asc';


@track columns = [];
@track records = [];

@track showSpinner = false;
@track columnMode;
@track firstLoad = true;


@track relationTitleName = {'Task':'Tareas relacionadas','Event':'Eventos','Opportunity':'Oportunidades'};
@track relationsColumnsObject = {'Task':columnsTsk,'Event':columnsEvt,'Opportunity':columnsOppo};
grpName;

	get optionsPageSize() {
		return [
			{ label: '10', value: 10 },
			{ label: '20', value: 20 },
			{ label: '50', value: 50 },
			{ label: '100', value: 100 }
		];
	}

	
	@wire(getRecord , { recordId:'$recordId', fields:[NAME,MEMBER]})
	wiredAV_GrupoInterlocucion__c({data}){
		if(data){
			this.grpName = data.fields.Name.value;
			this.retrieveData();
		}
	}

	connectedCallback(){
		this.titleLabel = this.relationTitleName[this.currentObject];
		this.icon = 'standard:'+this.currentObject.toLowerCase();
		this.isOppo = this.currentObject == 'Opportunity'
	}

	retrieveData(){
		this.showSpinner = true;
	
		if(this.typeOfQueryOppo == 'NA'){
			this.typeOfQueryOppo = null;
		}
		getRecordsCurrentObject({grpName:this.grpName,currentObject:this.currentObject,typeOfQueryOppo:this.typeOfQueryOppo})
		.then(results=>{
			this.columns = this.relationsColumnsObject[this.currentObject];
			this.recordsToDisplay = [];
			this.records = [];
			if(results != null){
					results.forEach(record =>{
						record.account = this.capitaliseNames(record.account);
					})
					this.records = results;
					this.numRecords = results.length;
					// this.columnMode = 'fixed';
					this.columnMode = (this.currentObject == 'Opportunity')?'auto':'fixed';
                    this.minWidthColOppo = (this.currentObject == 'Opportunity')?180:null;
					this.totalPage = Math.ceil(this.numRecords / this.pageSize);
					this.pagination();

					
				}
			}).catch(error =>{
				console.log(error)
			})
	}

	pagination(){
		
		if (this.totalPage<=1 && this.firstLoad) {
			this.isMultipagina= false;
		}else{
			for(let i=1; i < this.totalPage+1; i++){
				var aux= { label: i.toString() , value: i };
				this.optionsPage.push(aux);
			}
			this.isMultipagina= true;
		}
		this.firstLoad = false;


		for(let i=(this.pageNumber-1)*this.pageSize; i < this.pageNumber*this.pageSize; i++){
			if(this.records[i] != null ){
				this.recordsToDisplay.push(this.records[i]);
			}
		}

		this.showSpinner = false;
	}

	capitaliseNames(name){
		let newName = "";
		let separateName = name.split(' ');

		separateName.forEach(word =>{
			newName += word.charAt(0).toUpperCase()+word.slice(1).toLowerCase()+" ";
		})

		return newName;

	}

	handleChangePageSize(event) {
		this.pageSize = event.detail.value;
		this.page=1;
		this.optionsPage=[];
		this.totalPage = Math.ceil(this.numRecords / this.pageSize);
		for(let i=1; i < this.totalPage+1; i++){
			var aux= { label: i.toString() , value: i };
			this.optionsPage.push(aux);
		}
        this.displayRecordPerPage(this.pageNumber);
	}
	handleChangePage(event) {
		this.page = event.detail.value;
        this.displayRecordPerPage(this.page);
	}
	displayRecordPerPage(page){
		this.recordsToDisplay = [];

		for(let i=(page-1)*this.pageSize; i < page*this.pageSize; i++){
			if(this.records[i] != null ){
				this.recordsToDisplay.push(this.records[i]);
			}
		}
	}


	handleSortdata(event) {
		const { fieldName: sortedBy, sortDirection } = event.detail;
		const cloneData = [...this.recordsToDisplay];
		const sortFieldName = this.columns.find(field=>sortedBy===field.fieldName).sortBy;
		cloneData.sort(this.sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1));
		this.recordsToDisplay = cloneData;
		this.sortDirection = sortDirection;
		this.sortedBy = sortedBy;
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