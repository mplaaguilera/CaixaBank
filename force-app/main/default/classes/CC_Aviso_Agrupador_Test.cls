@isTest
public class CC_Aviso_Agrupador_Test {
	@isTest
    public static void publicarEventoDeAviso() {
        
        //Alta de datos para la prueba
        CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores.CC_Activa__c = true;
        lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
        insert lovAvisosSobreAgrupadores;
        List<CC_Lista_Valores__c> valorUmbralInsert = new List<CC_Lista_Valores__c>();
        for (String recordTypeDeveloperName : new List<String> {'CC_Comunicacion_Informativa', 'CC_Comunicacion_Informativa_de_Campana', 'CC_Incidencia', 'CC_Seguimiento', 'CC_Masiva_Control'}) {
            CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
            valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralPrimerAviso.CC_Activa__c = true;
            valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral primer aviso';
            valorUmbralPrimerAviso.CC_Valor__c = '2';
            valorUmbralInsert.add(valorUmbralPrimerAviso);
            CC_Lista_Valores__c valorUmbralSiguientesAvisos = new CC_Lista_Valores__c();
            valorUmbralSiguientesAvisos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralSiguientesAvisos.CC_Activa__c = true;
            valorUmbralSiguientesAvisos.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralSiguientesAvisos.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral siguientes avisos';
            valorUmbralSiguientesAvisos.CC_Valor__c = '50';
            valorUmbralInsert.add(valorUmbralSiguientesAvisos);
    	}
    	insert valorUmbralInsert;
        Map<String, String> mapNamesDeveloper = new Map<String, String>();
        List<CC_Agrupador__c> agrupadoresInsert = new List<CC_Agrupador__c>();
        List<String> recordDeveloperNames = new List<String> {'CC_Comunicacion_Informativa', 'CC_Comunicacion_Informativa_de_Campana', 'CC_Incidencia', 'CC_Seguimiento', 'CC_Masiva_Control'};
        Set<String> setRecordNames = new Set<String>();
        for (String recordDeveloperName : recordDeveloperNames) {
            String name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordDeveloperName);
            mapNamesDeveloper.put(name + ' - Umbral primer aviso', recordDeveloperName);
            setRecordNames.add(name + ' - Umbral primer aviso');
        }
        
        List<CC_Lista_Valores__c> valores = [SELECT CC_Valor__c, Name FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Avisos sobre agrupadores' AND Name IN :setRecordNames  WITH SECURITY_ENFORCED];
            
        for (CC_Lista_Valores__c valor : valores) {
            String umbralPrimerAvisoString = valor.CC_Valor__c;
            Integer umbralPrimerAviso = Integer.valueOf(umbralPrimerAvisoString);
            CC_Agrupador__c agrupador = new CC_Agrupador__c();
            agrupador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', mapNamesDeveloper.get(valor.Name));
            agrupador.CC_Estado__c = 'Activo';
            agrupador.CC_Titulo__c = 'Título';
            agrupador.CC_Numero_Casos__c = umbralPrimerAviso;
            agrupadoresInsert.add(agrupador);
        }
        
        insert agrupadoresInsert;
        Set<Id> idsAgrupadores = new Set<Id>();
        for (CC_Agrupador__c agrupador : agrupadoresInsert) {
            idsAgrupadores.add(agrupador.Id);
        }
        List<CC_Agrupador__c> agrupadores = [SELECT Id, Name, CC_Record_Type_Name__c, CC_Numero_Casos__c FROM CC_Agrupador__c WHERE Id IN :idsAgrupadores];
        
        //Ejecución de la prueba
        Test.startTest();
        CC_Aviso_Agrupador.publicarEventoDeAviso(agrupadores);
        Test.stopTest();
    }

    @isTest
    public static void publicarEventoDeAvisoClientes() {
        
        //Alta de datos para la prueba
        CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores.CC_Activa__c = true;
        lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
        insert lovAvisosSobreAgrupadores;

        List<CC_Lista_Valores__c> valorUmbralInsert = new List<CC_Lista_Valores__c>();
        
        for (String recordTypeDeveloperName : new List<String> {'CC_Comunicacion_Informativa', 'CC_Comunicacion_Informativa_de_Campana', 'CC_Incidencia', 'CC_Seguimiento', 'CC_Masiva_Control'}) {
            CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
            valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralPrimerAviso.CC_Activa__c = true;
            valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral primer aviso';
            valorUmbralPrimerAviso.CC_Valor__c = '2';
            valorUmbralInsert.add(valorUmbralPrimerAviso);
            CC_Lista_Valores__c valorUmbralSiguientesAvisos = new CC_Lista_Valores__c();
            valorUmbralSiguientesAvisos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralSiguientesAvisos.CC_Activa__c = true;
            valorUmbralSiguientesAvisos.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralSiguientesAvisos.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral siguientes avisos';
            valorUmbralSiguientesAvisos.CC_Valor__c = '50';
            valorUmbralInsert.add(valorUmbralSiguientesAvisos);
    	}
    	insert valorUmbralInsert;
        List<CC_Agrupador__c> agrupadoresInsert = new List<CC_Agrupador__c>();
        List<String> recordDeveloperNames = new List<String> {'CC_Comunicacion_Informativa', 'CC_Comunicacion_Informativa_de_Campana', 'CC_Incidencia', 'CC_Seguimiento', 'CC_Masiva_Control'};
        Set<String> setRecordNames = new Set<String>();
        Map<String, String> mapNamesDeveloper = new Map<String, String>();
        for (String recordDeveloperName : recordDeveloperNames) {
            String name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordDeveloperName);
            mapNamesDeveloper.put(name + ' - Umbral primer aviso', recordDeveloperName);
            setRecordNames.add(name + ' - Umbral primer aviso');
        }

        List<CC_Lista_Valores__c> valores = [SELECT CC_Valor__c, Name FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Avisos sobre agrupadores' AND Name IN :setRecordNames  WITH SECURITY_ENFORCED];
		for (CC_Lista_Valores__c valor : valores) {
            String umbralPrimerAvisoString = valor.CC_Valor__c;
            Integer umbralPrimerAviso = Integer.valueOf(umbralPrimerAvisoString);
            CC_Agrupador__c agrupador = new CC_Agrupador__c();
            agrupador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', mapNamesDeveloper.get(valor.Name));
            agrupador.CC_Estado__c = 'Activo';
            agrupador.CC_Titulo__c = 'Título';
            agrupador.CC_Numero_Casos__c = umbralPrimerAviso;
            agrupadoresInsert.add(agrupador);
        }
        insert agrupadoresInsert;

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        insert cuenta;        
        
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        Id recordTypeCasoCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id sRecordTypeIncidencia = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'ES';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;        

        Case oCaso = new Case();
        oCaso.Subject = 'Test Agrupador Toast';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Activo';
        oCaso.ContactId = contacto.Id;
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeCasoCliente;
        oCaso.CC_Agrupador_Id__c = agrupadoresInsert[0].Id;
        insert oCaso;

        
        Set<Id> idsAgrupadores = new Set<Id>();
        for (CC_Agrupador__c agrupador : agrupadoresInsert) {
            idsAgrupadores.add(agrupador.Id);
        }
        List<CC_Agrupador__c> agrupadores = [SELECT Id, Name, CC_Record_Type_Name__c, CC_Numero_Casos__c FROM CC_Agrupador__c WHERE Id IN :idsAgrupadores];
        
        //Ejecución de la prueba
        Test.startTest();
        CC_Aviso_Agrupador.publicarEventoDeAviso(agrupadores);
        Test.stopTest();
    }    
}