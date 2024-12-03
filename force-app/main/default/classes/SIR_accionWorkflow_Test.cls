/*****************************************************************
 Name:  SIR_accionWorkflow_Test
 Copyright © 2022  CaixaBank

Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_accionWorkflow                                                                                                          

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         10/05/2022     	  Created   
    2.0                             Atmira         25/04/2023     	  Created  

*****************************************************************/
@isTest
public class SIR_accionWorkflow_Test {

    /*****************************************************************
        Proposito:  crearAcciones sirve para comprobar la logica de la clase SIR_LCMP_accionWorkflow                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0                             Atmira         25/04/2023     	  Created   
        
	*****************************************************************/    
    @istest static void crearAcciones(){

        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomeImpaAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');  
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);   

        Map<String,Schema.RecordTypeInfo> mapRTsObjectsAccion = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName();
        Id rtAccion = mapRTsObjectsAccion.get('SIREC_rt_accion').getRecordTypeId(); 
        System.runAs(usuario){ 
            Account cuenta = SIR_TestDataFactory.crearCuentaEMP();
            Contact contacto = SIR_TestDataFactory.crearContacto(cuenta, 'CIBE_ContactoComercial');
            Contact contactoApo = SIR_TestDataFactory.crearContacto(cuenta, 'CIBE_Apoderado');
           
           Test.startTest();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProcesoPRESOL(cuenta);
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_tipo_tarea__c = 'ACT';
            update tarea;
            SIR_LCMP_accionWorkflow.getProceso(proceso.Id);
            Id rtIdAccion = SIR_LCMP_accionWorkflow.buscarIdsAccion(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL);
            SIR_LCMP_accionWorkflow.getAccionProceso(tarea.Id);
            SIR_LCMP_accionWorkflow.getPicklistIntervinientes(proceso.Id);
            SIR_LCMP_accionWorkflow.getPicklistContactos(cuenta.Id);

            List<String> dataAccion = new List<String>();        
            dataAccion.add('2022-08-01'); //fechaContacto
            dataAccion.add('12'); //valueTipo
            dataAccion.add('01'); //valueAccion
            dataAccion.add(''); //valueResultado
            dataAccion.add('Comentario de prueba'); //comentarios
            dataAccion.add(usuario.Id); //responsable
            dataAccion.add(cuenta.Id); //interviniente
            dataAccion.add(proceso.Id); //recordId
            dataAccion.add(contacto.Id); //contacto
            dataAccion.add('Pepito - Director'); //contactoCargo
            dataAccion.add('10001'); //estrategia
            dataAccion.add(rtAccion); //recordTypeIdAcc
            dataAccion.add('Descripcion estrategia 10001'); // descEstrategia
            dataAccion.add(tarea.Id); // tarea
            SIR_LCMP_accionWorkflow.insertAccion(dataAccion);
                    
            //Modificamos la accion
         //   dataAccion.add('Comentario de prueba 2'); //comentarios
           // dataAccion.add('10002'); //estrategia
            SIREC__SIREC_obj_acciones__c accionQuery1 = [SELECT Id FROM SIREC__SIREC_obj_acciones__c WHERE SIREC__SIREC_fld_proceso__c =: proceso.Id order by createddate desc limit 1];
            SIR_LCMP_accionWorkflow.updateAccion(dataAccion, accionQuery1.Id, proceso.Id);
            SIR_LCMP_accionWorkflow.updateAccion(dataAccion, null, proceso.Id);
            SIR_LCMP_accionWorkflow.getAccion(accionQuery1.Id);

            List<String> dataAccionConResultado = new List<String>();
            dataAccionConResultado.add('2022-08-01'); //fechaContacto
            dataAccionConResultado.add('12'); //valueTipo
            dataAccionConResultado.add('01'); //valueAccion
            dataAccionConResultado.add('15'); //valueResultado
            dataAccionConResultado.add('Comentario de prueba'); //comentarios
            dataAccionConResultado.add(usuario.Id); //responsable
            dataAccionConResultado.add(cuenta.Id); //interviniente
            dataAccionConResultado.add(proceso.Id); //recordId
            dataAccionConResultado.add(contacto.Id); //contacto
            dataAccionConResultado.add('Pepito - Director'); //contactoCargo
            dataAccionConResultado.add('10001'); //estrategia
            dataAccionConResultado.add(rtAccion); //recordTypeIdAcc
            dataAccionConResultado.add('Descripcion estrategia 10001'); // descEstrategia
            dataAccionConResultado.add(tarea.Id); // tarea
            String resultado = SIR_LCMP_accionWorkflow.insertAccion(dataAccionConResultado);
            SIREC__SIREC_obj_acciones__c accionQuery2 = [SELECT Id FROM SIREC__SIREC_obj_acciones__c WHERE SIREC__SIREC_fld_proceso__c =: proceso.Id order by createddate desc limit 1];
            SIR_LCMP_accionWorkflow.enviarAccion(accionQuery2.Id, proceso.Id);
            SIR_LCMP_accionWorkflow.updateAccionWS(accionQuery2.Id);
            
            Test.stopTest();
        
            System.assertEquals(true, resultado.contains('OK'), 'No se ha podido insertar la acción');
        }
    }
}