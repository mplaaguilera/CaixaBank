/*****************************************************************
 Name:  SIR_cls_procesoHandlerTest
 Copyright © 2021  CaixaBank
  
Proposito:   Clase Test de la clase SIR_cls_procesoHandler                                                                                                                   
  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244057         atmira         02/09/2021	      Created    

*****************************************************************/

@isTest
public with sharing class SIR_cls_procesoHandlerTest {
    @TestSetup
    static void makeData(){
        
      UserRole rol = new UserRole(DeveloperName = 'testRoleSSMM', Name = 'testRoleSSMM');
        insert rol;
        User usuarioSSMM = SIR_TestDataFactory.createTestUser('ssmm', rol, SIR_Constantes.SSMM_PROFILE_NAME);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :SIR_Constantes.PS_SSMM_NAME];
        insert new PermissionSetAssignment(AssigneeId = usuarioSSMM.id, PermissionSetId = ps.Id);
      
        System.runAs(usuarioSSMM){
            
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.CrearProceso(cuenta,'primero');
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.CrearFormulario(proceso); 
            proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION;
            proceso.Name = 'Proceso Original';       
            update proceso;
            SIREC__SIREC_obj_proceso__c procesoRefi = SIR_TestDataFactory.CrearProceso(cuenta,'segundo');
            procesoRefi.Name = SIR_Constantes.PROCESO_NAME_REFINANCIACION;
            update procesoRefi;

            //Proceso PRESOL
            SIREC__SIREC_obj_proceso__c procesoPRESOL = new SIREC__SIREC_obj_proceso__c();
            procesoPRESOL.SIREC__SIREC_fld_cliente__c    = cuenta.Id;
		    procesoPRESOL.SIREC__SIREC_fld_fechaInicio__c  = date.today();
            procesoPRESOL.SIREC__SIREC_fld_fechaLimite__c  = date.today();
            procesoPRESOL.SIREC__SIREC_fld_fechaSituacion__c = date.today();
            procesoPRESOL.SIREC__SIREC_fld_masterRecordId__c = 'PROCESOMRId1111';
            procesoPRESOL.RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId();
            procesoPRESOL.SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1;
            procesoPRESOL.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_ANALISIS_PREVIO;
            procesoPRESOL.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_ANALISIS_PREVIO;
            procesoPRESOL.Name = 'Proceso Original PRESOL';        
            insert procesoPRESOL;

            //Proceso PREVEMP
            SIREC__SIREC_obj_proceso__c procesoPREVEMP = new SIREC__SIREC_obj_proceso__c();
            procesoPREVEMP.SIREC__SIREC_fld_cliente__c    = cuenta.Id;
		    procesoPREVEMP.SIREC__SIREC_fld_fechaInicio__c  = date.today();
            procesoPREVEMP.SIREC__SIREC_fld_fechaLimite__c  = date.today();
            procesoPREVEMP.SIREC__SIREC_fld_fechaSituacion__c = date.today();
            procesoPREVEMP.SIREC__SIREC_fld_masterRecordId__c = 'PROCESOMRId2222';
            procesoPREVEMP.RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId();      
            procesoPREVEMP.SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1;
            procesoPREVEMP.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_ANALISIS_PREVIO;
            procesoPREVEMP.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_ANALISIS_PREVIO;
            procesoPREVEMP.Name = 'Proceso Original PREVEMP';        
            insert procesoPREVEMP;
        }
    }

    @isTest
    public static void finalizarProcesoRefiTest() {
           
        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
        SIREC__SIREC_obj_proceso__c proceso = [SELECT SIREC__SIREC_fld_fechaBaja__c, SIREC__SIREC_fld_motivosBaja__c FROM SIREC__SIREC_obj_proceso__c WHERE Name = 'Proceso Original'];
        System.runAs(usuarioSSMM){
            Test.startTest();
            proceso.SIREC__SIREC_fld_fechaBaja__c = Date.today();
            proceso.SIREC__SIREC_fld_motivosBaja__c = 'motivo de baja';
            update proceso; 
            Test.stopTest();    
        }  
        SIREC__SIREC_obj_proceso__c procesoRefi = [SELECT SIREC__SIREC_fld_fechaBaja__c, SIREC__SIREC_fld_motivosBaja__c FROM SIREC__SIREC_obj_proceso__c WHERE Name = :SIR_Constantes.PROCESO_NAME_REFINANCIACION]; 
        System.assertEquals(procesoRefi.SIREC__SIREC_fld_fechaBaja__c, proceso.SIREC__SIREC_fld_fechaBaja__c, 'finalizarProcesoRefiTest. No ha cambiado la fecha de baja en el Refi');
        System.assertEquals(procesoRefi.SIREC__SIREC_fld_motivosBaja__c, proceso.SIREC__SIREC_fld_motivosBaja__c, 'finalizarProcesoRefiTest. No ha cambiado el motivo de baja en el Refi' );
    }

    @isTest
    public static void setEstrategiaEnProcRefiTest(){
    
        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
        System.runAs(usuarioSSMM){
            SIREC__SIREC_obj_proceso__c proceso = [SELECT SIREC__SIREC_fld_fechaBaja__c, SIREC__SIREC_fld_motivosBaja__c FROM SIREC__SIREC_obj_proceso__c WHERE Name = 'Proceso Original'];
            Test.startTest();
            proceso.SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E3;
            proceso.SIR_DescripcionesAlertas__c = 'Texto con pipe | para quitar';
            update proceso;
            Test.stopTest();
        }
        List<SIREC__SIREC_obj_proceso__c> lstProceso = [SELECT ID, SIR_FechaInicioEstrategia__c, SIR_fld_Situacion_SF__c, SIR_DescripcionesAlertas__c FROM SIREC__SIREC_obj_proceso__c where  Name = 'Proceso Original']; 
        System.assertEquals(SIR_Constantes.PROCESO_ESTRATEGIA_E3, [SELECT Id,SIREC__SIREC_fld_estrategia__c FROM SIREC__SIREC_obj_proceso__c WHERE Name = :SIR_Constantes.PROCESO_NAME_REFINANCIACION].SIREC__SIREC_fld_estrategia__c, 'setEstrategiaEnProcRefiTest. No ha cambiado la estrategia en el Refi');
        System.assertEquals(Date.today(), lstProceso[0].SIR_FechaInicioEstrategia__c, 'setEstrategiaEnProcRefiTest. No ha cambiado la Fecha Inicio Estrategia');
        System.assertEquals(false, lstProceso[0].SIR_DescripcionesAlertas__c.contains('|'), 'setEstrategiaEnProcRefiTest. No se ha quitado el pipe');
    }

    @isTest
    public static void crearHistoricoProcesoInserTest(){
        List<SIR_HistoricoProceso__c> lstHistoricos;
        Account cliente = [SELECT Id FROM Account LIMIT 1];
      
        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
        System.runAs(usuarioSSMM){
            List<SIREC__SIREC_obj_proceso__c> lstProcesos = new List<SIREC__SIREC_obj_proceso__c>();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.CrearProceso(cliente);
            proceso.Name = 'testArbolEstrategias';
            proceso.SIREC__SIREC_fld_estrategia__c = '10001';
            proceso.SIREC__SIREC_fld_estrategiaCatalogo__c = SIR_TestDataFactory.crearCatalogoEstrategia(proceso.SIREC__SIREC_fld_estrategia__c).Id;
            proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION;
            update proceso; 
            lstProcesos.add(proceso);
            Test.startTest();
            lstHistoricos = SIR_cls_procesoHandler.crearHistoricoProcesoInsert(lstProcesos);
            Test.stopTest();
        }
        System.assertEquals(1, lstHistoricos.size(), 'crearHistoricoProcesoInserTest. No se ha creado el historico');
    }


   @isTest
    public static void setProcessOwnerTest(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
        User gestor = SIR_TestDataFactory.createTestUser('gestor', rol, SIR_Constantes.GESTOR_PROFILE_NAME);
        PermissionSet psGestor = [SELECT Id FROM PermissionSet WHERE Name = :SIR_Constantes.PS_GESTOR_NAME];
        insert new PermissionSetAssignment(AssigneeId = gestor.id, PermissionSetId = psGestor.Id);

        System.runAs(gestor){
            Account cliente = SIR_TestDataFactory.crearCuenta();
            cliente.LastName = 'Cliente Gestor';
            update cliente;
        }
        Test.startTest();
        System.runAs(usuarioSSMM){
            Account cliente = [SELECT Id FROM Account WHERE LastName = 'Cliente Gestor' LIMIT 1];
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
                                                                                    Name = 'testProcess',
                                                                                    SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1,
                                                                                    SIREC__SIREC_fld_fechaInicio__c  = date.today(),
                                                                                    SIREC__SIREC_fld_fechaLimite__c  = date.today(),
                                                                                    SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                                                                                    SIREC__SIREC_fld_cliente__c = cliente.Id,
                                                                                    recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId()
                                                                                    );
            insert proceso;
            proceso.SIREC__SIREC_fld_fechaLimite__c = date.today().addDays(1);
            update proceso;
        }
        Test.stopTest();
        System.assertEquals( [SELECT Id,OwnerId FROM SIREC__SIREC_obj_proceso__c WHERE Name = 'testProcess' LIMIT 1].OwnerId,  [SELECT Id,OwnerId FROM Account ORDER BY CreatedDate DESC  LIMIT 1].OwnerId, 'setProcessOwnerTest. No se ha asignado en owner correctamente');

    }
   
