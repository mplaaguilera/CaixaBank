import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";

//import
import getRecords 	        from '@salesforce/apex/CIBE_CXBDisplayController.getRecords';
import showAddMemberButton  from '@salesforce/apex/CIBE_CXBDisplayController.showAddMemberButton';
import showAddMemberGC      from '@salesforce/apex/CIBE_CXBDisplayController.showAddMemberGC';
import lookupSearchUser     from '@salesforce/apex/CIBE_CXBDisplayController.searchUser';
import createTeamMember     from '@salesforce/apex/CIBE_CXBDisplayControllerDelete.createTeamMember';
import updateTeamMember     from '@salesforce/apex/CIBE_CXBDisplayControllerDelete.updateTeamMember';
import deleteTeamMember     from '@salesforce/apex/CIBE_CXBDisplayControllerDelete.deleteTeamMember';

//import labels
import anadirParticipante from '@salesforce/label/c.CIBE_AnadirParticipante';
import editarParticipante from '@salesforce/label/c.CIBE_EditarParticipante';
import editarMiembro from '@salesforce/label/c.CIBE_EditarMiembro';
import borrarMiembro from '@salesforce/label/c.CIBE_borrarMiembro';


import validacionBorrado from '@salesforce/label/c.CIBE_ValidacionBorrado';
import miembroNoModificable from '@salesforce/label/c.CIBE_MiembroNoModificable';
import noModificaMiembro from '@salesforce/label/c.CIBE_NoModificaMiembro';
import miembroNoEliminable from '@salesforce/label/c.CIBE_MiembroNoEliminable';
import noEliminaMiembroAutomatico from '@salesforce/label/c.CIBE_NoEliminaMiembroAutomatico';
import altaGestorPrincipalGC from '@salesforce/label/c.CIBE_AltaGestorPrincipalGC';
import miembroAnadido from '@salesforce/label/c.CIBE_MiembroAnadido';
import miembroAnadidoCorrectamente from '@salesforce/label/c.CIBE_MiembroAnadidoCorrectamente';
import problemaAnadiendoMiembro from '@salesforce/label/c.CIBE_ProblemaAnadiendoMiembro';
import cumplimentacionDatos from '@salesforce/label/c.CIBE_CumplimentacionDatos';
import cumplimentarDatosParaAnadir from '@salesforce/label/c.CIBE_CumplimentarDatosParaAnadir';
import modificacionGPenFichaGC from '@salesforce/label/c.CIBE_ModificacionGPenFichaGC';
import modificacionCCRenFichaGC from '@salesforce/label/c.CIBE_ModificacionCCRenFichaGC';
import altaContactoCaixabankRetailGC from '@salesforce/label/c.CIBE_AltaContactoCaixabankRetailGC';
import miembroActualizado from '@salesforce/label/c.CIBE_MiembroActualizado';
import miembroActualizadoCorrectamente from '@salesforce/label/c.CIBE_MiembroActualizadoCorrectamente';
import problemaModificandoMiembro from '@salesforce/label/c.CIBE_ProblemaModificandoMiembro';
import cumplimentarDatosParaModificar from '@salesforce/label/c.CIBE_CumplimentarDatosParaModificar';
import miembroEliminado from '@salesforce/label/c.CIBE_MiembroEliminado';
import miembroEliminadoCorrectamente from '@salesforce/label/c.CIBE_MiembroEliminadoCorrectamente';
import problemaBorrandoMiembroDelEquipo from '@salesforce/label/c.CIBE_ProblemaBorrandoMiembroDelEquipo';
import problemaBorrandoMiembro from '@salesforce/label/c.CIBE_ProblemaBorrandoMiembro';

import nombreEmpleado from '@salesforce/label/c.CIBE_nombreEmpleado';
import numCentro from '@salesforce/label/c.CIBE_numCentro';
import funcion from '@salesforce/label/c.CIBE_funcion';
import codigoCartera from '@salesforce/label/c.CIBE_codigoCartera';
import rol from '@salesforce/label/c.CIBE_rol';
import responsabilidad from '@salesforce/label/c.CIBE_Responsabilidad';
import automatico from '@salesforce/label/c.CIBE_automatico';

import participante from '@salesforce/label/c.CIBE_participante';
import gestorPrincipal from '@salesforce/label/c.CIBE_gestorPrincipal';
//import contactoCaixabankRetail from '@salesforce/label/c.CIBE_contactoCaixabankRetail';

import buscaParticipantes from '@salesforce/label/c.CIBE_BuscaParticipantes';
import rolParticipante from '@salesforce/label/c.CIBE_RolParticipante';
import add from '@salesforce/label/c.CIBE_Add';
import actualizar from '@salesforce/label/c.CIBE_Actualizar';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import eliminarParticipante from '@salesforce/label/c.CIBE_EliminarParticipante';
import eliminar from '@salesforce/label/c.CIBE_Eliminar';
import equipoCBK from '@salesforce/label/c.CIBE_equipoCBK';


