@isTest
public with sharing class FRA_TestDataFactory {
    public static User usuarioPruebasFRA() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usuario = new User();
        usuario.IsActive = true;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
        usuario.FirstName = 'FRA Clases Test';
        usuario.LastName = 'Prueba Clases Test';
        usuario.Alias = uniqueName.substring(18, 23);
        usuario.Email = uniqueName + '@test' + orgId + '.org';
        usuario.Username = uniqueName + '@test' + orgId + '.org';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.TimezonesIdKey = 'Europe/Madrid';
        usuario.EmployeeNumber = 'U0199999';
        insert usuario;

        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador')]) {
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;

        return usuario;
    }
    
    public static User usuarioPruebasIntSupFRA() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usuario = new User();
        usuario.IsActive = true;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
        usuario.FirstName = 'FRA Int Sup Clases Test';
        usuario.LastName = 'Prueba Int Clases Test';
        usuario.Alias = uniqueName.substring(18, 23);
        usuario.Email = uniqueName + '@test' + orgId + '.org';
        usuario.Username = uniqueName + '@test' + orgId + '.org';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.TimezonesIdKey = 'Europe/Madrid';
        usuario.EmployeeNumber = 'U0199999';
        insert usuario;
    
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Supervisor','FRA_PS_Integracion')]) {
        	PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;

        return usuario;
        
    }
    
    public static User usuarioPruebasIntFRA() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usuario = new User();
        usuario.IsActive = true;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
        usuario.FirstName = 'FRA Int Clases Test';
        usuario.LastName = 'Prueba Int Clases Test';
        usuario.Alias = uniqueName.substring(18, 23);
        usuario.Email = uniqueName + '@test' + orgId + '.org';
        usuario.Username = uniqueName + '@test' + orgId + '.org';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.TimezonesIdKey = 'Europe/Madrid';
        usuario.EmployeeNumber = 'U0199999';
        insert usuario;
    
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador','FRA_PS_Integracion')]) {
        	PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;

        return usuario;
        
    }
    
    public static User usuarioSoporteFRA() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usuario = new User();
        usuario.IsActive = true;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
        usuario.FirstName = 'FRA Clases Test';
        usuario.LastName = 'Prueba Clases Test';
        usuario.Alias = uniqueName.substring(18, 23);
        usuario.Email = uniqueName + '@test' + orgId + '.org';
        usuario.Username = uniqueName + '@test' + orgId + '.org';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.TimezonesIdKey = 'Europe/Madrid';
        usuario.EmployeeNumber = 'U0199999';
        insert usuario;

        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador','FRA_PS_Soporte')]) {
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;

        return usuario;
    }
    
}