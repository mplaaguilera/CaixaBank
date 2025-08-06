public with sharing class HDT_Identificacion_Auto {

    public static Map<Account, List<Contact>> identificarCliente(String tipo, String valor) {

        //Identificación de clientes
        Map<Account, List<Contact>> resultados = new Map<Account, List<Contact>>();
        
        List<Contact> contactos = new List<Contact>();
        
        if (tipo == 'Email') {
            //Identificación de clientes por correo
            contactos = [SELECT RecordType.DeveloperName, AccountId, Name, Email FROM Contact
                            WHERE RecordTypeId IN :recordTypesContactos() AND Email = :valor];

        } else if (tipo == 'Telefono') {
            
            //Identificación de clientes por teléfono
            Boolean identificacionTelefonoALF = identificacionTelefonoALF();

            if (identificacionTelefonoALF) {
                //Identificación contra ALF (ignora resultados con más de una cuenta)
                List<Account> cuentasALF = (List<Account>)CC_IdentCliente_Future.IdentificarPersALFSync('TEL', valor).get('CUENTAS');
                if (cuentasALF.size() == 1) {
                    contactos = [SELECT RecordType.DeveloperName, AccountId, Account.RecordType.DeveloperName, Name, Email FROM Contact
                                    WHERE RecordTypeId IN :recordTypesContactos() AND AccountId = :cuentasALF[0].Id];
                }
            }

            if (!identificacionTelefonoALF || contactos.isEmpty()) {
                //Identificación contra BD (también cuando identificación ALF sin resultados)
                contactos = [SELECT RecordType.DeveloperName, AccountId, Account.RecordType.DeveloperName, Name, Phone FROM Contact
                                WHERE RecordTypeId IN :recordTypesContactos() AND (Phone = :valor OR MobilePhone = :valor)];
            }
        } 
        
        //Recuperar las cuentas de los contactos
        Set<Id> idCuentas = new Set<Id>();
        for (Contact contacto : contactos) {
            idCuentas.add(contacto.AccountId);
        }
        
        for (Account cuenta : [SELECT RecordType.DeveloperName, Name FROM Account WHERE Id IN :idCuentas]) {
            //Añadimos cada cuenta al mapa con la lista de sus contactos encontrados
            List<Contact> contactosCuenta = new List<Contact>();
            for (Contact contacto : contactos) {
                if (contacto.AccountId == cuenta.Id) {
                    contactosCuenta.add(contacto);
                }
            }
            resultados.put(cuenta, contactosCuenta);
        }
        return resultados;
    }
    
    private static Boolean identificacionTelefonoALF() {
        Boolean retorno = false;
		/*
        if (!Test.isRunningTest()) {
            List<HDT_Identificacion_Telefono__mdt> mdt = [SELECT HDT_Identificar_Llamada_ALF__c
                                                            FROM HDT_Identificacion_Telefono__mdt LIMIT 1];
            if (!mdt.isEmpty() && mdt[0].HDT_Identificar_Llamada_ALF__c) {
                retorno = true;
            }
        }*/
        return retorno;
    }

    private static List<Id> recordTypesContactos() {
        List<Id> retorno = new List<Id>();
        retorno.add(null); //Los contactos vinculados a cuentas tipo person account tienen RT vacío
        retorno.add(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado'));
        return retorno;
    }
}