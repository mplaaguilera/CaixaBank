/*****************************************************************
 Name:  SIR_GetProfileClient_Test
 Copyright © 2021  CaixaBank

Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_GetProfileClient                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244035      Atmira         21/06/2021     	  Created    
    2.0                             Atmira         11/04/2022     	  Modify  

*****************************************************************/
@isTest
public class SIR_GetProfileClient_Test {
	 /*****************************************************************
        Proposito:  WrapperCabeceraProcesos sirve para comprobar toda la logica del controlador SIR_LCMP_GetProfileClient                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US US244035      Atmira         21/06/2021     	  Created 
        2.0                             Atmira         26/04/2022         Edited
        
	*****************************************************************/
    @isTest static void WrapperCabeceraProcesos() {
        // Constantes
		SIR_Constantes constante = new SIR_Constantes();
        //RT Procesos
        Id recordTypeIdAmistoso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
        Id recordTypeIdPRESOL = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId();
        
        Test.startTest();
        // Se crean dos cuentas, una para que sea la principal y otra para que haga de intervininiente
        Account cuenta = SIR_TestDataFactory.crearCuenta();
		List <SIREC__SIREC_obj_proceso__c> procesosPresol = SIR_TestDataFactory.crearProceso(1, cuenta, SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL);
        List <SIREC__SIREC_obj_proceso__c> procesosImpa = SIR_TestDataFactory.crearProceso(1, cuenta, SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO);
        // Se crea Info Cliente
       	SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.crearInfoCliente(cuenta);
       	
        // Creamos un proceso con RT Amistoso y otro con RT PRESOL
        SIREC__SIREC_obj_proceso__c procesoIMPA = procesosImpa.get(0);
        procesoIMPA.RecordTypeId = recordTypeIdAmistoso;
        update procesoIMPA;
        SIREC__SIREC_obj_proceso__c procesoPRESOL = procesosPresol.get(0);
        procesoPRESOL.RecordTypeId = recordTypeIdPRESOL;
        update procesoPRESOL;

        // Ejecutamos el metodo WrapperCabecera para cubrir el codigo de la ficha del Proceso IMPA y PRESOL
        SIR_LCMP_GetProfileClient.WrapperCabecera(procesoIMPA.Id); 
        SIR_LCMP_GetProfileClient.wrapperProcesoPRESOL(procesoPRESOL.Id); 
   		Test.stopTest();
        system.assertNotEquals(null, SIR_LCMP_GetProfileClient.WrapperCabecera(procesoIMPA.Id), constante.STRING_TEST);
        system.assertNotEquals(null, SIR_LCMP_GetProfileClient.wrapperProcesoPRESOL(procesoPRESOL.Id), constante.STRING_TEST);
   }

    /*****************************************************************
    Proposito:  WrapperCabeceraCliente sirve para comprobar toda la logica del controlador SIR_LCMP_GetProfileClient                                                      
    Parameters: No
    Returns: No
    Throws [Exceptions]: No                                                          
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244035      Atmira         21/06/2021     	  Created   
    2.0                             Atmira         11/04/2022     	  Edited   

	*****************************************************************/
    @isTest static void WrapperCabeceraCliente() {
        // Constantes
		SIR_Constantes constante = new SIR_Constantes();
        //RT Procesos
        Id recordTypeIdAmistoso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
        Id recordTypeIdPRESOL = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId();
        
        Test.startTest();
        
        // Se crean dos cuentas, una para que sea la principal y otra para que haga de intervininiente
        Account cuenta = SIR_TestDataFactory.crearCuenta();     
		List <SIREC__SIREC_obj_proceso__c> procesosPresol = SIR_TestDataFactory.crearProceso(1, cuenta, SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL);
        List <SIREC__SIREC_obj_proceso__c> procesosImpa = SIR_TestDataFactory.crearProceso(1, cuenta, SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO);
        // Se crea un contrato
       	SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.crearInfoCliente(cuenta);
        infoCliente.SIREC__SIREC_fld_saldPasivo__c 			= constante.INTEGER_1;
        infoCliente.SIREC__SIREC_fld_ingresosNomina__c  	= constante.INTEGER_1;
		infoCliente.SIREC__SIREC_fld_ingresosPension__c 	= constante.INTEGER_1;
        infoCliente.SIREC__SIREC_fld_ingresosParo__c    	= constante.INTEGER_1;
        infoCliente.SIREC__SIREC_fld_deudaTotal__c      	= constante.INTEGER_1;
        infoCliente.SIREC__SIREC_fld_deudaVencidaTotal__c   = constante.INTEGER_1;
        infoCliente.SIREC__SIREC_fld_deudaPendienteTotal__c = constante.INTEGER_1;
        Update(infoCliente);

        
        // Creamos un proceso con RT Amistoso y otro con RT PRESOL
        SIREC__SIREC_obj_proceso__c procesoIMPA = procesosImpa.get(0);
        procesoIMPA.RecordTypeId = recordTypeIdAmistoso;
        update procesoIMPA;
        SIREC__SIREC_obj_proceso__c procesoPRESOL = procesosPresol.get(0);
        procesoPRESOL.RecordTypeId = recordTypeIdPRESOL;
        update procesoPRESOL;

        // Ejecutamos el metodo procesosPendientes
        SIR_LCMP_GetProfileClient.procesosPendientes(cuenta.Id); 
        // Ejecutamos el metodo WrapperCabeceraTabs para cubrir el codigo de la ficha del Cliente
        SIR_LCMP_GetProfileClient.WrapperCabeceraTabs(cuenta.Id);
        
   		Test.stopTest();
        system.assertNotEquals(null, SIR_LCMP_GetProfileClient.WrapperCabeceraTabs(cuenta.Id), constante.STRING_TEST);
   }
   
}