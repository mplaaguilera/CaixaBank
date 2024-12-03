import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";

//schema fields
import USER_ID from '@salesforce/user/Id';

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

import detalleNuevoContacto from '@salesforce/label/c.CIBE_NuevoContacto';
import contactoCoincidente from '@salesforce/label/c.CIBE_ContactosCoincidentes';
import contactoExistente from '@salesforce/label/c.CIBE_ContactoExistente';
import nuevoContacto from '@salesforce/label/c.CIBE_Contacto';
import previous from '@salesforce/label/c.CIBE_Anterior';
import htContactos from '@salesforce/label/c.CIBE_Contactos_HT';
import modificar from '@salesforce/label/c.CIBE_Modificar'
import llamada from '@salesforce/label/c.CIBE_LlamadaTelefonica'

import errorInsertarContacto from '@salesforce/label/c.CIBE_ErrorInsertarContacto'
import errorEditarContacto from '@salesforce/label/c.CIBE_ErrorEditarContacto'
import contactosApoderadosNoEditables from '@salesforce/label/c.CIBE_ContactosApoderadosNoEditables'
import contactosApoderadosNoEliminables from '@salesforce/label/c.CIBE_ContactosApoderadosNoEliminables'
import errorBorrandoContacto from '@salesforce/label/c.CIBE_ErrorBorrandoContacto'
import llamadaFallida from '@salesforce/label/c.CIBE_LlamadaFallida'
import contExistente from '@salesforce/label/c.CIBE_ContExistente'




//import
import getRecords from '@salesforce/apex/CIBE_Contacts_Controller.getRecords';
import getRecordType from '@salesforce/apex/CIBE_Contacts_Controller.getRecordType';
// import deleteContact    from '@salesforce/apex/CIBE_Contacts_ControllerDelete.deleteContact';
import hasPermission from '@salesforce/apex/CIBE_Contacts_Controller.hasPermission';
import getDuplicado from '@salesforce/apex/CIBE_Contacts_Controller.getDuplicado';
import contactosDuplicados from '@salesforce/apex/CIBE_Contacts_Controller.contactosDuplicados';
import insertContact from '@salesforce/apex/CIBE_Contacts_Controller.insertContact';
import insertAccounContactRelation from '@salesforce/apex/CIBE_Contacts_Controller.insertAccounContactRelation';
// import c2cMakeCall from '@salesforce/apex/AV_C2C_Controller.c2cMakeCall';
import c2cMakeCall from '@salesforce/apex/AV_SObjectRelatedInfoCController.c2cMakeCall';
//import clickButton from 'c/cibe_butttonClickToCall';
import getUserRole from '@salesforce/apex/CIBE_CXBVisualizacionGC_Controller.getUserRole';



