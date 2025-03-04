/*****************************************************************
 * Name: SAC_LCMP_Reclamantes
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador del LWC sac_Reclamantes.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            NaN              Carlos Solis   02/02/22     Creación Clase
*****************************************************************/
public without sharing class SAC_LCMP_Reclamantes {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    final static Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    final static Id RECTYPECONSULTACOPS = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    final static Id RECTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();

    /*****************************************************************
    * Proposito: Recupera los reclamantes de una reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            NaN              Carlos Solis   02/02/22     Creación
    * 1.1            US274749         Raúl Santos    22/09/2023   Modificación: recuperar características de un cliente  
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
    * 1.0            NaN              Carlos Solis   02/02/22     Creación
    * 1.1            US826290         Raúl Santos    28/05/24     Modificación: actualizar el campo SAC_ReclamantesConDatosNoAlf__c del caso si es necesario
    * 1.2            US683740         Raúl Santos    04/11/24     Modificación: en consultas SAC, también puede realizar la operativa el letrado
    *****************************************************************/
    @AuraEnabled
    public static void eliminarReclaSecu(String idCaso, String ownerId, String pretPrincipalownerId, String reclamanteId){

        Case caso = [SELECT Id, RecordTypeId, SAC_Letrado__c FROM Case WHERE Id = :idCaso LIMIT 1];

        if(caso.RecordTypeId == RECTYPECONSULTASAC){
            String userName = UserInfo.getName();

            if (!esPropietarioCaso(ownerId, pretPrincipalownerId) && !(caso.SAC_Letrado__c == userName)) {
                throw new AuraHandledException('Debes ser el propietario del caso o propietario letrado para poder realizar la acción');
            }
        }else{
        if (!esPropietarioCaso(ownerId, pretPrincipalownerId)) {
            throw new AuraHandledException('Debes ser el propietario del caso para poder realizar la acción');
        }
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

            SAC_DatabaseDML.deleteDML(reclamanteDelete, true);
        }
    }

    /*****************************************************************
    * Proposito: Comprueba si el nuevo reclamante que se quiere convertir en principal ya tiene 
    * una reclamación abierta que está siendo gestionada por otro owner
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            NaN              Carlos Solis   03/02/22     Creación
    * 1.1            US683740         Raúl Santos    04/11/24     Modificación: en consultas SAC, también puede realizar la operativa el letrado
    *****************************************************************/
    @AuraEnabled
    public static Boolean comprobarMultiplesCasosCliente(String caseId, String ownerId, String pretPrincipalownerId, String reclamanteId){

        Case caso = [SELECT Id, RecordTypeId, SAC_Letrado__c FROM Case WHERE Id = :caseId LIMIT 1];

        if(caso.RecordTypeId == RECTYPECONSULTASAC){
            String userName = UserInfo.getName();

            if (!esPropietarioCaso(ownerId, pretPrincipalownerId) && !(caso.SAC_Letrado__c == userName)) {
                throw new AuraHandledException('Debes ser el propietario del caso o propietario letrado para poder realizar la acción');
            }
        }else{
        if (!esPropietarioCaso(ownerId, pretPrincipalownerId)) {
            throw new AuraHandledException('Debes ser el propietario del caso para poder realizar la acción');
        }
        }
        
        //Recupero el account y el contact del reclamante
        SAC_CaseReclamante__c reclamante = [SELECT Id, SAC_Account__c, SAC_Contact__c FROM SAC_CaseReclamante__c WHERE Id = :reclamanteId];
        //Compruebo si existen casos y lo devuelvo en forma de booleano
        Boolean existenCasos = false;
        //Id userId = UserInfo.getUserId();
        List<Case> casosExistentes = [SELECT Id FROM Case 
                                        WHERE RecordTypeId =: RECTYPERECLAMACION 
                                        AND ((AccountId <> NULL AND AccountId =: reclamante.SAC_Account__c) 
                                        OR (ContactId <> null AND ContactId =: reclamante.SAC_Contact__c)) 
                                        AND (OwnerId <>: ownerId)
                                        AND isClosed = false];

        existenCasos = !casosExistentes.isEmpty() ? true : false;
        return existenCasos;
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
    * 1.0            NaN              Carlos Solis   03/02/22     Creación
    * 1.1            NaN              Sergio Martín  21/03/23     Modificación
    * 1.2            US503998         Sergio Martín  06/11/23     Modificación
    *****************************************************************/
    @AuraEnabled
    public static void cambiarReclaPrincipal(String reclamanteId){
        try {
            SAC_CaseReclamante__c reclamanteActualizar = [SELECT Id, SAC_ReclamantePrincipal__c, SAC_Pretension__c, SAC_Case__c, SAC_Account__c, SAC_Contact__c, SAC_Account__r.CC_Idioma__pc, SAC_Account__r.AV_EAPGestor__r.AccountId  FROM SAC_CaseReclamante__c WHERE Id = :reclamanteId LIMIT 1];
            reclamanteActualizar.SAC_ReclamantePrincipal__c = true;
            SAC_DatabaseDML.updateDML(reclamanteActualizar, true); 

            List<Case> casos = [SELECT Id, AccountId, ContactId, RecordTypeId, SAC_Reclamacion__r.OS_Email__c, SAC_Reclamacion__r.CC_Telefono_Contacto__c, SAC_Reclamacion__r.SAC_DireccionPostalNotificacion__c FROM Case WHERE RecordTypeId IN (:RECTYPERECLAMACION, :RECTYPEPRETENSION, :RECTYPECONSULTASAC, :RECTYPECONSULTACOPS) AND (SAC_Reclamacion__c =: reclamanteActualizar.SAC_Case__c OR Id =: reclamanteActualizar.SAC_Case__c)];
            for(Case caso : casos) {
                if(caso.RecordTypeId == RECTYPEPRETENSION) {
                    caso.AccountId = reclamanteActualizar.SAC_Account__c;
                    caso.ContactId = reclamanteActualizar.SAC_Contact__c;
                    caso.CC_Telefono_Contacto__c = caso.SAC_Reclamacion__r.CC_Telefono_Contacto__c; 
                    caso.OS_Email__c = caso.SAC_Reclamacion__r.OS_Email__c;
                    caso.SAC_DireccionPostalNotificacion__c = caso.SAC_Reclamacion__r.SAC_DireccionPostalNotificacion__c;

                } else if(caso.RecordTypeId == RECTYPERECLAMACION) {
                    // caso.CC_Idioma__c = reclamanteActualizar.SAC_Account__r.CC_Idioma__pc;
                    caso.CC_Oficina__c = reclamanteActualizar.SAC_Account__r.AV_EAPGestor__r.AccountId;
                }
            }
            SAC_DatabaseDML.updateListDML(casos, true); 
            List<SAC_CaseReclamante__c> reclamantesAModificar = [SELECT Id, SAC_Account__c, SAC_Contact__c, SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_ReclamantePrincipal__c = true AND SAC_Case__c in :casos AND Id != :reclamanteId];
            for (SAC_CaseReclamante__c reclamante : reclamantesAModificar) {
                reclamante.SAC_ReclamantePrincipal__c = false;
            }

            SAC_DatabaseDML.updateListDML(reclamantesAModificar, true);
            
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
    * 1.0            NaN              Carlos Solis   04/02/22     Creación
    * 1.1            US826290         Raúl Santos    28/05/24     Modificación: actualizar el campo SAC_ReclamantesConDatosNoAlf__c del caso
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


        SAC_DatabaseDML.updateDML(caso, true);
        SAC_DatabaseDML.deleteListDML(listaReclaEliminar, true);
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
    * 1.0            NaN              Carlos Solis   04/02/22     Creación
    * 1.1            NaN              Sergio Martín  20/04/23     Modificación
    * 1.2            US503998         Sergio Martín  06/11/23     Modificación
    * 1.3            US826290         Raúl Santos    28/05/24     Modificación: actualizar el campo SAC_ReclamantesConDatosNoAlf__c del caso si es necesario
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
        SAC_DatabaseDML.updateDML(reclamanteUpdatear, true);

        SAC_CaseReclamante__c reclamanteActualizar = [SELECT Id, SAC_Account__c, SAC_Contact__c, SAC_Account__r.CC_Idioma__pc, SAC_Account__r.AV_EAPGestor__r.AccountId FROM SAC_CaseReclamante__c WHERE Id = :idReclamanteCambiarAPrincipal LIMIT 1];

        List<Case> casos = [SELECT Id, AccountId, ContactId, RecordTypeId, SAC_Reclamacion__r.OS_Email__c, SAC_Reclamacion__r.CC_Telefono_Contacto__c, SAC_Reclamacion__r.SAC_DireccionPostalNotificacion__c  FROM Case WHERE RecordTypeId IN (:RECTYPERECLAMACION, :RECTYPEPRETENSION) AND (SAC_Reclamacion__c =: caseId OR Id =: caseId)];
        for(Case caso : casos) {
            if(caso.RecordTypeId == RECTYPEPRETENSION) {
                caso.AccountId = reclamanteActualizar.SAC_Account__c;
                caso.ContactId = reclamanteActualizar.SAC_Contact__c;
                caso.CC_Telefono_Contacto__c = caso.SAC_Reclamacion__r.CC_Telefono_Contacto__c; 
                caso.OS_Email__c = caso.SAC_Reclamacion__r.OS_Email__c;
                caso.SAC_DireccionPostalNotificacion__c = caso.SAC_Reclamacion__r.SAC_DireccionPostalNotificacion__c;

            } else if(caso.RecordTypeId == RECTYPERECLAMACION) {
                // caso.CC_Idioma__c = reclamanteActualizar.SAC_Account__r.CC_Idioma__pc;
                caso.CC_Oficina__c = reclamanteActualizar.SAC_Account__r.AV_EAPGestor__r.AccountId;

                if(numRecEliminarDatosNoAlf == numRecDatosNoAlf){
                    caso.SAC_ReclamantesConDatosNoAlf__c = false;
                }
            }
        }
        SAC_DatabaseDML.updateListDML(casos, true);
        
        //Elimino los reclamantes recuperados anteriormente
        SAC_DatabaseDML.deleteListDML(listaReclaEliminar, true);
    }

    /*****************************************************************
    * Proposito: Comprueba si hay algun reclamante secundario en el caso.
    * Si hay reclamantes secundarios, devuelve true. Si no hay, devuelve false
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            NaN              Carlos Solis   03/02/22     Creación
    * 1.1            US683740         Raúl Santos    04/11/24     Modificación: en consultas SAC, también puede realizar la operativa el letrado
    *****************************************************************/
    @AuraEnabled
    public static Boolean tieneReclamanteSecundario(String caseId, String ownerId, String pretPrincipalownerId){
        Case caso = [SELECT Id, RecordTypeId, SAC_Letrado__c FROM Case WHERE Id = :caseId LIMIT 1];

        if(caso.RecordTypeId == RECTYPECONSULTASAC){
            String userName = UserInfo.getName();

            if (!esPropietarioCaso(ownerId, pretPrincipalownerId) && !(caso.SAC_Letrado__c == userName)) {
                throw new AuraHandledException('Debes ser el propietario del caso o propietario letrado para poder realizar la acción');
            }
        }else{
        if (!esPropietarioCaso(ownerId, pretPrincipalownerId)) {
            throw new AuraHandledException('Debes ser el propietario del caso para poder realizar la acción');
        }
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
    * 1.0            NaN              Carlos Solis   02/02/22     Creación
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
    * Proposito: informará datos no alfabetizados asociados a un reclamante
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US826290      Raúl Santos    28/05/24        Creación
    *****************************************************************/
    @AuraEnabled
    public static void informarDatosNoAlf(String idReclamacion, String idReclamante, String emailNoAlf, String tlfNoAlf, String direccionNoAlf) {

        List<SAC_CaseReclamante__c> listRecDatosNoAlf = [SELECT Id, SAC_TieneDatosNoAlf__c, SAC_Case__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c = :idReclamacion];

        if(!listRecDatosNoAlf.isEmpty()){

            SAC_CaseReclamante__c reclamanteAct = new SAC_CaseReclamante__c();
            Boolean otrosRecNoAlf = false;

            for(SAC_CaseReclamante__c reclamante : listRecDatosNoAlf){
                if(reclamante.Id == idReclamante){
                    reclamanteAct = reclamante;
                }else if(reclamante.SAC_TieneDatosNoAlf__c == true){
                    otrosRecNoAlf = true;
                }
            }

            if(reclamanteAct != null){
                reclamanteAct.SAC_EmailNoAlf__c = emailNoalf;
                reclamanteAct.SAC_TelefonoNoAlf__c = tlfNoAlf;
                reclamanteAct.SAC_DireccionNoAlf__c = direccionNoAlf;
        
                if(emailNoAlf != '' || tlfNoAlf != '' || direccionNoAlf != ''){
                    reclamanteAct.SAC_TieneDatosNoAlf__c = true;
                }else{
                    reclamanteAct.SAC_TieneDatosNoAlf__c = false;
                }
        
                SAC_DatabaseDML.updateDML(reclamanteAct, true);
        
                //Si es el único reclamante con datos no ALF, debemos actualizar el campo de la reclamación
                if(otrosRecNoAlf == false){
                    actualizarRecNoAlf(reclamanteAct);
                }        
            }
        }
    }

    /*****************************************************************
    * Proposito: Actualiza el campo SAC_ReclamantesConDatosNoAlf__c del caso si es necesario después de eliminar o informar datos no ALF en el reclamante.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US826290      Raúl Santos    28/05/24        Creación
    *****************************************************************/
    public static void actualizarRecNoAlf(SAC_CaseReclamante__c reclamante) {

        Case caso = [SELECT Id, SAC_ReclamantesConDatosNoAlf__c FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPECONSULTASAC OR RecordTypeId = :RECTYPECONSULTACOPS) AND Id = :reclamante.SAC_Case__c LIMIT 1];

        //Actualizo el caso para ponerle el check.
        if(reclamante.SAC_TieneDatosNoAlf__c == true){
            caso.SAC_ReclamantesConDatosNoAlf__c = true;
        }else if(reclamante.SAC_TieneDatosNoAlf__c == false){
            //Actulizo el caso para quitar el check.
            caso.SAC_ReclamantesConDatosNoAlf__c = false;
        }

        SAC_DatabaseDML.updateDML(caso, true);
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