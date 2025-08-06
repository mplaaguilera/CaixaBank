@isTest
public class CC_ServiceResourceSkill_AD_TRHan_Test {
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

        //Asignamos al agente un usuario genesys
        CC_Usuario_Genesys__c usuarioGen = new CC_Usuario_Genesys__c(
            CC_User__c = userList[0].Id,
            Name = 'LOGINTEST',
            CC_DN__c = '1234',
            CC_Acceso__c = 'Teléfono;Chat',
            CC_Negocio__c = 'CC'
        );
        insert usuarioGen;

        //Obtenemos la lista de skills y colas para buscar una cola de Stop&Go
        List<Skill> listaSkills = [SELECT Id, DeveloperName FROM Skill];

        //Creamos la relación del agente con el serviceResource para poder asignar el skill
        ServiceResource userServiceResource = new ServiceResource();
        userServiceResource.Name = usuario1.FirstName;
        userServiceResource.ResourceType = 'A';
        userServiceResource.RelatedRecordId = usuario1.Id;
        userServiceResource.IsActive = true;

        insert userServiceResource;

        //Asignamos el skill al agente
        ServiceResourceSkill userSkill = new ServiceResourceSkill();
        userSkill.SkillLevel = 10;
        userSkill.ServiceResourceId = userServiceResource.Id;
        userSkill.EffectiveStartDate = DateTime.now();
        userSkill.SkillId = listaSkills[0].Id;
        
