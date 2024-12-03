public with sharing class GRR_Identificacion_Auto {

    public static Map<Account, List<Contact>> identificarCliente(String tipo, String valor) {

        //Identificación de clientes
        Map<Account, List<Contact>> resultados = new Map<Account, List<Contact>>();
        
        List<Contact> contactos = new List<Contact>();
        
        if (tipo == 'Email') {
            //Identificación de clientes por correo
            contactos = [SELECT RecordType.DeveloperName, AccountId, Name, Email FROM Contact
                            WHERE RecordTypeId IN :recordTypesContactos() AND Email = :valor];
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

    private static List<Id> recordTypesContactos() {
        List<Id> retorno = new List<Id>();
        retorno.add(null); //Los contactos vinculados a cuentas tipo person account tienen RT vacío
        retorno.add(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'));
        return retorno;
    }
}