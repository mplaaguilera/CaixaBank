import { LightningElement, track, wire, api } from 'lwc';
import getTarea from '@salesforce/apex/SIRE_LCMP_ConsultaFormDinamicoOPC.getTarea';


export default class Sire_lwc_ConsultaFormDinamicoOPC extends LightningElement {
    @api recordId;
    @track tituloFormulario = '';
   
    @track campos = [];
    @track respuestaUsuario = [];

    @track camposVisualizar;
    @track respuestasUsu;
   
    @track tareaId = null;
    @track tareaRecord = null;
    @track estadoTarea = null;
    
    @wire(getTarea, {
        tareaId: '$recordId'
    })wiredTarea(result) {
        this.wiredResultTarea = result;
        if(result.data){            
            this.tareaRecord = result.data;
            this.tareaId = this.tareaRecord.Id;
            if(this.tareaRecord.SIREC__SIREC_fld_codigo_tarea__c === 'OPC-ACUEPAGO' || this.tareaRecord.SIREC__SIREC_fld_codigo_tarea__c === 'OPC-PLANPAGO'){          
                this.estadoTarea = this.tareaRecord.SIREC__SIREC_fld_estado__c;
                this.tituloFormulario = this.tareaRecord.Name;            
                var respuestaSirec = JSON.parse(this.tareaRecord.SIR_FormularioOPC__c);       
                // Recorremos la informacion que ha pasado Sirec para crear un array de objetos (cada objeto será un input)
                for(let i = 0; i < respuestaSirec.length; i++){  
                    if(respuestaSirec[i].visible !== 'N'){               
                        var campo = [];
                        campo['formato'] = '';
                        campo['campoSelect'] = false;
                        campo['campoInput'] = false;
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
                        
                        campo['disabled'] = true;
                    }
                    if(this.tareaRecord.SIR_FormularioOPCResp__c != null && this.tareaRecord.SIR_FormularioOPCResp__c !== ''){ 
                        var objBBDD = JSON.parse(this.tareaRecord.SIR_FormularioOPCResp__c);
                        // Si el campo Visible == S creamos la variable vacia
                        if(respuestaSirec[i].visible !== 'N'){
                            var infoProvisional = objBBDD[Object.keys(objBBDD)[i]];
                            if(infoProvisional.search(/^([0-2][0-9]|(3)[0-1])(\/)(((0)[0-9])|((1)[0-2]))(\/)\d{4}$/) !== -1 ){                       
                                var date = infoProvisional;
                                var newdate = date.split("/").reverse().join("-");                                      
                                campo['valor'] = newdate;                     
                            } else {
                                var cambioEspacio = infoProvisional.replaceAll('\\n','\n');
                                campo['valor'] = cambioEspacio;
                            }	            
                        }
                        // Añadimos el campo en la array de respuesta con el valor de bbdd
                        var campoRespuestaBBDD = [];
                        campoRespuestaBBDD['codigoHito'] = respuestaSirec[i].codigoHito; 
                        campoRespuestaBBDD['valor'] = objBBDD[Object.keys(objBBDD)[i]];
                        this.respuestaUsuario.push(campoRespuestaBBDD);
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
            }       
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
}