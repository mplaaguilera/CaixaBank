import { LightningElement, api, track } from 'lwc';

import getClientComments from '@salesforce/apex/CIBE_TimelineEMPController.getClientComments';

//Labels
import noDataFoundLabel from '@salesforce/label/c.CIBE_NoDataFound';
import buscar from '@salesforce/label/c.CIBE_buscar';
import cita from '@salesforce/label/c.CIBE_Event';
import oportunidad from '@salesforce/label/c.CIBE_Oportunidad';
import tarea from '@salesforce/label/c.CIBE_Task';
import caso from '@salesforce/label/c.CIBE_Caso';

export default class cibe_TimelineEMP extends LightningElement {
    @api recordId;

    @track lstComments;
    @track lstAllComments;
    @track showAll = false;
    @track loading = false;
    @track refreshIco = false;

    doneTypingInterval = 300;
    typingTimer;
    showResults = false;
    nestedMap = [];
    filterValue;
    label = {
        noDataFoundLabel,
        buscar,
        cita,
        oportunidad,
        tarea,
        caso
    }
    options = [
        { label: 'Read', value: 'Read' },
        { label: 'Edit', value: 'Edit' }
    ];

    connectedCallback() {
        this.toggleSpinner();
        this.getClientComments();
    }

    refresh() {
        this.toggleSpinner();
        this.cita = false;
        this.oportunidad = false;
        this.tarea = false;
        this.caso = false;
        this.primeraVez = true;
        this.refreshIco=true;
        this.getClientComments();
    }


    @track cita = false;
    @track oportunidad = false;
    @track tarea = false;
    @track caso = false;
    @track primeraVez = true;
    @track checked;
    

    handlecheckboxChange(event) {
        let id = event.target.id;
        let obj = id.split("-");     
        let object = obj[0];

        let checked = event.target.checked;
        this.primeraVez = false;
        switch(object) {
            case 'cita':
                if(this.cita !== checked){
                    this.cita = checked;
                }
                break;
            case 'oportunidad':
                if(this.oportunidad !== checked){
                    this.oportunidad = checked;
                }
                break;
            case 'tarea':
                if(this.tarea !== checked){
                    this.tarea = checked;
                }
                break;
            case 'caso':
                if(this.caso !== checked){
                    this.caso = checked;
                }
                break;
        }
        if (!this.cita && !this.oportunidad && !this.tarea && !this.caso) {
            this.primeraVez = true;
        }
        this.toggleSpinner();
        this.getClientComments();
        this.refreshIco=true;
    }
    
    getClientComments() {
        getClientComments({ accId: this.recordId, filter: this.filterValue, cita: this.cita, oportunidad: this.oportunidad, tarea: this.tarea, caso: this.caso, inicial: this.primeraVez })
            .then(result => {

                if(result != null) {
                    this.nestedMap = [];

                    for (var key in result) {
                            this.nestedMap.push({ key: key, value: result[key] })
                    }
                    if(this.nestedMap.length > 0){
                        this.showResults = true;
                    }
                }
                this.toggleSpinner();
                this.refreshIco=false;
                this.primeraVez = false;
            })
            .catch(error => {
                this.toggleSpinner();
            });
    }

    toggleSpinner() {
        this.loading = !this.loading;
    }

    handleFilterValue(event){

        this.filterValue = event.target.value;
        this.nestedMap = null;
        if (!this.cita && !this.oportunidad && !this.tarea && !this.caso) {
            this.primeraVez = true;
        }

        this.typingTimer = setTimeout(() => {
                getClientComments({ accId: this.recordId, filter: this.filterValue, cita: this.cita, oportunidad: this.oportunidad, tarea: this.tarea, caso: this.caso, inicial: this.primeraVez })
                .then(result => {
                    if(result != null) {
    
                        this.nestedMap = [];

                        for (var key in result) {
                                this.nestedMap.push({ key: key, value: result[key] })
                        }
    
                        if(this.nestedMap.length > 0){
                            this.showResults = true;
                        }
    
                    }
                    this.refreshIco=false;
                })
        }, this.doneTypingInterval);
    }
}