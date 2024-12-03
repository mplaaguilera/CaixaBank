import { LightningElement, api, wire, track } from 'lwc';
import insertTarea from '@salesforce/apex/SPV_LCMP_CrearTarea.insertarTarea';
import camposRequeridos from '@salesforce/apex/SPV_LCMP_CrearTarea.camposRequeridos';
import camposRequeridosMaestro from '@salesforce/apex/SPV_LCMP_CrearTarea.camposRequeridosMaestro';
import tienePermisos from '@salesforce/apex/SPV_LCMP_CrearTarea.tienePermisos';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case';
import { RefreshEvent } from 'lightning/refresh';

const fields = [
    'Case.Status',
    'Case.OwnerId'
];

export default class Spv_CrearTarea extends LightningElement {
    @api recordId;
    @api tienePermisosEditar = false;
    casetInfo;
    ownerId;
    @track error;
    @track modalNuevaTarea = false;
    value = '';
	valueModal = '';
    @track modalOtrasTareas = false;
	@track modalMaestroTareas = false;
	@track modalSelectTarea = false;
    @track _options = [];
    @track campoVacio = false;
    @track seleccionRealizada = false;
    @track descripcion = '';
    @api tareaId;
    @api spinnerLoading = false;
	@track otratareaORmaestro;
	@track isOpen = false;
	@track highlightCounter = null;
	@track _value = "";
    @track equipoResponsableId = '';
	@api messageWhenInvalid = "Porfavor realice una selección";
	@api required = false;
	@track controlador = true;
	@track controladorDos = false;
	

