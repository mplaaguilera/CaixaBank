@isTest
public with sharing class SAC_EnvioResolucionCorreoPostal_Test {
    //Clase test para SAC_LCMP_EnvioResolucionCorreoPostal
    
    @TestSetup
    static void makeData(){  
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            Account acc = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
            Database.insert(acc);

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
            camposRecl.put('CC_Oficina_Afectada_Lookup__c',  acc.id);
            Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'testRec2');
            camposRecl2.put('Status', 'SAC_003');
            // camposRecl2.put('CC_Oficina_Afectada_lookup__c', oficina.Id);
            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

            reclamaciones.add(reclamacion1);
            reclamaciones.add(reclamacion2);
            Database.insert(reclamaciones);

            List<SAC_DocumentoEnvio__c> docEnv = SAC_TestDataFactory.crearDocumentoEnvio(1,reclamacion1);
            docEnv[0].SAC_TipoDocumento__c = 'redacción';
            docEnv[0].SAC_Direccion__c = 'direccionTest';
            Database.insert(docEnv);

            Blob vd =  blob.valueOf('Unit.Test');
            List<ContentVersion> cvs = new List<ContentVersion>();
            ContentVersion cv = new ContentVersion(VersionData = vd, PathOnClient = 'SampleTitle.pdf' , Title = 'tituloTest', FirstPublishLocationId = reclamacion1.Id, SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion');
            cvs.add(cv);
            ContentVersion cv2 = new ContentVersion(VersionData = vd, PathOnClient = 'SampleTitle.pdf' , Title = 'tituloTest', FirstPublishLocationId = reclamacion2.Id, SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion');
            cvs.add(cv2);
            Database.insert(cvs);

            EmailTemplate validEmailTemplate = new EmailTemplate(
                isActive = true, 
                Name = 'SAC_Redaccion',
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
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'testRec'];
        List<FeedItem> listaPrevia = [SELECT Id FROM FeedItem];

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_EnvioResolucionCorreoPostal.finalizarRedaccionCartaPostal(reclamacion.Id, 'test@enviaremailtest.invalid', '', '', 'testCuerpo', 'testAsunto', '');
            Test.stopTest();
        }

        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'testRec'];
        List<FeedItem> listaPosterior = [SELECT Id FROM FeedItem];

        System.assertNotEquals(reclamacion.Status, reclamacion2.Status, 'El envío de carta ha fallado.');
        System.assertNotEquals(listaPrevia.size(), listaPosterior.size(), 'La comunicación ha fallado.');
    }   

    @isTest
    static void obtenerDatosEmailTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'testRec' LIMIT 1];
        SAC_LCMP_EnvioResolucionCorreoPostal.DatosEmailWrapper informacion;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuarioGeneral){
            Test.startTest();
            reclamacion.CC_Canal_Respuesta__c = 'Carta';
            Database.update(reclamacion);
            informacion = SAC_LCMP_EnvioResolucionCorreoPostal.obtenerDatosEmail(reclamacion.Id, false);
            Test.stopTest();
        }
        system.assertNotEquals(informacion, null, 'El objeto wrapper con datos del email no se ha instanciado correctamente.');
    }
}