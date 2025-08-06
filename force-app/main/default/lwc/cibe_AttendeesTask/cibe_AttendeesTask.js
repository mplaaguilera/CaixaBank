import { LightningElement, api, wire, track } from 'lwc';

import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getAttendees from '@salesforce/apex/CIBE_AttendeesTask_Controller.getAttendees';
import createAttendees from '@salesforce/apex/CIBE_AttendeesTask_Controller.createAttendees';
import deleteAttendees from '@salesforce/apex/CIBE_AttendeesTask_Controller.deleteAttendees';
import lookupSearchUser from '@salesforce/apex/CIBE_AttendeesTask_Controller.searchUser';

//Labels 

import participantes from '@salesforce/label/c.CIBE_Participantes';
import anadeParticipantesTarea from '@salesforce/label/c.CIBE_AnadeParticipantesTarea';
import anadir from '@salesforce/label/c.CIBE_Anadir';
import cargando from '@salesforce/label/c.CIBE_Cargando';
import participante from '@salesforce/label/c.CIBE_participante';

export default class Cibe_AttendeesTask extends NavigationMixin(LightningElement) {
    labels = {
        participantes,
        anadeParticipantesTarea,
        anadir,
        cargando,
        participante
    };
    @api recordId;
    @track attendees;

    @track loading = true;

    @track initialSelection = [];
    @track selected;
	@track errors = [];

    @track _wiredData;
    @wire(getAttendees, { recordId : '$recordId' })
    getAttendees(wireResult) {
        const { error, data } = wireResult;
        this._wiredData = wireResult;
        if (data) {
            this.attendees = data;
            this.loading = false;
        } else if (error) {
            console.log(error);
        }
    }

    handleClick(event) {
        event.preventDefault();
        const contactId = event.target.dataset.contact;
        if(contactId != null && contactId != "") {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: contactId,
                    objectApiName: 'Contact',
                    actionName: 'view'
                }
            });
        }
    } 

    handleRemove(event) {
        event.preventDefault();
        this.loading = true;
        deleteAttendees({ recordId : event.detail.name })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Participante eliminado.',
                        message: 'El participante se ha eliminado de la tarea correctamente.',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error eliminando el participante',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            }).finally(() => {
                refreshApex(this._wiredData);
            });
    }

    handleSearch(event) {
		lookupSearchUser(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup"]').setSearchResults(results);
			}).catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

    handleSelectionChange(event) {
        const selection = this.template.querySelector('[data-id="clookup"]').getSelection();
        if(selection.length !== 0){
            for(let sel of selection) {
                this.selected = String(sel.id);
            }
        }
	}

    handleSave(event) {
        if(this.selected != null) {
            this.loading = true;
            createAttendees({ recordId : this.recordId, relationId : this.selected })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Participante creado.',
                            message: 'El participante se ha añadido correctamente.',
                            variant: 'success'
                        })
                    );
                    refreshApex(this._wiredData);
                })
                .catch(error => {
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creando el participante',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                }).finally(() => {
                    this.selected = null;
                    this.template.querySelector('[data-id="clookup"]').handleClearSelection();
                    this.loading = false;
                });
        }
    }

}