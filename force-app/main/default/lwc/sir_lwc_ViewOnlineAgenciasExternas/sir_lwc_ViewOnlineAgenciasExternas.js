import { LightningElement, track, api } from 'lwc';
import callWS from '@salesforce/apex/SIR_LCMP_ViewOnlineAgenciasExternas.callWSAgenciasExternas';

const columns = [
    { label: 'Fecha/Hora', fieldName: 'fechaHora', wrapText: true, initialWidth: 80 },
    { label: 'Acción', fieldName: 'accion', wrapText: true, initialWidth: 100 },
    { label: 'Resultado', fieldName: 'resultado', wrapText: true, initialWidth: 200 },
    { label: 'Interviniente', fieldName: 'interviniente', initialWidth: 100},
    { label: 'Contacto', fieldName: 'contacto', initialWidth: 100},
    { label: 'Comentarios gestión agencia externa', fieldName: 'comentarios', wrapText: true}
];

export default class Sir_lwc_ViewOnlineAgenciasExternas extends LightningElement {   
    @api recordId;
    // Variable que nace como True pero que si el lwc que lo llame le puede pasar a false
    @api historico;   
   
    @track icono = 'utility:chevronright';
    @track datosProcesos = [];    
	@track idPropuesta = '';
    @track datosCabecera = [];
    @track cabecera = [];  
    columns = columns;
    data = [];
    @track mensaje = 'No existen registros asociados.';

    // Variables booleanas mostrar secciones en Front
    @track cabeceraProcesoActivo;
    @track abrirComponente = false;
    @track mostrarInfo = false;
    @track vacio = false;
    @track mensajeKO = false;
    @track loadingVisible = true;
    // Variables información error
    @track mensajeError = '';
    @track codigoError = '';
      
  
    connectedCallback(){ 
        this.loadingVisible = true;
        // Si Historico = true --> cabecera oculta, historico = false --> cabecera visible 
        if(this.historico === "false"){
            this.cabeceraProcesoActivo = true;  
            this.historico = false;  
        } else {
            this.cabeceraProcesoActivo = false;
            this.historico = true;
        } 
            
        callWS({recordId: this.recordId, historico: this.historico}).then(result => {
            if(result !== undefined && result.length >= 0){                 	
				//Si el resultado del WS es OK
				if(result[0] === 'OK'){   
                    if(result[1] != null){                  
                        // Si hay procesos en Agencias Externas
                        if(result[1].procesos.length >= 0){
                            for(let i = 0; i < result[1].procesos.length; i++){                         
                                let registro = [];                                            
                                // TABLA PROCESOS
                                registro.numRegistro = i+1;
                                registro.icono = 'utility:chevronright';
                                registro.nombreProceso = result[1].procesos[i].proceso.nombreProceso;
                                registro.situacion = result[1].procesos[i].proceso.situacion;
                                registro.fechaSituacion = result[1].procesos[i].proceso.fechaSituacion;
                                registro.gestor = result[1].procesos[i].proceso.gestor;
                                registro.fechaInicio = result[1].procesos[i].proceso.fechaInicio;                         
                                if(result[1].procesos[i].proceso.idPropuesta != null && result[1].procesos[i].proceso.idPropuesta !== ''){                
                                    // Para mostrar la lupa
                                    registro.idPropuesta = result[1].procesos[i].proceso.idPropuesta;                                    
                                    registro.verDetalles = true;
                                } 
                                // Para hacer que cambien los iconos para saber de que proceso es la cabecera
                                if(this.historico === false){                              
                                    if(i === 0){
                                        registro.iconoCabecera = 'standard:form';
                                        registro.titleIconoCabecera = 'La cabecera contiene la información de este Proceso';                        
                                    } else {
                                        registro.iconoCabecera = 'standard:document';
                                        registro.titleIconoCabecera = 'Pulsa para ver en la cabecera la información de este Proceso';  
                                    }
                                } else {
                                    registro.iconoCabecera = 'standard:document';                                
                                }                         
                                registro.acciones = [];                           
                        
                                if(result[1].procesos[i].accionesProceso != null && result[1].procesos[i].accionesProceso.length > 0){ 
                                    // TABLA ACCIONES
                                    for(let j = 0; j < result[1].procesos[i].accionesProceso.length; j++){  
                                        let registroAccion = [];                   
                                        registroAccion.numRegistro = i+1;                     
                                        registroAccion.fechaHora = result[1].procesos[i].accionesProceso[j].fechaHora;
                                        registroAccion.accion = result[1].procesos[i].accionesProceso[j].accion;  
                                        registroAccion.resultado = result[1].procesos[i].accionesProceso[j].resultado;                     
                                        registroAccion.interviniente = result[1].procesos[i].accionesProceso[j].personaContactada;
                                        registroAccion.contacto = result[1].procesos[i].accionesProceso[j].contacto;
                                        registroAccion.comentarios = result[1].procesos[i].accionesProceso[j].comentarioGestor; 
                                        registro.acciones.push(registroAccion);             
                                    } 
                                }                           
                                this.datosProcesos.push(registro);
                                
                                if(this.historico === false){
                                    let registroCabecera = [];
                                    // PROCESO ACTIVO CABECERA - COLUMNA 1                           
                                    registroCabecera.unoSituacion = result[1].procesos[i].situacionGestionExterna.situacion;
                                    registroCabecera.unoFecha = result[1].procesos[i].situacionGestionExterna.fecha;               
                                    registroCabecera.unoAgencia = result[1].procesos[i].situacionGestionExterna.agencia;
                                    registroCabecera.unoFechaInicioGestion = result[1].procesos[i].situacionGestionExterna.fechaInicioGestion;                   
                                    
                                    // PROCESO ACTIVO CABECERA - COLUMNA 2                            
                                    registroCabecera.dosAccion = result[1].procesos[i].ultimaAccionProceso.accion;
                                    registroCabecera.dosFechaHora = result[1].procesos[i].ultimaAccionProceso.fechaHora;                    
                                    registroCabecera.dosTelefono = result[1].procesos[i].ultimaAccionProceso.contacto;
                                    registroCabecera.dosInterviniente = result[1].procesos[i].ultimaAccionProceso.interviniente;
                                    registroCabecera.dosResultado = result[1].procesos[i].ultimaAccionProceso.resultado;
                                    registroCabecera.dosComentarioGestor = result[1].procesos[i].ultimaAccionProceso.comentarioGestor; 
                                    
                                    // PROCESO ACTIVO CABECERA - COLUMNA 3                                      
                                    registroCabecera.tresAccion = result[1].procesos[i].ultimaAccionContacto.accion;
                                    registroCabecera.tresFechaHora = result[1].procesos[i].ultimaAccionContacto.fechaHora;                    
                                    registroCabecera.tresContacto = result[1].procesos[i].ultimaAccionContacto.contacto;
                                    registroCabecera.tresInterviniente = result[1].procesos[i].ultimaAccionContacto.interviniente;
                                    registroCabecera.tresResultado = result[1].procesos[i].ultimaAccionContacto.resultado;
                                    registroCabecera.tresComentario = result[1].procesos[i].ultimaAccionContacto.comentarioGestor;
                                    
                                    this.datosCabecera.push(registroCabecera);                
                                }                                   
                            }  
                            if(this.historico === false){       
                                this.cabecera.push(this.datosCabecera[0]);
                            }
                            this.loadingVisible = false;
                            this.mostrarInfo = true;
                        }
                    } else {
                        this.loadingVisible = false;
                        // Si no hay Procesos en Agencias Externas
                        this.vacio = true; 
                    }                    
                } else {
                    if(result.length > 0){
                        this.loadingVisible = false;
                        this.mensajeError = result[1];
                        this.codigoError = result[2];
                        this.mostrarInfo = false; 
                        this.vacio = false;  
                        this.mensajeKO = true;
                    } else { 
                        this.mensaje = 'No se puede consultar. No existe relación de la persona con procesos de Recuperación de la deuda o Preventivo.';
                        this.loadingVisible = false;                    
                        this.mostrarInfo = false; 
                        this.vacio = true;  
                        this.mensajeKO = false;
                    }                    
                }
            } else if(result.error){
                this.loadingVisible = false;
                this.mensajeError = result.body.message;
                this.codigoError = result.body.stackTrace;
                this.mostrarInfo = false;  
                this.vacio = false; 
                this.mensajeKO = true;
            }
        })
        .catch(error => {
            console.log('Error');
            console.log(error);            
        }); 
    }
    
