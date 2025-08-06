import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; 
import getReclamacionesCliente from '@salesforce/apex/SAC_LCMP_RecuperarReclamacionesCliente.getReclamacionesCliente';


export default class Sac_InformacionReclamacion extends NavigationMixin(LightningElement) {

    @api recordId;
    @track infoCasos;
    @track mostrarCasos;
    @track activeSections = ['Pretensiones', 'Tareas', 'Consultas', 'Escalados', 'ConsultasSACrelacionadas'];
    @track hayReclamaciones = false;
    @track hayConsultasSAC = false;
    @track hayConsultasCOPS = false;
    @track hayReclamacionesCC = false;
    @track mostrarTareasPretensiones;


    @wire(getReclamacionesCliente, { idCuenta: '$recordId'}) 
    mapaPermisos(result){ 
        if(result){
            if(result.data !== '' && result.data != undefined){

                this.infoCasos = result.data;

                this.mostrarCasos = this.infoCasos.map(caso => {

                    if(caso.tipoCase === 'reclamacion'){
                        this.hayReclamaciones = true;
                    }else if(caso.tipoCase === 'consultasac'){
                        this.hayConsultasSAC = true;
                    }else if(caso.tipoCase === 'consultacops'){
                        this.hayConsultasCOPS = true;
                    }else if(caso.tipoCase === 'reclamacioncc'){
                        this.hayReclamacionesCC = true;
                    }

                    let listPretensionesMap = caso.listPretensiones.map(pret => {

                        let pretConTareas = false;
                        let tareasDeLaPretension = [];
                        let contratosPret = '';

                        if(Object.keys(caso.mapaPretConTareas).length > 0){
                            for(const key in caso.mapaPretConTareas) {
                                if(key === pret.Id) {
                                    pretConTareas = true;

                                    let currentObject = caso.mapaPretConTareas[key];

                                    const tareasDeLaPret = currentObject.map(tarea => {
                                       return {
                                        ...tarea,
                                        NombreMaestroAccionTarea: (tarea.SAC_MaestroAccionesReclamacion__r && tarea.SAC_MaestroAccionesReclamacion__r.Name) || ''
                                       }
                                    });

                                    tareasDeLaPretension = tareasDeLaPret;
                                    break;
                                }
                            }
                        }

                        if(Object.keys(caso.mapaPretContratos).length > 0){
                            for(const key in caso.mapaPretContratos) {
                                if(key === pret.Id) {
                                    let nContratoArray = [];
                                    pretConTareas = true;

                                    let currentObject = caso.mapaPretContratos[key];

                                    currentObject.forEach(obj => {
                                        nContratoArray.push(obj.N_Contrato__c);
                                    });

                                    contratosPret = nContratoArray.join('\n');
                                    break;
                                }
                            }
                        }

                        return {
                            ...pret,
                            NombreGrupoPretension: (pret.SEG_Grupo__r && pret.SEG_Grupo__r.Name) || '',
                            showDetailsPretension: false,
                            SinTareasAsociadas: pretConTareas,
                            listaTareasPretension: tareasDeLaPretension,
                            NombreTematicaPretension: (pret.CC_MCC_Tematica__r && pret.CC_MCC_Tematica__r.Name) || '',
                            NombreProductoPretension: (pret.CC_MCC_ProdServ__r && pret.CC_MCC_ProdServ__r.Name) || '',
                            NombreMotivoPretension: (pret.CC_MCC_Motivo__r && pret.CC_MCC_Motivo__r.Name) || '',
                            NombreDetallePretension: (pret.SEG_Detalle__r && pret.SEG_Detalle__r.Name) || '',
                            NombreOwnerPretension: (pret.Owner && pret.Owner.Name) || '',
                            FechaResolucionPretension: (pret.SAC_Reclamacion__r && pret.SAC_Reclamacion__r.OS_Fecha_Resolucion__c) || '',
                            ContratosPretension: contratosPret
                        };
                    });

                    const listTareasMap = caso.listTareas.map(tarea => {
                        return {
                            ...tarea,
                            NombrePropietarioTarea: (tarea.Owner && tarea.Owner.Name) || '',
                            NombreEqRespTarea: (tarea.SAC_EquipoResponsable__r && tarea.SAC_EquipoResponsable__r.Name) || '',
                            NumeroPretTarea: (tarea.SAC_Pretension__r && tarea.SAC_Pretension__r.CaseNumber) || '',
                            NombreMaestroTarea: (tarea.SAC_MaestroAccionesReclamacion__r && tarea.SAC_MaestroAccionesReclamacion__r.Name) || '',
                            CreadoPorTarea: (tarea.CreatedBy && tarea.CreatedBy.Name) || ''

                        };
                    });

                    const listConsultasMap = caso.listConsultas.map(consulta => {
                        return {
                            ...consulta,
                            NombreGrupoColabConsulta: (consulta.SAC_GrupoColaborador__r && consulta.SAC_GrupoColaborador__r.Name) || '',
                            NombreOficinaConsulta: (consulta.SAC_Oficina__r && consulta.SAC_Oficina__r.Name) || ''
                        };
                    });

                    const listEscaladosMap = caso.listEscalados.map(escalado => {

                        let fechaRespEsc = '';

                        if(Object.keys(caso.mapaEscTME).length > 0){
                            for(const key in caso.mapaEscTME) {
                                if(key === escalado.Id) {
                                    let currentObject = caso.mapaEscTME[key];

                                    currentObject.forEach(obj => {
                                        fechaRespEsc = obj.SAC_FechaFin__c;
                                    });

                                    break;
                                }
                            }
                        }

                        return {
                            ...escalado,
                            NombreGrupoColabEscalado: (escalado.SAC_GrupoColaborador__r && escalado.SAC_GrupoColaborador__r.Name) || '',
                            NombreEscaladoAJ: (escalado.SAC_EscaladoNV3__r && escalado.SAC_EscaladoNV3__r.Name) || '',
                            NombrePropietarioEscalado: (escalado.Owner && escalado.Owner.Name) || '',
                            FechaRespuestaEscalado : fechaRespEsc
                        };
                    });

                    const listConsultasSacMap = caso.listConsultasSac.map(consulta => {
                        return {
                            ...consulta,
                            NaturalezaConsulta: consulta.SAC_Naturaleza__c || '',
                            GrupoConsulta: (consulta.SEG_Grupo__r && consulta.SEG_Grupo__r.Name) || '',
                            CasoRelacionadoConsulta: (consulta.CC_CasoRelacionado__r && consulta.CC_CasoRelacionado__r.CaseNumber) || '',
                        };
                    });

                    return {
                        idReclamacion: caso.reclamacion.Id || '',
                        SoyReclamacion: caso.tipoCase === 'reclamacion' ? true : false,
                        SoyConsultaSAC: caso.tipoCase === 'consultasac' ? true : false,
                        SoyConsultaCOPS: caso.tipoCase === 'consultacops' ? true : false,
                        SoyReclamacionCC: caso.tipoCase === 'reclamacioncc' ? true : false,
                        NumeroReclamacion: caso.reclamacion.CaseNumber || '',
                        AsuntoReclamacion: caso.reclamacion.Subject || '',
                        SentidoResolucionReclamacion: caso.reclamacion.SAC_SentidoResolucion__c || '',
                        CasoEspecialReclamacion: caso.reclamacion.SAC_CasoEspecial__c || '',
                        CanalProcedenciaReclamacion: caso.reclamacion.CC_Canal_Procedencia__c || '',
                        FechaCreaciónReclamación:  caso.reclamacion.CreatedDate || '',
                        FechaResolucionReclamacion: caso.reclamacion.OS_Fecha_Resolucion__c || '',
                        FechaRecepcionReclamacion:  caso.reclamacion.SAC_FechaRecepcion__c || '',
                        FechaCierreReclamacion:  caso.reclamacion.ClosedDate || '',
                        idCasoRelacionado: caso.reclamacion.CC_CasoRelacionado__r || '',
                        CasoRelacionadoNumber: (caso.reclamacion.CC_CasoRelacionado__r && caso.reclamacion.CC_CasoRelacionado__r.CaseNumber) || '',
                        idTematica: caso.reclamacion.CC_MCC_Tematica__c || '',
                        NombreTematicaReclamacion: (caso.reclamacion.CC_MCC_Tematica__r && caso.reclamacion.CC_MCC_Tematica__r.Name) || '',
                        idProducto: caso.reclamacion.CC_MCC_ProdServ__c || '',
                        NombreProductoReclamacion: (caso.reclamacion.CC_MCC_ProdServ__r && caso.reclamacion.CC_MCC_ProdServ__r.Name) || '',
                        idMotivo: caso.reclamacion.CC_MCC_Motivo__c || '',
                        NombreMotivoReclamacion: (caso.reclamacion.CC_MCC_Motivo__r && caso.reclamacion.CC_MCC_Motivo__r.Name) || '',
                        idDetalle: caso.reclamacion.SEG_Detalle__c || '',
                        NombreDetalleReclamacion: (caso.reclamacion.SEG_Detalle__r && caso.reclamacion.SEG_Detalle__r.Name) || '',
                        idCausa: caso.reclamacion.CC_MCC_Causa__c || '',
                        NombreCausaReclamacion: (caso.reclamacion.CC_MCC_Causa__r && caso.reclamacion.CC_MCC_Causa__r.Name) || '',
                        idSolucion: caso.reclamacion.CC_MCC_Solucion__c || '',
                        NombreSolucionReclamacion: (caso.reclamacion.CC_MCC_Solucion__r && caso.reclamacion.CC_MCC_Solucion__r.Name) || '',
                        idGrupoCaso: caso.reclamacion.SEG_Grupo__c || '' ,
                        NombreGrupoCaso: (caso.reclamacion.SEG_Grupo__r && caso.reclamacion.SEG_Grupo__r.Name) || '',
                        idOwnerCaso: caso.reclamacion.OwnerId || '' ,
                        NombreOwnerCaso: (caso.reclamacion.Owner && caso.reclamacion.Owner.Name) || '',
                        EstadoReclamacion:  caso.reclamacion.Status || '',
                        TienePretensiones: caso.listPretensiones && caso.listPretensiones.length > 0 ? true : false,
                        ListaPretensiones: listPretensionesMap,
                        TieneTareas: caso.listTareas && caso.listTareas.length > 0 ? true : false,
                        ListaTareas: listTareasMap,
                        TieneConsultas: caso.listConsultas && caso.listConsultas.length > 0 ? true : false,
                        ListaConsultas: listConsultasMap,
                        TieneEscalados: caso.listEscalados && caso.listEscalados.length > 0 ? true : false,
                        ListaEscalados: listEscaladosMap,
                        TieneConsultasSAC: caso.listConsultasSac && caso.listConsultasSac.length > 0 ? true : false,
                        ListaConsultasSac: listConsultasSacMap,
                        SinRegistrosAsociados: (caso.listPretensiones && caso.listPretensiones.length <= 0) && (caso.listTareas && caso.listTareas.length <= 0) && (caso.listConsultas && caso.listConsultas.length <= 0) && (caso.listEscalados && caso.listEscalados.length <= 0) && (caso.listConsultasSac && caso.listConsultasSac.length <= 0) ? true : false,
                        Prioridad: caso.reclamacion.Priority || '',
                        CanalEntrada: caso.reclamacion.Origin || '',
                        TipoContacto: caso.reclamacion.CC_Tipo_Contacto__c || '',
                        NaturalezaReclamacion: caso.reclamacion.SAC_Naturaleza__c || '',
                        showDetails: false
                    };
                });
            }
        }else{
            this.deshabilitarBotones = false;
        }
    };

    toggleDetails(event) {
        const recId = event.currentTarget.dataset.id;
        this.mostrarCasos = this.mostrarCasos.map((rec) => {
            if (rec.idReclamacion === recId) {
                return { ...rec, showDetails: !rec.showDetails };
            } else {
                return rec;
            }
        });
    }

    toggleDetailsPretension(event) {
        const pretId = event.currentTarget.dataset.id;

        this.mostrarCasos = this.mostrarCasos.map((rec) => {

            for(let pretension of rec.ListaPretensiones) {
                if(pretension.Id === pretId) {
                    let foundPretension = rec.ListaPretensiones.find((p) => p.Id === pretId);
                    if (foundPretension) {
                      foundPretension.showDetailsPretension = !foundPretension.showDetailsPretension;
                    }
                    return rec;
                }
            }
            return rec;
        });
    }

    redirigirRegistro(event) {
        const recordId = event.currentTarget.dataset.id;
        const recordObject = event.currentTarget.dataset.objeto;
      
        if(recordId != undefined && recordId != ''){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                  recordId: recordId,
                  objectApiName: recordObject,
                  actionName: 'view'
                }
            });
        }
    }
}