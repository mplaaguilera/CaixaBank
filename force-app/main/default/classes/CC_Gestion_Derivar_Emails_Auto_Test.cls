@isTest
private class CC_Gestion_Derivar_Emails_Auto_Test {

    @testSetup
    static void setup() {

        User admin = CC_TestDataFactory.insertUserAdmin();
        User operador = CC_TestDataFactory.insertUserOperadorCliente('000001');

        System.runAs(admin){

            Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtCentroId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');


            Account centro = new Account();
            centro.Name = 'Centro Caixabank 001';
            centro.CC_Email__c = 'test@test.com';
            centro.CC_Numero_Oficina_Empresa__c = '000-14141';
            centro.CC_Tipo_Oficina__c = 'I';
            centro.CC_Numero_Empresa__c  = '001';
            centro.CC_Tipo_Centro__c = 'OF';
            centro.CC_Numero_Oficina__c = '09917';
            centro.RecordtypeId = rtCentroId;
            insert centro;

            Id recordTypeGrupoColaborador =  Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();

            CC_Grupo_Colaborador__c grupoColaborador  = new CC_Grupo_Colaborador__c();
            grupoColaborador.RecordTypeId = recordTypeGrupoColaborador;
            grupoColaborador.Name = 'Amenazas empleados';
            grupoColaborador.OS_Negocio__c = 'CC';
            insert grupoColaborador;

            Contact contactoEmple1 = new Contact();
            contactoEmple1.LastName = 'Contacto empleado';
            contactoEmple1.FirstName = 'Prueba empleado';
            contactoEmple1.CC_Inactivo__c = false;
            contactoEmple1.Email = 'test@test.com';
            contactoEmple1.CC_Matricula__c = 'U0124112';
            contactoEmple1.AccountId = centro.Id;
            contactoEmple1.AV_DescFuncion__c = 'DIRECCION';
            contactoEmple1.AccountId = centro.Id;
            contactoEmple1.RecordtypeId =  rtEmpleado;
            contactoEmple1.CC_Num_Empleado_Generico__c = '12345';
            insert contactoEmple1;

            Contact contactoEmple = new Contact();
            contactoEmple.LastName = 'Contacto empleado';
            contactoEmple.FirstName = 'Prueba empleado';
            contactoEmple.CC_Inactivo__c = false;
            contactoEmple.Email = 'test2@test.com';
            contactoEmple.CC_Matricula__c = 'U0124113';
            contactoEmple.AccountId = centro.Id;
            contactoEmple.AV_DescFuncion__c = 'DIRECCION';
            contactoEmple.AccountId = centro.Id;
            contactoEmple.RecordtypeId =  rtEmpleado;
            contactoEmple.CC_Num_Empleado_Generico__c = '12945';
            insert contactoEmple;

            Account cuentaImagin1 = new Account(
                FirstName = 'Cuenta Test',
                LastName = 'test',
                CC_Email__c = 'cuenta@test.com',
                AV_IndicadoresClientes__c = '28',
                AV_EAPGestor__c = contactoEmple1.Id,
                AV_OficinaPrincipal__c = centro.Id,
                CC_Numero_Documento__c = '45729937A',
                AV_Cliente__c = true,
                AV_NumPerso__c = '214622853',
                PersonMobilePhone = '666666666',
                RecordtypeId =  rtClientePA,
                CC_Numero_Oficina__c = '16987',
                CC_Direccion_Territorial__c = centro.Id
                );
            insert cuentaImagin1;

            Account cuentaImagin = new Account(
                FirstName = 'Cuenta Test',
                LastName = 'test',
                CC_Email__c = 'cuenta2@test.com',
                AV_IndicadoresClientes__c = '28',
                AV_EAPGestor__c = contactoEmple.Id,
                AV_OficinaPrincipal__c = centro.Id,
                CC_Numero_Documento__c = '45720937A',
                AV_Cliente__c = true,
                PersonMobilePhone = '666966666',
                RecordtypeId =  rtClientePA,
                CC_Numero_Oficina__c = '09917'
                );
            insert cuentaImagin;

            Case testCase = new Case(
                Subject='Test Case',
                recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                Origin = 'Email',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Tipo_Contacto__c = 'Consulta',
                OwnerId = operador.Id,
                AccountId = cuentaImagin1.Id,
                Status = 'Activo'
            );
            insert testCase;

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

            CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
            valor1.Name = 'Nombre Plantilla Amenazas Empleados';
            valor1.RecordTypeId = recordTypeValor;
            valor1.CC_Lista__c = listaDerivar.Id;
            valor1.CC_Mensajes_Mostrar__c = 'Amenazas empleados';
            valores.add(valor1);

            
            CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
            valor2.Name = 'Nombre Plantilla Amenazas Suicidios';
            valor2.RecordTypeId = recordTypeValor;
            valor2.CC_Lista__c = listaDerivar.Id;
            valor2.CC_Mensajes_Mostrar__c = 'Amenazas Suicidios';
            valores.add(valor2);
            
            CC_Lista_Valores__c valor3 = new CC_Lista_Valores__c();
            valor3.Name = 'OWA activa amenazas';
            valor3.RecordTypeId = recordTypeValor;
            valor3.CC_Lista__c = listaDerivar.Id;
            valor3.CC_Mensajes_Mostrar__c = emailCorreoEntrante;
            valores.add(valor3);

            insert valores;
        }
    }

