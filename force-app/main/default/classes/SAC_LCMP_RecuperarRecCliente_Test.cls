@isTest
public with sharing class SAC_LCMP_RecuperarRecCliente_Test {
    @TestSetup
    static void makeData(){
        
        Test.startTest();
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];     
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);
        //Database.insert(usuarioAdmin);

        User usuario;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuario.Username = 'ustestesteo@test.com';  
            SAC_DatabaseDML.insertDML(usuario, false);    
            //Database.insert(usuario);
        }
        Test.stopTest();

        //Cuentas
        Account cuentaA = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
        SAC_DatabaseDML.insertDML(cuentaA, false);  
        //Database.insert(cuentaA);
        
        List<Case> listaReclamaciones = new List<Case>();
        //RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('OwnerId', usuario.Id);
        camposRecl.put('AccountId', cuentaA.Id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaReclamaciones.add(casoReclamacion);

        //CONSULTA COPS
        Case casoConsulta3 = new Case();
        casoConsulta3.Subject = 'TestCons3';
        casoConsulta3.Origin = 'Backoffice';
        casoConsulta3.Status = 'Alta';
        casoConsulta3.SAC_StatusAuxiliar__c = casoConsulta3.Status;
        casoConsulta3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        casoConsulta3.OwnerId = usuario.Id;
        casoConsulta3.AccountId = cuentaA.Id;
        listaReclamaciones.add(casoConsulta3);

        //CONSULTA SAC
        Case casoConsulta4 = new Case();
        casoConsulta4.Subject = 'TestCons4';
        casoConsulta4.Origin = 'Backoffice';
        casoConsulta4.Status = 'SAC_011';
        casoConsulta4.SAC_StatusAuxiliar__c = casoConsulta4.Status;
        casoConsulta4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();
        casoConsulta4.OwnerId = usuario.Id;
        casoConsulta4.AccountId = cuentaA.Id;
        listaReclamaciones.add(casoConsulta4);

        SAC_DatabaseDML.insertListDML(listaReclamaciones, false); 
        //Database.insert(listaReclamaciones);  

        List<Case> listaPretensiones = new List<Case>();
        //PRETENSION 1
        Map<String, Object> campsoPret1 = new Map<String, Object>();
        campsoPret1.put('Subject', 'TestPret1');
        campsoPret1.put('Origin', 'Backoffice');
        campsoPret1.put('Status', 'Alta');
        campsoPret1.put('SAC_StatusAuxiliar__c', 'Alta');
        campsoPret1.put('OwnerId', usuario.Id);
        campsoPret1.put('SAC_Reclamacion__c', casoReclamacion.Id);
        
        Case casoPretension1 = SAC_TestDataFactory.crearCaso('Pretension',campsoPret1);
        listaPretensiones.add(casoPretension1);
        SAC_DatabaseDML.insertListDML(listaPretensiones, false); 
        //Database.insert(listaPretensiones); 

        //grupo colaborador nivel 2
        List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1);
        listaGrupos[0].Name = 'grupoTest';
        listaGrupos[0].SAC_PermiteEscalado__c = true;
        listaGrupos[0].SAC_NivelGrupo__c = 'SAC_Nivel2';
        listaGrupos[0].SAC_Email__c = 'etesting@test.test';
        listaGrupos[0].SAC_Email2__c = 'etesting1@test.test';
        listaGrupos[0].SAC_Email3__c = 'etesting2@test.test';
        listaGrupos[0].SAC_PeriodoConsulta__c = 12;
        listaGrupos[0].SAC_PermiteConsultas__c = true;
        listaGrupos[0].SAC_TieneUsuariosActivos__c = true;
        listaGrupos[0].SAC_TienePropietario__c = true;
        SAC_DatabaseDML.insertListDML(listaGrupos, false); 
        //Database.insert(listaGrupos);

        //Interaccion escalado
        List<SAC_Interaccion__c> listaInteracciones = new List<SAC_Interaccion__c>();
        Map<String, Object> camposEsc = new Map<String, Object>();
        camposEsc.put('SAC_Titulo__c', 'propuesta test');
        camposEsc.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc.put('SAC_CasoEscalado__c', casoReclamacion.Id);
        camposEsc.put('SAC_Email1__c', 'testing@test.test');
        camposEsc.put('OwnerId', usuario.Id);
        camposEsc.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        
        SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);
        listaInteracciones.add(escalado);

        //Interaccion consulta
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('SAC_Titulo__c', 'consulta');
        camposCons.put('SAC_Propuesta__c', 'consulta');
        camposCons.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposCons.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposCons.put('OwnerId', usuario.Id);
        
        SAC_Interaccion__c interaccion = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
        listaInteracciones.add(interaccion);
        SAC_DatabaseDML.insertListDML(listaInteracciones, false); 
        //Database.insert(listaInteracciones);

        //Tareas
        SAC_Accion__c accion1 = SAC_TestDataFactory.crearTareas(1,casoPretension1,false)[0];
        accion1.SAC_Reclamacion__C = casoReclamacion.Id;
        SAC_DatabaseDML.insertDML(accion1, false); 
        //Database.insert(accion1);
    }

    @isTest
    static void getReclamacionesClienteTest() {
        Account cuenta = [SELECT id FROM Account WHERE PersonEmail = 'acuserecibo0@acuse.com.test' LIMIT 1];
		User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        List<SAC_LCMP_RecuperarReclamacionesCliente.InfoReclamacionWrapper> wrapperReclamaciones;

        System.runAs(usuario) {
            Test.startTest();
        	wrapperReclamaciones = SAC_LCMP_RecuperarReclamacionesCliente.getReclamacionesCliente(cuenta.Id);
            Test.stopTest();
        }
        
        Assert.areNotEqual(null, wrapperReclamaciones, 'No se ha recuperado reclamaciones asociadas al reclamante.');
    }
}