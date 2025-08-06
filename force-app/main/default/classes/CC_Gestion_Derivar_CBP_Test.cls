@isTest
private with sharing class CC_Gestion_Derivar_CBP_Test {

    @testSetup
    static void setup() {
        
        User admin = CC_TestDataFactory.insertUserAdmin();
        User operador = CC_TestDataFactory.insertUserOperadorCliente('000001');
        
        System.runAs(admin) {

            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtCentroId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');

            Account centro = new Account();
            centro.Name = 'Centro Test';
            centro.CC_Email__c = 'test@test.com';
            centro.CC_Numero_Oficina_Empresa__c = '000-14141';
            centro.CC_Tipo_Oficina__c = 'I';
            centro.CC_Numero_Empresa__c  = '001';
            centro.CC_Tipo_Centro__c = 'OF';
            centro.CC_Numero_Oficina__c = '16987';
            centro.RecordTypeId = rtCentroId;
            insert centro;
            
            Id recordTypeGrupoColaborador =  Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            
            CC_Grupo_Colaborador__c grupoColaborador  = new CC_Grupo_Colaborador__c();
            grupoColaborador.RecordTypeId = recordTypeGrupoColaborador;
            grupoColaborador.Name = 'CBP Connecta';
            grupoColaborador.OS_Negocio__c = 'CC';
            insert grupoColaborador;

            

            // Insert gestor
            Contact gestor = new Contact();
            gestor.LastName = 'Gestor';
            gestor.FirstName = 'Test';
            gestor.CC_Inactivo__c = false;
            gestor.Email = 'test@test.com';
            gestor.CC_Matricula__c = 'U0124112';
            gestor.AccountId = centro.Id;
            gestor.AV_DescFuncion__c = 'DIRECCION';
            gestor.RecordtypeId =  rtEmpleado;
            gestor.CC_Num_Empleado_Generico__c = '12345';

            insert gestor;
            
            Account cuentaNoInTouch = new Account();
            cuentaNoInTouch.Name = 'Cliente NoIntouch';
            cuentaNoInTouch.CC_Email__c = 'NoIntouch@test.com';
            cuentaNoInTouch.AV_IndicadoresClientes__c = '28';
            cuentaNoInTouch.AV_EAPGestor__c = gestor.Id;
            cuentaNoInTouch.AV_OficinaPrincipal__c = centro.Id;
            cuentaNoInTouch.RecordTypeId = rtCliente;
            cuentaNoInTouch.AV_Cliente__c = true;
            insert cuentaNoInTouch;

            Case casoNoInTouch = new Case();
            casoNoInTouch.Subject = 'Caso Test NoInTouch';
            casoNoInTouch.AccountId = cuentaNoInTouch.Id;
            casoNoInTouch.OwnerId = operador.Id;
            casoNoInTouch.RecordTypeId = recordTypeCaso;
            casoNoInTouch.Origin = 'Email';
            insert casoNoInTouch;

            // Insert colaborador y relación con grupo colaborador
            Contact colaborador = new Contact(LastName = 'Colaborador', FirstName = 'CBP', Email = 'cbp@prueba.com', AccountId = cuentaNoInTouch.Id, RecordTypeId = rtEmpleado);
            insert colaborador;
            CC_Grupo_Colaborador_Contact__c grupoContacto = new CC_Grupo_Colaborador_Contact__c(
                CC_Grupo_Colaborador__c = grupoColaborador.Id,
                CC_Contacto__c = colaborador.Id
            );
            insert grupoContacto;
            
            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT  CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
            String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;
            
            Id recordTypeLista = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            Id recordTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            
            List<CC_Lista_Valores__c> listas = new List<CC_Lista_Valores__c>();
            List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c> ();
            
            CC_Lista_Valores__c listaDerivar = new CC_Lista_Valores__c();
            listaDerivar.Name = 'Textos operativa Derivar';
            listaDerivar.RecordTypeId = recordTypeLista;
            listas.add(listaDerivar);
            insert listas;
            
            CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
            valor.Name = 'OWA activa CBP';
            valor.RecordTypeId = recordTypeValor;
            valor.CC_Lista__c = listaDerivar.Id;
            valor.CC_Mensajes_Mostrar__c = emailCorreoEntrante;
            valores.add(valor);

            insert valores;

            // Crear Account Share y Contact Share para el operador
            List<AccountShare> accountShares = new List<AccountShare>();
            List<ContactShare> contactShares = new List<ContactShare>();
            
            // Configurar Account Shares
            for(Account acc : new List<Account>{centro, cuentaNoInTouch}) {
                accountShares.add(new AccountShare(
                    AccountId = acc.Id,
                    UserOrGroupId = operador.Id,
                    AccountAccessLevel = 'Read',
                    OpportunityAccessLevel = 'None',
                    CaseAccessLevel = 'Read',
                    ContactAccessLevel = 'Read'
                ));
            }
            
            // Configurar Contact Shares
            contactShares.add(new ContactShare(
                ContactId = gestor.Id,
                UserOrGroupId = operador.Id,
                ContactAccessLevel = 'Read'
            ));
            contactShares.add(new ContactShare(
                ContactId = colaborador.Id,
                UserOrGroupId = operador.Id,
                ContactAccessLevel = 'Read'
            ));
            
            insert accountShares;
            insert contactShares;

            // Crear Group Share para CC_Grupo_Colaborador__c
            List<CC_Grupo_Colaborador__Share> grupoShares = new List<CC_Grupo_Colaborador__Share>();
            
            CC_Grupo_Colaborador__Share grupoShare = new CC_Grupo_Colaborador__Share(
                ParentId = grupoColaborador.Id,
                UserOrGroupId = operador.Id,
                AccessLevel = 'Read',
                RowCause = Schema.CC_Grupo_Colaborador__Share.RowCause.Manual
            );
            grupoShares.add(grupoShare);
            insert grupoShares;
        }
    }

    @isTest
    static void testEmailResponderClienteCBP() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        System.runAs(operador) {
            List<Case> casos = [SELECT Id, Subject, ContactId, AccountId, OwnerId FROM Case WHERE Subject = 'Caso Test NoInTouch' LIMIT 1];
            System.assert(!casos.isEmpty(), 'No se encontró el caso de test');
            Case casoNoInTouch = casos[0];

            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT  CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
            String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;

            Map<String, String> params = new Map<String, String>();
            params.put('[Test]', 'Valor');

            Test.startTest();
            CC_Gestion_Derivar_CBP.emailResponderClienteCBP(
                casoNoInTouch,
                'CBP Connecta',
                'Plantilla CBP',
                params,
                emailCorreoEntrante
            );
            Test.stopTest();
        }
    }
}