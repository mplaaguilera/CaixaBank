import { LightningElement, wire, api, track } from 'lwc';
import cargarDatosOCS from '@salesforce/apex/SAC_LCMP_InformacionCualitativa.cargarDatosOCS';
import setTopicACase from '@salesforce/apex/SAC_LCMP_InformacionCualitativa.setTopicACase';
import Id from '@salesforce/user/Id';
import RECTYPE_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [RECTYPE_FIELD];

export default class SAC_SeccionesInfoCualitativa extends LightningElement {
    @track desabilitado;
    @api recordId;
    @track mapaSecciones = [];
    @track listaTemas = [];

    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    get recordType() {
        return getFieldValue(this.case.data, RECTYPE_FIELD);
    }

    @wire(cargarDatosOCS, {idUsuario : Id, idCaso: '$recordId' })
    wireSecciones(result){
        this.listaTemas = [];
        if(result.data){
            var conts = result.data;
            for(var key in conts){
                this.mapaSecciones.push({value:conts[key],key:key});
            } 
            //this.desabilitado = (this.mapaSecciones[0].value[0].esPropietario && this.recordType == 'SAC_Pretension') ? false : true; 
            this.desabilitado = (this.mapaSecciones[0].value[0].esPropietario) ? false : true;  
            for(let acc of this.mapaSecciones){
                let listadoValores = acc.value;
                for(let valor of listadoValores){
                    if(valor.Selecionado){ 
                        this.listaTemas.push(valor.Name);
                    }                    
                }
            }            
        }
    }

    handleChange(e) { 
        if(e.target.checked){
            this.listaTemas.push(e.target.value);
        }else{
            var index = this.listaTemas.indexOf(e.target.value); 
            this.listaTemas.splice(index,1);
        }
    }

    handleClick(e){   
        setTopicACase({idCaso: this.recordId, listaTopics : this.listaTemas}).then(result =>{ 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Marcas actualizadas',
                    message: 'Se han asignado correctamente las marcas al caso',
                    variant: 'success'
                }),
            );          
            refreshApex(this.mapaSecciones);
        }).catch(error =>{
			this.mostrarToast('error', 'ERROR', JSON.stringify(error));
        })
    } 

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}
}