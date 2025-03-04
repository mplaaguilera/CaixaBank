@isTest 
public class CC_EmailMessage_BD_TRHan_Test {
    @testSetup
    static void setupData() {
        String profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'Contact_Center_sin_acceso_a_Directorio'];
        
        // Create User
        User ccUser = new User(
            Username = 'ccUser01@test.com',
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
        insert ccUser;
		PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment(
            AssigneeId = ccUser.Id,
            PermissionSetId = permiSet.Id);
        insert permiSetAssi;

        EmailTemplate templateClienteEs = new EmailTemplate();
        templateClienteEs.Name = 'Segunda Comunicación - Castellano Formal';
        templateClienteEs.DeveloperName = 'Respuesta_automatica_cliente_Castellano_Caso_Email_Revisar';
        templateClienteEs.TemplateType = 'Text';
        templateClienteEs.folderId =ccUser.id; 
        insert templateClienteEs;


        System.runAs(ccUser){
            // Create Reclamación
            Case caso = new Case(
                Subject = 'Caso de prueba para EmailMessage',
                Status = 'CC_001',
                //SAC_StatusAuxiliar__c = 'SAC_001',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId()
                //SAC_FechaRecepcion__c = System.today()
            );
            insert caso;
            
            // Delete permissions
            List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: ccUser.Id AND PermissionSet.Name = 'CC_Operador_CCO' LIMIT 1];
            if(psa.isEmpty()){
                delete psa;
            }
        }
    }
    
    @IsTest
    static void deleteEmailMessage() {
        User ccUser = [SELECT Id FROM User WHERE username = 'ccUser01@test.com' LIMIT 1];
        Case caso = [SELECT Id FROM Case LIMIT 1];
        System.runAs(ccUser){
            // Create EmailMessage
            EmailMessage emailMessage = new EmailMessage(
                ParentId = caso.Id,
                FromAddress =  [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Atencion_Cliente_ESP'].CC_Direccion_Correo__c,
                //FromAddress = 'test@example.com',
                ToAddress = 'support@example.com',
                Subject = 'Subject Test',
                TextBody = 'Body Test'
            );
            insert emailMessage;
            
            // Delete
            try {
                delete emailMessage;
                System.assert(false, 'Se esperaba un error de eliminación.');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('No se puede eliminar el email.'));
            }
        }
    }
}