@isTest
public class CSBD_MetodosComunes_Test {

    @testSetup
    static void prepararDatosTest() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Id idRecordTypeListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            CC_Lista_Valores__c cmnWS = new CC_Lista_Valores__c();
            cmnWS.RecordTypeId = idRecordTypeListaValores;
            cmnWS.Name = 'CSBD: Entrada CMN Cajeros - Códigos de campaña que se reenvían a AltaOportunidad';
            CC_Lista_Valores__c cmnMail = new CC_Lista_Valores__c();
            cmnMail.RecordTypeId = idRecordTypeListaValores;
            cmnMail.Name = 'CSBD: Entrada CMN Cajeros - Códigos de campaña que se externalizan por correo';
            CC_Lista_Valores__c vidaCaixa = new CC_Lista_Valores__c();
            vidaCaixa.RecordTypeId = idRecordTypeListaValores;
            vidaCaixa.Name = 'CSBD: Desistimientos - Productos gestionados externamente';
            CC_Lista_Valores__c imagin = new CC_Lista_Valores__c();
            imagin.RecordTypeId = idRecordTypeListaValores;
            imagin.Name = 'CSBD: Traspaso Imagin - Destinatarios';
            CC_Lista_Valores__c cmnDestMail = new CC_Lista_Valores__c();
            cmnDestMail.RecordTypeId = idRecordTypeListaValores;
            cmnDestMail.Name = 'CSBD: Entrada CMN Cajeros - Destinatarios de la externalización por correo';
            CC_Lista_Valores__c desisMail = new CC_Lista_Valores__c();
            desisMail.RecordTypeId = idRecordTypeListaValores;
            desisMail.Name = 'CSBD_RS8_EMAIL_DESIS';
            CC_Lista_Valores__c lovPlantillasDesistimientos = new CC_Lista_Valores__c();
            lovPlantillasDesistimientos.RecordTypeId = idRecordTypeListaValores;
            lovPlantillasDesistimientos.Name = 'CSBD: Plantillas para cierre de desistimientos';
            CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
            listaValores.RecordTypeId = idRecordTypeListaValores;
            listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
            CC_Lista_Valores__c matriculasPool = new CC_Lista_Valores__c();
            matriculasPool.RecordTypeId = idRecordTypeListaValores;
            matriculasPool.Name = 'Gestion Oficinas del Pool';
            insert new List<CC_Lista_Valores__c>{cmnWS, cmnMail, vidaCaixa, imagin, cmnDestMail, desisMail, lovPlantillasDesistimientos, listaValores, matriculasPool};

