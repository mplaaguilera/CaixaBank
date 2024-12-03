import { LightningElement, wire, api, track } from 'lwc';
import getIntervininientes from '@salesforce/apex/SIR_LCMP_IngresosIntervinientes.getIntervininientes';
import updateIntervinientes from '@salesforce/apex/SIR_LCMP_IngresosIntervinientes.updateIntervinientes';
import getFormulario from '@salesforce/apex/SIR_LCMP_IngresosIntervinientes.getFormulario';
import updateFormulario from '@salesforce/apex/SIR_LCMP_IngresosIntervinientes.updateFormulario';
import {loadStyle } from 'lightning/platformResourceLoader';
import recurso from '@salesforce/resourceUrl/SIR_Formulario';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Sir_lwc_IngresosIntervinientes extends LightningElement {

    @api recordId;
    @track totalTrabajo;
    @track totalBienes;
    @track otrosDatos; 
    @track ingresosAdicionales;   
    intervinientes; 
    @api valorTotalTrabajo;
    @api valorTotalBienes;

    // cargamos con el recurso estatico los estilos
    connectedCallback(){
        loadStyle(this, recurso);
    }
    @wire(getIntervininientes, { idFormulario: '$recordId'})
    getIntervininientes({ error, data }) {                   
        this.intervinientes = data;
        if(data){
            let totalTrabajoTemp = 0;
            let totalBienesTemp = 0;
            for (let j = 0; j < data.length; j++) {
                totalTrabajoTemp = parseFloat(totalTrabajoTemp) + parseFloat(data[j].SIR_IngresosTrabajo__c);
                totalBienesTemp = parseFloat(totalBienesTemp) + parseFloat(data[j].SIR_IngresosBienes__c);
            }
            this.totalTrabajo = totalTrabajoTemp;
            this.totalBienes = totalBienesTemp;
            this.handleChnage();
        }
    }


    @wire(getFormulario, { idFormulario: '$recordId'})
    getFormulario({ error, data }) {
        if(data){
            this.otrosDatos = data[0].SIR_OtrosDatosInteres__c;
            this.ingresosAdicionales = data[0].SIR_IngresosAdicionalesUnidFam__c;
        }
    }


    changeIngresosAdicionales(event){
        this.ingresosAdicionales = event.target.value;
    }

  
    changeIngresosTrabajo(event){
        let tempAllRecords = Object.assign([], this.intervinientes);
        for (let j = 0; j < this.intervinientes.length; j++) {
            let tempRec = Object.assign({}, tempAllRecords[j]);
            if(j == event.target.label){
                tempRec[event.target.name] = (event.target.value != '')? event.target.value : 0;   
            }               
            tempAllRecords[j] = tempRec;
        }
        this.intervinientes = tempAllRecords;  

        var totalTrabajoTemp = 0;        
        for (var i = 0; i < this.intervinientes.length; i++) {            
            totalTrabajoTemp = parseFloat(totalTrabajoTemp)  + parseFloat(this.intervinientes[i].SIR_IngresosTrabajo__c);
        }
        this.totalTrabajo = totalTrabajoTemp;
        this.handleChnage();      
    }


    changeIngresosBienes(event){   
        let tempAllRecords = Object.assign([], this.intervinientes);
        for (let j = 0; j < this.intervinientes.length; j++) {
            let tempRec = Object.assign({}, tempAllRecords[j]);
            if(j == event.target.label){
                tempRec[event.target.name] = (event.target.value != '') ? event.target.value : 0;
            }               
            tempAllRecords[j] = tempRec;
        }
        this.intervinientes = tempAllRecords;

        var totalBienesTemp = 0;        
        for (var i = 0; i < this.intervinientes.length; i++) {
            totalBienesTemp = parseFloat(totalBienesTemp)  + parseFloat(this.intervinientes[i].SIR_IngresosBienes__c);
        }
        this.totalBienes = totalBienesTemp;
        this.handleChnage();

    }

    changeBienes(event){      
        let tempAllRecords = Object.assign([], this.intervinientes);
        for (let j = 0; j < this.intervinientes.length; j++) {
            let tempRec = Object.assign({}, tempAllRecords[j]);
            if(j == event.target.label){
                tempRec[event.target.name] = event.target.value;
            }               
            tempAllRecords[j] = tempRec;
        }
        this.intervinientes = tempAllRecords;
    }


    changeOtrosDatos(event){ 
        this.otrosDatos = event.target.value;
    }


    guardar(){
        // Actualizo los datos de Intervinientes Formulario
        updateIntervinientes({data: this.intervinientes}) .then(result => {            
            if(result == 'OK'){
                updateFormulario({idFormulario: this.recordId, totalTrabajo: this.totalTrabajo, totalBienes: this.totalBienes, otrosDatos: this.otrosDatos, ingresosAdicionales: this.ingresosAdicionales }) .then(result => {           
                    if(result == 'OK'){
                        // Muestro mensaje de OK
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Guardado',
                                message: 'Se ha guardado los cambios correctamente',
                                variant: 'success'
                            })
                        );
                    }
                });
            }
        });    
    }
    // mandamos evento
    handleChnage() {
        this.valorTotalTrabajo =  this.totalTrabajo;
        this.valorTotalBienes  =  this.totalBienes;
        
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("valoresingresos", {
            detail: {
                valorBienes:  this.valorTotalBienes,
                valorTrabajo: this.valorTotalTrabajo
               
            } 
        });
    
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
      }
}