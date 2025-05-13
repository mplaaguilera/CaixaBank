@isTest
public class SAC_Reclamacion_Test {

    @TestSetup
    static void makeData(){
        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];

        List<Case> casos = new List<Case>();
        List<Case> pretensiones = new List<Case>();
        List<Case> reclamaciones = new List<Case>();

        //Account
        List<Account> listaCuentas = SAC_TestDataFactory.crearCuentas(1);
        listaCuentas[0].name = 'cuentaTest';
        SAC_DatabaseDML.insertListDML(listaCuentas, false);
        //Database.insert(listaCuentas);

        Account cuentaOficina = SAC_TestDataFactory.crearCuentasOficina(1)[0];
        cuentaOficina.CC_Email__c = 'test@test.com'; 
        SAC_DatabaseDML.insertDML(cuentaOficina, false);
        //Database.insert(cuentaOficina);

        //Users
        List<User> listaUsers = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
        listaUsers[0].Username = 'sac5reclamacion@test.test';
        listaUsers[1].Username = 'Name123456@test.com';
        SAC_DatabaseDML.insertListDML(listaUsers, false);
        //Database.insert(listaUsers);

        List<User> listaUsersAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1);
        listaUsersAdmin[0].Username = 'sacadmin1906@test.test';
        SAC_DatabaseDML.insertListDML(listaUsersAdmin, false);
        //Database.insert(listaUsersAdmin);
        
        //MCC
        CC_MCC__c mccTematica1 = new CC_MCC__c(
        RecordTypeId = recTypeTematica,
        Name = 'Avales',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-0101');
        SAC_DatabaseDML.insertDML(mccTematica1, false);
        //Database.insert(mccTematica1);

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
        RecordTypeId = recTypeProdServ,
        Name = 'Avales Fianzas y Otras Garantías',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101',
        CC_Tematica__c = mccTematica1.id);
        SAC_DatabaseDML.insertDML(mccProdServ1, false);
        //Database.insert(mccProdServ1);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
        RecordTypeId = recTypeMotivo,
        Name = 'Discrepancia con importe deuda reclamada',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Producto_Servicio__c = mccProdServ1.id,
        CC_Codigo_Externo__c = 'TEST-0102');
        SAC_DatabaseDML.insertDML(mccMotivo1, false);
        //Database.insert(mccMotivo1);

        List<CC_MCC__c> listamccsDetalle = new List<CC_MCC__c>();
        CC_MCC__c mccDetalle1 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda reclamada',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-01010101',
        CC_Motivo__c = mccMotivo1.id);
        listamccsDetalle.add(mccDetalle1);

        CC_MCC__c mccDetalle2 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda reclamada',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101012',
        CC_Motivo__c = mccMotivo1.id,
        SAC_GenerarTaskMisClientes__c = true);
        listamccsDetalle.add(mccDetalle2);
        SAC_DatabaseDML.insertListDML(listamccsDetalle, false);
        //Database.insert(listamccsDetalle);

        
        Map<String, Object> mapaCamposCaso = new Map<String, Object>();
        mapaCamposCaso.put('Subject', 'TestRec');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle1.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('OwnerId', listaUsers[0].id);
        mapaCamposCaso.put('CC_Oficina_Afectada_Lookup__c', cuentaOficina.id);
        mapaCamposCaso.put('CC_Idioma__c', 'en');
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        reclamaciones.add(casoReclamacion);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'TestRec2');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle1.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('SAC_TipoConsumidor__c', 'Si');
        mapaCamposCaso.put('SAC_TipoDeRepresentante__c', 'SAC_Abogado');
        mapaCamposCaso.put('CC_Importe_Abonado__c', 0.0);
        mapaCamposCaso.put('CC_Oficina_Afectada_Lookup__c', cuentaOficina.id);
        mapaCamposCaso.put('AccountId', listaCuentas[0].id);
        mapaCamposCaso.put('OwnerId', listaUsers[0].id);
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        reclamaciones.add(casoReclamacion2);
        
        Test.startTest();

        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'TestRec3');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle2.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('SAC_TipoConsumidor__c', 'Si');
        mapaCamposCaso.put('AccountId', listaCuentas[0].id);
        mapaCamposCaso.put('OwnerId', listaUsers[0].id);
        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        reclamaciones.add(casoReclamacion3);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'TestRec4');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_007');
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle2.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('SAC_TipoConsumidor__c', 'Si');
        mapaCamposCaso.put('AccountId', listaCuentas[0].id);
        mapaCamposCaso.put('OwnerId', listaUsers[0].id);
        Case casoReclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        reclamaciones.add(casoReclamacion4);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'TestRec5');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_006');
        mapaCamposCaso.put('SAC_DetenidoDesde__c', System.now().addDays(-1));
        mapaCamposCaso.put('SAC_DetenidoHasta__c', System.now());
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle2.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('SAC_TipoConsumidor__c', 'Si');
        mapaCamposCaso.put('AccountId', listaCuentas[0].id);
        mapaCamposCaso.put('OwnerId', listaUsers[0].id);
        Case casoReclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        reclamaciones.add(casoReclamacion5);
        
        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'TestRec6');
        mapaCamposCaso.put('Origin', 'Otros');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SAC_TipoConsumidor__c', 'No');
        mapaCamposCaso.put('SAC_Naturaleza__c', 'SAC_004');
        mapaCamposCaso.put('OwnerId', listaUsers[0].id);
        Case casoReclamacion6 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        reclamaciones.add(casoReclamacion6);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'Complementaria');
        mapaCamposCaso.put('Origin', 'Otros');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SAC_TipoConsumidor__c', 'No');
        mapaCamposCaso.put('SAC_Naturaleza__c', 'SAC_007');
        mapaCamposCaso.put('CC_Importe_Abonado__c', 5.0);
        mapaCamposCaso.put('OwnerId', listaUsers[0].id);
        Case casoReclamacion7 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        reclamaciones.add(casoReclamacion7);


        SAC_DatabaseDML.insertListDML(reclamaciones, false);


        List<Case> listaComplementariasVinculadas = new List<Case>();
        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'ComplementariaVinculada');
        mapaCamposCaso.put('Origin', 'Otros');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SAC_TipoConsumidor__c', 'No');
        mapaCamposCaso.put('SAC_Naturaleza__c', 'SAC_007');
        mapaCamposCaso.put('CC_Importe_Abonado__c', 5.0);
        mapaCamposCaso.put('CC_CasoRelacionado__c', casoReclamacion2.Id);
        mapaCamposCaso.put('OwnerId', listaUsers[0].id);
        Case casoReclamacion8 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        listaComplementariasVinculadas.add(casoReclamacion8);

        //Esta tiene naturaleza: reclamación, para en un método cambiarla ahí por Complementaria
        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'ComplementariaVinculada2');
        mapaCamposCaso.put('Origin', 'Otros');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SAC_TipoConsumidor__c', 'No');
        mapaCamposCaso.put('SAC_Naturaleza__c', 'SAC_004');
        mapaCamposCaso.put('CC_Importe_Abonado__c', 10.0);
        mapaCamposCaso.put('CC_CasoRelacionado__c', casoReclamacion2.Id);
        mapaCamposCaso.put('OwnerId', listaUsers[0].id);
        Case casoReclamacion9 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        listaComplementariasVinculadas.add(casoReclamacion9);

        SAC_DatabaseDML.insertListDML(listaComplementariasVinculadas, false);
        //Database.insert(reclamaciones);
        
        //Documentos envío
        List<SAC_DocumentoEnvio__c> listaDocs = new List<SAC_DocumentoEnvio__c>();
        SAC_DocumentoEnvio__c documento = new SAC_DocumentoEnvio__c();
        documento.SAC_Caso__c = casoReclamacion.Id;
        documento.SAC_TipoDocumento__c = 'redaccion';

        listaDocs.add(documento);
        SAC_DatabaseDML.insertListDML(listaDocs, true);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('SuppliedCompany', 'Pret1');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SAC_SentidoResolucion__c', 'SAC_001');
        mapaCamposCaso.put('SAC_Reclamacion__c', casoReclamacion.Id);
        mapaCamposCaso.put('OwnerId', listaUsers[1].id);
        mapaCamposCaso.put('SAC_Entidad_Afectada__c', 'SAC_002');
        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension', mapaCamposCaso);
        pretensiones.add(casoPretension);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('SuppliedCompany', 'Pret2');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle1.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('OwnerId', listaUsers[1].Id);
        Case casoPretension2 = SAC_TestDataFactory.crearCaso('Pretension', mapaCamposCaso);
        pretensiones.add(casoPretension2);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('SuppliedCompany', 'Pret3');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SAC_Reclamacion__c', casoReclamacion3.Id);
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle2.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('OwnerId', listaUsers[1].Id);
        Case casoPretension3 = SAC_TestDataFactory.crearCaso('Pretension', mapaCamposCaso);
        pretensiones.add(casoPretension3);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('SuppliedCompany', 'Pret4');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_007');
        mapaCamposCaso.put('SAC_Reclamacion__c', casoReclamacion4.Id);
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle2.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('SAC_ValidacionMCC__c', false);
        mapaCamposCaso.put('OwnerId', listaUsers[1].Id);
        Case casoPretension4 = SAC_TestDataFactory.crearCaso('Pretension', mapaCamposCaso);
        pretensiones.add(casoPretension4);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('SuppliedCompany', 'Pret5');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_007');
        mapaCamposCaso.put('SAC_Reclamacion__c', casoReclamacion4.Id);
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle2.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('OwnerId', listaUsers[1].Id);
        Case casoPretension5 = SAC_TestDataFactory.crearCaso('Pretension', mapaCamposCaso);
        pretensiones.add(casoPretension5);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('SuppliedCompany', 'Pret6');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_006');
        mapaCamposCaso.put('SAC_DetenidoDesde__c', System.now().addDays(-1));
        mapaCamposCaso.put('SAC_Reclamacion__c', casoReclamacion5.Id);
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle2.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('OwnerId', listaUsers[1].Id);
        Case casoPretension6 = SAC_TestDataFactory.crearCaso('Pretension', mapaCamposCaso);
        pretensiones.add(casoPretension6);

        SAC_DatabaseDML.insertListDML(pretensiones, false);
        //Database.insert(pretensiones);

        casoReclamacion2.SAC_PretensionPrincipal__c = casoPretension2.Id;
        SAC_DatabaseDML.updateDML(casoReclamacion2, false);
        //Database.update(casoReclamacion2);
        
        // Test.startTest();

        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'Consulta');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_010');
        mapaCamposCaso.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        mapaCamposCaso.put('OwnerId', listaUsers[1].Id);
        mapaCamposCaso.put('CC_CasoRelacionado__c', casoReclamacion.Id);
        Case consulta = SAC_TestDataFactory.crearCaso('Consulta', mapaCamposCaso);
        
        casos.add(consulta);
        SAC_DatabaseDML.insertListDML(casos, false);
        //Database.insert(casos);
        Test.stopTest();

        List<CC_Grupo_Colaborador__c> listaGrupoTareas = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 2);
        listaGrupoTareas[0].Name = 'COPS';

        System.runAs(listaUsersAdmin[0]){
            PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_Administrador'];
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = listaUsers[0].id);
            SAC_DatabaseDML.insertDML(psa, false);
            //Database.insert(psa);
        }

        System.runAs(listaUsers[0]){
            SAC_DatabaseDML.insertListDML(listaGrupoTareas, false);
            //Database.insert(listaGrupoTareas);

            CC_Grupo_Colaborador_Contact__c contact = SAC_TestDataFactory.crearColaboradorContact(listaUsers[0].id, listaGrupoTareas[1].id);
            SAC_DatabaseDML.insertDML(contact, false);
            //Database.insert(contact);
            
            List<SAC_Accion__c> listaTareas = SAC_TestDataFactory.crearTareas(2, casoReclamacion, false);
            listaTareas[0].SAC_Observaciones__c = 'TareaTest';
            listaTareas[1].SAC_Observaciones__c = 'TareaTest2';
            
            SAC_DatabaseDML.insertListDML(listaTareas, false);
            //Database.insert(listaTareas);
        }
    }

    @isTest
    public static void arrastrarImporteReclamacionVinculadaTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        Case complementaria = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'Complementaria'];
        
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        CBK_Case_Extension__c casoExtension = new CBK_Case_Extension__c();

        Test.startTest();
        System.runAs(usuario){

            complementaria.CC_CasoRelacionado__c = reclamacion.Id;
            SAC_DatabaseDML.updateDML(complementaria, false);
        }

        Case reclamacionResult = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'TestRec2'];
        Assert.areEqual(complementaria.CC_Importe_Abonado__c, reclamacionResult.CC_Importe_Abonado__c, 'No se ha arrastrado el imorte abonado a la reclamación.');
        Test.stopTest();
    }

    @isTest
    public static void actualizarImporteCambioVinculacionTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        Case complementaria = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'ComplementariaVinculada'];
        
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        CBK_Case_Extension__c casoExtension = new CBK_Case_Extension__c();

        Test.startTest();
        System.runAs(usuario){

            //Se le quita el caso relacionado para que reste el importe abonado que le correspondía a la complementaria
            complementaria.CC_CasoRelacionado__c = null;
            SAC_DatabaseDML.updateDML(complementaria, false);

        }

        Case reclamacionResult = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'TestRec2'];
        Assert.areEqual(0, reclamacionResult.CC_Importe_Abonado__c, 'No se ha arrastrado el imorte abonado a la reclamación.');
        Test.stopTest();
    }
    

    @isTest
    public static void calcularNuevoImporteAbonadoTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        Case complementaria = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'ComplementariaVinculada'];
        
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        CBK_Case_Extension__c casoExtension = new CBK_Case_Extension__c();

        Test.startTest();
        System.runAs(usuario){

            //Aunque ponga 10, el inicial es 5 asique le sumará 5 a la reclamación vinculada. El resultado será 5 porque se ha puesto el test para que parta desde importe = 0 la reclamación vinculada
            complementaria.CC_Importe_Abonado__c = 10;
            SAC_DatabaseDML.updateDML(complementaria, false);

        }

        Case reclamacionResult = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'TestRec2'];
        Assert.areEqual(5, reclamacionResult.CC_Importe_Abonado__c, 'No se ha arrastrado el imorte abonado a la reclamación.');
        Test.stopTest();
    }


    @isTest
    public static void calcularNuevoImporteAbonadoTest2(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        Case complementaria = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'ComplementariaVinculada'];
        
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        CBK_Case_Extension__c casoExtension = new CBK_Case_Extension__c();

        Test.startTest();
        System.runAs(usuario){

            complementaria.CC_Importe_Abonado__c = 0;
            SAC_DatabaseDML.updateDML(complementaria, false);

        }

        Case reclamacionResult = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'TestRec2'];
        Assert.areEqual(0, reclamacionResult.CC_Importe_Abonado__c, 'No se ha arrastrado el imorte abonado a la reclamación.');
        Test.stopTest();
    }

    @isTest
    public static void calcularNuevoImporteCambioNaturalezaTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        Case complementaria = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'ComplementariaVinculada2'];
        
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        CBK_Case_Extension__c casoExtension = new CBK_Case_Extension__c();

        Test.startTest();
        System.runAs(usuario){

            complementaria.SAC_Naturaleza__c = 'SAC_007';
            SAC_DatabaseDML.updateDML(complementaria, false);

        }

        Case reclamacionResult = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'TestRec2'];
        Assert.areEqual(10, reclamacionResult.CC_Importe_Abonado__c, 'No se ha arrastrado el imorte abonado a la reclamación.');
        Test.stopTest();
    }
    
     

    @isTest
    public static void comprobarDespachoRepresentanteTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        CBK_Case_Extension__c casoExtension = new CBK_Case_Extension__c();

        Test.startTest();
        System.runAs(usuario){
            
            casoExtension.SAC_DespachoRepresentante__c = 'Test';
            SAC_DatabaseDML.insertDML(casoExtension, false);

            reclamacion.CBK_Case_Extension_Id__c = casoExtension.Id;
            reclamacion.SAC_TipoDeRepresentante__c = 'SAC_Autorizado';
            SAC_DatabaseDML.updateDML(reclamacion, false);

            
           // SAC_DatabaseDML.updateDML(reclamacion, false);

        }

        CBK_Case_Extension__c casoExtensionResult = [SELECT SAC_DespachoRepresentante__c FROM CBK_Case_Extension__c WHERE Id = :casoExtension.Id];
        Assert.areEqual(null, casoExtensionResult.SAC_DespachoRepresentante__c, 'No se ha vaciado el despacho representante.');
        Test.stopTest();


    }

    @isTest
    public static void actualizarPlantillaLateralTest(){

        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];

        Test.startTest();
        System.runAs(usuario){
            
            reclamacion.CC_Idioma__c = 'es';
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
        }

        SAC_DocumentoEnvio__c resultado = [SELECT Id, SAC_NombrePlantillaLateral__c FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c = :reclamacion.Id];
        Assert.areEqual(resultado.SAC_NombrePlantillaLateral__c, 'SAC_CartaPlantilla', 'No se ha actualizado la plantilla,');
        Test.stopTest();
    }


    @isTest
    public static void devolverConsultasCOPSTest(){

        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
        reclamacion.Status = 'Cerrado';
        reclamacion.SAC_StatusAuxiliar__c = 'Cerrado';

        Case consulta = [SELECT Id, Status, OwnerId FROM Case WHERE Subject = 'Consulta'];

        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case consulta2 = [SELECT Id, Status, OwnerId FROM Case WHERE Subject = 'Consulta'];

        Assert.areNotEqual(consulta, consulta2, 'devolverConsultaCOPS no ha funcionado correctamente');
    }


    /*@isTest
    static void actualizarTAETest(){
        Id recordTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];

        Case caso = [SELECT Id, Subject, SAC_PretensionPrincipal__c  FROM Case WHERE Subject = 'TestRec6' LIMIT 1];
        Case pretension = [SELECT Id, Status, Origin, SAC_Reclamacion__c, RecordTypeId, SEG_Detalle__c, SAC_TAE__c FROM Case WHERE RecordTypeId = :recordTypePret AND SAC_Reclamacion__c = :caso.Id limit 1];


        Test.startTest();
        System.runAs(usuario){

            caso.SAC_PretensionPrincipal__c= pretension.Id;
            Database.update(caso);
        }

        Case reclamacion2 = [SELECT Id, SAC_TAE__c FROM Case WHERE Subject = 'TestRec6' LIMIT 1];
        Case pretension2 = [SELECT Id, Status, Origin, SAC_Reclamacion__c, RecordTypeId, SEG_Detalle__c, SAC_TAE__c FROM Case WHERE RecordTypeId = :recordTypePret AND SAC_Reclamacion__c = :reclamacion2.Id limit 1];
    
        Assert.areEqual(pretension2.SAC_TAE__c, reclamacion2.SAC_TAE__c, 'No se ha asignado el TAE correctamente');
    }*/


    @isTest
    public static void recuperarGestorClienteTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'cuentaTest'];

        System.runAs(usuario){
            Test.startTest();
            reclamacion.AccountId = cuenta.Id;
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT Id, Status, AccountId FROM Case WHERE Subject = 'TestRec'];

        Assert.areNotEqual(null, reclamacionResult.AccountId, 'No se ha podido recuperar el gestor');
    }
    
    /*
    @isTest
    public static void rellenarDatosReclamanteTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'cuentaTest'];

        Test.startTest();
        reclamacion.AccountId = cuenta.Id;
        Database.update(reclamacion);
        Test.stopTest();

        Case reclamacionResult = [SELECT Id, Status, AccountId FROM Case WHERE Subject = 'TestRec'];

        Assert.areNotEqual(null, reclamacionResult.AccountId, 'No se ha podido rellenar los reclamantes');
    }
*/

    @isTest
    public static void informarDireccionPostarTest(){
        
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
        reclamacion.SAC_DireccionContacto__c = 'direccionTest';
        reclamacion.SAC_CodigoPostalContacto__c = '12345';
        reclamacion.SAC_PoblacionContacto__c = 'Silla';
        reclamacion.SAC_ProvinciaContacto__c = 'Valencia';
        reclamacion.SAC_PaisContacto__c = 'España';
        
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT Id, Status, AccountId, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c FROM Case WHERE Subject = 'TestRec'];

        Assert.areNotEqual(null, reclamacionResult.SAC_DireccionContacto__c, 'No se han podido rellenar los campos postales');
        Assert.areNotEqual(null, reclamacionResult.SAC_CodigoPostalContacto__c, 'No se han podido rellenar los campos postales');
        Assert.areNotEqual(null, reclamacionResult.SAC_PoblacionContacto__c, 'No se han podido rellenar los campos postales');
        Assert.areNotEqual(null, reclamacionResult.SAC_ProvinciaContacto__c, 'No se han podido rellenar los campos postales');
        Assert.areNotEqual(null, reclamacionResult.SAC_PaisContacto__c, 'No se han podido rellenar los campos postales');

    }

    @isTest
    static void modificarPermisoLetradoTest() {
        Case casoPretension = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'Pret1' LIMIT 1];
        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sac5reclamacion@test.test' LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            casoPretension.OwnerId = usuario.Id;
            SAC_DatabaseDML.updateDML(casoPretension, false);
            //Database.update(casoPretension);
            Test.stopTest();
        }

        CaseShare csResult = [SELECT CaseId, UserOrGroupId FROM CaseShare WHERE CaseId = :casoPretension.SAC_Reclamacion__c AND UserOrGroupId = :usuario.Id];
        
        Assert.areEqual(usuario.Id, csResult.UserOrGroupId, 'No se ha podido insertar el permiso sobre la reclamación padre');
    }		

    @isTest
    static void entidadAfectadaPrincipalTest() {
        List<Case> listaCasos = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c, SAC_PretensionPrincipal__c, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c, RecordType.DeveloperName FROM Case WHERE SuppliedCompany = 'Pret1' OR Subject = 'TestRec'];
        Case reclamacion = new Case();
        Case pretension = new Case();
        for (Case caso : listaCasos) {
            if (caso.RecordType.DeveloperName == 'SAC_Reclamacion') {
                reclamacion.Id = caso.Id;
            }
            if (caso.RecordType.DeveloperName == 'SAC_Pretension') {
                pretension.Id = caso.Id;
            }
        }

        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            reclamacion.SAC_PretensionPrincipal__c = pretension.Id;
            pretension.SAC_Entidad_Afectada__c = 'SAC_009';
            pretension.SAC_EntidadProductora__c = 'Microbank';
            List<Case> listaUpdate = new List<Case>();
            listaupdate.add(reclamacion);
            listaupdate.add(pretension);
            SAC_DatabaseDML.updateListDML(listaUpdate, false);
            //Database.update(listaUpdate);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT Id, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        Assert.areEqual('SAC_009', reclamacionResult.SAC_Entidad_Afectada__c, 'No se ha podido asignar la entidad afectada de la pretensión principal a la reclamación padre');
        Assert.areEqual('Microbank', reclamacionResult.SAC_EntidadProductora__c, 'No se ha podido asignar la entidad productora de la pretensión principal a la reclamación padre');

    }
    
     @isTest
    static void cerrarTareasTest() {
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
        //SAC_Accion__c accion = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c ='TareaTest' LIMIT 1];
        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sac5reclamacion@test.test' LIMIT 1];
        
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);      
        SAC_DatabaseDML.insertDML(psa, false); 
        //Database.insert(psa);
        
        reclamacion.Status = 'Rechazado';
       	reclamacion.SAC_StatusAuxiliar__c = reclamacion.Status;
        reclamacion.SAC_MotivoRechazo__c = 'Spam';
        
        System.runAs(usuario){
        	Test.startTest();
            SAC_DatabaseDML.updateDML(reclamacion, false);
        	//Database.update(reclamacion);
        	Test.stopTest();
        }
        
        SAC_Accion__c accion2 = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c ='TareaTest' LIMIT 1];
        
        Assert.areEqual('SAC_Finalizada', accion2.SAC_Estado__c, 'No se ha cerrado la tarea');
    }

    @isTest
    static void modificarPermisoGestorTest() {
        List<Case> listaCasos = [SELECT Id, Status, OwnerId, RecordType.DeveloperName FROM Case WHERE Subject = 'TestRec' OR SuppliedCompany = 'Pret1'];
        User usuario2 = [SELECT Id, UserName FROM User WHERE UserName = 'Name123456@test.com' LIMIT 1];
        Case reclamacion = new Case();
        Case pretension = new Case();

        for (Case caso : listaCasos) {
            if (caso.RecordType.DeveloperName == 'SAC_Reclamacion') {
                reclamacion.Id = caso.Id;
            }
            if (caso.RecordType.DeveloperName == 'SAC_Pretension') {
                pretension.Id = caso.Id;
            }
        }
        reclamacion.OwnerId = usuario2.Id;

        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        CaseShare cs = [SELECT CaseId, UserOrGroupId FROM CaseShare WHERE CaseId = :pretension.Id AND UserOrGroupId = :reclamacion.OwnerId];
        Assert.areNotEqual(null, cs, 'No se ha podido insertar el permiso');
    }
    
    @isTest
    static void guardarComentariosRechazoTest(){
        
        Case reclamacion = [SELECT Id, Status,SAC_StatusAuxiliar__c, SAC_MotivoRechazo__c, Comments FROM Case WHERE Subject = 'TestRec'];
        reclamacion.Status = 'Rechazado';
        reclamacion.SAC_StatusAuxiliar__c = 'Rechazado';
        reclamacion.SAC_MotivoRechazo__c = 'Otros';
        reclamacion.Comments = 'comentario';

        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

    	List<FeedItem> feeds = [SELECT Id, Body FROM FeedItem WHERE ParentId =:reclamacion.Id];
        Assert.areEqual(feeds[0].Body, 'Se ha rechazado el caso por el motivo: ' + reclamacion.SAC_MotivoRechazo__c+'\n Observación: ' + reclamacion.Comments);    
    }
    
    @isTest
    static void bajaPretensionesRechazoTest(){
        
        Case reclamacion = [SELECT Id, Status,SAC_StatusAuxiliar__c, SAC_MotivoRechazo__c, Comments FROM Case WHERE Subject = 'TestRec'];
        //Case casoPretension = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'Pret1' LIMIT 1];
        reclamacion.Status = 'Rechazado';
        reclamacion.SAC_StatusAuxiliar__c = 'Rechazado';
        reclamacion.SAC_MotivoRechazo__c = 'Otros';
        reclamacion.Comments = 'comentario';
        reclamacion.CC_Rechazar_Reabrir_Caso__c = true;

        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }
        
        Case casoPretension2 = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'Pret1' LIMIT 1];

        Assert.areEqual('SAC_009', casoPretension2.Status, 'No se ha dado de baja las pretensiones');    
    }
    
    // @isTest
    // static void entidadAfectadaProductoraTest() {
    //     List<Case> listaCasos = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c, SAC_PretensionPrincipal__c, SAC_EntidadProductora__c, RecordType.DeveloperName FROM Case WHERE SuppliedCompany = 'Pret1' OR Subject = 'TestRec'];
    //     Case reclamacion = new Case();
    //     Case pretension = new Case();
    //     for (Case caso : listaCasos) {
    //         if (caso.RecordType.DeveloperName == 'SAC_Reclamacion') {
    //             reclamacion.Id = caso.Id;
    //         }
    //         if (caso.RecordType.DeveloperName == 'SAC_Pretension') {
    //             pretension.Id = caso.Id;
    //         }
    //     }

    //     Test.startTest();
    //     reclamacion.SAC_PretensionPrincipal__c = pretension.Id;
    //     pretension.SAC_EntidadProductora__c = 'Microbank';
    //     List<Case> listaUpdate = new List<Case>();
    //     listaupdate.add(reclamacion);
    //     listaupdate.add(pretension);
    //     Database.update(listaUpdate);
    //     Test.stopTest();

    //     Case reclamacionResult = [SELECT Id, SAC_EntidadProductora__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];

    //     Assert.areEqual('Microbank', reclamacionResult.SAC_EntidadProductora__c, 'No se ha podido asignar la entidad productora de la pretensión principal a la reclamación padre');
    // }		

    @isTest
    static void scheduleAlertaNegociacionTest() {
        Case reclamacion = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c, SAC_PretensionPrincipal__c, SAC_EntidadProductora__c, RecordType.DeveloperName FROM Case WHERE Subject = 'TestRec'];

        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            reclamacion.Status = 'SAC_007';
            reclamacion.SAC_StatusAuxiliar__c = reclamacion.Status;
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        Assert.areEqual('SAC_007', reclamacionResult.Status, 'No se ha podido schedular la alerta de negociación');
    }		

    @isTest
    static void scheduleAlertaSubsanacionTest() {
        Case reclamacion = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c, SAC_PretensionPrincipal__c, SAC_EntidadProductora__c, RecordType.DeveloperName FROM Case WHERE Subject = 'TestRec'];

        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            reclamacion.Status = 'SAC_006';
            reclamacion.SAC_StatusAuxiliar__c = reclamacion.Status;
            reclamacion.SAC_TipoConsumidor__c = 'Si';
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        Assert.areEqual('SAC_006', reclamacionResult.Status, 'No se ha podido schedular la alerta de negociación');
    }

    @isTest
    static void informarGrupoLetradoTest() {
        Case reclamacion = [SELECT Id, Status, SAC_GrupoLetrado__c, SAC_PretensionPrincipal__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        Case pretension = [SELECT Id, SEG_Grupo__c, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'Pret2' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'COPS' LIMIT 1];


        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            pretension.SEG_Grupo__c = grupo.id;

            SAC_DatabaseDML.updateDML(pretension, false);
            //Database.update(pretension);
            Test.stopTest();
        }
       
        Case reclamacionResult = [SELECT Id, Status, SAC_GrupoLetrado__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];

        Assert.areNotEqual(reclamacion.SAC_GrupoLetrado__c, reclamacionResult.SAC_GrupoLetrado__c, 'No se ha cambiado el grupo Letrado.');
    }		
    
    @isTest
    static void informarFechaUltimaActualizacionTest() {
        Case reclamacion = [SELECT Id, Status, SAC_FechaUltimaAsignacionLetrado__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];


        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            reclamacion.Status = 'SAC_002';
            reclamacion.SAC_StatusAuxiliar__c = 'SAC_002';
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT Id, Status, SAC_FechaUltimaAsignacionLetrado__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        
        Assert.areNotEqual(reclamacion.SAC_FechaUltimaAsignacionLetrado__c, reclamacionResult.SAC_FechaUltimaAsignacionLetrado__c, 'No se ha actualizado la fecha de ultima asignacion letrado.');
    }	


    @isTest
    static void crearTaskMisClientesTest() {
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];

        System.runAs(usuario){
            Test.startTest();
            reclamacion.OS_Fecha_Resolucion__c = system.now();
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        List<CBK_SCH_PendingProcess__c> listaPendingProcess = [SELECT Id FROM CBK_SCH_PendingProcess__c WHERE recordId__c = :reclamacion.Id];

        Assert.areEqual(false, listaPendingProcess.isEmpty(), 'No se ha creado el pending proccess');
    }

    @isTest
    static void comprobarResultadoNegociacionTest() {
        List <Case> pretensiones = new List <Case>();
        Case pret1 = [SELECT Id FROM Case WHERE SuppliedCompany = 'Pret4' LIMIT 1];
        Case pret2 = [SELECT Id FROM Case WHERE SuppliedCompany = 'Pret5' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];

        System.runAs(usuario){
            Test.startTest();
            pret1.SAC_ResultadoNegociacion__c = 'Sin acuerdo';
            pretensiones.add(pret1);
            pret2.SAC_ResultadoNegociacion__c = 'Sin acuerdo';
            pretensiones.add(pret2);
            SAC_DatabaseDML.updateListDML(pretensiones, false);
            //Database.update(pretensiones);
            Test.stopTest();
        }

        Case reclamacion = [SELECT Id, SAC_ResultadoNegociacion__c FROM Case WHERE Subject = 'TestRec4' LIMIT 1];

        Assert.areEqual('Sin acuerdo', reclamacion.SAC_ResultadoNegociacion__c, 'No se completado correctamente el campo en la reclamacion');
    }

    @isTest
    static void informarEsClienteTest() {
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);       
        SAC_DatabaseDML.insertDML(psa, false);
        //Database.insert(psa);

        System.runAs(usuario){
            Test.startTest();
            List<Account> listaCuenta = SAC_TestDataFactory.crearCuentasNoClientePA(1);
            listaCuenta[0].AV_Empleado__c = true;
            SAC_DatabaseDML.insertListDML(listaCuenta, false);
            //Database.insert(listaCuenta);

            reclamacion.AccountId = listaCuenta[0].Id;
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT Id, SAC_Empleado__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        Assert.areEqual(true, reclamacionResult.SAC_Empleado__c, 'No se ha rellenado el campo empleado de la reclamación');
    }

    @isTest
    static void actualizarArgumentarioResolucionTest() {
        List<Case> listaCasos = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c, SAC_PretensionPrincipal__c, SAC_MotivoSentidoResolucion__c, RecordType.DeveloperName FROM Case WHERE SuppliedCompany = 'Pret1'  OR Subject = 'TestRec'];
        Case pretension = new Case();
        Case reclamacion = new Case();

        for (Case caso : listaCasos) {
            if (caso.RecordType.DeveloperName == 'SAC_Pretension') {
                pretension.Id = caso.Id;
                pretension.SAC_Reclamacion__c = caso.SAC_Reclamacion__c;
            }
            if (caso.RecordType.DeveloperName == 'SAC_Reclamacion') {
                reclamacion.Id = caso.Id;
            }
        }

        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            pretension.SAC_MotivoSentidoResolucion__c = 'Prueba test argumentario';
            List<Case> listaUpdate = new List<Case>();
            listaupdate.add(pretension); 
            listaupdate.add(reclamacion); 
            SAC_DatabaseDML.updateListDML(listaUpdate, false);
            //Database.update(listaUpdate);
            Test.stopTest();
        }
        Case preteResult = [SELECT Id, CaseNumber, SAC_MotivoSentidoResolucion__c FROM Case WHERE SuppliedCompany = 'Pret1' LIMIT 1];
        Case reclamacionResult = [SELECT Id, CaseNumber, SAC_ArgumentarioPretensiones__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        Assert.areEqual(preteResult.CaseNumber + '  ' + 'A favor de la entidad' + ': ' + '\r\n' + preteResult.SAC_MotivoSentidoResolucion__c, reclamacionResult.SAC_ArgumentarioPretensiones__c, 'No se ha actualizado el argumentario correctamente');
    }

    @isTest
    static void validarReclamacionTest() {

        Case pret1 = [SELECT Id FROM Case WHERE SuppliedCompany = 'Pret4' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];

        System.runAs(usuario){
            Test.startTest();
            pret1.SAC_ValidacionMCC__c = true;
            SAC_DatabaseDML.updateDML(pret1, false);
            //Database.update(pret1);
            Test.stopTest();
        }

        Case pretFinal = [SELECT Id, SAC_ValidacionMCC__c FROM Case WHERE SuppliedCompany = 'Pret4' LIMIT 1];

        Assert.areNotEqual(false, pretFinal.SAC_ValidacionMCC__c, 'No se ha validado correctamente la pretension');
    }


    @isTest
    static void informarFechaDerivacion() {
      
        Case reclamacion = [SELECT Id, Status, SAC_FechaDerivacion__c FROM Case WHERE Subject= 'TestRec2' LIMIT 1];
        User user = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];

        System.runAs(user){
            Test.startTest();
            //El estado de derivación es SAC_008
            reclamacion.Status = 'SAC_008';
            reclamacion.SAC_StatusAuxiliar__c = 'SAC_008';
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case reclamacionEditada = [SELECT Id, Status, SAC_FechaDerivacion__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        Assert.areNotEqual(reclamacion.SAC_FechaDerivacion__c, reclamacionEditada.SAC_FechaDerivacion__c, 'No se ha actualizado la fecha de derivación.');
    }	


    @isTest
    static void informarFechaEjecucion() {

        Case reclamacion = [SELECT Id, Status, SAC_FechaEjecucion__c , CC_Oficina_Afectada_Lookup__c FROM Case WHERE Subject= 'TestRec2' LIMIT 1];
        User user = [SELECT Id FROM User WHERE Username = 'sacadmin1906@test.test'];
     
        System.runAs(user){
            Test.startTest();
            //El estado de derivación es SAC_004
            reclamacion.Status = 'SAC_004';
            reclamacion.SAC_StatusAuxiliar__c = 'SAC_004';
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case reclamacionEditada = [SELECT Id, Status, SAC_FechaEjecucion__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        Assert.areNotEqual(reclamacion.SAC_FechaEjecucion__c, reclamacionEditada.SAC_FechaEjecucion__c, 'No se ha actualizado la fecha de ejecución.');
    }	

    @isTest
    static void informarDetenidoDesdeTest() {

        Case reclamacion = [SELECT Id, Status, SAC_DetenidoDesde__c FROM Case WHERE Subject= 'TestRec2' LIMIT 1];
        User user = [SELECT Id FROM User WHERE Username = 'sacadmin1906@test.test'];
     
        System.runAs(user){
            Test.startTest();
            //El estado de subsanacion es SAC_006
            reclamacion.Status = 'SAC_006';
            reclamacion.SAC_StatusAuxiliar__c = 'SAC_006';
            SAC_DatabaseDML.updateDML(reclamacion, true);
            Test.stopTest();
        }

        Case reclamacionEditada = [SELECT Id, Status, SAC_DetenidoDesde__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        Assert.areNotEqual(reclamacion.SAC_DetenidoDesde__c, reclamacionEditada.SAC_DetenidoDesde__c, 'No se ha actualizado la fecha de detenido desde.');
    }	

    @isTest
    static void informarGrupoLetradoTest2() {
        Case reclamacion = [SELECT Id, Status, SAC_GrupoLetrado__c, SAC_PretensionPrincipal__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        Case pretension = [SELECT Id, SEG_Grupo__c, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'Pret2' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'COPS' LIMIT 1];

        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            Map<String, Object> camposCons = new Map<String, Object>();
            camposCons.put('Subject', 'Consulta2');
            camposCons.put('OwnerId', usuario.id);

            Case consulta = SAC_TestDataFactory.crearCaso('Consulta',camposCons);
            consulta.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();   
            consulta.CC_CasoRelacionado__c = reclamacion.Id;
            SAC_DatabaseDML.insertDML(consulta, true);

            pretension.SEG_Grupo__c = grupo.id;
            SAC_DatabaseDML.updateDML(pretension, true);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT Id, Status, SAC_GrupoLetrado__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        
        Assert.areNotEqual(reclamacion.SAC_GrupoLetrado__c, reclamacionResult.SAC_GrupoLetrado__c, 'No se ha cambiado el grupo Letrado.');
    }		

    @isTest
    static void actualizarResumenManualTest() {
        List<Case> listaCasos = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c, SAC_PretensionPrincipal__c, SAC_ResumenManual__c, RecordType.DeveloperName FROM Case WHERE SuppliedCompany = 'Pret1'  OR Subject = 'TestRec'];
        Case pretension = new Case();
        Case reclamacion = new Case();

        for (Case caso : listaCasos) {
            if (caso.RecordType.DeveloperName == 'SAC_Pretension') {
                pretension.Id = caso.Id;
                pretension.SAC_Reclamacion__c = caso.SAC_Reclamacion__c;
            }
            if (caso.RecordType.DeveloperName == 'SAC_Reclamacion') {
                reclamacion.Id = caso.Id;
            }
        }

        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            pretension.SAC_ResumenManual__c = 'Prueba test resumen';
            List<Case> listaUpdate = new List<Case>();
            listaupdate.add(pretension); 
            listaupdate.add(reclamacion); 
            SAC_DatabaseDML.updateListDML(listaUpdate, true);
            Test.stopTest();
        }
        Case reclamacionResult = [SELECT Id, CaseNumber, SAC_ResumenManual__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        Assert.areNotEqual(reclamacionResult, null, 'No se ha actualizado el resumen correctamente');
    }
    
    @isTest
    static void cambiarOwnerReclamaciones() {
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        List<Case> reclamaciones = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c, SAC_PretensionPrincipal__c, SAC_ResumenManual__c, RecordType.DeveloperName FROM Case WHERE Subject = 'TestRec'];
        List<Case> pretensiones = [SELECT Id, SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c IN: reclamaciones];
        System.runAs(usuario){
            Test.startTest();
            SAC_Reclamacion.insertarCaseSharePorReclamacionOPretension(pretensiones);
            Test.stopTest();
        }
        List<CaseShare> sharings = [SELECT Id, RowCause FROM CaseShare WHERE RowCause = 'Manual' AND CaseId IN: pretensiones LIMIT 1];

        System.assertEquals(sharings.isEmpty(), false, 'Existen sharings en las pretensiones');
    }
    
    @isTest
    static void cambiarOwnerPretensiones() {
        User usuario = [SELECT Id FROM User WHERE Username = 'sac5reclamacion@test.test' AND isActive = true];
        List<Case> reclamaciones = [SELECT Id, Status, OwnerId, SAC_Reclamacion__c, SAC_PretensionPrincipal__c, SAC_ResumenManual__c, RecordType.DeveloperName FROM Case WHERE Subject = 'TestRec'];
        List<Case> pretensiones = [SELECT Id, SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c IN: reclamaciones];
        System.runAs(usuario){
            Test.startTest();
            SAC_Reclamacion.insertarCaseSharePorReclamacionOPretension(reclamaciones);
            Test.stopTest();
        }
        List<CaseShare> sharings = [SELECT Id, RowCause FROM CaseShare WHERE RowCause = 'Manual' AND CaseId IN: pretensiones LIMIT 1];

        System.assertEquals(sharings.isEmpty(), false, 'Existen sharings en las pretensiones');
    }

}