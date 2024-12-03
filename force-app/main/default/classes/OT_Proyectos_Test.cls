@isTest
public class OT_Proyectos_Test {
	@isTest
    public static void registroProyecto(){
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón International Operations';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;
        
        
        Test.startTest();
        String prefijo = OT_Proyectos.registroProyecto(caso.Id);
        Test.stopTest();
        
        System.assertEquals('OS', prefijo);
        
    }

    @isTest
    public static void getRecordTypeIdFromObjectId(){
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón International Operations';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;
        
        
        Test.startTest();
        Id idRecordType = OT_Proyectos.getRecordTypeIdFromObjectId(caso.Id);
        Test.stopTest();
        
        System.assertEquals(recordTypeCaso, idRecordType);
        
    }
}