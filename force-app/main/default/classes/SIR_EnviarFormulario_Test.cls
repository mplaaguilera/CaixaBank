/*****************************************************************
 Name:  SIR_EnviarFormulario_Test
 Copyright © 2021  CaixaBank
  
Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_EnviarFormulario                                                                                                          
  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244045         Atmira         04/08/2021     	  Created    

*****************************************************************/
@isTest
public class SIR_EnviarFormulario_Test {

    @testSetup static void setupMethod(){ 
        SIR_TestDataFactory.CrearIntegrationSetting('updateFormRefinanciacion');
        SIR_TestDataFactory.CrearIntegrationSetting('altaProcRefinanciacion');
        
    }       

    
    /*****************************************************************
        Proposito:  test1 sirve para comprobar la logica de la clase SIR_LCMP_EnviarFormulario                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US244045         Atmira         04/08/2021     	  Created   
        
	*****************************************************************/    
    
    @istest static void comprobarCampostest(){
        SIR_Constantes constantes = new SIR_Constantes();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);       
        System.runAs(u) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            String validacion;
            Test.startTest();
            validacion = SIR_LCMP_EnviarFormulario.comprobarCampos(formulario.Id);
            Test.stopTest();
            System.assertNotEquals('', validacion, 'No se han detectado ningún error');
        }
    }

    @istest static void comprobarCamposOKtest(){
        SIR_Constantes constantes = new SIR_Constantes();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);     
        Id myId = u.Id;
        System.runAs(u) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            formulario.SIR_MiembrosUnidadFamiliar__c = '2';
            formulario.SIR_CuotaOperacionRefCaixa__c = 250;
            formulario.SIR_DeudaOperacionRefCaixa__c = 1000;
            formulario.SIR_ingresosFuturo__c = 100;
            update formulario;
            String validacion;
            Test.startTest();
            validacion = SIR_LCMP_EnviarFormulario.comprobarCampos(formulario.Id);
            Test.stopTest();
            System.assertEquals('OK', validacion, 'Se ha detectado ningún error');
        }
    }


    @istest static void enviarProcesoOKtest(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        
   		System.runAs(usuario){
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            infoCliente.SIREC__SIREC_fld_masterRecordId__c = 'correcto';
            update infoCliente;
            proceso.SIREC__SIREC_fld_masterRecordId__c ='';
            update proceso;
            List<String> lstString = new List<String>();
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaProcRefinanciacionMock()); 
            Test.startTest();
                List<String> lstResponse = SIR_LCMP_EnviarFormulario.enviarProceso(formulario.Id);
            Test.stopTest();
            system.assertEquals(lstresponse.get(0), 'OK', constantes.STRING_TEST);
        }
    }


    @istest static void enviarFormOKtest(){
        SIR_Constantes constantes = new SIR_Constantes();
       String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);       
        System.runAs(u) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            formulario.SIR_OtrosDatosInteresCargas__c = 'correcto';
            update formulario;
            Test.setMock(HttpCalloutMock.class, new SIR_SendFormulario_WSMock()); 
            Test.startTest();       
            String [] resultado = SIR_LCMP_EnviarFormulario.enviarForm(formulario.Id);  

            Test.stopTest();
            system.assertEquals(resultado[0], 'OK', 'SIR_EnviarFormulario_Test.enviarFormOKtest ');
        }
    }

    @istest static void enviarFormKOtest(){
        SIR_Constantes constantes = new SIR_Constantes();
       String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);       
        System.runAs(u) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            formulario.SIR_OtrosDatosInteresCargas__c = 'incorrecto';
            update formulario;
            Test.setMock(HttpCalloutMock.class, new SIR_SendFormulario_WSMock()); 
            Test.startTest();       
            String [] resultado = SIR_LCMP_EnviarFormulario.enviarForm(formulario.Id);  
            Test.stopTest();
            System.assertEquals(resultado[0], '', 'SIR_EnviarFormulario_Test.enviarFormKOtest' );
        }
    }

 
    @istest static void updateFormularioOKtest(){
        SIR_Constantes constantes = new SIR_Constantes();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);       
        System.runAs(u) {
            String response;
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            formulario.SIR_OtrosDatosInteresCargas__c = 'incorrecto';
            update formulario;
            Test.setMock(HttpCalloutMock.class, new SIR_SendFormulario_WSMock()); 
            Test.startTest();
            response = SIR_LCMP_EnviarFormulario.updateFormulario(formulario.Id, 'OK');
            Test.stopTest();
            System.assertEquals('OK', response, 'SIR_EnviarFormulario_Test.updateFormularioKOtestNo ha asignado el Id');
        }
    }

    @istest static void updateFormularioKOtest(){
        SIR_Constantes constantes = new SIR_Constantes();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);       
        System.runAs(u) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            formulario.SIR_OtrosDatosInteresCargas__c = 'incorrecto';
            update formulario;
            Test.setMock(HttpCalloutMock.class, new SIR_SendFormulario_WSMock()); 
            Test.startTest();
            SIR_LCMP_EnviarFormulario.updateFormulario(formulario.Id, 'KO');
            Test.stopTest();
            List<SIR_FormularioRefinanciacion__c> lstformuario = [SELECT Id,SIR_Estado__c FROM SIR_FormularioRefinanciacion__c LIMIT 10];
            System.assertEquals(1, lstformuario.size(), 'SIR_EnviarFormulario_Test.updateFormularioKOtest No se ha creado el formulario');
            System.assertEquals(SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_PENDIENTE_ENVIO, lstformuario.get(0).SIR_Estado__c, 'SIR_EnviarFormulario_Test.updateFormularioKOtest No se ha creado ningún formulario');

        }
    }

    
    @istest static void updateFormularioExceptiontest(){
        SIR_Constantes constantes = new SIR_Constantes();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);       
        System.runAs(u) {
            String response;
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            formulario.SIR_OtrosDatosInteresCargas__c = 'incorrecto';
            update formulario;
            Test.setMock(HttpCalloutMock.class, new SIR_SendFormulario_WSMock()); 
            Test.startTest();
            response = SIR_LCMP_EnviarFormulario.updateFormulario('Exception', 'KO');
            Test.stopTest();
            System.assert(response.contains('Ha ocurrido un error:'), 'SIR_EnviarFormulario_Test.updateFormularioExceptiontest No se ha registrado el error');
        }
    }

    @istest static void updateProcesotest(){
        SIR_Constantes constantes = new SIR_Constantes();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);       
        System.runAs(u) {
            String result;
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            formulario.SIR_OtrosDatosInteresCargas__c = 'incorrecto';
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaProcRefinanciacionMock()); 
            Test.startTest();
            result = SIR_LCMP_EnviarFormulario.updateProceso(proceso.Id, '1234');
            Test.stopTest();
            System.assertEquals('1234', [SELECT SIREC__SIREC_fld_masterRecordId__c FROM SIREC__SIREC_obj_proceso__c LIMIT 1][0].SIREC__SIREC_fld_masterRecordId__c, 'SIR_EnviarFormulario_Test.updateProcesotest No se ha asignado correctamente el MasterRecordId');
        }
    }

    
    @istest static void updateProcesoExceptiontest(){
        SIR_Constantes constantes = new SIR_Constantes();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);       
        System.runAs(u) {
            String response;
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            formulario.SIR_OtrosDatosInteresCargas__c = 'incorrecto';
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaProcRefinanciacionMock()); 
            Test.startTest();
            response =SIR_LCMP_EnviarFormulario.updateProceso('Exception', '1234');
            Test.stopTest();
            System.assert(response.contains('Ha ocurrido un error:'), 'SIR_EnviarFormulario_Test.updateProcesoExceptiontest No ha saltado la excepcion');
        }
    }
    
    @istest static void getIntervinientesFormulariotest(){
        SIR_Constantes constantes = new SIR_Constantes();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);       
        System.runAs(u) {
            String response;
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            List<SIR_IntervinienteFormulario__c> intervinientes;
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            formulario.SIR_OtrosDatosInteresCargas__c = 'incorrecto';
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaProcRefinanciacionMock()); 
            Test.startTest();
            intervinientes = SIR_LCMP_EnviarFormulario.getIntervinientesFormulario(formulario.id);
            Test.stopTest();
            System.assertNotEquals(null, intervinientes, 'No está devolviendo los intervinientes');
        }
    }


    
}