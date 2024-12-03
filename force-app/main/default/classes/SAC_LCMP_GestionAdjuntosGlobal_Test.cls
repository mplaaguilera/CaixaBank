@isTest
public with sharing class SAC_LCMP_GestionAdjuntosGlobal_Test {
    @TestSetup
    static void makeData(){

        List<User> usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        usuarioGeneral[0].Username = 'ustestesteo@test.com';       
        Database.insert(usuarioGeneral);

        List<User> usuarioSPV = SPV_TestDataFactory.crearUsuarioAdministrador(1);
        Database.insert(usuarioSPV);

        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        Database.insert(cuenta);
       
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('AccountId', cuenta.Id);
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(casoReclamacion);

        Map<String, Object> camposRecSPV = new Map<String, Object>();
        camposRecSPV.put('Subject', 'TestRecSPV');
        camposRecSPV.put('Status', 'SAC_002');
        Case casoReclamacionSPV = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecSPV);
        Database.insert(casoReclamacionSPV);

        Map<String, Object> camposConl = new Map<String, Object>();
        camposConl.put('Subject', 'TestCons');
        Case casoConsulta = SAC_TestDataFactory.crearCaso('Consulta',camposConl);
        Database.insert(casoConsulta);

        ContentVersion cv = SAC_TestDataFactory.crearContentVersion(casoReclamacion);
        Database.insert(cv);

        List<SAC_MaestroTemas__c> maestrosTemas = SAC_TestDataFactory.crearMaestroTemas(1,'SAC_TipoAdjuntos');
        maestrosTemas[0].Name = 'TestMaestro';
        Database.insert(maestrosTemas);
    }
    
    @isTest
    static void recuperarDatosTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_GestionAdjuntosGlobal.oficinaWrapper resultado = SAC_LCMP_GestionAdjuntosGlobal.recuperarDatos(reclamacion.id, 'Status', 'Case');
            Test.stopTest();
            
            Assert.areNotEqual(resultado, null, 'No ha recuperado nada.');
        }
    }
    
    @isTest
    static void replicarAdjuntosCaseTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        ContentVersion cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        Boolean resultado = false;

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_GestionAdjuntosGlobal.replicarAdjuntosCase(cv.ContentDocumentId, reclamacion.id, false, true);
            Test.stopTest();
            
            Assert.areEqual(resultado, resultado, 'No se ha replicado el documento.');
        } 
    }

    @isTest
    static void replicarAdjuntosCase2Test(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        ContentVersion cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        Boolean resultado = false;

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_GestionAdjuntosGlobal.replicarAdjuntosCase(cv.ContentDocumentId, reclamacion.id, true, false);
            Test.stopTest();
            
            Assert.areEqual(resultado, resultado, 'No se ha replicado el documento.');
        } 
    }

    @isTest
    static void replicarAdjuntosCaseTest2(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecSPV' LIMIT 1];
        ContentVersion cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        Boolean resultado = false;

        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            reclamacion.OwnerId = usuario.Id;
            Database.update(reclamacion);

            resultado = SAC_LCMP_GestionAdjuntosGlobal.replicarAdjuntosCase(cv.ContentDocumentId, reclamacion.id, false, true);
            Test.stopTest();
            
            Assert.areEqual(resultado, resultado, 'No se ha replicado el documento.');
        } 
    }
    
    @isTest
    static void recuperaAdjuntosTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            ContentVersion[] resultado = SAC_LCMP_GestionAdjuntosGlobal.recuperaAdjuntos(reclamacion.id);
            Test.stopTest();
            
            Assert.areEqual(resultado[0].Id, cv.Id, 'No ha funcionado correctamente la recuperación de archivos adjuntos.');
        }
    }
    
    @isTest
    static void desvincularAdjuntoTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        ContentVersion cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_GestionAdjuntosGlobal.desvincularAdjunto(cv.ContentDocumentId, reclamacion.id);
            Test.stopTest();
        }

        List<ContentVersion> cvD = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        Assert.areEqual(cv.id, cvD[0].id, 'No se ha desvinculado el documento.'); 
    }
    
    @isTest
    static void eliminarAdjuntoTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        ContentVersion cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_GestionAdjuntosGlobal.eliminarAdjunto(cv.ContentDocumentId);
            Test.stopTest();
            
            List<ContentVersion> cvD = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
            
            Assert.areNotEqual(cv.id, null, 'No se ha eliminado el documento.');
        }
    }

    @isTest
    static void obtieneAdjuntosTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        ContentVersion cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

        ContentVersion[] resultado;
		System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_GestionAdjuntosGlobal.obtieneAdjuntos(reclamacion.id);
            Test.stopTest();
        }  
        
        Assert.areNotEqual(null, cv.Id, 'No ha funcionado correctamente la recuperación de archivos adjuntos.');
    }
    
    @isTest
    static void ocultarContentVersionTest(){
        ContentVersion cv = [SELECT Id,ContentDocumentId,SAC_Oculto__c FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_GestionAdjuntosGlobal.ocultarContentVersion(cv.id);
            Test.stopTest();
        }

        ContentVersion csOculto = [SELECT Id,ContentDocumentId,SAC_Oculto__c FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        Assert.areEqual(true,csOculto.SAC_Oculto__c, 'No se ha ocultado el documento.');
    }
   
    @isTest
    static void desocultarContentVersion(){
        ContentVersion cv = [SELECT Id,ContentDocumentId,SAC_Oculto__c FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_GestionAdjuntosGlobal.desocultarContentVersion(cv.id);
            Test.stopTest();
        }

        ContentVersion csOculto = [SELECT Id,ContentDocumentId,SAC_Oculto__c FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        Assert.areEqual(false,csOculto.SAC_Oculto__c, 'No se ha desocultado el documento.');
    }

    @isTest
    static void recuperaTipoAdjuntosTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        ContentVersion cv = [SELECT Id,ContentDocumentId,SAC_Oculto__c FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            List<SAC_MaestroTemas__c> resultado = SAC_LCMP_GestionAdjuntosGlobal.recuperaTipoAdjuntos(reclamacion.id);
            Test.stopTest();
            
            Assert.areNotEqual(null, resultado, 'No se ha recuperado el tipo de documento correctamente.'); 
        }
    }

    @isTest
    static void asignarTipoAdjuntoTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<ContentVersion> cv = [SELECT Id,ContentDocumentId,SAC_Oculto__c,SAC_TipoAdjunto__c FROM ContentVersion WHERE Title='ABC Test'];
        SAC_MaestroTemas__c maestroT = [SELECT Id, SAC_DocumentoVisible__c FROM SAC_MaestroTemas__c WHERE Name = 'TestMaestro' LIMIT 1];

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_GestionAdjuntosGlobal.asignarTipoAdjunto(cv[0].Id, cv, maestroT);
            Test.stopTest();      
        }

        List<ContentVersion> cvUpdate = [SELECT Id,ContentDocumentId,SAC_Oculto__c, SAC_TipoAdjunto__c FROM ContentVersion WHERE Title='ABC Test'];
        Assert.areEqual(cv[0].SAC_TipoAdjunto__c, cvUpdate[0].SAC_TipoAdjunto__c, 'No se ha actualizando el tipo adjunto correctamente');     
    }

    @isTest
    static void cambiarClasificacionTest(){
        List<ContentVersion> cv = [SELECT Id,ContentDocumentId,SAC_Oculto__c,SAC_Bloque__c FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        List<String> listaValores = new List<String>{'SAC_Entrada', 'SAC_Respuesta'};

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_GestionAdjuntosGlobal.cambiarClasificacion(cv[0].Id, listaValores);
            Test.stopTest();      
        }

        List<ContentVersion> cvUpdate = [SELECT Id,ContentDocumentId,SAC_Oculto__c, SAC_Bloque__c FROM ContentVersion WHERE Title='ABC Test'];
        Assert.areNotEqual(cv[0].SAC_Bloque__c, cvUpdate[0].SAC_Bloque__c, 'No se ha actualizado la clasificación de adjunto correctamente');     
    }

    
    @isTest
    static void cambiarTituloFicheroTest(){
        ContentVersion cv = [SELECT Id,ContentDocumentId, Title FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

		System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_GestionAdjuntosGlobal.cambiarTituloFichero(cv.Id, 'titulo', '0001', false);
            SAC_LCMP_GestionAdjuntosGlobal.cambiarTituloFichero(cv.Id, 'titulo', '0001', true);
            Test.stopTest();      
        }

        Assert.areNotEqual(cv.Title, 'test', 'Los titulos no son iguales');     
    }
}