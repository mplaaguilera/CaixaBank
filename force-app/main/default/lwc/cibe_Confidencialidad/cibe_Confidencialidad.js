import { LightningElement, api , wire, track} from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";

//Fields
import USER_ID_FIELD from '@salesforce/user/Id';
import OPPORTUNITY_OWNER_FIELD from '@salesforce/schema/Opportunity.OwnerId';
import OPPORTUNITY_STAGENAME_FIELD from '@salesforce/schema/Opportunity.StageName';
import OPPORTUNITY_CONFIDENTIAL_FIELD from '@salesforce/schema/Opportunity.AV_ClienteConfidencial__c';
import OPPORTUNITY_ESG_FIELD from '@salesforce/schema/Opportunity.CIBE_ESG__c';
import OPPORTUNITY_SINDICACION_FIELD from '@salesforce/schema/Opportunity.CIBE_Sindicaciones__c';
import OPPORTUNITY_ECAS_FIELD from '@salesforce/schema/Opportunity.CIBE_ECAs__c';
import OPPORTUNITY_PRODUCT_FIELD from '@salesforce/schema/Opportunity.AV_PF__c';
import OPPORTUNITY_LINEA_FIELD from '@salesforce/schema/Opportunity.CIBE_Linea__c';

//Controller
import createNotification from '@salesforce/apex/CIBE_ConfidencialidadController.createNotification';
import saveESG from '@salesforce/apex/CIBE_ConfidencialidadController.saveESG';
import getOpportunityFields from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.getOpportunityFields';
import saveFields from '@salesforce/apex/CIBE_ConfidencialidadController.saveFields';
import getOpportunityRT from '@salesforce/apex/CIBE_ConfidencialidadController.getOpportunityRT';


//Labels
import cargando from '@salesforce/label/c.CIBE_Cargando';
import cerrar from '@salesforce/label/c.CIBE_Cerrar';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import opConfidencialGestionadaPorEquipoAsignado from '@salesforce/label/c.CIBE_OpConfidencialGestionadaPorEquipoAsignado';
import opDejaDeSerConfidencial from '@salesforce/label/c.CIBE_OpDejaDeSerConfidencial';
import confirmacionCambiarConfidencialidad from '@salesforce/label/c.CIBE_ConfirmacionCambiarConfidencialidad';
import guardar from '@salesforce/label/c.CIBE_Guardar';
import oportunidadConfidencial from '@salesforce/label/c.CIBE_OportunidadConfidencial';
import oportunidadActualizada from '@salesforce/label/c.CIBE_OportunidadActualizada';
import oportunidadActualizadaCorrectamente from '@salesforce/label/c.CIBE_OportunidadActualizadaCorrectamente';
import problemaAlEnviarNotificaciones from '@salesforce/label/c.CIBE_ProblemaAlEnviarNotificaciones';
import esgLabel from '@salesforce/label/c.CIBE_ESG';
import problemUpdatingESG from '@salesforce/label/c.CIBE_ProblemUpdatingESG';
import problemUpdatingECAS from '@salesforce/label/c.CIBE_ProblemUpdatingECAs';
import problemUpdatingSindi from '@salesforce/label/c.CIBE_ProblemUpdatingSindi';
import linea from '@salesforce/label/c.CIBE_Linea';
import problemUpdatingLinea from '@salesforce/label/c.CIBE_ProblemUpdatingLinea';
import ecas from '@salesforce/label/c.CIBE_ECAs';
import sindicaciones from '@salesforce/label/c.CIBE_Sindicaciones';

export default class Cibe_Confidencialidad extends NavigationMixin(LightningElement) {

    @api recordId;

    @track opportunity;
    @track ownerId;
    @track stageName;
    @track confidential;
    @track esg;
    @track sindicaciones;
    @track linea;
    @track ecas;
    @track product;
    @track isEca = true;
    @track isSindi = true;
    @track isCIB = false;
    @track isLinea = true;

    @track showModal = false;
    @track loading = false;
    
    labels = {
        cargando,
        cerrar,
        cancelar,
        opConfidencialGestionadaPorEquipoAsignado,
        opDejaDeSerConfidencial,
        confirmacionCambiarConfidencialidad,
        guardar,
        oportunidadConfidencial,
        oportunidadActualizada,
        oportunidadActualizadaCorrectamente,
        problemaAlEnviarNotificaciones,
        problemUpdatingESG,
        esgLabel,
        ecas,
        sindicaciones,
        problemUpdatingECAS,
        problemUpdatingSindi,
        linea,
        problemUpdatingLinea
    }

