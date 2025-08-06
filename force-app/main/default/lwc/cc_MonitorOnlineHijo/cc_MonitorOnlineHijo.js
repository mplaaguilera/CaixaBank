import { LightningElement, api, track, wire } from 'lwc';
import cargarDatos from '@salesforce/apex/CC_MonitorOnlineMethods.getData';
import filtrarDatos from '@salesforce/apex/CC_MonitorOnlineMethods.busquedaFiltrada';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columns = [
    { label: 'Fecha', fieldName: 'fecha', type: 'date' },
    { label: 'Franja horaria', fieldName: 'franjaHoraria', type: 'text' },
    { label: 'Proveedor', fieldName: 'proveedor', type: 'text' },
    // { label: 'Tipo Previsión', fieldName: 'tipoPrev', type: 'text' },
    { label: 'Número Previsiones', fieldName: 'prevision', type: 'text' },
    { label: 'Usuarios Disponibles', fieldName: 'agentesDisponibles', type: 'text' },
    { label: 'Usuarios No Disponibles', fieldName: 'agentesNoDisponibles', type: 'text' },
    { label: 'Real', fieldName: 'real', type: 'text' },
    { label: 'Diferencia', fieldName: 'calculo', type: 'text' }
];

const columnsChats = [
    { label: 'Fecha', fieldName: 'fecha', type: 'date' },
    { label: 'Franja horaria', fieldName: 'franjaHoraria', type: 'text' },
    { label: 'Proveedor', fieldName: 'proveedor', type: 'text' },
    { label: 'Servicio', fieldName: 'servicio', type: 'text' },
    // { label: 'Tipo Previsión', fieldName: 'tipoPrev', type: 'text' },
    { label: 'Número Previsiones', fieldName: 'prevision', type: 'text' },
    { label: 'Chat Atendidos', fieldName: 'chatAtendidos', type: 'text' },
    { label: 'Chats No Atendidos', fieldName: 'chatsNoAtendidos', type: 'text' },
    { label: 'Chat Entrantes', fieldName: 'real', type: 'text' },
    { label: 'Diferencia', fieldName: 'calculo', type: 'text' }
];

const data = [];
const data2 = [];

export default class cc_MonitorOnlineHijo extends LightningElement {
    @api parametro;
    @api refresco;
    @api refresco2;
    @api spinnerLoading = false;
    @track franjaSeleccionada;
    @track franjaPorDefecto;
    @track contactoSeleccionado;
    @track proveedoresSeleccionado;
    @track servicioSeleccionado;
    data = [];
    data2 = [];
    columns = columns;
    columnsChats = columnsChats;
    optionsFH = [];
    optionsPro = [];
    optionsPre = [];
    optionsServ = [];


    connectedCallback(){
        //do something
        //cargarDatos({recTypeDevName: this.parametro})
        cargarDatos()
        .then(result => {            
            this.data = result.previsionData;
            this.data2 = result.previsionDataChats;
            this.optionsFH = result.pickListEntries;
            this.optionsPro = result.pickListEntriesPro;
            this.optionsPre = result.pickListEntriesPre;
            this.optionsServ = result.pickListEntriesServ;
            if(result.previsionData){
                this.franjaPorDefecto = result.previsionData[0].franjaHoraria;
                //this.franjaSeleccionada = this.franjaPorDefecto;
            }
            const dateObject = new Date(result.hora);
            const options = { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' };
            this.refresco = dateObject.toLocaleString(undefined, options);
            this.refresco2 = dateObject.toLocaleString(undefined, options);
            /*console.log(JSON.stringify(result.previsionData));
            console.log(JSON.stringify(result.previsionDataChats));*/
        })
        .catch(error => { 
            console.log(JSON.stringify(error));
        });
   }

   /*getSelectedName(event) {
       const selectedRows = event.detail.selectedRows;
       // Display that fieldName of the selected rows
       for (let i = 0; i < selectedRows.length; i++) {
            alert('You selected: ' + selectedRows[i].CC_Proveedor__c);
        }
    }*/
    recuperarClickChat(){
        this.recuperarClick('CC_Chats');
    }
    recuperarClickAgente(){
        this.recuperarClick('CC_Agentes');
    }

    recuperarClick(tabla){
        this.spinnerLoading = true;
        if(this.franjaSeleccionada === undefined){
            this.franjaSeleccionada = this.franjaPorDefecto;
        }
       // filtrarDatos({recTypeDevName: this.parametro, franjaHoraria: this.franjaSeleccionada, proveedores: this.proveedoresSeleccionado, tipoContacto: this.contactoSeleccionado})
       filtrarDatos({franjaHoraria: this.franjaSeleccionada, proveedores: this.proveedoresSeleccionado, tipoContacto: this.contactoSeleccionado, servicios: this.servicioSeleccionado, tablaSeleccionada: tabla})
        .then(result => {
            this.data = result.previsionData || this.data;
            this.data2 = result.previsionDataChats || this.data2;
            const dateObject = new Date(result.hora);
            const options = { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' };
            if(tabla === 'CC_Agentes'){
                this.refresco = dateObject.toLocaleString(undefined, options);
            }else {
                this.refresco2 = dateObject.toLocaleString(undefined, options);
            }            
            console.log(JSON.stringify(result.previsionData));
            console.log(JSON.stringify(result.previsionDataChats));
            this.spinnerLoading = false; 
            this.dispatchEvent(new ShowToastEvent({
                title: 'Tabla refrescada',
                message: 'Los datos han sido actualizados',
                variant: 'success'
            }),);
        })
        .catch(error => { 
            this.spinnerLoading = false;
            console.log(JSON.stringify(error));
        });
    }


    eventProveedores(event){
        this.proveedoresSeleccionado = event.detail;
    }

    eventTipo(event){
        this.contactoSeleccionado = event.detail;
    }

    eventFranja(event){
        this.franjaSeleccionada = event.detail;
    }

    eventServicio(event){
        this.servicioSeleccionado = event.detail;
    }

}