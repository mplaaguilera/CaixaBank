/********************************************************************************************************************
 Name:	  AV_CesionPermisos_Controller
 Copyright © 2022  CaixaBank
 ----------------------------------------------------------------------------------------------------------------------
 Proposito: Gives support to AV_OfficeUtility Aura Component and AV_CesionPermisosOficina LWC
 ----------------------------------------------------------------------------------------------------------------------
 Historial
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 VERSION		USER_STORY			AUTHOR				DATE			Description
 1.0			US428379    		Luis Fernandez		13/09/2022		Init version
 1.1			US428379    		Sandra Gómez		05/10/2022		Change sin gestor eap to null
 1.2		    US486147            Patricia Solano	    06/02/2023	    Modify method checkForPermissionGivenToMe to add field for referent agro users
 *********************************************************************************************************************/
public with sharing class AV_CesionPermisos_Controller {
    private final static Integer MAX_RESULTS = 10;
    /**
     * Method that builds the notification of the permission according to the data and the notification type.
     * @param  permiso Permiso to be notified
     * @param isDelete 
     * @param isUpdate
     */
    private static void notifyUsers(AV_OfficePermission__c permiso,Boolean isDelete,Boolean isUpdate){
        String method = 'notifyUsers';
        CustomNotificationType nt= [SELECT ID,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'AV_Permiso_cedido'];
        String cedenteName = [SELECT Name FROM User WHERE Id = :permiso.AV_Assigner__c LIMIT 1].Name;
        Messaging.CustomNotification cn = new Messaging.CustomNotification();
        cn.setNotificationTypeId(nt.Id);
        cn.setTargetId(permiso.Id);
        if(!isDelete && !isUpdate){//Inserción de permiso
            cn.setTitle(cedenteName +' te ha concedido un permiso');
            cn.setBody('Se te ha concedido un permiso desde el ' + formatDate(permiso.AV_InicioPermiso__c) + ' hasta el ' + formatDate(permiso.AV_FinalPermiso__c));
        }else if(isDelete && !isUpdate){//Borrado de permiso
            cn.setTitle(cedenteName +' te ha retirado el permiso');
            cn.setBody('Se te han retirado los permisos de ' + cedenteName + ' sobra la oficina ' + permiso.AV_OficinaCedida__r.Name);
        }else if(!isDelete && isUpdate){//Actualización de permiso
            cn.setTitle(cedenteName +' ha actualizado el periodo de permiso');
            cn.setBody('El nuevo periodo es desde el ' + formatDate(permiso.AV_InicioPermiso__c) + ' hasta el ' + formatDate(permiso.AV_FinalPermiso__c));
        }
        try { 
            cn.send(new Set<String>{permiso.AV_UsuarioCedido__c});
        }catch(Exception e){
            System.debug('Problema');
        }
    }

    /**
     * Returns the formatted date
     *  @param  dateToFormat date to convert
     */
    private static String formatDate(Date dateToFormat){
        return dateToFormat.day() + '/' + dateToFormat.month() + '/' + dateToFormat.year();
    }

    /**
     * Return an string to label the utility bar when this is opened
     */
    @AuraEnabled
    public static String setLabel(){
        return 'Permisos';
    }

    /**
     * Return the employees according to the term introduced in the input
     * @param searchTerm Term to query 
     */
    @AuraEnabled(cacheable=true)
    public static List<AV_LookupSearchResult> searchEmployees(String searchTerm) {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'];
    searchTerm += '*';
    List<AV_OfficePermission__c> repitedUsers = checkForPermissionGivenToUsers(UserInfo.getUserId());
    List<String> selectedIds = new List<String>{UserInfo.getUserId()};
    for(AV_OfficePermission__c perm : repitedUsers){
        selectedIds.add(perm.AV_UsuarioCedido__c);
    }
    List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
    List<List<SObject>> searchResults = new List<List<SObject>>();

        searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                User(Id, Name, AV_NumeroOficinaEmpresa__c  WHERE Id NOT IN :selectedIds and IsActive=true and ProfileId = :p.Id )
            LIMIT :MAX_RESULTS
        ];
    String userIcon = 'standard:user';
    String userCentro = '';
    User[] listUser = (List<User>) searchResults[0];
    for (User u : listUser) {
        if (u.AV_NumeroOficinaEmpresa__c != null && u.AV_NumeroOficinaEmpresa__c.length() >= 5) {
            userCentro = u.AV_NumeroOficinaEmpresa__c.substring(4);
        } else {
            userCentro = u.AV_NumeroOficinaEmpresa__c;
        }
        results.add(
            new AV_LookupSearchResult(
                u.Id,
                'User',
                userIcon,
                u.Name,
                'Centro • ' + userCentro
            )
        );
    }
    results.sort();
    return results;
    }

    /**
     * Return the relevant data from permissions  that has been given by current user
     * @param current user id
     */
    @AuraEnabled
    public static List<AV_OfficePermission__c> checkForPermissionGivenToUsers(Id userId){
        return [SELECT Id,
            AV_UsuarioCedido__c,AV_UsuarioCedido__r.Name,AV_UsuarioCedido__r.AV_NumeroOficinaEmpresa__c,
            AV_ContactoUsuarioCedido__c,
            AV_InicioPermiso__c,
            AV_FinalPermiso__c,
            AV_OficinaCedida__r.CC_Numero_Oficina_Empresa__c
            FROM AV_OfficePermission__c WHERE AV_Assigner__c = :userId AND AV_FinalPermiso__c >= :Date.Today()];
    }

    /**
     * Return relevant data from permissions that has been given to the user
     * @param current user id
     */
    @AuraEnabled
    public static List<AV_OfficePermission__c> checkForPermissionGivenToMe(Id userId){
        return [SELECT Id,
            AV_OficinaCedida__c,
            AV_OficinaCedida__r.Name,
            AV_OficinaCedida__r.CC_Numero_Oficina_Empresa__c,
            AV_OficinaCedida__r.AV_CentroSuperior__c,
            AV_Assigner__c,
            AV_Assigner__r.Name,
            AV_Assigner__r.AV_NumeroOficinaEmpresa__c,
            AV_Assigner__r.AV_Funcion__c,
            AV_Assigner__r.AV_OriginalOfficeNumber__c,
            AV_GestorPermiso__c,
            AV_GestorPermiso__r.Name,
            AV_GestorPermiso__r.AV_CodFuncion__c,
            AV_GestorPermiso__r.AV_Responsabilidad__c,
            AV_InicioPermiso__c,
            AV_FinalPermiso__c 
            FROM AV_OfficePermission__c  WHERE AV_UsuarioCedido__c = :userId AND AV_FinalPermiso__c >= :Date.Today()];
    }

    /**
   * Insert a new permission in the BBDD and sends the correspondent notification
   * @param permisoInfo A map (comes from a JSON) that gives permi labeled information
   * @param destinatario A set with the id of the users that will receive the permission
   * @return A set of BBDD insertion respones 
   */
    @AuraEnabled
    public static List<String> givePermission(Map<String,String> permisoInfo,String[] destinatario){
    String methodName = 'givePermission';
    List<String> response = new List<String>();
    List<Id> destinatarios = new List<Id>();
    List<Contact> gestorOwnerId = [SELECT ID FROM Contact WHERE AV_UsuarioAsociado__c = :permisoInfo.get('Cedente')];
            
    //I look up for contacts of the owners who i am giving permissions
    List<Contact> gestoresCedidos = [SELECT ID,AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c in :destinatario];
    
    Map<String,Contact> destinatariosContact = new Map<String,Contact>();
    //Fill the map with the user associated as a key and the contact object as value
    for(Contact gestor : gestoresCedidos){
        destinatariosContact.put(gestor.AV_UsuarioAsociado__c,gestor);
    }
    //Iterating the users that we are giving permissions. We evaluate if his id is in contacts map
    //If they aren't, it means that the user has not salesforce contact, and in that case we put a 
    //register in the map with his id and the null to contact not link in order to do not let the field remain empty.
    for(String id : destinatario){
        destinatarios.add(id);
        if(!destinatariosContact.keySet().contains(id)){
            destinatariosContact.put(id,null);
        }
    }
    User cedenteInfo = [SELECT Id,AV_OriginalOfficeNumber__c FROM User WHERE Id = :permisoInfo.get('Cedente')];
    String originalNumber = cedenteInfo.AV_OriginalOfficeNumber__c;
    originalNumber = (String.isNotBlank(originalNumber)) ? originalNumber.split(AV_APPConstants.SLASH)[0] : permisoInfo.get('Oficinas');
    List<Account> ofiPermisoId = [SELECT Id FROM Account WHERE CC_Numero_Oficina_Empresa__c = :originalNumber];

    for(String destino : destinatarios){
        AV_OfficePermission__c newPermiso = new AV_OfficePermission__c(
            AV_Assigner__c = (Id) permisoInfo.get('Cedente'),
            AV_UsuarioCedido__c = (Id) destino,
            AV_InicioPermiso__c = Date.parse(permisoInfo.get('Inicio')),
            AV_FinalPermiso__c = Date.parse(permisoInfo.get('Final'))
            );
            if(!ofiPermisoId.isEmpty()) {
                newPermiso.AV_OficinaCedida__c = (Id) ofiPermisoId[0].Id;
                }
            if(!gestorOwnerId.isEmpty() && gestorOwnerId[0] != null) {
                newPermiso.AV_GestorPermiso__c = gestorOwnerId[0].Id;//Esto lo hago por que la mayoría de veces no tendrán.
                }
            if(destinatariosContact.get(destino) != null) {
                newPermiso.AV_ContactoUsuarioCedido__c = (destinatariosContact.get(destino)).Id;
            response.add(insertPermiso(newPermiso));
            }else{
                response.add('NOKCNT');
            }
        }
        return response;
    }

    /**
     * Aux method. It contains the DML instruction and the call to the notification method
     * @param newPermiso Permission to be inserted
     */
    private static String insertPermiso(AV_OfficePermission__c newPermiso){
      String response = 'OK';
      Database.SaveResult sr = Database.insert(newPermiso,true);
      if(sr.isSuccess()) {
        notifyUsers(newPermiso,false,false);
      }
      if(!sr.isSuccess()) {
        response = 'NOK';
      }
      return response;
    }

    /**
     * Retrieve the given permission and executes the DML sentence to Delete the record. Send the notification to the user 
     */
    @AuraEnabled
    public static String deletePermiso(id recordId){
    String response = 'OK';
    AV_OfficePermission__c oldPermiso = [SELECT Id,AV_Assigner__c,AV_Assigner__r.Name,AV_UsuarioCedido__c,AV_OficinaCedida__r.Name 
                                FROM AV_OfficePermission__c WHERE ID = :recordId LIMIT 1];
    Database.DeleteResult sr = Database.delete(recordId,true);
    if(sr.isSuccess()) {
        notifyUsers(oldPermiso,true,false);
    }
    if(!sr.isSuccess()) {
        response = 'NOK';
    }
    return response;
    }
    
    /**
     * Retrieve the given Permission and execute DML sentence to update the relevant Data.Send the notification too
     * @param Permision to be updated ID
     * 
     */
    @AuraEnabled
    public static String actualizarPermiso(Map<String,String> permisos){
        String response = 'OK';
        AV_OfficePermission__c permisoToUpdt= [SELECT AV_Assigner__c,AV_Assigner__r.Name,AV_OficinaCedida__r.Name,AV_UsuarioCedido__c,AV_FinalPermiso__c,AV_InicioPermiso__c 
                                FROM AV_OfficePermission__c WHERE Id = :permisos.get('Id') LIMIT 1];
        permisoToUpdt.AV_InicioPermiso__c = Date.parse(permisos.get('Inicio'));
        permisoToUpdt.AV_FinalPermiso__c = Date.parse(permisos.get('Final'));
        Database.SaveResult sr = Database.update(permisoToUpdt,true);
        if(sr.isSuccess()) {
            notifyUsers(permisoToUpdt,false,true);
        }
        if(!sr.isSuccess()) {
            response = 'NOK';
        }
        return response;
    }
}