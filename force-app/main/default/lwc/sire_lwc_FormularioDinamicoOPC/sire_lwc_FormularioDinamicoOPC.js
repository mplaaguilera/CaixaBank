import { LightningElement, track, wire, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getTarea from '@salesforce/apex/SIRE_LCMP_FormularioDinamicoOPC.getTarea';
import updateTarea from '@salesforce/apex/SIRE_LCMP_FormularioDinamicoOPC.updateTarea';


export default class Sire_lwc_FormularioDinamicoOPC extends LightningElement {
    @api recordId;
    @track tituloFormulario = '';    

    @track campos = [];
    @track respuestaUsuario = [];

    @track camposVisualizar;
    @track respuestasUsu;

    @track nombreBoton = 'Guardar y enviar';
    @track tareaId = null;
    @track tareaRecord = null;
    @track estadoTarea = null;

    @track formularioVisible = false;
    @track mensajeError = null;
    @track codigoError = null;
    @track mensajeKO = false;

    @track disabledGuardar = true;
    @track disabledCerrar = true;
    
    @wire(getTarea, {
        procesoId: '$recordId'
    })wiredTarea(result) {
        this.wiredResultTarea = result;
        if(result.data){            
            this.tareaRecord = result.data;
            this.tareaId = this.tareaRecord.SIREC__SIREC_fld_tareaOPCPendiente__c;
            this.estadoTarea = this.tareaRecord.SIREC__SIREC_fld_tareaOPCPendiente__r.SIREC__SIREC_fld_estado__c;
            this.tituloFormulario = this.tareaRecord.SIREC__SIREC_fld_tareaOPCPendiente__r.Name;
            var respuestaSirec = JSON.parse(this.tareaRecord.SIREC__SIREC_fld_tareaOPCPendiente__r.SIR_FormularioOPC__c);            
            // Recorremos la informacion que ha pasado Sirec para crear un array de objetos (cada objeto será un input)
            for(let i = 0; i < respuestaSirec.length; i++){  
                // Si el campo Visible != N se muestra en el frontal  
                if(respuestaSirec[i].visible !== 'N'){          
                    var campo = [];
                    campo['formato'] = '';
                    campo['campoSelect'] = false;
                    campo['campoInput'] = false;
                    campo['campoTextArea'] = false;                    
                
                    if(respuestaSirec[i].tipoCampo === 'input-text' && respuestaSirec[i].tipoCampoFront === 'TEXTO'){
                        campo['tipo'] = 'text';
                        campo['campoInput'] = true;
                        campo['anchoCampo'] = 'max-width: 300px;';
                    } else if(respuestaSirec[i].tipoCampo === 'input-text' && respuestaSirec[i].tipoCampoFront === 'IMPORTE'){
                        campo['tipo'] = 'number';
                        campo['formato'] = 'currency';
                        campo['step'] = '.01';
                        campo['campoInput'] = true;
                        campo['anchoCampo'] = 'max-width: 250px;';
                    } else if(respuestaSirec[i].tipoCampo === 'input-text' && respuestaSirec[i].tipoCampoFront === 'NUMERO'){
                        campo['tipo'] = 'number';
                        campo['campoInput'] = true;
                        campo['anchoCampo'] = 'max-width: 250px;';
                    } else if(respuestaSirec[i].tipoCampo === 'input-number' && respuestaSirec[i].tipoCampoFront === 'NUMERO'){
                        campo['tipo'] = 'number';
                        campo['campoInput'] = true;
                        campo['anchoCampo'] = 'max-width: 250px;';
                    } else if(respuestaSirec[i].tipoCampo === 'datepicker'){
                        campo['tipo'] = 'date';
                        campo['campoInput'] = true;
                        if(respuestaSirec[i].label.length > 25){
                            campo['anchoCampo'] = 'max-width: 200px;';
                        } else {
                            campo['anchoCampo'] = 'max-width: 150px;';
                        }
                    } else if(respuestaSirec[i].tipoCampo === 'select'){
                        campo['campoSelect'] = true;                        
                        var opcionesSelect = [];
                        for(let j = 0; j < respuestaSirec[i].opciones.length; j++){  
                            opcionesSelect.push({'label': respuestaSirec[i].opciones[j].text, 'value': respuestaSirec[i].opciones[j].value});
                        }               
                        campo['opciones'] = opcionesSelect;
                        campo['anchoCampo'] = 'max-width: 300px;';
                    } else if(respuestaSirec[i].tipoCampo === 'text-area' && respuestaSirec[i].tipoCampoFront === 'TEXTO'){
                        campo['campoTextArea'] = true;
                        campo['anchoCampo'] = 'max-width: 537px;';
                    }
                    campo['label'] = respuestaSirec[i].label;
                    campo['value'] = ''; 
                    campo['orden'] = respuestaSirec[i].ordenPantalla;  
                    campo['codigoHito'] = respuestaSirec[i].codigoHito; 
                    campo['identificador'] = respuestaSirec[i].identificador; 
                
                    if(respuestaSirec[i].requerido === 'S'){
                        campo['requerido'] = true; 
                    } else {
                        campo['requerido'] = false;  
                    }
                    campo['dependientes'] = respuestaSirec[i].dependientes; 
                    campo['idDependencia'] = respuestaSirec[i].idDependencia; 
                    campo['valorDependencia'] = respuestaSirec[i].valorDependencia; 
                    campo['valorDependencia2'] = respuestaSirec[i].valorDependencia2; 
                    if(respuestaSirec[i].idDependencia != null){
                        campo['disabled'] = true; 
                    } else {
                        campo['disabled'] = false; 
                    }                    
                }
                // En caso de que haya info en SIR_FormularioOPCResp__c.  Y se cambia el botón Guardar y Enviar por Enviar
                if(this.tareaRecord.SIREC__SIREC_fld_tareaOPCPendiente__r.SIR_FormularioOPCResp__c != null){  
                    var objBBDD = JSON.parse(this.tareaRecord.SIREC__SIREC_fld_tareaOPCPendiente__r.SIR_FormularioOPCResp__c);                     
                    if(respuestaSirec[i].visible !== 'N'){
                        var infoProvisional = objBBDD[Object.keys(objBBDD)[i]];
                        if(infoProvisional.search(/^([0-2][0-9]|(3)[0-1])(\/)(((0)[0-9])|((1)[0-2]))(\/)\d{4}$/) != -1 ){                       
                            var date = infoProvisional;
                            var newdate = date.split("/").reverse().join("-");                                      
                            campo['valor'] = newdate;
                        } else {
                            campo['valor'] = infoProvisional.replaceAll('\\n','\n');                   
                        }  
                    }
                    this.nombreBoton = 'Enviar';
                    // Añadimos el campo en la array de respuesta con el valor de bbdd
                    var campoRespuestaBBDD = [];
                    campoRespuestaBBDD['codigoHito'] = respuestaSirec[i].codigoHito;
                    campoRespuestaBBDD['valor'] = objBBDD[Object.keys(objBBDD)[i]].replaceAll('\\n','\n');
                    this.respuestaUsuario.push(campoRespuestaBBDD);           
                } else {
                    // Añadimos el campo en la array de respuestas
                    var campoRespuestaVacio = [];
                    campoRespuestaVacio['codigoHito'] = respuestaSirec[i].codigoHito;
                    // Si el campo Visible != N creamos la variable vacia
                    if(respuestaSirec[i].visible !== 'N'){
                        campoRespuestaVacio['valor'] = '';                   
                    } else {          
                        // creamos la variable con la informacion del campo Codigo 
                        campoRespuestaVacio['valor'] = respuestaSirec[i].codigo;
                    }   
                    this.respuestaUsuario.push(campoRespuestaVacio);                    
                } 
                if(respuestaSirec[i].visible !== 'N'){    
                    this.campos.push(campo);
                }
            }
            // Ordenamos la variable de front para mostrar los campos tal como nos indica Sirec        
            let cloneData = [...this.campos];
            cloneData.sort(this.sortBy('orden', 1, undefined));
            this.campos = cloneData;  
            
            for(let i = 0; i < this.campos.length; i++){  
                if(this.campos[i].campoTextArea === true){
                    this.campos[i].claseColumnas = 'slds-col slds-size_12-of-12';
                } else {
                    this.campos[i].claseColumnas = 'slds-col slds-size_6-of-12';
                }
            }

            //Se muestra el formulario y los botones
            this.formularioVisible = true; 
            this.disabledGuardar = false;
            this.disabledCerrar = false;         
           
        } else if(result.error){
            this.formularioVisible = false;
            this.mensajeKO = true;
            this.mensajeError = result.error;
        }
    }


    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };
        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };        
    }

    getCambioValor(event){     
		var dependencia = '';
        // Recorremos la array de respuestasUsuario y si el name del input es igual al idPregunta pondremos el value que ha introducido el usuario
        for(let i = 0; i < this.respuestaUsuario.length; i++){ 
            if(event.target.name === this.respuestaUsuario[i].codigoHito){
                if(event.target.value.search(/[1-9][0-9][0-9]{2}-([0][1-9]|[1][0-2])-([1-2][0-9]|[0][1-9]|[3][0-1])/) !== -1 ){
                    var fechaProvisional = new Date(event.target.value);
                    var opciones = { year: 'numeric', month: 'numeric', day: 'numeric' };
                    var fechaParaBBDD = fechaProvisional.toLocaleString('en-GB', opciones);                    
                    this.respuestaUsuario[i].valor = fechaParaBBDD; 
                } else {
                    this.respuestaUsuario[i].valor = event.target.value;
                }	                	
				dependencia = this.respuestaUsuario[i].codigoHito;		
            }            
        }
		var identificadorDependencia = '';
		for(let i = 0; i < this.campos.length; i++){
			if(dependencia === this.campos[i].codigoHito && this.campos[i].dependientes != null){
				identificadorDependencia = this.campos[i].dependientes[0].identificador[0];
			}
		}
		for(let i = 0; i < this.campos.length; i++){
			if(this.campos[i].idDependencia != null && identificadorDependencia === this.campos[i].identificador){
				if(event.target.value === this.campos[i].valorDependencia || event.target.value === this.campos[i].valorDependencia2){
					this.campos[i].requerido = true;
					this.campos[i].disabled = false;
				} else if(event.target.value !== this.campos[i].valorDependencia && event.target.value !== this.campos[i].valorDependencia2){
					this.campos[i].requerido = false;
					this.campos[i].disabled = true;
				}				
			}			
		}	
    }


    guardar(){	        
        if(this.estadoTarea === 'En curso'){            
            const allValidInput = [
                ...this.template.querySelectorAll('lightning-input'),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                if( (inputCmp.value === '' || inputCmp.value === ' ') && inputCmp.required === true){
                    return false;
                } else {
                    return validSoFar && inputCmp.checkValidity();
                }            
            }, true);
            const allValidSelect = [
                ...this.template.querySelectorAll('lightning-combobox'),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                if( (inputCmp.value === '' || inputCmp.value === ' ') && inputCmp.required === true){
                    return false;
                } else {
                    return validSoFar && inputCmp.checkValidity();
                }            
            }, true);

            if(allValidInput && allValidSelect){
                this.botonGuardarDisabled = false;
            } else {
                this.botonGuardarDisabled = true;
            }
        } else {
            // Cuando la tarea está pendiente sincro no validamos los campos
            this.botonGuardarDisabled = false;
        }

        if(this.botonGuardarDisabled === false){           
            this.disabledCerrar = true;
            this.disabledGuardar = true;
            var respuesta;
            for(let i = 0; i < this.respuestaUsuario.length; i++){ 
                if(respuesta === undefined){
                    respuesta = '"' + this.respuestaUsuario[i].codigoHito + '":"'+ this.respuestaUsuario[i].valor + '"';	
                } else {
                    respuesta = respuesta + ',"' + this.respuestaUsuario[i].codigoHito + '":"'+ this.respuestaUsuario[i].valor + '"';	
                }                           
            }
            respuesta = '{' + respuesta + '}';  
            respuesta = respuesta.replace(/\n/g, '\\\\n');  
            updateTarea({tareaId: this.tareaId, respuesta: respuesta}).then(result => {
                if(result.length >= 0){
                    //Si el resultado del WS es OK 
                    if(result[0] === 'OK'){                    
                        this.formularioVisible = false;
                        this.dispatchEvent(new CustomEvent('siguiente'));
                    } else { //Si el resultado del WS es KO se muestra el error
                        //Se oculta el formulario
                        this.formularioVisible = false;
                        //Se muestra el error
                        this.mensajeKO = true;
                        this.mensajeError = result[1];
                        this.codigoError = result[2];
                        this.disabledCerrar = false;
                    }   
                }  
            })
            .catch(error => {
                //Se oculta el formulario
                this.formularioVisible = false;
                //Se muestra el error
                this.mensajeKO = true;
                this.mensajeError = 'Se ha producido un problema. Por favor, pongase en contacto con su Administrador del sistema. ' + error;
                this.disabledCerrar = false;
            });
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        window.location.reload();
    }  
}