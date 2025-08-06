public with sharing class SACH_Identificacion_Auto {

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

        if (!Test.isRunningTest()) {
            List<SACH_Identificacion_Telefono__mdt> mdt = [SELECT SACH_Identificar_Llamada_ALF__c
                                                            FROM SACH_Identificacion_Telefono__mdt LIMIT 1];
            if (!mdt.isEmpty() && mdt[0].SACH_Identificar_Llamada_ALF__c) {
                retorno = true;
            }
        }
        return retorno;
    }

    private static List<Id> recordTypesContactos() {
        List<Id> retorno = new List<Id>();
        retorno.add(null); //Los contactos vinculados a cuentas tipo person account tienen RT vacío
        retorno.add(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'));
        return retorno;
    }

    public static Contact identificarNUMPERSOsinCodificar(String numPersoFormat){
        
        Id clientePAId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();  //Cliente Físico
        Id clienteId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();        //Cliente Juridico

        //Primero buscamos en los Contactos si son de tipo Cliente o Cliente PA
        List<Contact> contactos = [SELECT AccountId FROM Contact
                                                    WHERE (RecordTypeId = :clienteId OR Account.RecordTypeId = :clientePAId)
                                                    AND AV_NumPerso__c = :numPersoFormat];

        if(!contactos.isEmpty()){
            return contactos[0];
        }else{
            //Buscamos el primer contacto asociado al cliente jurídico
            List<Account> cuentas = [SELECT Id FROM Account WHERE RecordTypeId = :cliente AND AV_NumPerso__c = :numPersoFormat LIMIT 1];
            if(!cuentas.isEmpty()){
                List<Contact> miscontactos = [SELECT Id FROM Contact WHERE AccountId = :cuentas[0].Id AND CC_Inactivo__c = false LIMIT 1];
                if(!miscontactos.isEmpty()){
                    return miscontactos[0];
                }
            }
        }
        return null;

    }


    public static String formatearNumperso(String texto) {
        try {
            if (String.isBlank(texto)) {
                return '';
            } else {
                Map<String, Integer> mapa = new Map<String, Integer>();
                mapa.put('0', 0);
                mapa.put('1', 1);
                mapa.put('2', 2);
                mapa.put('3', 3);
                mapa.put('4', 4);
                mapa.put('5', 5);
                mapa.put('6', 6);
                mapa.put('7', 7);
                mapa.put('8', 8);
                mapa.put('9', 9);
                mapa.put('A', 10);
                mapa.put('B', 11);
                mapa.put('C', 12);
                mapa.put('D', 13);
                mapa.put('E', 14);
                mapa.put('F', 15);
                mapa.put('a', 10);
                mapa.put('b', 11);
                mapa.put('c', 12);
                mapa.put('d', 13);
                mapa.put('e', 14);
                mapa.put('f', 15);

                Double retorno = 0;
                for (Integer i = 0; i < texto.length(); i++)  {
                    retorno += (mapa.get(texto.substring(i, i + 1)) * Math.pow(16, texto.length() - (i + 1))) ;
                }
                //El numperso retornado puede tener un número diferente de 8 caracteres. Si tiene menos caracteres, no están guardados con 0 delante
                //return String.valueOf(Integer.valueOf(retorno)).leftPad(8, '0');
                return String.valueOf(Integer.valueOf(retorno));
            }
        } catch (Exception e) {
            return null;
        }
    }

    
}