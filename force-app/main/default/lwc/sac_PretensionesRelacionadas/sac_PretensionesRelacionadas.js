import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getPretensiones from '@salesforce/apex/SAC_LCMP_PretensionesRelacionController.getPretensiones';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import validarPretension from '@salesforce/apex/SAC_LCMP_PretensionesRelacionController.validarPretension';


const fields = [STATUS_FIELD];

export default class SAC_LCMP_PretensionesRelacionadas extends NavigationMixin(LightningElement) {
    @api recordId;
    @api titulotabla;
    @track spinnerLoading
    @track pretensiones;
    @track wiredPretensiones;
    @track error;
    @track hayPretensiones;

    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    get statusReclamacion() {
        return getFieldValue(this.case.data, STATUS_FIELD);
    }

    @wire(getPretensiones, {recordId: '$recordId'})
    wiredPretensiones(result) {
        this.wiredPretensiones = result;
        if (result.data != undefined) {
            this.pretensiones = result.data;
            this.error = undefined;
            this.titulotabla = 'Pretensiones Relacionadas '+ '(' + this.pretensiones.length +  ')';
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
                console.log('case IDDD' + prete.Id);
                console.log('check' + prete.SAC_ValidacionMCC__c);
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
        if(estado != 'SAC_002' && estado != 'SAC_001'){
            return true;
        }else{
            return false;
        }
    }


}