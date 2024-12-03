import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import perteneceCOPSAJ from '@salesforce/schema/User.SAC_PerteneceCOPSAJ__c';
import gruposUser from '@salesforce/schema/User.SAC_GruposPerteneciente__c';
import buscarResultados from '@salesforce/apex/SAC_LCMP_AuditoriasController.buscarResultados';
import comprobarGruposUsuario from '@salesforce/apex/SAC_LCMP_AuditoriasController.comprobarGruposUser';
import crearProgramacionAuditoria from '@salesforce/apex/SAC_LCMP_AuditoriasController.crearProgramacionAuditoria';
import recuperarCOPS from '@salesforce/apex/SAC_LCMP_AuditoriasController.recuperarIdCops';
import tienePSAuditoria from '@salesforce/apex/SAC_LCMP_AuditoriasController.comprobarPSAuditoria';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import estadosAuditoria from "@salesforce/schema/SEG_Auditoria__c.SAC_Tipo__c";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import SENTIDORESOLUCION_FIELD from '@salesforce/schema/Case.SAC_SentidoResolucion__c';
// import { RefreshEvent } from 'lightning/refresh';


export default class Sac_AuditoriaAutomatica extends NavigationMixin(LightningElement) {
  
    //Campos del formulario
    @track nombreAuditoria = '';
    @track fechaPlanificacion;
    @track fechaCierre;
    @track fechaCierreLabel;
    @track fechaInicio;
    @track fechaFin;
    @track importeDesde;
    @track importeHasta;
    @track numRec;
    
    //Cadena de búsqueda de cada buscador
    @track searchInput = '';
    @track searchInputSlaCalidad = '';
    @track searchInputPeriocidad = '';
    @track searchInputFechaCierre = '';
    @track searchInputGrupoProveedor = '';
    @track searchInputGrupoLetrado = '';
    @track searchInputSoloPretPpal = '';
    @track searchInputTematica = '';
    @track searchInputProducto = '';
    @track searchInputMotivo = '';
    @track searchInputDetalle = '';
    @track searchInputGrupoResolver = '';

    //Flags para mostrar el selector de cada buscador
    @track modalOpcionesSlaCalidad = false;
    @track modalOpcionesPeriocidad = false;
    @track modalOpcionesFechaCierre = false;
    @track modalOpcionesGrupoProveedor = false;
    @track modalOpcionesGrupoLetrado = false;
    @track modalOpcionesSoloPretPpal = false;
    @track modalOpcionesTematica = false;
    @track modalOpcionesProducto = false;
    @track modalOpcionesMotivo = false;
    @track modalOpcionesDetalle = false;
    @track modalOpcionesGrupoResolver = false;

    //Variables para filtrar las búsquedas de cada buscador
    @track filteredResultsGrupoProv = [];
    @track filteredResultsGrupoLet = [];
    @track filteredResultsTematica = [];
    @track filteredResultsProducto = [];
    @track filteredResultsMotivo = [];
    @track filteredResultsDetalle = [];
    @track filteredResultsGrupoResolver = [];

    //Variables para guardar el id del registro seleccionado en cada buscador
    @track idSelect = ''; //global
    @track idSelectGrupoProv = '';
    @track idSelectGrupoProvVarios = '';
    @track idSelectGrupoLet = '';
    @track idSelectGrupoLetVarios = '';
    @track idMccSelectTematica = '';
    @track idMccSelectProducto = '';
    @track idMccSelectMotivo = '';
    @track idSelectGrupoResolver = '';

    //Flags para desactivar/activar buscadores/botones
    @track disabledProducto = true;
    @track disabledMotivo = true;
    @track disabledDetalle = true;
    @track disabledProgramarAudit = false;

    //Variables/flags generales
    @track esCOPSAJ;
    @track tipoBuscador = '';
    @track mensaje = '';
    @track hayMasResultados = false;
    @track mensajeMuchosResultados = 'Más resultados encontrados, escriba para filtrar...';
    @track estaAbierto = false;
    @track opcionSeleccionada = false;
    @track idCOPS;
    @track idAJ;
    @track perteneceVariosGrupos = false;
    @track spinnerLoading = false;
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

