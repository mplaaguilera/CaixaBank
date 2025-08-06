@isTest(SeeAllData=true)
//Se usa el seeAllData porque el objeto Survey no se puede crear/editar en un test
public class OS_Encuesta_Test {

    public static Id mccProductoServicioRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
    public static Id mccMotivoRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
    public static Id ccMCCTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
    public static Id recordTypeIdAccountCentroCaixaBank = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId(); 
    public static Id recordTypeIdContactCCEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
    public static Id recordTypeIdCaseOSEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

    @isTest
    static void enviarEncuesta() {      
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = recordTypeIdAccountCentroCaixaBank;
        insert cuenta;

        Contact contacto = new Contact();
        contacto.LastName = 'Test contacto';
        contacto.Email = 'test@test.es';
        contacto.RecordTypeId = recordTypeIdContactCCEmpleado;
        contacto.AccountId = cuenta.Id;
        insert contacto;

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = ccMCCTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001' + String.valueOf(System.now()).left(3); //añadimos variable de tiempo porque con el see all data el ExternalId puede estar repetido
        mccTematica.OS_No_Enviar_Encuestas__c = false;
		insert mccTematica;

        Id recordTypeIdProducto = mccProductoServicioRecordTypeId;
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'MCC Producto';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'+ String.valueOf(System.now()).left(3); //añadimos variable de tiempo porque con el see all data el ExternalId puede estar repetido
        mccProducto.OS_No_Enviar_Encuestas__c = false;
        insert mccProducto; 
        
        Id recordTypeIdMotivo = mccMotivoRecordTypeId;
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'MCCMotivo';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001' + + String.valueOf(System.now()).left(3); //añadimos variable de tiempo porque con el see all data el ExternalId puede estar repetido
        mccMotivo.OS_No_Enviar_Encuestas__c = false;
        insert mccMotivo;
        
        Case caso = new Case();
        caso.Subject = 'Caso de prueba';
        caso.CC_Idioma__c = 'es';
        caso.recordtypeId = recordTypeIdCaseOSEmpleado;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        //caso.CC_Tipo_Contacto__c = 'Formación';
        caso.Status = 'Activo';
        caso.ContactId = contacto.Id;
        caso.AccountId = cuenta.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id ;
        caso.CC_Buzon_Salida__c = 'buzon.servicedesk.devcops5@gmail.com';
        insert caso;

        EmailTemplate plantilla = new EmailTemplate();
        plantilla.FolderId = UserInfo.getUserId();
        plantilla.Name = 'OS Encuesta Offline';
        plantilla.DeveloperName = 'OS_Encuesta_Offline';
        plantilla.TemplateType = 'Text';
        plantilla.isactive = true;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert plantilla;
        }

        Test.startTest();
        List<Id> lista = new List<Id>();
        lista.add(caso.Id);
        OS_Encuesta.enviarEncuesta(lista);
        Test.stopTest();

        String nombre = 'Encuesta para el caso ' + [SELECT CaseNumber FROM Case WHERE Id = :caso.Id].CaseNumber;
        Case elCasoCreado = [SELECT Id, CC_Admin__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(true, elCasoCreado.CC_Admin__c);
        System.assertEquals(nombre, [SELECT Name FROM SurveyInvitation WHERE Name = :nombre].Name);
    }

    @isTest
    static void enviarEncuesta2() { 
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente2';
        cuenta.RecordTypeId = recordTypeIdAccountCentroCaixaBank;
        insert cuenta;

        Contact contacto = new Contact();
        contacto.LastName = 'Test contacto2';
        contacto.Email = 'testoliver@test.es';
        contacto.RecordTypeId = recordTypeIdContactCCEmpleado;
        contacto.AccountId = cuenta.Id;
        insert contacto;

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = ccMCCTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001' + String.valueOf(System.now()).left(3); //añadimos variable de tiempo porque con el see all data el ExternalId puede estar repetido
        mccTematica.OS_No_Enviar_Encuestas__c = false;
		insert mccTematica;

        Id recordTypeIdProducto = mccProductoServicioRecordTypeId;
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'MCC Producto';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'+ String.valueOf(System.now()).left(3); //añadimos variable de tiempo porque con el see all data el ExternalId puede estar repetido
        mccProducto.OS_No_Enviar_Encuestas__c = false;
        insert mccProducto; 
        
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'MCCMotivo';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = mccMotivoRecordTypeId;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001' + + String.valueOf(System.now()).left(3); //añadimos variable de tiempo porque con el see all data el ExternalId puede estar repetido
        mccMotivo.OS_No_Enviar_Encuestas__c = false;
        insert mccMotivo;

        Case caso2 = new Case();
        caso2.Subject = 'Caso de prueba2';
        caso2.CC_Idioma__c = 'es';
        caso2.recordtypeId = recordTypeIdCaseOSEmpleado;
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        //caso.CC_Tipo_Contacto__c = 'Formación';
        caso2.Status = 'Activo';
        caso2.ContactId = contacto.Id;
        caso2.AccountId = cuenta.Id;
        caso2.CC_Tematica__c = 'UAC ExportOnline';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.EntitlementID = null;
        //caso2.CC_Buzon_Salida__c = 'buzon.servicedesk.devcops2@gmail.com';
        insert caso2;

        EmailTemplate plantilla = new EmailTemplate();
        plantilla.FolderId = UserInfo.getUserId();
        plantilla.Name = 'OS Encuesta Offline';
        plantilla.DeveloperName = 'OS_Encuesta_Offline';
        plantilla.TemplateType = 'Text';
        plantilla.isactive = true;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert plantilla;
        }

        Test.startTest();

        List<Id> idCasos = new List<Id>();
        idCasos.add(caso2.Id);
        OS_Encuesta.enviarEncuesta(idCasos);
        Test.stopTest();

        String nombre2 = 'Encuesta para el caso ' + [SELECT CaseNumber FROM Case WHERE Id = :caso2.Id].CaseNumber;
        Case elCasoCreado2 = [SELECT Id, CC_Admin__c, CC_URL_Encuesta_3N__c FROM Case WHERE Id = :caso2.Id];
        
        SurveyInvitation invitacionCreada = [SELECT Name, InvitationLink FROM SurveyInvitation WHERE Name = :nombre2 LIMIT 1];
        System.assertEquals(nombre2, invitacionCreada.Name);
        System.assertEquals(invitacionCreada.InvitationLink, elCasoCreado2.CC_URL_Encuesta_3N__c);
        //System.assertEquals(true, elCasoCreado2.CC_Admin__c);
    }
}