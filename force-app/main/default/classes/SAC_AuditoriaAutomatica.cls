/*********************************************************************************************
 * Proposito: Clase batch para ejecutar las auditorías automáticas.                                 
 * 
 * Historial
 * VERSION        USER_STORY            AUTHOR                DATE        Description
 * 1.0             US791098           Raúl Santos           04/01/24       Creación
 * 1.2            US1278233             Jose M. Fernández     20/06/2025  Modificado: cambiar queries/lógica para usar campos nuevos    
 * *******************************************************************************************/

public with sharing class SAC_AuditoriaAutomatica implements Database.batchable<sObject>{

    private static Set<String> objetos = new Set<String>{'SEG_Auditoria__c','Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private final static Id RECORDTYPEAUDITORIA = mapRTsObjects.get('SEG_Auditoria__c').get('SAC_Auditoria').getRecordTypeId();
    private final static Id RECORDTYPEAUDITORIAGENERAL = mapRTsObjects.get('SEG_Auditoria__c').get('SAC_AuditoriaGeneral').getRecordTypeId();
    private final static Id RECORDTYPEAUDITORIAAUTOMATICA = mapRTsObjects.get('SEG_Auditoria__c').get('SAC_AuditoriaAutomatica').getRecordTypeId();
    private final static Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private final static Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    
    public Database.QueryLocator start(Database.BatchableContext dbc) {

        //Recuperamos las auditorías automáticas que esten activas y que la fecha del momento en que se ejecuta este comprendida entre las fechas inicio y fin de las auditorías
        return Database.getQueryLocator([SELECT Id, SAC_NombreAuditoria__c, SAC_FechaCierre__c,	SAC_GrupoProveedor__c, 	SAC_GrupoLetrado__c, SAC_ImporteAbonadoDesde__c, 
                                                SAC_ImporteAbonadoHasta__c, SAC_MCCTematicaList__c, SAC_MCCProductoList__c, SAC_MCCMotivoList__c, SAC_MCCDetalleList__c, SAC_MCCTematicaListLabel__c, SAC_MCCProductoListLabel__c, SAC_MCCMotivoListLabel__c, SAC_MCCDetalleListLabel__c, SAC_NumMaxReclamaciones__c, 
                                                SAC_GrupoResponsableResolver__c, SAC_SoloPretPpal__c, SAC_Tipo__c, SAC_SLACalidad__c, SAC_PeriocidadEjecucion__c, SAC_FechaUltimaEjecucion__c, SAC_SentidoResolucion__c
                                                FROM SEG_Auditoria__c 
                                                WHERE recordTypeId =: RECORDTYPEAUDITORIAAUTOMATICA 
                                                AND SAC_Activo__c = true
                                                AND SAC_FechaInicio__c <=: Date.today()
                                                AND SAC_FechaFin__c >=: Date.today()]);
    }

    public void execute(Database.BatchableContext dbc, List<SEG_Auditoria__c> listAuditorias){

        if(!listAuditorias.isEmpty()){
            //Se va a ejecutar de uno en uno luego tomo el elemento 0 de la lista
            SEG_Auditoria__c auditoriaAutomatica = listAuditorias[0];

            //Comprobamos si la auditoría se debe ejecutar
            Boolean ejecutarAuditoria = verificarEjecucionAuditoria(auditoriaAutomatica);

            //En caso de devolver true, comienza la ejecución de la auditoría programada
            if(ejecutarAuditoria){
                
                DateTime fechaDesde = null;
                DateTime fechaHasta = null;

                auditoriaAutomatica.SAC_FechaUltimaEjecucion__c = System.now();
    
                //Si la auditoría tiene una fecha de cierre informada, realizamos la lógica para a partir de la fecha cierre completar la fechaCierreDesde y fechaCierreHasta
                if(String.isNotBlank(auditoriaAutomatica.SAC_FechaCierre__c)){
                    FechaCierreRango fechaCierreRango = establecerFechaCierre(auditoriaAutomatica.SAC_FechaCierre__c);
                    fechaDesde = fechaCierreRango.fechaCierreDesde;
                    fechaHasta = fechaCierreRango.fechaCierreHasta;
                }
    
                //Creación de un wrapper con los campos de la auditoría necesarios para la búsqueda de reclamaciones
                FiltrosBusquedaReclamaciones filtroBusqueda = new FiltrosBusquedaReclamaciones(auditoriaAutomatica.SAC_Tipo__c, fechaDesde, fechaHasta, auditoriaAutomatica.SAC_GrupoProveedor__c, auditoriaAutomatica.SAC_GrupoLetrado__c, 
                                                                            auditoriaAutomatica.SAC_ImporteAbonadoDesde__c, auditoriaAutomatica.SAC_ImporteAbonadoHasta__c, (String.isNotBlank(auditoriaAutomatica.SAC_MCCTematicaList__c))? auditoriaAutomatica.SAC_MCCTematicaList__c.split(';') : null, 
                                                                            (String.isNotBlank(auditoriaAutomatica.SAC_MCCProductoList__c))? auditoriaAutomatica.SAC_MCCProductoList__c.split(';') : null, (String.isNotBlank(auditoriaAutomatica.SAC_MCCMotivoList__c))? auditoriaAutomatica.SAC_MCCMotivoList__c.split(';') : null,
                                                                            (String.isNotBlank(auditoriaAutomatica.SAC_MCCDetalleList__c))? auditoriaAutomatica.SAC_MCCDetalleList__c.split(';') : null, Integer.valueOf(auditoriaAutomatica.SAC_NumMaxReclamaciones__c), auditoriaAutomatica.SAC_SentidoResolucion__c);
    
                //Recuperamos las reclamaciones que cumplan estos criterios
                List<Case> listReclamaciones = buscarReclamaciones(filtroBusqueda, auditoriaAutomatica.SAC_SoloPretPpal__c);
    
                if(!listReclamaciones.isEmpty()){
                    
                    List<Case> listRecUpdate = new List<Case>();
                    List<SEG_Auditoria__c> listAuditoriasHijas = new List<SEG_Auditoria__c>();
                    SAC_LCMP_AuditoriasController.DetallesAuditoria detallesNuevaAuditoria;
    
                    Integer numAuditorias = listReclamaciones.size(); 
    
                    //Dependiendo si la fechaDesde/fechaHasta esta informada, completamos el wrapper con los campos para crear la auditoría de una forma u otra
                    if(fechaDesde != null && fechaHasta != null){
                        detallesNuevaAuditoria = new SAC_LCMP_AuditoriasController.DetallesAuditoria(auditoriaAutomatica.SAC_Tipo__c, auditoriaAutomatica.SAC_SLACalidad__c, fechaDesde.date(), fechaHasta.date().addDays(-1), auditoriaAutomatica.SAC_GrupoProveedor__c, auditoriaAutomatica.SAC_GrupoLetrado__c, null, null, auditoriaAutomatica.SAC_ImporteAbonadoDesde__c, auditoriaAutomatica.SAC_ImporteAbonadoHasta__c, auditoriaAutomatica.SAC_MCCTematicaList__c, auditoriaAutomatica.SAC_MCCProductoList__c, auditoriaAutomatica.SAC_MCCMotivoList__c, auditoriaAutomatica.SAC_MCCDetalleList__c, auditoriaAutomatica.SAC_MCCTematicaListLabel__c, auditoriaAutomatica.SAC_MCCProductoListLabel__c, auditoriaAutomatica.SAC_MCCMotivoListLabel__c, auditoriaAutomatica.SAC_MCCDetalleListLabel__c, auditoriaAutomatica.SAC_GrupoResponsableResolver__c);
                    }else{
                        detallesNuevaAuditoria = new SAC_LCMP_AuditoriasController.DetallesAuditoria(auditoriaAutomatica.SAC_Tipo__c, auditoriaAutomatica.SAC_SLACalidad__c, null, null, auditoriaAutomatica.SAC_GrupoProveedor__c, auditoriaAutomatica.SAC_GrupoLetrado__c, null, null, auditoriaAutomatica.SAC_ImporteAbonadoDesde__c, auditoriaAutomatica.SAC_ImporteAbonadoHasta__c, auditoriaAutomatica.SAC_MCCTematicaList__c, auditoriaAutomatica.SAC_MCCProductoList__c, auditoriaAutomatica.SAC_MCCMotivoList__c, auditoriaAutomatica.SAC_MCCDetalleList__c, auditoriaAutomatica.SAC_MCCTematicaListLabel__c, auditoriaAutomatica.SAC_MCCProductoListLabel__c, auditoriaAutomatica.SAC_MCCMotivoListLabel__c, auditoriaAutomatica.SAC_MCCDetalleListLabel__c, auditoriaAutomatica.SAC_GrupoResponsableResolver__c);
                    }
    
                    //Creamos la auditoria padre
                    SEG_Auditoria__c auditoriaPadre = SAC_LCMP_AuditoriasController.generarAuditoria(RECORDTYPEAUDITORIAGENERAL, detallesNuevaAuditoria);
                    String sufijoNombre = '';
                    if(auditoriaAutomatica.SAC_PeriocidadEjecucion__c != null){
                        sufijoNombre = crearSufijoNombre(auditoriaAutomatica.SAC_PeriocidadEjecucion__c);
                    }
                    auditoriaPadre.SAC_NombreAuditoria__c = auditoriaAutomatica.SAC_NombreAuditoria__c + ' ' + sufijoNombre;
                    auditoriaPadre.SAC_TotalReclamacionesAuditadas__c = numAuditorias;
                    //US844784 - 24/04/2024 - Raúl Santos - Añadido el campo SAC_SentidoResolucion__c
                    auditoriaPadre.SAC_SentidoResolucion__c = auditoriaAutomatica.SAC_SentidoResolucion__c;
                    auditoriaPadre.SAC_TotalPendientes__c = numAuditorias;
                    auditoriaPadre.SAC_TotalOk__c = 0;
                    auditoriaPadre.SAC_TotalKo__c = 0;
                    auditoriaPadre.SAC_TotalNoAplica__c = 0;
                    auditoriaPadre.SAC_PorcentajeAcierto__c = '0%';
                    auditoriaPadre.SAC_AuditoriaGeneral__c = auditoriaAutomatica.Id;
                    SAC_DatabaseDML.insertDML(auditoriaPadre, false);   
                    
                    //Para cada reclamación auditada, creamos su respectiva auditoría
                    for(Case reclamacion : listReclamaciones){
                        //Actualizamos el campo SEG_SRAuditoria__c de la reclamacion
                        reclamacion.SEG_SRAuditoria__c = true;
                        listRecUpdate.add(reclamacion);
    
                        //Creamos el registro de la auditoria      
                        SEG_Auditoria__c auditoriaHija = SAC_LCMP_AuditoriasController.generarAuditoria(RECORDTYPEAUDITORIA, detallesNuevaAuditoria); 
                        auditoriaHija.SAC_NombreAuditoria__c = auditoriaPadre.SAC_NombreAuditoria__c;
                        auditoriaHija.SAC_AuditoriaGeneral__c = auditoriaPadre.Id;
                        auditoriaHija.SAC_Reclamacion__c = reclamacion.Id;
    
                        listAuditoriasHijas.add(auditoriaHija);
                    }
    
                    //Actualizamos las reclamaciones, insertamos las auditorias e informamos la fecha de ejecución en la auditoría automática
                    if(!listRecUpdate.isEmpty() && !listAuditoriasHijas.isEmpty()){        
                        if (Schema.sObjectType.Case.isUpdateable()){
                            SAC_DatabaseDML.updateListDML(listRecUpdate, false);
                        } 
    
                        if (Schema.sObjectType.SEG_Auditoria__c.isCreateable()){
                            SAC_DatabaseDML.insertListDML(listAuditoriasHijas, false);
    
                            SAC_LCMP_AuditoriasController.crearPuntosDeControlAuditoria(listAuditoriasHijas, auditoriaAutomatica.SAC_Tipo__c);
                        }   
                    }
                }
                if (Schema.sObjectType.SEG_Auditoria__c.isUpdateable()){
                    SAC_DatabaseDML.updateDML(auditoriaAutomatica, false);
                } 
            }
        }
    }

    public void finish(Database.BatchableContext dbc){
        CBK_Log.debug('Auditoría automática ejecutada con éxito');
    }
	/*********************************************************************************************
     * Proposito: Añadir sufijo al nombre de la Auditoría según sea diaria, mensual o anual                              
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0            US1278177            Iria ANPC            24/06/25       Creación
     * *******************************************************************************************/
    public static String crearSufijoNombre(String periodicidad){
        String sufijoNombre = '';
        DateTime day = CBK_UtilsDate.nowDT();
        Integer month = day.month();
        Integer year = day.year();
        
        List<String> monthList = new List<String>{'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'};
            if(periodicidad.contains('Diaria')){
                sufijoNombre = day.format('dd/MM/yyyy');
            }else if(periodicidad.contains('Mensual')){
                sufijoNombre = monthList[month - 1] + ' ' + String.valueOf(year);
            }
        return sufijoNombre;
    }

    /*********************************************************************************************
     * Proposito: Dependiendo de si la auditoría programada tiene el campo de solo pret principal de la reclamación o todas las pretensiones,
     *            llamamos a un método u otro.                               
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US791098           Raúl Santos           04/01/24       Creación
     * *******************************************************************************************/
    public static List<Case> buscarReclamaciones (FiltrosBusquedaReclamaciones filtroBusqueda, Boolean soloPretPpal){

        if(soloPretPpal == true){
            return buscarReclamacionesSoloPretPpal(filtroBusqueda);
        }else{
            return buscarReclamacionesTodasPretensiones(filtroBusqueda);
        }
    }


    /*********************************************************************************************
     * Proposito: Búsqueda por Pret Principal de la reclamación.
     *            Creación de querys dinámicas. Se crearán las querys dependiendo de los criterios de busqueda de la auditoría automática.
     *            Devolverá la lista de reclamaciones que cumplan estos criterios.                                
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US791098           Raúl Santos           04/01/24       Creación
     * 1.1             US844784           Raúl Santos           24/04/24       Modificado: Añadida la búsqueda por estados y por sentido de resolucion
     * *******************************************************************************************/
    public static List<Case> buscarReclamacionesSoloPretPpal(FiltrosBusquedaReclamaciones filtroBusqueda){
    
        List<Case> reclamacionesAuditoria = new List<Case>();
        List<String> estadosRec = new List<String>{'Cerrado','SAC_008'};
        Integer numMaxReclamaciones = filtroBusqueda.numMaxReclamaciones;

        String selectQ = 'SELECT Id, CaseNumber, SEG_Grupo__c, SAC_GrupoLetrado__c, CC_Importe_Abonado__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, SEG_Detalle__c FROM Case';
        String whereQ = ' WHERE RecordTypeId =: RECORDTYPERECLAMACION AND Status IN :estadosRec AND SEG_SRAuditoria__c = false AND ClosedDate != null';
        String limitQ = ' LIMIT :numMaxReclamaciones';
    
        if(String.isnotBlank(filtroBusqueda.tipoAuditoriaStr) && !filtroBusqueda.tipoAuditoriaStr.contains('Todas')){ 
            String tipoAuditoria = filtroBusqueda.tipoAuditoriaStr;
            if(tipoAuditoria.contains('Subsanacion')){
                whereQ = whereQ + ' AND SAC_TipoSubsanacion__c != null'; 
            }
            if(tipoAuditoria.contains('Analisis')){
                whereQ = whereQ + ' AND SAC_FechaUltimaAsignacionLetrado__c != null';
            }
            if(tipoAuditoria.contains('Negociacion')){
                whereQ = whereQ + ' AND SAC_FechaFinNegociacion__c != null'; 
            }
            if(tipoAuditoria.contains('Resolucion')){
                whereQ = whereQ + ' AND OS_Fecha_Resolucion__c != null';
            }
            if(tipoAuditoria.contains('Ejecucion')){
                whereQ = whereQ + ' AND SAC_FechaEjecucion__c != null'; 
            }
            if(tipoAuditoria.contains('Derivacion')){
                whereQ = whereQ + ' AND SAC_FechaDerivacion__c != null'; 
            }
        }
        if(filtroBusqueda.fechaCierreDesde != null && filtroBusqueda.fechaCierreHasta !=  null){
            DateTime fechaDesde = filtroBusqueda.fechaCierreDesde;
            DateTime fechaHasta = filtroBusqueda.fechaCierreHasta;
            whereQ = whereQ + ' AND ClosedDate >=: fechaDesde AND ClosedDate <=: fechaHasta';
        }
        if(String.isNotBlank(filtroBusqueda.grupoProvId)){
            String grupoProvId = filtroBusqueda.grupoProvId;   
            whereQ = whereQ + ' AND SEG_Grupo__c =: grupoProvId';
        }
        if(String.isNotBlank(filtroBusqueda.despachosId)){
            String despachosId = filtroBusqueda.despachosId; 
            whereQ = whereQ + ' AND SAC_GrupoLetrado__c =: despachosId';
        } 
        if(filtroBusqueda.impAbonadoDesde != null &&  filtroBusqueda.impAbonadoDesde != 0){
            Decimal impAbonadoDesde = filtroBusqueda.impAbonadoDesde; 
            whereQ = whereQ + ' AND CC_Importe_Abonado__c >=: impAbonadoDesde';
        }
        if(filtroBusqueda.impAbonadoHasta != null &&  filtroBusqueda.impAbonadoHasta != 0){
            Decimal impAbonadoHasta = filtroBusqueda.impAbonadoHasta; 
            whereQ = whereQ + ' AND CC_Importe_Abonado__c <=: impAbonadoHasta';
        }
        if(String.isNotBlank(filtroBusqueda.sentidoResolucionStr)){
            List<String> sentidosResolucion = filtroBusqueda.sentidoResolucionStr.split(';');

            whereQ = whereQ + ' AND toLabel(SAC_SentidoResolucion__c) IN :sentidosResolucion';
        }
        if(filtroBusqueda.listIdsTematica != null && !filtroBusqueda.listIdsTematica.isEmpty()){
            List<String> listIdsTematica = filtroBusqueda.listIdsTematica;
            whereQ = whereQ + ' AND CC_MCC_Tematica__c IN :listIdsTematica';
        }
        if(filtroBusqueda.listIdsProducto != null && !filtroBusqueda.listIdsProducto.isEmpty()){
            List<String> listIdsProducto = filtroBusqueda.listIdsProducto;
            whereQ = whereQ + ' AND CC_MCC_ProdServ__c IN :listIdsProducto';
        }
        if(filtroBusqueda.listIdsMotivo != null && !filtroBusqueda.listIdsMotivo.isEmpty()){
            List<String> listIdsMotivo = filtroBusqueda.listIdsMotivo;
            whereQ = whereQ + ' AND CC_MCC_Motivo__c IN :listIdsMotivo';
        }
        if(filtroBusqueda.listIdsDetalle != null && !filtroBusqueda.listIdsDetalle.isEmpty()){
            List<String> listIdsDetalle = filtroBusqueda.listIdsDetalle;
            whereQ = whereQ + ' AND SEG_Detalle__c IN :listIdsDetalle';
        }

        if(String.isnotBlank(whereQ)){
            reclamacionesAuditoria = Database.query(String.escapeSingleQuotes(selectQ + whereQ + limitQ));
            return reclamacionesAuditoria;
        }

        return reclamacionesAuditoria;
    }


    /*********************************************************************************************
     * Proposito: Búsqueda por todas las pretensiones de la reclamación.
     *            Creación de querys dinámicas. Se crearán las querys dependiendo de los criterios de busqueda de la auditoría automática.
     *            Devolverá la lista de reclamaciones que cumplan estos criterios.                                
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US791098           Raúl Santos           04/01/24       Creación
     * 1.1             US844784           Raúl Santos           24/04/24       Modificado: Añadida la búsqueda por estados y por sentido de resolucion
     * *******************************************************************************************/
    public static List<Case> buscarReclamacionesTodasPretensiones(FiltrosBusquedaReclamaciones filtroBusqueda){
    
        List<Case> listPrets = new List<Case>();
        List<Case> listReclamaciones = new List<Case>();
        List<String> estadosRec = new List<String>{'Cerrado','SAC_008'};

        String selectQ = 'SELECT Id, SAC_Reclamacion__c, CC_MCC_ProdServ__c FROM Case';
        String whereQ = ' WHERE RecordTypeId =: RECORDTYPEPRETENSION AND SAC_Reclamacion__r.Status IN :estadosRec AND SAC_Reclamacion__r.SEG_SRAuditoria__c = false AND SAC_Reclamacion__r.ClosedDate != null';
    
        if(String.isnotBlank(filtroBusqueda.tipoAuditoriaStr) && !filtroBusqueda.tipoAuditoriaStr.contains('Todas')){ 
            String tipoAuditoria = filtroBusqueda.tipoAuditoriaStr;
            if(tipoAuditoria.contains('Subsanacion')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_TipoSubsanacion__c != null'; 
            }
            if(tipoAuditoria.contains('Analisis')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_FechaUltimaAsignacionLetrado__c != null'; 
            }
            if(tipoAuditoria.contains('Negociacion')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_FechaFinNegociacion__c != null';  
            }
            if(tipoAuditoria.contains('Resolucion')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.OS_Fecha_Resolucion__c != null'; 
            }
            if(tipoAuditoria.contains('Ejecucion')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_FechaEjecucion__c != null'; 
            }
            if(tipoAuditoria.contains('Derivacion')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_FechaDerivacion__c != null'; 
            }
        }
        if(filtroBusqueda.fechaCierreDesde != null && filtroBusqueda.fechaCierreHasta !=  null){
            DateTime fechaDesde = filtroBusqueda.fechaCierreDesde;
            DateTime fechaHasta = filtroBusqueda.fechaCierreHasta;
            whereQ = whereQ + ' AND SAC_Reclamacion__r.ClosedDate >=: fechaDesde AND SAC_Reclamacion__r.ClosedDate <=: fechaHasta';
        }
        if(String.isNotBlank(filtroBusqueda.grupoProvId)){
            String grupoProvId = filtroBusqueda.grupoProvId;   
            whereQ = whereQ + ' AND SAC_Reclamacion__r.SEG_Grupo__c =: grupoProvId';
        }
        if(String.isNotBlank(filtroBusqueda.despachosId)){
            String despachosId = filtroBusqueda.despachosId; 
            whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_GrupoLetrado__c =: despachosId';
        } 
        if(filtroBusqueda.impAbonadoDesde != null &&  filtroBusqueda.impAbonadoDesde != 0){
            Decimal impAbonadoDesde = filtroBusqueda.impAbonadoDesde; 
            whereQ = whereQ + ' AND SAC_Reclamacion__r.CC_Importe_Abonado__c >=: impAbonadoDesde';
        }
        if(filtroBusqueda.impAbonadoHasta != null &&  filtroBusqueda.impAbonadoHasta != 0){
            Decimal impAbonadoHasta = filtroBusqueda.impAbonadoHasta; 
            whereQ = whereQ + ' AND SAC_Reclamacion__r.CC_Importe_Abonado__c <=: impAbonadoHasta';
        }
        if(String.isNotBlank(filtroBusqueda.sentidoResolucionStr)){
            List<String> sentidosResolucion = filtroBusqueda.sentidoResolucionStr.split(';');

            whereQ = whereQ + ' AND toLabel(SAC_Reclamacion__r.SAC_SentidoResolucion__c) IN :sentidosResolucion';
        }
        if(filtroBusqueda.listIdsTematica != null && !filtroBusqueda.listIdsTematica.isEmpty()){
            List<String> listIdsTematica = filtroBusqueda.listIdsTematica;
            whereQ = whereQ + ' AND CC_MCC_Tematica__c IN :listIdsTematica';
        }
        if(filtroBusqueda.listIdsProducto != null && !filtroBusqueda.listIdsProducto.isEmpty()){
            List<String> listIdsProducto = filtroBusqueda.listIdsProducto;
            whereQ = whereQ + ' AND CC_MCC_ProdServ__c IN :listIdsProducto';
        }
        if(filtroBusqueda.listIdsMotivo != null && !filtroBusqueda.listIdsMotivo.isEmpty()){
            List<String> listIdsMotivo = filtroBusqueda.listIdsMotivo;
            whereQ = whereQ + ' AND CC_MCC_Motivo__c IN :listIdsMotivo';
        }
        if(filtroBusqueda.listIdsDetalle != null && !filtroBusqueda.listIdsDetalle.isEmpty()){
            List<String> listIdsDetalle = filtroBusqueda.listIdsDetalle;
            whereQ = whereQ + ' AND SEG_Detalle__c IN :listIdsDetalle';
        }
        
        if(String.isnotBlank(whereQ)){
            Set<Id> idsUnicos = new Set<Id>();

            listPrets = Database.query(String.escapeSingleQuotes(selectQ + whereQ));
            if(!listPrets.isEmpty()){
                for(Case pret : listPrets){
                    if(!idsUnicos.contains(pret.SAC_Reclamacion__c)){
                        idsUnicos.add(pret.SAC_Reclamacion__c);
                    }
                }
            }
            Integer numMaxReclamaciones = filtroBusqueda.numMaxReclamaciones;

            listReclamaciones = [SELECT Id, CaseNumber, SEG_Grupo__c, SAC_GrupoLetrado__c, CC_Importe_Abonado__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, SEG_Detalle__c FROM Case WHERE RecordTypeId =: RECORDTYPERECLAMACION AND Id IN :idsUnicos LIMIT :numMaxReclamaciones];
        }

        return listReclamaciones;
    }


    /*********************************************************************************************
     * Proposito: Si la auditoría automática tiene el campo SAC_FechaCierre__c informado. Tratamos la información de este
     *            para devolver la fechaCierreDesde y fechaCierreHasta                       
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US791098           Raúl Santos           04/01/24       Creación
     * *******************************************************************************************/
    public static FechaCierreRango establecerFechaCierre(String fechaCierre){
    
        String valorTextoStr;
        Integer valorNumerico;
        DateTime fechaCierreDesde;
        DateTime fechaCierreHasta; 

        //Dependiendo del formato con el que llegue fechaCierre, guardamos en la varaible 'valorTextoStr' para trabajar en el switch
        if(fechaCierre.startsWith('Últimos')) {
            List<String> partes = fechaCierre.split(' ');
            valorTextoStr = partes[0].trim() + partes[2].trim();
            String valorNumericoStr = partes[1].trim();
            valorNumerico = Integer.valueOf(valorNumericoStr);
        }else{
            valorTextoStr = fechaCierre;
        }
        
        switch on valorTextoStr {
            when 'Hoy' {
                //Establece la fecha cierre desde al día actual a las 00:00h
                fechaCierreDesde = Date.today();
               
                //Establece la fecha cierre hasta al día actual a las 23:59:59h
                fechaCierreHasta = fechaCierreDesde.addDays(1).addSeconds(-1);
            }	
            when 'Ayer' {
                //Establece la fecha cierre desde al día anterior a las 00:00h
                fechaCierreDesde = Date.today().addDays(-1);
            
                //Establece la fecha cierre hasta al día anterior a las 23:59:59h
                fechaCierreHasta = fechaCierreDesde.addDays(1).addSeconds(-1);
            }
            when 'Últimosdías' { 
                //Establece la fecha cierre desde a los X (los días informados en 'valorNumerico') días anteriores a las 00:00h
                fechaCierreDesde = Date.today().addDays(-valorNumerico);

                //Establece la fecha cierre hasta al día actual a las 23:59:59h
                DateTime today = Date.today();
                fechaCierreHasta = today.addDays(1).addSeconds(-1);
            }
            when 'Este mes' {
                //Establece la fecha cierre desde al primer día del mes actual a las 00:00h
                fechaCierreDesde = Date.today().toStartOfMonth(); 

                //Establece la fecha cierre hasta al último día del mes actual a las 23:59:59h
                fechaCierreHasta = fechaCierreDesde.addMonths(1).addSeconds(-1);
            }
            when 'Últimosmeses' {
                //Establece la fecha cierre desde al primer día a las 00:00h del mes actual - X (siendo 'X' los meses informados en 'valorNumerico')
                fechaCierreDesde = Date.today().addMonths(-valorNumerico).toStartOfMonth();
                
                //Establece la fecha cierre hasta al último día a las 23:59:59h del mes anterior al actual
                DateTime mesActual = Date.today().toStartOfMonth();
                fechaCierreHasta = mesActual.addSeconds(-1);
            }
            when 'Este año' {
                //Establece la fecha cierre desde al primer día del año actual a las 00:00h
                fechaCierreDesde = Date.newInstance(Date.today().year(), 1, 1);

                //Establece la fecha cierre hasta al último día del año actual a las 23:59:59h
                fechaCierreHasta = Datetime.newInstanceGmt(Date.today().year(), 12, 31, 23, 59, 59);
            }
            when 'Últimosaños' {
                //Establece la fecha cierre desde al primer día a las 00:00h del año actual - X (siendo 'X' los años informados en 'valorNumerico')
                fechaCierreDesde = Date.newInstance(Date.today().year() - valorNumerico, 1, 1);
                
                //Establece la fecha cierre hasta al último día a las 23:59:59h del año anterior al actual
                fechaCierreHasta = Datetime.newInstanceGmt(Date.today().year() - valorNumerico, 12, 31, 23, 59, 59);
            }
        }

        FechaCierreRango rangoFechaCierre = new FechaCierreRango(fechaCierreDesde, fechaCierreHasta);

        return rangoFechaCierre;
    }


    /*********************************************************************************************
     * Proposito: Tratar la información del campo SAC_PeriocidadEjecucion__c de la auditoría para verificar si en el momento que se lanza
     *            el batch, las auditorías recogidas en la query del start, cumplen las condiciones para ejecutarse                       
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US791098           Raúl Santos           04/01/24       Creación
     * *******************************************************************************************/
    public static Boolean verificarEjecucionAuditoria(SEG_Auditoria__c auditoria){
    
        Boolean ejecutarAuditoria = false;

        //Separamos la cadena para obtener: Ejecucion Diaria/Mensual por un lado, y los días de la semana/meses por otro
        List<String> partes = auditoria.SAC_PeriocidadEjecucion__c.split(':');

        //Si la auditoría tiene una periocidad diaria
        if(partes[0].contains('Diaria')){

            //Mapeamos los días de la semana al formato: día - número
            Map<String, Integer> diasSemana = new Map<String, Integer>{
                'Lunes' => 1,
                'Martes' => 2,
                'Miércoles' => 3,
                'Jueves' => 4,
                'Viernes' => 5,
                'Sábado' => 6,
                'Domingo' => 7,
                'Todos los días' => 8
            };

            List<String> diasPeriocidad = partes[1].split(',');

            //Recuperamos el día actual de la semana en formato numérico donde: 1 es lunes... 7 es domingo
            Integer diaActualNumero = Integer.valueOf(System.now().format('u'));             

            //Recorremos los días de periocidad de la auditoría
            for(String diaPeriocidad : diasPeriocidad) {
                String dia = diaPeriocidad.trim();

                //Si el día de la periocidad está entre los permitidos AND (día de la periocidad -de la auditoria- es igual al día actual OR día de la periocidad -de la auditoria- es igual TODOS) AND auditoira.SAC_FechaUltimaEjecucion__c es diferente de HOY, si la expresión devuelve Sí, la auditoría programada se ejecutará
                if(diasSemana.containsKey(dia) && (diasSemana.get(dia) == diaActualNumero || diasSemana.get(dia) == 8) && ((auditoria.SAC_FechaUltimaEjecucion__c != null && Date.valueOf(auditoria.SAC_FechaUltimaEjecucion__c.addHours(2)) != CBK_UtilsDate.todayDT()) || auditoria.SAC_FechaUltimaEjecucion__c == null)) { 
                    ejecutarAuditoria = true;
                }
            }
        }else if(partes[0].contains('Mensual')){
            //Si la auditoría tiene una periocidad mensual

            //Mapeamos los meses del año al formato: mes - número
            Map<String, Integer> mesesAnio = new Map<String, Integer>{
                'Enero' => 1,
                'Febrero' => 2,
                'Marzo' => 3,
                'Abril' => 4,
                'Mayo' => 5,
                'Junio' => 6,
                'Julio' => 7,
                'Agosto' => 8,
                'Septiembre' => 9,
                'Octubre' => 10,
                'Noviembre' => 11,
                'Diciembre' => 12,
                'Todos los meses' => 13
            };

            List<String> mesesPeriocidad = partes[1].split(',');

            //Recuperamos el mes actual en formato numérico donde: 1 es enero... 12 es diciembre
            Integer mesActualNumero = Integer.valueOf(System.now().format('MM'));             

            //Si la fecha de ultima ejecucion viene informada, almacenamos el mes en el que se ejecuto por última vez
            Integer mesUltimaEjecucion = -1;  
            if(Date.valueOf(auditoria.SAC_FechaUltimaEjecucion__c) != null){
                mesUltimaEjecucion = Date.valueOf(auditoria.SAC_FechaUltimaEjecucion__c.addHours(2)).month();     
            }            

            //Recorremos los meses de periocidad de la auditoría
            for(String mesPeriocidad : mesesPeriocidad) {
                String mes = mesPeriocidad.trim();

                //Si el mes de la periocidad está entre los permitidos AND (dímesa de la periocidad -de la auditoria- es igual al mes actual OR mes de la periocidad -de la auditoria- es igual TODOS) AND auditoira.SAC_FechaUltimaEjecucion__c es diferente de MES ACTUAL, si la expresión devuelve Sí, la auditoría programada se ejecutará
                if(mesesAnio.containsKey(mes) && (mesesAnio.get(mes) == mesActualNumero || mesesAnio.get(mes) == 13) && (mesUltimaEjecucion != mesActualNumero)) { 
                    ejecutarAuditoria = true;
                }
            }
        }

        return ejecutarAuditoria;
    }

    public class FiltrosBusquedaReclamaciones{

        public String tipoAuditoriaStr{get; set;}
        public DateTime fechaCierreDesde{get; set;}
        public DateTime fechaCierreHasta{get; set;}
        public Id grupoProvId {get; set;}
        public Id despachosId{get; set;}
        public Decimal impAbonadoDesde {get; set;}
        public Decimal impAbonadoHasta {get; set;}
        public List<String> listIdsTematica {get; set;}
        public List<String> listIdsProducto {get; set;}
        public List<String> listIdsMotivo {get; set;}
        public List<String> listIdsDetalle {get; set;}
        public Integer numMaxReclamaciones {get; set;}
        public String sentidoResolucionStr{get; set;}

        public filtrosBusquedaReclamaciones(String tipoAuditoriaStrActual, DateTime fechaCierreDesdeActual, DateTime fechaCierreHastaActual, Id grupoProvIdActual, Id despachosIdActual, Decimal impAbonadoDesdeActual,
        Decimal impAbonadoHastaActual, List<String> listIdsTematicaActual, List<String> listIdsProductoActual, List<String> listIdsMotivoActual, List<String> listIdsDetalleActual,
        Integer numMaxReclamacionesActual, String sentidoResolucionStrActual)
        {
            tipoAuditoriaStr = tipoAuditoriaStrActual;
            fechaCierreDesde = fechaCierreDesdeActual;
            fechaCierreHasta = fechaCierreHastaActual;
            grupoProvId = grupoProvIdActual;
            despachosId = despachosIdActual;
            impAbonadoDesde = impAbonadoDesdeActual;
            impAbonadoHasta = impAbonadoHastaActual;
            listIdsTematica = listIdsTematicaActual;
            listIdsProducto = listIdsProductoActual;
            listIdsMotivo = listIdsMotivoActual;
            listIdsDetalle = listIdsDetalleActual;
            numMaxReclamaciones = numMaxReclamacionesActual;
            sentidoResolucionStr = sentidoResolucionStrActual;
        }
    }

    public class FechaCierreRango{

        public DateTime fechaCierreDesde{get; set;}
        public DateTime fechaCierreHasta {get; set;}

        public fechaCierreRango(DateTime fechaCierreDesdeActual, DateTime fechaCierreHastaActual)
        {
            fechaCierreDesde = fechaCierreDesdeActual;
            fechaCierreHasta = fechaCierreHastaActual;
        }
    }
}