public with sharing class SPV_Utils {
    /*
    @description Método para recuperar los record types de un mapa de objetos.
    @param mapObjetos -> Mapa de objetos a obtener los recordTypes.
    @return Mapa con la configuración de de recordTypes obtenidos.
    */
    public static Map<String,Map<String,Schema.RecordTypeInfo>> getRecordTypesObjects(Set<String> setObjetos) {
        
        Map<String,Map<String,Schema.RecordTypeInfo>> mapObjectRT = new Map<String,Map<String,Schema.RecordTypeInfo>>();
        for(String objeto : setObjetos){
            if (String.isNotBlank(objeto) && !mapObjectRT.containsKey(objeto)){
                switch on objeto {
                    when 'Case' {
                        mapObjectRT.put(objeto,Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName());
                    }
                    when 'CC_MCC__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'CC_Grupo_Colaborador__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'CC_Grupo_Colaborador_Contact__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CC_Grupo_Colaborador_Contact__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_Accion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_Interaccion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SPV_Formulario__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_MaestroAccionesReclamacion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_TMECaso__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_MaestroTemas__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName());
                    }
                    
                    //Añadido
                    when 'Account' {
                        mapObjectRT.put(objeto, Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName());
                    }


                }
            }
        }
        return mapObjectRT;
    }

    /**
    Creación del ThreadId
    */
    public static String creacionThreadID(String id){
        String threadId;

        threadId = ('ref:_'+ UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._' + id + ':ref');

        return threadId;
    }

    /**
	 * Método para comprobar en los envios de emails manuales que las direcciones de envio sean válidad (no se encuentren activas en la blackList)
	 */
    public static String comprobarEmailsBlackList(List<SAC_MaestroTemas__c> emailsBlackList, String para, String copia, String copiaOculta) {

        String emails = para + ';' + copia + ';' + copiaOculta;
        List<String> listaEmails = emails.split(';');

		//Si vienen una misma direccion en el para y en el cc o coo, almaceno solo una vez esa direccion
		Set<String> setEmails = new Set<String>();
        for (String email : listaEmails) {
            setEmails.add(email.trim());
        }

		//Iteramos para recuperar los correos únicos de la blackList
        Set<String> emailsNoValidosSet = new Set<String>();
        for (SAC_MaestroTemas__c emailNoValido : emailsBlackList) {
            emailsNoValidosSet.add(emailNoValido.Name);
        }

		//Iterar sobre cada correo electrónico en setEmails y verificar si está presente en la lista de correos electrónicos de la lista negra
        String emailsNoValidosEncontrados = '';
        for (String email : setEmails) { //listaEmails
            if (emailsNoValidosSet.contains(email.trim())) {
				//Si el email está en la lista negra, lo añadimos al string 'emailsNoValidosEncontrados' para devolverlo y mostrarlo por pantalla
                if (emailsNoValidosEncontrados != '') {
                    emailsNoValidosEncontrados += ', ';
                }
                emailsNoValidosEncontrados += email;
            }
        }

		//Devolver una cadena que informa los correos que están en la lista negra y coinciden con los pasados por parámetros
        return emailsNoValidosEncontrados;
    }

    /**
	 * Método para comprobar en los envios de emails automáticos que las direcciones de envio sean válidad (no se encuentren activas en la blackList)
	 */
    public static List<String> comprobarEmailsBlackListAuto(List<SAC_MaestroTemas__c> emailsBlackList, List<String> listEmailsEnviar) {

		//Iteramos para recuperar los correos únicos de la blackList
		Set<String> emailsNoValidosSet = new Set<String>();
		for (SAC_MaestroTemas__c emailNoValido : emailsBlackList) {
			emailsNoValidosSet.add(emailNoValido.Name);
		}

		//Crear una nueva lista para almacenar correos electrónicos válidos
		List<String> filteredEmails = new List<String>();

		//Iterar sobre cada correo electrónico en listEmailsEnviar y verificar si está presente en la lista de correos electrónicos de la lista negra
		if(!listEmailsEnviar.isEmpty()){
			for (String email : listEmailsEnviar) {
				//Si el email no pertenece a la blackList, le añadimos como valido a la lista filteredEmails
				if (!emailsNoValidosSet.contains(email.trim())) {
					filteredEmails.add(email);
				}
			}
		}		
		
		//Devolver la lista de correos electrónicos válidos
		return filteredEmails;
    }
}