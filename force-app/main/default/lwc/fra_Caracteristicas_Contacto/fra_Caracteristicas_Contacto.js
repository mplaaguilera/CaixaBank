import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from '@salesforce/apex';
import getCaracteristicas from '@salesforce/apex/FRA_Caracteristicas_Controller.conseguirCaracteristicaContactoCaso';
import getCaracteristicasFRADeContacto from '@salesforce/apex/FRA_Caracteristicas_Controller.conseguirCaracteristicasFRADeContacto';
import asociarCaracteristicaAContacto from '@salesforce/apex/FRA_Caracteristicas_Controller.asociarCaracteristicaContacto';

export default class Fra_Caracteristicas_Contacto extends LightningElement {
    @api recordId; // ID del registro actual
    
    caracteristicasFRA = []; // Lista de características FRA
    mostrarComboBox = false; // Control para mostrar/ocultar el combobox
    selectedCaracteristicaId; // ID de la característica seleccionada

    // Wire para obtener características asociadas al caso
    @wire(getCaracteristicas, { idCaso: '$recordId' }) ccaracteristics;

    // Wire para obtener todas las características FRA disponibles
    @wire(getCaracteristicasFRADeContacto)
    wiredCaracteristicasFRA({ data, error }) {
        if (data) {
            this.caracteristicasFRA = data.map(caracteristica => ({
                label: caracteristica.Name,
                value: caracteristica.Id
            }));
        } 
    }

    navigateToCaracteristica(event) {
        var oId = event.target.dataset.key;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: oId,
                actionName: 'view'
            }
        });
    }

    // Manejar la selección en el menú
    handleSeleccionar(event) {
        const selectedValue = event.detail.value;

        // Mostrar combobox si el usuario selecciona "add"
        if (selectedValue === 'add') {
            this.mostrarComboBox = !this.mostrarComboBox;
        }
    }

    // Manejar cambios en el combobox
    handleComboboxChange(event) {
        const selectedValue = event.detail.value;
        this.selectedCaracteristicaId = selectedValue;

        // Asociar característica si se selecciona una
        if (selectedValue) {
            this.asociarCaracteristica(selectedValue);
            this.mostrarComboBox = false;
        }
    }

    // Llamada al método Apex para asociar la característica
    asociarCaracteristica(idCaracteristica) {
        asociarCaracteristicaAContacto({ idCaso: this.recordId, idCaracteristica })
            .then(() => {
                // Disparar el RefreshEvent para recargar datos en la página
                refreshApex(this.ccaracteristics);
                this.dispatchEvent(new RefreshEvent());
            })
            .catch(error => {
            });
    }
}