@isTest
public with sharing class CSBD_Batch_RechazoOppChat_Test {
    @testSetup
    public static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '12345678N';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioGestor.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        User idOwner = [SELECT Id, name FROM User WHERE UserName LIKE 'csbd_generico@cc-caixabank.com%'];
        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuenta.Id;
        acshare2.UserOrGroupId = idOwner.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        insert acshare2;

        Id rt = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Chat').getRecordTypeId();
        Opportunity oportunidadTest = new Opportunity();
        oportunidadTest.Name='test';
        oportunidadTest.stageName='Solicitud';
        oportunidadTest.AccountId=cuenta.Id;
        oportunidadTest.OwnerId=usuarioGestor.Id;
        oportunidadTest.RecordTypeId = rt;
        insert oportunidadTest;

    }

    @isTest
    public static void batchRechazarOppChat() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        User idOwner = [SELECT Id, name FROM User WHERE UserName LIKE 'csbd_generico@cc-caixabank.com%'];
        Opportunity registro = [SELECT Id, CSBD_Estado__c, CSBD_Resolucion__c, OwnerId FROM Opportunity WHERE OwnerId =: usuarioGestor.Id LIMIT 1];

        System.runAs (usuarioGestor) {
            registro.OwnerId = idOwner.Id;
            update registro;
        }

        System.runAs (idOwner) {
            Test.startTest();
            CSBD_Batch_RechazoOppChat obj = new CSBD_Batch_RechazoOppChat();
            DataBase.executeBatch(obj); 
            Test.stopTest();
        

            Opportunity registroPostBatch = [SELECT Id, CSBD_Estado__c, CSBD_Resolucion__c, OwnerId FROM Opportunity WHERE Id =:registro.Id LIMIT 1];
                
            System.assertEquals('Rechazada', registroPostBatch.CSBD_Estado__c, 'El estado de la oportunidad no se ha modificado correctamente.');
            System.assertEquals('Chat no iniciado', registroPostBatch.CSBD_Resolucion__c, 'El campo resolución de la oportunidad no se ha modificado correctamente.');
        }
    }
}