public abstract with sharing class TMS_Usuarios {
 public static User usuarioSupervisor(){
        User supervisor = new User();

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            supervisor.FirstName = 'SupervisorTMS';
            supervisor.LastName = '1';    
            supervisor.IsActive = true; 	
            supervisor.Alias = 'Superv1';
            supervisor.Email = 'usuario_test@test.com';
            supervisor.EmailEncodingKey = 'ISO-8859-1';
            supervisor.LanguageLocaleKey = 'es';
            supervisor.LocaleSidKey = 'es_ES';
            supervisor.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Testamentarías'].Id;
            supervisor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMS_UsuarioCaixabank'].Id;
            supervisor.TimeZoneSidKey = 'Europe/Madrid';
            supervisor.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com'; 
	
            insert supervisor;   


            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'TMS_PS_Supervisor' LIMIT 1];
            if (permissionSet != null)
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet.Id;
                nuevoPermiso.AssigneeId = supervisor.Id;

                insert nuevoPermiso;
            }
            Group grp = [SELECT Id FROM Group WHERE DeveloperName = 'TMS_Grupo_BC' LIMIT 1] ;

            groupMember gp = new groupMember(GroupId = grp.Id);
            gp.UserOrGroupId = supervisor.Id;
            insert gp;
        }

        

        return supervisor;
    }
   
    public static User usuarioLetrado(){
        User letrado = new User();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            letrado.FirstName = 'LetradoTMS';
            letrado.LastName = '1';     
            letrado.IsActive = true; 	
            letrado.Alias = 'LetTMS';
            letrado.Email = 'usuario_test@test.com';
            letrado.EmailEncodingKey = 'ISO-8859-1';
            letrado.LanguageLocaleKey = 'es';
            letrado.LocaleSidKey = 'es_ES';
            letrado.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Testamentarías'].Id;
            letrado.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMS_UsuarioCaixabank'].Id;
            letrado.TimeZoneSidKey = 'Europe/Madrid';
            letrado.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com'; 

            insert letrado; 

            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'TMS_PS_Letrado' LIMIT 1];
            if (permissionSet != null)
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet.Id;
                nuevoPermiso.AssigneeId = letrado.Id;

                insert nuevoPermiso;
            }

            List<Group> grp = [SELECT Id FROM Group WHERE (DeveloperName = 'TMS_Grupo_BC' OR DeveloperName = 'TMS_Letrados')] ;
            List<GroupMember> gpsMember = new List<GroupMember>();

            for(Group grupo : grp){
                groupMember gp = new groupMember(GroupId = grupo.Id);
                gp.UserOrGroupId = letrado.Id;
                gpsMember.add(gp);
            }
            
            insert gpsMember;
        } 
        return letrado;
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
            admin.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Testamentarías'].Id;
            admin.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
            admin.TimeZoneSidKey = 'Europe/Madrid';
            admin.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
	
            insert admin;

    
            List<PermissionSetAssignment> nuevosPermisos = new List<PermissionSetAssignment>();
            List<PermissionSet> permissionSet = [SELECT Id FROM PermissionSet WHERE Name LIKE 'TMS%'];
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
    public static User usuarioAdminTMS(){
        User adminTMS = new User();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {    
            adminTMS.FirstName = 'AdministradorTMS';
            adminTMS.LastName = 'adminTMS';
            adminTMS.IsActive = true;
            adminTMS.Alias = 'adminTMS';
            adminTMS.Email = 'usuario_test@test.com';
            adminTMS.EmailEncodingKey = 'ISO-8859-1';
            adminTMS.LanguageLocaleKey = 'es';
            adminTMS.LocaleSidKey = 'es_ES';
            adminTMS.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Testamentarías'].Id;
            adminTMS.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMS_UsuarioCaixabank'].Id;
            adminTMS.TimeZoneSidKey = 'Europe/Madrid';
            adminTMS.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            	
            insert adminTMS;

            List<Group> grp = [SELECT Id FROM Group WHERE (DeveloperName = 'TMS_Admin' OR DeveloperName = 'TMS_Letrados' OR DeveloperName = 'TMS_Grupo_BC' OR DeveloperName = 'TMS_Generico')] ;
            List<GroupMember> gpsMember = new List<GroupMember>();

            for(Group grupo : grp){
                groupMember gp = new groupMember(GroupId = grupo.Id);
                gp.UserOrGroupId = adminTMS.Id;
                gpsMember.add(gp);
            }
            
            insert gpsMember;


            List<PermissionSetAssignment> nuevosPermisos = new List<PermissionSetAssignment>();
            List<PermissionSet> permissionSet = [SELECT Id FROM PermissionSet WHERE (Name = 'TMS_PS_Admin' OR Name = 'TMS_PS_Letrado')];
            for (PermissionSet permissionSet1:permissionSet )
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet1.Id;
                nuevoPermiso.AssigneeId = adminTMS.Id;
                nuevosPermisos.add(nuevoPermiso);
            } 
            insert nuevosPermisos;
          }
        return adminTMS;
    }

    public static User usuarioAPI(){
        User responsable = new User();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            responsable.FirstName = 'TMSApi';
            responsable.LastName = '1';     
            responsable.IsActive = true; 	
            responsable.Alias = 'API_tms';
            responsable.Email = 'usuario_test@test.com';
            responsable.EmailEncodingKey = 'ISO-8859-1';
            responsable.LanguageLocaleKey = 'es';
            responsable.LocaleSidKey = 'es_ES';
            responsable.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Testamentarías'].Id;
            responsable.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMS_UsuarioCaixabank'].Id;
            responsable.TimeZoneSidKey = 'Europe/Madrid';
            responsable.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com'; 

            insert responsable; 

            List<PermissionSetAssignment> nuevosPermisos = new List<PermissionSetAssignment>();
            List<PermissionSet> permissionSet = [SELECT Id FROM PermissionSet WHERE (Name = 'TMS_PS_Admin' OR Name = 'TMS_API_Only')];
            for (PermissionSet permissionSet1:permissionSet )
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet1.Id;
                nuevoPermiso.AssigneeId = responsable.Id;
                nuevosPermisos.add(nuevoPermiso);
            } 
            insert nuevosPermisos;
        } 
        return responsable;
    }
}