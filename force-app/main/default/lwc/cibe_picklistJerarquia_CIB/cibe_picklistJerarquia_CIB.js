import { LightningElement, api,track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin,CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistValues from '@salesforce/apex/CBK_CustomPicklist_Controller.picklistValues';
import getPicklistValuesDepen from '@salesforce/apex/CBK_CustomPicklist_Controller.picklistValuesDependency';
//CAMPOS
import NEGOCIOS_FIELD from '@salesforce/schema/Account.CIBE_Negocios__c';
import REDES_FIELD from '@salesforce/schema/Account.CIBE_RedesSegmentos__c';
import SECTOR_FIELD from '@salesforce/schema/Account.CIBE_SectoresPaises__c';
import CENTROS_FIELD from '@salesforce/schema/Account.CIBE_CentrosCarteras__c';
import ID_FIELD from '@salesforce/schema/Account.Id';
//Labels
import selecciona from '@salesforce/label/c.CIBE_SeleccionaOpcion';
import guardar from '@salesforce/label/c.CIBE_Guardar';
import negocio from '@salesforce/label/c.CIBE_Negocio';
import redeSeg from '@salesforce/label/c.CIBE_RedeSeg';
import sectorPai from '@salesforce/label/c.CIBE_SectorPais';
import centCar from '@salesforce/label/c.CIBE_CentroCartera';
import jerarCIB from '@salesforce/label/c.CIBE_jerarquiaCIB';

export default class cibe_picklistJerarquia_CIB extends NavigationMixin(LightningElement) {
	@track picklistValues;
	@track picklistValues2;
	@track picklistValues3;
    @track picklistValues4;

	@track inputValue;
    @track inputValue2;	
    @track inputValue3;
    @track inputValue4;
	//"Accordeon"
    @track showAlert = true;

	// Object
	@api inputObj = 'Account';
	// PicklistFields
	@api inputField = 'Negocios';
	@api inputField2  = 'Redes-Segmentos';
	@api inputField3  = 'Sectores-Paises';
    @api inputField4  = 'Centros-Carteras';

	@api labels = {guardar,negocio,redeSeg,sectorPai,centCar,jerarCIB}
	
	//Precarga valores campos
	@track negociosValue = selecciona;
	@track redesValue = selecciona;
	@track sectorValue = selecciona;
	@track centrosValue = selecciona;
	
	@api recordId;
	//Pre carga fields
	@wire(getPicklistValues, {inputField:'$inputField', inputObj: '$inputObj'})
		wiredPicklist({ data,error }){
        if(data){
			this.picklistValues = data;
        }
        if(error){ 
            this.picklistValues = undefined;
			console.log(error);

        }
    }

	@wire(getRecord,{recordId:'$recordId', fields:[NEGOCIOS_FIELD,REDES_FIELD,SECTOR_FIELD,CENTROS_FIELD]})
	wiredCentro({error,data}){
		if(data){
			if(data.fields.CIBE_Negocios__c.value != '' && data.fields.CIBE_Negocios__c.value != null){
				this.negociosValue = data.fields.CIBE_Negocios__c.value;
			}
			if(data.fields.CIBE_RedesSegmentos__c.value != '' && data.fields.CIBE_RedesSegmentos__c.value != null){
				this.redesValue = data.fields.CIBE_RedesSegmentos__c.value;
			}
			if(data.fields.CIBE_SectoresPaises__c.value != '' && data.fields.CIBE_SectoresPaises__c.value != null){
				this.sectorValue = data.fields.CIBE_SectoresPaises__c.value;
			}
			if(data.fields.CIBE_CentrosCarteras__c.value != '' && data.fields.CIBE_CentrosCarteras__c.value != null){
				this.centrosValue = data.fields.CIBE_CentrosCarteras__c.value;
			}
		}else if(error){
			console.log(error);
		}
	}
	// Fin precarga Fields

	// Selección de valores
	handleValueChange(event){
		console.log('picklist selected 1: ' + JSON.stringify(event.detail));
		this.inputValue = event.detail.value;
		this.getDependencyPicklist(this.inputField, this.inputValue, this.inputObj);
    }

	handleValueChange2(event){
		console.log('picklist selected 2: : ' + JSON.stringify(event.detail));
		this.inputValue2 = event.detail.value;
		this.getDependencyPicklist(this.inputField2, this.inputValue2, this.inputObj);
		//this.updateCentro();
    }

	handleValueChange3(event){
		console.log('picklist selected 3: ' + JSON.stringify(event.detail));
		this.inputValue3 = event.detail.value;
		this.getDependencyPicklist(this.inputValue2, this.inputValue3, this.inputObj);
		//this.updateCentro();
    }

    handleValueChange4(event){
		console.log('picklist selected 4: ' + JSON.stringify(event.detail));
		this.inputValue4 = event.detail.value;
		//this.updateCentro();
    }
	// FIN Selecion de valores

	//Obetener dependencias del valor de la picklist en función de su inputField
	getDependencyPicklist(inputFld, inputVal, inputObjt){
		getPicklistValuesDepen({inputField: inputFld, inputValue: inputVal, inputObj: inputObjt})
						.then((data) => {
								switch(inputVal){
									case this.inputValue:
										//this.picklistValues2 = data;
										this.picklistValues2 = JSON.parse(JSON.stringify(data));
										if(data === null || data.length === 0 ) {
											this.picklistValues3 = JSON.parse(JSON.stringify(data));
											this.picklistValues4 = JSON.parse(JSON.stringify(data));
										}
									break;
									case this.inputValue2:
										this.picklistValues3 = JSON.parse(JSON.stringify(data));
										if(data === null || data.length === 0 ) {
											this.picklistValues3 = JSON.parse(JSON.stringify(data));
										}									
									break;
                                    case this.inputValue3:
										this.picklistValues4 = JSON.parse(JSON.stringify(data));
										break;
								}
								//this.error = undefined;
							})
							.catch(error => {
								//this.error = error;
								console.log(error);
							}
						);
	}

	updateCentro() {
		/* corregir QC
        const allValid = [this.template.querySelectorAll('lightning-combobox')];
        */
		if (allValid) {
            // Create the recordInput object
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[NEGOCIOS_FIELD.fieldApiName] = this.template.querySelector("[data-field='negocio']").value;
            fields[REDES_FIELD.fieldApiName] = this.template.querySelector("[data-field='redes']").value;
			fields[SECTOR_FIELD.fieldApiName] = this.template.querySelector("[data-field='sectores']").value;
            fields[CENTROS_FIELD.fieldApiName] = this.template.querySelector("[data-field='centro']").value;
			const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Centro updated',
                            variant: 'success'
                        })
                    );
                    // Display fresh data in the form
                    return refreshApex(this.recordId);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
            }
        else {
            // The form is not valid
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Check your input and try again.',
                    variant: 'error'
                })
			);
        }
    }

	toggleShowAlerts() {
		this.alertsReaded = true;
		if(this.showAlert === false){
			this.showAlert = true;
		}else{
			this.showAlert = false;
		}
    }
}