    _wiredResult;  
    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getRecord, {recordId: '$recordId', fields})
    actualCase({data, error}){
        if(data){
            this.casetInfo = data;
            this.ownerId = this.casetInfo.fields.OwnerId.value;  
        }            
    };

    @wire(tienePermisos, { idCaso: '$recordId'}) 
    mapaPermisos(result){ 
        if(result.data){ 
            this.tienePermisosEditar = result.data;          
        }
		//else{
        //     this.ownerId == Id ? this.tienePermisosEditar = true :  this.tienePermisosEditar = false;
        // }
    };

	get options1() {
        return [
            { label: 'Maestro de tareas', value: 'MaestroTareas' }
        ];
    }

    get options2() {
        return [
            { label: 'Otras Tareas', value: 'OtrasTareas' }
        ];
    }

    get selectedValues() {
        return this.value;
    }

	@api
	get value() {  
		return this._value;
	}

	set value(val) { 
		this._value = val;
	}

	@api
	get options() {
		return this._options;
	}

	set options(val) {
		this._options = val; 
	}

	get tempOptions() {
		
		let options = this.options;

		if (this.value.length > 2) {

			options = this.options.filter((op) => op.Name.toLowerCase().includes(this.value.toLowerCase()));

			return this.highLightOption(options);
		}else{
			return this.highLightOption(this.options);
		}
		
	}

	get isInvalid() {
		return this.required && !this.value;
	}

	get formElementClasses() {
		let classes = "slds-form-element";
		if (this.isInvalid) {
			classes += " slds-has-error";
		}
		return classes;
	}

	get classes() {
		let classes = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
		if (this.isOpen) {
			return classes + " slds-is-open";
		}
		return classes;
	}

	get inputClasses() {
		let inputClasses = "slds-input slds-combobox__input";
		if (this.isOpen) {
			return inputClasses + " slds-has-focus";
		}
		return inputClasses;
	}

    abrirModalNuevaTarea() {
        this.modalNuevaTarea = true;
    }

    cerrarModalNuevaTarea() {
        this.modalNuevaTarea = false;
        this.modalOtrasTareas = false;
		this.modalMaestroTareas = false;
		this.modalSelectTarea = false;
		this.seleccionRealizada = false;
		this.descripcion = '';
		this.campoVacio = false;
    }

    anterior() {
        this.modalNuevaTarea = true;
        this.modalOtrasTareas = false;
		this.modalMaestroTareas = false;
		this.modalSelectTarea = false;
		this.equipoResponsableId = '';
		this.campoVacio = false;
		this.seleccionRealizada = false;
		this.descripcion = '';
    }

    handleChange(e) {
        this.value = e.detail.value;
    }

    tareaSeleccionada() {
        if(this.value === 'MaestroTareas'){
            this.modalNuevaTarea = false;
            this.modalMaestroTareas = true;
			this.modalSelectTarea = true;
			this.otratareaORmaestro = false;  // Se pone a false en caso de ser Maestro de Tareas
			this.valueModal = this.value;
			this.value = '';
            this.traerCamposMaestro(this.valueModal);
        }
        else if(this.value === 'OtrasTareas'){
            this.modalNuevaTarea = false;
            this.modalOtrasTareas = true;
			this.modalSelectTarea = true;
			this.otratareaORmaestro = true;  // Se pone a true en caso de ser Otras Tareas
			this.valueModal = this.value;
			this.value = '';
            this.traerCampos(this.valueModal);
        }
        else{
            const evt = new ShowToastEvent({
                title: 'Precaución',
                message: 'Recuerde seleccionar alguna de las tareas.', 
                variant: 'warning'
            });
            this.dispatchEvent(evt);
        }
    }

    traerCampos(valor){
        camposRequeridos({caseId: this.recordId, tipoTarea: valor}).then(result => {
            this._options = result;
            //this.value = '';
        })
		.catch(error => {
			const evt = new ShowToastEvent({
				title: 'Fallo al recuperar los equipos responsables',
				message: error.body.message,
				variant: 'error'
			}); 
			this.dispatchEvent(evt);
		})
    }

	traerCamposMaestro(valor){
        camposRequeridosMaestro({caseId: this.recordId, tipoTarea: valor}).then(result => {
            this._options = result;
            //this.value = '';
		})
		.catch(error => {
			const evt = new ShowToastEvent({
				title: 'Fallo al recuperar las tareas predefinidas',
				message: error.body.message,
				variant: 'error'
			}); 
			this.dispatchEvent(evt);
		})
    }

    guardarTarea() {
        if((this.modalOtrasTareas === true && (this.descripcion === '' || this.descripcion === 'undefined'  || this.seleccionRealizada === false)) || (this.modalMaestroTareas === true && this.seleccionRealizada === false)){
            this.campoVacio = true;
        }else{
            this.spinnerLoading = true;
			this.modalOtrasTareas = false;
			this.modalMaestroTareas = false;
			this.modalSelectTarea = false;
			this.campoVacio = false;
			this.seleccionRealizada = false;
					
            insertTarea({tareaId: this.recordId, descripcion: this.descripcion, equipoResponsableId: this.equipoResponsableId, esMaestroOrOtras: this.otratareaORmaestro}).then(result => {
            	const evt = new ShowToastEvent({
                	title: 'Tarea creada',
                	message: 'Se ha creado la tarea con éxito',
                	variant: 'success'
				});
				this.dispatchEvent(evt);

				/*
				let nuevaId = result;
				this[NavigationMixin.Navigate]({ 
					type: 'standard__recordPage',
					attributes: {
						recordId: nuevaId,
						objectApiName: 'SAC_Accion__c',
						actionName: 'view'
					}
            	});
				*/

				this.descripcion= '';
				this.equipoResponsableId = '';	
				this.spinnerLoading = false;
				
				this.dispatchEvent(new RefreshEvent());
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Fallo al crear la tarea',
                    message: error.body.message,
                    variant: 'error'
                });

                this.dispatchEvent(evt);
                this.spinnerLoading = false;
            })
        }
    }

	handleChanges(event) {
		this._value = event.target.value;
        this.seleccionRealizada = false;
		this.fireChange();
	}

    inputDescripcion(event) {
		this.descripcion = event.target.value;
		//this.fireChange();
	}

	handleInput(event) {
		this.isOpen = true;
	}

	fireChange() {
		this.dispatchEvent(new CustomEvent("change", {detail: {value: this._value}}));
	}

	allowBlur() {
		this._cancelBlur = false;
	}

	cancelBlur() {
		this._cancelBlur = true;
	}

	handleDropdownMouseDown(event) {
		const mainButton = 0;
		if (event.button === mainButton) {
			this.cancelBlur();
		}
	}

	handleDropdownMouseUp() {
		this.allowBlur();
	}

	handleDropdownMouseLeave() {
		if (!this._inputHasFocus) {
			this.showList = false;
		}
	}

	handleBlur() {
		this._inputHasFocus = false;
		if (this._cancelBlur) {
			return;
		}
		this.isOpen = false;

		this.highlightCounter = null;
		this.dispatchEvent(new CustomEvent("blur"));
	}

	handleFocus() {
		this._inputHasFocus = true;
		this.isOpen = true;
		this.highlightCounter = null;
		this.controladorDos = false;
		this.controlador = true;
		this.dispatchEvent(new CustomEvent("focus"));
	}

	handleSelect(event) {
		this.isOpen = false;
		this.allowBlur();
		this._value = event.currentTarget.dataset.value;

		let idSeleccion;
		this._options.forEach( function(element, index) {
            if(element.Name === event.currentTarget.dataset.value) {
				idSeleccion = element.Id;
            }
        });

		this.controlador = false;
		this.equipoResponsableId = idSeleccion; 
        this.seleccionRealizada = true;
		this.controladorDos= true;
	
		this.fireChange();
	}

	highLightOption(options) {
		let classes = "slds-media slds-listbox__option slds-listbox__option_plain slds-media_small";

		return options.map((option, index) => {
			let cs = classes;
			let focused = "";
			if (index === this.highlightCounter) {
				cs = classes + " slds-has-focus";
				focused = "yes";
			}
			return {classes: cs, focused, ...option};
		});
	}

	renderedCallback() {
		this.template.querySelector("[data-focused='yes']")?.scrollIntoView();
	}
}