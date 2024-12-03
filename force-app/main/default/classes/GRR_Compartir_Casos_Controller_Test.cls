@isTest
public with sharing class GRR_Compartir_Casos_Controller_Test {

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
        Group grupo = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName = 'GRR_Grupo_Compartir_Usuarios' AND Type = 'Regular' LIMIT 1];
        GroupMember miembroGrupo = new GroupMember();
        miembroGrupo.GroupId = grupo.Id;
        miembroGrupo.UserOrGroupId = usuario.Id;
        insert miembroGrupo;
    }

    private static Case crearCaso() {
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Prueba Compartir Test'
        );           
        insert caso;
        return caso;
    }

    @isTest
    public static void testGetCaseTeamMembers() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            Integer numeroTeamMembersInicial = [SELECT COUNT() FROM CaseTeamMember WHERE ParentId = :caso.Id];

            User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
            CaseTeamRole rol = [SELECT Id FROM CaseTeamRole WHERE Name LIKE 'GRR_%' LIMIT 1];
            CaseTeamMember member = new CaseTeamMember();
            member.ParentId = caso.Id; 
            member.MemberId = usuario.Id;
            member.TeamRoleId = rol.Id;
            insert member;
            
            Test.startTest();
            List<CaseTeamMember> lstTeamMembersFinal = GRR_Compartir_Casos_Controller.getCaseTeamMembers(caso.Id);
            System.assertNotEquals(numeroTeamMembersInicial, lstTeamMembersFinal.size());
            System.assertEquals(0, numeroTeamMembersInicial);
            System.assertEquals(1, lstTeamMembersFinal.size());
            Test.stopTest();
        }
    }

    @isTest
    public static void testGetUsuarios() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

            Test.startTest();
            List<GroupMember> lstGroupMembers = GRR_Compartir_Casos_Controller.getUsuarios();
            Set<Id> idsUsuariosGrupo = new Set<Id>();

            for(GroupMember member : lstGroupMembers){
                idsUsuariosGrupo.add(member.UserOrGroupId);
            }
            
            System.assertNotEquals(0, lstGroupMembers.size());
            System.assertEquals(true, idsUsuariosGrupo.contains(usuario.Id));
            Test.stopTest();
        }
    }

    @isTest
    public static void testGetCaseTeamRoles() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            List<CaseTeamRole> lstTeamRoles = GRR_Compartir_Casos_Controller.getCaseTeamRoles();
            System.assertNotEquals(0, lstTeamRoles.size());
            Test.stopTest();
        }
    }

    @isTest
    public static void testCompartirEliminarUsuarioCaso() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            Integer numeroTeamMembersInicial = [SELECT COUNT() FROM CaseTeamMember WHERE ParentId = :caso.Id];

            List<Map<String, String>> records = new List<Map<String, String>>();
            Map<String, String> recordMap = new Map<String, String>();

            User usuario = [SELECT Id, Name FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
            CaseTeamRole rol = [SELECT Id FROM CaseTeamRole WHERE Name LIKE 'GRR_%' LIMIT 1];
            recordMap.put('Usuario', usuario.Name);
            recordMap.put('UsuarioId', usuario.Id);
            recordMap.put('RoleId', rol.Id);
            records.add(recordMap);

            Test.startTest();
            List<String> lstUsuariosCompartir = GRR_Compartir_Casos_Controller.compartirUsuarioCaso(records, caso.Id);
            System.assertNotEquals(0, lstUsuariosCompartir.size());
            System.assertEquals(0, numeroTeamMembersInicial);
            System.assertEquals(1, [SELECT COUNT() FROM CaseTeamMember WHERE ParentId = :caso.Id]);
            
            List<String> lstUsuariosEliminar = GRR_Compartir_Casos_Controller.eliminarUsuarioCaso(records, caso.Id);
            System.assertNotEquals(0, lstUsuariosEliminar.size());
            System.assertEquals(0, [SELECT COUNT() FROM CaseTeamMember WHERE ParentId = :caso.Id]);

            Test.stopTest();
        }
    }
}