public with sharing class SAC_GetOwnerCases {
/*****************************************************************
 * Name: SAC_GetOwnerCases
 * Copyright © 2021  CaixaBank
 * ============================================================
 * Proposito: Controlador  para poder visualizar y asociar Reclamaciones de un mismo propietario siempre y cuando
 *   sus pretensiones sean las mismas o tengan relación entre Reclamaciones ya existentes.
 *   LWC asociado: sAC_AsociarReclamaciones
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa     16/04/21      Creación Clase
*****************************************************************/

private static final String MSG_ERROR_PERMISSIONS = 'No tienes permisos para realizar la acción.';
private static final String MSG_ERROR_RECORDS = 'No existe un cliente asociado a la reclamación.';
   
    @AuraEnabled(cacheable = true)
    public static List<ReclamacionWrapper> getSameOwnerCases(String idCasoDisparador){
/*****************************************************************
 * Proposito: Método para obtener la lista de reclamaciones asignadas al mismo propietario de la reclamación que se esta visualizando
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa    16/04/21       Creación Método
*****************************************************************/
        
        Id tipoRegistro = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();

        if(!Case.SObjectType.getDescribe().isAccessible()){
            throwAuraHandledException( MSG_ERROR_PERMISSIONS );
        }

        //Caso para poder obtener casos relacionados a este
        Case casoAuxiliar = [Select Id, CaseNumber, AccountId From Case Where Id =: idcasoDisparador];
                     
        if(casoAuxiliar.AccountId == null){
            throwAuraHandledException( MSG_ERROR_RECORDS );
        }

        //Lista reclamaciones
        List<Case> reclamaciones = [SELECT SAC_Reclamacion__c, Id, CaseNumber, AccountId, Description, ParentId, Subject, CreatedDate, Status
                                    FROM Case 
                                    WHERE AccountId =: casoAuxiliar.AccountId
                                    AND AccountId != null
                                    AND recordTypeId =: tipoRegistro
                                    AND isClosed = False
                                    AND Id != :casoAuxiliar.Id];

        //Map con Id - Reclamacion
        Map<Id,Case> mapDeReclamaciones = new Map<Id, Case>();
        for(Case reclamacionMap : reclamaciones){
            mapDeReclamaciones.put(reclamacionMap.Id, reclamacionMap);
        }

        //Lista pretensiones de las reclamaciones
        List<Case> pretensiones = [ SELECT Id, SAC_Reclamacion__c, SAC_Reclamacion__r.Subject, CaseNumber, CC_MCC_ProdServ__c, CC_MCC_Tematica__c, CC_MCC_Motivo__c, Subject, CreatedDate, Status
                                    FROM Case
                                    WHERE SAC_Reclamacion__c IN: reclamaciones];

        //Objeto reclamaciones + pretensiones
        List<ReclamacionWrapper> listadoFinal = new List<ReclamacionWrapper>();

        //Map contiene reclamacion + pretensiones
        Map<Id,List<Case>> mapPretensiones = new Map<Id,List<Case>>();

        //MAPEO DEL LISTADO PRETENSIONES A SU CORRESPONDIENTE MAP DE RECLAMACIONES, LISTA PRETENSIONES
        for(Case casoMap : pretensiones){        
            //Lista para iterar las pretensiones
            List<Case> listadoAuxiliar = new List<Case>();
            if(mapPretensiones.containsKey(casoMap.SAC_Reclamacion__c)){
                listadoAuxiliar = mapPretensiones.get(CasoMap.SAC_Reclamacion__c);
                listadoAuxiliar.add(casoMap);
                mapPretensiones.put(CasoMap.SAC_Reclamacion__c, listadoAuxiliar);

            }
            else{
                listadoAuxiliar.add(casoMap);
                mapPretensiones.put(casoMap.SAC_Reclamacion__c, listadoAuxiliar);
            }
        }

        //Pasar el objeto MAP al objeto wrapper
        for(String reclamacionMap : mapPretensiones.keySet()){
            
            //Lista para iterar las pretensiones
            List<Case> pretensionesMapa = new List<Case>();
            pretensionesMapa = mapPretensiones.get(reclamacionMap);

            ReclamacionWrapper reclamacionAuxiliar = new ReclamacionWrapper(mapDeReclamaciones.get(reclamacionMap) , pretensionesMapa);
            listadoFinal.add(reclamacionAuxiliar);

        }

        return listadoFinal;
    }
    
    @AuraEnabled
    public static void modifySameOwnerCases(String idCasoVinculado, String idCasoActual){
/*****************************************************************
 * Proposito: Método para vincular reclamaciones en el apartado Antecedentes del objeto Case 
 *  (Solo disponible para el recordType SAC_Reclamacion)
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa    16/04/21       Creación Método
*****************************************************************/

        if(
            !Case.SObjectType.getDescribe().isAccessible()
        ){
            throwAuraHandledException( MSG_ERROR_PERMISSIONS );
        }
        List<Case> casoAVincular = [Select Id, CC_CasoRelacionado__c, CaseNumber From Case Where Id =: idCasoVinculado Limit 1];
        List<Case> casoActual = [Select Id, CC_CasoRelacionado__c, CaseNumber From Case Where Id =: idCasoActual Limit 1];
   

        Id casoRelacionado = casoAVincular[0].Id;

        casoActual[0].CC_CasoRelacionado__c = casoRelacionado;

        if(
            Case.SObjectType.getDescribe().isUpdateable()
        ){
            update casoActual;
        }else{
            throwAuraHandledException( MSG_ERROR_PERMISSIONS );
        }
    }
    
    
    public class ReclamacionWrapper{
/*****************************************************************
 * Name: ReclamacionWrapper
 * Copyright © 2021  CaixaBank
 * ============================================================
 * Proposito: Clase Wrapper para mandar contenido formateado del controlador Apex al controlador JS para el correcto funcionamiento
 *  del Lightning Web Component: sAC_AsociarReclamacion.
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa     16/04/21      Creación Clase
*****************************************************************/

        @AuraEnabled public List<Case> pretensiones {get; set;}
        @AuraEnabled public Case reclamacionActual {get; set;}
        
        public ReclamacionWrapper(Case reclamacion, List<Case> listaPretensiones)
        {
/*****************************************************************
 * Proposito: Método constructor de la clase Wrapper
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa    16/04/21       Creación Método
*****************************************************************/
            reclamacionActual = reclamacion;
            pretensiones = listaPretensiones;            
        }
        
    }

    private static void throwAuraHandledException( String errorMsg ){
/*****************************************************************
 * Proposito: Método para controlar errores y lanzarlos por pantalla
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa    16/04/21       Creación Método
*****************************************************************/
        AuraHandledException auraException = new AuraHandledException( errorMsg );
        auraException.setMessage( errorMsg );
        throw auraException;
    }
    
}