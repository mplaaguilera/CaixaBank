import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

import lookupSearch from '@salesforce/apex/CIBE_CXBTeamNewOpportunityController.search';
import getMembers from '@salesforce/apex/CIBE_CXBTeamNewOpportunityController.getMembers';

//methods
import getAccountTeamMember from '@salesforce/apex/CIBE_OpportunityUpdateTeam.getAccountTeamMember';
import newRecords from '@salesforce/apex/CIBE_OpportunityUpdateTeam.updateOpportunityTeamMember';
import getOpportunityTeamMembers from '@salesforce/apex/CIBE_OpportunityUpdateTeam.getOpportunityTeamMembers';
import showAddMemberButton from '@salesforce/apex/CIBE_OpportunityUpdateTeam.showAddMemberButton';
import deleteTeamMember  from '@salesforce/apex/CIBE_OpportunityUpdateTeam.deleteTeamMember';
import updateTeamMember     from '@salesforce/apex/CIBE_OpportunityUpdateTeam.updateTeamMember';
import validationCloseDate from       '@salesforce/apex/CIBE_OpportunityUpdateTeam.validationCloseDate';





//import labels
import anadirParticipante from '@salesforce/label/c.CIBE_AnadirParticipante';
import add from '@salesforce/label/c.CIBE_Add';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import nombre from '@salesforce/label/c.CIBE_Name';
import funcion from '@salesforce/label/c.CIBE_funcion';
import centro from '@salesforce/label/c.CIBE_Centro';
import buscaParticipantes from '@salesforce/label/c.CIBE_BuscaParticipantes';
import participante from '@salesforce/label/c.CIBE_participante';
import editarMiembro from '@salesforce/label/c.CIBE_EditarMiembro';
import addOppTM from '@salesforce/label/c.CIBE_AddOppTM';
import oppAccess from '@salesforce/label/c.CIBE_OppAccess';
import readOnly from '@salesforce/label/c.CIBE_ReadOnly';
import readWrite from '@salesforce/label/c.CIBE_ReadWrite';
import clientTeam from '@salesforce/label/c.CIBE_ClientTeam';
import otrosGestores from '@salesforce/label/c.CIBE_OtrosGestores';
import teamOppo from '@salesforce/label/c.CIBE_TeamOpportunity';
import miembroAnadido from '@salesforce/label/c.CIBE_MiembroAnadido';
import miembroAnadidoCorrectamente from '@salesforce/label/c.CIBE_MiembroEquipoOpp';
import problemaAnadiendoMiembro from '@salesforce/label/c.CIBE_ProblemaAnadiendoMiembro';
import nombreEmpleado from '@salesforce/label/c.CIBE_nombreEmpleado';
import rol from '@salesforce/label/c.CIBE_rol';
import borrarMiembro from '@salesforce/label/c.CIBE_borrarMiembro';
import eliminarParticipante from '@salesforce/label/c.CIBE_EliminarParticipante';
import validacionBorrado from '@salesforce/label/c.CIBE_DeleteOppTeamMember';
import eliminar from '@salesforce/label/c.CIBE_Eliminar';
import miembroEliminado from '@salesforce/label/c.CIBE_MiembroEliminado';
import miembroEliminadoCorrectamente from '@salesforce/label/c.CIBE_DeleteSuccessfully';
import deleteProblemOppTeam from '@salesforce/label/c.CIBE_DeleteProblemOppTeam';
import problemaBorrandoMiembro from '@salesforce/label/c.CIBE_ProblemaBorrandoMiembro';
import editarParticipante from '@salesforce/label/c.CIBE_EditarParticipante';
import miembroActualizado from '@salesforce/label/c.CIBE_MiembroActualizado';
import miembroActualizadoCorrectamente from '@salesforce/label/c.CIBE_MiembroActualizadoCorrectamente';
import problemaModificandoMiembro from '@salesforce/label/c.CIBE_ErrorUpdate';
import cumplimentacionDatos from '@salesforce/label/c.CIBE_CumplimentacionDatos';
import cumplimentarDatosParaAnadir from '@salesforce/label/c.CIBE_CumplimentarDatosParaAnadir';
import 	selecedOptions from '@salesforce/label/c.CIBE_SelectedOptions';
import 	availableOptions from '@salesforce/label/c.CIBE_AvailableOptions';
import miembroNoModificable from '@salesforce/label/c.CIBE_MiembroNoModificable';
import noModificaMiembro from '@salesforce/label/c.CIBE_NoModificaMiembroOpp';

