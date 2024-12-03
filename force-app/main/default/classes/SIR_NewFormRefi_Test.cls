/*****************************************************************
 Name:  SIR_NewFormRefi_Test
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_NewFormRefi (sir_lwc_newFormRefi)                                                                                                                  
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244049         Atmira         21/06/2021     	 Created    

*****************************************************************/
@isTest 
public class SIR_NewFormRefi_Test {
    
    /*****************************************************************
        Proposito:  test1 sirve para comprobar toda la logica del controlador SIR_LCMP_NewFormRefi                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US244049         Atmira         21/06/2021     	  Created    
        
	*****************************************************************/
    @isTest static void test1() {
        SIR_Constantes constantes = new SIR_Constantes();
        Test.startTest();
        
        // Se crean dos cuentas, una para que sea la principal y otra para que haga de intervininiente
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        Account cuenta1 = SIR_TestDataFactory.crearCuenta();
        //Se crean Informacion Clientes
        SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
        //SIREC__SIREC_obj_informacionCliente__c infoCliente1 = SIR_TestDataFactory.CrearInfoCliente(cuenta1);
        // Creamos un registro de catalogo CNAE
        SIR_CatalogoSirec__c cat = SIR_TestDataFactory.crearCatalogoCNAE();
        // Se crea un contrato
        Contract contrato = SIR_TestDataFactory.crearContrato(cuenta);
        // Se relaciona a una cuenta (interviniente) con el contrato que se ha creado
        SIREC__SIREC_obj_intervinientesContrato__c intervinienteContrato = SIR_TestDataFactory.crearInterContrato(cuenta, contrato, 'TIT');
        // Ponemos el contrato en una variable string
        String idContrato = contrato.Id;
        SIR_LCMP_NewFormRefi.queryContratosConDeuda(cuenta.Id);
        SIR_LCMP_NewFormRefi.queryContratosSinDeuda(cuenta.Id);
        // Ejecutamos el metodo CrearRegistros de SIR_LCMP_NewFormRefi pasando los parametros cuenta principal y contrato
        SIR_LCMP_NewFormRefi.crearRegistros(cuenta.Id, idContrato); 
        // Ejecutamos el metodo CrearRegistros pero para ir por el CATCH de Exception, por eso un id contrato en lugar del id de la cuenta principal
        SIR_LCMP_NewFormRefi.crearRegistros(contrato.Id, idContrato); 
        SIR_LCMP_NewFormRefi.isEnabledNuevoProceso(cuenta.Id);
        
        
   		Test.stopTest();
        System.assertNotEquals(null, SIR_LCMP_NewFormRefi.queryContratosConDeuda(cuenta.Id), constantes.STRING_TEST);
        System.assertNotEquals(null, SIR_LCMP_NewFormRefi.queryContratosSinDeuda(cuenta.Id), constantes.STRING_TEST);
        System.assertNotEquals(null, SIR_LCMP_NewFormRefi.crearRegistros(cuenta.Id, idContrato), constantes.STRING_TEST);
        System.assertNotEquals(null, SIR_LCMP_NewFormRefi.crearRegistros(contrato.Id, idContrato), constantes.STRING_TEST);

   }
}