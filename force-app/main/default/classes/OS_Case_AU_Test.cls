@isTest
public class OS_Case_AU_Test {
    @TestSetup
    public static void cargaDeDatos() {
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Empleado');

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.OS_No_Enviar_Encuestas__c = false;
        insert mccTematica;

        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        mccProducto.OS_No_Enviar_Encuestas__c = false;
        insert mccProducto;

        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccMotivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        mccMotivo.OS_No_Enviar_Encuestas__c = false;
        insert mccMotivo;

        CC_MCC__c mccTematica2 = new CC_MCC__c();
        mccTematica2.Name = 'Segmentos';
        mccTematica2.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        mccTematica2.OS_No_Enviar_Encuestas__c = false;
        insert mccTematica2;

        CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Confirming';
        mccProducto2.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002';
        mccProducto2.OS_No_Enviar_Encuestas__c = false;
        insert mccProducto2;

        CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Gestión UAFE';
        mccMotivo2.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccMotivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.OS_No_Enviar_Encuestas__c = false;
        insert mccMotivo2;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u1 = new User();
        u1.Alias = 'tsAlias';
        u1.Email = 'testdevdev@test.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'testLastName';
        u1.LanguageLocaleKey = 'es';
        u1.LocaleSidKey = 'es';
        u1.TimeZoneSidKey = 'Europe/Berlin';
        u1.ProfileId = p.Id;
        u1.UserName = 'testdevdev@test.com.dev';
        insert u1;

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.OwnerId = u1.Id;
        insert cuenta;

        Contact contacto = new Contact();
        contacto.LastName = 'Test contacto';
        contacto.Email = 'test@test.es';
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Case caso1 = new Case();
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Prueba Test';
        caso1.Status = 'Activo';
        caso1.CC_Idioma__c = 'es';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso1.CC_Tematica__c = 'PRUEBA1';
        caso1.CC_Buzon_Salida__c = 'serviciofirma.devcops@gmail.com';
        caso1.CC_Cola_Procedencia__c = 'OS_Servicio_Firma';
        caso1.OS_Departamento__c = 'GESTORIAS';
        caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;
        caso1.AccountId = cuenta.Id;
        caso1.ContactId = contacto.Id;
        caso1.CC_Oficina__c = cuenta.Id;
        caso1.OwnerId = u1.Id;
        caso1.OS_GrupoTrabajo__c = 'Servicio Firma COPS';
        caso1.OS_Alerta_Fecha__c = System.now();
        insert caso1;
    }

    @isTest
    public static void reasignacionDelCaso() {
        User usuario =  [SELECT Id FROM User WHERE Email = 'testdevdev@test.com' LIMIT 1] ; 
        System.runAs (usuario) {
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Prueba Test'];
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Empleado');
            Profile p = [SELECT Id FROM Profile WHERE Name = 'OS_Responsable'];
            User u2 = new User();
            u2.Alias = 'tsAlias2';
            u2.Email = 'testdevdev2@test.com';
            u2.EmailEncodingKey = 'UTF-8';
            u2.LastName = 'testLastName2';
            u2.LanguageLocaleKey = 'es';
            u2.LocaleSidKey = 'es';
            u2.TimeZoneSidKey = 'Europe/Berlin';
            u2.ProfileId = p.Id;
            u2.UserName = 'testdevdev2@test.com.dev';
            insert u2;

            Test.startTest();
            caso.OwnerId = u2.Id;
            update caso;
            Test.stopTest();

            Case elCasoCreado = [SELECT CC_Ultima_Interaccion__c, CC_Fecha_Ultima_Interaccion__c, OwnerId FROM Case WHERE Id = :caso.Id];
            System.assertEquals('Reasignación del caso', elCasoCreado.CC_Ultima_Interaccion__c);
            //System.assertEquals(System.now(), elCasoCreado.CC_Fecha_Ultima_Interaccion__c);
        }
    }

    @isTest
    public static void eliminarSituacion() {
        User usuario =  [SELECT Id FROM User WHERE Email = 'testdevdev@test.com' LIMIT 1] ; 
        System.runAs (usuario) {
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Prueba Test'];

            Test.startTest();
            caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
            caso.OS_Eliminar_Situacion__c = true;
            update caso;
            Test.stopTest();

            Case elCasoCreado = [SELECT CC_Ultima_Interaccion__c, OS_Eliminar_Situacion__c, CC_Fecha_Ultima_Interaccion__c FROM Case WHERE Id = :caso.Id];
            System.assertEquals('Nuevo', elCasoCreado.CC_Ultima_Interaccion__c);
            System.assertEquals(false, elCasoCreado.OS_Eliminar_Situacion__c);
            //System.assertEquals(System.now(), elCasoCreado.CC_Fecha_Ultima_Interaccion__c);
        }
    }

    @isTest
    public static void avisoPropietarioNuevoCorreo() {
        User usuario =  [SELECT Id FROM User WHERE Email = 'testdevdev@test.com' LIMIT 1] ; 
        System.runAs (usuario) {
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Prueba Test'];

            Test.startTest();
            caso.OS_Aviso_Propietario__c = true;
            update caso;
            Test.stopTest();

            Case elCasoCreado = [SELECT OS_Aviso_Propietario__c FROM Case WHERE Id = :caso.Id];
            System.assertEquals(false, elCasoCreado.OS_Aviso_Propietario__c);
        }
    }

