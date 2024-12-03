@isTest 
public class SAC_Accion_BD_TRHan_Test {
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
    static void deleteAccion() {
        User sacUser = [SELECT Id FROM User WHERE username = 'sacUser01@test.com' LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case LIMIT 1];
        System.runAs(sacUser){
        // Create Acción
        SAC_Accion__c accion = new SAC_Accion__c(
            SAC_Reclamacion__c = reclamacion.Id,
            SAC_Descripcion__c = 'test'
        );
        insert accion;
            // Delete
            try {
                delete accion;
                System.assert(false, 'Se esperaba un error de eliminación.');
            } catch (DmlException e) {
                system.debug('*e.getMessage() '+e.getMessage());
                System.assert(e.getMessage().contains('No se puede eliminar la tarea.'));
            }
        }
    }
}