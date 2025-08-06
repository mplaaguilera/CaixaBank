import { LightningElement, api, wire, track } from 'lwc';
import cargarCopias from '@salesforce/apex/SAC_LCMP_CopiaMasivaCasos.cargarCopias';
import comprobarCOPS from '@salesforce/apex/SAC_LCMP_CopiaMasivaCasos.comprobarCOPS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Sac_CopiaMasivaCasos extends LightningElement {

    @api recordId; //Variable que contiene el id del record. Viene cargada del componente padre
    numeroCopias; //Almacenar el número de copias que el usuario quiere realizar
    spinnerLoading = false;
    pantalla1 = true;
    pantalla2 = false;
    pantalla3 = false;
    esCops = false;

    @wire(comprobarCOPS) cops({ error, data }) {
        if (data) {
            this.esCops = data;
        }
    };

    abrirSpinner() {
        this.spinnerLoading = true;
    }

    cerrarSpinner() {
        this.spinnerLoading = false;
    }

    cerrarModalPadre() {
         //Mando el valor false al componente padre para que este recoja el valor en la variable que controla el pop up
         //en el que se muestra este componente
         let dataToSend = false;

        //Custom event en el que se manda la info que queremos enviar al componente padre
        const sendDataEvent = new CustomEvent('senddata', {
            detail: {dataToSend}
        });

        //Hacemos el dispatch event del evento que hemos creado
        this.dispatchEvent(sendDataEvent);
    }

    cerrarModalPadreRefresh() {
        let refrescar = true;

       const sendDataEvent = new CustomEvent('senddata', {
           detail: {refrescar}
       });

       this.dispatchEvent(sendDataEvent);
   }

    abrirPantalla2() {
        this.abrirSpinner();
        if (this.esCops && (this.numeroCopias < 1 || this.numeroCopias > 300 || this.numeroCopias == null || this.numeroCopias == '')) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Valor incorrecto',
                message: 'Debe introducir un número entre 1 y 300',
                variant: 'warning'
            }),);
            this.cerrarSpinner();
        } else if (this.esCops == false && (this.numeroCopias < 1 || this.numeroCopias > 3 || this.numeroCopias == null || this.numeroCopias == '')) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Valor incorrecto',
                message: 'Debe introducir un número entre 1 y 3',
                variant: 'warning'
            }),);
            this.cerrarSpinner();
        } else {
            this.pantalla1 = false;
            this.pantalla2 = true;
            this.cerrarSpinner();
        }
    }

    generarCopias(evt) {
        this.abrirSpinner();
        this.pantalla2 = false;
        cargarCopias({ recordId: this.recordId, numeroCopias: this.numeroCopias })
            .then(result => {
                this.pantalla3 = true;
                this.cerrarSpinner();
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No se han podido realizar la acción',
                    message: error.body.message,
                    variant: 'error'
                }),);
                this.cerrarSpinner();
            });
    }

    handleNumberChange(evt){
        this.numeroCopias = evt.target.value;
    }
}