/*****************************************************************
    Name: SIR_LCMP_ViewOnlineAgenciasExternas_Test
    Copyright © 2024 CaixaBank

    Proposito: Clase de test de SIR_LCMP_ViewOnlineAgenciasExternas                                                                                               
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         12/06/2024     	  Created    

*****************************************************************/
@isTest
public with sharing class SIR_LCMP_ViewOnlineAgenciasExternas_Test {
	/*****************************************************************
        Proposito: test1 sirve para llamar al ws de Agencias externas                                                     
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         12/06/2024   	  Created    
        
	*****************************************************************/
    @isTest
    public static void test1() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser', rol, 'System Administrator', 'U011111');
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();      
            cuenta.AV_NumPerso__c = '123456789';
            update cuenta;
                            
            Test.startTest();
            List<Object> listObject = SIR_LCMP_ViewOnlineAgenciasExternas.callWSAgenciasExternas(cuenta.ID, true);
            Test.stopTest();
            Assert.areEqual(cuenta.Id, cuenta.Id, 'Ha ocurrido algún error inesperado. En test1');
        }
    }
}