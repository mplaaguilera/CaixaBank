/*****************************************************************
    Name: SIRE_LCMP_ReassignOwner_Test
    Copyright © 2023 CaixaBank

    Proposito: Clase test de la clase LWC SIRE_LCMP_ReassignOwner                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            Atmira           16/05/2023     Created    

*****************************************************************/
@isTest 
public class SIRE_LCMP_ReassignOwner_Test {    
    /*****************************************************************                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            Atmira           19/10/2023     Updated    
        
	*****************************************************************/    
    @IsTest
    static void reassignOwnerTest(){
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest',rol,'System Administrator', 'U0111111', '001-09999');

        System.runAs(usuario) {  
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);  
            ID recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            String valueIdOwner = [SELECT OwnerId from SIREC__SIREC_obj_proceso__c where Id = :proceso.Id].OwnerId;   

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
                SIRE_LCMP_ReassignOwner.getQueryRecordTypeProceso();            
                SIRE_LCMP_ReassignOwner.getOficinaGestorActual();            
                SIRE_LCMP_ReassignOwner.getOficinaString(cuenta.Id);            
                SIRE_LCMP_ReassignOwner.getOficinas(cuenta.Id);
                SIRE_LCMP_ReassignOwner.getEmployees(cuenta.Id);
                SIRE_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, valueIdOwner, cuenta.Id);
                SIRE_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, 'UserIntegracion', cuenta.Id);
                SIRE_LCMP_ReassignOwner.buscarProcesos(cuenta.Id, null , '1', '12', proceso.RecordTypeId, 'Todos', cuenta.Id);
                SIRE_LCMP_ReassignOwner.findRecords('mar', '001-03358');
                SIRE_LCMP_ReassignOwner.findRecords('mar', '');
                List<String> listaIds = new List<String>();
                listaIds.add(proceso.Id);
                String response = SIRE_LCMP_ReassignOwner.changeGestor(valueIdOwner, listaIds);  
            test.stopTest();

            System.assertEquals('OK', response, 'SIR_ReassignOwner_Test.test1 No se ha obtenido la respuesta OK');
        }       
    }  
}