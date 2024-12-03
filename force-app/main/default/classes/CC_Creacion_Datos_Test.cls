/**
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Creación de datos para clases de test.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public class CC_Creacion_Datos_Test {

    // Lista de valores "Avisos sobre agrupadores".
    public static void lovAvisosSobreAgrupadores() {
        
        String recordTypeDeveloperName1 = 'CC_Comunicacion_Informativa';
        CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores.CC_Activa__c = true;
        lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
        insert lovAvisosSobreAgrupadores;
        
        CC_Lista_Valores__c valorUmbralPrimerAviso1 = new CC_Lista_Valores__c();
        valorUmbralPrimerAviso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralPrimerAviso1.CC_Activa__c = true;
        valorUmbralPrimerAviso1.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralPrimerAviso1.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName1) + ' - Umbral primer aviso';
        valorUmbralPrimerAviso1.CC_Valor__c = '2';
        insert valorUmbralPrimerAviso1;
        
        CC_Lista_Valores__c valorUmbralSiguientesAvisos1 = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisos1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisos1.CC_Activa__c = true;
        valorUmbralSiguientesAvisos1.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralSiguientesAvisos1.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName1) + ' - Umbral siguientes avisos';
        valorUmbralSiguientesAvisos1.CC_Valor__c = '50';
        insert valorUmbralSiguientesAvisos1;
        
        String recordTypeDeveloperName2 = 'CC_Comunicacion_Informativa_de_Campana';
        CC_Lista_Valores__c valorUmbralPrimerAviso2 = new CC_Lista_Valores__c();
        valorUmbralPrimerAviso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralPrimerAviso2.CC_Activa__c = true;
        valorUmbralPrimerAviso2.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralPrimerAviso2.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName2) + ' - Umbral primer aviso';
        valorUmbralPrimerAviso2.CC_Valor__c = '2';
        insert valorUmbralPrimerAviso2;
        
        CC_Lista_Valores__c valorUmbralSiguientesAvisos2 = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisos2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisos2.CC_Activa__c = true;
        valorUmbralSiguientesAvisos2.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralSiguientesAvisos2.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName2) + ' - Umbral siguientes avisos';
        valorUmbralSiguientesAvisos2.CC_Valor__c = '50';
        insert valorUmbralSiguientesAvisos2;
        
        String recordTypeDeveloperName3 = 'CC_Incidencia';
        CC_Lista_Valores__c valorUmbralPrimerAviso3 = new CC_Lista_Valores__c();
        valorUmbralPrimerAviso3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralPrimerAviso3.CC_Activa__c = true;
        valorUmbralPrimerAviso3.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralPrimerAviso3.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName3) + ' - Umbral primer aviso';
        valorUmbralPrimerAviso3.CC_Valor__c = '2';
        insert valorUmbralPrimerAviso3;
        
        CC_Lista_Valores__c valorUmbralSiguientesAvisos3 = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisos3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisos3.CC_Activa__c = true;
        valorUmbralSiguientesAvisos3.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralSiguientesAvisos3.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName3) + ' - Umbral siguientes avisos';
        valorUmbralSiguientesAvisos3.CC_Valor__c = '50';
        insert valorUmbralSiguientesAvisos3;
    }
    
}