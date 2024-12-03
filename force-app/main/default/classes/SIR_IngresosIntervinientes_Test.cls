/*****************************************************************
 Name:  SIR_IngresosIntervinientes_Test
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_IngresosIntervinientes (sir_lwc_ingresosIntervinientes)                                                                                                                  
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249657         Atmira         07/07/2021     	 Created    

*****************************************************************/
@isTest 
public class SIR_IngresosIntervinientes_Test {

    /*****************************************************************
        Proposito:  getIntervininientesTest sirve para comprobar la logica del metodo getIntervininientes se comporta correctamente                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249657         Atmira         15/07/2021     	  Created    
        
	*****************************************************************/
    
   @Istest static void getIntervininientesTest(){
        SIR_Constantes constantes = new SIR_Constantes();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        Contract contrato = SIR_TestDataFactory.crearContrato(cuenta);
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta); 
        SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
        SIR_IntervinienteFormulario__c intervinienteFormulario = new SIR_IntervinienteFormulario__c(SIR_FormularioRefinanciacion__c = formulario.Id);
        insert intervinienteFormulario;
        test.startTest();
        List<SIR_IntervinienteFormulario__c> lstIntervinientes = SIR_LCMP_IngresosIntervinientes.getIntervininientes(formulario.Id);
        test.stopTest();
        System.assertEquals(1, lstIntervinientes.size(), constantes.STRING_TEST);
        System.assertEquals(0, lstIntervinientes.get(0).SIR_IngresosTrabajo__c, constantes.STRING_TEST);
        System.assertEquals(0, lstIntervinientes.get(0).SIR_IngresosBienes__c, constantes.STRING_TEST);
   
    }
    
    /*****************************************************************
        Proposito:  test1 sirve para comprobar toda la logica del controlador SIR_LCMP_IngresosIntervinientes                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249657         Atmira         07/07/2021     	  Created    
        
	*****************************************************************/
    @isTest static void test1() {
        Test.startTest();
        SIR_Constantes constantes = new SIR_Constantes();
        // Se crean dos cuentas, una para que sea la principal y otra para que haga de intervininiente
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        Account cuenta1 = SIR_TestDataFactory.crearCuenta();
        // Se crea un contrato
        Contract contrato = SIR_TestDataFactory.crearContrato(cuenta);
        // Se relaciona a una cuenta (interviniente) con el contrato que se ha creado
        SIREC__SIREC_obj_intervinientesContrato__c intervinienteContrato = SIR_TestDataFactory.crearInterContrato(cuenta1, contrato, 'TIT');
        // Ponemos el contrato en una variable string
        String idContrato = contrato.Id;
        
        SIR_LCMP_NewFormRefi.queryContratosConDeuda(cuenta.Id);
        SIR_LCMP_NewFormRefi.queryContratosSinDeuda(cuenta.Id);
        
        // Ejecutamos el metodo CrearRegistros de SIR_LCMP_NewFormRefi pasando los parametros cuenta principal y contrato
        String idFormulario = SIR_LCMP_NewFormRefi.crearRegistros(cuenta.Id, idContrato); 
        SIR_LCMP_IngresosIntervinientes.getValoresForm(idFormulario);
        
        List<SIR_IntervinienteFormulario__c> lIntervinientes = SIR_LCMP_IngresosIntervinientes.getIntervininientes(idFormulario);
        List<SIR_FormularioRefinanciacion__c> lFormulario = SIR_LCMP_IngresosIntervinientes.getFormulario(idFormulario);
        
        for(SIR_FormularioRefinanciacion__c formulario: lFormulario){
            formulario.SIR_TotalIngresosTrabajo__c = 123;
            formulario.SIR_TotalIngresosBienes__c = 123;
            formulario.SIR_OtrosDatosInteres__c = '123';
            formulario.SIR_IngresosAdicionalesUnidFam__c = 123;
        }
        update lFormulario;
        SIR_LCMP_IngresosIntervinientes.updateIntervinientes(lIntervinientes);

        SIR_LCMP_IngresosIntervinientes.updateFormulario(idFormulario, lFormulario[0].SIR_TotalIngresosTrabajo__c, lFormulario[0].SIR_TotalIngresosBienes__c, lFormulario[0].SIR_OtrosDatosInteres__c, lFormulario[0].SIR_IngresosAdicionalesUnidFam__c);
         
   		Test.stopTest();
        System.assertNotEquals(null, SIR_LCMP_IngresosIntervinientes.updateIntervinientes(lIntervinientes), constantes.STRING_TEST);

   }


}