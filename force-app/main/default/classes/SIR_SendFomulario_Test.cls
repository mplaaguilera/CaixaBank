/*****************************************************************
 Name:  SIR_SendFomulario_Test
 Copyright © 2021  CaixaBank
  
Proposito:   Clase Test de la clase SIR_SendFomulario_WS                                                                                                                 
  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244049         Atmira         21/06/2021     	 Created    

*****************************************************************/
@isTest
public class SIR_SendFomulario_Test {
/*****************************************************************
        Proposito:  test1 sirve para comprobar la cobertura                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US244049         Atmira         21/06/2021     	  Created    
        
	*****************************************************************/
    @isTest static void OKtest() {
        SIR_Constantes constantes = new SIR_Constantes();
        // Se crean dos cuentas, una para que sea la principal y otra para que haga de intervininiente
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        //Se crean Informacion Clientes
        SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
        // Creamos proceso  Asociado a la cuenta 
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.CrearProceso(cuenta); 
        // Creamos el formulario 
        SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.CrearFormulario(proceso);
        Contract contrato = SIR_TestDataFactory.crearContrato(cuenta);
        // Se relaciona a una cuenta (interviniente) con el contrato que se ha creado
        SIREC__SIREC_obj_intervinientesContrato__c intervinienteContrato = SIR_TestDataFactory.crearInterContrato(cuenta, contrato, 'TIT');
        formulario.SIR_solucionCortoPlazo__c = 'Prueba3';
        formulario.SIR_SolucionFinalista__c = 'Prueba2';
        formulario.SIR_solucionLargoPlazo__c = 'Prueba1';
        update formulario;
        List<String> listText = new List<String>();
        Test.startTest();
        listText = SIR_SendFormulario_WS.sendFormulario(formulario.Id);
   		Test.stopTest();
        System.assertNotEquals(null, listText, constantes.STRING_TEST);
   }
}