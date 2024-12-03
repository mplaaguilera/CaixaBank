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
        Map<String,Schema.RecordTypeInfo> mapRTsObjectsAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        Id rtAccount = mapRTsObjectsAccount.get('CC_Cliente').getRecordTypeId();  
        Account cuenta = new Account(
            Name = 'Test',
            CC_TipoPersona__c = 'J',            	
            RecordTypeId = rtAccount
        );   
        insert cuenta;    
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
        SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
        tarea.SIREC__SIREC_fld_tipo_tarea__c = 'ACT';
        update tarea;

        Map<String,Schema.RecordTypeInfo> mapRTsObjectsAccion = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName();
        Id rtAccion = mapRTsObjectsAccion.get('SIREC_rt_accion').getRecordTypeId(); 

        Account accountQuery = [SELECT Id FROM Account limit 1];
        Map<String,Schema.RecordTypeInfo> mapRTsObjects = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
        Id rtContactoComercial = mapRTsObjects.get('CIBE_ContactoComercial').getRecordTypeId(); 
        Contact contacto = new Contact(
            LastName = 'ContPrueba',
            AccountId = cuenta.Id,
            RecordTypeId= rtContactoComercial
        );
        insert contacto;
        Id rtContactoApoderado = mapRTsObjects.get('CIBE_Apoderado').getRecordTypeId(); 
        Contact contactoApo = new Contact(
            LastName = 'ContApoderadoPrueba',
            AccountId = cuenta.Id,
            RecordTypeId= rtContactoApoderado
        );
        insert contactoApo;
        
        Test.startTest();
        SIR_LCMP_accionWorkflow.getProceso(proceso.Id);
        SIR_LCMP_accionWorkflow.getAccionProceso(tarea.Id);
        SIR_LCMP_accionWorkflow.getPicklistIntervinientes(proceso.Id);
        SIR_LCMP_accionWorkflow.getPicklistContactos(cuenta.Id);

        List<String> dataAccion = new List<String>();        
        dataAccion.add('2022-08-01'); //fechaContacto
        dataAccion.add('12'); //valueTipo
        dataAccion.add('01'); //valueAccion
        dataAccion.add(''); //valueResultado
        dataAccion.add('Comentario de prueba'); //comentarios
        dataAccion.add(UserInfo.getUserId()); //responsable
        dataAccion.add(cuenta.Id); //interviniente
        dataAccion.add(proceso.Id); //recordId
        dataAccion.add(contacto.Id); //contacto
        dataAccion.add('Pepito - Director'); //contactoCargo
        dataAccion.add('10001'); //estrategia
        dataAccion.add(rtAccion); //recordTypeIdAcc
        SIR_LCMP_accionWorkflow.insertAccion(dataAccion);
                
        //Modificamos la accion
        dataAccion.add('Comentario de prueba 2'); //comentarios
        dataAccion.add('10002'); //estrategia
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
        dataAccionConResultado.add(UserInfo.getUserId()); //responsable
        dataAccionConResultado.add(cuenta.Id); //interviniente
        dataAccionConResultado.add(proceso.Id); //recordId
        dataAccionConResultado.add(contacto.Id); //contacto
        dataAccionConResultado.add('Pepito - Director'); //contactoCargo
        dataAccionConResultado.add('10001'); //estrategia
        dataAccionConResultado.add(rtAccion); //recordTypeIdAcc
        String resultado = SIR_LCMP_accionWorkflow.insertAccion(dataAccionConResultado);
        SIREC__SIREC_obj_acciones__c accionQuery2 = [SELECT Id FROM SIREC__SIREC_obj_acciones__c WHERE SIREC__SIREC_fld_proceso__c =: proceso.Id order by createddate desc limit 1];
        SIR_LCMP_accionWorkflow.enviarAccion(accionQuery2.Id, proceso.Id);
        SIR_LCMP_accionWorkflow.updateAccionWS(accionQuery2.Id);
        
        Test.stopTest();
        System.assertEquals(true, resultado.contains('OK'), 'No se ha podido insertar la acción');
    }

}