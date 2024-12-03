@isTest
public class CC_Task_Gestion_Test {
    @isTest
    public static void actualizarPropietarioTest() {        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Status = 'Activo';
        caso.Subject = 'Caso de prueba';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Accionista';
        insert caso;

        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        Task actividad = new Task();
        actividad.WhatId = caso.Id;
        actividad.Status = 'Open';
        actividad.Type = 'Traslado Tercer Nivel';
        actividad.RecordTypeId = taskRecordTypeId;
        insert actividad;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = 'Manola',
                                lastName = 'Pruebas',
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profile.Id
                               );
        insert tuser;
        
        // Actualizar el propietario con un nuevo usuario para que después la tareas canvien al nuevo
        caso.OwnerId = tuser.Id;
        update caso;
        
        Test.startTest();
        CC_Task_Gestion.actualizarPropietarioTareas(new List<Id>{caso.Id});        
        // Comprobar que la tarea está cerrada
        System.assertEquals(tuser.Id, [SELECT OwnerId, Status FROM Task WHERE Id = :actividad.Id AND Status = 'Open' LIMIT 1].OwnerId);
        Test.stopTest();
        
    }
}