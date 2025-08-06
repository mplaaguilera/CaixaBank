import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateContactField from '@salesforce/apex/SEG_Boton_AcuseRecibo_Controller.updateContactField';

export default class seg_Boton_AcuseRecibo extends LightningElement {
  @api recordId;

  modificarAcuse() {
    updateContactField({ contactId: this.recordId })
      .then(result => {
        // Perform any necessary post-update actions
        console.log('Contact field updated successfully.');
        this.mostrarToast('success', 'Datos modificados', 'Se ha cambiado la marca de acuse de recibo correctamente.');
      })
      .catch(error => {
        // Handle any errors
        console.error('Error updating contact field:', error);
        this.mostrarToast('error', 'Error al modificar el contacto', error.body.message);
      });
  }

  mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000}));
	}
}