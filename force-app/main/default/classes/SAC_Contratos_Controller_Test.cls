@isTest
public class SAC_Contratos_Controller_Test {

    @testSetup
    static void test(){

        Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
        Account cliente = SAC_TestDataFactory.crearCuentas(1)[0];
        cliente.RecordTypeId = rtCliente;
        cliente.CC_Numperso__c = '2062121421';
        SAC_DatabaseDML.insertDML(cliente, false);
        //Database.insert(cliente);
        
        //Usuario con perfil SAC_General para ejecutar la acción
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);
		//Database.insert(usuarioGeneral);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Tarjeta');
        camposRecl.put('OwnerId', usuarioGeneral.id);
        camposRecl.put('AccountId', cliente.Id);
       
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, false);
        //Database.insert(reclamacion);
    	
        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'Integracion Tarjeta');
        camposPret.put('OwnerId', usuarioGeneral.id);
        camposPret.put('AccountId', cliente.Id);
        camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
        
        Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        SAC_DatabaseDML.insertDML(pretension, false);
        //Database.insert(pretension);
        
        CBK_IntegrationSetting__c csContrato = new CBK_IntegrationSetting__c();
        csContrato.Name = 'SAC_Contratos_Cliente';
        csContrato.NamedCredential__c = 'callout:API_GWT_PRO/partyReference/customers/commercialProducts';
        SAC_DatabaseDML.insertDML(csContrato, false);
        //Database.insert(csContrato);
        
        CBK_IntegrationSetting__c csDetalleContrato = new CBK_IntegrationSetting__c();
        csDetalleContrato.Name = 'SAC_Contratos_Detalle';
        csDetalleContrato.NamedCredential__c = 'callout:API_GWT_PRO/partyReference/customers/commercialProducts/{commercialProductId}?tenure=S';
        SAC_DatabaseDML.insertDML(csDetalleContrato, false);
        //Database.insert(csDetalleContrato);

        CBK_IntegrationSetting__c csTicket = new CBK_IntegrationSetting__c();
        csTicket.Name = 'SAC_Contratos_Ticket';
        csTicket.NamedCredential__c = 'callout:API_GWT_PRO/customerPosition/customers/tickets';
        SAC_DatabaseDML.insertDML(csTicket, false);
        //Database.insert(csTicket);

        CBK_IntegrationSetting__c csContract = new CBK_IntegrationSetting__c();
        csContract.Name = 'SAC_Contratos_Contrato';
        csContract.NamedCredential__c = 'callout:API_GWT_PRO/customerPosition/customers/tickets';
        SAC_DatabaseDML.insertDML(csContract, false);
        //Database.insert(csContract);

        SAC_ProductCase__c producto = new SAC_ProductCase__c();
        producto.SAC_Pretension__c = reclamacion.id;
        producto.SAC_Tipo__c = 'Seguros de Ahorro';
        producto.N_Contrato__c = '1231312313';
        producto.SAC_Descripcion__c = 'BK Seg.Ahorro';

        SAC_DatabaseDML.insertDML(producto, false);
        //Database.insert(producto);

    }
    
    @isTest
    static void obtenerContratosTest(){
    	
        Case pretension = [Select id, Account.CC_NumPerso__c from Case where Subject = 'Integracion Tarjeta' limit 1];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
                
        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        SAC_DatabaseDML.insertDML(psa, false);
        //Database.insert(psa);

        PermissionSet ps2 = [select id from PermissionSet where PermissionSet.Label ='SAC_Administrador'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = ps2.id, AssigneeId = usuario.id);
        SAC_DatabaseDML.insertDML(psa2, false);
        //Database.insert(psa2);
        
        System.runAs(usuario) {
        	SAC_Contratos_Controller.ResponseData response = SAC_Contratos_Controller.obtenerContratos(pretension.Id);
            
            system.assertEquals('200', response.statusCode, 'Comprobamos el estado de la petición.');
        	system.assertEquals('2062121421', response.customerId, 'Comprobamos el numperso del cliente.');
		}
    }
    @isTest
    static void showAllContractsTest(){
    	
        Case reclamacion = [Select id, Account.CC_NumPerso__c from Case where Subject = 'Integracion Tarjeta' limit 1];
        SAC_Contratos_Controller.ResponseDataProduct response;
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
                
        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        SAC_DatabaseDML.insertDML(psa, false);
        //Database.insert(psa);

        PermissionSet ps2 = [select id from PermissionSet where PermissionSet.Label ='SAC_Administrador'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = ps2.id, AssigneeId = usuario.id);
        SAC_DatabaseDML.insertDML(psa2, false);
        //Database.insert(psa2);
        
        System.runAs(usuario) {
            Test.startTest();
        	response = SAC_Contratos_Controller.showAllContracts(reclamacion.Id);
            Test.stopTest();
        }
            System.assertEquals('200', response.statusCode, 'Comprobamos el estado de la petición.');
        	System.assertEquals('2062121421', response.customerId, 'Comprobamos el numperso del cliente.');
    }
    
    @isTest
    static void obtenerContratosDetalleTest(){
    	
        Case pretension = [Select id, Account.CC_NumPerso__c from Case where Subject = 'Integracion Tarjeta' limit 1];
        String codProducto = '50046';
        SAC_Contratos_Controller.ResponseDataDetail response;
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
                
        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        SAC_DatabaseDML.insertDML(psa, false);
        //Database.insert(psa);

        PermissionSet ps2 = [select id from PermissionSet where PermissionSet.Label ='SAC_Administrador'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = ps2.id, AssigneeId = usuario.id);
        SAC_DatabaseDML.insertDML(psa2, false);
        //Database.insert(psa2);

		System.runAs(usuario) {
            Test.startTest();
        	response = SAC_Contratos_Controller.obtenerDetalleContrato(pretension.Account.CC_NumPerso__c, codProducto);
            Test.stopTest();
		}   
        system.assertEquals('200', response.statusCode, 'Comprobamos el estado de la petición.');
        system.assertEquals('Tarjeta crédito', response.description, 'Comprobamos la descripción del detalle.');
    }
	
    @isTest
    static void linkarContratoTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case pretension = [Select id from Case where Subject = 'Integracion Tarjeta' limit 1];

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        SAC_DatabaseDML.insertDML(psa, false);
        //Database.insert(psa);

        PermissionSet ps2 = [select id from PermissionSet where PermissionSet.Label ='SAC_Administrador'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = ps2.id, AssigneeId = usuario.id);
        SAC_DatabaseDML.insertDML(psa2, false);
        //Database.insert(psa2);
    	   
		System.runAs(usuario) { 
            Test.startTest();
            SAC_Contratos_Controller.linkarContrato(pretension.id, 'NameProductTest', '123151321315169', 'DescripcionProductTest', String.valueOf(system.today()), String.valueOf(system.today()));
            Test.stopTest();
		}   
        SAC_ProductCase__c producto = [SELECT SAC_Pretension__c, SAC_Tipo__c, N_Contrato__c, SAC_Descripcion__c FROM SAC_ProductCase__c WHERE  SAC_Tipo__c = 'NameProductTest'];
        system.assertEquals(pretension.Id , producto.SAC_Pretension__c, 'Comprobamos el id de la pretension.');
    }
    
}