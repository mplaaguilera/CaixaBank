public with sharing class OS_Identificacion_Auto {

    public static Map<Account, List<Contact>> identificarCliente(String tipo, String valor, string tipocliente) {

        //Identificación de clientes
        Map<Account, List<Contact>> resultados = new Map<Account, List<Contact>>();
        List<Contact> contactos = new List<Contact>();
        List<Contact> contactosEmpleados = new List<Contact>();
        if (tipo == 'Email') {

            //Identificación de clientes por correo
            contactos = [SELECT RecordType.DeveloperName, AccountId, Account.RecordTypeId, Account.RecordType.DeveloperName, Name, Email FROM Contact
                            WHERE RecordTypeId IN :recordTypesContactos(tipocliente) AND Email = :valor
                              AND Account.RecordTypeId IN :recordTypesAccounts(tipocliente)];

        } else if (tipo == 'Telefono') {
            //Identificación de clientes por teléfono
            Boolean identificacionTelefonoALF = identificacionTelefonoALF();

            if (identificacionTelefonoALF) {
                //Identificación contra ALF (ignora resultados con más de una cuenta)
                List<Account> cuentasALF = (List<Account>)CC_IdentCliente_Future.IdentificarPersALFSync('TEL', valor).get('CUENTAS');
                if (cuentasALF.size() == 1) {
                    contactos = [SELECT RecordType.DeveloperName, AccountId, Account.RecordTypeId, Account.RecordType.DeveloperName, Name, Email FROM Contact
                                    WHERE RecordTypeId IN :recordTypesContactos(tipocliente) AND AccountId = :cuentasALF[0].Id AND CC_Inactivo__c = false]; 
                }
            }
            
            if (!identificacionTelefonoALF || contactos.isEmpty()) {
                //Identificación contra BD (también cuando identificación ALF sin resultados)
                contactos = [SELECT RecordType.DeveloperName, Account.RecordTypeId, AccountId, Account.RecordType.DeveloperName, Name, Phone FROM Contact
                                WHERE RecordTypeId IN :recordTypesContactos(tipocliente) AND (Phone = :valor OR MobilePhone = :valor)
                                 AND Account.RecordTypeId IN :recordTypesAccounts(tipocliente) AND CC_Inactivo__c = false];
            }
            
            if(contactos.isEmpty()){
                //Si no hay contactos con el número de teléfono asociado, se busca entre las Accounts y se pone como contacto al Contact EQUIPO DE SOPORTE asociado.
                contactos = [SELECT RecordType.DeveloperName, Account.RecordTypeId, AccountId, Account.RecordType.DeveloperName, Name, Phone FROM Contact
                                WHERE RecordTypeId IN :recordTypesContactos(tipocliente) 
                                AND (Account.Phone = :valor OR Account.PersonMobilePhone = :valor)
                                AND Account.RecordTypeId IN :recordTypesAccounts(tipocliente) 
                                AND LastName = 'EQUIPO DE SOPORTE' AND CC_Inactivo__c = false];
            }
            
            if(contactos.isEmpty()){
                //Si no hay tampoco contactos con el nombre EQUIPO DE SOPORTE, buscamos entre las Person Accounts
                contactos = [SELECT RecordType.DeveloperName, Account.RecordTypeId, AccountId, Account.RecordType.DeveloperName, Name, Phone FROM Contact
                                WHERE Account.RecordTypeId IN :recordTypesAccounts('cliente')
                                AND (Account.Phone = :valor OR Account.PersonMobilePhone = :valor) AND CC_Inactivo__c = false];
            }
            
        } 
        
        // Recuperar las cuentas de los contactos
        Set<Id> idCuentas = new Set<Id>();
        Set<Id> idCuentasEmpleados = new Set<Id>();
        for (Contact contacto : contactos) {
            //Si es empleado
            if (contacto.RecordTypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado') || 
                    contacto.RecordTypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'OS_Buzon_Contact')) {
                idCuentasEmpleados.add(contacto.AccountId);
                contactosEmpleados.add(contacto);
            }//Si es cliente
            else { 
                idCuentas.add(contacto.AccountId);

            }
            
        }
        //Si lista de empleados no está vacía, se trata (se prioriza identificación de contactos de empleados respecto de clientes)
        if (contactosEmpleados.size()>0 && idCuentasEmpleados.size()>0) { 
            for (Account cuenta : [SELECT RecordType.DeveloperName, Name, OS_Cartera__c FROM Account WHERE Id IN :idCuentasEmpleados]) {
                //Añadimos cada cuenta al mapa con la lista de sus contactos encontrados
                List<Contact> contactosCuenta = new List<Contact>();
                for (Contact contacto : contactosEmpleados) {
                    if (contacto.AccountId == cuenta.Id) {
                        contactosCuenta.add(contacto);
                    }
                }
                resultados.put(cuenta, contactosCuenta);
            }
        }
        else {
            for (Account cuenta : [SELECT RecordType.DeveloperName, Name, OS_Cartera__c FROM Account WHERE Id IN :idCuentas]) {
                //Añadimos cada cuenta al mapa con la lista de sus contactos encontrados
                List<Contact> contactosCuenta = new List<Contact>();
                for (Contact contacto : contactos) {
                    if (contacto.AccountId == cuenta.Id) {
                        contactosCuenta.add(contacto);
                    }
                }
                resultados.put(cuenta, contactosCuenta);
            }
        }     
        return resultados;
    }
   
    private static Boolean identificacionTelefonoALF() {
        Boolean retorno = false;

        if (!Test.isRunningTest()) {
            List<OS_Identificacion_Telefono__mdt> mdt = [SELECT OS_Identificar_Llamada_ALF__c
                                                           FROM OS_Identificacion_Telefono__mdt LIMIT 1];

        if (!mdt.isEmpty() && mdt[0].OS_Identificar_Llamada_ALF__c) {
                retorno = true;
            }
        }
        return retorno;
    }

    @TestVisible
    private static List<Id> recordTypesContactos(string tipocliente) {
        List<Id> retorno = new List<Id>();

        Map<String,Schema.RecordTypeInfo> mapObjectRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();

        if (tipocliente == 'cliente') {
            retorno.add(null);
            retorno.add(mapObjectRT.get('CC_Cliente').getRecordTypeId());
        }
        else if (tipocliente == 'empleado') {
            retorno.add(mapObjectRT.get('CC_Empleado').getRecordTypeId());        
            retorno.add(mapObjectRT.get('OS_Buzon_Contact').getRecordTypeId());
        }
        else {
            retorno.add(null);
            retorno.add(mapObjectRT.get('CC_Cliente').getRecordTypeId());
            retorno.add(mapObjectRT.get('CC_Empleado').getRecordTypeId());        
            retorno.add(mapObjectRT.get('OS_Buzon_Contact').getRecordTypeId());

        }
        return retorno;
    }
    
    @TestVisible 
    private static List<Id> recordTypesAccounts(string tipocliente)  {
        List<Id> retorno = new List<Id>();

        Map<String,Schema.RecordTypeInfo> mapObjectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        
        if (tipocliente == 'cliente') {
            retorno.add(null);
            retorno.add(mapObjectRT.get('CC_Cliente').getRecordTypeId());
            retorno.add(mapObjectRT.get('CC_ClientePA').getRecordTypeId());
        }
        else if (tipocliente == 'empleado') {
            retorno.add(mapObjectRT.get('CC_CentroCaixaBank').getRecordTypeId());
            retorno.add(mapObjectRT.get('OS_Buzon_Account').getRecordTypeId());
        }
        else {
            retorno.add(null);
            retorno.add(mapObjectRT.get('CC_Cliente').getRecordTypeId());
            retorno.add(mapObjectRT.get('CC_CentroCaixaBank').getRecordTypeId());
            retorno.add(mapObjectRT.get('OS_Buzon_Account').getRecordTypeId());
            retorno.add(mapObjectRT.get('OS_Buzon_Account').getRecordTypeId());

        }
        return retorno;
    }

}