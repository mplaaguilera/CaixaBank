import { LightningElement, track, api, wire } from 'lwc';

import { NavigationMixin }      from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

import getName      from '@salesforce/apex/CIBE_Header_Controller.getAccountInfo';
import getActions   from '@salesforce/apex/CIBE_Header_Controller.getActions';
import getFields    from '@salesforce/apex/CIBE_Header_Controller.getFields';
import getLoadDate    from '@salesforce/apex/CIBE_Header_Controller.getDateLoad';
import fechaModT from '@salesforce/label/c.CIBE_fechaModTabla';


export default class Cibe_Header extends NavigationMixin(LightningElement) {

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
    
    //Header
    @api title;
    @api fieldName;
    @api icon;
    @api showHierarchy;
    @api actionSetting;

    //Body
    @api filterObject;
    @api fieldSetName;

    @track name;
    @track _wiredName;
    @track actions;
    @track flowlabel;
    @track flowName;
    @track flowOutput;
    @track redirectId;
    @track objectAPIName;
    @track isShowFlowAction = false;
    @track fields;
    @track _wiredFields;
    @track isRating = false;
    @track fechaCarga;
    @api fieldSearch;
    @api helpField;
    @api nameRecord;
    @api account;
    @api isIntouch;
    @track recordType;

    @wire(getName, {recordId: '$recordId'})
	getNameData(wireResult) {
		let data = wireResult.data;
		let error = wireResult.error; 
		this._wiredName = wireResult;
        
		if (data) {
			//this.name = data[0]; Cambio para que use el name bien en Opportunity.
            this.name = (this.filterObject === 'Account' ) ? data[0] : data[3];

			this.recordType = data[1];
			this.isIntouch = data[2];
            this.nameRecord = (this.filterObject === 'Account' || this.filterObject === 'Opportunity') ? data[0] : data[3];

			//this.nameRecord = (this.objectApiName == 'Account') ? data[0] : data[3];
			this.account = data[4];

		} else if (error) {
			console.log(error);
		}
        
	}

    @wire(getActions, { actionSetting: '$actionSetting' })
    getActions(wireResult) {
        const { error, data } = wireResult;
        if (data) {
            this.actions = data;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getFields, {recordId: '$recordId', fieldSetName: '$fieldSetName'})
    getFieldsData(wireResult) {
        const { error, data } = wireResult;
        this._wiredData = wireResult;
        if (data) {
            const fieldList = data;
            this.fields = Object.values(fieldList).map(f => {
                if(f.name === this.fieldSearch){
                    return {
                        name: f.name,
                        isCustomField: true
                    };
                }
                    return {
                        name: f.name,
                        isCustomField: false
                    };
            });

        } else if (error) {
            console.log(error);
        }
    }

    fireFlowAction(event) {
        const opportunityId = this.recordId;
        if(event.target.dataset.type === 'Flow'){
            this.flowlabel = event.target.dataset.label;
            this.flowName = event.target.dataset.flow;
            this.flowOutput = event.target.dataset.output;
            this.isShowFlowAction = true;
            this.redirectId = null;
            
        }else if(event.target.dataset.type === 'Tab'){
            this.navigateToTab(event.target.dataset.flow);
            // this.navigateToTab(event.target.dataset.flow, opportunityId);
        }
    }

    hideFlowAction(event) {
        this.isShowFlowAction = false;
    }

    navigateToHierarchy(event) {
        var evt = eval("$A.get('e.force:navigateToComponent')");
        evt.setParams({
            componentDef: "sfa:hierarchyFullView",
            componentAttributes: {
                recordId: this.recordId,
                sObjectName: "Account"
            }
        });
        evt.fire();
    }

    get inputFlowVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
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
				c__recId: this.filterObject === 'Account' ? this.recordId : this.account,
				c__id:this.nameRecord,
				c__rt:this.recordType,
				c__intouch:this.isIntouch,
				c__account:this.account,
                c__oppId: this.recordId
			}
		});
	}

    @wire(getLoadDate, {recordId: '$recordId', filterObject:'$filterObject', helpField:'$helpField'})
    getLoadDate(wireResult) {
        const { error, data } = wireResult;
        if (data) {
            this.fechaCarga = fechaModT +' '+ data;
        } else if (error) {
            console.log(error);
        }
    }

    handleStatusChange(event) {
        const status = event.detail.status;
        const outputVariables = event.detail.outputVariables;
        
        if(outputVariables) {
            outputVariables.forEach(e => {
                this.flowOutput.split(',').forEach(v => {
                    if(e.name === v && e.value) {
                        this.redirectId = e.value;
                    }
                });
            });       
        }
        
        if(status === 'FINISHED') {
            this.isShowFlowAction = false;

            if(this.redirectId != null){
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.redirectId,
                        actionName:'view'
                    }
                })
            }
        }
    }

}