    //Selector solo pret ppal/SLA Calidad/periocidad/Fecha cierre
    @track optionPretPpal;
    @track soloPretPpal;
    @track slaCalidad;
    @track optionSlaCalidad;
    @track optionPeriocidad;
    @track periocidad;
    @track mostrarOpcionesPeriocidad = false;
    @track mostrarOpcionesDiasMeses = false;
    @track optionsDiasMeses;
    // @track diasMesesValue;
    @track optionFechaCierre;
    @track cadenaPeriocidad = '';
    @track mostrarInputNumero = false;
    @track mensajeFechaCierre = '';
    @track numFechaCierre;
    @track stringFechaCierre = '';

    //Selectorsentido resolución
    @track listaSentidosResolucion;
    @track searchInputSentidoResolucion = '';
    @track valuesSentidoRes = [];
    @track modalOpcionesSentidoResolucion = false;
    @track sentidoResolucionValue;
    @track cadenaSentidoRes = '';

    get optionsTrueFalse() {
        return [
            { label: 'Sí', value: 'true' },
            { label: 'No', value: 'false' }
        ];
    }

    get optionsPeriocidad() {
        return [
            { label: 'Diaria', value: 'Diaria' },
            { label: 'Mensual', value: 'Mensual' }
        ];
    }

    get diasSemana() {
        return [
            { label: 'Todos los días', value: 'Todos' },
            { label: 'Lunes', value: 'Lunes' },
            { label: 'Martes', value: 'Martes' },
            { label: 'Miércoles', value: 'Miercoles' },
            { label: 'Jueves', value: 'Jueves' },
            { label: 'Viernes', value: 'Viernes' },
            { label: 'Sábado', value: 'Sabado' },
            { label: 'Domingo', value: 'Domingo' }
        ];
    }

    get mesesAnio() {
        return [
            { label: 'Todos los meses', value: 'Todos' },
            { label: 'Enero', value: 'Enero' },
            { label: 'Febrero', value: 'Febrero' },
            { label: 'Marzo', value: 'Marzo' },
            { label: 'Abril', value: 'Abril' },
            { label: 'Mayo', value: 'Mayo' },
            { label: 'Junio', value: 'Junio' },
            { label: 'Julio', value: 'Julio' },
            { label: 'Agosto', value: 'Agosto' },
            { label: 'Septiembre', value: 'Septiembre' },
            { label: 'Octubre', value: 'Octubre' },
            { label: 'Noviembre', value: 'Noviembre' },
            { label: 'Diciembre', value: 'Diciembre' }
        ];
    }

