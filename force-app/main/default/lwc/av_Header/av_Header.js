import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin }      from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getName      from '@salesforce/apex/AV_Header_Controller.getAccountInfo';
import getActions   from '@salesforce/apex/AV_Header_Controller.getActions';
import getFields    from '@salesforce/apex/AV_Header_Controller.getFields';
import getLoadDate    from '@salesforce/apex/AV_Header_Controller.getDateLoad';
import clientLabel from '@salesforce/label/c.AV_Client'
import BPRPS from '@salesforce/customPermission/AV_PrivateBanking';
import REPPS from '@salesforce/customPermission/AV_ReportClienteCP';

export default class Av_Header extends NavigationMixin(LightningElement) {

	 _currentPage;
	@wire(CurrentPageReference)
	wirePageRef(data){
		if(data){
			this._currentPage = data;
		}
	}
	@api recordId;
	@api showHeader;
	@api showBody;
	@api withPS; 
	
	//Header
	@api title;
	labelCliente = clientLabel;
	@api fieldName;
	@api icon;
	@api showHierarchy;
	@api actionSetting;
	//LIMITDROPDOWN = (BPRPS) ? 2 : 1;
	LIMITDROPDOWN2 = 2;

	//Body
	@api filterObject;
	@api fieldSetName;
	@track isBpr = (BPRPS != undefined);
	@track etiquetasCampos=[];
	@api resultMap;
	@track resultadosMapeados;
	@track name;
	@track _wiredName;
	@track actions = [];
	@track flowlabel;
	@track flowName;
	@track flowOutput;
	@track redirectId;
	@track isShowFlowAction = false;
	@track fields;
	@track recordType;
	@track isIntouch;
	@track _wiredFields;
	@track isRating = false;
	@track fechaCarga;
	@api fieldSearch;
	@api helpField;
	@track dropdownActions = [];
	@api objectApiName; 
	showDropdownActions = false;
	nameRecord;
	@track activityData = [];
	@track activityData2 =[];
	@track nameAccount;
	@track showFieldCheckboxMemorable = false;
	@track isChecked= false;
	@track account;
	@track navigatetoReportCustomButtonHeader = false;
	get isActivity(){
		return (this.objectApiName == 'Task' || this.objectApiName == 'Event');
	}
	@wire(getName, {recordId: '$recordId'})
	getNameData(wireResult) {
		let data = wireResult.data;
		let error = wireResult.error;
		this._wiredName = wireResult;
		if (data) {
			this.name = data[0];
			this.recordType = data[1];
			this.isIntouch = data[2];
			this.nameRecord = (this.objectApiName == 'Account') ? data[0] : data[3];
			this.account = data[4];
		} else if (error) {
			console.log(error);
		}
	}

	//Para usar en versiones futuras
	limitObjMap ={
		'Event':4,
		'Account' : 2,
		'Opportunity':2
	};

	@wire(getActions, { actionSetting: '$actionSetting' })
	getActions(wireResult) {
		let error = wireResult.error;
		let data = wireResult.data;
		if (data) {
			if(this.objectApiName == 'Account'){
				if(REPPS){
					this.showDropdownActions = true;
					
					let i = 0;
					data.forEach(act => {
						if(++i <= this.LIMITDROPDOWN2){
							this.actions.push(act);
						}else{
							this.dropdownActions.push(act);
						}
						
						this.showDropdownActions = this.dropdownActions.length > 0;
					})
				}else{
					this.actions = data;
					this.showDropdownActions = false;
					
				}
			}else{
				this.actions = data;
				this.showDropdownActions = false;
			}
		} else if (error) {
			console.log(error);
		}
	}
	
	connectedCallback(){
		this.isBpr = BPRPS;
	}

