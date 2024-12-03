@isTest
public class CC_ServiceResourceSkill_AI_TRHan_Test {
    @testSetup
    public static void testSetup()
    {
        //crear usuarios CC
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        usuario1.FirstName = 'first 1';
        usuario1.LastName = 'last1';
        usuario1.Email = 'tuser000@amamama.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        userList.add(usuario1);
        insert userList;

        CC_Usuario_Genesys__c usuarioGen = new CC_Usuario_Genesys__c(
            CC_User__c = userList[0].Id,
            Name = 'LOGINTEST',
            CC_DN__c = '1234',
            CC_Acceso__c = 'Teléfono;Chat',
            CC_Negocio__c = 'CC'
        );
        insert usuarioGen;

    }

    @isTest
    public static void asignarSkillsAUsuario() 
    {
        User usuario = [SELECT Id, Name FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        CC_Usuario_Genesys__c usuarioGenesys = [SELECT Id FROM CC_Usuario_Genesys__c WHERE CC_User__c = :usuario.Id LIMIT 1];
        
        List<Skill> listaSkills = [SELECT Id, DeveloperName FROM Skill];
        
        ServiceResource userServiceResource = new ServiceResource();
        userServiceResource.Name = usuario.Name;
        userServiceResource.ResourceType = 'A';
        userServiceResource.RelatedRecordId = usuario.Id;
        userServiceResource.IsActive = true;

        insert userServiceResource;

        //List<ServiceResourceSkill> userSkillList = new List<ServiceResourceSkill>();
        ServiceResourceSkill userSkill = new ServiceResourceSkill();
        userSkill.SkillLevel = 10;
        userSkill.ServiceResourceId = userServiceResource.Id;
        userSkill.EffectiveStartDate = DateTime.now();
        userSkill.SkillId = listaSkills[0].Id;
        
        Test.startTest();
            insert userSkill;
        Test.stopTest();

        List<CC_SkillHistory__c> listaSesiones = [SELECT Id,CC_Fecha_Inicio__c, CC_SkillId__c, CC_User__c, CC_Fecha_Fin__c, CC_Usuario_Genesys__c FROM CC_SkillHistory__c];

        System.assertEquals(1, listaSesiones.size(), 'Se ha creado un registro de inicio de sesion por skills');
        System.assertEquals(usuario.Id, listaSesiones[0].CC_User__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario');
        System.assertNotEquals(Null, listaSesiones[0].CC_Fecha_Inicio__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario con fecha inicio');
        System.assertEquals(Null, listaSesiones[0].CC_Fecha_Fin__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario sin fecha fin');
        System.assertEquals(usuarioGenesys.Id, listaSesiones[0].CC_Usuario_Genesys__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario con usuarioGenesys');
    }

}