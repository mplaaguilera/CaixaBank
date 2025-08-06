import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference  } from 'lightning/navigation';



import getCalls from '@salesforce/apex/AV_CallsPendReporSDGHome_Controller.getCalls';
import getUserPermissions from '@salesforce/apex/AV_CallsPendReporSDGHome_Controller.getUserPermissions';
import discardCalls from '@salesforce/apex/AV_CallsPendReporSDGHome_Controller.discardCalls';
import c2cMakeCall from '@salesforce/apex/AV_SObjectRelatedInfoCController.c2cMakeCall';

export default class av_callsPendReporSDGHome extends NavigationMixin(LightningElement) {

    actionsEnabled = [
        { label: 'Asignar', name: 'asignar' },
        { label: 'Reportar', name: 'reportar_disabled', disabled: true},
        { label: 'Descartar', name: 'descartar' }

    ];
    
    actionsDisabled = [
        { label: 'Asignar', name: 'asignar_disabled', disabled: true },
        { label: 'Reportar', name: 'reportar' },
        { label: 'Descartar', name: 'descartar' }
    ];

    @track columns = [
        { label: 'CLIENTE',             fieldName: 'accountId',     sortable: true,       type: 'url',                                  hideDefaultActions: true,       cellAttributes: { alignment: 'left'},       typeAttributes: {label: {fieldName: 'accountName'}, tooltip: {fieldName: 'accountName'}}},
        { label: 'ORIGEN',              fieldName: 'tipo',          sortable: false,      type: 'text',      initialWidth : 70,         hideDefaultActions: true,       cellAttributes: { alignment: 'left'}},  
        { label: 'FECHA',               fieldName: 'fechaInicio',   sortable: true,       type: 'text',      initialWidth : 130,        hideDefaultActions: true,       cellAttributes: { alignment: 'left' }},
        { label: 'DURACIÓN',            fieldName: 'duracion',      sortable: true,       type: 'text',      initialWidth : 70,         hideDefaultActions: true,       cellAttributes: { alignment: 'left' }},
        { label: 'TELÉFONO',            fieldName: 'telefono',      sortable: false,      type: 'button',    initialWidth : 105,        hideDefaultActions: true,       cellAttributes: { alignment: 'left', class: 'slds-size_xx-small',  variant:'base' }, typeAttributes: { name: 'Click-To-Call', value: 'Click-To-Call', label: {fieldName: 'telefono'}, iconName: 'utility:call', class: 'slds-size_xx-small', variant: 'base', alignment: 'center' }, alignment: 'center'},
        // { iconName: 'utility:call',                                 sortable: false,      type: 'button',    cellAttributes: {alignment: 'center', class:'slds-size_xx-small',variant:'base' },   typeAttributes:{alignment: 'center', name:'Click-To-Call', value:'Click-To-Call',iconName: 'utility:call',class:'slds-size_xx-small',variant:'base'}, initialWidth : 40, alignment: 'center'},
        // { label: 'TELEFONO',            fieldName: 'telefono',      sortable: false,      type: 'text',      cellAttributes: { alignment: 'left' },      initialWidth : 122},
        // { label: 'ESTADO',              fieldName: 'estado',        sortable: true,       type: 'text',      cellAttributes: { alignment: 'left' }},     initialWidth : 100,    
        { label: '1er GESTOR',       fieldName: 'idFirstEmployee',sortable: false,      type: 'url',                                     hideDefaultActions: true,       cellAttributes: { alignment: 'left'},      typeAttributes: {label: {fieldName: 'firstEmployee'}}},
        { label: 'LLAMADA',             fieldName: 'idCall',        sortable: true,       type: 'url',       initialWidth : 90,         hideDefaultActions: true,       cellAttributes: { alignment: 'left'},       typeAttributes: {label: {fieldName: 'callName'}, tooltip: {fieldName: 'callName'}}},
        { type: 'action',                typeAttributes: { rowActions: this.getRowActions.bind(this) } }
    
    ];

    @api recordId;
    @track dataValues = [];
    @track callsData = [];
    @track error;
    @track loading = false;
    @track showTable = false;

    @track sortedBy;
    @track sortByFieldName;
    @track sortByLabel;
    @track sortDirection;
    @track defaultSort = 'asc';

    @track totalPages = 0;
    @track pageData = [];
    @track pageNumber = 1;
    @track totalPage = 0;
    @track pageSize = 10;
    @track page = 1;
    @track isMultipagina = true;
    @track totalRecountCount;
    @track optionsPage = [];


    @track wiredResult;

