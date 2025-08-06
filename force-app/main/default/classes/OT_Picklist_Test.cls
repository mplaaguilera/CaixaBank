@isTest
public class OT_Picklist_Test {
	@isTest
    public static void picklistCampo(){
        Case caso = new Case();
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón International Operations';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;
        List<OT_Picklist.Item> items =  OT_Picklist.picklistCampo('Case', 'CC_Canal_Procedencia__c');
        
        System.assertNotEquals(null, items);
    }
    @isTest
    public static void picklistSoql(){
        List<Case> listaCasos = new List<Case>();
        Case caso = new Case();
        caso.Subject ='Caso de prueba 1';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón International Operations';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        listaCasos.add(caso);
        
        Case caso2 = new Case();
        caso2.Subject ='Caso de prueba 2';
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Buzón International Operations';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        listaCasos.add(caso2);

        
        insert listaCasos;
        List<SObject> resultados = Database.query('SELECT Id, Subject FROM Case WHERE RecordTypeId = \'' + CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente') + '\' AND Subject != null'); 
        List<OT_Picklist.Item> items =  OT_Picklist.picklistSoql(resultados,'Id', 'Subject');
        
        System.assertNotEquals(null, items);
    }
}