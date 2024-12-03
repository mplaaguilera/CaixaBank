/*****************************************************************
 * Name: SAC_InteraccionOperativas_Controller
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Autoasignar los escalados al
 *             usuario que entre dentro del escalado y pertenezca 
 *             al mismo grupo del escalado.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219272         Carlos Solis   12/07/21     Creación
*****************************************************************/
public without sharing class SAC_InteraccionOperativas_Controller {

    public class wrapperInit {
        @AuraEnabled public Boolean mostrarBoton = false;
        @AuraEnabled public SAC_Interaccion__c interaccion = new SAC_Interaccion__c();
    }
    /*****************************************************************
     * Proposito: Recuperar el registro de la Interaccion 
     *            (SAC_Interaccion__c)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   12/07/21     Creación
    *****************************************************************/
    @AuraEnabled
    static public SAC_Interaccion__c recuperarInteraccion(Id interaccionId){
        Id recTypeEscalado = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
        Id recTypeEscaladoNV3 = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_EscaladoNV3').getRecordTypeId();
        Id recTypeConsulta = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        SAC_Interaccion__c interaccion = new SAC_Interaccion__c();
        interaccion = [SELECT id, OwnerId, SAC_GrupoColaborador__c, SAC_Estado__c, SAC_Respuesta__c, RecordTypeId, SAC_GrupoVolverEscalar__c, SAC_EscaladoNV2__c, SAC_EscaladoNV3__c,
                    Name, SAC_CasoEscalado__r.OwnerId, SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId
                    FROM SAC_Interaccion__c
                    WHERE (RecordTypeId = :recTypeEscalado OR RecordTypeId = :recTypeEscaladoNV3 OR RecordTypeId = :recTypeConsulta)
                    AND id = :interaccionId LIMIT 1];
        return interaccion;
    }

    /*****************************************************************
     * Proposito: Asignar al usuario la propiedad de la interaccion, si este
     *            pertenece al grupo donde esta asignada la interaccion
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   12/07/21     Creación
    *****************************************************************/
    @AuraEnabled
    static public void  autoasignarPropiedadInteraccion(Id interaccionId, Id ownerId){
        SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);

        if (interaccion.OwnerId != ownerId)
        { 
            List<CC_Grupo_Colaborador_Contact__c> colabContact = new List<CC_Grupo_Colaborador_Contact__c>();
            colabContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c   //Buscar si el Grupo de la interacción es el mismo del propietario de la interacción
                            FROM CC_Grupo_Colaborador_Contact__c 
                            WHERE CC_Grupo_Colaborador__c=:interaccion.SAC_GrupoColaborador__c and CC_Usuario__c=:interaccion.OwnerId 
                            AND CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion' LIMIT 1];

            if(colabContact.isEmpty())
            {
                colabContact = [SELECT id,CC_Grupo_Colaborador__c,CC_Usuario__c 
                                FROM CC_Grupo_Colaborador_Contact__c //Buscar si el usuario que ejecuta la interacción pertenece al mismo grupo al que pertenece la interacción
                                WHERE CC_Grupo_Colaborador__c=:interaccion.SAC_GrupoColaborador__c 
                                AND CC_Usuario__c=:ownerId AND CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion'];
                              
                if(!colabContact.isEmpty())
                {
                    interaccion.OwnerId = ownerId;
                    Database.update(interaccion);
                }               
            }
            
        }
    }

    /*****************************************************************
     * Proposito: Tomar en propiedad la interacción
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   12/07/21     Creación
    *****************************************************************/
    @AuraEnabled
    public static void tomarPropiedadInteraccion(Id interaccionId, Id idUser){

        SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);
        interaccion.ownerId = idUser;

        Database.update(interaccion);
    }

    /*****************************************************************
     * Proposito: Mostrar el botón de "tomar en propiedad" dependiendo
     *            de si el ususario pertenece al mismo grupo de la interaccion
     *            y si tiene permisos de modificación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   12/07/21     Creación
     * 1.1                             Carlos Solis   06/09/23     Añadido wrapper para devolver el antiguo mostrar boton y el escalado
    *****************************************************************/
    @AuraEnabled
    public static wrapperInit mostrarBoton(Id interaccionId, Id idUser){
        wrapperInit wInit = new wrapperInit();
        Boolean mostrar = false;
        SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);

        if (interaccion.OwnerId != idUser){             
            
            List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
            colabContact = [SELECT id    //Buscar si el Grupo de la interaccion es el mismo del propietario de la interaccion
                            FROM CC_Grupo_Colaborador_Contact__c 
                            WHERE CC_Grupo_Colaborador__c=:interaccion.SAC_GrupoColaborador__c and CC_Usuario__c=:idUser
                            AND (CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion' OR CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_Letrados') LIMIT 1];

            if(!colabContact.isEmpty()){
                mostrar = Schema.SObjectType.SAC_Interaccion__c.isUpdateable(); 
            }
                    
        }
        wInit.mostrarBoton = mostrar;
        wInit.interaccion = interaccion;
        return wInit;
    }


    /***************************************************************************************
     * Proposito: Mostrar el botón de "tomar en propiedad" y Devolver consulta en caso
     *          de que la consulta sea interna, no sea de oficinas y tenga marcado 
     *          el check "Tiene propietario"
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US723790     Sergio Martín   02/04/24        Creación
    ***************************************************************************************/
    @AuraEnabled
    public static Boolean mostrarBotonPropiedadConsultas(Id interaccionId){
        Boolean mostrar = false;
        SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);

        if (Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){      
            //Buscar si el Grupo de la interaccion es el mismo del propietario de la interaccion        
            List<CC_Grupo_Colaborador__c> colabContact= new List<CC_Grupo_Colaborador__c>();
            colabContact = [SELECT id, SAC_Externo__c, SAC_DeveloperName__c, SAC_TienePropietario__c FROM CC_Grupo_Colaborador__c 
                                WHERE Id =: interaccion.SAC_GrupoColaborador__c LIMIT 1];

            if(!colabContact.isEmpty()) {
                if(colabContact[0].SAC_Externo__c == false && colabContact[0].SAC_DeveloperName__c != 'OFICINA' && colabContact[0].SAC_TienePropietario__c == true) {
                    mostrar = true; 
                }
            }
                    
        }
        return mostrar;
    }

    /*****************************************************************
     * Proposito: Devuelve true si el propietario de la interacción es el mismo que el usuario actual
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   12/07/21     Creación
    *****************************************************************/
    @AuraEnabled
    static public boolean esPropietario(Id interaccionId){
        boolean propietario = false;
        String userId = UserInfo.getUserId();
        SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);
        if (interaccion.ownerId == userId) {
            propietario = true;
        }
        return propietario;
    }


    /*****************************************************************
     * Proposito: Devuelve true si la interacción es una consulta
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US560251      Sergio Martín   03/05/23         Creación
    *****************************************************************/
    @AuraEnabled
    static public boolean esConsulta(Id interaccionId){
        boolean consulta = false;
        Id recTypeConsulta = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);
        if (interaccion.RecordTypeId == recTypeConsulta) {
            consulta = true;
        }
        return consulta;
    }

    /*****************************************************************
     * Proposito: Devolver la interaccion para que vuelva a estar pendiente de asignar
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   12/07/21     Creación
    *****************************************************************/
    @AuraEnabled
    static public void devolverInteraccion(Id interaccionId){
        String userId = UserInfo.getUserId();
        SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);

		List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        if(!cola.isEmpty()){
            interaccion.OwnerId = cola[0].id;
        }
		if(Schema.sObjectType.Case.isUpdateable()){   
			Database.update(interaccion);
		}else{
			throw new AuraHandledException('No tienes permisos');
		}
    }

    /*****************************************************************
    * Proposito: Copiar el los archivos adjuntados en el Escalado dentro del caso padre
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US320985         Daniel Benito   10/02/22     Creación
    *****************************************************************/
    @AuraEnabled
    public static void insertarAdjuntoCaso(Id interaccionId){

        SAC_Interaccion__c escalado = [SELECT id,SAC_CasoEscalado__c FROM SAC_Interaccion__C WHERE id =: interaccionId LIMIT 1];

        List<ContentVersion> archivo = [SELECT id,CreatedDate,FirstPublishLocationId,Title,PathOnClient,VersionData FROM ContentVersion WHERE FirstPublishLocationId =: interaccionId ORDER BY CreatedDate DESC];

        ContentVersion newcont = new ContentVersion();
        newcont.Title = archivo[0].Title;
        newcont.PathOnClient = archivo[0].PathOnClient;
        newcont.VersionData = archivo[0].VersionData;
        newcont.FirstPublishLocationId = escalado.SAC_CasoEscalado__c;

        Database.insert(newcont);

    }
    
    /*****************************************************************
    * Proposito: Botón volver a escalar. Está disponible para el letrado cuando se le ha devuelto el escalado
    * nivel 2 y el estado del escalado es devuelto.
    * Vuelve a poner el escalado con el grupo que tenia el escalado en el momento de devolverla.
    * Pone como owner la cola pendiente de asignar. Pone el estado en pendiente respuesta.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US504007         CS             18/09/23     Creación
    *****************************************************************/
    @AuraEnabled
    public static void volverAEscalar(Id interaccionId, String propuestaLet){
        try {
            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];

            SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);

            //Se devuelve al grupo que tenía el escalado y se vuelve a poner en estado pendiente de respuesta y owner la cola pendiente de respuesta.
            interaccion.SAC_Estado__c = 'SAC_PendienteRespuesta';
            interaccion.SAC_Propuesta__c = propuestaLet;
            interaccion.SAC_GrupoColaborador__c = interaccion.SAC_GrupoVolverEscalar__c;
            interaccion.SAC_Conclusion__c = null;
            if (!cola.isEmpty()) {
                interaccion.OwnerId = cola[0].Id;
            }

            Database.update(interaccion);
        } catch (Exception e) {
            CBK_log.error(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************
    * Proposito: Cancela el escalado, llevandolo a estado cancelado. Si el escalado posee un escalado de
    * nivel 2 o nivel 3, este también pasa a estado cancelado ya que se considera que forman parte del mismo escalado.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US504007         CS             18/09/23     Creación
    *****************************************************************/
    @AuraEnabled
    public static void cancelarEscalado(Id interaccionId){
        try {
            List<SAC_Interaccion__c> listaEscaladosUpdatear = new List<SAC_Interaccion__c>();
            SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);
            interaccion.SAC_Estado__c = 'SAC_Cancelado';
            listaEscaladosUpdatear.add(interaccion);

            //Si la interaccion tiene una interaccion de nivel 3 o una de nivel 2, cancelarlas
            if (String.isNotBlank(interaccion.SAC_EscaladoNV2__c)) {
                SAC_Interaccion__c escaladoNV2 = new SAC_Interaccion__c();
                escaladoNV2.Id = interaccion.SAC_EscaladoNV2__c;
                escaladoNV2.SAC_Estado__c = 'SAC_Cancelado';
                listaEscaladosUpdatear.add(escaladoNV2);
            }
            if (String.isNotBlank(interaccion.SAC_EscaladoNV3__c)) {
                SAC_Interaccion__c escaladoNV3 = new SAC_Interaccion__c();
                escaladoNV3.Id = interaccion.SAC_EscaladoNV3__c;
                escaladoNV3.SAC_Estado__c = 'SAC_Cancelado';
                listaEscaladosUpdatear.add(escaladoNV3);
            }
            
            Database.update(listaEscaladosUpdatear);

            //Mandar una notificación de campanita al letrado de la pretensión.
            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
            String recipientId= '';
            String targetId = interaccionId;
            String titulo = 'Escalado cancelado.';
            String contenidoMensaje = 'El escalado ' + interaccion.Name + ' ha sido cancelado.';
            if (String.isNotBlank(interaccion.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId) && interaccion.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId != cola[0].Id) {
                recipientId = interaccion.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId;
            } else if (String.isNotBlank(interaccion.SAC_CasoEscalado__r.OwnerId) && interaccion.SAC_CasoEscalado__r.OwnerId != cola[0].Id) {
                recipientId = interaccion.SAC_CasoEscalado__r.OwnerId;
            }

            if (String.isNotBlank(recipientId)) {
                SAC_Notificacion.enviarNotificacion(recipientId, targetId, titulo, contenidoMensaje);
            }
        } catch (Exception e) {
            CBK_log.error(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**************************************************************************************
     * Proposito: Actualizar el estado de la consulta a pendiente de repuesta definitiva
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US723790     Sergio Martín     02/04/24        Creación
    **************************************************************************************/
    @AuraEnabled
    static public void marcarPendienteRespuestaDefinitiva(Id interaccionId) {
        SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);

        if(interaccion.SAC_Estado__c == 'SAC_Resuelta') {
            interaccion.SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva';
            Database.update(interaccion);
        }
    }
}