import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import perteneceCOPSAJ from '@salesforce/schema/User.SAC_PerteneceCOPSAJ__c';
import gruposUser from '@salesforce/schema/User.SAC_GruposPerteneciente__c';
import buscarResultados from '@salesforce/apex/SAC_LCMP_AuditoriasController.buscarResultados';
import buscarReclamacionesAuditoria from '@salesforce/apex/SAC_LCMP_AuditoriasController.buscarReclamacionAuditoria';
import comprobarGruposUsuario from '@salesforce/apex/SAC_LCMP_AuditoriasController.comprobarGruposUser';
import crearAuditorias from '@salesforce/apex/SAC_LCMP_AuditoriasController.crearAuditoria';
import recuperarCOPS from '@salesforce/apex/SAC_LCMP_AuditoriasController.recuperarIdCops';
import tienePSAuditoria from '@salesforce/apex/SAC_LCMP_AuditoriasController.comprobarPSAuditoria';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import estadosAuditoria from "@salesforce/schema/SEG_Auditoria__c.SAC_Tipo__c";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import SENTIDORESOLUCION_FIELD from '@salesforce/schema/Case.SAC_SentidoResolucion__c';


export default class Sac_Auditorias extends NavigationMixin(LightningElement) {
  
    //Campos del formulario
    @track nombreAuditoria = '';
    @track fechaActual;
    @track fechaDesde;
    @track fechaHasta;
    @track importeDesde;
    @track importeHasta;
    @track numRec;
    
    //Cadena de búsqueda de cada buscador
    @track searchInput = '';
    @track searchInputSlaCalidad = '';
    @track searchInputGrupoProveedor = '';
    @track searchInputGrupoLetrado = '';
    @track searchInputGestor = '';
    @track searchInputLetrados = '';
    @track searchInputSoloPretPpal = '';
    @track searchInputGrupoResolver = '';

    //Flags para mostrar el selector de cada buscador
    @track modalOpcionesSlaCalidad = false;
    @track modalOpcionesGrupoProveedor = false;
    @track modalOpcionesGrupoLetrado = false;
    @track modalOpcionesGestor = false;
    @track modalOpcionesLetrados = false;
    @track modalOpcionesSoloPretPpal = false;
    @track modalOpcionesGrupoResolver = false;

    //Variables para filtrar las búsquedas de cada buscador
    @track filteredResultsGrupoProv = [];
    @track filteredResultsGrupoLet = [];
    @track filteredResultsGestor = [];
    @track filteredResultsLetrados = [];
    @track filteredResultsGrupoResolver = [];

    //Variables para guardar el id del registro seleccionado en cada buscador
    @track idSelect = ''; //global
    @track idSelectGrupoProv = '';
    @track idSelectGrupoProvVarios = '';
    @track idSelectGrupoLet = '';
    @track idSelectGrupoLetVarios = '';
    @track idSelectGestor = '';
    @track idSelectLetrado = '';
    @track idSelectGrupoResolver = '';

    //Flags para desactivar/activar buscadores/botones
    @track disabledGestor = true;
    @track disabledLetrados = true;
    @track disabledConfirmarAudit = true;

    //Variables/flags generales
    @track esCOPSAJ;
    @track tipoBuscador = '';
    @track mensaje = '';
    @track hayMasResultados = false;
    @track mensajeMuchosResultados = 'Más resultados encontrados, escriba para filtrar...';
    @track mostrarListaReclamaciones = false;
    @track vSeleccionador;
    @track hayReclamaciones = false;
    @track listaRecs = [];
    @track estaAbierto = false;
    @track opcionSeleccionada = false;
    @track idCOPS;
    @track idAJ;
    @track perteneceVariosGrupos = false;
    @track spinnerLoading = false;
    @track picklistValues = [];
    @track variosProv = false;
    @track variosLet = false;
    @track idGrupoAuditor = '';
    @track tienePermisos = true;

    //Flag para mostrar campos si eres supervisor gestor/letrado
    @track userSupervisorProv = false;
    @track userSupervisorLet = false;
    @track supervisorProvOrLet = false;

    //Selector tipo auditoria
    @track options;
    @track value;
    @track values = [];
    @track optionData;
    @track searchInputTipoAudit;
    @track tipoAuditValue;
    @track message;
    @track modalOpcionesTipoAudit = false;
    @track cadena = '';

    //Selector solo pret ppal/SLA Calidad
    @track optionPretPpal;
    @track soloPretPpal;
    @track slaCalidad;
    @track optionSlaCalidad;

    //Selectorsentido resolución
    @track listaSentidosResolucion;
    @track searchInputSentidoResolucion = '';
    @track valuesSentidoRes = [];
    @track modalOpcionesSentidoResolucion = false;
    @track sentidoResolucionValue;
    @track cadenaSentidoRes = '';

    //Selector Temática
    @track filteredResultsTematica = [];
    @track searchInputTematica = '';
    @track valuesMccTematica = [];
    @track modalOpcionesTematica = false;
    @track tematicaValue;
    @track cadenaTematica = '';
    @track disabledTematica = false;

    //Selector Producto
    @track filteredResultsProducto = [];
    @track searchInputProducto = '';
    @track valuesMccProducto = [];
    @track modalOpcionesProducto = false;
    @track cadenaProducto = '';
    @track disabledProducto = false;

    //Selector Motivo
    @track filteredResultsMotivo = [];
    @track searchInputMotivo = '';
    @track valuesMccMotivo = [];
    @track modalOpcionesMotivo = false;
    @track cadenaMotivo = '';
    @track disabledMotivo = false;

    //Selector Detalle
    @track filteredResultsDetalle = [];
    @track searchInputDetalle = '';
    @track valuesMccDetalle = [];
    @track modalOpcionesDetalle = false;
    @track cadenaDetalle = '';
    @track disabledDetalle = false;