export default class Cibe_CXBVisualizacionEMP extends NavigationMixin(LightningElement) {

    labels = {
        anadirParticipante,
        editarParticipante,
        editarMiembro,
        borrarMiembro,
        validacionBorrado,
        miembroNoModificable,
        noModificaMiembro,
        miembroNoEliminable,
        noEliminaMiembroAutomatico,
        altaGestorPrincipalGC,
        miembroAnadido,
        miembroAnadidoCorrectamente,
        problemaAnadiendoMiembro,
        cumplimentacionDatos,
        cumplimentarDatosParaAnadir,
        modificacionGPenFichaGC,
        miembroActualizado,
        miembroActualizadoCorrectamente,
        problemaModificandoMiembro,
        cumplimentarDatosParaModificar,
        miembroEliminado,
        miembroEliminadoCorrectamente,
        problemaBorrandoMiembroDelEquipo,
        problemaBorrandoMiembro,
        nombreEmpleado,
        numCentro,
        funcion,
        codigoCartera,
        rol,
        responsabilidad,
        automatico,
        participante,
        gestorPrincipal,
        //contactoCaixabankRetail,
        buscaParticipantes,
        rolParticipante,
        add,
        actualizar,
        cancelar,
        eliminarParticipante,
        eliminar,
        equipoCBK,
        modificacionCCRenFichaGC,
        altaContactoCaixabankRetailGC
    };

    actions = [
        { label: this.labels.editarMiembro, name: 'edit' },
        { label: this.labels.borrarMiembro, name: 'delete' }
    ];

    @track columns = [
        { label: this.labels.nombreEmpleado, fieldName: 'showContactRecord', type: 'url',    sortable: true, typeAttributes: { label: { fieldName: "nombre" } }, target: '_blank' },
        { label:  this.labels.funcion,             fieldName: 'empleado',          type: 'text', sortable: true },
        { label:  this.labels.codigoCartera,      fieldName: 'cartera',           type: 'text' },
        { label:  this.labels.rol,                 fieldName: 'rol',               type: 'text' },
        { label:  this.labels.responsabilidad,     fieldName: 'responsabilidad',   type: 'text' },
        { label: this.labels.numCentro,       fieldName: 'centro',            type: 'text', sortable: true },
        { label:  this.labels.automatico,          fieldName: 'automatic',         type: 'boolean' },
        { type: 'action', typeAttributes: { rowActions: this.actions } }
    ];

    @track optionsAdd = [
        { label: this.labels.participante,                    value: 'Participante' },
        { label: this.labels.gestorPrincipal,                value: 'Gestor Principal' },
       
    ];
    
    @track optionsEdit = [
        { label: this.labels.gestorPrincipal,                value: 'Gestor Principal' },
        
    ];


    @api recordId;
    @track dataValues = [];
    
   // @track options = optionsAdd;
   // @track options2 = optionsEdit;

    @track isShowSpinner = true;

    @track isShowAddMember = false;
    @track isShowAddMemberButton = false;
    @track isShowEditMember = false;
    @track isShowDeleteMember = false;

    @track sortBy;
    @track sortDirection;
    @track defaultSort = 'asc';

    //ADD MODAL
    @track _record;
    @track rol = 'Participante';
    @track initialSelection = [];
	@track errors = [];

    //EDIT MODAL
    @track _editedRecord;
    @track editedRol;

    //DELETE MODAL
    @track _deleteRecord;

    //GRUPO COMERCIAL
    @track hasGC = false;

    @track _wiredData;
    @wire(getRecords, { recordId : '$recordId' })
    getValues(wireResult) {
        const { data, error } = wireResult;
        this._wiredData = wireResult;
        if(data){
            this.dataValues = this.sortData(data, 'empleado', 'asc');
            this.isShowSpinner = false;
        }else if(error) {
            this.isShowSpinner = false;
            console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
        }
    }

    @track _wiredDataButton;
    @wire(showAddMemberButton, { 'accountId' : '$recordId' })
    getShowAddMemberButton(wireResult) {
        const { data, error } = wireResult;
        this._wiredDataButton = wireResult;
        if(data){
            this.isShowAddMemberButton = data;
        }else if(error) {
            console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
        }
    }

    @track _wiredDataGC;
    @wire(showAddMemberGC, { recordId : '$recordId' })
    getShowAddMemberGC(wireResult) {
        const { data, error } = wireResult;
        this._wiredDataGC = wireResult;
        if(data==true){
            this.hasGC = true;  

        }else if(error) {
            console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
        }
    }

