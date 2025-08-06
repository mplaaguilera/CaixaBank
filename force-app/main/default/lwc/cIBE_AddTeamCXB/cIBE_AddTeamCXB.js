import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uId from '@salesforce/user/Id';



import participante from '@salesforce/label/c.CIBE_participante';
import buscaParticipantes from '@salesforce/label/c.CIBE_BuscaParticipantes';
import add from '@salesforce/label/c.CIBE_Add';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import añadirParticipante from '@salesforce/label/c.CIBE_AnadirParticipante';
import miembroAnadido from '@salesforce/label/c.CIBE_MiembroAnadido';
import miembroAnadidoCorrectamente from '@salesforce/label/c.CIBE_MiembroAnadidoCorrectamente';
import problemaAnadiendoMiembro from '@salesforce/label/c.CIBE_ProblemaAnadiendoMiembro';
import select from '@salesforce/label/c.CIBE_Select';
import codigoCartera from '@salesforce/label/c.CIBE_codigoCartera';
import equipo from '@salesforce/label/c.CIBE_Equipo';



import getCartera     from '@salesforce/apex/CIBE_AddTeamCXBController.getCartera';
import insertCXB     from '@salesforce/apex/CIBE_AddTeamCXBController.insertCXB';
import lookupSearchUser     from '@salesforce/apex/CIBE_CXBDisplayController.searchUser';



export default class CIBE_AddTeamCXB extends LightningElement {

    labels = {
        participante,
        buscaParticipantes,
        add,
        cancelar,
        añadirParticipante,
        miembroAnadido,
        miembroAnadidoCorrectamente,
        problemaAnadiendoMiembro,
        select,
        codigoCartera,
        equipo
    };

    @track initialSelection = [];
	@track errors = [];
    @track _record;
    @track isShow = false;
    @track isShowAddMember = false;
    @track optionsAdd = [];

    @track allValues = [];
    @track user = uId;
    @track showSpinner = false;

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

    hideAddMember() {
        this.isShowAddMember = false;
        this.allValues = [];
    }

    showAddMember() {
        this.isShowAddMember = true;
    }

    @wire(getCartera, {idUsuario: '$user'})
    getCartera({data, error}){
        if(data){
            data.forEach(element => {
                this.optionsAdd.push({label: element.AV_Cartera__r.AV_ExternalID__c, value:  element.AV_Cartera__r.AV_ExternalID__c})
            });
        }else if (error){
            console.log(error);
        }
    }
    

    handleChange(event){
        if(!this.allValues.includes(event.target.value)){
            this.allValues.push(event.target.value)
        }
    }

    handleRemove(event){
        const valueRemoved = event.target.name;
        this.allValues.splice(this.allValues.indexOf(valueRemoved), 1);
    }

    handleSaveMember(){
        this.showSpinner = true;
        insertCXB({memberId : this._record, carteraElegida : this.allValues})
        .then((result) =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.miembroAnadido,
                    message: this.labels.miembroAnadidoCorrectamente,
                    variant: 'success'
                })
            );
        })
        .catch((error) =>{
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.problemaAnadiendoMiembro,
                    message: error.body.message,
                    variant: 'error'
                })
            );
        })
        .finally(() =>{
            this.isShowAddMember = false;
            this.allValues = [];
            this.showSpinner = false;
        })
    }

}