export default class Cibe_OpportunityUpdateTeam extends LightningElement {

    labels = {
        anadirParticipante,
        add,
        cancelar,
        nombre,
        funcion,
        centro,
        participante,
        buscaParticipantes,
        addOppTM,
        oppAccess,
        readOnly,
        readWrite,
        clientTeam,
        otrosGestores,
        teamOppo,
        miembroAnadido,
        miembroAnadidoCorrectamente,
        problemaAnadiendoMiembro,
        nombreEmpleado,
        rol,
        eliminarParticipante,
        validacionBorrado,
        eliminar,
        miembroEliminado,
        miembroEliminadoCorrectamente,
        deleteProblemOppTeam,
        problemaBorrandoMiembro,
        editarParticipante,
        miembroActualizado,
        miembroActualizadoCorrectamente,
        problemaModificandoMiembro,
        cumplimentacionDatos,
        cumplimentarDatosParaAnadir,
        selecedOptions,
        availableOptions,
        miembroNoModificable,
        noModificaMiembro
    }


    @track editedAcces;
    @track memberId;
    @track _editedRecord = [];
    @track _deleteRecord;
    @track isShowAddMemberButton = false;
    @track isShowDeleteMember = false;
    @track isShowEditMember = false;
    @track isModalOpen = false;
    @track selectedIds = [];
    @track teamAccount = [];
    @track _records = [];
	@track errors = [];
	@track buscar = '';
    @track teamOpp = [];
    @track selected = [];
    @api recordId;
    @track isShowSpinner = false;
    @track data = [];
    @track _wiredDataValues;
    @track _wiredOppTeam;

    @track funcionEdit;
    @track centronEdit;
    @track accesoEdit;
    @track participanteEdit;
    

    options = [
        { label: this.labels.readOnly, value: 'Read' },
        { label: this.labels.readWrite, value: 'Edit' }
    ];

    // @track actions = [
    //     { label: editarMiembro, name: 'edit'
    //     },
    //     { label: borrarMiembro, name: 'delete'
    //     }
    // ];

    columns = [ { label: this.labels.nombreEmpleado, fieldName: 'contactoId', type: 'url', typeAttributes: {label: { fieldName: 'contactoName' } }},
        {
            label: this.labels.funcion,
            fieldName: 'funcion',
            type: 'text'
        },
        {
            label: this.labels.centro,
            fieldName: 'centro',
            type: 'Text'
        },
        { type: 'action', typeAttributes: { rowActions: this.getRowActions } }
    ];

    columnsAccTM = [
        {
            label: this.labels.nombreEmpleado,
            fieldName: 'Name',
            type: 'Text'
        },
        {
            label: this.labels.funcion,
            fieldName: 'AV_DescFuncion__c',
            type: 'Text'
        },
        { label: this.labels.centro, fieldName: 'AccountName', type: 'text', typeAttributes: {label: { fieldName: 'AccountName' } }}
    ];

    
    @wire(getOpportunityTeamMembers, {recordId: '$recordId'})
    getOpportunityTeamMembers(wiredResult){
        this._wiredOppTeam = wiredResult;
        const {data, error} = wiredResult;
        if(data){
            console.log(data);
            this.teamOpp = data;
        }else if (error){
            console.log(error);
        }
    }
    
