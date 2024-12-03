@IsTest
public class HDT_Agrupador_Controller_Test {
    
    @testSetup
    static void testSetup() {

        User usrToInsert = new User();
        usrToInsert.FirstName = 'Test';
        usrToInsert.LastName = 'User';
        usrToInsert.Email = 'pruebas@gmai.com';
        usrToInsert.Alias = 'tuser';
        usrToInsert.Username = 'pruebas@gmai.com';
        usrToInsert.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        usrToInsert.TimeZoneSidKey = 'America/Los_Angeles';
        usrToInsert.LocaleSidKey = 'en_US';
        usrToInsert.EmailEncodingKey = 'UTF-8';
        usrToInsert.LanguageLocaleKey = 'en_US';
        insert usrToInsert;

        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        //oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Usuario__c = usrToInsert.Id;
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Estado__c = 'Activo';
        insert oAgr;
        
        CC_PlantillaAsociada__c oTexto = new CC_PlantillaAsociada__c();
        oTexto.CC_Canal__c = 'Email';
        oTexto.CC_Idioma__c = 'es';
        oTexto.CC_Agrupador__c = oAgr.Id;
        oTexto.CC_CuerpoNotificacion__c = 'text';        
        insert oTexto;

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank'); 
        insert cuenta;        
        
        Id accountId = cuenta.Id;
        
        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = recordTypeEmpleado;
        insert contacto; 

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;

        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
    }
	
    @isTest
    static void datosAgrupador() {
        
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        CC_Agrupador__c oAgr = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Test'];
        
               
        Id cId = [SELECT Id FROM Contact WHERE FirstName = 'Contacto' LIMIT 1].Id;
        Id accounId = [SELECT Id FROM Account WHERE Name = 'Cuenta01' LIMIT 1].Id;
        
        Case oCaso = new Case();
        ocaso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.AccountId = accounId;
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        insert oCaso;

        Id mccTematicaId = [SELECT Id FROM CC_MCC__c WHERE Name = 'Ahorro a la vista'].Id;
        Id mccProductoId = [SELECT Id FROM CC_MCC__c WHERE Name = 'Cuenta corriente'].Id;
        Id mccMotivoId = [SELECT Id FROM CC_MCC__c WHERE Name = 'Apertura sin autorización'].Id;
        
        oCaso.CC_MCC_Tematica__c = mccTematicaId;
        oCaso.CC_MCC_ProdServ__c = mccProductoId;
        oCaso.CC_MCC_Motivo__c = mccMotivoId;
        update oCaso;
        
        Map<String,Object> oRes;

        Test.startTest();

        
            oRes = HDT_Agrupador_Controller.getAgrupadorCaso(String.valueOf(oCaso.Id));   
        System.assertNotEquals(oRes, null);
        
        String sRes = HDT_Agrupador_Controller.setAgrupadorCaso(String.valueOf(oCaso.Id), String.valueOf(oAgr.Id));
        
        System.assertEquals(sRes, '');
        
        String sResVal = HDT_Agrupador_Controller.validarCamposCaso(String.valueOf(oCaso.Id));
        
        System.assertEquals(sResVal, '');
        
        List<Id> agrupadores = new List<Id>();
        agrupadores.add(oAgr.Id);
        
        HDT_Agrupador_Controller.actualizarAgrupador(agrupadores);
        }
        Test.stopTest();
    }
    
    @isTest
    static void datosAgrupador_error_01() {
        
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            
        CC_Agrupador__c oAgr = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Test'];
        
        Id cId = [SELECT Id FROM Contact WHERE FirstName = 'Contacto' LIMIT 1].Id;
        
        Case oCaso = new Case();
        ocaso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert oCaso;
        
        
        
        Test.startTest();

       
            

		Map<String,Object> oRes = HDT_Agrupador_Controller.getAgrupadorCaso(String.valueOf(oCaso.Id));
        
        System.assertNotEquals(oRes, null);
        
        String sRes = HDT_Agrupador_Controller.setAgrupadorCaso(String.valueOf(oCaso.Id), String.valueOf(oAgr.Id));
        
        System.assertEquals(sRes, '');
        
        String sResVal = HDT_Agrupador_Controller.validarCamposCaso(String.valueOf(oCaso.Id));
        
        System.assertNotEquals(sResVal, '');
        
        Id mccTematicaId = [SELECT Id FROM CC_MCC__c WHERE Name = 'Ahorro a la vista'].Id;
        Id mccProductoId = [SELECT Id FROM CC_MCC__c WHERE Name = 'Cuenta corriente'].Id;
        Id mccMotivoId = [SELECT Id FROM CC_MCC__c WHERE Name = 'Apertura sin autorización'].Id;
        
        oCaso.CC_MCC_Tematica__c = mccTematicaId;
        oCaso.CC_MCC_ProdServ__c = mccProductoId;
        oCaso.CC_MCC_Motivo__c = mccMotivoId;
        
        oCaso.Status = 'Cerrado';
        update oCaso;
        
        String sResVal2 = HDT_Agrupador_Controller.validarCamposCaso(String.valueOf(oCaso.Id));
        
        System.assertNotEquals(sResVal2, '');
        
        List<CC_Agrupador__c> agrupadores = HDT_Agrupador_Controller.getAgrupadoresActivos();
        }

        
        Test.stopTest();
        
        

    }
    
}