import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import recuperarReclamantes from '@salesforce/apex/SAC_LCMP_Reclamantes.recuperarReclamantes';



export default class Sac_MostrarDatosNoAlf extends NavigationMixin(LightningElement)  {
    @api recordId;
    @track tituloTabla;
    @track _wiredResult;
    @track reclamantes;
    @track mostrarCmpDAtosNoAlf = false;


    @wire(recuperarReclamantes, { caseId: '$recordId' })
    caseReclamantes(result){
        this._wiredResult = result; 
        
        if (result.data) {
            this.reclamantes = result.data.listReclamantes;

            let numReclamantesDatosNoAlf = 0;
            for(let i=0; i<this.reclamantes.length; i++){
                if(this.reclamantes[i].SAC_TieneDatosNoAlf__c === true){
                    this.mostrarCmpDAtosNoAlf = true;
                    numReclamantesDatosNoAlf++;
                }
            }

            this.tituloTabla = 'Datos No Alfabetizados (' +  numReclamantesDatosNoAlf + ')';
        }
        
    }

    mostrarCuenta(event){

        const recordId = event.currentTarget.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }   
    
    handleRefreshClick() {
        return refreshApex(this._wiredResult);
    }
}