public with sharing class SAC_LCMP_RecuperarReclamacionesCliente {

    private static Set<String> objetos = new Set<String>{'Case','SAC_Accion__c','SAC_Interaccion__c','SAC_TMECaso__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();   
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();   
    private static final Id RECTYPECONSULTACOPS = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    private static final Id RECTYPERECLAMACIONCC = mapRTsObjects.get('Case').get('CC_Cliente').getRecordTypeId();
    private static final Id RECORDTYPEACCIONMASETRO =  mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private static final Id RECORDTYPEACCIONOTRAS =  mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Consulta').getRecordTypeId();
    private static final Id RECTYPEESCALADONV2 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Escalado').getRecordTypeId();
    private static final Id RECTYPEESCALADONV3 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_EscaladoNV3').getRecordTypeId();
    private static final Id RECORDTYPETMEESCALADO = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_TMEEscalado').getRecordTypeId();


    /*****************************************************************
     * Proposito: Recupera las reclamaciones, consultas SAC, consultas COPS y reclamaciones de CC asociadas al cliente que se está consultando. También recupera las pretensiones, tareas, consultas y escalados
     * asociados a estas reclamaciones.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US938202      Raúl Santos    15/07/24        Creación
    ****************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static List<InfoReclamacionWrapper> getReclamacionesCliente(String idCuenta){

        List<InfoReclamacionWrapper> listInfoReclamaciones = new List<InfoReclamacionWrapper>();

        //Recuperar las reclamaciones asociadas a este cliente
        List<Case> listReclamaciones = [SELECT Id, CaseNumber, Subject, SAC_FechaRecepcion__c, toLabel(SAC_Naturaleza__c), CreatedDate, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, SEG_Detalle__r.Name, CC_MCC_Causa__r.Name, CC_MCC_Solucion__r.Name, toLabel(Status), RecordTypeId, SEG_Grupo__r.Name, Priority, OS_Fecha_Resolucion__c, toLabel(SAC_SentidoResolucion__c), Owner.Name, CC_CasoRelacionado__c, CC_CasoRelacionado__r.CaseNumber, toLabel(SAC_CasoEspecial__c), toLabel(CC_Canal_Procedencia__c), ClosedDate, Origin, CC_Tipo_Contacto__c FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPECONSULTASAC OR RecordTypeId = :RECTYPECONSULTACOPS OR RecordTypeId = :RECTYPERECLAMACIONCC) AND AccountId = :idCuenta];

        if(!listReclamaciones.isEmpty()){
            
            Set<Id> idsRec = new Set<Id>();
            List<Case> listaConsultasSac = new List<Case>();

            for(Case rec : listReclamaciones){
                idsRec.add(rec.id);

                if(rec.RecordTypeId == RECTYPECONSULTASAC){
                    listaConsultasSac.add(rec);
                }
            }

            //Recuperar las pretensiones asociadas a las reclamaciones recuperadas
            List<Case> listPretensiones = [SELECT Id, CaseNumber, Subject, CreatedDate, SEG_Grupo__c, SEG_Grupo__r.Name, SAC_EsPrincipal__c, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name, SEG_Detalle__c, SEG_Detalle__r.Name, toLabel(Status), SAC_Reclamacion__C, OwnerId, Owner.Name, SAC_Reclamacion__r.OS_Fecha_Resolucion__c FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__C IN :idsRec];

            //Recuperar los contratos asociados a las pretensiones
            Set<Id> idsPret = new Set<Id>();
            List<SAC_ProductCase__c> listContratos = new List<SAC_ProductCase__c>();

            if(!listPretensiones.isEmpty()){
                for(Case pret : listPretensiones){
                    idsPret.add(pret.id);
                }

                listContratos = [SELECT Id, N_Contrato__c, SAC_Pretension__c FROM SAC_ProductCase__c WHERE SAC_Pretension__c IN :idsPret];
            }

            //Recuperar las tareas asociadas a las reclamaciones recuperadas
            List<SAC_Accion__c> listTareas = [SELECT Id, Name, SAC_Descripcion__c, toLabel(SAC_Estado__c), Owner.Name, SAC_EquipoResponsable__r.Name, CreatedDate, SAC_FechaVencimientoInicial__c, SAC_FechaVencimientoProrroga__c, SAC_Reclamacion__C, SAC_Pretension__r.CaseNumber, SAC_MaestroAccionesReclamacion__r.Name, SAC_GrupoCreadorTarea__c, CreatedBy.Name, SAC_ImporteAbonar__c, SAC_FechaDeEjecucion__c FROM SAC_Accion__c WHERE (RecordTypeId = :RECORDTYPEACCIONMASETRO OR RecordTypeId = :RECORDTYPEACCIONOTRAS) AND SAC_Reclamacion__c IN :idsRec];

            //Recuperar las consultas y escalados asociadas a las reclamaciones recuperadas
            List<SAC_Interaccion__c> listConsultasEscalados = [SELECT Id, Name, SAC_GrupoColaborador__r.Name, CreatedDate, SAC_FechaRespuesta__c, toLabel(SAC_Estado__c), SAC_Titulo__c, toLabel(SAC_MotivoEscalado__c), toLabel(SAC_Conclusion__c), SAC_EscaladoNV3__r.Name, RecordTypeId, SAC_Reclamacion__C, SAC_CasoEscalado__c, SAC_Oficina__r.Name, Owner.Name FROM SAC_Interaccion__c WHERE (RecordTypeId = :RECTYPECONSULTA AND SAC_Reclamacion__c IN :idsRec) OR ((RecordTypeId = :RECTYPEESCALADONV2 OR RecordTypeId = :RECTYPEESCALADONV3) AND SAC_CasoEscalado__c IN :idsRec)];

            //Recuperar la respuesta asociadas a los escalados
            Set<Id> idsEscalados = new Set<Id>();
            List<SAC_TMECaso__c> listTMEEscalado = new List<SAC_TMECaso__c>();

            if(!listConsultasEscalados.isEmpty()){
                for(SAC_Interaccion__c inte : listConsultasEscalados){
                    if(inte.RecordTypeId == RECTYPEESCALADONV2 || inte.RecordTypeId == RECTYPEESCALADONV3){
                        idsEscalados.add(inte.id);
                    }
                }

                listTMEEscalado = [SELECT Id, SAC_FechaFin__c, SAC_Interaccion__c FROM SAC_TMECaso__c WHERE RecordTypeId = :RECORDTYPETMEESCALADO AND SAC_Interaccion__c IN :idsEscalados AND SAC_FechaFin__c <> null AND SAC_Interaccion__r.SAC_Conclusion__c <> null];
            }

            //Recorremos la lista de reclamaciones, para crear un wrapper que asocie cada reclamacion con sus registros relacionados
            for(Case rec : listReclamaciones) {

                List<Case> pretensionesRec = new List<Case>();
                List<SAC_Accion__c> tareasRec = new List<SAC_Accion__c>();
                List<SAC_Interaccion__c> consultasRec = new List<SAC_Interaccion__c>();
                List<SAC_Interaccion__c> escaladosRec = new List<SAC_Interaccion__c>();
                Map<Id, List<SAC_Accion__c>> mapPretConTareas = new Map<Id, List<SAC_Accion__c>>();
                Map<Id, List<SAC_ProductCase__c>> mapPretContratos = new Map<Id, List<SAC_ProductCase__c>>();
                Map<Id, List<SAC_TMECaso__c>> mapEscTME = new Map<Id, List<SAC_TMECaso__c>>();
                List<Case> consultasSacRec = new List<Case>();
                String tipoCaso = '';

                if(rec.RecordTypeId == RECTYPERECLAMACION){
                    tipoCaso = 'reclamacion';

                    //Recorrer las pretensiones para guardar aquellas asociadas a la reclamacion actual
                    for(Case pre : listPretensiones) {
                        if(pre.SAC_Reclamacion__C == rec.Id) {
                            pretensionesRec.add(pre);
                        }
                    }

                    //Recorrer las tareas para guardar aquellas asociadas a la reclamacion actual
                    for(SAC_Accion__c tarea : listTareas) {
                        if (tarea.SAC_Reclamacion__C == rec.Id) {
                            tareasRec.add(tarea);
                        }
                        if(tarea.SAC_Pretension__c != null){
                            for(Case pret : listPretensiones){
                                if(tarea.SAC_Pretension__c == pret.Id){
                                    if(!mapPretConTareas.containsKey(pret.Id)){    //Si la pretensión no está en el mapa, se añade la pretensión y la tarea
                                        List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();
                                        listaTareas.add(tarea);
                                        mapPretConTareas.put(pret.Id, listaTareas);
                                    }else{ //Si la pretensión sí está, se actualiza el mapa de tareas añadiendo la nueva
                                        List<SAC_Accion__c> listaTareas = mapPretConTareas.get(pret.Id);
                                        listaTareas.add(tarea);
                                        mapPretConTareas.put(pret.Id, listaTareas);
                                    }
                                }
                            }
                        }
                    }

                    //Recorrer las consultas y escalados para clasificarlas y guardar aquellas asociadas a la reclamacion actual
                    for(SAC_Interaccion__c consultaEscalado : listConsultasEscalados) {
                        if (consultaEscalado.RecordTypeId == RECTYPECONSULTA && consultaEscalado.SAC_Reclamacion__c == rec.Id) {
                            consultasRec.add(consultaEscalado);
                        } else if ((consultaEscalado.RecordTypeId == RECTYPEESCALADONV2 || consultaEscalado.RecordTypeId == RECTYPEESCALADONV3) && consultaEscalado.SAC_CasoEscalado__c == rec.Id) {
                            escaladosRec.add(consultaEscalado);
                        }
                    }

                    //Recorrer las consultas SAC para guardar aquellas asociadas a la reclamacion actual
                    for(Case caso : listaConsultasSac) {
                        if(caso.CC_CasoRelacionado__c == rec.Id) {
                            consultasSacRec.add(caso);
                        }
                    }

                    //Recorrer los contratos para guardar aquellos asociados a cada pretensión
                    for(SAC_ProductCase__c contrato : listContratos) {
                        if(!mapPretContratos.containsKey(contrato.SAC_Pretension__c)){    //Si la pretensión no está en el mapa, se añade la pretensión y el contrato
                            List<SAC_ProductCase__c> listaContratos = new List<SAC_ProductCase__c>();
                            listaContratos.add(contrato);
                            mapPretContratos.put(contrato.SAC_Pretension__c, listaContratos);
                        }else{ //Si la pretensión sí está, se actualiza el mapa de contratos añadiendo el nuevo
                            List<SAC_ProductCase__c> listaContratos = mapPretContratos.get(contrato.SAC_Pretension__c);
                            listaContratos.add(contrato);
                            mapPretContratos.put(contrato.SAC_Pretension__c, listaContratos);
                        }
                    }

                    //Recorrer los tme escalados para guardar aquellos asociados a cada escalado
                    for(SAC_TMECaso__c tmeEsc : listTMEEscalado) {
                        if(!mapEscTME.containsKey(tmeEsc.SAC_Interaccion__c)){    //Si el escalado no está en el mapa, se añade el escalado y el tme
                            List<SAC_TMECaso__c> listaTME = new List<SAC_TMECaso__c>();
                            listaTME.add(tmeEsc);
                            mapEscTME.put(tmeEsc.SAC_Interaccion__c, listaTME);
                        }else{ //Si el escalado sí está, se actualiza el mapa de tmes añadiendo el nuevo
                            List<SAC_TMECaso__c> listaTME = mapEscTME.get(tmeEsc.SAC_Interaccion__c);
                            listaTME.add(tmeEsc);
                            mapEscTME.put(tmeEsc.SAC_Interaccion__c, listaTME);
                        }
                    }

                }else if(rec.RecordTypeId == RECTYPECONSULTASAC){
                    tipoCaso = 'consultasac';
                }else if(rec.RecordTypeId == RECTYPECONSULTACOPS){
                    tipoCaso = 'consultacops';
                }else if(rec.RecordTypeId == RECTYPERECLAMACIONCC){
                    tipoCaso = 'reclamacioncc';
                }
               
                //Añadimos al wrapper la reclamacion con sus registros asociados
                listInfoReclamaciones.add(new InfoReclamacionWrapper(rec, pretensionesRec, tareasRec, consultasRec, escaladosRec, mapPretConTareas, consultasSacRec, mapPretContratos, mapEscTME, tipoCaso));
            }
        }

        return listInfoReclamaciones;
    }

    public class InfoReclamacionWrapper {
        @AuraEnabled public Case reclamacion;
        @AuraEnabled public List<Case> listPretensiones;
        @AuraEnabled public List<SAC_Accion__c> listTareas;
        @AuraEnabled public List<SAC_Interaccion__c> listConsultas;
        @AuraEnabled public List<SAC_Interaccion__c> listEscalados;
        @AuraEnabled public Map<Id, List<SAC_Accion__c>> mapaPretConTareas;
        @AuraEnabled public List<Case> listConsultasSac;
        @AuraEnabled public Map<Id, List<SAC_ProductCase__c>> mapaPretContratos;
        @AuraEnabled public Map<Id, List<SAC_TMECaso__c>> mapaEscTME;
        @AuraEnabled public String tipoCase;
    
        public InfoReclamacionWrapper(Case reclamacionActual, List<Case> listPretensionesActual, List<SAC_Accion__c> listTareasActual, List<SAC_Interaccion__c> listConsultasActual, List<SAC_Interaccion__c> listEscaladosActual, Map<Id, List<SAC_Accion__c>> mapaPretConTareasActual, List<Case> listConsultasSacActual, Map<Id, List<SAC_ProductCase__c>> mapaPretContratosActual, Map<Id, List<SAC_TMECaso__c>> mapaEscTMEActual, String tipoCaseActual) {
            this.reclamacion = reclamacionActual;
            this.listPretensiones = listPretensionesActual;
            this.listTareas = listTareasActual;
            this.listConsultas = listConsultasActual;
            this.listEscalados = listEscaladosActual;
            this.mapaPretConTareas = mapaPretConTareasActual;
            this.listConsultasSac = listConsultasSacActual;
            this.mapaPretContratos = mapaPretContratosActual;
            this.mapaEscTME = mapaEscTMEActual;
            this.tipoCase = tipoCaseActual;
        }
    } 
}