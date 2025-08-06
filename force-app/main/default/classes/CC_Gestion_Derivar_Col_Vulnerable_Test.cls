@isTest
private with sharing class CC_Gestion_Derivar_Col_Vulnerable_Test {
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
            grupoColaborador.Name = 'Atención al Cliente';
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
            cuentaNoInTouch.AV_Segmento__c = 'PIM';
            insert cuentaNoInTouch;

            Case casoNoInTouch = new Case();
            casoNoInTouch.Subject = 'Caso Test NoInTouch';
            casoNoInTouch.AccountId = cuentaNoInTouch.Id;
            casoNoInTouch.OwnerId = operador.Id;
            casoNoInTouch.RecordTypeId = recordTypeCaso;
            casoNoInTouch.Origin = 'Email';
            insert casoNoInTouch;

            // Insert colaborador y relación con grupo colaborador
            Contact colaborador = new Contact(LastName = 'Colaborador', FirstName = 'CV', Email = 'cv@prueba.com', AccountId = cuentaNoInTouch.Id, RecordTypeId = rtEmpleado);
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

            List<CC_Settings__c> listCustomSetting = new List<CC_Settings__c>();


            CC_Settings__c  customSetting = new CC_Settings__c ();
            customSetting.Name = 'CC_SegmentosTarea';
            customSetting.CC_Activa__c = true;
            customSetting.CC_Configuracion_1__c = 'PIM';
            customSetting.CC_Configuracion_2__c = 'GEM';
            customSetting.CC_Configuracion_3__c = 'MIC';
            customSetting.CC_Configuracion_4__c = 'REM';
            customSetting.CC_Configuracion_10__c = 'EFI';
            customSetting.CC_Configuracion_11__c = 'BPR';
            customSetting.CC_Configuracion_12__c = 'BPE';
            customSetting.CC_Configuracion_13__c = 'BPJ';

            listCustomSetting.add(customSetting);

            CC_Settings__c  customSetting3 = new CC_Settings__c ();
            customSetting3.Name = 'CC_OperativaOficina';
            customSetting3.CC_Activa__c = true;
            customSetting3.CC_Configuracion_1__c = 'test';
            customSetting3.CC_Configuracion_2__c = 'test';
            customSetting3.CC_Configuracion_3__c = 'test';
            customSetting3.CC_Configuracion_4__c = 'test';
            customSetting3.CC_Configuracion_6__c = 'test';
            customSetting3.CC_Configuracion_7__c = 'test';
            customSetting3.CC_Configuracion_8__c = 'test';
            customSetting3.CC_Configuracion_9__c = 'test';
            customSetting3.CC_Configuracion_10__c = 'test';
            customSetting3.CC_Configuracion_11__c = 'test';
            customSetting3.CC_Configuracion_12__c = 'test';
            customSetting3.CC_Configuracion_13__c = 'test';
            customSetting3.CC_Configuracion_14__c = 'test';
            listCustomSetting.add(customSetting3);  
            
            CC_Settings__c  customSetting4 = new CC_Settings__c ();
            customSetting4.Name = 'CC_Configuracion_Cita_Rapida';
            customSetting4.CC_Activa__c = true;
            customSetting4.CC_Configuracion_1__c = 'true';
            customSetting4.CC_Configuracion_2__c = 'TELEMATIC';
            customSetting4.CC_Configuracion_3__c = 'true';
            listCustomSetting.add(customSetting4);

            CC_Settings__c  customSetting5 = new CC_Settings__c ();
            customSetting5.Name = 'CC_OcultarModalTrasladarAmbitos';
            customSetting5.CC_Activa__c = true;
            customSetting5.CC_Configuracion_1__c = 'Argos General';
            listCustomSetting.add(customSetting5);
    
            insert listCustomSetting;

            CC_TestDataFactory.insertarLOVDerivar();
        }
    }

    @isTest
    static void testEmailResponderClienteColectivosVulnerables() {
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
            CC_Gestion_Derivar_Col_Vulnerable.emailRemitirColaboradorColectivoVulnerable(
                casoNoInTouch,
                'Atención al Cliente',
                'TEXTO REMITIDO ATENCION AL CLIENTE​',
                params,
                emailCorreoEntrante
            );
            Test.stopTest();
        }
    }

    @isTest
    static void testCrearTareaColectivosVulnerables() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        System.runAs(operador) {
            List<Case> casos = [SELECT Id, Subject, ContactId, AccountId, OwnerId FROM Case WHERE Subject = 'Caso Test NoInTouch' LIMIT 1];
            System.assert(!casos.isEmpty(), 'No se encontró el caso de test');
            Case casoNoInTouch = casos[0];
            String asunto = 'Prueba';
            String fechaActividad = CBK_UtilsDate.nowDT().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];

            Test.startTest();
            CC_Gestion_Derivar_Col_Vulnerable.crearTareaColectivosVulnerables(casoNoInTouch.Id.toString(), asunto, fechaActividad,true, centro.Id, true, contacto, true ,comentarios);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(tarea.isEmpty(), true);
            Test.stopTest();
        }
    }
}