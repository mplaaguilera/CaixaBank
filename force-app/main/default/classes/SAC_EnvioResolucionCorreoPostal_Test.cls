@isTest
public with sharing class SAC_EnvioResolucionCorreoPostal_Test {
    //Clase test para SAC_LCMP_EnvioResolucionCorreoPostal
    
    @TestSetup
    static void makeData(){  
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        System.runAs(usuarioGeneral){
            Account acc = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
            SAC_DatabaseDML.insertDML(acc, false);

            //Oficina
            // List<Account> listaCuentas = SAC_TestDataFactory.crearCuentas(2);
            // listaCuentas[0].Name = 'Cuenta A';
            // listaCuentas[0].Phone = '123456789';
            // listaCuentas[0].CC_Email__c = 'cuenta@mailtestSAC.com';
            // listaCuentas[0].billingStreet  = 'Calle Mayor 55';
            // listaCuentas[0].BillingCountry = 'España';
            // listaCuentas[0].OwnerId = usuarioGeneral.id;
            // listaCuentas[0].recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            // Database.insert(listaCuentas);

            List<Case> reclamaciones = new List<Case>();
            //Reclamaciones
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'testRec');
            camposRecl.put('Status', 'SAC_003');
            camposRecl.put('AccountId', acc.Id);
            camposRecl.put('SuppliedEmail', 'test@enviaremailtest.invalid');
            camposRecl.put('Origin', 'Email');
            camposRecl.put('CC_Idioma__c', 'de');
            camposRecl.put('CC_Oficina_Afectada_Lookup__c',  acc.id);
            Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'testRec2');
            camposRecl2.put('Status', 'SAC_003');
            // camposRecl2.put('CC_Oficina_Afectada_lookup__c', oficina.Id);
            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

            reclamaciones.add(reclamacion1);
            reclamaciones.add(reclamacion2);
            SAC_DatabaseDML.insertListDML(reclamaciones, false);

            List<SAC_DocumentoEnvio__c> docEnv = SAC_TestDataFactory.crearDocumentoEnvio(1,reclamacion1);
            docEnv[0].SAC_TipoDocumento__c = 'redacción';
            docEnv[0].SAC_Direccion__c = 'direccionTest';
            SAC_DatabaseDML.insertListDML(docEnv, false);

            Blob vd =  blob.valueOf('Unit.Test');
            List<ContentVersion> cvs = new List<ContentVersion>();
            ContentVersion cv = new ContentVersion(VersionData = vd, PathOnClient = 'SampleTitle.pdf' , Title = 'tituloTest', FirstPublishLocationId = reclamacion1.Id, SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion');
            cvs.add(cv);
            ContentVersion cv2 = new ContentVersion(VersionData = vd, PathOnClient = 'SampleTitle.pdf' , Title = 'tituloTest', FirstPublishLocationId = reclamacion2.Id, SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion');
            cvs.add(cv2);
            SAC_DatabaseDML.insertListDML(cvs, false);

            EmailTemplate validEmailTemplate = new EmailTemplate(
                isActive = true, 
                Name = 'SAC_Redaccion',
                DeveloperName = 'SAC_TareaOficina',
                TemplateType = 'text', 
                HtmlValue = '<p>htmlValue<p>', 
                Body = 'Texted', 
                FolderId = UserInfo.getUserId()
            );
            SAC_DatabaseDML.insertDML(validEmailTemplate, false);

            //Email Backlist
            SAC_MaestroTemas__c maestroTemaBL = new SAC_MaestroTemas__c();
            maestroTemaBL.Name ='emailtestinvalido@prueba.com';
            maestroTemaBL.SAC_Activo__c = true;
            maestroTemaBL.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_BlackListEmails').getRecordTypeId();
            SAC_DatabaseDML.insertDML(maestroTemaBL, true);

            List<SAC_PlantillaRedaccion__c> plantillas = new List<SAC_PlantillaRedaccion__c>();
            //Plantilla
            SAC_PlantillaRedaccion__c plantilla = new SAC_PlantillaRedaccion__c();
            plantilla.SAC_TipoPlantilla__c = 'SAC_AvisoResolucionCartaPostal';
            plantilla.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
            plantilla.RecordTypeId = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
            plantilla.Name = 'testPlantilla';
            plantillas.add(plantilla);

            SAC_DatabaseDML.insertListDML(plantillas, false);

            //grupo colaborador
            List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1);
            listaGrupos[0].Name = 'grupo de tareas';
            listaGrupos[0].SAC_PermiteTareas__c = true;
            listaGrupos[0].SAC_Email__c = 'test@test.com';
            SAC_DatabaseDML.insertListDML(listaGrupos, true);

            SAC_MaestroAccionesReclamacion__c maestroTema = SAC_TestDataFactory.crearMaestroAcciones(1,listaGrupos[0].Id)[0];
            maestroTema.SAC_DeveloperName__c ='SAC_ImprimirCartasOrdinario';
            SAC_DatabaseDML.insertDML(maestroTema, true);

            //ContentVersion
            ContentVersion adjunto = SAC_TestDataFactory.crearContentVersion(reclamacion1);
            List<ContentVersion> listaCV = new List<ContentVersion>();
            listaCV.add(adjunto);
            SAC_DatabaseDML.insertListDML(listaCV, true);
        
        }
    }

    @isTest
    static void buscaCartaPrevia1Test(){
        Case reclamacion1 = [SELECT Id FROM Case WHERE Subject = 'testRec'];
        SAC_DocumentoEnvio__c doc = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c =: reclamacion1.Id];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_EnvioResolucionCorreoPostal.WrappedInfoCartas resultado = SAC_LCMP_EnvioResolucionCorreoPostal.buscaCartaPrevia(reclamacion1.Id, 'redacción');
            Test.stopTest();

            System.assertEquals(resultado.idCarta, doc.Id, 'La búsqueda de información ha fallado.');
        }   
    }

    @isTest
    static void buscaCartaPrevia2Test(){
        Case reclamacion2 = [SELECT Id FROM Case WHERE Subject = 'testRec2'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_EnvioResolucionCorreoPostal.WrappedInfoCartas resultado = SAC_LCMP_EnvioResolucionCorreoPostal.buscaCartaPrevia(reclamacion2.Id, 'redacción');
            Test.stopTest();

            System.assertEquals(resultado.idCarta, '', 'La búsqueda de información ha fallado.');
        }  
    }

    @isTest
    static void finalizarRedaccionCartaPostal(){
        Case reclamacion = [SELECT Id, Status, CC_Idioma__c FROM Case WHERE Subject = 'testRec'];
        Integer feedItemCtn = [SELECT Count() FROM FeedItem];
        List<SAC_MaestroTemas__c> emailsBlacklist = [SELECT Id, Name FROM SAC_MaestroTemas__c WHERE RecordType.DeveloperName = 'SAC_BlackListEmails' AND Name = 'emailtestinvalido@prueba.com' AND SAC_Activo__c = true LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List <ContentVersion> seleccionados = [SELECT id FROM ContentVersion Limit 1];
            String idSeleccionados;
    
            for(ContentVersion cv: seleccionados){
                idSeleccionados = cv.id;
            }
            String idAdjuntosJson = '[ "' + idSeleccionados + '" ]'; 


            reclamacion.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
            SAC_DatabaseDML.updateDML(reclamacion, false);
            SAC_LCMP_EnvioResolucionCorreoPostal.finalizarRedaccionCartaPostal(reclamacion.Id, 'test@enviaremailtest.invalid', '', '', 'testCuerpo', 'testAsunto', idAdjuntosJson);
            Test.stopTest();
        }

        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'testRec'];

        System.assertNotEquals(reclamacion.Status, reclamacion2.Status, 'El envío de carta ha fallado.');
        System.assertNotEquals(feedItemCtn, [SELECT Count() FROM FeedItem], 'La comunicación ha fallado.');
    }   

    @isTest
    static void obtenerDatosEmailTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'testRec' LIMIT 1];
        SAC_LCMP_EnvioResolucionCorreoPostal.DatosEmailWrapper informacion;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuarioGeneral){
            Test.startTest();
            reclamacion.CC_Canal_Respuesta__c = 'Carta';
            SAC_DatabaseDML.updateDML(reclamacion, false);
            informacion = SAC_LCMP_EnvioResolucionCorreoPostal.obtenerDatosEmail(reclamacion.Id, false);
            Test.stopTest();
        }
        system.assertNotEquals(informacion, null, 'El objeto wrapper con datos del email no se ha instanciado correctamente.');
    }
}