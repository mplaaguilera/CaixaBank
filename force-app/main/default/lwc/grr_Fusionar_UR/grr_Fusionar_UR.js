import { LightningElement, api, wire } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { IsConsoleNavigation, getFocusedTabInfo, openTab, closeTab } from 'lightning/platformWorkspaceApi';

//Métodos Apex
import mergeUR from '@salesforce/apex/GRR_UR_Merge.fusionarUR';

//Campos UR
import UR_ID from '@salesforce/schema/GRR_UR__c.Id';
import UR_NAME from '@salesforce/schema/GRR_UR__c.Name';


const FIELDS_UR = [UR_ID, UR_NAME];


export default class grr_Fusionar_UR extends NavigationMixin(LightningElement) {
	@api recordId;
	ur;

    @wire(IsConsoleNavigation) isConsoleNavigation;
	
	@wire(getRecord, { recordId: '$recordId', fields: FIELDS_UR })
    wiredUR({ error, data }) {
        if (data) {
            this.ur = data; 
        } else if (error) {
            let mensajeError;
			if (Array.isArray(error.body)) {
				mensajeError = error.body.map(e => e.message).join(', ');
			} else if (typeof error.body.message === 'string') {
				mensajeError = error.body.message;
			}
			this.mostrarToast('error', 'Problema recuperando los datos de la UR', mensajeError);
        }
    }

	async openTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
        await openTab({
            pageReference: {
                type: 'standard__recordPage',
                attributes: {
					recordId: this.template.querySelector('[data-id="urRelacionada"]').value,
                    objectApiName: 'GRR_UR__c',
                    actionName: 'view'
                },
				state: {
					fv0:this.recordId
				}
            },
            focus: true
        });
    }

	async closeTab() {
		if (!this.isConsoleNavigation) {
			return;
		}
		const focusedTabInfo = await getFocusedTabInfo();
		const tabId = focusedTabInfo.tabId;
		await closeTab(tabId);
	}

	mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}

    modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
            this.closeModals();
		}
	}

	closeModals() {
		this.template.querySelectorAll('.slds-modal').forEach(modal => modal.classList.remove('slds-fade-in-open'));
		this.template.querySelector('.backdropModales').classList.remove('slds-backdrop_open');
	}

	handleBotonFusionar() {
		this.modalFusionarUR();
	}

	modalFusionarUR() {
		this.template.querySelector('.modalFusionar').classList.add('slds-fade-in-open');
		this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
		this.template.querySelector('.modalFusionarCancelar').focus();
	}

	handleFusionarUR() {
		this.idNuevaUR = this.template.querySelector('[data-id="urRelacionada"]').value;
		if (this.idNuevaUR === this.recordId) {
			this.mostrarToast('error', 'Problema fusionando las URs', 'Las URs origen y destino de la fusión deben ser distintos');
		} else {
			mergeUR({masterURId: this.recordId, idURSelected: this.idNuevaUR})
			.then(() => {
				this.mostrarToast('success', 'Se han fusionado las URs', 'Se han fusionado las URs correctamente');
				this.openTab();
				this.closeTab();
			}).catch(error => {
				console.error(error);
				this.mostrarToast('error', 'Problema fusionando las URs');
			})
		}
	}

}