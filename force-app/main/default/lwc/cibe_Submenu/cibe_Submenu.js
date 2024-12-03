import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//flow
import getActions from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getActions';
import oppFinder from '@salesforce/label/c.CIBE_OppFinder';
import newOpp from '@salesforce/label/c.CIBE_AltaOpps';
import oppDashboard from '@salesforce/label/c.CIBE_OppDashboard';
import newMeeting from '@salesforce/label/c.CIBE_AltaEvento';
import meetingWithClient from '@salesforce/label/c.CIBE_MeetingWithClient';
import calendar from '@salesforce/label/c.CIBE_Calendar';
import eventDashboard from '@salesforce/label/c.CIBE_EventDashboard';
import priceComittee from '@salesforce/label/c.CIBE_PriceCommittee';
import approvalSignatures from '@salesforce/label/c.CIBE_ApprovalSignatures';
import pricingDashboard from '@salesforce/label/c.CIBE_PricingDashboard';
import listSupportTeams from '@salesforce/label/c.CIBE_ListSupportTeams';
import linkCOE from '@salesforce/label/c.CIBE_LinkCOE';
import clientFinder from '@salesforce/label/c.CIBE_ClientFinder';
import oppWithoutClient from '@salesforce/label/c.CIBE_OppWithoutClient';
import eventWithoutClient from '@salesforce/label/c.CIBE_EventWithoutClient';
import soon from '@salesforce/label/c.CIBE_Soon';

export default class Cibe_Submenu extends NavigationMixin(LightningElement) {
    readyToRender = false;

    showOpp = true;
    showCalendar = true;
    showPrecios = true;
    showDashboards = true;
    showSupport = true;
    altaOpp = false;
    altaCita = false;
    showMessage = false;
    originMenu;
    inputFlowVariables;
    flowApiName = 'CIBE_New_Opportunity_CIB'
    @track showSinCliente;
    @track flowlabel;
    @track flowName;
    @track flowOutput;
    @track redirectId;
    @track objectAPIName;
    @track launchFlow = false;


    //labels
    oppFinder = oppFinder;
    newOpp = newOpp;
    newMeeting = newMeeting;
    oppDashboard = oppDashboard;
    calendar = calendar;
    eventDashboard = eventDashboard;
    priceComittee = priceComittee;
    approvalSignatures = approvalSignatures;
    pricingDashboard = pricingDashboard;
    listSupportTeams = listSupportTeams;
    linkCOE = linkCOE;
    clientFinder = clientFinder;
    oppWithoutClient = oppWithoutClient;
    eventWithoutClient = eventWithoutClient;
    meetingWithClient = meetingWithClient;
    soon = soon;

    flowTitle = 'Buscador';


    get inputVariables() {
        return [
            {
                name: "Cibe_buscadorClienteMenu",
                type: "Boolean",
                value: this.showSinCliente
            }
        ];
    }

    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        if (!pageRef) {
            return;
        }

        const stateMap = {
            'CIBE_Citas_y_Calendario': {
                showCalendar: true,
                showMessage: false
            },
            'CIBE_Precios': {
                showPrecios: true
            },
            'CIBE_Dashboards': {
                showDashboards: true
            },
            'CIBE_Soporte': {
                showSupport: true
            },
            'CIBE_Oportunidades': {
                showOpp: true
            }
        };

        this.originMenu = pageRef.attributes.apiName;
        this.resetState();

        const state = stateMap[this.originMenu];
        if (state) {
            Object.assign(this, state);
        }

