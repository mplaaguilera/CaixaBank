import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import {createRecord, getRecord, updateRecord, getFieldValue} from 'lightning/uiRecordApi';
//import {listMCC} from 'c/sac_BuscadorMCC'
import Id from "@salesforce/user/Id";   //Para obtener el currentUser id
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case';
import insertarPretensionPrincipal from '@salesforce/apex/SPV_LCMP_InsertarPretension.insertarPretensionPrincipal'; //Import de la clase Apex para poder usar el método insertarPretensionPrincipal
import insertarPretensiones from '@salesforce/apex/SPV_LCMP_InsertarPretension.insertarPretensiones'; //Import de la clase Apex para poder usar el método insertarPretensionPrincipal
import tienePermisos from '@salesforce/apex/SPV_LCMP_InsertarPretension.tienePermisos';



//Campos a los que va a acceder y recoger al hacer al consulta de @wire getRecord
const fields = [
    'Case.Status',
    'Case.OwnerId',
    'Case.SAC_PretensionPrincipal__c'
];

const columns = [
    { label: 'Id', fieldName: 'name' },
    { label: 'Temática', fieldName: 'tematica', type: 'name' },
    { label: 'Producto', fieldName: 'producto', type: 'name' },
    { label: 'Motivo', fieldName: 'motivo', type: 'name' },
    { label: 'Detalle', fieldName: 'detalle', type: 'name' },
    { label: 'Principal', fieldName: 'amount', type: 'name' }
];

//const numIndice = 0;

export default class Spv_InsertarPretensionMasiva extends LightningElement {
    @api recordId;
    caso;       //Caso en el que te encuentras
    ownerId;    //Id del Owner del caso
    tienePermisosEditar = false;
    modalPretensiones = false;
    @track listMCC = [];            //Con @track mantendrá la lista actualizada ante los cambios
    @track mostrarClasificacionMCC = false; //Mostrará en la tablas los MCC añadidos cuando esté en true
    @track numIndice = 0;
    @track arrayIndices = [];
    @track modalReemplazarPrincipal = false;
    @track isLoading = false;

    _wiredResult; 

    
    //Al poner @Wire, se harán las llamdas al cargar el componente
    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

        //Esta primera es una llamada propia de Salesforce que se hace para recuperar el objeto
    @wire(getRecord, {recordId: '$recordId', fields})
    actualCase({data, error}){
        if(data){
            this.caso = data;
            this.ownerId = this.caso.fields.OwnerId.value; 
        }            
    };


    //Con esta, se comprobará si el usuario que accede tiene los permisos necesarios para editar

    @wire(tienePermisos, { idCaso: '$recordId'}) 
    mapaPermisos(result){ 
        if(result.data){
            //Si se ha obtenido resultados, será true o false en función de lo que se haya devuelto y que no esté en estado de alta ni análisis

           // this.tienePermisosEditar = (result.data && (this.caso.fields.Status.value=='SAC_001' || this.caso.fields.Status.value=='SAC_002'));   
            this.tienePermisosEditar = true;  //Las comprobaciones se hacen en el método tienePermisos
        }else{
            //Si no, si el owner del caso es el Id del usuario, entonces se pondrá a true
            // this.ownerId == Id ? this.tienePermisosEditar = true :  this.tienePermisosEditar = false;
            this.tienePermisosEditar = false;
        }
    };

   /* renderedCallback(){
    }*/


    abrirModalPretensiones(){
        this.modalPretensiones = true;
        this.listMCC = [];
        this.numIndice = 0;
        this.mostrarClasificacionMCC = false;
    } 

    cerrarModalPretensiones(){
        this.modalPretensiones = false;
        this.listMCC = [];
    }

    cerrarModalReemplazarPretension(){
        this.modalReemplazarPrincipal = false;
    }

    //Para obtener un valor desde html, se  utilizan métodos get
    get obtenerindice(){
        return this.numIndice;
     
    }

