/*****************************************************************
    Name: SIR_GastosIntervinientes_Test
    Copyright © 2021 CaixaBank
============================================================
    Proposito: Clase Test de la clase controladora externa del LWC SIR_LCMP_GastosIntervinientes (sir_lwc_GastosIntervinientes)                                                                                                                  
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249657         Atmira         17/07/2021     	 Created    

*****************************************************************/
@isTest 
public class SIR_GastosIntervinientes_Test {
    
    /*****************************************************************
        Proposito: gestorIntervenientesTest sirve para comprobar toda la logica del controlador SIR_LCMP_GastosIntervinientes                                                      
        Parameters: No
        Returns: No                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249657         Atmira         14/07/2021     	  Created    
        
	*****************************************************************/
    @isTest 
    public static void gestorIntervenientesTest() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Test.startTest();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            List<SIR_FormularioRefinanciacion__c> lForm = new List<SIR_FormularioRefinanciacion__c>();
            lForm.add(formulario);
            SIR_LCMP_GastosIntervinientes.getFormulario(formulario.id);
            SIR_LCMP_GastosIntervinientes.getMetadatos();
            List<String> datosUpdate = new List<String>();
            datosUpdate.add('3'); //SIR_MiembrosUnidadFamiliar__c
            datosUpdate.add('500'); //SIR_IngresosAdicionalesUnidFam__c
            datosUpdate.add('600'); //SIR_ImporteMinSubsistencia__c
            datosUpdate.add('1000'); //SIR_AlquilerViviendaHabitual__c
            datosUpdate.add('200'); //SIR_PensionAlimenticia__c
            datosUpdate.add('60'); //SIR_Otros__c
            datosUpdate.add('Otros gastos'); //SIR_JustificarOtrosGastos__c
            datosUpdate.add('5000'); //SIR_TotalGastos__c
            SIR_LCMP_GastosIntervinientes.updateFormulario(formulario.id, datosUpdate);
            Test.stopTest();
            System.assertNotEquals(null, SIR_LCMP_GastosIntervinientes.updateFormulario(formulario.id, datosUpdate), constantes.STRING_TEST);
        }
    }
}