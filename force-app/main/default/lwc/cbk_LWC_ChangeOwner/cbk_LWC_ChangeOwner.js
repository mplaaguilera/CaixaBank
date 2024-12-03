import { LightningElement, api,track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRegistros from '@salesforce/apex/CBK_LWC_ChangeOwner_Controller.getRegistros';
import functionChangeOwner from '@salesforce/apex/CBK_LWC_ChangeOwner_Controller.functionChangeOwner';
//import getProjects from '@salesforce/apex/CBK_LWC_ChangeOwner_Controller.getProjects';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class Cbk_LWC_ChangeOwner extends LightningElement {
    @api inputProject;
    @api inputLabel;
    @api recordId;
    @api labeltest=[];
    @track active = false;
    selectedItem;
    options = [];
    projectSelect;
    //showProject = true;
    showProject = false;
    showbutton;
    currentPageReference = null; 
    typePage = null;
    disableButtonOwner = true;

    tiposBusqueda = [
        {label: 'Usuario', iconName: 'standard:user'},
        {label: 'Cola', iconName: 'standard:orders'}
    ];

    tipoBusquedaSeleccionado = {label: 'Usuario', iconName: 'standard:user'};
    idTimeoutBusqueda;
    resultados = [];
    resultadoSeleccionado;
    isUser = false;

    tipoBusquedaSeleccionadoEsUsuario() {
        return this.tipoBusquedaSeleccionado.label === 'Usuario';
    }
    
    menuTipoBusquedaAbrir() {
        this.template.querySelector('.menuOpcionesTipoBusqueda').classList.remove('slds-hide');
    }

    menuTipoBusquedaCerrar() {
        window.setTimeout(() => this.template.querySelector('.menuOpcionesTipoBusqueda').classList.add('slds-hide'), 200);
    }
    
    menuTipoBusquedaSeleccion(event) {
        this.resultados = [];
        this.tipoBusquedaSeleccionado = this.tiposBusqueda.find(
            tipoBusqueda => tipoBusqueda.label === event.currentTarget.dataset.tipoBusqueda
        );
        this.tipoBusquedaSeleccionado = {...this.tipoBusquedaSeleccionado};
        let inputBusqueda = this.template.querySelector('.inputBusqueda');
        inputBusqueda.value = '';
        inputBusqueda.focus();

        this.busquedaApex(this.tipoBusquedaSeleccionado.label, '');
    }

    inputBusquedaChange(event) {
        window.clearTimeout(this.idTimeoutBusqueda);
        let cadenaBusqueda = event.currentTarget.value.trim();
        if (cadenaBusqueda.length > 1) {
            this.idTimeoutBusqueda = window.setTimeout(this.busquedaApex.bind(this, this.tipoBusquedaSeleccionado.label, cadenaBusqueda), 200);
        } else {
            this.resultados = [];
        }
    }

    busquedaApex(tipoObjeto, cadenaBusqueda) {
        this.template.querySelector('.inputBusqueda').isLoading = true;
        if (tipoObjeto == 'Usuario'){
            this.isUser = true;
        }else{
            this.isUser = false;
        }
        if ((tipoObjeto && cadenaBusqueda) || tipoObjeto) {
            getRegistros({tipoObjeto: tipoObjeto, cadenaBusqueda: cadenaBusqueda, project: this.inputProject, recordId: this.recordId})
            .then(registros => {
                if (this.template.querySelector('.inputBusqueda').value.trim() === cadenaBusqueda) {
                    this.resultados = registros;
                }
            }).catch(error => console.error('Problema obteniendo registros: ' + JSON.stringify(error)))
            .finally(() => this.template.querySelector('.inputBusqueda').isLoading = false);
        }
    }

    menuResultadosAbrir() {
        this.template.querySelector('.menuResultados').classList.add('slds-is-open');
        this.busquedaApex(this.tipoBusquedaSeleccionado.label, '');
    }

    menuResultadosCerrar() {
        window.setTimeout(() => this.template.querySelector('.menuResultados').classList.remove('slds-is-open'), 200);
    }

    resultadoClick(event) {
        let idResultadoSeleccionado = event.currentTarget.dataset.idResultado;
        this.resultadoSeleccionado = this.resultados.find(resultado => resultado.Id === idResultadoSeleccionado);
        
        if(!this.resultadoSeleccionado.Queue){
            
            this.selectedItem =  this.resultadoSeleccionado.Assignee.Name;
        }else{
            this.selectedItem =  this.resultadoSeleccionado.Queue.Name;
        }
        this.disableButtonOwner = false;
    }

    changeOwnerClick(event) {
        functionChangeOwner({obj: this.resultadoSeleccionado, recordId: this.recordId})
						.then((data) => {
								console.info('Messages: '+  JSON.stringify(data));
                                getRecordNotifyChange([{recordId: this.recordId}]);

                                if (data == 'OK'){
                                    if (this.typePage === 'standard__quickAction'){
                                        if(!this.resultadoSeleccionado.Queue){
                                            const evt = new ShowToastEvent({
                                                title: this.resultadoSeleccionado.Assignee.Name + " Now owns the record for " + this.recordId,
                                                //message: "",
                                                variant: "success"
                                            });
                                            this.dispatchEvent(evt);
                                        }else{
                                            const evt = new ShowToastEvent({
                                                title: this.resultadoSeleccionado.Queue.Name +  " Now queue owns the record for " + this.recordId,
                                                //message: "",
                                                variant: "success"
                                            });
                                            this.dispatchEvent(evt);
                                        }
                                        
                                        this.dispatchEvent(new CloseActionScreenEvent());
                                    }else{
                                        console.info('Messages: '+  JSON.stringify(this.resultadoSeleccionado));
                                        if(!this.resultadoSeleccionado.Queue){
                                            console.info('OK else0: '+  JSON.stringify(this.recordId));
                                            const evt = new ShowToastEvent({
                                                title: this.resultadoSeleccionado.Assignee.Name + " Now owns the record for " + this.recordId,
                                                //message: "",
                                                variant: "success"
                                            });
                                            this.dispatchEvent(evt);

                                        }else{
                                            console.info('OK else1: ');
                                            const evt = new ShowToastEvent({
                                                title: this.resultadoSeleccionado.Queue.Name +  " Now queue owns the record for " + this.recordId,
                                                //message: "",
                                                variant: "success"
                                            });
                                            this.dispatchEvent(evt);
                                        }
                                        
                                        this.active = false;
                                        if (this.labeltest.length > 0){
                                            window.history.back();
                                        }
                                    }
                                }else{
                                    if (this.typePage === 'standard__quickAction'){

                                        if(!this.resultadoSeleccionado.Queue){
                                            const evt = new ShowToastEvent({
                                                title: 'Error in the Change Owner for user: ' + this.resultadoSeleccionado.Assignee.Name,
                                                //message: "",
                                                variant: "error"
                                            });
                                            this.dispatchEvent(evt);
                                        }else{
                                            const evt = new ShowToastEvent({
                                                title: 'Error in the Change Owner for queue: ' + this.resultadoSeleccionado.Queue.Name,
                                                //message: "",
                                                variant: "error"
                                            });
                                            this.dispatchEvent(evt);
                                        }
                                    }else{
                                        if(!this.resultadoSeleccionado.Queue){
                                            const evt = new ShowToastEvent({
                                                title: 'Error in the Change Owner for user: ' + this.resultadoSeleccionado.Assignee.Name,
                                                //message: "",
                                                variant: "error"
                                            });
                                            this.dispatchEvent(evt);
                                        }else{
                                            const evt = new ShowToastEvent({
                                                title: 'Error in the Change Owner for queue: ' + this.resultadoSeleccionado.Queue.Name,
                                                //message: "",
                                                variant: "error"
                                            });
                                            this.dispatchEvent(evt);
                                        }
                                    }
                                }
							})
							.catch(error => {     
								console.log('Error: '+  JSON.stringify(this.error));
							}
						);
    }


    @wire(CurrentPageReference)
		getStateParameters(currentPageReference) {
		   if (currentPageReference) {
				this.typePage = currentPageReference.type;
				if (this.typePage === 'standard__quickAction'){
					//this.showProject = true;
                    this.showbutton = false;
                    this.active = true;

				}else{
					this.showProject = false;
                    this.showbutton = true;
				}
			}

	}

    connectedCallback(){
        if (this.labeltest.length > 0){
           
            this.active = true;
            this.recordId = this.labeltest;
        }
    }

    handleClick(event) {
        this.active = true;
    }

    closeModal(event) {
        this.selectedItem = '';

        if (this.typePage === 'standard__quickAction'){
            this.dispatchEvent(new CloseActionScreenEvent());
        }else{
            this.active = false;

            if (this.labeltest.length > 0){
                window.history.back();
            }
        }
    }

    handleChange(event) {
        this.inputProject = event.target.value;
        this.showProject = false;
    }
}