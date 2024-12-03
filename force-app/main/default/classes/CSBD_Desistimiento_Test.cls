@isTest
public class CSBD_Desistimiento_Test {

    @TestSetup
    static void testSetup() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(CSBD_Usuarios.usuarioAdministrador()) {
            Account oficinaGestora = new Account();
            oficinaGestora.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            oficinaGestora.Name = 'test centro';
            oficinaGestora.CC_Numero_Empresa__c = '001';
            oficinaGestora.CC_Numero_Oficina__c = '09999';
            oficinaGestora.CC_Numero_Oficina_Empresa__c = '001-09999';
            oficinaGestora.CC_Idioma_Oficina__c = '001';
            oficinaGestora.CC_Email__c = 'prueba@test.com';
            insert oficinaGestora;

            Account cuentaSinCorreoOficinaGestora = (Account)CSBD_TestDataFactory.crearCuentaContacto('46979497L').get('cuenta');

            AccountShare acshare1 = new AccountShare();
            acshare1.AccountId = cuentaSinCorreoOficinaGestora.Id;
            acshare1.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
            acshare1.AccountAccessLevel = 'Edit';
            acshare1.OpportunityAccessLevel = 'Edit';
            acshare1.CaseAccessLevel = 'Edit';
            AccountShare acshare2 = new AccountShare();
            acshare2.AccountId = oficinaGestora.Id;
            acshare2.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
            acshare2.AccountAccessLevel = 'Edit';
            acshare2.OpportunityAccessLevel = 'Edit';
            acshare2.CaseAccessLevel = 'Edit';
            insert new List<AccountShare>{acshare1, acshare2};

            Map<String, SObject> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('46979496X');
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Contact contacto = (Contact)cuentaContacto.get('contacto');

            Pricebook2 listaPreciosCsbd = new Pricebook2();
            listaPreciosCsbd.Name = 'CSBD Price Book';
            listaPreciosCsbd.Description = 'CSBD Price Book';
            listaPreciosCsbd.IsActive = true;
            insert listaPreciosCsbd;

            CC_Lista_Valores__c lovPlantillasDesistimientos = new CC_Lista_Valores__c();
            lovPlantillasDesistimientos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            lovPlantillasDesistimientos.Name = 'CSBD: Plantillas para cierre de desistimientos';
            lovPlantillasDesistimientos.CC_Activa__c = true;
            CC_Lista_Valores__c lovProductosVidaCaixa = new CC_Lista_Valores__c();
            lovProductosVidaCaixa.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            lovProductosVidaCaixa.Name = 'CSBD: Desistimientos - Productos gestionados externamente';
            lovProductosVidaCaixa.CC_Activa__c = true;
            CC_Lista_Valores__c lovProductosDireccionesCorreo = new CC_Lista_Valores__c();
            lovProductosDireccionesCorreo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            lovProductosDireccionesCorreo.Name = 'CSBD_RS8_EMAIL_DESIS';
            lovProductosDireccionesCorreo.CC_Activa__c = true;
            insert new List<CC_Lista_Valores__c>{lovPlantillasDesistimientos, lovProductosVidaCaixa, lovProductosDireccionesCorreo};

            CC_Lista_Valores__c lovPlantillasDesistimientosOkClienteCastellano = new CC_Lista_Valores__c();
            lovPlantillasDesistimientosOkClienteCastellano.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            lovPlantillasDesistimientosOkClienteCastellano.CC_Lista__c = lovPlantillasDesistimientos.Id;
            lovPlantillasDesistimientosOkClienteCastellano.Name = 'Formalizada.*.Cliente.Castellano';
            lovPlantillasDesistimientosOkClienteCastellano.CC_Valor__c = 'plantilla ok cliente cast test';
            CC_Lista_Valores__c lovPlantillasDesistimientosOkClienteCatalan = new CC_Lista_Valores__c();
            lovPlantillasDesistimientosOkClienteCatalan.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            lovPlantillasDesistimientosOkClienteCatalan.CC_Lista__c = lovPlantillasDesistimientos.Id;
            lovPlantillasDesistimientosOkClienteCatalan.Name = 'Formalizada.*.Cliente.Catalán';
            lovPlantillasDesistimientosOkClienteCatalan.CC_Valor__c = 'plantilla ok cliente cat test';
            CC_Lista_Valores__c lovPlantillasDesistimientosOkOficinaCatalan = new CC_Lista_Valores__c();
            lovPlantillasDesistimientosOkOficinaCatalan.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            lovPlantillasDesistimientosOkOficinaCatalan.CC_Lista__c = lovPlantillasDesistimientos.Id;
            lovPlantillasDesistimientosOkOficinaCatalan.Name = 'Formalizada.*.Oficina.Catalán';
            lovPlantillasDesistimientosOkOficinaCatalan.CC_Valor__c = 'plantilla ok oficina cat test';
            CC_Lista_Valores__c lovPlantillasDesistimientosPaiOkOficinaCatalan = new CC_Lista_Valores__c();
            lovPlantillasDesistimientosPaiOkOficinaCatalan.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            lovPlantillasDesistimientosPaiOkOficinaCatalan.CC_Lista__c = lovPlantillasDesistimientos.Id;
            lovPlantillasDesistimientosPaiOkOficinaCatalan.Name = 'PAI.Formalizada.*.Oficina.Catalán';
            lovPlantillasDesistimientosPaiOkOficinaCatalan.CC_Valor__c = 'plantilla pai ok oficina cat test';
            CC_Lista_Valores__c lovProductosVidaCaixaValor = new CC_Lista_Valores__c();
            lovProductosVidaCaixaValor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            lovProductosVidaCaixaValor.CC_Lista__c = lovProductosVidaCaixa.Id;
            lovProductosVidaCaixaValor.Name = 'Cancelación retos Imagin';
            CC_Lista_Valores__c lovProductosDireccionesCorreoValor = new CC_Lista_Valores__c();
            lovProductosDireccionesCorreoValor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            lovProductosDireccionesCorreoValor.CC_Lista__c = lovProductosDireccionesCorreo.Id;
            lovProductosDireccionesCorreoValor.Name = 'Cancelación retos Imagin';
            lovProductosDireccionesCorreoValor.CC_Valor__c = 'destinatario@de.correo';
            lovProductosDireccionesCorreoValor.CC_Valor_SFDC__c = 'plantilla vidacaixa test';
            insert new List<CC_Lista_Valores__c>{
                lovProductosVidaCaixaValor,
                lovProductosDireccionesCorreoValor,
                lovPlantillasDesistimientosOkClienteCastellano,
                lovPlantillasDesistimientosOkClienteCatalan,
                lovPlantillasDesistimientosOkOficinaCatalan,
                lovPlantillasDesistimientosPaiOkOficinaCatalan
            };

            CC_Lista_Valores__c lovDiasCierre = new CC_Lista_Valores__c();
            lovDiasCierre.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            lovDiasCierre.Name = 'CSBD: Días cierre oportunidad por defecto';
            lovDiasCierre.CC_Activa__c = true;
            insert lovDiasCierre;

            CC_Lista_Valores__c lovDiasCierreDesistimiento = new CC_Lista_Valores__c();
            lovDiasCierreDesistimiento.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            lovDiasCierreDesistimiento.CC_Lista__c = lovDiasCierre.Id;
            lovDiasCierreDesistimiento.Name = 'Desistimiento';
            lovDiasCierreDesistimiento.CC_Valor__c = '1';
            insert lovDiasCierreDesistimiento;

            System.runAs(usuarioGestor) {
                EmailTemplate plantillasDesistimientosVidaCaixa = new EmailTemplate();
                plantillasDesistimientosVidaCaixa.IsActive = true;
                plantillasDesistimientosVidaCaixa.Name = 'plantilla vidacaixa test';
                plantillasDesistimientosVidaCaixa.DeveloperName = 'CSBD_VidaCaixa_Test_' + System.now().getTime();
                plantillasDesistimientosVidaCaixa.TemplateType = 'text';
                plantillasDesistimientosVidaCaixa.FolderId = usuarioGestor.Id;
                plantillasDesistimientosVidaCaixa.HtmlValue = 'html test';
                EmailTemplate plantillasDesistimientoOkOficinaCat = new EmailTemplate();
                plantillasDesistimientoOkOficinaCat.IsActive = true;
                plantillasDesistimientoOkOficinaCat.Name = 'plantilla ok oficina cat test';
                plantillasDesistimientoOkOficinaCat.DeveloperName = 'CSBD_Ok_Ofi_Cat_Test_' + System.now().getTime();
                plantillasDesistimientoOkOficinaCat.TemplateType = 'text';
                plantillasDesistimientoOkOficinaCat.FolderId = usuarioGestor.Id;
                plantillasDesistimientoOkOficinaCat.HtmlValue = 'html test';
                EmailTemplate plantillasDesistimientoOkClienteCat = new EmailTemplate();
                plantillasDesistimientoOkClienteCat.IsActive = true;
                plantillasDesistimientoOkClienteCat.Name = 'plantilla ok cliente cast test';
                plantillasDesistimientoOkClienteCat.DeveloperName = 'CSBD_Ok_Cliente_Cast_Test_' + System.now().getTime();
                plantillasDesistimientoOkClienteCat.TemplateType = 'text';
                plantillasDesistimientoOkClienteCat.FolderId = usuarioGestor.Id;
                plantillasDesistimientoOkClienteCat.HtmlValue = 'html test';
                EmailTemplate plantillasDesistimientosPaiOk = new EmailTemplate();
                plantillasDesistimientosPaiOk.IsActive = true;
                plantillasDesistimientosPaiOk.Name = 'plantilla pai ok oficina cat test';
                plantillasDesistimientosPaiOk.DeveloperName = 'CSBD_Pai_Ok_Ofi_Cat_Test_' + System.now().getTime();
                plantillasDesistimientosPaiOk.TemplateType = 'text';
                plantillasDesistimientosPaiOk.FolderId = usuarioGestor.Id;
                plantillasDesistimientosPaiOk.HtmlValue = 'html test';
                insert new List<EmailTemplate>{
                    plantillasDesistimientosVidaCaixa,
                    plantillasDesistimientoOkOficinaCat,
                    plantillasDesistimientoOkClienteCat,
                    plantillasDesistimientosPaiOk
                };
            }
        }
    }

    @isTest
    public static void cerrarDesistimiento() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD'];
        Account oficinaGestora = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE Name = 'test centro'];
        Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979496X'];

        Map<String, Object> camposDesistimiento = new Map<String, Object>();
        camposDesistimiento.put('AccountId', cuenta.Id);
        camposDesistimiento.put('Amount',10);
        camposDesistimiento.put('CSBD_Email_Solicitud__c', 'prueba2@test.com');
        camposDesistimiento.put('CSBD_Now_Codigo_Producto__c', 'producto NO VidaCaixa');
        Opportunity desistimiento = CSBD_Opportunity.crearOportunidad('CSBD_Desistimiento', camposDesistimiento);
        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = desistimiento.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        System.runAs(usuarioGestor) {
            Test.startTest();
            desistimiento.OwnerId = usuarioGestor.Id;
            update desistimiento;
            desistimiento = CSBD_Opportunity.cerrarOportunidad(desistimiento.Id, 'Formalizada', 'Desistimiento realizado');
            Test.stopTest();

            System.assert(
                [SELECT Count() FROM EmailMessage WHERE RelatedToId = :desistimiento.Id] > 0,
                'No se han enviado los correos automáticos'
            );
        }
    }

    @isTest
    public static void cerrarDesistimientoSinCorreo() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account oficinaGestora = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE Name = 'test centro'];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979496X'];
        Account cuentaSinCorreoOficinaGestora = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979497L'];

        Map<String, Object> camposDesistimientoSinCorreoCliente = new Map<String, Object>();
        camposDesistimientoSinCorreoCliente.put('AccountId', cuenta.Id);
        camposDesistimientoSinCorreoCliente.put('Amount',10);
        camposDesistimientoSinCorreoCliente.put('CSBD_Now_Codigo_Producto__c', 'producto NO VidaCaixa');
        Opportunity desistimientoSinCorreoCliente = CSBD_Opportunity.crearOportunidad('CSBD_Desistimiento', camposDesistimientoSinCorreoCliente);

        Map<String, Object> camposDesistimientoSinCorreoOficinaGestora = new Map<String, Object>();
        camposDesistimientoSinCorreoOficinaGestora.put('AccountId', cuentaSinCorreoOficinaGestora.Id);
        camposDesistimientoSinCorreoOficinaGestora.put('Amount',10);
        camposDesistimientoSinCorreoOficinaGestora.put('CSBD_Email_Solicitud__c', '');
        camposDesistimientoSinCorreoOficinaGestora.put('CSBD_Now_Codigo_Producto__c', 'producto NO VidaCaixa');
        Opportunity desistimientoSinCorreoOficinaGestora = CSBD_Opportunity.crearOportunidad('CSBD_Desistimiento', camposDesistimientoSinCorreoOficinaGestora);

        List<OpportunityShare> permisosOportunidades = new List<OpportunityShare>();

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = desistimientoSinCorreoCliente.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        permisosOportunidades.add(oppshare);

        OpportunityShare oppshare2 = new OpportunityShare();
        oppshare2.UserOrGroupId = usuarioGestor.Id;
        oppshare2.OpportunityId = desistimientoSinCorreoOficinaGestora.Id;
        oppshare2.OpportunityAccessLevel = 'Edit';
        permisosOportunidades.add(oppshare2);
        insert permisosOportunidades;

        List<Opportunity> oportunidadesTotales = new List<Opportunity>();
        oportunidadesTotales.add(desistimientoSinCorreoCliente);
        oportunidadesTotales.add(desistimientoSinCorreoOficinaGestora);

        System.runAs ( usuarioGestor ) {
            desistimientoSinCorreoCliente.OwnerId = usuarioGestor.Id;
            desistimientoSinCorreoOficinaGestora.OwnerId = usuarioGestor.Id;
            update oportunidadesTotales;
            Test.startTest();
            desistimientoSinCorreoCliente = CSBD_Opportunity.cerrarOportunidad(desistimientoSinCorreoCliente.Id, 'Formalizada', 'Desistimiento realizado');
            desistimientoSinCorreoOficinaGestora = CSBD_Opportunity.cerrarOportunidad(desistimientoSinCorreoOficinaGestora.Id, 'Formalizada', 'Desistimiento realizado');
            Test.stopTest();

            System.assert(
                [SELECT Count() FROM Task WHERE WhatId = :desistimientoSinCorreoCliente.Id AND Type = 'Error notificando resultado de desistimiento a cliente'] > 0,
                'No se ha creado la tarea registrando el problema enviado el correo automático al cliente'
            );
            System.assert(
                [SELECT Count() FROM Task WHERE WhatId = :desistimientoSinCorreoOficinaGestora.Id AND Type = 'Error notificando desistimiento a oficina'] > 0,
                'No se ha creado la tarea registrando el problema enviado el correo automático a la oficina'
            );
        }
    }

    @isTest
    public static void automatismosDesistimientosTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account oficina = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE Name = 'test centro'];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979496X'];
        Account cuentaSinCorreoOficinaGestora = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979497L'];
        Contact contacto = [SELECT Id, Name, CC_Numero_Documento__c FROM Contact WHERE AccountId = :cuenta.Id];
        Contact contactoSinCorreoOficinaGestora = [SELECT Id, Name, CC_Numero_Documento__c FROM Contact WHERE AccountId = :cuentaSinCorreoOficinaGestora.Id];


        Map<String, Object> camposDesistimientoVidaCaixa = new Map<String, Object>();
        camposDesistimientoVidaCaixa.put('AccountId', cuenta.Id);
        camposDesistimientoVidaCaixa.put('CSBD_Contact__c', contacto.Id);
        camposDesistimientoVidaCaixa.put('Amount',10);
        camposDesistimientoVidaCaixa.put('CSBD_Email_Solicitud__c', 'prueba@test.com');
        camposDesistimientoVidaCaixa.put('CSBD_Now_Codigo_Producto__c', 'Cancelación retos Imagin');
        Opportunity desistimientoVidaCaixa = CSBD_Opportunity.crearOportunidad('CSBD_Desistimiento', camposDesistimientoVidaCaixa);

        Map<String, Object> camposDesistimiento = new Map<String, Object>();
        camposDesistimiento.put('AccountId', cuenta.Id);
        camposDesistimiento.put('CSBD_Contact__c', contacto.Id);
        camposDesistimiento.put('Amount',10);
        camposDesistimiento.put('CSBD_Email_Solicitud__c', 'prueba@test.com');
        camposDesistimiento.put('CSBD_Now_Codigo_Producto__c', 'producto NO VidaCaixa');
        Opportunity desistimiento = CSBD_Opportunity.crearOportunidad('CSBD_Desistimiento', camposDesistimiento);

        Map<String, Object> camposDesistimientoPai = new Map<String, Object>();
        camposDesistimientoPai.put('AccountId', cuentaSinCorreoOficinaGestora.Id);
        camposDesistimientoPai.put('CSBD_Contact__c', contactoSinCorreoOficinaGestora.Id);
        camposDesistimientoPai.put('CSBD_Email_Solicitud__c', 'prueba@test.com');
        camposDesistimientoPai.put('Amount',10);
        camposDesistimientoPai.put('CSBD_Now_Codigo_Producto__c', 'producto pai ok');
        camposDesistimientoPai.put('CSBD_Now_Resultado__c', 'OK');
        camposDesistimientoPai.put('CSBD_OficinaLO__c', oficina.Id);
        Opportunity desistimientoPai = CSBD_Opportunity.crearOportunidad('CSBD_DesistimientoPAI', camposDesistimientoPai);

        List<OpportunityShare> permisosOportunidades = new List<OpportunityShare>();

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = desistimientoVidaCaixa.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        permisosOportunidades.add(oppshare);

        OpportunityShare oppshare2 = new OpportunityShare();
        oppshare2.UserOrGroupId = usuarioGestor.Id;
        oppshare2.OpportunityId = desistimiento.Id;
        oppshare2.OpportunityAccessLevel = 'Edit';
        permisosOportunidades.add(oppshare2);

        OpportunityShare oppshare3 = new OpportunityShare();
        oppshare3.UserOrGroupId = usuarioGestor.Id;
        oppshare3.OpportunityId = desistimientoPai.Id;
        oppshare3.OpportunityAccessLevel = 'Edit';
        permisosOportunidades.add(oppshare3);
        insert permisosOportunidades;

        List<Opportunity> todasLasOportunidades = new List<Opportunity>();
        todasLasOportunidades.add(desistimientoPai);
        todasLasOportunidades.add(desistimiento);
        todasLasOportunidades.add(desistimientoVidaCaixa);

        System.runAs ( usuarioGestor ) {
            desistimientoPai.OwnerId = usuarioGestor.Id;
            desistimiento.OwnerId = usuarioGestor.Id;
            desistimientoVidaCaixa.OwnerId = usuarioGestor.Id;
            update todasLasOportunidades;
            Test.startTest();
            CSBD_Desistimiento.automatismosDesistimientos(new List<Id>{desistimientoVidaCaixa.Id, desistimiento.Id, desistimientoPai.Id});
            Test.stopTest();

            System.assert([SELECT Count() FROM EmailMessage WHERE RelatedToId = :desistimientoVidaCaixa.Id] > 0, 'No se han enviado los correos automáticos');
            System.assert([SELECT Count() FROM EmailMessage WHERE RelatedToId = :desistimiento.Id] == 0, 'No se deberían haber enviado correos automáticos');
            System.assert([SELECT Count() FROM EmailMessage WHERE RelatedToId = :desistimientoPai.Id] > 0, 'No se han enviado los correos automáticos');
        }
    }

    private static Account crearCuentaContacto(String nif, Id idOficinaGestora) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        cuenta.CC_OficinaGestoraId__c = idOficinaGestora;
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        return cuenta;
    }
}