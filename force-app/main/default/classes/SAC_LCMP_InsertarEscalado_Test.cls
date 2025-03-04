/*****************************************************************
 * Name: SAC_LCMP_InsertarEscalado_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_InsertarEscalado
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US219272         Carlos Solis         23/08/21     Creación Clase
 * 1.1            US593664         Jose Carlos Blanco  	16/05/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_InsertarEscalado_Test {
    @TestSetup
    static void makeData(){

        User usuario;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            SAC_DatabaseDML.insertDML(usuario, false);     
            //Database.insert(usuario);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);    
            //Database.insert(permiSetAssi);
        }

        List<CC_Grupo_Colaborador__c> listagrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();

        System.runAs(usuario){
            // Grupos colaboradores
            listagrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',3);
            listagrupos[0].Name = 'grupoTest';
            listagrupos[0].SAC_PermiteEscalado__c = true;
            listagrupos[0].SAC_NivelGrupo__c = 'SAC_Nivel2';
            listagrupos[0].SAC_Email__c = 'testing@test.test';
            listagrupos[0].SAC_DeveloperName__c = 'COPS';

            listagrupos[1].Name = 'grupoTest';
            listagrupos[1].SAC_PermiteEscalado__c = true;
            listagrupos[1].SAC_NivelGrupo__c = 'SAC_Nivel2';
            listagrupos[1].SAC_Email__c = 'testing@test.test';
            listagrupos[1].SAC_DeveloperName__c = 'AJ';

            listagrupos[2].Name = 'grupoTestFORCAda';
            listagrupos[2].SAC_PermiteEscalado__c = true;
            listagrupos[2].SAC_NivelGrupo__c = 'SAC_Nivel2';
            listagrupos[2].SAC_Email__c = 'testing@test.test';
            listagrupos[2].SAC_DeveloperName__c = 'FYRLEGAL';
            
            SAC_DatabaseDML.insertListDML(listagrupos, false);    
            //Database.insert(listagrupos);
            grupo = listagrupos[0];

            // Colaborador contact
            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = SAC_TestDataFactory.crearColaboradorContact(usuario.Id, grupo.Id); 
            grupoColaboradorContact.SAC_Administrador__c = true;
            SAC_DatabaseDML.insertDML(grupoColaboradorContact, false);   
            //Database.insert(grupoColaboradorContact);

            // Reclamacion

            List<Case> listaReclamaciones = new List<Case>();
            
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('Origin', 'Backoffice');
            camposRecl.put('Status', 'Alta');
            camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
            camposRecl.put('OwnerId', usuario.id);
            camposRecl.put('SEG_Grupo__c', grupo.Id);

            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            listaReclamaciones.add(casoReclamacion);

                    //RECLAMACION 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl2.put('SAC_CasoEspecial__c', 'SAC_Presidencia');
        
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        listaReclamaciones.add(casoReclamacion2);

              //RECLAMACION 3 
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Backoffice');
        camposRecl3.put('Status', 'Alta');
        camposRecl3.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl3.put('OwnerId', usuario.Id);
        camposRecl3.put('SAC_CasoEspecial__c', 'SAC_Presidencia');
        camposRecl3.put('SAC_Importe_Resuelto__c', 10);
        camposRecl3.put('SAC_EntidadProductora__c', 'Microbank');
        
        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
        listaReclamaciones.add(casoReclamacion3);

        //RECLAMACION 4 
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'TestRec4');
        camposRecl4.put('Origin', 'Backoffice');
        camposRecl4.put('Status', 'Alta');
        camposRecl4.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl4.put('OwnerId', usuario.Id);
        camposRecl4.put('CC_Importe_Reclamado__c', 300);
        camposRecl4.put('SAC_Importe_Resuelto__c', 300);
        camposRecl4.put('SAC_EntidadProductora__c', 'Bankia');
        
        Case casoReclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl4);
        listaReclamaciones.add(casoReclamacion4);

        //RECLAMACION 5 
        Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'Reclamacion5');
        camposRecl5.put('Status', 'Alta');
        camposRecl5.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl5.put('OwnerId', usuario.Id);
        camposRecl5.put('SAC_CasoEspecial__c', 'SAC_Sensible');

        Case casoReclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl5);
        listaReclamaciones.add(casoReclamacion5);

           //RECLAMACION 6
           Map<String, Object> camposRecl6 = new Map<String, Object>();
           camposRecl6.put('Subject', 'Reclamacion6');
           camposRecl6.put('Status', 'Alta');
           camposRecl6.put('SAC_StatusAuxiliar__c', 'Alta');
           camposRecl6.put('OwnerId', usuario.Id);
           camposRecl6.put('SAC_CasoEspecial__c', 'SAC_Sensible');
   
           Case casoReclamacion6 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl6);
           listaReclamaciones.add(casoReclamacion6);
                   //RECLAMACION 7
        Map<String, Object> camposRecl7 = new Map<String, Object>();
        camposRecl7.put('Subject', 'Reclamacion7');
        camposRecl7.put('Status', 'Alta');
        camposRecl7.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl7.put('OwnerId', usuario.Id);
        camposRecl7.put('SAC_Entidad_Afectada__c', 'SAC_007');
        camposRecl7.put('CC_Importe_Reclamado__c', 20000);
        
        Case casoReclamacion7 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl7);
        listaReclamaciones.add(casoReclamacion7);

                //RECLAMACION 8
        Map<String, Object> camposRecl8 = new Map<String, Object>();
        camposRecl8.put('Subject', 'TestRec8');
        camposRecl8.put('Origin', 'Backoffice');
        camposRecl8.put('Status', 'Alta');
        camposRecl8.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl8.put('OwnerId', usuario.Id);
        camposRecl8.put('SAC_Importe_Resuelto__c', 10);
        camposRecl8.put('SAC_EntidadProductora__c', 'Microbank');                
        Case casoReclamacion8 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl8);
        listaReclamaciones.add(casoReclamacion8);

         //RECLAMACION 9
         Map<String, Object> camposRecl9 = new Map<String, Object>();
         camposRecl9.put('Subject', 'TestRec9');
         camposRecl9.put('Origin', 'Backoffice');
         camposRecl9.put('Status', 'Alta');
         camposRecl9.put('SAC_StatusAuxiliar__c', 'Alta');
         camposRecl9.put('OwnerId', usuario.Id);
                 
         Case casoReclamacion9 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl9);
         listaReclamaciones.add(casoReclamacion9);

           //RECLAMACION 10
        Map<String, Object> camposRecl10 = new Map<String, Object>();
        camposRecl10.put('Subject', 'TestRec10');
        camposRecl10.put('Origin', 'Backoffice');
        camposRecl10.put('Status', 'Alta');
        camposRecl10.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl10.put('OwnerId', usuario.Id);
        
        Case casoReclamacion10 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl10);
        listaReclamaciones.add(casoReclamacion10);

        SAC_DatabaseDML.insertListDML(listaReclamaciones, false);
        //Database.insert(listaReclamaciones); 
        

            //Interaccion Consulta
            Map<String, Object> camposEsc = new Map<String, Object>();
            camposEsc.put('SAC_Titulo__c', 'propuesta test');
            camposEsc.put('SAC_Propuesta__c', 'propuesta test');
            camposEsc.put('SAC_CasoEscalado__c', casoReclamacion.Id);
            camposEsc.put('SAC_Email1__c', 'testing@test.test');
            camposEsc.put('OwnerId', usuario.Id);
            camposEsc.put('SAC_GrupoColaborador__c', grupo.Id);
            camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
            camposEsc.put('SAC_ImporteAutorizado__c', 20);
            
            SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);
            SAC_DatabaseDML.insertDML(escalado, false);
            //Database.insert(escalado); 
        }


        //Parametrizaciones Escalado 
        Map<String, Object> camposParam = new Map<String, Object>();
        camposParam.put('Name', 'Validacion Escalado AJ');
        camposParam.put('Aplica_escalado__c', true);
        camposParam.put('SAC_Despacho__c', grupo.id);
        camposParam.put('SAC_GrupoDestino__c', grupo.Id);
        camposParam.put('SAC_Importe__c', 200);
        camposParam.put('SAC_Mensaje__c', 'Mensaje');
        camposParam.put('SAC_todosMCCs__c', true);
        camposParam.put('SAC_TodosDespachos__c', true);
        camposParam.put('SAC_validarImporte__c', false);
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado = SAC_TestDataFactory.crearParamEsc(camposParam);
        SAC_DatabaseDML.insertDML(parametrizacionEscalado, false);
        //Database.insert(parametrizacionEscalado);

 
    }

    @isTest
    static void insertarEscaladoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c = 'COPS' LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_InsertarEscalado.insertarEscalado(caso.Id, 'propuesta de prueba', 'titulo1', 'SAC_Importe', 'observaciones', caso.SEG_Grupo__c);
            SAC_LCMP_InsertarEscalado.insertarEscalado(caso.Id, 'propuesta de prueba', 'titulo1', 'SAC_Importe', 'observaciones', grupo.Id);
           
        }
        Test.stopTest();

        SAC_Interaccion__c escalado = [SELECT Id, SAC_Propuesta__c FROM SAC_Interaccion__c LIMIT 1];
        System.assertNotEquals('propuesta de prueba', escalado.SAC_Propuesta__c, 'no se ha podido crear el escalado');
    }

    @isTest
    static void esPropietarioTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Boolean propietario = false;

        Test.startTest();
        System.runAs(usuario) {
            propietario = SAC_LCMP_InsertarEscalado.esPropietario(caso.Id);
        }
        Test.stopTest();

        System.assertEquals(true, propietario, 'no se ha podido comprobar el propietario');
    }

    @isTest
    static void hayEscaladosAbiertosTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Boolean hayEscaladosAbiertos = false;

        Test.startTest();
        System.runAs(usuario) {
            hayEscaladosAbiertos = SAC_LCMP_InsertarEscalado.hayEscaladosAbiertos(caso.Id);
        }
        Test.stopTest();

        System.assertNotEquals(false, hayEscaladosAbiertos, 'no se ha podido comprobar el propietario');
    }
    
     @isTest
    static void adjuntarArchivos() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Propuesta__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];     

        Test.startTest();
        System.runAs(usuario) {
          
            List<ContentVersion> adjuntos = new List<ContentVersion>();
            //Archivo adjunto
            ContentVersion newcont = new ContentVersion();
            newcont.Title  = 'prueba';
            newcont.PathOnClient  = 'caixa.jpeg';
            Blob b=Blob.valueOf('This is version data');
            newcont.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
            newcont.FirstPublishLocationId  = caso.id;
            adjuntos.add(newcont);
            
            //Archivo adjunto
            ContentVersion newcont2 = new ContentVersion();
            newcont2.Title  = 'prueba2';
            newcont2.PathOnClient  = 'caixa.jpeg';
            Blob b2=Blob.valueOf('This is version data');
            newcont2.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
            newcont2.FirstPublishLocationId  = caso.id;
            adjuntos.add(newcont2);

            SAC_DatabaseDML.insertListDML(adjuntos, false);
            //Database.insert(adjuntos);
                
            SAC_LCMP_InsertarEscalado.insertarAdjuntoCaso(caso.Id, 2);
        }
        Test.stopTest();
		
        System.assertNotEquals(null, 'adjuntado', 'no se ha podido adjuntar');    
    }

    @IsTest
    static void recogerGruposParaEscalados_Test(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<CC_Grupo_Colaborador__c> resultado;

        Test.startTest();
        System.runAs(usuario){
            resultado = SAC_LCMP_InsertarEscalado.recogerGruposParaEscalados(caso.Id);
        }
        Test.stopTest();
        
        System.assertNotEquals(null, resultado, 'no se han recogido grupos');   
    }

    @isTest
    static void getPickListValuesIntoListTest(){ 
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        List<SAC_LCMP_InsertarEscalado.plantillasWrapper> resultado;
        Test.startTest();
        System.runAs(usuario) {
            resultado = SAC_LCMP_InsertarEscalado.getPickListValuesIntoList();
        }
        Test.stopTest();
        system.assertNotEquals(resultado, null, 'la creacion del objeto wrapper ha fallado');
    }

    @istest
    static void RecuperarCasoTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<Id> listaIdsCasosRetornar = new List<Id>();

        Test.startTest();
        SAC_DatabaseDML.insertDML(caso, false);
        //Database.update(caso);
		system.runAs(usuario) {
        	caso = SAC_LCMP_InsertarEscalado.recuperarCaso(caso.Id);
        }

        Test.stopTest();

        System.assertNotEquals(Null, caso.Id, 'No se ha recuperado el caso');
    }

    @isTest
    static void recuperarUserTest() {
        Case caso = [SELECT id, OwnerId, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec'];
        User usuario = [SELECT id, name FROM user WHERE Username = 'usertest0@test.com.testSetup' and isActive = true  limit 1];
		PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Map<String,String> resultado = new Map<String,String>();

        System.runAs(usuario) {
            Test.startTest();            
            resultado = SAC_LCMP_InsertarEscalado.recuperarUser(caso, caso.OwnerId);
            Test.stopTest();
        }
        system.assertNotEquals(null, resultado, 'No se ha recuperado el usuario');
    }

    
    @isTest
    static void obtieneAdjuntosTest() {
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];

        ContentVersion cv = SAC_TestDataFactory.crearContentVersion(reclamacion);
        SAC_DatabaseDML.insertDML(cv, false);
        //Database.insert(cv);
        ContentVersion[] resultado;
		System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_InsertarEscalado.obtieneAdjuntos(reclamacion.id);
            Test.stopTest();
        }  
        
        System.assertNotEquals(null, cv.Id, 'No ha funcionado correctamente la recuperación de archivos adjuntos.');
    }

    @isTest 
    static void validacionesEscaladoTest() {
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];

        SAC_Interaccion.ValidacionesEscalado resultado; 

        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_InsertarEscalado.validacionesEscalados(reclamacion.id);
            Test.stopTest();
        }  
        
        System.assertNotEquals(null, resultado, 'No ha funcionado la validacion.');


    }

}