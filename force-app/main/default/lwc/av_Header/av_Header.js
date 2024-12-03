import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin }      from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } 	    from 'lightning/platformShowToastEvent';
import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';
import getName      from '@salesforce/apex/AV_Header_Controller.getAccountInfo';
import getActions   from '@salesforce/apex/AV_Header_Controller.getActions';
import getFields    from '@salesforce/apex/AV_Header_Controller.getFields';
import clientLabel from '@salesforce/label/c.AV_Client'
import BPRPS from '@salesforce/customPermission/AV_PrivateBanking';
import oldReportPS 	   from '@salesforce/customPermission/AV_OldReports';
import getIdFilterObject       	from '@salesforce/apex/AV_SObjectRelatedInfoCController.getIdFilterObject';
import caixaBankNowIcon  from '@salesforce/resourceUrl/AV_CaixaBankNow';
import getCaixaBankURL 	   from '@salesforce/apex/AV_LinkOperativoController.getCaixaBankURL';

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
	trueRender = false;
	imageUrl = caixaBankNowIcon;
	//Header
	@api title;
	labelCliente = clientLabel;
	@api fieldName;
	@api icon;
	@api showHierarchy;
	@api actionSetting;
    @api setting = 'AV0001';
    @api filterField = 'Id';
    @track hasLinks = false;
    @track listData;

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
	@track numDocument;
	@track isIntouch;
	@track _wiredFields;
	@track isRating = false;
	@track fechaCarga;
	@api fieldSearch;
	@api helpField;
	@track dropdownActions = [];
	@api objectApiName; 
	showDropdownActions = false;
	showSpinner = true;
	nameRecord;
	@track activityData = [];
	@track activityData2 =[];
	@track nameAccount;
	@track showFieldCheckboxMemorable = false;
	@track isChecked= false;
	@track account;
	@track navigatetoReportCustomButtonHeader = false;
	clientNumper
	clientplates
	get isActivity(){
		return (this.objectApiName === 'Task' || this.objectApiName === 'Event');
	}

	
	connectedCallback(){
		this.isBpr = BPRPS;
		this.getNameData();
		this.getIdFilterObjectData();
	}

	getNameData(){
		this.showSpinner = true;
		getName({recordId:this.recordId}) 
		.then(data => {
			if (data) {
				this.name = data.accountName;
				this.recordType = data.rtDevName;
				this.isIntouch = data.isIntouch;
				this.nameRecord = (this.objectApiName === 'Account') ? data.accountName : data.nameRecord;
				this.account = data.accountId;
				this.clientNumper = data.clientNumper;
				this.clientplates = data.contactPlate;
				this.trueRender = true;
				this.numDocument = data.numDocument ? data.numDocument : null;
			} else {
				console.log(data);
			}
			this.showSpinner = false;
		}).catch(error => {
			console.log(error);
			this.showSpinner = false;
		})
	}

	getIdFilterObjectData(){
		this.showSpinner = true;
		getIdFilterObject({recordId:this.recordId, objectApiName:this.objectApiName, objectFilter:this.filterObject, filterField:this.filterField})
 		.then(data => {
			if (data) {
				var result = JSON.parse(JSON.stringify(data));
				
				getCaixaBankURL({filterObject: this.filterObject, customerId: result, setting: this.setting}).then(result => {
					this.hasLinks = true;
					this.listData = result;
					this.externalUrl = result.url;
					
				}).catch(error => {
					const evt = new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					});
					this.dispatchEvent(evt);
				});
			} 
			
			this.showSpinner = false;
		}).catch(error => {
			console.log(error);
			this.showSpinner = false;
		})
	}



	navigateToCaixaBankNow() {
        if(this.externalUrl) {
			window.location.href = this.externalUrl;
        } else {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'URL not found',
                variant: 'error'
            });
            this.dispatchEvent(evt);
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
            if(this.objectApiName === 'Account'){
                if(!oldReportPS){

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
					if(f.name === this.fieldSearch){
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
						if(data[0][key] === false || data[0][key]== null){
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
			},state: ((tabName) != 'AV_PlanificarCita')?
			{
				c__recId:this.recordId,
				c__id:this.name,
				c__rt:this.recordType,
				c__intouch:this.isIntouch,
				c__account:this.account
			}
			:{
				c__clientNumper: this.clientNumper,
				c__matricula : this.clientplates
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
		if(this.flowName === 'EV_SendInvitaionCampaign'){
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
		if(event.detail.status === 'FINISHED') {
			this.hideFlowAction(event);
			const outputVariables = event.detail.outputVariables;
			for (let i=0;i < outputVariables.length; i++) {
				const outputVar = outputVariables[i];
				if(outputVar === 'redirectId') {
					this.navigateToRecordDirect(outputVar.value);
				}
			}
		}
	}
 
	navigateToRecordDirect(recordId){
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: recordId,
				actionName:'view'
			}
		});
	}
}