        this.readyToRender = true;
    }

    resetState() {
        this.showCalendar = false;
        this.showMessage = false;
        this.altaOpp = false;
        this.showOpp = false;
        this.showPrecios = false;
        this.showDashboards = false;
        this.showSupport = false;
    }

    redirect(event) {
        const origin = event.currentTarget.dataset.origin;

        const actions = {
            'Calendario': () => this.navigateToCalendar(),
            'Buscador Oportunidades': () => this.navigateToFlexiPage('CIBE_OportunidadesTabCIB', null),
            'Buscador de cliente en cita': () => this.navigateToFlexiPage('CIBE_PlanificarCitaCIB', false),
            'Cita sin cliente': () => this.navigateToFlexiPage('CIBE_PlanificarCitaCIB', true),
            'Dashboard Citas': () => this.navigateToFlexiPage('CIBE_SeguimientodeEventosCIB', null),
            'Dashboard Oportunidades': () => this.navigateToFlexiPage('CIBE_SeguimientodeOportunidadesCIB', null),
            'Comite de Precios': () => this.navigateToFlexiPage('CIBE_ComitePrecios', null),
            'Alta oportunidades': () => this.updateState({ altaOpp: true }),
            'Aprobacion por firmas': () => this.updateState({ showMessage: true }),
            'Enlace al COE': () => this.updateState({ showMessage: true }),
            'Listado equipos de soporte': () => this.updateState({ showMessage: true }),
            'Dashboard de precios': () => this.updateState({ showMessage: true }),
            'Buscador de cliente': () => this.handleClientSearch(false, this.clientFinder),
            'Oportunidad sin cliente': () => this.handleClientSearch(true, this.oppWithoutClient),
            'Alta de cita': () => this.updateState({ altaCita: true }),
            'backOpp': () => this.updateState({ showOpp: true }),
            'backCita': () => this.updateState({ showCalendar: true }),
            'Listado equipos de soporte': () => this.navigateToFlexiPage('CIBE_ListadoEquipoSoporte', null)
        };

        if (actions[origin]) {
            actions[origin]();
        }
    }

    updateState(stateUpdates) {
        this.altaOpp = stateUpdates.altaOpp || false;
        this.showOpp = stateUpdates.showOpp || false;
        this.showCalendar = stateUpdates.showCalendar || false;
        this.showPrecios = stateUpdates.showPrecios || false;
        this.showDashboards = stateUpdates.showDashboards || false;
        this.showSupport = stateUpdates.showSupport || false;
        this.showMessage = stateUpdates.showMessage || false;
        this.altaCita = stateUpdates.altaCita || false;
        this.readyToRender = true;
    }

    handleClientSearch(showSinCliente, title) {
        this.flowTitle = title;
        this.showSinCliente = showSinCliente;
        this.handleClickOppo();
        this.updateState({});
    }


    navigateToCalendar() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Event',
                actionName: 'home'
            }
        });
    }

    navigateToFlexiPage(flexiName, sinCliente) {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: flexiName
            },
            state: {
                c__sinCliente: sinCliente
            }
        });
    }

    handleClickOppo() {
        getActions({ actionSetting: this.flowApiName })
            .then(data => {
                this.isLoaded = false;
                this.flowlabel = data[0].label;
                this.flowName = data[0].name;
                this.flowOutput = data[0].output;
                this.redirectId = null;
                this.launchFlow = true;
            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: 'error',
                    message: 'Error actualizando evento',
                    variant: 'error',
                    mode: 'pester'
                });
                this.dispatchEvent(evt);
                this.isLoaded = false;
            });
    }

    handleStatusChange(event) {
        const status = event.detail.status;
        const outputVariables = event.detail.outputVariables;
        if (outputVariables) {
            outputVariables.forEach(e => {
                if (e.name === this.flowOutput && e.value) {
                    this.redirectId = e.value;
                }
            });
        }
        if (status === 'FINISHED') {
            this.launchFlow = false;
            if (this.redirectId) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.redirectId,
                        objectApiName: 'Opportunity',
                        actionName: 'view'
                    }
                });
            }
        }
    }

    hideFlowAction() {
        this.launchFlow = false;
        this.altaOpp = true;
    }

    goback() {
        if (this.originMenu === 'CIBE_Dashboards') {
            this.showMessage = false;
            this.showDashboards = true;
        }
        if (this.originMenu === 'CIBE_Precios') {
            this.showMessage = false;
            this.showPrecios = true;
        }
        if (this.originMenu === 'CIBE_Soporte') {
            this.showMessage = false;
            this.showSupport = true;
        }
    }


}