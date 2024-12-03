public with sharing class SAC_LCMP_AuditoriasController {

    private static Set<String> objetos = new Set<String>{'Case','CC_Grupo_Colaborador__c','CC_MCC__c','SEG_Auditoria__c','SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    final static Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    final static Id RECORDTYPEGRUPOPROV = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoProveedores').getRecordTypeId();
    final static Id RECORDTYPEGRUPOLET = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_Letrados').getRecordTypeId();
    final static Id RECORDTYPEGRUPORESPONSABLE = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId();
    final static Id RECORDTYPETEMATICA = mapRTsObjects.get('CC_MCC__c').get('CC_Tematica').getRecordTypeId();
    final static Id RECORDTYPEPRODSERV = mapRTsObjects.get('CC_MCC__c').get('CC_Producto_Servicio').getRecordTypeId();
    final static Id RECORDTYPEMOTIVO = mapRTsObjects.get('CC_MCC__c').get('CC_Motivo').getRecordTypeId();
    final static Id RECORDTYPEDETALLE = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();
    final static Id RECORDTYPEAUDITORIA = mapRTsObjects.get('SEG_Auditoria__c').get('SAC_Auditoria').getRecordTypeId();
    final static Id RECORDTYPEAUDITORIAGENERAL = mapRTsObjects.get('SEG_Auditoria__c').get('SAC_AuditoriaGeneral').getRecordTypeId();
    final static Id RECORDTYPEAUDITORIAAUTOMATICA = mapRTsObjects.get('SEG_Auditoria__c').get('SAC_AuditoriaAutomatica').getRecordTypeId();
    final static Id RECTYPEPUNTOSCONTROL = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_PuntoDeControl').getRecordTypeId();
    final static Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();


    /*********************************************************************************************
     * Proposito: Buscador de resultados filtrados para cada uno de los buscadores de los criterios de búsqueda de la auditoría                                       
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl Santos           22/11/23       Creación
     * *******************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<SObject> buscarResultados(String searchTerm, String tipoBusqueda, String id) {

        List<String> idList = new List<String>();
        List<SObject> listaResultado = new List<sObject>();
        String cadenaBusqueda= '%'+searchTerm+'%';

        if(String.isNotBlank(id)){
            for (String s : id.split(',')) {
                idList.add(s.trim());
            }
        }

        if(tipoBusqueda == 'buscadorGrupoProveedor'){
            listaResultado = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECORDTYPEGRUPOPROV AND SAC_PermiteDerivacion__c = false AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 20];
        }

        if(tipoBusqueda == 'buscadorVariosGruposProv' || tipoBusqueda == 'buscadorVariosGruposLet'){
            listaResultado = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE (RecordTypeId = :RECORDTYPEGRUPOPROV OR RecordTypeId = :RECORDTYPEGRUPOLET) AND Id IN :idList AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 20];
        }

        if(tipoBusqueda == 'buscadorGrupoLetrado'){
            listaResultado = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECORDTYPEGRUPOLET AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 20];
        }

        if(tipoBusqueda == 'buscadorGestor' || tipoBusqueda == 'buscadorLetrados'){
            Set<Id> idsUnicos = new Set<Id>();

            List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = [SELECT CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c  WHERE CC_Grupo_Colaborador__c IN :idList AND CC_Usuario__r.Name LIKE :cadenaBusqueda LIMIT 20];

            if(!listaColaboradores.isEmpty()){
                for(CC_Grupo_Colaborador_Contact__c colaborador : listaColaboradores){
                    //Compruebo si el id del user ya está en el set, si no está lo añado al set
                    if(!idsUnicos.contains(colaborador.CC_Usuario__c)){
                        idsUnicos.add(colaborador.CC_Usuario__c);
                    }
                }
            }

            listaResultado = [SELECT Id, Name FROM User Where Id IN :idsUnicos ORDER BY Name ASC LIMIT 20];  
        }

        if(tipoBusqueda == 'buscadorTematica'){
            listaResultado = [SELECT Id, Name FROM CC_MCC__c WHERE RecordTypeId = :RECORDTYPETEMATICA AND  CC_Activo__c = true AND CC_Tipo_Cliente__c = 'SAC' AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 20];
        }

        if(tipoBusqueda == 'buscadorProducto'){
            listaResultado = [SELECT Id, Name FROM CC_MCC__c WHERE RecordTypeId = :RECORDTYPEPRODSERV AND CC_Activo__c = true AND CC_Tipo_Cliente__c = 'SAC' AND CC_Tematica__c IN :idList AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 20]; 
        }

        if(tipoBusqueda == 'buscadorMotivo'){
            listaResultado = [SELECT Id, Name FROM CC_MCC__c WHERE RecordTypeId = :RECORDTYPEMOTIVO AND CC_Activo__c = true AND CC_Tipo_Cliente__c = 'SAC' AND CC_Producto_Servicio__c IN :idList AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 20]; 
        }

        if(tipoBusqueda == 'buscadorDetalle'){
            listaResultado = [SELECT Id, Name FROM CC_MCC__c WHERE RecordTypeId = :RECORDTYPEDETALLE AND CC_Activo__c = true AND CC_Tipo_Cliente__c = 'SAC' AND CC_Motivo__c IN :idList AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 20]; 
        }

        if(tipoBusqueda == 'buscadorGrupoResolver'){
            listaResultado = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE ((RecordTypeId = :RECORDTYPEGRUPOPROV AND SAC_PermiteDerivacion__c = false) OR RecordTypeId = :RECORDTYPEGRUPOLET) AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 20];
        }

        return listaResultado;
    }

    /*********************************************************************************************
     * Proposito: Tras completar los criterios de búsqueda deseados para la auditoría, dependiendo del búscador de solo pret principal de la reclamación o todas las pretensiones,
     *            derivamos el fluje por un método u otro.                                  
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl / Carlos         22/11/23       Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static List<ReclamacionWrapper> buscarReclamacionAuditoria(String tipoAuditoria, Boolean soloPretPpal, Date fechaDesde, Date fechaHasta, String grupoProvId, String despachosId, String gestorId, String letrado, Decimal impAbonadoDesde, Decimal impAbonadoHasta, List<String> sentidoResolucion, String tematicaId, String productoId, String motivoId, String detalleId, Integer numMaxReclamaciones){
        
        List<ReclamacionWrapper> listRecl = new List<ReclamacionWrapper>();

        if(soloPretPpal == true){
            listRecl = buscarReclamacionPretPrincipal(tipoAuditoria, fechaDesde, fechaHasta, grupoProvId, despachosId, gestorId, letrado, impAbonadoDesde, impAbonadoHasta, sentidoResolucion, tematicaId, productoId, motivoId, detalleId, numMaxReclamaciones);
        }else if(soloPretPpal == false){
            listRecl = buscarReclamacionPretensiones(tipoAuditoria, fechaDesde, fechaHasta, grupoProvId, despachosId, gestorId, letrado, impAbonadoDesde, impAbonadoHasta, sentidoResolucion, tematicaId, productoId, motivoId, detalleId, numMaxReclamaciones);
        }
        return listRecl;
    }   

    /*********************************************************************************************
     * Proposito: Búsqueda por todas las pretensiones de la reclamación.
     *            Creación de querys dinámicas. Se crearán las querys dependiendo de los criterios de busqueda que ha introducido el usuario.
     *            Devolverá la lista de reclamaciones que cumplan estos criterios.                                 
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl / Carlos         22/11/23       Creación
     * 1.1             US844784           Raúl Santos           24/04/24       Modificado: Añadida la búsqueda por estados y por sentido de resolucion
     * *******************************************************************************************/
    public static List<ReclamacionWrapper> buscarReclamacionPretensiones(String tipoAuditoria, Date fechaDesde, Date fechaHasta, String grupoProvId, String despachosId, String gestorId, String letrado, Decimal impAbonadoDesde, Decimal impAbonadoHasta, List<String> sentidoResolucion, String tematicaId, String productoId, String motivoId, String detalleId, Integer numMaxReclamaciones){

        List<Case> listPrets = new List<Case>();
        Map<String,ReclamacionWrapper> mapReclamaciones = new Map<String,ReclamacionWrapper>();
        List<String> estadosRec = new List<String>{'Cerrado','SAC_008'};

        Integer numMaxRec = numMaxReclamaciones * 10;
        if(numMaxRec > 2000){
            numMaxRec = 2000;
        }

        String selectQ = 'SELECT Id, SAC_Reclamacion__c, SAC_Reclamacion__r.Subject, SAC_Reclamacion__r.CaseNumber, toLabel(SAC_Reclamacion__r.Status) FROM Case';
        String whereQ = ' WHERE RecordTypeId =: RECORDTYPEPRETENSION AND SAC_Reclamacion__r.Status IN :estadosRec AND SAC_Reclamacion__r.SEG_SRAuditoria__c = false AND SAC_Reclamacion__r.ClosedDate != null';
        String limitQ = ' LIMIT :numMaxRec';
        
        if(String.isnotBlank(tipoAuditoria) && !tipoAuditoria.contains('Todas')){  
            if(tipoAuditoria.contains('Subsanación')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_TipoSubsanacion__c != null';  
            }
            if(tipoAuditoria.contains('Análisis')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_FechaUltimaAsignacionLetrado__c != null';  
            }
            if(tipoAuditoria.contains('Negociación')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_FechaFinNegociacion__c != null';  
            }
            if(tipoAuditoria.contains('Resolución')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.OS_Fecha_Resolucion__c != null'; 
            }
            if(tipoAuditoria.contains('Ejecución')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_FechaEjecucion__c != null'; 
            }
            if(tipoAuditoria.contains('Derivación')){
                whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_FechaDerivacion__c != null'; 
            }
        }
        if(fechaDesde != null){
            whereQ = whereQ + ' AND SAC_Reclamacion__r.ClosedDate >=: fechaDesde';
        }
        if(fechaHasta != null){
            // La fecha hasta llega en formato 'dd/mm/yyyy 00:00:00' luego no incluye el día seleccionado. Para solucionar esto establecemos la fecha a la medianoche
            Datetime fechaInicio = DateTime.newInstance(fechaHasta.year(), fechaHasta.month(), fechaHasta.day());
            // Establecer la fecha a las 23:59:59
            Datetime fechaFin = fechaInicio.addDays(1).addSeconds(-1);

            whereQ = whereQ + ' AND SAC_Reclamacion__r.ClosedDate <=: fechaFin';
        }
        if(string.isnotBlank(grupoProvId)){
            whereQ = whereQ + ' AND SAC_Reclamacion__r.SEG_Grupo__c =: grupoProvId';
        }
        if(string.isNotBlank(despachosId)){
            whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_GrupoLetrado__c =: despachosId';
        } 
        if(string.isNotBlank(gestorId)){
            whereQ = whereQ + ' AND SAC_Reclamacion__r.OwnerId =: gestorId';
        } 
        if(string.isNotBlank(letrado)){
            whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_Letrado__c =: letrado';
        }
        if(impAbonadoDesde != null &&  impAbonadoDesde != 0){
            whereQ = whereQ + ' AND SAC_Reclamacion__r.CC_Importe_Abonado__c >=: impAbonadoDesde';
        }
        if(impAbonadoHasta != null &&  impAbonadoHasta != 0){
            whereQ = whereQ + ' AND SAC_Reclamacion__r.CC_Importe_Abonado__c <=: impAbonadoHasta';
        }
        if(!sentidoResolucion.isEmpty()){
            whereQ = whereQ + ' AND SAC_Reclamacion__r.SAC_SentidoResolucion__c IN :sentidoResolucion';
        }
        if(string.isNotBlank(tematicaId)){
            whereQ = whereQ + ' AND CC_MCC_Tematica__c =: tematicaId';
        }
        if(string.isNotBlank(productoId)){
            whereQ = whereQ + ' AND CC_MCC_ProdServ__c =: productoId';
        }
        if(string.isNotBlank(motivoId)){
            whereQ = whereQ + ' AND CC_MCC_Motivo__c =: motivoId';
        }
        if(string.isNotBlank(detalleId)){
            whereQ = whereQ + ' AND SEG_Detalle__c =: detalleId';
        }

        if(String.isnotBlank(whereQ)){

            listPrets = Database.query(String.escapeSingleQuotes(selectQ + whereQ + limitQ));
            if(!listPrets.isEmpty()){
                for(Case pret : listPrets){
                    ReclamacionWrapper wrapperRec = new ReclamacionWrapper(pret.SAC_Reclamacion__c, pret.SAC_Reclamacion__r.CaseNumber, pret.SAC_Reclamacion__r.Subject, pret.SAC_Reclamacion__r.Status);
                    mapReclamaciones.put(pret.SAC_Reclamacion__c, wrapperRec);

                    if(mapReclamaciones.size() >= numMaxReclamaciones){
                        break;
                    }
                }
            }
        }

        return mapReclamaciones.values();
    }

    /*********************************************************************************************
     * Proposito: Búsqueda por Pret Principal de la reclamación.
     *            Creación de querys dinámicas. Se crearán las querys dependiendo de los criterios de busqueda que ha introducido el usuario.
     *            Devolverá la lista de reclamaciones que cumplan estos criterios.                                 
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl / Carlos         22/11/23       Creación
     * 1.1             US844784           Raúl Santos           24/04/24       Modificado: Añadida la búsqueda por estados y por sentido de resolucion
     * *******************************************************************************************/
    public static List<ReclamacionWrapper> buscarReclamacionPretPrincipal (String tipoAuditoria, Date fechaDesde, Date fechaHasta, String grupoProvId, String despachosId, String gestorId, String letrado, Decimal impAbonadoDesde, Decimal impAbonadoHasta, List<String> sentidoResolucion, String tematicaId, String productoId, String motivoId, String detalleId, Integer numMaxReclamaciones){

        List<Case> reclamacionesAuditoria = new List<Case>();
        List<ReclamacionWrapper> listWrapperRec = new List<ReclamacionWrapper>();
        List<String> estadosRec = new List<String>{'Cerrado','SAC_008'};

        String selectQ = 'SELECT Id, Subject, CaseNumber, toLabel(Status) FROM CASE';
        String whereQ = ' WHERE RecordTypeId =: RECORDTYPERECLAMACION AND Status IN :estadosRec AND SEG_SRAuditoria__c = false AND ClosedDate != null';
        String limitQ = ' LIMIT :numMaxReclamaciones';

        if(String.isnotBlank(tipoAuditoria)  && !tipoAuditoria.contains('Todas')){ 
            if(tipoAuditoria.contains('Subsanación')){
                whereQ = whereQ + ' AND SAC_TipoSubsanacion__c != null';  
            }
            if(tipoAuditoria.contains('Análisis')){
                whereQ = whereQ + ' AND SAC_FechaUltimaAsignacionLetrado__c != null';  
            }
            if(tipoAuditoria.contains('Negociación')){
                whereQ = whereQ + ' AND SAC_FechaFinNegociacion__c != null';  
            }
            if(tipoAuditoria.contains('Resolución')){
                whereQ = whereQ + ' AND OS_Fecha_Resolucion__c != null';
            }
            if(tipoAuditoria.contains('Ejecución')){
                whereQ = whereQ + ' AND SAC_FechaEjecucion__c != null'; 
            }
            if(tipoAuditoria.contains('Derivación')){
                whereQ = whereQ + ' AND SAC_FechaDerivacion__c != null'; 
            }
        }
        if(fechaDesde != null){
            whereQ = whereQ + ' AND ClosedDate >=: fechaDesde';
        }
        if(fechaHasta != null){
            // La fecha hasta llega en formato 'dd/mm/yyyy 00:00:00' luego no incluye el día seleccionado. Para solucionar esto establecemos la fecha a la medianoche
            Datetime fechaInicio = DateTime.newInstance(fechaHasta.year(), fechaHasta.month(), fechaHasta.day());
            // Establecer la fecha a las 23:59:59
            Datetime fechaFin = fechaInicio.addDays(1).addSeconds(-1);

            whereQ = whereQ + ' AND ClosedDate <=: fechaFin';
        }
        if(string.isnotBlank(grupoProvId)){           
            whereQ = whereQ + ' AND SEG_Grupo__c =: grupoProvId';
        }
        if(string.isNotBlank(despachosId)){
            whereQ = whereQ + ' AND SAC_GrupoLetrado__c =: despachosId';
        } 
        if(string.isNotBlank(gestorId)){
            whereQ = whereQ + ' AND OwnerId =: gestorId';
        } 
        if(string.isNotBlank(letrado)){
            whereQ = whereQ + ' AND SAC_Letrado__c =: letrado';
        }
        if(impAbonadoDesde != null &&  impAbonadoDesde != 0){
            whereQ = whereQ + ' AND CC_Importe_Abonado__c >=: impAbonadoDesde';
        }
        if(impAbonadoHasta != null &&  impAbonadoHasta != 0){
            whereQ = whereQ + ' AND CC_Importe_Abonado__c <=: impAbonadoHasta';
        }
        if(!sentidoResolucion.isEmpty()){
            whereQ = whereQ + ' AND SAC_SentidoResolucion__c IN :sentidoResolucion';
        }
        if(string.isNotBlank(tematicaId)){
            whereQ = whereQ + ' AND CC_MCC_Tematica__c =: tematicaId';
        }
        if(string.isNotBlank(productoId)){
            whereQ = whereQ + ' AND CC_MCC_ProdServ__c =: productoId';
        }
        if(string.isNotBlank(motivoId)){
            whereQ = whereQ + ' AND CC_MCC_Motivo__c =: motivoId';
        }
        if(string.isNotBlank(detalleId)){
            whereQ = whereQ + ' AND SEG_Detalle__c =: detalleId';
        }

        if(String.isnotBlank(whereQ)){
            reclamacionesAuditoria = Database.query(String.escapeSingleQuotes(selectQ + whereQ + limitQ));
            
            if(!reclamacionesAuditoria.isEmpty()){
                for(Case rec : reclamacionesAuditoria){
                    ReclamacionWrapper wrapperRec = new ReclamacionWrapper(rec.Id, rec.CaseNumber, rec.Subject, rec.Status);
                    listWrapperRec.add(wrapperRec);
                }
            }
            return listWrapperRec;
        }

        return listWrapperRec;
        
    }

    /*********************************************************************************************
     * Proposito: Creación de las auditorías de las reclamaciones seleccionadas por el usuario.                                 
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl Santos           22/11/23       Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static SEG_Auditoria__c crearAuditoria(String nombreAuditoria, String tipoAuditoria, String slaCalidad,  Date fechaDesde, Date fechaHasta, String grupoProvId, String despachosId, String gestorId, String letradoId, Decimal impAbonadoDesde, Decimal impAbonadoHasta, String sentidoResolucion, String tematicaId, String productoId, String motivoId, String detalleId, String grupoResolverId, List<String> listaCasos){
        
        List<Case> listRecUpdate = new List<Case>();
        List<SEG_Auditoria__c> listAuditorias = new List<SEG_Auditoria__c>();
        SEG_Auditoria__c auditoriaCreada = new SEG_Auditoria__c();
        DetallesAuditoria detallesNuevaAuditoria = new DetallesAuditoria(tipoAuditoria, slaCalidad, fechaDesde, fechaHasta, grupoProvId, despachosId, gestorId, letradoId, impAbonadoDesde, impAbonadoHasta, tematicaId, productoId, motivoId, detalleId, grupoResolverId);

        List<Case> listRec = [SELECT Id FROM Case WHERE RecordTypeId = :RECORDTYPERECLAMACION AND Id IN :listaCasos];

        if(!listRec.isEmpty()){
            List<Case> listaSize = new List<Case>();
            listaSize = listRec;
            Integer numAuditorias = listaSize.size(); 

            //Creamos la auditoria padre
            SEG_Auditoria__c auditoriaPadre = generarAuditoria(RECORDTYPEAUDITORIAGENERAL, detallesNuevaAuditoria);
            auditoriaPadre.SAC_NombreAuditoria__c = nombreAuditoria;
            //US844784 - 24/04/2024 - Raúl Santos - Añadido el campo SAC_SentidoResolucion__c
            auditoriaPadre.SAC_SentidoResolucion__c = sentidoResolucion;
            auditoriaPadre.SAC_TotalReclamacionesAuditadas__c = numAuditorias;
            auditoriaPadre.SAC_TotalPendientes__c = numAuditorias;
            auditoriaPadre.SAC_TotalOk__c = 0;
            auditoriaPadre.SAC_TotalKo__c = 0;
            auditoriaPadre.SAC_TotalNoAplica__c = 0;
            auditoriaPadre.SAC_PorcentajeAcierto__c = '0%';
            SAC_DatabaseDML.insertDML(auditoriaPadre, false);
            auditoriaCreada = auditoriaPadre;

            //Por cada reclamación seleccionada debemos crear una auditoría. De forma que creamos tantas auditorías como reclamaciones hemos seleccionado. Esta nueva auditoría tendrá un campo con el id de la reclamación que corresponda y además el id de la auditoría general
            for(Case recUpdate : listRec){
                //Actualizamos el campo SEG_SRAuditoria__c de la reclamacion
                recUpdate.SEG_SRAuditoria__c = true;
                listRecUpdate.add(recUpdate);

                //Creamos el registro de la auditoria
                String nombre =  nombreAuditoria;
                SEG_Auditoria__c auditoriaHija = generarAuditoria(RECORDTYPEAUDITORIA, detallesNuevaAuditoria); 
                auditoriaHija.SAC_NombreAuditoria__c = nombre;
                auditoriaHija.SAC_AuditoriaGeneral__c = auditoriaPadre.Id;
                auditoriaHija.SAC_Reclamacion__c = recUpdate.Id;
        
                listAuditorias.add(auditoriaHija);
            }
        }

        //Actualizamos las reclamaciones e insertamos las auditorias
        if(!listRecUpdate.isEmpty()){        
            if (Schema.sObjectType.Case.isUpdateable()){
                SAC_DatabaseDML.updateListDML(listRecUpdate, false);
            } 
        }
        if(!listAuditorias.isEmpty()){
            if (Schema.sObjectType.SEG_Auditoria__c.isCreateable()){
                SAC_DatabaseDML.insertListDML(listAuditorias, false);

                crearPuntosDeControlAuditoria(listAuditorias, tipoAuditoria);
            } 
        }

        return auditoriaCreada;
    }

    /*********************************************************************************************
     * Proposito: Método para generar los campos comunes de las auditorías creadas.                               
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl Santos          22/11/23       Creación
     * *******************************************************************************************/
    public static SEG_Auditoria__c generarAuditoria(Id idRecordType, DetallesAuditoria detallesAudit){      

        SEG_Auditoria__c auditoria = new SEG_Auditoria__c();

        if(idRecordType == RECORDTYPEAUDITORIAGENERAL){
            auditoria.RecordTypeId = RECORDTYPEAUDITORIAGENERAL;
        }else if(idRecordType == RECORDTYPEAUDITORIA){
            auditoria.RecordTypeId = RECORDTYPEAUDITORIA;
        }else if(idRecordType == RECORDTYPEAUDITORIAAUTOMATICA){
            auditoria.RecordTypeId = RECORDTYPEAUDITORIAAUTOMATICA;
        }
        if(detallesAudit.tipoAuditoria != null){
            auditoria.SAC_Tipo__c = detallesAudit.tipoAuditoria;
        }
        if(detallesAudit.slaCalidad != null){
            auditoria.SAC_SLACalidad__c = detallesAudit.slaCalidad;
        }
        if(detallesAudit.fechaDesde != null){
            auditoria.SAC_FechaCierreDesde__c = detallesAudit.fechaDesde;
        }
        if(detallesAudit.fechaHasta != null){
            auditoria.SAC_FechaCierreHasta__c = detallesAudit.fechaHasta;
        }
        if(detallesAudit.grupoProvId != null && detallesAudit.grupoProvId != ''){
            auditoria.SAC_GrupoProveedor__c = detallesAudit.grupoProvId;
        }
        if(detallesAudit.despachosId != null && detallesAudit.despachosId != ''){
            auditoria.SAC_GrupoLetrado__c = detallesAudit.despachosId;
        }
        if(detallesAudit.gestorId != null && detallesAudit.gestorId != ''){
            auditoria.SAC_Gestor__c = detallesAudit.gestorId;
        }
        if(detallesAudit.letradoId != null && detallesAudit.letradoId != ''){
            auditoria.SAC_Letrado__c = detallesAudit.letradoId;
        }
        if(detallesAudit.impAbonadoDesde  != null && detallesAudit.impAbonadoDesde != 0){
            auditoria.SAC_ImporteAbonadoDesde__c = detallesAudit.impAbonadoDesde;
        }
        if(detallesAudit.impAbonadoHasta  != null && detallesAudit.impAbonadoHasta != 0){
            auditoria.SAC_ImporteAbonadoHasta__c = detallesAudit.impAbonadoHasta;
        }
        if(detallesAudit.tematicaId != null && detallesAudit.tematicaId != ''){
            auditoria.SAC_MCCTematica__c = detallesAudit.tematicaId;
        }
        if(detallesAudit.productoId != null && detallesAudit.productoId != ''){
            auditoria.SAC_MCCProducto__c = detallesAudit.productoId;
        }
        if(detallesAudit.motivoId != null && detallesAudit.motivoId != ''){
            auditoria.SAC_MCCMotivo__c = detallesAudit.motivoId;
        }
        if(detallesAudit.detalleId != null && detallesAudit.detalleId != ''){
            auditoria.SAC_MCCDetalle__c = detallesAudit.detalleId;
        }
        if(detallesAudit.grupoResolverId != null && detallesAudit.grupoResolverId != ''){
            auditoria.SAC_GrupoResponsableResolver__c = detallesAudit.grupoResolverId;
        }
        
        auditoria.SAC_Estado__c = 'SAC_Pendiente';

        return auditoria;
    }

    /*********************************************************************************************
     * Proposito: Recuperar el id del grupo COPS, debido a que debe ser asignado al campo SAC_GrupoResponsableResolver__c, en caso de que un usuario sea auditor de varios grupos Let/Prov                               
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl Santos          22/11/23       Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static String recuperarIdCops() {

        return [SELECT id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId =: RECORDTYPEGRUPORESPONSABLE AND SAC_DeveloperName__c = 'COPS'].Id; 
    }

    /*********************************************************************************************
     * Proposito: Método que comprueba si el usuario tiene el Permission Set de Auditorias                             
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl Santos          22/11/23       Creación
     * *******************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static boolean comprobarPSAuditoria(String idUser){
        Boolean tienePermisos = false;
        List<PermissionSetAssignment> listPermisosUser = [SELECT PermissionSetId, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: idUser];

        for(PermissionSetAssignment permiso : listPermisosUser) {
            if(permiso.PermissionSet.Name == 'SAC_Auditorias') {
                tienePermisos = true;
                return tienePermisos;
            }
        }
        return tienePermisos;
    }

    /*********************************************************************************************
     * Proposito: Metodo que recupera la información de los grupos a los que pertenece el usuario en ejecución.
     *            Recuperar si pertenece al grupo de Auditores.
     *            Recuperar si pertenece al grupo de AJ o COPS.
     *            Recuperar si pertenece a algún grupo Prov/Letrado como Auditor.                       
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl Santos          22/11/23       Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static InfoGruposUser comprobarGruposUser(String gruposUser, String idUser){

        if(String.isNotBlank(gruposUser) ){
            List<CC_Grupo_Colaborador_Contact__c> listGruposAuditor = new List<CC_Grupo_Colaborador_Contact__c>();
            String idGrupoAuditor = '';
            List<CC_Grupo_Colaborador__c> listCOPSOrAJ = new List<CC_Grupo_Colaborador__c>();
            List<String> idList = gruposUser.split(';');

            //Recuperamos los grupos a los que pertenece el usuario que sean grupos proveedores o grupos letrados, o que el grupo sea Auditores
            List<CC_Grupo_Colaborador__c> listGrupos = [SELECT Id, Name, RecordTypeId, SAC_DeveloperName__c FROM CC_Grupo_Colaborador__c WHERE ((RecordTypeId = :RECORDTYPEGRUPOPROV AND SAC_PermiteDerivacion__c = false)OR RecordTypeId = :RECORDTYPEGRUPOLET OR SAC_DeveloperName__c = 'SAC_AUDITORES' OR SAC_DeveloperName__c = 'COPS' OR SAC_DeveloperName__c = 'AJ') AND Id IN :idList];
        
            if(!listGrupos.isEmpty()){
                for(CC_Grupo_Colaborador__c grupo : listGrupos){
                    if(grupo.SAC_DeveloperName__c == 'SAC_AUDITORES'){
                        idGrupoAuditor = grupo.Id;
                    }
                    if(grupo.SAC_DeveloperName__c == 'COPS' || grupo.SAC_DeveloperName__c == 'AJ'){
                        listCOPSOrAJ.add(grupo);
                    }
                }
                listGruposAuditor = [SELECT Id, CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__r.RecordType.DeveloperName FROM CC_Grupo_Colaborador_Contact__c WHERE (CC_Grupo_Colaborador__r.RecordTypeId = :RECORDTYPEGRUPOPROV OR CC_Grupo_Colaborador__r.RecordTypeId = :RECORDTYPEGRUPOLET) AND CC_Grupo_Colaborador__c IN :listGrupos AND CC_Usuario__c = :idUser AND SAC_Auditor__c = true]; 
            }   

            InfoGruposUser infoGrupos = new InfoGruposUser(listGruposAuditor, idGrupoAuditor, listCOPSOrAJ);
            return infoGrupos;
        }
        return null;
    }

    /**********************************************************************************************                                                                                     
     * Proposito: Creación de clases wrapper para el tratamiento de datos.
     *                                                                                        
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl Santos          22/11/23       Creación
     * *******************************************************************************************/
    public class InfoGruposUser{

        @AuraEnabled public List<CC_Grupo_Colaborador_Contact__c> listGruposAuditor{get; set;}
        @AuraEnabled public String idGrupoAuditor {get; set;}
        @AuraEnabled public List<CC_Grupo_Colaborador__c> listCOPSOrAJ{get; set;}

        public infoGruposUser(List<CC_Grupo_Colaborador_Contact__c> listGruposAuditorActual, String idGrupoAuditorActual, List<CC_Grupo_Colaborador__c> listCOPSOrAJActual)
        {
            listGruposAuditor = listGruposAuditorActual;
            idGrupoAuditor = idGrupoAuditorActual;
            listCOPSOrAJ = listCOPSOrAJActual;
        }
    }

    public class DetallesAuditoria{

        public String tipoAuditoria {get; set;}
        public String slaCalidad{get; set;}
        public Date fechaDesde {get; set;}
        public Date fechaHasta{get; set;}
        public String grupoProvId {get; set;}
        public String despachosId{get; set;}
        public String gestorId {get; set;}
        public String letradoId{get; set;}
        public Decimal impAbonadoDesde {get; set;}
        public Decimal impAbonadoHasta {get; set;}
        public String tematicaId{get; set;}
        public String productoId {get; set;}
        public String motivoId {get; set;}
        public String detalleId{get; set;}
        public String grupoResolverId {get; set;}

        public detallesAuditoria(String tipoAuditoriaActual, String slaCalidadActual, Date fechaDesdeActual, Date fechaHastaActual, String grupoProvIdActual,
        String despachosIdActual, String gestorIdActual, String letradoIdActual, Decimal impAbonadoDesdeActual, Decimal impAbonadoHastaActual, String tematicaIdActual, String productoIdActual,
        String motivoIdActual, String detalleIdActual, String grupoResolverIdActual)
        {
            tipoAuditoria = tipoAuditoriaActual;
            slaCalidad = slaCalidadActual;
            fechaDesde = fechaDesdeActual;
            fechaHasta = fechaHastaActual;
            grupoProvId = grupoProvIdActual;
            despachosId = despachosIdActual;
            gestorId = gestorIdActual;
            letradoId = letradoIdActual;
            impAbonadoDesde = impAbonadoDesdeActual;
            impAbonadoHasta = impAbonadoHastaActual;
            tematicaId = tematicaIdActual;
            productoId = productoIdActual;
            motivoId = motivoIdActual;
            detalleId = detalleIdActual;
            grupoResolverId = grupoResolverIdActual;
        }
    }

    /***************************************************************************************
     * Proposito: Comprobar si el user tiene permisos para crear la auditoria                                                 
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US745661          Sergio Martín          09/11/23         Creación
     * *************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static boolean comprobarPermisosCreacionAuditoria(Case casoOriginal){
        Boolean tienePermisos = false;

        if(casoOriginal != null && !String.isBlank(casoOriginal.Id)) {
            User usuario = [SELECT Id, SAC_GruposPerteneciente__c FROM user WHERE Id =: UserInfo.getUserId()];
            Boolean tienePSAuditoria = comprobarPSAuditoria(usuario.id);

            if(usuario != null && String.isNotBlank(usuario.SAC_GruposPerteneciente__c) && tienePSAuditoria) {
                InfoGruposUser infoGrupos = comprobarGruposUser(usuario.SAC_GruposPerteneciente__c, usuario.id);

                // Si el usuario pertene al grupo auditores tiene permisos para crear la auditoria
                if(String.isNotBlank(infoGrupos.idGrupoAuditor)) {
                    tienePermisos = true;
                    return tienePermisos;
                }
                // Si el usuario pertenece a COPS o AJ tiene permisos para crear la auditoria
                if(!infoGrupos.listCOPSOrAJ.isEmpty()) {
                    tienePermisos = true;
                    return tienePermisos;
                }
                // Si el usuario es auditor del grupo responsable de la reclamacion tiene permisos para crear la auditoria
                if(!infoGrupos.listGruposAuditor.isEmpty()) {
                    for(CC_Grupo_Colaborador_Contact__c grupoAuditor : infoGrupos.listGruposAuditor) {
                        if(grupoAuditor.CC_Grupo_Colaborador__c == casoOriginal.SEG_Grupo__c) {
                            tienePermisos = true;
                            return tienePermisos;
                        }
                    }
                }
            }     
        }
        return tienePermisos;
    }


    /********************************************************************************************************************************************                                                                                       
     * Proposito: Clase Wrapper para mandar la información de si puede editar o replicar la auditoría de la reclamación 
     *            desde el controlador Apex al controlador JS para el correcto funcionamiento del Lightning Web Component: sac_AuditoriaReclamacion.
     *                                                                                        
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US745661      Sergio Martín     21/11/23        Creación
    **********************************************************************************************************************************************/
    public class InfoEdicionAuditoria{

        @AuraEnabled public Boolean tienePermisosEditar {get; set;}
        @AuraEnabled public Boolean esAuditorGestor {get; set;}
        @AuraEnabled public Boolean esAuditorLetrado {get; set;}

        public InfoEdicionAuditoria(Boolean tienePermisosEditarActual, Boolean esAuditorGestorActual, Boolean esAuditorLetradoActual)
        {
            tienePermisosEditar = tienePermisosEditarActual;
            esAuditorGestor = esAuditorGestorActual;
            esAuditorLetrado = esAuditorLetradoActual;
        }
    }


    /***********************************************************************************************************************
     * Proposito: Comprobar si el user tiene permisos para realizar acciones sobre la auditoría o para replicarla auditoria                                                
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US745677          Sergio Martín          28/11/23         Creación
     * *********************************************************************************************************************/
    @AuraEnabled
    public static InfoEdicionAuditoria comprobarPermisosEdicionAuditoria(Case casoOriginal, SEG_Auditoria__c auditoria){
        Boolean tienePermisosEditar = false;
        Boolean esAuditorGestor = false;
        Boolean esAuditorLetrado = false;

        if(casoOriginal != null && !String.isBlank(casoOriginal.Id)) {
            User usuario = [SELECT Id, SAC_GruposPerteneciente__c FROM user WHERE Id =: UserInfo.getUserId()];
            if(usuario != null && String.isNotBlank(usuario.SAC_GruposPerteneciente__c)) {
                InfoGruposUser infoGrupos = comprobarGruposUser(usuario.SAC_GruposPerteneciente__c, usuario.id);

                // Si el usuario pertene al grupo auditores tiene permisos para editar la auditoria
                if(String.isNotBlank(infoGrupos.idGrupoAuditor)) {
                    tienePermisosEditar = true;
                }
                // Si el usuario pertenece a COPS o AJ tiene permisos para editar la auditoria
                if(!infoGrupos.listCOPSOrAJ.isEmpty()) {
                    tienePermisosEditar = true;
                }

                // Si el usuario es auditor del grupo responsable de auditoria tiene permisos para editar la auditoria
                // Si el usuario es auditor del grupo gestor de la reclamacion se devuelve esAuditorGestor = true
                // Si el usuario es auditor del grupo letrado de la pretension principal se devuelve esAuditorLetrado = true
                if(!infoGrupos.listGruposAuditor.isEmpty()) {
                    for(CC_Grupo_Colaborador_Contact__c grupoAuditor : infoGrupos.listGruposAuditor) {
                        if(grupoAuditor.CC_Grupo_Colaborador__c == auditoria.SAC_GrupoResponsableResolver__c) {
                            tienePermisosEditar = true;
                        }
                        if(grupoAuditor.CC_Grupo_Colaborador__c == casoOriginal.SEG_Grupo__c) {
                            esAuditorGestor = true;
                        }
                        if(grupoAuditor.CC_Grupo_Colaborador__c == casoOriginal.SAC_PretensionPrincipal__r.SEG_Grupo__c) {
                            esAuditorLetrado = true;
                        }
                    }
                }
            }
        }

        InfoEdicionAuditoria wrapperInfo = new InfoEdicionAuditoria(tienePermisosEditar, esAuditorGestor, esAuditorLetrado);
        return wrapperInfo;
    }


    /***************************************************************************************
     * Proposito: Crear un registro del objeto SEG_Auditoria__c relacionado con la reclamacion                                                 
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US745661          Sergio Martín          09/11/23         Creación
     * *************************************************************************************/
    @AuraEnabled
    public static void crearAuditoriaReclamacion(Case casoOriginal, String tipoAuditoria, String nombreAuditoria, String auditoriaSLACalidad){     

        // Recuperar el grupo resposable de la auditoria
        String grupoResponsable = getGrupoResponsableAuditoria();

        //Crear la auditoria padre
        SEG_Auditoria__c auditoriaPadre =  new SEG_Auditoria__c (RecordTypeId = RECORDTYPEAUDITORIAGENERAL, SAC_NombreAuditoria__c = nombreAuditoria, SAC_Tipo__c = tipoAuditoria, SAC_Estado__c = 'SAC_Pendiente', 
                        SAC_TotalReclamacionesAuditadas__c = 1, SAC_SLACalidad__c = auditoriaSLACalidad, SAC_GrupoResponsableResolver__c = grupoResponsable, SAC_TotalPendientes__c = 1, SAC_TotalOk__c = 0, SAC_TotalKo__c = 0, SAC_TotalNoAplica__c = 0, SAC_PorcentajeAcierto__c = '0%');
        if (Schema.sObjectType.SEG_Auditoria__c.isCreateable()){
            SAC_DatabaseDML.insertDML(auditoriaPadre, false);
        } 

        SEG_Auditoria__c nuevaAuditoria = new SEG_Auditoria__c (RecordTypeId = RECORDTYPEAUDITORIA, SAC_NombreAuditoria__c = nombreAuditoria, SAC_Reclamacion__c = casoOriginal.id, SAC_Tipo__c = tipoAuditoria, 
                            SAC_Estado__c = 'SAC_Pendiente', SAC_AuditoriaGeneral__c = auditoriaPadre.Id, SAC_SLACalidad__c = auditoriaSLACalidad, SAC_GrupoResponsableResolver__c = grupoResponsable);
        if(casoOriginal.SEG_SRAuditoria__c == false) {
            casoOriginal.SEG_SRAuditoria__c = true;
            if (Schema.sObjectType.Case.isUpdateable()){
                SAC_DatabaseDML.updateDML(casoOriginal, false);
            }
        }
        
        if (Schema.sObjectType.SEG_Auditoria__c.isCreateable()){
            SAC_DatabaseDML.insertDML(nuevaAuditoria, false);
        } 

        // Hacer llamada a crear puntos de control
        List<SEG_Auditoria__c> lstAuditorias = new List<SEG_Auditoria__c>();
        lstAuditorias.add(nuevaAuditoria);
        crearPuntosDeControlAuditoria(lstAuditorias, tipoAuditoria);
    }


    /***************************************************************************************
     * Proposito: Recuperar el grupo resposable de la auditoria con los siguientes criterios:
     *          - Si pertenece a AJ ese es el grupo responsable
     *          - Si no pertenece a AJ pero si a COPS ese es el grupo responsable
     *          - Si no pertenece a AJ ni a COPS y es auditor de un grupo ese es el grupo responsable
     *          - Si no cumple ninguna condición será COPS el responsable                                                
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US745661          Sergio Martín          23/11/23         Creación
     * *************************************************************************************/
    @AuraEnabled
    public static String getGrupoResponsableAuditoria() {
        String idAJ;
        String idCOPS;     
        String idAuditor;     
        
        List<CC_Grupo_Colaborador_Contact__c> lstGrupos = [SELECT Id, CC_Usuario__c, SAC_Auditor__c, CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.SAC_DeveloperName__c
                                                FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: UserInfo.getUserId()];
        for(CC_Grupo_Colaborador_Contact__c grupo : lstGrupos) {
            if(grupo.CC_Grupo_Colaborador__r.SAC_DeveloperName__c == 'AJ') {
                idAJ = grupo.CC_Grupo_Colaborador__c;
            } else if(grupo.CC_Grupo_Colaborador__r.SAC_DeveloperName__c == 'COPS') {
                idCOPS= grupo.CC_Grupo_Colaborador__c;
            } else if(grupo.SAC_Auditor__c == true) {
                idAuditor = grupo.CC_Grupo_Colaborador__c;
            }
        }

        if(idAJ !=null && !String.isBlank(idAJ)) {
            return idAJ;
        } else if(idCOPS !=null && !String.isBlank(idCOPS)) {
            return idCOPS;
        } else if(idAuditor !=null && !String.isBlank(idAuditor)) {
            return idAuditor;
        }
        return recuperarIdCops();
    }


    /***************************************************************************************
     * Proposito: Crear los registros del objeto junction SAC_PuntosControlAuditoria__c 
     *            a partir de los registros del maestro SAC_MaestroTemas__c                                         
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US745661          Sergio Martín          21/11/23        Creación
     * *************************************************************************************/
    @AuraEnabled
    public static void crearPuntosDeControlAuditoria(List<SEG_Auditoria__c> lstAuditorias, String tipoAuditoria){   
        List<SAC_PuntosControlAuditoria__c> lstPuntos = new List<SAC_PuntosControlAuditoria__c>(); 
        List<String> lstTipos = tipoAuditoria.split(';');
        Boolean tipoTodas = false;
        
        if(tipoAuditoria.contains('SAC_Todas')) {
            tipoTodas = true;
        }

        List<SAC_MaestroTemas__c> listMaestro = new List<SAC_MaestroTemas__c>();
        if(tipoTodas) {
            listMaestro =  [SELECT Name, SAC_Critico__c FROM SAC_MaestroTemas__c WHERE RecordTypeId =:RECTYPEPUNTOSCONTROL AND SAC_Activo__c = true];
        } else {
            listMaestro =  [SELECT Name, SAC_Critico__c FROM SAC_MaestroTemas__c 
                    WHERE RecordTypeId =:RECTYPEPUNTOSCONTROL AND SAC_TipoAuditoria__c IN :lstTipos AND SAC_Activo__c = true];
        }
        
        for(SEG_Auditoria__c auditoria : lstAuditorias) {
            for(SAC_MaestroTemas__c maestro : listMaestro) {
                SAC_PuntosControlAuditoria__c punto = new SAC_PuntosControlAuditoria__c(SAC_Auditoria__c = auditoria.id, SAC_PuntoDeControl__c = maestro.id);
                lstPuntos.add(punto);
            }
        }

        if(lstPuntos != null && !lstPuntos.isEmpty()) {
            SAC_DatabaseDML.insertListDML(lstPuntos, false);
        }
    }


    /********************************************************************************************************************************************                                                                                       
     * Proposito: Clase Wrapper para mandar contenido la información de la auditoría y sus puntos de control 
     *            desde el controlador Apex al controlador JS para el correcto funcionamiento del Lightning Web Component: sac_AuditoriaReclamacion.
     *                                                                                        
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US745661      Sergio Martín     21/11/23        Creación
    **********************************************************************************************************************************************/
    public class InfoAuditoriaReclamacion{
        @AuraEnabled public SEG_Auditoria__c auditoria {get; set;}
        @AuraEnabled public List<SEG_Auditoria__c> lstAuditoria {get; set;}
        @AuraEnabled public List<SAC_PuntosControlAuditoria__c> lstPuntos {get; set;}
        @AuraEnabled public Map<String,String> mapTiposDisponibles {get; set;}
        @AuraEnabled public Boolean permitirReabrir {get; set;}
        @AuraEnabled public Map<id,List<SAC_PuntosControlAuditoria__c>> mapAuditoriaPuntos {get; set;}
        @AuraEnabled public Boolean tienePermisosEditar {get; set;}
        @AuraEnabled public Boolean esAuditorGestor {get; set;}
        @AuraEnabled public Boolean esAuditorLetrado {get; set;}

        public infoAuditoriaReclamacion(SEG_Auditoria__c auditoriaActual, List<SEG_Auditoria__c> lstAuditoriaActual, List<SAC_PuntosControlAuditoria__c> lstPuntosActual, 
                                        Map<String,String> mapTiposDisponiblesActual, Boolean permitirReabrirActual, Map<id,List<SAC_PuntosControlAuditoria__c>> mapAuditoriaPuntosActual,
                                        Boolean tienePermisosEditarActual, Boolean esAuditorGestorActual, Boolean esAuditorLetradoActual)
        {
            auditoria = auditoriaActual;
            lstAuditoria = lstAuditoriaActual;
            lstPuntos = lstPuntosActual;
            mapTiposDisponibles = mapTiposDisponiblesActual;
            permitirReabrir = permitirReabrirActual;
            mapAuditoriaPuntos = mapAuditoriaPuntosActual;
            tienePermisosEditar = tienePermisosEditarActual;
            esAuditorGestor = esAuditorGestorActual;
            esAuditorLetrado = esAuditorLetradoActual;
        }
    }


    /*********************************************************************************************
     * Proposito: Obtener la información de la auditoría de la reclamación y sus puntos de control                                        
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US745661          Sergio Martín          21/11/23        Creación
     * *******************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static InfoAuditoriaReclamacion getAuditoriaReclamacion(Case casoOriginal) {
        String idCaso = casoOriginal.Id;
        Set<String> setTipos = new Set<String>(); 
        Map<String,String> mapValoresPicklist = new Map<String,String>(); 
        Boolean puedeReabrir = true;
        Map<id,List<SAC_PuntosControlAuditoria__c>> mapAuditoriaPuntos = new Map<id,List<SAC_PuntosControlAuditoria__c>>();

        if (idCaso != null){
            Case caso = [SELECT id, OwnerId, SEG_Grupo__c, SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_TipoSubsanacion__c, SAC_FechaUltimaAsignacionLetrado__c, SAC_FechaFinNegociacion__c, OS_Fecha_Resolucion__c, 
                                SAC_FechaEjecucion__c, SAC_FechaDerivacion__c FROM Case WHERE RecordTypeId =: RECORDTYPERECLAMACION AND Id =: idCaso LIMIT 1];
            List<SEG_Auditoria__c> lstAuditorias = [SELECT Id, Name, SAC_NombreAuditoria__c, CreatedDate, SAC_Tipo__c, SAC_DictamenManual__c, SAC_Observaciones__c, SAC_Estado__c, SAC_GrupoResponsableResolver__c, SAC_AuditoriaGeneral__r.SAC_NombreAuditoria__c FROM SEG_Auditoria__c WHERE RecordTypeId =:RECORDTYPEAUDITORIA AND SAC_Reclamacion__c = :idCaso  ORDER BY CreatedDate ASC]; 
            List<SEG_Auditoria__c> listaSize = new List<SEG_Auditoria__c>();
            listaSize = lstAuditorias;

            if (lstAuditorias != null && !lstAuditorias.isEmpty()) {
                List<SAC_PuntosControlAuditoria__c> lstPuntos = [SELECT Id, Name, SAC_Dictamen__c, SAC_PuntoDeControl__c, SAC_Auditoria__c, SAC_PuntoDeControl__r.name, toLabel(SAC_PuntoDeControl__r.SAC_TipoAuditoria__c), SAC_PuntoDeControl__r.SAC_Critico__c 
                                                                FROM SAC_PuntosControlAuditoria__c WHERE SAC_Auditoria__c IN :lstAuditorias ORDER BY SAC_PuntoDeControl__r.SAC_TipoAuditoria__c]; 
                // Obtener los tipos de auditoria con los que podrá reabrir la auditoría  
                Integer contador = 1;       
                List<SAC_PuntosControlAuditoria__c> lstPuntosAuditoriaActual = new List<SAC_PuntosControlAuditoria__c>();                                                                   
                for(SEG_Auditoria__c auditoria : lstAuditorias) { 
                    List<String> lstTipos = auditoria.SAC_Tipo__c.split(';');
                    setTipos.addAll(lstTipos);

                    List<SAC_PuntosControlAuditoria__c> lstPuntosAuditoria = new List<SAC_PuntosControlAuditoria__c>();
                    for(SAC_PuntosControlAuditoria__c punto : lstPuntos) {
                        if(punto.SAC_Auditoria__c == auditoria.id) {
                            lstPuntosAuditoria.add(punto);
                        }
                    }

                    if(contador == listaSize.size()) {
                        lstPuntosAuditoriaActual = lstPuntosAuditoria;
                    } else {
                        mapAuditoriaPuntos.put(auditoria.id, lstPuntosAuditoria);
                    }
                    contador++;
                }
                
                // Si alguna auditoria contiene el tipo Todas no se podrá reabrir 
                if(setTipos.contains('SAC_Todas')) {
                    puedeReabrir = false;
                }

                // Obtener los valores disponibles en la picklist para comparar con las de las auditorias existentes y mostrar solo los valores no seleccionados
                Schema.DescribeFieldResult fieldResult = SEG_Auditoria__c.SAC_Tipo__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry pickListVal : ple){
                    //US844784 - 24/04/2024 - Raúl Santos - solo muestre aquellos tipos que no han sido seleccionados Y los tipos equivalentes a los estados por los que ha pasado la reclamación
                    if((pickListVal.getLabel() == 'Subsanación' && caso.SAC_TipoSubsanacion__c != null) || (pickListVal.getLabel() == 'Análisis' && caso.SAC_FechaUltimaAsignacionLetrado__c != null) || 
                       (pickListVal.getLabel() == 'Negociación' && caso.SAC_FechaFinNegociacion__c != null) || (pickListVal.getLabel() == 'Resolución' && caso.OS_Fecha_Resolucion__c != null) || 
                       (pickListVal.getLabel() == 'Ejecución' && caso.SAC_FechaEjecucion__c != null) || (pickListVal.getLabel() == 'Derivación' && caso.SAC_FechaDerivacion__c != null) || pickListVal.getLabel() == 'Alta'){
                        mapValoresPicklist.put(pickListVal.getValue(), pickListVal.getLabel());
                    }
                }   
                mapValoresPicklist.remove('SAC_Todas');
                for(String tipo: setTipos) {
                    mapValoresPicklist.remove(tipo);
                }

                // Si no queda ningún tipo disponible no se podrá reabrir  no se podrá reabrir 
                if(mapValoresPicklist == null || mapValoresPicklist.isEmpty()) {
                    puedeReabrir = false;
                }
                
                // Auditoria actual de la reclamacion
                SEG_Auditoria__c auditoriaNueva = lstAuditorias.get(listaSize.size()-1);
                
                InfoEdicionAuditoria infoEdicion = comprobarPermisosEdicionAuditoria(caso, auditoriaNueva);

                // Quitar la auditoria actual de la lista
                lstAuditorias.remove(listaSize.size()-1);
                
                InfoAuditoriaReclamacion infoAuditoria = new InfoAuditoriaReclamacion(auditorianueva, lstAuditorias, lstPuntosAuditoriaActual, mapValoresPicklist, puedeReabrir, mapAuditoriaPuntos, infoEdicion.tienePermisosEditar, infoEdicion.esAuditorGestor, infoEdicion.esAuditorLetrado);
                return infoAuditoria;
            }
        }  
        return null;
    }


    /*********************************************************************************************
     * Proposito: Finalizar la auditoría de la reclamación comprobando si todos los campos 
     *            están informados correctamente                                         
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US745661          Sergio Martín          15/11/23        Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static void finalizarAuditoriaReclamacion(Case casoOriginal, String idAuditoria){ 
        if (idAuditoria != null){
            SEG_Auditoria__c auditoria = [SELECT Id, SAC_Estado__c, SAC_DictamenManual__c, SAC_Observaciones__c FROM SEG_Auditoria__c WHERE RecordTypeId =:RECORDTYPEAUDITORIA AND Id =: idAuditoria LIMIT 1];
            if (auditoria != null && !String.isBlank(auditoria.id)){
                if(auditoria.SAC_Observaciones__c == null || String.isBlank(auditoria.SAC_Observaciones__c)) {
                    throw new AuraHandledException('El campo observaciones de la auditoría no ha sido completado.');
                }
                if(auditoria.SAC_DictamenManual__c == 'SAC_Pendiente' || String.isBlank(auditoria.SAC_DictamenManual__c)) {
                    throw new AuraHandledException('El dictamen manual de la auditoría no ha sido informado.');
                }
                List<SAC_PuntosControlAuditoria__c> lstPuntos = [SELECT Id, SAC_Dictamen__c FROM SAC_PuntosControlAuditoria__c WHERE SAC_Auditoria__c =: idAuditoria]; 
                for(SAC_PuntosControlAuditoria__c punto : lstPuntos) {
                    if(punto.SAC_Dictamen__c == 'SAC_Pendiente' || String.isBlank(punto.SAC_Dictamen__c)) {
                        throw new AuraHandledException('No todos los puntos de control tienen el dictamen informado.');
                    }
                }

                auditoria.SAC_Estado__c = 'SAC_Completada';
                
                if (Schema.sObjectType.SEG_Auditoria__c.isUpdateable()){
                    SAC_DatabaseDML.updateDML(auditoria, false);
                } 
            }
        }
    }


    /*********************************************************************************************
     * Proposito: Finalizar la réplica de auditoría de la reclamación comprobando si todos los campos 
     *            están informados correctamente                                         
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US745677          Sergio Martín          28/11/23        Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static void replicarAuditoriaReclamacion(Case casoOriginal, String idAuditoria){ 
        if (idAuditoria != null){
            SEG_Auditoria__c auditoria = [SELECT Id, SAC_Estado__c, SAC_DictamenManual__c, SAC_Replica__c FROM SEG_Auditoria__c WHERE RecordTypeId =:RECORDTYPEAUDITORIA AND Id =: idAuditoria LIMIT 1];
            if (auditoria != null && !String.isBlank(auditoria.id)){
                if(auditoria.SAC_Replica__c == null || String.isBlank(auditoria.SAC_Replica__c)) {
                    throw new AuraHandledException('El campo réplica de la auditoría no ha sido completado.');
                }

                auditoria.SAC_Estado__c = 'SAC_Revisada';
                
                if (Schema.sObjectType.SEG_Auditoria__c.isUpdateable()){
                    SAC_DatabaseDML.updateDML(auditoria, false);
                } 
            }
        }
    }


    /*********************************************************************************************
     * Proposito: actualizamos la auditoría padre cuando se actualiza la información de las hijas:
     *              - Actualizamos el % de éxito, número de hijas OK entre el número total de hijas
     *              - Actualizamos los valores de hiajsOK, hijasKO, hijasPte de la auditoria padre
     *              - Cuando todas las hijas están completadas o revisadas, pasamos el estado de la auditoría padre a completada                       
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491           Raúl Santos          22/11/23       Creación
     * *******************************************************************************************/
    public static void actualizarAuditoriaPadre(List<SEG_Auditoria__c> listaAuditorias){

        Map<Id, List<SEG_Auditoria__c>> mapAuditoriaPorPadre = new Map<Id, List<SEG_Auditoria__c>>();
        // Map<Id, List<SEG_Auditoria__c>> mapAuditoriasEmail = new Map<Id, List<SEG_Auditoria__c>>();

        Set<Id> idsUnicos = new Set<Id>();
        List<SEG_Auditoria__c> listaAuditoriasActualizar = new List<SEG_Auditoria__c>();

        //Recupero el id de la auditoría padre
        for(SEG_Auditoria__c auditoria : listaAuditorias){
            //Compruebo si el id del padre ya está en el set, si no está lo añado
            if(!idsUnicos.contains(auditoria.SAC_AuditoriaGeneral__c)){
                idsUnicos.add(auditoria.SAC_AuditoriaGeneral__c);
            }
        }

        //Recupero todas las auditorías hermanas, que dependen del mismo padre que la que se ha actualizado
        List<SEG_Auditoria__c> listAuditoriasHermanas = [SELECT Id, SAC_Estado__c, SAC_AuditoriaGeneral__c, SAC_DictamenManual__c, SAC_Observaciones__c, SAC_Tipo__c, SAC_Reclamacion__r.SEG_Grupo__c, SAC_Reclamacion__r.SAC_GrupoLetrado__c, SAC_Reclamacion__r.CaseNumber FROM SEG_Auditoria__c WHERE RecordTypeId =:RECORDTYPEAUDITORIA AND SAC_AuditoriaGeneral__c IN :idsUnicos];

        //Organizo con un mapa las auditorias que he recogido. Mapa<idAuditoriaPadre, List<auditoriasHijas>
        for(SEG_Auditoria__c auditoria : listAuditoriasHermanas) {
            if (!mapAuditoriaPorPadre.containsKey(auditoria.SAC_AuditoriaGeneral__c)) {
                mapAuditoriaPorPadre.put(auditoria.SAC_AuditoriaGeneral__c, new List<SEG_Auditoria__c>());
            }
            mapAuditoriaPorPadre.get(auditoria.SAC_AuditoriaGeneral__c).add(auditoria);
        }

        //Itero sobre las auditorias padre
        for(Id idPadre : mapAuditoriaPorPadre.keySet()) {
            List<SEG_Auditoria__c> listAuditoriasPorPadre = mapAuditoriaPorPadre.get(idPadre);
            List<SEG_Auditoria__c> listaSize = new List<SEG_Auditoria__c>();
            listaSize = listAuditoriasPorPadre;
            Integer hijasOK = 0;
            Integer hijasKO = 0;
            Integer hijasPte = 0;
            Integer hijasNoAplica = 0;

            //Verifico si todas las auditorias tienen el campo SAC_Estado__c igual a "Completada" o "Revisada"
            //Recupero el dictamen de cada auditoría hija, para informar al padre del dictamen de estas
            Boolean todosCompletados = true;
            for (SEG_Auditoria__c auditoria : listAuditoriasPorPadre) {
                if (auditoria.SAC_Estado__c != 'SAC_Completada' && auditoria.SAC_Estado__c != 'SAC_Revisada') {
                    todosCompletados = false;
                }
                if(auditoria.SAC_DictamenManual__c == 'SAC_OK'){
                    hijasOk++;
                }else if(auditoria.SAC_DictamenManual__c == 'SAC_KO'){
                    hijasKO++;
                }else if(auditoria.SAC_DictamenManual__c == 'SAC_Pendiente'){
                    hijasPte++;
                }else if(auditoria.SAC_DictamenManual__c == 'SAC_NoAplica'){
                    hijasNoAplica++;
                }
            }

            //Calculo el porcentaje de éxito de la auditoria general. % de auditorias hijas OK respecto al total
            Decimal porcentajeOk = (Decimal.valueOf(hijasOk) / Decimal.valueOf(listaSize.size())) * 100;
            porcentajeOk = porcentajeOk.setScale(1, System.RoundingMode.HALF_UP);
            String porcentajeString = porcentajeOk.toPlainString();
            if(porcentajeString.endsWith('.0')) {
                porcentajeString = porcentajeString.substring(0, porcentajeString.length() - 2);
            }
            porcentajeString = porcentajeString + '%';

            //Actualizo la auditoria padre con el porcentaje de acierto correspondiente, y el total de OK/KO/Pte
            SEG_Auditoria__c casoPadre = new SEG_Auditoria__c(Id = idPadre, SAC_PorcentajeAcierto__c = porcentajeString, SAC_TotalOk__c = hijasOk, SAC_TotalKo__c = hijasKO, SAC_TotalPendientes__c = hijasPte, SAC_TotalNoAplica__c = hijasNoAplica);

            //Si todas las hijas de la auditoría padre están en estado "Completado" o "Revisado", la auditoría padre pasa a estado "Completado"
            //Además creamos un mapa, para posteriormente realizar el envío de emails a los auditores de los grupos prov/let
            if(todosCompletados){
                casoPadre.SAC_Estado__c = 'SAC_Completada';
            }

            listaAuditoriasActualizar.add(casoPadre);
        }

        //Actualizamos la auditoría padre
        if(!listaAuditoriasActualizar.isEmpty()){
            SAC_DatabaseDML.updateListDML(listaAuditoriasActualizar, false);
        }   
    }


    /*********************************************************************************************
     * Proposito: Comprobar si todas las reclamaciones auditadas de una determinada auditoría están completadas.
     *            Para: en caso de estarlo devolver true e informar al usuario si quiere enviar un mail de comunicación.                                     
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US790271           Raúl Santos          27/12/2023       Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static boolean comprobarEnvioEmail(String idAuditoria){ 
        Boolean enviarEmail = false;

        if (idAuditoria != null){
            SEG_Auditoria__c auditoria = [SELECT Id, SAC_AuditoriaGeneral__c FROM SEG_Auditoria__c WHERE RecordTypeId =:RECORDTYPEAUDITORIA AND Id =: idAuditoria LIMIT 1];
            if (auditoria != null){
                //Recuperamos las auditorias que tienen el mismo padre que la auditoria actual
                List<SEG_Auditoria__c> listAuditorias = [SELECT Id, SAC_Estado__c FROM SEG_Auditoria__c WHERE RecordTypeId =:RECORDTYPEAUDITORIA AND SAC_AuditoriaGeneral__c =: auditoria.SAC_AuditoriaGeneral__c AND Id !=: idAuditoria];
                List<SEG_Auditoria__c> listaSize = new List<SEG_Auditoria__c>();
                listaSize = listAuditorias;
                Integer auditoriasCompletadas = 0;

                //Recorremos las todas las auditorias hijas, si todas estan en estado 'Completado' o 'Revisado' devolvemos true, para mostrar el modal de envio de email
                for(SEG_Auditoria__c audit : listAuditorias){
                    if(audit.SAC_Estado__c == 'SAC_Completada' || audit.SAC_Estado__c == 'SAC_Revisada'){
                        auditoriasCompletadas++;
                    }
                }

                if(auditoriasCompletadas == listaSize.size()){
                    enviarEmail = true;
                }
            }
        }
        return enviarEmail;
    }


    /*********************************************************************************************
     * Proposito: Preparar el envío de emails a los auditores de los grupos porv/letrado cuando una auditoría padre pasa a estado "Completado"   
     *              - Si auditoría es tipo Alta únicamente: se enviará un correo al auditor/es (check auditor del grupo) del Grupo Proveedor auditado.
     *              - Para el resto de tipos: Se envía un correo al auditor/es (check auditor del grupo) de cada uno de los grupos letrados auditados, tantos emails como auditorias 
     *                hayan sido realizadas sobre sus casos. Ejemplo:
     *                   Auditoría general con 6 casos. (3 casos DXC Letrados, 2 casos Ferrer, 1 caso FYR Legal)
     *                   Se debe enviar: 1 informe le debe llegar con 3 dictámenes a DXC Letrados, 1 informe le debe llegar con 2 dictámenes a Ferrer, 1 informe le debe llegar con 1 dictámen a FYR Legal
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US745670           Raúl Santos          22/11/23       Creación
     * 1.1             US790271           Raúl Santos          27/12/23       Modificación: recuperar las auditorias hermanas de la pasada por parámetro y enviar el email
     * 1.2             US723742           Raúl Santos          05/03/24       Modificación: añadir lógica envio emails blackList
     * *******************************************************************************************/

    @AuraEnabled
    public static Boolean enviarEmailsAuditores (String idAuditoria){

        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        Set<Id> idsGrupos = new Set<Id>();
        Boolean enviarEmail = false;
        OrgWideEmailAddress orgWideId =  [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SAC' LIMIT 1];

        //Recuperamos las plantillas necesarias
        List<EmailTemplate> listPlantillas = [SELECT Id, Name, Subject, HtmlValue, RelatedEntityType, DeveloperName FROM EmailTemplate WHERE (DeveloperName = 'SAC_ResolucionAuditoria' OR DeveloperName = 'SAC_ResolucionAuditoriaInfoReclamaciones')];

        //Tenemos que recuperar los usuarios que son auditores de todos los grupos proveedores y letrados auditados. Para no recuperar todos los de la org (sino solo los auditados) recorremos las auditorias
        //hijas de su respectivo padre, y almacenamos el grupo letrado o proveedor auditado de estas. Para despues simplificar el select de los auditores solo sobre los grupos auditados.
        //Recuperamos el id de la auditoria padre
        SEG_Auditoria__c auditoriaActual = [SELECT Id, SAC_AuditoriaGeneral__c FROM SEG_Auditoria__c WHERE RecordTypeId =:RECORDTYPEAUDITORIA AND Id =: idAuditoria LIMIT 1];

        //Recuperamos todas las auditorias cuyo padre sea el especificado
        List<SEG_Auditoria__c> listAuditoriasPorPadre = [SELECT Id, SAC_Tipo__c, SAC_Reclamacion__r.SEG_Grupo__c, SAC_Reclamacion__r.SAC_GrupoLetrado__c, SAC_Estado__c FROM SEG_Auditoria__c WHERE RecordTypeId =:RECORDTYPEAUDITORIA AND SAC_AuditoriaGeneral__c =: auditoriaActual.SAC_AuditoriaGeneral__c];

        for(SEG_Auditoria__c auditoria : listAuditoriasPorPadre){
            //Recuperar los grupos letrado o prov de la reclamacion, meterlos en una lista
            if(auditoria.SAC_Tipo__c == 'SAC_Altas'){
                if(auditoria.SAC_Reclamacion__r.SEG_Grupo__c != null){
                    idsGrupos.add(auditoria.SAC_Reclamacion__r.SEG_Grupo__c);
                }
            }else{
                if(auditoria.SAC_Reclamacion__r.SAC_GrupoLetrado__c != null){
                    idsGrupos.add(auditoria.SAC_Reclamacion__r.SAC_GrupoLetrado__c);
                }
            }
        }
        
        //Recupero los usuarios auditores de los grupos prov/let auditados
        List <CC_Grupo_Colaborador_Contact__c> listGruposAuditor = [SELECT CC_Grupo_Colaborador__c, CC_Usuario__r.Email FROM CC_Grupo_Colaborador_Contact__c WHERE (CC_Grupo_Colaborador__r.RecordTypeId = :RECORDTYPEGRUPOPROV OR CC_Grupo_Colaborador__r.RecordTypeId = :RECORDTYPEGRUPOLET) AND SAC_Auditor__c = true AND CC_Grupo_Colaborador__c IN :idsGrupos]; 
        if(!listGruposAuditor.isEmpty()){  
            EmailTemplate plantillaInfoRec;
            EmailTemplate plantillaGeneral;

            //Asignamos las plantillas
            for(EmailTemplate plantilla : listPlantillas){
                if(plantilla.DeveloperName == 'SAC_ResolucionAuditoriaInfoReclamaciones'){
                    plantillaInfoRec = plantilla;
                }else if(plantilla.DeveloperName == 'SAC_ResolucionAuditoria'){
                    plantillaGeneral = plantilla;
                }
            }

            Set<Id> idsGruposAuditados= new Set<Id>();
            List<SEG_Auditoria__c> listAuditorias = new List<SEG_Auditoria__c>();

            //Recupero de cada hija su grupo Prov o Letrado auditado. Provedor si la auditoria es de tipo Alta únicamente. Letrado si es de cualquier otro tipo
            for(SEG_Auditoria__c auditoria : listAuditoriasPorPadre){
                if(auditoria.SAC_Tipo__c == 'SAC_Altas'){
                    if(auditoria.SAC_Reclamacion__r.SEG_Grupo__c != null){
                        idsGruposAuditados.add(auditoria.SAC_Reclamacion__r.SEG_Grupo__c);
                    }
                }else{
                    if(auditoria.SAC_Reclamacion__r.SAC_GrupoLetrado__c != null){
                        idsGruposAuditados.add(auditoria.SAC_Reclamacion__r.SAC_GrupoLetrado__c);
                    }
                }
                listAuditorias.add(auditoria);
            }

            if(!idsGruposAuditados.isEmpty()){
                //Necesitamos recuperar los emails de los usuarios auditores que pertenecen a esos grupos.
                //Para ello creamos un mapa que almacena: Map<IdGrupo, List<emails de los auditores de ese grupo>>
                Map<Id,List<String>> mapaEmails = new Map<Id,List<String>>();
                for(CC_Grupo_Colaborador_Contact__c grupo : listGruposAuditor){
                    if(idsGruposAuditados.contains(grupo.CC_Grupo_Colaborador__c)){
                        if (!mapaEmails.containsKey(grupo.CC_Grupo_Colaborador__c)) {
                            mapaEmails.put(grupo.CC_Grupo_Colaborador__c, new List<String>());
                        }
                        mapaEmails.get(grupo.CC_Grupo_Colaborador__c).add(grupo.CC_Usuario__r.Email);
                    }
                }      
                
                //Recupero los emails no validos de envio (emails en la blackList)
                List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

                //Recorremos los grupos auditados a los que tenemos que enviar un email. Para cada grupo, se enviará un email diferente, con diferente contenido.
                for(Id idGrupo : idsGruposAuditados){
                    //Si el grupo en cuestión está en el mapa de emails (tiene algún auditor con email informado) generamos el email. En caso de no tener auditores, no generamos email para ese grupo
                    if(mapaEmails.containsKey(idGrupo) && plantillaInfoRec != null && plantillaGeneral != null){
                        List<String> listaDireccionesPara = new List<String>();
                        String infoReclamaciones = '';

                        for(SEG_Auditoria__c auditoria : listAuditorias){
                            //Si la auditoria hija (tiene una reclamación asocaida) pertenece al grupo porv/letrado auditado que estamos recorriendo, significa que en el mail que se mandará a ese grupo
                            //deberá estar reflejada la información de esta auditoría. Concretamente los campos de la auditoría: SAC_Reclamacion__r.CaseNumber - SAC_DictamenManual__c - SAC_Observaciones__c
                            //Recuperamos esta información a partir de una plantilla de email, y en caso de pertenecer varias auditorias al mismo grupo, concatenamos esta información.
                            if(auditoria.SAC_Reclamacion__r.SEG_Grupo__c == idGrupo || auditoria.SAC_Reclamacion__r.SAC_GrupoLetrado__c == idGrupo){     

                                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(plantillaInfoRec.Id, UserInfo.getUserId(), auditoria.Id);  

                                if(infoReclamaciones == ''){
                                    infoReclamaciones = renderStored.getHtmlBody();
                                }else{
                                    infoReclamaciones = infoReclamaciones + '<br>' + renderStored.getHtmlBody();
                                }
                            }
                        }

                        //Compruebo las direcciones de envio con las de la blackList
                        listaDireccionesPara = mapaEmails.get(idGrupo);
                        List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

                        //Si existen direcciones válidas, continuo el proceso
                        if(!emailsValidos.isEmpty()){
                            //Recuperamos la información de la plantilla general, y en esta sustituimos la cadena '(INFORECAUDITADAS)' por el contenido específico de la plantilla
                            //con la información de las diferentes reclamaciones auditadas de un grupo específico (la información almacenada en 'infoReclamaciones')
                            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(plantillaGeneral.Id, UserInfo.getUserId(), auditoriaActual.SAC_AuditoriaGeneral__c);    
                            String cuerpoCorreo = renderStored.getHtmlBody();
                            
                            if(cuerpoCorreo.contains('(INFORECAUDITADAS)')){
                                cuerpoCorreo = renderStored.getHtmlBody().replace('(INFORECAUDITADAS)', infoReclamaciones);
                            }   

                            //Generamos el correo que vamos a enviar.
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            message.setOrgWideEmailAddressId(orgWideId.Id);
                            message.setToAddresses(emailsValidos);                        
                            message.htmlBody = cuerpoCorreo; 
                            message.setWhatId(auditoriaActual.SAC_AuditoriaGeneral__c);
                            message.optOutPolicy = 'FILTER';
                            //message.saveAsActivity = false;
                            message.subject = plantillaGeneral.Subject; 
                            messageList.add(message);
                        }              
                    }
                }
            }
        }
        
        //Enviamos los emails a los auditores
        if(!messageList.isEmpty()){
            enviarEmail = true;
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList); 
        }

        return enviarEmail;
    }

    /**********************************************************************************************                                                                                     
     * Proposito: Recuperar las auditorías de reclamaciones de una auditoría padre.
     * 
     * Modificación 1.1: Incluir el RT de auditorias general y los campos deseados para recoger las auditorias hijas de las auditorias automáticas.
     *                                                                                        
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US742491             Carlos              22/11/23       Creación
     * 1.1             US791098           Raúl Santos           09/01/24     Modificación
     * *******************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<SEG_Auditoria__c> getAuditoriasHijas(Id recordId) {
    
        List<SEG_Auditoria__c> listaHijas = [SELECT Id, RecordType.DeveloperName, SAC_Reclamacion__r.CaseNumber, SAC_Reclamacion__r.Subject, toLabel(SAC_Reclamacion__r.SAC_Entidad_Afectada__c), 
                                                    SAC_Reclamacion__r.CC_MCC_Tematica__r.Name, SAC_Reclamacion__r.CC_MCC_ProdServ__r.Name, SAC_Reclamacion__r.CC_MCC_Motivo__r.Name, 
                                                    SAC_Reclamacion__r.SEG_Detalle__r.Name, toLabel(SAC_DictamenManual__c), Name, SAC_NombreAuditoria__c, toLabel(SAC_Estado__c), CreatedDate,
                                                    SAC_TotalReclamacionesAuditadas__c, SAC_TotalOk__c, SAC_TotalKo__c, SAC_TotalPendientes__c, SAC_PorcentajeAcierto__c, SAC_TotalNoAplica__c
                                                    FROM SEG_Auditoria__c 
                                                    WHERE (RecordTypeId =: RECORDTYPEAUDITORIA OR RecordTypeId =: RECORDTYPEAUDITORIAGENERAL) AND SAC_AuditoriaGeneral__c =: recordId]; 
        return listaHijas;
    }


    /**************************************************************************
     * Proposito: Recuperar los emails asociados a una determina auditoría
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US790271      Raúl Santos   27/12/2023        Creación
    *****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<EmailMessage> getEmailMessagesByAuditoriaId(String recordId) {
        List<EmailMessage> listaEmailMessages = new List<EmailMessage>();

        if(String.isNotBlank(recordId)) {
            listaEmailMessages = [SELECT Id, ToAddress, CreatedDate, Subject FROM EmailMessage WHERE RelatedToId =: recordId];
        }

        return listaEmailMessages;
    }

    
    /*********************************************************************************************
     * Proposito: Programación de las auditorías automáticas.                                 
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US791098           Raúl Santos           04/01/24       Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static SEG_Auditoria__c crearProgramacionAuditoria(String nombreAuditoria, String tipoAuditoria, String slaCalidad, Date fechaInicio, Date fechaFin, String fechaCierre, String grupoProvId, String despachosId, Decimal impAbonadoDesde, Decimal impAbonadoHasta, String sentidoResolucion, String tematicaId, String productoId, String motivoId, String detalleId, Integer numMaxReclamaciones, String grupoResolverId, Boolean soloPretPpal, String periocidad){

        DetallesAuditoria detallesNuevaAuditoria = new DetallesAuditoria(tipoAuditoria, slaCalidad, null, null, grupoProvId, despachosId, null, null, impAbonadoDesde, impAbonadoHasta, tematicaId, productoId, motivoId, detalleId, grupoResolverId);

        //Creamos la programación de la auditoría
        SEG_Auditoria__c auditoria = generarAuditoria(RECORDTYPEAUDITORIAAUTOMATICA, detallesNuevaAuditoria); 
        auditoria.SAC_NombreAuditoria__c = nombreAuditoria;
        auditoria.SAC_FechaInicio__c = fechaInicio;
        auditoria.SAC_FechaFin__c = fechaFin;
        //US844784 - 24/04/2024 - Raúl Santos - Añadido el campo SAC_SentidoResolucion__c
        auditoria.SAC_SentidoResolucion__c = sentidoResolucion;
        auditoria.SAC_NumMaxReclamaciones__c = numMaxReclamaciones;
        auditoria.SAC_SoloPretPpal__c = soloPretPpal;
        auditoria.SAC_PeriocidadEjecucion__c = periocidad;
        
        if(fechaCierre != ''){
            auditoria.SAC_FechaCierre__c = fechaCierre;
        }
        
        SAC_DatabaseDML.insertDML(auditoria, false);

        return auditoria;
    }

    public class ReclamacionWrapper{

        @AuraEnabled public String id{get; set;}
        @AuraEnabled public String caseNumber{get; set;}
        @AuraEnabled public String subject{get; set;}
        @AuraEnabled public String status{get; set;}
        
        public ReclamacionWrapper(String id, String caseNumber, String subject, String status){
            this.id = id;
            this.caseNumber = caseNumber;
            this.subject = subject;
            this.status = status;
        }
    }
}