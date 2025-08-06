import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import USER_ID from '@salesforce/user/Id';

import lookupSearch from '@salesforce/apex/CIBE_CXBTeamNewOpportunityController.search';
import getMembers from '@salesforce/apex/CIBE_CXBTeamNewOpportunityController.getMembers';
import getAccountTeamMember from '@salesforce/apex/CIBE_CXBTeamNewOpportunityController.getAccountTeamMember';
import getContact from '@salesforce/apex/CIBE_CXBTeamNewOpportunityController.getContact';
import getUserRole 	    from '@salesforce/apex/CIBE_CXBVisualizacionGC_Controller.getUserRole';


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
import 	selecedOptions from '@salesforce/label/c.CIBE_SelectedOptions';
import 	availableOptions from '@salesforce/label/c.CIBE_AvailableOptions';
import 	equipoInternacional from '@salesforce/label/c.CIBE_EquipoInternacional';


export default class cibe_CXBTeamNewOpportunity extends NavigationMixin(LightningElement) {

    labels = {
        anadirParticipante,
        add,
        cancelar,
        nombre,
        funcion,
        centro,
        participante,
        buscaParticipantes,
        editarMiembro,
        addOppTM,
        oppAccess,
        readOnly,
        readWrite, 
        clientTeam,
        otrosGestores,
        availableOptions,
        selecedOptions,
        equipoInternacional

    }

    @api EAPGestor;
    @api recordId;
    @api valuePais;
    @api valueCountries;
    @api paisesArr;


    @api
    get records() {
        return this._records;
    }

    set records(records = []) {
        this._records = [...records];
    }

    @track _records = [];

    options = [
        { label: this.labels.readOnly, value: 'Read' },
        { label: this.labels.readWrite, value: 'Edit' }
    ];

    @track initialSelection = [];
    @track members = [];
	@track errors = [];
	@track buscar = '';
    @track selectedIds = [];
    @track contactIds = [];
    @track teamAccount = [];
    @track selected = [];
    @track selected2 = [];
    @track teamInternational = [];
    @track paises;
    @track isEMP = false;

    connectedCallback(){

        if(this.valuePais != null || this.valuePais != undefined){
            this.paises = this.valuePais.toString();
        }

        if(this.paises != null) {
            this.getContact();
        }
    }

    handleSearch(event) {
		this.buscar = event.detail.searchTerm;
		lookupSearch ({searchTerm: event.detail.searchTerm, EAPGestor: this.EAPGestor})
			.then((results) => {
				this.template.querySelector('[data-id="clookup1"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup1"]').scrollIntoView();
			})
			.catch((error) => {
				Console.log(error);
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
					Console.log(error);
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


    @track prueba;

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

    handleChange2(event){
        
        const teamIds = [];
        this.teamInternational.forEach(e => {
            teamIds.push(e.value);
        });
        this.selected2 = event.detail.value;

        let aux = [...this.selected2];
        const selectedIds = this.selectedIds.filter((item) => !teamIds.includes(item));
        aux = aux.concat(selectedIds);
        this.selectedIds = aux;

        this.data = this.data.filter(item => aux.includes(item.id));
        refreshApex(this._wiredDataValues);
        
    }

    @track data = [];
    @track _wiredDataValues;

    @wire(getMembers, { listIdContact : '$selectedIds' })
    getMembers(wireResult) {
        const { data, error } = wireResult;
        this._wiredDataValues = wireResult;

        if (data) {
            this.members = JSON.parse(JSON.stringify(data));
            this.members.forEach(e1 => {
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
            Console.log(error);
        }
    }

    @wire(getAccountTeamMember, {recordId : '$recordId', EAPGestor: '$EAPGestor'})
    getAccountTeamMember({ error, data }) {
        if(data){
            let options = [];
            for (var key in data) {
                options.push({ label: data[key].Name, value: data[key].Id  });
            }
            this.teamAccount = options;
        }else if(error){
            Console.log(error);
        }
        
    }

    getContact(){
        getContact({pais: this.paises})
            .then(result => {
                let options = [];
                for (var key in result) {
                    options.push({ label: result[key].Name, value: result[key].Id  });
                }
                this.teamInternational = options;
            })
            .catch(error => {
                Console.log(error);
        });
    }

    handlePermiso(event) {
        const value = event.detail.value;
        let targetId = event.target.dataset.id;
        let miembros = JSON.parse(JSON.stringify(this.data));
        
        miembros.forEach(e1 => {
            if(e1.id === targetId) {
                e1.permiso = value;
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
        this.selected2 = this.selectedIds;

    }

    sendData() {
        this._records = [];
        this.data.forEach(e => {
            this._records.push(
                {
                    UserId : e.user,
                    OpportunityAccessLevel : e.permiso,
                    TeamMemberRole : e.role
                }
            ); 
        });

        const attributeChangeEvent = new FlowAttributeChangeEvent(
            'records',
            this._records
        );
        this.dispatchEvent(attributeChangeEvent);
    }


    @wire(getUserRole,{userId:USER_ID})
	wiredUser({error,data}){
        if (data) {
            this.userRoleName = data;
            if(this.userRoleName == 'EMP'){
                this.isEMP = true;
            }else if (this.userRoleName == 'CIBE_CIBEmpresas'){
                this.isEMP = true;
            }
        } else if (error) {
            Console.log(error);
        }
	}

   

}