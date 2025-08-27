@isTest
public with sharing class GRR_GestionController_Test {
   @TestSetup
    static void makeData(){
        String orgId = UserInfo.getOrganizationId();
        //String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        User usuario = new User();
        usuario.IsActive = true;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'GRR_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'GRR'].Id;
        usuario.FirstName = 'GRR Prueba Clases Test';
        usuario.LastName = 'GRR Prueba Clases Test';
        usuario.Alias = uniqueName.substring(18, 23);
        usuario.Email = uniqueName + '@test' + orgId + '.org';
        usuario.Username = uniqueName + '@test' + orgId + '.org';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.TimezonesIdKey = 'Europe/Madrid';
        insert usuario;
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('GRR_Agente','GRR_Supervisor','GRR_Buzon_Servicio_Recobro')]) {
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;
    }


    @isTest
    static void testgetGestionesByCaseId() {
         System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {

       
         User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        // Crear un Case
        Case caso = new Case(

            Subject = 'Caso de prueba',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Origin = 'Email',
            Status = 'Nuevo',
            Priority = 'Medium'
        );
        insert caso;

        // Crear registros de GRR_Gestion__c relacionados con el Case
        List<GRR_Gestion__c> gestiones = new List<GRR_Gestion__c>{
            new GRR_Gestion__c(
                GRR_Case_Gestion__c = caso.Id,
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Gestion__c', 'GRR_Cirbe'),
                GRR_Interviniente__c = 'Inte1',
                GRR_Importe_Riesgo_directo__c = 1000
            ),
            new GRR_Gestion__c(
               GRR_Case_Gestion__c = caso.Id,
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Gestion__c', 'GRR_Cirbe'),
                GRR_Interviniente__c = 'Int2',
                GRR_Cirbe_Externo__c = 'No',
                GRR_Importe_Riesgo_directo__c = 2000
            )
        };
        insert gestiones;
          //System.runAs(usuario) {

            Test.startTest();
            List<GRR_Gestion__c> result = GRR_GestionController.getGestionesByCaseId(caso.Id, 'GRR_Cirbe');
            Id result2 = GRR_GestionController.getGestionRecordTypeId('GRR_Cirbe');
            
            Test.stopTest();
        
            // Verificaciones
            System.assertEquals(2, result.size(), 'Debe devolver 2 gestiones');
        //}
        }
    }


    
}