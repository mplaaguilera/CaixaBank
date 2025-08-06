import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { log } from 'lightning/logger';
import AV_CMP_ErrorMessage from '@salesforce/label/c.AV_CMP_ErrorMessage';
import getLinks from '@salesforce/apex/AV_LinkOperativoController.getLinks';
import getIdFilterObject from '@salesforce/apex/AV_SObjectRelatedInfoCController.getIdFilterObject';

export default class AV_TFButtons extends LightningElement {
    @api title;
    @api icon;
    @api setting;
    @api description;
    @api objectApiName;
    @api recordId;
    @api filterField;
    @api filterObject;
    @track hasLinks = false;
    @track listData;

    @wire(getIdFilterObject, { recordId: '$recordId', objectApiName: '$objectApiName', objectFilter: '$filterObject', filterField: '$filterField' })
    wiredObject({ error, data }) {
        if (data) {
            var result = JSON.parse(JSON.stringify(data));
            getLinks({ seccion: this.objectApiName, filterObject: this.filterObject, customerId: result, parentId: this.recordId, setting: this.setting })
                .then(result => {
                    this.hasLinks = true;
                    this.processedListData(result);
                })
                .catch(error => {
                    this.handleError(error);
                });
        } else if (error) {
            this.handleError(error);
        }
    }

    processedListData(linksData) {
        this.listData = linksData.map(section => ({
            ...section,
            links: section.links.map(link => ({
                ...link,
                class: link.label === 'Mis Clientes' ? 'select' : 'nonselect',
            }))
        }));
    }
    
    handleLinkClick(event) {
        event.preventDefault();
        const linkName = event.target.title;
        const href = event.target.href;

        this.logLinkClick(linkName)
            .then(() => {
                window.location.href = href;
            })
            .catch(error => {
                console.error('Error logging link click:', error);
            });
    }

    logLinkClick(linkName) {
        return new Promise((resolve, reject) => {
            let msg = {
                identifier: 'Tab selection',
                message: 'Click in TF9 tab ' + this.removeAccents(linkName)
            }

            try {
                log(msg);
                resolve();
            } catch (error) {
                reject(error);
            }
        });
    }

    removeAccents(text) {
        const withAccents = 'áéíóúÁÉÍÓÚüÜñÑ';
        const withoutAccents = 'aeiouAEIOUuUnN';
    
        return text.replace(/[áéíóúÁÉÍÓÚüÜñÑ]/g, match => 
            withoutAccents[withAccents.indexOf(match)]
        );
    }

    handleError(error) {
        const evt = new ShowToastEvent({
            title: AV_CMP_ErrorMessage,
            message: JSON.stringify(error),
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }
}