/**
 *  Name: Ev_ButtomImportMassEvent
 *  Copyright © 2024  CaixaBank
 * ----------------------------------------------------------------------------------------------------------------------
 * Historial
 * ----------------------------------------------------------------------------------------------------------------------
 *  VERSION         AUTHOR             USER_STORY               DATE               Description
 *   1.0            Carolina Lopez     FIX                      22/04/2024         Logic included NavigationMixin in handleButtonClick.
 **/
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTraducciones from '@salesforce/apex/EV_ImportMassEvent_Controller.getTraducciones';

export default class Ev_ButtomImportMassEvent extends NavigationMixin(LightningElement) {
    @api recordId;
    translationsExist = false;

    checkTranslations(Event) {
        getTraducciones({ recordId: this.recordId })
            .then(result => {
                this.translationsExist = result;
                if (!this.translationsExist) {
                    this.showMissingTranslationsToast();
                }
                else{
                    this.handleButtonClick();
                }
            })
            .catch(error => {
                console.log('@@entro en error ' + error);
                this.showMissingErrorToast();
            });
    }
    showMissingTranslationsToast() {
        const event = new ShowToastEvent({
            title: 'Traducciones o encuesta en catálogo faltantes',
            message: 'Por favor, rellene el campo "Encuesta asociada" o complete las traducciones del catálogo en los idiomas castellano y catalán para poder continuar.',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

    showMissingErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Se ha producido un error, por favor, contacte con su administrador',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

    handleButtonClick(event) {
        console.log('@@handleButtonClick ' + this.recordId);
        let cmpDef ={
            componentDef: "c:Ev_lwc_ImportMassEvent",
            attributes: {
                c__recordId: this.recordId
            }
        };
        let encodedDef = btoa(JSON.stringify(cmpDef));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedDef
            }
        });
    }
}