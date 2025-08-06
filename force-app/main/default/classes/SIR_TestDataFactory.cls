/*****************************************************************
 Name:  SIR_TestDataFactory
 Copyright © 2021  CaixaBank

Proposito:   Clase DataFactory con metodos para realizar Test                                                                                                                  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US Id            Atmira         21/06/2021     	  Created    

*****************************************************************/
@isTest
public with sharing class SIR_TestDataFactory {

    /*****************************************************************
        Proposito:  crearContacto() sirve para crear un contacto asociado a una cuenta
        Returns: Contact                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/04/2024     	  Created   
    *****************************************************************/
	public static Contact crearContacto(Account cuenta, String rtDeveloperName ){         
        Contact contacto = new Contact(
            LastName = 'Contacto Test',
            AccountId = cuenta.Id,
            RecordTypeId=  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId()
        );
		insert contacto;
		return contacto;
	}

    /*****************************************************************
        Proposito:  crearCuenta() sirve para crear una cuenta con el recordtype ????
        Returns: Account                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created   
    *****************************************************************/
	public static Account crearCuenta(){        
        Id accClienteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.CLIENTE_RECORDTYPE_DEVELOPERNAME).getRecordTypeId();
		Account acc = new Account(
				LastName = 'Test',
            	CC_TipoPersona__c = 'J',            	
				RecordTypeId = accClienteRecordTypeId
			);
		insert acc;
		return acc;
	}
        /*****************************************************************
        Proposito:  crearCuenta() sirve para crear una cuenta con el empresas
        Returns: Account                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created   
    *****************************************************************/
	public static Account crearCuentaEMP(){        
        
		Account acc = new Account(
            Name = 'Test',
            CC_TipoPersona__c = 'J',           	
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId()
		);
		insert acc;
		return acc;
	}
    /*****************************************************************
        Proposito:  crearAccJerarquiaCaixa() sirve para crear una jerarquia de cuentas con el recordtype Caixa
        Returns: Account                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/07/2021     	  Created   
    *****************************************************************/
	public static List<Account> crearAccJerarquiaCaixa(){        
        Id accEmpleadoRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		List<Account> accLst = new List<Account>();
       
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest',rol,'System Administrator');        

        System.runAs(usuario) {  
		//Se crea Cuenta DT
        Account accDT = new Account(
                Name = 'DT',          	
				RecordTypeId = accEmpleadoRecordTypeId,
                AV_TipoCentroSuperior__c = 'TT',
                AV_TipoEstructura__c = '02',
                AV_EmpresaSuperior__c = '001',
                CC_Numero_Empresa__c = '001',
                CC_Numero_Oficina__c = '00001',
                CC_Numero_Oficina_Empresa__c = '001-DT'
			);
        insert accDT;
        accLst.add(accDT);
        //Cuenta DC
        Account accDC = new Account(
				Name = 'DC',          	
				RecordTypeId = accEmpleadoRecordTypeId,
                ParentId = accDT.Id,
                AV_CentroSuperior__c = accDT.Id,
                AV_TipoCentroSuperior__c = 'DT',
                AV_TipoEstructura__c = '02',
                AV_EmpresaSuperior__c = '001',
                CC_Numero_Empresa__c = '001',
                CC_Numero_Oficina__c = '00002',
                CC_Numero_Oficina_Empresa__c = '001-DC'
			);
		insert accDC;
        accLst.add(accDC);
        //Cuenta DAN
        Account accDAN = new Account(
				Name = 'DAN',          	
				RecordTypeId = accEmpleadoRecordTypeId,
                ParentId = accDC.Id,
                AV_CentroSuperior__c = accDC.Id,
                AV_TipoCentroSuperior__c = 'DG',
                AV_TipoEstructura__c = '02',
                AV_EmpresaSuperior__c = '001',
                CC_Numero_Empresa__c = '001',
                CC_Numero_Oficina__c = '00003',
                CC_Numero_Oficina_Empresa__c = '001-DAN'
			);
		insert accDAN;
        accLst.add(accDAN);
        //Cuenta Oficina
        Account accOficina = new Account(
				Name = 'Oficina',          	
				RecordTypeId = accEmpleadoRecordTypeId,
                ParentId = accDAN.Id,
                AV_CentroSuperior__c = accDAN.Id,
                AV_TipoCentroSuperior__c = 'GC',
                AV_TipoEstructura__c = '02',
                AV_EmpresaSuperior__c = '001',
                CC_Numero_Empresa__c = '001',
                CC_Numero_Oficina__c = '00004',
                CC_Numero_Oficina_Empresa__c = '001-Ofi'
			);
		insert accOficina;
        accLst.add(accOficina);
        }

		return accLst;
	}
    /*****************************************************************
        Proposito:  crearCntJerarquiaCaixa() sirve para crear una jerarquia de cuentas con el recordtype Caixa
        Returns: Account                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/07/2021     	  Created   
    *****************************************************************/
	public static List<Contact> crearCntJerarquiaCaixa(List<Account> accLst, List<User> userLst){        
        Id accEmpleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        List<Contact> cntLst = new List<Contact>();
        Account accDT;
        Account accDC;
        Account accDAN;
        Account accOficina;
        User userDT;
        User userDC;
        User userDAN;
        User userOficina;
        User userGestor;

        for(Account acc : accLst){
            if(acc.Name == 'DT'){
                accDT = acc;
            }else if(acc.Name == 'DC'){
                accDC = acc;
            }else if(acc.Name == 'DAN'){
                accDAN = acc;
            }else if(acc.Name == 'Oficina'){
                accOficina = acc;
            }
        }

        for(User us : userLst){
            if(us.Alias == 'DT'){
                userDT = us;
            }else if(us.Alias  == 'DC'){
                userDC = us;
            }else if(us.Alias  == 'DAN'){
                userDAN = us;
            }else if(us.Alias  == 'Oficina'){
                userOficina = us;
            }else if(us.Alias  == 'Gestor'){
                userGestor = us;
            }
        }

        //Se actualiza el Contacto de la Cuenta DT y se asocia al usuario
        Contact contDT = new Contact(
                LastName = 'DT',
                AccountId = accDT.Id,
                AV_UsuarioAsociado__c = userDT.Id,
                Email = 'standarduserdt@testorg.com',
                RecordTypeId= accEmpleadoRecordTypeId,
                CC_Idioma__c = 'es',
                CC_Cargo__c = 'DIRECCIÓN'
        );
        insert contDT;
        cntLst.add(contDT);
        //Se actualiza el Contacto de la Cuenta DC y se asocia al usuario
        Contact contDC = new Contact(
                LastName = 'DC',
                AccountId = accDC.Id,
                AV_UsuarioAsociado__c = userDC.Id,
                Email = 'standarduserdc@testorg.com',
                RecordTypeId= accEmpleadoRecordTypeId,
                CC_Idioma__c = 'es',
                CC_Cargo__c = 'DIRECCIÓN ÁREA DE NEGOCIO'
        );
        insert contDC;
        cntLst.add(contDC);
        //Se actualiza el Contacto de la Cuenta DAN y se asocia al usuario
        Contact contDAN = new Contact(
                LastName = 'DAN',
                AccountId = accDAN.Id,
                AV_UsuarioAsociado__c = userDAN.Id,
                Email = 'standarduserdan@testorg.com',
                RecordTypeId= accEmpleadoRecordTypeId,
                CC_Idioma__c = 'es',
                CC_Cargo__c = 'DIRECCIÓN'
        );
        insert contDAN;
        cntLst.add(contDAN);
        //Se actualiza el Contacto de la Cuenta Oficina y se asocia al usuario
        Contact contOficina = new Contact(
                LastName = 'Oficina',
                AccountId = accOficina.Id,
                AV_UsuarioAsociado__c = userOficina.Id,
                Email = 'standarduseroficina@testorg.com',
                RecordTypeId= accEmpleadoRecordTypeId,
                CC_Idioma__c = 'es',
                CC_Cargo__c = 'SUBDIRECCIÓN'
        );
        insert contOficina;
        cntLst.add(contOficina);
        Contact contGestor = new Contact(
                LastName = 'Gestor',
                AccountId = accOficina.Id,
                AV_UsuarioAsociado__c = userGestor.Id,
                Email = 'standardusergestor@testorg.com',
                RecordTypeId= accEmpleadoRecordTypeId,
                CC_Idioma__c = 'es',
                CC_Cargo__c = 'Empleado'
        );
        insert contGestor;
        cntLst.add(contGestor);

		return cntLst;
	}

    
    /*****************************************************************
        Proposito:  crearContrato() sirve para crear un contrato con una cuenta determinada                                                      
        Parameters: Account
        Returns: Account                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created    
    *****************************************************************/
	public static Contract crearContrato(Account cuenta){
		Contract con = new Contract(
				Status = 'Draft',
				AccountId = cuenta.Id,
				StartDate = Date.today(),
                SIREC__SIREC_fld_deudaTotalContrato__c = 100,
            	SIREC__SIREC_fld_importeImpagado__c = 50,
                SIREC__SIREC_fld_fechaActualizacionSIREC__c = Date.today()
			);
		insert con;
		return con;
	}

    
    /*****************************************************************
        Proposito:  crearInterContrato() sirve para crear una relacion entre objeto contrato y objeto interviniente                                                      
        Parameters: Account, Contract, String (que tipo de relacion entre cuenta y contrato hay)
        Returns: SIREC__SIREC_obj_intervinientesContrato__c                                                     
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created    
    *****************************************************************/
	public static SIREC__SIREC_obj_intervinientesContrato__c crearInterContrato(Account cuenta, Contract contrato, String relacion){
		SIREC__SIREC_obj_intervinientesContrato__c interCon = new SIREC__SIREC_obj_intervinientesContrato__c(
				SIREC__SIREC_fld_contract__c = contrato.Id,
				SIREC__SIREC_fld_persona__c = cuenta.Id,
				SIREC__SIREC_fld_relacionContract__c = relacion
			);
		insert interCon;
		return interCon;
	}

        /*****************************************************************
        Proposito:  CrearInfoCliente() sirve para crear un SIREC__SIREC_obj_informacionCliente__c del account                                                     
        Parameters: Account
        Returns: Account                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created    
    *****************************************************************/
	public static SIREC__SIREC_obj_informacionCliente__c crearInfoCliente(Account cuenta){
		SIREC__SIREC_obj_informacionCliente__c infoCliente = new SIREC__SIREC_obj_informacionCliente__c(
				SIREC__SIREC_fld_cliente__c    = cuenta.Id,
				SIREC__SIREC_fld_arquetipo__c  = 'Test',
            	SIREC__SIREC_fld_ingresosTotal__c = 2000,
            	SIREC__SIREC_fld_CNAETexto__c = '000009525',
                SIREC__SIREC_fld_masterRecordId__c = '123456'
			);
		insert infoCliente;
		return infoCliente;
	}
    
        /*****************************************************************
        Proposito:  CrearProceso() sirve para crear un SIREC__SIREC_obj_proceso__c del account                                                     
        Parameters: Account
        Returns: Account                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created    
    *****************************************************************/
	public static SIREC__SIREC_obj_proceso__c crearProceso(Account cuenta){
		SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
				Name = SIR_Constantes.PROCESO_NAME_REFINANCIACION,
                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1,	
            	SIREC__SIREC_fld_cliente__c    = cuenta.Id,
				SIREC__SIREC_fld_fechaInicio__c  = date.today(),
            	SIREC__SIREC_fld_fechaLimite__c  = date.today(),
            	SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                SIREC__SIREC_fld_masterRecordId__c = 'PROCESOMRId',
                SIREC__SIREC_fld_codProceso__c = 'test',
                recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId()
			);
		insert proceso;
		return proceso;
	}

        /*****************************************************************
        Proposito:  CrearProcesoPRESOL() sirve para crear un SIREC__SIREC_obj_proceso__c de PRESOL del account                                                     
        Parameters: Account
        Returns: Account                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         03/10/2022     	  Created    
    *****************************************************************/
	public static SIREC__SIREC_obj_proceso__c crearProcesoPRESOL(Account cuenta){
		SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
				Name = 'PRESOL - Preventivo',
                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_PRESOL_E1,	
            	SIREC__SIREC_fld_cliente__c    = cuenta.Id,
				SIREC__SIREC_fld_fechaInicio__c  = date.today(),
            	SIREC__SIREC_fld_fechaLimite__c  = date.today(),
            	SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                SIREC__SIREC_fld_masterRecordId__c = 'PROCESOMRId',
                recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId()
			);
		insert proceso;
		return proceso;
	}

    public static SIREC__SIREC_obj_proceso__c crearProceso(Account cuenta, String mrId){
        		SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
				Name = SIR_Constantes.PROCESO_NAME_REFINANCIACION,
                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1,
                SIREC__SIREC_fld_cliente__c    = cuenta.Id,
				SIREC__SIREC_fld_fechaInicio__c  = date.today(),
            	SIREC__SIREC_fld_fechaLimite__c  = date.today(),
            	SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                SIREC__SIREC_fld_masterRecordId__c = mrId,
                recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId()
			);
		insert proceso;
		return proceso;
    }

    public static SIREC__SIREC_obj_proceso__c crearProcesoPRESOL(Account cuenta, String mrId){
        SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
        Name = SIR_Constantes.PROCESO_NAME_REFINANCIACION,
        SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1,
        SIREC__SIREC_fld_cliente__c    = cuenta.Id,
        SIREC__SIREC_fld_fechaInicio__c  = date.today(),
        SIREC__SIREC_fld_fechaLimite__c  = date.today(),
        SIREC__SIREC_fld_fechaSituacion__c = date.today(),
        SIREC__SIREC_fld_masterRecordId__c = mrId,
        recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId()
    );
