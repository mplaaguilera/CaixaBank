/**
 *  Name: Ev_lwc_CampaignStatistics
 *  Copyright © 2024  CaixaBank
 * ----------------------------------------------------------------------------------------------------------------------
 * Historial
 * ----------------------------------------------------------------------------------------------------------------------
 *  VERSION         AUTHOR             USER_STORY               DATE               Description
 *   1.0            Carolina Lopez     CampaignStatistics       29/02/2024         Init version
 *   1.1            Carolina Lopez     TechSummit               14/05/2024         Include RecordTypes TechSummit.
 *   1.2            Carolina Lopez     Fix                      09/07/2024         Delete the field EV_TotalRegistrosConfirmadosC__c, include the fields EV_AsistioEnDiferido and EV_NumberOfAccounts.
 **/
import { LightningElement, wire, api, track } from 'lwc';
import campaignObj from '@salesforce/schema/Campaign';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getFieldCampaign from '@salesforce/apex/EV_CampaignStatisticsController.getCampaignStatistics';

const accionistaEvt = 'EV_Eventos_Accionistas'; 
const hibridoEvt = 'EV_EventoHibrido'; 
const virtualEvt = 'EV_EventoVirtual'; 
const fisicoEvt = 'EV_EventoFisico'; 
const festivalesEvt = 'EV_FestivalesYexperiencias';
const hibridoEvtTech = 'EV_TechSummitHibrido';
const virtualEvtTech = 'EV_TechSummitVirtual';
const fisicoEvtTech = 'EV_TechSummitFisico'; 

export default class Ev_lwc_CampaignStatistics extends LightningElement {
    @track isSpanish = false;
    @track isExpanded = true;
    @api recordId;
    //Campos filtrado
    @track newArch;
    @track tipoEvento;
    fisFesti = false;
    virtual = false;
    hibAcc = false;
    //Campos comunes estandar
    @track numLeads = 0;
    @track numContacts = 0;
    //Antigua arquitectura
    @track totalInscritos = 0;
    @track totalAsistentes= 0;
    @track asistentesFisicos= 0;
    @track asistDiferido = 0;
    @track numAccounts = 0;
    @track inscritosVirtuales= 0;
    @track asistentesVirtuales= 0;
    @track inscritosFisicos= 0;
    @track inscritosFisVir= 0;
    //label
    totalInscritosLabel = '';
    totalAsistentesLabel = '';
    asistentesFisicosLabel = '';
    asistDiferidoLabel = '';
    numAccountLabel = '';
    inscritosVirtualesLabel = '';
    asistentesVirtualesLabel = '';
    inscritosFisicosLabel = '';
    inscritosFisVirLabel = '';
    numLeadsLabel = '';
    numContactsLabel = '';

    @wire(getObjectInfo, { objectApiName: campaignObj })
    oppInfo({ data, error }) {
        if(data){
            this.totalInscritosLabel = data.fields.EV_TotalInscritos__c.label;
            this.totalAsistentesLabel = data.fields.EV_TotalAsistentes__c.label;
            this.asistentesFisicosLabel = data.fields.EV_asistentesFisicos__c.label;
            this.asistDiferidoLabel = data.fields.EV_AsistioEnDiferido__c.label;
            this.inscritosVirtualesLabel = data.fields.EV_inscritosVirtuales__c.label;
            this.asistentesVirtualesLabel = data.fields.EV_asistentesVirtuales__c.label;
            this.inscritosFisicosLabel = data.fields.EV_inscritosFisicos__c.label;
            this.inscritosFisVirLabel = data.fields.EV_inscritosFisicosVirtuales__c.label;
            this.numLeadsLabel = data.fields.EV_NumberOfLeads__c.label;
            this.numContactsLabel = data.fields.EV_NumberOfContacts__c.label;
            this.numAccountLabel = data.fields.EV_NumberOfAccounts__c.label;
            if(this.numContactsLabel.includes('campaña')){
                this.isSpanish = true;
            }else{
                this.isSpanish = false;
            }
        }else if(error){
            console.error('Ocurrió un error al procesar la información: ', error);
        }
    }
    connectedCallback(){
        this.handleGetCampaign();
    }
    get iconName() {
        return this.isExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }
    toggleSection() {
        this.isExpanded = !this.isExpanded;
    }
    handleGetCampaign() {
		getFieldCampaign({ recordId: this.recordId })
			.then(result => {
				if (result != null) {
                    this.newArch = result.EV_NewArchitecture__c;
                    this.tipoEvento = result.RecordType.DeveloperName;

                    if(this.tipoEvento === accionistaEvt || this.tipoEvento === hibridoEvt || this.tipoEvento === hibridoEvtTech){
                        this.hibAcc = true;
                    }else if(this.tipoEvento === fisicoEvt || this.tipoEvento === festivalesEvt || this.tipoEvento === fisicoEvtTech){
                        this.fisFesti = true;
                    }else if(this.tipoEvento === virtualEvt || this.tipoEvento === virtualEvtTech){
                        this.virtual = true;
                    }

                    if(this.newArch === true){
                        this.totalInscritos = result.EV_TotalInscritosC__c;
                        this.totalAsistentes = result.EV_TotalAsistentesC__c;
                        this.asistentesFisicos = result.EV_AsistentesFisicosC__c;
                        this.asistDiferido = result.EV_AsistioEnDiferido__c;
                        this.numAccounts = result.EV_NumberOfAccounts__c;
                        this.numLeads = result.EV_NumberOfLeads__c;
                        this.numContacts = result.EV_NumberOfContacts__c;
                        this.inscritosVirtuales = result.EV_InscritosVirtualesC__c;
                        this.asistentesVirtuales = result.EV_AsistentesVirtualesC__c;
                        this.inscritosFisicos = result.EV_InscritosFisicosC__c;
                        this.inscritosFisVir = result.EV_inscritosFisicosVirtualesC__c;
                    }else{
                        this.totalInscritos = result.EV_TotalInscritos__c;
                        this.totalAsistentes = result.EV_TotalAsistentes__c;
                        this.asistentesFisicos = result.EV_asistentesFisicos__c;
                        this.numLeads = result.NumberOfLeads;
                        this.numContacts = result.NumberOfContacts;
                        this.inscritosVirtuales = result.EV_inscritosVirtuales__c;
                        this.asistentesVirtuales = result.EV_asistentesVirtuales__c;
                        this.inscritosFisicos = result.EV_inscritosFisicos__c;
                        this.inscritosFisVir = result.EV_inscritosFisicosVirtuales__c;
                        
                    }
                }
            });
    }
}