    @wire(getRecord, { recordId: '$recordId', fields: [OPPORTUNITY_OWNER_FIELD, OPPORTUNITY_STAGENAME_FIELD, OPPORTUNITY_CONFIDENTIAL_FIELD,OPPORTUNITY_ESG_FIELD,
        OPPORTUNITY_SINDICACION_FIELD,OPPORTUNITY_ECAS_FIELD,OPPORTUNITY_PRODUCT_FIELD, OPPORTUNITY_LINEA_FIELD] })
    getOpportunity({ error, data }){
        if(data){
            var result = JSON.parse(JSON.stringify(data));
            this.opportunity = result;
            this.ownerId = result.fields.OwnerId.value;
            this.stageName = result.fields.StageName.value;
            this.confidential = result.fields.AV_ClienteConfidencial__c.value;
            this.esg = result.fields.CIBE_ESG__c.value;
            this.ecas = result.fields.CIBE_ECAs__c.value;
            this.sindicaciones = result.fields.CIBE_Sindicaciones__c.value;
            this.linea = result.fields.CIBE_Linea__c.value;
            this.product = result.fields.AV_PF__c.value;
        }else if(error) {
            var result = JSON.parse(JSON.stringify(error));
            console.log('Error loading: ', result);
        }
    };

    @wire(getOpportunityRT, {recordId: '$recordId'})
    getOpportunityRT({ error, data }){
        if(data){
            this.isCIB = data;
        }else if(error) {
            var result = JSON.parse(JSON.stringify(error));
            console.log('Error loading: ', result);
        }
    };

    get hasNotPermission() {
        return (this.stageName == 'CIBE_Cerrado positivo' || this.stageName == 'Cerrado negativo' || this.stageName == 'CIBE_Vencido') || (USER_ID_FIELD != this.ownerId);
    }

    @wire(getOpportunityFields, {productoName: '$product'})
    getOpportunityFields({error,data}) {
        this.isEca = true;
        this.isLinea = true;
        this.isSindi = true;
        if(data){
            data.forEach(d => {
                    if(d == 'CIBE_ECAs__c') {
                        this.isEca = false;            
                    }
                    if(d == 'CIBE_Sindicaciones__c') {
                        this.isSindi = false;            
                    }
                    if(d == 'CIBE_Linea__c') {
                        this.isLinea = false;            
                    }
                });
        }else if(error) {
            console.log(error);
        }
    }

    handleChange (event) {
        this.confidential = event.target.checked;
        this.showModal = true;
    }
    handleChangeESG(event) {
        this.loading = true;
        this.esg = event.target.checked;
        saveESG({recordId: this.recordId, esg: this.esg }).then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.oportunidadActualizada,
                    message: this.labels.oportunidadActualizadaCorrectamente,
                    variant: 'success'
                })
            ); 
            this.loading = false;
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: this.labels.problemUpdatingESG,
                message: JSON.stringify(error),
                variant: 'error'
            });
            this.dispatchEvent(evt);
        });
    }

    closeModal() {
        this.confidential = !this.confidential;
        this.showModal = false;
    }

    handleSubmit () {
        this.loading = true;
        this.showModal = false;
    }

    handleSuccess () {
        if(this.confidential == true) {
            createNotification({recordId: this.recordId}).then(result => {
                this.loading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.oportunidadActualizada,
                        message: this.labels.oportunidadActualizadaCorrectamente,
                        variant: 'success'
                    })
                ); 
            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: this.labels.problemaAlEnviarNotificaciones,
                    message: JSON.stringify(error),
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            });
        } else {
            this.loading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.oportunidadActualizada,
                    message: this.labels.oportunidadActualizadaCorrectamente,
                    variant: 'success'
                })
            );
        }
    }

    handleChangeECAs (event) {
        this.loading = true;
        this.ecas = event.target.checked;
        saveFields({recordId: this.recordId, bool: this.ecas, name:'ecas' }).then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.oportunidadActualizada,
                    message: this.labels.oportunidadActualizadaCorrectamente,
                    variant: 'success'
                })
            ); 
            this.loading = false;
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: this.labels.problemUpdatingECAS,
                message: JSON.stringify(error),
                variant: 'error'
            });
            this.dispatchEvent(evt);
        });    }

    handleChangeSindicaciones (event) {
        this.loading = true;
        this.sindicaciones = event.target.checked;
        saveFields({recordId: this.recordId, bool: this.sindicaciones, name:'sindicaciones' }).then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.oportunidadActualizada,
                    message: this.labels.oportunidadActualizadaCorrectamente,
                    variant: 'success'
                })
            ); 
            this.loading = false;
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: this.labels.problemUpdatingSindi,
                message: JSON.stringify(error),
                variant: 'error'
            });
            this.dispatchEvent(evt);
        });
    }

    handleChangeLinea (event) {
        this.loading = true;
        this.linea = event.target.checked;
        saveFields({recordId: this.recordId, bool: this.linea, name:'linea' }).then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.oportunidadActualizada,
                    message: this.labels.oportunidadActualizadaCorrectamente,
                    variant: 'success'
                })
            ); 
            this.loading = false;
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: this.labels.problemUpdatingLinea,
                message: JSON.stringify(error),
                variant: 'error'
            });
            this.dispatchEvent(evt);
        });
    }

}