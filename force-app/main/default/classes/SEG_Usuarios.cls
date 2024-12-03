//User operativo = SEG_Usuarios.usuarioOperativo();
//User supervisor = SEG_Usuarios.usuarioSupervisor();

public abstract with sharing class SEG_Usuarios {
    public static User usuarioOperativo(){
        User operativo = new User(); 
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            operativo.FirstName = 'Operador';
            operativo.LastName = '1';    
            operativo.IsActive = true; 	
            operativo.Alias = 'Operador';
            operativo.Email = 'usuario_test@test.com';
            operativo.EmailEncodingKey = 'UTF-8';
            operativo.LanguageLocaleKey = 'en_US';
            operativo.LocaleSidKey = 'en_US';
            operativo.UserRoleId = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'].Id;
            operativo.ProfileId = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'].Id;
            operativo.TimeZoneSidKey = 'America/Los_Angeles';
            operativo.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';  	
            insert operativo; 

            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo' LIMIT 1];
            
            if (permissionSet != null)
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet.Id;
                nuevoPermiso.AssigneeId = operativo.Id;

                insert nuevoPermiso;
            }
        }
        return operativo;
    }
   
    public static User usuarioSupervisor(){ 
        User supervisor = new User(); 
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            supervisor.FirstName = 'supervisor';
            supervisor.LastName = '1';    
            supervisor.IsActive = true; 	
            supervisor.Alias = 'supervi';
            supervisor.Email = 'testSEGBI@acme.com';
            supervisor.EmailEncodingKey = 'UTF-8';
            supervisor.LanguageLocaleKey = 'en_US';
            supervisor.LocaleSidKey = 'en_US';
            supervisor.UserRoleId = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'].Id;
            supervisor.ProfileId = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'].Id;
            supervisor.TimeZoneSidKey = 'America/Los_Angeles';
            supervisor.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';  	
            insert supervisor; 

            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor') LIMIT 2]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = supervisor.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
            
            CustomPermission CustomPermission = [SELECT Id FROM CustomPermission WHERE DeveloperName = 'SEG_EditarAccount' LIMIT 1];
        }
        return supervisor;
    }

}