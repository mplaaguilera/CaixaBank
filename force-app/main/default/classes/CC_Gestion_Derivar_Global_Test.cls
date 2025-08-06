@isTest
private class CC_Gestion_Derivar_Global_Test {
    @TestSetup
    static void makeData(){
        User adminUser = CC_TestDataFactory.insertUserAdmin();
        User usuarioOperador = CC_TestDataFactory.insertUserOperadorCliente('U0123456');
        System.runAs(adminUser){
            CC_TestDataFactory.insertarLOVDerivar();
            CC_TestDataFactory.insertarMCCsDerivar(usuarioOperador);

            List<CC_Settings__c> settings = new List<CC_Settings__c>();

            CC_Settings__c  modalParam = new CC_Settings__c ();
            modalParam.Name = 'CC_OcultarModalTrasladarAmbitos';
            modalParam.CC_Activa__c = true;
            modalParam.CC_Configuracion_1__c = 'Argos General';
            settings.add(modalParam);
            
            CC_Settings__c  clienteConfidencial = new CC_Settings__c ();
            clienteConfidencial.Name = 'CC_3NClienteConfidencial';
            clienteConfidencial.CC_Activa__c = false;
            settings.add(clienteConfidencial);

            CC_Settings__c circuitoMF = new CC_Settings__c ();
            circuitoMF.Name = 'CC_MecanismoFirmaCircuitoCaso';
            circuitoMF.CC_Activa__c = true;
            settings.add(circuitoMF);

            insert settings;

        } 
    }