    get optionsTrueFalse() {
        return [
            { label: 'Sí', value: 'true' },
            { label: 'No', value: 'false' }
        ];
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: estadosAuditoria })
    wiredPicklistValues({ error, data }) {
        if(data !== '' && data !== undefined){
            this.optionData = data.values;
        }
    }

    @wire (getObjectInfo, {objectApiName: CASE_OBJECT})
    objectInfoCase;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoCase.data.defaultRecordTypeId', fieldApiName: SENTIDORESOLUCION_FIELD })
    wiredSentidoRes({ error, data }) {
        if(data !== '' && data !== undefined){
            this.listaSentidosResolucion = data.values;
        }
    }

    @wire(buscarResultados, { searchTerm: '$searchInput', tipoBusqueda: '$tipoBuscador', id: '$idSelect' })
    wiredSearchResults({ error, data }) {

        console.log(this.valuesMccTematica.length);
            console.log(this.valuesMccProducto.length);
            console.log(this.valuesMccMotivo.length);
            console.log(this.valuesMccDetalle.length);
            console.log(JSON.stringify(this.valuesMccTematica));

        if (data == '' || data == undefined) {

            if(this.tipoBuscador === 'buscadorGrupoProveedor'){
                this.filteredResultsGrupoProv = '';
            }
            if(this.tipoBuscador === 'buscadorGrupoLetrado'){
                this.filteredResultsGrupoLet = '';
            }
            if(this.tipoBuscador === 'buscadorGestor'){
                this.filteredResultsGestor = '';
            }
            if(this.tipoBuscador === 'buscadorLetrados'){
                this.filteredResultsLetrados = '';
            }
            if(this.tipoBuscador === 'buscadorTematica'){
                this.filteredResultsTematica = '';
            }
            if(this.tipoBuscador === 'buscadorProducto'){
                this.filteredResultsProducto = '';
            }
            if(this.tipoBuscador === 'buscadorMotivo'){
                this.filteredResultsMotivo = '';
            }
            if(this.tipoBuscador === 'buscadorDetalle'){
                this.filteredResultsDetalle = '';
            }
            if(this.tipoBuscador === 'buscadorGrupoResolver'){
                this.filteredResultsGrupoResolver = '';
            }

            if(this.searchInput === ''){
                this.message = "No hay resultados";
            }else{
                this.message = "No hay resultados para '" + this.searchInput + "'";
            }
        }else {
            this.message = '';

            if(data.length >= 20){
                this.hayMasResultados = true;
            }else{
                this.hayMasResultados = false;
            }

            if(this.tipoBuscador === 'buscadorGrupoProveedor' || this.tipoBuscador === 'buscadorVariosGruposProv'){
                this.filteredResultsGrupoProv = data;
            }
            if(this.tipoBuscador === 'buscadorGrupoLetrado' || this.tipoBuscador === 'buscadorVariosGruposLet'){
                this.filteredResultsGrupoLet = data;
            }
            if(this.tipoBuscador === 'buscadorGestor'){
                this.filteredResultsGestor = data;
            }
            if(this.tipoBuscador === 'buscadorLetrados'){
                this.filteredResultsLetrados = data;
            }
            if(this.tipoBuscador === 'buscadorTematica' && this.valuesMccTematica.length == 0){
                this.filteredResultsTematica = data;
            }
            if(this.tipoBuscador === 'buscadorProducto' && (this.valuesMccProducto.length == 0 || (this.valuesMccProducto.length > 0 && this.valuesMccTematica.length == 0))){
                this.filteredResultsProducto = data;
            }
            if(this.tipoBuscador === 'buscadorMotivo' && (this.valuesMccMotivo.length == 0 || (this.valuesMccMotivo.length > 0 && this.valuesMccProducto.length == 0))){
                this.filteredResultsMotivo = data;
            }
            if(this.tipoBuscador === 'buscadorDetalle' && (this.valuesMccDetalle.length == 0 || (this.valuesMccDetalle.length > 0 && this.valuesMccMotivo.length == 0))){
                this.filteredResultsDetalle = data;
            }
            if(this.tipoBuscador === 'buscadorGrupoResolver'){
                this.filteredResultsGrupoResolver = data;
            }
        }
    }

    @wire(getRecord,{recordId:USER_ID,fields:[perteneceCOPSAJ, gruposUser]})
	wiredUser({error,data}){
		if(data){
            tienePSAuditoria({ idUser: USER_ID }).then(result => {
                if(result === true){
                    this.tienePermisos = true;
                    this.comprobarGrupos(data);
                }else{
                    this.tienePermisos = false;
                }
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Fallo al comprobar los PS que tiene asignados el usuario',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            })
		}else{
            this.tienePermisos = false;
        }
	}

    comprobarGrupos(data){
        this.esCOPSAJ = data.fields.SAC_PerteneceCOPSAJ__c.value;

        comprobarGruposUsuario({ gruposUser: data.fields.SAC_GruposPerteneciente__c.value, idUser: USER_ID}).then(result => {
            if(result){  
                var perteneceGrupoAuditores = false;
                this.idGrupoAuditor = result.idGrupoAuditor;

                if(this.idGrupoAuditor === ''){
                    perteneceGrupoAuditores = false;
                }else{
                    perteneceGrupoAuditores = true;
                }

                if(perteneceGrupoAuditores === true || this.esCOPSAJ === true){
                    //Mostrar inputs de Grupo Proveedor, Despachos, Gestor y Letrado
                    this.esCOPSAJ = true;
                    this.userSupervisorProv = true;
                    this.userSupervisorLet = true;
                    this.supervisorProvOrLet = false;

                    if(this.esCOPSAJ === true){ 
                        var listaGruposCopsAJ = result.listCOPSOrAJ;

                        for(let i=0; i < listaGruposCopsAJ.length; i++){
                            if(listaGruposCopsAJ[i].SAC_DeveloperName__c === 'COPS'){
                                this.idCOPS = listaGruposCopsAJ[i].Id;
                            }
                            if(listaGruposCopsAJ[i].SAC_DeveloperName__c === 'AJ'){
                                this.idAJ = listaGruposCopsAJ[i].Id;
                            }
                        }
                    }
                }else{
                    var listGruposSupervisor = result.listGruposAuditor;
                    var nombreGrupoGestor = '';
                    var nombreGrupoLet = '';
                    var countProv = 0;
                    var countLet = 0;

                    for(let i=0; i < listGruposSupervisor.length; i++){
                        if(listGruposSupervisor[i].CC_Grupo_Colaborador__r.RecordType.DeveloperName === 'SAC_GrupoProveedores'){
                            if(countProv === 0){
                                //La primera vez que encuentra un grupo proveedor del que el user es auditor, modifica los flag para mostrar los inputs deseados, y carga el nanem e id del grupo en cuestión
                                this.userSupervisorProv = true;
                                this.supervisorProvOrLet = true;
                                this.disabledGestor = false;

                                nombreGrupoGestor = listGruposSupervisor[i].CC_Grupo_Colaborador__r.Name;
                                this.idSelectGrupoProv = listGruposSupervisor[i].CC_Grupo_Colaborador__r.Id;          
                                this.searchInputGrupoProveedor = nombreGrupoGestor;
                            }else{
                                //Si soy supervisor de más de un grupo proveedor, concateno los nombre y los ids
                                nombreGrupoGestor = nombreGrupoGestor + ', ' + listGruposSupervisor[i].CC_Grupo_Colaborador__r.Name;
                                this.idSelectGrupoProvVarios = this.idSelectGrupoProv + ', ' + listGruposSupervisor[i].CC_Grupo_Colaborador__r.Id;
                                this.idSelectGrupoProv =  this.idSelectGrupoProvVarios;
                                this.perteneceVariosGrupos = true;
                                this.disabledGestor = true;
                                this.variosProv = true;
                                this.searchInputGrupoProveedor = '';
                            }
                            
                            countProv++;
                        }
                        if(listGruposSupervisor[i].CC_Grupo_Colaborador__r.RecordType.DeveloperName === 'SAC_Letrados'){
                            if(countLet === 0){
                                //La primera vez que encuentra un grupo letrado del que el user es auditor, modifica los flag para mostrar los inputs deseados, y carga el nanem e id del grupo en cuestión
                                this.userSupervisorLet = true;
                                this.supervisorProvOrLet = true;
                                this.disabledLetrados = false;

                                nombreGrupoLet = listGruposSupervisor[i].CC_Grupo_Colaborador__r.Name;
                                this.idSelectGrupoLet = listGruposSupervisor[i].CC_Grupo_Colaborador__r.Id;
                                this.searchInputGrupoLetrado = nombreGrupoLet;
                            }else{
                                //Si soy supervisor de más de un grupo letrado, concateno los nombre y los ids
                                nombreGrupoLet = nombreGrupoLet + ', ' + listGruposSupervisor[i].CC_Grupo_Colaborador__r.Name;
                                this.idSelectGrupoLetVarios = this.idSelectGrupoLet + ', ' + listGruposSupervisor[i].CC_Grupo_Colaborador__r.Id;
                                this.idSelectGrupoLet =  this.idSelectGrupoLetVarios;
                                this.perteneceVariosGrupos = true;
                                this.disabledLetrados = true;
                                this.variosLet = true;
                                this.searchInputGrupoLetrado = '';
                            }
                
                            countLet++;
                        }
                    }

                    if(this.userSupervisorProv === true && this.userSupervisorLet === true){
                        this.supervisorProvOrLet = false;
                        this.perteneceVariosGrupos = true;

                        recuperarCOPS({}).then(result => {
                            this.idCOPS = result;
                        })
                        .catch(error => {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: 'Fallo al recuperar el grupo COPS',
                                variant: 'error'
                            });
                            this.dispatchEvent(evt);
                        })  
                    }
                }
            }
        })
        .catch(error => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Fallo al comprobar los grupos a los que pertenece el usuario',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        })
    }

    connectedCallback() {
        const now = new Date();

        // Formatea la fecha en "DD/MM/YYYY"
        const day = now.getDate().toString().padStart(2, '0');
        const month = (now.getMonth() + 1).toString().padStart(2, '0'); // Suma 1 ya que los meses comienzan desde 0
        const year = now.getFullYear();

        this.fechaActual = `${year}-${month}-${day}`;

        var optionsTF = this.optionsTrueFalse ? (JSON.parse(JSON.stringify(this.optionsTrueFalse))) : null;
        this.optionPretPpal = optionsTF;
        this.optionSlaCalidad = optionsTF;

        //Ponemos por defecto el campo SLA Calidad a "False"
        var options = JSON.parse(JSON.stringify(this.optionSlaCalidad));
        for(var i = 0; i < options.length; i++) {
            if(options[i].value === 'false') {
                options[i].value = 'SAC_SLACalidadFalse';
                options[i].selected = true;
                this.searchInputSlaCalidad = options[i].label;
                this.slaCalidad = options[i].value;
                this.opcionSeleccionada = true;
            }else{
                options[i].value = 'SAC_SLACalidadTrue';
                options[i].selected = false;
            }
        }
        
        this.optionSlaCalidad = options;        
    }


    /* Bloque métodos Tipo Auditoria */

    blurTipoAuditoria(){
        this.searchInputTipoAudit = this.cadena;
        this.modalOpcionesTipoAudit = false;
        this.estaAbierto = false;
    }

    mostrarOpcTipoAudit() {
        this.mostrarListaReclamaciones = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.modalOpcionesTipoAudit = true;
        }else{
            this.estaAbierto = false;
            this.modalOpcionesTipoAudit = false;
        }
	}

    selectTipoAuditoria(event) {

        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.optionData));

            if(selectedVal === 'SAC_Todas'){
                for(var i = 0; i < options.length; i++) {
                    if(options[i].value !== selectedVal) {
                        if(this.values.includes(options[i].value)) {
                            this.values.splice(this.values.indexOf(options[i].value), 1);
                        }
                        options[i].selected =  false;
                    }else{
                        options[i].selected = options[i].selected ? false : true;
                    }
                }
            }else{
                for(var i = 0; i < options.length; i++) {
                    if(options[i].value === 'SAC_Todas'){
                        options[i].selected = false;
                    }
                    if(options[i].value === selectedVal) {
                        if(this.values.includes(options[i].value)) {
                            this.values.splice(this.values.indexOf(options[i].value), 1);
                        } else {
                            this.values.push(options[i].value);
                        }
                        options[i].selected = options[i].selected ? false : true;
                    }
                }
            }

            this.optionData = options;
            this.cadena = '';
            this.auditValue = '';
            var count = 0;

            for(var i = 0; i < options.length; i++){
                if(options[i].selected === true) {
                    count++;

                    if(count > 1){
                        this.cadena = this.cadena + ', ' + options[i].label;
                        this.auditValue = this.auditValue + ';' + options[i].value;
                    }else{
                        this.cadena = options[i].label;
                        this.auditValue = options[i].value;
                    }
                }
            }

            this.searchInputTipoAudit =  this.cadena;
            this.tipoAuditValue = this.auditValue;
            event.preventDefault();
        }
    }


    /* Bloque métodos SLA Calidad */

    blurSlaCalidad(){
        this.modalOpcionesSlaCalidad = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.slaCalidad = '';
            this.searchInputSlaCalidad = '';

            var options = JSON.parse(JSON.stringify(this.optionSlaCalidad));

            for(var i = 0; i < options.length; i++) {
                options[i].selected = false;
            }
            
            this.optionSlaCalidad = options;   
        }
    }

    mostrarOpcSlaCalidad(){
        // this.mostrarListaReclamaciones = false;
        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.modalOpcionesSlaCalidad = true;
        }else{
            this.estaAbierto = false;
            this.modalOpcionesSlaCalidad = false;
        }
    }

    selectSlaCalidad(event){
        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.optionSlaCalidad));

            for(var i = 0; i < options.length; i++) {
                if(options[i].value === selectedVal) {

                    options[i].selected = options[i].selected ? false : true;

                    if(options[i].selected === true){
                        this.searchInputSlaCalidad = options[i].label;
                        this.slaCalidad = options[i].value;
                        this.opcionSeleccionada = true;
                    }else{
                        this.searchInputSlaCalidad = '';
                        this.opcionSeleccionada = false;
                    }
                   
                }else{
                    options[i].selected = false;
                }
            }
            
            this.optionSlaCalidad = options;        
            this.modalOpcionesSlaCalidad = false;
        }
    }


    /* Bloque métodos Grupo Proveedor */

    blurGrupoProv(){
        this.modalOpcionesGrupoProveedor = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputGrupoProveedor = '';
            this.idSelectGrupoProv = '';

            //Modifico el Grupo Proveedor -> Bloqueo el input del gestor, y vacio sus posibles valores
            this.disabledGestor = true;
            this.searchInputGestor = '';
            this.idSelectGestor = '';
        }
    }

    mostrarOpcGrupoProv(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;
        this.mostrarListaReclamaciones = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            if(this.variosProv === true){
                this.idSelect = this.idSelectGrupoProvVarios;
            }

            setTimeout(() => {
                this.searchInputGrupoProveedor = '';
                this.modalOpcionesGrupoProveedor = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.modalOpcionesGrupoProveedor = false;
        }
    }

    selectGrupoProv(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputGrupoProveedor = resultName;
        this.idSelectGrupoProv = selectedValue;
        this.disabledGestor = false;

        //Modifico el Grupo Proveedor -> Vacio posibles valores del input del gestor.
        this.searchInputGestor = '';

        this.modalOpcionesGrupoProveedor = false;
    }

    filtrarOpcGrupoProv(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputGrupoProveedor = event.target.value;
        this.searchInput = this.searchInputGrupoProveedor;

        //Modifico el Grupo Proveedor -> Bloqueo el input del gestor, y vacio sus posibles valores
        this.disabledGestor = true;
        this.searchInputGestor = '';

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }


    /* Bloque métodos Despachos */

    blurGrupoLetrado(){
        this.modalOpcionesGrupoLetrado = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputGrupoLetrado = '';
            this.idSelectGrupoLet = '';
            
            //Modifico el Grupo Letrado -> Bloqueo el input del letrado, y vacio sus posibles valores
            this.disabledLetrados = true;
            this.searchInputLetrados = '';
            this.idSelectLetrado = '';
        }
    }

    mostrarOpcGrupoLetrado(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;
        this.mostrarListaReclamaciones = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            if(this.variosLet === true){
                this.idSelect = this.idSelectGrupoLetVarios;
            }

            setTimeout(() => {
                this.searchInputGrupoLetrado = '';
                this.modalOpcionesGrupoLetrado = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.modalOpcionesGrupoLetrado = false;
        }
    }

    selectGrupoLetrado(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputGrupoLetrado = resultName;
        this.idSelectGrupoLet = selectedValue;
        this.disabledLetrados = false;

        //Modifico el Grupo Letrado -> Vacio posibles valores del input del letrado.
        this.searchInputLetrados = '';

        this.modalOpcionesGrupoLetrado = false;
    }

    filtrarOpcGrupoLetrado(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputGrupoLetrado = event.target.value;
        this.searchInput = this.searchInputGrupoLetrado;

        //Modifico el Grupo Letrado -> Bloqueo el input del letrado, y vacio sus posibles valores
        this.disabledLetrados = true;
        this.searchInputLetrados = '';

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }


    /* Bloque métodos Gestor */

    blurGestor(){
        this.modalOpcionesGestor = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputGestor = '';
            this.idSelectGestor = '';
        }
    }

    mostrarOpcGestor(event){
        this.searchInput = '';
        this.idSelect = this.idSelectGrupoProv;
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;
        this.mostrarListaReclamaciones = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                this.searchInputGestor = '';
                this.modalOpcionesGestor = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.modalOpcionesGestor = false;
        }
    }

    selectGestor(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputGestor = resultName;
        this.idSelectGestor = selectedValue;
        this.modalOpcionesGestor = false;
    }

    filtrarOpcGestor(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputGestor = event.target.value;
        this.searchInput = this.searchInputGestor;

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }


    /* Bloque métodos Letrados */

    blurLetrados(){
        this.modalOpcionesLetrados = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputLetrados = '';
            this.idSelectLetrado = '';
        }
    }

    mostrarOpcLetrados(event){
        this.searchInput = '';
        this.idSelect = this.idSelectGrupoLet;
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;
        this.mostrarListaReclamaciones = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                this.searchInputLetrados = '';
                this.modalOpcionesLetrados = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.modalOpcionesLetrados = false;
        }
    }

    selectLetrados(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputLetrados = resultName;
        this.idSelectLetrado = selectedValue;
        this.modalOpcionesLetrados = false;
    }

    filtrarOpcLetrados(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputLetrados = event.target.value;
        this.searchInput = this.searchInputLetrados;

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }

    /* Bloque métodos Sentido Resolución */

    blurSentidoResolucion(){
        this.searchInputSentidoResolucion = this.cadenaSentidoRes;
        this.modalOpcionesSentidoResolucion = false;
        this.estaAbierto = false;
    }

    mostrarOpcSentidoResolucion() {
        this.mostrarListaReclamaciones = false;
        
        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.modalOpcionesSentidoResolucion = true;
        }else{
            this.estaAbierto = false;
            this.modalOpcionesSentidoResolucion = false;
        }
	}

    selectSentidoResolucion(event) {

        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.listaSentidosResolucion));

            for(var i = 0; i < options.length; i++) {
                if(options[i].value === selectedVal) {
                    if(this.valuesSentidoRes.includes(options[i].value)) {
                        this.valuesSentidoRes.splice(this.valuesSentidoRes.indexOf(options[i].value), 1);
                    } else {
                        this.valuesSentidoRes.push(options[i].value);
                    }
                    options[i].selected = options[i].selected ? false : true;
                }
            }

            this.listaSentidosResolucion = options;
            this.cadenaSentidoRes = '';
            this.resolucionValue = '';
            var count = 0;

            for(var i = 0; i < options.length; i++){
                if(options[i].selected === true) {
                    count++;

                    if(count > 1){
                        this.cadenaSentidoRes = this.cadenaSentidoRes + ', ' + options[i].label;
                        // this.resolucionValue = this.resolucionValue + ';' + options[i].value;
                        this.resolucionValue = this.resolucionValue + ';' + options[i].label;
                    }else{
                        this.cadenaSentidoRes = options[i].label;
                        // this.resolucionValue = options[i].value;
                        this.resolucionValue = options[i].label;
                    }
                }
            }

            this.searchInputSentidoResolucion = this.cadenaSentidoRes;
            this.sentidoResolucionValue = this.resolucionValue;
            event.preventDefault();
        }
    }


    /* Bloque métodos Pret Ppal */

    blurSoloPretPpal(){
        this.modalOpcionesSoloPretPpal = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.soloPretPpal = '';
            this.searchInputSoloPretPpal = '';

            var options = JSON.parse(JSON.stringify(this.optionPretPpal));

            for(var i = 0; i < options.length; i++) {
                options[i].selected = false;
            }
            
            this.optionPretPpal = options;        
        }
    }

    mostrarOpcSoloPretPpal(){
        this.mostrarListaReclamaciones = false;
        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.modalOpcionesSoloPretPpal = true;
        }else{
            this.estaAbierto = false;
            this.modalOpcionesSoloPretPpal = false;
        }
    }

    selectSoloPretPpal(event){
        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.optionPretPpal));

            for(var i = 0; i < options.length; i++) {
                if(options[i].value === selectedVal) {

                    options[i].selected = options[i].selected ? false : true;

                    if(options[i].selected === true){
                        this.searchInputSoloPretPpal = options[i].label;
                        this.soloPretPpal = options[i].value;
                        this.opcionSeleccionada = true;
                    }else{
                        this.searchInputSoloPretPpal = '';
                        this.opcionSeleccionada = false;
                    }
                   
                }else{
                    options[i].selected = false;
                }
            }
            
            this.optionPretPpal = options;        
            this.modalOpcionesSoloPretPpal = false;
        }
    }


    /* Bloque métodos Tematica */

    blurTematica(){
        this.modalOpcionesTematica = false;
        this.estaAbierto = false;
    }

    mostrarOpcTematica(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        this.idSelect = '';
        this.mostrarListaReclamaciones = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.modalOpcionesTematica = true;
        }else{
            this.estaAbierto = false;
            this.modalOpcionesTematica = false;
        }
    }

    selectTematica(event){
        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.filteredResultsTematica));

            for(var i = 0; i < options.length; i++) {
                if(options[i].Id === selectedVal) {
                    if(this.valuesMccTematica.includes(options[i].Id)) {
                        this.valuesMccTematica.splice(this.valuesMccTematica.indexOf(options[i].Id), 1);
                    } else {
                        this.valuesMccTematica.push(options[i].Id);
                    }
                    options[i].selected = options[i].selected ? false : true;
                }
            }

            this.filteredResultsTematica = options;
            this.cadenaTematica = '';
            this.temValue = '';
            var count = 0;

            for(var i = 0; i < options.length; i++){
                if(options[i].selected === true) {
                    count++;

                    if(count > 1){
                        this.cadenaTematica = this.cadenaTematica + ', ' + options[i].Name;
                    }else{
                        this.cadenaTematica = options[i].Name;
                        this.temValue = options[i].Id;
                    }
                }                
            }

            //Se desactivan y blanquean el resto de niveles en el caso de que se seleccione más de 1 opción
            if(count > 1){
                this.disabledProducto = true;
                this.searchInputProducto = '';
                this.valuesMccProducto = [];
                this.filteredResultsProducto = [];
                this.cadenaProducto = '';
                this.disabledMotivo = true;
                this.searchInputMotivo = '';
                this.valuesMccMotivo = [];
                this.filteredResultsMotivo = [];
                this.cadenaMotivo = '';
                this.disabledDetalle = true;
                this.searchInputDetalle = '';
                this.valuesMccDetalle = [];
                this.filteredResultsDetalle = [];
                this.cadenaDetalle = '';
            }

            //En el caso de deseleccionar todas las opciones se blanquean todos los inputs de menor nivel
            else if(count == 0){
                this.searchInputProducto = '';
                this.valuesMccProducto = [];
                this.filteredResultsProducto = [];
                this.cadenaProducto = '';
                this.searchInputMotivo = '';
                this.valuesMccMotivo = [];
                this.filteredResultsMotivo = [];
                this.cadenaMotivo = '';
                this.searchInputDetalle = '';
                this.valuesMccDetalle = [];
                this.filteredResultsDetalle = [];
                this.cadenaDetalle = '';
            }

            //En el caso de solo tener 1 opción seleccionada, se dejan activos
            else{
                this.disabledProducto = false;
                this.disabledMotivo = false;
                this.disabledDetalle = false;
            }

            this.searchInputTematica = this.cadenaTematica;
            event.preventDefault();
        }
    }

    /* Bloque métodos Producto */

    blurProducto(){
        this.modalOpcionesProducto = false;
        this.estaAbierto = false;
    }

    mostrarOpcProducto(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        if(this.valuesMccTematica.length > 0){
            this.idSelect = this.valuesMccTematica[0];
        }else{
            this.idSelect = '';
        }
        this.mostrarListaReclamaciones = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.modalOpcionesProducto = true;
        }else{
            this.estaAbierto = false;
            this.modalOpcionesProducto = false;
        }
    }

    selectProducto(event){
        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.filteredResultsProducto));

            for(var i = 0; i < options.length; i++) {
                if(options[i].Id === selectedVal) {
                    if(this.valuesMccProducto.includes(options[i].Id)) {
                        this.valuesMccProducto.splice(this.valuesMccProducto.indexOf(options[i].Id), 1);
                    } else {
                        this.valuesMccProducto.push(options[i].Id);
                    }
                    options[i].selected = options[i].selected ? false : true;
                }
            }

            this.filteredResultsProducto = options;
            this.cadenaProducto = '';
            var count = 0;

            for(var i = 0; i < options.length; i++){
                if(options[i].selected === true) {
                    count++;

                    if(count > 1){
                        this.cadenaProducto = this.cadenaProducto + ', ' + options[i].Name;
                    }else{
                        this.cadenaProducto = options[i].Name;
                    }
                }
            }

            //Se desactivan y blanquean el resto de niveles en el caso de que se seleccione más de 1 opción
            if(count > 1){
                this.disabledTematica = true;
                this.searchInputTematica = '';
                this.valuesMccTematica = [];
                this.filteredResultsTematica = [];
                this.cadenaTematica = '';
                this.disabledMotivo = true;
                this.searchInputMotivo = '';
                this.valuesMccMotivo = [];
                this.filteredResultsMotivo = [];
                this.cadenaMotivo = '';
                this.disabledDetalle = true;
                this.searchInputDetalle = '';
                this.valuesMccDetalle = [];
                this.filteredResultsDetalle = [];
                this.cadenaDetalle = '';
            }

            //En el caso de deseleccionar todas las opciones se blanquean todos los inputs de menor nivel, y el mismo
            else if(count == 0){

                this.searchInputMotivo = '';
                this.valuesMccMotivo = [];
                this.filteredResultsMotivo = [];
                this.cadenaMotivo = '';
                this.searchInputDetalle = '';
                this.valuesMccDetalle = [];
                this.filteredResultsDetalle = [];
                this.cadenaDetalle = '';
            }

            //En el caso de solo tener 1 opción seleccionada, se dejan activos
            else{
                this.disabledTematica = false;
                this.disabledMotivo = false;
                this.disabledDetalle = false;
            }

            this.searchInputProducto = this.cadenaProducto;
            event.preventDefault();
        }
    }

    /* Bloque métodos Motivo */

    blurMotivo(){
        this.modalOpcionesMotivo = false;
        this.estaAbierto = false;
    }

    mostrarOpcMotivo(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        if(this.valuesMccProducto.length > 0){
            this.idSelect = this.valuesMccProducto[0];
        }else{
            this.idSelect = '';
        }
        this.mostrarListaReclamaciones = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.modalOpcionesMotivo = true;
        }else{
            this.estaAbierto = false;
            this.modalOpcionesMotivo = false;
        }
    }

    selectMotivo(event){
        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.filteredResultsMotivo));

            for(var i = 0; i < options.length; i++) {
                if(options[i].Id === selectedVal) {
                    if(this.valuesMccMotivo.includes(options[i].Id)) {
                        this.valuesMccMotivo.splice(this.valuesMccMotivo.indexOf(options[i].Id), 1);
                    } else {
                        this.valuesMccMotivo.push(options[i].Id);
                    }
                    options[i].selected = options[i].selected ? false : true;
                }
            }

            this.filteredResultsMotivo = options;
            this.cadenaMotivo = '';
            var count = 0;

            for(var i = 0; i < options.length; i++){
                if(options[i].selected === true) {
                    count++;

                    if(count > 1){
                        this.cadenaMotivo = this.cadenaMotivo + ', ' + options[i].Name;
                    }else{
                        this.cadenaMotivo = options[i].Name;
                    }
                }
            }

            //Se desactivan y blanquean el resto de niveles en el caso de que se seleccione más de 1 opción
            if(count > 1){
                this.disabledTematica = true;
                this.searchInputTematica = '';
                this.valuesMccTematica = [];
                this.filteredResultsTematica = [];
                this.cadenaTematica = '';
                this.disabledProducto = true;
                this.searchInputProducto = '';
                this.valuesMccProducto = [];
                this.filteredResultsProducto = [];
                this.cadenaProducto = '';
                this.disabledDetalle = true;
                this.searchInputDetalle = '';
                this.valuesMccDetalle = [];
                this.filteredResultsDetalle = [];
                this.cadenaDetalle = '';
            }

            //En el caso de deseleccionar todas las opciones se blanquean todos los inputs de menor nivel
            else if(count == 0){
                this.searchInputDetalle = '';
                this.valuesMccDetalle = [];
                this.filteredResultsDetalle = [];
                this.cadenaDetalle = '';
            }

            //En el caso de solo tener 1 opción seleccionada, se dejan activos
            else{
                this.disabledTematica = false;
                this.disabledProducto = false;
                this.disabledDetalle = false;
            }

            this.searchInputMotivo = this.cadenaMotivo;
            event.preventDefault();
        }
    }

    /* Bloque métodos Detalle */

    blurDetalle(){
        this.modalOpcionesDetalle = false;
        this.estaAbierto = false;
    }

    mostrarOpcDetalle(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        if(this.valuesMccMotivo.length > 0){
            this.idSelect = this.valuesMccMotivo[0];
        }else{
            this.idSelect = '';
        }
        this.mostrarListaReclamaciones = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.modalOpcionesDetalle = true;
        }else{
            this.estaAbierto = false;
            this.modalOpcionesDetalle = false;
        }
    }

    selectDetalle(event){
        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.filteredResultsDetalle));

            for(var i = 0; i < options.length; i++) {
                if(options[i].Id === selectedVal) {
                    if(this.valuesMccDetalle.includes(options[i].Id)) {
                        this.valuesMccDetalle.splice(this.valuesMccDetalle.indexOf(options[i].Id), 1);
                    } else {
                        this.valuesMccDetalle.push(options[i].Id);
                    }
                    options[i].selected = options[i].selected ? false : true;
                }
            }

            this.filteredResultsDetalle = options;
            this.cadenaDetalle = '';
            var count = 0;

            for(var i = 0; i < options.length; i++){
                if(options[i].selected === true) {
                    count++;

                    if(count > 1){
                        this.cadenaDetalle = this.cadenaDetalle + ', ' + options[i].Name;
                    }else{
                        this.cadenaDetalle = options[i].Name;
                    }
                }
            }

            //Se desactivan y blanquean el resto de niveles en el caso de que se seleccione más de 1 opción
            if(count > 1){
                this.disabledTematica = true;
                this.searchInputTematica = '';
                this.valuesMccTematica = [];
                this.filteredResultsTematica = [];
                this.cadenaTematica = '';
                this.disabledProducto = true;
                this.searchInputProducto = '';
                this.valuesMccProducto = [];
                this.filteredResultsProducto = [];
                this.cadenaProducto = '';
                this.disabledMotivo = true;
                this.searchInputMotivo = '';
                this.valuesMccMotivo = [];
                this.filteredResultsMotivo = [];
                this.cadenaMotivo = '';
            }

            //En el caso de solo tener 1 opción seleccionada, se dejan activos
            else{
                this.disabledTematica = false;
                this.disabledProducto = false;
                this.disabledMotivo = false;
            }

            this.searchInputDetalle = this.cadenaDetalle;
            event.preventDefault();
        }
    }

    /* Bloque métodos Grupo Responsable */
  
    blurGrupoResolver(){
        this.modalOpcionesGrupoResolver = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputGrupoResolver = '';
            this.idSelectGrupoResolver = '';
        }
    }

    mostrarOpcGrupoResolver(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                // this.searchInput = '';
                this.searchInputGrupoResolver = '';
                this.modalOpcionesGrupoResolver = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.modalOpcionesGrupoResolver = false;
        }
    }

    selectGrupoResolver(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputGrupoResolver = resultName;
        this.idSelectGrupoResolver = selectedValue;

        this.modalOpcionesGrupoResolver = false;
    }

    filtrarOpcGrupoResolver(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputGrupoResolver = event.target.value;
        this.searchInput = this.searchInputGrupoResolver;

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }


    /* Otros métodos */

    botonGenerarAuditoria(){

        if(this.numRec <= 0 || this.numRec === undefined || this.searchInputTipoAudit === '' || this.searchInputTipoAudit === undefined || this.nombreAuditoria === '' || this.slaCalidad === '' || this.slaCalidad === undefined || this.nombreAuditoria === undefined ||  this.soloPretPpal === '' ||  this.soloPretPpal === undefined || (this.variosProv === true && (this.searchInputGrupoProveedor === '' || this.searchInputGrupoProveedor === undefined)) || (this.variosLet === true && (this.searchInputGrupoLetrado === '' || this.searchInputGrupoLetrado === undefined))){
            var contador = 0;
            this.mostrarListaReclamaciones = false;
            var mensaje = 'Debe informar';

            if(this.nombreAuditoria === '' || this.nombreAuditoria === undefined){
                mensaje = mensaje + ' el nombre de la auditoría';
                contador++;
            }
            if(this.searchInputTipoAudit === '' || this.searchInputTipoAudit === undefined){
                if(contador === 1){
                    mensaje = mensaje + ' , el tipo de auditoría';
                }else{
                    mensaje = mensaje + ' el tipo de auditoría';
                    contador++;
                }
            }
            if(this.slaCalidad === '' || this.slaCalidad === undefined){
                if(contador === 1){
                    mensaje = mensaje + ' , el campo "SLA Calidad"';
                }else{
                    mensaje = mensaje + ' el campo "SLA Calidad"';
                    contador++;
                }
            }
            if((this.variosProv === true && (this.searchInputGrupoProveedor === '' || this.searchInputGrupoProveedor === undefined))){
                if(contador === 1){
                    mensaje = mensaje + ' , el campo "Grupo Proveedor"';
                }else{
                    mensaje = mensaje + ' el campo "Grupo Proveedor"';
                    contador++;
                }
            }
            if((this.variosLet === true && (this.searchInputGrupoLetrado === '' || this.searchInputGrupoLetrado === undefined))){
                if(contador === 1){
                    mensaje = mensaje + ' , el campo "Despachos"';
                }else{
                    mensaje = mensaje + ' el campo "Despachos"';
                    contador++;
                }
            }
            if(this.soloPretPpal === '' ||  this.soloPretPpal === undefined){
                if(contador === 1){
                    mensaje = mensaje + ' , el campo "Solo tomar la pretensión principal"';
                }else{
                    mensaje = mensaje + ' el campo "Solo tomar la pretensión principal"';
                    contador++;
                }
            }
            if(this.numRec <= 0 || this.numRec === undefined){
                if(contador === 1){
                    mensaje = mensaje + ' , el número de reclamaciones a auditar';
                }else{
                    mensaje = mensaje + ' el número de reclamaciones a auditar';                  
                }
            }
            
            const evt = new ShowToastEvent({
                title: 'Campos incompletos',
                message: mensaje,
                variant: 'warning'
            });
            this.dispatchEvent(evt);
        }else{
            buscarReclamacionesAuditoria({ tipoAuditoria: this.searchInputTipoAudit, soloPretPpal: this.soloPretPpal, fechaDesde: this.fechaDesde, fechaHasta: this.fechaHasta, grupoProvId: this.idSelectGrupoProv, despachosId: this.idSelectGrupoLet, gestorId: this.idSelectGestor, letrado: this.searchInputLetrados, impAbonadoDesde: this.importeDesde, impAbonadoHasta: this.importeHasta, sentidoResolucion: this.valuesSentidoRes, listIdsTematica: this.valuesMccTematica, listIdsProducto: this.valuesMccProducto, listIdsMotivo: this.valuesMccMotivo, listIdsDetalle: this.valuesMccDetalle, numMaxReclamaciones: this.numRec }).then(result => {
                this.mostrarListaReclamaciones = true;
                this.listaRecs = result;

                if(this.listaRecs.length === 0){
                    this.hayReclamaciones = false;
                    this.disabledConfirmarAudit = true;
                }
                else{
                    this.hayReclamaciones = true;
                }
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Fallo al recuperar las reclamaciones para la auditoria',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            })
        }
    }

    cargarFechaDesde(event){
        this.fechaDesde = event.target.value;
        this.mostrarListaReclamaciones = false;
    }

    cargarFechaHasta(event){
        this.fechaHasta = event.target.value;
        this.mostrarListaReclamaciones = false;
    }

    cargarImporteDesde(event){
        if(event.target.value === ''){
            this.importeDesde = 0;
        }else{
            this.importeDesde = event.target.value;
        }

        this.mostrarListaReclamaciones = false;
    }

    clicarImporte(){
        this.mostrarListaReclamaciones = false;
    }

    cargarImporteHasta(event){
        if(event.target.value === ''){
            this.importeHasta = 0;
        }else{
            this.importeHasta = event.target.value;
        }
        
        this.mostrarListaReclamaciones = false;
    }

    cargarNumRec(event){
        this.numRec = event.target.value;
        this.mostrarListaReclamaciones = false;
    }

    cargarNombreAudit(event){
        this.nombreAuditoria = event.target.value;
    }

    allSelected(event) {
        var check = false;
        this.seleccionador();
        
        for(let i = 0; i < this.vSeleccionador.length; i++) {
            if(this.vSeleccionador[i].type === 'checkbox') {
                this.vSeleccionador[i].checked = event.target.checked;

                if(event.target.checked === true){
                    check = true;
                }
            }
        }

        if(check === true){
            this.disabledConfirmarAudit = false;
        }else{
            this.disabledConfirmarAudit = true;
        }
    }

    selectUnaRec(event){
        var check = false;
        this.seleccionador();

        for(let i = 0; i < this.vSeleccionador.length; i++) {
            if(this.vSeleccionador[i].type === 'checkbox') {
                if(this.vSeleccionador[i].name === 'selectAll' && this.vSeleccionador[i].checked === true) {
                    this.vSeleccionador[i].checked = event.target.checked;
                }
                if(this.vSeleccionador[i].name === 'individual' && this.vSeleccionador[i].checked === true){
                    check = true;
                }
            }
        }

        if(check === true){
            this.disabledConfirmarAudit = false;
        }else{
            this.disabledConfirmarAudit = true;
        }
    }

    seleccionador() {
        this.vSeleccionador = this.template.querySelectorAll('lightning-input');
    }

    botonConfirmarAuditoria(){
        this.disabledConfirmarAudit = true;
        this.spinnerLoading = true;      
        this.selectedCons = [];
        this.seleccionador();

        for(let i = 1; i < this.vSeleccionador.length; i++) {
            if(this.vSeleccionador[i].checked && this.vSeleccionador[i].type === 'checkbox' && this.vSeleccionador[i].name === 'individual') {
                this.selectedCons.push(this.vSeleccionador[i].value);
            }
        }

        if(this.idSelectGrupoResolver === '' || this.idSelectGrupoResolver === undefined){
            //Es un usuario de AJ/COPS/Auditores, cargamos con su grupo. 
            if(this.esCOPSAJ === true){
                if(this.idAJ !== '' && this.idAJ !== undefined){
                    this.idSelectGrupoResolver = this.idAJ;
                }else if(this.idCOPS !== '' && this.idCOPS !== undefined){
                    this.idSelectGrupoResolver = this.idCOPS;
                }else if(this.idGrupoAuditor !== '' && this.idGrupoAuditor !== undefined){
                    this.idSelectGrupoResolver = this.idGrupoAuditor;
                }
            }else{
                //Si no es AJ/COPS/Auditores cargamos con el grupo prov/letrado del usuario que crea la auditoria. En caso de pertenecer a varios, la asignamos a COPS
                if(this.perteneceVariosGrupos === true && this.userSupervisorProv === true && this.userSupervisorLet === true){
                    this.idSelectGrupoResolver = this.idCOPS;
                }else{
                    if(this.idSelectGrupoProv !== '' && this.idSelectGrupoProv !== undefined){
                        this.idSelectGrupoResolver = this.idSelectGrupoProv;
                    }else if(this.idSelectGrupoLet !== '' && this.idSelectGrupoLet !== undefined){
                        this.idSelectGrupoResolver = this.idSelectGrupoLet;
                    }
                }
            }
        }

        crearAuditorias({ nombreAuditoria: this.nombreAuditoria, tipoAuditoria:  this.tipoAuditValue, slaCalidad: this.slaCalidad, fechaDesde: this.fechaDesde, fechaHasta: this.fechaHasta, grupoProvId: this.idSelectGrupoProv, despachosId: this.idSelectGrupoLet, gestorId: this.idSelectGestor, letradoId: this.idSelectLetrado, impAbonadoDesde: this.importeDesde, impAbonadoHasta: this.importeHasta, sentidoResolucion: this.sentidoResolucionValue, listIdsTematica: this.cadenaTematica, listIdsProducto: this.cadenaProducto, listIdsMotivo: this.cadenaMotivo, listIdsDetalle: this.cadenaDetalle, listIdsTematicaLabel: this.searchInputTematica, listIdsProductoLabel: this.searchInputProducto, listIdsMotivoLabel: this.searchInputMotivo, listIdsDetalleLabel: this.searchInputDetalle, grupoResolverId: this.idSelectGrupoResolver, listaCasos: this.selectedCons }).then(result => {
            this.spinnerLoading = false;
            this.mostrarListaReclamaciones = false;
            const evt = new ShowToastEvent({
                title: 'Auditoría creada',
                message: 'Se ha creado correctamente la auditoría',
                variant: 'success'
            });
            this.dispatchEvent(evt);

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result.Id,
                    objectApiName: 'SEG_Auditoria__c',
                    actionName: 'view'
                }
            });
        })
        .catch(error => {
            this.spinnerLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Fallo al crear la auditoria',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        })
    }

    mostrarRec(event){
        const caseId = event.currentTarget.dataset.value;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }

    // resetBuscador(){
    //     this.dispatchEvent(new RefreshEvent());
    // }
}