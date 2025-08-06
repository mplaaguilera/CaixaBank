@isTest
public with sharing class CBK_SCH_OS_ScheduleProgramarAlerta_Test {
    @isTest
    public static void CBK_SCH_OS_ScheduleProgramarAlerta() {
        Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = new Account();
        cuenta.Name = 'PRUEBAS CLIENTE';
        cuenta.CC_Numero_Documento__c = '64850344G';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;
        
        Id recordTypeContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        contacto.RecordTypeId = recordTypeContacto; 
        contacto.Phone = '666444555';
        contacto.Email = 'testCopsBI@test.com';
        insert contacto;

        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        insert caso;

        caso.Status = 'Pendiente Alerta';
        caso.OS_Alerta_Fecha__c = System.now().addHours(2);
        update caso;

        CBK_SCH_PendingProcess__c pendingProcessAlerta = new CBK_SCH_PendingProcess__c();
        pendingProcessAlerta.RecordId__c = caso.Id;
        pendingProcessAlerta.Schedule_Time__c = caso.OS_Alerta_Fecha__c;
        pendingProcessAlerta.ClassName__c = 'CBK_SCH_OS_ScheduleProgramarAlerta';
        insert pendingProcessAlerta;

        List<CBK_SCH_PendingProcess__c> pendingProcess = new List<CBK_SCH_PendingProcess__c>();
        pendingProcess.add(pendingProcessAlerta);

        Test.startTest();
        CBK_SCH_OS_ScheduleProgramarAlerta implClass = new CBK_SCH_OS_ScheduleProgramarAlerta();
        implClass.lstInfoProcess = pendingProcess;
        System.enqueueJob(implClass);
        Test.stopTest();

        List<Case> casoProgramado = [SELECT Id FROM Case WHERE Id = :caso.Id AND OS_Alerta_Fecha__c = null];

        System.assert(!casoProgramado.isEmpty());
    }
}