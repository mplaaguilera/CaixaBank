import { api, track, wire, LightningElement } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import getRecord from '@salesforce/apex/CIBE_EventAttendeesController.getRecord';
import search from '@salesforce/apex/CIBE_EventAttendeesController.search';
import createAttendee from '@salesforce/apex/CIBE_EventAttendeesController.createAttendee';
import removeAttendee from '@salesforce/apex/CIBE_EventAttendeesController.removeAttendee';
import isOwner from '@salesforce/apex/CIBE_EventAttendeesController.isOwner';

import asistentes from '@salesforce/label/c.CIBE_Attendee';
import declinado from '@salesforce/label/c.CIBE_Declinado';
import aceptado from '@salesforce/label/c.CIBE_Aceptado';
import pendiente from '@salesforce/label/c.CIBE_Pendiente';
import organizador from '@salesforce/label/c.CIBE_Organizador';
import contactos from '@salesforce/label/c.CIBE_BuscarContacto';


export default class CIBE_EventAttendees extends LightningElement {

    labels = {
        asistentes,
        declinado,
        aceptado,
        pendiente,
        organizador,
        contactos

    };

    @api recordId;

    @track hasPermission = false;

    @track attendees;
    @track editMode = false;
    @track loading = false;
    
    @track initialSelection = [];
    @track errors = [];
    @track required = false;
    @track placeholder = this.labels.contactos;
    @track buscar = '';

    @track owner;
    @track declined;
    @track accepted;
    @track undecided;





    @wire(isOwner, { recordId : '$recordId'})
    isOwner({ data, error }) {
        if(data) {
            this.hasPermission = data;
        } else if(error) {
            console.log(error);
        }
    }

    @track _wiredData;
    @wire(getRecord, { recordId: '$recordId' })
    getRecordData(wiredData) {
        this._wiredData = wiredData;
        const { data, error } = wiredData;
        if(data) {
            this.attendees = JSON.parse(JSON.stringify(data));

            this.owner = this.attendees.filter((e) => e.isOwner == true);
            this.declined = this.attendees.filter((e) => e.isOwner == false && e.declined == true);
            this.accepted = this.attendees.filter((e) =>  e.isOwner == false && e.accepted == true);
            this.undecided = this.attendees.filter((e) =>  e.isOwner == false && e.undecided == true);


        }else if(error) {
            console.log(error);
        }
    };

    handleEnableEdit(event) {
        this.editMode = true;
    }

    handleDisableEdit(event) {
        this.editMode = false;
    }

    handleRemove(event) {
        const selection = event.target.dataset.id;
        if(selection) {
            this.loading = true;
            removeAttendee({ recordId : this.recordId, attendeeId : selection })
                .then((results) => {
                    refreshApex(this._wiredData).then(result => {
                        this.loading = false;
                    });
                })
                .catch((error) => {
                    console.error(error);
                });
        }
    }

    get title() {
        return this.attendees ?  this.labels.asistentes + ' (' + this.attendees.length + ')' : this.labels.asistentes;
    }

    get declinado() {
        return this.declined ?  this.labels.declinado + ' (' + this.declined.length + ')' : this.labels.declinado;
    }

    get aceptado() {
        return this.accepted ?  this.labels.aceptado + ' (' + this.accepted.length + ')' : this.labels.aceptado;
    }

    get pendiente() {
        return this.undecided ?  this.labels.pendiente + ' (' + this.undecided.length + ')' : this.labels.pendiente;
    }

    handleSearch(event) {
		search({ recordId : this.recordId, searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds })
			.then((results) => {
				this.template.querySelector('[data-id="clookup1"]').setSearchResults(results);
			})
			.catch((error) => {
                console.error(error);
				this.errors = [error];
			});
	}

	handleSelectionChange(event) {
        this.errors = [];
        let targetId = event.target.dataset.id;

        const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
        if(selection && selection.length !== 0) {
            this.loading = true;
            createAttendee({ recordId : this.recordId, contactId : selection[0].id })
                .then((results) => {
                    this.template.querySelector(`[data-id="${targetId}"]`).handleClearSelection();
                    refreshApex(this._wiredData).then(result => {
                        this.loading = false;
                    });
                })
                .catch((error) => {
                    console.error(error);
                });
        }
	}


}