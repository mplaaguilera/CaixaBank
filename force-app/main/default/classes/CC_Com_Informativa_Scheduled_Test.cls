@isTest
public class CC_Com_Informativa_Scheduled_Test {
	@isTest
    public static void planificar() {
        
        //Alta de datos para la prueba
        CC_Agrupador__c comunicacionInformativa = new CC_Agrupador__c();
        comunicacionInformativa.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        comunicacionInformativa.CC_Estado__c = 'Activo';
        comunicacionInformativa.CC_Titulo__c = 'Título';
        insert comunicacionInformativa;
        
        //Ejecución de la prueba
        Test.startTest();
        CC_Comunicacion_Informativa_Scheduled.planificar();
        Test.stopTest();
        
        //Evaluación del resultado de la prueba
        //TODO
    }
    
}