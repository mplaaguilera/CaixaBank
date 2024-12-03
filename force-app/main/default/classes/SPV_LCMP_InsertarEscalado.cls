/*****************************************************************
 * Name: SPV_LCMP_InsertarEscalado
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador del LWC spv_InsertarEscalado.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US929958     Sergio Martín   30/05/24     Creación Clase
*****************************************************************/
public with sharing class SPV_LCMP_InsertarEscalado {
    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c', 'Case', 'CC_Grupo_Colaborador__c'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    private static final Id RECTYPEGRUPOACCIONES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();


    /*****************************************************************
    * Proposito: Comprueba si el usuario que usa el componente es el owner de la
    * reclamación o alguna de sus pretensiones
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US929958     Sergio Martín   31/05/24        Creación
    *****************************************************************/
    @AuraEnabled
    public static boolean esPropietario(String caseId){
        Boolean esPropietario = false;
        Id idUsuario = UserInfo.getUserId();
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id = :caseId LIMIT 1];
        List<Case> listaPretensionesHijas = [SELECT Id, SAC_Reclamacion__c, OwnerId FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c = :caseId];

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
    * Proposito: Obtener los grupos que permiten escalados
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US929958     Sergio Martín   04/06/24        Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> recogerGruposParaEscalados(Id idCase){ 
        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        //List<CC_Grupo_Colaborador__c> gruposSinNivel3 = new List<CC_Grupo_Colaborador__c>();
        try {
            grupos = [SELECT Id, Name, SAC_DeveloperName__c, SAC_NivelGrupo__c
                                        FROM CC_Grupo_Colaborador__c
                                        WHERE SAC_PermiteEscalado__c = true AND RecordTypeId =: RECTYPEGRUPOACCIONES 
                                        // AND (SAC_NivelGrupo__c = 'SAC_Nivel2'  OR SAC_NivelGrupo__c = 'SAC_Nivel3')
                                        ORDER BY Name];             
            return grupos;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /*****************************************************************
    * Proposito: Comprueba si hay algún escalado que esté abierto, para que solo permita abrir un escalado a la vez
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US929958     Sergio Martín   31/05/24        Creación
    *****************************************************************/
    @AuraEnabled
    public static boolean hayEscaladosAbiertos(String caseId) {
        Boolean hayEscaladosAbiertos = false;
        List<SAC_Interaccion__c> listaEscalados = [SELECT Id, SAC_CasoEscalado__c, SAC_Estado__c FROM SAC_Interaccion__c 
                                                    WHERE RecordTypeId = :RECTYPEESCALADO
                                                    AND SAC_CasoEscalado__c = :caseId
                                                    AND SAC_Estado__c != 'SAC_Resuelta'];

        if (!listaEscalados.isEmpty()) {
            hayEscaladosAbiertos = true;
        }
        return hayEscaladosAbiertos;
    }


    /*****************************************************************
    * Proposito: Inserta una interacción con el record type SPV_Escalado
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US929958     Sergio Martín   31/05/24        Creación
    *****************************************************************/
    @AuraEnabled
    public static String insertarEscalado(String caseId, String propuesta, String titulo, String motivo, String observaciones, String equipoId){ 
        // List<CC_Grupo_Colaborador__c> grupos = [SELECT Id, SAC_PermiteEscalado__c, SAC_NivelGrupo__c, SAC_Email__c, SAC_Email2__c, SAC_Email3__c, SAC_DeveloperName__c 
        //             FROM CC_Grupo_Colaborador__c
        //             WHERE //SAC_DeveloperName__c = 'COPS' OR  SAC_DeveloperName__c = 'AJ' OR  SAC_DeveloperName__c = 'FORCADA' OR
        //             Id =:equipoId];
        SAC_Interaccion__c escalado = new SAC_Interaccion__c();
        //CC_Grupo_Colaborador__c grupoCOPS, grupoAJ, grupoFORCADA;
        if(!String.isBlank(equipoId)){
            //List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
            
            escalado.RecordTypeId = RECTYPEESCALADO;           
            escalado.SAC_GrupoColaborador__c = equipoId;
            // escalado.SAC_Email1__c = grupos[0].SAC_Email__c;
            // escalado.SAC_Email2__c = grupos[0].SAC_Email2__c;
            // escalado.SAC_Email3__c = grupos[0].SAC_Email3__c;

            escalado.SAC_CasoEscalado__c = caseId;
            escalado.SAC_Propuesta__c = propuesta;
            escalado.SAC_Estado__c = 'SPV_PendienteEnviar';
            escalado.SAC_Titulo__c = titulo;
            escalado.SAC_MotivoEscalado__c = motivo;
            escalado.SAC_Observaciones_Interaccion__c = observaciones;
            //escalado.OwnerId = cola[0].Id;
            try {
                SPV_DatabaseDML.insertDML(escalado, false);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }        
        return escalado.id;  
    }
}