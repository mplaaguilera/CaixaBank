/*****************************************************************************************
 * Name: SAC_LCMP_NuevaTarea
 * Copyright © 2021  CaixaBank
 * =======================================================================================
 * Proposito: Controlador para el nuevo componente de forzar resolución de una reclamación
 * Principal objetivo: Forzar el cierre de la reclamación y de sus asuntos pendientes
 * LWC asociado: sAC_ForzarResolucion
 * =======================================================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE          Description
 * 1.0            US505370         Raúl Santos    08/03/2023    Creación 
******************************************************************************************/

public without sharing class SAC_LCMP_ForzarResolucion {

    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();


    /********************************************************************************************************
     * Proposito: Comprobar el estado de la reclamación (para evitar mostrar el componente en determinados estados)
     *            y además comprueba que el usuario pertecene a COPS o AJ
     * ******************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US505370         Raúl Santos    08/03/2023    Creación      
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean perteneceCOPSAJ(String idCaso){ 

        String whoId = UserInfo.getUserId();

        if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'No tiene permisos para realizar la acción.' ); }
        Case caso = [SELECT Id, Status, RecordType.DeveloperName FROM Case WHERE Id =: idCaso AND RecordTypeId =: RECTYPERECLAMACION];

        if(!caso.Status.equals('SAC_014')  && !caso.Status.equals('Cerrado') && !caso.Status.equals('Rechazado') && !caso.Status.equals('SAC_008') && !caso.Status.equals('SAC_013') && !caso.Status.equals('SAC_012') && !caso.Status.equals('SAC_009')){

            if(!Schema.sObjectType.User.isAccessible()){ throw new AuraHandledException( 'No tiene permisos para realizar la acción.' ); }
            User usuarioActual = [SELECT Id, SAC_PerteneceCOPSAJ__c  FROM User WHERE Id =: whoId];
            return usuarioActual.SAC_PerteneceCOPSAJ__c;
        }

        return false;
       
    }

     /*********************************************************************************************
     * Proposito: Método para recuperar las tareas, consultas o escalados que puedan estar asociados al caso en cuestión
     * ===========================================================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0            US505370         Raúl Santos    08/03/2023    Creación                
    *********************************************************************************************/

    @AuraEnabled
    public static List<SAC_Interaccion__c> recuperarEscalados(String caseId){
        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();

        if(!Schema.sObjectType.SAC_Interaccion__c.isAccessible()){ throw new AuraHandledException( 'No tiene permisos para realizar la acción.' ); }
        listaEscalados = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_CasoEscalado__c =: caseId AND (RecordType.DeveloperName = 'SAC_EscaladoNV3' OR RecordType.DeveloperName = 'SAC_Escalado') AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SAC_Borrador' OR SAC_Estado__c = 'SAC_Reescalada')];

        return listaEscalados;
    }

    @AuraEnabled
    public static List<SAC_Interaccion__c> recuperarConsultas(String caseId){
        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();

        if(!Schema.sObjectType.SAC_Interaccion__c.isAccessible()){ throw new AuraHandledException( 'No tiene permisos para realizar la acción.' ); }
        listaConsultas = [SELECT Id, SAC_Estado__c, SAC_MotivoDeFinalizado__c FROM SAC_Interaccion__c WHERE SAC_Reclamacion__c =: caseId AND RecordType.DeveloperName = 'SAC_Consulta' AND (SAC_Estado__c = null OR SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SAC_Borrador' OR SAC_Estado__c = 'SAC_Reescalada' OR SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva')];

        return listaConsultas;
    }

    @AuraEnabled
    public static List<SAC_Accion__c> recuperarTareas(String caseId){
        List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();

        if(!Schema.sObjectType.SAC_Accion__c.isAccessible()){ throw new AuraHandledException( 'No tiene permisos para realizar la acción.' ); }
        listaTareas = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Reclamacion__c =: caseId AND (RecordType.DeveloperName = 'SAC_MaestroDeTareas' OR RecordType.DeveloperName = 'SAC_OtrasTareas') AND (SAC_Estado__c = 'SAC_PendienteEnviar' 
                        OR SAC_Estado__c = 'SAC_PendienteAsignar' OR SAC_Estado__c = 'SAC_EnGestion' OR SAC_Estado__c = 'SAC_StandBy' OR SAC_Estado__c = 'SAC_PendienteRevision' OR SAC_Estado__c = 'SAC_Devuelta' 
                        OR SAC_Estado__c = 'SAC_PteReenvio')];

        return listaTareas;
    }

    /*********************************************************************************************
     * Proposito: Método para finalizar el proceso de cierre. Si existen escalados, consultas o tareas asociadas pendientes, finaliza estos
     *            para posteriormente pasar al estado "Cerrada sin resolver" al caso, y las pretensiones asociadas a "Cerrado"
     * ===========================================================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0            US505370         Raúl Santos    08/03/2023    Creación                
    *********************************************************************************************/

    @AuraEnabled
    public static void finalizarProcesoForzado(String caseId, List<SAC_Interaccion__c> listaEscalados,List<SAC_Interaccion__c> listaConsultas, List<SAC_Accion__c> listaTareas, String motivo){

        if(!listaEscalados.isEmpty()){
            escaladosAsociados(listaEscalados);
        }

        if(!listaConsultas.isEmpty()){
            consultasAsociadas(listaConsultas);
        }

        if(!listaTareas.isEmpty()){
            tareasAsociadas(listaTareas);
        }

        // Proceso de pasar a cerrado la reclamación
        if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'No tiene permisos para realizar la acción.' ); }
        Case caso = [SELECT Id FROM Case WHERE Id =: caseId];
        List<Case> pretensiones = [SELECT Id, Status FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_Reclamacion__c =: caseId];

        caso.SAC_MotivoReabrir__c = null;
        caso.SAC_MotivoCierre__c = motivo;
        caso.Status = 'SAC_014';
        caso.SAC_StatusAuxiliar__c = 'SAC_014';

        if(!pretensiones.isEmpty()){
            for(Case pretension : pretensiones){
                if(pretension.Status != 'SAC_009') {
                    pretension.Status = 'Cerrado';
                    pretension.SAC_StatusAuxiliar__c = 'Cerrado';
                }
            }
        }
    
        List<Case> listaCasosUpdatear = new List<Case>();
        listaCasosUpdatear.addAll(pretensiones);
        listaCasosUpdatear.add(caso);

        if (!Schema.sObjectType.Case.isUpdateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
        Database.update(listaCasosUpdatear);  
    }

    @AuraEnabled
    public static void escaladosAsociados(List<SAC_Interaccion__c> listaEscalados){

        for(SAC_Interaccion__c escalado : listaEscalados){
            escalado.SAC_Estado__c = 'SAC_FinalizadoSinAtender';
        }

        if (!Schema.sObjectType.SAC_Interaccion__c.isUpdateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
        Database.update(listaEscalados);
    }

    @AuraEnabled
    public static void consultasAsociadas(List<SAC_Interaccion__c> listaConsultas){

        for(SAC_Interaccion__c consulta : listaConsultas){
            consulta.SAC_Estado__c = 'SAC_Finalizada';
            consulta.SAC_MotivoDeFinalizado__c = 'SAC_FinalizadaSinContestar';
        }

        if (!Schema.sObjectType.SAC_Interaccion__c.isUpdateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
        Database.update(listaConsultas);
    }

    @AuraEnabled
    public static void tareasAsociadas(List<SAC_Accion__c> listaTareas){

        for(SAC_Accion__c tarea : listaTareas){
            tarea.SAC_SaltarValidacion__c = true;
            tarea.SAC_Estado__c = 'SAC_FinalizadaIncompleta';
        }

        if (!Schema.sObjectType.SAC_Accion__c.isUpdateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
        Database.update(listaTareas);
    }
}