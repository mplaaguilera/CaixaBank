import { api, LightningElement, track} from 'lwc';
import getPicklistValues from '@salesforce/apex/CIBE_CallReportCountry.getPicklistValues';
import getRecordValue from '@salesforce/apex/CIBE_CallReportCountry.updateRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import detalleTitle from '@salesforce/label/c.CIBE_DetalleTitle';
import reportCountry from '@salesforce/label/c.CIBE_ReportCountry';

export default class Cibe_EventCallReportCountry extends LightningElement {
    labels = {
        detalleTitle,
        reportCountry
    }

    @api recordId;
    @track vCountry = '';
    @track isExpanded = true;
    @track selectedValue = ''; 
    @track picklistOptions = []; 
    @track isEditing = false;
    @track hasChanges = false;

    fetchPicklistValues() {
        getPicklistValues({fieldName: 'CIBE_Country__c' })
            .then(data => {
                this.picklistOptions = data.map(value => ({
                    label: value,
                    value: value
                }));
            })
            .catch(error => {
                // CBK_Log.error(error, 'Se ha producido un error al intentar recuperar la lista.');
                console.log(error, 'Se ha producido un error al intentar recuperar la lista.');
                
            });
    }

    fetchCountryField() {
        if (!this.recordId) {
            return;
        }

        getRecordValue({ recordId: this.recordId, newCountryValue: null, 
            shouldUpdate: this.hasChanges })
            .then(result => {
                this.vCountry = result.CIBE_Country__c;
                this.selectedValue = this.vCountry;
            })
            .catch(error => {
                // CBK_Log.error(error, 'Se ha producido un error al intentar recuperar el registro.');
                console.log(error, 'Se ha producido un error al intentar recuperar la lista.');

            });
    }

    connectedCallback() {
        this.fetchCountryField();
        this.fetchPicklistValues();
    }


    toggleEdit() {
        this.isEditing = !this.isEditing;
        if (this.isEditing) {
            this.selectedValue = this.vCountry;
        }
    }

    cancel() {
        this.isEditing = false;
        this.selectedValue = this.vCountry;
    }

    handlePicklistChange(event) {
        this.selectedValue = event.detail.value;
        this.hasChanges = true;
    }

    save() {
        if (!this.recordId) {
            this.showToast('Error No recordId provided', 'error');
            return;
        }

        getRecordValue({ 
            recordId: this.recordId, 
            newCountryValue: this.selectedValue, 
            shouldUpdate: this.hasChanges
        })

        .then(result => {
            this.vCountry = this.selectedValue; 
            this.isEditing = false;
            this.hasChanges = false; 
            this.showToast('Success', 'Se ha actualizado con éxito', 'success');
        })
        .catch(error => {
            this.showToast('Error al guardar', error.body.message, 'error');
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    get iconName() {
        return this.isExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }
    toggleSection() {
        this.isExpanded = !this.isExpanded;
    }
}