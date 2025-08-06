import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getPretensiones from '@salesforce/apex/SPV_LCMP_PretensionesRelacionadas.getPretensiones';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CASEID_FIELD from '@salesforce/schema/SAC_Interaccion__c.SAC_CasoEscalado__c';


const fields = [CASEID_FIELD];

export default class SPV_LCMP_PretensionesRelacionadas extends NavigationMixin(LightningElement) {
    @api recordId;
    @api idCasoEscalado;
    @api titulotabla;
    @track spinnerLoading
    @track pretensiones;
    @track wiredPretensiones;
    @track error;
    @track hayPretensiones;

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredEscalado(data) {
        if (data) {
            this.idCasoEscalado = data.fields.SAC_CasoEscalado__c.value;
        }
    }
       

    @wire(getPretensiones, {recordId: this.idCasoEscalado})
    wiredPretensiones(result) {
        this.wiredPretensiones = result;
        if (result.data != undefined) {
            this.pretensiones = result.data;
            this.error = undefined;
            this.titulotabla = 'Información de las pretensiones';
            if(result.data.length >= 1){
                this.hayPretensiones = true;
            }else{
                this.hayPretensiones = false;
            }
        }else if (result.data == '' || result.error || result.data == undefined ){
            this.error = result.error;
            this.pretensiones = undefined;
            this.hayPretensiones = false;
        }

    }


    get pretensionesPorColumnas() {
        if(this.pretensiones != '' && this.pretensiones != undefined){
            let sortedData = [...this.pretensiones];
            const sortDirection = this.sortedDirection;

       
            return sortedData.map(prete => {
                const options = { day: 'numeric', month: 'numeric', year: 'numeric', hour: 'numeric', minute: 'numeric' };
                const formattedDate = new Intl.DateTimeFormat('es-ES', options).format(new Date(prete.CreatedDate));
                return {
                    idCaso: prete.Id,
                    numeroCaso: prete.CaseNumber,
                    asunto: prete.Subject,
                    formattedCreateDate: formattedDate,
                    status: prete.Status,
                    validacionMCC: prete.SAC_ValidacionMCC__c

                };
            });
        } 
    }



    navigateToRecord(event) {
        const caseId = event.currentTarget.dataset.value;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }

        });

      }

      handleChange(event) {
        this.idCase = event.target.value;
        this.spinnerLoading = true;
        validarPretension({recordId: this.idCase, checkValidar: event.target.checked})
        .then(result => {
            this.spinnerLoading = false;
        })
        .catch(error => {
            this.spinnerLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Fallo al validar',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        })

    }

    handleRefreshClick() {
        return refreshApex(this.wiredPretensiones);
    }

    get comprobarStatus() {
        let estado = this.statusReclamacion;
        if(estado != 'SPV_AnalisisDecision' && estado != 'SAC_001'){
            return true;
        }else{
            return false;
        }
    }


}