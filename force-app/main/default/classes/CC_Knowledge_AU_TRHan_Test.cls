@isTest
public with sharing class CC_Knowledge_AU_TRHan_Test {
    @TestSetup
    static void makeData(){
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profileSupervisor = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        
        User administrador = new User();
        administrador.ProfileId = profileAdmin;
        administrador.FirstName = 'Usuario Admin Prueba';
        administrador.LastName = 'last211';
        administrador.Email = 'aalsdna@kfsb.com';
        administrador.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        administrador.CompanyName = 'MST';
        administrador.Title = 'title';
        administrador.Alias = 'alias';
        administrador.TimeZoneSidKey = 'Europe/Paris';
        administrador.EmailEncodingKey = 'UTF-8';
        administrador.LanguageLocaleKey = 'es';
        administrador.LocaleSidKey = 'es_ES';
		insert administrador;

        System.runAs(administrador)
        {
            User supervisor = new User();
            supervisor.ProfileId = profileSupervisor;
            supervisor.FirstName = 'Supervisor';
            supervisor.LastName = 'last11';
            supervisor.Email = 'tuser000@amamama.com';
            supervisor.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            supervisor.CompanyName = 'MST';
            supervisor.Title = 'title';
            supervisor.Alias = 'alias';
            supervisor.TimeZoneSidKey = 'Europe/Paris';
            supervisor.EmailEncodingKey = 'UTF-8';
            supervisor.LanguageLocaleKey = 'es';
            supervisor.LocaleSidKey = 'es_ES';
            supervisor.UserRoleId = rolCC.Id;
            insert supervisor;

            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id);

            Knowledge__kav know = new Knowledge__kav();
            know.Title = 'Test';
            know.UrlName = 'Test';
            know.CC_Fecha_Inicio_Publicacion__c = CBK_UtilsDate.nowDT().addHours(2);
            know.CC_Fecha_Caducidad__c =CBK_UtilsDate.nowDT().addHours(4);
            //know.PublishStatus = 'Draft';
            know.ValidationStatus = 'Validated';
            insert know;

            CC_Settings__c knowledgeSettings = new CC_Settings__c(
                Name = 'CC_Knowledge_Settings',
                CC_Activa__c = true,
                CC_Configuracion_1__c = '30;15;7',
                CC_Configuracion_2__c = '7'
            );
            insert knowledgeSettings;
            //Database.insert(settings);
        }
    }

    @isTest
    static void schedulableKnowledgeTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE LIMIT 1];
        Knowledge__kav know = [SELECT Id FROM Knowledge__kav WHERE Title = 'Test'];

        System.runAs(supervisor)
        {
            List<CBK_SCH_PendingProcess__c> pdpBefore = [SELECT Id FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :know.Id];
            Test.startTest();
                know.Title = 'test2';
                update know;
                List<CBK_SCH_PendingProcess__c> pdpAfter = [SELECT Id FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :know.Id];
                System.assertEquals(pdpBefore.size(), pdpAfter.size(), 'Se han reprogramado los pending process al cambiar el titulo');
            Test.stopTest();
        }
    }

    @isTest
    static void schedulableKnowledgeChangeDateTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE LIMIT 1];
        Knowledge__kav know = [SELECT Id FROM Knowledge__kav WHERE Title = 'Test'];

        System.runAs(supervisor)
        {
            List<CBK_SCH_PendingProcess__c> pdpBefore = [SELECT Id, Param2__c, Param1__c  FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :know.Id];
            Test.startTest();
                know.Title = 'test2';
                know.CC_Fecha_Caducidad__c = CBK_UtilsDate.nowDT().addHours(8);
                know.CC_Fecha_Inicio_Publicacion__c = CBK_UtilsDate.nowDT().addHours(3);            
                update know;    
            Test.stopTest();        
            List<CBK_SCH_PendingProcess__c> pdpAfter = [SELECT Id, Param2__c, Param1__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :know.Id];
            
            List<Id> deletedPdpIds = new List<Id>();
            for (CBK_SCH_PendingProcess__c pdp : pdpBefore) {
                //  AND ((Param1__c = 'actualizarEstadoPublicacion' AND Param2__c = 'despublicar') OR 
                //(Param1__c = 'notificacionVencimiento' AND Param2__c = 'articuloVencido'))
               
                if ((pdp.Param1__c == 'actualizarEstadoPublicacion' && pdp.Param2__c == 'despublicar') || 
                    (pdp.Param1__c == 'notificacionVencimiento' && pdp.Param2__c == 'articuloVencido')) { 
                    deletedPdpIds.add(pdp.Id);
                }
            }
            List<CBK_SCH_PendingProcess__c> pdpAfterDelete = [SELECT Id, Param2__c, Param1__c FROM CBK_SCH_PendingProcess__c WHERE Id IN: deletedPdpIds];

            List<Id> newPdpIds = new List<Id>();
            for (CBK_SCH_PendingProcess__c pdp : pdpAfter) {
                //  AND ((Param1__c = 'actualizarEstadoPublicacion' AND Param2__c = 'despublicar') OR 
                //(Param1__c = 'notificacionVencimiento' AND Param2__c = 'articuloVencido'))
               
                if ((pdp.Param1__c == 'actualizarEstadoPublicacion' && pdp.Param2__c == 'despublicar') || 
                    (pdp.Param1__c == 'notificacionVencimiento' && pdp.Param2__c == 'articuloVencido')) { 
                        newPdpIds.add(pdp.Id);
                }
            }
          
         
            System.assertEquals(pdpAfterDelete.isEmpty(), true, 'No se han eliminado los pending process');
            System.assertEquals(!newPdpIds.isEmpty(), true, 'No se han creado nuevos pending process');
            
        }
    }


}