insert proceso;
return proceso;
}

public static SIREC__SIREC_obj_proceso__c crearProcesoPrevemp(Account cuenta, String mrId){
    SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
    Name = 'Preventivo',
    SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1,
    SIREC__SIREC_fld_cliente__c    = cuenta.Id,
    SIREC__SIREC_fld_fechaInicio__c  = date.today(),
    SIREC__SIREC_fld_fechaLimite__c  = date.today(),
    SIREC__SIREC_fld_fechaSituacion__c = date.today(),
    SIREC__SIREC_fld_masterRecordId__c = mrId,
    recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId()
);
insert proceso;
return proceso;
}

public static SIREC__SIREC_obj_proceso__c crearProcesoHijo(SIREC__SIREC_obj_proceso__c procesoPadre, String mrId){
    SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
    Name = 'AP-PP Hijo',
    SIREC__SIREC_fld_estrategia__c = procesoPadre.SIREC__SIREC_fld_estrategia__c,
    SIREC__SIREC_fld_cliente__c    = procesoPadre.SIREC__SIREC_fld_cliente__c,
    SIREC__SIREC_fld_fechaInicio__c  = date.today(),
    SIREC__SIREC_fld_fechaLimite__c  = date.today(),
    SIREC__SIREC_fld_fechaSituacion__c = date.today(),
    SIREC__SIREC_fld_masterRecordId__c = mrId,
    SIREC__SIREC_fld_procesoSuperior__c = procesoPadre.Id,
    recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_AP_PP).getRecordTypeId()
);
insert proceso;
return proceso;
}