    @isTest
    public static void envioCorreoTrasladoRemitidoAutomatico() {
        User usuario =  [SELECT Id FROM User WHERE Email = 'testdevdev@test.com' LIMIT 1] ; 
        System.runAs (usuario) {
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Prueba Test'];

            CC_MCC__c mccTematica2 = new CC_MCC__c();
            mccTematica2.Name = 'MCC Tematica Oliver';
            mccTematica2.CC_Tipo_Cliente__c = 'Empleado';
            mccTematica2.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccTematica2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mccTematica2.CC_Codigo_Externo__c = 'TE-000003';
            mccTematica2.OS_No_Enviar_Encuestas__c = false;
            insert mccTematica2;
    
            CC_MCC__c mccProducto2 = new CC_MCC__c();
            mccProducto2.Name = 'Cuenta corriente Oliver';
            mccProducto2.CC_Tipo_Cliente__c = 'Empleado';
            mccProducto2.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccProducto2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            mccProducto2.CC_Tematica__c = mccTematica2.Id;
            mccProducto2.CC_Codigo_Externo__c = 'PR-000003';
            mccProducto2.OS_No_Enviar_Encuestas__c = false;
            insert mccProducto2;
    
            CC_MCC__c mccMotivo2 = new CC_MCC__c();
            mccMotivo2.Name = 'Apertura sin autorización Oliver';
            mccMotivo2.CC_Tipo_Cliente__c = 'Empleado';
            mccMotivo2.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccMotivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mccMotivo2.CC_Codigo_Externo__c = 'MO-000003';
            mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
            mccMotivo2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            mccMotivo2.OS_No_Enviar_Encuestas__c = false;
            mccMotivo2.CBK_Traslado_Remitido__c = 'Traslado';
            insert mccMotivo2;

            Test.startTest();
            caso.CC_MCC_Tematica__c = mccTematica2.Id;
            caso.CC_MCC_ProdServ__c = mccProducto2.Id;
            caso.CC_MCC_Motivo__c = mccMotivo2.Id;
            update caso;
            Test.stopTest();

            Case elCasoCreado = [SELECT CC_MCC_Motivo__c FROM Case WHERE Id = :caso.Id];
            System.assertEquals(mccMotivo2.Id, elCasoCreado.CC_MCC_Motivo__c);
        }
    }
    
    @isTest
    public static void casoRelacionadoSegCierre() {
        User usuario =  [SELECT Id FROM User WHERE Email = 'testdevdev@test.com' LIMIT 1] ; 
        System.runAs (usuario) {

            Case caso1 = [SELECT Id, SEG_Id_Related_Mail__c FROM Case WHERE Subject ='Prueba Test' LIMIT 1];
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'MCC Tematica';
            mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccTematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mccTematica.CC_Codigo_Externo__c = 'TE-000003';
            mccTematica.OS_No_Enviar_Encuestas__c = false;
            insert mccTematica;

            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Cuenta corriente';
            mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000003';
            mccProducto.OS_No_Enviar_Encuestas__c = false;
            insert mccProducto;

            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Apertura sin autorización';
            mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccMotivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mccMotivo.CC_Codigo_Externo__c = 'MO-000003';
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            mccMotivo.OS_No_Enviar_Encuestas__c = false;
            insert mccMotivo;

            Case caso2 = new Case();
            caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SEG_Cliente');
            caso2.Subject = 'Prueba Test 2';
            caso2.Status = 'Pendiente';
            caso2.SEG_Subestado__c = 'En gestión UAFE';
            caso2.CC_Idioma__c = 'es';
            caso2.Origin = 'Email';
            caso2.CC_Tematica__c = 'PRUEBA1';
            caso2.CC_Buzon_Salida__c = 'serviciofirma.devcops@gmail.com';
            caso2.CC_Cola_Procedencia__c = 'OS_Servicio_Firma';
            caso2.OwnerId = usuario.Id;
            caso2.SEG_Id_Related_Mail__c = '00000';
            caso2.CC_CasoRelacionado__c = caso1.Id;
            insert caso2;

            Test.startTest();
            caso1.SEG_Id_Related_Mail__c = '00000';
            caso1.CC_CasoRelacionado__c = caso2.Id;
            caso1.Status = 'Cerrado';
            update caso1;
            Test.stopTest();

            List<Case> casoUpd = [SELECT Id, Status, SEG_Subestado__c FROM Case WHERE Id = :caso2.Id];
            System.assertEquals('Cerrado', casoUpd[0].Status);
            System.assertEquals('Gestionado por UAFE', casoUpd[0].SEG_Subestado__c);

        }
    }
    @isTest
    public static void casoRelacionadoSegRechazo() {
        User usuario =  [SELECT Id FROM User WHERE Email = 'testdevdev@test.com' LIMIT 1] ; 
        System.runAs (usuario) {

            Case caso1 = [SELECT Id, SEG_Id_Related_Mail__c FROM Case WHERE Subject ='Prueba Test' LIMIT 1];
  

            Case caso2 = new Case();
            caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SEG_Cliente');
            caso2.Subject = 'Prueba Test 2';
            caso2.Status = 'Pendiente';
            caso2.SEG_Subestado__c = 'En gestión UAFE';
            caso2.CC_Idioma__c = 'es';
            caso2.Origin = 'Email';
            caso2.OwnerId = usuario.Id;
            caso2.SEG_Id_Related_Mail__c = '00000';
            caso2.CC_CasoRelacionado__c = caso1.Id;
            insert caso2;

            Test.startTest();
            caso1.SEG_Id_Related_Mail__c = '00000';
            caso1.CC_CasoRelacionado__c = caso2.Id;
            caso1.Status = 'Rechazado';
            update caso1;
            Test.stopTest();

            List<Case> casoUpd =[SELECT Id, Status, SEG_Subestado__c FROM Case WHERE Id = :caso2.Id];
            System.assertEquals('Activo', casoUpd[0].Status);
            System.assertEquals('En gestión UAFE', casoUpd[0].SEG_Subestado__c);
            

        }
    }
}