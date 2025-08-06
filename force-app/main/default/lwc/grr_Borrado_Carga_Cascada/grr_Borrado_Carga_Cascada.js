import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import currentUserId from '@salesforce/user/Id';

//Métodos Apex
import eliminarCarga from '@salesforce/apex/GRR_Borrado_Carga_Cascada.eliminarCarga'; 

//Campos Carga
import CARGA_ID from '@salesforce/schema/GRR_Carga__c.Id';
import CARGA_OWNER_ID from '@salesforce/schema/GRR_Carga__c.OwnerId';

const FIELDS_CARGA = [CARGA_ID,CARGA_OWNER_ID]; 

export default class grr_Borrado_Carga_Cascada extends LightningElement {
    @api recordId;
    carga;
    datosCargados = false;

    get esPropietario() {
		return currentUserId === getFieldValue(this.carga, CARGA_OWNER_ID);
	}

    get BorradoDisabled() {
		return !this.esPropietario;
	}

    @wire(IsConsoleNavigation) isConsoleNavigation;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS_CARGA })
    wiredCaso({ error, data }) {
        if (data) {
            this.carga = data; 
            this.datosCargados = true;
        } else if (error) {
            let mensajeError;
			if (Array.isArray(error.body)) {
				mensajeError = error.body.map(e => e.message).join(', ');
			} else if (typeof error.body.message === 'string') {
				mensajeError = error.body.message;
			}
			this.mostrarToast('error', 'Problema recuperando los datos de la carga', mensajeError); 
        }
    }

    modalBorradoAbrir() {
        this.template.querySelector('.modalBorrado').classList.add('slds-fade-in-open');
        this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
        this.template.querySelector('.modalBorradoCancelar').focus();
	}

    modalBorradoConfirmado() {
		this.template.querySelector('.modalBorradoConfirmar').disabled = true;
        eliminarCarga({idCarga: this.recordId})
        .then(() => {
            this.closeModals();
			this.mostrarToast('success', 'Se ha eliminado la carga', 'Se ha eliminado la carga correctamente', 'dismissible');
            this.closeTab();
		}).catch(error => {
            this.closeModals();
			console.error(error);
            this.mostrarToast('error', 'Problema eliminando la carga', error.body.message, 'sticky');
		})
	}

    modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.closeModals();
		}
	}

    closeModals() {
		this.template.querySelectorAll('.slds-modal').forEach(modal => modal.classList.remove('slds-fade-in-open'));
		this.template.querySelector('.backdropModales').classList.remove('slds-backdrop_open');
        this.template.querySelector('.modalBorradoConfirmar').disabled = false;
	}

    mostrarToast(tipo, titulo, mensaje, modo) {
        const eventoToast = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: tipo,
            mode: modo
        });
        this.dispatchEvent(eventoToast);
    }

    async closeTab() {
		if (!this.isConsoleNavigation) {
			return;
		}
		const focusedTabInfo = await getFocusedTabInfo();
		const tabId = focusedTabInfo.tabId;
		await closeTab(tabId);
	}

}