import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation'; 
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import getReclamacionVinculada from '@salesforce/apex/SPV_LCMP_ReclamacionesVinculadas.getReclamacionVinculada';

import CASORELACIONADO from '@salesforce/schema/Case.CC_CasoRelacionado__c';




export default class Spv_ReclamacionVinculada extends  NavigationMixin(LightningElement)  {
    @track listadoReclamaciones = [];
    @track idCasoRelacionado = '';
    @track tieneVinculada = false;
    @api recordId;    

    _wiredResult;
    @wire(getRecord, {recordId: '$recordId', fields : CASORELACIONADO})
    getCaseRecord({ error, data }){
        if (data) {
            this.tieneVinculada = false;
            if (data.fields.CC_CasoRelacionado__c.value != null){
                this.tieneVinculada = true;
                this.idCasoRelacionado = data.fields.CC_CasoRelacionado__c.value;                
            }
            
            if(this.tieneVinculada){
                getReclamacionVinculada({ idCasoRelacionado: this.idCasoRelacionado}).then(result => {
                    if (result) {
                        this.listadoReclamaciones = [];
                        this._wiredResult = result;
                        let reclamaciones = result;


                        for (var miReclamacion in reclamaciones) {                
                            let reclamacion = reclamaciones[miReclamacion];
                            reclamacion.isExpanded = false;
                            reclamacion.toggleText = 'Ver más...';

                            if(reclamacion.reclamacionActual.Id === this.idCasoRelacionado){
                                this.listadoReclamaciones.push(reclamacion);
                            }

                        } 
                        this.listadoReclamaciones.sort(function(r1,r2){ 

                            if (r1.reclamacionActual.CreatedDate > r2.reclamacionActual.CreatedDate){
                                return -1;
                            }if(r1.reclamacionActual.CreatedDate < r2.reclamacionActual.CreatedDate){
                                return 1;
                            }
                            return 0;   
                        });
                    }
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                });
            }
        }
    }

 // Método para alternar el estado expandido de una reclamación
 toggleText(event) {
    const caseId = event.target.dataset.id;

    this.listadoReclamaciones = this.listadoReclamaciones.map(reclamacion => {
        if (reclamacion.reclamacionActual.Id === caseId) {
            reclamacion.isExpanded = !reclamacion.isExpanded;
            reclamacion.toggleText = reclamacion.isExpanded ? ' ...Ver menos' : 'Ver más...'; // Actualizar el texto del botón
        }
        return reclamacion;
    });
}

}