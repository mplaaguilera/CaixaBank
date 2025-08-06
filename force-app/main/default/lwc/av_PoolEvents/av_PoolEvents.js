import { LightningElement,track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

import retrievePoolEvents from '@salesforce/apex/AV_PoolEvents_Controller.retrievePoolEvents';
import AV_CitaPoolTableName from '@salesforce/label/c.AV_CitaPoolTableName';

export default class Av_PoolEvents extends NavigationMixin(LightningElement) {
    titleLabel = AV_CitaPoolTableName;
    numRecords = 0;
    loading = false;
    showTable = true;
    iconName = 'standard:event';
    recordsToDisplay = [];
    eventToClientMapReport;
    eventToClientMapAssign;
    loading = true;
    sortByFieldName;
    @track sortDirection=['asc','desc'];
    displayTable;

    columns=[
        { label: 'CLIENTE', fieldName: 'clientId', type: 'url',typeAttributes:{label:{fieldName:'clientName'},tooltip:{fieldName:'clientName'}},sortBy:'clientName',hideDefaultActions: true, wrapText:false,sortable:true, class: "columnClass" },
        { label: 'ASUNTO', fieldName: 'eventId', type: 'url',typeAttributes:{label:{fieldName:'eventSubject'},tooltip:{fieldName:'eventSubject'}},sortBy:'eventSubject',hideDefaultActions: true, wrapText:false,sortable:true, class: "columnClass" },
        { label: 'FECHA/HORA', fieldName: 'eventDateTime', type: 'text' ,sortBy:'eventDateTime',hideDefaultActions: true, wrapText:false,sortable:true, class: "columnClass"},
        { label: 'TIPO', fieldName: 'eventType', type: 'text' ,sortBy:'eventType',hideDefaultActions: true, wrapText:false,sortable:true, class: "columnClass"},
        { type: 'action', label: 'ASIGNAR/REPORTAR', typeAttributes: { rowActions: this.getRowActions.bind(this) }, fixedWidth: 146, cellAttributes: { style: "text-align: right; display: flex; justify-content: flex-end;padding-right: 25px;"}}

        
    ];

        actions = [
            { label: 'Asignar', name: 'asignar' },
            { label: 'Reportar', name: 'reportar'}
    
        ];

       
    refresh(){
        this.loading = true;
        this.getRecords();
    }   
        
    getRowActions(row, doneCallback) {
        doneCallback(this.actions);
    }
    connectedCallback(){
        this.getRecords();
    }

    getRecords(){
        retrievePoolEvents()
            .then(data => {
                if(data){
                    this.recordsToDisplay = data.data;
                    this.numRecords = data.dataSize;
                    this.eventToClientMapReport = data.eventToClientMapReport;
                    this.eventToClientMapAssign = data.eventToClientMapAssign;
                    this.displayTable = this.numRecords > 0;
                    this.loading = false;
                }
            }).catch(error => {
                console.error(error);
                this.loading = false;
        });
    }
    handleRowAction(event) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if(actionName ==='reportar'){
            this.navigateToReportEvent(row.eventRightId);
        }else if (actionName ==='asignar'){
            this.navigateToAssignEvent(row.eventRightId);
        }
    }
    
    handleSortData(event) {
        this.sortByFieldName = event.detail.fieldName;
        let sortField = event.detail.fieldName;
        
        for (let col of this.columns) {
            if (col.fieldName == this.sortByFieldName && col.type == 'url'){
                sortField = col.typeAttributes.label.fieldName;
            }
        }
        this.sortDirection = event.detail.sortDirection;
        this.sortData(sortField, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.recordsToDisplay));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        this.recordsToDisplay = parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

       
            return isReverse * ((x > y) - (y > x));
        });

    }    

    sortBy(field, reverse, primer) {
        const key = primer
        ? function(x) {
        return primer(x[field]);
        }
        : function(x) {
        return x[field];
        };return function(a, b) {
        a = key(a);
        b = key(b);
         return reverse * ((a > b) - (b > a));
        };
    }
    navigateToReportEvent(eventId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
                apiName: 'AV_EventReportParentTab'
            },state: this.eventToClientMapReport[eventId]
				
        });
    }
    
    navigateToAssignEvent(eventId){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
                apiName: 'AV_PlanificarCita'
            },state: this.eventToClientMapAssign[eventId]
				
        });
    }

}