/*    @isTest
    public static void imaginTest(){
       
        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
  
        Test.startTest();
        System.runAs(usuarioSSMM){
           //Crear oficina IMAGIN
            Account oficinaImagin = SIR_TestDataFactory.crearOficinaIMAGIN();

            //Crear cliente con oficina principal IMAGIN
            Account cliente = SIR_TestDataFactory.crearCuenta();
            cliente.AV_OficinaPrincipal__c = oficinaImagin.Id;
            cliente.OwnerId = usuarioSSMM.Id;
            update cliente;
            //Crear proceso  
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProcesoPRESOL(cliente,'testImagin');
            proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_ILOCALIZADO;
            update proceso;
        }
        Test.stopTest();
        SIREC__SIREC_obj_proceso__c proceso = [SELECT OwnerId, SIR_fld_Situacion_SF__c, Name  FROM SIREC__SIREC_obj_proceso__c WHERE SIREC__SIREC_fld_masterRecordId__c ='testImagin' LIMIT 1];
        Id imaginUserId = [SELECT Id FROM User WHERE AV_ExternalID__c = :SIR_Variables__mdt.getInstance('IMAGINGestor').Valor__c].Id;
        System.assertEquals( imaginUserId, proceso.OwnerId, 'SIR_cls_procesoHandlerTest.imaginTest No se ha asignado en owner imagin correctamente');      
    }
*/
    @isTest
    public static void setAsignarAnalistaTest(){
     
        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
        UserRole rol = [SELECT ID from UserRole where DeveloperName = :SIR_Constantes.GESTOR_ROL_NAME_EMP];
        User gestor = SIR_TestDataFactory.createTestUser('gestor', rol, SIR_Constantes.GESTOR_PROFILE_NAME_EMP);
        PermissionSet psGestor = [SELECT Id FROM PermissionSet WHERE Name = :SIR_Constantes.PS_GESTOR_NAME_EMP];
        insert new PermissionSetAssignment(AssigneeId = gestor.id, PermissionSetId = psGestor.Id);

        User analista = SIR_TestDataFactory.createTestUser('analista', rol, SIR_Constantes.GESTOR_PROFILE_NAME_EMP);
        analista.AV_tipoGestor__c = SIR_Constantes.TIPO_ANALISTA_RIESGOS;
        update analista;
        insert new PermissionSetAssignment(AssigneeId = analista.id, PermissionSetId = psGestor.Id);      
                
        System.runAs(gestor){
           Account cliente = SIR_TestDataFactory.crearCuenta();
           cliente.LastName = 'Cliente Gestor';
           update cliente;
            
           insert new AccountTeamMember(AccountId = cliente.id, UserId = analista.Id);            
        }
        Test.startTest();
        System.runAs(usuarioSSMM){
              //Proceso PREVEMP
              SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(SIREC__SIREC_fld_fechaInicio__c  = date.today(),
                                                                                    SIREC__SIREC_fld_fechaLimite__c  = date.today(),
                                                                                    SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                                                                                    SIREC__SIREC_fld_masterRecordId__c = 'PROCESOPREVEMPId1111',
                                                                                    RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId(),
                                                                                    SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1,
                                                                                    SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_ANALISIS_PREVIO,
                                                                                    SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_ANALISIS_PREVIO,
                                                                                    Name = 'Proceso Original PREVEMPRESAS',
                                                                                    SIR_AccionActual__c = true,
                                                                                    SIR_TipoGestionPREVEMP__c = SIR_Constantes.GESTION_NEGOCIO_RIESGOS);
             insert proceso;   
            
            Account cliente = [SELECT Id FROM Account WHERE LastName = 'Cliente Gestor' LIMIT 1];                        
            proceso.SIREC__SIREC_fld_cliente__c = cliente.Id;                       
            update proceso;
        }
        Test.stopTest();        
        
        System.assertEquals( [SELECT Id,OwnerId FROM SIREC__SIREC_obj_proceso__c WHERE Name = 'Proceso Original PREVEMPRESAS' LIMIT 1].OwnerId,  [SELECT Id,OwnerId FROM Account ORDER BY CreatedDate DESC  LIMIT 1].OwnerId, 'setAsignarAnalistaTest. No se ha asignado en owner correctamente');
        System.assertEquals( [SELECT Id,SIR_AnalistaRiesgo__c FROM SIREC__SIREC_obj_proceso__c WHERE Name = 'Proceso Original PREVEMPRESAS' LIMIT 1].SIR_AnalistaRiesgo__c,  analista.id, 'setAsignarAnalistaTest. No se ha asignado el analista de riesto correctamente');
    }
 
   @isTest
    public static void setSituacionSFTest(){
        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
        System.runAs(usuarioSSMM){
            Test.startTest();
            SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_situacion__c, SIR_fld_Situacion_SF__c, SIR_AccionActual__c FROM SIREC__SIREC_obj_proceso__c WHERE Name = 'Proceso Original PRESOL'];
            proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_FINALIZADO;
            proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_FINALIZADO;
            update proceso;
            Test.stopTest();
        }
        SIREC__SIREC_obj_proceso__c procesoAfter = [SELECT Id, SIREC__SIREC_fld_situacion__c, SIR_fld_Situacion_SF__c, SIR_AccionActual__c FROM SIREC__SIREC_obj_proceso__c WHERE Name = 'Proceso Original PRESOL'];
        System.assertEquals(procesoAfter.SIR_fld_Situacion_SF__c, SIR_Constantes.PROCESO_SITUACION_ANALISIS_PREVIO, 'setSituacionSFTest. No ha mantenido la situacion SF');
        System.assertEquals(procesoAfter.SIR_AccionActual__c, false, 'setSituacionSFTest. No ha modificado a false SIR_AccionActual__c');
    }

    @isTest
    public static void setSituacionPrevempSFTest(){
        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
        System.runAs(usuarioSSMM){
            Test.startTest();
            SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_situacion__c, SIR_fld_Situacion_SF__c, SIR_AccionActual__c FROM SIREC__SIREC_obj_proceso__c WHERE Name = 'Proceso Original PREVEMP'];
            proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_NO_LOCALIZADO;
            proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_FINALIZADO;
            update proceso;
            Test.stopTest();
        }
        SIREC__SIREC_obj_proceso__c procesoAfter = [SELECT Id, SIREC__SIREC_fld_situacion__c, SIR_fld_Situacion_SF__c, SIR_AccionActual__c FROM SIREC__SIREC_obj_proceso__c WHERE Name = 'Proceso Original PREVEMP'];
        System.assertEquals(procesoAfter.SIR_fld_Situacion_SF__c, SIR_Constantes.PROCESO_SITUACION_NO_LOCALIZADO,'setSituacionPrevempSFTest. No ha cambiado la situacion SF');
    }

    @isTest
    public static void setTareaClienteTest(){
        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
        list<Account> lstClientes = [SELECT Id FROM Account];
        
        System.runAs(usuarioSSMM){
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
                                                                                    Name = 'testProcess',
                                                                                    SIREC__SIREC_fld_cliente__c =lstClientes.get(0).Id,
                                                                                    SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1,
                                                                                    SIREC__SIREC_fld_fechaInicio__c  = date.today(),
                                                                                    SIREC__SIREC_fld_fechaLimite__c  = date.today(),
                                                                                    SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                                                                                    recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId()
                                                                                    );
            insert proceso;
            SIR_TestDataFactory.createTarea(1,proceso);
            Test.startTest();
            proceso.SIREC__SIREC_fld_cliente__c = lstClientes.get(1).Id;
            update proceso;
            Test.stopTest();
        }
        System.assertEquals(lstClientes.get(1).Id, [SELECT SIR_cliente__c FROM SIREC__SIREC_obj_tarea__c].SIR_cliente__c, 'setTareaClienteTest. No se ha asignado correctamente el cliente');
    }

    @IsTest
    static void setMatriculaTest() {
        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;      
        User gestor = SIR_TestDataFactory.createTestUser('gestor', rol, SIR_Constantes.GESTOR_PROFILE_NAME);
        gestor.EmployeeNumber = '123456789123456';
        update gestor;
        PermissionSet psGestor = [SELECT Id FROM PermissionSet WHERE Name = :SIR_Constantes.PS_GESTOR_NAME];
        insert new PermissionSetAssignment(AssigneeId = gestor.id, PermissionSetId = psGestor.Id);
        list<Account> lstClientes = [SELECT Id FROM Account];
        System.runAs(usuarioSSMM){
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
                                                                                    Name = 'testProcess',
                                                                                    SIREC__SIREC_fld_cliente__c =lstClientes.get(0).Id,
                                                                                    SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1,
                                                                                    SIREC__SIREC_fld_fechaInicio__c  = date.today(),
                                                                                    SIREC__SIREC_fld_fechaLimite__c  = date.today(),
                                                                                    SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                                                                                    recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId()
                                                                                    );
            insert proceso;
            
            Test.startTest();
            proceso.ownerId = gestor.Id;
            update proceso;
            Test.stopTest();
            List<SIREC__SIREC_obj_proceso__c> lstProcesos = new List<SIREC__SIREC_obj_proceso__c>();
            lstProcesos.add([SELECT SIR_MatriculaGestor__c FROM SIREC__SIREC_obj_proceso__c WHERE id = :proceso.Id]);
            for(SIREC__SIREC_obj_proceso__c procesoQuery : lstProcesos){
                System.assertNotEquals(procesoQuery.SIR_MatriculaGestor__c, gestor.EmployeeNumber, 'setMatricula. No ha cambiado el numero de empleado.');
            }
        }
    }

    @IsTest
    static void insertProcesoTest() {

        User usuarioSSMM = [SELECT Id FROM User WHERE Name = 'ssmm' LIMIT 1];
        Account cliente = [SELECT Id FROM Account LIMIT 1];
        system.runAs(usuarioSSMM){
            Test.startTest();
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c();
            proceso.SIREC__SIREC_fld_cliente__c    = cliente.Id;
            proceso.SIREC__SIREC_fld_fechaInicio__c  = date.today();
            proceso.SIREC__SIREC_fld_masterRecordId__c = 'insertProcesoTest';
            proceso.RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId();
            proceso.SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1;
            proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_ANALISIS_PREVIO;            
            proceso.SIR_DescripcionesAlertas__c = 'Texto con pipe | para quitar';
            proceso.Name = 'Proceso';        
            insert proceso;
            Test.stopTest();

            List<SIREC__SIREC_obj_proceso__c> lstProceso = [SELECT ID, SIR_FechaInicioEstrategia__c, SIR_fld_Situacion_SF__c, SIR_DescripcionesAlertas__c FROM SIREC__SIREC_obj_proceso__c where SIREC__SIREC_fld_masterRecordId__c = 'insertProcesoTest']; 
            System.assertEquals(lstProceso[0].SIR_FechaInicioEstrategia__c, proceso.SIREC__SIREC_fld_fechaInicio__c, 'insertProcesoTest. No se ha asignado correctamente SIR_FechaInicioEstrategia__c ');
            System.assertEquals(lstProceso[0].SIR_fld_Situacion_SF__c, proceso.SIREC__SIREC_fld_situacion__c, 'insertProcesoTest. No se ha asignado correctamente SIR_fld_Situacion_SF__c ');
            System.assertEquals(false, lstProceso[0].SIR_DescripcionesAlertas__c.contains('|'), 'insertProcesoTest. No se ha quitado el pipe');
        }
    }
}