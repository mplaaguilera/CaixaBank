@isTest
public with sharing class SPV_LCMP_InsertarPretensionTest {
    
    @TestSetup
    static void makeData(){
        
        Test.startTest();
    User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
    usuarioAdmin.Username = 'useraadmin@test.com.testdata';
    //Database.insert(usuarioAdmin);
    SPV_DatabaseDML.insertDML(usuarioAdmin, false);

    User usuario;
    System.runAs(usuarioAdmin){
        usuario = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
        //Database.insert(usuario);
        SPV_DatabaseDML.insertDML(usuario, false);

        PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
        PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
        permiSetAssiAdmin.AssigneeId = usuario.Id;
        permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
        //Database.insert(permiSetAssiAdmin);
        SPV_DatabaseDML.insertDML(permiSetAssiAdmin, false);
    }
    Test.stopTest();    

        List<CC_Grupo_Colaborador__c> listGrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado', 1)[0];
        //grupo.OwnerId = usuario.id;
        grupo.SAC_Email__c = 'testSPV@testemail.com.invalid';
        grupo.SAC_DeveloperName__c = 'SPV_FYRLEGALLETRADO';
   
        listGrupos.add(grupo);
        //Database.insert(listGrupos);
        SPV_DatabaseDML.insertListDML(listGrupos, false);

        //Añadir las reclamaciones
        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion = new Map<String, Object>();  //Siendo Object tipo genérico
        camposReclamacion.put('Subject', 'TestRec');
        camposReclamacion.put('Origin', 'Backoffice');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposReclamacion.put('SAC_GrupoLetrado__c', listGrupos[0].Id);

        //Se llama al método que devolverá el caso creado con los campos pasados
        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);

        Map<String, Object> camposReclamacion2 = new Map<String, Object>();  //Siendo Object tipo genérico
        camposReclamacion2.put('Subject', 'TestRec2');
        camposReclamacion2.put('Origin', 'Backoffice');
        camposReclamacion2.put('Status', 'SPV_AnalisisDecision');
        camposReclamacion2.put('SAC_StatusAuxiliar__c', 'SPV_AnalisisDecision');
        camposReclamacion2.put('OwnerId', usuario.Id);
        camposReclamacion2.put('SAC_GrupoLetrado__c', listGrupos[0].Id);

        Case casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion2);
        listaReclamaciones.add(casoReclamacion2);

        //Y, una vez obtenidos los casos en una lista, se insertan
        //Database.insert(listaReclamaciones);
        SPV_DatabaseDML.insertListDML(listaReclamaciones, false);

        

        //Se añaden las pretensiones
        List<Case> listaPretensiones = new List<Case>();

        //Pretensión 1
        Map<String, Object> camposPretension = new Map<String, Object>();
        camposPretension.put('OwnerId', usuario.Id);
        camposPretension.put('SuppliedCompany', 'pret1');

        Case pretension1 = SPV_TestDataFactory.crearCaso('Pretension', camposPretension);
        listaPretensiones.add(pretension1);


        //Pretensión 2
        Map<String, Object> camposPretension2 = new Map<String, Object>();
        camposPretension2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPretension2.put('Status', casoReclamacion.Status);
        camposPretension2.put('SAC_StatusAuxiliar__c', casoReclamacion.Status);
        camposPretension2.put('Origin', casoReclamacion.Origin);
        camposPretension2.put('SAC_TiempoSLARegulatorio__c', 30);
        camposPretension2.put('SAC_TiempoSLALetradoAlta__c', 30);
        camposPretension2.put('CC_No_Identificado__c', true);
        camposPretension2.put('CC_IdentCliente__c', '0');
        camposPretension2.put('OwnerId', usuario.id);
        camposPretension2.put('SAC_EsPrincipal__c', true);

        Case pretension2 = SPV_TestDataFactory.crearCaso('Pretension', camposPretension2);
        listaPretensiones.add(pretension2);

        //Database.insert(listaPretensiones);
        SPV_DatabaseDML.insertListDML(listaPretensiones, false);

           //MCCs
           String mccTematicaRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
           String mccProdServRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
           String mccMotivoRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
           String mccDetalleRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
           
           CC_MCC__c mccTematica = new CC_MCC__c(Name='Tematica', CC_Codigo_Externo__c='a', RecordTypeId=mccTematicaRecordTypeId, CC_Tipo_Cliente__c='SAC');
           //Database.insert(mccTematica);
           SPV_DatabaseDML.insertDML(mccTematica, false);
   
           CC_MCC__c mccProdServ = new CC_MCC__c(Name='ProdServ',CC_Tematica__c = mccTematica.id , CC_Codigo_Externo__c='b', RecordTypeId=mccProdServRecordTypeId, CC_Tipo_Cliente__c='SAC');
           //Database.insert(mccProdServ);
           SPV_DatabaseDML.insertDML(mccProdServ, false);
   
           CC_MCC__c mccMotivo = new CC_MCC__c(Name='Motivo',CC_Producto_Servicio__c = mccProdServ.id, CC_Codigo_Externo__c='c', RecordTypeId=mccMotivoRecordTypeId, CC_Tipo_Cliente__c='SAC');
           //Database.insert(mccMotivo);
           SPV_DatabaseDML.insertDML(mccMotivo, false);
   
           CC_MCC__c mccDetalle = new CC_MCC__c(Name='Detalle',CC_Motivo__c = mccMotivo.id, CC_Codigo_Externo__c='d', RecordTypeId=mccDetalleRecordTypeId, CC_Tipo_Cliente__c='SAC');
           //Database.insert(mccDetalle);
           SPV_DatabaseDML.insertDML(mccDetalle, false);
    }//Fin de makeData



    @isTest
    public static void tienePermisosTest(){
    
        Case reclamacion = [SELECT id, OwnerId FROM Case Where Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username='useraadmin@test.com.testdata' AND isActive = true LIMIT 1];

        Boolean resultado= false;
        System.runAs(usuario){
            Test.startTest();
             resultado = SPV_LCMP_InsertarPretension.tienePermisos(reclamacion.id);
            Test.stopTest();
        }

        //Devuelve true porque una de las pretensiones de esa reclamación tiene como Owner el usuario 
        System.assertEquals(true, resultado, 'No tiene permisos para insertar una pretensión/consulta(Interacción).');

    }



  
    @isTest
    public static void insertarPretensionPrincipalTest(){
        Case casoReclamacion = [SELECT id, Status, Origin, SAC_PretensionPrincipal__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        List<CC_MCC__c> mccs = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            SPV_LCMP_InsertarPretension.insertarPretensionPrincipal(casoReclamacion.id, mccs);
            Test.stopTest();
        }
        Case casoReclamacionAct = [SELECT id, Status, Origin, SAC_PretensionPrincipal__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        Case pretension = [SELECT Id, SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c =:casoReclamacion.id];
        System.assertEquals(pretension.id, casoReclamacionAct.SAC_PretensionPrincipal__c, 'No se ha insertado la pretensión como principal.');
        System.assertEquals(pretension.SAC_Reclamacion__c, casoReclamacionAct.id, 'No se ha insertado la pretensión como principal.');


    }


    @isTest
    public static void insertarPretensionPrincipalTest2(){

        List<CC_MCC__c> mccs = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND isActive = true Limit 1];

        Case pretension = new Case();
        Map<String, Object> campospret = new Map<String, Object>();
        //campospret.put('SAC_Reclamacion__c', casoRelacionado.Id);
        campospret.put('Status', 'SAC_001'); 
        campospret.put('OwnerId', usuario.Id);

        pretension = SPV_TestDataFactory.crearCaso('Pretension', campospret);
        //Database.insert(pretension);
        SPV_DatabaseDML.insertDML(pretension, false);


        Case casoReclamacion = new Case();
        Map<String, Object> camposReclamacion = new Map<String, Object>(); 
        camposReclamacion.put('Subject', 'testRecla');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('SAC_PretensionPrincipal__c', pretension.Id);
        //Se llama al método que devolverá el caso creado con los campos pasados
        casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        //Database.insert(casoReclamacion);
        SPV_DatabaseDML.insertDML(casoReclamacion, false);

        System.runAs(usuario){
            Test.startTest();
            SPV_LCMP_InsertarPretension.insertarPretensionPrincipal(casoReclamacion.id, mccs);
            Test.stopTest();
        }
        Case casoReclamacionAct = [SELECT id, Status, Origin, SAC_PretensionPrincipal__c FROM Case WHERE Subject = 'testRecla' LIMIT 1];
        Case pretensionRes = [SELECT Id, SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c =:casoReclamacion.id];
        System.assertEquals(pretensionRes.id, casoReclamacionAct.SAC_PretensionPrincipal__c, 'No se ha insertado la pretensión como principal.');
        System.assertEquals(pretensionRes.SAC_Reclamacion__c, casoReclamacionAct.id, 'No se ha insertado la pretensión como principal.');


    }


    @isTest
    static void insertarPretensionCasoRelacionado(){

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND isActive = true Limit 1];
        List<CC_MCC__c> mccs = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle'];
        Boolean respuesta = false;

        Case casoRelacionado = new Case();
        Map<String, Object> camposReclamacion = new Map<String, Object>(); 
        camposReclamacion.put('Subject', 'testrelacionado');
        camposReclamacion.put('Status', 'Cerrado');

        //Se llama al método que devolverá el caso creado con los campos pasados
        casoRelacionado = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        //Database.insert(casoRelacionado);
        SPV_DatabaseDML.insertDML(casoRelacionado, false);

        Case pretension = new Case();
        Map<String, Object> campospret = new Map<String, Object>();
        campospret.put('SAC_Reclamacion__c', casoRelacionado.Id);
        campospret.put('Status', 'SAC_001'); 
        campospret.put('OwnerId', usuario.Id);

        pretension = SPV_TestDataFactory.crearCaso('Pretension', campospret);
        //Database.insert(pretension);
        SPV_DatabaseDML.insertDML(pretension, false);

        casoRelacionado.SAC_PretensionPrincipal__c = pretension.Id;
        //Database.update(casoRelacionado);
        SPV_DatabaseDML.updateDML(casoRelacionado, false);

        Case casoPrincipal = new Case();
        Map<String, Object> camposReclamacion2 = new Map<String, Object>(); 
        camposReclamacion2.put('Subject', 'testNuevo');
        camposReclamacion2.put('Status', 'SAC_001');
        camposReclamacion2.put('SAC_CasoRelacionado__c', casoRelacionado.Id);
        casoPrincipal.SAC_CasoRelacionado__c = casoRelacionado.Id;
        
        casoPrincipal = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion2);
        //Database.insert(casoPrincipal);
        SPV_DatabaseDML.insertDML(casoPrincipal, false);

        System.runAs(usuario){
            respuesta = SPV_LCMP_InsertarPretension.insertarPretensiones(casoPrincipal.id, mccs);
      
        }

        System.assertEquals( true, respuesta, 'No se han insertado las pretensiones');

        Test.stoptest();
    }


    @isTest
    static void insertarPretensionesVueltaAltaTest(){
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<CC_MCC__c> mccs = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle'];
        CC_MCC__c mccsRepetido = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle' LIMIT 1];
        mccs.add(mccsRepetido);
        Boolean respuesta = false;
        User usuario = [SELECT id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND isActive = true Limit 1];
        Case pretension = [SELECT Id FROM Case WHERE SAC_Reclamacion__c = :casoReclamacion.Id LIMIT 1];



        System.runAs(usuario){
            Test.startTest();
            casoReclamacion.SPV_VueltaAlta__c = true;
            casoReclamacion.SAC_PretensionPrincipal__c = pretension.Id;
            //Database.update(casoReclamacion);
            SPV_DatabaseDML.updateDML(casoReclamacion, false);

            respuesta = SPV_LCMP_InsertarPretension.insertarPretensiones(casoReclamacion.id, mccs);
            Test.stopTest();
        }
        System.assertEquals( true, respuesta, 'No se han insertado las pretensiones');
    }

    @isTest
    static void insertarPretensionesAltaTest(){
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<CC_MCC__c> mccs = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle'];
        CC_MCC__c mccsRepetido = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle' LIMIT 1];
        mccs.add(mccsRepetido);
        Boolean respuesta = false;
        User usuario = [SELECT id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            respuesta = SPV_LCMP_InsertarPretension.insertarPretensiones(casoReclamacion.id, mccs);
            Test.stopTest();
        }
        System.assertEquals( true, respuesta, 'No se han insertado las pretensiones');
    }

    
    @isTest
    static void insertarPretensionesAnalisisTest(){
        List<CC_MCC__c> mccs = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle'];
        CC_MCC__c mccsRepetido = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle' LIMIT 1];
        mccs.add(mccsRepetido);
        Boolean respuesta = false;
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE subject = 'TestRec2' LIMIT 1];
        Case pretension = [SELECT Id, OwnerId FROM Case WHERE SuppliedCompany = 'pret1' LIMIT 1];
        String idRec = reclamacion.Id; 
        User usuario = [SELECT id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            reclamacion.SAC_PretensionPrincipal__c = pretension.Id;
            //Database.update(reclamacion);
            SPV_DatabaseDML.updateDML(reclamacion, false);
            respuesta = SPV_LCMP_InsertarPretension.insertarPretensiones(reclamacion.id, mccs);
            Test.stopTest();
        }
		System.assertEquals( true, respuesta, 'No se han insertado las pretensiones');        
    }
    
    
}