@isTest
public with sharing class CC_LiveChatTranscript_AI_TRHan_Test {

    //IMPORTANTE: Actualmente este test solo cubre el metodo identificarClientes de la clase CC_LiveChatTranscript_AI_TRHan
    //Por lo que para cubrir el resto de la clase, se deberá ejecutar el test de CC_LiveChatTranscript_BI_TRHan_Test
    //y posteriormente ejecutar este test.

    @isTest
    static void testIdentificarClientes() {
        Test.startTest();
        User adminUser = CC_TestDataFactory.insertUserAdmin();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Analista_Cliente' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps.Id);

        System.runAs(adminUser) {
            

            //Creamos un LiveChatTranscript de prueba
            Account acc = new Account();
            acc.Name = 'Prueba';
            acc.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            acc.CC_Numero_Documento__c = '45855598S';
            acc.CC_NumPerso__c = '533752';
            insert acc;

            Id clienteContactRT = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            Contact contacto = new Contact ();
            contacto.RecordTypeId = clienteContactRT;
            contacto.LastName = 'cnt';
            contacto.FirstName = 'prueba';
            contacto.Email = 'test@test.com';
            contacto.AccountId = acc.Id;
            insert contacto;



            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.CC_Canal_Procedencia__c = 'Accionista';
            caso.CC_Canal_Resolucion__c = 'Accionista';
            caso.CC_Canal_Operativo__c = 'App CaixaBankPay';
            caso.Origin = 'Email';
            caso.Status = 'Activo';
            caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso.CC_Detalles_Solucion__c = 'Detalles Solución';
            caso.AccountId = acc.Id;
            caso.ContactId = contacto.Id;

            insert caso;

            LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
            insert liveChatVisitor;

            LiveChatTranscript chat = new LiveChatTranscript();
            chat.CC_Actualizar_ALF__c = true;
            chat.ContactId = contacto.Id;
            chat.AccountId = acc.Id;
            chat.CaseId = caso.Id;
            chat.LiveChatVisitorId = liveChatVisitor.Id;
            chat.Status = 'InProgress';
            insert chat;

            List<LiveChatTranscript> chats = [SELECT Id, CC_Actualizar_ALF__c, ContactId, AccountId, CaseId, LiveChatVisitorId, Status FROM LiveChatTranscript WHERE Id = :chat.Id];


            System.assertEquals(chats[0].CC_Actualizar_ALF__c, false);
        }
        Test.stopTest();
    }
    

}