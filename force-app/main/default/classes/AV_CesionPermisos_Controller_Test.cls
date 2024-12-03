/********************************************************************************************************************
 Name:	  AV_CesionPermisos_Controller_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
 Proposito: AV_CesionPermisos_Controller Test class
-----------------------------------------------------------------------------------------------------------------------
 Historial
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 VERSION		USER_STORY			AUTHOR				DATE			Description
 1.0			US428379    		Luis Fernandez		04/10/2022		Init version
 1.1            US486147            Patricia Solano     07/02/2023      Modified method to validate quality clouds
 1.4								Vladislav Lityagin  10/03/2023	    Fixed Quality Clouds errors
 1.5            Fix                 Patricia Villacañas 16/05/2023      Modified to set run as
 *********************************************************************************************************************/
@isTest
public with sharing class AV_CesionPermisos_Controller_Test {
    @TestSetup
    static void setup(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545400', 'AV_SistematicaComercial');
        userGestor.Alias = 'gest';
        userGestor.Email = 'gestor-test@test.com';
        userGestor.IsActive = true;
        insert userGestor;

        System.runAs(userGcf){
            User cedente = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank',null,'AV_SistematicaComercial');
            Account centro = AV_TestHelper.createCaixaCenter();
            Contact cedenteContact = AV_TestHelper.createEmployee(centro,cedente);
            User cedido = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','99999','AV_SistematicaComercial');
            cedido.Alias = 'cedido';
            cedido.LastName = 'cedidoSurname';
            cedido.AV_NumeroOficinaEmpresa__c = '001-9999';
            List<Database.SaveResult> ids = Database.insert(new List<User>{cedente,cedido});
            Id cedenteId = ids[0].getId();
            Id cedidoId = ids[1].getId();
            Account centroCedido = AV_TestHelper.createCaixaCenterSinInsert();
            centroCedido.Name = 'office';
            centroCedido.CC_Numero_Oficina_Empresa__c = '09615';
            centroCedido.CC_Numero_Oficina__c = '09615';   
            insert centroCedido;
            Contact cedidoContact = AV_TestHelper.createEmployee(centroCedido,cedido);
            Map<String,String> jsonPermisos = new Map<String,String>();
            jsonPermisos.put('Cedente',cedenteId);
            jsonPermisos.put('Inicio','22/10/2022');
            jsonPermisos.put('Final',System.today().format());
            AV_CesionPermisos_Controller.givePermission(jsonPermisos,new List<String>{cedidoId});
        }
    }

    @isTest
    public static void setLabelTest(){
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
       Test.startTest();
       System.runAs(userGestor){
           String label =  AV_CesionPermisos_Controller.setLabel();
           Test.stopTest();
           System.assert(label.equals('Permisos'));
       }
    }

    @isTest 
    public static void searchEmployeesTest(){
        Test.startTest();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            Contact retrieveCedido = [SELECT ID,AV_UsuarioAsociado__c FROM CONTACT Where AV_UsuarioAsociado__r.Alias = 'cedido' LIMIT 1 ];        
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = retrieveCedido.AV_UsuarioAsociado__c;
            Test.setFixedSearchResults(fixedSearchResults);
            List<AV_LookupSearchResult> result =  AV_CesionPermisos_Controller.searchEmployees(fixedSearchResults[0]);
            Test.stopTest();
            System.assert(!result.isEmpty());
        }

    }

    @isTest 
    public static void actualizarPermisoTest(){
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
        System.runAs(userGestor){
            Test.startTest();
            AV_OfficePermission__c permisoToUpdt= [SELECT Id FROM AV_OfficePermission__c  LIMIT 1];
            Map<String,String> testUpdtMap = new Map<String,String>();
            testUpdtMap.put('Id',permisoToUpdt.Id);
            String initDateToUpdt = '23/10/2022';
            String finishDateToUpdt = '09/12/2022';
            testUpdtMap.put('Inicio',initDateToUpdt);
            testUpdtMap.put('Final',finishDateToUpdt);
            AV_CesionPermisos_Controller.actualizarPermiso(testUpdtMap);
            AV_OfficePermission__c permisoToPostUpdt= [SELECT AV_InicioPermiso__c,AV_FinalPermiso__c FROM AV_OfficePermission__c  LIMIT 1];
            Test.stopTest();
            System.assertEquals(permisoToPostUpdt.AV_InicioPermiso__c,Date.parse(initDateToUpdt),'');
            System.assertEquals(permisoToPostUpdt.AV_FinalPermiso__c,Date.parse(finishDateToUpdt),'');
        }
    }

    @isTest
    public static void checkForPermissionGivenToMeTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            Test.startTest();
            Contact cntToLookUp = [SELECT AV_UsuarioAsociado__c FROM CONTACT Where AV_UsuarioAsociado__r.Alias = 'cedido' LIMIT 1 ];
            List<AV_OfficePermission__c> retrievedPerms = AV_CesionPermisos_Controller.checkForPermissionGivenToMe(cntToLookUp.AV_UsuarioAsociado__c);
            Test.stopTest();
            System.assert(!retrievedPerms.isEmpty());
        }
    }
    
    @isTest
    public static void deletePermisoTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            Test.startTest();
            AV_OfficePermission__c permisoToDelete= [SELECT Id FROM AV_OfficePermission__c LIMIT 1];
            AV_CesionPermisos_Controller.deletePermiso(permisoToDelete.Id);
            List<AV_OfficePermission__c> emptyList = [SELECT Id FROM AV_OfficePermission__c];
            Test.stopTest();
            System.assert(emptyList.isEmpty());
        }
    }
}