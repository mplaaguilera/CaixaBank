import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues  } from 'lightning/uiObjectInfoApi';
import obtenerNotasAsociadas from '@salesforce/apex/SPV_LCMP_Notas.obtenerNotasAsociadas';
import obtenerContenido from '@salesforce/apex/SPV_LCMP_Notas.obtenerContenido';
import addNuevaNota from '@salesforce/apex/SPV_LCMP_Notas.addNuevaNota';
import recuperarNotasAsociadasRefresh from '@salesforce/apex/SPV_LCMP_Notas.recuperarNotasAsociadasRefresh';
import comprobarUserSystemAdmin from '@salesforce/apex/SPV_LCMP_Notas.comprobarUserSystemAdmin';
import eliminarNota from '@salesforce/apex/SPV_LCMP_Notas.eliminarNota';

//import getUsuariosShare from '@salesforce/apex/SPV_LCMP_Notas.getUsuariosShare';
//import getCasosUser from '@salesforce/apex/SPV_LCMP_Notas.getCasosUser';

const FIELDS = ['RecordType.DeveloperName'];

const columns = [
    { label: 'Nº', fieldName: 'filaNota', type: 'number', initialWidth: 60, cellAttributes : {alignment: 'center'}}, 
    /*{label: '', type: 'button', initialWidth: 80, typeAttributes: {label: 'Ver Nota', name: 'verNota', variant: 'base'}},*/
    { label: 'Title', fieldName: 'tituloAcortado', initialWidth: 250, fixedwidth: 250, type: 'button', variant: 'base', cellAttributes: {class: 'columnaTitulo'}, typeAttributes: { label: {fieldName: 'tituloAcortado', name: 'verNota', variant: 'base'}, name: 'verNota', variant: 'base'}}, 
    { label: 'TextPreview', fieldName: 'body', initialWidth: 500},
    { label: 'Created By', fieldName: 'createdByName', initialWidth: 250, type: 'button', variant: 'base', typeAttributes: { label: {fieldName: 'createdByName', name: 'verUsuarioCreated', variant: 'base'}, name: 'verUsuarioCreated', variant: 'base'}},
    { label: 'Created Date', fieldName: 'createdDate', initialWidth: 150}
    /*{ label: 'Last Modified By', fieldName: 'lastModifiedByName', initialWidth: 250,  type: 'button', variant: 'base', typeAttributes: { label: {fieldName: 'lastModifiedByName', name: 'verUsuarioModified', variant: 'base'}, name: 'verUsuarioModified', variant: 'base'}}*/
];

