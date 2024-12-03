@isTest
public class CC_ServiceResourceSkill_Test {
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

        //Creamos la relación del agente con el serviceResource para poder asignar el skill
        ServiceResource userServiceResource = new ServiceResource();
        userServiceResource.Name = usuario1.FirstName;
        userServiceResource.ResourceType = 'A';
        userServiceResource.RelatedRecordId = usuario1.Id;
        userServiceResource.IsActive = true;

        insert userServiceResource;

        List<Skill> listaSkills = [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName IN ('Agente', 'Hidden', 'ES', 'CA')];
        List<ServiceResourceSkill> listaServResoyrceSkills = new List<ServiceResourceSkill>();
        for (Skill skillParaUsuario : listaSkills)
        {
            //Asignamos el skill al agente
            ServiceResourceSkill userSkill = new ServiceResourceSkill();
            userSkill.SkillLevel = 10;
            userSkill.ServiceResourceId = userServiceResource.Id;
            userSkill.EffectiveStartDate = DateTime.now();
            userSkill.SkillId = skillParaUsuario.Id;
            listaServResoyrceSkills.add(userSkill);
        }
        //Creamos el skill
        insert listaServResoyrceSkills;


        Integer contador = 0;
        List<String> listaQueue = new List<String>();
        List<String> listaQueueCrearMiembros = new List<String>();
        //Obtenemos la lista de skills y colas para buscar las colas de Stop&Go
        List<Skill> listaSkillsToCreateQueue = [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName NOT IN ('Agente', 'Hidden', 'ES', 'CA') ORDER BY DeveloperName ASC LIMIT 3];
        for (Skill skillToQueue : listaSkillsToCreateQueue)
        {
            String stopGoQueueHiddenES = 'CC_Hidden_' + skillToQueue.DeveloperName + '_ES_stopGo';
            String stopGoQueueAgenteES = 'CC_Agente_' + skillToQueue.DeveloperName + '_ES_stopGo';
            String stopGoQueueHiddenCA = 'CC_Hidden_' + skillToQueue.DeveloperName + '_CA_stopGo';
            String stopGoQueueAgenteCA = 'CC_Agente_' + skillToQueue.DeveloperName + '_CA_stopGo';

            listaQueue.add(stopGoQueueHiddenES);
            listaQueue.add(stopGoQueueAgenteES);
            listaQueue.add(stopGoQueueHiddenCA);
            listaQueue.add(stopGoQueueAgenteCA);

            //Solo queremos que se añada el usuario a las colas del primer Skill
            if (contador == 0)
            {
                listaQueueCrearMiembros.add(stopGoQueueHiddenES);
                listaQueueCrearMiembros.add(stopGoQueueAgenteES);
                listaQueueCrearMiembros.add(stopGoQueueHiddenCA);
                listaQueueCrearMiembros.add(stopGoQueueAgenteCA);
                contador++;
            }
        }

