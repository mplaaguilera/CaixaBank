@isTest
public with sharing class HDT_Asociar_Casos_Masivas_Test {
    @testSetup
    public static void testSetup(){
        
        CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores.CC_Activa__c = true;
        lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
        insert lovAvisosSobreAgrupadores;
        
        CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
        valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralPrimerAviso.CC_Activa__c = true;
        valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') + ' - Umbral primer aviso';
        valorUmbralPrimerAviso.CC_Valor__c = '2';
        
        CC_Lista_Valores__c valorUmbralSiguientesAvisos = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisos.CC_Activa__c = true;
        valorUmbralSiguientesAvisos.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralSiguientesAvisos.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') + ' - Umbral siguientes avisos';
        valorUmbralSiguientesAvisos.CC_Valor__c = '50';
        
        insert new List<CC_Lista_Valores__c>{valorUmbralPrimerAviso, valorUmbralSiguientesAvisos};
        
        List<Case> casesList = new List <Case>();
        Case caso1 = new Case();
        caso1.Subject = 'CASO HDT';
        caso1.Status = 'Activo';
        caso1.Origin = 'Chat';
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso1.CC_Canal_Procedencia__c='SmartPhones';
        casesList.add(caso1);
        
        Case caso2 = new Case();
        caso2.Subject = 'CASO HDT 2';
        caso2.Status = 'Activo';
        caso2.Origin = 'Chat';
        caso2.CC_Idioma__c = 'es';
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso2.CC_Canal_Procedencia__c='SmartPhones';
        casesList.add(caso2);
        
        insert casesList;
        
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.CC_Estado__c = 'Activo';
        agrupador.CC_Publica__c = true;
        agrupador.CC_Titulo__c = 'AGRUPADOR TEST';
        agrupador.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        agrupador.CC_Notificar_Clientes__c = true;
        
        
        insert agrupador;

        HDT_Parametros__c customSetting = new HDT_Parametros__c();
        customSetting.Name = 'HDT_Casos_Asociados_Maximo';
        customSetting.HDT_Configuracion_1__c = '1';
        insert customSetting;
        
    }
    @isTest
    public static void testgetCaso() {
        Case caso = [SELECT Id,CaseNumber FROM Case WHERE Subject = 'CASO HDT'];
        Test.startTest();
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()){
            List<Case> buscarCasos = HDT_Asociar_Casos_Masivas.buscarCasos(caso.CaseNumber);
            System.assertEquals(1, buscarCasos.size());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testVincularCasos() {
        List<Id> casosIds = new List<Id>();
        Case caso = [SELECT Id,CaseNumber FROM Case WHERE Subject = 'CASO HDT'];
        List<CC_Agrupador__c> agrupadores = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'AGRUPADOR TEST'];
        
        casosIds.add(caso.Id);
        
        Test.startTest();
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()){
            HDT_Asociar_Casos_Masivas.vincularCasos(agrupadores[0].Id, casosIds);
            List<Case> casosVinculados = [SELECT Id, CC_Agrupador_Id__c FROM Case WHERE Subject = 'CASO HDT'];
            List<CC_Agrupador__c> agrupador = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'AGRUPADOR TEST'];
            System.assertEquals(agrupador[0].Id, casosVinculados[0].CC_Agrupador_Id__c);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testgetHDTParametro() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
                System.assertEquals(1, HDT_Asociar_Casos_Masivas.numeroMaximoCasosAsociados());
            Test.stopTest();
        }
    }
}