    hasPermission = false;
    @track selectedRows = [];


    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if(currentPageReference.state.c__id){
            this.refresh();
        }
    }

    @wire(getUserPermissions)
    wiredPermissions({ error, data }) {
        if (data) {
            this.hasPermission = data.includes('AV_RainbowCTI');
        } else if (error) {
            console.error('Error retrieving permissions:', error);
        }
    }

    @wire(getCalls)
    getValues(result) {
        this.wiredResult = result;
        const { data, error } = result;

        if (data) {
            this.processData(data);
        } else if (error) {
            this.error = true;
            this.loading = false;
            console.error('Error retrieving calls:', error);
        }
    }
    
    processData(dataWR){
        this.dataValues = dataWR;
        this.totalRecountCount = dataWR.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

        this.isMultipagina = this.totalPage > 1;
        if (this.totalPage <= 1) {
            this.isMultipagina = false;
        }else {
            for (let i = 1; i < this.totalPage + 1; i++) {
                let aux = { label: i.toString(), value: i };
                this.optionsPage.push(aux);
            }
            this.isMultipagina = true;
        }

        this.callsData = [];

        this.dataValues.forEach(call => {
            let callExists = this.callsData.some(existingCall => existingCall.callName === call.callName);
            let durationSeg = call.duracion + ' s';

            if (!callExists) {
                this.callsData.push({
                    accountId: call.accountId,
                    accountName: call.accountName,
                    callName: call.callName,
                    duracion: durationSeg,
                    estado: call.estado,
                    fechaInicio: this.formatDateTime(call.fechaInicio),
                    idCall: call.idCall,
                    telefono: this.formatPhone(call.telefono),
                    tipo: call.tipo,
                    idOwner: call.idOwner,
                    ownerName: call.ownerName,
                    idFirstEmployee: call.idFirstEmployee,
                    firstEmployee: call.firstEmployee
                });
            }
        });

        this.displayRecordPerPage(this.pageNumber);

        this.showTable = true;
        this.loading = false;
    }

    getRowActions(row, doneCallback) {
        const actions = row.accountId ? this.actionsDisabled : this.actionsEnabled;
        doneCallback(actions);
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
        let parseData = JSON.parse(JSON.stringify(this.callsData));
        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;
        this.callsData = parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            if (fieldname === 'duracion') {
                x = parseInt(x,10);
                y = parseInt(y,10);
            }
            return isReverse * ((x > y) - (y > x));
        });

        this.displayRecordPerPage(this.pageNumber);
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

    refresh() {
        this.loading = true;
        
        refreshApex(this.wiredResult)
            .then(() => {
                
                if (this.wiredResult.data) {
                    this.processData(this.wiredResult.data);
                }
                this.loading = false;
            })
            .catch(error => {
                this.loading = false;
                this.error = true;
                console.error('Error refreshing data: ', error);
            });
    }

    displayRecordPerPage(page) {
        this.pageData = [];
        for (let i = (page - 1) * this.pageSize; i < page * this.pageSize; i++) {
            if (this.callsData[i] != null) {
                this.pageData.push(this.callsData[i]);
            }
        }
    }

    handleChangePage(event) {
        this.page = event.detail.value;
        this.displayRecordPerPage(this.page);
    }

    get optionsPageSize() {
        return [
            { label: '10', value: 10 },
            { label: '20', value: 20 },
            { label: '50', value: 50 },
            { label: '100', value: 100 }
        ];
    }

    handleChangePageSize(event) {
        this.pageSize = event.detail.value;
        this.page = 1;
        this.optionsPage = [];
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        for (let i = 1; i < this.totalPage + 1; i++) {
            let aux = { label: i.toString(), value: i };
            this.optionsPage.push(aux);
        }
        this.displayRecordPerPage(this.pageNumber);
    }


    handleRowAction(event) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if(actionName ==='reportar'){
            this.navigateToParentComponent(row.idCall);
        }else if (actionName ==='asignar'){
            this.navigateToParentComponentAsignar(row.idCall, row.telefono);
        }else if (actionName ==='descartar'){
            this.loading = true;
            this.handleDescartar(row.idCall);
            this.loading = false;
        
        }else if(actionName ==='Click-To-Call'  && row.telefono!=null && row.telefono!=undefined){
            this.loading = true;
            this.makeCall(row.telefono);
        }
    }

    makeCall(calledDevice) {
        const mess = 'No se puede llamar al cliente seleccionado';    
        if (!calledDevice|| calledDevice==null) {
            this.ShowDisplayToast('Error',mess,'error');
            this.loading = false;
            return;
        }
        c2cMakeCall({ calledDevice: calledDevice })
            .then(result => {
                const [typeMessage, message] = result;
                this.ShowDisplayToast(typeMessage,message,typeMessage);
                this.loading = false;
            })
            .catch(error => {
                console.error(error);
                this.ShowDisplayToast('Error',mess,'error');
                this.loading = false;
            });
    }

    ShowDisplayToast(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    navigateToParentComponentAsignar(callId, telefono) {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'AV_AsignacionLlamada'
            },
            state: {
                c__callId:callId,
                c__isMissed: false,
                c__callPhone: telefono
            }
        });
    }

    navigateToParentComponent(callId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'AV_Reporte_de_llamada'
            },
            state: {
                c__callId:callId
            }
        });
    }
    // Función para formatear la fecha
    formatDateTime(dateString) {
        const dateOptions = {
            day: '2-digit',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        };
        const date = new Date(dateString);
        const formattedDate = new Intl.DateTimeFormat('es-ES', dateOptions).format(date);
        const [datePart, timePart] = formattedDate.split(', ');
        return `${datePart.replace('.', '')}, ${timePart}`;
    }

    handleDescartar(idCall){
        let idCallFormated = idCall.substring(1);
        let callIdList = [idCallFormated];
        discardCalls({ callsList: callIdList})
            .then(result => {
                this.ShowDisplayToast('Descartada','Llamada descartada correctamente','success');
                this.refresh();
                
            })
            .catch(error => {
                this.ShowDisplayToast('Error','No se ha podido descartar la llamada','error');
                this.loading = false;
            });

            callIdList = [];
    }

    // Función para formatear el telefono
    formatPhone(phoneNumber) {
        let formatPhoneNumber = phoneNumber;
        if (phoneNumber.startsWith('+34')) {     
            formatPhoneNumber = phoneNumber.substring(3); 
        } else if (phoneNumber.startsWith('+34 ')) {
            formatPhoneNumber = phoneNumber.substring(4);
        } else if (phoneNumber.startsWith('34')) {
            formatPhoneNumber = phoneNumber.substring(2);
        }
        return formatPhoneNumber;
    }
}