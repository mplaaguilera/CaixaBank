import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getPretensiones from '@salesforce/apex/SPV_LCMP_PretensionesRelacionadas.getPretensiones';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CASORECLAMADO_FIELD from '@salesforce/schema/SAC_Interaccion__c.SAC_CasoEscalado__r.Id';


const fields = [CASORECLAMADO_FIELD];

export default class Spv_InformacionPretensiones extends NavigationMixin(LightningElement) {
    @api recordId;
    @api titulotabla;
    @track idReclamacion;
    @track spinnerLoading
    @track pretensiones;
    @track wiredPretensiones;
    @track error;
    @track hayPretensiones;

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredEscalado({data, error}) {
    if (data) {
        this.idReclamacion = getFieldValue(data, CASORECLAMADO_FIELD);        
    } 
    }

    @wire(getPretensiones, {recordId: '$idReclamacion'})
    wiredPretensiones(result) {
        this.wiredPretensiones = result;
        if (result.data != undefined) {
            this.pretensiones = result.data;
            this.error = undefined;
            this.titulotabla = 'Información Pretensiones '+ '(' + this.pretensiones.length +  ')';
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
                    SPV_DecisionPretensionLetrado__c: prete.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c,
                    SPV_ObservacionesDecisionPretLetrado__c: prete.CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionPretLetrado__c,
                    SPV_DecisionFinal__c: prete.CBK_Case_Extension_Id__r.SPV_DecisionFinal__c,
                    SPV_ObservacionesDecisionFinal__c: prete.CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionFinal__c
                };
            });
        } 
        return [];
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