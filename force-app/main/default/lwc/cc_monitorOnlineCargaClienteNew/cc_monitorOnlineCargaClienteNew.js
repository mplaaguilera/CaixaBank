import { LightningElement, api, track } from 'lwc';

export default class cc_monitorOnlineCargaClienteNew extends LightningElement
{
    @api mostrarModal = false;

    abrirModal(){
        this.mostrarModal = true;
    }

    closeModal(){
        this.mostrarModal = false;
    }
}