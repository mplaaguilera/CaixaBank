/*****************************************************************
 * Name: SAC_LCMP_InsertarEscalado
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador del LWC sac_InsertarEscalado.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219272         Carlos Solis   09/07/21     Creación Clase
*****************************************************************/
public with sharing class SAC_LCMP_InsertarEscalado {

    private static Set<String> objetos = new Set<String>{'SAC_TMECaso__c', 'SAC_Interaccion__c', 'Task', 'CC_Grupo_Colaborador__c', 'Case'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    static Id recTypeEscalado = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
    static Id recTypeEscaladoNV3 = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_EscaladoNV3').getRecordTypeId();
    static Id recTypeGrupoAcciones = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
    static Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    static Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPEESCALADONV2 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Escalado').getRecordTypeId();

    /*****************************************************************
    * Proposito: Inserta una interacción con el record type SAC_Escalado
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US219272         Carlos Solis   09/07/21     Creación
    * 2.0            US413879           MNR          13/10/2022   Modificación (Se puede escalar a cualquier grupo que tenga el check de permite escalado)
    *****************************************************************/
    @AuraEnabled
    public static String insertarEscalado(String caseId, String propuesta, String titulo, String motivo, String observaciones, String equipoId){ 

        
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Id, SAC_PermiteEscalado__c, SAC_NivelGrupo__c, SAC_Email__c, SAC_Email2__c, SAC_Email3__c, SAC_DeveloperName__c 
                    FROM CC_Grupo_Colaborador__c
                    WHERE //SAC_DeveloperName__c = 'COPS' OR  SAC_DeveloperName__c = 'AJ' OR  SAC_DeveloperName__c = 'FORCADA' OR
                    Id =:equipoId ];
        SAC_Interaccion__c escalado = new SAC_Interaccion__c();
        //CC_Grupo_Colaborador__c grupoCOPS, grupoAJ, grupoFORCADA;
        if(!grupos.isEmpty()){
            /*for (CC_Grupo_Colaborador__c grupo : grupos) {
                if(grupo.SAC_DeveloperName__c == 'COPS'){
                    grupoCOPS = grupo;
                }else if(grupo.SAC_DeveloperName__c == 'AJ'){
                    grupoAJ = grupo;
                }else if(grupo.SAC_DeveloperName__c == 'FORCADA'){
                    grupoFORCADA = grupo;
                } 
            }*/
            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];

            /*if(equipo == 'COPS'){
                escalado.RecordTypeId = recTypeEscalado;
                escalado.SAC_GrupoColaborador__c = grupoCOPS.Id;
                escalado.SAC_Email1__c = grupoCOPS.SAC_Email__c;
                escalado.SAC_Email2__c = grupoCOPS.SAC_Email2__c;
                escalado.SAC_Email3__c = grupoCOPS.SAC_Email3__c;
            }else if(equipo == 'AJ'){
                escalado.RecordTypeId = recTypeEscaladoNV3;
                escalado.SAC_GrupoColaborador__c = grupoAJ.Id;
                escalado.SAC_Email1__c = grupoAJ.SAC_Email__c;
                escalado.SAC_Email2__c = grupoAJ.SAC_Email2__c;
                escalado.SAC_Email3__c = grupoAJ.SAC_Email3__c;
            }else if(equipo == 'FORCADA'){
                escalado.RecordTypeId = recTypeEscalado;
                escalado.SAC_GrupoColaborador__c = grupoFORCADA.Id;
                escalado.SAC_Email1__c = grupoFORCADA.SAC_Email__c;
                escalado.SAC_Email2__c = grupoFORCADA.SAC_Email2__c;
                escalado.SAC_Email3__c = grupoFORCADA.SAC_Email3__c;
            } */ 
            
            if(grupos[0].SAC_NivelGrupo__c == 'SAC_Nivel2'){
                escalado.RecordTypeId = recTypeEscalado;
            }else if(grupos[0].SAC_NivelGrupo__c == 'SAC_Nivel3'){
                escalado.RecordTypeId = recTypeEscaladoNV3;
            }            
            escalado.SAC_GrupoColaborador__c = grupos[0].Id;
            escalado.SAC_Email1__c = grupos[0].SAC_Email__c;
            escalado.SAC_Email2__c = grupos[0].SAC_Email2__c;
            escalado.SAC_Email3__c = grupos[0].SAC_Email3__c;

            escalado.SAC_CasoEscalado__c = caseId;
            escalado.SAC_Propuesta__c = propuesta;
            escalado.SAC_Estado__c = 'SAC_PendienteRespuesta';
            escalado.SAC_Titulo__c = titulo;
            escalado.SAC_MotivoEscalado__c = motivo;
            escalado.SAC_Observaciones_Interaccion__c = observaciones;
            escalado.OwnerId = cola[0].Id;
            try {
                insert escalado;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }/*else{
            throw new AuraHandledException('No hay grupos disponibles para los escalados. ' + );
        }  */   
        
        return escalado.id;  
    }

    /*****************************************************************
    * Proposito: Comprueba si el usuario que usa el componente es el owner de la
    * reclamación o alguna de sus pretensiones
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US219272         Carlos Solis   16/07/21     Creación
    *****************************************************************/
    @AuraEnabled
    public static boolean esPropietario(String caseId){
        Boolean esPropietario = false;
        Id idUsuario = UserInfo.getUserId();
        Case reclamacion = new Case();
        reclamacion = [SELECT Id, OwnerId FROM Case WHERE RecordTypeId = :recTypeReclamacion
                        AND Id = :caseId LIMIT 1];

        List<Case> listaPretensionesHijas = new List<Case>();
        listaPretensionesHijas = [SELECT Id, SAC_Reclamacion__c, OwnerId FROM Case WHERE RecordTypeId = :recTypePretension
                                    AND SAC_Reclamacion__c = :caseId];

        listaPretensionesHijas.add(reclamacion);
        if (!listaPretensionesHijas.isEmpty()) {
            for (Case caso : listaPretensionesHijas) {
                if (caso.OwnerId == idUsuario) {
                    esPropietario = true;
                }
            }
        }
        return esPropietario;
    }

    /*****************************************************************
    * Proposito: Comprueba si hay algún escalado que esté abierto, para que solo permita abrir un escalado a la vez
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US271698         Carlos Solis   27/10/21     Creación
    *****************************************************************/
    @AuraEnabled
    public static boolean hayEscaladosAbiertos(String caseId) {
        Boolean hayEscaladosAbiertos = false;
        List<SAC_Interaccion__c> listaEscalados = [SELECT Id, SAC_CasoEscalado__c, SAC_Estado__c FROM SAC_Interaccion__c 
                                                    WHERE (RecordTypeId = :recTypeEscalado OR RecordTypeId = :recTypeEscaladoNV3)
                                                    AND SAC_CasoEscalado__c = :caseId
                                                    AND SAC_Estado__c = 'SAC_PendienteRespuesta'];

        if (!listaEscalados.isEmpty()) {
            hayEscaladosAbiertos = true;
        }

        return hayEscaladosAbiertos;
    }

    /*****************************************************************
    * Proposito: Copiar el los archivos adjuntados en el Escalado dentro del caso padre
    * Modificacion 1.1 : Modificacion para que se inserten todos los archivos del escalado
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US320985         Daniel Benito   10/02/22     Creación
    * 1.1            US320985         Sergio y Raúl   28/11/22     Modificacion
    *****************************************************************/
    @AuraEnabled
    public static void insertarAdjuntoCaso(Id caseId, Integer numFicheros){
        SAC_Interaccion__c escalado = [SELECT id,SAC_CasoEscalado__c,CreatedDate FROM SAC_Interaccion__C WHERE SAC_CasoEscalado__c =: caseId ORDER BY CreatedDate DESC LIMIT 1];

        List<ContentVersion> archivo = [SELECT id,CreatedDate,FirstPublishLocationId,Title,PathOnClient,VersionData FROM ContentVersion WHERE FirstPublishLocationId =: caseId ORDER BY CreatedDate DESC];
        
        List<ContentVersion> archivoInsertar = new List<ContentVersion>();
        
        for (Integer i = 0; i < numFicheros; i++) {
            ContentVersion newcont = new ContentVersion();
            newcont.Title = archivo[i].Title;
            newcont.PathOnClient = archivo[i].PathOnClient;
            newcont.VersionData = archivo[i].VersionData;
            newcont.FirstPublishLocationId = escalado.id;
            archivoInsertar.add(newcont);
        }
        
        insert archivoInsertar;
    }

     /*****************************************************************
    * Proposito: Obtener los grupos que permiten escalados
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US413879          MNR         13/10/22     Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> recogerGruposParaEscalados(Id idCase){ 
        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador__c> gruposSinNivel3 = new List<CC_Grupo_Colaborador__c>();
        try {
            Case caso = [SELECT Id, SAC_CasoEspecial__c, SAC_Entidad_Afectada__c, SAC_M2P__c FROM Case WHERE Id=: idCase];
            
            if(caso.SAC_CasoEspecial__c == 'SAC_Presidencia'){ //SAC_007 VDX  || caso.SAC_Entidad_Afectada__c == 'SAC_007'
                grupos = [SELECT Id, Name, SAC_DeveloperName__c, SAC_NivelGrupo__c
                                            FROM CC_Grupo_Colaborador__c
                                            WHERE SAC_DeveloperName__c = 'COPS']; 
            } else {
                grupos = [SELECT Id, Name, SAC_DeveloperName__c, SAC_NivelGrupo__c
                                            FROM CC_Grupo_Colaborador__c
                                            WHERE SAC_PermiteEscalado__c = true AND RecordTypeId =: recTypeGrupoAcciones 
                                            AND (SAC_NivelGrupo__c = 'SAC_Nivel2'  OR SAC_NivelGrupo__c = 'SAC_Nivel3')
                                            ORDER BY Name];             
            }

            if(caso.SAC_M2P__c) {
                for(CC_Grupo_Colaborador__c grupo : grupos) {
                    if(grupo.SAC_NivelGrupo__c != 'SAC_Nivel3') {
                        gruposSinNivel3.add(grupo);
                    }
                }
                return gruposSinNivel3;
            } 
            return grupos;
            
            

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoList(){
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = SAC_Interaccion__c.SAC_MotivoEscalado__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            if(!pickListVal.getValue().startsWith('SPV_')) {
                plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
                pickListValuesList.add(wrapper);
            }
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

     @AuraEnabled
    static public Case recuperarCaso(Id caseId){        
        String userId = UserInfo.getUserId();
        Case caseSR = new Case();
        if (Schema.sObjectType.Case.isAccessible()) {
            caseSR = [SELECT id, Status, SEG_Grupo__c, SEG_Grupo__r.Name, OwnerId, AccountId, CaseNumber, Origin, RecordTypeId, SuppliedEmail, 
            CC_MCC_Motivo__c,CC_MCC_ProdServ__c,CC_MCC_Tematica__c, RecordType.Name, CC_Idioma__c, Priority, SEG_Detalle__c, Subject, SAC_PretensionPrincipal__c,
            SAC_Reclamacion__r.SAC_PretensionPrincipal__c, SAC_Motivo__c, RecordType.DeveloperName, CC_Canal_Respuesta__c, CC_No_Identificado__c, SAC_OrigenConsulta__c,
            SAC_EsCliente__c, ContactId, OS_Email__c, SAC_NombreContacto__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_UsarDatos__c, SAC_PoblacionContacto__c, SAC_DireccionPostalNotificacion__c, CC_Importe_Reclamado__c, SAC_NPretensionesActivas__c,
            SAC_TipoDeRepresentante__c, SAC_DespachoRepresentante__c, SAC_TipoDeDocumento__c, SAC_NumeroDelDocumento__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreRepresentante__c, SAC_DireccionPostal__c,
            SAC_EmailRepresentante__c, SAC_TelefonoRepresentante__c, SAC_Naturaleza__c, SAC_CasoEspecial__c, SAC_CASE_esPSD2__c,SAC_DerivadoA__c, SAC_CasoRelacionado__c,
            CC_Detalles_Solucion__c, SAC_UserElevoASupervisor__c, SAC_FechaRecepcion__c, SAC_ObservacionesSupervisor__c, SAC_Prorrogado__c, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c, Description, SAC_EsPrincipal__c, 

            SAC_Reclamacion__c , SAC_Reclamacion__r.Status, 

            SAC_PretensionPrincipal__r.Status, SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_PretensionPrincipal__r.SEG_Grupo__r.Name, SAC_PretensionPrincipal__r.OwnerId, 
            SAC_PretensionPrincipal__r.AccountId, SAC_PretensionPrincipal__r.CaseNumber, SAC_PretensionPrincipal__r.Origin, SAC_PretensionPrincipal__r.RecordTypeId, 
            SAC_PretensionPrincipal__r.SuppliedEmail, SAC_PretensionPrincipal__r.CC_MCC_Motivo__c, SAC_PretensionPrincipal__r.CC_MCC_ProdServ__c, SAC_PretensionPrincipal__r.CC_MCC_Tematica__c, 
            SAC_PretensionPrincipal__r.RecordType.Name, SAC_PretensionPrincipal__r.CC_Idioma__c, SAC_PretensionPrincipal__r.Priority, SAC_PretensionPrincipal__r.SEG_Detalle__c,
            SAC_PretensionPrincipal__r.Subject, SAC_PretensionPrincipal__r.SAC_Motivo__c, SAC_PretensionPrincipal__r.RecordType.DeveloperName, 
            SAC_PretensionPrincipal__r.CC_Canal_Respuesta__c, SAC_PretensionPrincipal__r.CC_No_Identificado__c, SAC_PretensionPrincipal__r.SAC_OrigenConsulta__c,
            SAC_PretensionPrincipal__r.SAC_EsCliente__c, SAC_PretensionPrincipal__r.ContactId, SAC_PretensionPrincipal__r.OS_Email__c, SAC_PretensionPrincipal__r.SAC_NombreContacto__c,
            SAC_PretensionPrincipal__r.SAC_UsarDatos__c, SAC_PretensionPrincipal__r.SAC_DireccionPostalNotificacion__c, SAC_PretensionPrincipal__r.CC_Importe_Reclamado__c,
            SAC_PretensionPrincipal__r.SAC_TipoDeRepresentante__c, SAC_PretensionPrincipal__r.SAC_DespachoRepresentante__c, SAC_PretensionPrincipal__r.SAC_TipoDeDocumento__c, 
            SAC_PretensionPrincipal__r.SAC_NumeroDelDocumento__c, SAC_PretensionPrincipal__r.SAC_NombreRepresentante__c, SAC_PretensionPrincipal__r.SAC_DireccionPostal__c,
            SAC_PretensionPrincipal__r.SAC_EmailRepresentante__c, SAC_PretensionPrincipal__r.SAC_TelefonoRepresentante__c, SAC_PretensionPrincipal__r.SAC_Naturaleza__c, 
            SAC_PretensionPrincipal__r.SAC_CasoEspecial__c, SAC_PretensionPrincipal__r.SAC_CASE_esPSD2__c, SAC_PretensionPrincipal__r.SAC_Entidad_Afectada__c, SAC_PretensionPrincipal__r.SAC_EntidadProductora__c, 
            SAC_MotivoReabrir__c, OS_Fecha_Resolucion__c
            FROM Case WHERE RecordType.DeveloperName LIKE 'SAC_%' AND Id = :caseId LIMIT 1];
        }
        
        return caseSR; 
    }

    @AuraEnabled
    static public Map<String,String> recuperarUser(Case casoActual, id ownerCaso){
        
        Map<String,String> mapKeyValue =  new Map<String,String>();
        String idUser = UserInfo.getUserId();
		List<PermissionSetAssignment> lstPS = [Select Id, PermissionSet.Name From PermissionSetAssignment Where AssigneeId = :idUser];
		for(PermissionSetAssignment ps : lstPS){
			mapKeyValue.put(ps.PermissionSet.Name,ps.PermissionSet.Name);
		}
		mapKeyValue.put('UserId',idUser); 

        if(ownerCaso == idUser){
      
            List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
                    colabContact = [SELECT id
                                    FROM CC_Grupo_Colaborador_Contact__c 
                                    WHERE CC_Usuario__c=:ownerCaso
                                    AND CC_Grupo_Colaborador__r.RecordType.DeveloperName LIKE 'SAC_%'
                                    AND CC_Grupo_Colaborador__c = :casoActual.SEG_Grupo__c
                                    AND SAC_Supervisor__c = true];

            if(!colabContact.isEmpty()){ 
        
                Group colaSupervisores = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PteSupervisor' LIMIT 1];
                List<CaseHistory> ch = [SELECT id,OldValue, NewValue, Field, CreatedDate  
                                        FROM CaseHistory 
                                        WHERE CaseId =:casoActual.Id AND Case.RecordType.DeveloperName LIKE 'SAC_%' AND Field = 'Owner' AND DataType = 'EntityId' ORDER BY CreatedDate desc]; 
           
                if(Test.isRunningTest() || ch[0].OldValue == colaSupervisores.Id ){
                    mapKeyValue.put('mostrarSupervisor', 'si');  
                }                
            }            
        }       

        return mapKeyValue;  
    }

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

    
    @AuraEnabled
    public static SAC_Interaccion.ValidacionesEscalado validacionesEscalados(Id caseId){
        // Llama al método validacionesEscalados de la clase SAC_Interaccion
        SAC_Interaccion.ValidacionesEscalado resultado = SAC_Interaccion.validacionesEscalados(caseId);

        return resultado;
    }

}