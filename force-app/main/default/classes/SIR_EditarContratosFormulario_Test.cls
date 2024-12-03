/*****************************************************************
    Name: SIR_EditarContratosFormulario_Test
    Copyright © 2022 CaixaBank

    Proposito: Clase test de la clase LWC SIR_LCMP_EditarContratosFormulario                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US484767         Atmira         07/12/2022     	  Created    

*****************************************************************/
@isTest 
public class SIR_EditarContratosFormulario_Test {

    /*****************************************************************                                                    
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
            
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US484767         Atmira         07/12/2022     	  Created   
            
    *****************************************************************/    
    @isTest 
    public static void queryContratosTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        String respContratos;
        String respCrearBorrar;
        List<SIREC__SIREC_obj_procesoContrato__c> respEditarContratosFormularios;  
        SIR_Constantes constantes = new SIR_Constantes();
        System.runAs(usuario){
            // Se crean dos cuentas, una para que sea la principal y otra para que haga de intervininiente
            Account cuenta = SIR_TestDataFactory.crearCuenta();        
            //Se crean Informacion Clientes
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);        
            // Creamos un registro de catalogo CNAE
            SIREC__SIREC_obj_Catalogo__c  cat = SIR_TestDataFactory.crearCatalogoCNAE();
            // Se crea un contrato
            Contract contrato = SIR_TestDataFactory.crearContrato(cuenta);
            // Se crea otro contrato
            Contract contrato1 = SIR_TestDataFactory.crearContrato(cuenta);
            // Se relaciona a una cuenta (interviniente) con el contrato que se ha creado
            SIREC__SIREC_obj_intervinientesContrato__c intervinienteContrato = SIR_TestDataFactory.crearInterContrato(cuenta, contrato, 'TIT');
            SIREC__SIREC_obj_intervinientesContrato__c intervinienteContrato1 = SIR_TestDataFactory.crearInterContrato(cuenta, contrato1, 'TIT');
            // Se crea un proceso
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            // Se crea un formulario de refi
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            //Creamos un proceso relacionado con un contrato
            SIREC__SIREC_obj_procesoContrato__c procesoContrato = SIR_TestDataFactory.CrearProcesoContrato(proceso, contrato);
            Test.startTest();
            respContratos = SIR_LCMP_EditarContratosFormulario.queryContratos(formulario.Id);
            Test.stopTest();
            System.assertNotEquals('', respContratos, 'El formulario está vacio');
            System.assertNotEquals(null, respContratos, 'El metodo no está funcionando correctamente');
            System.assertEquals(cuenta.id+'*'+proceso.id, respContratos, 'No está devolviendo correctamente lo que debería');
        }
    }

    /*****************************************************************                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira       
        
	*****************************************************************/  
    @isTest 
    public static void queryContratatosFormularioTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        String respContratos;
        String respCrearBorrar;
        List<SIREC__SIREC_obj_procesoContrato__c> respEditarContratosFormularios;  
        SIR_Constantes constantes = new SIR_Constantes();
        System.runAs(usuario){
            // Se crean dos cuentas, una para que sea la principal y otra para que haga de intervininiente
            Account cuenta = SIR_TestDataFactory.crearCuenta();        
            //Se crean Informacion Clientes
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);        
            // Creamos un registro de catalogo CNAE
            SIREC__SIREC_obj_Catalogo__c  cat = SIR_TestDataFactory.crearCatalogoCNAE();
            // Se crea un contrato
            Contract contrato = SIR_TestDataFactory.crearContrato(cuenta);
            // Se crea otro contrato
            Contract contrato1 = SIR_TestDataFactory.crearContrato(cuenta);
            // Se relaciona a una cuenta (interviniente) con el contrato que se ha creado
            SIREC__SIREC_obj_intervinientesContrato__c intervinienteContrato = SIR_TestDataFactory.crearInterContrato(cuenta, contrato, 'TIT');
            SIREC__SIREC_obj_intervinientesContrato__c intervinienteContrato1 = SIR_TestDataFactory.crearInterContrato(cuenta, contrato1, 'TIT');
            // Se crea un proceso
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            // Se crea un formulario de refi
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            //Creamos un proceso relacionado con un contrato
            SIREC__SIREC_obj_procesoContrato__c procesoContrato = SIR_TestDataFactory.CrearProcesoContrato(proceso, contrato);
            Test.startTest();
            respEditarContratosFormularios = SIR_LCMP_EditarContratosFormulario.queryContratatosFormulario(proceso.Id);
            Test.stopTest();
            System.assertNotEquals(true, respEditarContratosFormularios.isEmpty(),'el metodo no ha encontrado ningun procesoContrato de esas caracteristicas');
            System.assertEquals(procesoContrato.SIREC__SIREC_fld_contract__c, respEditarContratosFormularios.get(0).SIREC__SIREC_fld_contract__c, 'No devuelve lo que corresponde');
        }
    }

    /*****************************************************************                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira       
        
	*****************************************************************/  
    @isTest 
    public static void apexCrearBorrarRegistrosTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        String respContratos;
        String respCrearBorrar;
        List<SIREC__SIREC_obj_procesoContrato__c> respEditarContratosFormularios;  
        SIR_Constantes constantes = new SIR_Constantes();
        System.runAs(usuario){
            // Se crean dos cuentas, una para que sea la principal y otra para que haga de intervininiente
            Account cuenta = SIR_TestDataFactory.crearCuenta();        
            //Se crean Informacion Clientes
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);        
            // Creamos un registro de catalogo CNAE
            SIREC__SIREC_obj_Catalogo__c  cat = SIR_TestDataFactory.crearCatalogoCNAE();
            // Se crea un contrato
            Contract contrato = SIR_TestDataFactory.crearContrato(cuenta);
            // Se crea otro contrato
            Contract contrato1 = SIR_TestDataFactory.crearContrato(cuenta);
            // Se relaciona a una cuenta (interviniente) con el contrato que se ha creado
            SIREC__SIREC_obj_intervinientesContrato__c intervinienteContrato = SIR_TestDataFactory.crearInterContrato(cuenta, contrato, 'TIT');
            SIREC__SIREC_obj_intervinientesContrato__c intervinienteContrato1 = SIR_TestDataFactory.crearInterContrato(cuenta, contrato1, 'TIT');
            // Se crea un proceso
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            // Se crea un formulario de refi
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            //Creamos un proceso relacionado con un contrato
            SIREC__SIREC_obj_procesoContrato__c procesoContrato = SIR_TestDataFactory.CrearProcesoContrato(proceso, contrato);
            Test.startTest();
            formulario.SIR_CuotaOperacionRefCaixa__c = 0;
            update formulario;
            String listaContratosAntiguos = contrato.Id;
            String listaContratosNuevos = contrato1.Id;
            respCrearBorrar = SIR_LCMP_EditarContratosFormulario.apexCrearBorrarRegistros (formulario.Id, proceso.Id, cuenta.Id,listaContratosAntiguos, listaContratosNuevos); 
            Test.stopTest();
            System.assertEquals('OK', respCrearBorrar, 'Ha ocurrido un error con la QUERY');
        }
    }
}