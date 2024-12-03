import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getRecords 	        from '@salesforce/apex/CIBE_CXBVisualizacionGC_Controller.getRecords';
import getUserRole 	        from '@salesforce/apex/CIBE_CXBVisualizacionGC_Controller.getUserRole';
import showAddMemberButton  from '@salesforce/apex/CIBE_CXBVisualizacionGC_Controller.showAddMemberButton';
import lookupSearchUser     from '@salesforce/apex/CIBE_CXBVisualizacionGC_Controller.searchUser';
import createTeamMember     from '@salesforce/apex/CIBE_CXBVisualizacionGC_Controller.createTeamMember';
import updateTeamMember     from '@salesforce/apex/CIBE_CXBVisualizacionGC_Controller.updateTeamMember';
import deleteTeamMember     from '@salesforce/apex/CIBE_CXBVisualizacionGC_Controller.deleteTeamMember';

//schema fields
import USER_ID from '@salesforce/user/Id';

//import labels
import anadirParticipante from '@salesforce/label/c.CIBE_AnadirParticipante';
import editarParticipante from '@salesforce/label/c.CIBE_EditarParticipante';
import editarMiembro from '@salesforce/label/c.CIBE_EditarMiembro';
import borrarMiembro from '@salesforce/label/c.CIBE_borrarMiembro';
import equipoCBK from '@salesforce/label/c.CIBE_equipoCBK';
import buscaParticipantes from '@salesforce/label/c.CIBE_BuscaParticipantes';
import rolParticipante from '@salesforce/label/c.CIBE_RolParticipante';
import add from '@salesforce/label/c.CIBE_Add';
import actualizar from '@salesforce/label/c.CIBE_Actualizar';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import eliminarParticipante from '@salesforce/label/c.CIBE_EliminarParticipante';
import eliminar from '@salesforce/label/c.CIBE_Eliminar';
import validacionBorrado from '@salesforce/label/c.CIBE_ValidacionBorrado';
import miembroNoModificable from '@salesforce/label/c.CIBE_MiembroNoModificable';
import noModificaMiembro from '@salesforce/label/c.CIBE_NoModificaMiembro';
import noModificarGPoCCR from '@salesforce/label/c.CIBE_NoModificarGPoCCR';
import noEliminarGPoCCR from '@salesforce/label/c.CIBE_NoEliminaGPoCCR';
import miembroNoEliminable from '@salesforce/label/c.CIBE_MiembroNoEliminable';
import noEliminaMiembroAutomatico from '@salesforce/label/c.CIBE_NoEliminaMiembroAutomatico';
import miembroActualizadoCorrectamente from '@salesforce/label/c.CIBE_MiembroActualizadoCorrectamente';
import problemaModificandoMiembro from '@salesforce/label/c.CIBE_ProblemaModificandoMiembro';
import cumplimentarDatosParaModificar from '@salesforce/label/c.CIBE_CumplimentarDatosParaModificar';
import miembroEliminado from '@salesforce/label/c.CIBE_MiembroEliminado';
import miembroEliminadoCorrectamente from '@salesforce/label/c.CIBE_MiembroEliminadoCorrectamente';
import problemaBorrandoMiembroDelEquipo from '@salesforce/label/c.CIBE_ProblemaBorrandoMiembroDelEquipo';
import problemaBorrandoMiembro from '@salesforce/label/c.CIBE_ProblemaBorrandoMiembro';
import miembroAnadido from '@salesforce/label/c.CIBE_MiembroAnadido';
import miembroAnadidoCorrectamente from '@salesforce/label/c.CIBE_MiembroAnadidoCorrectamente';
import problemaAnadiendoMiembro from '@salesforce/label/c.CIBE_ProblemaAnadiendoMiembro';
import cumplimentacionDatos from '@salesforce/label/c.CIBE_CumplimentacionDatos';
import cumplimentarDatosParaAnadir from '@salesforce/label/c.CIBE_CumplimentarDatosParaAnadir';

import nombreEmpleado from '@salesforce/label/c.CIBE_nombreEmpleado';
import numCentro from '@salesforce/label/c.CIBE_numCentro';
import funcion from '@salesforce/label/c.CIBE_funcion';
import codigoCartera from '@salesforce/label/c.CIBE_codigoCartera';
import rol from '@salesforce/label/c.CIBE_rol';
import responsabilidad from '@salesforce/label/c.CIBE_Responsabilidad';
import automatico from '@salesforce/label/c.CIBE_automatico';

import participante from '@salesforce/label/c.CIBE_participante';
import gestorPrincipal from '@salesforce/label/c.CIBE_gestorPrincipal';
import contactoCaixabankRetail from '@salesforce/label/c.CIBE_contactoCaixabankRetail';