public static SIREC__SIREC_obj_proceso__c crearProceso(ProcesosTest procesoTest){
        Account cuenta = procesoTest.getCuenta();
        String mrId = procesoTest.getMRID();
        String estrategia = procesoTest.getEstrategia();
        String tipoProceso = procesoTest.getTipoProceso();

            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
            Name = SIR_Constantes.PROCESO_NAME_REFINANCIACION,
            SIREC__SIREC_fld_estrategia__c = estrategia,
            SIREC__SIREC_fld_cliente__c    = cuenta.Id,
            SIREC__SIREC_fld_fechaInicio__c  = date.today(),
            SIREC__SIREC_fld_fechaLimite__c  = date.today(),
            SIREC__SIREC_fld_fechaSituacion__c = date.today(),
            SIREC__SIREC_fld_masterRecordId__c = mrId,
            recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(tipoProceso).getRecordTypeId()
        );
    insert proceso;
    return proceso;
    }
    
        /*****************************************************************
        Proposito:  crearProcesoFechaConcreta() sirve para crear un SIREC__SIREC_obj_proceso__c del account                                                     
        Parameters: Account
        Returns: Account                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created    
    *****************************************************************/
	public static SIREC__SIREC_obj_proceso__c crearProcesoFechaConcreta(Account cuenta){
		SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
				Name = SIR_Constantes.PROCESO_NAME_REFINANCIACION,
                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1,	
            	SIREC__SIREC_fld_cliente__c    = cuenta.Id,
				SIREC__SIREC_fld_fechaInicio__c  = Date.newInstance(2022, 1, 1),
            	SIREC__SIREC_fld_fechaLimite__c  = date.today(),
            	SIREC__SIREC_fld_fechaSituacion__c = date.today()
			);
		insert proceso;
		return proceso;
	}
    /*****************************************************************
        Proposito:  CrearProcesoContrato()                                                  
        Parameters: Account
        Returns: Account                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created    
    *****************************************************************/
	public static SIREC__SIREC_obj_procesoContrato__c crearProcesoContrato(SIREC__SIREC_obj_proceso__c proceso, Contract contrato){
		SIREC__SIREC_obj_procesoContrato__c procesoContrato = new SIREC__SIREC_obj_procesoContrato__c(
				SIREC__SIREC_fld_contract__c    = contrato.Id,
				SIREC__SIREC_fld_proceso__c  = proceso.Id
            
			);
		insert procesoContrato;
		return procesoContrato;
	}
     /*****************************************************************
        Proposito:  crearAccion()                                                  
        Parameters: Account
        Returns: Account                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created    
    *****************************************************************/
	public static SIREC__SIREC_obj_acciones__c crearAccion (SIREC__SIREC_obj_proceso__c proceso){
		SIREC__SIREC_obj_acciones__c accionNew = new SIREC__SIREC_obj_acciones__c(
				SIREC__SIREC_fld_proceso__c  = proceso.Id,
            	SIR_valorAccion__c			 = '174', 
                SIREC__SIREC_fld_tipo__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA,
                SIREC__SIREC_fld_fechaContacto__c = Date.today()    	
            
			);
		insert accionNew;
		return accionNew;
	}

     /*****************************************************************
        Proposito:  crearAccion()                                                  
        Parameters: Account
        Returns: Account                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created    
    *****************************************************************/
	public static SIREC__SIREC_obj_acciones__c crearAccionProcesoAmistoso (SIREC__SIREC_obj_proceso__c proceso){
		SIREC__SIREC_obj_acciones__c accionNew = new SIREC__SIREC_obj_acciones__c(
				SIREC__SIREC_fld_proceso__c  = proceso.Id,
            	SIR_valorAccion__c			 = '174', 
                SIREC__SIREC_fld_tipo__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA,
                SIREC__SIREC_fld_fechaContacto__c = Date.today(),
                recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByName().get(SIR_Constantes.ACCION_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId()  	
            
			);
		insert accionNew;
		return accionNew;
	}
        /*****************************************************************
        Proposito:  CrearFormulario()                                                  
        Parameters: SIREC__SIREC_obj_proceso__c
        Returns: formulario                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         21/06/2021     	  Created    
    *****************************************************************/
	public static SIR_FormularioRefinanciacion__c crearFormulario(SIREC__SIREC_obj_proceso__c proceso){
		SIR_FormularioRefinanciacion__c formulario = new SIR_FormularioRefinanciacion__c(
				SIR_Proceso__c  = proceso.Id,
                SIR_Persona__c = proceso.SIREC__SIREC_fld_cliente__c,
                Name = '0001 - ' + SIR_Constantes.FORMULARIOREFINANCIACION_CHECK_LIST_REFINANCIACION
			);
		insert formulario;
		return formulario;
	}


    public static User createTestUser(String userName, UserRole rol, String perfil) {
        User u = new User(
            ProfileId = [SELECT Id,Name FROM Profile WHERE Name = :perfil].Id,
            LastName = userName,
            Email = userName + '@testemail.com',
            Username =  userName + '@usertestsirec.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = rol.Id
        );
        insert u;
        return u;
    }

    public static User createTestUser(String userName, UserRole rol, String perfil, String employeeNumber) {
        User u = new User(
            ProfileId = [SELECT Id,Name FROM Profile WHERE Name = :perfil].Id,
            LastName = userName,
            Email = userName + '@testemail.com',
            Username =  userName + '@usertestsirec.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = rol.Id,
            EmployeeNumber = employeeNumber
        );
        insert u;
        return u;
    }
    
    public static User createTestUser(String userName, UserRole rol, String perfil, String employeeNumber, String numeroOficinaEmpresa) {
        User u = new User(
            ProfileId = [SELECT Id,Name FROM Profile WHERE Name = :perfil].Id,
            LastName = userName,
            Email = userName + '@testemail.com',
            Username =  userName + '@usertestsirec.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = rol.Id,
            EmployeeNumber = employeeNumber,
            AV_NumeroOficinaEmpresa__c = numeroOficinaEmpresa
        );
        insert u;
        return u;
    }

    public static User createTestUser(String userName, UserRole rol, String perfil, String employeeNumber, String numeroOficinaEmpresa, String funcion) {
        User u = new User(
            ProfileId = [SELECT Id,Name FROM Profile WHERE Name = :perfil].Id,
            LastName = userName,
            Email = userName + '@testemail.com',
            Username =  userName + '@usertestsirec.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = rol.Id,
            EmployeeNumber = employeeNumber,
            AV_NumeroOficinaEmpresa__c = numeroOficinaEmpresa,
            AV_Funcion__c = funcion
        );
        insert u;
        return u;
    }
    
    /*****************************************************************
        Proposito:  Creamos un registro para el catalogo CNAE
        Returns: SIREC__SIREC_obj_Catalogo__c                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         23/09/2021     	  Created   
    *****************************************************************/
	public static SIREC__SIREC_obj_Catalogo__c  crearCatalogoCNAE(){        
        SIREC__SIREC_obj_Catalogo__c  cat = new SIREC__SIREC_obj_Catalogo__c (
                SIREC__SIREC_fld_Codigo__c = '000009525',
                SIREC__SIREC_fld_Descripcion__c = 'Reparación de relojes y joyería',
				Name = 'CNAE'
			);
		insert cat;
		return cat;
	}

    /*****************************************************************
        Proposito:  Creamos un registro para las estrategias en el catalogo
        Returns: SIREC__SIREC_obj_Catalogo__c                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         08/08/2024     	  Created   
    *****************************************************************/
	public static  SIREC__SIREC_obj_Catalogo__c  crearCatalogoEstrategia(String estrategia){        
        SIREC__SIREC_obj_Catalogo__c cat = new SIREC__SIREC_obj_Catalogo__c(
            SIREC__SIREC_fld_Codigo__c = estrategia,
            SIREC__SIREC_fld_Descripcion__c = 'Descripcion estrategia ' + estrategia,
            SIREC__SIREC_fld_CodigoActivo__c = 'S',
			Name = 'ESTATEGIA'
		);
		insert cat;
		return cat;
	}

    /*****************************************************************
        Proposito:  Creamos N registros para las estrategias en el catalogo 
                    para un negocio pasado por parametro
        Returns: SIREC__SIREC_obj_Catalogo__c                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         08/08/2024     	  Created   
    *****************************************************************/
	public static  List<SIREC__SIREC_obj_Catalogo__c>  crearCatalogoEstrategiasNegocio(Integer n, String negocio){        
        List<SIREC__SIREC_obj_Catalogo__c> listCatalogo = new List<SIREC__SIREC_obj_Catalogo__c>();
        for(Integer i = 0; i < n; i++){
            listCatalogo.add(new SIREC__SIREC_obj_Catalogo__c(
                   SIREC__SIREC_fld_Codigo__c = String.valueOf(i),
                    SIREC__SIREC_fld_Descripcion__c = 'Descripcion estrategia ' + String.valueOf(i),
                    SIREC__SIREC_fld_CodigoActivo__c = 'S',
                    SIREC__SIREC_fld_CodigoNegocio__c = negocio,
                    SIREC__SIREC_fld_OrdenAgrupador__c = i,
			        Name = SIR_Constantes.CATALOGO_PREFIJO_ESTRATEGIA 
		    ));
        }
        insert listCatalogo;
		return listCatalogo;
	}

    public static void crearIntegrationSetting(String name){
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
            wsc.Name = name;
            wsc.NamedCredential__c = 'callout:' + name;
            insert wsc;
    }

    public static void crearIntegrationSetting(String name, String param){
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
            wsc.Name = name;
            wsc.NamedCredential__c = 'callout:' + name + '/' + param;
            insert wsc;
    }

    public static SIREC__SIREC_obj_tarea__c crearTareaTipoSEL(SIREC__SIREC_obj_proceso__c proceso){
        SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c(
            SIREC__SIREC_fld_proceso__c = proceso.Id,
            SIREC__SIREC_fld_masterRecordId__c = String.valueof((Integer)(Math.random() * 100000)),
            SIREC__SIREC_fld_codigo_tarea__c = 'CódigoTareaTest',
            Name = 'TareaTest',
            SIREC__SIREC_fld_tipo_tarea__c = 'SEL',
            SIREC__SIREC_fld_seleccion__c = 'S',
            SIREC__SIREC_fld_SEL_opciones_cod__c = 'opcion1|opcion2',
            SIREC__SIREC_fld_SEL_opciones_desc__c = 'desc1|desc2',
            SIREC__SIREC_fld_tituloInfo__c = 'Titulo test',
            SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
            SIREC__SIREC_fld_estado__c = 'En curso'
        );
        insert tarea;
        return tarea;
    }
    public static SIREC__SIREC_obj_tarea__c crearTareaTipoDAT(SIREC__SIREC_obj_proceso__c proceso){
        SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c(
            SIREC__SIREC_fld_proceso__c = proceso.Id,
            SIREC__SIREC_fld_masterRecordId__c = String.valueof((Integer)(Math.random() * 100000)),
            SIREC__SIREC_fld_codigo_tarea__c = 'CódigoTareaTest',
            Name = 'TareaTest',
            SIREC__SIREC_fld_tipo_tarea__c = 'DAT',            
            SIREC__SIREC_fld_tituloInfo__c = 'Titulo test',
            SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
            SIREC__SIREC_fld_estado__c = 'En curso'
        );
        insert tarea;
        return tarea;
    }
    public static SIREC__SIREC_obj_tarea__c crearTareaTipoOPC(SIREC__SIREC_obj_proceso__c proceso){
        SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c(
            SIREC__SIREC_fld_proceso__c = proceso.Id,
            SIREC__SIREC_fld_masterRecordId__c = String.valueof((Integer)(Math.random() * 100000)),
            SIREC__SIREC_fld_codigo_tarea__c = 'CódigoTareaTest',
            Name = 'TareaTest',
            SIREC__SIREC_fld_tipo_tarea__c = 'OPC',            
            SIREC__SIREC_fld_tituloInfo__c = 'Titulo test',
            SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
            SIREC__SIREC_fld_estado__c = 'En curso'
        );
        insert tarea;
        return tarea;
    }
    public static SIREC__SIREC_obj_tarea__c crearTareaTipoOPCC(SIREC__SIREC_obj_proceso__c proceso){

        Map<String, Object> mapToSerialize = new map<String, Object>();
        List<String> lista = new List<String>{'1806511'};
        mapToSerialize.put('idOpcSeleccionados', (Object)'122222');
        mapToSerialize.put('idOpcNoSeleccionados', (Object)'44444');
        string jsonstring = JSON.serialize(mapToSerialize);


        SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c(
            SIREC__SIREC_fld_proceso__c = proceso.Id,
            SIREC__SIREC_fld_masterRecordId__c = String.valueof((Integer)(Math.random() * 100000)),
            SIREC__SIREC_fld_codigo_tarea__c = 'CódigoTareaTest',
            Name = 'TareaTest OPC Contrato',
            SIREC__SIREC_fld_tipo_tarea__c = 'OPC',            
            SIREC__SIREC_fld_tituloInfo__c = 'Titulo test',
            SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
            SIR_FormularioOPCResp__c = '{"idOpcSeleccionados": ["1806511","22179075"], "idOpcNoSeleccionados": ["21428723"]}',
            SIREC__SIREC_fld_estado__c = 'En curso'
        );
        insert tarea;
        return tarea;
    }
    public static SIREC__SIREC_obj_tarea__c crearTareaTipoCTLWS(SIREC__SIREC_obj_proceso__c proceso){
        SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c(
            SIREC__SIREC_fld_proceso__c = proceso.Id,
            SIREC__SIREC_fld_masterRecordId__c = String.valueof((Integer)(Math.random() * 100000)),
            SIREC__SIREC_fld_codigo_tarea__c = 'CódigoTareaTestCTL',
            Name = 'TareaTestCTL',
            SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_CTL,
            SIREC__SIREC_fld_tituloInfo__c = 'Titulo test CTL',
            SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
            SIREC__SIREC_fld_estado__c = 'En curso',
            SIREC__SIREC_fld_insertWS__c = true
        );
        insert tarea;
        return tarea;
    }

    public static SIREC__SIREC_obj_tarea__c crearTareaTipoBAT(SIREC__SIREC_obj_proceso__c proceso){
        SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c(
            SIREC__SIREC_fld_proceso__c = proceso.Id,
            SIREC__SIREC_fld_masterRecordId__c = String.valueof((Integer)(Math.random() * 100000)),
            SIREC__SIREC_fld_codigo_tarea__c = 'CódigoTareaTest',
            Name = 'TareaTestBAT',
            SIREC__SIREC_fld_tipo_tarea__c = 'BAT',                        
            SIREC__SIREC_fld_tituloInfo__c = 'Titulo test BAT',
            SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
            SIREC__SIREC_fld_estado__c = 'En curso'
        );
        insert tarea;
        return tarea;
    }

    public static SIREC__SIREC_obj_tarea__c crearTareaTipoCTLSeg(SIREC__SIREC_obj_proceso__c proceso){
        SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c(
            SIREC__SIREC_fld_proceso__c = proceso.Id,
            SIREC__SIREC_fld_masterRecordId__c = String.valueof((Integer)(Math.random() * 100000)),
            SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_TAREA_CTL_SEGUIMIENTO,
            Name = 'TareaTestCTLSeg',
            SIREC__SIREC_fld_tipo_tarea__c = 'CTL',                        
            SIREC__SIREC_fld_tituloInfo__c = 'Titulo test CTL SEGUIMIENTO',
            SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
            SIREC__SIREC_fld_estado__c = 'En curso',
            SIREC__SIREC_fld_insertWS__c = false
        );
        insert tarea;
        return tarea;
    }

     /*****************************************************************
        Proposito:  Método para crear cuentas
        Returns: List<Account>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                           Atmira         28/04/2022     	  Created   
    *****************************************************************/

    public static List<Account> crearCuenta(Integer n){        
		List<Account> lstAccount = new List<Account>();
        if (Schema.sObjectType.Account.isCreateable()) {
            for (Integer i = 0; i < n; i++) {
                lstAccount.add(
                    new Account(
                        Name = 'Test' + n
                        ));
            }
            insert lstAccount;
        }
		return lstAccount;
	}


    /*****************************************************************
        Proposito:  Método para crear procesos
        Returns: List<SIREC__SIREC_obj_proceso__c>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                           Atmira         28/04/2022     	  Created   
    *****************************************************************/
	public static List<SIREC__SIREC_obj_proceso__c> crearProceso(Integer n, Account cuenta){
        List<SIREC__SIREC_obj_proceso__c> lstProceso = new List<SIREC__SIREC_obj_proceso__c>();
        if (Schema.sObjectType.SIREC__SIREC_obj_proceso__c.isCreateable()) {
        for (Integer i = 0; i < n; i++) {
            lstProceso.add(new SIREC__SIREC_obj_proceso__c(
                Name = SIR_Constantes.PROCESO_NAME_REFINANCIACION,
                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1,
				SIREC__SIREC_fld_cliente__c    = cuenta.Id,
				SIREC__SIREC_fld_fechaInicio__c  = date.today(),
            	SIREC__SIREC_fld_fechaLimite__c  = date.today(),
            	SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                SIREC__SIREC_fld_masterRecordId__c = 'masterRecordId'+ i,
                recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId()
			));
        }
		
		insert lstProceso;
        }
		return lstProceso;
	}


    /*****************************************************************
        Proposito:  Método para crear registro de Historico de Procesos de tipo Estrategia
        Returns: List<SIR_HistoricoProceso__c                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                           Atmira         06/07/2022     	  Created   
    *****************************************************************/
    public static List<SIR_HistoricoProceso__c> crearHistoricoProceso(Integer n, SIREC__SIREC_obj_proceso__c proceso){
        List<SIR_HistoricoProceso__c> lstHistoricoProceso = new List<SIR_HistoricoProceso__c>();
        if (Schema.sObjectType.SIR_HistoricoProceso__c.isCreateable()) {
            for (Integer i = 0; i < n; i++) {
                    lstHistoricoProceso.add(new SIR_HistoricoProceso__c(
                        Name = 'testProcesoHistorico' + n,
                        SIR_Proceso__c = proceso.Id,
                        SIR_Tipo__c = 'Estrategia'
                    )
                    
                );
                
            }
            insert lstHistoricoProceso;
        }
        return lstHistoricoProceso;
    }

    /*****************************************************************
        Proposito:  Método para crear tareas
        Returns: List<SIR_HistoricoProceso__c                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                           Atmira         28/04/2022    	  Created   
    *****************************************************************/
    public static List<SIREC__SIREC_obj_tarea__c> createTarea(Integer n, SIREC__SIREC_obj_proceso__c proceso){
        List<SIREC__SIREC_obj_tarea__c> lstTarea  = new List<SIREC__SIREC_obj_tarea__c> ();
        if (Schema.sObjectType.SIR_HistoricoProceso__c.isCreateable()) {
            for (Integer i = 0; i < n; i++) {
                SIREC__SIREC_obj_tarea__c tarea = (new SIREC__SIREC_obj_tarea__c(
                    SIREC__SIREC_fld_proceso__c = proceso.Id,
                    SIREC__SIREC_fld_masterRecordId__c = String.valueof((Integer)(Math.random() * 100000)),
                    SIREC__SIREC_fld_codigo_tarea__c = 'CódigoTareaTest',
                    Name = 'TareaTest',
                    SIREC__SIREC_fld_tipo_tarea__c = 'TipoTareaTest',
                    //SIREC__SIREC_fld_seleccion__c = 'S',
                    //SIREC__SIREC_fld_SEL_opciones_cod__c = 'opcion1|opcion2',
                    //SIREC__SIREC_fld_SEL_opciones_desc__c = 'desc1|desc2',
                    //SIREC__SIREC_fld_tituloInfo__c = 'Titulo test',
                    SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
                    SIREC__SIREC_fld_estado__c = 'En curso'
                ));
                lstTarea.add(tarea);
            }
            insert lstTarea;
        }
        return lstTarea;
    }

    /*
    @creation date: 28/04/2022
    @author: Kevin Alexander Louis Espinal - Atmira
    @description: Método para asignar una tarea al proceso mientras no esté el trigger de tarea
    @exception: Exception e
    @throws: No se lanzan excepciones.
    */
    public static void asignarTareaPrincipal (List <SIREC__SIREC_obj_tarea__c> tareas, List <SIREC__SIREC_obj_proceso__c> procesos){
        
        for ( SIREC__SIREC_obj_tarea__c tarea : tareas) {
            for (SIREC__SIREC_obj_proceso__c proceso : procesos) {
                if (tarea.SIREC__SIREC_fld_proceso__c == proceso.id) {
                    proceso.SIREC__SIREC_fld_tarea__c = tarea.id;
                }
            }
        }
        update procesos;

    }


	public static List<SIREC__SIREC_obj_proceso__c> crearProceso(Integer n, Account cuenta, String rt){
        List<SIREC__SIREC_obj_proceso__c> lstProceso = new List<SIREC__SIREC_obj_proceso__c>();
        if (Schema.sObjectType.SIREC__SIREC_obj_proceso__c.isCreateable()) {
        for (Integer i = 0; i < n; i++) {
            lstProceso.add(new SIREC__SIREC_obj_proceso__c(
				RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(rt).getRecordTypeId(),
                Name = SIR_Constantes.PROCESO_NAME_REFINANCIACION,
                SIREC__SIREC_fld_estrategia__c = (rt == SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL) ? SIR_Constantes.PROCESO_ESTRATEGIA_PRESOL_E1 : SIR_Constantes.PROCESO_ESTRATEGIA_E1,
                SIREC__SIREC_fld_cliente__c    = cuenta.Id,
				SIREC__SIREC_fld_fechaInicio__c  = date.today(),
            	SIREC__SIREC_fld_fechaLimite__c  = date.today(),
            	SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                SIREC__SIREC_fld_masterRecordId__c = rt + i
			));
        }
		insert lstProceso;
        }
		return lstProceso;
    }
/*
	public static List<SIREC__SIREC_obj_proceso__c> crearProcesoEMP(Integer n, Account cuenta, String rt){
        List<SIREC__SIREC_obj_proceso__c> lstProceso = new List<SIREC__SIREC_obj_proceso__c>();
        if (Schema.sObjectType.SIREC__SIREC_obj_proceso__c.isCreateable()) {
        for (Integer i = 0; i < n; i++) {
            lstProceso.add(new SIREC__SIREC_obj_proceso__c(
				RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(rt).getRecordTypeId(),
                Name = SIR_Constantes.PROCESO_NAME_REFINANCIACION,
                SIREC__SIREC_fld_estrategia__c = (rt == SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL) ? SIR_Constantes.PROCESO_ESTRATEGIA_PRESOL_E1 : SIR_Constantes.PROCESO_ESTRATEGIA_E1,
                SIREC__SIREC_fld_cliente__c    = cuenta.Id,
				SIREC__SIREC_fld_fechaInicio__c  = date.today(),
            	SIREC__SIREC_fld_fechaLimite__c  = date.today(),
            	SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                SIREC__SIREC_fld_masterRecordId__c = rt + i,
				SIR_AccionActual__c = (rt == SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_FLUJO) ? true : null,
                SIREC__SIREC_fld_situacion__c =  SIR_Constantes.PROCESO_SITUACION_NO_LOCALIZADO
			));
        }
		insert lstProceso;
        }
		return lstProceso;
    }*/

    public static List<CBK_Notification__c> crearNotificaciones(Set<Id> setAccounts){
        List<CBK_Notification__c> lstNotificacion = new List<CBK_Notification__c>();
        if (Schema.sObjectType.SIREC__SIREC_obj_proceso__c.isCreateable()) {
        for (Id accountId : setAccounts) {
            lstNotificacion.add(new CBK_Notification__c(
				App__c = 'MCs Solution',
                Account__c = accountId,
                AlertType__c = 'banner'
			));
        }
		insert lstNotificacion;
        }
		return lstNotificacion;
    }

    public static List<CBK_Notification__c> crearNotificacionesEmp(Set<Id> setAccounts){
        List<CBK_Notification__c> lstNotificacion = new List<CBK_Notification__c>();
        if (Schema.sObjectType.SIREC__SIREC_obj_proceso__c.isCreateable()) {
        for (Id accountId : setAccounts) {
            lstNotificacion.add(new CBK_Notification__c(
				App__c = 'MCs Solution EMP',
                Account__c = accountId,	
                AlertType__c = 'banner'
			));
        }
		insert lstNotificacion;
        }
		return lstNotificacion;
    }

    public static Map<String,Object> createSirecRespone(String idActividad, String tipo, Integer idProceso, String situacion){
        Map<String, Object> sirecTarea = new Map<String, Object>();
        sirecTarea.put('idActividad',idActividad);
        sirecTarea.put('codigoAct','');
        sirecTarea.put('tipoDialogoDim',tipo);
        sirecTarea.put('descripcion','');
        sirecTarea.put('tipoVariable','');
        sirecTarea.put('fechaVencimiento','');
        sirecTarea.put('accessToken','');
        Map<String, String> mapDescripcion = new Map<String, String>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        List<Object> lstSeleccion = new List<Object>();
        lstSeleccion.add(mapDescripcion);
        mapDescripcion.put('idSeleccion', 'idSeleccion2');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu2');
        mapDescripcion.put('descripcionRes', 'respuestaUsu2');
        lstSeleccion.add(mapDescripcion);
        sirecTarea.put('seleccion', lstSeleccion);
        sirecTarea.put('idProceso', idProceso);
        sirecTarea.put('codigoProcesoSituacion', situacion);
        sirecTarea.put('fechaProcesoSituacion', '20/10/2022');
        return sirecTarea;
    }

    public static Map<String,Object> createSirecRespone(Integer codigo, String mensaje, string descripcion){
        
        Map<String, Object> mapRespuesta = new Map<String, Object>();
        Map<String, Object> mapInfo = new Map<String, Object>();
        mapInfo.put('codigo', codigo);
        mapInfo.put('mensaje', mensaje);
        mapInfo.put('descripcion', descripcion);
        mapRespuesta.put('info', mapInfo);
        return mapRespuesta;
    }

    public static Map<String,Object> createSirecErrorRespone(String codigo, String mensaje, string descripcion){
        
        Map<String, Object> mapRespuesta = new Map<String, Object>();
        Map<String, Object> mapError = new Map<String, Object>();
        mapError.put('codigo', codigo);
        mapError.put('mensaje', mensaje);
        mapError.put('descripcion', descripcion);
        mapRespuesta.put('error', mapError);
        return mapRespuesta;
    }
    
    public static Account crearOficinaIMAGIN(){
        Account account = New Account(Name = 'Oficina IMAGIN',
                                    AV_TipoCentroSuperior__c = 'OF',
                                    AV_TipoEstructura__c = '02',
                                    CC_Tipo_Centro__c = 'OF',
                                    CC_Numero_Oficina_Empresa__c = '001-05236',
                                    RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Centro CaixaBank').getRecordTypeId());     
        insert account;
        return account;
    }

    /*****************************************************************
        Proposito:  Creamos un registro Account recordtype Grupo Comercial
        Returns: Account                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         23/09/2021     	  Created   
    *****************************************************************/
	public static Account crearCuentaGrupoComercial(){  
        String recordTypeGC = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();   
        Account cuenta = new Account(
                Name = 'Grupo Comercial',
                RecordtypeId = recordTypeGC
			);
		insert cuenta;
		return cuenta;
	}

    /*****************************************************************
        Proposito:  Creamos un registro Account recordtype Grupo Economico
        Returns: Account                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         23/09/2021     	  Created   
    *****************************************************************/
	public static Account crearCuentaGrupoEconomico(){  
        String recordTypeGE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();      
        Account cuenta = new Account(
                Name = 'Grupo Comercial',
                RecordtypeId = recordTypeGE
			);
		insert cuenta;
		return cuenta;
	}

    /*****************************************************************
        Proposito:  Creamos un registro FinServ__ReciprocalRole__c
        Returns: Account                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         23/09/2021     	  Created   
    *****************************************************************/
	public static FinServ__ReciprocalRole__c crearReciprocalRole(){        
        FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(
            Name = 'Parent',
            FinServ__InverseRole__c = 'Cliente'
        );
        insert role;
		return role;
	}

    /*****************************************************************
        Proposito:  Creamos un registro FinServ__AccountAccountRelation__c
        Returns: Account                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US Id            Atmira         23/09/2021     	  Created   
    *****************************************************************/
	public static FinServ__AccountAccountRelation__c crearAccountAccountRelationGE(Account cuenta1, Account cuenta2, FinServ__ReciprocalRole__c rol){ 
        String recordTypeRelacionGE= Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();       
        FinServ__AccountAccountRelation__c relacion = new FinServ__AccountAccountRelation__c(
            RecordtypeId = recordTypeRelacionGE, 
            FinServ__Account__c = cuenta1.id,
            FinServ__RelatedAccount__c = cuenta2.id,
            FinServ__Role__c = rol.id
        );
        insert relacion;
		return relacion;
	}
            
    public with sharing class ProcesosTest {
        private String mrId;
        private String estrategia;
        private String tipoProceso;
        private Account cuenta;
        public procesosTest(String mrid, String estrategia, String tipoProceso, Account cuenta){
            this.mrId = mrid;
            this.estrategia = estrategia;
            this.tipoProceso = tipoProceso;
            this.cuenta = cuenta;
        }
        public String getMRID(){
            return this.mrId;
        }
        public String getEstrategia(){
            return this.estrategia;
        }
        public String getTipoProceso(){
            return this.tipoProceso;
        }
        public Account getCuenta(){
            return this.cuenta;
        }
    }

}