        List<Group> listaQueuesExistentes = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :listaQueue AND QueueRoutingConfigId <> Null];
        List<QueueRoutingConfig> queueRooutingConfigList = [SELECT Id, DeveloperName FROM QueueRoutingConfig WHERE DeveloperName = 'CC_Chat_Empleados'];

        List<Group> listaQueuesCreate = new List<Group>();
        Integer numero = 0;
        //Si no existen las cola de stop&Go, las creamos
        for (String colaName : listaQueue)
        {
            Group stopGoQueue = new Group();
            stopGoQueue.DeveloperName = colaName;
            stopGoQueue.Name = colaName;
            stopGoQueue.Type = 'Queue';
            stopGoQueue.QueueRoutingConfigId = queueRooutingConfigList[0].Id;
            System.debug(stopGoQueue);
            if (listaQueuesExistentes == null || listaQueuesExistentes.isEmpty())
            {
                listaQueuesCreate.add(stopGoQueue);
            }
            else
            {
                Boolean existeEnQueue = false;
                for (Group colaExistente : listaQueuesExistentes)
                {
                    if (colaExistente.DeveloperName.equals(colaName))
                    {
                        existeEnQueue = true;
                    }
                }

                if (!existeEnQueue)
                {
                    listaQueuesCreate.add(stopGoQueue);
                }
            }
        }

        insert listaQueuesCreate;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            listaQueuesExistentes = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :listaQueueCrearMiembros AND QueueRoutingConfigId <> Null];
            List<GroupMember> miembrosList =  new List<GroupMember>();
            for (Group queueAsignar : listaQueuesExistentes)
            {
                GroupMember miembroQueue = new GroupMember();
                //Asignar agente a cola Stop&Go 
                miembroQueue.GroupId = queueAsignar.Id;
                miembroQueue.UserOrGroupId = usuario1.Id;
                miembrosList.add(miembroQueue);
            }

            insert miembrosList;
        }
        
    }

    @isTest
    public static void crearSkillAUsuarioComprobarAsignacionQueueStopGo() 
    {
        User usuario = [SELECT Id, Name FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        CC_Usuario_Genesys__c usuarioGenesys = [SELECT Id FROM CC_Usuario_Genesys__c WHERE CC_User__c = :usuario.Id LIMIT 1];
        
        List<Skill> listaSkills = [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName NOT IN ('Agente', 'Hidden', 'ES', 'CA') ORDER BY DeveloperName ASC LIMIT 3];
        ServiceResource userServiceResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = : usuario.Id LIMIT 1];
       
        List<GroupMember> queueMemberList = [SELECT GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :usuario.Id AND Group.QueueRoutingConfigId <> null];
        System.assertEquals(4, queueMemberList.size(), 'Se ha añadido al agente a las 4 colas de Stop&Go');

        //Creamos el skill del agente
        List<Id> userSkillIdList = new List<Id>();
        ServiceResourceSkill userSkill = new ServiceResourceSkill();
        userSkill.SkillLevel = 10;
        userSkill.ServiceResourceId = userServiceResource.Id;
        userSkill.EffectiveStartDate = DateTime.now();
        userSkill.SkillId = listaSkills[1].Id; //Descartamos el primer Skill, porque ya está el agente dentro de la cola (se añade en el método del setup)
       
        Test.startTest();
            insert userSkill;
        Test.stopTest();

        List<CC_SkillHistory__c> listaSesiones = [SELECT Id,CC_Fecha_Inicio__c, CC_SkillId__c, CC_User__c, CC_Fecha_Fin__c, CC_Usuario_Genesys__c FROM CC_SkillHistory__c];

        System.assertEquals(5, listaSesiones.size(), 'Se ha creado un registro de inicio de sesion por skills');
        System.assertEquals(usuario.Id, listaSesiones[0].CC_User__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario');
        System.assertNotEquals(Null, listaSesiones[0].CC_Fecha_Inicio__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario con fecha inicio');
        System.assertEquals(Null, listaSesiones[0].CC_Fecha_Fin__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario sin fecha fin');
        System.assertEquals(usuarioGenesys.Id, listaSesiones[0].CC_Usuario_Genesys__c, 'Se ha creado un registro de inicio de sesion por skills para el usuario con usuarioGenesys');
        
        queueMemberList = [SELECT GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :usuario.Id AND Group.QueueRoutingConfigId <> null];
        System.assertEquals(6, queueMemberList.size(), 'Se ha añadido al agente a las 4 colas de Stop&Go');
        
    }

    @isTest
    public static void quitarSkillAUsuarioComprobarEliminacionQueueStopGo() 
    {
        User usuario = [SELECT Id, Name FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        CC_Usuario_Genesys__c usuarioGenesys = [SELECT Id FROM CC_Usuario_Genesys__c WHERE CC_User__c = :usuario.Id LIMIT 1];
        
        //Obtenemos la lista de skills y colas para buscar las colas de Stop&Go
        List<Skill> listaSkills = [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName NOT IN ('Agente', 'Hidden', 'ES', 'CA') ORDER BY DeveloperName ASC LIMIT 3];

        ServiceResource userServiceResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = : usuario.Id LIMIT 1];
        //Creamos el skill del agente
        ServiceResourceSkill userSkill = new ServiceResourceSkill();
        userSkill.SkillLevel = 10;
        userSkill.ServiceResourceId = userServiceResource.Id;
        userSkill.EffectiveStartDate = DateTime.now();
        userSkill.SkillId = listaSkills[0].Id;
        insert userSkill;

        Test.startTest();
            //Comprobamos que el agente está en las colas de Stop&Go
            List<GroupMember> queueMemberList = [SELECT GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :usuario.Id AND Group.QueueRoutingConfigId <> null];
            System.assertEquals(4, queueMemberList.size(), 'El agente pertenece a las 4 colas de Stop&Go');
            
            delete userSkill;
        Test.stopTest();

        List<CC_SkillHistory__c> listaSesionesFinalizadas = [SELECT Id,CC_Fecha_Inicio__c, CC_SkillId__c, CC_SkillDescription__c, CC_User__c, CC_Fecha_Fin__c, CC_Usuario_Genesys__c 
                                                    FROM CC_SkillHistory__c WHERE CC_Fecha_Fin__c <> Null];

        System.assertEquals(1, listaSesionesFinalizadas.size(), 'Se ha finalizado un registro de inicio de sesion por skills');
        System.assertEquals(usuario.Id, listaSesionesFinalizadas[0].CC_User__c);
        System.assertNotEquals(Null, listaSesionesFinalizadas[0].CC_Fecha_Inicio__c);
        System.assertNotEquals(Null, listaSesionesFinalizadas[0].CC_Fecha_Fin__c, 'Se ha modificado la fecha fin del registro porque se ha finalizado la sesión');
        System.assertEquals(usuarioGenesys.Id, listaSesionesFinalizadas[0].CC_Usuario_Genesys__c);
        System.assertEquals(listaSkills[0].DeveloperName, listaSesionesFinalizadas[0].CC_SkillDescription__c);
        
        //Comprobamos que se ha eliminado el agente de las colas de Stop&Go
        queueMemberList = [SELECT GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :usuario.Id AND Group.QueueRoutingConfigId <> null];
        System.assertEquals(0, queueMemberList.size(), 'Se ha eliminado el agente de las colas de Stop&Go');  
    }

    @isTest
    public static void quitarSkillIdiomaAUsuarioComprobarEliminacionQueueStopGo() 
    {
        User usuario = [SELECT Id, Name FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        CC_Usuario_Genesys__c usuarioGenesys = [SELECT Id FROM CC_Usuario_Genesys__c WHERE CC_User__c = :usuario.Id LIMIT 1];
        
        ServiceResource userServiceResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = : usuario.Id LIMIT 1];
        
        //Obtenemos la lista de skills y colas para buscar las colas de Stop&Go
        List<ServiceResourceSkill> userSkill = [SELECT Id, Skill.DeveloperName  FROM ServiceResourceSkill WHERE Skill.DeveloperName = 'ES' AND ServiceResourceId = :userServiceResource.Id];

        Test.startTest();
            //Comprobamos que el agente está en las colas de Stop&Go
            List<GroupMember> queueMemberList = [SELECT GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :usuario.Id AND Group.QueueRoutingConfigId <> null];
            System.assertEquals(4, queueMemberList.size(), 'El agente pertenece a las 4 colas de Stop&Go');
            
            delete userSkill;
        Test.stopTest();

        List<CC_SkillHistory__c> listaSesionesFinalizadas = [SELECT Id,CC_Fecha_Inicio__c, CC_SkillId__c, CC_SkillDescription__c, CC_User__c, CC_Fecha_Fin__c, CC_Usuario_Genesys__c 
                                                    FROM CC_SkillHistory__c WHERE CC_Fecha_Fin__c <> Null];

        System.assertEquals(1, listaSesionesFinalizadas.size(), 'Se ha finalizado un registro de inicio de sesion por skills');
        System.assertEquals(usuario.Id, listaSesionesFinalizadas[0].CC_User__c);
        System.assertNotEquals(Null, listaSesionesFinalizadas[0].CC_Fecha_Inicio__c);
        System.assertNotEquals(Null, listaSesionesFinalizadas[0].CC_Fecha_Fin__c, 'Se ha modificado la fecha fin del registro porque se ha finalizado la sesión');
        System.assertEquals(usuarioGenesys.Id, listaSesionesFinalizadas[0].CC_Usuario_Genesys__c);
        System.assertEquals('ES', listaSesionesFinalizadas[0].CC_SkillDescription__c);
        
        //Comprobamos que se ha eliminado el agente de las colas de Stop&Go
        queueMemberList = [SELECT GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :usuario.Id AND Group.QueueRoutingConfigId <> null];
        System.assertEquals(2, queueMemberList.size(), 'Se ha eliminado el agente de las colas de Stop&Go del idioma ES');
    }

    @isTest
    public static void quitarSkillTipoChatAUsuarioComprobarEliminacionQueueStopGo() 
    {
        User usuario = [SELECT Id, Name FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        CC_Usuario_Genesys__c usuarioGenesys = [SELECT Id FROM CC_Usuario_Genesys__c WHERE CC_User__c = :usuario.Id LIMIT 1];
        
        ServiceResource userServiceResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = : usuario.Id LIMIT 1];
        
        //Obtenemos la lista de skills y colas para buscar las colas de Stop&Go
        List<ServiceResourceSkill> userSkill = [SELECT Id, Skill.DeveloperName  FROM ServiceResourceSkill WHERE Skill.DeveloperName = 'Agente' AND ServiceResourceId = :userServiceResource.Id];

        Test.startTest();
            //Comprobamos que el agente está en las colas de Stop&Go
            List<GroupMember> queueMemberList = [SELECT GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :usuario.Id AND Group.QueueRoutingConfigId <> null];
            System.assertEquals(4, queueMemberList.size(), 'El agente pertenece a las 4 colas de Stop&Go');
            
            delete userSkill;
        Test.stopTest();

        List<CC_SkillHistory__c> listaSesionesFinalizadas = [SELECT Id,CC_Fecha_Inicio__c, CC_SkillId__c, CC_SkillDescription__c, CC_User__c, CC_Fecha_Fin__c, CC_Usuario_Genesys__c 
                                                    FROM CC_SkillHistory__c WHERE CC_Fecha_Fin__c <> Null];

        System.assertEquals(1, listaSesionesFinalizadas.size(), 'Se ha finalizado un registro de inicio de sesion por skills');
        System.assertEquals(usuario.Id, listaSesionesFinalizadas[0].CC_User__c);
        System.assertNotEquals(Null, listaSesionesFinalizadas[0].CC_Fecha_Inicio__c);
        System.assertNotEquals(Null, listaSesionesFinalizadas[0].CC_Fecha_Fin__c, 'Se ha modificado la fecha fin del registro porque se ha finalizado la sesión');
        System.assertEquals(usuarioGenesys.Id, listaSesionesFinalizadas[0].CC_Usuario_Genesys__c);
        System.assertEquals('Agente', listaSesionesFinalizadas[0].CC_SkillDescription__c);
        
        //Comprobamos que se ha eliminado el agente de las colas de Stop&Go
        queueMemberList = [SELECT GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :usuario.Id AND Group.QueueRoutingConfigId <> null];
        System.assertEquals(2, queueMemberList.size(), 'Se ha eliminado el agente de las colas de Stop&Go del tipoChat Agente');  
    }
}