    get optionsFechaCierre() {
        return [
            { label: 'Hoy', value: 'TODAY' },
            { label: 'Ayer', value: 'YESTERDAY' },
            { label: 'Últimos "X" días', value: 'LAST_N_DAYS' },
            { label: 'Este mes', value: 'THIS_MONTH' },
            { label: 'Últimos "X" meses', value: 'LAST_N_MONTHS' },
            { label: 'Este año', value: 'THIS_YEAR' },
            { label: 'Últimos "X" años', value: 'LAST_N_YEARS' }
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

        if (data == '' || data == undefined) {

            if(this.tipoBuscador === 'buscadorGrupoProveedor'){
                this.filteredResultsGrupoProv = '';
            }
            if(this.tipoBuscador === 'buscadorGrupoLetrado'){
                this.filteredResultsGrupoLet = '';
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
            if(this.tipoBuscador === 'buscadorTematica'){
                this.filteredResultsTematica = data;
            }
            if(this.tipoBuscador === 'buscadorProducto'){
                this.filteredResultsProducto = data;
            }
            if(this.tipoBuscador === 'buscadorMotivo'){
                this.filteredResultsMotivo = data;
            }
            if(this.tipoBuscador === 'buscadorDetalle'){
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

                    if(this.esCOPSAJ === true){ // Y no pertenece al grupo auditores, hacer un else debajo, para que si pertence al grupo auditores pero no a cops/aj, llame al metodo de recuperar el id de cops,O recuperar el del grupo auditores
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

                                nombreGrupoGestor = listGruposSupervisor[i].CC_Grupo_Colaborador__r.Name;
                                this.idSelectGrupoProv = listGruposSupervisor[i].CC_Grupo_Colaborador__r.Id;          
                                this.searchInputGrupoProveedor = nombreGrupoGestor;
                            }else{
                                //Si soy supervisor de más de un grupo proveedor, concateno los nombre y los ids
                                nombreGrupoGestor = nombreGrupoGestor + ', ' + listGruposSupervisor[i].CC_Grupo_Colaborador__r.Name;
                                this.idSelectGrupoProvVarios = this.idSelectGrupoProv + ', ' + listGruposSupervisor[i].CC_Grupo_Colaborador__r.Id;
                                this.idSelectGrupoProv =  this.idSelectGrupoProvVarios;
                                this.perteneceVariosGrupos = true;
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

                                nombreGrupoLet = listGruposSupervisor[i].CC_Grupo_Colaborador__r.Name;
                                this.idSelectGrupoLet = listGruposSupervisor[i].CC_Grupo_Colaborador__r.Id;
                                this.searchInputGrupoLetrado = nombreGrupoLet;
                            }else{
                                //Si soy supervisor de más de un grupo letrado, concateno los nombre y los ids
                                nombreGrupoLet = nombreGrupoLet + ', ' + listGruposSupervisor[i].CC_Grupo_Colaborador__r.Name;
                                this.idSelectGrupoLetVarios = this.idSelectGrupoLet + ', ' + listGruposSupervisor[i].CC_Grupo_Colaborador__r.Id;
                                this.idSelectGrupoLet =  this.idSelectGrupoLetVarios;
                                this.perteneceVariosGrupos = true;
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

        this.fechaPlanificacion = `${year}-${month}-${day}`;

        var optionsPeriocidad = this.optionsPeriocidad ? (JSON.parse(JSON.stringify(this.optionsPeriocidad))) : null;
        this.optionPeriocidad = optionsPeriocidad;

        var optionsFechaCierre = this.optionsFechaCierre ? (JSON.parse(JSON.stringify(this.optionsFechaCierre))) : null;
        this.optionFechaCierre = optionsFechaCierre;

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


    /* Bloque métodos Periocidad */

    blurPeriocidad(){
        this.modalOpcionesPeriocidad = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.periocidad = '';
            this.searchInputPeriocidad = '';
            this.mostrarOpcionesPeriocidad = false;

            var options = JSON.parse(JSON.stringify(this.optionPeriocidad));

            for(var i = 0; i < options.length; i++) {
                options[i].selected = false;
            }
            
            this.optionPeriocidad = options;        
        }
    }

    mostrarOpcPeriocidad(){
        this.opcionSeleccionada = false;
        this.searchInputPeriocidadDiasMeses = '';
        // this.diasMesesValue = '';

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.modalOpcionesPeriocidad = true;
        }else{
            this.estaAbierto = false;
            this.modalOpcionesPeriocidad = false;
        }
    }

    selectPeriocidad(event){
        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.optionPeriocidad));

            for(var i = 0; i < options.length; i++) {
                if(options[i].value === selectedVal) {

                    options[i].selected = options[i].selected ? false : true;

                    if(options[i].selected === true){
                        this.searchInputPeriocidad = options[i].label;
                        this.periocidad = options[i].value;
                        this.opcionSeleccionada = true;

                        if(this.periocidad === 'Diaria'){
                            var optionsDias= this.diasSemana ? (JSON.parse(JSON.stringify(this.diasSemana))) : null;
                            this.optionsDiasMeses = optionsDias;
                        }else if(this.periocidad === 'Mensual'){
                            var optionsMeses = this.mesesAnio ? (JSON.parse(JSON.stringify(this.mesesAnio))) : null;
                            this.optionsDiasMeses = optionsMeses;
                        }
                        this.mostrarOpcionesPeriocidad = true;
                    }else{
                        this.searchInputPeriocidad = '';
                        this.opcionSeleccionada = false;
                        this.mostrarOpcionesPeriocidad = false;
                    }
                   
                }else{
                    options[i].selected = false;
                }
            }
            
            this.optionPeriocidad = options;        
            this.modalOpcionesPeriocidad = false;
        }
    }



    /* Bloque métodos Periocidad Opciones */

    blurPeriocidadDiasMeses(){
        this.searchInputPeriocidadDiasMeses = this.cadenaPeriocidad;
        this.mostrarOpcionesDiasMeses = false;
        this.estaAbierto = false;
    }

    mostrarOpcPeriocidadDiasMeses() {

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.mostrarOpcionesDiasMeses = true;
        }else{
            this.estaAbierto = false;
            this.mostrarOpcionesDiasMeses = false;
        }
	}

