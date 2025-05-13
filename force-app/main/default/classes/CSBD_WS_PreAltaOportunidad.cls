// @RestResource(urlMapping='/PreAltaOportunidad/*')
public with sharing class CSBD_WS_PreAltaOportunidad extends CBK_HttpServiceIntegration_Abstract {


    public with sharing class Output {
        public String referenciaUsuario {get;set;}
        public String resultado {get;set;}
        public String codigoError {get;set;}
        public String detalleError {get;set;}
        public String opportunityId {get;set;}
        public String opportunityNumero {get;set;}
        public String detalleOportunidad {get;set;}
    }


    // @HttpGet
    public static Output preAltaOportunidad() {
        Output output = new Output();
        output.referenciaUsuario =  UUID.randomUUID().toString();
        output.resultado = 'OK';
        output.codigoError = '0';
        output.detalleError = null;
        output.opportunityId = null;
        output.opportunityNumero = null;
        output.detalleOportunidad = null;
        return output;

        Contact empleado = [SELECT AccountId, Name, Phone FROM Contact
                            WHERE Account.RecordType.DeveloperName = 'CC_CentroCaixaBank' AND RecordType.DeveloperName = 'CC_Empleado'
                            AND (Phone = :valor OR MobilePhone = :valor) AND CC_Inactivo__c = false LIMIT 1];

    // Recuperar las cuentas de los contactos
    Set<Id> idCuentas = new Set<Id>();
    Set<Id> idCuentasEmpleados = new Set<Id>();
    for (Contact contacto : contactos) {
        idCuentasEmpleados.add(contacto.AccountId);
        contactosEmpleados.add(contacto);
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
}