export default class Cibe_CXBVisualizacionGC extends LightningElement {
    labels = {
        noModificarGPoCCR,
        noEliminarGPoCCR,
        anadirParticipante,
        editarParticipante,
        editarMiembro,
        borrarMiembro,
        equipoCBK,
        nombreEmpleado,
        numCentro,
        funcion,
        codigoCartera,
        rol,
        responsabilidad, 
        automatico,
        participante,
        gestorPrincipal,
        contactoCaixabankRetail,
        buscaParticipantes,
        rolParticipante,
        add,
        actualizar,
        cancelar,
        eliminar,
        eliminarParticipante,
        validacionBorrado,
        miembroNoModificable,
        noModificaMiembro,
        miembroNoEliminable,
        noEliminaMiembroAutomatico,
        miembroActualizadoCorrectamente,
        problemaModificandoMiembro,
        cumplimentarDatosParaModificar,
        miembroEliminado,
        miembroEliminadoCorrectamente,
        problemaBorrandoMiembroDelEquipo,
        problemaBorrandoMiembro,
        miembroAnadido,
        miembroAnadidoCorrectamente,
        problemaAnadiendoMiembro,
        cumplimentacionDatos,
        cumplimentarDatosParaAnadir
    };

    actions = [
        { label: this.labels.editarMiembro, name: 'edit' },
        { label: this.labels.borrarMiembro, name: 'delete' }
    ];

    @track columns = [
        { label: this.labels.nombreEmpleado,    fieldName: 'showContactRecord', type: 'url',        sortable: true,         typeAttributes: { label: { fieldName: "nombre" } }, target: '_self' },
        { label: this.labels.funcion,           fieldName: 'empleado',          type: 'text',       sortable: true },
        { label: this.labels.codigoCartera,     fieldName: 'cartera',           type: 'text' },
        { label: this.labels.rol,               fieldName: 'rol',               type: 'text',       sortable: true },
        { label: this.labels.responsabilidad,   fieldName: 'responsabilidad',   type: 'text',       initialWidth : 250 },
        { label: this.labels.numCentro,         fieldName: 'centro',            type: 'text',       sortable: true,         initialWidth : 150 },
        { label: this.labels.automatico,        fieldName: 'automatic',         type: 'boolean',    initialWidth : 100,     cellAttributes: { alignment: 'center' }  },
        { type: 'action', typeAttributes: { rowActions: this.actions } }
    ];
    
    @track optionsAdd = [
        { label: this.labels.participante,                      value: 'Participante' },
        { label: this.labels.gestorPrincipal,                   value: 'Gestor Principal' },
        { label: this.labels.contactoCaixabankRetail,           value: 'Contacto Caixabank para retail' }
    ];

    @track optionsEditEMP = [
        { label: this.labels.gestorPrincipal,                   value: 'Gestor Principal' }
    ];

    @track optionsEditCIB = [
        { label: this.labels.gestorPrincipal,                   value: 'Gestor Principal' },
        { label: this.labels.contactoCaixabankRetail,           value: 'Contacto Caixabank para retail' }
    ];
    
    @api recordIds;
    // @track sortBy;
    // @track sortDirection;
    // @track defaultSort = 'asc';
    @track isShowSpinner = true;

    @track isShowAddMember = false;
    @track isShowAddMemberButton = false;
    @track isShowEditMember = false;
    @track isShowDeleteMember = false;

    @track dataValues = [];

    //ADD MODAL
    @track _record;
    @track initialSelection = [];
    @track errors = [];

    //EDIT MODAL
    @api userId = USER_ID;
    @track userRoleName;
    @track isCIB;

    // DELETE MODAL
    @track usuarioAsociado;

    @wire(getUserRole,{userId:USER_ID})
	wiredUser({error,data}){
        if (data) {
            this.userRoleName = data;
            if(this.userRoleName == 'CIB'){
                this.isCIB = true;
            }else{
                this.isCIB = false;
            }
        } else if (error) {
            console.error(error);
        }
	}

    // Ordenacion
    @track offSet = 0;
    @track _wiredData;

