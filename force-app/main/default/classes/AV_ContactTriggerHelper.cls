/**********************************************************************************************************************
 Name:	  AV_ContactTriggerHelper
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Contact.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US208429		Víctor Santiago		23/04/2021			Init version
    1.1			US208429		Jash				03/05/2021			Custom Metadata mapping added to getUpdatedFuncion
	1.2			FIX				David Rufo			19/05/2021			Fixed query loop problem
	1.3			FIX				David Rufo			09/06/2021			public method to update the function user from user trigger
	1.4			DE49047			David Rufo			28/06/2021			update bulk change data
    1.5		    AV_Query IT	    Daniel Rodríguez	09/02/2022	        Change AV_Query to SOQL for User, Account, Contact
    1.6         US394910        Alex Campos         27/06/2022          Added CIBE_Centro__c y CIBE_Cargo to updateUserFuncion
	1.7			US3736884		Vladislav Lityagin	15/11/2022			Modified updateUserFuncion adding if changed AV_EmpleadoIntouch__c
    1.8			US590740		Lucía Muñoz		    08/06/2023			New methods updateContactMatriculaInvalid, tieneUsuario
    1.9         US586011        Luis Fernández      13/06/2023          Added procesBPRRole to redirecto UserTrigger
    1.10        US599950        Alex Perez          21/06/2023          Added AV_TipoGestor__c    
    1.11        IN1098585       Elisabeth R.        06/03/2024          Update CC_Inactivo__c to false value  
    1.12        US912548        Oscar Moreno        10/06/2024          Add  codFuncion parameter of getupdatedFuncion
    1.13        FIX             Gonzalo Ávila       11/06/2024          The updateContactMatriculaInvalid method is modified by changing the way nulls are controlled
    1.14        PPM100492394    Ángel Medina        17/09/2024          New methods employeeExists and isPoolContact
***********************************************************************************************************************/
public with sharing class AV_ContactTriggerHelper {
    
    private static AV_AppUtilities.SearchRT employee 	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_CONTACT, 'CC_Empleado');
    private static Recordtype apoderadoRt 								= AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, 'CIBE_Apoderado');
    private static Recordtype contactoComercialRt 						= AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, 'CIBE_ContactoComercial'); 
    private static Set<Id> setRtAll 		= getAllRT();
    private static Set<Id> setRtEmployee 	= getIdsRT(new Set<AV_AppUtilities.SearchRT>{employee});
    
    /**
	 * @description		 	Check the record types
	 * @param listNews  	list of new records
	 */
    public static List<Contact> checkGeneralRT(List<Contact> listNews){
        List<Contact> listData = new List<Contact>();
        for(Contact dataNew : listNews){
            if((setRtAll).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
            }
        }
        return listData;
    }
    
    /**
	 * @description		 	Check the cibe record types
	 * @param listNews  	list of new records
	 */
    public static List<Contact> checkCibeRTs(List<Contact> listNews){
        List<Contact> listData = new List<Contact>();
        for(Contact dataNew : listNews){
            if(dataNew.RecordTypeId == apoderadoRt.Id || dataNew.RecordTypeId == contactoComercialRt.Id){
				listData.add(dataNew);
            }
        }
        return listData;
    }
    
    /**
	 * @description		 	Get all the ID's of the RT
	 */
    public static Set<Id> getAllRT(){
        Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{employee};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
    }
        
    /**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
    public static Set<Id> getIdsRT(Set<AV_AppUtilities.SearchRT> setRT){
        return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
    }
    
    /**
     * Check whether AV_JobLevels__c has been updated. If so, updates user's AV_Funcion__c.
     */
    public static void updateUserFuncion(List<Contact> listNewObj, Map<Id, Contact> mapOldObj) {
        String methodName = 'updateUserFuncion';
        List<User> usersToUpdate = new List<User>();
        List<User> psUsersToUpdate = new List<User>();
        Set<String> usersIds = getIds(listNewObj);
        Map<Id, Contact> mapContactUser = getContactExtraData(usersIds);
        Map<String, String> mapTipoCentroFuncion = getAllJobLevelFunctions();
        for (Contact contact : listNewObj) {
            if (setRtEmployee.contains(contact.RecordTypeId) &&
                	mapContactUser.get(contact.Id).AV_UsuarioAsociado__c!=null &&
                    (contact.AV_JobLevels__c != mapOldObj.get(contact.Id).AV_JobLevels__c 
                     || contact.AV_UsuarioAsociado__c != mapOldObj.get(contact.Id).AV_UsuarioAsociado__c 
                     || contact.AccountId != mapOldObj.get(contact.Id).AccountId
                     || contact.AV_DescFuncion__c != mapOldObj.get(contact.Id).AV_DescFuncion__c
                     || contact.AV_EmpleadoIntouch__c != mapOldObj.get(contact.Id).AV_EmpleadoIntouch__c
                     || contact.AV_TipoGestor__c != mapOldObj.get(contact.Id).AV_TipoGestor__c
                     || contact.CIBE_Manager__c != mapOldObj.get(contact.Id).CIBE_Manager__c
                     || contact.AV_CodFuncion__c != mapOldObj.get(contact.Id).AV_CodFuncion__c)) {  
                     
				//AV_LogDebug.printLogDebug(methodName, 'JobLevel: ' + contact.AV_JobLevels__c);
                //AV_LogDebug.printLogDebug(methodName, 'TipoCentro: ' + contact.AV_TipoCentro__c);

                User updatedUser = new User();
                updatedUser.Id = mapContactUser.get(contact.Id).AV_UsuarioAsociado__c;
                updatedUser.AV_Funcion__c = getUpdatedFuncion(contact.AV_JobLevels__c, contact.AV_TipoCentro__c, mapTipoCentroFuncion,contact.AV_CodFuncion__c); 
                updatedUser.AV_NumeroOficinaEmpresa__c = mapContactUser.get(contact.Id).Account.CC_Numero_Oficina_Empresa__c;
                updatedUser.CIBE_FuncionEmpleado__c = mapContactUser.get(contact.Id).AV_DescFuncion__c;
                updatedUser.CIBE_Centro__c = mapContactUser.get(contact.Id).Account.Name;
                updatedUser.AV_TipoGestor__c = contact.AV_TipoGestor__c;
                updatedUser.CIBE_Manager__c = contact.CIBE_Manager__c;
                
                AV_LogDebug.printLogDebug(methodName, 'Numero Oficina Empresa: ' + updatedUser.AV_NumeroOficinaEmpresa__c);
                
                AV_LogDebug.printLogDebug(methodName, 'User info to update: ' + updatedUser);
                usersToUpdate.add(updatedUser);
                
                Boolean updatedPS = contact.AV_JobLevels__c != mapOldObj.get(contact.Id).AV_JobLevels__c;
                AV_LogDebug.printLogDebug(methodName, 'Update joblevel?: ' + updatedPS);
                if (updatedPS){
                	psUsersToUpdate.add(updatedUser);             
                }
			}
        }

		//Update info user
        if (usersToUpdate != null && !usersToUpdate.isEmpty()) {
			List<Database.SaveResult> listResult = Database.update(usersToUpdate, false);
            AV_AppUtilities.displayErrors(methodName, listResult);
		}
        
        //Update the permission set of the user
        if (System.isFuture() && psUsersToUpdate != null && !psUsersToUpdate.isEmpty()) {
			AV_UserTriggerHelper.permissionUser(psUsersToUpdate);
		}
    }
    
    /**
	 * @description		 	get the contact's ids
	 * @param  listNewObj  	list of user data that execute the process
	 * @return		Set the data with the external ID's or null if the external ID of the user is empty
	 */
	private static Set<String> getIds(List<Contact> listNewObj) {
		Set<String> ids = new Set<String>();
		for (Contact c : listNewObj) {
			ids.add(c.Id);
		}
		return ids;
	}

    /**
     * @description Gets contact's related user and updates its AV_Funcion__c accordingly,
     * then returns it.
     * @param jobLevel 
     * @param tipoCentro 
     * @param mapTipoCentroFuncion 
     * @return User with updated AV_Funcion__c
     */
    public static String getUpdatedFuncion(String jobLevel, String tipoCentro, Map<String, String> mapTipoCentroFuncion,String codFuncion) {    
        List<String> centrosInmutables = new List<String> {'SSCC', 'DT', 'DC', 'DAN'};
        
        String funcion = mapTipoCentroFuncion.get(tipoCentro);
        String codEmpleado = '50408562';
        if('Oficina'.equalsIgnoreCase(funcion)){
            if(String.isNotBlank(jobLevel)){
                if (Integer.valueOf(jobLevel) <= 120 && codEmpleado.equals(codFuncion)) {
                    funcion = 'Gestor';
                } else {
                    funcion = Integer.valueOf(jobLevel) <= 120 ? 'Oficina' : 'Gestor';
                }
            }else{
                funcion ='Gestor';
            }
        }
        
        return funcion;
    }
    
    public static Map<String, String> getAllJobLevelFunctions(){
        Map<String, String> result = new Map<String, String>();
        List<AV_Map_TipoCentro_Funcion__mdt> listTipoCentroFuncion = [Select Id, 
        DeveloperName, 
        MasterLabel, 
        Language, 
        Label, QualifiedApiName, AV_Tipo_Centro__c, AV_Funcion_Usuario__c From AV_Map_TipoCentro_Funcion__mdt];
        /*List<AV_Map_TipoCentro_Funcion__mdt> listTipoCentroFuncion = new AV_Query('AV_Map_TipoCentro_Funcion__mdt')
                        .selectFields('Id, DeveloperName, MasterLabel, Language, Label, QualifiedApiName, AV_Tipo_Centro__c, AV_Funcion_Usuario__c')
                        .run();*/
        
        for(AV_Map_TipoCentro_Funcion__mdt aux : listTipoCentroFuncion){
            result.put(aux.AV_Tipo_Centro__c, aux.AV_Funcion_Usuario__c);
        }
        
        return result;
    }

    /**
     * Returns a Map with contacts's Id and their related user's Id.
     */
    private static Map<Id, Contact> getContactExtraData(Set<String> contactIds) {
        Map<Id, Contact> contactUser = new Map<Id, Contact>();
        List<Contact> usuariosAsociadosContact= [Select Id, AV_UsuarioAsociado__c, CC_Matricula__c, AccountId, Account.Name, Account.CC_Numero_Oficina_Empresa__c, AV_DescFuncion__c From Contact Where Id in :contactIds];
        /*List<Contact> usuariosAsociadosContact = new AV_Query('Contact')
                            .selectFields('Id, AV_UsuarioAsociado__c, CC_Matricula__c, AccountId, Account.CC_Numero_Oficina_Empresa__c')
                            .addConditionIn('Id', contactIds)
                            .run();*/

        for (Contact c : usuariosAsociadosContact) {
            contactUser.put(c.Id, c);
        }

        return contactUser;
    }


    public static void processBPRRole(List<Contact> listNewObj, Map<Id, Contact> mapOldObj){
        String BPR = AV_AppConstants.BPRROL;
        Set<String> userToUpdate = new Set<String>();
        for(Contact cnt : listNewObj){
            if(cnt.AV_UsuarioAsociado__c != null ){

                String oldRol = mapOldObj.get(cnt.Id).AV_Rol__c;
                
                if( ((cnt.AV_Rol__c != oldRol)) && (
                    (cnt.AV_Rol__c != null && cnt.AV_Rol__c.equalsIgnoreCase(BPR) ) || (oldRol != null && oldRol.equalsIgnoreCase(BPR)))
                    ) {//Evaluamos si han actualizado el rol
                        userToUpdate.add(cnt.AV_UsuarioAsociado__c);
                    }
                }
            }
            if(!userToUpdate.isEmpty()){
                List<User> usersToUpdateList = [SELECT Id,AV_NotGrantPermissionSet__c,AV_Funcion__c,Email,AV_ExternalID__c,isActive,AV_DeactiveAutoPS__c,AV_ProfileName__c FROM User WHERE Id IN :userToUpdate];
            AV_UserTriggerHelper.permissionUser(usersToUpdateList);
        }

    
    }

     /**
    * Al actualizar un contacto, si en la matricula tiene _inavalid, el campo CC_Inactivo__c marcarlo como true, 
    * si tiene usuario asociado, el campo isActive sera false.
    */
    public static void updateContactMatriculaInvalid(List<Contact> contacts){
        try {
            List<String> usuariosAsociados = new List<String>();
            if (contacts != null && !contacts.isEmpty()) {
                for (Contact c : contacts) {
                    if (c.CC_Matricula__c != null && c.CC_Matricula__c.containsIgnoreCase('Invalid')) {
                        if (c.AV_UsuarioAsociado__c != null) {
                            c.CC_Inactivo__c = true;
                            usuariosAsociados.add(c.AV_UsuarioAsociado__c);
                            c.AV_UsuarioAsociado__c = null;
                        } else {
                            c.CC_Inactivo__c = true;
                        }
                    } else {
                        c.CC_Inactivo__c = false;
                    }
                }
            }
            

           if(!usuariosAsociados.isEmpty() && !contacts.isEmpty() && Schema.sObjectType.Contact.isUpdateable() && Schema.sObjectType.User.isUpdateable()) {
               tieneUsuario(usuariosAsociados);
           }
        } catch (System.NullPointerException e) {
            CBK_Log.error(e);
        }
        

      
    }

    @future
	public static void tieneUsuario(List<String> usuariosAsociados){
        
		if(!usuariosAsociados.isEmpty()) {
			List<User> usuario = new List<User>();
            if(Schema.sObjectType.User.isAccessible() && Schema.SObjectType.User.fields.isActive.isAccessible() && Schema.SObjectType.User.fields.Id.isAccessible()) {
                usuario = [SELECT Id, isActive FROM User WHERE Id  =: usuariosAsociados];
            }
            
            for(User u : usuario){
                u.isActive = false; 
            }
            
            if(!usuario.isEmpty() && Schema.sObjectType.User.isUpdateable()) {
                Database.SaveResult[] updates = Database.update(usuario, false);

                boolean hasError = false;
                List<Object> objs = new List<Object>();
                Map<String, String> msjs = new Map<String, String>();
                for (Integer i = 0; i < usuario.size(); i++) {
                    Database.SaveResult dr = updates[i];
                    if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                        msjs.put(usuario[i].Id, ((String)dr.getErrors()[0].getMessage()));
                        objs.add(usuario[i]);
                        hasError = true;
                    }
                }
                if(hasError) {
                    CBK_Log.error(msjs, objs);
                }
            }
        }
	}
    
     /**
    * Metodo de utilidad para rellenar los campos de telefono 
    * si tiene usuario asociado, el campo isActive sera false.
    */
    public static void migrateApoderados(List<Contact> contacts){
        Boolean noEmpresa = false;
        Boolean fijoEmpresa = false; 
        String phoneAux;
        for(Contact cont: contacts){
            if((cont.RecordtypeId == apoderadoRt.Id || cont.RecordtypeId == contactoComercialRt.Id) && String.isBlank(cont.phone)){
                for(Integer i = 1; i <= 10; i++){
                    if( !String.isBlank(String.valueOf(cont.get('CIBE_Telefono'+ i + '__c'))) &&   String.valueOf(cont.get('CIBE_CategoriaTelefono'+ i + '__c')) == '2'
                         && String.valueOf(cont.get('CIBE_TipoTelefono'+ i + '__c')) == '006'){
                        phoneAux =   String.valueOf(cont.get('CIBE_Telefono'+ i + '__c'));
                        break;
                    }
                    else if( !String.isBlank(String.valueOf(cont.get('CIBE_Telefono'+ i + '__c'))) &&   String.valueOf(cont.get('CIBE_CategoriaTelefono'+ i + '__c')) == '2' 
                            && String.valueOf(cont.get('CIBE_TipoTelefono'+ i + '__c')) == '001'  && !fijoEmpresa){
                        phoneAux =   String.valueOf(cont.get('CIBE_Telefono'+ i + '__c'));
                        fijoEmpresa = true;
                    }
                    else if( !String.isBlank(String.valueOf(cont.get('CIBE_Telefono'+ i + '__c'))) && String.valueOf(cont.get('CIBE_CategoriaTelefono'+ i + '__c')) == '1'  && 
                            (String.valueOf(cont.get('CIBE_TipoTelefono'+ i + '__c')) == '001' ||   String.valueOf(cont.get('CIBE_TipoTelefono'+ i + '__c')) == '006') && !noEmpresa && !fijoEmpresa){
                        phoneAux =   String.valueOf(cont.get('CIBE_Telefono'+ i + '__c'));
                        noEmpresa = true;
                    }
                }
                cont.phone = cont.phone != null ? cont.Phone : phoneAux;
                phoneAux = null;
                noEmpresa = false;
        		fijoEmpresa = false;
            }   
        }      
    }



    public static void employeeExists(List<Contact> listNewObj){
        Map<String, Contact> matriculaToContactMap = new Map<String, Contact>();

        for(Contact contact : listNewObj){
            if(contact != null && contact.CC_Matricula__c != null){
                matriculaToContactMap.put(contact.CC_Matricula__c, contact);
            }
        }

        if(!matriculaToContactMap.isEmpty()){
            List<User> users = [SELECT Id, AV_ExternalID__c FROM User WHERE AV_ExternalID__c IN :matriculaToContactMap.keySet()];
            if(users != null && !users.isEmpty()){
                for(User user : users){
                    if(user.AV_ExternalID__c != null && matriculaToContactMap.containsKey(user.AV_ExternalID__c)){
                        matriculaToContactMap.get(user.AV_ExternalID__c).AV_UsuarioAsociado__c = user.Id;
                    }
                }
            }
        }
    }

    public static void isPoolContact(List<Contact> listNewObj, Map<Id, Contact> mapOldObj){
        List<User> usersToUpdate = new List<User>();
        Map<Id, Contact> contactWithUser = new Map<Id, Contact>();
        Set<Id> accountIds = new Set<Id>();
    
        for(Contact newContact : listNewObj){
            Contact oldContact = (mapOldObj != null) ? mapOldObj.get(newContact.Id) : null;

            if (oldContact == null || oldContact.AV_Pool__c != newContact.AV_Pool__c) {
    
                if (newContact.AV_UsuarioAsociado__c != null) {
                    contactWithUser.put(newContact.AV_UsuarioAsociado__c, newContact);

                    if (oldContact == null && newContact.AccountId != null) {
                        accountIds.add(newContact.AccountId);
                    }
                }
            }
        }
    
        if (!contactWithUser.isEmpty()) {
            Map<Id, Account> accountsMap = new Map<Id, Account>();
            if (!accountIds.isEmpty()) {
                accountsMap = new Map<Id, Account>([
                    SELECT Id, CC_Numero_Oficina_Empresa__c FROM Account WHERE Id IN :accountIds
                ]);
            }
            List<User> relatedUser = [SELECT Id, AV_Pool__c, AV_NumeroOficinaEmpresa__c FROM User WHERE Id IN :contactWithUser.keySet() AND AV_ProfileName__c = :AV_AppConstants.AV_PROFILE];
    
            if (relatedUser != null && !relatedUser.isEmpty()) {
                for (User user : relatedUser) { 
                    if (contactWithUser.get(user.Id) != null && user.AV_Pool__c != contactWithUser.get(user.Id).AV_Pool__c) {
                        user.AV_Pool__c = contactWithUser.get(user.Id).AV_Pool__c;
                    }
                    
                    if (mapOldObj == null || mapOldObj.get(contactWithUser.get(user.Id).Id) == null) { 
                        if (contactWithUser.get(user.Id).AccountId != null && accountsMap.containsKey(contactWithUser.get(user.Id).AccountId)) {
                            Account relatedAccount = accountsMap.get(contactWithUser.get(user.Id).AccountId);
                            if (relatedAccount.CC_Numero_Oficina_Empresa__c != null) {
                                user.AV_NumeroOficinaEmpresa__c = relatedAccount.CC_Numero_Oficina_Empresa__c;
                            }
                        }
                    }
                    usersToUpdate.add(user);
                }
            }
        }
        if (!usersToUpdate.isEmpty()) {
            Database.update(usersToUpdate,true);
        }
    }
    
}