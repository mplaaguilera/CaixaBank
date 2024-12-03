/*****************************************************************
 Name:  SIR_ReassignOwner_Test
 Copyright © 2022  CaixaBank

Proposito:   Clase test de la clase LWC SIR_LCMP_ReassignOwner                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US372106         Atmira         11/05/2022     	  Created    

*****************************************************************/
@isTest 
public class SIR_ReassignOwner_Test {    
    /*****************************************************************
        Proposito:  Metodo clase test                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US372106         Atmira         05/07/2021     	  Created    
        
	*****************************************************************/    
    @Istest static void test1(){
        
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest',rol,'System Administrator', 'U0111111', '001-09999');        
        System.runAs(usuario) {  
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);  
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            Map<String,Schema.RecordTypeInfo> mapRTsObjectsAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
            Id recordTypeCentro = mapRTsObjectsAccount.get('CC_CentroCaixaBank').getRecordTypeId(); 
            Account centro2 = new Account();
            centro2.RecordTypeId = recordTypeCentro;
            centro2.Name = 'Centro INTOUCH';
            centro2.CC_Numero_Empresa__c = '001';
            centro2.CC_Numero_Oficina__c = '09999';
            centro2.CC_Numero_Oficina_Empresa__c = '001-09999';            
            insert centro2;
            
            Account centro1 = new Account();
            centro1.RecordTypeId = recordTypeCentro;
            centro1.Name = 'D.A.N. Centro';
            centro1.CC_Numero_Empresa__c = '001';
            centro1.CC_Numero_Oficina__c = '09991';
            centro1.CC_Numero_Oficina_Empresa__c = '001-09991';
            centro1.AV_CentroSuperior__c = centro2.id;
            insert centro1;
            
            Contact contacto = new Contact(LastName='Test01',CC_NumPerso__c = '99999991', CC_Matricula__c='U0111111', AccountId= centro1.Id, AV_UsuarioAsociado__c= usuario.Id);
            insert contacto;
            test.startTest();
            SIR_LCMP_ReassignOwner.getOficinaGestorActual();
            SIR_LCMP_ReassignOwner.getOficinaString(cuenta.Id);
            SIR_LCMP_ReassignOwner.getOficinas('Oficina', 'siIntouch', 'noDan', cuenta.AV_CentroSuperior__c, cuenta.Id);
            SIR_LCMP_ReassignOwner.getEmployees(cuenta.Id, false, centro1.CC_Numero_Oficina_Empresa__c);
            SIR_LCMP_ReassignOwner.getEmployees(cuenta.Id, true, centro1.CC_Numero_Oficina_Empresa__c);
            SIR_LCMP_ReassignOwner.getQueryRecordTypeProceso();
            SIR_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, usuario.Id, cuenta.Id, true);
            SIR_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, 'UserIntegracion', cuenta.Id, true);
            SIR_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, 'Todos', cuenta.Id, true);
            SIR_LCMP_ReassignOwner.findRecords('mar', '001-03358');
            SIR_LCMP_ReassignOwner.findRecords('mar', '');
            List<String> listaIds = new List<String>();
            listaIds.add(proceso.Id);
            String response;
            
            response = SIR_LCMP_ReassignOwner.changeGestor(usuario.Id, listaIds);  
            test.stopTest();
            System.assertEquals('OK', response, 'SIR_ReassignOwner_Test.test1 No se ha obtenido la respuesta OK');
            System.assertEquals(usuario.Id, [SELECT OwnerId from SIREC__SIREC_obj_proceso__c where Id = :proceso.Id].OwnerId, 'SIR_ReassignOwner_Test.test1 no se ha asignado el usuario correctamente');
        }
           
   }
       /*****************************************************************
        Proposito:  Metodo clase test                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US372106         Atmira         05/07/2022     	  Created    
        
	*****************************************************************/    
   @Istest static void test2(){
             
       UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
       insert rol;
       User usuario = SIR_TestDataFactory.createTestUser('usuarioTest',rol,'System Administrator', 'U0111111', '001-09999', 'Gestor');        
       System.runAs(usuario) {  
           Account cuenta = SIR_TestDataFactory.crearCuenta();
           SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta); 
           
           ID recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
           Account centro2 = new Account();
           centro2.RecordTypeId = recordTypeCentro;
           centro2.Name = 'Centro 2';
           centro2.CC_Numero_Empresa__c = '001';
           centro2.CC_Numero_Oficina__c = '09999';
           centro2.CC_Numero_Oficina_Empresa__c = '001-09999';            
           insert centro2;
           
           Account centro1 = new Account();
           centro1.RecordTypeId = recordTypeCentro;
           centro1.Name = 'D.A.N. Centro';
           centro1.CC_Numero_Empresa__c = '001';
           centro1.CC_Numero_Oficina__c = '09991';
           centro1.CC_Numero_Oficina_Empresa__c = '001-09991';
           centro1.AV_CentroSuperior__c = centro2.id;
           insert centro1;           
           Contact contacto = new Contact(LastName='Test01',CC_NumPerso__c = '99999991', CC_Matricula__c='U0111111', AccountId= centro1.Id, AV_UsuarioAsociado__c= usuario.Id);
           insert contacto;          
           String response;
           test.startTest();
           SIR_LCMP_ReassignOwner.getOficinaGestorActual();
           SIR_LCMP_ReassignOwner.getOficinaString(cuenta.Id);
           SIR_LCMP_ReassignOwner.getOficinas('Oficina', 'noIntouch', 'noDan', centro1.AV_CentroSuperior__c, centro1.Id);
           SIR_LCMP_ReassignOwner.getEmployees(centro1.Id, false, centro1.CC_Numero_Oficina_Empresa__c); 
           SIR_LCMP_ReassignOwner.getEmployees(centro1.Id, true, centro1.CC_Numero_Oficina_Empresa__c); 
           SIR_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, usuario.Id, centro1.Id, true ); 
           SIR_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, 'UserIntegracion', centro1.Id, false );
           SIR_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, 'Todos', centro1.Id,false );
            List<String> listaIds = new List<String>();
            listaIds.add(proceso.Id);
            response = SIR_LCMP_ReassignOwner.changeGestor(usuario.Id, listaIds);       
            test.stopTest(); 
            System.assertEquals('OK', response, 'SIR_ReassignOwner_Test.test2 No se ha obtenido la respuesta OK');
            System.assertEquals(usuario.Id, [SELECT OwnerId from SIREC__SIREC_obj_proceso__c where Id = :proceso.Id].OwnerId,'SIR_ReassignOwner_Test.test2 No se ha asignado el usuario correctamente');
        }   
   }
 
    
    /*****************************************************************
        Proposito:  Metodo clase test                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US372106         Atmira         05/07/2022     	  Created    
        
	*****************************************************************/    
   @Istest static void test3(){        
       
       UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
       insert rol;
       User usuario = SIR_TestDataFactory.createTestUser('usuarioTest',rol,'System Administrator', 'U0111111', '001-09999', 'DAN');        
       System.runAs(usuario) {  
           Account cuenta = SIR_TestDataFactory.crearCuenta();
           SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta); 
           
           ID recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
           Account centro2 = new Account();
           centro2.RecordTypeId = recordTypeCentro;
           centro2.Name = 'Centro 2';
           centro2.CC_Numero_Empresa__c = '001';
           centro2.CC_Numero_Oficina__c = '09999';
           centro2.CC_Numero_Oficina_Empresa__c = '001-09999';            
           insert centro2;
           
           Account centro1 = new Account();
           centro1.RecordTypeId = recordTypeCentro;
           centro1.Name = 'D.A.N. Centro';
           centro1.CC_Numero_Empresa__c = '001';
           centro1.CC_Numero_Oficina__c = '09991';
           centro1.CC_Numero_Oficina_Empresa__c = '001-09991';
           centro1.AV_CentroSuperior__c = centro2.id;
           insert centro1;           
           Contact contacto = new Contact(LastName='Test01',CC_NumPerso__c = '99999991', CC_Matricula__c='U0111111', AccountId= centro1.Id, AV_UsuarioAsociado__c= usuario.Id);
           insert contacto;          
           String response;
           test.startTest();
           SIR_LCMP_ReassignOwner.getOficinaGestorActual();
           SIR_LCMP_ReassignOwner.getOficinaString(cuenta.Id);
           SIR_LCMP_ReassignOwner.getOficinas('Oficina', 'noIntouch', 'siDan', centro1.AV_CentroSuperior__c, centro1.Id);
           SIR_LCMP_ReassignOwner.getEmployees(centro1.Id, false, centro1.CC_Numero_Oficina_Empresa__c); 
           SIR_LCMP_ReassignOwner.getEmployees(centro1.Id, true, centro1.CC_Numero_Oficina_Empresa__c); 
           SIR_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, usuario.Id, centro1.Id, false ); 
           SIR_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, 'UserIntegracion', centro1.Id, false );
           SIR_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, 'Todos', centro1.Id, false );
            List<String> listaIds = new List<String>();
            listaIds.add(proceso.Id);
            response = SIR_LCMP_ReassignOwner.changeGestor(usuario.Id, listaIds);       
            test.stopTest(); 
            System.assertEquals('OK', response, 'SIR_ReassignOwner_Test.test2 No se ha obtenido la respuesta OK');
            System.assertEquals(usuario.Id, [SELECT OwnerId from SIREC__SIREC_obj_proceso__c where Id = :proceso.Id].OwnerId,'SIR_ReassignOwner_Test.test2 No se ha asignado el usuario correctamente');
        }   
   }     
  
}