import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getTarea from '@salesforce/apex/SIR_LCMP_ListaContratosOPC.getTarea';
import updateTarea from '@salesforce/apex/SIR_LCMP_ListaContratosOPC.updateTarea';

const columns = [
    { label: 'Contrato', fieldName: 'numeroContrato', type: 'text', typeAttributes: { tooltip: { fieldName: 'idCuenta' } }},
    { label: 'Nombre titular', fieldName: 'nombreTitular', type: 'text'}  
];

export default class Sir_lwc_ListaContratosOPC extends LightningElement {

    columns = columns;
    @api recordId;
    @track titulo = '';    

    @track nombreBoton = 'Guardar y enviar';
    @track tareaId = null;
    @track tareaRecord = null;
    

    @track listaContratos = [];
    @track listaContratosPreSelect = [];
    @track listaContratosSeleccionados = [];
    @track listaContratosNoSeleccionados = [];
    @track listaContratosSelecFront = [];

    @track listaVisible = false;
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
            this.tareaId = this.tareaRecord.SIREC__SIREC_fld_tarea__c;
            this.titulo = this.tareaRecord.SIREC__SIREC_fld_tarea__r.Name;
            var respuestaSirec = JSON.parse(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIR_FormularioOPC__c);              
            // Recorremos la informacion que ha pasado Sirec para crear un array de objetos (cada objeto será un input)           
            let currentData = [];
            let noSelected = [];
            for (let i = 0; i < respuestaSirec.length; i++) {
                let rowData = {};                                             
                rowData.idCuenta = respuestaSirec[i].idCuenta;   
                rowData.numeroContrato = respuestaSirec[i].numeroContrato;  
                rowData.nombreTitular = respuestaSirec[i].nombreTitular;                              
                currentData.push(rowData);
                noSelected.push(respuestaSirec[i].idCuenta);
            }      
            this.listaContratos = currentData; 
             
            // En caso de que haya info en SIR_FormularioOPCResp__c.  Se cambia el botón Guardar y Enviar por Enviar
            if(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIR_FormularioOPCResp__c != null){                  
                var objBBDD = JSON.parse(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIR_FormularioOPCResp__c);
                let idSelected = [];
                let idNoSelected = [];
                let hayContratosEnBBDD = false;
                for (let i = 0; i <  this.listaContratos.length; i++) {                    
                    for (let j = 0; j < objBBDD.idOpcSeleccionados.length; j++) {  
                        if(JSON.stringify(objBBDD.idOpcSeleccionados[j]) === ('"' + this.listaContratos[i].idCuenta + '"')){                                                              
                            idSelected.push(this.listaContratos[i].idCuenta);  
                            hayContratosEnBBDD = true;                                                                                                                
                        }
                    }
                    for (let j = 0; j < objBBDD.idOpcNoSeleccionados.length; j++) {                                            
                        if(JSON.stringify(objBBDD.idOpcNoSeleccionados[j]) === this.listaContratos[i].idCuenta){
                            idNoSelected.push(this.listaContratos[i].idCuenta); 
                        }
                    }                                
                }   
                this.listaContratosSeleccionados = idSelected;            
                this.listaContratosPreSelect = idSelected;
                
                this.listaContratosNoSeleccionados = idNoSelected;
                if(hayContratosEnBBDD === true){                    
                    this.nombreBoton = 'Enviar';
                    this.disabledGuardar = false;
                } else {
                    this.disabledGuardar = true;
                } 
            } else {
                this.listaContratosNoSeleccionados = noSelected; 
                this.disabledGuardar = true;
            }              
            //Se muestra la lista y los botones
            this.listaVisible = true;                     
            this.disabledCerrar = false;
        } else if(result.error){
            this.listaVisible = false;
            this.mensajeKO = true;
            this.mensajeError = result.error;
        }
    }

    // Recogemos los idCuenta de las filas seleccionadas
    getSelectedContratos(event) {    
        this.listaContratosSeleccionados = [];
        this.listaContratosSelecFront = [];
        const selectedRows = event.detail.selectedRows;        
        for (let i = 0; i < selectedRows.length; i++){
            this.listaContratosSeleccionados.push(selectedRows[i].idCuenta); 
            this.listaContratosSelecFront.push(selectedRows[i].numeroContrato);                       
        }             
        if(this.listaContratosSeleccionados.length !== 0){
            this.disabledGuardar = false; 
        } else {
            this.disabledGuardar = true; 
        }        
    }

    guardar(){
        this.disabledCerrar = true;
        this.disabledGuardar = true;    
        this.listaContratosNoSeleccionados = [];   
        for (let j = 0; j < this.listaContratos.length; j++){  
            this.listaContratosNoSeleccionados.push(this.listaContratos[j].idCuenta);   
        }               
        for (let j = 0; j < this.listaContratosNoSeleccionados.length; j++){  
            for (let i = 0; i < this.listaContratosSeleccionados.length; i++){               
                if(this.listaContratosSeleccionados[i] === this.listaContratosNoSeleccionados[j]){ 
                    let index = this.listaContratosNoSeleccionados.indexOf(this.listaContratosSeleccionados[j]);                  
                    this.listaContratosNoSeleccionados.splice(index, 1);
                }                
            }
        } 
        let respuestaParaFront = 'Contratos Seleccionados: \n';  
        for(let i = 0; i < this.listaContratosSelecFront.length; i++){              
            respuestaParaFront = respuestaParaFront + this.listaContratosSelecFront[i] + '\n';                         
        }                  
        let respuesta = '"idOpcSeleccionados": [';
        for(let i = 0; i < this.listaContratosSeleccionados.length; i++){ 
            if(i === 0){
                respuesta = respuesta + '"' + this.listaContratosSeleccionados[i] + '"';                
            } else {
                respuesta = respuesta + ',"' + this.listaContratosSeleccionados[i] + '"';	                
            }                         
        }
        respuesta = respuesta + '], "idOpcNoSeleccionados": ['
        for(let i = 0; i < this.listaContratosNoSeleccionados.length; i++){ 
            if(i === 0){
                respuesta = respuesta + '"' + this.listaContratosNoSeleccionados[i] + '"';	
            } else {
                respuesta = respuesta + ',"' + this.listaContratosNoSeleccionados[i] + '"';     	
            }                           
        }
        respuesta = respuesta + ']'       
        respuesta = '{' + respuesta + '}';        
        updateTarea({tareaId: this.tareaId, respuesta: respuesta, respuestaParaFront: respuestaParaFront}).then(result => {
            if(result.length >= 0){
                //Si el resultado del WS es OK 
                if(result[0] === 'OK'){                  
                    this.listaVisible = false;
                    this.dispatchEvent(new CustomEvent('siguiente'));
                }
                //Si el resultado del WS es KO se muestra el error
                else{
                    //Se oculta el formulario
                    this.listaVisible = false;
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
            this.listaVisible = false;
            //Se muestra el error
            this.mensajeKO = true;
            this.mensajeError = 'Se ha producido un problema. Por favor, pongase en contacto con su Administrador del sistema. ' + error;
            this.disabledCerrar = false;
        });
    }

    // Cerrar el modal y refrescar pantalla
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        window.location.reload();
    }
}