import showAddMemberButton from '@salesforce/apex/CIBE_CXBDisplayController.showAddMemberButton';
import deleteContactFromAccount from '@salesforce/apex/CIBE_Contacts_GC_Controller.deleteContactFromAccount';



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
        ayuda,
        detalleNuevoContacto,
        contactoCoincidente,
        contactoExistente,
        nuevoContacto,
        previous,
        htContactos,
        modificar,
        errorInsertarContacto,
        errorEditarContacto,
        contactosApoderadosNoEditables,
        contactosApoderadosNoEliminables,
        errorBorrandoContacto,
        llamada,
        llamadaFallida,
        contExistente
    };

    actions = [
        { label: this.labels.modificar, name: 'edit' },
        { label: this.labels.eliminar, name: 'delete' }
    ];



    @track columns = [
        { label: this.labels.nombre, fieldName: 'showContactRecord', type: 'url', initialWidth: 200, sortable: true, typeAttributes: { label: { fieldName: "name" } }, target: '_blank' },
        { label: this.labels.cargo, fieldName: 'rol', type: 'text', initialWidth: 120, sortable: true },
        { label: this.labels.email, fieldName: 'email', type: 'email', initialWidth: 165 },
        { iconName: 'utility:call', alignment: 'center', type: 'button', initialWidth: 40, cellAttributes: { alignment: 'center', class: 'slds-size_xx-small', variant: 'base' }, sortable: false, typeAttributes: { alignment: 'center', name: 'Click-To-Call', value: 'Click-To-Call', iconName: 'utility:call', class: 'slds-size_xx-small', variant: 'base' } },
        { label: this.labels.telefono, fieldName: 'phone', type: 'text', initialWidth: 122, sortable: false, cellAttributes: { alignment: 'left' } },
        { label: this.labels.apoderado, fieldName: 'apoderado', type: 'boolean', initialWidth: 80, cellAttributes: { alignment: 'center' } },
        { label: this.labels.observaciones, fieldName: 'description', type: 'text', cellAttributes: { alignment: 'left' } },
        { type: 'action', typeAttributes: { rowActions: this.actions } }
    ];

    @track columnsContactDuplicado = [
        { label: this.labels.nombre, fieldName: 'NameLink', type: 'url', sortable: true, typeAttributes: { label: { fieldName: "Name" } }, target: '_blank' },
        { label: this.labels.cargo, fieldName: 'cargo', type: 'text', sortable: true },
        { label: this.labels.email, fieldName: 'email', type: 'email' },
        { label: this.labels.telefono, fieldName: 'phone', type: 'phone', initialWidth: 120, cellAttributes: { alignment: 'center' } },
    ];

    get optionsRadioButtons() {
        return [
            { label: this.labels.contactoExistente, value: 'duplicado' },
            { label: this.labels.nuevoContacto, value: 'nuevoContacto' }
        ];
    }


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

    //DUPLICADOS
    @track esDuplicado = false;
    @track email;
    @track phone;
    @track name;
    @track description;
    @track loadDuplicate = false;
    @track contactoComercial = false;
    @track confidential = false;
    @track cargo;
    @track idioma;
    @track apellidos;
    @track nombreCompleto;
    @track salutation;
    //Call
    @api calledDevice = '';

    //TABLA CONTACTOS DUPLICADOS
    @track dataContact;
    @track selectedItem = 'duplicado';
    @track valueRadioButton = 'duplicado';
    fields = [];
    selectedRows = [];
    setSelectedRows = [];

    @track disabledButton = true;
    @track disabledTable = false;
    @track table = true;

    @api userId = USER_ID;
    @track userRoleName;
    @track isCIB;

    @wire(getUserRole, { userId: USER_ID })
    wiredUser({ error, data }) {
        if (data) {
            this.userRoleName = data;
            if (this.userRoleName == 'CIB') {
                this.contactoComercial = false;
            } else {
                this.contactoComercial = true;
            }
        } else if (error) {
            console.error(error);
        }
    }


    @track recordTypeId;
    @wire(getRecordType)
    getRecordTypes({ data, error }) {
        if (data) {
            this.recordTypeId = data;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(showAddMemberButton, { 'accountId': '$recordId' })
    getShowAddMemberButton({ data, error }) {
        if (data) {
            this.isShowAddMemberButton = data;
        } else if (error) {
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
    @wire(getRecords, { recordId: '$recordId' })
    getValues(wireResult) {
        this._wiredData = wireResult;
        const { data, error } = wireResult;
        if (data) {
            this.dataValues = this.sortData(data, 'lastName', 'asc');
            this.pageNumber = 0;
            this.totalPages = this.dataValues.length > 0 ? (Math.ceil(this.dataValues.length / 10) - 1) : 0;
            this.updatePage();
            this.isShowSpinner = false;
        } else if (error) {
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

        let isReverse = direction === 'asc' ? 1 : -1;

        dataToSort.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        return dataToSort;
    }

    updatePage() {
        this.pageData = this.dataValues.slice(this.pageNumber * 10, this.pageNumber * 10 + 10);
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
        if ((this.pageNumber + 1) <= this.totalPages) {
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
        if (this.isShowAddMemberButton) {
            const actionName = event.detail.action.name;
            const row = event.detail.row;
            switch (actionName) {
                case 'edit':
                    this.editRow(row);
                    break;
                case 'Click-To-Call':
                    this.makeCall(row.phone);
                    break;
                case 'delete':
                    this.deleteRow(row);
                    break;
                default:
            }

        } else {
            const actionName = event.detail.action.name;
            const row = event.detail.row;

            if (actionName === 'Click-To-Call' && row.phone != null && row.phone != undefined) {
                this.isShowSpinner = true;
                this.makeCall(row.phone);
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
    }

    showAddContact(event) {
        this.isShowAddContact = true;
    }

    hideAddContact(event) {
        this.isShowAddContact = false;
        this.resetField();
    }

    hideDuplicateContact(event) {
        this.esDuplicado = false;
        this.loadingAdd = false;
        this.resetField();
    }

    handlePrevious() {
        this.esDuplicado = false;
        this.isShowAddContact = true;
        this.loadingAdd = false;
    }

    handleAddSuccess() {
        this.isShowAddContact = false;
        this.loadingAdd = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.labels.contactoAnadido,
                message: this.labels.anadidoCorrectamente,
                variant: 'success'
            })
        );        
        // refreshApex(this._wiredData);
        this.resetField();
        this.table = true;
        this.disabledTable = false;
    }

    handleAddSubmit(event) {

        var a = this.name == null ? '' : this.name;
        var b = this.apellidos == null ? '' : this.apellidos;
        var c = this.phone == null ? '' : this.phone;
        var d = this.email == null ? '' : this.email;


        this.nombreCompleto = a + ' ' + b;
        this.phone = c;
        this.email = d;


        event.preventDefault();

        this.loadingAdd = true;

        if ((this.email == null || this.email == '') && (this.phone == null || this.phone == '')) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.errorInsertarContacto,
                    message: this.labels.htContactos,
                    variant: 'warning'
                })
            );
            this.loadingAdd = false;
        } else {

            getDuplicado({ email: this.email, telefono: this.phone })
                .then((results => {
                    this.esDuplicado = results;
                    this.isShowAddContact = false;
                    this.fields = event.detail.fields;
                    if (this.esDuplicado === false) {
                        this.template.querySelector('lightning-record-edit-form').submit(this.fields);
                        this.handleAddSuccess();
                    } else if (this.email !== null || this.email !== '') {
                        this.duplicados();
                    }

                }))
                .catch((error => {
                    console.log(error);
                }))
        }
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

        if (record.apoderado) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.errorEditarContacto,
                    message: this.labels.contactosApoderadosNoEditables,
                    variant: 'warning'
                })
            );
        } else {
            this.isShowEditContact = true;
        }
    }

    hideEditContact(event) {
        this.isShowEditContact = false;
        this.editedRecord = null;
    }

    handleEditSuccess() {
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

    handleEditSubmit() {
        this.loadingEdit = true;
    }

    handleError(event) {
        this.loadingEdit = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: event.detail.detail,
                variant: 'Error'
            })
        );
        refreshApex(this._wiredData);
    }


    deleteRow(row) {
        const record = JSON.parse(JSON.stringify(row));
        this._deleteRecord = record.id;

        if (record.apoderado === true) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.problemaBorrandoContacto,
                    message: this.labels.contactosApoderadosNoEliminables,
                    variant: 'warning'
                })
            );
        } else {
            this.isShowDeleteContact = true;
        }
    }

    handleDeleteContact(event) {
        if (this._deleteRecord != null) {
            this.isShowSpinner = true;
            this.isShowDeleteContact = false;
            deleteContactFromAccount({ recordId: this.recordId, contactId: this._deleteRecord })
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
                            title: this.labels.errorBorrandoContacto,
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
        refreshApex(this._wiredData, Object.assign({}, event))
            .finally(() => {
                this.isShowSpinner = false;
            });
    }

    emailChange(event) {

        this.email = event.target.value;
    }

    phoneChange(event) {
        this.phone = event.target.value;
    }

    nameChange(event) {
        this.name = event.target.value;
    }

    descriptionChange(event) {
        this.description = event.target.value;
    }
    contactoComercialChange(event) {
        this.contactoComercial = event.target.value;
    }
    confidentialChange(event) {
        this.confidential = event.target.value
    }

    cargoChange(event) {
        this.cargo = event.target.value
    }

    idiomaChange(event) {
        this.idioma = event.target.value
    }

    apellidosChange(event) {
        this.apellidos = event.target.value
    }

    salutationChange(event) {
        this.salutation = event.target.value
    }

    duplicados() {
        contactosDuplicados({ email: this.email, telefono: this.phone })
            .then((results => {
                if (results != null && results.length > 0) {
                    this.dataContact = results.map(
                        record => Object.assign(
                            {
                                "NameLink": record.Id !== undefined ? "/" + record.Id : "",
                                "Name": record.Name,
                                "cargo": record.CIBE_Cargo__c,
                                "email": record.Email,
                                "phone": record.Phone
                            },
                            record
                        )
                    )
                }
            }))
            .catch((error => {
                console.log(error);
            }))
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows
        if (this.selectedRows.length > 0) {
            this.disabledButton = false;
        } else {
            this.disabledButton = true;
        }
    }

    handleRadioChange(event) {
        this.selectedItem = event.detail.value;
        if (this.selectedItem == 'nuevoContacto') {
            this.disabledTable = true;
            this.table = false;
            this.disabledButton = false;
            this.setSelectedRows = [];
        } else if (this.selectedItem == 'duplicado') {
            this.disabledButton = true;
            this.table = true;
            this.disabledTable = false;
        }
    }

    handleAdd(event) {
        this.loadDuplicate = true;
        if (this.selectedItem === 'nuevoContacto') {
            const array = [];
            array.push(this.fields);

            insertContact({ lista: array })
                .then((results => {
                    this.esDuplicado = false;
                    this.handleAddSuccess();
                }))
                .catch((error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.labels.errorInsertarContacto,
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    console.log(error);
                }))
                .finally(() => {
                    this.loadDuplicate = false;
                })
        } else if (this.selectedItem === 'duplicado') {

            const prueba = [{
                ContactId: this.selectedRows[0].Id,
                AccountId: this.recordId
            }];

            insertAccounContactRelation({ lista: prueba, recordId: this.recordId, contactId: this.selectedRows[0].Id })
                .then((results => {
                    this.esDuplicado = false;
                    this.handleAddSuccess();
                }))
                .catch((error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.labels.errorInsertarContacto,
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    console.log(error);
                }))
                .finally(() => {
                    this.loadDuplicate = false;
                })
        }
    }

    resetField() {
        this.name = '';
        this.phone = '';
        this.email = '';
        this.apellidos = '';
        this.salutation = '';
        this.cargo = '';
        this.confidential = false;
        this.contactoComercial = false;
        this.description = '';
    }

    makeCall(calledDevice) {
        const mess = this.labels.CIBE_LlamadaFallida;
        if (!calledDevice || calledDevice == null) {
            this.ShowDisplayToast('Error', mess, 'error');
            this.isShowSpinner = false;
            return;
        }
        c2cMakeCall({ calledDevice: calledDevice })
            .then(result => {
                const [typeMessage, message] = result;
                this.ShowDisplayToast(typeMessage, message, typeMessage);
                this.isShowSpinner = false;
            })
            .catch(error => {
                console.log('Error:', error);
                this.ShowDisplayToast('Error', mess, 'error');
                this.isShowSpinner = false;
            });
    }

    ShowDisplayToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    get getPageNumber() {
        return (this.pageNumber + 1);
    }

    get getTotalPageNumber() {
        return (this.totalPages + 1);
    }
}