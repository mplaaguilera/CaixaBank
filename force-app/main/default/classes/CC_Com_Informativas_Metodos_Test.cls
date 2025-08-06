@isTest
public class CC_Com_Informativas_Metodos_Test {

    @TestSetup
    static void makeData(){
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
    }

    @isTest
    public static void actualizarEstadisticasComunicacionInformativa() {
        
        //Alta de datos para la prueba
		Set<Id> idsComunicacionInformativa = new Set<Id>();
        CC_Agrupador__c comunicacionInformativa = new CC_Agrupador__c();
        comunicacionInformativa.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        comunicacionInformativa.CC_Estado__c = 'Activo';
        comunicacionInformativa.CC_Titulo__c = 'Título';
        comunicacionInformativa.CC_Numero_Casos__c = 0;
        insert comunicacionInformativa;
        idsComunicacionInformativa.add(comunicacionInformativa.Id);
        
        Case caso = new Case();
        caso.CC_Comunicacion_Informativa__c = comunicacionInformativa.Id;
        caso.Origin = 'Chat';
        insert caso;
        
        Case caso2 = new Case();
        caso2.CC_Comunicacion_Informativa__c = comunicacionInformativa.Id;
        caso2.Origin = 'Email';
        insert caso2;

        //Ejecución de la prueba
        Test.startTest();
        CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(idsComunicacionInformativa);
        Test.stopTest();

        CC_Agrupador__c comunicacion = [SELECT Id, CC_Numero_Casos_Chat__c FROM CC_Agrupador__c WHERE Id = :comunicacionInformativa.Id];
        System.assertEquals(1, comunicacion.CC_Numero_Casos_Chat__c, 'El número de comunicaciones no coindice.');
    }
    
	@isTest
    public static void actualizarEstadisticasComunicacionInformativaCampana() {
        
        //Alta de datos para la prueba
		Set<Id> idsComunicacionInformativaCampana = new Set<Id>();
        CC_Agrupador__c comunicacionInformativaCampana = new CC_Agrupador__c();
        comunicacionInformativaCampana.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
        comunicacionInformativaCampana.CC_Estado__c = 'Activo';
        comunicacionInformativaCampana.CC_Titulo__c = 'Título';
        comunicacionInformativaCampana.CC_Numero_Casos__c = 0;
        insert comunicacionInformativaCampana;
        idsComunicacionInformativaCampana.add(comunicacionInformativaCampana.Id);
        
        Case caso = new Case();
        caso.CC_Comunicacion_Informativa_Campana__c = comunicacionInformativaCampana.Id;
        caso.Origin = 'Chat';
        insert caso;
        
        Case caso2 = new Case();
        caso2.CC_Comunicacion_Informativa_Campana__c = comunicacionInformativaCampana.Id;
        caso2.Origin = 'Email';
        insert caso2;

        //Ejecución de la prueba
        Test.startTest();
        CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativaCampana(idsComunicacionInformativaCampana);
        Test.stopTest();

        CC_Agrupador__c comunicacion = [SELECT Id, CC_Numero_Casos_Chat__c FROM CC_Agrupador__c WHERE Id = :comunicacionInformativaCampana.Id];
        System.assertEquals(1, comunicacion.CC_Numero_Casos_Chat__c, 'El número de comunicaciones no coindice.');
    }
    
}