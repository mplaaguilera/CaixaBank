@isTest
public with sharing class GRR_ContentVersionTriggerHelper_Test {

    private static Account crearCuenta() {
        Account cuenta = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'GRR_NoCliente_PA'),
            LastName = 'Cliente GRR'
        );
        insert cuenta;

        return cuenta;
    }
    

    private static CollaborationGroup crearGrupo(){
        CollaborationGroup nuevoGrupo = new CollaborationGroup();
        nuevoGrupo.Name = 'GRR Grupo Archivos Test';
        nuevoGrupo.CollaborationType = 'Private';
        nuevoGrupo.Description = 'Grupo que permite compartir archivos solo con los miembros del proyecto GRR';
        nuevoGrupo.IsArchived = false;
        nuevoGrupo.IsAutoArchiveDisabled = true;
        
        insert nuevoGrupo;
        
        return nuevoGrupo;
    }    
    
    @isTest
    public static void testTriggerContentVersion() {
        //NOTA: Se podría también crear otro método en GRR_TestDataFactory para la creación del usuario de Soporte
        User usuario = GRR_TestDataFactory.usuarioPruebasGRR();
        
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('GRR_Soporte')]) {
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;
        
        System.runAs(usuario) {
            Test.startTest();
			
            CollaborationGroup grupo = crearGrupo();
            
            Account cuenta = crearCuenta();

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S';
            contentVersion.PathOnClient = 'Test';
            contentVersion.Origin = 'H';
            contentVersion.Title = 'Test';
            contentVersion.VersionData = Blob.valueOf('Test Content');
            contentVersion.FirstPublishLocationId = cuenta.Id;
            insert contentVersion;

            System.assertEquals('R', [SELECT SharingOption FROM ContentVersion WHERE Id = :contentVersion.Id].SharingOption);
            System.assertEquals('P', [SELECT SharingPrivacy FROM ContentVersion WHERE Id = :contentVersion.Id].SharingPrivacy);
            System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :grupo.Id]);

            Test.stopTest();
        }
    }

}