    // @isTest
    // static void testEmailAmenazas() {
    //     Test.startTest();
    //         List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT  CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
    //         String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;

    //         Id recordTypeGrupoColaborador =  Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
    //         List <Contact> contactos = [SELECT Id, Name, Email FROM Contact WHERE FirstName = 'Prueba empleado' LIMIT 1];
    //         List<CC_Grupo_Colaborador__c> grupo =  [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'Amenazas empleados' LIMIT 1];
    //         CC_Grupo_Colaborador_Contact__c contacto = new CC_Grupo_Colaborador_Contact__c(
    //             CC_Grupo_Colaborador__c = grupo[0].Id,
    //             CC_Contacto__c = contactos[0].Id
    //         );
    //         insert contacto;
    //         List<Case> caso = [SELECT Id FROM Case WHERE Subject='Test Case' LIMIT 1];
    //         CC_Gestion_Derivar_Amenazas.operativasEmail(caso[0].Id,'test', 'tes', grupo[0].Name, 'Amenazas empleados', null, 'Amenazas empleados', emailCorreoEntrante);
    //     Test.stopTest();

    // }

    // @isTest
    // static void testEmailAmenazasSuicidios() {
    //     Test.startTest();
    //         List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT  CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
    //         String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;

    //         Id recordTypeGrupoColaborador =  Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
    //         List <Contact> contactos = [SELECT Id, Name, Email FROM Contact WHERE FirstName = 'Prueba empleado' LIMIT 1];
    //         List<CC_Grupo_Colaborador__c> grupo =  [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'Amenazas empleados' LIMIT 1];
    //         CC_Grupo_Colaborador_Contact__c contacto = new CC_Grupo_Colaborador_Contact__c(
    //             CC_Grupo_Colaborador__c = grupo[0].Id,
    //             CC_Contacto__c = contactos[0].Id
    //         );
    //         insert contacto;
    //         Map<String,String> param = new Map<String,String>();
    //         param.put('[Motivo amenaza]', 'Test');
    //         List<Case> caso = [SELECT Id FROM Case WHERE Subject='Test Case' LIMIT 1];
    //         CC_Gestion_Derivar_Amenazas.operativasEmail(caso[0].Id,'test','test', grupo[0].Name, 'Amenazas suicidios', param, 'Amenazas suicidios', emailCorreoEntrante);
    //     Test.stopTest();

    // }

    @isTest
    static void parametrizacionesRiesgoReputacionalTest(){
        Test.startTest();
            List<CC_Riesgo_Reputacional_Derivar__mdt> centros = [SELECT Id, 
            CC_Nombre_centro_riesgo_reputacional__c, 
            CC_Numero_centro_riesgo_reputacional__c, 
            CC_Nombre_direccion_territorial__c,
            CC_Numero_direccion_territorial__c
            FROM CC_Riesgo_Reputacional_Derivar__mdt];

            System.debug(JSON.serializePretty(centros));

            CC_Gestion_Derivar_Amenazas.parametrizacionesRiesgoReputacional(centros[0].CC_Numero_direccion_territorial__c);
        Test.stopTest();
    }
}