	receiveLWCData(event){
      
        let nuevoMCC = event.detail;    //Obtiene el nuevoMCC como un mapa clave-valor-> la clave es el nombre "dataToSend" y el valor es el MCC
        this.mostrarClasificacionMCC = true;    //Se activa a true para que se muestren los campos en la tabla
        this.numIndice ++;

        for (var key in nuevoMCC) {
            let value = [];
            for (var innerkey in nuevoMCC[key]) {
                let nuevoElemento = { indice: this.numIndice, objeto: nuevoMCC[key][innerkey]};
                this.listMCC.push(nuevoElemento);
      
            }

        }
	}

    eliminarRegistro(event){
        var listaActual = this.listMCC;
        var selectedItem = event.currentTarget;
        var listaActualizada = [];
        var nuevoIndice = 0;
        var index = selectedItem.dataset.record;    //Se obtiene el indice de la posición del elemento que se ha pulsado para borar, ya que en la llamada, como data-record se le pasó index
        listaActual.splice(index, 1);   //1 es el parámetro que indica que se elimine el elemento "index" de la lista

        //Se decrementa numIndice, para que al aádir un nuevo MCC, tenga el valor de índice correcto
        this.numIndice--;
        //Ahora, a todos aquellos que tengan un índice mayor que el borrado, hay que reducirselo en una unidad
    
        for(let i=0; i<=listaActual.length-1; i++){
            nuevoIndice = listaActual[i].indice //Se obiene el índice del elemento accedido
            if(listaActual[i].indice > index){  //Si su índice es mayor al borrado, habrá que reducir su valor en 1, para que la lista siga consistente
                nuevoIndice--;
            }
            
            //Se añaden los elementos con sus valores a una nueva lista actualizada, con los valores que sean ncesarios
            let nuevoElemento = { indice: nuevoIndice, objeto: listaActual[i].objeto};
            listaActualizada.push(nuevoElemento);
        }

        this.listMCC = listaActualizada;     //Convierto en la lista real, la lista a la que le he eliminado el elemento y actualizado los índices


    }
   