            Id idRecordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            CC_Lista_Valores__c valor1MailDesis = new CC_Lista_Valores__c();
            valor1MailDesis.RecordTypeId = idRecordTypeValor;
            valor1MailDesis.CC_Lista__c = desisMail.Id;
            valor1MailDesis.Name = 'Cancelación retos Imagin';
            valor1MailDesis.CC_Valor__c = 'TEST1@TEST1.COM';
            valor1MailDesis.CC_Valor_SFDC__c = 'plantillaVidaCaixa';
            valor1MailDesis.CC_Orden__c = 1;
            CC_Lista_Valores__c valor1Mail = new CC_Lista_Valores__c();
            valor1Mail.RecordTypeId = idRecordTypeValor;
            valor1Mail.CC_Lista__c = cmnDestMail.Id;
            valor1Mail.Name = 'DEST_1';
            valor1Mail.CC_Valor__c = 'TEST1@TEST1.COM';
            valor1Mail.CC_Orden__c = 1;
            CC_Lista_Valores__c valor2Mail = new CC_Lista_Valores__c();
            valor2Mail.RecordTypeId = idRecordTypeValor;
            valor2Mail.CC_Lista__c = cmnDestMail.Id;
            valor2Mail.Name = 'DEST_2';
            valor2Mail.CC_Valor__c = 'TEST2@TEST1.COM';
            valor2Mail.CC_Orden__c = 2;
            CC_Lista_Valores__c valor1CmnWS = new CC_Lista_Valores__c();
            valor1CmnWS.RecordTypeId = idRecordTypeValor;
            valor1CmnWS.CC_Lista__c = cmnWS.Id;
            valor1CmnWS.Name = 'TIPO_CAMPAÑA';
            valor1CmnWS.CC_Valor__c = '351';
            valor1CmnWS.CC_Orden__c = 1;
            CC_Lista_Valores__c valor2CmnMail = new CC_Lista_Valores__c();
            valor2CmnMail.RecordTypeId = idRecordTypeValor;
            valor2CmnMail.CC_Lista__c = cmnMail.Id;
            valor2CmnMail.Name = 'TIPO_CAMPAÑA';
            valor2CmnMail.CC_Valor__c = '400';
            valor2CmnMail.CC_Orden__c = 1;
            CC_Lista_Valores__c valor3VidaCaixa = new CC_Lista_Valores__c();
            valor3VidaCaixa.RecordTypeId = idRecordTypeValor;
            valor3VidaCaixa.CC_Lista__c = vidaCaixa.Id;
            valor3VidaCaixa.Name = 'Cancelación retos Imagin';
            valor3VidaCaixa.CC_Valor__c = '';
            valor3VidaCaixa.CC_Orden__c = 1;
            CC_Lista_Valores__c valorImagin = new CC_Lista_Valores__c();
            valorImagin.RecordTypeId = idRecordTypeValor;
            valorImagin.CC_Lista__c = imagin.Id;
            valorImagin.Name = 'CMB';
            valorImagin.CC_Valor__c = 'test@org.com';
            valorImagin.CC_Orden__c = 1;
            CC_Lista_Valores__c valorHipoteca = new CC_Lista_Valores__c();
            valorHipoteca.RecordTypeId = idRecordTypeValor;
            valorHipoteca.CC_Lista__c = listaValores.Id;
            valorHipoteca.Name = 'Hipoteca';
            valorHipoteca.CC_Valor__c = '1';
            CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
            valorPrestamo.RecordTypeId = idRecordTypeValor;
            valorPrestamo.CC_Lista__c = listaValores.Id;
            valorPrestamo.Name = 'Préstamo';
            valorPrestamo.CC_Valor__c = '1';
            CC_Lista_Valores__c valorRenting = new CC_Lista_Valores__c();
            valorRenting.RecordTypeId = idRecordTypeValor;
            valorRenting.CC_Lista__c = listaValores.Id;
            valorRenting.Name = 'Renting';
            valorRenting.CC_Valor__c = '1';
            CC_Lista_Valores__c valorCompraEstrella = new CC_Lista_Valores__c();
            valorCompraEstrella.RecordTypeId = idRecordTypeValor;
            valorCompraEstrella.CC_Lista__c = listaValores.Id;
            valorCompraEstrella.Name = 'Wivai';
            valorCompraEstrella.CC_Valor__c = '1';
            CC_Lista_Valores__c valorCMN = new CC_Lista_Valores__c();
            valorCMN.RecordTypeId = idRecordTypeValor;
            valorCMN.CC_Lista__c = listaValores.Id;
            valorCMN.Name = 'CMN';
            valorCMN.CC_Valor__c = '1';
            CC_Lista_Valores__c valorCMB = new CC_Lista_Valores__c();
            valorCMB.RecordTypeId = idRecordTypeValor;
            valorCMB.CC_Lista__c = listaValores.Id;
            valorCMB.Name = 'CMB';
            valorCMB.CC_Valor__c = '1';
            CC_Lista_Valores__c valorTPV = new CC_Lista_Valores__c();
            valorTPV.Name = 'TPV';
            valorTPV.RecordTypeId = idRecordTypeValor;
            valorTPV.CC_Lista__c = listaValores.Id;
            valorTPV.CC_Valor__c = '1';
            CC_Lista_Valores__c valorDES = new CC_Lista_Valores__c();
            valorDES.Name = 'Desistimiento';
            valorDES.RecordTypeId = idRecordTypeValor;
            valorDES.CC_Lista__c = listaValores.Id;
            valorDES.CC_Valor__c = '1';
            CC_Lista_Valores__c valorDESPAI = new CC_Lista_Valores__c();
            valorDESPAI.Name = 'Desistimiento PAI';
            valorDESPAI.RecordTypeId = idRecordTypeValor;
            valorDESPAI.CC_Lista__c = listaValores.Id;
            valorDESPAI.CC_Valor__c = '1';          
            CC_Lista_Valores__c matriculaGenerica = new CC_Lista_Valores__c();
            matriculaGenerica.RecordTypeId = idRecordTypeValor;
            matriculaGenerica.CC_Lista__c = matriculasPool.Id;
            matriculaGenerica.Name = 'Centro Genérico';
            matriculaGenerica.CC_Valor__c = '012345';
       