    @isTest
    static void testRellenarDatosFraude() {
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            // Create test data

            CC_Settings__c setting = new CC_Settings__c();
            setting.Name = 'CC_GruposColaboradoresFraude';
            setting.CC_Configuracion_1__c = 'true';
            setting.CC_Configuracion_2__c = 'true';
            insert setting;

            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();
            textosMap.put('Toast remitir desde guardar', 'Toast remitir desde guardar');
            textosMap.put('Pregunta señal', 'Pregunta señal');
            textosMap.put('Pregunta realizar remitido', 'Pregunta realizar remitido');
            textosMap.put('Toast remitir', 'Toast remitir');
            textosMap.put('Pregunta motivo devolucion tema fraude', 'Pregunta motivo devolucion tema fraude');

            // Set ambitoMotivo to 'Caso a Fraude'
            retorno.put('ambitoMotivo', 'Caso a Fraude');
            Test.startTest();
                // Run the method under test
                CC_Gestion_Derivar_Global.rellenarDatosFraude(retorno, textosMap);

                // Verify the results
                // System.assertEquals('Toast remitir desde guardar', retorno.get('toastTrasladarDesdeDerivar'), 'Toast remitir desde guardar should be set');
                System.assertEquals('Pregunta señal', retorno.get('preguntaSenal'), 'Pregunta señal should be set');
                // System.assertEquals('Pregunta realizar remitido', retorno.get('preguntaRealizarRemitido'), 'Pregunta realizar remitido should be set');
                System.assertEquals('Toast remitir', retorno.get('toastRemitir'), 'Toast remitir should be set');

                // Set ambitoMotivo to 'Bizum Fraude'
                retorno.put('ambitoMotivo', 'Bizum Fraude');

                // Run the method under test
                CC_Gestion_Derivar_Global.rellenarDatosFraude(retorno, textosMap);

                // Verify the results
                System.assertEquals('Pregunta motivo devolucion tema fraude', retorno.get('motivoDevolucionTemaFraude'), 'Pregunta motivo devolucion tema fraude should be set');
            Test.stopTest();
        }
       
    }

    @isTest
    static void rellenarDatosDocumentacionTest(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Test.startTest();
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');

            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();
            retorno.put('imagin', false);
            textosMap.put('Pregunta información requerida documentación', 'Pregunta información requerida documentación');
            textosMap.put('Modal documentación caso creado', 'Modal documentación caso creado');
            textosMap.put('Toast documentación caso creado', 'Toast documentación caso creado');
            textosMap.put('Documentacion certificado caixa', 'CSBD');
            textosMap.put('Toast CSBD No Contratar', 'Toast CSBD No Contratar');
            textosMap.put('Texto Oportunidad Existente', 'Texto Oportunidad Existente');

            Account cuentaCaixa = new Account();
            cuentaCaixa.LastName = 'Cliente Senior';
            cuentaCaixa.CC_NumPerso__c = '0000015';
            cuentaCaixa.RecordtypeId =  rtClientePA;
            cuentaCaixa.CC_Numero_Documento__c = '45729937A';
            cuentaCaixa.AV_Cliente__c = false;
            insert cuentaCaixa;
            
            Case caso = new Case(
                Description = 'casoDocumentacionNoImagin',
                Subject = 'casoDocumentacionNoImagin',
                Origin = 'Phone',
                Status = 'Activo',
                accountId = cuentaCaixa.Id,
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );
            insert caso;

            CC_Gestion_Derivar_Global.rellenarDatosDocumentacion(caso, retorno, textosMap);

            System.assertEquals(textosMap.get('Documentacion certificado caixa'), retorno.get('documentacionDecisionCaixa'), 'documentacionDecisionCaixa should be set');

            Test.stopTest();
        }
    }

    @isTest
    static void testRellenarDatosFraudeSolucion(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            // Create test data

            CC_Settings__c setting = new CC_Settings__c();
            setting.Name = 'CC_GruposColaboradoresFraude';
            setting.CC_Configuracion_1__c = 'true';
            setting.CC_Configuracion_2__c = 'true';
            insert setting;

            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();
            textosMap.put('Pregunta señal Antigua', 'Pregunta señal Antigua');
            textosMap.put('Pregunta realizar remitido', 'Pregunta realizar remitido');
            textosMap.put('Toast remitir', 'Toast remitir');

            Test.startTest();
                // Run the method under test
                CC_Gestion_Derivar_Global.rellenarDatosFraudeSolucion(retorno, textosMap);

                // Verify the results
                System.assertEquals('Pregunta señal Antigua', retorno.get('preguntaSenalAntigua'), 'Pregunta señal should be set');
                System.assertEquals('Toast remitir', retorno.get('toastRemitir'), 'Toast remitir should be set');

            Test.stopTest();
        }
    }

    @isTest
    static void testRellenarDatosCliente(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){

            Map<String, Object> retorno = new Map<String, Object>();

            Test.startTest();
                CC_Gestion_Derivar_Global.rellenarDatosCliente(retorno);
                System.assertEquals(true, retorno.get('cambioOficina'), 'Cambio oficina should be true');
                System.assertEquals(true, retorno.get('mostrarModalCreacionTarea'), 'mostrarModalCreacionTarea should be true');
            Test.stopTest();
        }
    }

    @isTest
    static void rellenarDatosClienteConfidencialTest(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');

            Map<String, Object> retorno = new Map<String, Object>();

            retorno.put('3NClienteConfidencial', false);

            Map<String, Object> textosMap = new Map<String, Object>();
            textosMap.put('Toast CSBD No Contratar cliente confidencial', 'Toast CSBD No Contratar cliente confidencial');
            textosMap.put('Texto motivo CSBD No Contratar cliente confidencial', 'Texto motivo CSBD No Contratar cliente confidencial');
            textosMap.put('Texto Oportunidad Existente', 'Texto Oportunidad Existente');

            Account cuentaCaixa = new Account();
            cuentaCaixa.LastName = 'Cliente Senior';
            cuentaCaixa.CC_NumPerso__c = '0000015';
            cuentaCaixa.RecordtypeId =  rtClientePA;
            cuentaCaixa.CC_Numero_Documento__c = '45729937A';
            cuentaCaixa.AV_Cliente__c = false;
            insert cuentaCaixa;
            
            Case casoDocumentacionNoImagin = new Case(
                Description = 'casoDocumentacionNoImagin',
                Subject = 'casoDocumentacionNoImagin',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuentaCaixa.Id,
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );
            insert casoDocumentacionNoImagin;
                        
            
            CC_Settings__c  gestorPool = new CC_Settings__c ();
            gestorPool.Name = 'CC_Configuracion_Cita_Rapida';
            gestorPool.CC_Activa__c = false;
            insert gestorPool;

            Test.startTest();
                CC_Gestion_Derivar_Global.rellenarDatosClienteConfidencial(retorno, textosMap, casoDocumentacionNoImagin, 'Gestor generico', CC_Settings__c.getValues('CC_Configuracion_Cita_Rapida'));
                System.assertEquals(textosMap.get('Texto motivo CSBD No Contratar cliente confidencial'), retorno.get('textoMotivoCSBDNoContratar'), 'Texto motivo CSBD No Contratar cliente confidencial not found');
                System.assertEquals(true, retorno.get('ambitoCSBD'), 'ambitoCSBD is false');

            Test.stopTest();
        }
    }

    @isTest
    static void testRellenarDatosAmbitoAccionistas(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');

            Map<String, Object> retorno = new Map<String, Object>();

            Map<String, Object> textosMap = new Map<String, Object>();
            textosMap.put('Mensaje derivar accionistas', 'Mensaje derivar accionistas');

            Account cuentaCaixa = new Account();
            cuentaCaixa.LastName = 'Cliente Senior';
            cuentaCaixa.CC_NumPerso__c = '0000015';
            cuentaCaixa.RecordtypeId =  rtClientePA;
            cuentaCaixa.CC_Numero_Documento__c = '45729937A';
            cuentaCaixa.AV_Cliente__c = false;
            insert cuentaCaixa;
            
            Case casoDocumentacionNoImagin = new Case(
                Description = 'casoDocumentacionNoImagin',
                Subject = 'casoDocumentacionNoImagin',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuentaCaixa.Id,
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );
            insert casoDocumentacionNoImagin;

            Test.startTest();
                CC_Gestion_Derivar_Global.rellenarDatosAmbitoAccionistas(casoDocumentacionNoImagin, retorno, textosMap);
                System.assertEquals(textosMap.get('Mensaje derivar accionistas'), retorno.get('mensajeDerivarAccionistas'), 'Mensaje derivar accionistas not found');
            Test.stopTest();
        }
    }

    
    @isTest
    static void testRellenarDatosOficinaNull(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){

            CC_Settings__c setting = new CC_Settings__c();
            setting.Name = 'CC_consultarGestorPool';
            setting.CC_Configuracion_3__c = 'false';
            setting.CC_Configuracion_2__c = 'true';
            insert setting;

            Map<String, Object> retorno = new Map<String, Object>();
            retorno.put('imagin', true);
            Map<String, Object> textosMap = new Map<String, Object>();


            Test.startTest();
                CC_Gestion_Derivar_Global.rellenarDatosOficinaNull(retorno, setting);
                System.assertEquals(true, retorno.get('mostrarModalCreacionTarea'), 'mostrarModalCreacionTarea should be true');
            Test.stopTest();
        }
    }

        
    @isTest
    static void testRellenarDatosAmenazasTest(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){

            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();

            textosMap.put('Mensaje derivacion amenazas tipo', 'Mensaje derivacion amenazas tipo');
            textosMap.put('Mensaje solicitud datos amenazas suicidios', 'Mensaje solicitud datos amenazas suicidios');
            textosMap.put('Mensaje email enviado OK', 'Mensaje email enviado OK');
            textosMap.put('Nombre Plantilla Amenazas Suicidios', 'Nombre Plantilla Amenazas Suicidios');
            textosMap.put('Mensaje solicitud datos amenazas empleados', 'Mensaje solicitud datos amenazas empleados');
            textosMap.put('Nombre Plantilla Amenazas Empleados', 'Nombre Plantilla Amenazas Empleados');
            textosMap.put('Mensaje solicitud datos amenazas empleados', 'Mensaje solicitud datos amenazas empleados');
            textosMap.put('Nombre Plantilla Amenazas Empleados', 'Nombre Plantilla Amenazas Empleados');

            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');

            List<CC_Settings__c> settings = new List<CC_Settings__c>();
            CC_Settings__c setting = new CC_Settings__c();
            setting.Name = 'CC_GruposColaboradoresParamDerivar';
            setting.CC_Configuracion_1__c = 'test';
            setting.CC_Configuracion_2__c = 'true';
            settings.add(setting);

            CC_Settings__c settingOwa = new CC_Settings__c();
            settingOwa.Name = 'CC_OWA_Por_Defecto_Email_Automatico';
            settingOwa.CC_Configuracion_1__c = 'test@test.com';
            settings.add(settingOwa);

            insert settings;
            
            Case casoDocumentacionNoImagin = new Case(
                Description = 'casoDocumentacionNoImagin',
                Subject = 'casoDocumentacionNoImagin',
                Origin = 'Email',
                Status = 'Activo',
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );
            insert casoDocumentacionNoImagin;


            Test.startTest();
                CC_Gestion_Derivar_Global.rellenarDatosAmenazas(casoDocumentacionNoImagin, retorno, textosMap);
                System.assertEquals(settingOwa.CC_Configuracion_1__c , retorno.get('nameOWA'), 'CC_OWA_Por_Defecto_Email_Automatico error');
            Test.stopTest();
        }
    }

    @isTest
    static void testRellenarDatosVentaOficina(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){

            Map<String, Object> retorno = new Map<String, Object>();
            retorno.put('imagin', true);

            Test.startTest();
                CC_Gestion_Derivar_Global.rellenarDatosVentaOficina(retorno);
                System.assertEquals(true, retorno.get('mostrarModalCreacionTarea'), 'mostrarModalCreacionTarea should be true');
            Test.stopTest();
        }
    }


    // @isTest
    // static void testRellenarDatosCambioOficina(){


    //     System.runAs(CC_TestDataFactory.getUserAdmin()){
                    
    //         Id rtCentroId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');

    //         Account centroCaixa = new Account();
    //         centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
    //         centroCaixa.CC_Numero_Oficina_Empresa__c = '001-00615';
    //         centroCaixa.CC_Numero_Oficina__c = '00615';
    //         centroCaixa.RecordTypeId = rtCentroId;
    //         insert centroCaixa;

    //         Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
    //         Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');

    //         Account cuentaCaixa = new Account();
    //             cuentaCaixa.LastName = 'Cliente Senior';
    //             cuentaCaixa.CC_NumPerso__c = '0000015';
    //             cuentaCaixa.AV_OficinaPrincipal__c = [SELECT Id FROM Account WHERE Name = '00615 STORE DOS DE MAIG-ROSSELLO' LIMIT 1].Id;
    //             cuentaCaixa.RecordtypeId =  rtClientePA;
    //             cuentaCaixa.CC_Numero_Documento__c = '45729937A';
    //             cuentaCaixa.AV_Cliente__c = true;
    //         insert cuentaCaixa;
            
    //         Case casoDocumentacionNoImagin = new Case(
    //             Description = 'casoDocumentacionNoImagin',
    //             Subject = 'casoDocumentacionNoImagin',
    //             Origin = 'Email',
    //             Status = 'Activo',
    //             accountId = cuentaCaixa.Id,
    //             CC_Idioma__c = 'es',
    //             CC_Canal_Respuesta__c = 'Email',
    //             CC_Tipo_Contacto__c = 'Consulta',
    //             CC_Canal_Procedencia__c = 'Formulario web',
    //             CC_Detalles_Consulta__c = 'Caso de Contact Center',
    //             RecordTypeId = recordTypeCaso
    //         );

    //         insert casoDocumentacionNoImagin;

    //         Map<String, Object> retorno = new Map<String, Object>();
    //         Map<String, Object> textosMap = new Map<String, Object>();
    //         textosMap.put('Comentario cambio oficina', 'El cliente [nombre], [apellidos], [dni] solicita el cambio de oficina de la [oficina origen] a la [oficina destino]. Os recordamos que la oficina destino debe dar de alta el CEM correspondiente, que puede ser revisado por la oficina origen. Por favor, contactad con el cliente cuando finalice la gestión.');

    //         Test.startTest();
    //             CC_Gestion_Derivar_Global.rellenarDatosCambioOficina(casoDocumentacionNoImagin, retorno, textosMap);
    //             System.assertEquals(true, retorno.get('cambioOficina'), 'cambioOficina should be set');
    //             System.assertEquals(true, retorno.get('mostrarModalCreacionTarea'), 'mostrarModalCreacionTarea should be set');

    //         Test.stopTest();
    //     }
    // }

    // @isTest
    // static void testRellenarDatosCambioGestor(){

    //     System.runAs(CC_TestDataFactory.getUserAdmin()){

    //         Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
    //         Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
    //         Id rtCentroId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');

    //         Account centroCaixa = new Account();
    //         centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
    //         centroCaixa.CC_Numero_Oficina_Empresa__c = '001-00615';
    //         centroCaixa.CC_Numero_Oficina__c = '00615';
    //         centroCaixa.RecordTypeId = rtCentroId;
    //         insert centroCaixa;

    //         Account cuentaCaixa = new Account();
    //             cuentaCaixa.LastName = 'Cliente Senior';
    //             cuentaCaixa.CC_NumPerso__c = '0000015';
    //             cuentaCaixa.AV_OficinaPrincipal__c = centroCaixa.Id;
    //             cuentaCaixa.RecordtypeId =  rtClientePA;
    //             cuentaCaixa.CC_Numero_Documento__c = '45729937A';
    //             cuentaCaixa.AV_Cliente__c = true;
    //         insert cuentaCaixa;
            
    //         Case casoDocumentacionNoImagin = new Case(
    //             Description = 'casoDocumentacionNoImagin',
    //             Subject = 'casoDocumentacionNoImagin',
    //             Origin = 'Email',
    //             Status = 'Activo',
    //             accountId = cuentaCaixa.Id,
    //             CC_Idioma__c = 'es',
    //             CC_Canal_Respuesta__c = 'Email',
    //             CC_Tipo_Contacto__c = 'Consulta',
    //             CC_Canal_Procedencia__c = 'Formulario web',
    //             CC_Detalles_Consulta__c = 'Caso de Contact Center',
    //             RecordTypeId = recordTypeCaso
    //         );

    //         insert casoDocumentacionNoImagin;

    //         Map<String, Object> retorno = new Map<String, Object>();
    //         Map<String, Object> textosMap = new Map<String, Object>();
    //         textosMap.put('Comentario cambio gestor', 'El cliente [nombre], [apellidos], [dni] solicita el cambio de gestor. Solicitamos que se gestione la petición de acuerdo con la política comercial de la entidad. Por favor, contactad con el cliente cuando finalice la gestión.');

    //         Test.startTest();
    //         try {
    //             CC_Gestion_Derivar_Global.rellenarDatosCambioGestor(casoDocumentacionNoImagin, retorno, textosMap);
    //             System.assertEquals(true, retorno.get('cambioGestor'), 'cambioGestor should be set');
    //             System.assertEquals(true, retorno.get('mostrarModalCreacionTarea'), 'mostrarModalCreacionTarea should be set');
    //         } catch (Exception e) {
    //             throw new AuraHandledException('Error');
    //         }
    //         Test.stopTest();
    //     }
    // }

    @isTest
    static void testRellenarDatosGrupoColaborador() {

        System.runAs(CC_TestDataFactory.getUserAdmin()){
            // Create test data
            Id recordTypeGrupoColaborador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Tercer_Nivel');
            CC_Grupo_Colaborador__c	grupo = new CC_Grupo_Colaborador__c();
            grupo.RecordTypeId = recordTypeGrupoColaborador;
            grupo.name = '3N de CSBD';
            grupo.OS_Negocio__c = 'CC';
            grupo.CC_Queue_Traslado__c = 'Cola_3N_CSBD';
            grupo.CC_Tipo__c = 'Traslados';
            insert grupo;

            CC_MCC_Grupo_Colaborador__c grupoColaboradorMCC = new CC_MCC_Grupo_Colaborador__c();
            grupoColaboradorMCC.CC_MCC__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'CSBD 3N' AND RecordType.DeveloperName = 'CC_Motivo' LIMIT 1].Id;
            grupoColaboradorMCC.CC_Grupo_Colaborador__c = grupo.Id;
            grupoColaboradorMCC.Name = 'Grupo Colaborador MCC';
            insert grupoColaboradorMCC;

            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();
            textosMap.put('Pregunta traslado colaborador', 'Pregunta traslado colaborador');
            textosMap.put('Toast trasladar desde guardar', 'Toast trasladar desde guardar');
            retorno.put('preguntaTrasladarDocumentacion', true);
            Test.startTest();
                // Run the method under test
                List<CC_MCC_Grupo_Colaborador__c> listaGrupoColaborador = new List<CC_MCC_Grupo_Colaborador__c>{grupoColaboradorMCC};
                CC_Gestion_Derivar_Global.rellenarDatosGrupoColaborador(listaGrupoColaborador, retorno, textosMap);            
            Test.stopTest();

            // Verify the results
            System.assertEquals('Pregunta traslado colaborador', retorno.get('preguntaGrupoColaborador'), 'Pregunta traslado colaborador should be set');
            System.assertEquals('Toast trasladar desde guardar', retorno.get('toastTrasladarDesdeDerivar'), 'Toast trasladar desde guardar should be set');
            System.assertNotEquals(null, retorno.get('grupoColaborador'), 'Grupo colaborador should be set');
        }
      
    }

    
    @isTest
    static void testRellenarDatosCajeros(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){

            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();
            textosMap.put('Pregunta cajeros', 'Pregunta cajeros');
            textosMap.put('Pregunta cajero externalizado', 'Pregunta cajero externalizado');
            textosMap.put('Toast cajero externalizado', 'Toast cajero externalizado');

            Test.startTest();
                // Run the method under test
                CC_Gestion_Derivar_Global.rellenarDatosCajeros(retorno, textosMap);

                // Verify the results
                System.assertEquals('Pregunta cajeros', retorno.get('preguntaCajeros'), 'preguntaCajeros should be set');
                System.assertEquals('Pregunta cajero externalizado', retorno.get('preguntaCajerosExternos'), 'preguntaCajerosExternos should be set');
                System.assertEquals('Toast cajero externalizado', retorno.get('toastCajerosExternos'), 'toastCajerosExternos should be set');


            Test.stopTest();
        }
    }

    @isTest
    static void testRellenarMecanismoFirmaNoTask(){

        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();

            textosMap.put('Pregunta mecanismo firma datos preguntas', 'Pregunta mecanismo firma datos preguntas');
            textosMap.put('Pregunta mecanismo firma', 'Pregunta mecanismo firma');
            textosMap.put('Pregunta mecanismo firma datos', 'Pregunta mecanismo firma datos');
            textosMap.put('Toast mecanismo firma caso creado', 'Toast mecanismo firma caso creado');
            textosMap.put('Toast mecanismo firma datos incompletos','Toast mecanismo firma datos incompletos');
            textosMap.put('Toast  mecanismo firma argos correcto', 'Toast  mecanismo firma argos correcto');
            textosMap.put('Toast mecanismo firma identificador no bloqueado', 'Toast mecanismo firma identificador no bloqueado');
            textosMap.put('Toast mecanismo firma identificador bloqueado', 'Toast mecanismo firma identificador bloqueado');
            textosMap.put('Pregunta mecanismo firma identificador', 'Pregunta mecanismo firma identificador');

            Test.startTest();

            CC_Settings__c configuracion = new CC_Settings__c (
                Name = 'CC_MecanismoFirmaCircuitos',
                CC_Configuracion_1__c = 'true',
                CC_Configuracion_2__c = 'false'
            );

            insert configuracion;

            Account cuentaCaixa = new Account();
            cuentaCaixa.LastName = 'Cliente Senior';
            cuentaCaixa.CC_NumPerso__c = '0000015';
            cuentaCaixa.RecordtypeId =  rtClientePA;
            cuentaCaixa.CC_Numero_Documento__c = '45729937A';
            cuentaCaixa.AV_Cliente__c = true;
            insert cuentaCaixa;
            
            Case casoDocumentacionNoImagin = new Case(
                Description = 'casoDocumentacionNoImagin',
                Subject = 'casoDocumentacionNoImagin',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuentaCaixa.Id,
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );
            insert casoDocumentacionNoImagin;
            
            CC_Gestion_Derivar_Global.rellenarDatosMecanismoFirma(casoDocumentacionNoImagin, retorno, textosMap);

            System.assertEquals('Pregunta mecanismo firma', retorno.get('preguntaMecanismoFirma'), 'preguntaMecanismoFirma should be set');

            Test.stopTest();
        }
    }

    @isTest
    static void testRellenarMecanismoFirmaTask(){

        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();

            textosMap.put('Pregunta mecanismo firma datos preguntas', 'Pregunta mecanismo firma datos preguntas');
            textosMap.put('Toast mecanismo firma asunto envio codigo', 'Toast mecanismo firma asunto envio codigo');
            textosMap.put('Pregunta mecanismo firma cliente autenticado', 'Pregunta mecanismo firma cliente autenticado');

            Test.startTest();
            List<CC_Settings__c> configuraciones = new List<CC_Settings__c>();

            CC_Settings__c configuracion2 = new CC_Settings__c (
                Name = 'CC_GruposColaboradoresMecanismoFirma',
                CC_Configuracion_1__c = 'A',
                CC_Configuracion_2__c = 'B'
            );
            configuraciones.add(configuracion2);
            insert configuraciones;

            Account cuentaCaixa = new Account();
            cuentaCaixa.LastName = 'Cliente Senior';
            cuentaCaixa.CC_NumPerso__c = '0000015';
            cuentaCaixa.RecordtypeId =  rtClientePA;
            cuentaCaixa.CC_Numero_Documento__c = '45729937A';
            cuentaCaixa.AV_Cliente__c = true;
            insert cuentaCaixa;
            
            Case casoDocumentacionNoImagin = new Case(
                Description = 'casoDocumentacionNoImagin',
                Subject = 'casoDocumentacionNoImagin',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuentaCaixa.Id,
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );

            CBK_Case_Extension__c extension = new CBK_Case_Extension__c(
                Case_Id__c = casoDocumentacionNoImagin.Id,
                CC_MecanismoFirma__c = true
            );
            insert extension;

            casoDocumentacionNoImagin.CBK_Case_Extension_Id__c = extension.Id;
            insert casoDocumentacionNoImagin;

            Task tarea = new Task (
                WhatId = [SELECT Id FROM Case WHERE Subject = 'casoDocumentacionNoImagin' LIMIT 1][0].Id,
                Subject = 'true',
                Type = 'Mecanismo de firma'
            );

            insert tarea;

            CC_Gestion_Derivar_Global.rellenarDatosMecanismoFirma(casoDocumentacionNoImagin, retorno, textosMap);

            System.assertEquals('Pregunta mecanismo firma cliente autenticado', retorno.get('preguntaMecanismoFirmaClienteAutenticado'), 'preguntaMecanismoFirmaClienteAutenticado should be set');

            Test.stopTest();
        }
    }


    @isTest
    static void testRellenarDatosCajerosIncidencias() {
        System.runAs(CC_TestDataFactory.getUserAdmin()){

            //test data
            Account testAccount = new Account(
                Name = 'Test Account',
                CC_Numero_Documento__c = '12345678X'
            );
            insert testAccount;
    
            Asset testAsset = new Asset(
                Name = 'Test Asset',
                SerialNumber = '12345',
                AccountId = testAccount.Id
            );
            insert testAsset;
    
            Case testCaseWithAsset = new Case(
                Origin = 'Phone',
                Status = 'New',
                Subject = 'Test Case with Asset',
                AssetId = testAsset.Id,
                AccountId = testAccount.Id
            );
            insert testCaseWithAsset;
    
            Case testCaseWithoutAsset = new Case(
                Origin = 'Phone',
                Status = 'New',
                Subject = 'Test Case without Asset',
                AccountId = testAccount.Id
            );
            insert testCaseWithoutAsset;
    
            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();
            textosMap.put('Error Incidencias Cajeros', 'Error: Incidencias Cajeros');
            textosMap.put('Titulo Error Incidencias Cajeros', 'Titulo: Error Incidencias Cajeros');
            Test.startTest();
            // Run the method under test with a case that has an asset
                CC_Gestion_Derivar_Global.rellenarDatosCajerosIncidencias(testCaseWithAsset, retorno, textosMap);
        
                // Verify the results
                System.assertEquals(true, retorno.get('flowDerivar'), 'Flow Derivar should be true for case with asset');
        
                // Run the method under test with a case that does not have an asset
                CC_Gestion_Derivar_Global.rellenarDatosCajerosIncidencias(testCaseWithoutAsset, retorno, textosMap);
        
                // Verify the results
                System.assertEquals('Error: Incidencias Cajeros', retorno.get('toastCajerosIncidencias'), 'Error message should be set for case without asset');
                System.assertEquals('Titulo: Error Incidencias Cajeros', retorno.get('tituloCajerosIncidencias'), 'Error title should be set for case without asset');
            Test.stopTest();
        }   
      
    }

    @isTest
    static void rellenarDatosSACTest() {
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            //test data
            Test.startTest();
                CC_MCC__c sac = new CC_MCC__c(
                Name = 'sac',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
                CC_Ambito_Tareas_Caixa__c = 'SAC',
                CC_Ambito_Tareas_Imagin__c = 'SAC',
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Codigo_Externo__c = 'MO-000026'
                );
                insert sac;

                Case casoDerivarSAC = new Case(
                Description = 'casoDerivarSAC',
                Subject = 'casoDerivarSAC',
                Origin = 'Email',
                Status = 'Activo',
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_MCC_Motivo__c = sac.Id,
                CC_Motivo__c = 'casoDerivarSAC',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente')
                );
                insert casoDerivarSAC;

                CC_DevolverDerivarSAC__c  cssac = new CC_DevolverDerivarSAC__c ();
                cssac.Name = 'CC_Derivar';
                cssac.CC_Activo__c = true;
                insert cssac;
        
                Map<String, Object> retorno = new Map<String, Object>();
                Map<String, Object> textosMap = new Map<String, Object>();
                textosMap.put('Derivar al SAC', 'derivar sac');
                textosMap.put('Devolver al SAC', 'devolver sac');
                
                CC_Gestion_Derivar_Global.rellenarDatosSAC(casoDerivarSAC, retorno, textosMap);
        
                System.assertEquals(retorno.get('mostrarDerivarSAC'), true, 'No se muestra derivar al sac');
            Test.stopTest();
        }
    }

    @isTest
    static void rellenarDatosSACTest2() {
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            //test data
            Test.startTest();
                CC_MCC__c sac = new CC_MCC__c(
                Name = 'sac',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
                CC_Ambito_Tareas_Caixa__c = 'SAC',
                CC_Ambito_Tareas_Imagin__c = 'SAC',
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Codigo_Externo__c = 'MO-000026'
                );
                insert sac;

                Case casoDerivarSAC = new Case(
                Description = 'casoDerivarSAC',
                Subject = 'casoDerivarSAC',
                Origin = 'Email',
                Status = 'Activo',
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_MCC_Motivo__c = sac.Id,
                CC_Motivo__c = 'casoDerivarSAC',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Accionista',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente')
                );
                insert casoDerivarSAC;

                CC_DevolverDerivarSAC__c  cssac = new CC_DevolverDerivarSAC__c ();
                cssac.Name = 'CC_Derivar';
                cssac.CC_Activo__c = true;
                insert cssac;
        
                Map<String, Object> retorno = new Map<String, Object>();
                Map<String, Object> textosMap = new Map<String, Object>();
                textosMap.put('Derivar al SAC', 'derivar sac');
                textosMap.put('Devolver al SAC', 'devolver sac');
                textosMap.put('Derivar al SAC canal procedencia erroneo', 'Test mensaje error');
                
                CC_Gestion_Derivar_Global.rellenarDatosSAC(casoDerivarSAC, retorno, textosMap);
        
                System.assertEquals(retorno.get('mensajeCanalProcedenciaErroneo'), 'Test mensaje error', 'No se muestra derivar al sac');
            Test.stopTest();
        }
    }

    static void rellenarDatosRefinanciacionDeudasTest(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){

            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();

            textosMap.put('Final Operativa', 'Final Operativa');
            textosMap.put('Texto tarea AV Pool = True', 'Texto tarea AV Pool = True');
            textosMap.put('Texto tarea AV Pool = False', 'Texto tarea AV Pool = False');
            textosMap.put('Pregunta números de contrato', 'Pregunta números de contrato');


            Test.startTest();
                CC_Gestion_Derivar_Global.rellenarDatosRefinanciacionDeudas(retorno, textosMap);
                System.assertEquals(textosMap.get('Final Operativa'), retorno.get('Final Operativa'), 'Final Operativa should be true');
            Test.stopTest();
        }
    }

    @isTest
    static void recuperarArgosTest(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Test.startTest();
            Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            List<Case> casosArgos = new List<Case>();
            List<CBK_Case_Extension__c> caseExArgos = new List<CBK_Case_Extension__c>();

            Account cuentaCaixa = new Account();
            cuentaCaixa.Name = 'Cliente Senior';
            cuentaCaixa.CC_NumPerso__c = '0000015';
            cuentaCaixa.RecordtypeId =  rtCliente;
            cuentaCaixa.CC_Numero_Documento__c = '45729937A';
            cuentaCaixa.AV_Cliente__c = false;
            insert cuentaCaixa;
            
            Contact contacto = new Contact(
                LastName = 'Cliente Senior',
                AccountId = cuentaCaixa.Id
            );
            insert contacto;

            Case resticted = new Case(
                Description = 'resticted',
                Subject = 'resticted',
                Origin = 'Email',
                Status = 'Activo',
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Motivo__c = 'resticted',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Accionista',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                AccountId = cuentaCaixa.Id,
                ContactId = contacto.Id
                );
            casosArgos.add(resticted);
            insert casosArgos;

            Task tarea = new Task(
                WhatId = casosArgos[0].Id,
                Subject = 'Test Task',
                CC_Detalles_Solucion__c = casosArgos[0].AccountId+ ' - ' +casosArgos[0].ContactId,
                Type = 'Argos'
            );

            insert tarea;

            List <Case> casos = [SELECT Id FROM Case WHERE Subject = 'resticted' LIMIT 1];
            CBK_Case_Extension__c restictedCBK = new CBK_Case_Extension__c(
                CC_Risk_Restricted__c = true,
                Case_Id__c = casos[0].Id
            );
            caseExArgos.add(restictedCBK);

            CBK_Case_Extension__c deniedCBK = new CBK_Case_Extension__c(
                CC_Risk_Denied__c = true,
                Case_Id__c = casos[0].Id
            );
            caseExArgos.add(deniedCBK);
            insert caseExArgos;

            Boolean retorno = CC_Gestion_Derivar_Global.recuperarArgos(casos[0].Id);
            System.assertEquals(true, retorno, 'retorno is false');
            Test.stopTest();
        }
    }

    @isTest
    static void actualizarDetallesSolucionArgosTest() {
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Test.startTest();
            Case caso = new Case(
                Description = 'resticted',
                Subject = 'resticted',
                Origin = 'Email',
                Status = 'Activo',
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Motivo__c = 'resticted',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Accionista',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente')
                );

            insert caso;

            CC_Gestion_Derivar_Global.actualizarDetallesSolucionArgos(caso.Id, 'Hola');

            String detallesSolucion = [SELECT CC_Detalles_Solucion__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_Detalles_Solucion__c;
            System.assertEquals('Hola', detallesSolucion, 'el mensaje tiene que ser Hola');
            Test.stopTest();
        }
    }

    @isTest
    static void testRellenarDatosCBP() {
         System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Test.startTest();
            Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            Map<String, Object> retorno = new Map<String, Object>();
            Map<String, Object> textosMap = new Map<String, Object>();
            textosMap.put('Pregunta números de contrato', 'Texto');
            textosMap.put('Pregunta CBP', 'Texto');

            Account cuentaCaixa = new Account();
            cuentaCaixa.Name = 'Cliente Senior';
            cuentaCaixa.CC_NumPerso__c = '0000015';
            cuentaCaixa.RecordtypeId =  rtCliente;
            cuentaCaixa.CC_Numero_Documento__c = '45729937A';
            cuentaCaixa.AV_Cliente__c = false;
            insert cuentaCaixa;


            Case caso = new Case(
                Description = 'resticted',
                Subject = 'resticted',
                Origin = 'Email',
                Status = 'Activo',
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Motivo__c = 'resticted',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Accionista',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                AccountId = cuentaCaixa.Id
                );

            insert caso;

            List<CC_Settings__c> settings = new List<CC_Settings__c>();

            CC_Settings__c setting = new CC_Settings__c(
                Name = 'CC_OWA_Por_Defecto_Email_Automatico',
                CC_Configuracion_2__c = 'contactcenter.devservice@gmail.com'
            );
            settings.add(setting);

            CC_Settings__c setting2 = new CC_Settings__c(
                Name = 'CC_GruposColaboradoresCBP',
                CC_Configuracion_1__c = 'CBP Connecta'
            );
            settings.add(setting2);

            insert settings;

            CC_Gestion_Derivar_Global.rellenarDatosCBP(caso, retorno, textosMap);

            String detallesSolucion = [SELECT CC_Detalles_Solucion__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_Detalles_Solucion__c;
            System.assertEquals('Texto', textosMap.get('Pregunta CBP'));
            Test.stopTest();
        }
    }
}