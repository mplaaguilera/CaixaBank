@isTest
public with sharing class FRA_GenesysCloud_CTIExtensions_Test {
    @TestSetup
    public static void testSetup() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User usuario = new User();
            usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_Caixabank'].Id;
            usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
            usuario.FirstName = 'Fraude';
            usuario.LastName = 'Prueba';
            usuario.Alias = uniqueName.substring(18, 23);
            usuario.Email = uniqueName + '@test' + orgId + '.org';
            usuario.Username = uniqueName + '@test' + orgId + '.org';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.LanguageLocaleKey = 'es';
            usuario.LocaleSidKey = 'es_ES';
            usuario.TimezonesIdKey = 'Europe/Madrid';
            insert usuario;
    
            List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
            for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador')]) {
                PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                psAssignment.AssigneeId = usuario.Id;
                psAssignment.PermissionSetId = ps.Id;
                psAssignments.add(psAssignment);
            }
            insert psAssignments;
        }
    }

    @isTest
    public static void testOnClickToDial() {
		User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Case caso = new Case();
            insert caso;
            Map<String, Object> input1 = new Map<String, Object>{'object' => 'Case', 'objectId' => caso.Id};

            Map<String, Object> input2 = new Map<String, Object>{'object' => 'Account'};

            Test.startTest();
            FRA_GenesysCloud_CTIExtensions ctiExtensions = new FRA_GenesysCloud_CTIExtensions();
            String retorno1 = ctiExtensions.onClickToDial(JSON.serialize(input1));
            String retorno2 = ctiExtensions.onClickToDial(JSON.serialize(input2));
            Test.stopTest();

            Map<String, Object> clickToDialData = (Map<String, Object>)JSON.deserializeUntyped(retorno1);
            System.assert(clickToDialData.containsKey('attributes'), 'Deberían haberse añadido custom attributes a la respuesta.');
            System.assertEquals('', retorno2, 'El retorno debería ser un String vacío al ser no ser object ni "Case" ni "Opportunity".');
        }
    }
}