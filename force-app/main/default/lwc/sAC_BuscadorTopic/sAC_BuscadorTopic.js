import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getResultados from '@salesforce/apex/SAC_LCMP_BuscadorTopic.getResultados';
import setTopicACase from '@salesforce/apex/SAC_LCMP_BuscadorTopic.setTopicACase';
import cargarDatos from '@salesforce/apex/SAC_LCMP_BuscadorTopic.cargarDatos';
import cargarEstado from '@salesforce/apex/SAC_LCMP_BuscadorTopic.cargarEstado';
import deleteTopicACase from '@salesforce/apex/SAC_LCMP_BuscadorTopic.deleteTopicACase';
import newTopic from '@salesforce/apex/SAC_LCMP_BuscadorTopic.newTopic';
import { NavigationMixin } from 'lightning/navigation'; 
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';

export default class SAC_BuscadorTopic extends NavigationMixin(LightningElement) {
    
    @track objects = [];
    @track error;
    @track mensaje;
    @track enteredValue;
    @track listadoTopics = [];
    @track desabilitado = false;
    @track isExpanded = false;
    @track mostrarModificarTopic = false;
    @track nuevoTopic = false;
    @track borrarTopic = false;
    @api recordId; 
    
    selectedItem = '';
    codigoTopicPulsado = '';
    indiceTopic;
    pillIndex;
    _wiredResult;

    @wire(cargarDatos, {idUsuario : Id, idCaso: '$recordId' })
    case(result){
        this._wiredResult = result;
        this.listadoTopics=[];
        this.mensaje = '';

        if(result.data){
            //this.desabilitado =(result.data.esPropietario) ? false : true;
            let topics = result.data.listaTopics;            
            for (var miTopic in topics) {      
                let topic = {
                    label : topics[miTopic].Name, 
                    alternativeText: topics[miTopic].Name,  
                    id:topics[miTopic].Id,
                    href: '/lightning/r/Topic/'+topics[miTopic].Id +'/view'
                };
                this.listadoTopics.push(topic);
            } 
        }           
    }

    buscarTopic(component, event, helper){

        let valorInput = this.template.querySelector("lightning-input");
        let filteKeyValue = valorInput.value;
        this.enteredValue = filteKeyValue;
         
        if(this.enteredValue === ''){
            this.objects = [];
            this.error = 'error';
        }else{

            getResultados({nombre: this.enteredValue}).then(result => {
                this.objects = [];
                this.error = '';
                if(result.length === 0){
                    this.error = error;
                }else{
                    for(let topic in result) {
                        if (result.hasOwnProperty(topic)) { 
                            var cadena = result[topic].Name; 
                            cadena=cadena.replace(/ /g,"%"); 
                            this.objects.push({value:result[topic].Name, cadena:cadena});
                        }
                    }
                }                
            })
            .catch(error => {
                this.error = error;
            });
        }
    }

    handleclick(event){
        
        this.codigoTopicPulsado = event.currentTarget.id;

        cargarEstado({idCaso: this.recordId}).then(result => {
            if(result.Status === 'SAC_001'){
                this.añadirTopic();
            }else{
                this.mostrarModificarTopic = true;
                this.nuevoTopic = true;
            }          
        })
        .catch(error => {
            this.error = error;
        });
    }

    confirmarModificarTopic(){
        this.mostrarModificarTopic = false;
        
        if(this.borrarTopic === true){
            this.eliminarTopic();
            this.borrarTopic = false;
        }else if(this.nuevoTopic === true){
            this.añadirTopic();
            this.nuevoTopic = false;
        }
    }

    añadirTopic(){
        this.mensaje = '';

        for (var i = 0; i < this.codigoTopicPulsado.length - 1; i++) {
            if (this.codigoTopicPulsado.charAt(i) == '-') {
                this.selectedItem = this.codigoTopicPulsado.substring(0, i);
            }
        }

        var cadena = this.selectedItem;
        cadena=cadena.replace(/%/g," ");

        setTopicACase({idCaso: this.recordId, topic : cadena}).then(result =>{ 
            this.objects = [];
            this.error = '';
            this.enteredValue = '';
            refreshApex(this._wiredResult);
        }).catch(error =>{
			this.mostrarToast('error', 'ERROR', JSON.stringify(error));
        })
    }

    teclaPulsada(event){
        if(event.keyCode === 13){
            let valorInput = this.template.querySelector("lightning-input");
            let filteKeyValue = valorInput.value;
            this.enteredValue = filteKeyValue;

            newTopic({topic : this.enteredValue}).then(result =>{ 
                if(result === true){
                    setTopicACase({idCaso: this.recordId, topic : this.enteredValue}).then(result =>{                    
                        this.objects = [];
                        this.error = '';
                        this.enteredValue = '';
                        refreshApex(this._wiredResult);
                    }).catch(error =>{
                        this.mostrarToast('error', 'ERROR', JSON.stringify(error));
                    })    
                }                
            }).catch(error =>{
                this.mensaje = 'Tema desactivado';
            })
        }
    }

    updateRecordView(recordId) {
        updateRecord({fields: { Id: recordId }});
    }

    handleItemRemove(event, data){ 

        this.indiceTopic = event.detail.index;
        this.pillIndex = event.detail.index ? event.detail.index : event.detail.name;

        cargarEstado({idCaso: this.recordId}).then(result => {
            if(result.Status === 'SAC_001'){
                this.eliminarTopic();
            }else{
                this.mostrarModificarTopic = true;
                this.borrarTopic = true;
            }         
        })
        .catch(error => {
            this.error = error;
        });
    }

    eliminarTopic(){
        this.mensaje = '';
        
        const itempill = this.listadoTopics;
        var idTopic = itempill[this.indiceTopic].id; 

        deleteTopicACase({topic: idTopic,  idCaso: this.recordId}).then(result=>{
            itempill.splice(this.pillIndex, 1);       
            this.listadoTopics = [...itempill];
            refreshApex(this._wiredResult);
        }).catch(error=>{
			this.mostrarToast('error', 'ERROR', JSON.stringify(error));
        })   
    }

    navigateToTopic(event) {

        event.preventDefault();
        var variableAuxiliarCodigoboton = event.currentTarget.id;
        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.topicId = variableAuxiliarCodigoboton.substring(0, i);
            }
        }
        event.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.topicId,
                "objectApiName": "Topic",
                "actionName": "view"
            }
        });

    }
    setExpanded(event){
        this.isExpanded = !this.isExpanded ;
    }

    cerrarModalModificar() {
        this.mostrarModificarTopic = false;
        this.borrarTopic = false;
        this.nuevoTopic = false;
    }

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}
}