    generarPretensiones(event){
    
            /*const event = new ShowToastEvent({
                title: 'Toast message',
                message: 'MCC NO SELECCIONADO',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);*/
       
        let botonReemplazo = event.currentTarget.title; //Obtengo el título del botón pulsado, porque en función de este, se hace una cosa u otra
		let listaMCCs = this.listMCC;                   //Y la lista de MCCs que se van a añadir
            

        //Se van a recorrer las checkBox asociadas al listado de MCC a añadir, se realiza un conteo sobre cuántas están seleccionadas
        // Y, en caso de haber alguna, se marca isChecked a true
		
        const checkboxes = this.template.querySelectorAll('table input[type="checkbox"]');
		let contador = 0;
		let isChecked = false;
		checkboxes.forEach(checkbox=> {
			if(checkbox.checked){
				contador++;
				isChecked = true;
			}
		});
  

        //Si no se ha seleccionado ningún MCC, se le notificará al usuario que debe seleciconar alguno
		if(listaMCCs == ''){
                const event = new ShowToastEvent({
                    title: 'MCC no seleccionado',
                    message: 'Debes seleccionar al menos un MCC para poder crear pretensiones.',
                    variant: 'warning',
                    mode: 'dismissable'     //Hasta que no pulsas la x, o se supere el tiempo, la notificación será visible
                });
                this.dispatchEvent(event);
		}else if(contador > 1){     //Si hay más de una MCC marcada como principal (con checkbox marcado), entonces se le notificará al usuario que solo debe seleccionar una
            const event = new ShowToastEvent({
                title: 'Pretensión principal',
                message: 'Debes seleccionar solamente una pretensión principal.',
                variant: 'warning',
                mode: 'dismissable'     //Hasta que no pulsas la x, o se supere el tiempo, la notificación será visible
            });
            this.dispatchEvent(event);

        }else if(isChecked == true && this.caso.fields.SAC_PretensionPrincipal__c.value != null && botonReemplazo != 'botonReemplazar'){ //En caso de haber marcado alguna como principal, pero ya tener un MCC principal almacenado, y no estar en la opción de remplazo, se muestra el modal de remplazo
                    this.modalReemplazarPrincipal = true;    
        }else{

            //En caso contrario, se mostrará isLoading, y se cerrarán los modales
            this.isLoading = true;
            this.modalPretensiones = false;
            this. modalReemplazarPrincipal = false;

            let mccSelecPrin = [];  //MCC que se ha marcado como principal
			let restoMCCs = [];     //El resto de los MCC que se hayan seleccionado

            //Para cada checkbox se realizará lo siguiente
            let listaObjetosMccPrincipal =  [];
            checkboxes.forEach(function(checkbox){
                if(checkbox.checked){
                    let index = checkbox.getAttribute("data-index");
                    let mccPrin = listaMCCs[index];

                    if (mccPrin){
						mccSelecPrin.push(mccPrin.objeto);
					}

                        
                    for(let i= 0; i<=mccSelecPrin.length-1; i++){
                        listaObjetosMccPrincipal.push(mccSelecPrin[i].objeto);
                    }
       

                }else{  //Fin de if checkBox checked
                    let index = checkbox.getAttribute("data-index");
                    restoMCCs.push(listaMCCs[index]); 
                }  
            });


            if(isChecked == true){

 
                insertarPretensionPrincipal({idCase: this.recordId, mccsPretension: mccSelecPrin}).then(result=>{
         
                //Si funciona correctamente, se informa de éxito
                const event = new ShowToastEvent({
                    title: 'Pretensión principal asignada',
                    message: 'Se ha asignado la pretensión principal correctamente.',
                    variant: 'success',
                    mode: 'dismissable'     //Hasta que no pulsas la x, o se supere el tiempo, la notificación será visible
                });
                this.dispatchEvent(event);

                }).catch(error=>{
                    this.isLoading = false
                    //Si falla y se recibe mensaje de error, se muestra el mensaje
                    if(error && error.body.message){
                        const event = new ShowToastEvent({
                            title: 'Pretension principal no asignada',
                            message: error.body.message,
                            variant: 'error',
                            mode: 'dismissable'     //Hasta que no pulsas la x, o se supere el tiempo, la notificación será visible
                        });
                        this.dispatchEvent(event);
                    }else{
                    //Si falla y no se obtiene mensaje de error:
              
                        const event = new ShowToastEvent({
                            title: 'Pretension principal no asignada.',
                            message: 'No se ha asignado la pretension principal a la reclamación debido a un error.',
                            variant: 'error',
                            mode: 'dismissable'     //Hasta que no pulsas la x, o se supere el tiempo, la notificación será visible
                        });
                        this.dispatchEvent(event);


                    }

                })


            }
            //Se insertan ahora el resto de pretensiones seleccionadas que no sean principales


            let listaObjetosMcc =  [];
            for(let i= 0; i<=restoMCCs.length-1; i++){
                listaObjetosMcc.push(restoMCCs[i].objeto);                
            }       

            insertarPretensiones({idCase: this.recordId, mccsPretension: listaObjetosMcc}).then(result=>{
    
                this.isLoading = false;

                    //Si funciona correctamente, se informa de éxito
                    const event = new ShowToastEvent({
                        title: 'Pretensiones asignadas.',
                        message: 'Se ha creado ' + listaMCCs.length + ' pretensiones correctamente.',
                        variant: 'success',
                        mode: 'dismissable'     //Hasta que no pulsas la x, o se supere el tiempo, la notificación será visible
                    });
                    this.dispatchEvent(event);


            }).catch(error=>{
                this.isLoading = false;

                if(error && error.body.message){
                    const event = new ShowToastEvent({
                        title: 'Pretensiones no creadas.',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'dismissable'     //Hasta que no pulsas la x, o se supere el tiempo, la notificación será visible
                    });
                    this.dispatchEvent(event);
                }else{
                //Si falla y no se obtiene mensaje de error:
                    const event = new ShowToastEvent({
                        title: 'Pretensiones no creadas.',
                        message: 'No se han creado las pretensiones debido a un error.',
                        variant: 'error',
                        mode: 'dismissable'     //Hasta que no pulsas la x, o se supere el tiempo, la notificación será visible
                    });
                    this.dispatchEvent(event);


                }

            })


        }
            
    }

}