import { LightningElement, api, track } from 'lwc';

import getClientComments from '@salesforce/apex/CIBE_TimelineCIBController.getClientComments';

// Labels 

import cita from '@salesforce/label/c.CIBE_Event';
import oportunidad from '@salesforce/label/c.CIBE_Oportunidad';
import tarea from '@salesforce/label/c.CIBE_Task';
import buscar from '@salesforce/label/c.CIBE_buscar';
import tipoConPro from '@salesforce/label/c.cibe_TipoContactoProducto';
import estado from '@salesforce/label/c.CIBE_Estado';
import empleado from '@salesforce/label/c.CIBE_Empleado';
import fechaCierre from '@salesforce/label/c.CIBE_ClosingDate';
//import fechaCierre from '@salesforce/label/c.CIBE_FechaCierre';
import noDataFoundLabel from '@salesforce/label/c.CIBE_NoDataFound';
import todos from '@salesforce/label/c.CIBE_Todos';
import ult30dias from '@salesforce/label/c.CIBE_Ultimos30dias';
import ult6meses from '@salesforce/label/c.CIBE_Ultimos6meses';
import ult12meses from '@salesforce/label/c.CIBE_Ulti12meses';


export default class cibe_TimelineCIB extends LightningElement {
    @api recordId;

    @track lstComments;
    @track lstAllComments;
    @track showAll = false;
    @track loading = false;
    @track refreshIco = false;

    labels = {
		cita,
        oportunidad,
        tarea,
        buscar,
        tipoConPro,
        estado,
        empleado,
        fechaCierre,
        noDataFoundLabel,
        todos,
        ult30dias,
        ult6meses,
        ult12meses
	};

    doneTypingInterval = 300;
    typingTimer;
    showResults = false;
    nestedMap = [];
    filterValue;
    label = {
        noDataFoundLabel
    }


    connectedCallback() {
        this.toggleSpinner();
        this.getClientComments();
    }

    refresh() {
        this.toggleSpinner();
        this.cita = true;
        this.oportunidad = true;
        this.tarea = false;
        this.primeraVez = true;
        this.refreshIco=true;
        this.value = this.stringAll;
        this.getClientComments();
    }

    @track cita = true;
    @track oportunidad = true;
    @track tarea = false;
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
        }

        this.toggleSpinner();
        this.getClientComments();
        this.refreshIco=true;
    }
    
    getClientComments() {
        getClientComments({ accId: this.recordId, filter: this.filterValue, cita: this.cita, oportunidad: this.oportunidad, tarea: this.tarea, inicial: this.primeraVez, filterDate: this.value})    
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

        if (this.cita && this.oportunidad && !this.tarea) {
            this.primeraVez = true;
        }

        this.typingTimer = setTimeout(() => {
                getClientComments({ accId: this.recordId, filter: this.filterValue, cita: this.cita, oportunidad: this.oportunidad, tarea: this.tarea, inicial: this.primeraVez, filterDate: this.value })
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

    selectedItemValue;

    handleOnselect(event) {
        this.selectedItemValue = event.detail.value;
    }

    getDateStringNMonth(nMonths) {
        var actualDate = new Date();
        actualDate.setMonth(actualDate.getMonth() - nMonths);
        var year = actualDate.getFullYear();
        var month = actualDate.getMonth() + 1; // los meses comienzan desde 0
        var day = actualDate.getDate();

        // Ajusta el formato para que haya dos dígitos en mes y día
        var monthStr = month < 10 ? '0' + month : month.toString();
        var dayStr = day < 10 ? '0' + day : day.toString();
    
        var dateFormated = year + '-' + monthStr + '-' + dayStr;

        return dateFormated;
    }

    @track string6Months = this.getDateStringNMonth(6);
    
    @track string12Months = this.getDateStringNMonth(12);
    
    @track string30Days = this.getDateStringNMonth(1);

    @track stringAll = this.getDateStringNMonth(1200);

    @track value = this.stringAll;

    get options() {
        return [
            { label: this.labels.todos, value: this.stringAll},
            { label: this.labels.ult30dias, value: this.string30Days},
            { label: this.labels.ult6meses, value: this.string6Months},
            { label: this.labels.ult12meses, value: this.string12Months}
        ];
    }

    handleChange(e) {
        this.value = e.detail.value;
        this.toggleSpinner();
        this.getClientComments();
        
    }
}