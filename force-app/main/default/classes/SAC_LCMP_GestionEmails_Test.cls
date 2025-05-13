@isTest
public with sharing class SAC_LCMP_GestionEmails_Test {

    @TestSetup
    static void makeData(){
        Test.startTest();
        User usuarioGeneral;
        User usuarioAdmin;
        List<User> listaUsuarios = new List<User>();
        //Usuario SAC General
        usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioGeneral.SAC_PerteneceCOPSAJ__c = true; 
        listaUsuarios.add(usuarioGeneral);    

        //Usuario Admin
        usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        listaUsuarios.add(usuarioAdmin);    

        SAC_DatabaseDML.insertListDML(listaUsuarios, false);

        System.runAs(usuarioAdmin) {
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }
        
        //System.runAs(usuarioGeneral){
            //Cuenta
            Account cuenta = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
            //Database.insert(cuenta);
            
            //Oficina
            List<Account> listaCuentas = SAC_TestDataFactory.crearCuentas(2);
            listaCuentas[0].Name = 'Cuenta A';
            listaCuentas[0].Phone = '123456789';
            listaCuentas[0].CC_Email__c = 'cuenta@mailtestSAC.com';
            listaCuentas[0].billingStreet  = 'Calle Mayor 55';
            listaCuentas[0].BillingCountry = 'España';
            listaCuentas[0].OwnerId = usuarioGeneral.id;
            listaCuentas[0].recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            listaCuentas.add(cuenta);
            SAC_DatabaseDML.insertListDML(listaCuentas, false);


            //Entitlement
            Entitlement entitle = SAC_TestDataFactory.crearEntitlement(cuenta.id);
            SAC_DatabaseDML.insertDML(entitle, false);
            
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('Status', 'SAC_001');
            camposRecl.put('AccountId', cuenta.id);
            camposRecl.put('CC_Oficina_Afectada_Lookup__c',  listaCuentas[0].id);
            camposRecl.put('OS_Email__c',  'cuenta@mailtestSAC.com');
            camposRecl.put('SuppliedEmail',  'cuenta@mailtestSAC.com');


            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(casoReclamacion, false);
            //Consulta
            Map<String, Object> camposCons = new Map<String, Object>();
            camposCons.put('Subject', 'TestCons');
            camposCons.put('Status', 'SAC_001');
            camposCons.put('AccountId', cuenta.id);

            Case casoConsulta = SAC_TestDataFactory.crearCaso('Reclamacion',camposCons);
            SAC_DatabaseDML.insertDML(casoConsulta, false);
            
            Test.stopTest();    

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Subject', 'TestPret2');
            camposPret.put('SuppliedCompany', 'TestPret');
            camposPret.put('Origin', 'Backoffice');
            camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
            camposPret.put('SAC_Case_esPsd2__c', true);

            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            SAC_DatabaseDML.insertDML(casoPretension, false);


            //Grupos
            CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
            grupoColaborador.SAC_PermiteConsultas__c = true;
            grupoColaborador.SAC_Externo__c = true;
            grupoColaborador.SAC_Email__c = 'test@emailSAC0304.com';
            SAC_DatabaseDML.insertDML(grupoColaborador, false);
            

            //Interaccion Consulta
            List<SAC_Interaccion__c> listConsultas = new List<SAC_Interaccion__c>();
            Map<String, Object> camposIntCons = new Map<String, Object>();
            camposIntCons.put('SAC_Titulo__c', 'consulta');
            camposIntCons.put('SAC_Propuesta__c', 'consulta');
            camposIntCons.put('SAC_Reclamacion__c', casoReclamacion.Id);
            
            SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposIntCons);
            listConsultas.add(consulta);

            Map<String, Object> camposIntCons2 = new Map<String, Object>();
            camposIntCons2.put('SAC_Titulo__c', 'consulta2test');
            camposIntCons2.put('SAC_Pregunta__c', 'consulta');
            camposIntCons2.put('SAC_Reclamacion__c', casoReclamacion.Id);
            camposIntCons2.put('SAC_GrupoColaborador__c', grupoColaborador.Id);
            
            SAC_Interaccion__c consulta2 = SAC_TestDataFactory.crearInteraccion('Consulta',camposIntCons2);
            listConsultas.add(consulta2);
            SAC_DatabaseDML.insertListDML(listConsultas, false);

            //Parametrizacion escalado
            Map<String, Object> camposParams = new Map<String, Object>();
            camposParams.put('Name', 'Validacion Escalado COPS');
            camposParams.put('Aplica_escalado__c', true);
            camposParams.put('SAC_Importe__c', 200);
            camposParams.put('SAC_Mensaje__c', 'Mensaje');
            camposParams.put('SAC_todosMCCs__c', true);
            camposParams.put('SAC_TodosDespachos__c', true);
            camposParams.put('SAC_validarImporte__c', false);
            
            SAC_ParametrizacionEscalado__c parametrizacionEscalado = SAC_TestDataFactory.crearParamEsc(camposParams);
            SAC_DatabaseDML.insertDML(parametrizacionEscalado, false);

            //Email Backlist
            SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c();
            maestroTema.Name ='emailtest@prueba.com';
            maestroTema.SAC_Activo__c = true;
            maestroTema.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_BlackListEmails').getRecordTypeId();
            SAC_DatabaseDML.insertDML(maestroTema, false);


            //ContentVersion
            ContentVersion cv = SAC_TestDataFactory.crearContentVersion(casoReclamacion);
            ContentVersion cv2 = SAC_TestDataFactory.crearContentVersion(casoPretension);
            cv2.Title = 'cv2Test';
            List<ContentVersion> listaCV = new List<ContentVersion>();
            listaCV.add(cv);
            listaCV.add(cv2);
            SAC_DatabaseDML.insertListDML(listaCV, false);

            EmailMessage em  = new EmailMessage();
            em.relatedtoId = consulta2.Id;
            em.Subject = 'emTest Consulta externa';
            em.ToAddress = 'test@test.com';
            em.MessageDate = System.now();
            SAC_DatabaseDML.insertDML(em, false);

            System.runAs(usuarioAdmin){
                EmailTemplate validEmailTemplate = new EmailTemplate(
                    isActive = true, 
                    Name = 'nombreTest',
                    DeveloperName = 'SAC_Test',
                    TemplateType = 'text', 
                    HtmlValue = '<p>htmlValue<p>', 
                    Body = 'Texted', 
                    FolderId = usuarioAdmin.id
                );
                SAC_DatabaseDML.insertDML(validEmailTemplate, false);
                
                SAC_PlantillaRedaccion__c plantilla = new SAC_PlantillaRedaccion__c();
                plantilla.SAC_TipoPlantilla__c = 'SAC_AvisoResolucion';
                plantilla.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
                plantilla.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
                plantilla.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
                plantilla.RecordTypeId = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
                plantilla.Name = 'testPlantilla';
                SAC_DatabaseDML.insertDML(plantilla, false);
            }
        //}            
 

    }

    @isTest
    static void enviarEmailTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestCons' LIMIT 1];
        Integer emailMsgCnt = [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY];

        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'ABC Test'];
        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.ContentDocumentId);
        }
        String idsAdjuntos = JSON.serialize(listaIds);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            try{
                SAC_LCMP_GestionEmails.enviarEmail(reclamacion.Id, 'lmesa@viewnext.com; luis.mesa@ibm.com', 'lmesa@viewnext.com; luis.mesa@ibm.com', 'lmesa@viewnext.com; luis.mesa@ibm.com', 'cuerpo prueba', 'Asunto', idsAdjuntos, null);
            }catch(AuraHandledException e){
                Assert.areEqual(null, null, 'No se puede enviar el mail porque hay un adjunto no valido');
            }   

        }

        Test.stopTest();
    }

    @isTest
    static void enviarResolucionEmailTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Integer emailMsgCnt = [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY];

        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];

        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.Id);
        }
        String idsAdjuntos = JSON.serialize(listaIds);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_LCMP_GestionEmails.finalizarRedaccion(reclamacion.Id, 'lmesa@viewnext.com; luis.mesa@ibm.com', 'lmesa@viewnext.com; luis.mesa@ibm.com', 'lmesa@viewnext.com; luis.mesa@ibm.com', 'cuerpo prueba', 'Asunto', idsAdjuntos);
        }

        Assert.areNotEqual(emailMsgCnt, [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY], 'No se ha podido efectuar el envío de email');
        Test.stopTest();
    }

    @isTest
    static void obtieneAdjuntosTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
       
        reclamacion.OwnerId = usuario.id; 
        cv.OwnerId = usuario.id; 
        SAC_DatabaseDML.updateDML(reclamacion, false);
        SAC_DatabaseDML.updateDML(cv, false);

        System.runAs(usuario){
            ContentVersion[] resultado = SAC_LCMP_GestionEmails.obtieneAdjuntos(reclamacion.id);
            Assert.areEqual(resultado[0].Id, cv.Id, 'No ha funcionado correctamente la recuperación de archivos adjuntos.');
        }
        Test.stopTest();
    }

    @isTest
    static void eliminaRegistroTest(){
        Test.startTest();
        List<ContentVersion> cv = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        Integer cvCnt = [SELECT Count() FROM ContentVersion WHERE Title = 'ABC Test'];

        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_LCMP_GestionEmails.eliminaRegistro(cv[0].Id);
        }
        
        Assert.areNotEqual(cvCnt, [SELECT Count() FROM ContentVersion WHERE Title='ABC Test'], 'No ha funcionado correctamente la eliminación de archivos adjuntos.');
        Test.stopTest();
    }

    @isTest
    static void recogerCasoTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Case casoFinal = SAC_LCMP_GestionEmails.recogerCaso(reclamacion.Id);
            Assert.areEqual(reclamacion, casoFinal, 'No ha recogido el caso correctamente.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void recuperaAdjuntosTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            ContentVersion[] resultado = SAC_LCMP_GestionEmails.recuperaAdjuntos(reclamacion.Id);
            Assert.areEqual(resultado[0].Title, 'ABC Test', 'No ha recogido el adjunto correctamente.');
        }
        Test.stopTest();
    }

    @isTest
    static void recuperaAdjuntosVacioTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){
            ContentVersion[] resultado = SAC_LCMP_GestionEmails.recuperaAdjuntos(null);
            Assert.areEqual(resultado.isEmpty(), true, 'No ha recogido el adjunto correctamente.');
        }
        Test.stopTest();
    }

    @isTest
    static void eliminaContentDocumentTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: reclamacion.Id LIMIT 1];
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =: cv.ContentDocumentId LIMIT 1];
        Integer cdCnt = [SELECT Count() FROM ContentDocument];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_LCMP_GestionEmails.eliminaContentDocument(cd.Id); 
        }
        
        Assert.areNotEqual(cdCnt, [SELECT Count() FROM ContentDocument], 'No ha eliminado el documento correctamente.');
        Test.stopTest();
    }

    @isTest
    static void enviarEmailInteraccionTest(){
        Test.startTest();
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta' LIMIT 1];
        Integer emailMsgCnt = [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY];

        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.Id);
        }
        String idsAdjuntos = JSON.serialize(listaIds);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_LCMP_GestionEmails.enviarEmail(consulta.Id, 'lmesa@viewnext.com; luis.mesa@ibm.com', 'lmesa@viewnext.com; luis.mesa@ibm.com', 'lmesa@viewnext.com; luis.mesa@ibm.com', 'cuerpo prueba', 'Asunto', idsAdjuntos, null);
        }
        Assert.areNotEqual(emailMsgCnt, [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY], 'No se ha podido efectuar el envío de email');
        Test.stopTest();
    }

    @isTest
    static void enviarEmailInteraccionTest2(){
        Test.startTest();
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta2test' LIMIT 1];
        Integer emailMsgCnt = [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY];

        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.Id);
        }
        String idsAdjuntos = JSON.serialize(listaIds);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_LCMP_GestionEmails.enviarEmail(consulta.Id, 'test@testsac.com; test@testsac2.com', 'test@testsac.com; test@testsac2.com', 'test@testsac.com; test@testsac2.com', 'cuerpo prueba', 'Asunto prueba', idsAdjuntos, null);
        }
        Assert.areNotEqual(emailMsgCnt, [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY], 'No se ha podido efectuar el envío de email');
        Test.stopTest();
    }

    @isTest
    static void getDocumentRedaccionTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId, SAC_ValidadoCV__c, FirstPublishLocationId, SAC_Bloque__c FROM ContentVersion WHERE Title = 'ABC Test' LIMIT 1];
        cv.SAC_Bloque__c = 'SAC_Respuesta';
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        reclamacion.OwnerId = usuario.id; 
        cv.OwnerId = usuario.id; 
        SAC_DatabaseDML.updateDML(reclamacion, false);
        SAC_DatabaseDML.updateDML(cv, false);
        
        System.runAs(usuario){
            List<contentVersion> resultado = SAC_LCMP_GestionEmails.getDocumentRedaccion(reclamacion.id);
            if (resultado != null && !resultado.isEmpty()) {
                // Asegurarse de que el primer elemento de la lista tenga el título esperado
                Assert.areEqual(resultado[0].Title, cv.Title, 'No ha funcionado correctamente la recuperación de archivos adjuntos.');
            } else {
                // Si la lista está vacía, fallar el test con un mensaje claro
                Assert.fail('La lista de resultados está vacía.');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void prorrogarCasoTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status,SAC_Prorrogado__c FROM Case WHERE Subject = 'TestRec'];
        Integer emailMsgCnt = [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY];

        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.Id);
        }
        String idsAdjuntos = JSON.serialize(listaIds);

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_LCMP_GestionEmails.prorrogarCaso(reclamacion.id, 'testSACenvioemail@test.test', 'testSACenvioemail@test.test', 'testSACenvioemail@test.test', 'Envio prorroga', 'Caso prorrogado', idsAdjuntos);
        }

        reclamacion = [SELECT Id, SAC_Prorrogado__c FROM Case WHERE Subject = 'TestRec'];
        
        Assert.areEqual(reclamacion.SAC_Prorrogado__c, true,'No se ha prorrogado. Falla parte 1'); 

        Assert.areNotEqual(emailMsgCnt, [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY], 'No se ha podido efectuar el envío de email. Falla parte 2'); 
        Test.stopTest();  
    }

    @isTest
    static void rellenarUltimaModFicheroTest() {
        Test.startTest();
        Case pretension = [SELECT Id, SAC_UltimaModificacionFichero__c FROM Case WHERE SuppliedCompany = 'TestPret' LIMIT 1];
        List<ContentVersion> listaCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'cv2Test'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        List<String> listaIdsFicheros = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIdsFicheros.add(cv.ContentDocumentId);
        }
       
        pretension.OwnerId = usuario.id; 
        listaCV[0].OwnerId = usuario.id; 
        SAC_DatabaseDML.updateDML(pretension, false);
        SAC_DatabaseDML.updateListDML(listaCV, false);

        System.runAs(usuario){
            SAC_LCMP_GestionEmails.rellenarUltimaModFichero(pretension.Id, listaIdsFicheros, false);
        }

        Case pretensionResult = [SELECT Id, SAC_UltimaModificacionFichero__c FROM Case WHERE SuppliedCompany = 'TestPret' LIMIT 1];

        Assert.areNotEqual(pretension.SAC_UltimaModificacionFichero__c, pretensionResult.SAC_UltimaModificacionFichero__c, 'No se ha modificado el campo SAC_UltimaModificacionFichero__c');
        Test.stopTest();
    }

    @isTest
    static void actualizarSACBloqueFieldTest() {
        Test.startTest();
        Case pretension = [SELECT Id, SAC_UltimaModificacionFichero__c FROM Case WHERE SuppliedCompany = 'TestPret' LIMIT 1];
        List<ContentVersion> listaCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title != 'cv2Test'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        List<String> listaIdsFicheros = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIdsFicheros.add(cv.ContentDocumentId);
        }
       
        pretension.OwnerId = usuario.id; 
        listaCV[0].OwnerId = usuario.id; 
        SAC_DatabaseDML.updateDML(pretension, false);
        SAC_DatabaseDML.updateListDML(listaCV, false);

        System.runAs(usuario){
            SAC_LCMP_GestionEmails.actualizarSACBloqueField(listaIdsFicheros[0]);
        }

        ContentVersion cv = [SELECT Id, SAC_Bloque__c FROM ContentVersion WHERE ContentDocumentId = :listaIdsFicheros[0] ORDER BY CreatedDate DESC LIMIT 1];

        System.assertEquals(true, cv.SAC_Bloque__c.contains('SAC_Respuesta'), 'No se ha puesto el bloque de respuesta');
        Test.stopTest();
    }

    @isTest
    static void comprobarEmailsEnvioTest() {
        
        Test.startTest();

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        string para = 'emailtest@prueba.com';
        string copia1 ='emailtestcopia1@prueba.com';
        string copia2 ='emailtestcopia2@prueba.com';
        string result;
        System.runAs(usuario){
           result =  SAC_LCMP_GestionEmails.comprobarEmailsEnvio(para, copia1, copia2);
        }
        Test.stopTest();

        System.assertEquals('emailtest@prueba.com', result, 'No coincide');
    }

    @isTest
    static void validarFicheroTest() {
        
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId, SAC_ValidadoCV__c, FirstPublishLocationId, SAC_Bloque__c FROM ContentVersion WHERE Title = 'ABC Test' LIMIT 1];
        cv.SAC_ValidadoCV__c = false;
        SAC_DatabaseDML.updateDML(cv, false);
        System.runAs(usuario){
        SAC_LCMP_GestionEmails.validarFichero(cv.ContentDocumentId);
        }
        
        ContentVersion cv2 = [SELECT Id, Title, ContentDocumentId, SAC_ValidadoCV__c, FirstPublishLocationId, SAC_Bloque__c FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        System.assertEquals(cv2.SAC_ValidadoCV__c, true, 'No coincide');
        Test.stopTest();
    }

    @isTest
    static void checkAdjuntoConsultaTest() {
        
        Test.startTest();

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta2test' LIMIT 1];
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId, SAC_ValidadoCV__c, FirstPublishLocationId, SAC_Bloque__c FROM ContentVersion WHERE Title = 'ABC Test' LIMIT 1];

        System.runAs(usuario){
            SAC_LCMP_GestionEmails.checkAdjuntoConsulta(consulta.Id, cv.ContentDocumentId);
        }
        Test.stopTest();

        List<ContentDocumentLink> cdl = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :consulta.Id LIMIT 1];

        Assert.areNotEqual(null, cdl, 'No se ha podido linkar el adjunto a la consulta');
    }

    @isTest
    static void deleteFileConsultaTest() {
        
        Test.startTest();

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta2test' LIMIT 1];
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId, SAC_ValidadoCV__c, FirstPublishLocationId, SAC_Bloque__c FROM ContentVersion WHERE Title = 'ABC Test' LIMIT 1];

        System.runAs(usuario){
            ContentDocumentLink newLink = new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId = consulta.Id,
                ShareType = 'V' 
            );

            SAC_DatabaseDML.insertDML(newLink, true);

            SAC_LCMP_GestionEmails.deleteFileConsulta(consulta.Id, cv.ContentDocumentId);
        }
        Test.stopTest();

        List<ContentDocumentLink> cdl = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :consulta.Id LIMIT 1];

        Assert.areNotEqual(false, cdl.isEmpty(), 'No se ha podido desvincular el adjunto a la consulta');
    }
}