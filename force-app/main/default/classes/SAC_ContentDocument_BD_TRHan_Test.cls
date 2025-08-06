@isTest 
public class SAC_ContentDocument_BD_TRHan_Test {
    @testSetup
    static void setupData() {
        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        
        // Create User
        User sacUser = new User(
            Username = 'sacUser01@test.com',
            Email = 'email@test.com',
            LastName = 'Test',
            ProfileId = profileId,
            Alias = 'alias',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            isActive = true,
            userRole = uRole);
        insert sacUser;
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
		PermissionSetAssignment permiSetAssi = new PermissionSetAssignment(
            AssigneeId = sacUser.Id,
            PermissionSetId = permiSet.Id);
        insert permiSetAssi;
        System.runAs(sacUser){
            // Create Reclamación
            Case reclamacion = new Case(
                Subject = 'Caso de prueba para EmailMessage',
                Status = 'SAC_001',
                SAC_StatusAuxiliar__c = 'SAC_001',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId(),
                SAC_FechaRecepcion__c = System.today()
            );
            insert reclamacion;
            
            // Delete permissions
            List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: sacUser.Id AND PermissionSet.Name = 'SAC_SystemAdmin' LIMIT 1];
            if(!psa.isEmpty()){
                delete psa;
            }
        }
    }
    
    @IsTest
    static void deleteContentDocument() {
        User sacUser = [SELECT Id FROM User WHERE username = 'sacUser01@test.com' LIMIT 1];
        System.runAs(sacUser){
            Case reclamacion = [SELECT Id FROM Case LIMIT 1];
            // Create EmailMessage
            EmailMessage emailMessage = new EmailMessage(
                ParentId = reclamacion.Id,
                FromAddress = 'test@example.com',
                ToAddress = 'support@example.com',
                Subject = 'Subject Test',
                TextBody = 'Body Test'
            );
            insert emailMessage;
            
            // Create ContentVersion
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion;
            
            // Get ContentDocument
            ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
            
            // Create ContentDocumentLink
            ContentDocumentLink docLink = new ContentDocumentLink(
                ContentDocumentId = cd.Id,
                LinkedEntityId = emailMessage.Id,
                ShareType = 'V');
            insert docLink;
            
            // Delete
            try {
                delete cd;
                System.assert(false, 'Se esperaba un error de eliminación.');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('No se pueden eliminar adjuntos vinculados a correos que ya han sido enviados.'));
            }
        }
    }
}