/*****************************************************************
 * Name: SAC_LCMP_InsertarReescalado
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador del LWC sac_ReescalarNV3.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219272         Carlos Solis   12/07/21     Creación Clase
*****************************************************************/
public without sharing class SAC_LCMP_InsertarReescalado {

    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c','CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECTYPEESCALADONV2 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Escalado').getRecordTypeId();
    final static Id RECTYPEESCALADONV3 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_EscaladoNV3').getRecordTypeId();
    final static Id RECTYPEESCALADOSPV = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    final static Id RECTYPEREESCALADOSPV = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Reescalado').getRecordTypeId();
    final static Id RECTYPEGRUPOACCIONES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId();
    final static Id RECTYPEGRUPOTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();


    //Wrapper para la funcion devolver escalado
    public class wrapEscalado{
        List<SAC_Interaccion__c> listaEscaladosActualizar = new List<SAC_Interaccion__c>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
     }

    @AuraEnabled
    public static String insertReescalado(Id interaccionId, String porpuestaCops, String motivo, String observaciones) {
        String idEscalado = '';
        SAC_Interaccion__c escaladoNv2 = new SAC_Interaccion__c();
        escaladoNv2 = [SELECT id, SAC_CasoEscalado__c, SAC_Estado__c, SAC_Propuesta__c, OwnerId, SAC_Titulo__c, SAC_CasoEscalado__r.SAC_Entidad_Afectada__c, SAC_EscaladoNV3__c, RecordTypeId
                        FROM SAC_Interaccion__c 
                        WHERE (RecordTypeId = :RECTYPEESCALADONV2 OR RecordTypeId = :RECTYPEESCALADOSPV)
                        AND id = :interaccionId LIMIT 1];

        if(escaladoNv2.RecordTypeId == RECTYPEESCALADOSPV) {
            idEscalado = insertReescaladoSPV(interaccionId, porpuestaCops, motivo, observaciones, escaladoNv2);
        } else {
            idEscalado = insertReescaladoSAC(interaccionId, porpuestaCops, motivo, observaciones, escaladoNv2);
        }

        return idEscalado;
    }

    /*****************************************************************
    * Proposito: Inserta una interacción con el record type SAC_EscaladoNV3 ligado al Escalado NV2 correspondiente
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US219272         Carlos Solis   12/07/21     Creación
    *****************************************************************/
    @AuraEnabled
    public static String insertReescaladoSAC(Id interaccionId, String propuestaCops, String motivo, String observaciones, SAC_Interaccion__c escaladoNv2) {
        List<ContentDocumentLink> documentos = [SELECT id, ContentDocument.Owner.name, ContentDocumentId 
                                        FROM ContentDocumentLink WHERE  LinkedEntityId =: interaccionId];

        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();

        if (escaladoNv2 != null) {
            //Comprobar propietario
            Id idUsuario = UserInfo.getUserId();
            if (escaladoNv2.OwnerId != idUsuario) {throw new AuraHandledException('No eres el propietario del escalado');
            }

            //Comprobar si ya se ha reescalado o ya se ha respondido
            List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
            listaEscalados = [SELECT id, SAC_CasoEscalado__c, SAC_Estado__c, SAC_Propuesta__c FROM SAC_Interaccion__c WHERE RecordTypeId = :RECTYPEESCALADONV3
                            AND SAC_EscaladoNV2__c = :escaladoNv2.Id];

            Boolean devuelto = false;
            String error = '';
            if (!listaEscalados.isEmpty()) {
                for (SAC_Interaccion__c escaladoNV3 : listaEscalados) {
                    if (escaladoNV3.SAC_Estado__c == 'SAC_Devuelto') {
                        //Nuevo camino reescalado
                        devuelto = true;
                    } else if (escaladoNV3.SAC_Estado__c == 'SAC_Atendida') {
                        //Error ya ha sido respondida
                        error = 'La propuesta ya ha sido respondida!';
                    } else {
                        //Error ya ha sido reescalado
                        error = 'Ya ha sido reescalado con anterioridad!';
                    }
                }
            }

            //Si existe un escalado de nivel 3 que está en estado devuelto, se vuelve a poner en estado pendiente de respuesta y el de nivel 2 pasa a estado reescalado
            if (devuelto) {
                reescalarDevuelto(escaladoNv2, propuestaCops, motivo, observaciones);
                return escaladoNv2.SAC_EscaladoNV3__c;
            } else if (String.isNotBlank(error)) { //Si tenemos un error que enviar (ya reescalado o ya respondido) lo enviamos
                throw new AuraHandledException(error);
            } else { //Insertar el nuevo escalado de nivel 3
                if(escaladoNv2.SAC_CasoEscalado__r.SAC_Entidad_Afectada__c == 'SAC_007'){
                    listaGrupos = [SELECT Id, SAC_PermiteEscalado__c, SAC_NivelGrupo__c, SAC_Email__c, SAC_Email2__c, SAC_Email3__c 
                                                                FROM CC_Grupo_Colaborador__c
                                                                WHERE SAC_PermiteEscalado__c = true
                                                                AND SAC_DeveloperName__c   = 'AJ_VCX'
                                                                AND RecordTypeId = :RECTYPEGRUPOACCIONES];
                }else{
                    listaGrupos = [SELECT Id, SAC_PermiteEscalado__c, SAC_NivelGrupo__c, SAC_Email__c, SAC_Email2__c, SAC_Email3__c 
                                                                FROM CC_Grupo_Colaborador__c
                                                                WHERE SAC_PermiteEscalado__c = true
                                                                AND SAC_DeveloperName__c   = 'AJ'
                                                                AND RecordTypeId = :RECTYPEGRUPOACCIONES];
                }
    
                List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
    
                //Insert del escalado de nivel 3
                SAC_Interaccion__c escaladoNv3 = new SAC_Interaccion__c();
                escaladoNv3.RecordTypeId = RECTYPEESCALADONV3;
                escaladoNv3.SAC_Estado__c = 'SAC_PendienteRespuesta';
                escaladoNv3.SAC_Propuesta__c = escaladoNv2.SAC_Propuesta__c;
                escaladoNv3.SAC_EscaladoNV2__c = escaladoNv2.Id;
                escaladoNv3.SAC_CasoEscalado__c = escaladoNv2.SAC_CasoEscalado__c;
                escaladoNv3.SAC_PropuestaCOPS__c = propuestaCops;
                escaladoNv3.SAC_Titulo__c = escaladoNv2.SAC_Titulo__c;
                escaladoNv3.SAC_MotivoEscalado__c = motivo;
                escaladoNv3.SAC_Observaciones_Interaccion__c = observaciones;
                if (!listaGrupos.isEmpty()) {
                    escaladoNv3.SAC_GrupoColaborador__c = listaGrupos[0].Id;
                    escaladoNv3.SAC_Email1__c = listaGrupos[0].SAC_Email__c;
                    escaladoNv3.SAC_Email2__c = listaGrupos[0].SAC_Email2__c;
                    escaladoNv3.SAC_Email3__c = listaGrupos[0].SAC_Email3__c;
                }
                if (!cola.isEmpty()) {
                    escaladoNv3.OwnerId = cola[0].Id;
                }

                SAC_DatabaseDML.insertDML(escaladoNv3, false);
                //Database.insert(escaladoNv3);
    
                List<SAC_CloneDocuments> listaDocumentos = new List<SAC_CloneDocuments>();
                SAC_CloneDocuments documentosClonados = new SAC_CloneDocuments(interaccionId, escaladoNv3.Id);
    
                listaDocumentos.add(documentosClonados);
    
                SAC_CloneDocuments.cloneDocuments(listaDocumentos);
    
                //Update del escalado de nivel 2
                if (escaladoNv2.SAC_Estado__c == 'SAC_PendienteRespuesta') {
                    escaladoNv2.SAC_Estado__c = 'SAC_Reescalada';
                    escaladoNv2.SAC_EscaladoNV3__c = escaladoNv3.Id;
    
                    try {
                        SAC_DatabaseDML.updateDML(escaladoNv2, false);
                        //Database.update(escaladoNv2);
                    } catch (Exception e) {
                        throw new AuraHandledException(e.getMessage());
                    }
                }
    
                return escaladoNv3.id;
            }
        }
        return '';
    }


    /*****************************************************************
    * Proposito: Inserta una interacción con el record type SPV_Reescalado ligado al Escalado correspondiente
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE         Description
    * 1.0            US1277284      Sergio Martín   06/06/25        Creación
    *****************************************************************/
    @AuraEnabled
    public static String insertReescaladoSPV(Id interaccionId, String propuestaCops, String motivo, String observaciones, SAC_Interaccion__c escaladoNv2) {
        
        List<ContentDocumentLink> documentos = [SELECT id, ContentDocument.Owner.name, ContentDocumentId 
                                        FROM ContentDocumentLink WHERE  LinkedEntityId =: interaccionId];

        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();

        if (escaladoNv2 != null) {
            //Comprobar propietario
            Id idUsuario = UserInfo.getUserId();
            if (escaladoNv2.OwnerId != idUsuario) {throw new AuraHandledException('No eres el propietario del escalado');
            }

            //Comprobar si ya se ha reescalado o ya se ha respondido
            List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
            listaEscalados = [SELECT id, SAC_CasoEscalado__c, SAC_Estado__c, SAC_Propuesta__c FROM SAC_Interaccion__c WHERE RecordTypeId = :RECTYPEREESCALADOSPV
                            AND SAC_EscaladoNV2__c = :escaladoNv2.Id];

            Boolean devuelto = false;
            String error = '';
            if (!listaEscalados.isEmpty()) {
                for (SAC_Interaccion__c escaladoNV3 : listaEscalados) {
                    if (escaladoNV3.SAC_Estado__c == 'SAC_Devuelto') {
                        //Nuevo camino reescalado
                        devuelto = true;
                    } else if (escaladoNV3.SAC_Estado__c == 'SAC_Atendida') {
                        //Error ya ha sido respondida
                        error = 'La propuesta ya ha sido respondida!';
                    } else {
                        //Error ya ha sido reescalado
                        error = 'Ya ha sido reescalado con anterioridad!';
                    }
                }
            }

            //Si existe un escalado de nivel 3 que está en estado devuelto, se vuelve a poner en estado pendiente de respuesta y el de nivel 2 pasa a estado reescalado
            if (devuelto) {
                reescalarDevueltoSPV(escaladoNv2, propuestaCops, motivo, observaciones);
                return escaladoNv2.SAC_EscaladoNV3__c;
            } else if (String.isNotBlank(error)) { //Si tenemos un error que enviar (ya reescalado o ya respondido) lo enviamos
                throw new AuraHandledException(error);
            } else { //Insertar el nuevo escalado de nivel 3
                if(escaladoNv2.SAC_CasoEscalado__r.SAC_Entidad_Afectada__c == 'SAC_007'){
                    listaGrupos = [SELECT Id, SAC_PermiteEscalado__c, SAC_Email__c, SAC_Email2__c, SAC_Email3__c 
                                                                FROM CC_Grupo_Colaborador__c
                                                                WHERE SAC_PermiteEscalado__c = true
                                                                AND SAC_DeveloperName__c   = 'AJ_VCX'
                                                                AND RecordTypeId = :RECTYPEGRUPOTAREAS];
                }else{
                    listaGrupos = [SELECT Id, SAC_PermiteEscalado__c, SAC_Email__c, SAC_Email2__c, SAC_Email3__c 
                                                                FROM CC_Grupo_Colaborador__c
                                                                WHERE 
                                                                SAC_PermiteEscalado__c = true
                                                                AND SAC_DeveloperName__c   = 'SPV_AJ'
                                                                AND RecordTypeId = :RECTYPEGRUPOTAREAS];
                }
                List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
    
                //Insert del escalado de nivel 3
                SAC_Interaccion__c escaladoNv3 = new SAC_Interaccion__c();
                escaladoNv3.RecordTypeId = RECTYPEREESCALADOSPV;
                escaladoNv3.SAC_Estado__c = 'SAC_PendienteRespuesta';
                escaladoNv3.SAC_Propuesta__c = escaladoNv2.SAC_Propuesta__c;
                escaladoNv3.SAC_EscaladoNV2__c = escaladoNv2.Id;
                escaladoNv3.SAC_CasoEscalado__c = escaladoNv2.SAC_CasoEscalado__c;
                escaladoNv3.SAC_PropuestaCOPS__c = propuestaCops;
                escaladoNv3.SAC_Titulo__c = escaladoNv2.SAC_Titulo__c;
                escaladoNv3.SAC_MotivoEscalado__c = motivo;
                escaladoNv3.SAC_Observaciones_Interaccion__c = observaciones;
                if (!listaGrupos.isEmpty()) {
                    escaladoNv3.SAC_GrupoColaborador__c = listaGrupos[0].Id;
                    escaladoNv3.SAC_Email1__c = listaGrupos[0].SAC_Email__c;
                    escaladoNv3.SAC_Email2__c = listaGrupos[0].SAC_Email2__c;
                    escaladoNv3.SAC_Email3__c = listaGrupos[0].SAC_Email3__c;
                }
                if (!cola.isEmpty()) {
                    escaladoNv3.OwnerId = cola[0].Id;
                }
                SAC_DatabaseDML.insertDML(escaladoNv3, false);
    
                List<SAC_CloneDocuments> listaDocumentos = new List<SAC_CloneDocuments>();
                SAC_CloneDocuments documentosClonados = new SAC_CloneDocuments(interaccionId, escaladoNv3.Id);
    
                listaDocumentos.add(documentosClonados);
                SAC_CloneDocuments.cloneDocuments(listaDocumentos);
    
                //Update del escalado de nivel 2
                if (escaladoNv2.SAC_Estado__c == 'SAC_PendienteRespuesta') {
                    escaladoNv2.SAC_Estado__c = 'SAC_Reescalada';
                    escaladoNv2.SPV_SLAFinalizado__c = true;
                    escaladoNv2.SAC_EscaladoNV3__c = escaladoNv3.Id;
    
                    try {
                        SAC_DatabaseDML.updateDML(escaladoNv2, false);
                        //Database.update(escaladoNv2);
                    } catch (Exception e) {
                        throw new AuraHandledException(e.getMessage());
                    }
                }
                return escaladoNv3.id;
            }
        }
        return '';
    }

    /*****************************************************************
    * Proposito: Traer los valores del picklist motivo del objeto SAC_interaccion__c
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --               Carlos Solis   05/01/22     Creación
    *****************************************************************/
    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoList(){
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = SAC_Interaccion__c.SAC_MotivoEscalado__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
    }

     /*****************************************************************
    * Proposito: Traer los valores del picklist conclusion del objeto SAC_interaccion__c
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US320985         Daniel Benito   10/02/22     Creación
    *****************************************************************/
    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoListConclusion(){
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = SAC_Interaccion__c.SAC_Conclusion__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
    }

    public class plantillasWrapper{

        @AuraEnabled public String idPlantilla{get; set;}
        @AuraEnabled public String nombrePlantilla{get; set;}   
        
        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }
    }

     /*****************************************************************
    * Proposito: Copiar el los archivos adjuntados en el Escalado dentro del caso padre
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US320985         Daniel Benito   10/02/22     Creación
    * 1.1            US785007         CS              15/02/24     Poner el valor SAC_Tramitacion en el ContentVersion insertado
    *****************************************************************/
    @AuraEnabled
    public static void insertarAdjuntoCaso(Id interaccionId, List<String> listaContentVersionIds){
        SAC_Interaccion__c escalado = [SELECT id,SAC_CasoEscalado__c FROM SAC_Interaccion__C WHERE id =: interaccionId LIMIT 1];

        List<ContentVersion> listaCVInsertados = [SELECT Id, Title, PathOnClient, VersionData FROM ContentVersion WHERE Id IN : listaContentVersionIds];

        if (!listaCVInsertados.isEmpty()) {
            List<ContentVersion> listaCVAInsertar = new List<ContentVersion>();
            for (ContentVersion cv : listaCVInsertados) {
                //Crear el contentVersion para el caso
                ContentVersion newcont = new ContentVersion();
                newcont.Title  = cv.Title;
                newcont.PathOnClient  = cv.PathOnClient;
                newcont.VersionData = cv.VersionData;
                newcont.FirstPublishLocationId  = escalado.SAC_CasoEscalado__c;
                newcont.SAC_Bloque__c = 'SAC_Tramitacion';
                listaCVAInsertar.add(newcont);
            }

            if (!listaCVAInsertar.isEmpty()) {
                SAC_DatabaseDML.insertListDML(listaCVAInsertar, true);
                //Database.insert(listaCVAInsertar);
            }
            // Crear una nueva lista de ContentVersion con solo el campo SAC_Bloque__c actualizado
            List<ContentVersion> listaCVActualizados = new List<ContentVersion>();
            for (ContentVersion cv : listaCVInsertados) {
                ContentVersion updatedCV = new ContentVersion(Id = cv.Id, SAC_Bloque__c = 'SAC_Tramitacion');
                listaCVActualizados.add(updatedCV);
            }

            // Actualizar la lista listaCVActualizados
            if (!listaCVActualizados.isEmpty()) {
                SAC_DatabaseDML.updateListDML(listaCVActualizados, true);
                //Database.update(listaCVActualizados);
            }
        }
    }

    /*****************************************************************
    * Proposito: Responder un escalado
    * Modificación: Quitado parámetro importe y asignación al campo SAC_ImporteAutorizado__c al 
    *               quitarse el campo SAC_ImporteAutorizado__c
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US320985         Daniel Benito   11/02/22     Creación
    * 1.1            US555020      Sergio Martín   16/05/2023     Modificación
    *****************************************************************/
    @AuraEnabled
    //public static void responderEscalado(Id interaccionId, String conclusion, Double importe, String respuesta){
    public static void responderEscalado(Id interaccionId, String conclusion, String respuesta){
        List<SAC_Interaccion__c> listaEscaladosActualizar = new List<SAC_Interaccion__c>();
        Boolean notificarOwnerNV2 = false;
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        String[] gruposUsuario;

        //Recuperar escalado actual
        SAC_Interaccion__c escalado = [SELECT id, OwnerId, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, RecordTypeId, SAC_Titulo__c,
                                        Name, SAC_CasoEscalado__c, SAC_CasoEscalado__r.RecordTypeId, SAC_CasoEscalado__r.SAC_CasoEspecial__c, SAC_Reclamacion__c,
                                        SAC_EscaladoNV2__c, SAC_EscaladoNV2__r.OwnerId, SAC_EscaladoNV2__r.Name, SAC_EscaladoNV2__r.SAC_Titulo__c, 
                                        SAC_EscaladoNV3__c, SAC_EscaladoNV3__r.SAC_Estado__c, SAC_GrupoColaborador__c, 
                                        SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId, SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c
                                        FROM SAC_Interaccion__C
                                        WHERE Id =: interaccionId LIMIT 1];
        
        User usuario = [SELECT SAC_GruposPerteneciente__c FROM User WHERE Id =: UserInfo.GetUserId() LIMIT 1];
        //Comprobamos los grupos a los que pertenece el usuario 
        // if(usuario.SAC_GruposPerteneciente__c != null){   
        if(String.isNotBlank(usuario.SAC_GruposPerteneciente__c)){
            gruposUsuario = usuario.SAC_GruposPerteneciente__c.split(';');
        }     

        //Comprobar owner este en el grupo del escalado.
        if(!gruposUsuario.isEmpty()){
            if(!gruposUsuario.contains(escalado.SAC_GrupoColaborador__c)){
                throw new AuraHandledException('Debes ser el propietario del escalado para poder responder');
            }
        }

        // //Comprobar Owner.
        // if (escalado.OwnerId != UserInfo.GetUserId()) {
        //     throw new AuraHandledException('Debes ser el propietario del escalado para poder responder');
        // }

        //Si es de presidencia y se está respondiendo siendo un escalado nivel 2 sin tener un reescalado de nivel 3 previamente respondido, obliga a reescalar. 
        //Añadido US504007: Añadido a la condición que no sea conclusión devolver, para que en caso de que se devuelva no muestre el error.
        if (escalado.SAC_CasoEscalado__r.SAC_CasoEspecial__c == 'SAC_Presidencia' && escalado.recordTypeId == RECTYPEESCALADONV2 && escalado.SAC_EscaladoNV3__r.SAC_Estado__c != 'SAC_Atendida' && conclusion != 'SAC_DevolverNivelAnterior') {
            throw new AuraHandledException('Este escalado pertenece a una reclamación de presidencia. Debe reescalarlo a AJ');
        }

        //Si es de presidencia y se está respondiendo siendo un escalado nivel 3, actualiza el escalado de nivel 2 y lo devuelve a pendiente de respuesta.
        //Mod 07/06/23 Se controla el hecho de que no exista un escalado de nivel 2, ya que ahora pueden escalar directamente a nivel 3 sin pasar por el nivel 2.
        //Añadido US504007: Añadido a la condición que no sea conclusión devolver, para que se ejecute la parte del código de devolución.
        if (escalado.SAC_CasoEscalado__r.SAC_CasoEspecial__c == 'SAC_Presidencia' && escalado.recordTypeId == RECTYPEESCALADONV3 && String.isNotBlank(escalado.SAC_EscaladoNV2__c) && conclusion != 'SAC_DevolverNivelAnterior') {
            SAC_Interaccion__c escaladoNV2 = new SAC_Interaccion__c();
            escaladoNV2.Id = escalado.SAC_EscaladoNV2__c;
            escaladoNV2.SAC_Estado__c = 'SAC_PendienteRespuesta';
            listaEscaladosActualizar.add(escaladoNV2);
            notificarOwnerNV2 = true;
        }

        //Añadido US504007 (devolución nivel anterior)
        if (conclusion == 'SAC_DevolverNivelAnterior') {
            wrapEscalado wEsc = new wrapEscalado();
            wEsc = devolverEscalado(escalado, conclusion, respuesta);
            listaEscaladosActualizar.addAll(wEsc.listaEscaladosActualizar);
            listaWrapperAlerta.addAll(wEsc.listaWrapperAlerta);
        } else {
            //Actualización del escalado actual dando una respuesta
            escalado.SAC_Conclusion__c = conclusion;
            //escalado.SAC_ImporteAutorizado__c = importe;
            escalado.SAC_Respuesta__c = respuesta;
            escalado.SAC_Estado__c = 'SAC_Atendida';
            listaEscaladosActualizar.add(escalado);
        }

        Id recordTypeTareaResponder = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_AccionResponderEsc').getRecordTypeId();
        SAC_Accion__c respuestaEsc = new SAC_Accion__c();
        respuestaEsc.RecordTypeId = recordTypeTareaResponder;
        respuestaEsc.SAC_Comentarios__c = respuesta;
        respuestaEsc.OwnerId =  UserInfo.GetUserId();
        respuestaEsc.SAC_Estado__c = 'SAC_Finalizada';
        respuestaEsc.SAC_RespuestaEscalado__c = interaccionId;
        SAC_DatabaseDML.insertDML(respuestaEsc, false);
        //Database.insert(respuestaEsc);

        try {
            //Actualización de la lista
            SAC_DatabaseDML.updateListDML(listaEscaladosActualizar, true);
            //Database.update(listaEscaladosActualizar);

            //Mandar notificación a el owner del escalado NV2 si hiciera falta
            if (notificarOwnerNV2) {
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(escalado.SAC_CasoEscalado__c,'SAC_013','El escalado ' + escalado.Name + ' ha sido atendido por AJ. Ya puede responder el escalado '+ escalado.SAC_EscaladoNV2__r.Name,escalado.SAC_EscaladoNV2__r.OwnerId,'','',escalado.SAC_EscaladoNV2__c);
                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + escalado.SAC_EscaladoNV2__c;
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);

                /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                SAC_Notificacion.enviarNotificacion(escalado.SAC_EscaladoNV2__r.OwnerId, escalado.SAC_EscaladoNV2__c, 'Escalado atendido', 'El escalado ' + escalado.SAC_Titulo__c + ' ha sido atendido por AJ. Ya puede responder el escalado.');*/
            }

            //Si tenemos alertas que enviar, se llama al método que las envía
            if (!listaWrapperAlerta.isEmpty()) {
                SAC_Alertas.generarAlertas(listaWrapperAlerta);
            }
        } catch (Exception e) {
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            if (String.isNotBlank(pureErrorMsg)) {
                pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
                throw new AuraHandledException(pureErrorMsg);
            } else {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    /*****************************************************************
    * Proposito: Guardar un escalado
    * Modificación: Quitado parámetro importe y asignación al campo SAC_ImporteAutorizado__c al 
    *               quitarse el campo SAC_ImporteAutorizado__c
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0               504023        Jesús Costa   12/19/22        Creación
    * 1.1            US555020      Sergio Martín   16/05/2023     Modificación
    *****************************************************************/
    @AuraEnabled
    //public static void guardarUnEscalado(Id interaccionId, String conclusion, Double importe, String respuesta){
    public static void guardarUnEscalado(Id interaccionId, String conclusion, String respuesta){
        List<SAC_Interaccion__c> listaEscaladosAGuardar = new List<SAC_Interaccion__c>();
        SAC_Interaccion__c escalado = getEscalado(interaccionId);
        String[] gruposUsuario;

        User usuario = [SELECT SAC_GruposPerteneciente__c FROM User WHERE Id =: UserInfo.GetUserId() LIMIT 1];
        
        //Comprobamos los grupos a los que pertenece el usuario   
        if(String.isNotBlank(usuario.SAC_GruposPerteneciente__c)){
            gruposUsuario = usuario.SAC_GruposPerteneciente__c.split(';');
        }     

        //Comprobar owner este en el grupo del escalado.
        if(!gruposUsuario.isEmpty()){
            if(!gruposUsuario.contains(escalado.SAC_GrupoColaborador__c)){
                throw new AuraHandledException('Debes ser el propietario del escalado para poder responder');
            }
        }
        

        // //Comprobar Owner.
        // if (escalado.OwnerId != UserInfo.GetUserId()) {
        //     throw new AuraHandledException('Debes ser el propietario del escalado para poder modificarlo');
        // }

        //Actualización del escalado actual dando una respuesta
        escalado.SAC_Conclusion__c = conclusion;
        //escalado.SAC_ImporteAutorizado__c = importe;
        escalado.SAC_Respuesta__c = respuesta;
        escalado.SAC_Estado__c = 'SAC_Borrador';
        listaEscaladosAGuardar.add(escalado);

        Id recordTypeTareaResponder = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_AccionResponderEsc').getRecordTypeId();
        SAC_Accion__c respuestaEsc = new SAC_Accion__c();
        respuestaEsc.RecordTypeId = recordTypeTareaResponder;
        respuestaEsc.SAC_Comentarios__c = respuesta;
        respuestaEsc.OwnerId =  UserInfo.GetUserId();
        respuestaEsc.SAC_Estado__c = 'SAC_Finalizada';
        respuestaEsc.SAC_RespuestaEscalado__c = interaccionId;
        SAC_DatabaseDML.insertDML(respuestaEsc, false);
        //Database.insert(respuestaEsc);

        try {
            //Actualización de la lista
            SAC_DatabaseDML.updateListDML(listaEscaladosAGuardar, true);
            //Database.update(listaEscaladosAGuardar);

        } catch (Exception e) { 
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            if (String.isNotBlank(pureErrorMsg)) {
                pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
                throw new AuraHandledException(pureErrorMsg);
            } else {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    /*****************************************************************
    * Proposito: Recupera los adjuntos del escalado
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US478280       Sergio Martín   29/11/22        Creación
    *****************************************************************/
    @AuraEnabled
    public static ContentVersion[] obtieneAdjuntos(String id){
        try {
            List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title, SAC_Oculto__c FROM ContentVersion WHERE 
                                    FirstPublishLocationId =: id];

            ContentVersion[] resultado =  new List<ContentVersion>();
            for(ContentVersion record : cv){
                resultado.add(record);
            }
            return resultado;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************
    * Proposito: Recuperar el  escalado
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US478280       Jesús Costa   19/12/22        Creación
    *****************************************************************/
    @AuraEnabled
    public static SAC_Interaccion__c getEscalado(Id interaccionId){
        //Recuperar escalado actual
        return [SELECT id, OwnerId, SAC_Conclusion__c, SAC_Respuesta__c, SAC_Estado__c, SAC_ImporteAutorizado__c, RecordTypeId, SAC_Titulo__c,
                                    Name, SAC_CasoEscalado__c, SAC_CasoEscalado__r.RecordTypeId, SAC_CasoEscalado__r.SAC_CasoEspecial__c, SAC_Reclamacion__c,
                                    SAC_EscaladoNV2__c, SAC_EscaladoNV2__r.OwnerId, SAC_EscaladoNV2__r.Name, SAC_EscaladoNV2__r.SAC_Titulo__c, 
                                    SAC_EscaladoNV3__c, SAC_EscaladoNV3__r.SAC_Estado__c, SAC_GrupoColaborador__c
                                    FROM SAC_Interaccion__C
                                    WHERE Id =: interaccionId LIMIT 1];
    }    

    /*****************************************************************
    * Proposito: Devolver el escalado al nivel anterior. Si el escalado es nivel 2, se devuelve
    * al letrado (grupo letrado y owner de la pretensión). Si el escalado es nivel 3, se devuelve al
    * nivel 2 (la nivel 3 pasa a estado devuelta, y la nivel 2 vuelve a abrirse).
    * Manda una alerta al uduario del anterior nivel avisando de la devolución.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US504007         CS             18/09/23     Creación
    *****************************************************************/
    private static wrapEscalado devolverEscalado(SAC_Interaccion__c escalado, String conclusion, String respuesta) {
            wrapEscalado wEsc = new wrapEscalado();
            List<SAC_Interaccion__c> listaEscaladosActualizar = new List<SAC_Interaccion__c>();
            List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
            //Actualizar escalado a estado devuelto
            if (escalado.RecordTypeId == RECTYPEESCALADONV2) {
                //Pasar escalado a devuelto y poner el owner y el grupo de la pretension y guardar el grupo que tenía en el campo SAC_GrupoVolverEscalar__c
                escalado.SAC_Conclusion__c = conclusion;
                //escalado.SAC_ImporteAutorizado__c = importe;
                escalado.SAC_Respuesta__c = respuesta;
                escalado.SAC_Estado__c = 'SAC_Devuelto';
                escalado.SAC_GrupoVolverEscalar__c = escalado.SAC_GrupoColaborador__c;
                escalado.OwnerId = escalado.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId;
                escalado.SAC_GrupoColaborador__c = escalado.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c;
                listaEscaladosActualizar.add(escalado);

                //Enviar alerta al letrado
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(escalado.SAC_CasoEscalado__c,'SAC_023','El escalado ' + escalado.Name + ' le ha sido devuelto. Debe responder el escalado '+ escalado.Name,escalado.OwnerId,'','',escalado.Id);
                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + escalado.Id;
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);

            } else if (escalado.RecordTypeId == RECTYPEESCALADONV3) {
                //Pasar escalado a estado devuelta
                escalado.SAC_Conclusion__c = conclusion;
                //escalado.SAC_ImporteAutorizado__c = importe;
                escalado.SAC_Respuesta__c = respuesta;
                escalado.SAC_Estado__c = 'SAC_Devuelto';
                listaEscaladosActualizar.add(escalado);

                //Comprobar que tiene un escalado de nivel 2, y si lo tiene, pasarlo a estado pendiente respuesta
                if (String.isNotBlank(escalado.SAC_EscaladoNV2__c)) {
                    SAC_Interaccion__c escaladoNV2 = new SAC_Interaccion__c();
                    escaladoNV2.Id = escalado.SAC_EscaladoNV2__c;
                    escaladoNV2.SAC_Estado__c = 'SAC_PendienteRespuesta';
                    listaEscaladosActualizar.add(escaladoNV2);
                    
                    //Alerta para owner escalado nivel 2
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(escalado.SAC_CasoEscalado__c,'SAC_023','El escalado ' + escalado.Name + 'le ha sido devuelto. Debe responder el escalado '+ escalado.SAC_EscaladoNV2__r.Name,escalado.SAC_EscaladoNV2__r.OwnerId,'','',escalado.SAC_EscaladoNV2__c);
                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + escalado.SAC_EscaladoNV2__c;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                } else {
                    //Pasar escalado a devuelto y poner el owner y el grupo de la pretension
                    listaEscaladosActualizar[0].SAC_Conclusion__c = conclusion;
                    //escalado.SAC_ImporteAutorizado__c = importe;
                    listaEscaladosActualizar[0].SAC_Respuesta__c = respuesta;
                    listaEscaladosActualizar[0].SAC_GrupoVolverEscalar__c = listaEscaladosActualizar[0].SAC_GrupoColaborador__c;
                    listaEscaladosActualizar[0].SAC_Estado__c = 'SAC_Devuelto';
                    listaEscaladosActualizar[0].OwnerId = escalado.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId;
                    listaEscaladosActualizar[0].SAC_GrupoColaborador__c = escalado.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c;

                    //Enviar alerta al letrado
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(escalado.SAC_CasoEscalado__c,'SAC_023','El escalado ' + escalado.Name + 'le ha sido devuelto. Debe responder el escalado '+ escalado.Name,escalado.OwnerId,'','',escalado.Id);
                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + escalado.Id;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                
            }
            //Preparar alerta
            wEsc.listaEscaladosActualizar = listaEscaladosActualizar;
            wEsc.listaWrapperAlerta = listaWrapperAlerta;
            return wEsc;
    }

    /*****************************************************************
    * Proposito: Reescalar un escalado que ha sido devuelto. Esto sucede cuando ya existe
    * un escalado nivel 3 y está en estado devuelto. El escalado nivel 2 vuelve a pasar a estado
    * reescalado y el nivel 3 pasa de estado devuelto a estado pendiente respuesta.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US504007         CS             18/09/23     Creación
    *****************************************************************/
    private static void reescalarDevuelto(SAC_Interaccion__c escaladoNv2, String propuestaCops, String motivo, String observaciones) {
        //Si existe un escalado de nivel 3 que está en estado devuelto, se vuelve a poner en estado pendiente de respuesta y el de nivel 2 pasa a estado reescalado
        List<SAC_Interaccion__c> listaInteraccionUpdatear = new List<SAC_Interaccion__c>();
        escaladoNv2.SAC_Estado__c = 'SAC_Reescalada';
        listaInteraccionUpdatear.add(escaladoNv2);

        SAC_Interaccion__c escaladoNV3 = new SAC_Interaccion__c();
        escaladoNV3.Id = escaladoNv2.SAC_EscaladoNV3__c;
        escaladoNv3.SAC_Estado__c = 'SAC_PendienteRespuesta';
        escaladoNv3.SAC_Propuesta__c = escaladoNv2.SAC_Propuesta__c;
        escaladoNv3.SAC_PropuestaCOPS__c = propuestaCops;
        escaladoNv3.SAC_MotivoEscalado__c = motivo;
        escaladoNv3.SAC_Observaciones_Interaccion__c = observaciones;
        escaladoNv3.SAC_Conclusion__c = null;

        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        if (!cola.isEmpty()) {
            escaladoNv3.OwnerId = cola[0].Id;
        }
        listaInteraccionUpdatear.add(escaladoNV3);

        SAC_DatabaseDML.updateListDML(listaInteraccionUpdatear, true);
        //Database.update(listaInteraccionUpdatear);
    }


    /*****************************************************************
    * Proposito: Reescalar un escalado que ha sido devuelto. Esto sucede cuando ya existe
    * un escalado nivel 3 y está en estado devuelto. El escalado nivel 2 vuelve a pasar a estado
    * reescalado y el nivel 3 pasa de estado devuelto a estado pendiente respuesta.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1277284      Sergio Martín   06/06/25        Creación
    *****************************************************************/
    private static void reescalarDevueltoSPV(SAC_Interaccion__c escaladoNv2, String propuestaCops, String motivo, String observaciones) {
        //Si existe un escalado de nivel 3 que está en estado devuelto, se vuelve a poner en estado pendiente de respuesta y el de nivel 2 pasa a estado reescalado
        List<SAC_Interaccion__c> listaInteraccionUpdatear = new List<SAC_Interaccion__c>();
        escaladoNv2.SAC_Estado__c = 'SAC_Reescalada';
        listaInteraccionUpdatear.add(escaladoNv2);

        SAC_Interaccion__c escaladoNV3 = new SAC_Interaccion__c();
        escaladoNV3.Id = escaladoNv2.SAC_EscaladoNV3__c;
        escaladoNv3.SAC_Estado__c = 'SAC_PendienteRespuesta';
        escaladoNv3.SAC_Propuesta__c = escaladoNv2.SAC_Propuesta__c;
        escaladoNv3.SAC_PropuestaCOPS__c = propuestaCops;
        escaladoNv3.SAC_MotivoEscalado__c = motivo;
        escaladoNv3.SAC_Observaciones_Interaccion__c = observaciones;
        escaladoNv3.SAC_Conclusion__c = null;

        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
        if (!cola.isEmpty()) {
            escaladoNv3.OwnerId = cola[0].Id;
        }
        listaInteraccionUpdatear.add(escaladoNV3);

        SAC_DatabaseDML.updateListDML(listaInteraccionUpdatear, true);
        //Database.update(listaInteraccionUpdatear);
    }
}