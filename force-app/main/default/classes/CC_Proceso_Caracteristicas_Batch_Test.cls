@istest
public class CC_Proceso_Caracteristicas_Batch_Test {
	@istest
    public static void test() {
        Id clienteCuentaRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(); 
        Id clienteContactoRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(); 
		//CONTACTO
        Id clienteContactoCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente_Contacto').getRecordTypeId(); 
        CC_Caracteristica__c caracteristicaClienteContacto = new CC_Caracteristica__c(
            RecordTypeId = clienteContactoCaracteristicaRecordTypeId,
            Name = 'Caracteristica Cliente Contacto',
            CC_Fecha_vigencia_inicio__c = Datetime.now(),
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'test'
        );
        insert caracteristicaClienteContacto;

        Account cuenta = new Account(
        	RecordTypeId = clienteCuentaRecordTypeId,
            Name = 'Cuenta Cliente',
            CC_Numero_Documento__c = '44445555X'
        );
        insert cuenta;

        Contact contactocli = new Contact(
            RecordTypeId = clienteContactoRecordTypeId,
            LastName = 'apellido',
            AccountId = cuenta.Id,
            CC_Idioma__c = 'es',
            CC_Numero_Documento__c = '44445555X'
        );
        insert contactocli;
        
        CC_Caracteristica_Detalle__c detallecontactocliente = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristicaClienteContacto.Id,
            CC_Identificador__c = '44445555X'
        );
        insert detallecontactocliente;
		
        //ACCOUNT
        Id clienteCuentaCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente_Cuenta').getRecordTypeId(); 
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Cliente_Cuenta Test',
            RecordTypeId = clienteCuentaCaracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica;

        Account cuenta1 = new Account(
        	RecordTypeId = clienteCuentaRecordTypeId,
            Name = 'Cuenta Cliente Test 1',
            CC_Numero_Documento__c = '88992528P'
        );
        insert cuenta1;
        
		CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica.Id,
            CC_Identificador__c = '88992528P'
        );
        insert detalle;
        
        //OFICINA
        Id centroCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Centro_CaixaBank').getRecordTypeId(); 
        Id centroRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId(); 
        CC_Caracteristica__c caracteristica1 = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Centro_CaixaBank Test',
            RecordTypeId = centroCaracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica1;

        Account cuenta2 = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta Centro CaixaBank Test 1',
            CC_Numero_Oficina_Empresa__c = '11111-001'
        );
        insert cuenta2;
            
		CC_Caracteristica_Detalle__c detalle1 = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica1.Id,
            CC_Identificador__c = '11111-001'
        );
        insert detalle1;
        
        CC_Caracteristica__c caracteristicaCentro = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Centro_CaixaBank Test',
            RecordTypeId = centroCaracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristicaCentro;
        
        Account cuentaCentro = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta Centro CaixaBank Test 1',
            CC_Numero_Oficina_Empresa__c = '11112-001'
        );
        insert cuentaCentro;
            
		CC_Caracteristica_Detalle__c detalleCentro = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristicaCentro.Id,
            CC_Identificador__c = '11112-001'
        );
        insert detalleCentro;
        
        //ACCOUNT
        Id clienteRecordTypePAId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        CC_Caracteristica__c caracteristicaCli = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Cliente_Cuenta Test',
            RecordTypeId = clienteCuentaCaracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristicaCli;

        Account cuentaCli = new Account(
        	RecordTypeId = clienteRecordTypePAId,
            FirstName = 'Cuenta',
            LastName = 'Cliente Test 1',
            CC_Numero_Documento__c = '93792708L'
        );
        insert cuentaCli;
        
		CC_Caracteristica_Detalle__c detalleCli = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristicaCli.Id,
            CC_Identificador__c = '93792708L'
        );
        insert detalleCli;

        //EMPLEADO
        Id empleadoCaracteristicaContactRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id empleadoRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId(); 
        CC_Caracteristica__c caracteristicaCont = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Empleado Test',
            RecordTypeId = empleadoCaracteristicaContactRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristicaCont;

        Account cuenta3 = new Account(
        	RecordTypeId = clienteCuentaRecordTypeId,
            Name = 'Cuenta Cliente Test 1',
            CC_Numero_Documento__c = '80726321R'
        );
        insert cuenta3;
        
        Contact empleado2 = new Contact(
            RecordTypeId = empleadoRecordTypeId,
            LastName = 'apellido',
            AccountId = cuenta3.Id,
            CC_Idioma__c = 'es',
            CC_Matricula__c = 'U0193932'
        );
        insert empleado2;
        
		CC_Caracteristica_Detalle__c detalleEmpl = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristicaCont.Id,
            CC_Identificador__c = 'U0193932'
        );
        insert detalleEmpl;
        
        Test.StartTest();
        CC_Proceso_Caracteristicas_Batch batch = new CC_Proceso_Caracteristicas_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
    }
}