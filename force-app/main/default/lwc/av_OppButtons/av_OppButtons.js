import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getEnlaces from '@salesforce/apex/AV_OppButtons_Controller.getEnlaces';
import getArgumentario from '@salesforce/apex/AV_LinkArgumentario_Controller.getProductData';
import getAyuda from '@salesforce/apex/AV_OppButtons_Controller.getAyuda';

export default class av_OppButtons extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    @track listData;
    @track urlAyudaPEA;
    @track urlAyudaPEA2;
    @track labelAyudaPEA;
    @track labelAyudaPEA2; 
    @track showArgumentario = false;
    @track showSimulador = false;
    @track showAyudaPEA = false;
    @track showAyudaPEA2 = false;
    @track simuladores = [];
    @track showModal = false;
    @track linkOptions = [];
    @track selectedLink;
    @track singleLinkLabel = 'Simuladores';
    @track colorLink;
    @track singleLinkUrl;

    connectedCallback() {
        this.getLink();
        this.getArgInfo();
        this.prepareLinks();
    }

    navigateToWebPage(url) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: url 
            }
        }).then(url => {
            window.open(url, "_self"); 
        });
    }

    getArgInfo() {
        getArgumentario({ idOpp: this.recordId })
            .then(result => {
                this.listData = result;
                if (this.listData.AV_URLArgumentario__c != null) {
                    this.showArgumentario = true;
                }
            })
            .catch(error => {

            });
    }

    getLink() {
        getAyuda({ oppId: this.recordId, objectApiName: 'Opportunity' })
            .then(result => {
                if (result != null) {
                    if (result.pea === 'AV_PEA__c') {
                        this.showAyudaPEA = true;
                        this.labelAyudaPEA = result.labelPEA;
                        this.urlAyudaPEA = result.urlPEA != null ? result.urlPEA : null;
                    }
                    if (result.pea2 === 'AV_PEA2__c') {
                        this.showAyudaPEA2 = true;
                        this.labelAyudaPEA2 = result.labelPEA2;
                        this.urlAyudaPEA2 = result.urlPEA2 != null ? result.urlPEA2 : null;
                    }
                }
            })
            .catch(error => {
                
            });
    }

    prepareLinks() {
        getEnlaces({ oppId: this.recordId })
            .then(result => {
                let linkOptionsTemp = [];
                let singleLinkTemp = null;
                const defaultColor = "#216186";
    
                if (result.length > 1) {
                    this.showSimulador = true;
                    linkOptionsTemp = result.sort((a, b) => {
                        if (a.AV_Orden__c === null || a.AV_Orden__c === undefined) { return 1; }
                        if (b.AV_Orden__c === null || b.AV_Orden__c === undefined) { return -1; }
                        return a.AV_Orden__c - b.AV_Orden__c;
                    }).map(enlace => ({
                        label: enlace.Name,
                        value: enlace.AV_URL_PEA__c === 'URL' ? enlace.AV_URL__c : enlace.AV_PEA__c,
                        color: "background-color: " + (enlace.AV_Color__c ? enlace.AV_Color__c : defaultColor) + 
                               "; border: 1px solid white;" + 
                               (enlace.AV_URL_PEA__c === 'PEA' ? " max-width: 100%;" : "")
                    }));

                    this.colorLink = "background-color: " + defaultColor + "; border: 1px solid white;";
                } else if (result.length === 1) {
                    let enlace = result[0];
                    singleLinkTemp = {
                        url: enlace.AV_URL_PEA__c === 'URL' ? enlace.AV_URL__c : enlace.AV_PEA__c,
                        label: enlace.Name,
                        color: "background-color: " + (enlace.AV_Color__c ? enlace.AV_Color__c : defaultColor) + 
                               "; border: 1px solid white;"
                    };
                    this.showSimulador = true;
                }
    
                this.linkOptions = linkOptionsTemp;
                if (singleLinkTemp) {
                    this.singleLinkUrl = singleLinkTemp.url;
                    this.singleLinkLabel = singleLinkTemp.label;
                    this.colorLink = singleLinkTemp.color;
                }
            })
            .catch(error => {
    
            });
    }

    handleOpenLinks(event) {
        event.preventDefault();
    
        if (this.linkOptions.length > 1) {
            this.showModal = true; 
        } else if (this.linkOptions.length === 0) {
            window.location.href = this.singleLinkUrl;
        }
    }

    handleLinkChange(event) {
        this.selectedLink = event.detail.value;
    }

    handleCloseModal() {
        this.showModal = false;
        this.selectedLink = null;
    }
}