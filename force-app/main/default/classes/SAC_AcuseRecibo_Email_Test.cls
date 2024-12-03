@isTest
public class SAC_AcuseRecibo_Email_Test {
    
    @TestSetup
    static void makeData() {
        
        Account cuentaA = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
        Database.insert(cuentaA);
       
        User usuario;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuario.Username = 'sacacuserecibo@test.com';
            Database.insert(usuario);
        
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }
        
        //Account
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        Database.insert(cuenta);

        //Contact
		Contact contacto = SAC_TestDataFactory.crearContacto(1,cuenta.id)[0];
		Database.insert(contacto);
        
        System.runAs(usuario){
            EmailTemplate validEmailTemplate = new EmailTemplate(
                isActive = true, 
                Name = 'nombreTest',
                DeveloperName = 'SAC_Test',
                TemplateType = 'text', 
                HtmlValue = '<p>htmlValue<p>', 
                Body = 'Texted', 
                FolderId = UserInfo.getUserId()
            );
            Database.insert(validEmailTemplate);    
        }
    }
    
    @isTest
    static void envioAcuseReciboEmailTest(){
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        EmailTemplate validEmailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        Account cliente = [SELECT Id FROM Account WHERE Name = 'cuentaTest0' LIMIT 1];
        
        //Plantilla
        SAC_PlantillaRedaccion__c plantilla = new SAC_PlantillaRedaccion__c();
        plantilla.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla.SAC_Origen__c = 'Email';
        plantilla.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla.RecordTypeId = recordTypeRedaccion;
        plantilla.Name = 'testPlantilla';
        Database.insert(plantilla);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Email');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SuppliedEmail', 'test@test.com'); 
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('AccountId', cliente.Id);
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(casoReclamacion);

        System.RunAs(usuario){   
            Test.startTest();
            SAC_LCMP_UpdateStatus.updateRecordStatusInadmision(casoReclamacion.Id, 'test1');
            Test.stopTest();
        }
        
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        System.assertNotEquals(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');    
    }

    @isTest
    static void envioAcuseReciboEmail9Test(){
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        EmailTemplate validEmailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        Account cliente = [SELECT Id FROM Account WHERE Name = 'cuentaTest0' LIMIT 1];
        
        //Plantilla
        SAC_PlantillaRedaccion__c plantilla = new SAC_PlantillaRedaccion__c();
        plantilla.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla.SAC_Origen__c = 'Email';
        plantilla.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla.RecordTypeId = recordTypeRedaccion;
        plantilla.Name = 'testPlantilla';
        Database.insert(plantilla);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Email');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SuppliedEmail', 'test@test.com'); 
        camposRecl.put('CC_Idioma__c', 'gr');
        // camposRecl.put('AccountId', cliente.Id);
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(casoReclamacion);

        System.RunAs(usuario){   
            Test.startTest();
            SAC_LCMP_UpdateStatus.updateRecordStatusInadmision(casoReclamacion.Id, 'test1');
            Test.stopTest();
        }
        
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        System.assertNotEquals(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');    
    }
    
    @isTest
    static void envioAcuseReciboEmail2Test(){
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        Account cliente = [SELECT Id FROM Account WHERE Name = 'cuentaTest0' LIMIT 1];

        SAC_PlantillaRedaccion__c plantilla2 = new SAC_PlantillaRedaccion__c();
        plantilla2.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla2.SAC_Origen__c = 'SAC_Formulario';
        plantilla2.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla2.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla2.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla2.RecordTypeId = recordTypeRedaccion;
        plantilla2.Name = 'testPlantilla2';
        Database.insert(plantilla2);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'SAC_Formulario');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SuppliedEmail', 'test@test.com');
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('AccountId', cliente.Id);
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(casoReclamacion);
    
        System.RunAs(usuario){   
            Test.startTest();
            SAC_LCMP_UpdateStatus.updateRecordStatusInadmision(casoReclamacion.Id, 'test2');
            Test.stopTest();
        }
        
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        System.assertNotEquals(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');    
    }
    
    @isTest
    static void envioAcuseReciboEmail3Test(){
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        Account cliente = [SELECT Id FROM Account WHERE Name = 'cuentaTest0' LIMIT 1];

        SAC_PlantillaRedaccion__c plantilla2 = new SAC_PlantillaRedaccion__c();
        plantilla2.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla2.SAC_Origen__c = 'SAC_Formulario';
        plantilla2.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla2.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla2.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla2.RecordTypeId = recordTypeRedaccion;
        plantilla2.Name = 'testPlantilla2';
        Database.insert(plantilla2);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'SAC_Formulario');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SuppliedEmail', 'test@test.com');
        camposRecl.put('CC_Idioma__c', 'gr');
        // camposRecl.put('AccountId', cliente.Id);
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(casoReclamacion);
    
        System.RunAs(usuario){   
            Test.startTest();
            SAC_LCMP_UpdateStatus.updateRecordStatusInadmision(casoReclamacion.Id, 'test2');
            Test.stopTest();
        }
        
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        System.assertNotEquals(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');    
    }

    @isTest
    static void envioAcuseReciboEmail4Test(){
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        Account cliente = [SELECT Id FROM Account WHERE Name = 'cuentaTest0' LIMIT 1];
        
        SAC_PlantillaRedaccion__c plantilla4 = new SAC_PlantillaRedaccion__c();
        plantilla4.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla4.SAC_Origen__c = 'SAC_Formulario';
        plantilla4.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla4.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla4.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla4.RecordTypeId = recordTypeRedaccion;
        plantilla4.Name = 'testPlantilla4';
        Database.insert(plantilla4);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'SAC_Formulario');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SuppliedEmail', 'test@test.com');
        camposRecl.put('CC_Idioma__c', 'ca');
        camposRecl.put('AccountId', cliente.Id);
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(casoReclamacion);
        
        System.RunAs(usuario){   
            Test.startTest();
            SAC_LCMP_UpdateStatus.updateRecordStatusInadmision(casoReclamacion.Id, 'test1');
            Test.stopTest();
        }
        
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        System.assertNotEquals(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');    
    }

    @isTest
    static void envioAcuseReciboEmail5Test(){
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        
        SAC_PlantillaRedaccion__c plantilla5 = new SAC_PlantillaRedaccion__c();
        plantilla5.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla5.SAC_Origen__c = 'SAC_FormularioOficina';
        plantilla5.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla5.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla5.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla5.RecordTypeId = recordTypeRedaccion;
        plantilla5.Name = 'testPlantilla5';
        Database.insert(plantilla5);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec2');
        camposRecl.put('Origin', 'SAC_FormularioOficina');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SuppliedEmail', 'test@test.com');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
       
        System.RunAs(usuario){   
            Test.startTest();
            Database.insert(casoReclamacion);
            SAC_LCMP_AcuseReciboCartaPostal.envioEmail(casoReclamacion);
            Test.stopTest();
        }
        
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        System.assertNotEquals(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');    
    }

    @isTest
    static void envioAcuseReciboEmail6Test(){
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        
        SAC_PlantillaRedaccion__c plantilla6 = new SAC_PlantillaRedaccion__c();
        plantilla6.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla6.SAC_Origen__c = 'SAC_Manual';
        plantilla6.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla6.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla6.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla6.RecordTypeId = recordTypeRedaccion;
        plantilla6.Name = 'testPlantilla6';
        Database.insert(plantilla6);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'SAC_Manual');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SuppliedEmail', 'test@test.com');
        camposRecl.put('CC_Idioma__c', 'es');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        System.RunAs(usuario){   
            Test.startTest();
            Database.insert(casoReclamacion);
            SAC_LCMP_AcuseReciboCartaPostal.envioEmail(casoReclamacion);
            Test.stopTest();
        }
        
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        System.assertNotEquals(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');    
    }

    @isTest
    static void envioAcuseReciboEmail8Test(){
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        
        SAC_PlantillaRedaccion__c plantilla6 = new SAC_PlantillaRedaccion__c();
        plantilla6.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla6.SAC_Origen__c = 'SAC_Manual';
        plantilla6.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla6.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla6.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla6.RecordTypeId = recordTypeRedaccion;
        plantilla6.Name = 'testPlantilla6';
        Database.insert(plantilla6);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'SAC_Manual');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SuppliedEmail', 'test@test.com');
        // camposRecl.put('CC_Idioma__c', 'es');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        System.RunAs(usuario){   
            Test.startTest();
            Database.insert(casoReclamacion);
            SAC_LCMP_AcuseReciboCartaPostal.envioEmail(casoReclamacion);
            Test.stopTest();
        }
        
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        System.assertNotEquals(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');    
    }

    @isTest
    static void envioAcuseReciboEmail7Test(){
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        
        SAC_PlantillaRedaccion__c plantilla6 = new SAC_PlantillaRedaccion__c();
        plantilla6.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla6.SAC_Origen__c = 'SAC_Manual';
        plantilla6.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla6.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla6.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla6.RecordTypeId = recordTypeRedaccion;
        plantilla6.Name = 'testPlantilla7';
        Database.insert(plantilla6);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'SAC_Manual');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SuppliedEmail', 'test@test.com');
        camposRecl.put('CC_Idioma__c', 'ca');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        
        System.RunAs(usuario){   
            Test.startTest();
            Database.insert(casoReclamacion);
            SAC_LCMP_AcuseReciboCartaPostal.envioEmailManual(casoReclamacion);
            Test.stopTest();
        }
        
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        System.assertNotEquals(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');    
    }

    @isTest
    static void envioAcuseReciboEmail10Test(){
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        
        SAC_PlantillaRedaccion__c plantilla6 = new SAC_PlantillaRedaccion__c();
        plantilla6.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla6.SAC_Origen__c = 'SAC_CartaPostal';
        plantilla6.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla6.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla6.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla6.RecordTypeId = recordTypeRedaccion;
        plantilla6.Name = 'testPlantilla7';
        Database.insert(plantilla6);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'SAC_CartaPostal');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SuppliedEmail', 'test@test.com');
        camposRecl.put('CC_Idioma__c', 'gr');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(casoReclamacion);
        
        System.RunAs(usuario){   
            Test.startTest();
            List<Case> listaCasos = new List<Case>();
            listaCasos.add(casoReclamacion);
            Map<Id,Case> mapCasos = new Map<Id,Case>(listaCasos);

            SAC_AcuseRecibo_Email.envioAcuseRecibo(listaCasos, mapCasos);
            Test.stopTest();
        }
        
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        System.assertNotEquals(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');    
    }
}