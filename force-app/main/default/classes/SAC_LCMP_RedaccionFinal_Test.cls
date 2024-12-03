@isTest
public with sharing class SAC_LCMP_RedaccionFinal_Test {
    @TestSetup
    static void makeData(){
        User userAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        userAdmin.Username = 'useradminpruebaredfinal@test.com.testdata';
        Database.insert(userAdmin);
        
        //Grupo que se encarga de gestionar las tareas
        CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1)[0];
        grupoColaborador.Name = 'Grupo Proveedores Test';
        grupoColaborador.SAC_NivelGrupo__c = 'SAC_Nivel2';
        grupoColaborador.SAC_PermiteEscalado__c = true;
        grupoColaborador.SAC_PermiteTareas__c = true;
        grupoColaborador.SAC_Email__c = 'mneira@viewnext.com';
        Database.insert(grupoColaborador);

        User usuarioGeneral;
        System.runAs(userAdmin) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0]; 
            usuarioGeneral.Username = 'usergeneral@test.com'; 
            usuarioGeneral.SAC_GruposPerteneciente__c = grupoColaborador.id;   
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);

            
        }
        Test.startTest();
        //Account
        Account cuentaOficina = SAC_TestDataFactory.crearCuentasOficina(1)[0];
        cuentaOficina.CC_Email__c = 'test@test.com'; 
        Database.insert(cuentaOficina);

        //Contact
        Contact contacto = SAC_TestDataFactory.crearContacto(1,null)[0];
        contacto.Email = 'test.t@t.t';
        Database.insert(contacto);

        //Cuentas
        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(2);
        cuentas[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentas[0].Name = 'Cuenta A';
        cuentas[0].Phone = '123456789';
        cuentas[0].CC_Email__c = 'nosquenoscuantoTEST4540986s@test.TEST';
        cuentas[0].billingStreet  = 'Calle Mayor 55';
        cuentas[0].BillingCountry = 'España';
        cuentas[0].OwnerId = usuarioGeneral.id;
    
        cuentas[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente').getRecordTypeId();
        cuentas[1].Name = 'Cuenta B';
        cuentas[1].Phone = '123456789';
        cuentas[1].CC_Email__c = 'nosquenoscuantoTEST4540986s2@test.TEST';
        cuentas[1].billingStreet  = 'Calle Mayor 55';
        cuentas[1].BillingCountry = 'España';
        cuentas[1].OwnerId = usuarioGeneral.id;
        Database.insert(cuentas);

        //MCC
        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        Id recTypeMotivoDemora =  Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_MotivoDemora').getRecordTypeId();
        Id recTypeTipoAdjuntos =  Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_TipoAdjuntos').getRecordTypeId();
        
        CC_MCC__c mccTematica1 = new CC_MCC__c(
        RecordTypeId = recTypeTematica,
        Name = 'Avales',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-0101');
        Database.insert(mccTematica1);

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
        RecordTypeId = recTypeProdServ,
        Name = 'Avales Fianzas y Otras Garantías',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101',
        CC_Tematica__c = mccTematica1.id);
        Database.insert(mccProdServ1);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
        RecordTypeId = recTypeMotivo,
        Name = 'Discrepancia con importe deuda reclamada',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Producto_Servicio__c = mccProdServ1.id,
        CC_Codigo_Externo__c = 'TEST-0102');
        Database.insert(mccMotivo1);

        CC_MCC__c mccDetalle1 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda reclamada',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-01010101',
        CC_Motivo__c = mccMotivo1.id);
        Database.insert(mccDetalle1);


        //Reclamacion 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('AccountId', cuentas[1].Id);
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('Origin', 'SAC_Manual');
        camposRecl.put('CC_Canal_Respuesta__c', 'Carta');
        camposRecl.put('SuppliedEmail', 'nosquenoscuantoTEST4540986s@test.TEST');
        camposRecl.put('SuppliedCompany', 'reclamacion');
        camposRecl.put('SEG_Grupo__c', grupoColaborador.id);
        camposRecl.put('SEG_Detalle__c', mccDetalle1.id);
        camposRecl.put('CC_MCC_Tematica__c', mccTematica1.id);
        camposRecl.put('CC_MCC_Motivo__c', mccMotivo1.id);
        camposRecl.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        camposRecl.put('SAC_Entidad_Afectada__c', 'SAC_007');
        camposRecl.put('CC_Oficina_Afectada_Lookup__c', cuentaOficina.id);
        
      
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('AccountId', cuentas[0].Id);
        camposRecl2.put('OwnerId', usuarioGeneral.Id);
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('Origin', 'SAC_Manual');
        camposRecl2.put('CC_Canal_Respuesta__c', 'Carta');
        camposRecl2.put('SuppliedEmail', 'nosquenoscuantoTEST4540986s@test.TEST');
        camposRecl2.put('SuppliedCompany', 'reclamacion');
        camposRecl2.put('SAC_Entidad_Afectada__c', 'SAC_007');
        camposRecl2.put('CC_Oficina_Afectada_Lookup__c',  cuentas[1].id);
      
        Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl2);

        //Reclamacion 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('AccountId', cuentas[0].Id);
        camposRecl3.put('OwnerId', usuarioGeneral.Id);
        camposRecl3.put('Status', 'SAC_001');
        camposRecl3.put('Origin', 'SAC_Manual');
        camposRecl3.put('CC_Canal_Respuesta__c', 'Email');
        camposRecl3.put('SuppliedEmail', 'nosquantoTEST4540986s@test.TEST');
        camposRecl3.put('SuppliedCompany', 'reclamacion');
      
        Case reclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl3);

        //Reclamacion 4
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'TestRec4');
        camposRecl4.put('AccountId', cuentas[1].Id);
        camposRecl4.put('OwnerId', usuarioGeneral.Id);
        camposRecl4.put('Status', 'SAC_001');
        camposRecl4.put('Origin', 'SAC_Manual');
        camposRecl4.put('CC_Canal_Respuesta__c', 'Email');
        camposRecl4.put('SuppliedEmail', 'nosquantoTEST4540986s@test.TEST');
        camposRecl4.put('SuppliedCompany', 'reclamacion');
      
        Case reclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl4);

        //Reclamacion 5
        /*Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'TestRec5');
        camposRecl5.put('AccountId', cuentaB.Id);
        camposRecl5.put('OwnerId', usuarioGeneral.Id);
        camposRecl5.put('Status', 'SAC_001');
        camposRecl5.put('Origin', 'SAC_Manual');
        camposRecl5.put('CC_Canal_Respuesta__c', 'Email');
        camposRecl5.put('SuppliedEmail', 'nosquantoTEST4540986s@test.TEST');
        camposRecl5.put('SuppliedCompany', 'reclamacion');
      
        Case reclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl5);*/
      
        //Reclamacion 6
        Map<String, Object> camposRecl6 = new Map<String, Object>();
        camposRecl6.put('Subject', 'TestRec6');
        camposRecl6.put('AccountId', cuentas[1].Id);
        camposRecl6.put('OwnerId', usuarioGeneral.Id);
        camposRecl6.put('Status', 'SAC_001');
        camposRecl6.put('Origin', 'SAC_Manual');
        camposRecl6.put('CC_Canal_Respuesta__c', 'Email');
        camposRecl6.put('SuppliedEmail', 'nosequantoTEST4540986s@test.TEST');
        camposRecl6.put('SuppliedCompany', 'reclamacion');
        camposRecl6.put('SAC_CasoEspecial__c', 'SAC_Presidencia');

      
        Case reclamacion6 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl6);
        
        //Reclamacion 7
        Map<String, Object> camposRecl7 = new Map<String, Object>();
        camposRecl7.put('Subject', 'TestRec7');
        camposRecl7.put('AccountId', cuentas[1].Id);
        camposRecl7.put('OwnerId', usuarioGeneral.Id);
        camposRecl7.put('Status', 'SAC_001');
        camposRecl7.put('Origin', 'SAC_Manual');
        camposRecl7.put('CC_Canal_Respuesta__c', 'Email');
        camposRecl7.put('SuppliedEmail', 'nosequantoTEST4540986s@test.TEST');
        camposRecl7.put('SuppliedCompany', 'reclamacion');
        camposRecl7.put('SAC_CasoEspecial__c', 'SAC_Presidencia');
      
        Case reclamacion7 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl7);
      
        //Reclamacion 8
        Map<String, Object> camposRecl8 = new Map<String, Object>();
        camposRecl8.put('Subject', 'TestRec8');
        camposRecl8.put('AccountId', cuentas[0].Id);
        camposRecl8.put('OwnerId', usuarioGeneral.Id);
        camposRecl8.put('Status', 'SAC_001');
        camposRecl8.put('Origin', 'SAC_Manual');
        camposRecl8.put('CC_Canal_Respuesta__c', 'Carta');
        camposRecl8.put('SuppliedEmail', 'nosquenoscuantoTEST4540986s@test.TEST');
        camposRecl8.put('SuppliedCompany', 'reclamacion');
        camposRecl8.put('SAC_Entidad_Afectada__c', 'SAC_007');
      
        Case reclamacion8 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl8);
       
        List<Case> reclamaciones = new List<Case>();
        reclamaciones.add(reclamacion);
        reclamaciones.add(reclamacion2);
        reclamaciones.add(reclamacion3);
        reclamaciones.add(reclamacion4);
        //reclamaciones.add(reclamacion5);
        reclamaciones.add(reclamacion6);
        reclamaciones.add(reclamacion7);
        reclamaciones.add(reclamacion8);
        Database.insert(reclamaciones);
        
        //Pretensiones
        //Pretension 1
        Map<String, Object> camposPret1 = new Map<String, Object>();
        camposPret1.put('SuppliedCompany', 'TestPret');
        camposPret1.put('Status', 'SAC_001');
        camposPret1.put('SAC_Reclamacion__c', reclamacion.Id);
        camposPret1.put('SAC_Redaccion__c', 'Lorem ipsum test redaccion');
        camposPret1.put('SAC_RedaccionFinal__c', true);
        camposPret1.put('SAC_SentidoResolucion__c', 'SAC_001');
      
        Case pretension = SAC_TestDataFactory.crearCaso('Pretension', camposPret1);

        //Pretension 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'TestPret2');
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_Reclamacion__c', reclamacion.Id);
        camposPret2.put('SAC_Redaccion__c', 'Lorem ipsum test redaccion 2');
        camposPret2.put('SAC_RedaccionFinal__c', true);
        camposPret2.put('SAC_SentidoResolucion__c', 'SAC_001');
      
        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension', camposPret2);

        //Pretension 3
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('SuppliedCompany', 'TestPret3');
        camposPret3.put('Status', 'SAC_001');
        camposPret3.put('SAC_Reclamacion__c', reclamacion2.Id);
        camposPret3.put('SAC_Redaccion__c', 'Lorem ipsum test redaccion 3');
        camposPret3.put('SAC_RedaccionFinal__c', true);
        camposPret3.put('SAC_SentidoResolucion__c', 'SAC_001');
      
        Case pretension3 = SAC_TestDataFactory.crearCaso('Pretension', camposPret3);

        //Pretension 4
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('SuppliedCompany', 'TestPret4');
        camposPret4.put('Status', 'SAC_001');
        camposPret4.put('SAC_Reclamacion__c', reclamacion2.Id);
        camposPret4.put('SAC_Redaccion__c', 'Lorem ipsum test redaccion 4');
        camposPret4.put('SAC_RedaccionFinal__c', false);
        camposPret4.put('SAC_SentidoResolucion__c', 'SAC_001');
      
        Case pretension4 = SAC_TestDataFactory.crearCaso('Pretension', camposPret4);

        //Pretension 5
        Map<String, Object> camposPret5 = new Map<String, Object>();
        camposPret5.put('SuppliedCompany', 'TestPret5');
        camposPret5.put('Status', 'SAC_001');
        camposPret5.put('SAC_Reclamacion__c', reclamacion7.Id);
        camposPret5.put('SAC_Redaccion__c', 'Lorem ipsum test redaccion 5');
        camposPret5.put('SAC_RedaccionFinal__c', false);
        camposPret5.put('SAC_SentidoResolucion__c', 'SAC_001');
      
        Case pretension5 = SAC_TestDataFactory.crearCaso('Pretension', camposPret5);
     
        List<Case> pretensiones = new List<Case>();
        pretensiones.add(pretension);
        pretensiones.add(pretension2);
        pretensiones.add(pretension3);
        pretensiones.add(pretension4);
        pretensiones.add(pretension5);
        Database.insert(pretensiones);
        
        
        SAC_ProductCase__c producto  = new SAC_ProductCase__c();
        producto.SAC_Pretension__c = pretension.Id;
        producto.SAC_Descripcion__c = 'Descripcion test contrato test';
        Database.insert(producto);
        
        
        
        //Tarea
        SAC_MaestroAccionesReclamacion__c maestro2 = SAC_TestDataFactory.crearMaestroAcciones(1, grupoColaborador.id)[0];
        maestro2.name = 'GENERAL PARA OFICINAS';
        maestro2.SAC_Descripcion__c = 'Descripción';
        maestro2.SAC_PlazoMaximo__c = 15;
        maestro2.SAC_Prorroga__c = 30;
        maestro2.SAC_DeveloperName__c = 'GENERAL PARA OFICINAS';
        maestro2.SAC_Activo__c = true;
        Database.insert(maestro2);

        List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();
        SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1, reclamacion, false)[0];
        tarea.SAC_EquipoResponsable__c= grupoColaborador.Id;
        tarea.OwnerId = usuarioGeneral.id;
        tarea.SAC_Estado__c = null;
        listaTareas.add(tarea);

        SAC_Accion__c tarea2 = SAC_TestDataFactory.crearTareas(1, reclamacion, true)[0];
        tarea2.SAC_Estado__c = null;
        tarea2.SAC_MaestroAccionesReclamacion__c = maestro2.Id;
        tarea2.SAC_EquipoResponsable__c = grupoColaborador.id;
        tarea2.SAC_Observaciones__c = 'tarea5'; 
        tarea2.SAC_PlazoMaximo__c = 10; 
        tarea2.SAC_Prorroga__c = 5;
        tarea2.OwnerId = usuarioGeneral.id;
        tarea2.SAC_Oficina__c = cuentaOficina.id;
        tarea2.SAC_ImporteNotariaAbonar__c = 20;
        tarea2.SAC_ImporteGestoriaAbonar__c = 30;
        tarea2.SAC_ImporteRegistroAbonar__c = 35;
        tarea2.SAC_ImporteTasacionAbonar__c = 25;
        tarea2.SAC_NCuentaAbono__c = '1234567890';
        tarea2.SAC_Comentarios__c = 'Comentario prueba';
        listaTareas.add(tarea2);
        Database.insert(listaTareas);
        
        //ContentVersion
        List<ContentVersion> listaCV = new List<ContentVersion>();
        ContentVersion cv = new Contentversion();
        cv.title = 'ABC';
        cv.PathOnClient = 'test';
        Blob b = Blob.valueOf('Unit Test Attachment Body');
        cv.FirstPublishLocationId = reclamacion2.Id;
        cv.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion';
        listaCV.add(cv);

        ContentVersion cv2 = new Contentversion();
        cv2.title = 'ABC2';
        cv2.PathOnClient = 'test';
        Blob b2 = Blob.valueOf('Unit Test Attachment Body');
        cv2.FirstPublishLocationId = reclamacion2.Id;
        cv2.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv2.SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion';
        cv2.ownerId = usuarioGeneral.Id;
        listaCV.add(cv2);
        Database.insert(listaCV);
        

        //User de prueba
        // User usuario = new User();
        // usuario.Username = 'Name126524345@test.com';
        // usuario.Email = 'email@t1231432est.com';
        // usuario.LastName = 'Usuario Test1234321';
        // usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        // usuario.Alias = 'alia2342';
        // usuario.TimeZoneSidKey = 'GMT';
        // usuario.LocaleSidKey = 'es_ES';
        // usuario.EmailEncodingKey = 'ISO-8859-1';
        // usuario.LanguageLocaleKey = 'en_US';
        // usuario.isActive = true;
        // usuario.userRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        // Database.insert(usuario);

        //Interaccion Escalado
        Map<String, Object> camposEsc = new Map<String, Object>();
        camposEsc.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc.put('SAC_CasoEscalado__c', reclamacion2.id);
        camposEsc.put('SAC_Email1__c', 'testing@test.test');
        camposEsc.put('OwnerId', usuarioGeneral.id);
        camposEsc.put('SAC_GrupoColaborador__c', grupoColaborador.id);
        camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        
        SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);

        //Interaccion Escalado 2
        Map<String, Object> camposEsc2 = new Map<String, Object>();
        camposEsc2.put('SAC_Propuesta__c', 'propuesta2 test');
        camposEsc2.put('SAC_CasoEscalado__c', reclamacion6.id);
        camposEsc2.put('SAC_Email1__c', 'testing@test.test2');
        camposEsc2.put('OwnerId', usuarioGeneral.id);
        camposEsc2.put('SAC_GrupoColaborador__c', grupoColaborador.id);
        camposEsc2.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        
        SAC_Interaccion__c escalado2 = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc2);

        List<SAC_Interaccion__c> escalados = new List<SAC_Interaccion__c>();
        escalados.add(escalado);
        escalados.add(escalado2);
        Database.insert(escalados); 

        

        List<SAC_DocumentoEnvio__c> listDocumentoEnvio = SAC_TestDataFactory.crearDocumentoEnvio(2, reclamacion);
        listDocumentoEnvio[0].SAC_TipoDocumento__c = 'redaccion';
        listDocumentoEnvio[1].SAC_TipoDocumento__c = 'redacción';
        Database.insert(listDocumentoEnvio);  
        Test.stopTest();

        //Parametrizaciones Escalado 1
        Map<String, Object> camposParam = new Map<String, Object>();
        camposParam.put('Name', 'Validacion Escalado AJ');
        camposParam.put('Aplica_escalado__c', true);
        camposParam.put('SAC_Despacho__c', grupoColaborador.id);
        camposParam.put('SAC_GrupoDestino__c', grupoColaborador.Id);
        camposParam.put('SAC_Importe__c', 200);
        camposParam.put('SAC_Mensaje__c', 'Mensaje');
        camposParam.put('SAC_todosMCCs__c', true);
        camposParam.put('SAC_TodosDespachos__c', true);
        camposParam.put('SAC_validarImporte__c', false);
        camposParam.put('SAC_Entidad__c', 'SAC_001');
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado = SAC_TestDataFactory.crearParamEsc(camposParam);
        
        //Parametrizaciones Escalado 2
        Map<String, Object> camposParam2 = new Map<String, Object>();
        camposParam2.put('Name', 'Validacion Escalado COPS');
        camposParam2.put('Aplica_escalado__c', true);
        camposParam2.put('SAC_Importe__c', 200);
        camposParam2.put('SAC_Mensaje__c', 'Mensaje');
        camposParam2.put('SAC_todosMCCs__c', true);
        camposParam2.put('SAC_TodosDespachos__c', true);
        camposParam2.put('SAC_validarImporte__c', false);
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado2 = SAC_TestDataFactory.crearParamEsc(camposParam2);
        
        List<SAC_ParametrizacionEscalado__c> listaParametrizaciones = new List<SAC_ParametrizacionEscalado__c>();
        listaParametrizaciones.add(parametrizacionEscalado);
        listaParametrizaciones.add(parametrizacionEscalado2);
        Database.insert(listaParametrizaciones);

        List<SAC_PlantillaRedaccion__c> listaPlantillas = new List<SAC_PlantillaRedaccion__c>();
        SAC_PlantillaRedaccion__c plantilla1 = new SAC_PlantillaRedaccion__c();
        plantilla1.Name = 'plantilla1';
        plantilla1.SAC_TipoPlantilla__c = 'SAC_Inadmision';
        listaPlantillas.add(plantilla1);

        SAC_PlantillaRedaccion__c plantilla2 = new SAC_PlantillaRedaccion__c();
        plantilla2.Name = 'plantilla2';
        plantilla2.SAC_TipoPlantilla__c = 'SAC_Inadmision';
        listaPlantillas.add(plantilla2);

        SAC_PlantillaRedaccion__c plantilla3 = new SAC_PlantillaRedaccion__c();
        plantilla3.Name = 'plantilla3';
        plantilla3.SAC_TipoPlantilla__c = 'SAC_Inadmision';
        listaPlantillas.add(plantilla3);
        Database.insert(listaPlantillas); 

        List<SAC_MaestroTemas__c> listaMaestro = new List<SAC_MaestroTemas__c>();
        SAC_MaestroTemas__c maestroT = new SAC_MaestroTemas__c(Name = 'SACMotivoDemoraTest', RecordTypeId = recTypeMotivoDemora);
        listaMaestro.add(maestroT);

        SAC_MaestroTemas__c maestroT2 = new SAC_MaestroTemas__c(Name = 'SACMotivoDemoraTest2', RecordTypeId = recTypeMotivoDemora);
        listaMaestro.add(maestroT2);

        SAC_MaestroTemas__c maestroT3 = new SAC_MaestroTemas__c(Name = 'ResolucionTest', RecordTypeId = recTypeTipoAdjuntos, SAC_DeveloperName__c = 'RESOLUCION');
        listaMaestro.add(maestroT3);
        Database.insert(listaMaestro);

        EmailMessage em  = new EmailMessage();
        em.relatedtoId = reclamacion.Id;
        em.Subject = 'emTestRedaccionFInal';
        em.SAC_EnvioRedaccion__c = 'primerenvioredaccion';
        Database.insert(em);
    }

    @isTest
    static void compruebaPDFsTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Boolean resultado;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuarioGeneral){
            Test.startTest();
            resultado = SAC_LCMP_RedaccionFinal.compruebaPDFs(reclamacion.Id);
            Test.stopTest();
        }
        System.assertEquals(resultado, false, 'El método que comprueba si tiene PDFs una reclamación ha fallado.');
    }

    @isTest
    static void devolverCasoTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Case resultado;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            resultado = SAC_LCMP_RedaccionFinal.devolverCaso(reclamacion.Id);
            Test.stopTest();
        }
        System.assertEquals(resultado.Id, reclamacion.Id, 'El método que comprueba si tiene PDFs una reclamación ha fallado.');
        System.assertEquals(resultado.Status, reclamacion.Status, 'El método que comprueba si tiene PDFs una reclamación ha fallado.');
    }

    @isTest
    static void guardarResolucionApexTest(){
        Case reclamacion = [SELECT Id, SAC_SentidoResolucion__c, SAC_MotivoSentidoResolucion__c, SAC_MotivoInadmision__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        reclamacion.SAC_SentidoResolucion__c = 'SAC_004';
        reclamacion.SAC_MotivoSentidoResolucion__c = 'Motivo sentido resolucion';
        reclamacion.SAC_MotivoInadmision__c = 'SAC_005';
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_RedaccionFinal.guardarResolucionApex(reclamacion.Id, reclamacion.SAC_SentidoResolucion__c, reclamacion.SAC_MotivoSentidoResolucion__c, reclamacion.SAC_MotivoInadmision__c);
            Test.stopTest();
        }
        Case reclamacionModificada = [SELECT Id, SAC_SentidoResolucion__c, SAC_MotivoSentidoResolucion__c, SAC_MotivoInadmision__c  FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        System.assertEquals(reclamacionModificada.Id, reclamacion.Id, 'El método que guarda la resolucion de la redacción de una reclamación ha fallado.');
        System.assertEquals(reclamacionModificada.SAC_SentidoResolucion__c, reclamacion.SAC_SentidoResolucion__c, 'El método que guarda la resolucion de la redacción de una reclamación ha fallado.');
        System.assertEquals(reclamacionModificada.SAC_MotivoSentidoResolucion__c, reclamacion.SAC_MotivoSentidoResolucion__c, 'El método que guarda la resolucion de la redacción de una reclamación ha fallado.');
        System.assertEquals(reclamacionModificada.SAC_MotivoInadmision__c, reclamacion.SAC_MotivoInadmision__c, 'El método que guarda el motivo de inadmision de la redacción de una reclamación ha fallado.');

    }

    @isTest
    static void getPickListValuesIntoListTest(){ 
        List<SAC_LCMP_RedaccionFinal.plantillasWrapper> resultado = new List<SAC_LCMP_RedaccionFinal.plantillasWrapper>();
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            resultado = SAC_LCMP_RedaccionFinal.getPickListValuesIntoList();
            Test.stopTest();
        }
        System.assertNotEquals(resultado, null, 'la creacion del objeto wrapper ha fallado');
    }




    @isTest
    static void getPickListMotivoInadmision(){ 
       
        List<SAC_LCMP_RedaccionFinal.PlantillasWrapper> result = new List<SAC_LCMP_RedaccionFinal.PlantillasWrapper>();
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            result = SAC_LCMP_RedaccionFinal.getPickListMotivoInadmision();
            Test.stopTest();
        }

        System.assertNotEquals(result, null, 'La creacion del objeto wrapper ha fallado');
    }







    @isTest
    static void finalizarRedaccionTest(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        User usuarioAdmin = [SELECT Id FROM User WHERE Username = 'useradminpruebaredfinal@test.com.testdata' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        reclamacion.OwnerId = usuarioGeneral.id;
        Database.update(reclamacion);

        //List<SAC_Accion__c> listTareas = [SELECT Id, OwnerId FROM SAC_Accion__c WHERE]

        System.runAs(usuarioAdmin){
            /*EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'nombreTest';
            validEmailTemplate.DeveloperName = 'SAC_TareaOficina';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.HtmlValue = '<p><p>';
            validEmailTemplate.Body = 'Texted';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            //validEmailTemplate.OwnerId = usuarioGeneral.id;
            Database.insert(validEmailTemplate);*/

            Test.startTest();
            SAC_LCMP_RedaccionFinal.finalizarRedaccion(reclamacion.Id, true);
            Test.stopTest();
        }
        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        System.assertNotEquals(reclamacion2.Status, reclamacion.Status, 'La etapa en la que se finaliza la tarea no ha funcionado correctamente');
    }

    @isTest
    static void finalizarRedaccion2Test(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_RedaccionFinal.finalizarRedaccion(reclamacion.Id, true);
            Test.stopTest();
        }
        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        System.assertNotEquals(reclamacion2.Status, reclamacion.Status, 'La etapa en la que se finaliza la tarea no ha funcionado correctamente');
    }

    @isTest
    static void updateNombrePDFTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId =: reclamacion.Id LIMIT 1];
        List<String> archivos = new List<String>();
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_RedaccionFinal.updateNombrePDF(archivos, reclamacion.id, true);
            Test.stopTest();
        }
        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        System.assertNotEquals(reclamacion2.Status, null, 'La etapa en la que se finaliza la tarea no ha funcionado correctamente');
    }

    @isTest
    static void updateNombrePDF2Test(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId =: reclamacion.Id LIMIT 1];
        List<String> archivos = new List<String>();
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_RedaccionFinal.updateNombrePDF(archivos, reclamacion.id, false);
            Test.stopTest();
        }
        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        System.assertNotEquals(reclamacion2.Status, null, 'La etapa en la que se finaliza la tarea no ha funcionado correctamente');
    }

    @isTest
    static void fetchUserTest(){ 
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        User usuario2 = new User();
        System.runAs(usuarioGeneral){
            Test.startTest();
            usuario2 = SAC_LCMP_RedaccionFinal.fetchUser();
            Test.stopTest();
        }
        System.assertEquals(usuarioGeneral.Id, usuario2.Id, 'La creacion del objeto wrapper ha fallado');
    }

    @isTest
    static void getDocumentTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        ContentDocumentLink resultado;
        List<String> listaIds = new  List<String>();
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        // List<ContentVersion> cvIds = [SELECT Id FROM Contentversion];
        // for(ContentVersion cvid : cvIds){
        //     listaIds.add(cvid.Id);
        // }
        // System.debug('testtttt ' + reclamacion.id );
        // System.debug('testtttt ' + listaIds );
        System.runAs(usuarioGeneral){
            Test.startTest();
            resultado = SAC_LCMP_RedaccionFinal.getDocument(reclamacion.id, listaIds);
            Test.stopTest();
        }
        System.assertNotEquals(resultado, null, 'Obtener el documento de la reclamación ha fallado.');
    }

    @isTest
    static void obtenerDatosEmailTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        SAC_LCMP_RedaccionFinal.DatosEmailWrapper informacion;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            reclamacion.CC_Canal_Respuesta__c = 'Carta';
            Database.update(reclamacion);
            informacion = SAC_LCMP_RedaccionFinal.obtenerDatosEmail(reclamacion.Id, false);
            Test.stopTest();
        }
        System.assertNotEquals(informacion, null, 'El objeto wrapper con datos del email no se ha instanciado correctamente.');
    }

    @isTest
    static void obtenerDatosEmail2Test(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_LCMP_RedaccionFinal.DatosEmailWrapper informacion;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            informacion = SAC_LCMP_RedaccionFinal.obtenerDatosEmail(reclamacion.Id, false);
            Test.stopTest();
        }
        System.assertNotEquals(informacion, null, 'El objeto wrapper con datos del email no se ha instanciado correctamente.');
    }

    @isTest
    static void obtenerDatosEmail3Test(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        SAC_LCMP_RedaccionFinal.DatosEmailWrapper informacion;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            informacion = SAC_LCMP_RedaccionFinal.obtenerDatosEmail(reclamacion.Id, false);
            Test.stopTest();
        }
        System.assertNotEquals(informacion, null, 'El objeto wrapper con datos del email no se ha instanciado correctamente.');
    }

    @isTest
    static void obtenerDatosEmail4Test(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec4' LIMIT 1];
        SAC_LCMP_RedaccionFinal.DatosEmailWrapper informacion;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            informacion = SAC_LCMP_RedaccionFinal.obtenerDatosEmail(reclamacion.Id, false);
            Test.stopTest();
        }
        System.assertNotEquals(informacion, null, 'El objeto wrapper con datos del email no se ha instanciado correctamente.');
    }

    @isTest
    static void obtenerDatosEmail5Test(){
        Case pretension = [SELECT Id, Status FROM Case WHERE SuppliedCompany = 'TestPret5' LIMIT 1];
        SAC_LCMP_RedaccionFinal.DatosEmailWrapper informacion;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            informacion = SAC_LCMP_RedaccionFinal.obtenerDatosEmail(pretension.Id, false);
            Test.stopTest();
        }
        System.assertNotEquals(informacion, null, 'El objeto wrapper con datos del email no se ha instanciado correctamente.');
    }

    @isTest
    static void validacionesTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];

        SAC_LCMP_RedaccionFinal.Validaciones resultado;
        System.runAs(usuarioGeneral){
            Test.startTest();
            resultado = SAC_LCMP_RedaccionFinal.validacionRedaccion(reclamacion.Id);
            Test.stopTest();
        }
        System.assertEquals(resultado.pretension, false, 'Las validaciones han fallado.');
    }

    @isTest
    static void borraDocumento(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        List<ContentVersion> cv = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId =: reclamacion.Id];

        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_RedaccionFinal.borraDocumento(reclamacion.Id);
            List<ContentVersion> cv2 = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId =: reclamacion.Id];
            Test.stopTest();
            System.assertNotEquals(cv2, cv, 'Ha fallado el borrado del documento vinculado a la reclamación.');
        }  
    }

    @istest
    static void obtenerPlantillaTest() {
        SAC_PlantillaRedaccion__c plantillaDos =  [SELECT Id FROM SAC_PlantillaRedaccion__c WHERE Name = 'plantilla2' LIMIT 1];
        SAC_PlantillaRedaccion__c plantillaTres =  [SELECT Id FROM SAC_PlantillaRedaccion__c WHERE Name = 'plantilla3' LIMIT 1];
        SAC_PlantillaRedaccion__c plantillaUno =  [SELECT Id FROM SAC_PlantillaRedaccion__c WHERE Name = 'plantilla1' LIMIT 1];
        plantillaUno.SAC_PlantillaCastellanoId__c = plantillaUno.Id;
        plantillaUno.SAC_PlantillaCatalanId__c = plantillaDos.Id;
        plantillaUno.SAC_PlantillaInglesId__c = plantillaTres.Id;
        Database.update(plantillaUno);

        Id recordTypeRedaccion =  Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        List<SAC_PlantillaRedaccion__c> listaPlantillas = new List<SAC_PlantillaRedaccion__c> ();
        SAC_PlantillaRedaccion__c plantillaCastellano = New SAC_PlantillaRedaccion__c(RecordTypeId = recordTypeRedaccion, 
                                                            Name='Plantilla Inadmisión',
                                                            SAC_TipoPlantilla__c = 'SAC_Inadmision', 
                                                            SAC_PlantillaCastellanoId__c=plantillaUno.Id,
                                                            SAC_PlantillaCatalanId__c = plantillaUno.Id, 
                                                            SAC_PlantillaInglesId__c =plantillaUno.Id);    
        listaPlantillas.add(plantillaCastellano);
        Database.insert(listaPlantillas);
        listaPlantillas = [SELECT id, Name, SAC_PlantillaCastellanoId__c,SAC_PlantillaCatalanId__c,SAC_PlantillaInglesId__c  FROM SAC_PlantillaRedaccion__c];
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];

        String idplantilla1;
        String idplantilla2;
        String idplantilla3;
        String idplantilla4;

        System.runAs(usuarioGeneral){
            Test.startTest();
            idplantilla1 = SAC_LCMP_RedaccionFinal.obtenerPlantilla('SAC_Inadmision', 'es');
            idplantilla2 = SAC_LCMP_RedaccionFinal.obtenerPlantilla('SAC_Inadmision', 'ca');
            idplantilla3 = SAC_LCMP_RedaccionFinal.obtenerPlantilla('SAC_Inadmision', 'en');
            idplantilla4 = SAC_LCMP_RedaccionFinal.obtenerPlantilla('SAC_Inadmision', 'fr');
            Test.stopTest();
        }
        System.assertNotEquals(null, idplantilla1, 'No se obtuvo la plantilla en Castellano');        
        System.assertNotEquals(null, idplantilla2, 'No se obtuvo la plantilla en Catalán');
        System.assertNotEquals(null, idplantilla3, 'No se obtuvo la plantilla en Inglés');
        System.assertNotEquals(null, idplantilla4, 'No se obtuvo la plantilla por defecto');   
    }

    @isTest
    static void finalizarRedaccionCartaPostalTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_RedaccionFinal.finalizarRedaccionCartaPostal(reclamacion.Id);
            Test.stopTest();
        }
        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        System.assertNotEquals(reclamacion2.Status, reclamacion.Status, 'La etapa en la que se finaliza la tarea no ha funcionado correctamente');
    }

    @isTest
    static void validacionEscaladoTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec6' LIMIT 1];
        SAC_LCMP_RedaccionFinal.ObjWrapper result;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
       
        System.runAs(usuarioGeneral){
            Test.startTest();
            result = SAC_LCMP_RedaccionFinal.validacionEscalado(reclamacion.Id);
            Test.stopTest();
        }
        System.assertEquals(result.validacionesEscalados.escalado, true, 'La validación de escalado no ha funcionado correctamente');
        System.assertEquals(result.validacionesEscalados.presidencia, true, 'La validación de presidencia no ha funcionado correctamente');
    }

    @isTest
    static void recuperarPermisoTest() {
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec6' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE UserName = 'usergeneral@test.com' AND isActive = true];
        
        Boolean resultado;
        Test.startTest();
        System.runAs(usuario){
            resultado = SAC_LCMP_RedaccionFinal.recuperarPermiso(reclamacion);
        }
        Test.stopTest();
        System.assertEquals(true, resultado, 'No se ha podido recuperar el permiso');
    }

    @isTest
    static void recuperarPermiso2Test() {
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec7' LIMIT 1];
        Boolean resultado;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            resultado = SAC_LCMP_RedaccionFinal.recuperarPermiso(reclamacion);
            Test.stopTest();
        }
        System.assertEquals(true, resultado, 'No se ha podido recuperar el permiso');
    }

    @isTest
    static void comprobrarRecordTypeTest() {
        Case reclamacion = [SELECT Id, OwnerId, RecordTypeId FROM Case WHERE Subject = 'TestRec8' LIMIT 1];
        Boolean resultado;
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
                resultado = SAC_LCMP_RedaccionFinal.comprobrarRecordType(reclamacion.Id);
            Test.stopTest();
        }
        System.assertEquals(true, resultado, 'No se ha podido recuperar el recordType');
    }

    @isTest
    static void buscarGruposTest() {
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            listaGrupos = SAC_LCMP_RedaccionFinal.buscarGrupos('derivar');
            Test.stopTest();
        }
        System.assertNotEquals(null, listaGrupos, 'No se han podido recuperar los grupos');
    }

    @isTest
    static void buscarGruposTest2() {
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            listaGrupos = SAC_LCMP_RedaccionFinal.buscarGrupos('consulta');
            Test.stopTest();
        }
        System.assertNotEquals(null, listaGrupos, 'No se han podido recuperar los grupos');
    }

    @isTest
    static void getPretensionesTest() {
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<Case> listaPret = new List<Case>();

        System.runAs(usuarioGeneral){
            Test.startTest();
            listaPret = SAC_LCMP_RedaccionFinal.getPretensiones(reclamacion.id);
            Test.stopTest();
        }
        System.assertNotEquals(null, listaPret, 'No se han podido recuperar las pretensiones.');
    }

    @isTest
    static void finalizarRedaccionNegociacionTest() {
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<Case> pretensiones = [SELECT Id, Status FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];

        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_RedaccionFinal.finalizarRedaccionNegociacion(reclamacion.id, null, pretensiones);
            Test.stopTest();
        }
        List<Case> pretensionesUpd = [SELECT Id, Status FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];
        System.assertNotEquals(pretensiones, pretensionesUpd, 'No se han actualizado las pretensiones.');
    }

    @isTest
    static void getMotivosDemoraTest() {
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];

        List<SAC_MaestroTemas__c> resultado;
        System.runAs(usuarioGeneral){
            Test.startTest();
            resultado = SAC_LCMP_RedaccionFinal.getMotivosDemora();
            Test.stopTest();
        }

        System.assertNotEquals(null, resultado, 'Fallo al recuperar los motivos de demora.');
    }

    @isTest
    static void actualizarMotivosDemoraTest() {
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status, SAC_MotivoDemora__c, SAC_ComentarioDemora__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<SAC_MaestroTemas__c> motivosDemora = [SELECT Name FROM SAC_MaestroTemas__c WHERE Name = 'SACMotivoDemoraTest' OR Name  = 'SACMotivoDemoraTest2'];


        System.runAs(usuarioGeneral){
            Test.startTest();
            List<String> motivoNames = new List<String>();

            for (SAC_MaestroTemas__c motivo : motivosDemora) {
                motivoNames.add(motivo.Name);
            }

            SAC_LCMP_RedaccionFinal.actualizarMotivosDemora(reclamacion.Id, motivoNames, 'comentariosTest');
            Test.stopTest();
        }

        Case reclamacionFinal = [SELECT Id, Status, SAC_MotivoDemora__c, SAC_ComentarioDemora__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        System.assertNotEquals(reclamacion.SAC_MotivoDemora__c, reclamacionFinal.SAC_MotivoDemora__c, 'Fallo al añadir los motivos de demora.');
        System.assertNotEquals(reclamacion.SAC_ComentarioDemora__c, reclamacionFinal.SAC_ComentarioDemora__c, 'Fallo al añadir los comentarios de demora.');
    }
    
    @isTest
    static void getContratoPretensionTest() {
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Boolean tieneContratos = false;

        System.runAs(usuarioGeneral) {
            tieneContratos = SAC_LCMP_RedaccionFinal.getContratoPretension(reclamacion.Id);
            System.assertNotEquals(false, tieneContratos, 'No se han recuperado los contratos de pretension');
        }
    }

    @isTest
    static void clasificarTipoAdjuntoTest() {
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        List<ContentVersion> listaCV = new List<ContentVersion>();

        Test.startTest();
        System.runAs(usuarioGeneral) {
            listaCV = SAC_LCMP_RedaccionFinal.clasificarTipoAdjunto(reclamacion.Id);
        }
        Test.stopTest();

        System.assertEquals(false, listaCV.isEmpty(), 'No se ha podido poner el tipo de adjunto');
    }

    @isTest
    static void compruebaDocumentoRedaccionTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Boolean documento;

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuarioGeneral){
            Test.startTest();
            documento = SAC_LCMP_RedaccionFinal.compruebaDocumentoRedaccion(reclamacion.Id);
            Test.stopTest();
        }
        Assert.areNotEqual(documento, false, 'El método que comprueba si existen documentos de redaccion ha fallado.');
    }

    @isTest
    static void comprobarComunicacionRedaccionClienteTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Boolean documento;

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuarioGeneral){
            Test.startTest();
            documento = SAC_LCMP_RedaccionFinal.comprobarComunicacionRedaccionCliente(reclamacion.Id, 'SAC_CartaPostal');
            Test.stopTest();
        }
        Assert.areNotEqual(documento, false, 'El método que comprueba si existen documentos de redaccion ha fallado.');
    }

    @isTest
    static void comprobarComunicacionRedaccionClienteTest2(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Boolean documento;

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuarioGeneral){
            Test.startTest();
            documento = SAC_LCMP_RedaccionFinal.comprobarComunicacionRedaccionCliente(reclamacion.Id, 'Email');
            Test.stopTest();
        }
        Assert.areNotEqual(documento, false, 'El método que comprueba si existen documentos de redaccion ha fallado.');
    }
}