	@wire(getFields, {recordId: '$recordId', fieldSetName: '$fieldSetName'})
	getFieldsData(wireResult) {
		let error = wireResult.error;
		let data = wireResult.data;
		this._wiredData = wireResult;
		if (data) {
			const fieldList = data;
			if( !this.isActivity){
				this.fields = Object.values(fieldList).map(f => {
					var isCustomField = false;
					if(f.name == this.fieldSearch){
						isCustomField = true;
					}
					return {
						name: f.name,
						isCustomField: isCustomField
					};
				});

			}else{
				this.activityData;
				for(let key in data[0]){
					if(typeof data[0][key] === 'boolean'){
						if(data[0][key] == false || data[0][key]== null){
							this.activityData.push({
								label:key,
								checkbox2:true
							})
							this.isChecked = false;
						}else{
							this.activityData.push({
								label:key,
								checkbox:true
							})
							this.isChecked = true;
						}
					}else{
						this.activityData.push({
							label:key,
							value:data[0][key]
						})
					}
				}
				//Cliente relacionado
				this.activityData.map(ad =>{
					if(ad.value.includes('-')){
						let infoArray = ad.value.split('-');
						ad.value = infoArray[1];
						ad.relId = infoArray[0];
					}
					return ad;
				})
			}
		} else if (error) {
			console.log(error);
		}
	}

	navigateToRecord(e){
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'Account',
				recordId: e.target.name,
				actionName:'view'
			}
		})
	}

	hideFlowAction(event) {
		this.isShowFlowAction = false;
	}

	navigateToTab(tabName){
		this[NavigationMixin.Navigate]({
			type: 'standard__navItemPage',
			attributes: {
				// CustomTabs from managed packages are identified by their
				// namespace prefix followed by two underscores followed by the
				// developer name. E.g. 'namespace__TabName'
				apiName: tabName
			},state: {
				c__recId:this.recordId,
				c__id:this.name,
				c__rt:this.recordType,
				c__intouch:this.isIntouch,
				c__account:this.account
			}
		});
	}

	navigateToNewEvent(){
		this[NavigationMixin.Navigate]({
			type: 'standard__navItemPage',
			attributes: {
				// CustomTabs from managed packages are identified by their
				// namespace prefix followed by two underscores followed by the
				// developer name. E.g. 'namespace__TabName'
				apiName: 'AV_Reportar_cita'
			},state: {
				c__recId:this.recordId,
				c__id:this.name,
				c__rt:this.recordType,
				c__intouch:this.isIntouch
			}
		});
	}

	// navigateToReportClient() {
	navigateToHierarchy(event) {
		var evt = eval("$A.get('e.force:navigateToComponent')");
		evt.setParams({
			componentDef: "c:av_ReportAppointmentParent",
			componentAttributes: {
				accountId: this.recordId
			}
		});
		evt.fire();
	}

	get inputFlowVariables() {
		if(this.flowName == 'EV_SendInvitaionCampaign'){
			return [
				{              
					name: 'EV_RecordId',
					type: 'String',
					value: this.recordId
				}
			]
		}else{
			return [
				{
					name:'recordId',
					type: 'String',
					value: this.recordId
			   }
			]
		}
	}

	@wire(getLoadDate, {recordId: '$recordId', filterObject:'$filterObject', helpField:'$helpField'})
	getLoadDate(wireResult) {
		let error = wireResult.error;
		let data = wireResult.data;
		if (data) {
			this.fechaCarga = fechaModT + data;
		} else if (error) {
			console.log(error);
		}
	}

	fireFlowAction(event) {
		if(event.target.dataset.type === 'Flow'){
			this.flowlabel = event.target.dataset.label;
			this.flowName = event.target.dataset.flow;
			this.flowOutput = event.target.dataset.output;
			this.redirectId = null;
			this.isShowFlowAction = true;
		}else if(event.target.dataset.type === 'Tab'){
			this.navigateToTab(event.target.dataset.flow);
		}else if(event.target.dataset.type === 'Modal'){
			this.navigatetoReportCustomButtonHeader = true;
		}
	}

	handleStatusChange(event) {
		const status = event.detail.status;
		const outputVariables = event.detail.outputVariables;
		if(outputVariables && this.flowOutput != null) {
			outputVariables.forEach(e => {
				this.flowOutput.split(',').forEach(v => {
					if(e.name == v && e.value) {
						this.redirectId = e.value;
					}
				});
			});       
		}
		if(status === 'FINISHED') {
			this.hideFlowAction(event);
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
}