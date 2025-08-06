@isTest
public with sharing class GRR_Borrado_Carga_Cascada_Test {
    
    private static void crearDatos(){
        //Creación MCCs
        List<CC_MCC__c> lstTematicas = new List<CC_MCC__c>();
        CC_MCC__c mccTematica = new CC_MCC__c(
            Name = 'MCC Tematica',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'TEGR-000001',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
        );
        lstTematicas.add(mccTematica);
        CC_MCC__c mccTematicaPendiente = new CC_MCC__c(
            Name = 'Pendiente de clasificar',
            CC_Fecha_Vigencia_Inicio__c = Date.today()-1,
            CC_Fecha_Vigencia_Fin__c = Date.today(),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'TEGR-000002',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
        );
        lstTematicas.add(mccTematicaPendiente);
        insert lstTematicas;

        List<CC_MCC__c> lstProductos = new List<CC_MCC__c>();
        CC_MCC__c mccProducto = new CC_MCC__c(
            Name = 'MCC Producto',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'PRGR-000001',
            CC_Tematica__c = mccTematica.Id
        );
        lstProductos.add(mccProducto);
        CC_MCC__c mccProductoPendiente = new CC_MCC__c(
            Name = 'Pendiente de clasificar',
            CC_Fecha_Vigencia_Inicio__c = Date.today()-1,
            CC_Fecha_Vigencia_Fin__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'PRGR-000002',
            CC_Tematica__c = mccTematicaPendiente.Id
        );
        lstProductos.add(mccProductoPendiente);
        insert lstProductos;

        List<CC_MCC__c> lstMotivos = new List<CC_MCC__c>();
        CC_MCC__c mccMotivo = new CC_MCC__c(
            Name = 'MCC Motivo',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'MOGR-000001',
            CC_Producto_Servicio__c = mccProducto.Id
        );
        lstMotivos.add(mccMotivo);
        CC_MCC__c mccMotivoPendiente = new CC_MCC__c(
            Name = 'Pendiente de clasificar',
            CC_Fecha_Vigencia_Inicio__c = Date.today()-1,
            CC_Fecha_Vigencia_Fin__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'MOGR-000002',
            CC_Producto_Servicio__c = mccProductoPendiente.Id
        );
        lstMotivos.add(mccMotivoPendiente);
        insert lstMotivos;

        //Creación cargas 
        List<GRR_Carga__c> lstCargas = new List<GRR_Carga__c>();
        GRR_Carga__c cargaComite = new GRR_Carga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Carga__c', 'GRR_Carga'),
            GRR_NombreDelFichero__c = 'Fichero actas de comité clases de test',
            GRR_TipoDeFichero__c = 'Acta de comité'
        );
        lstCargas.add(cargaComite);
        GRR_Carga__c cargaRecobros = new GRR_Carga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Carga__c', 'GRR_Carga'),
            GRR_NombreDelFichero__c = 'Fichero recobros clases de test',
            GRR_TipoDeFichero__c = 'Recobro'
        );
        lstCargas.add(cargaRecobros);
        insert lstCargas;

        //Creación casos
        List<Case> lstCasos = new List<Case>();
        Group grupo = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName = 'GRR_Buzon_Barcelona' AND Type = 'Queue' LIMIT 1];
        Case casoComite1 = new Case(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Comité 1',
            OwnerId = grupo.Id,
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id,
            CC_MCC_Motivo__c = mccMotivo.Id
        );
        lstCasos.add(casoComite1);
        Case casoComite2 = new Case(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Comité 2',
            OwnerId = grupo.Id
        );
        lstCasos.add(casoComite2);
        Case casoRecobro1 = new Case(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Recobro 1'
        );
        lstCasos.add(casoRecobro1);
        Case casoRecobro2 = new Case(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Recobro 2'
        );
        lstCasos.add(casoRecobro2);
        insert lstCasos;

        //Creación registros de carga
        List<GRR_RegistroCarga__c> lstRegistros = new List<GRR_RegistroCarga__c>();
        GRR_RegistroCarga__c registroComite1 = new GRR_RegistroCarga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Acta_comite'),
            GRR_Fichero__c = cargaComite.Id,
            GRR_Caso__c = casoComite1.Id
        );
        lstRegistros.add(registroComite1);
        GRR_RegistroCarga__c registroComite2 = new GRR_RegistroCarga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Acta_comite'),
            GRR_Fichero__c = cargaComite.Id,
            GRR_Caso__c = casoComite2.Id
        );
        lstRegistros.add(registroComite2);
        GRR_RegistroCarga__c registroRecobro1 = new GRR_RegistroCarga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Recobro'),
            GRR_Fichero__c = cargaRecobros.Id,
            GRR_Caso__c = casoRecobro1.Id
        );
        lstRegistros.add(registroRecobro1);
        GRR_RegistroCarga__c registroRecobro2 = new GRR_RegistroCarga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Recobro'),
            GRR_Fichero__c = cargaRecobros.Id,
            GRR_Caso__c = casoRecobro2.Id
        );
        lstRegistros.add(registroRecobro2);
        insert lstRegistros;
    }

    @isTest
    public static void testBorradoCargas() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            crearDatos();
            GRR_Carga__c ficheroComite = [SELECT Id FROM GRR_Carga__c WHERE GRR_NombreDelFichero__c = 'Fichero actas de comité clases de test' LIMIT 1];
            GRR_Carga__c ficheroRecobro = [SELECT Id FROM GRR_Carga__c WHERE GRR_NombreDelFichero__c = 'Fichero recobros clases de test' LIMIT 1];

            Test.startTest();
            GRR_Borrado_Carga_Cascada.eliminarCarga(ficheroComite.Id);
            GRR_Borrado_Carga_Cascada.eliminarCarga(ficheroRecobro.Id);
            Test.stopTest();
            
            System.assertEquals(0, [SELECT COUNT() FROM GRR_Carga__c WHERE GRR_NombreDelFichero__c = 'Fichero actas de comité clases de test']);
            System.assertEquals(0, [SELECT COUNT() FROM GRR_Carga__c WHERE GRR_NombreDelFichero__c = 'Fichero recobros clases de test']);
            System.assertEquals(0, [SELECT COUNT() FROM GRR_RegistroCarga__c]);
            System.assertEquals(0, [SELECT COUNT() FROM Case WHERE Status != 'Rechazado']);
        }
    }
}