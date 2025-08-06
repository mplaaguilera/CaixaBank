import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import currentUserId from '@salesforce/user/Id';

//Métodos Apex
import getCaseTeamMembers from '@salesforce/apex/GRR_Compartir_Casos_Controller.getCaseTeamMembers'; 
import getUsuarios from '@salesforce/apex/GRR_Compartir_Casos_Controller.getUsuarios'; 
import getCaseTeamRoles from '@salesforce/apex/GRR_Compartir_Casos_Controller.getCaseTeamRoles'; 
import compartirUsuarioCaso from '@salesforce/apex/GRR_Compartir_Casos_Controller.compartirUsuarioCaso'; 
import eliminarUsuarioCaso from '@salesforce/apex/GRR_Compartir_Casos_Controller.eliminarUsuarioCaso'; 

//Campos del caso
import CASO_ID from '@salesforce/schema/Case.Id';
import CASE_OWNER_ID from '@salesforce/schema/Case.OwnerId';

const FIELDS_CASO = [CASO_ID,CASE_OWNER_ID]; 

export default class grr_Compartir_Casos extends NavigationMixin(LightningElement) {
    @api recordId;
    caseTeamMembers;
    usuariosGrupo;
    selectedCaseTeamMembers = [];
    selectedUsuariosGrupo = [];
    wiredCaseTeamMembersResult;
    wiredUsuariosGrupoResult;
    modalCompartirCargado = false;
    caseTeamRoles = [];
    selectedRoleId = '';
    caso;

    get botonCompartirDisabled() {
        return this.selectedUsuariosGrupo.length === 0 || this.selectedRoleId === '';
    }

    get botonEliminarDisabled() {
        return this.selectedCaseTeamMembers.length === 0;
    }

    get propietarioDisabled() {
		return currentUserId !== getFieldValue(this.caso, CASE_OWNER_ID);
	}

    connectedCallback() {
        this.loadCaseTeamRoles();
    }

    caseTeamColumns = [
        { label: 'Usuario', fieldName: 'memberName', type: 'text' },
        { label: 'Acceso', fieldName: 'teamRoleName', type: 'text' }
    ];

    usuariosGrupoColumns = [
        { label: 'Usuario', fieldName: 'usuario', type: 'text' }
    ];

    @wire(getCaseTeamMembers, { caseId: '$recordId' })
    wiredCaseTeamMembers(result) {
        this.wiredCaseTeamMembersResult = result;
        if (result.data) {
            this.caseTeamMembers = result.data.map(item => ({
                ...item,
                teamRoleName: item.TeamRole ? item.TeamRole.Name : '',
                memberName: item.Member ? item.Member.Name : '',
                memberId: item.Member ? item.MemberId : '',
                caseTeamMemberId: item.Id ? item.Id : ''
            }));
        } else if (result.error) {
            this.caseTeamMembers = undefined;
            console.error(JSON.stringify(result.error));
            this.mostrarToast('error', 'Problema al cargar los datos de CaseTeamMembers', result.error.body.message, 'sticky');
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS_CASO })
    wiredCaso({ error, data }) {
        if (data) {
            this.caso = data; 
        } else if (error) {
            this.caso = undefined;
            console.error(JSON.stringify(result.error));
            this.mostrarToast('error', 'Problema al cargar los datos del caso', result.error.body.message, 'sticky');
        }
    }

    loadCaseTeamRoles() {
        getCaseTeamRoles()
            .then(result => {
                this.caseTeamRoles = result.map(role => ({
                    label: role.Name,
                    value: role.Id
                }));
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.mostrarToast('error', 'Problema al cargar los datos de los roles', error.body.message, 'sticky');
            });
    }

