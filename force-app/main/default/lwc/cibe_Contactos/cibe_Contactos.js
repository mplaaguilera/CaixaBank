import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";

//Labels
import title from '@salesforce/label/c.CIBE_Contactos';
import nuevo from '@salesforce/label/c.CIBE_Nuevo';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import add from '@salesforce/label/c.CIBE_Add';
import addContacto from '@salesforce/label/c.CIBE_AddContacto';
import informacion from '@salesforce/label/c.CIBE_InformacionDelContacto';
import observaciones from '@salesforce/label/c.CIBE_Observaciones';
import actualizar from '@salesforce/label/c.CIBE_Actualizar';
import editarContacto from '@salesforce/label/c.CIBE_EditarContacto';
import eliminar from '@salesforce/label/c.CIBE_Eliminar';
import eliminarContacto from '@salesforce/label/c.CIBE_EliminarContacto';
import eliminarContactoConfirmacion from '@salesforce/label/c.CIBE_EliminarContactoConfirmacion';

import nombre from '@salesforce/label/c.CIBE_NombreSimple';
import apellido from '@salesforce/label/c.CIBE_Apellido';
import cargo from '@salesforce/label/c.CIBE_Cargo';
import idioma from '@salesforce/label/c.CIBE_Idioma';
import email from '@salesforce/label/c.CIBE_Email';
import telefono from '@salesforce/label/c.CIBE_Telefono';
import confidencial from '@salesforce/label/c.CIBE_Confidencial';
import contactoInfoComercial from '@salesforce/label/c.CIBE_ContactoInfoComercial';
import apoderado from '@salesforce/label/c.CIBE_Apoderado';
import ayuda from '@salesforce/label/c.CIBE_AyudaTfnoEmail';


import contactoNoModificable from '@salesforce/label/c.CIBE_ContactoNoModificable';
import noModifcableNoEquipoCliente from '@salesforce/label/c.CIBE_NoModifcableNoEquipoCliente';
import contactoAnadido from '@salesforce/label/c.CIBE_ContactoAnadido';
import anadidoCorrectamente from '@salesforce/label/c.CIBE_AnadidoCorrectamente';
import contactoActualizado from '@salesforce/label/c.CIBE_ContactoActualizado';
import actualizadoCorrectamente from '@salesforce/label/c.CIBE_ActualizadoCorrectamente';
import contactoEliminado from '@salesforce/label/c.CIBE_ContactoEliminado';
import contactoEliminadoCorrectamente from '@salesforce/label/c.CIBE_ContactoEliminadoCorrectamente';
import problemaBorrandoContacto from '@salesforce/label/c.CIBE_ProblemaBorrandoContacto';
import haOcurridoProblemaBorrandoContacto from '@salesforce/label/c.CIBE_HaOcurridoProblemaBorrandoContacto';

//import
import getRecords 	    from '@salesforce/apex/CIBE_Contacts_Controller.getRecords';
import getRecordType    from '@salesforce/apex/CIBE_Contacts_Controller.getRecordType';
import deleteContact    from '@salesforce/apex/CIBE_Contacts_ControllerDelete.deleteContact';
import hasPermission from '@salesforce/apex/CIBE_Contacts_Controller.hasPermission';

import showAddMemberButton  from '@salesforce/apex/CIBE_CXBDisplayController.showAddMemberButton';



export default class cibe_Contactos extends NavigationMixin(LightningElement) {
    
    labels = {
        title,
        nuevo,
        cancelar,
        add,
        addContacto,
        informacion,
        observaciones,
        actualizar,
        editarContacto,
        eliminar,
        eliminarContacto,
        eliminarContactoConfirmacion,
        nombre,
        apellido,
        cargo,
        idioma,
        email,
        telefono,
        confidencial,
        contactoInfoComercial,
        contactoNoModificable,
        noModifcableNoEquipoCliente,
        contactoAnadido,
        anadidoCorrectamente,
        contactoActualizado,
        actualizadoCorrectamente,
        contactoEliminado,
        contactoEliminadoCorrectamente,
        problemaBorrandoContacto,
        haOcurridoProblemaBorrandoContacto,
        apoderado,
        ayuda
    };

    actions = [
        { label: this.labels.actualizar, name: 'edit' },
        { label: this.labels.eliminar, name: 'delete' }
    ];
    
    @track columns = [
        { label: this.labels.nombre,         fieldName: 'showContactRecord',     type: 'url',    sortable: true,     typeAttributes: { label: { fieldName: "name" } }, target: '_blank' },
        { label: this.labels.cargo,          fieldName: 'rol',                   type: 'text',   sortable: true},
        //{ label: this.labels.idioma,         fieldName: 'language',              type: 'text',   sortable: true,     initialWidth : 100 },
        { label: this.labels.email,          fieldName: 'email',                 type: 'email' },
        { label: this.labels.telefono,       fieldName: 'phone',                 type: 'text',   initialWidth : 120 , cellAttributes: { alignment: 'center' } },
        //{ label: this.labels.contactoInfoComercial,   fieldName: 'contactoInfoComercial',          type: 'boolean', initialWidth : 100, cellAttributes: { alignment: 'center' }},
        { label: this.labels.apoderado,      fieldName: 'apoderado',            type: 'boolean',initialWidth : 100, cellAttributes: { alignment: 'center' }},
        { label: this.labels.observaciones,   fieldName: 'description',          type: 'text',initialWidth : 300, cellAttributes: { alignment: 'center' }},
        { type: 'action',       typeAttributes: { rowActions: this.actions } }
    ];

    


    @api recordId;
    @track dataValues = [];

    @track pageNumber = 0;
    @track totalPages = 0;
    @track pageData = [];

