/*****************************************************************
 Name:  SIR_accionSinWorkflow_Test
 Copyright © 2021  CaixaBank

Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_accionSinWorkflow                                                                                                          

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                     Atmira         01/06/2022     	 Created    

*****************************************************************/
@isTest
public class SIR_accionSinWorkflow_Test {

    @testSetup static void setupMethod(){
        SIR_TestDataFactory.CrearIntegrationSetting('altaResultAcciones');
    }
    
    /*****************************************************************
        Proposito:  test1 sirve para comprobar la logica de la clase SIR_LCMP_accionSinWorkflow                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0                     Atmira         01/06/2022     	 Created       
        
	*****************************************************************/    
    @istest static void test1(){
     //   SelectOption.SelectOption('hola', 'hola');
        SIR_Constantes constantes = new SIR_Constantes();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
        SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
        Test.startTest();
      /*  SELECT id, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_persona__r.Name 
                                                                        FROM SIREC__SIREC_obj_personaAsociada__c 
                                                                        WHERE SIREC__SIREC_fld_proceso__c =: idProceso AND SIR_estadoCarga__c != 'B'*/
        SIREC__SIREC_obj_personaAsociada__c personaAsociada = new SIREC__SIREC_obj_personaAsociada__c(SIREC__SIREC_fld_proceso__c = proceso.Id, SIR_estadoCarga__c='A',
                                                                                       SIREC__SIREC_fld_persona__c = cuenta.Id);
        insert personaAsociada;
        SIR_LCMP_accionSinWorkflow.buscarIdsProceso();
        SIR_LCMP_accionSinWorkflow.buscarIdsAccion();
        SIR_LCMP_accionSinWorkflow.getProceso(proceso.Id, proceso);
        SIR_LCMP_accionSinWorkflow.getPicklistIntervinientes(proceso.Id);    
        SIR_LCMP_accionSinWorkflow.comprobarPropietarioProceso(proceso.Id);
        SIR_LCMP_accionSinWorkflow.comprobarPropietarioAccion(accion.Id);
        SIR_LCMP_accionSinWorkflow.getAccion(accion.Id);
        List<String> dataUpdateAccion0 = new List<String>();
        dataUpdateAccion0.add('2021-08-04'); //fechaContacto
        dataUpdateAccion0.add(''); //valueResultado
        SIR_LCMP_accionSinWorkflow.updateAccion(dataUpdateAccion0,accion.Id);
        
        List<String> dataUpdateAccion = new List<String>();
        dataUpdateAccion.add('2021-08-04'); //fechaContacto
        dataUpdateAccion.add('01'); //valueTipo
        dataUpdateAccion.add('01'); //valueAccion
        dataUpdateAccion.add('17'); //valueResultado
        dataUpdateAccion.add('Comentario de prueba'); //comentarios
        dataUpdateAccion.add(UserInfo.getUserId()); //responsable
        dataUpdateAccion.add(cuenta.Id); //interviniente
        dataUpdateAccion.add(proceso.Id); //recordId
        dataUpdateAccion.add('10001'); //estrategia
        dataUpdateAccion.add('2021-08-04'); //fechaCompromisoPago
        SIR_LCMP_accionSinWorkflow.updateAccion(dataUpdateAccion,accion.Id);
        SIR_LCMP_accionSinWorkflow.enviarAccion(accion.Id);
        SIR_LCMP_accionSinWorkflow.updateAccionWS(accion.Id);
        
        List<String> dataUpdateAccion1 = new List<String>();
        dataUpdateAccion1.add('2021-08-04'); //fechaContacto
        dataUpdateAccion1.add('01'); //valueTipo
        dataUpdateAccion1.add('01'); //valueAccion
        dataUpdateAccion1.add(''); //valueResultado
        dataUpdateAccion1.add('Comentario de prueba'); //comentarios
        dataUpdateAccion1.add(UserInfo.getUserId()); //responsable
        dataUpdateAccion1.add(cuenta.Id); //interviniente
        dataUpdateAccion1.add(proceso.Id); //recordId
        dataUpdateAccion1.add('10001'); //estrategia
        SIR_LCMP_accionSinWorkflow.updateAccion(dataUpdateAccion1,accion.Id);
        
        List<String> data = new List<String>();
        data.add('2021-08-04'); //fechaContacto
        data.add('01'); //valueTipo
        data.add('01'); //valueAccion
        data.add('17'); //valueResultado
        data.add('Comentario de prueba'); //comentarios
        data.add(UserInfo.getUserId()); //responsable
        data.add(cuenta.Id); //interviniente
        data.add(proceso.Id); //recordId
        data.add('10001'); //estrategia
        data.add('2021-08-04'); //fechaCompromisoPago
        SIR_LCMP_accionSinWorkflow.insertAccion(data);        
        
        List<String> data2 = new List<String>();
        data2.add('2021-08-04'); //fechaContacto
        data2.add('01'); //valueTipo
        data2.add('01'); //valueAccion
        data2.add(''); //valueResultado
        data2.add('Comentario de prueba'); //comentarios
        data2.add(UserInfo.getUserId()); //responsable
        data2.add(cuenta.Id); //interviniente
        data2.add(proceso.Id); //recordId
        data2.add('10001'); //estrategia
        data2.add(''); //fechaCompromisoPago
        SIR_LCMP_accionSinWorkflow.insertAccion(data2); 
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            // The following code runs as user 'u'
            SIR_LCMP_accionSinWorkflow.comprobarPropietarioProceso(proceso.Id);
        	SIR_LCMP_accionSinWorkflow.comprobarPropietarioAccion(accion.Id);
            SIR_LCMP_accionSinWorkflow.getProceso(proceso.Id, proceso);
            SIR_LCMP_accionSinWorkflow.getAccion(accion.Id);
            SIR_LCMP_accionSinWorkflow.getPicklistIntervinientes(proceso.Id);
            SIR_LCMP_accionSinWorkflow.insertAccion(data);
            SIR_LCMP_accionSinWorkflow.updateAccion(dataUpdateAccion,accion.Id);
            SIR_LCMP_accionSinWorkflow.enviarAccion(accion.Id);
        }
        
        Test.stopTest();
        System.assertNotEquals(null,   SIR_LCMP_accionSinWorkflow.insertAccion(data), constantes.STRING_TEST);
    }

}