        //Creamos el skill
        insert userSkill;
    }

    @isTest
    public static void eliminar1SkillAUsuario() 
    {
        User usuario = [SELECT Id, Name FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        CC_Usuario_Genesys__c usuarioGenesys = [SELECT Id FROM CC_Usuario_Genesys__c WHERE CC_User__c = :usuario.Id LIMIT 1];
             
        List<CC_SkillHistory__c> listaSesionesCreadas = [SELECT Id,CC_Fecha_Inicio__c, CC_SkillId__c, CC_User__c, CC_Fecha_Fin__c, CC_Usuario_Genesys__c FROM CC_SkillHistory__c];

        System.assertEquals(1, listaSesionesCreadas.size(), 'Se ha creado un registro de inicio de sesion por skills');
        System.assertEquals(usuario.Id, listaSesionesCreadas[0].CC_User__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario');
        System.assertNotEquals(Null, listaSesionesCreadas[0].CC_Fecha_Inicio__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario con fecha inicio');
        System.assertEquals(Null, listaSesionesCreadas[0].CC_Fecha_Fin__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario sin fecha fin');
        System.assertEquals(usuarioGenesys.Id, listaSesionesCreadas[0].CC_Usuario_Genesys__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario con usuarioGenesys');

        //Obtenermos el skill del agente
        ServiceResourceSkill userSkill = [SELECT Id FROM ServiceResourceSkill WHERE ServiceResourceId IN (SELECT Id FROM ServiceResource WHERE RelatedRecordId = : usuario.Id) LIMIT 1];
        
        Test.startTest();
            //Eliminamos el skill
            delete userSkill;
        Test.stopTest();


        List<CC_SkillHistory__c> listaSesiones = [SELECT Id,CC_Fecha_Inicio__c, CC_SkillId__c, CC_User__c, CC_Fecha_Fin__c, CC_Usuario_Genesys__c FROM CC_SkillHistory__c];
        System.assertEquals(1, listaSesiones.size(), 'Se ha finalizado un registro de inicio de sesion por skills');
        
        System.assertEquals(listaSesionesCreadas[0].Id, listaSesiones[0].Id, 'Se ha finalizado el registro creado antes');
        
        System.assertEquals(usuario.Id, listaSesiones[0].CC_User__c, 'Se ha finalizado un registro de inicio de sesion por skills para el usuario');
        System.assertNotEquals(Null, listaSesiones[0].CC_Fecha_Inicio__c, 'Se ha finalizado un registro de inicio de sesion por skills para el usuario con fecha inicio');
        System.assertNotEquals(Null, listaSesiones[0].CC_Fecha_Fin__c, 'Se ha modificado la fecha fin del registro porque se ha finalizado la sesión');
        System.assertEquals(usuarioGenesys.Id, listaSesiones[0].CC_Usuario_Genesys__c, 'Se ha finalizado un registro de inicio de sesion por skills para el usuario con usuarioGenesys');
        
    }

    @isTest
    public static void eliminarMultiplesSkillsAUsuario() 
    {
        User usuario = [SELECT Id, Name FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        CC_Usuario_Genesys__c usuarioGenesys = [SELECT Id FROM CC_Usuario_Genesys__c WHERE CC_User__c = :usuario.Id LIMIT 1];
             
        ServiceResourceSkill userSkillOld = [SELECT Id, SkillId, ServiceResourceId FROM ServiceResourceSkill WHERE ServiceResourceId IN (SELECT Id FROM ServiceResource WHERE RelatedRecordId = : usuario.Id) LIMIT 1];
        
        //Obtenemos la lista de skills y colas para buscar una cola de Stop&Go
        List<Skill> listaSkills = [SELECT Id, DeveloperName FROM Skill WHERE Id <> :userSkillOld.SkillId];
        Integer maxSkillNumber = 3;
        if (listaSkills.size() < 3)
        {
            maxSkillNumber = listaSkills.size();
        }
        
        List<ServiceResourceSkill> listaSkillsAgente = new List<ServiceResourceSkill>();
        for (Integer i = 0; i < maxSkillNumber; i++)
        {
            //Asignamos el skill al agente
            ServiceResourceSkill userSkill = new ServiceResourceSkill();
            userSkill.SkillLevel = 10;
            userSkill.ServiceResourceId = userSkillOld.ServiceResourceId;
            userSkill.EffectiveStartDate = DateTime.now();
            userSkill.SkillId = listaSkills[i].Id;
            listaSkillsAgente.add(userSkill);
        }

        Test.startTest();
            //Creamos la lista de skills
            insert listaSkillsAgente;

            List<CC_SkillHistory__c> listaSesionesCreadas = [SELECT Id,CC_Fecha_Inicio__c, CC_SkillId__c, CC_User__c, CC_Fecha_Fin__c, CC_Usuario_Genesys__c FROM CC_SkillHistory__c];

            System.assertEquals((maxSkillNumber + 1), listaSesionesCreadas.size(), 'Se han creado registros de inicio de sesion por skills');
            System.assertEquals(usuario.Id, listaSesionesCreadas[0].CC_User__c);
            System.assertNotEquals(Null, listaSesionesCreadas[0].CC_Fecha_Inicio__c);
            System.assertEquals(Null, listaSesionesCreadas[0].CC_Fecha_Fin__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario sin fecha fin');
            System.assertEquals(usuarioGenesys.Id, listaSesionesCreadas[0].CC_Usuario_Genesys__c);
            
            //Añadimos también a la lista el skill inicial para eliminar todos
            listaSkillsAgente.add(userSkillOld);
            //Eliminamos la lista de skills
            delete listaSkillsAgente;
        Test.stopTest();


        List<CC_SkillHistory__c> listaSesiones = [SELECT Id,CC_Fecha_Inicio__c, CC_SkillId__c, CC_User__c, CC_Fecha_Fin__c, CC_Usuario_Genesys__c FROM CC_SkillHistory__c];
        System.assertEquals((maxSkillNumber + 1), listaSesiones.size(), 'Se han finalizado registros de inicio de sesion por skills');
        
        System.assertEquals(listaSesionesCreadas[0].Id, listaSesiones[0].Id, 'Se ha finalizado el registro creado antes');
        
        System.assertEquals(usuario.Id, listaSesiones[0].CC_User__c);
        System.assertNotEquals(Null, listaSesiones[0].CC_Fecha_Inicio__c);
        System.assertNotEquals(Null, listaSesiones[0].CC_Fecha_Fin__c, 'Se ha modificado la fecha fin del registro porque se ha finalizado la sesión');
        System.assertEquals(usuarioGenesys.Id, listaSesiones[0].CC_Usuario_Genesys__c);
        
    }
}