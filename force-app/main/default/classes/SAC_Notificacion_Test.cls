/*****************************************************************
 * Name: SAC_Notificacion_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Notificacion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR                DATE         Description
 * 1.0            US219258         Marcela Neira         17/06/21     Creación Clase
 * 1.1            NAN              Carlos Solis          17/09/21     Modificación acorde a testear la última modificación de la clase SAC_Notificacion
 * 1.2            US643756         Jose Carlos Blanco    11/07/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@istest
public with sharing class SAC_Notificacion_Test {
   @TestSetup
   static void makeData(){
      
      Id recordTypeIdMCCSAC = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

      //Grupos
      List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
      CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor', 1)[0];
      grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
      grupoColaborador.SAC_MaximoCasosDiarios__c = 1;

      CC_Grupo_Colaborador__c grupoColaborador2 = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1)[0];
      grupoColaborador2.SAC_PermiteEscalado__c = true;
      grupoColaborador2.SAC_NivelGrupo__c = 'SAC_Nivel2';
      grupoColaborador2.SAC_Email__c = 'etesting@test.test';
      
      listaGrupos.add(grupoColaborador);
      listaGrupos.add(grupoColaborador2);
      SAC_DatabaseDML.insertListDML(listaGrupos, false);
      //Database.insert(listaGrupos);

      //Usuarios
      List<User> listaUsers = new List<User>();
      List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
      User usuarioGeneral;
      User usuarioGeneral2;
      System.runAs(new User(Id = Userinfo.getUserId())) {
         //Usuario SAC General
         usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(2)[0];
         usuarioGeneral.Username = 'usergeneralSAC@test.com';
         usuarioGeneral.SAC_GruposPerteneciente__c = grupoColaborador.id;     
         listaUsers.add(usuarioGeneral);

         //Usuario SAC General 2
         usuarioGeneral2 = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
         usuarioGeneral2.Username = 'usergeneralSAC2@test.com';
         usuarioGeneral2.SAC_GruposPerteneciente__c = grupoColaborador.id;     
         listaUsers.add(usuarioGeneral2);
         SAC_DatabaseDML.insertListDML(listaUsers, false);
         //Database.insert(listaUsers);

         //Permisos
         PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
         PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
         permiSetAssi.AssigneeId = usuarioGeneral.Id;
         permiSetAssi.PermissionSetId = permiSet.Id;
         permisos.add(permiSetAssi);

         PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
         PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
         permiSetAssi2.AssigneeId = usuarioGeneral2.Id;
         permiSetAssi2.PermissionSetId = permiSet2.Id;
         permisos.add(permiSetAssi2);
         SAC_DatabaseDML.insertListDML(permisos, false);
         //Database.insert(permisos);

         //Grupo colaborador contact
         List<CC_Grupo_Colaborador_Contact__c> listaColabContact = new List<CC_Grupo_Colaborador_Contact__c>();
         CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = SAC_TestDataFactory.crearColaboradorContact(usuarioGeneral.Id, grupoColaborador.Id);
         grupoColaboradorContact.SAC_Administrador__c = true;
         listaColabContact.add(grupoColaboradorContact);

         CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SAC_TestDataFactory.crearColaboradorContact(usuarioGeneral2.Id, grupoColaborador.Id);
         grupoColaboradorContact2.SAC_Administrador__c = true;
         listaColabContact.add(grupoColaboradorContact2);

         SAC_DatabaseDML.insertListDML(listaColabContact, false);
         //Database.insert(listaColabContact);
      }
           
      //MCCs
      CC_MCC__c mccDetalle = new CC_MCC__c(Name='Prueba', CC_Codigo_Externo__c='a', RecordTypeId=recordTypeIdMCCSAC, CC_Tipo_Cliente__c='SAC');
      SAC_DatabaseDML.upsertDML(mccDetalle, false);
      //Database.upsert(mccDetalle);

      SAC_ParametrizacionSLATME__c parametrizacion1 = SAC_TestDataFactory.crearParamsSla('Regulatorio', 1)[0];
      parametrizacion1.SAC_Duracion__c = 3;
      parametrizacion1.SAC_MCC__c = mccDetalle.Id; 
      parametrizacion1.SAC_CanalProcedencia__c = ''; 
      SAC_DatabaseDML.upsertDML(parametrizacion1, false);
      //Database.upsert(parametrizacion1);

      //Cuentas
      Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
      cuenta.Name = 'Cuenta A';
      cuenta.Phone = '123456789';
      cuenta.CC_Email__c = 'cuenta@test.test';
      cuenta.billingStreet  = 'Calle Mayor 55';
      cuenta.BillingCountry = 'España';
      cuenta.OwnerId = usuarioGeneral.id;
      SAC_DatabaseDML.insertDML(cuenta, false);
      //Database.insert(cuenta);

      Account cuentaOfi = SAC_TestDataFactory.crearCuentasOficina(1)[0];
      SAC_DatabaseDML.insertDML(cuentaOfi, false);
      //Database.insert(cuentaOfi);

      Test.startTest();

      //Reclamaciones
      List<Case> misCasos = new List<Case>();
      //Reclamacion 1
      Map<String, Object> camposRecl = new Map<String, Object>();
      camposRecl.put('Subject', 'reclamacion1');
      //camposRecl.put('OS_SLA_Completado__c', 'SLAAltaEntitlement');
      camposRecl.put('SEG_Detalle__c', mccDetalle.id);
      camposRecl.put('SAC_FechaRecepcion__c', system.now());
      camposRecl.put('AccountId', cuenta.id);
      camposRecl.put('OwnerId', usuarioGeneral2.id);
      camposRecl.put('SEG_Grupo__c', grupoColaborador.id);
    
      Case caso = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
      misCasos.add(caso);  

      //Reclamacion 2
      Map<String, Object> camposRecl2 = new Map<String, Object>();
      camposRecl2.put('Subject', 'reclamacion2');
      //camposRecl2.put('OS_SLA_Completado__c', '48RegulatorioEntitlement');
      camposRecl2.put('SEG_Detalle__c', mccDetalle.id);
      camposRecl2.put('SAC_FechaRecepcion__c', system.now());
    
      Case caso2 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl2);
      misCasos.add(caso2);  

      //Reclamacion 3
      Map<String, Object> camposRecl3 = new Map<String, Object>();
      camposRecl3.put('Subject', 'reclamacion5');
      //camposRecl3.put('OS_SLA_Completado__c', '24RegulatorioEntitlement');
      camposRecl3.put('SEG_Detalle__c', mccDetalle.id);
      camposRecl3.put('SAC_FechaRecepcion__c', system.now());
    
      Case caso3 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl3);
      misCasos.add(caso3); 
      
      //Reclamacion 4
      Map<String, Object> camposRecl4 = new Map<String, Object>();
      camposRecl4.put('Subject', 'recPrueba');
      camposRecl4.put('Status', 'SAC_003');
      camposRecl4.put('SAC_StatusAuxiliar__c', 'SAC_003');
      camposRecl4.put('SEG_Detalle__c', mccDetalle.Id);
      camposRecl4.put('SAC_FechaRecepcion__c', system.now());
      camposRecl4.put('OwnerId', usuarioGeneral2.id);
      camposRecl4.put('SEG_Grupo__c', grupoColaborador.id);
    
      Case caso4 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl4);
      misCasos.add(caso4); 

      //Reclamacion 5
      Map<String, Object> camposRecl5 = new Map<String, Object>();
      camposRecl5.put('Subject', 'recPrueba2');
      camposRecl5.put('Status', 'SAC_002');
      camposRecl5.put('SAC_StatusAuxiliar__c', 'SAC_002');
      camposRecl5.put('SEG_Detalle__c', mccDetalle.Id);
      camposRecl5.put('SAC_FechaRecepcion__c', system.now());
      camposRecl5.put('OwnerId', usuarioGeneral2.id);
      camposRecl5.put('SEG_Grupo__c', grupoColaborador.id);
    
      Case caso5 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl5);
      misCasos.add(caso5); 

      SAC_DatabaseDML.insertListDML(misCasos, false);
      //Database.insert(misCasos);

      

      //Pretensiones
      List<Case> listaPrets = new List<Case>();
      //Pretension
      Map<String, Object> camposPret = new Map<String, Object>();
      //camposPret.put('OS_SLA_Completado__c', '24LetradoEntitlement');
      camposPret.put('Subject', 'pretPrueba');
      camposPret.put('SAC_Reclamacion__c', caso.Id);
      camposPret.put('SEG_Detalle__c', mccDetalle.id);
      camposPret.put('SAC_FechaRecepcion__c', system.now());
      camposPret.put('OwnerId', usuarioGeneral.id);
    
      Case casoPret = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
      listaPrets.add(casoPret);

      //Pretension 2
      Map<String, Object> camposPret2 = new Map<String, Object>();
      camposPret2.put('SuppliedCompany', 'testpret2');
      //camposPret2.put('OS_SLA_Completado__c', '24LetradoEntitlement');
      camposPret2.put('SAC_Reclamacion__c', caso4.Id);
      camposPret2.put('SEG_Detalle__c', mccDetalle.id);
      camposPret2.put('SAC_FechaRecepcion__c', system.now());
      camposPret2.put('OwnerId', usuarioGeneral.id);
    
      Case casoPret2 = SAC_TestDataFactory.crearCaso('Pretension', camposPret2);
      listaPrets.add(casoPret2);

      SAC_DatabaseDML.insertListDML(listaPrets, false);
      //Database.insert(listaPrets);


      //Test.startTest();
      //Escalado
      Map<String, Object> camposEsc = new Map<String, Object>();
      camposEsc.put('SAC_Titulo__c', 'propuesta test');
      camposEsc.put('SAC_Propuesta__c', 'propuesta test');
      camposEsc.put('SAC_CasoEscalado__c', caso.Id);
      camposEsc.put('SAC_Email1__c', 'testing@test.test');
      camposEsc.put('OwnerId', usuarioGeneral.Id);
      camposEsc.put('SAC_GrupoColaborador__c', grupoColaborador2.Id);
      camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
      
      SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);
      SAC_DatabaseDML.insertDML(escalado, false);
      //Database.insert(escalado);

      //Parametrización escalado
      Map<String, Object> camposParam = new Map<String, Object>();
      camposParam.put('Name', 'Validacion Escalado AJ');
      camposParam.put('Aplica_escalado__c', true);
      //camposParam.put('SAC_Despacho__c', grupoColaborador2.id);
      //camposParam.put('SAC_GrupoDestino__c', grupoColaborador.id);
      camposParam.put('SAC_Importe__c', 200);
      camposParam.put('SAC_Mensaje__c', 'Mensaje');
      camposParam.put('SAC_todosMCCs__c', true);
      camposParam.put('SAC_TodosDespachos__c', true);
      camposParam.put('SAC_validarImporte__c', false);
      
      SAC_ParametrizacionEscalado__c parametrizacionEscalado = SAC_TestDataFactory.crearParamEsc(camposParam);
      SAC_DatabaseDML.insertDML(parametrizacionEscalado, false);
      //Database.insert(parametrizacionEscalado);

      //Acciones
      SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas (1, caso, false)[0];
      tarea.SAC_Descripcion__c = 'tareaTest1';
      tarea.OwnerId = usuarioGeneral2.Id;
      SAC_DatabaseDML.insertDML(tarea, false);
      //Database.insert(tarea);
      
      //Interaccion Consulta
      Map<String, Object> camposCons = new Map<String, Object>();
      camposCons.put('SAC_Pregunta__c', 'pregunta test');
      camposCons.put('SAC_Titulo__c', 'titulo test'); //En este caso solo se utiliza para luego filtrar la query
      camposCons.put('OwnerId', usuarioGeneral.id);

      SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
      SAC_DatabaseDML.insertDML(consulta, false);
      //Database.insert(consulta);

      Test.stopTest();
   }

   @istest
   static void comprobarTest(){
      Test.startTest();
      User usuario = [SELECT id FROM User WHERE Username = 'usergeneralSAC2@test.com' AND IsActive = true LIMIT 1];
      Case caso = [SELECT id, OS_SLA_Completado__c  FROM Case WHERE Subject = 'reclamacion1' LIMIT 1];
      Case caso2 = [SELECT id, OS_SLA_Completado__c  FROM Case WHERE SuppliedCompany = 'testpret2' LIMIT 1];
      Case caso3 = [SELECT id, OS_SLA_Completado__c  FROM Case WHERE Subject = 'recPrueba2' LIMIT 1];
      
      System.runAs(usuario){
         caso.OS_SLA_Completado__c = '48RegulatorioEntitlement';
         caso2.OS_SLA_Completado__c = '24RegulatorioEntitlement';
         caso3.OS_SLA_Completado__c = '48LetradoEntitlement';
         SAC_DatabaseDML.updateDML(caso, false);
         //Database.update(caso);
         SAC_DatabaseDML.updateDML(caso2, false);
         //Database.update(caso2);
         SAC_DatabaseDML.updateDML(caso3, false);
         //Database.update(caso3);
      }

      Case casoActualizado = [SELECT id, OS_SLA_Completado__c  FROM Case WHERE Subject = 'reclamacion1' LIMIT 1];
    
      System.assertNotEquals(caso.OS_SLA_Completado__c, casoActualizado.OS_SLA_Completado__c, 'No se ha modificado el picklist con el valor Adecuado');
      Test.stopTest();
   }

   @isTest
   static void derivacionTest(){
      Test.startTest();
      User usuario = [SELECT id FROM User WHERE Username = 'usergeneralSAC2@test.com' AND IsActive = true LIMIT 1];
      Case caso = [SELECT Id, Status FROM Case WHERE Subject = 'reclamacion1'];

      System.runAs(usuario){
         caso.Status = 'SAC_008';
         caso.SAC_StatusAuxiliar__c = 'SAC_008';

         SAC_DatabaseDML.updateDML(caso, false);
         //Database.update(caso);
      }

      Case casoFinal = [SELECT Id, Status FROM Case WHERE Subject = 'reclamacion1'];
      System.assertEquals('SAC_008', casoFinal.Status, 'No se ha podido notificar la derivacion');
      Test.stopTest();
   }

   /*@isTest
   static void notificarCambioOwnerTest() {
      Test.startTest();
      Case caso = [SELECT Id, Status, SEG_Grupo__c FROM Case WHERE Subject = 'recPrueba' LIMIT 1];
      User usuario = [SELECT Id FROM User WHERE Username = 'usergeneralSAC@test.com' LIMIT 1];
      User usuario2 = [SELECT Id FROM User WHERE Username = 'usergeneralSAC2@test.com' LIMIT 1];
      CC_Grupo_Colaborador__c grupoA = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoA' LIMIT 1];

      system.runAs(usuario){
         PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
         PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
         permiSetAssi.AssigneeId = usuario.Id;
         permiSetAssi.PermissionSetId = permiSet.Id;
         insert permiSetAssi;

         PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
         PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
         permiSetAssi2.AssigneeId = usuario2.Id;
         permiSetAssi2.PermissionSetId = permiSet2.Id;
         insert permiSetAssi2;
      }

      caso.OwnerId = usuario.Id;

      
      System.runAs(usuario2){  
         update caso;
      }
      Case casoFinal = [SELECT Id, Status, OwnerId FROM Case WHERE Subject = 'recPrueba'];
      
      
      System.assertEquals(usuario.Id, casoFinal.OwnerId, 'No se ha podido notificar el cambio de owner');

      Test.stopTest();
   }*/

   @isTest
   static void notificarEjecucionTest() {
      Test.startTest();
      User usuario = [SELECT id FROM User WHERE Username = 'usergeneralSAC2@test.com' AND IsActive = true LIMIT 1];
      List<Case> listaCaso = [SELECT Id, Status, Subject, SuppliedCompany FROM Case WHERE Subject = 'recPrueba' OR SuppliedCompany = 'testpret2'];
      Account cuentaOfi = [SELECT Id FROM Account WHERE Name = 'cuentaTest Oficina0' LIMIT 1];
      Case reclamacion = new Case();
      Case pretension = new Case();
      for (Case caso : listaCaso) {
         if (caso.Subject == 'recPrueba') {
            reclamacion = caso;
         } else {
            pretension = caso;
         }
      }

      System.runAs(usuario){
         reclamacion.Status = 'SAC_004';
         reclamacion.SAC_StatusAuxiliar__c = 'SAC_004';
         reclamacion.SAC_PretensionPrincipal__c = pretension.Id;
         
      }
      reclamacion.CC_Oficina_Afectada_Lookup__c = cuentaOfi.id;
         
      SAC_DatabaseDML.updateDML(reclamacion, false);
      //Database.update(reclamacion);

      Case casoFinal = [SELECT Id, Status FROM Case WHERE Subject = 'recPrueba' LIMIT 1];
      System.assertEquals('SAC_004', casoFinal.Status, 'No se ha podido notificar el cambio de redacción a ejecución');
      Test.stopTest();
   }

   @isTest
   static void notificarVolverAltaTest() {
      Test.startTest();
      User usuario = [SELECT id FROM User WHERE Username = 'usergeneralSAC2@test.com' AND IsActive = true LIMIT 1];
      Case caso = [SELECT Id, Status FROM Case WHERE Subject = 'recPrueba2' LIMIT 1];
      
      System.runAs(usuario){
         caso.Status = 'SAC_001';
         caso.SAC_StatusAuxiliar__c = 'SAC_001';

         SAC_DatabaseDML.updateDML(caso, false);
         //Database.update(caso);
      }

      Case casoFinal = [SELECT Id, Status FROM Case WHERE Subject = 'recPrueba2' LIMIT 1];
      System.assertEquals('SAC_001', casoFinal.Status, 'No se ha podido notificar el cambio de análisis a alta');
      Test.stopTest();
   }

   @isTest
   static void notificarConsultaTest() {
      Test.startTest();
      Id recTypeConsulta = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
      Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'reclamacion1' LIMIT 1];
      User usuario = [SELECT id FROM User WHERE Username = 'usergeneralSAC2@test.com' AND IsActive = true LIMIT 1];
      
      
      System.runAs(usuario){
         SAC_Interaccion__c consulta = new SAC_Interaccion__c();
         consulta.recordTypeId = recTypeConsulta;
         consulta.SAC_Reclamacion__c = reclamacion.Id;
         
         SAC_DatabaseDML.insertDML(consulta, false);
         //Database.insert(consulta);

         SAC_Interaccion__c consultaFinal = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Reclamacion__c = :reclamacion.Id LIMIT 1];
         System.assertEquals(consulta.Id, consultaFinal.Id, 'no se ha podido notificar la inserción de la consulta');
      }
      Test.stopTest();
   }

   @isTest
   static void notificarCasoCreadoVinculadoTest() {
      Test.startTest();
      Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
      Case caso = [SELECT Id, AccountId FROM Case WHERE Subject = 'reclamacion1' LIMIT 1];
      User usuario = [SELECT id FROM User WHERE Username = 'usergeneralSAC2@test.com' AND IsActive = true LIMIT 1];
      
      System.runAs(usuario){
         Case casoNuevo = new Case();
         casoNuevo.RecordTypeId = recTypeReclamacion;
         casoNuevo.AccountId = caso.AccountId;
         casoNuevo.Subject = 'nueva Rec';

         SAC_DatabaseDML.insertDML(casoNuevo, false);
         //Database.insert(casoNuevo);
      }

      Case casoFinal = [SELECT Id, Subject FROM Case WHERE Subject = 'nueva Rec'];
      System.assertEquals('nueva Rec', casoFinal.Subject, 'No se ha podido notificar el caso creado con vinculación');
      Test.stopTest();
   }

   @isTest
   static void notificarEscaladoAtendidoTest() {
      Test.startTest();
      User usuario = [SELECT id FROM User WHERE Username = 'usergeneralSAC@test.com' AND IsActive = true LIMIT 1];
      SAC_Interaccion__c escalado = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test'];

      System.runAs(usuario){
         escalado.SAC_Estado__c = 'SAC_Atendida';
         escalado.SAC_ImporteAutorizado__c = 20;

         SAC_DatabaseDML.updateDML(escalado, false);
         //Database.update(escalado);
      }

      SAC_Interaccion__c escaladoFinal = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test'];
      System.assertEquals('SAC_Atendida', escaladoFinal.SAC_Estado__c, 'No se ha podido notificar el escalado atendido');
      Test.stopTest();
   }

   @isTest
   static void notificarTareasFinalizadasTest() {
      Test.startTest();
      User usuario = [SELECT Id FROM User WHERE Username = 'usergeneralSAC2@test.com' AND isActive = true LIMIT 1];
      Case caso = [SELECT Id, AccountId, OwnerId FROM Case WHERE Subject = 'reclamacion1' LIMIT 1];
      SAC_Accion__c tarea = [SELECT Id, OwnerId FROM SAC_Accion__c WHERE SAC_Descripcion__c = 'tareaTest1' LIMIT 1];

      system.runAs(usuario) {
         tarea.SAC_Estado__c = 'SAC_FinalizadaIncompleta';
         SAC_DatabaseDML.updateDML(tarea, false);
         //Database.update(tarea);
      }

      SAC_Accion__c tareaFinal = [SELECT Id, OwnerId, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Descripcion__c = 'tareaTest1' LIMIT 1];
      System.assertEquals('SAC_FinalizadaIncompleta', tareaFinal.SAC_Estado__c, 'No se ha podido notificar la tarea finalizada');
      Test.stopTest();
   }

   @isTest
   static void notiAntiguoPropietarioTest() {
      Test.startTest();
      User usuario = [SELECT Id FROM User WHERE Username = 'usergeneralSAC@test.com' AND isActive = true LIMIT 1];
      Case caso = [SELECT Id, AccountId, OwnerId FROM Case WHERE Subject = 'recPrueba' LIMIT 1];
      User usuario2 = [SELECT Id FROM User WHERE Username = 'usergeneralSAC2@test.com' AND isActive = true LIMIT 1];

      System.runAs(usuario2){
         caso.OwnerId = usuario.Id;
         SAC_DatabaseDML.updateDML(caso, false);
         //Database.update(caso);

      }

      Case casoFinal = [SELECT Id, AccountId, OwnerId FROM Case WHERE Subject = 'recPrueba' LIMIT 1];
      System.assertEquals(usuario.Id, casoFinal.OwnerId, 'No se ha podido notificar el cambio de owner');
      Test.stopTest();
   }

   @isTest
   static void notiAntiguoPropietarioTest2() {
      Test.startTest();
      User usuario = [SELECT Id FROM User WHERE Username = 'usergeneralSAC@test.com' AND isActive = true LIMIT 1];
      Case caso = [SELECT Id, AccountId, OwnerId FROM Case WHERE Subject = 'pretPrueba' LIMIT 1];
      User usuario2 = [SELECT Id FROM User WHERE Username = 'usergeneralSAC2@test.com' AND isActive = true LIMIT 1];

      System.runAs(usuario){
         caso.OwnerId = usuario2.Id;
         SAC_DatabaseDML.updateDML(caso, false);
         //Database.update(caso);

      }

      Case casoFinal = [SELECT Id, AccountId, OwnerId FROM Case WHERE Subject = 'pretPrueba' LIMIT 1];
      System.assertEquals(usuario2.Id, casoFinal.OwnerId, 'No se ha podido notificar el cambio de owner');
      Test.stopTest();
   }

   @isTest
   static void alertaConsultaRespondidaTest() {
      Test.startTest();
      User usuario = [SELECT Id FROM User WHERE Username = 'usergeneralSAC@test.com' AND isActive = true LIMIT 1];
      SAC_Interaccion__c consulta = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'titulo test'];

      System.runAs(usuario){
         consulta.SAC_Estado__c = 'SAC_Resuelta';
         SAC_DatabaseDML.updateDML(consulta, false);
         //Database.update(consulta);
      }

      SAC_Interaccion__c consultaResult = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'titulo test'];
      System.assertEquals('SAC_Resuelta', consultaResult.SAC_Estado__c, 'No se ha responder la consulta');
      Test.stopTest();
   }
}