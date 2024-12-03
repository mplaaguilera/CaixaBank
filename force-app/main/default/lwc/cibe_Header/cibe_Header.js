import { LightningElement, track, api, wire } from 'lwc';

import { NavigationMixin }      from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

import getName      from '@salesforce/apex/CIBE_Header_Controller.getName';
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

    @wire(getName, {recordId: '$recordId', fieldName: '$fieldName'})
    getNameData(wireResult) {
        const { error, data } = wireResult;
        this._wiredName = wireResult;
        if (data) {
            this.name = data;
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
            console.log('data');
            console.log(data);
            const fieldList = data;
            console.log('fieldList');
            console.log(fieldList);
            this.fields = Object.values(fieldList).map(f => {
                if(f.name === this.fieldSearch){
                    return {
                        name: f.name,
                        isCustomField: true
                    };
                }else{
                    return {
                        name: f.name,
                        isCustomField: false
                    };
                }
            });
            console.log('fields');
            console.log(this.fields);
        } else if (error) {
            console.log(error);
        }
    }

    fireFlowAction(event) {
        this.flowlabel = event.target.dataset.label;
        this.flowName = event.target.dataset.flow;
        this.flowOutput = event.target.dataset.output;
        this.redirectId = null;
        this.isShowFlowAction = true;
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

    @wire(getLoadDate, {recordId: '$recordId', filterObject:'$filterObject', helpField:'$helpField'})
    getLoadDate(wireResult) {
        const { error, data } = wireResult;
        if (data) {
            this.fechaCarga = fechaModT +' '+ data;
        } else if (error) {
            console.log('this.fechaCarga');
            console.log(error);
        }
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