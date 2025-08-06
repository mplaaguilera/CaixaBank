import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import conseguirCaracteristicaContacto from '@salesforce/apex/HDT_Caracteristicas_Controller.conseguirCaracteristicaContactoLlamada';

export default class Hdt_MostrarToast_Activos_Caso extends LightningElement {

    // Método para el botón "Continuar"
    handleContinue() {
        this.showToast('Advertencia', 'Has decidido continuar aunque el activo está inactivo.', 'warning');
        // Aquí puedes implementar la lógica adicional si se selecciona continuar
    }

     // Método para el botón "Cancelar"
     handleCancel() {
        this.showToast('Información', 'Has cancelado la operación.', 'info');
        // Aquí puedes agregar lógica adicional para cancelar la operación
    }

    // Método para mostrar el Toast
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
        
}