    // Para extender o contraer las Acciones de los Procesos
    extenderContraer(event) {
        // Se resta 1 ya que la array empieza por cero
        var numRegistro = parseInt(event.target.name, 10) - 1;     
        var clase = ".ocultos[data-recid='" + event.target.name + "']";
        var elemento = this.template.querySelector(clase); 
        // Si el icono esta plegado
        if(this.datosProcesos[parseInt(numRegistro, 10)].icono === 'utility:chevronright'){
            // Quitamos la clase oculto, para mostrar la tr y ponemos el icono desplegado
            elemento.classList.remove('ocultos');                
            this.datosProcesos[parseInt(numRegistro, 10)].icono = 'utility:chevrondown'; 
        } else {  
            // Buscamos la clase claseIdentificador y pondremos la clase oculto y plegaremos el icono
            let clase2 = ".claseIdentificados[data-recid='" + event.target.name + "']";
            let elemento2 = this.template.querySelector(clase2);            
            elemento2.classList.add('ocultos'); 
            this.datosProcesos[parseInt(numRegistro, 10)].icono = 'utility:chevronright';        
        }
    }

    // Cambia la información de la cabecera (3 columnas de proceso activo) y cambia de color el icono para saber que información estamos visualizando
    infoCabecera(event) {
        // Se resta 1 ya que la array empieza por cero
        var numRegistro = parseInt(event.target.name, 10) - 1; 
        this.cabecera = [];
        this.cabecera.push(this.datosCabecera[numRegistro]);
        for(let i = 0; i < this.datosProcesos.length; i++){      
            if(i === numRegistro){
                this.datosProcesos[i].iconoCabecera = 'standard:form';
                this.datosProcesos[i].titleIconoCabecera = 'La cabecera contiene la información de este Proceso'; 
            } else {
                this.datosProcesos[i].iconoCabecera = 'standard:document';
                this.datosProcesos[i].titleIconoCabecera = 'Pulsa para ver en la cabecera la información de este Proceso';  
            }       
        }                     
    }

    // Llama al LWC de Sir_lwc_ViewOnlineAcuPagoPlanPago
    verDetalles(event){
        this.abrirComponente = true;
		this.idPropuesta = event.target.value;
    }

    // Sirve para cerrar el modal del lwc incrustado
    cerrarComponente(){
        this.abrirComponente = false;
    }
}