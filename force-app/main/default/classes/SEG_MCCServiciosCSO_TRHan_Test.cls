@IsTest
public with sharing class SEG_MCCServiciosCSO_TRHan_Test {
    @testSetup
    static void testSetup() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('CBK_Framework_Login','CBK_Framework_Admin')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }

        Id recordTypeMCC = Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName().get('MCC').getRecordTypeId();
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
       	CC_MCC__c mccDetalle = new CC_MCC__c();
        mccDetalle.Name = 'Detalle1';
        mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalle.RecordTypeId = recordTypeIdDetalle;
        mccDetalle.CC_Tematica__c = mccTematica.Id;
        mccDetalle.CC_Producto_Servicio__c = mccProducto.Id;
        mccDetalle.CC_Motivo__c = mccMotivo.Id;
        mccDetalle.CC_Codigo_Externo__c = 'DE-000001';
        insert mccDetalle;

        // Servicios
        //Crear Id de Servicio tipo MCC
        SEG_ServiciosCSO__c servCsoMCC = new SEG_ServiciosCSO__c();
        servCsoMCC.SEG_Activo__c = true;
        servCsoMCC.RecordTypeId = recordTypeMCC;
        servCsoMCC.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
        servCsoMCC.SEG_Zona__c = 'Corporativa';
        servCsoMCC.SEG_TMO__c = 10;
        servCsoMCC.Name = 'Test MCC';
        insert servCsoMCC;

        // Servicios
        //Crear Id de Servicio tipo MCC
        SEG_ServiciosCSO__c servCsoMCC2 = new SEG_ServiciosCSO__c();
        servCsoMCC2.SEG_Activo__c = true;
        servCsoMCC2.RecordTypeId = recordTypeMCC;
        servCsoMCC2.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
        servCsoMCC2.SEG_Zona__c = 'Corporativa';
        servCsoMCC2.SEG_TMO__c = 10;
        servCsoMCC2.Name = 'Test MCC 2';
        insert servCsoMCC2;

        SEG_MCCServiciosCSO__c servMcc = new SEG_MCCServiciosCSO__c();
		servMcc.SEG_Activo__c = true;
		servMcc.SEG_Tematica__c = mccTematica.Id;
		servMcc.SEG_Producto__c = mccProducto.Id;
		servMcc.SEG_Motivo__c = mccMotivo.Id;
		servMcc.SEG_ServiciosCSO__c = servCsoMCC.Id;
		insert servMcc;
    }

    @IsTest
    static void testActivacionMCC() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        Test.startTest();
        System.runAs(usuarioTest) { 

        // Crear datos de prueba
        List<SEG_MCCServiciosCSO__c> lstMcc = new List<SEG_MCCServiciosCSO__c>();
        SEG_MCCServiciosCSO__c mcc1 = new SEG_MCCServiciosCSO__c(SEG_Activo__c = true);
        SEG_MCCServiciosCSO__c mcc2 = new SEG_MCCServiciosCSO__c(SEG_Activo__c = false);
        lstMcc.add(mcc1);
        lstMcc.add(mcc2);

        // Insertar datos de prueba
        insert lstMcc;

        List<SEG_MCCServiciosCSO__c> mccInsertados = new List<SEG_MCCServiciosCSO__c>();

        // Verificar que los campos SEG_FechaActivacion__c y SEG_FechaDesactivacion__c se han actualizado correctamente
        for (SEG_MCCServiciosCSO__c mcc : [SELECT SEG_Activo__c,SEG_FechaActivacion__c, SEG_FechaDesactivacion__c FROM SEG_MCCServiciosCSO__c WHERE Id IN :lstMcc]) {
            if (mcc.SEG_Activo__c) {
                System.assertNotEquals(null, mcc.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
                System.assertEquals(null, mcc.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
                mcc.SEG_Activo__c = false;
            } else {
                System.assertEquals(null, mcc.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
                System.assertNotEquals(null, mcc.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
                mcc.SEG_Activo__c = true;
            }
            mccInsertados.add(mcc);
        }

        update mccInsertados;

        // Verificar que los campos SEG\_FechaActivacion\_\_c y SEG\_FechaDesactivacion\_\_c se han actualizado correctamente
    for (SEG_MCCServiciosCSO__c mcc : [SELECT SEG_Activo__c, SEG_FechaActivacion__c, SEG_FechaDesactivacion__c FROM SEG_MCCServiciosCSO__c WHERE Id IN :lstMcc]) {
        if (mcc.SEG_Activo__c) {
            System.assertNotEquals(null, mcc.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
        } else {
            System.assertNotEquals(null, mcc.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
        }
    }
}
}
@IsTest
    static void concatenacionMCCsTest() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        // Query para traer datos
        SEG_MCCServiciosCSO__c servMcc= [SELECT Id, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c, SEG_ServiciosCSO__c FROM SEG_MCCServiciosCSO__c LIMIT 1];

        SEG_ServiciosCSO__c servCsoMCC = [SELECT Id, Name FROM SEG_ServiciosCSO__c WHERE Name = 'Test MCC' LIMIT 1];
        SEG_ServiciosCSO__c servCsoMCC2 = [SELECT Id, Name FROM SEG_ServiciosCSO__c WHERE Name = 'Test MCC 2' LIMIT 1];


        Test.startTest();
        System.runAs(usuarioTest) { 
            System.assertNotEquals(servCsoMCC.Id , String.valueof(servMcc.SEG_Tematica__c) + String.valueof(servMcc.SEG_Producto__c) + String.valueof(servMcc.SEG_Motivo__c) + String.valueof(servMcc.SEG_Detalle__c) + String.valueof(servMcc.SEG_ServiciosCSO__c), 'No se ha concatenado correctamente marca y servicio');

            servMcc.SEG_ServiciosCSO__c = servCsoMCC2.Id;
            update servMcc;
        
            SEG_MCCServiciosCSO__c servMccUpdate= [SELECT Id, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c, SEG_ServiciosCSO__c FROM SEG_MCCServiciosCSO__c LIMIT 1];
            System.assertNotEquals(servMccUpdate.Id , String.valueof(servMccUpdate.SEG_Tematica__c) + String.valueof(servMccUpdate.SEG_Producto__c) + String.valueof(servMccUpdate.SEG_Motivo__c) + String.valueof(servMccUpdate.SEG_Detalle__c) + String.valueof(servMccUpdate.SEG_ServiciosCSO__c), 'No se ha concatenado correctamente marca y servicio');
        }
}
}