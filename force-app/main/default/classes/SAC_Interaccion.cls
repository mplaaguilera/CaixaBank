/***********************************************************************
 * Name: SAC_Interaccion
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase para operaciones con Interaccion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219270         Esteve Llaó    02/07/2021   Creación
*************************************************************************/
public without sharing class SAC_Interaccion {


    private static Set<String> objetos = new Set<String>{'SAC_TMECaso__c', 'SAC_Interaccion__c', 'Task', 'CC_Grupo_Colaborador__c', 'Case','SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPETMEESCALADO = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_TMEEscalado').getRecordTypeId();
    private static final Id RECTYPETMECONSULTA = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_Consulta').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Consulta').getRecordTypeId();
    private static final Id RECTYPEESCALADONV2 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Escalado').getRecordTypeId();
    private static final Id RECTYPEESCALADONV3 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_EscaladoNV3').getRecordTypeId();
    private static final Id RECTYPEREGISTRO = mapRTsObjects.get('Task').get('SAC_Registro').getRecordTypeId();
    private static final Id RECTYPEGRUPOSTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId();
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();




    /**************************************************************************
     * Proposito: Añade al campo SAC_InedexedThreadId el compuesto con los ID
     * acotados de la Organizacion y de la Consulta.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219270         Esteve Llaó    02/07/2021   Creación
    **************************************************************************/    
    public static void crearThreadId(List<SAC_Interaccion__c> interacciones) {
        for (SAC_Interaccion__c interaccion : interacciones) {
            String threadId;
            String consultaID = interaccion.Id; 

            if (String.isBlank(interaccion.SAC_IndexedThreadId__c)) {
                //threadId = ('ref:_'+ UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._' + consultaID + ':ref');
                threadId = SAC_Utils.creacionThreadID(consultaID);
                interaccion.SAC_IndexedThreadId__c = threadId;
            }
        }
    }

    /**************************************************************************
     * Proposito: Rellenar los campos SAC_NIF__c y SAC_NombreReclamante__c en el before insert del trigger
     * para poder utilizar los campos en los email templates
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   15/07/2021   Creación
    **************************************************************************/  
    public static void rellenarNifYNombreReclamante(List<SAC_Interaccion__c> listNewInteraccion) {
        List<Id> listaIdsCasoRelacionado = new List<Id>();
        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (String.IsNotBlank(interaccion.SAC_Reclamacion__c)) {
                listaIdsCasoRelacionado.add(interaccion.SAC_Reclamacion__c);
            } else if (String.isNotBlank(interaccion.SAC_CasoEscalado__c)) {
                listaIdsCasoRelacionado.add(interaccion.SAC_CasoEscalado__c);    
            }
        }

        Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, AccountId, Account.name, Account.CC_Numero_Documento__c, CC_Oficina_Afectada_Lookup__c 
                                                    FROM Case 
                                                    WHERE RecordType.DeveloperName LIKE 'SAC_%' AND Id IN :listaIdsCasoRelacionado]);

        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (mapaCasos.containsKey(interaccion.SAC_CasoEscalado__c)) {
                interaccion.SAC_DNI__c = mapaCasos.get(interaccion.SAC_CasoEscalado__c).Account.CC_Numero_Documento__c;
                interaccion.SAC_Reclamante__c = mapaCasos.get(interaccion.SAC_CasoEscalado__c).Account.Name;
                //interaccion.SAC_Oficina__c = mapaCasos.get(interaccion.SAC_CasoEscalado__c).CC_Oficina_Afectada_Lookup__c;
            } else if (mapaCasos.containsKey(interaccion.SAC_Reclamacion__c)) {
                interaccion.SAC_DNI__c = mapaCasos.get(interaccion.SAC_Reclamacion__c).Account.CC_Numero_Documento__c;
                interaccion.SAC_Reclamante__c = mapaCasos.get(interaccion.SAC_Reclamacion__c).Account.Name;
                //interaccion.SAC_Oficina__c = mapaCasos.get(interaccion.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__c; 
            }
        }
    }  

        /**************************************************************************
     * Proposito: Rellenar el campo SAC_GrupoCreador__c en el before insert del trigger
     * para poder utilizarlo en la list view
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Gomez   10/10/2023   Creación
    **************************************************************************/  
    public static void rellenarGrupoCreador (List<SAC_Interaccion__c> listNewInteraccion) {
        id userid = userinfo.getUserId();
        user userCreador = [SELECT SAC_GruposPerteneciente__c FROM User WHERE Id =:userid limit 1];
        List<String> idList = new List<String>();

        List<Id> listaIdsCasoRelacionado = new List<Id>();
        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (String.IsNotBlank(interaccion.SAC_Reclamacion__c)) {
                listaIdsCasoRelacionado.add(interaccion.SAC_Reclamacion__c);
        }
        }

        Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, SEG_Grupo__c, RecordTypeId, SAC_PretensionPrincipal__r.OwnerId, OwnerId, SAC_GrupoLetrado__c
        FROM Case 
        WHERE RecordTypeId =:RECTYPERECLAMACION AND OwnerId =:userid AND Id IN :listaIdsCasoRelacionado]);

        if(String.isnotBlank(userCreador.SAC_GruposPerteneciente__c)){
            idList = userCreador.SAC_GruposPerteneciente__c.split(';');
        }

        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if(idList.size() == 1 && idList != null){
                interaccion.SAC_GrupoCreador__c = idList[0];
             
            }else if(idList.size() > 1 && idList != null){
                if (mapaCasos.containsKey(interaccion.SAC_Reclamacion__c)) {
                    if(mapaCasos.get(interaccion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId == userid && String.isnotBlank(mapaCasos.get(interaccion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId)){
                   
                        interaccion.SAC_GrupoCreador__c = mapaCasos.get(interaccion.SAC_Reclamacion__c).SAC_GrupoLetrado__c;

                    }else if(mapaCasos.get(interaccion.SAC_Reclamacion__c).OwnerId == userid && String.isnotBlank(mapaCasos.get(interaccion.SAC_Reclamacion__c).OwnerId)){
                   
                        interaccion.SAC_GrupoCreador__c =  mapaCasos.get(interaccion.SAC_Reclamacion__c).SEG_Grupo__c;

                    }else{
                        interaccion.SAC_GrupoCreador__c = idList[0];
                    }
                }
            
            }     
        }  

    }   


    /**************************************************************************
     * Proposito: Crear una Task cuando se crea un escalado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   21/07/2021   Creación
    **************************************************************************/  
    public static void crearTaskNuevoEscalado(List<SAC_Interaccion__c> escaladoNewList) {

        List<Task> listaTasks = new List<Task>();

        for (SAC_Interaccion__c escalado : escaladoNewList) {
            Task tarea = new Task();
            tarea.RecordTypeId = RECTYPEREGISTRO;
            tarea.WhatId = escalado.SAC_CasoEscalado__c;
            tarea.OwnerId = UserInfo.getUserId();
            tarea.Status = 'Open';
            if (escalado.recordTypeId == RECTYPEESCALADONV2) {
                
                tarea.Subject = 'Solicitud de escalado a COPS';
            } else if (escalado.recordTypeId == RECTYPEESCALADONV3) {
                tarea.Subject = 'Solicitud de escalado a AJ';
            }
            listaTasks.add(tarea);
        }
        if (!listaTasks.isEmpty()) {
            //if (!Schema.sObjectType.Task.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
            SAC_DatabaseDML.insertListDML(listaTasks, true);
        }  
    }

    /**************************************************************************
     * Proposito: Crear una Task cuando se responde un escalado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   21/07/2021   Creación
    **************************************************************************/  
    public static void crearTaskEscaladoAtendido(List<SAC_Interaccion__c> escaladoNewList, Map<Id, SAC_Interaccion__c> escaladoOldMap) {

        List<Task> listaTasks = new List<Task>();
        List<Id> listaIds = new List<Id>();
        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
        for (SAC_Interaccion__c escalado : escaladoNewList) {
            if (escaladoOldMap.containsKey(escalado.Id) && escalado.SAC_Estado__c != escaladoOldMap.get(escalado.Id).SAC_Estado__c 
                && (escalado.SAC_Estado__c == 'SAC_Atendida' || escalado.SAC_Estado__c == 'SAC_Reescalada')) {
                listaIds.add(escalado.SAC_CasoEscalado__c);
                listaEscalados.add(escalado);
            }
        }

        if (!listaEscalados.isEmpty()) {
            //if(!Schema.sObjectType.Task.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
            listaTasks = [SELECT WhatId, RecordTypeId, OwnerId, Status, Subject FROM Task WHERE RecordTypeId = :RECTYPEREGISTRO
                            AND WhatId IN :listaIds];

            if (!listaTasks.isEmpty()) {
                for (SAC_Interaccion__c escalado : listaEscalados) {
                    listaTasks[0].Status = 'Completed';
                    if (escalado.recordTypeId == RECTYPEESCALADONV2 && escalado.SAC_Estado__c == 'SAC_Atendida') {
                        listaTasks[0].Subject = 'Escalado de COPS atendido';
                    } 
                    if (escalado.recordTypeId == RECTYPEESCALADONV2 && escalado.SAC_Estado__c == 'SAC_Reescalada') {
                        listaTasks[0].Subject = 'Escalado de COPS re escalado';
                    }
                    if (escalado.recordTypeId == RECTYPEESCALADONV3 && escalado.SAC_Estado__c == 'SAC_Atendida') {
                        listaTasks[0].Subject = 'Escalado de AJ atendido';
                    }
                    if (escalado.recordTypeId == RECTYPEESCALADONV3 && escalado.SAC_Estado__c == 'SAC_Reescalada') {
                        listaTasks[0].Subject = 'Escalado de AJ re escalado';
                    }
                }
                //if (!Schema.sObjectType.Task.isUpdateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
                SAC_DatabaseDML.updateListDML(listaTasks, false);
            }
        } 
    }

    /**************************************************************************
     * Proposito: Validaciones obligatorias para los escalados
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   26/08/2021   Creación
     * 1.1            DE68655          Raúl/Sergio    19/01/2023   Modificación
     * 1.2            US488950         Raúl           09/02/2023   Modificación: deshabilitar obligatorio escalado cuando es un caso sensible
     * 1.3            US523481         Raúl Santos    05/07/2023   Modificación: escalado obligatorio campo SAC_EscaladoObligatorio__c del MCC
    **************************************************************************/  
    @AuraEnabled
    public static ValidacionesEscalado validacionesEscalados(Id caseId) {
        
        Boolean aplicaEscalado = false;
        Boolean valPresidencia = true;
        Boolean valPresidenciaFinal = false;
        Map<Id,String> mapaGrupoDestino = new Map<Id,String>();
        String mensaje='';
        Boolean encontrado = false;
        Boolean mccEscObligatorio = false;
        
        //if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
        Case reclamacion = [SELECT id, CC_Importe_Reclamado__c, SEG_Grupo__c, CC_MCC_Tematica__c,CC_MCC_Motivo__c, 
                            CC_MCC_ProdServ__c, SEG_Detalle__c, SAC_CasoEspecial__c, SAC_Entidad_Afectada__c, SAC_Importe_Resuelto__c, SAC_EntidadProductora__c,
                            SEG_Detalle__r.SAC_EscaladoObligatorio__c
                             FROM Case WHERE RecordType.DeveloperName = 'SAC_Reclamacion' AND Id = :caseId LIMIT 1];

        List<Case> listaPretensiones = [SELECT Id, SEG_Detalle__r.SAC_EscaladoObligatorio__c, CaseNumber FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c = :reclamacion.Id AND Status != 'SAC_009'];

        if(!listaPretensiones.isEmpty()){
            for(Case pret : listaPretensiones){
                if(pret.SEG_Detalle__r.SAC_EscaladoObligatorio__c == true){
                    mccEscObligatorio = true;
                }
            }
        }
                             
        List<String> mccs = new list<String> {reclamacion.CC_MCC_Tematica__c,reclamacion.CC_MCC_Motivo__c, reclamacion.CC_MCC_ProdServ__c, reclamacion.SEG_Detalle__c};


        //if(!Schema.sObjectType.SAC_Interaccion__c.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
        List<SAC_Interaccion__c> listaEscalados = [SELECT Id, SAC_Estado__c, SAC_Conclusion__c, SAC_CasoEscalado__c, RecordTypeId, SAC_EscaladoNV3__c, SAC_EscaladoNV3__r.SAC_Estado__c
                                                    FROM SAC_Interaccion__c 
                                                    WHERE SAC_CasoEscalado__c =: caseId 
                                                    AND (RecordType.DeveloperName = 'SAC_Escalado' OR RecordType.DeveloperName = 'SAC_EscaladoNV3')
                                                    AND SAC_Estado__c != 'SAC_Cancelado' AND SAC_Estado__c != 'SAC_Devuelto'];
                                              
        List<SAC_ParametrizacionEscalado__c> listaParametrizaciones = new List<SAC_ParametrizacionEscalado__c>();
        if (listaEscalados.isEmpty()) {

            if (reclamacion.SAC_CasoEspecial__c == 'SAC_Presidencia') {
                aplicaEscalado = true;
                mensaje='Esta reclamación es especial (Alta Dirección). Debe escalarse.';
            }
            // Deshabilitado el escalado obligatorio cuando es un caso sensible
            // else if(reclamacion.SAC_CasoEspecial__c == 'SAC_Sensible'){                
            //     aplicaEscalado = true;
            //     mensaje='Esta reclamación es especial (Caso sensible). Debe escalarse.';
            // }
            else if(mccEscObligatorio == true){
                aplicaEscalado = true;
                mensaje='Algun/os MCCs tienen el check escalado obligatorio activo, debe escalar antes de resolver la reclamación.';
            }
            else if(reclamacion.SAC_Entidad_Afectada__c =='SAC_007'){//Si la entidad afectada es VidaCaixa
                //if(!Schema.sObjectType.SAC_ParametrizacionEscalado__c.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
                listaParametrizaciones = [SELECT Id, Aplica_escalado__c, SAC_Despacho__c, SAC_ValidarImporte_Hasta__c, SAC_GrupoDestino__c, SAC_GrupoDestino__r.Name, SAC_Importe__c, SAC_MCC__c, SAC_Mensaje__c 
                                        FROM SAC_ParametrizacionEscalado__c
                                        WHERE SAC_Entidad__c = 'SAC_007' //VidaCaixa 
                                        AND ( SAC_Importe__c <= :reclamacion.CC_Importe_Reclamado__c OR SAC_ValidarImporte_Hasta__c >= :reclamacion.CC_Importe_Reclamado__c)
                                        AND SAC_validarImporte__c = true];

                if (!listaParametrizaciones.isEmpty()) {
                    mensaje = listaParametrizaciones[0].SAC_Mensaje__c;
                    aplicaEscalado = listaParametrizaciones[0].Aplica_escalado__c;
                    mapaGrupoDestino.put(listaParametrizaciones[0].SAC_GrupoDestino__c, listaParametrizaciones[0].SAC_GrupoDestino__r.Name);
                }
            }
            else if(reclamacion.SAC_Importe_Resuelto__c != null) {
                /*escalado general por importe*/         
                
                listaParametrizaciones = [SELECT Id, Aplica_escalado__c, SAC_ValidarImporte_Hasta__c, SAC_Despacho__c, SAC_GrupoDestino__c, SAC_GrupoDestino__r.Name, SAC_Importe__c, SAC_MCC__c, SAC_Mensaje__c 
                                        FROM SAC_ParametrizacionEscalado__c
                                        WHERE SAC_todosMCCs__c = true
                                        AND Aplica_escalado__c = true
                                        AND SAC_TodosDespachos__c = true
                                        AND (toLabel(SAC_Entidad__c) =: reclamacion.SAC_EntidadProductora__c OR SAC_Entidad__c = 'SAC_016') /* Otros */
                                        AND (SAC_Importe__c <= :reclamacion.SAC_Importe_Resuelto__c OR SAC_validarImporte__c = false) /* OR SAC_ValidarImporte_Hasta__c >= :reclamacion.CC_Importe_Reclamado__c */
                                        ORDER BY SAC_Entidad__c, SAC_Importe__c, SAC_ValidarImporte_Hasta__c ASC NULLS LAST];

                if (!listaParametrizaciones.isEmpty()) {                
                    for (SAC_ParametrizacionEscalado__c paramAux : listaParametrizaciones) {
                        if(!encontrado){
                            if(paramAux.SAC_ValidarImporte_Hasta__c != null){ // tiene rango desde-hasta 
                                if(paramAux.SAC_Importe__c <= reclamacion.SAC_Importe_Resuelto__c && paramAux.SAC_ValidarImporte_Hasta__c >= reclamacion.SAC_Importe_Resuelto__c){
                                    //Parametrizacion mas baja con rango desde-hasta
                                    mensaje = paramAux.SAC_Mensaje__c;
                                    aplicaEscalado = paramAux.Aplica_escalado__c;
                                    encontrado = true;
                                }
                            }
                            else{
                                //Parametrizacion mas baja con el Importe de la entidad
                                mensaje = paramAux.SAC_Mensaje__c;
                                aplicaEscalado = paramAux.Aplica_escalado__c;
                                encontrado = true;
                            }  
                        }
                    }                       
                }
                
                /*  Comentado, descomentar si la parametrizacion solo aplica a un MCC o Despacho determinadpo

                listaParametrizaciones = [SELECT Id, Aplica_escalado__c, SAC_Despacho__c, SAC_GrupoDestino__c, SAC_GrupoDestino__r.Name, SAC_Importe__c, SAC_MCC__c, SAC_Mensaje__c 
                                        FROM SAC_ParametrizacionEscalado__c
                                        WHERE SAC_Despacho__c = :reclamacion.SEG_Grupo__c
                                        AND Aplica_escalado__c = true
                                        AND SAC_todosMCCs__c = true
                                        AND (SAC_Importe__c <= :reclamacion.SAC_Importe_Resuelto__c OR SAC_validarImporte__c = false)
                                        ORDER BY SAC_Importe__c DESC];

                                         

                if (!listaParametrizaciones.isEmpty()) { 
                    mensaje = listaParametrizaciones[0].SAC_Mensaje__c;
                    if (listaParametrizaciones[0].Aplica_escalado__c) {
                        aplicaEscalado = true;
                        mapaGrupoDestino.put(listaParametrizaciones[0].SAC_GrupoDestino__c, listaParametrizaciones[0].SAC_GrupoDestino__r.Name);
                    }
                }

                listaParametrizaciones = [SELECT Id, Aplica_escalado__c, SAC_Despacho__c, SAC_GrupoDestino__c, SAC_GrupoDestino__r.Name, SAC_Importe__c, SAC_MCC__c, SAC_Mensaje__c 
                                        FROM SAC_ParametrizacionEscalado__c
                                        WHERE SAC_MCC__c in: mccs
                                        AND SAC_TodosDespachos__c = true
                                        AND (SAC_Importe__c <= :reclamacion.SAC_Importe_Resuelto__c OR SAC_validarImporte__c = false)
                                        ORDER BY SAC_Importe__c DESC];

                if (!listaParametrizaciones.isEmpty()) { 
                    mensaje = listaParametrizaciones[0].SAC_Mensaje__c;
                    if (!listaParametrizaciones[0].Aplica_escalado__c) {
                        aplicaEscalado = false;
                    } 
                }*/
                
            }
            
        }else{
            Boolean escaladoAtendido = false;

            for(SAC_Interaccion__c escalado : listaEscalados){
                if(reclamacion.SAC_CasoEspecial__c != 'SAC_Presidencia' && mccEscObligatorio == true){
                    if(escalado.SAC_Estado__c == 'SAC_Atendida'){
                        escaladoAtendido = true;
                    }
                }
                if(escalado.SAC_Estado__c == 'SAC_PendienteRespuesta' || escalado.SAC_Estado__c == 'SAC_Borrador'){
                    aplicaEscalado = true;
                    mensaje = 'Tiene escalados pendientes de respuesta.';
                }
                //Comprobación presidencia
                if(reclamacion.SAC_CasoEspecial__c == 'SAC_Presidencia' && escalado.RecordTypeId == RECTYPEESCALADONV2 && escalado.SAC_Estado__c == 'SAC_Atendida' && escalado.SAC_EscaladoNV3__r.SAC_Estado__c == 'SAC_Atendida'){
                    valPresidenciaFinal = true;
                }
            }

            if(escaladoAtendido == false && mccEscObligatorio == true && reclamacion.SAC_CasoEspecial__c != 'SAC_Presidencia'){
                aplicaEscalado = true;
                mensaje='El MCC Detalle de alguna/s pretension/es tiene el check escalado obligatorio activo, debe atender el escalado para continuar.'; 
            }
        }
     
        if(mensaje=='') {
            mensaje = SAC_Validaciones.validarEscaladoEnvioTarea(null, caseId, '');
            if(mensaje != ''){
                aplicaEscalado = true;
            }
        }
             

        ValidacionesEscalado validacion = new ValidacionesEscalado(aplicaEscalado, valPresidencia, mensaje);
        for(Id key : mapaGrupoDestino.keySet()){
            if(String.isBlank(key)){
                mapaGrupoDestino.remove(key);
            }else{
                String grupo = mapaGrupoDestino.get(key);
                if (String.isBlank(grupo)) {
                    mapaGrupoDestino.remove(key);
                }
            }            
        }
        validacion.mapaGrupoDestino = mapaGrupoDestino;
        if (!valPresidencia) {
            validacion.presidencia = valPresidenciaFinal;
        }
         
        return validacion;
    }
    
    /**************************************************************************
     * Proposito: Crear TME al crear una Interaccion de tipo Escalado NV2 o Escalado NV3
     * o una consulta
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271688         Carlos Solis   25/10/2021   Creación
     * 1.1			  US415467		   Alex Perez     20/09/2022	Adaptación para crearlos por consultas
    **************************************************************************/  
    public static void insertarTME(List<SAC_Interaccion__c> listNewEscalado) {

        List<SAC_TMECaso__c> listaTMEs = new List<SAC_TMECaso__c>();
        
        for (SAC_Interaccion__c escalado : listNewEscalado) {
            SAC_TMECaso__c tme = new SAC_TMECaso__c();
            if(RECTYPECONSULTA == escalado.RecordTypeId) {
               tme.name = 'TMO Consulta';
               tme.RecordTypeId = RECTYPETMECONSULTA;
            } else {
               tme.name = 'Escalado ' + escalado.Name;
               tme.RecordTypeId = RECTYPETMEESCALADO;
            }
            tme.SAC_Interaccion__c= escalado.id;
            listaTMEs.add(tme);
        }
        //if (!Schema.sObjectType.SAC_TMECaso__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
        SAC_DatabaseDML.insertListDML(listaTMEs, true);
    }

    /**************************************************************************
     * Proposito: Cerrar los TMEs dándoles una fecha de fin cuando un escalado o una consulta
     * se completa o Reescala
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271688         Carlos Solis   25/10/2021   Creación
     * 1.1			  US415467		   Alex Perez	  26/09/2022   adaptacion para todo tipo de interaccion
    **************************************************************************/  
    public static void cerrarTME(List<SAC_Interaccion__c> listNewEscalado, Map<Id, SAC_Interaccion__c> mapOldEscalado) {
        List<Id> listaIdsEscalados = new List<Id>();
        for (SAC_Interaccion__c escalado : listNewEscalado) {
            if (mapOldEscalado.containsKey(escalado.Id) && mapOldEscalado.get(escalado.Id).SAC_Estado__c != escalado.SAC_Estado__c && escalado.SAC_Estado__c != 'SAC_PendienteRespuesta' && escalado.SAC_Estado__c != 'SAC_PendienteRespuestaDefinitiva') {
                listaIdsEscalados.add(escalado.Id);
            }
        }

        if (!listaIdsEscalados.isEmpty()) {
            //if(!Schema.sObjectType.SAC_TMECaso__c.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
            List<SAC_TMECaso__c> listaTMEsCerrar = [SELECT Id, SAC_Interaccion__c, SAC_FechaFin__c FROM SAC_TMECaso__c WHERE SAC_Interaccion__c IN :listaIdsEscalados];    

            if (!listaTMEsCerrar.isEmpty()) {
                for (SAC_TMECaso__c tme : listaTMEsCerrar) {
                    tme.SAC_FechaFin__c = system.now();
                }
                //if (!Schema.sObjectType.SAC_TMECaso__c.isUpdateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
                SAC_DatabaseDML.updateListDML(listaTMEsCerrar, false);
            }
        }   
    }

    /**************************************************************************
     * Proposito: Rebrir los TMEs cuando una consulta pasa al estado pendiente de 
     *              respuesta definitiva
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US723790     Sergio Martín     05/04/24        Creación
    **************************************************************************/  
    public static void reabrirTME(List<SAC_Interaccion__c> listNewConsulta, Map<Id, SAC_Interaccion__c> mapOldConsulta) {
        List<Id> listaIdsConsulta = new List<Id>();
        for (SAC_Interaccion__c consulta : listNewConsulta) {
            if (mapOldConsulta.containsKey(consulta.Id) && mapOldConsulta.get(consulta.Id).SAC_Estado__c != consulta.SAC_Estado__c && consulta.SAC_Estado__c == 'SAC_PendienteRespuestaDefinitiva') {
                listaIdsConsulta.add(consulta.Id);
            }
        }

        if (!listaIdsConsulta.isEmpty()) {
            List<SAC_TMECaso__c> listaTMEsReabrir = [SELECT Id, SAC_Interaccion__c, SAC_FechaFin__c FROM SAC_TMECaso__c WHERE SAC_Interaccion__c IN :listaIdsConsulta];
            if (!listaTMEsReabrir.isEmpty()) {
                for (SAC_TMECaso__c tme : listaTMEsReabrir) {
                    if(tme.SAC_FechaFin__c != null) {
                        tme.SAC_FechaFin__c = null;
                    }
                }
                SAC_DatabaseDML.updateListDML(listaTMEsReabrir, false);
            }
        }   
    }

    @AuraEnabled
    public static List<SAC_ParametrizacionEscalado__c>  recuperaEscaladosObligatorios(Id caseId) {
        Case reclamacion = [SELECT id, CC_Importe_Reclamado__c, SAC_Importe_Resuelto__c, SEG_Grupo__c, CC_MCC_Tematica__c,CC_MCC_Motivo__c, CC_MCC_ProdServ__c, SEG_Detalle__c, SAC_CasoEspecial__c
                             FROM Case WHERE RecordType.DeveloperName = 'SAC_Reclamacion' AND Id = :caseId LIMIT 1];
        List<SAC_ParametrizacionEscalado__c> listaParametrizaciones = [SELECT Id, Aplica_escalado__c, SAC_Despacho__c, SAC_GrupoDestino__c, SAC_Importe__c, SAC_MCC__c, SAC_Mensaje__c 
                                        FROM SAC_ParametrizacionEscalado__c
                                        WHERE SAC_todosMCCs__c = true
                                        AND SAC_TodosDespachos__c = true
                                        AND (SAC_Importe__c < :reclamacion.CC_Importe_Reclamado__c OR SAC_validarImporte__c = false) ORDER BY SAC_Importe__c];

        return listaParametrizaciones;
    }
    @AuraEnabled
    public static String requiereEscaladoCOPS(Id id) {
        String respuesta = '';

        List<SAC_Interaccion__c> listImporte = [SELECT Id, SAC_CasoEscalado__r.CC_Importe_Reclamado__c FROM  SAC_Interaccion__c WHERE RecordType.DeveloperName LIKE 'SAC_%' AND id =: id LIMIT 1];

        if(!listImporte.isEmpty() && listImporte[0].SAC_CasoEscalado__c != null){

            List<SAC_ParametrizacionEscalado__c> listRespuesta = [SELECT SAC_Mensaje__c 
            FROM SAC_ParametrizacionEscalado__c
           WHERE SAC_todosMCCs__c = true
             AND SAC_GrupoDestino__r.SAC_DeveloperName__c = 'AJ'
             AND SAC_Importe__c < :listImporte[0].SAC_CasoEscalado__r.CC_Importe_Reclamado__c
           LIMIT 1];
           
           if(!listRespuesta.isEmpty()){
            respuesta = listRespuesta[0].SAC_Mensaje__c;
           }

        }
        //if(!Schema.sObjectType.SAC_ParametrizacionEscalado__c.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
        return respuesta;
    }

     /**************************************************************************
     * Proposito: Validación para comprobar el valor máximo del importe al autorizar un escalado
     * Modificación: Comentado método y llamada al método en el trigger SAC_Interaccion_BU_TRHan al 
     *              quitarse el campo SAC_ImporteAutorizado__c
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                          Daniel Benito   21/01/2022      Creación
     * 1.1            US555020      Sergio Martín   16/05/2023     Modificación
    **************************************************************************/  
    
    // public static void validarImporteEscalados(List<SAC_Interaccion__c> escaladosNV2){

    //     List<SAC_ParametrizacionEscalado__c>  validacionAJ = [SELECT id, Name, SAC_Importe__c FROM SAC_ParametrizacionEscalado__c WHERE Name = 'Validacion Escalado AJ' LIMIT 1];

    //     if (!validacionAJ.isEmpty()) {
    //         for(SAC_Interaccion__c escaladoNV2 : escaladosNV2){
    //             if(escaladoNV2.SAC_ImporteAutorizado__c > validacionAJ[0].SAC_Importe__c){
    
    //                 escaladoNV2.addError('No puedes autorizar un escalado con importe superior a ' + validacionAJ[0].SAC_Importe__c + ' €.');
    //             }
    
    //         }    
    //     }
    // }

    /**************************************************************************
     * Proposito: Clase wrapper para las validaciones del Escalado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US308697     Marcela Neira   23/03/2022      Creación
    **************************************************************************/  
    
    public class ValidacionesEscalado{
        @AuraEnabled public Boolean escalado {get; set;}
        @AuraEnabled public Boolean presidencia {get; set;}
        @AuraEnabled public String mensaje {get; set;}
        @AuraEnabled public Map<Id,String> mapaGrupoDestino {get; set;}

        public ValidacionesEscalado(Boolean escaladoC, Boolean presidenciaC, String mensajeC){
            escalado = escaladoC;
            presidencia = presidenciaC;
            mensaje = mensajeC;
        }
 
    }

    
    /**************************************************************************
     * Proposito: calcular los dias de vencimiento teniendo en cuenta el calendario
     * laboarl de SAC dependiendo de periodo consulta configurado en el grupo asignado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                            Alex Perez     21/09/2022   Creación
    **************************************************************************/ 
    public static map<Id, Date> calculoFechaVencimiento(List<SAC_Interaccion__c> listaConsultas){
        //if(!Schema.sObjectType.BusinessHours.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
        BusinessHours bh = [select id from BusinessHours where name = 'SAC_Calendario' LIMIT 1];
        map<Id, Date> fechaV = new map<Id, Date>();
        for(SAC_Interaccion__c consulta : listaConsultas) {
            fechaV.put(consulta.Id, BusinessHours.add(bh.Id, datetime.now(), integer.valueof(consulta.SAC_GrupoColaborador__r.SAC_PeriodoConsulta__c*86400*1000)).date());
        }
        return fechaV;
    }
    

    /**************************************************************************
     * Proposito: Crea un registro de pendingProcess para lanzar una clase schedulable al cabo de 24 horas.
     * La clase schedulable creará una alerta si la consulta sigue en estado pendiente de asignar.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                             CS     21/01/2022   Creación
    **************************************************************************/  
    public static void scheduleAlertaConsulta24h(List<SAC_Interaccion__c> listNewConsulta) {
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();

        for (SAC_Interaccion__c consulta : listNewConsulta) {
            CBK_SCH_PendingProcess__c pendingProcessConsulta = new CBK_SCH_PendingProcess__c();
            pendingProcessConsulta.recordId__c = consulta.Id;
            pendingProcessConsulta.Schedule_Time__c = system.now().addHours(24);
            pendingProcessConsulta.className__c = 'SAC_SchedulableAlertas';
            pendingProcessConsulta.Param1__c = '24';
            listaPendingProcess.add(pendingProcessConsulta);
        }

        if (!listaPendingProcess.isEmpty()) {
            //if (!Schema.sObjectType.CBK_SCH_PendingProcess__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }  Falla la test por los PS
            SAC_DatabaseDML.insertListDML(listaPendingProcess, true);
        }
    }


    /**************************************************************************
     * Proposito: Crea un registro de pendingProcess para lanzar una clase schedulable 
     *      en el caso de que se pase al estado SAC_PendienteRespuestaDefinitiva y no tenga ninguna
     *      alerta pendiente de enviar
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US723790     Sergio Martín   09/04/24        Creación
    **************************************************************************/  
    public static void reprogramarAlertaConsulta(List<SAC_Interaccion__c> listNewConsulta) {
        List<Id> listaIdsConsulta = new List<Id>();
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
        Map<Id, CBK_SCH_PendingProcess__c> mapaAlertasConsultas = new map<Id, CBK_SCH_PendingProcess__c>();

        for (SAC_Interaccion__c consulta : listNewConsulta) {
            listaIdsConsulta.add(consulta.Id);
        }

        // Se recupera el grupo colaborador de cada consulta
        List<SAC_Interaccion__c> listaConsultasConGrupo = [SELECT Id, SAC_GrupoColaborador__r.SAC_DeveloperName__c FROM SAC_Interaccion__c WHERE Id IN: listaIdsConsulta];        

        List<CBK_SCH_PendingProcess__c> listaPendingProcessConsulta = [SELECT id, Param1__c, QueuedDate__c, Queued__c, RecordId__c, Schedule_Time__c, CreatedDate FROM CBK_SCH_PendingProcess__c WHERE RecordId__c IN: listaIdsConsulta ORDER BY CreatedDate ASC];

        for (CBK_SCH_PendingProcess__c alerta : listaPendingProcessConsulta) {
            mapaAlertasConsultas.put(alerta.RecordId__c,alerta);
        }

        for (SAC_Interaccion__c consulta : listaConsultasConGrupo) {
            // Tiene una alerta mandada anteriormente
            if(mapaAlertasConsultas.containsKey(consulta.Id) && mapaAlertasConsultas.get(consulta.Id).Queued__c == True) {
                
                CBK_SCH_PendingProcess__c pendingProcessConsulta = new CBK_SCH_PendingProcess__c();
                pendingProcessConsulta.recordId__c = consulta.Id;
                pendingProcessConsulta.Schedule_Time__c = system.now().addHours(24);
                pendingProcessConsulta.className__c = 'SAC_SchedulableAlertas';
                // Si es una alerta de OFICINA y la fecha de la ejecución de la alerta es mayor que un día se crea la alerta de 72 horas
                if(consulta.SAC_GrupoColaborador__r.SAC_DeveloperName__c == 'OFICINA' && Date.valueOf(mapaAlertasConsultas.get(consulta.Id).Schedule_Time__c).daysBetween(Date.today()) > 1) {
                    pendingProcessConsulta.Param1__c = '72';
                // Si no es una alerta de OFICINA y se ha creado una alerta anteriormente se crea un registro de la alerta de 48 horas
                // Si es una alerta de OFICINA y la fecha de la ejecución de la alerta es menor que un día se crea la alerta de 72 horas
                } else {
                    pendingProcessConsulta.Param1__c = '48';
                }
                listaPendingProcess.add(pendingProcessConsulta);
            }
        }

        if (!listaPendingProcess.isEmpty()) {
            SAC_DatabaseDML.insertListDML(listaPendingProcess, true);
        }
    }



    /**************************************************************************
     * Proposito: Finaliza las consultas en estado pendiende de respuesta de la reclamación cuando se cierra la reclamación
     * Modificación: añadido que recupere las consultas sin grupo y sin pregunta informados
     * 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US508431      Sergio Martín   30/12/2022       Creación
     * 1.1            US734542      Sergio Martín   16/04/2024     Modificación
    **************************************************************************/  
    public static void finalizarConsultasPendienteRespuesta(List<Case> listaCasos) {
        List<Id> idsCases = new List<Id>();
        Boolean hayError = false;
        Map<Id,Case> mapCasos = new Map<Id,Case>(listaCasos);

        for(Case caso : listaCasos) {
            idsCases.add(caso.Id);
        }

        List<SAC_Interaccion__c> listaConsultasAFinalizar = [SELECT id, SAC_Estado__c, SAC_Reclamacion__c, SAC_MotivoDeFinalizado__c, SAC_GrupoColaborador__r.SAC_PermiteConsultas__c, SAC_GrupoColaborador__r.SAC_TieneUsuariosActivos__c, SAC_GrupoColaborador__r.SAC_Externo__c, SAC_Pregunta__c FROM SAC_Interaccion__c  WHERE RecordTypeId = :RECTYPECONSULTA AND SAC_Reclamacion__c IN: idsCases AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva' OR SAC_Estado__c = '')];
        if (!listaConsultasAFinalizar.isEmpty()) {
            for (SAC_Interaccion__c consulta : listaConsultasAFinalizar) {
                if((consulta.SAC_GrupoColaborador__r.SAC_PermiteConsultas__c && consulta.SAC_GrupoColaborador__r.SAC_TieneUsuariosActivos__c) || (consulta.SAC_GrupoColaborador__r.SAC_PermiteConsultas__c && consulta.SAC_GrupoColaborador__r.SAC_Externo__c)  || (consulta.SAC_GrupoColaborador__c == null && String.isBlank(consulta.SAC_Pregunta__c)) || (consulta.SAC_GrupoColaborador__c != null && String.isNotBlank(consulta.SAC_Pregunta__c))){
                    consulta.SAC_Estado__c = 'SAC_Finalizada';
                    consulta.SAC_MotivoDeFinalizado__c = 'SAC_FinalizadaSinContestar';
                }else{
                    if(mapCasos.containsKey(consulta.SAC_Reclamacion__c)){
                        mapCasos.get(consulta.SAC_Reclamacion__c).addError('Las consultas no se pueden finalizar debido a que su grupo no tiene el check de permite consultas o no tiene usuarios activos');
                        hayError = true;
                    }
                }
            }

            if(!hayError){
                SAC_DatabaseDML.updateListDML(listaConsultasAFinalizar, false);
            }
        }
    }


    /**************************************************************************
     * Proposito: Finaliza las consultas en estado pendiende de respuesta de un caso
     * 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US508429      Sergio Martín   04/01/2022       Creación
    **************************************************************************/  
    @AuraEnabled
    public static void finalizarConsultasCaso(String[] idConsultas, String motivo) {
        List<SAC_Interaccion__c> listaConsultasAFinalizar = [SELECT id, SAC_Estado__c, SAC_MotivoDeFinalizado__c FROM SAC_Interaccion__c  WHERE RecordType.DeveloperName = 'SAC_Consulta' AND Id IN: Idconsultas AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva' OR SAC_Estado__c = '')];
        if (!listaConsultasAFinalizar.isEmpty()) {
            for (SAC_Interaccion__c consulta : listaConsultasAFinalizar) {
                consulta.SAC_Estado__c = 'SAC_Finalizada';
                consulta.SAC_MotivoDeFinalizado__c = motivo;
            }
            SAC_DatabaseDML.updateListDML(listaConsultasAFinalizar, false);
        }
    }


    /**************************************************************************
     * Proposito: Obtener todas las consultas en estado pendiente de respuesta de un caso
     * Modificación: añadido que recupere las consultas sin grupo y sin pregunta informados
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US508429      Sergio Martín   04/01/2022       Creación
     * 1.1            US734542      Sergio Martín   15/04/2024     Modificación
    **************************************************************************/  
    @AuraEnabled(cacheable=true)
    public static List<SAC_Interaccion__c> getConsultasCaso(String caseId, Boolean tienePermisosEditar, Boolean tienePermisosGrupo) {
        List<SAC_Interaccion__c> consultasPendientes = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> consultasCaso = new List<SAC_Interaccion__c>();

        try {
            if(tienePermisosEditar) {
                consultasCaso = [SELECT id, Name, SAC_GrupoColaborador__c ,SAC_GrupoColaborador__r.Name, CreatedDate, SAC_FechaRespuesta__c, SAC_Pregunta__c, toLabel(SAC_Estado__c) FROM SAC_Interaccion__c  WHERE RecordType.DeveloperName = 'SAC_Consulta' AND SAC_Reclamacion__c =: caseId];
                for(SAC_Interaccion__c consulta : consultasCaso) {
                    if((consulta.SAC_Estado__c == 'Pendiente Respuesta' || consulta.SAC_Estado__c == 'Pendiente Respuesta Definitiva' || ((consulta.SAC_GrupoColaborador__c == null || String.isBlank(consulta.SAC_Pregunta__c)) && consulta.SAC_Estado__c != 'Finalizada'))) {
                        consultasPendientes.add(consulta);
                    }
                }
            } else if(tienePermisosGrupo) {
                consultasCaso = [SELECT id, Name, SAC_GrupoColaborador__c ,SAC_GrupoColaborador__r.Name, CreatedDate, toLabel(SAC_Estado__c), SAC_FechaRespuesta__c, SAC_Pregunta__c FROM SAC_Interaccion__c  WHERE RecordType.DeveloperName = 'SAC_Consulta' AND CreatedById =: Userinfo.getUserId() AND  SAC_Reclamacion__c =: caseId];
                for(SAC_Interaccion__c consulta : consultasCaso) {
                    if((consulta.SAC_Estado__c == 'Pendiente Respuesta' || consulta.SAC_Estado__c == 'Pendiente Respuesta Definitiva' || ((consulta.SAC_GrupoColaborador__c == null || String.isBlank(consulta.SAC_Pregunta__c)) && consulta.SAC_Estado__c != 'Finalizada'))) {
                        consultasPendientes.add(consulta);
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return consultasPendientes;
    }


    /**************************************************************************
     * Proposito: Recupera los grupos colaboradores de la lista de interacciones pasada como parámetro
     *            La llamada al método se hace en el SAC_Interaccion_BU_TRHan
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE          Description
     * 1.0            US560251       Sergio Martín   08/05/2023       Creación
    **************************************************************************/  
    public static List<CC_Grupo_Colaborador__c> recuperarGruposConsulta(List<SAC_Interaccion__c> listaConsultas) {

        //Guardar ids de los grupos
        Set<Id> setIdsGrupos = new Set<Id>();
        for (SAC_Interaccion__c consulta : listaConsultas) {
            setIdsGrupos.add(consulta.SAC_GrupoColaborador__c);
        }

        //Buscar los grupos
        List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT Id, SAC_DeveloperName__c, SAC_Externo__c, SAC_TienePropietario__c FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPOSTAREAS AND Id IN :setIdsGrupos];

        return listaGrupos;
    }

    /**************************************************************************
     * Proposito: Cambia el valor SAC_Oficina__c de la consulta cuando cambia el grupo de esta (SAC_Interaccion_BU).
     * Si el grupo al que cambia es un grupo de oficina, se recupera el valor de la oficina afectada
     * de la reclamación padre (CC_Oficina_Afectada_Lookup__c). Si es distinto de oficina, se limpia el campo SAC_Oficina__c
     * de la consulta
     * 
     * Modificacion 1.1: En el momento en el que trae la oficina de la reclamación para ponerla en la interacción, también trae
     * el email de la oficina de la reclamación para añadirlo al campo SAC_EmailOficina__c
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos         23/02/2023   Creación
     * 1.1            US548542         Carlos         14/03/2023   Modificacion
    **************************************************************************/  
    public static void cambiarOficinaConsulta(List<SAC_Interaccion__c> listaConsultasGrupoCambiado, List<CC_Grupo_Colaborador__c> listaGrupos) {

        //Guardar ids de los grupos y las reclamaciones
        Set<Id> setIdsReclamaciones = new Set<Id>();
        for (SAC_Interaccion__c consulta : listaConsultasGrupoCambiado) {
            setIdsReclamaciones.add(consulta.SAC_Reclamacion__c);
        }

        //Buscar los casos padre
        List<Case> listaCasos = new List<Case>();
        if (!listaGrupos.isEmpty()) {
            listaCasos = [SELECT Id, CC_Oficina_Afectada_Lookup__c, CC_Oficina_Afectada_Lookup__r.CC_Email__c FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id IN :setIdsReclamaciones];    
        }

        if (!listaGrupos.isEmpty() && !listaCasos.isEmpty()) {
            //Guardar resultado de las búsquedas en mapas
            Map<Id, CC_Grupo_Colaborador__c> mapaGrupos = new Map<Id, CC_Grupo_Colaborador__c>(listaGrupos);
            Map<Id, Case> mapaCasos = new Map<Id, Case>(listaCasos);

            //Poner la oficina de la reclamación en la consulta
            for (SAC_Interaccion__c consulta : listaConsultasGrupoCambiado) {
                //Si el grupo de la consulta es oficina y la reclamación tiene una oficina informada, llevamos la oficina de la reclamación a la consulta
                if (mapaGrupos.containsKey(consulta.SAC_GrupoColaborador__c) && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_DeveloperName__c == 'OFICINA' 
                    && mapaCasos.containsKey(consulta.SAC_Reclamacion__c) && String.isNotBlank(mapaCasos.get(consulta.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__c)) {
                    consulta.SAC_Oficina__c = mapaCasos.get(consulta.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__c;
                    if(String.isNotBlank(mapaCasos.get(consulta.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__r.CC_Email__c)) {
                        consulta.SAC_EmailOficina__c = mapaCasos.get(consulta.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__r.CC_Email__c;
                    }
                //Si el grupo de la consulta es distinto al de la oficina y el campo oficina está informado, limpiamos el campo oficina de la interacción
                } else if(mapaGrupos.containsKey(consulta.SAC_GrupoColaborador__c) && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_DeveloperName__c != 'OFICINA'
                && String.isNotBlank(consulta.SAC_Oficina__c)) {
                    consulta.SAC_Oficina__c = null;
                    if (String.isNotBlank(consulta.SAC_EmailOficina__c)) {
                        consulta.SAC_EmailOficina__c = null;
                    }
                }
            }

        }
    }


    /**************************************************************************
     * Proposito: Asigna la consulta a la cola de SAC_PendienteAsignar si es una consulta interna y NO es de oficina
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE         Description
     * 1.0            US560251       Sergio Martín  05/05/2023       Creación
    **************************************************************************/  
    public static void asignarPropietarioConsultaInterna(List<SAC_Interaccion__c> listaConsultasGrupoCambiado, List<CC_Grupo_Colaborador__c> listaGrupos) {
        if (!listaGrupos.isEmpty()) {
            //Guardar resultado de la búsqueda en un mapa
            Map<Id, CC_Grupo_Colaborador__c> mapaGrupos = new Map<Id, CC_Grupo_Colaborador__c>(listaGrupos);
            Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];

            for (SAC_Interaccion__c consulta : listaConsultasGrupoCambiado) {
                //Si el grupo de la consulta NO es oficina el grupo NO es externo se debe asignar la propiedad de la consulta a la cola
                if (mapaGrupos.containsKey(consulta.SAC_GrupoColaborador__c) && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_DeveloperName__c != 'OFICINA' 
                        && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_Externo__c == false && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_TienePropietario__c == true) {
                    consulta.OwnerId = cola.id;      
                }
            }
        }
    }

    /**************************************************************************
     * Proposito: Recuperar la plantilla deseada y posteriormente realizar el envio de email para las consultas internas.
     * Tras guardar la pregunta en una consulta interna, además de notificar a la oficina vía interna, debe notificar vía email.
     * 
     * Modificación 1.1: Se ha modificado el valor del campo para. Se ha sustituido el valor SAC_Oficina__r.CC_Email__c
     * por el el valor SAC_EmailOficina__c
     * 
     * Modificación 1.2: Se ha añadido la comprobación de EmailCC y EmailCCO, para en caso de estar informados, enviar el mail
     * correspondiente a estas direcciones
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US537175         Raúl Santos    23/02/2023   Creación
     * 1.1            US548542         Carlos Solis   14/03/2023   Modificación
     * 1.2            US668635         Raúl Santos    05/10/2023   Modificación
     * 1.1            US723742         Raúl Santos    05/03/2024   Modificación: añadir lógica envio emails blackList
    **************************************************************************/   
    
    public static void enviarEmailConsultaInterna(List<SAC_Interaccion__c> listConsultasOficina) {

        //Recuperación plantillas
        if(!Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar las plantillas' ); }
        EmailTemplate listaTemplate = [SELECT Id, Name, Subject, HtmlValue, RelatedEntityType FROM EmailTemplate WHERE DeveloperName = 'SAC_ConsultaOficina'];

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

        for(SAC_Interaccion__c consulta : listConsultasOficina) {
            String para = '';
            String emailCC = '';
            String emailCCO = '';
            if (String.isNotBlank(consulta.SAC_EmailOficina__c)) {
                para = consulta.SAC_EmailOficina__c;    
            }
            if (String.isNotBlank(consulta.SAC_EmailCC__c)) {
                emailCC = consulta.SAC_EmailCC__c;    
            }
            if (String.isNotBlank(consulta.SAC_EmailCCO__c)) {
                emailCCO = consulta.SAC_EmailCCO__c;    
            }

            //Compruebo las direcciones de envio con las de la blackList
            String emailsNoValidosEncontrados = SAC_Utils.comprobarEmailsBlackList(listEmailsNoValidos, para, emailCC, emailCCO);

            //Si las direcciones de envio son válidas (no está en la blackList), continuo el proceso
            if (listaTemplate != null && emailsNoValidosEncontrados == '') {
                // Recuperar la plantilla
                String whoId = UserInfo.getUserId();
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(listatemplate.Id, whoId, consulta.Id);                      
                TemplateWrapper plantilla = new TemplateWrapper(listaTemplate.Id, listaTemplate.Name, renderStored.getSubject(), renderStored.getHtmlBody(), '');

                // Metodo para recuperar los adjuntos y enviar el mail
                if (String.isNotBlank(para) && plantilla != null) {
                    recuperarAdjuntos(consulta.Id, para, emailCC, emailCCO, plantilla);
                }
            }else{
                //Si las direcciones de envio no son válidas (están en la blackList), notifico al usuario
                consulta.addError('No está permitido el envío de emails a esta dirección: ' + emailsNoValidosEncontrados + ' de correo electrónico, por favor elimínela para proceder al envío');
            }
        }
    }

    @AuraEnabled
    public static void recuperarAdjuntos(Id idConsulta, String para, String emailCC, String emailCCO, TemplateWrapper plantillaEmail){

        List<ContentVersion> adjuntos = SAC_LCMP_gestionAdjuntosGlobal.recuperaAdjuntos(idConsulta); 

        Set<Id> idContentDocument = new Set<Id>();

        for(ContentVersion cv : adjuntos){
            if(cv.SAC_Oculto__c == false){  // No recuperamos los adjuntos ocultos (SAC_Oculto__c = true), ya que estos no debemos mandarlos.
                idContentDocument.add(cv.ContentDocumentId);
            }
        }

        List<ContentDocument> documentos = new List<ContentDocument>();
        if(!idContentDocument.isEmpty()){
            if(!Schema.sObjectType.ContentDocument.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
            documentos = [SELECT Id FROM ContentDocument WHERE id IN: idContentDocument]; 
        }

        Set<Id> idAdjuntos = new Set<Id>();
        for(ContentDocument doc : documentos){
            idAdjuntos.add(doc.Id);
        }

        SAC_LCMP_GestionEmails.enviarEmail(idConsulta, para, emailCC, emailCCO, plantillaEmail.htmlValueTemplate, plantillaEmail.subjectTemplate, JSON.serialize(idAdjuntos), null);
    }

    /**************************************************************************
     * Proposito: Añadir al campo SAC_EmailOficina__c el valor de CC_Email__c de la oficina de la consulta.
     * Este método se llama en el trigger SAC_Interaccion_BU para que modifique el valor del email cada vez que la oficina
     * de la consulta cambie
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US548542         Carlos         14/03/2023   Creación
    **************************************************************************/
    public static void informarCorreoOficina(List<SAC_Interaccion__c> listNewInteracciones) {
        //Almacenar ids de las oficinas para poder recuperarlas
        Set<Id> setIdsOficinas = new Set<Id>();
        for (SAC_Interaccion__c consulta : listNewInteracciones) {
            if (String.isNotBlank(consulta.SAC_Oficina__c)) {
                setIdsOficinas.add(consulta.SAC_Oficina__c);
            } else {
                //Si el campo oficina viene vacio, limpamos el email
                consulta.SAC_EmailOficina__c = null;
            }
        }

        //Recuperar oficinas
        List<Account> listaOfis = new List<Account>();
        if (!setIdsOficinas.isEmpty()) {
            listaOfis = [SELECT Id, CC_Email__c FROM Account WHERE Id IN :setIdsOficinas];
        }

        //Pasar listaOfis a mapa
        Map<Id, Account> mapaOfis = new Map<Id, Account>();
        for (Account ofi : listaOfis) {
            mapaOfis.put(ofi.Id, ofi);
        }

        //Añadir correos de las oficinas a las consultas
        if (!mapaOfis.isEmpty()) {
            for (SAC_Interaccion__c consulta : listNewInteracciones) {
                if (String.isNotBlank(consulta.SAC_Oficina__c) && mapaOfis.containsKey(consulta.SAC_Oficina__c) && String.isNotBlank(mapaOfis.get(consulta.SAC_Oficina__c).CC_Email__c)) {
                    consulta.SAC_EmailOficina__c = mapaOfis.get(consulta.SAC_Oficina__c).CC_Email__c;
                }
            }   
        }
    }


    /*****************************************************************
     * Proposito: Clase wrapper para recoger los valores de las plantillas
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US537175         Raúl Santos    23/02/23     Creación
    *****************************************************************/
    public class TemplateWrapper{

        @AuraEnabled public String idTemplate{get; set;}
        @AuraEnabled public String nameTemplate{get; set;}
        @AuraEnabled public String subjectTemplate{get; set;}
        @AuraEnabled public String htmlValueTemplate{get; set;}
        @AuraEnabled public String paraTemplate{get; set;}
        
        public TemplateWrapper(String idTemplate, String nameTemplate, String subjectTemplate, String htmlValueTemplate, String paraTemplate){
            this.idTemplate = idTemplate;
            this.nameTemplate = nameTemplate;
            this.subjectTemplate = subjectTemplate;
            this.htmlValueTemplate = htmlValueTemplate;
            this.paraTemplate = paraTemplate;
        }
    }
}