    handleSortData(event) {
        console.log('Entra handleSortData 1');
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

    handleSearch(event) {
		lookupSearchUser(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup"]').scrollIntoView();
			})
			.catch((error) => {
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

    handleSelectionChange(event) {
        const detail = JSON.parse(JSON.stringify(event.detail));
        if(detail != null && detail.length >= 0) {
            this._record = detail[0];
        } else {
            this._record = null;
        }
	}

    handleRolChange(event) {
        this.rol = event.detail.value;
    }

    handleEditRolChange(event) {
        this.editedRol = event.detail.value;
    }
    
    showAddMember() {
        this.isShowAddMember = true;
    }

    hideAddMember() {
        this.isShowAddMember = false;
        this.rol = 'Participante';
        this._record = null;
    }

    hideEditMember() {
        this._editedRecord = null;
        this.editedRol = null;
        this.isShowEditMember = false;
    }

    hideDeleteMember() {
        this.isShowDeleteMember = false;
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
                    title: this.labels.miembroNoModificable,
                    message: this.labels.noModificaMiembro,
                    variant: 'warning'
                })
            );
        }
    }

    editRow(row) {
        const record = JSON.parse(JSON.stringify(row));
        /*if(record.automatic) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.miembroNoModificable,
                    message: 'No es posible modificar un miembro automático del equipo del cliente.',
                    variant: 'warning'
                })
            );
        } else {*/
            this._editedRecord = record.id;
            this.editedRol = record.rol;
            this.isShowEditMember = true;
        //}
    }

    deleteRow(row) {
        const record = JSON.parse(JSON.stringify(row));
        if(record.automatic) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.miembroNoEliminable,
                    message:  this.labels.noEliminaMiembroAutomatico,
                    variant: 'warning'
                })
            );
        } else {
            this._deleteRecord = record.id;
            this.isShowDeleteMember = true;
        }
    }
    
    handleSaveMember(event) {
        if(this.rol =='Gestor Principal' && this.hasGC == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error.',
                    message: this.labels.altaGestorPrincipalGC,
                    variant: 'warning'
                })
            );
        } else if(this.rol =='Contacto Caixabank para retail' && this.hasGC == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error.',
                    message: this.labels.altaContactoCaixabankRetailGC,
                    variant: 'warning'
                })
            );
        } else{
            if(this.rol != null && this._record != null) {
                this.isShowSpinner = true;
                this.isShowAddMember = false;
                createTeamMember({'accountId' : this.recordId, 'userId' : this._record, 'teamMemberRole' : this.rol})
                    .then((results) => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: this.labels.miembroAnadido,
                                message: this.labels.miembroAnadidoCorrectamente,
                                variant: 'success'
                            })
                        );
                        this.rol = 'Participante';
                        this._record = null;
                        refreshApex(this._wiredData);
                    })
                    .catch((error) => {
                        console.error('Error creating Team Member:', JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title:  this.labels.problemaAnadiendoMiembro,
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
                        title: this.labels.cumplimentacionDatos,
                        message: this.labels.cumplimentarDatosParaAnadir,
                        variant: 'error'
                    })
                );
            }
        }
    }

    handleEditMember(event) {
        if(this.editedRol =='Gestor Principal' && this.hasGC == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error.',
                    message: this.labels.modificacionGPenFichaGC,
                    variant: 'warning'
                })
            );
        } else if(this.editedRol =='Contacto Caixabank para retail' && this.hasGC == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error.',
                    message: this.labels.modificacionCCRenFichaGC,
                    variant: 'warning'
                })
            );
        } else{
            if(this.editedRol != null && this._editedRecord != null) {
                this.isShowSpinner = true;
                this.isShowEditMember = false;
                updateTeamMember({ 'memberId' : this._editedRecord, 'accountId' : this.recordId, 'teamMemberRole' : this.editedRol })
                    .then((results) => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: this.labels.miembroActualizado,
                                message: this.labels.miembroActualizadoCorrectamente,
                                variant: 'success'
                            })
                        );
                        this.editedRol = null;
                        this._editedRecord = null;
                        refreshApex(this._wiredData);
                    })
                    .catch((error) => {
                        console.error('Error editing Team Member:', JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: this.labels.problemaModificandoMiembro,
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
                        title: this.labels.cumplimentacionDatos,
                        message: this.labels.cumplimentarDatosParaModificar,
                        variant: 'error'
                    })
                );
            }
        }
    }

    handleDeleteMember(event) {
        if(this._deleteRecord != null) {
            this.isShowSpinner = true;
            this.isShowDeleteMember = false;
            deleteTeamMember({ 'memberId' : this._deleteRecord })
                .then((results) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.labels.miembroEliminado,
                            message: this.labels.miembroEliminadoCorrectamente,
                            variant: 'success'
                        })
                    );
                    this._deleteRecord = null;
                    refreshApex(this._wiredData);
                })
                .catch((error) => {
                    console.error('Error deleting Team Member:', JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title:this.labels.problemaBorrandoMiembroDelEquipo,
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
                    title: this.labels.problemaBorrandoMiembro,
                    message: this.labels.problemaBorrandoMiembroDelEquipo,
                    variant: 'error'
                })
            );
        }
    }

}