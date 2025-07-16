import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation'; 
import getReclamacionesVinculadas from '@salesforce/apex/SPV_LCMP_ReclamacionesVinculadas.getReclamacionesVinculadas';



export default class Spv_ReclamacionVinculada extends  NavigationMixin(LightningElement)  {
    @api recordId;    
    @track listadoReclamacionesSAC = [];
    @track listadoReclamacionesSPV = [];
    @track mostrarRecSAC = false;
    @track mostrarRecSPV = false;
    @track mostrarMsjVariasRecsSPV = false;
    @track mostrarMsjVariasRecsSAC = false;
    @track todasSPV = false;
    @track todasSAC = false;
    @track msjVariasRec = 'La reclamación tiene más reclamaciones vinculadas..';

    @wire(getRecord, { recordId: '$recordId' })
    wiredGetRecord;

    connectedCallback(){
        this.comprobarRecsVinculadas();
    }

    handleRecargar(){
        this.comprobarRecsVinculadas();
    }

    comprobarRecsVinculadas(){
        getReclamacionesVinculadas({ idCasoActual: this.recordId }).then(result => {       
            if (result) {            
                this.listadoReclamacionesSAC = [];
                this.listadoReclamacionesSPV = [];
                this.mostrarRecSAC = false;
                this.mostrarRecSPV = false;

                let reclamaciones = JSON.parse(JSON.stringify(result));
                
                if(reclamaciones && reclamaciones.length > 0){                       
                    for (var miReclamacion in reclamaciones) {                
                        let reclamacion = reclamaciones[miReclamacion];
                        reclamacion.isExpanded = false;
                        reclamacion.toggleText = 'Ver más...';

                        //Aqui vamos a intentar meter a cada pretension su N_Contrato                            
                        var listPretensiones = reclamacion.listaPretensionesActual;
                        var listacontratos = reclamacion.mapPretNumerosContratosActual;

                        listPretensiones.forEach(pretension => {
                            //Obtener los contratos relacionados al Id de la pretension desde listacontratos
                            const contratos = listacontratos[pretension.Id] || [];

                            // Agregar un nuevo campo 'Contratos' al objeto pretension
                            pretension.contratosPret = contratos;
                        });
                        
                        if(reclamacion.reclamacionActual.RecordType.DeveloperName === 'SPV_Reclamacion'){
                            this.mostrarRecSPV = true;

                            this.listadoReclamacionesSPV.push(reclamacion);
                        }else if(reclamacion.reclamacionActual.RecordType.DeveloperName === 'SAC_Reclamacion'){
                            this.mostrarRecSAC = true;

                            this.listadoReclamacionesSAC.push(reclamacion);
                        }
                    } 

                    if(this.mostrarRecSPV){

                        this.listadoReclamacionesSPV.sort(function(r1,r2){ 
                            if (r1.reclamacionActual.CreatedDate > r2.reclamacionActual.CreatedDate){
                                return -1;
                            }if(r1.reclamacionActual.CreatedDate < r2.reclamacionActual.CreatedDate){
                                return 1;
                            }
                            return 0;   
                        });

                        if(!this.todasSPV && this.listadoReclamacionesSPV.length > 1){                            
                            this.mostrarMsjVariasRecsSPV = true;

                            this.listadoReclamacionesSPV = [this.listadoReclamacionesSPV[0]];
                        }else{
                            this.mostrarMsjVariasRecsSPV = false;
                        }
                    }
                    if(this.mostrarRecSAC){
                        this.listadoReclamacionesSAC.sort(function(r1,r2){ 
                            if (r1.reclamacionActual.CreatedDate > r2.reclamacionActual.CreatedDate){
                                return -1;
                            }if(r1.reclamacionActual.CreatedDate < r2.reclamacionActual.CreatedDate){
                                return 1;
                            }
                            return 0;   
                        });

                        if(!this.todasSAC && this.listadoReclamacionesSAC.length > 1){                            
                            this.mostrarMsjVariasRecsSAC = true;

                            this.listadoReclamacionesSAC = [this.listadoReclamacionesSAC[0]];
                        }else{
                            this.mostrarMsjVariasRecsSAC = false;
                        }
                    }   
                }
            }

        })
        .catch(error => {
            this.isLoading = false;

            this.showToast('Fallo al recuperar las reclamaciones vinculadas', error.body.message, 'error');
        })
    }

    // Método para alternar el estado expandido de una reclamación
    toggleText(event) {
        const caseId = event.target.dataset.id;

        this.listadoReclamacionesSAC = this.listadoReclamacionesSAC.map(reclamacion => {
            if (reclamacion.reclamacionActual.Id === caseId) {
                reclamacion.isExpanded = !reclamacion.isExpanded;
                reclamacion.toggleText = reclamacion.isExpanded ? ' ...Ver menos' : 'Ver más...'; // Actualizar el texto del botón
            }
            return reclamacion;
        });

        this.listadoReclamacionesSPV = this.listadoReclamacionesSPV.map(reclamacion => {
            if (reclamacion.reclamacionActual.Id === caseId) {
                reclamacion.isExpanded = !reclamacion.isExpanded;
                reclamacion.toggleText = reclamacion.isExpanded ? ' ...Ver menos' : 'Ver más...'; // Actualizar el texto del botón
            }
            return reclamacion;
        });
    }

    mostrarTodasRecsSPV(){
        this.mostrarMsjVariasRecsSPV = false;
        this.todasSPV = true;

        this.comprobarRecsVinculadas();
    }

    mostrarTodasRecsSAC(){
        this.mostrarMsjVariasRecsSAC = false;
        this.todasSAC = true;

        this.comprobarRecsVinculadas();
    }

    navigateToCase(evt) {

        evt.preventDefault();
        var variableAuxiliarCodigoboton = evt.currentTarget.id;
        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.caseId = variableAuxiliarCodigoboton.substring(0, i);
            }
        }
        evt.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.caseId,
                "objectApiName": "Case",
                "actionName": "view"
            }
        });

    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }
}