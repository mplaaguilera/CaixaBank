@isTest
public class OS_Reasignacion_Caso_Test {
    
    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();
    }

	@isTest
    public static void reasignacionCaso(){
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba Duplicar Caso';
        caso.Status = 'Activo';
        caso.Origin = 'Phone';
        caso.CC_Ultima_Interaccion__c = 'Nuevo';
        caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Reasignacion_Caso.reasignacionCaso(new List<Id>{caso.Id});
            Test.stopTest();

            System.assertEquals('Reasignación del caso', [SELECT CC_Ultima_Interaccion__c, Id FROM Case WHERE Id = :caso.Id].CC_Ultima_Interaccion__c);
            System.assertNotEquals(null, [SELECT CC_Fecha_Ultima_Interaccion__c, Id FROM Case WHERE Id = :caso.Id].CC_Fecha_Ultima_Interaccion__c);
            Integer day = System.today().Day();
            System.assertEquals(day, ([SELECT CC_Fecha_Ultima_Interaccion__c, Id FROM Case WHERE Id = :caso.Id].CC_Fecha_Ultima_Interaccion__c).day());
        }
    }

}