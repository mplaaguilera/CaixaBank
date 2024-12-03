@isTest
public with sharing class GRR_CaseTriggerHelper_Test {

    @TestSetup
    static void makeData(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
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
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('GRR_Agente','GRR_Supervisor')]) {
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;
    }
    
    private static Contact crearContacto() {
        List<Account>dt = new List<Account>();
        dt.add(new Account (
            Name = 'DT',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente')) 
        );
        insert dt;
        List<Account> dan = new List<Account>();
        dan.add(new Account (
            Name = 'DAN',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
            ParentId = dt[0].Id) 
        );
        insert dan;
        Account oficina = new Account (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
            Name = 'Oficina',
            CC_Gerencia_Comercial__c = dan[0].Id,
            ParentId = dan[0].Id,
            CC_Direccion_Territorial__c = dt[0].Id
        );
        insert oficina;

        Contact contacto = new Contact (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
            FirstName = 'Contacto',
            LastName = 'Contacto',
            AccountId = oficina.Id,
            MobilePhone = '642462269'
        );
        insert contacto;
        return contacto;
    }
    
    private static Case crearCaso(String usuarioId) {
        User user = [SELECT Id FROM User WHERE Id =: usuarioId];
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Test',
            Origin = 'SAC_Manual',
            CC_Canal_Procedencia__c = 'DT Canarias',
            OwnerId = user.Id
        );           
        insert caso;
        return caso;
    }

    @future
    private static void updateCaso(String idcaso) {
        Case caso = [SELECT Id FROM Case WHERE Id = :idcaso];
        update caso;
    }
    
    @isTest
    public static void testCrearActividadReasignacion() {
        User usuario = new User();
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'GRR_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'GRR'].Id;
        usuario.FirstName = 'first 1';
        usuario.LastName = 'last1';
        usuario.Email = 'puser000@amamama.com';
        usuario.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        usuario.CompanyName = 'TEST';
        usuario.Title = 'title';
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'Europe/Madrid';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        insert usuario;

        User usuarioCaso = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuarioCaso) {
            Case caso = crearCaso(usuarioCaso.Id);
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, OwnerId FROM Case]);
            List<Case> lstCasos = new List<Case>();
            caso.OwnerId = usuario.Id;
            updateCaso(caso.Id);
            lstCasos.add(caso);
            
            Test.startTest();
            GRR_CaseTriggerHelper.crearActividadReasignacion(lstCasos, mapaCasos);
            Test.stopTest();
            
            Task tareaCreada = [SELECT Id, Type FROM Task LIMIT 1];
            System.assertEquals('Reasignación', tareaCreada.Type);    
        }
    }

    @isTest
    public static void testInformarCamposOficina() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {
            Contact contacto = crearContacto();
            Case caso = crearCaso(usuario.Id);
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, CC_Oficina__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case]);
            List<Case> lstCasos = new List<Case>();
            caso.CC_Oficina__c = contacto.AccountId;
            updateCaso(caso.Id);
            lstCasos.add(caso);

            Test.startTest();
            GRR_CaseTriggerHelper.informarCamposOficina(lstCasos, mapaCasos);
            Test.stopTest();
            
            System.assertEquals(caso.CC_Oficina__c != null, true);
            System.assertEquals(caso.CC_DAN__c != null, true);
            System.assertEquals(caso.CC_Direccion_Territorial__c != null, true);
        
        }
    }

}