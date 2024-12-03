import { LightningElement, wire, api, track } from 'lwc';
import getFormulario from '@salesforce/apex/SIR_LCMP_GastosIntervinientes.getFormulario';
import getMetadatos from '@salesforce/apex/SIR_LCMP_GastosIntervinientes.getMetadatos';
import updateFormulario from '@salesforce/apex/SIR_LCMP_GastosIntervinientes.updateFormulario';
import {loadStyle } from 'lightning/platformResourceLoader';
import recurso from '@salesforce/resourceUrl/SIR_Formulario';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Sir_lwc_GastosIntervinientes extends LightningElement {
    formulario;
    @api recordId;
    @track optionsMiembros = [  { label: '1', value: '1' },
                                { label: '2', value: '2' },
                                { label: '3', value: '3' },
                                { label: '4', value: '4' },
                                { label: '+4', value: '+4' },
                            ];
    
    @track miembrosUnidad = '1';
    @track impMin;
    @track alquiler;
    @track pension;
    @track otros;
    @track justificarOtros = '';
    @track totalGastos = 0;
    @track form = [];
    @track calculo;
    @api valorTotalGastos;

    // cargamos con el recurso estatico los estilos
    connectedCallback(){
        loadStyle(this, recurso);
    }
    @wire(getFormulario, { idFormulario: '$recordId'})
    getFormulario({ error, data }) {           
        if(data){
            this.formulario = data;
            this.miembrosUnidad = this.formulario[0].SIR_MiembrosUnidadFamiliar__c;
            this.impMin = this.formulario[0].SIR_ImporteMinSubsistencia__c;
            this.alquiler = this.formulario[0].SIR_AlquilerViviendaHabitual__c;
            this.pension = this.formulario[0].SIR_PensionAlimenticia__c;
            this.otros = this.formulario[0].SIR_Otros__c;
            this.justificarOtros = this.formulario[0].SIR_JustificarOtrosGastos__c;
            this.totalGastos = this.formulario[0].SIR_TotalGastos__c;
            
            this.totalGastos = parseFloat(this.impMin) + parseFloat(this.alquiler) + parseFloat(this.pension ) + parseFloat(this.otros);             
            getMetadatos({}).then(result => {  
                this.calculo = result;                
                if(this.miembrosUnidad == '1'){
                    this.impMin = this.calculo['ImpMinSubsistencia1'].Valor__c;
                    this.totalGastos = parseFloat(this.impMin) + parseFloat(this.alquiler) + parseFloat(this.pension ) + parseFloat(this.otros);
                }
                this.handleChnage(); 
            });                         
        }
    }


    changeMiembros(event){ 
        this.miembrosUnidad = event.target.value;
        if(this.miembrosUnidad == '1'){
            this.impMin = this.calculo['ImpMinSubsistencia1'].Valor__c;
        } else if(this.miembrosUnidad == '2'){
            this.impMin = this.calculo['ImpMinSubsistencia2'].Valor__c;
        } else {
            this.impMin = this.calculo['ImpMinSubsistenciaMas3'].Valor__c;
        }
        this.totalGastos = parseFloat(this.impMin) + parseFloat(this.alquiler) + parseFloat(this.pension ) + parseFloat(this.otros);
        this.handleChnage(); 
    }


    changeAlquiler(event){        
        this.alquiler = event.target.value;
        if(this.alquiler == ''){
            this.alquiler = 0;
        }
        this.totalGastos = parseFloat(this.impMin) + parseFloat(this.alquiler) + parseFloat(this.pension ) + parseFloat(this.otros);
        this.handleChnage(); 
    }


    changePension(event){ 
        this.pension = event.target.value;
        if(this.pension == ''){
            this.pension = 0;
        }
        this.totalGastos = parseFloat(this.impMin) + parseFloat(this.alquiler) + parseFloat(this.pension ) + parseFloat(this.otros); 
        this.handleChnage();
    }


    changeOtros(event){ 
        this.otros = event.target.value;
        if(this.otros == ''){
            this.otros = 0;
        }
        this.totalGastos = parseFloat(this.impMin) + parseFloat(this.alquiler) + parseFloat(this.pension ) + parseFloat(this.otros); 
        this.handleChnage();
    }


    changeOtrosGastos(event){ 
        this.justificarOtros = event.target.value;
    }


    guardar(){
        this.form = [];
        if(this.miembrosUnidad == undefined){
            this.miembrosUnidad = '1';
        }
        this.form.push(this.comprobarValor(this.miembrosUnidad));
        this.form.push(this.comprobarValor(this.impMin));
        this.form.push(this.comprobarValor(this.alquiler));
        this.form.push(this.comprobarValor(this.pension));
        this.form.push(this.comprobarValor(this.otros));
        this.form.push(this.comprobarValor(this.justificarOtros));
        this.form.push(this.comprobarValor(this.totalGastos));

        // Actualizo los datos de Formulario
        updateFormulario({idFormulario: this.recordId, data: this.form}).then(result => {  
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
    // mandamos evento
    handleChnage() {
        this.valorTotalGastos =  this.totalGastos;
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("valoresgastos", {
            detail: {
               valorGastos:  this.valorTotalGastos   
            } 
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    comprobarValor(valor){
        if(valor === null || valor === undefined){
            valor= '';
        }
        valor = valor.toString();
        return valor;
      }
}