export default class Spv_Notas extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    @track caso;
    @track notas;
    @track numNotas = '';
    @track spinnerLoading = false;
    @track mapaNotas = [];
    @track tituloNotaSeleccionada;
    @track mensajeSpinner;
    @track hayNotas = false;
    @track esSystemAdmin = false;
    @track idNotaAbierta = '';

    @track idUserView;
    @track mostrarModalViewAll = false;

    @track mostrarModalVerNota = false;
    @track mostrarModalNuevaNota = false;
    @track tituloAniadido = '';
    @track contenidoAniadido = '';
    @track disableBotonAdd = true;
    @track vieneDeViewAll = false;

    /*@track mostrarModalShare = false;
    @track mapaUsuariosShare = [];
    @track inputValue = '';
    @track opcionesUsuario = [];
    @track hayResultadosBusqueda = false;
    @track selectedUsers = [];
    @track hayUserSelecionado = false;
    @track mensajeEscrito = '';*/

    /*@track mostrarModalAddToRecord = false;
    @track hayResultadosBusquedaRegistros = false;
    @track opcionesAddRecord = [];
    @track mapaAddRegistros = [];
    @track selectedRegistros = [];
    @track inputValueRegistro= '';
    @track hayRegistroSelecionado = false;*/

    columns = columns;
    notasConIndice;
    @track contenidoNota;
    @track componenteEnLateral = false;
    @track componenteCargado = false;
    @track claseAnimacion = 'slds-modal slds-fade-in-open animacion-in';

    @wire(getRecord, { recordId: '$recordId', fields: '$fieldsObtener' })
    wiredCase({data, error}){
        if(data){
            const objeto = data.apiName;        //Api name del objeto que es el registro actual
            const recordTypeRegistro = data.fields.RecordType.value.fields.DeveloperName.value;     //Rt del registro
            //this.caso = data;
            if(objeto == 'Case' && (recordTypeRegistro == 'SPV_Reclamacion' || recordTypeRegistro == 'SPV_Pretension')){
                this.componenteEnLateral = false;
            }else if(data.apiName == 'SAC_Interaccion__c' && recordTypeRegistro == 'SPV_Escalado'){
                this.componenteEnLateral = true;
            }else if(objeto == 'SAC_Interaccion__c' && (recordTypeRegistro == 'SPV_Consulta' || recordTypeRegistro == 'SPV_ConsultaTarea')){
                this.componenteEnLateral = false;
            }else if(objeto == 'SAC_Accion__c' && recordTypeRegistro == 'SPV_Acciones'){
                this.componenteEnLateral = true;
            }
            
            if(this.numNotas != ''){
                if(this.componenteEnLateral == true){
                    if(this.numNotas > 3){
                        this.numNotas = '3+';
                    }
                }else{
                    if(this.numNotas > 6){
                        this.numNotas = '6+';
                    }
                }
            }
            //Para que solo se muestre el componente cuando se sepa su posición
            this.componenteCargado = true;
        }
    }

    get fieldsObtener(){
        return [this.objectApiName + '.RecordType.DeveloperName'];
    } 

    @wire(obtenerNotasAsociadas, {idRegistro: '$recordId'})
    obtenerNotasAsociadas({error, data}) {
        if(data){
            if(data.length != 0){
                this.notas = data;
                this.hayNotas = true;
                this.numNotas = data.length;

                //En caso de haber más de 6 notas, en el texto indicando el número de notas se pone '6+'
                if(this.componenteEnLateral == false){
                    if(this.numNotas > 6){
                        this.numNotas = '6+';
                    }
                }else{  //Si es de los casos en los que el componente está en un lateral, solo se muestran 3
                    if(this.numNotas > 3){
                        this.numNotas = '3+';
                    }
                }


                //Se numera cada nota, cuando se le da a View All, se muestra una tabla con las notas numeradas. La 1 será la más reciente
                this.notas.forEach(nota => {
                    this.mapaNotas.push({key: nota.id, nota: nota});
                });

            }else{
                this.notas = [];
                this.mapaNotas = [];
                this.numNotas = 0;
                this.hayNotas = false;
            }
        }else{
            this.notas = [];
            this.mapaNotas = [];
            this.numNotas = 0;
            this.hayNotas = false;
        }
    }

    @wire(comprobarUserSystemAdmin)
    comprobarUserSystemAdmin({error, data}) {
        if(data != undefined){
            this.esSystemAdmin = data;
        }
    }

    /*@wire(getUsuariosShare)
    getUsuariosShare({error, data}) {
        if(data != undefined){
            //En la picklist de Share, se mostrarán los nombres de cada usuario
            data.forEach(usuario => {
                this.mapaUsuariosShare.push({key: usuario.Id, label: usuario.Name});
            });
        }
    }*/

    handleRecargarNotas(){
        this.mensajeSpinner = 'Recuperando las notas... por favor espere.';
        this.spinnerLoading = true;
        recuperarNotasAsociadasRefresh({'idRegistro': this.recordId}).then(result=> {
            this.spinnerLoading = false;
            if(result){
                if(result.length != 0){
                this.notas = result;
                this.hayNotas = true;
                this.numNotas = result.length;
                if(this.componenteEnLateral == false){
                    if(this.numNotas > 6){
                        this.numNotas = '6+';
                    }
                }else{  //Si es de los casos en los que el componente está en un lateral, solo se muestran 3
                    if(this.numNotas > 3){
                        this.numNotas = '3+';
                    }
                }
    
                this.notas.forEach(nota => {
                    this.mapaNotas.push({key: nota.id, nota: nota});
                });
               }else{
                this.notas = [];
                this.mapaNotas = [];
                this.numNotas = 0;
                this.hayNotas = false;   
               }
            }else{
                this.notas = [];
                this.mapaNotas = [];
                this.numNotas = 0;
                this.hayNotas = false;
            }


        }).catch(error=>{
            this.spinnerLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No se han podido recuperar las notas.',
                    variant: 'error'
                }),);
        });
    }

    //En caso de haber más de 6 notas, solo se mostrarán en la preview las 6 primeras. Para ver el resto hay que darle a View All
    get notasPreview () {
        if(this.componenteEnLateral == false){
            return this.notas ? this.notas.slice(0, 6) : [];
        }else{
            return this.notas ? this.notas.slice(0, 3) : [];
        }

    }

    //Al pulsar sobre una nota en la tabla de Viewl All:
    handleRowActionTablaNotas(event) {
        const nota = event.detail.row;

        if(event.detail.action.name == 'verNota'){
            const notaSeleccionadaId = event.detail.row.id;
            this.verNotaDesdeTabla(notaSeleccionadaId);
        }else if(event.detail.action.name == 'verUsuarioCreated'){
            const idUsuarioVer = event.detail.row.createdById;
            this.navegarUsuario(idUsuarioVer);
            this.mostrarModalViewAll = false;
        }else if(event.detail.action.name == 'verUsuarioModified'){
            const idUsuarioVer = event.detail.row.lastModifiedById;
            this.navegarUsuario(idUsuarioVer);
            this.mostrarModalViewAll = false;
        }
    }

    navegarUsuario(idUsuarioVer){
        this.idUserView = idUsuarioVer;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "objectApiName": "User",
                "recordId": this.idUserView,
                "actionName": "view"
            }
        });
    }

    verNotaDesdeTabla(notaSeleccionadaId){
        this.mostrarModalViewAll = false;
        this.mensajeSpinner = 'Cargando los datos... por favor espere.';
        this.spinnerLoading = true;
        this.idNotaAbierta = notaSeleccionadaId;
        const idNota = notaSeleccionadaId;
        //Se obitene del mapa de todas las notas, cuál es el título de la nota seleccionada
        this.tituloNotaSeleccionada = this.mapaNotas.find(item => item.key === idNota).nota.title;

        obtenerContenido({contentNoteId: idNota}).then(result=> {
            this.claseAnimacion = 'slds-modal slds-fade-in-open animacion-in';
            this.vieneDeViewAll = true;
            this.mostrarModalViewAll = false;
            this.mostrarModalVerNota = true;
            this.spinnerLoading = false;

            if(result && result !== ''){
                this.contenidoNota = result;
            }else{
                this.contenidoNota = '';
                
            }


        }).catch(error=>{
            this.spinnerLoading = false;
            this.mostrarModalViewAll = true;
            this.mostrarModalVerNota = false;
            this.contenidoNota = null;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No se ha podido recuperar el contenido de la nota.',
                    variant: 'error'
                }),);
        });
    }


    /*handleClickShare(){
        this.mostrarModalShare = true;
        this.mostrarModalNuevaNota = false;
    }*/

    /*closeModalShare(){
        this.mostrarModalShare = false;
        this.mostrarModalNuevaNota = true;
        this.inputValue = '';
    }*/

    /*handleOnBlurShare(event) {
        setTimeout(() => {
            this.hayResultadosBusqueda = false;}, 150);
    }*/

    /*handleFocusInputShare(event){
        if(this.opcionesUsuario.length != 0){
            this.hayResultadosBusqueda = true;
        }else{
            this.hayResultadosBusqueda = false;
        }
    }*/

    /*handleValorBusquedaChange(event){
        this.inputValue = event.target.value.toLowerCase();
        this.opcionesUsuario = this.mapaUsuariosShare.filter(opc => opc.label.toLowerCase().includes(this.inputValue));

        if(this.opcionesUsuario.length != 0){
            this.hayResultadosBusqueda = true;
        }else{
            this.hayResultadosBusqueda = false;
        }

    }*/
    
    /*handleClickSeleccionUsuario(event){
     
        this.inputValue = '';           //Cuando se ha seleccionado un Usuario, se vuelve a poner la barra de búsqueda en blanco              
        const user = this.mapaUsuariosShare.find(user => 
                user.key === event.currentTarget.dataset.id);
        
        //Si el user ya se había seleccionado, no se vuelve a añadir
        const userYaSelecionadoAntes = this.selectedUsers.some(userBuscado => userBuscado.id === event.currentTarget.dataset.id);


        if(userYaSelecionadoAntes === false){
            this.selectedUsers.push({id: user.key, label: user.label});

            if(this.selectedUsers.length > 0){
                this.hayUserSelecionado = true;
            }else{
                this.hayUserSelecionado = false;
            }
        }

    }*/

    /*handleClickEliminarUser(event){
        const userAEliminar = this.selectedUsers.find(user => 
            user.id === event.currentTarget.dataset.id);

        this.selectedUsers = this.selectedUsers.filter(usuario => usuario.id !== userAEliminar.id);
        if(this.selectedUsers.length > 0){
            this.hayUserSelecionado = true;
        }else{
            this.mensajeEscrito = '';
            this.hayUserSelecionado = false;
        }
    }*/

    /*handleChangeMensajeEscrito(event){
        this.mensajeEscrito = event.target.value;
    }*/

    /*handleClickAddRecord(){
        this.mostrarModalAddToRecord = true;
        this.mostrarModalNuevaNota = false;
    }*/
    /*closeModalAddRecord(){
        this.mostrarModalAddToRecord = false;
        this.mostrarModalNuevaNota = true;
        this.inputValueRegistro = '';
    }*/
    /*handleClickAddRecordConfirm(){
        this.mostrarModalAddToRecord = false;
        this.mostrarModalNuevaNota = true;
    }*/

    /*handleOnBlurRegistro(event) {
        setTimeout(() => {
            this.hayResultadosBusquedaRegistros = false;}, 150);
    }*/

    /*handleFocusInputRegistro(event){
        if(this.opcionesAddRecord.length != 0){
            this.hayResultadosBusquedaRegistros = true;
        }else{
            this.hayResultadosBusquedaRegistros = false;
        }
    }*/

    /*handleValorBusquedaRegistroChange(event){
        this.inputValueRegistro = event.target.value.toLowerCase();
        this.opcionesAddRecord = this.mapaAddRegistros.filter(opc => opc.label.toLowerCase().includes(this.inputValueRegistro));

        if(this.opcionesAddRecord.length != 0){
            this.hayResultadosBusquedaRegistros = true;
        }else{
            this.hayResultadosBusquedaRegistros = false;
        }
    }*/

    /*handleClickSeleccionRegistro(event){
        this.inputValueRegistro = '';           //Cuando se ha seleccionado un Usuario, se vuelve a poner la barra de búsqueda en blanco              
        const obj = this.mapaAddRegistros.find(objeto => 
                objeto.key === event.currentTarget.dataset.id);
        
        //Si el user ya se había seleccionado, no se vuelve a añadir
        const registroYaSelecionadoAntes = this.selectedRegistros.some(objBuscado => objBuscado.id === event.currentTarget.dataset.id);

        if(registroYaSelecionadoAntes === false){
            this.selectedRegistros.push({id: obj.key, label: obj.label});

            if(this.selectedRegistros.length > 0){
                this.hayRegistroSelecionado = true;
            }else{
                this.hayRegistroSelecionado = false;
            }
        }


    }*/


    /*handleClickEliminarRegistro(event){
        const objAEliminar = this.selectedRegistros.find(obj => 
            obj.id === event.currentTarget.dataset.id);

        this.selectedRegistros = this.selectedRegistros.filter(obj => obj.id !== objAEliminar.id);
        if(this.selectedRegistros.length > 0){
            this.hayRegistroSelecionado = true;
        }else{
            this.hayRegistroSelecionado = false;
        }
    }*/


    handleOnClickEliminarNota(){
        this.mostrarModalVerNota = false;
        this.spinnerLoading = true;
        eliminarNota({'idNotaBorrar': this.idNotaAbierta}).then(result=> {
            this.idNotaAbierta = '';
            this.mostrarModalVerNota = false;
            this.contenidoNota = null;
            this.tituloNotaSeleccionada = '';
            this.spinnerLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Nota eliminada',
                    message: 'Se ha eliminado la nota correctamente.',
                    variant: 'success'
                }),);
            this.refreshView();

        }).catch(error=>{
            this.spinnerLoading = false;
            this.mostrarModalVerNota = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No se ha podido eliminar la nota.',
                    variant: 'error'
                }),);
        });
    }

    //Gestionar cuando se pulsa en crear nueva nota
    handleOnClickNewNote(){
        this.claseAnimacion = 'slds-modal slds-fade-in-open animacion-in';
        this.tituloAniadido = '';
        this.contenidoAniadido = '';
        this.mostrarModalNuevaNota = true;
    }

    closeModalNuevaNota(){
        this.claseAnimacion = 'slds-modal slds-fade-in-open animacion-out';
        this.tituloAniadido = '';
        this.contenidoAniadido = '';
        this.disableBotonAdd = true;
        this.mensajeEscrito = '';
        this.hayUserSelecionado = false;
        this.selectedUsers = [];
        this.inputValue = '';
        this.inputValueRegistro = '';
        this.hayRegistroSelecionado = false;
        this.selectedRegistros = [];
        setTimeout(() => {
            this.mostrarModalNuevaNota = false;
        }, 300);

    }

    handleTituloOnChange(event){
        this.tituloAniadido = event.target.value;
        if(this.tituloAniadido.trim() === ''){
            this.disableBotonAdd = true;
        }else{
            this.disableBotonAdd = false;
        }
    }

    handleContenidoOnChange(event){
        this.contenidoAniadido = event.target.value;
    }

    handleOnClickAddNota(){
        if(this.tituloAniadido.trim() === '' || this.tituloAniadido.length > 255 /*|| this.contenidoAniadido.replace(/<[^>]*>/g, '').trim() === ''*/){
            if(this.tituloAniadido.trim() === '' /*|| this.contenidoAniadido.replace(/<[^>]*>/g, '').trim() === ''*/){
                this.dispatchEvent(
                    new ShowToastEvent({
                        tittle: 'Error',
                        message: "Es necesario rellenar el Título para poder añadir una Nota.",
                        variant: 'error'
                    }),);
            }else{
                if(this.tituloAniadido.length > 255){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            tittle: 'Error',
                            message: "El Título introducido es demasiado largo.",
                            variant: 'error'
                        }),);
                }
            }
        }else{
            this.mensajeSpinner = 'Actualizando los datos... por favor espere.';
            this.spinnerLoading = true;
            this.mostrarModalNuevaNota = false;
            addNuevaNota({'titulo': this.tituloAniadido, 'contenido': this.contenidoAniadido, 'idRegistro': this.recordId}).then(result=> {
                this.spinnerLoading = false;
                this.mostrarModalNuevaNota = false;
                this.tituloAniadido = '';
                this.contenidoAniadido = '';
                this.disableBotonAdd = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        tittle: 'Nota añadida',
                        message: "Se ha añadido la nota al caso",
                        variant: 'success'
                    }),);
    
    
            }).catch(error=>{
                this.spinnerLoading = false;
                this.mostrarModalNuevaNota = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No se ha podido añadir la nueva nota. ' + error,
                        variant: 'error'
                    }),);
            });
        }
    }



    verUserClick(event){
        this.idUserView = event.currentTarget.name;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "objectApiName": "User",
                "recordId": this.idUserView,
                "actionName": "view"
            }
        });
    }

    //Se abre modal para ver todas las notas
    handleClickViewAll(){
        this.notasConIndice = this.notas.map((n, i) => {return {...n, filaNota: i + 1}; });
        this.mostrarModalViewAll = true;
    }

    closeModalViewAll(){
        this.mostrarModalViewAll = false;
    }


    //Gestionar pulsar ver una nota
    handleOnClickVerNota(event){
        this.mensajeSpinner = 'Cargando los datos... por favor espere.';
        this.spinnerLoading = true;
        this.idNotaAbierta = event.target.dataset.id;
        const idNota = event.target.dataset.id;
        //Se obitene del mapa de todas las notas, cuál es el título de la nota seleccionada
        this.tituloNotaSeleccionada = this.mapaNotas.find(item => item.key === idNota).nota.title;

        obtenerContenido({contentNoteId: idNota}).then(result=> {
            this.claseAnimacion = 'slds-modal slds-fade-in-open animacion-in';
            this.mostrarModalVerNota = true;
            this.spinnerLoading = false;
            if(result && result !== ''){
                this.contenidoNota = result;
            }else{
                this.contenidoNota = '';
                
            }


        }).catch(error=>{
            this.spinnerLoading = false;
            this.mostrarModalVerNota = false;
            this.contenidoNota = null;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No se ha podido recuperar el contenido de la nota.',
                    variant: 'error'
                }),);
        });
    }

    closeModalVerNota(){
        this.claseAnimacion = 'slds-modal slds-fade-in-open animacion-out';
        this.idNotaAbierta = '';
        this.contenidoNota = null;
        this.tituloNotaSeleccionada = '';
        this.mensajeEscrito = '';
        this.selectedUsers = [];
        this.hayUserSelecionado = false;
        setTimeout(() => {
            this.mostrarModalVerNota = false;
            if(this.vieneDeViewAll == true){
                this.vieneDeViewAll = false;
                this.mostrarModalViewAll = true;
            }
        }, 250);

    }

    //Recargar la vista
    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }


}