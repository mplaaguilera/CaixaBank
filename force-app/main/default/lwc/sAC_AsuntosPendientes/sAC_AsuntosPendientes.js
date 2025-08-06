import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import comprobarAsuntos from '@salesforce/apex/SAC_LCMP_AsuntosPendientes.comprobarAsuntos';

const columnsTareas = [
    {   label: 'Nombre Tarea', 
        fieldName: 'tareaIDforURL',
        type: 'url',
        typeAttributes: { label: { fieldName: 'name' }, target: '_blank'},
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Fecha creación',
        fieldName: 'fechaCreacion',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Fecha vto inicial',
        fieldName: 'fechaVtoIncial',
        type: 'date',
        sortable: true
    },
    {   label: 'Estado', 
        fieldName: 'estado', 
        type: 'text',
        sortable: true
    }
];

const columnsConsultas = [
    {   label: 'Nombre Consulta', 
        fieldName: 'consultaIDforURL',
        type: 'url',
        typeAttributes: { label: { fieldName: 'name' }, target: '_blank'},
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Fecha creación',
        fieldName: 'fechaCreacion',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Grupo',
        fieldName: 'grupo',
        type: 'text',
        sortable: true
    },
    {   label: 'Estado', 
        fieldName: 'estado', 
        type: 'text' ,
        sortable: true
    }
];

const columnsEscalado = [
    {   label: 'Nombre Escalado', 
        fieldName: 'escaladoIDforURL',
        type: 'url',
        typeAttributes: { label: { fieldName: 'name' }, target: '_blank'},
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Fecha creación',
        fieldName: 'fechaCreacion',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Título',
        fieldName: 'titulo',
        type: 'text',
        sortable: true
    },
    {   label: 'Estado', 
        fieldName: 'estado', 
        type: 'text' ,
        sortable: true
    }
];

export default class SAC_AsuntosPendientes extends NavigationMixin(LightningElement) {

    @api recordId;
    @api columnasTareas = columnsTareas;
    @api columnasConsultas = columnsConsultas;
    @api columnasEscalado = columnsEscalado;
    @api mostrarTareas = false;
    @api mostrarConsultas = false;
    @api mostrarEscalados = false;
    @api mostrarComprobar = false;
    @api mostrarOcultar = false;
    @api mostrarMensaje = false;
    @api mensaje;
    dataTareas = [];
    dataConsultas = [];
    dataEscalados = [];
    defaultSortDirection = 'asc';
    sortDirectionTareas = 'asc';
    sortDirectionConsultas = 'asc';
    sortDirectionEscalados = 'asc';
    sortedBy;

    connectedCallback(){
        this.mostrarComprobar = true;
    }

    comprobarClick(){
        comprobarAsuntos({ idCaso: this.recordId }).then(result => {
            this.dataTareas = [];
            this.dataConsultas = [];
            this.dataEscalados = [];
            this.mostrarComprobar = false;
            this.mostrarOcultar = true;

            let mensaje = result.mensaje;

            if(mensaje == 'OK'){ 
                let tareas = result.listaTareas;
                let consultas = result.listaConsultas;
                let escalados = result.listaEscalados;
        
                for (var miTarea in tareas) {  
                    let tarea = tareas[miTarea];
                    let estado;
                    if(tarea.SAC_Estado__c == 'SAC_PendienteEnviar'){
                        estado='Pendiente enviar';
                    }else if(tarea.SAC_Estado__c == 'SAC_PendienteAsignar'){ 
                        estado = 'Pendiente asignar'
                    }else if(tarea.SAC_Estado__c == 'SAC_EnGestion'){ 
                        estado = 'En gestión'
                    }else if(tarea.SAC_Estado__c == 'SAC_StandBy'){ 
                        estado = 'Stand By'
                    }
                    let tareaParaAnadir = {
                                                id: tarea.Id,
                                                name: tarea.Name,
                                                tareaIDforURL:  '/' + tarea.Id,
                                                fechaCreacion: tarea.CreatedDate,
                                                fechaVtoIncial: tarea.SAC_FechaVencimientoInicial__c,
                                                estado: estado
                                            }
                    this.dataTareas.push(tareaParaAnadir);
                    this.mostrarTareas = true;
                } 
    
                for (var miConsulta in consultas) {  
                    let consulta = consultas[miConsulta];
                    let estado;
                    if(consulta.SAC_Estado__c == 'SAC_PendienteRespuesta'){
                        estado='Pendiente Respuesta';
                    } else if(consulta.SAC_Estado__c == 'SAC_PendienteRespuestaDefinitiva'){
                        estado='Pendiente Respuesta Definitiva';
                    }
                    let consultaParaAnadir = {
                                                id: consulta.Id,
                                                name: consulta.Name,
                                                consultaIDforURL: '/'+ consulta.Id,
                                                grupo: consulta.SAC_GrupoColaborador__r.Name,
                                                fechaCreacion: consulta.CreatedDate,
                                                estado: estado
                                            }
                    this.dataConsultas.push(consultaParaAnadir);
                    this.mostrarConsultas = true;
                } 
    
                for (var miEscalado in escalados) {  
                    let escalado = escalados[miEscalado];
                    let estado;
                    if(escalado.SAC_Estado__c == 'SAC_PendienteRespuesta'){
                        estado='Pendiente Respuesta';
                    }
                    let escaladoParaAnadir = {
                                                id: escalado.Id,
                                                name: escalado.Name,
                                                escaladoIDforURL: '/'+ escalado.Id,
                                                titulo : escalado.SAC_Titulo__c,
                                                fechaCreacion: escalado.CreatedDate,
                                                estado: estado
                                            }
                    this.dataEscalados.push(escaladoParaAnadir);
                    this.mostrarEscalados = true;
                }
            }else{
                this.mostrarMensaje = true;
                this.mensaje = mensaje;
            }            
        })
        
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

    onHandleSortTareas(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.dataTareas];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.dataTareas = cloneData;
        this.sortDirectionTareas = sortDirection;
        this.sortedBy = sortedBy;
    }

    onHandleSortConsultas(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.dataConsultas];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.dataConsultas = cloneData;
        this.sortDirectionConsultas = sortDirection;
        this.sortedBy = sortedBy;
    }

    onHandleSortEscalados(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.dataEscalados];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.dataEscalados = cloneData;
        this.sortDirectionEscalados = sortDirection;
        this.sortedBy = sortedBy;
    }

    ocultarClick(){
        this.mostrarComprobar = true;
        this.mostrarTareas = false;
        this.mostrarConsultas = false;
        this.mostrarEscalados = false;
        this.mostrarOcultar = false;
        this.mostrarMensaje = false;
    }

    navigateToRecordViewPage(event) {
        this.record = event.detail.row;

        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.record.id,
                //objectApiName: 'Lead', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}