            insert new List<CC_Lista_Valores__c>{
                valor1MailDesis, valor1Mail, valor2Mail, valor1CmnWS, valor2CmnMail, valor3VidaCaixa, valorImagin, valorHipoteca,
                valorPrestamo, valorRenting, valorCompraEstrella, valorCMN, valorCMB, valorTPV, valorDES, valorDESPAI, matriculaGenerica
            };

            CSBD_TestDataFactory.crearEmpleadoOficina('09999');
            CSBD_TestDataFactory.crearEmpleadoOficina('08888');

            CSBD_TestDataFactory.crearCuentaContacto('84465909L', new Map<String, Object>{
                'CC_Numero_Documento__c' => '84465909L', 'Email' => 'test@test.com'
            });

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
                Pricebook2 customPB = new Pricebook2(Name = 'Standard Price Book', isActive = true);
                insert customPB;

                List<PricebookEntry> customPrices = new List<PricebookEntry>();

                for (Product2 prod : productos ){
                    PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
                    customPrices.add(customPrice);
                }
                insert customPrices;

                EmailTemplate plantilla = new EmailTemplate();
                plantilla.isActive = true;
                plantilla.Name = 'CSBD - Externalización de CMN por correo';
                plantilla.DeveloperName = 'CSBD_Test_' + System.now().getTime();
                plantilla.TemplateType = 'text';
                plantilla.FolderId = usuarioGestor.Id;
                EmailTemplate plantilla2 = new EmailTemplate();
                plantilla2.isActive = true;
                plantilla2.Name = 'CSBD Traspaso CMB Imagin';
                plantilla2.DeveloperName = 'CSBD_Test2_' + System.now().getTime();
                plantilla2.TemplateType = 'text';
                plantilla2.FolderId = usuarioGestor.Id;
                EmailTemplate plantillaVidaCaixa = new EmailTemplate();
                plantillaVidaCaixa.IsActive = true;
                plantillaVidaCaixa.Name = 'plantillaVidaCaixa';
                plantillaVidaCaixa.DeveloperName = 'CSBD_plantillaVidaCaixa_' + System.now().getTime();
                plantillaVidaCaixa.TemplateType = 'text';
                plantillaVidaCaixa.FolderId = usuarioGestor.Id;
                plantillaVidaCaixa.HtmlValue = 'html test';
                insert new List<EmailTemplate>{plantilla, plantilla2, plantillaVidaCaixa};
            }
        }
    }

    @isTest
    public static void validarFlujoVidaCaixaTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            System.assert(CSBD_MetodosComunes.esFlujoVidaCaixa('Cancelación retos Imagin'), 'No se ha detectado correctamente el flujo de VidaCaixa');
            System.assertEquals(CSBD_MetodosComunes.externalizarCmnPorCorreo('400'), true, 'Retorno incorrecto');
            System.assertEquals(CSBD_MetodosComunes.redirigirCmnCajeosAAltaOportunidad('351'), true, 'Retorno incorrecto');
            Test.stopTest();
        }
    }

    @isTest
    public static void correoIdiomaOficina() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Id idOficina = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '09999' LIMIT 1].Id;
            Test.startTest();
            Account resultado = CSBD_MetodosComunes.correoIdiomaOficina(idOficina);
            Test.stopTest();

            System.assertNotEquals(null , resultado, 'Retorno incorrecto');
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
        User usuarioAdmin = CSBD_TestDataFactory.usuarioAdministrador();
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

    @isTest
    public static void buscarCentroPool() {
      
        User usuarioAdmin = CSBD_TestDataFactory.usuarioAdministrador();
        System.runAs(usuarioAdmin) {       
            Account oficina = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '09999'];
            Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '84465909L'];
            cuenta.AV_OfficeManager__c = oficina.Id;
            update cuenta;

            Contact contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id LIMIT 1];
            User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD'];

            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_CMN', new Map<String, Object>{
                'Name' => 'Opportunity Test 3',
                'StageName' => 'Solicitud',
                'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c,
                'AccountId' => cuenta.Id,
                'CSBD_Contact__c' => contacto.Id
            });
          
            System.runAs(usuarioGestor) {
                String centroPool = '';
                Test.startTest();
                    List<Opportunity> oportunidadGet = [
                        SELECT ContactId, AccountId, AV_PF__c, 
                            Account.AV_EAPGestor__r.Account.CC_Numero_Oficina__c, AV_Comentarios__c, 
                            Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, 
                            Account.AV_OfficeManager__r.CC_Numero_Oficina__c
                        FROM Opportunity 
                        WHERE Id = :oportunidad.Id
                    ];
                    centroPool = CSBD_MetodosComunes.buscarCentro(oportunidadGet[0], 'U01BPA01');
                Test.stopTest();

                System.assertEquals(centroPool, '09999',  'Error en el centro del gestor Pool');
            }
        }
    }

    @isTest
    public static void buscarCentroPoolDefault() {
      
        User usuarioAdmin = CSBD_TestDataFactory.usuarioAdministrador();
        System.runAs(usuarioAdmin) {     

            Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '84465909L'];
            Contact contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id LIMIT 1];
            User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD'];

            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_CMN', new Map<String, Object>{
                'Name' => 'Opportunity Test 3',
                'StageName' => 'Solicitud',
                'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c,
                'AccountId' => cuenta.Id,
                'CSBD_Contact__c' => contacto.Id
            });
          
            System.runAs(usuarioGestor) {
                String centroPool = '';
                Test.startTest();
                    List<Opportunity> oportunidadGet = [
                        SELECT ContactId, AccountId, AV_PF__c, 
                            Account.AV_EAPGestor__r.Account.CC_Numero_Oficina__c, AV_Comentarios__c, 
                            Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, 
                            Account.AV_OfficeManager__r.CC_Numero_Oficina__c
                        FROM Opportunity 
                        WHERE Id = :oportunidad.Id
                    ];
                    centroPool = CSBD_MetodosComunes.buscarCentro(oportunidadGet[0], 'U01BPA01');
                Test.stopTest();

                System.assertEquals(centroPool, '012345',  'Error en el centro del gestor por defecto');
            }
        }
    }


    @isTest
    public static void buscarCentroNoPool() {
      
        User usuarioAdmin = CSBD_TestDataFactory.usuarioAdministrador();
        System.runAs(usuarioAdmin) {       
            //Contact empleado = [SELECT Id FROM Contact WHERE Account.CC_Numero_Oficina__c = '08888' ORDER BY CreatedDate DESC LIMIT 1];
            Account oficina = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '08888'];
            Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '84465909L'];
            cuenta.AV_OficinaPrincipal__c = oficina.Id;
            update cuenta;

            Contact contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id LIMIT 1];
            User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD'];

            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_CMN', new Map<String, Object>{
                'Name' => 'Opportunity Test 3',
                'StageName' => 'Solicitud',
                'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c,
                'AccountId' => cuenta.Id,
                'CSBD_Contact__c' => contacto.Id
            });
          
            System.runAs(usuarioGestor) {
                String centroNoPool = '';
                Test.startTest();
                    List<Opportunity> oportunidadGet = [
                        SELECT ContactId, AccountId, AV_PF__c, 
                            Account.AV_EAPGestor__r.Account.CC_Numero_Oficina__c, AV_Comentarios__c, 
                            Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, 
                            Account.AV_OfficeManager__r.CC_Numero_Oficina__c
                        FROM Opportunity 
                        WHERE Id = :oportunidad.Id
                    ];
                    centroNoPool = CSBD_MetodosComunes.buscarCentro(oportunidadGet[0], 'U01010101'); 
                Test.stopTest();

                System.assertEquals(centroNoPool, '08888',  'Error en el centro del gestor No Pool');
            }
        }
    }

    @isTest
    public static void obtenerIdBuzonSalida() {
     

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName LIKE '%CSBD%' LIMIT 1];

            CSBD_Remitente_Enviar_Correo__c config = new CSBD_Remitente_Enviar_Correo__c();
            config.CSBD_Buzon_CaixaBank__c = owa.Address;
            config.CSBD_Buzon_ImaginBank__c = owa.Address;
            config.CSBD_Buzon_Alta_digital_de_menores__c = owa.Address;
            insert config;
            
            Test.startTest();
                Id idBuzonSalida = CSBD_MetodosComunes.obtenerIdBuzonSalida('CaixaBank');
            Test.stopTest();
            System.assertNotEquals(idBuzonSalida, null);
            System.assertEquals(idBuzonSalida, owa.Id);
        }
    }

}