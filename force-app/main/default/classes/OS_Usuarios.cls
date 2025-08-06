//User operador = OS_Usuarios.usuarioOperador();
//User responsable = OS_Usuarios.usuarioResponsable();
//User admin = OS_Usuarios.usuarioAdmin();

public abstract with sharing class OS_Usuarios {
    public static User usuarioOperador(){
        User operador = new User();

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            operador.FirstName = 'OperadorOS';
            operador.LastName = '1';    
            operador.IsActive = true; 	
            operador.Alias = 'Operador';
            operador.Email = 'usuario_test@test.com';
            operador.EmailEncodingKey = 'ISO-8859-1';
            operador.LanguageLocaleKey = 'es';
            operador.LocaleSidKey = 'es_ES';
            operador.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'COPS'].Id;
            operador.ProfileId = [SELECT Id FROM Profile WHERE Name = 'OS_Operador'].Id;
            operador.TimeZoneSidKey = 'Europe/Madrid';
            operador.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com'; 
            operador.OS_Cola_Backup__c = '2N CCI Holabank';
            operador.OS_Inicio_Vigencia_Agente_Backup__c = System.today();
            operador.OS_Fin_Vigencia_Agente_Backup__c = System.today().addDays(+1); 	
            insert operador;   

            Group grp = [SELECT Id FROM Group WHERE DeveloperName = 'OS_Calidad_Creditos_Documentarios' LIMIT 1] ;

            groupMember gp = new groupMember(GroupId = grp.Id);
            gp.UserOrGroupId = operador.Id;
            insert gp;

            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'OSPSOperador' LIMIT 1];
            if (permissionSet != null)
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet.Id;
                nuevoPermiso.AssigneeId = operador.Id;

                insert nuevoPermiso;
            }
        }
        return operador;
    }
   
    public static User usuarioResponsable(){
        User responsable = new User();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            responsable.FirstName = 'ResponsableOS';
            responsable.LastName = '1';     
            responsable.IsActive = true; 	
            responsable.Alias = 'Resp1';
            responsable.Email = 'usuario_test@test.com';
            responsable.EmailEncodingKey = 'ISO-8859-1';
            responsable.LanguageLocaleKey = 'es';
            responsable.LocaleSidKey = 'es_ES';
            responsable.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'COPS'].Id;
            responsable.ProfileId = [SELECT Id FROM Profile WHERE Name = 'OS_Responsable'].Id;
            responsable.TimeZoneSidKey = 'Europe/Madrid';
            responsable.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com'; 
            responsable.OS_Agente_Backup__c = [SELECT Id FROM User LIMIT 1].Id;
            insert responsable; 

            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'OS_PS_Responsable' LIMIT 1];
            if (permissionSet != null)
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet.Id;
                nuevoPermiso.AssigneeId = responsable.Id;

                insert nuevoPermiso;
            } 
        } 
        return responsable;
    }

    public static User usuarioAdmin(){
        User admin = new User();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {    
            admin.FirstName = 'AdministradorOS';
            admin.LastName = 'adminOS';
            admin.IsActive = true;
            admin.Alias = 'admin';
            admin.Email = 'usuario_test@test.com';
            admin.EmailEncodingKey = 'ISO-8859-1';
            admin.LanguageLocaleKey = 'es';
            admin.LocaleSidKey = 'es_ES';
            admin.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'COPS'].Id;
            admin.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
            admin.TimeZoneSidKey = 'Europe/Madrid';
            admin.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            admin.OS_Cola_Backup__c = 'CCI Holabank';
            admin.OS_Inicio_Vigencia_Agente_Backup__c = System.today(); 
            admin.OS_Fin_Vigencia_Agente_Backup__c = System.today().addDays(+1); 	
            insert admin;

    
            List<PermissionSetAssignment> nuevosPermisos = new List<PermissionSetAssignment>();
            List<PermissionSet> permissionSet = [SELECT Id FROM PermissionSet WHERE Name LIKE 'OS%' AND LicenseId = null];
            for (PermissionSet permissionSet1:permissionSet )
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet1.Id;
                nuevoPermiso.AssigneeId = admin.Id;
                nuevosPermisos.add(nuevoPermiso);
            } 
            insert nuevosPermisos;
          }
        return admin;
    }
}