import { LightningElement, track, api } from 'lwc';
import getCustomers from '@salesforce/apex/AV_CheckExistsCustomers_Controller.getCustomers';
import modal from "@salesforce/resourceUrl/CustomFlowModal";
import { loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from 'lightning/navigation';

const columnsCustomer = [
	{ label: 'Ingresos', fieldName: 'AV_Ingresos__c', type: 'currency', hideDefaultActions: true, wrapText:true, sortable: false},
	{ label: 'Financiación', fieldName: 'AV_Financiacion__c', type: 'currency', hideDefaultActions: true,  wrapText:true, sortable: false},
	{ label: 'Ahorro e Inversión', fieldName: 'AV_AhorroEInversion__c', type: 'currency', typeAttributes:{ label: { fieldName: 'ClientName' } }, hideDefaultActions: true, wrapText:true, sortable: false},
    { label: 'Rentabiliad', fieldName: 'AV_Rentabilidad__c', type: 'currency', sortable: false},
    { label: 'Movil', fieldName: 'PersonMobilePhone', type: 'phone', sortable: true},
    { label: 'Oficina principal', fieldName: 'AV_OficinaPrincipal__c', type: 'string', sortable: false},
	{ label: 'EAPGestor', fieldName: 'AV_EAPGestor__c', type: 'string',	hideDefaultActions: true, wrapText:true, sortable: false}
];

export default class Av_CheckExistsCustomer extends NavigationMixin(LightningElement){

    @track customerFilter = '';
    @api leadId;
	@api accsId;
	@track showSpinner = false;
	@track columns;
	@track items;
	@track data;
	@track view = true;


    @track optionsCustomers = [];


    //Equivale al init
	connectedCallback() {
		//window.addEventListener('resize', this.doResize);
		loadStyle(this, modal);
		this.getOptionsCustomers(this.leadId);
		this.toggleSpinner();
	}

    getOptionsCustomers(leadId){
		getCustomers({leadId : leadId}).then(result => {
			this.columns = columnsCustomer;
			this.data = null;
			if(result != null && result.recordList != null && result.recordList.length > 0) {
				var rows = result.recordList;
				for (var i = 0; i < rows.length; i++) {
					var row = rows[i];
					if(row.AV_OficinaPrincipal__c!=null && row.AV_OficinaPrincipal__c!=undefined){
						row.AV_OficinaPrincipal__c = row.AV_OficinaPrincipal__r.Name;
					}
					if(row.AV_EAPGestor__c!=null && row.AV_EAPGestor__c!=undefined){
						row.AV_EAPGestor__c = row.AV_EAPGestor__r.Name;
					}
				}
				this.data = [];
				this.data = rows;
				this.items = this.data.slice((0)*100,100*1);
			}else{
				this.view = false;
				this.accsId = 'No hay cuentas';
			}
			this.toggleSpinner();
		}).catch(error => {
			console.log(error);
		})
	}



	handleChangeCustomer(event) {
		this.customerFilter = event.target.value;
		let customerName="";
		for(let i=0;i<this.optionsCustomers.length;i++){
			if(this.optionsCustomers[i]['value']===event.target.value){
				customerName=this.optionsCustomers[i]['label'];
				break;
			}
		}
	}

	getSelectedName = event => {
		const selectedRows = event.detail.selectedRows;
		this.accsId = selectedRows[0].Id;
	}


	toggleSpinner() {
        this.showSpinner = !this.showSpinner;
    }

}