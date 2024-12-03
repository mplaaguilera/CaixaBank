@isTest
public class CSBD_MetodosComunes_Test {

    @testSetup
    static void prepararDatosTest() {

        System.runAs(CSBD_Usuarios.usuarioAdministrador()) {
            Map<String, Object> camposCuentaContacto = new Map<String, Object>{'CC_Numero_Documento__c' => '84465909L', 'Email' => 'test@test.com'};
            Map<String, SObject> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('84465909L', camposCuentaContacto);
            Account cuenta = (Account)cuentaContacto.get('Account');
            Contact contacto = (Contact)cuentaContacto.get('Contact');

            User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
            System.runAs(usuarioGestor) {
                Product2 productoPrestamo = new Product2(Name = 'Préstamo', Family = 'Préstamos', isActive = true);
                Product2 productoHipoteca = new Product2(Name = 'Hipoteca', Family = 'Hipotecas', isActive = true);
                Product2 productoSeguroSEVIAM = new Product2(Name = 'Seguro SEVIAM', Family = 'Seguros', isActive = true);
                Product2 productoRenting = new Product2(Name = 'Renting', Family = 'Renting', isActive = true);
                List<Product2> productos = new List<Product2>{productoPrestamo, productoHipoteca, productoSeguroSEVIAM, productoRenting};
                insert productos;
                List<PricebookEntry> standardPrices = new List<PricebookEntry>();
                Id pricebookId = Test.getStandardPricebookId();
                for (Product2 prod : productos) {
                    standardPrices.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true));
                }
                insert standardPrices;
                Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
                insert customPB;

                List<PricebookEntry> customPrices = new List<PricebookEntry>();

                for (Product2 prod : productos ){
                    PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
                    customPrices.add(customPrice);
                }
                insert customPrices;

                List<EmailTemplate> listaPlantillas = new List<EmailTemplate>();
                EmailTemplate plantilla = new EmailTemplate();
                plantilla.isActive = true;
                plantilla.Name = 'CSBD - Externalización de CMN por correo';
                plantilla.DeveloperName = 'CSBD_Test_' + System.now().getTime();
                plantilla.TemplateType = 'text';
                plantilla.FolderId = usuarioGestor.Id;
                listaPlantillas.add(plantilla);
                EmailTemplate plantilla2 = new EmailTemplate();
                plantilla2.isActive = true;
                plantilla2.Name = 'CSBD Traspaso CMB Imagin';
                plantilla2.DeveloperName = 'CSBD_Test2_' + System.now().getTime();
                plantilla2.TemplateType = 'text';
                plantilla2.FolderId = usuarioGestor.Id;
                listaPlantillas.add(plantilla2);
                EmailTemplate plantillaVidaCaixa = new EmailTemplate();
                plantillaVidaCaixa.IsActive = true;
                plantillaVidaCaixa.Name = 'plantillaVidaCaixa';
                plantillaVidaCaixa.DeveloperName = 'CSBD_plantillaVidaCaixa_' + System.now().getTime();
                plantillaVidaCaixa.TemplateType = 'text';
                plantillaVidaCaixa.FolderId = usuarioGestor.Id;
                plantillaVidaCaixa.HtmlValue = 'html test';
                listaPlantillas.add(plantillaVidaCaixa);
                insert listaPlantillas;
            }
        }

        CC_Lista_Valores__c cmnWS = new CC_Lista_Valores__c();
        cmnWS.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        cmnWS.Name = 'CSBD: Entrada CMN Cajeros - Códigos de campaña que se reenvían a AltaOportunidad';
        cmnWS.CC_Activa__c = true;
        CC_Lista_Valores__c cmnMail = new CC_Lista_Valores__c();
        cmnMail.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        cmnMail.Name = 'CSBD: Entrada CMN Cajeros - Códigos de campaña que se externalizan por correo';
        cmnMail.CC_Activa__c = true;
        CC_Lista_Valores__c vidaCaixa = new CC_Lista_Valores__c();
        vidaCaixa.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        vidaCaixa.Name = 'CSBD: Desistimientos - Productos gestionados externamente';
        vidaCaixa.CC_Activa__c = true;
        CC_Lista_Valores__c imagin = new CC_Lista_Valores__c();
        imagin.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        imagin.Name = 'CSBD: Traspaso Imagin - Destinatarios';
        imagin.CC_Activa__c = true;
        CC_Lista_Valores__c cmnDestMail = new CC_Lista_Valores__c();
        cmnDestMail.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        cmnDestMail.Name = 'CSBD: Entrada CMN Cajeros - Destinatarios de la externalización por correo';
        cmnDestMail.CC_Activa__c = true;
        CC_Lista_Valores__c desisMail = new CC_Lista_Valores__c();
        desisMail.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        desisMail.Name = 'CSBD_RS8_EMAIL_DESIS';
        desisMail.CC_Activa__c = true;
        CC_Lista_Valores__c lovPlantillasDesistimientos = new CC_Lista_Valores__c();
        lovPlantillasDesistimientos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovPlantillasDesistimientos.Name = 'CSBD: Plantillas para cierre de desistimientos';
        lovPlantillasDesistimientos.CC_Activa__c = true;
        insert new List<CC_Lista_Valores__c>{cmnWS, cmnMail, vidaCaixa, imagin, cmnDestMail, desisMail, lovPlantillasDesistimientos};

        Id valorRecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        List<CC_Lista_Valores__c> listaValoresCMN = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c valor1MailDesis = new CC_Lista_Valores__c();
        valor1MailDesis.RecordTypeId = valorRecordTypeId;
        valor1MailDesis.CC_Lista__c = desisMail.Id;
        valor1MailDesis.Name = 'Cancelación retos Imagin';
        valor1MailDesis.CC_Valor__c = 'TEST1@TEST1.COM';
        valor1MailDesis.CC_Valor_SFDC__c = 'plantillaVidaCaixa';
        valor1MailDesis.CC_Orden__c = 1;
        valor1MailDesis.CC_Activa__c = true;
        listaValoresCMN.add(valor1MailDesis);
        CC_Lista_Valores__c valor1Mail = new CC_Lista_Valores__c();
        valor1Mail.RecordTypeId = valorRecordTypeId;
        valor1Mail.CC_Lista__c = cmnDestMail.Id;
        valor1Mail.Name = 'DEST_1';
        valor1Mail.CC_Valor__c = 'TEST1@TEST1.COM';
        valor1Mail.CC_Orden__c = 1;
        valor1Mail.CC_Activa__c = true;
        listaValoresCMN.add(valor1Mail);
        CC_Lista_Valores__c valor2Mail = new CC_Lista_Valores__c();
        valor2Mail.RecordTypeId = valorRecordTypeId;
        valor2Mail.CC_Lista__c = cmnDestMail.Id;
        valor2Mail.Name = 'DEST_2';
        valor2Mail.CC_Valor__c = 'TEST2@TEST1.COM';
        valor2Mail.CC_Orden__c = 2;
        valor2Mail.CC_Activa__c = true;
        listaValoresCMN.add(valor2Mail);
        CC_Lista_Valores__c valor1CmnWS = new CC_Lista_Valores__c();
        valor1CmnWS.RecordTypeId = valorRecordTypeId;
        valor1CmnWS.CC_Lista__c = cmnWS.Id;
        valor1CmnWS.Name = 'TIPO_CAMPAÑA';
        valor1CmnWS.CC_Valor__c = '351';
        valor1CmnWS.CC_Orden__c = 1;
        valor1CmnWS.CC_Activa__c = true;
        listaValoresCMN.add(valor1CmnWS);
        CC_Lista_Valores__c valor2CmnMail = new CC_Lista_Valores__c();
        valor2CmnMail.RecordTypeId = valorRecordTypeId;
        valor2CmnMail.CC_Lista__c = cmnMail.Id;
        valor2CmnMail.Name = 'TIPO_CAMPAÑA';
        valor2CmnMail.CC_Valor__c = '400';
        valor2CmnMail.CC_Orden__c = 1;
        valor2CmnMail.CC_Activa__c = true;
        listaValoresCMN.add(valor2CmnMail);
        CC_Lista_Valores__c valor3VidaCaixa = new CC_Lista_Valores__c();
        valor3VidaCaixa.RecordTypeId = valorRecordTypeId;
        valor3VidaCaixa.CC_Lista__c = vidaCaixa.Id;
        valor3VidaCaixa.Name = 'Cancelación retos Imagin';
        valor3VidaCaixa.CC_Valor__c = '';
        valor3VidaCaixa.CC_Orden__c = 1;
        valor3VidaCaixa.CC_Activa__c = true;
        listaValoresCMN.add(valor3VidaCaixa);
        CC_Lista_Valores__c valorImagin = new CC_Lista_Valores__c();
        valorImagin.RecordTypeId = valorRecordTypeId;
        valorImagin.CC_Lista__c = imagin.Id;
        valorImagin.Name = 'CMB';
        valorImagin.CC_Valor__c = 'test@org.com';
        valorImagin.CC_Orden__c = 1;
        valorImagin.CC_Activa__c = true;
        listaValoresCMN.add(valorImagin);
        insert listaValoresCMN;

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valorHipoteca = new CC_Lista_Valores__c();
        valorHipoteca.RecordTypeId = valorRecordTypeId;
        valorHipoteca.CC_Lista__c = listaValores.Id;
        valorHipoteca.Name = 'Hipoteca';
        valorHipoteca.CC_Valor__c = '1';
        CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
        valorPrestamo.RecordTypeId = valorRecordTypeId;
        valorPrestamo.CC_Lista__c = listaValores.Id;
        valorPrestamo.Name = 'Préstamo';
        valorPrestamo.CC_Valor__c = '1';
        CC_Lista_Valores__c valorRenting = new CC_Lista_Valores__c();
        valorRenting.RecordTypeId = valorRecordTypeId;
        valorRenting.CC_Lista__c = listaValores.Id;
        valorRenting.Name = 'Renting';
        valorRenting.CC_Valor__c = '1';
        CC_Lista_Valores__c valorCompraEstrella = new CC_Lista_Valores__c();
        valorCompraEstrella.RecordTypeId = valorRecordTypeId;
        valorCompraEstrella.CC_Lista__c = listaValores.Id;
        valorCompraEstrella.Name = 'Wivai';
        valorCompraEstrella.CC_Valor__c = '1';
        CC_Lista_Valores__c valorCMN = new CC_Lista_Valores__c();
        valorCMN.RecordTypeId = valorRecordTypeId;
        valorCMN.CC_Lista__c = listaValores.Id;
        valorCMN.Name = 'CMN';
        valorCMN.CC_Valor__c = '1';
        CC_Lista_Valores__c valorCMB = new CC_Lista_Valores__c();
        valorCMB.RecordTypeId = valorRecordTypeId;
        valorCMB.CC_Lista__c = listaValores.Id;
        valorCMB.Name = 'CMB';
        valorCMB.CC_Valor__c = '1';
        CC_Lista_Valores__c valorTPV = new CC_Lista_Valores__c();
        valorTPV.Name = 'TPV';
        valorTPV.RecordTypeId = valorRecordTypeId;
        valorTPV.CC_Lista__c = listaValores.Id;
        valorTPV.CC_Valor__c = '1';
        CC_Lista_Valores__c valorDES = new CC_Lista_Valores__c();
        valorDES.Name = 'Desistimiento';
        valorDES.RecordTypeId = valorRecordTypeId;
        valorDES.CC_Lista__c = listaValores.Id;
        valorDES.CC_Valor__c = '1';
        CC_Lista_Valores__c valorDESPAI = new CC_Lista_Valores__c();
        valorDESPAI.Name = 'Desistimiento PAI';
        valorDESPAI.RecordTypeId = valorRecordTypeId;
        valorDESPAI.CC_Lista__c = listaValores.Id;
        valorDESPAI.CC_Valor__c = '1';
        insert new List<CC_Lista_Valores__c>{valorHipoteca, valorPrestamo, valorRenting, valorCompraEstrella, valorCMN, valorCMB, valorTPV, valorDES, valorDESPAI};

        Id recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account centro = new Account();
        centro.RecordTypeId = recordTypeCentro;
        centro.Name = 'test centro';
        centro.CC_Numero_Empresa__c = '001';
        centro.CC_Numero_Oficina__c = '09999';
        centro.CC_Numero_Oficina_Empresa__c = '001-09999';
        Account centro2 = new Account();
        centro2.RecordTypeId = recordTypeCentro;
        centro2.Name = 'test centro';
        centro2.CC_Numero_Empresa__c = '001';
        centro2.CC_Numero_Oficina__c = '08888';
        centro2.CC_Numero_Oficina_Empresa__c = '001-08888';
        centro2.CC_Email__c = 'test@test.es';
        insert new List<Account>{centro, centro2};
        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = centro.Id;
        acshare2.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        insert acshare2;
    }

    @isTest
    public static void validarFlujoVidaCaixaTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        System.runAs (usuarioGestor) {
            Test.startTest();
            Boolean bVidaCaixa = CSBD_MetodosComunes.esFlujoVidaCaixa('Cancelación retos Imagin');
            Boolean resultado2 = CSBD_MetodosComunes.externalizarCmnPorCorreo('400');
            Boolean resultado3 = CSBD_MetodosComunes.redirigirCmnCajeosAAltaOportunidad('351');
            Test.stopTest();

            System.assert(bVidaCaixa);
            System.assertEquals(resultado2, true);
            System.assertEquals(resultado3, true);
        }
    }

    @isTest
    public static void correoIdiomaOficina() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account centro = [SELECT CC_Numero_Oficina__c FROM Account WHERE Name= 'test centro' AND Recordtype.DeveloperName = 'CC_CentroCaixaBank' AND CC_Numero_Oficina__c = '09999' LIMIT 1];

        System.runAs (usuarioGestor) {
            Test.startTest();
            Account resultado = CSBD_MetodosComunes.correoIdiomaOficina(centro.Id);
            Test.stopTest();

            System.assertNotEquals(null , resultado);
        }
    }

    @isTest
    public static void enviarDesistimientoVidaCaixaMailTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '84465909L'];

        Pricebook2 listaPreciosCsbd = new Pricebook2();
        listaPreciosCsbd.Name = 'CSBD Price Book';
        listaPreciosCsbd.Description = 'CSBD Price Book';
        listaPreciosCsbd.IsActive = true;
        insert listaPreciosCsbd;

        Opportunity oportunidad1 = new Opportunity();
        oportunidad1.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Desistimiento').getRecordTypeId();
        oportunidad1.Name = 'Opportunity Test 1';
        oportunidad1.StageName = 'Solicitud';
        oportunidad1.CSBD_Contact__c = [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id;
        oportunidad1.CSBD_Now_NIF__c = cuenta.CC_Numero_Documento__c;
        oportunidad1.AccountId = cuenta.Id;
        insert oportunidad1;

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = oportunidad1.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        System.runAs (usuarioGestor) {
            Test.startTest();
            Messaging.SendEmailResult resultado = CSBD_MetodosComunes.enviarCorreoDesistimientoVidaCaixa(oportunidad1.Id, 'Cancelación retos Imagin');
            Test.stopTest();
            System.assert(resultado.isSuccess());
        }
    }

    @isTest
    public static void enviarCorreoCmn() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '84465909L'];

        Pricebook2 pb = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );
        insert pb;

        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_CMN').getRecordTypeId();
        oportunidad.Name = 'Opportunity Test 2';
        oportunidad.StageName = 'Solicitud';
        oportunidad.CSBD_Contact__c = [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id;
        oportunidad.CSBD_Now_NIF__c = cuenta.CC_Numero_Documento__c;
        oportunidad.AccountId = cuenta.Id;
        insert oportunidad;

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = oportunidad.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        System.runAs (usuarioGestor) {
            Test.startTest();
            Boolean resultado = CSBD_MetodosComunes.enviarCorreoCmn(oportunidad.id);
            Test.stopTest();

            System.assertEquals(true, resultado);
        }
    }

    @isTest
    public static void enviarCorreoReturnCorreo() {
        Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '84465909L'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id LIMIT 1];

        Id idBuzonSalida = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'CSBD - CaixaBank Informa'].Id;
        Id idPlantilla = [SELECT Id FROM EmailTemplate WHERE Name = 'CSBD Traspaso CMB Imagin' LIMIT 1].Id;
        List<String> destinatarios = new List<String>();
        for(CC_Lista_Valores__c destinatario: [SELECT CC_Valor__c FROM CC_Lista_Valores__c
                                                WHERE CC_Lista__r.Name = 'CSBD: Traspaso Imagin - Destinatarios' AND Name = 'CMB' AND CC_Activa__c = TRUE LIMIT 1]){
            destinatarios.add(destinatario.CC_Valor__c);
        }

        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD'];
        User usuarioAdmin = CSBD_Usuarios.usuarioAdministrador();
        System.runAs(usuarioAdmin) {
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_CMN', new Map<String, Object>{
                'Name' => 'Opportunity Test 3',
                'StageName' => 'Solicitud',
                'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c,
                'AccountId' => cuenta.Id,
                'CSBD_Contact__c' => contacto.Id
            });
            OpportunityShare oppshare = new OpportunityShare();
            oppshare.UserOrGroupId = usuarioGestor.Id;
            oppshare.OpportunityId = oportunidad.Id;
            oppshare.OpportunityAccessLevel = 'Edit';
            insert oppshare;

            System.runAs(usuarioGestor) {
                Test.startTest();
                Messaging.SingleEmailMessage resultado = CSBD_MetodosComunes.enviarCorreoReturnCorreo(
                    new Messaging.SingleEmailMessage(),
                    oportunidad.Id,
                    contacto.Id,
                    idBuzonSalida,
                    idPlantilla,
                    destinatarios
                );
                Test.stopTest();

                System.assertNotEquals(resultado, null);
            }
        }
    }
}