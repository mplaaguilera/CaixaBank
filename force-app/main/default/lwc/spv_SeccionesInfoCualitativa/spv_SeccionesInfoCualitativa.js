import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import RECTYPE_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';
import Id_FIELD from '@salesforce/schema/Case.Id';

//Llamadas Apex
import getSeccionesYInfoCualitativa from '@salesforce/apex/SPV_LCMP_SeccionesInfoCualitativa.getSeccionesYInfoCualitativa';
import getSeccionesYInfoCualitativaManual from '@salesforce/apex/SPV_LCMP_SeccionesInfoCualitativa.getSeccionesYInfoCualitativaManual';
import setTopicACase from '@salesforce/apex/SPV_LCMP_SeccionesInfoCualitativa.setTopicACase';

const fields = [RECTYPE_FIELD, Id_FIELD];

export default class Spv_SeccionesInfoCualitativa extends LightningElement {

    @track desabilitado;
    @track ocultarBoton;
    @api recordId;
    @track mapaSecciones = [];
    @track listaTemas = [];
    @track esPretension;
    @track case;
    @track spinnerLoading = false;

    //Controlar subDesplegable de información cualitativa en las pretensiones
    @track toggleInfoCualitativa = "slds-section slds-is-open";
    @track expandirInfoCualitativa = true;



    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCase({error, data}){
        if(data){
            this.case = data;
            if(this.case.fields.RecordType.value.fields.DeveloperName.value == 'SPV_Pretension'){
                this.esPretension = true;
            }else if(this.case.fields.RecordType.value.fields.DeveloperName.value == 'SPV_Reclamacion'){
                this.esPretension = false;
            }
        }
    }

    get recordType() {
        return getFieldValue(this.case.data, RECTYPE_FIELD);
    }

    @wire(getSeccionesYInfoCualitativa, {idUsuario : Id, idCaso: '$recordId' })
    wiredInfoCualitativa(result){
        this.listaTemas = [];
        this.mapaSecciones = [];
        this.ocultarBoton = true;
        if(result.data != null && result.data != undefined){

            var conts = result.data;    //El mapa String(nombre sección) -  wrapper(elementos de info. cualitativa) recibido de la Apex
            for(var key in conts){
                this.mapaSecciones.push({value:conts[key], key: key});  //En value: se encuentra la lista de elementos de info. cualitativa que le corresponde a la sección: key
            }

            //Propietario si es una pretensión y es su owner o de la reclamación padre (Si es una reclamación, se cuenta como que no tiene permisos para editar desde ahí la info. cualitativa de las pretensiones)
            this.desabilitado = (this.mapaSecciones[0].value[0].esPropietario) ? false : true;      

            //Se recorren los temas de cada sección
            for(let acc of this.mapaSecciones){
                let listadoValores = acc.value;
                for(let valor of listadoValores){
                    if(valor.selecionado){ 
                        this.listaTemas.push(valor.name);   //Se añaden a esta lista solo los temas que hayan sido seleccionados
                    }                    
                }
            }    
        }

    }

    //Controlar cuando se pulsan las distintas checkbox (Solo en las pretensiones, las reclamaciones tienen los checkbox desactivados)
    handleChange(event) { 
        if(event.target.checked){
            this.listaTemas.push(event.target.value);
        }else{
            var index = this.listaTemas.indexOf(event.target.value); 
            this.listaTemas.splice(index,1);                //Elimina ese tema de la lista de los que hay marcados para esta pretensión
        }
        //Cuando se actualiza algún checkbox y si se es propietario, se dará la opción de guardar
        if(this.desabilitado == false){
            this.ocultarBoton = false;
        }

    }

    
    handleClick(event){   
        this.spinnerLoading = true;
        setTopicACase({idCaso: this.recordId, listaTopics : this.listaTemas}).then(result =>{ 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Marcas actualizadas',
                    message: 'Se han asignado correctamente las marcas al caso',
                    variant: 'success'
                }),
            );    
            this.spinnerLoading = false;      
            this.ocultarBoton = true;
            refreshApex(this.mapaSecciones);
        }).catch(error =>{
            this.spinnerLoading = false;
			this.mostrarToast('error', 'ERROR', JSON.stringify(error));
        })
    } 

    obtenerLista(){
        getSeccionesYInfoCualitativaManual({idUsuario : Id, idCaso: this.case.fields.Id.value}).then(result =>{ 
            this.listaTemas = [];
            this.mapaSecciones = [];
            if(result != null && result != undefined){
    
                var conts = result;    //El mapa String(nombre sección) -  wrapper(elementos de info. cualitativa) recibido de la Apex
                for(var key in conts){
                    this.mapaSecciones.push({value:conts[key], key: key});  //En value: se encuentra la lista de elementos de info. cualitativa que le corresponde a la sección: key
                }
    
                //Propietario si es una pretensión y es su owner o de la reclamación padre (Si es una reclamación, se cuenta como que no tiene permisos para editar desde ahí la info. cualitativa de las pretensiones)
                this.desabilitado = (this.mapaSecciones[0].value[0].esPropietario) ? false : true;      
    
                //Se recorren los temas de cada sección
                for(let acc of this.mapaSecciones){
                    let listadoValores = acc.value;
                    for(let valor of listadoValores){
                        if(valor.selecionado){ 
                            this.listaTemas.push(valor.name);   //Se añaden a esta lista solo los temas que hayan sido seleccionados
                        }                    
                    }
                }    
            }
            this.expandirInfoCualitativa = true;
            this.toggleInfoCualitativa = "slds-section slds-is-open";
        }).catch(error =>{
            this.spinnerLoading = false;
            this.mostrarToast('error', 'ERROR', JSON.stringify(error));
        })
    }

    handleExpandirInfoCualitativa(){
        if(this.expandirInfoCualitativa){
            this.expandirInfoCualitativa = false;
            this.toggleInfoCualitativa = "slds-section";
            this.ocultarBoton = true;
        }else{
            this.obtenerLista();
        }
    }

    
    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}

}