    @wire(showAddMemberButton, { recordId : '$recordId' })
    getShowAddMemberButton({ data, error }) {
        if(data){
            this.isShowAddMemberButton = data;
        }else if(error) {
            console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(validationCloseDate, { recordId : '$recordId' })
    getValidationCloseDate({ data, error }) {
        if(data){
            this.isDisabled = data;
        }else if(error) {
            console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
        }
    }
    
    @wire(getAccountTeamMember, {recordId : '$recordId'})
    getAccountTeamMember({ error, data }) {
        if(data){
            for (var key in data) {
                this.teamAccount.push({ label: data[key].Name, value: data[key].Id  });
            }
        }else if(error){
            console.log(error);
        }
        
    }

    @wire(getMembers, { listIdContact : '$selectedIds' })
    getMembers(wireResult) {
        this._wiredDataValues = wireResult;
        const { data, error } = wireResult;

        if (data) {
            data.forEach(e1 => {
                if(this.data.some(item => item.id === e1.id)) {
                    this.data.forEach(e2 => {
                        if(e2.id === e1.id) {
                            e2.nombre = e1.nombre;
                            e2.user = e1.user;
                            e2.centro = e1.centro;
                            e2.funcion = e1.funcion;
                            e2.role = e1.role;
                        }
                    });
                } else {
                    this.data.push(e1);
                }
            });
            this.sendData();
        } else if(error) {
            console.log(error);
        }
    }

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
        this.data = [];
        this.selected = [];


    }
    submitDetails() {
        this.isShowSpinner = true;
        var record = this.recordId;
        newRecords({ recordId: record, lista: this._records})
        .then((result) =>{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.miembroAnadido,
                        message:  this.labels.miembroAnadidoCorrectamente,
                        variant: 'success'
                    })
                );   
            this.isShowSpinner = false;
        })
        .catch(error =>{
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title:  this.labels.problemaAnadiendoMiembro,
                    variant: 'error'
                })
            ); 
        })
        .finally(() =>{
            this.isShowSpinner = false;
            this.isModalOpen = false;
            this.data = [];
            this.selected = [];
            refreshApex(this._wiredOppTeam);
        })
        
    }


   

    handleSearch(event) {
		this.buscar = event.detail.searchTerm;
		lookupSearch ({searchTerm: event.detail.searchTerm, EAPGestor: this.EAPGestor})
			.then((results) => {
				this.template.querySelector('[data-id="clookup1"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup1"]').scrollIntoView();
			})
			.catch((error) => {
				console.error(error);
				this.errors = [error];
			});
	}

	handleSearchClick(event) {
		if (this.buscar == '') {
			lookupSearch ({searchTerm: event.detail.searchTerm, EAPGestor: this.EAPGestor })
				.then((results) => {
					this.template.querySelector('[data-id="clookup1"]').setSearchResults(results);
					this.template.querySelector('[data-id="clookup1"]').scrollIntoView();
				})
				.catch((error) => {
					console.error(error);
					this.errors = [error];
				});
		}
	}

    handleSelectionChange(event) {
        this.errors = [];
        let targetId = event.target.dataset.id;
        const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
        
        const selectedIds = JSON.parse(JSON.stringify(this.selectedIds));
        if(selection && selection.length !== 0){
            selection.forEach(sel => {
                if(!selectedIds.includes(sel.id)){
                    selectedIds.push(sel.id);
                }
            });
            this.selectedIds = selectedIds;
            this.template.querySelector(`[data-id="${targetId}"]`).handleClearSelection();
        }
    }
    


    handlePermiso(event) {
        const valueAcees = event.detail.value;
        let targetId = event.target.dataset.id;
        let miembros = JSON.parse(JSON.stringify(this.data));
        
        miembros.forEach(e1 => {
            if(e1.id === targetId) {
                e1.permiso = valueAcees;
            }
        });
        this.data = miembros;
        this.sendData();
    }


    removeMember(event) {
        let targetId = event.target.dataset.id;
        this.data = JSON.parse(JSON.stringify(this.data.filter(item => item.id !== targetId))); 
        this.selectedIds = this.selectedIds.filter((item) => item !== targetId);
        this.selected = this.selectedIds;

    }

    handleChange(event){
        const teamIds = [];
        this.teamAccount.forEach(e => {
            teamIds.push(e.value);
        });

        this.selected = event.detail.value;

        let aux = [...this.selected];
        const selectedIds = this.selectedIds.filter((item) => !teamIds.includes(item));
        aux = aux.concat(selectedIds);
        this.selectedIds = aux;

        this.data = this.data.filter(item => aux.includes(item.id));
        refreshApex(this._wiredDataValues);
    }   

    sendData() {
        this._records = []
        this.data.forEach(e => {
            this._records.push(
                {
                    UserId : e.user,
                    OpportunityAccessLevel : e.permiso,
                    TeamMemberRole : e.role,
                    OpportunityId : this.recordId
                }
            ); 
        });
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

    deleteRow(row) {
        const record = JSON.parse(JSON.stringify(row.Id));
        this._deleteRecord = record;
        this.isShowDeleteMember = true;

    }

    hideDeleteMember() {
        this.isShowDeleteMember = false;
    }

    handleDeleteMember(event) {
        if(this._deleteRecord != null) {
            this.isShowSpinner = true;
            this.isShowDeleteMember = true;
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
                    refreshApex(this._wiredOppTeam);
                })
                .catch((error) => {
                    console.error('Error deleting Team Member:', JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title:this.labels.deleteProblemOppTeam,
                            message: error.body.message,
                            variant: 'error'
                        })
                    );  
                })
                .finally(() => {
                    this.isShowSpinner = false;
                    this.isShowDeleteMember = false;

                });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.problemaBorrandoMiembro,
                    message: this.labels.deleteProblemOppTeam,
                    variant: 'error'
                })
            );  
        }
    }

    editRow(row) {
        const recordEdit = JSON.parse(JSON.stringify(row.Id));
        this.editedAcces = row.OpportunityAccessLevel
        this.memberId = recordEdit;
        this._editedRecord.push(recordEdit);
        this.isShowEditMember = true;
        this.funcionEdit = row.funcion;
        this.centronEdit = row.centro;
        this.accesoEdit = row.OpportunityAccessLevel;
        this.participanteEdit = row.contactoName;
    }

    hideEditMember() {
        this.memberId = null;
        this.isShowEditMember = false;
        this._editedRecord = [];

    }

    handleEditAccesChange(event) {
        this.editedAcces = event.detail.value;
    }

    handleEditMember(event) {
            if(this.editedAcces != null && this.memberId != null) {
                this.isShowSpinner = true;
                this.isShowEditMember = false;
                updateTeamMember({'memberId' : this.memberId, 'acces' : this.editedAcces })
                    .then((results) => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: this.labels.miembroActualizado,
                                message: this.labels.miembroActualizadoCorrectamente,
                                variant: 'success'
                            })
                        );
                         this.memberId = null;
                         this.editedAcces = null;
                         refreshApex(this._wiredOppTeam);
                            
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
                        this._editedRecord = [];
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


    getRowActions(row, doneCallback) {
        const actions = [];

        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;

        var date = new Date(new Date().setDate(new Date().getDate() + 547))
        var DD = String(date.getDate()).padStart(2, '0');
        var MM = String(date.getMonth() + 1).padStart(2, '0');
        var YYYY = date.getFullYear();
        date = YYYY + '-' + MM + '-' + DD;


        if ( ((row.recordType == 'CIBE_AccionComercialCIB' ||
        row.recordType == 'CIBE_AlertaComercialCIB' ||
        row.recordType == 'CIBE_AlertaComercialEMP' ||
        row.recordType == 'CIBE_IniciativaEmpleadoEMP' ||
        row.recordType == 'CIBE_IniciativaEmpleadoCIB' ||
        row.recordType == 'CIBE_AccionComercialEMP')
        && (row.closeDate >= today && row.closeDate <= date)) || 
        (row.recordType == 'CIBE_SugerenciaCIB' ||
        row.recordType == 'CIBE_SugerenciaEMP')  ) {
            actions.push ({
                label: editarMiembro,
                name: 'edit',
                disabled : false
            },
            {
                'label': borrarMiembro,
                'name': 'delete',
                'disabled' : false
            }
            );
        }else{
            actions.push({
                'label': editarMiembro,
                'name': 'edit',
                'disabled' : true
            }, 
            {
                'label': borrarMiembro,
                'name': 'delete',
                'disabled' : true
            });
        }
        setTimeout(() => {
            doneCallback(actions);
        }), 200;
               
    }
}