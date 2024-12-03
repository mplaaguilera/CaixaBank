import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import asociarRegistros from '@salesforce/apex/OS_BuscadorEspecilistaMICController.asociar';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecordId } from 'lightning/uiRecordApi';
import buscarCuentas from '@salesforce/apex/OS_BuscadorEspecilistaMICController.searchAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cargarDatosExistentes from '@salesforce/apex/OS_BuscadorEspecilistaMICController.cargarDatos';
import { RefreshEvent } from 'lightning/refresh';

export default class OS_BuscadorEspecilistaMIC extends LightningElement {
    
    @track cuentas = [];
    @track cuentasEncontradas = [];
    @api spinner = false;
    @track isModalOpen = true;
    @api recordId;
    @api hayRegistros = false;
    searchKey;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            /*console.log(this.recordId);
            console.log(currentPageReference);*/
        }
    }

    connectedCallback(){
        cargarDatosExistentes({regActualApex: this.recordId})
        .then(result => {            
            //console.log(JSON.stringify(result));
            if(result.length != 0){
                this.cuentas = result;
            }
            /*console.log(JSON.stringify(result));
            console.log(JSON.stringify(result.previsionDataChats));*/
        })
        .catch(error => { 
            console.log(JSON.stringify(error));
        });
    }

    submitDetails(){
        //console.log(this.recordId);
        this.spinner = true;
        let tituloError = 'Fallo al vincular cuentas.';
        let tituloExito = 'Éxito al vincular cuentas.';
        let varianteError = 'error';
        let varainteExito = 'success';
        let mensajeExito = 'Las cuentas se han modificado.';

        asociarRegistros({cuentasApex: this.cuentas, regActualApex: this.recordId})
            .then(result => { 

                const evt = new ShowToastEvent({
                    title: tituloExito,
                    message: mensajeExito,
                    variant: varainteExito
                });
                this.spinner = false;
                this.isModalOpen = false;
                this.dispatchEvent(new RefreshEvent());
                eval("$A.get('e.force:refreshView').fire();");                
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(evt);


                })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: tituloError,
                    message: error.body.message,
                    variant: varianteError
                });
                this.spinner = false;
                this.dispatchEvent(evt);
            })
        
    }

    closeModal() {
        this.isModalOpen = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleKeyChange(event){
        //console.log('CONTINUAR POR AQUI');
        this.searchKey = event.target.value;

        buscarCuentas({keyword: this.searchKey})
            .then(result => {
                this.cuentasEncontradas = result;
                if(this.cuentasEncontradas.length != 0){
                    this.hayRegistros = true;
                }
                else{
                    this.hayRegistros = false;
                }
                //console.log(JSON.stringify(this.cuentasEncontradas));
                /*if(result.length > 0) {
                    this.showProducts = true;
                } else{
                    this.showProducts = false;
                }*/
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
    }

    addAcc(event){
        //console.log('CONTINUAR POR AQUI');
        var variableAuxiliarCodigoboton = event.currentTarget.id;
        //console.log(variableAuxiliarCodigoboton);
        //console.log('id acc -> ' + JSON.stringify(event));
        let idAVincular;
        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                idAVincular = variableAuxiliarCodigoboton.substring(0, i);
            }
        }
        //console.log(idAVincular);

        for (var miCuenta in this.cuentasEncontradas) {
            let cuenta = this.cuentasEncontradas[miCuenta];
            //console.log(JSON.stringify(cuenta.Id));
            if(cuenta.Id === idAVincular){
                if(this.cuentas.length != 0){
                    let seInserta = true; 
                    for (var miCuentaExistente in this.cuentas) {
                        let cuentaExistente = this.cuentas[miCuentaExistente];
                        if(cuentaExistente.Id == idAVincular){
                            seInserta = false;
                        }
                    }
                    if(seInserta){
                        this.cuentas.push(cuenta);
                    }
                }
                else{
                    this.cuentas.push(cuenta);
                }
            }
        }
        this.cuentas.sort((a, b) => a.CC_Numero_Oficina__c - b.CC_Numero_Oficina__c);
    }

    remAcc(event){
        var variableAuxiliarCodigoboton = event.currentTarget.id;
        //console.log(variableAuxiliarCodigoboton);
        //console.log('id acc -> ' + JSON.stringify(event));
        let idAVincular;
        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                idAVincular = variableAuxiliarCodigoboton.substring(0, i);
            }
        }
        //console.log(idAVincular);

        let aBorrar;
        for (var miCuentaExistente in this.cuentas) {
            let cuentaExistente = this.cuentas[miCuentaExistente];
            if(cuentaExistente.Id == idAVincular){
                aBorrar = cuentaExistente;
            }
        }
        let nuevoArray = this.cuentas.filter(elemento => elemento !== aBorrar);
        this.cuentas = nuevoArray;

        this.cuentas.sort((a, b) => a.CC_Numero_Oficina__c - b.CC_Numero_Oficina__c);
    }

    cambiarFondo(event) {
        const div = event.target;
        div.style.backgroundColor = 'lightblue';
    }

    restaurarFondo(event) {
        const div = event.target;
        div.style.backgroundColor = '';
    }

}