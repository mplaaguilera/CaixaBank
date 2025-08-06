@isTest
public class OS_Usuario_Backup_Test {


    @TestSetup
    static void cargaDeDatos(){
        User admin = OS_Usuarios.usuarioAdmin();
        User usuarioBackup = OS_Usuarios.usuarioAdmin();
        admin.FirstName = 'testing backup';
        admin.OS_Cola_Backup__c = null;
        admin.OS_Agente_Backup__c = usuarioBackup.Id;
        update admin;

        usuarioBackup.OS_Cola_Backup__c = null;
        update usuarioBackup;

        List<Case> casos = new List<Case>();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso1.Subject = 'Prueba1';
        caso1.Status = 'Activo';
        caso1.Origin = 'Phone';
        caso1.OwnerId = admin.Id;
        caso1.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso1.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        casos.add(caso1);

        Case caso2 = new Case();
        caso2.CC_Idioma__c = 'es';
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso2.Subject = 'Prueba2';
        caso2.Status = 'Activo';
        caso2.Origin = 'Phone';
        caso2.OwnerId = admin.Id;
        caso2.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso2.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        casos.add(caso2);

        Case caso3 = new Case();
        caso3.CC_Idioma__c = 'es';
        caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        caso3.Subject = 'Prueba3';
        caso3.Status = 'Activo';
        caso3.Origin = 'Phone';
        caso3.OwnerId = admin.Id;
        caso3.CC_Canal_Procedencia__c = 'Teléfono COPS atención empleados';
        caso3.CC_Canal_Resolucion__c = 'Teléfono COPS atención empleados';
        caso3.CC_Tipo_Contacto__c = 'Asesoramiento';
        casos.add(caso3);
        
        insert casos;
    }

    @isTest
    public static void cambiarPropietario() {    
        User admin = [SELECT Id,OS_Agente_Backup__c FROM User WHERE FirstName = 'testing backup' LIMIT 1];

        System.runAs (admin) {
            Test.startTest();
            OS_Usuario_Backup.cambioPropietario(new List<Id>{admin.Id});
            Test.stopTest();
            
            Case caso1 = [SELECT Id, OwnerId FROM Case WHERE Subject = 'Prueba1' LIMIT 1];
            Case caso2 = [SELECT Id, OwnerId FROM Case WHERE Subject = 'Prueba2' LIMIT 1];
            Case caso3 = [SELECT Id, OwnerId FROM Case WHERE Subject = 'Prueba3' LIMIT 1];

            System.assertEquals(admin.OS_Agente_Backup__c, caso1.OwnerId,'Error caso 0');
            System.assertEquals(admin.OS_Agente_Backup__c, caso2.OwnerId,'Error caso 1');
            System.assertEquals(admin.OS_Agente_Backup__c, caso3.OwnerId,'Error caso 2');
        }
    }

}