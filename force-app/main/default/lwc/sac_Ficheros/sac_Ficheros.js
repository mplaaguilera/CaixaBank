import { LightningElement, api, wire, track } from 'lwc';
import getFicherosByAccountId from '@salesforce/apex/SAC_FicheroController.getFicherosByAccountId';
import rejectReclamacion from '@salesforce/apex/SAC_FicheroController.rejectReclamacion';
import getRecStatus from '@salesforce/apex/SAC_FicheroController.getRecStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';

export default class FicheroList extends LightningElement {
    @api recordId;
    ficherosRT;
    showRejectButton = false;
    @track selectedFicheroId;
    recStatus;

    // Get related Ficheros
    @wire(getFicherosByAccountId, { recId: '$recordId' })
    wiredFicheros({ error, data }) {
        if (data) {
            this.ficherosRT = Object.keys(data).map(recordTypeDevName => {
                let tableTitle;
                if (recordTypeDevName === 'SAC_Prestamo') {
                    tableTitle = 'Préstamos';
                } else if (recordTypeDevName === 'SAC_Titular_Prestamo') {
                    tableTitle = 'Titular Préstamo';
                } else if (recordTypeDevName === 'SAC_Titular_Cuenta') {
                    tableTitle = 'Titular Cuenta';
                }
                return {
                    tableTitle,
                    prestamoRT: recordTypeDevName === 'SAC_Prestamo',
                    titularPrestamoRT: recordTypeDevName === 'SAC_Titular_Prestamo',
                    titularCuentaRT: recordTypeDevName === 'SAC_Titular_Cuenta',
                    ficheros: data[recordTypeDevName].map(fichero => {
                        //Check validation is not empty and status
                        if (fichero.validation && this.recStatus != 'Rechazado') { 
                            this.showRejectButton = true;
                        }
                        return {
                            ...fichero,
                        };
                    })
                };
            });
        } else if (error) {
            this.ficherosRT = undefined;
        }
    }
    // Press "Desplegar" button
    toggleDetailsFichero(event) {   
        const recId = event.currentTarget.dataset.id;
        this.ficherosRT = this.ficherosRT.map((recordType) => {
            return {
                ...recordType,
                ficheros: recordType.ficheros.map((fichero) => {
                    if (fichero.fichero.Id === recId) {
                        return { ...fichero, showDetails: !fichero.showDetails };
                    } else {
                        return fichero;
                    }
                })
            };
        });
    }
    // Reject Reclamación
    handleRejectClick() {
        rejectReclamacion({ recId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'La reclamación se ha rechazado correctamente',
                        variant: 'success',
                    }),
                );
                this.dispatchEvent(new RefreshEvent());
                this.showRejectButton = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No se ha podido rechazar la reclamación',
                        variant: 'error',
                        messageData: [error.body.message],
                    }),
                );
            });
    }
    // Get the Status of the Reclamación
    @wire(getRecStatus, { recId: '$recordId' })
    wiredCaseStatus({ error, data }) {
        if (data) {
            this.recStatus = data;
        } else if (error) {
            console.error('Error retrieving Rec Status:', error);
        }
    }
}