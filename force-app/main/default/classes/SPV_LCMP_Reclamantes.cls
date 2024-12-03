/*****************************************************************
 * Name: SPV_LCMP_Reclamantes
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador del LWC sac_Reclamantes.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            NaN              Carlos Gomez   02/06/24     Creación Clase
*****************************************************************/
public with sharing class SPV_LCMP_Reclamantes {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    final static Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();


    /*****************************************************************
    * Proposito: Recupera los reclamantes de una reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            NaN              Carlos Gomez   02/06/24     Creación 
    *****************************************************************/
    @AuraEnabled(cacheable = true)
    public static InfoReclamantesWrapper recuperarReclamantes(String caseId){
        try {
            Id sacCaracteristicaClienteRT = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SAC_CaracteristicaClienteCuenta').getRecordTypeId();

            Set<Id> idsReclamantes = new Set<Id>();

            //Esta lista recupera todos los reclamantes que pertenezcan a la reclamación, sin tener en cuenta los de las pretensiones
            List<SAC_CaseReclamante__c> listaReclamantes = [SELECT Id, SAC_Account__c, SAC_Case__c, SAC_Account__r.Name, SAC_ReclamantePrincipal__c, SAC_Pretension__c, SAC_Empleado__c,
                                                            SAC_Account__r.AV_EAPGestor__c, SAC_Account__r.CC_OficinaGestoraId__c, SAC_Account__r.AV_EAPGestor__r.AccountId,
                                                            SAC_TelefonoNoAlf__c, SAC_EmailNoAlf__c, SAC_DireccionNoAlf__c, SAC_TieneDatosNoAlf__c
                                                            FROM SAC_CaseReclamante__c 
                                                            WHERE SAC_Case__c = :caseId
                                                            AND (SAC_Pretension__c = null)];

            for(SAC_CaseReclamante__c reclamante : listaReclamantes){
                idsReclamantes.add(reclamante.SAC_Account__c);
            }

            List<CC_Caracteristica_Detalle__c> listaCaracReclamantes = [SELECT Id, SAC_Cuenta__c, CC_Caracteristica__c, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c FROM CC_Caracteristica_Detalle__c WHERE SAC_Cuenta__c = :idsReclamantes AND CC_Caracteristica__r.RecordTypeId = :sacCaracteristicaClienteRT AND CC_Caracteristica__r.CC_Activo__c = true];
            InfoReclamantesWrapper infoReclamantes = new InfoReclamantesWrapper(listaReclamantes, listaCaracReclamantes);
            return infoReclamantes;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************
    * Proposito: Elimina el reclamante introducido por parámetro
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            NaN              Carlos Gomez   02/06/24     Creación
    *****************************************************************/
    @AuraEnabled
    public static void eliminarReclaSecu(String idCaso, String ownerId, String pretPrincipalownerId, String reclamanteId){
        //Compruebo si el que ejecuta la acción es el owner
        if (!esPropietarioCaso(ownerId, pretPrincipalownerId)) {
            throw new AuraHandledException('Debes ser el propietario del caso para poder realizar la acción');
        }

        //Recupero los reclamantes del caso
        List<SAC_CaseReclamante__c> listRecDatosNoAlf = [SELECT Id, SAC_TieneDatosNoAlf__c, SAC_Case__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c = :idCaso];

        SAC_CaseReclamante__c reclamanteDelete = new SAC_CaseReclamante__c();
        Boolean otrosRecNoAlf = false;

        for(SAC_CaseReclamante__c reclamante : listRecDatosNoAlf){
            if(reclamante.Id == reclamanteId){
                reclamanteDelete = reclamante;
            }else if(reclamante.SAC_TieneDatosNoAlf__c == true){
                otrosRecNoAlf = true;
            }
        }

        //Si es el único reclamante con datos no ALF, debemos actualizar el campo de la reclamación
        if(reclamanteDelete != null){
            if(otrosRecNoAlf == false){
                reclamanteDelete.SAC_TieneDatosNoAlf__c = false;
                actualizarRecNoAlf(reclamanteDelete);
            }     
            SPV_DatabaseDML.deleteDML(reclamanteDelete, true);
        }
    }

    /*****************************************************************
    * Proposito: Cambia el reclamante principal de un caso y pone de principal el introducido
    * por parámetro
    * Modificacion: Al cambiar el reclamante las pretensiones también deben ser propiedad del nuevo reclamante principal
    * Modificacion 1.2: Al cambiar el reclamante el idioma del nuevo reclamante debe ser arrastrado a la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            NaN             Carlos Gomez   02/06/24     Creación

    *****************************************************************/
    @AuraEnabled
    public static void cambiarReclaPrincipal(String reclamanteId){
        try {
            
            SAC_CaseReclamante__c reclamanteActualizar = [SELECT Id, SAC_ReclamantePrincipal__c, SAC_Pretension__c, SAC_Case__c, SAC_Account__c, SAC_Contact__c, SAC_Account__r.CC_Idioma__pc, SAC_Account__r.AV_EAPGestor__r.AccountId  FROM SAC_CaseReclamante__c WHERE Id = :reclamanteId LIMIT 1];
            
            reclamanteActualizar.SAC_ReclamantePrincipal__c = true;

            SPV_DatabaseDML.updateDML(reclamanteActualizar, true); 

            List<Case> casos = [SELECT Id, AccountId, ContactId, RecordTypeId FROM Case WHERE RecordTypeId IN (:RECTYPERECLAMACION, :RECTYPEPRETENSION) AND (SAC_Reclamacion__c =: reclamanteActualizar.SAC_Case__c OR Id =: reclamanteActualizar.SAC_Case__c)];
            for(Case caso : casos) {
                if(caso.RecordTypeId == RECTYPEPRETENSION) {
                    caso.AccountId = reclamanteActualizar.SAC_Account__c;
                    caso.ContactId = reclamanteActualizar.SAC_Contact__c;
                } else if(caso.RecordTypeId == RECTYPERECLAMACION) {
                    caso.CC_Idioma__c = reclamanteActualizar.SAC_Account__r.CC_Idioma__pc;
                    caso.CC_Oficina__c = reclamanteActualizar.SAC_Account__r.AV_EAPGestor__r.AccountId;
                }
            }
            SPV_DatabaseDML.updateListDML(casos, true);

            List<SAC_CaseReclamante__c> reclamantesAModificar = [SELECT Id, SAC_Account__c, SAC_Contact__c, SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_ReclamantePrincipal__c = true AND SAC_Case__c in :casos AND Id != :reclamanteId];
            for (SAC_CaseReclamante__c reclamante : reclamantesAModificar) {
                reclamante.SAC_ReclamantePrincipal__c = false;
            }
            SPV_DatabaseDML.updateListDML(reclamantesAModificar, true);
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************
    * Proposito: Elimina el reclamante principal y todos los que pertenezcan a una pretension.
    * Antes de eliminarlos, quita el account y el contact del caso y lo updatea.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            NaN              Carlos Gomez   02/06/24     Creación
    *****************************************************************/
    @AuraEnabled
    public static void eliminar(String caseId, String accountId) {
        //Recupero el reclamante a eliminar
        List<SAC_CaseReclamante__c> listaReclaEliminar = [SELECT Id, SAC_TieneDatosNoAlf__c 
                                                         FROM SAC_CaseReclamante__c 
                                                         WHERE (SAC_Case__c = :caseId AND SAC_Account__c = :accountId)
                                                         OR (SAC_Case__c = :caseId AND SAC_Pretension__c <> null)];
        //Preparo el caso que voy a updatear quitandole el account y el contact
        Case caso = new Case();
        caso.Id = caseId;
        caso.AccountId = null;
        caso.ContactId = null;
        caso.CC_Oficina__c = null;
        caso.SAC_ReclamantesConDatosNoAlf__c = false;


        SPV_DatabaseDML.updateDML(caso, true);
        SPV_DatabaseDML.deleteListDML(listaReclaEliminar, true);
    }

    /*****************************************************************
    * Proposito: Elimina el reclamante principal y pone a otro secundario elegido
    * como el principal. También borra los reclamantes que pertenezcan a una pretensión
    * Modificacion: Al cambiar el reclamante las pretensiones también deben ser propiedad del nuevo reclamante principal
    * Modificacion 1.2: Al cambiar el reclamante el idioma del nuevo reclamante debe ser arrastrado a la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            NaN             Carlos Gomez   02/06/24     Creación
    *****************************************************************/
    @AuraEnabled
    public static void eliminarYCambiarPrincipal(String caseId, String accountId, String idReclamanteCambiarAPrincipal) {
        //Recupero los reclamantes
        List<SAC_CaseReclamante__c> listReclamantes = [SELECT Id, SAC_Case__c, SAC_Pretension__c, SAC_Account__c, SAC_TieneDatosNoAlf__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c = :caseId];

        List<SAC_CaseReclamante__c> listaReclaEliminar = new List<SAC_CaseReclamante__c>();
        Integer numRecEliminarDatosNoAlf = 0;
        Integer numRecDatosNoAlf = 0;
        for(SAC_CaseReclamante__c reclamante : listReclamantes){
            //Recupero los reclamantes a eliminar
            if(reclamante.SAC_Account__c == accountId || (reclamante.SAC_Case__c == caseId && reclamante.SAC_Pretension__c <> null)){
                listaReclaEliminar.add(reclamante);

                if(reclamante.SAC_TieneDatosNoAlf__c){
                    numRecEliminarDatosNoAlf++;
                }
            }
            if(reclamante.SAC_TieneDatosNoAlf__c){
                numRecDatosNoAlf++;
            }
        }

        //Updateo el nuevo reclamante principal
        SAC_CaseReclamante__c reclamanteUpdatear = new SAC_CaseReclamante__c();

        reclamanteUpdatear.Id = idReclamanteCambiarAPrincipal;

        reclamanteUpdatear.SAC_ReclamantePrincipal__c = true;
        SPV_DatabaseDML.updateDML(reclamanteUpdatear, true);

        

        SAC_CaseReclamante__c reclamanteActualizar = [SELECT Id, SAC_Account__c, SAC_Contact__c, SAC_Account__r.CC_Idioma__pc, SAC_Account__r.AV_EAPGestor__r.AccountId FROM SAC_CaseReclamante__c WHERE Id = :idReclamanteCambiarAPrincipal LIMIT 1];

        List<Case> casos = [SELECT Id, AccountId, ContactId, RecordTypeId FROM Case WHERE RecordTypeId IN (:RECTYPERECLAMACION, :RECTYPEPRETENSION) AND (SAC_Reclamacion__c =: caseId OR Id =: caseId)];
        for(Case caso : casos) {
            if(caso.RecordTypeId == RECTYPEPRETENSION) {
                caso.AccountId = reclamanteActualizar.SAC_Account__c;
                caso.ContactId = reclamanteActualizar.SAC_Contact__c;
            } else if(caso.RecordTypeId == RECTYPERECLAMACION) {
                caso.CC_Idioma__c = reclamanteActualizar.SAC_Account__r.CC_Idioma__pc;
                caso.CC_Oficina__c = reclamanteActualizar.SAC_Account__r.AV_EAPGestor__r.AccountId;

                if(numRecEliminarDatosNoAlf == numRecDatosNoAlf){
                    caso.SAC_ReclamantesConDatosNoAlf__c = false;
                }
            }
        }

        SPV_DatabaseDML.updateListDML(casos, true);

        //Elimino los reclamantes recuperados anteriormente
        SPV_DatabaseDML.deleteListDML(listaReclaEliminar, true);

    }

    /*****************************************************************
    * Proposito: Comprueba si hay algun reclamante secundario en el caso.
    * Si hay reclamantes secundarios, devuelve true. Si no hay, devuelve false
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            NaN              Carlos Gomez   02/06/24    Creación
    *****************************************************************/
    @AuraEnabled
    public static Boolean tieneReclamanteSecundario(String caseId, String ownerId, String pretPrincipalownerId){
        //Compruebo si el que ejecuta la acción es el owner
        if (!esPropietarioCaso(ownerId, pretPrincipalownerId)) {
            throw new AuraHandledException('Debes ser el propietario del caso para poder realizar la acción');
        }

        List<SAC_CaseReclamante__c> listaReclamantesSecundarios = [SELECT Id, SAC_Account__r.Name, SAC_ReclamantePrincipal__c, SAC_Pretension__c 
                                                                    FROM SAC_CaseReclamante__c 
                                                                    WHERE SAC_Case__c = :caseId
                                                                    AND SAC_ReclamantePrincipal__c = false
                                                                    AND SAC_Pretension__c = null];

        return !listaReclamantesSecundarios.isEmpty() ? true : false;
    }

    /*****************************************************************
    * Proposito: Comprueba si el owner del caso es el mismo que ejecuta la acción.
    * Si es el propietario, devuelve true. De lo contrario, devuelve false
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            NaN              Carlos Gomez   02/06/24     Creación
    *****************************************************************/
    @AuraEnabled
    public static Boolean esPropietarioCaso(String ownerId, String pretPrincipalownerId) {
        Id usuarioActual = UserInfo.getUserId();
        return (usuarioActual == ownerId || usuarioActual == pretPrincipalownerId) ? true : false;
    }

    @AuraEnabled
    public static List<EmailMessage> recuperarComunicacionesEmail(Id caseId){

        List<EmailMessage> listaEmailMessage = new List<EmailMessage>();

        List<SAC_CaseReclamante__c> reclamantePrincipal = [SELECT Id, SAC_Account__c, SAC_CorreoElectronico__c, SAC_Case__c, SAC_Account__r.Name, SAC_ReclamantePrincipal__c, SAC_Pretension__c 
                                                        FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: caseId AND SAC_ReclamantePrincipal__c = true AND (SAC_Pretension__c = null) LIMIT 1];                                  

        if(!reclamantePrincipal.isEmpty()){

            String correoReclamante = '%' + reclamantePrincipal[0].SAC_CorreoElectronico__c + '%';

            listaEmailMessage = [SELECT Id, Subject, ParentId, CreatedDate, FromAddress, ToAddress FROM EmailMessage WHERE ParentId =:caseId AND (ToAddress LIKE :correoReclamante OR FromAddress LIKE :correoReclamante) ORDER BY CreatedDate DESC];

        }

        return listaEmailMessage;
    }

    /*****************************************************************
    * Proposito: Actualiza el campo SAC_ReclamantesConDatosNoAlf__c del caso si es necesario después de eliminar o informar datos no ALF en el reclamante.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US826290      Carlos Gomez   02/06/24        Creación
    *****************************************************************/
    public static void actualizarRecNoAlf(SAC_CaseReclamante__c reclamante) {

        Case caso = [SELECT Id, SAC_ReclamantesConDatosNoAlf__c FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION) AND Id = :reclamante.SAC_Case__c LIMIT 1];

        //Actualizo el caso para ponerle el check.
        if(reclamante.SAC_TieneDatosNoAlf__c == true){
            caso.SAC_ReclamantesConDatosNoAlf__c = true;
        }else if(reclamante.SAC_TieneDatosNoAlf__c == false){
            //Actulizo el caso para quitar el check.
            caso.SAC_ReclamantesConDatosNoAlf__c = false;
        }

        SPV_DatabaseDML.updateDML(caso, true);
    }

    /*****************************************************************
     * Name: InfoReclamantesWrapper
     * Copyright © 2021  CaixaBank
     *                                                                                        
     * Proposito: Clase Wrapper para mandar contenido formateado del controlador Apex al controlador JS para el correcto funcionamiento
     *  del Lightning Web Component: sac_Reclamantes.
     *                                                                                        
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US274749         Raúl Santos    22/09/23       Creación
    *****************************************************************/

    public class InfoReclamantesWrapper{

        @AuraEnabled public List<SAC_CaseReclamante__c> listReclamantes {get; set;}
        @AuraEnabled public List<CC_Caracteristica_Detalle__c> listCaracteristicas {get; set;}

        public InfoReclamantesWrapper(List<SAC_CaseReclamante__c> listReclamantesActual, List<CC_Caracteristica_Detalle__c> listCaracteristicasActual)
        {
            listReclamantes = listReclamantesActual;
            listCaracteristicas = listCaracteristicasActual;
        }
    }

}