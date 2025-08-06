import { LightningElement, api } from 'lwc';
import getURLs from '@salesforce/apex/AV_peaLink_Controller.getURLs';
import getCurrentPEA from '@salesforce/apex/AV_peaLink_Controller.getCurrentPEA';
import updateSimulador from '@salesforce/apex/AV_peaLink_Controller.updateSimulador';

export default class Av_peaLink extends LightningElement {
    urlOptions = [];
    selectedUrl;
    @api recordId; 
    @api setting;

    connectedCallback() {
        this.getURLsPEA();
    }

    getURLsPEA() {
        getURLs({ setting: this.setting })
        .then(result => {
            if (result) {
                this.urlOptions = result.map(item => {
                    return { label: item.label, value: item.url };
                });
                this.loadCurrentPEA();
            }
        })
        .catch(error => {
            console.error('Error retrieving URLs:', error);
        });
    }

    loadCurrentPEA() {
        getCurrentPEA({ recordId: this.recordId })
            .then(result => {
                if (result) {
                    this.selectedUrl = result;
                }
            })
            .catch(error => {
                console.error('Error loading current PEA:', error);
            });
    }

    handleChange(event) {
        this.selectedUrl = event.detail.value;
        updateSimulador({ recordId: this.recordId, selectedUrl: this.selectedUrl })
            .catch(error => {
                console.error('Error updating simulador:', error);
            });
    }
}