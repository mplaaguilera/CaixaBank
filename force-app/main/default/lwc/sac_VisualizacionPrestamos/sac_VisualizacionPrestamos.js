import { LightningElement, api, wire, track } from 'lwc';
import getPrestamosByAccountId from '@salesforce/apex/SAC_VisualizacionPrestamos.getPrestamosByAccountId';

export default class prestamoList extends LightningElement {
    @api recordId;
    prestamosRT;
    @track selectedPrestamoId;

    // Get related Préstamos
    @wire(getPrestamosByAccountId, { recId: '$recordId' })
    wiredprestamos({ error, data }) {
        if (data) {
            let hasValidation = false;
            let spinnerLoading = true;
            this.prestamosRT = Object.keys(data).map(recordTypeDevName => {
                let tableTitle;
                if (recordTypeDevName === 'SAC_Prestamo') {
                    tableTitle = 'Préstamos';
                } else if (recordTypeDevName === 'SAC_Titular_Prestamo') {
                    tableTitle = 'Titular Préstamo';
                } else if (recordTypeDevName === 'SAC_Titular_Cuenta') {
                    tableTitle = 'Titular Cuenta';
                }

                // Check validation
                const prestamos = data[recordTypeDevName].map(prestamo => {
                    if (prestamo.validation) { 
                        hasValidation = true;
                    }
                    return {
                        ...prestamo,
                    };
                });

                return {
                    tableTitle,
                    prestamoRT: recordTypeDevName === 'SAC_Prestamo',
                    titularPrestamoRT: recordTypeDevName === 'SAC_Titular_Prestamo',
                    titularCuentaRT: recordTypeDevName === 'SAC_Titular_Cuenta',
                    prestamos: prestamos
                };
            });
            spinnerLoading = false;
            // Event for validation
            const event = new CustomEvent('validationcheck', {
                detail: { hasValidation, spinnerLoading}
             });
            this.dispatchEvent(event);
        } else if (error) {
            this.prestamosRT = undefined;
        }
    }

    // Press "Desplegar" button
    toggleDetailsprestamo(event) {   
        const recId = event.currentTarget.dataset.id;
        this.prestamosRT = this.prestamosRT.map((recordType) => {
            return {
                ...recordType,
                prestamos: recordType.prestamos.map((prestamo) => {
                    if (prestamo.prestamo.Id === recId) {
                        return { ...prestamo, showDetails: !prestamo.showDetails };
                    } else {
                        return prestamo;
                    }
                })
            };
        });
    }
}