    selectPeriocidadDiasMeses(event) {
        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.optionsDiasMeses));

            if(selectedVal === 'Todos'){
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
                    if(options[i].value === 'Todos'){
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

            this.optionsDiasMeses = options;
            this.cadenaPeriocidad = '';
            // this.opcPeriocidadValue = '';
            var count = 0;

            for(var i = 0; i < options.length; i++){
                if(options[i].selected === true) {
                    count++;

                    if(count > 1){
                        this.cadenaPeriocidad = this.cadenaPeriocidad + ', ' + options[i].label;
                        // this.opcPeriocidadValue = this.opcPeriocidadValue + ';' + options[i].value;
                    }else{
                        this.cadenaPeriocidad = options[i].label;
                        // this.opcPeriocidadValue = options[i].value;
                    }
                }
            }

            this.searchInputPeriocidadDiasMeses =  this.cadenaPeriocidad;
            // this.diasMesesValue = this.opcPeriocidadValue;
            event.preventDefault();
        }
    }


    /* Bloque métodos Fecha Cierre */

    blurFechaCierre(){
        this.modalOpcionesFechaCierre = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.fechaCierre = '';
            this.fechaCierreLabel = '';
            this.searchInputFechaCierre = '';

            var options = JSON.parse(JSON.stringify(this.optionFechaCierre)); 

            for(var i = 0; i < options.length; i++) {
                options[i].selected = false;
            }
            
            this.optionFechaCierre = options;       
        }
    }

    mostrarOpcFechaCierre(){
        this.opcionSeleccionada = false;
        this.mostrarInputNumero = false;
        this.mensajeFechaCierre = '';
        this.searchInputFechaCierre = '';
        this.fechaCierre = '';
        this.fechaCierreLabel = '';
        this.numFechaCierre = -1;
        this.stringFechaCierre = '';

        if(this.estaAbierto === false){
            this.estaAbierto = true;
            this.modalOpcionesFechaCierre = true;
        }else{
            this.estaAbierto = false;
            this.modalOpcionesFechaCierre = false;
        }
    }

    selectFechaCierre(event){
        var selectedVal = event.currentTarget.dataset.value;

        if(selectedVal) {
            var options = JSON.parse(JSON.stringify(this.optionFechaCierre));

            for(var i = 0; i < options.length; i++) {
                if(options[i].value === selectedVal) {

                    options[i].selected = options[i].selected ? false : true;

                    if(options[i].selected === true){
                        this.searchInputFechaCierre = options[i].label;
                        this.fechaCierre = options[i].value;
                        this.fechaCierreLabel = options[i].label;
                        this.opcionSeleccionada = true;

                        if(this.fechaCierre !== 'TODAY' && this.fechaCierre !== 'YESTERDAY' && this.fechaCierre !== 'THIS_MONTH' && this.fechaCierre !== 'THIS_YEAR'){
                            this.mostrarInputNumero = true;
                            if(this.fechaCierre === 'LAST_N_DAYS'){
                                this.mensajeFechaCierre = ' días';
                            }else if(this.fechaCierre === 'LAST_N_MONTHS'){
                                this.mensajeFechaCierre = ' meses';
                            }else if(this.fechaCierre === 'LAST_N_YEARS'){
                                this.mensajeFechaCierre = ' años';
                            }
                        }else{
                            this.mostrarInputNumero = false;
                            this.mensajeFechaCierre = '';
                        }
                    }else{
                        this.searchInputFechaCierre = '';
                        this.opcionSeleccionada = false;
                    }
                   
                }else{
                    options[i].selected = false;
                }
            }
            
            this.optionFechaCierre = options;        
            this.modalOpcionesFechaCierre = false;
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
        }
    }

    mostrarOpcGrupoProv(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;

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

        this.modalOpcionesGrupoProveedor = false;
    }

    filtrarOpcGrupoProv(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputGrupoProveedor = event.target.value;
        this.searchInput = this.searchInputGrupoProveedor;

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
        }
    }

    mostrarOpcGrupoLetrado(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;

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

        this.modalOpcionesGrupoLetrado = false;
    }

    filtrarOpcGrupoLetrado(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputGrupoLetrado = event.target.value;
        this.searchInput = this.searchInputGrupoLetrado;

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

            this.searchInputSentidoResolucion =  this.cadenaSentidoRes;
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

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputTematica = '';
            this.idMccSelectTematica = '';

            //Modifico la Temática -> Bloque los niveles inferiores, y vacio sus posibles valores
            this.disabledProducto = true;
            this.searchInputProducto = '';
            this.idMccSelectProducto = '';
            this.disabledMotivo = true;
            this.searchInputMotivo = '';
            this.idMccSelectMotivo = '';
            this.disabledDetalle = true;
            this.searchInputDetalle = '';
            this.idMccSelectDetalle = '';
        }
    }

    mostrarOpcTematica(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                this.searchInputTematica = '';
                this.modalOpcionesTematica = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.modalOpcionesTematica = false;
        }
    }

    selectTematica(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputTematica = resultName;
        this.idMccSelectTematica = selectedValue;
        this.disabledProducto = false;

        //Modifico la Temática -> Bloque los niveles inferiores, y vacio sus posibles valores
        this.searchInputProducto = '';
        this.disabledMotivo = true;
        this.searchInputMotivo = '';
        this.disabledDetalle = true;
        this.searchInputDetalle = '';

        this.modalOpcionesTematica = false;
    }

    filtrarOpcTematica(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputTematica = event.target.value;
        this.searchInput = this.searchInputTematica;

        //Modifico la Temática -> Bloque los niveles inferiores, y vacio sus posibles valores
        this.disabledProducto = true;
        this.searchInputProducto = '';
        this.disabledMotivo = true;
        this.searchInputMotivo = '';
        this.disabledDetalle = true;
        this.searchInputDetalle = '';

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }


    /* Bloque métodos Producto */

    blurProducto(){
        this.modalOpcionesProducto = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputProducto = '';
            this.idMccSelectProducto = '';

            //Modifico el Producto -> Bloque los niveles inferiores, y vacio sus posibles valores
            this.disabledMotivo = true;
            this.searchInputMotivo = '';
            this.idMccSelectMotivo = '';
            this.disabledDetalle = true;
            this.searchInputDetalle = '';
            this.idMccSelectDetalle = '';
        }
    }

    mostrarOpcProducto(event){
        this.searchInput = '';
        this.idSelect = this.idMccSelectTematica;
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                this.searchInputProducto = '';
                this.modalOpcionesProducto = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.modalOpcionesProducto = false;
        }
    }

    selectProducto(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputProducto = resultName;
        this.idMccSelectProducto = selectedValue;
        this.disabledMotivo = false;

        //Modifico el Producto -> Bloque los niveles inferiores, y vacio sus posibles valores
        this.searchInputMotivo = '';
        this.disabledDetalle = true;
        this.searchInputDetalle = '';

        this.modalOpcionesProducto = false;
    }

    filtrarOpcProducto(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputProducto = event.target.value;
        this.searchInput = this.searchInputProducto;

        //Modifico el Producto -> Bloque los niveles inferiores, y vacio sus posibles valores
        this.disabledMotivo = true;
        this.searchInputMotivo = '';
        this.disabledDetalle = true;
        this.searchInputDetalle = '';

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }


    /* Bloque métodos Motivo */

    blurMotivo(){
        this.modalOpcionesMotivo = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputMotivo = '';
            this.idMccSelectMotivo = '';

            //Modifico el Motivo -> Bloque los niveles inferiores, y vacio sus posibles valores
            this.disabledDetalle = true;
            this.searchInputDetalle = '';
            this.idMccSelectDetalle= '';
        }
    }

    mostrarOpcMotivo(event){
        this.searchInput = '';
        this.idSelect = this.idMccSelectProducto;
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                this.searchInputMotivo = '';
                this.modalOpcionesMotivo = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.modalOpcionesMotivo = false;
        }
    }

    selectMotivo(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputMotivo = resultName;
        this.idMccSelectMotivo = selectedValue;
        this.disabledDetalle = false;

        //Modifico el Motivo -> Bloque los niveles inferiores, y vacio sus posibles valores
        this.searchInputDetalle = '';

        this.modalOpcionesMotivo = false;
    }

    filtrarOpcMotivo(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputMotivo = event.target.value;
        this.searchInput = this.searchInputMotivo;

        //Modifico el Motivo -> Bloque los niveles inferiores, y vacio sus posibles valores
        this.disabledDetalle = true;
        this.searchInputDetalle = '';

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }


    /* Bloque métodos Detalle */

    blurDetalle(){
        this.modalOpcionesDetalle = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputDetalle = '';
            this.idMccSelectDetalle= '';
        }
    }

    mostrarOpcDetalle(event){
        this.searchInput = '';
        this.idSelect = this.idMccSelectMotivo;
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                this.searchInputDetalle = '';
                this.modalOpcionesDetalle = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.modalOpcionesDetalle = false;
        }
    }

    selectDetalle(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputDetalle = resultName;
        this.idMccSelectDetalle = selectedValue;

        this.modalOpcionesDetalle = false;
    }

    filtrarOpcDetalle(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputDetalle = event.target.value;
        this.searchInput = this.searchInputDetalle;

        if(this.searchInput.length > 2){
            this.message = '';
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

    botonProgramarAuditoria(){

        if(this.numRec <= 0 || this.numRec === undefined || this.searchInputTipoAudit === '' || this.searchInputTipoAudit === undefined ||  this.nombreAuditoria === '' ||  this.slaCalidad === '' || this.slaCalidad === undefined || this.searchInputPeriocidadDiasMeses === '' || this.searchInputPeriocidadDiasMeses === undefined || this.nombreAuditoria === undefined ||  this.soloPretPpal === '' ||  this.soloPretPpal === undefined || this.fechaInicio === '' || this.fechaInicio === undefined || this.fechaInicio === null || this.fechaFin === '' || this.fechaFin === undefined || this.fechaFin === null || (this.variosProv === true && (this.searchInputGrupoProveedor === '' || this.searchInputGrupoProveedor === undefined)) || (this.variosLet === true && (this.searchInputGrupoLetrado === '' || this.searchInputGrupoLetrado === undefined)) || (this.mostrarInputNumero === true && (this.numFechaCierre <= 0 || this.numFechaCierre === undefined))){
            var contador = 0;
            var mensaje = 'Debe informar';

            if(this.nombreAuditoria === '' || this.nombreAuditoria === undefined){
                mensaje = mensaje + ' el nombre de la auditoría';
                contador++;
            }
            if(this.searchInputTipoAudit === '' || this.searchInputTipoAudit === undefined){
                if(contador === 1){
                    mensaje = mensaje + ', el tipo de auditoría';
                }else{
                    mensaje = mensaje + ' el tipo de auditoría';
                    contador++;
                }
            }
            if(this.slaCalidad === '' || this.slaCalidad === undefined){
                if(contador === 1){
                    mensaje = mensaje + ', el campo "SLA Calidad"';
                }else{
                    mensaje = mensaje + ' el campo "SLA Calidad"';
                    contador++;
                }
            }
            if(this.searchInputPeriocidadDiasMeses === '' || this.searchInputPeriocidadDiasMeses === undefined){
                if(contador === 1){
                    mensaje = mensaje + ', el campo "Periocidad de ejecución"';
                }else{
                    mensaje = mensaje + ' el campo "Periocidad de ejecución"';
                    contador++;
                }
            }
            if(this.fechaInicio === '' || this.fechaInicio === undefined || this.fechaInicio === null){
                if(contador === 1){
                    mensaje = mensaje + ', el campo "Fecha inicio"';
                }else{
                    mensaje = mensaje + ' el campo "Fecha inicio"';
                    contador++;
                }
            }
            if(this.fechaFin === '' || this.fechaFin === undefined || this.fechaFin === null){
                if(contador === 1){
                    mensaje = mensaje + ', el campo "Fecha fin"';
                }else{
                    mensaje = mensaje + ' el campo "Fecha fin"';
                    contador++;
                }
            }
            if(this.mostrarInputNumero === true && (this.numFechaCierre <= 0 || this.numFechaCierre === undefined)){
                if(contador === 1){
                    mensaje = mensaje + ', el campo "Número de ' + this.mensajeFechaCierre + '"';
                }else{
                    mensaje = mensaje + ' el campo "Número de ' + this.mensajeFechaCierre + '"';
                    contador++;
                }
            }
            if((this.variosProv === true && (this.searchInputGrupoProveedor === '' || this.searchInputGrupoProveedor === undefined))){
                if(contador === 1){
                    mensaje = mensaje + ', el campo "Grupo Proveedor"';
                }else{
                    mensaje = mensaje + ' el campo "Grupo Proveedor"';
                    contador++;
                }
            }
            if((this.variosLet === true && (this.searchInputGrupoLetrado === '' || this.searchInputGrupoLetrado === undefined))){
                if(contador === 1){
                    mensaje = mensaje + ', el campo "Despachos"';
                }else{
                    mensaje = mensaje + ' el campo "Despachos"';
                    contador++;
                }
            }
            if(this.soloPretPpal === '' ||  this.soloPretPpal === undefined){
                if(contador === 1){
                    mensaje = mensaje + ', el campo "Solo tomar la pretensión principal"';
                }else{
                    mensaje = mensaje + ' el campo "Solo tomar la pretensión principal"';
                    contador++;
                }
            }
            if(this.numRec <= 0 || this.numRec === undefined){
                if(contador === 1){
                    mensaje = mensaje + ', el número de reclamaciones a auditar';
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
        }else if(this.numRec > 150){
            const evt = new ShowToastEvent({
                title: 'Precaución!',
                message: 'El número máximo de reclamaciones a auditar está limitado a 150',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
        }else{
            this.disabledProgramarAudit = true;
            this.spinnerLoading = true;

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

            if(this.fechaCierre !== '' && this.fechaCierre !== undefined){
                if(this.fechaCierre === 'TODAY' || this.fechaCierre === 'YESTERDAY' || this.fechaCierre === 'THIS_MONTH' || this.fechaCierre === 'THIS_YEAR'){
                    this.stringFechaCierre = this.fechaCierreLabel;
                }else if(this.fechaCierre === 'LAST_N_DAYS'){
                    this.stringFechaCierre = 'Últimos ' + this.numFechaCierre + ' días';
                }else if(this.fechaCierre === 'LAST_N_MONTHS'){
                    this.stringFechaCierre = 'Últimos ' + this.numFechaCierre + ' meses';
                }else if(this.fechaCierre === 'LAST_N_YEARS'){
                    this.stringFechaCierre = 'Últimos ' + this.numFechaCierre + ' años';
                }
            }

            var periocidadAuditoria = this.periocidad + ': ' + this.searchInputPeriocidadDiasMeses;

            crearProgramacionAuditoria({ nombreAuditoria: this.nombreAuditoria, tipoAuditoria:  this.tipoAuditValue, slaCalidad: this.slaCalidad, fechaInicio: this.fechaInicio, fechaFin: this.fechaFin, fechaCierre: this.stringFechaCierre, grupoProvId: this.idSelectGrupoProv, despachosId: this.idSelectGrupoLet, impAbonadoDesde: this.importeDesde, impAbonadoHasta: this.importeHasta, sentidoResolucion: this.sentidoResolucionValue, tematicaId: this.idMccSelectTematica, productoId: this.idMccSelectProducto, motivoId: this.idMccSelectMotivo, detalleId: this.idMccSelectDetalle, numMaxReclamaciones: this.numRec, grupoResolverId: this.idSelectGrupoResolver, soloPretPpal: this.soloPretPpal, periocidad: periocidadAuditoria }).then(result => {
                this.spinnerLoading = false;
                const evt = new ShowToastEvent({
                    title: 'Éxito',
                    message: 'La programación de la auditoría se ha creado correctamente',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
               
                setTimeout(() => {
                    this.disabledProgramarAudit = false;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.Id,
                            objectApiName: 'SEG_Auditoria__c',
                            actionName: 'view'
                        }
                    });
                }, 300);
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Fallo al crear la auditoría automática',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            })
        }
    }

    cargarFechaCierre(event){
        this.fechaCierre = event.target.value;
    }

    cargarFechaInicio(event){
        this.fechaInicio = event.target.value;
    }

    cargarFechaFin(event){
        this.fechaFin = event.target.value;
    }

    cargarImporteDesde(event){
        if(event.target.value === ''){
            this.importeDesde = 0;
        }else{
            this.importeDesde = event.target.value;
        }
    }

    cargarImporteHasta(event){
        if(event.target.value === ''){
            this.importeHasta = 0;
        }else{
            this.importeHasta = event.target.value;
        }  
    }

    cargarNumRec(event){
        this.numRec = event.target.value;
    }

    cargarNombreAudit(event){
        this.nombreAuditoria = event.target.value;
    }

    cargarNumeroFechaCierre(event){
        this.numFechaCierre = event.target.value;
    }

    // resetBuscador(){
    //     this.dispatchEvent(new RefreshEvent());
    // }
}