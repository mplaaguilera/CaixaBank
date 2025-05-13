@isTest
private class CC_Gestion_Derivar_Global_Test {
    @TestSetup
    static void makeData(){
        User adminUser = CC_TestDataFactory.insertUserAdmin();
        User usuarioOperador = CC_TestDataFactory.insertUserOperadorCliente('U0123456');
        System.runAs(adminUser){
            CC_TestDataFactory.insertarLOVDerivar();
            CC_TestDataFactory.insertarMCCsDerivar(usuarioOperador);
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
    //             cuentaCaixa.CC_Numero_Documento__c = '45729937B';
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
    //             cuentaCaixa.CC_Numero_Documento__c = '45729937B';
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

}