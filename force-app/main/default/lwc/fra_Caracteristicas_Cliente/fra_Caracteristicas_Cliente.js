import { LightningElement, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { RefreshEvent } from 'lightning/refresh';
import LightningConfirm from 'lightning/confirm';
import { refreshApex } from '@salesforce/apex';
import getCaracteristicas from '@salesforce/apex/FRA_Caracteristicas_Controller.conseguirCaracteristicaCuenta'
import getCaracteristicasFRADeCuenta from '@salesforce/apex/FRA_Caracteristicas_Controller.conseguirCaracteristicasFRADeCuenta';
import asociarCaracteristicaACuenta from '@salesforce/apex/FRA_Caracteristicas_Controller.asociarCaracteristicaCuenta';

export default class Fra_Caracteristicas_Cliente extends LightningElement  {
    @api recordId;

    caracteristicasFRA = []; 
    mostrarComboBox = false;
    selectedCaracteristicaId;  

    @wire(getCaracteristicas,{idCaso: '$recordId'}) ccaracteristics;

    @wire(getCaracteristicasFRADeCuenta)
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

    handleSeleccionar(event) {
        const selectedValue = event.detail.value;

        if (selectedValue === 'add') {
            this.mostrarComboBox = !this.mostrarComboBox;
        }
    }

    handleComboboxChange(event) {
        const selectedValue = event.detail.value;
        this.selectedCaracteristicaId = selectedValue;  

        if (selectedValue) {
            this.asociarCaracteristica(selectedValue);
            this.mostrarComboBox = false;
        }
    }

    asociarCaracteristica(idCaracteristica) {
        LightningConfirm.open({
            message: '¿Estás seguro de asociar esta característica al Cliente?',
            label: 'Confirmar Asociación',
            theme: 'warning'
        }).then((userConfirmed) => {
            if (userConfirmed) {
                asociarCaracteristicaACuenta({ idCaso: this.recordId, idCaracteristica })
                    .then(() => {
                        refreshApex(this.ccaracteristics);
                        this.dispatchEvent(new RefreshEvent());
                    })
                    .catch(error => {
                    });
            }
        }).catch((error) => {
        });
    }
        
}