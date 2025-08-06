import { LightningElement, api, track } from 'lwc';

import getClientComments from '@salesforce/apex/AV_ClientCommentsController.getClientComments';

import noDataFoundLabel from '@salesforce/label/c.AV_CMP_NoDataFound';
 
export default class Av_ClientComments extends LightningElement {
    @api recordId;

    @track lstComments;
    @track lstAllComments;
    @track showAll = false;
    @track loading = false;
    @track refreshIco = false;

    doneTypingInterval = 900;
    typingTimer;
    showResults = false;
    nestedMap = [];
    filterValue;
    label = {
        noDataFoundLabel
    }

    connectedCallback() {
        this.toggleSpinner();
        this.getClientComments();
    }

    refresh() {
        this.toggleSpinner();
        this.refreshIco=true;
        this.getClientComments();
    }

    getClientComments() {
        getClientComments({ accId: this.recordId , filter: this.filterValue })
            .then(result => {

                if(result != null) {
                    this.nestedMap = [];
                    for (var key in result) {
                            this.nestedMap.push({ key: key, value: result[key] })
                    }

                    if(this.nestedMap.length > 0){
                        this.showResults = true;
                    }
                   
                }
                this.toggleSpinner();
                this.refreshIco=false;
            })
            .catch(error => {
                this.toggleSpinner();
            });
    }

    toggleShowAll() {
        this.toggleSpinner();
        this.showAll = !this.showAll;
        this.toggleSpinner();
    }

    toggleSpinner() {
        this.loading = !this.loading;
    }

    handleFilterValue(event){

        this.filterValue = event.target.value;
        this.nestedMap = null;

        this.typingTimer = setTimeout(() => {
                getClientComments({accId: this.recordId, filter: this.filterValue})
                .then(result => {
                    if(result != null) {
    
                        this.nestedMap = [];

                        for (var key in result) {
                                this.nestedMap.push({ key: key, value: result[key] })
                        }
    
                        if(this.nestedMap.length > 0){
                            this.showResults = true;
                        }
    
                    }
                    this.refreshIco=false;
                })
               
        }, this.doneTypingInterval);

    }

}