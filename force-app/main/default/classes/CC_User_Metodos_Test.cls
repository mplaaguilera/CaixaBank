@isTest
public class CC_User_Metodos_Test {

    @TestSetup
    static void makeData(){

        Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileIdAdmin;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'usuarioAdminTest@test.test';
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        insert usuario1;

        String profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Operador básico CCO'].Id;

        User usuario = new User();
        usuario.Username = 'usertest49i2342@test.test';
        usuario.Email = 'emailtest@test.test';  
        usuario.LastName = 'usuario Test';
        usuario.ProfileId = profileId;
        usuario.Alias = 'alias2';
        usuario.TimeZoneSidKey = 'GMT';
        usuario.LocaleSidKey = 'es_ES';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.LanguageLocaleKey = 'en_US';
        usuario.isActive = true; 
        insert usuario;

    }

    @isTest
    public static void asignarPublicGroupPerfil() {

            User user1 = [SELECT id from user where Username = 'usertest49i2342@test.test' LIMIT 1];
            User admin = [SELECT id from user where Username = 'usuarioAdminTest@test.test'LIMIT 1];
            List<Id> listaUsuarios = new List<Id>();
            listaUsuarios.add(user1.id);

            Test.startTest();
            System.runAs(admin){
            CC_User_Metodos.usuariosGruposPublicos(listaUsuarios);
            }
            Test.stopTest();
                   
            Group grupo = [SELECT id, Type FROM Group WHERE Type = 'Regular' AND DeveloperName = 'CC_Operadores' LIMIT 1];
            GroupMember groupM = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =:grupo.id AND UserOrGroupId = :user1.Id LIMIT 1];

            Boolean resultado = false;
            if(groupM.UserOrGroupId != null && groupM.UserOrGroupId == user1.Id)
            {
                resultado = true;
            }

            System.assertEquals(true, resultado, 'No se ha encontrado el usuario en el public group');
        
    }

}