    @track isShowSpinner = true;
    @track isShowDeleteContact = false;
    @track isShowAddMemberButton = false;

    @track sortBy;
    @track sortDirection;
    @track defaultSort = 'asc';

    //ADD MODAL
    @track isShowAddContact = false;
    @track loadingAdd = false;

    //EDIT MODAL
    @track isShowEditContact = false;
    @track editedRecord;
    @track loadingEdit = false;
    
    //DELETE MODAL
    @track _deleteRecord;

    defaultTrue = true;

    @track recordTypeId;
    @wire(getRecordType)
    getRecordTypes({ data, error }) {
        if(data){
            console.log(data);
            this.recordTypeId = data;
        }else if(error) {
            console.log(error);
        }
    }

    @wire(showAddMemberButton, { 'accountId' : '$recordId' })
    getShowAddMemberButton({ data, error }) {
        if(data){
            this.isShowAddMemberButton = data;
        }else if(error) {
            console.log(error);
        }
    }

    @wire(hasPermission, {})
    getTipoGestorConPSEMP({ data, error }) {
        if (data) {
            this.isShowAddMemberButton = data;
        } else if (error) {
            console.log(error);
        }
    }

    @track _wiredData;
    @wire(getRecords, { recordId : '$recordId' })
    getValues(wireResult) {
        this._wiredData = wireResult;
        const { data, error } = wireResult;
        
        if(data){
            this.dataValues = this.sortData(data, 'lastName', 'asc');
            this.pageNumber = 0;
            this.totalPages = this.dataValues.length > 0 ? (Math.ceil(this.dataValues.length/10)-1) : 0;
            this.updatePage();
            this.isShowSpinner = false;
        }else if(error) {
            this.isShowSpinner = false;
            console.log(error);
        }
    }

    handleSortData(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.dataValues = this.sortData(this.dataValues, event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(data, field, direction) {
        let fieldName = field;
        let dataToSort = [...data];
    
        let keyValue = (a) => {
            return a[fieldName];
        };
    
        let isReverse = direction === 'asc' ? 1: -1;
    
        dataToSort.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        return dataToSort;
    }

    updatePage() {
        this.pageData = this.dataValues.slice(this.pageNumber*10, this.pageNumber*10+10);
    }
    
    previous() {
        this.pageNumber = Math.max(0, this.pageNumber - 1);
        this.updatePage();
    }
    
    first() {
        this.pageNumber = 0;
        this.updatePage();
    }
    
    next() {
        if((this.pageNumber+1)<=this.totalPages) {
            this.pageNumber = this.pageNumber + 1;
            this.updatePage();
        }
    }
    
    last() {
        this.pageNumber = this.pageNumber = this.totalPages;
        this.updatePage();
    }

    hideDeleteContact() {
        this.isShowDeleteContact = false;
    }

    handleRowAction(event) {
        if(this.isShowAddMemberButton) {
            const actionName = event.detail.action.name;
            const row = event.detail.row;
            switch (actionName) {
                case 'edit':
                    this.editRow(row);
                    break;
                case 'delete':
                    this.deleteRow(row);
                    break;
                default:
            }
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.contactoNoModificable,
                    message: this.labels.noModifcableNoEquipoCliente,
                    variant: 'warning'
                })
            );
        }
    }

    showAddContact(event) {
        this.isShowAddContact = true;
    }

    hideAddContact(event) {
        this.isShowAddContact = false;
    }

    handleAddSuccess(){
        this.isShowAddContact = false;
        this.loadingAdd = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.labels.contactoAnadido,
                message: this.labels.anadidoCorrectamente,
                variant: 'success'
            })
        );
        refreshApex(this._wiredData);
    }

    handleAddSubmit(){
        this.loadingAdd = true;
    }

    handleAddError(event) {
        const payload = event.detail;
        this.loadingAdd = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: payload.message,
                message: payload.detail,
                variant: 'error'
            })
        );
    }

    editRow(row) {
        const record = JSON.parse(JSON.stringify(row));
        this.editedRecord = record.id;
        this.isShowEditContact = true;
    }

    hideEditContact(event) {
        this.isShowEditContact = false;
        this.editedRecord = null;
    }

    handleEditSuccess(){
        this.isShowEditContact = false;
        this.loadingEdit = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.labels.contactoActualizado,
                message: this.labels.actualizadoCorrectamente,
                variant: 'success'
            })
        );
        refreshApex(this._wiredData);
    }

    handleEditSubmit(){
        this.loadingEdit = true;
    }
    
    deleteRow(row) {
        const record = JSON.parse(JSON.stringify(row));
        this._deleteRecord = record.id;
        this.isShowDeleteContact = true;
    }

    handleDeleteContact(event) {
        if(this._deleteRecord != null) {
            this.isShowSpinner = true;
            this.isShowDeleteContact = false;
            deleteContact({ 'recordId' : this._deleteRecord })
                .then((results) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.labels.contactoEliminado,
                            message: this.labels.contactoEliminadoCorrectamente,
                            variant: 'success'
                        })
                    );
                    this._deleteRecord = null;
                    refreshApex(this._wiredData);
                })
                .catch((error) => {
                    console.error('Error deleting contact:', JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Ha ocurrido un problema borrando el contacto del cliente.',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                })
                .finally(() => {
                    this.isShowSpinner = false;
                });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.problemaBorrandoContacto,
                    message: this.labels.haOcurridoProblemaBorrandoContacto,
                    variant: 'error'
                })
            );
        }
    }

    refresh(event) {
        this.isShowSpinner = true;
        refreshApex(this._wiredData)
            .finally(() => {
                this.isShowSpinner = false;
            });
    }

    get getPageNumber() {
        return (this.pageNumber+1);
    }

    get getTotalPageNumber() {
        return (this.totalPages+1);
    }

}