    @wire(getRecords, { offSet : 0, recordIds : '$recordIds', isCIB : '$isCIB' })
    getValues(wireResult) {
        const { data, error } = wireResult;
        this._wiredData = wireResult;
        if(data){
            this.dataValues = JSON.parse(JSON.stringify(data));
            for (let i = 0; i < this.dataValues.length; i++) {
                if(this.dataValues[i].rol == 'Participante'){
                    this.dataValues[i].rol = this.labels.participante;
                }else if(this.dataValues[i].rol == 'Gestor Principal'){
                    this.dataValues[i].rol = this.labels.gestorPrincipal;
                }else {
                    this.dataValues[i].rol = this.labels.contactoCaixabankRetail;
                }
            }

            this.isShowSpinner = false;
            this.isLoaded = true;
            this.throwRefreshEvent();
        }else if(error) {
            this.isShowSpinner = false;
            console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
        }
    }
    viewMore() {
        this.isLoaded = false;
        this.offSet = (this.offSet <= 1990) ? (this.offSet + 10) : this.offSet;
        getRecords({ offSet : this.offSet, recordIds : this.recordIds, isCIB : this.isCIB })
            .then((data) => {
                if(this.isCIB){
                    const dataConcat = this.dataValues;
                    this.dataValues = dataConcat.concat(data);
                }else{
                    this.dataValues = JSON.parse(JSON.stringify(data));
                }
            })
            .catch(error => {
                console.log(error);
            })
            .finally(() => {
                this.isLoaded = true;
            });
    }

    get getViewMore() {
        return (this.offSet >= 2000 || (this.dataValues !== null && this.dataValues !== undefined && (this.dataValues.length % 10 !== 0)));
    }

    get height() {
        return (this.dataValues !== undefined && this.dataValues !== null && this.dataValues.length > 10) ? 'height: 295px' : '';
    }
    throwRefreshEvent() {
        this.dispatchEvent(new CustomEvent('loaded', {}));
    }


    @track _wiredDataButton;
    @wire(showAddMemberButton, { accountIds : '$recordIds' })
    getShowAddMemberButton(wireResult) {
        const { data, error } = wireResult;
        this._wiredDataButton = wireResult;
        if(data){
            this.isShowAddMemberButton = data;
        }else if(error) {
            console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
        }
    }

    showAddMember() {
        this.isShowAddMember = true;
    }

    @track sortBy;
    @track sortDirection;
    @track defaultSort = 'asc';

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

    handleSortData(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.dataValues = this.sortData(this.dataValues, event.detail.fieldName, event.detail.sortDirection);
    }

    hideAddMember() {
        this.isShowAddMember = false;
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

    handleSaveMember() {
        const cuentas=[]; 
        for (let i = 0; i < this.recordIds.length; i++) {
            cuentas.push(this.recordIds[i]);
        }

        if(this._record != null && cuentas.length > 0 ) {
            this.isShowSpinner = true;
            createTeamMember({'accountIds' : cuentas, 'userId' : this._record, 'rol' : this.rol})
                .then((results) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.labels.miembroAnadido,
                            message: this.labels.miembroAnadidoCorrectamente,
                            variant: 'success'
                        }));
                    this.rol = 'Participante';
                    this._record = null;
                    refreshApex(this._wiredData);
                    this.isShowAddMember = false;
                    
                })
                .catch((error) => {
                    console.error(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.labels.problemaAnadiendoMiembro,
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
        this._editedRecord = record.id;
        this.editedRol = record.rol;
        if(this.editedRol == 'Contacto Caixabank para retail' || this.editedRol == 'Gestor Principal'){
            this.isShowEditMember = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.miembroNoModificable,
                    message: this.labels.noModificarGPoCCR,
                    variant: 'warning'
                })
            );
        }else{
            this.usuarioAsociado = record.userId;
            this.isShowEditMember = true;
        }
    }

    deleteRow(row) {
        const record = JSON.parse(JSON.stringify(row));
        this.editedRol = record.rol;
        if(this.editedRol == 'Contacto Caixabank para retail' || this.editedRol == 'Gestor Principal'){
            this.isShowDeleteMember = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.miembroNoEliminable,
                    message: this.labels.noEliminarGPoCCR,
                    variant: 'warning'
                })
            );
        }else{

            if(record.automatic) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.miembroNoEliminable,
                        message: this.labels.noEliminaMiembroAutomatico,
                        variant: 'warning'
                    })
                );
            } else {
                this.usuarioAsociado = record.userId;
                this._deleteRecord = record.id;
                this.isShowDeleteMember = true;
            }
        }
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

    handleEditMember(event) {
        if(this.editedRol =='Gestor Principal' && this.hasGC == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error.',
                    message: this.labels.modificacionGPenFichaGC,
                    variant: 'warning'
                })
            );
            
        } else{
            if(this.editedRol != null && this._editedRecord != null) {
                this.isShowSpinner = true;
                this.isShowEditMember = false;
                
                updateTeamMember({ 'memberId' : this._editedRecord, 'accountIds' : this.recordIds, 'rol' : this.editedRol, 'userId' : this.usuarioAsociado })
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
            deleteTeamMember({ 'userId' : this.usuarioAsociado, 'accountIds' : this.recordIds})
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
                            title: this.labels.problemaBorrandoMiembroDelEquipo,
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