    compartirAbrir() {
        if(this.caseTeamMembers){
            if(!this.usuariosGrupo){
                getUsuarios()
                .then(result => {
                    this.wiredUsuariosGrupoResult = result;
                    const usuariosNoCompartidos = result.filter(usuario => {
                        return !this.caseTeamMembers.some(member => member.memberId === usuario.UserOrGroupId);
                    });
            
                    this.usuariosGrupo = usuariosNoCompartidos.map(item => ({
                        ...item,
                        usuario: item.UserOrGroup ? item.UserOrGroup.Name : '',
                        usuarioId: item.UserOrGroup ? item.UserOrGroupId : ''
                    }));
                })
                .catch(error => {
                    this.mostrarToast('error', 'Problema recuperando los datos de usuariosGrupo', error);
                });
            }
            this.modalCompartirCargado = true;
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (event.target.dataset.id === 'usuariosGrupoTable') {
            this.selectedUsuariosGrupo = selectedRows;
        } else if (event.target.dataset.id === 'caseTeamTable') {
            this.selectedCaseTeamMembers = selectedRows;
        }
    }

    compartirCaso() {
        if (!this.selectedRoleId) {
            this.mostrarToast('error', 'Seleccione un rol antes de compartir el caso', '');
            return;
        }

        const selectedRole = this.caseTeamRoles.find(role => role.value === this.selectedRoleId);
        const roleName = selectedRole ? selectedRole.label : ''; 

        const usuariosCompartir = this.selectedUsuariosGrupo.map(selectedUsuario => ({
            'Usuario': selectedUsuario.usuario,
            'UsuarioId': selectedUsuario.usuarioId,
            'RoleId': this.selectedRoleId
        }));

        compartirUsuarioCaso({ records: usuariosCompartir, caseId: this.recordId })
            .then(result => {
                this.caseTeamMembers = [...this.caseTeamMembers, ...this.selectedUsuariosGrupo.map(usuario => ({
                    memberName: usuario.usuario,
                    teamRoleName: roleName,
                    memberId: usuario.usuarioId
                }))];
                this.usuariosGrupo = this.usuariosGrupo.filter(usuario => !this.selectedUsuariosGrupo.some(selected => selected.usuarioId === usuario.usuarioId));
                
                this.selectedUsuariosGrupo = [];
                this.closeModal();
                this.mostrarToast('Success', 'Éxito', 'Se ha añadido acceso a este caso para los siguientes usuarios: (' + result + ').');
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.mostrarToast('error', 'Problema añadiendo acceso a este caso', error.body.message, 'sticky');
            });
    }

    eliminarCompartirCaso() {
        const usuariosEliminar = this.selectedCaseTeamMembers.map(selectedUsuario => ({
            'Usuario': selectedUsuario.memberName,
            'Permisos': selectedUsuario.teamRoleName,
            'UsuarioId': selectedUsuario.memberId,
            'Id': selectedUsuario.caseTeamMemberId
        }));

        eliminarUsuarioCaso({ records: usuariosEliminar, caseId: this.recordId})
            .then(result => {
                 this.usuariosGrupo = [...this.usuariosGrupo, ...this.selectedCaseTeamMembers.map(member => ({
                    usuario: member.memberName,
                    usuarioId: member.memberId
                }))];
                this.caseTeamMembers = this.caseTeamMembers.filter(member => !this.selectedCaseTeamMembers.some(selected => selected.memberId === member.memberId));
                
                this.selectedCaseTeamMembers = [];
                this.closeModal();
                this.mostrarToast('Success', 'Éxito', 'Se ha eliminado el acceso a este caso para los siguientes usuarios: (' + result + ').');
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.mostrarToast('error', 'Problema eliminado el acceso a este caso', error.body.message, 'sticky');
            });
    }

    modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.closeModal();
		}
	}

    closeModal() {
        this.modalCompartirCargado = false;
        this.selectedRoleId = '';
    }

    handleRoleChange(event) {
        this.selectedRoleId = event.detail.value;
    }

    mostrarToast(tipo, titulo, mensaje, modo) {
        const eventoToast = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: tipo,
            mode: modo
        });
        this.dispatchEvent(eventoToast);
    }

}