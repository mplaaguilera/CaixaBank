@isTest
public with sharing class GRR_Activity_Test {

    private static Contact crearContacto() {
        Contact contacto = new Contact (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
            LastName = 'Test',
            CC_Numero_Documento__c = '36592162J'
        );
        insert contacto;
        return contacto;
    }

    private static Case crearCasoConContacto(String idcont) {
        Contact contacto = [SELECT Id FROM Contact WHERE Id = :idcont];
        CC_MCC__c mccTematica = new CC_MCC__c(
            Name = 'MCC Tematica',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'TEGR-000001',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
        );
        insert mccTematica;
        CC_MCC__c mccProducto = new CC_MCC__c(
            Name = 'MCC Producto',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'PRGR-000001',
            CC_Tematica__c = mccTematica.Id
        );
        insert mccProducto;    
        CC_MCC__c mccMotivo = new CC_MCC__c(
            Name = 'MCC Motivo',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'MOGR-000001',
            CC_Producto_Servicio__c = mccProducto.Id
        );
        insert mccMotivo;
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Test',
            ContactId = contacto.Id,
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id,
            CC_MCC_Motivo__c = mccMotivo.Id
        );           
        insert caso;
        return caso;
    }

    @isTest
    public static void testCrearlstTareas() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Task tarea = new Task();
            List<Task> lstTareas = new List<Task>();
            lstTareas.add(tarea);

            GRR_Activity.crearlstTareas(lstTareas);
            List<Task> lstTaskCreadas = [SELECT Id FROM Task];
            System.assertEquals(lstTaskCreadas.isEmpty(), false);
            GRR_Activity.finalizarActividadesCaso(lstTaskCreadas,'Traslado Colaborador');
            List<Task> lstTareasCreadasDos = [SELECT Id, Status FROM Task];
            System.assertEquals(lstTareasCreadasDos[0].Status, 'Completed');

            Test.stopTest();
        }
    }

    @isTest
    public static void testCrearTarea() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Map<String, Object> camposTarea = new Map<String, Object>();
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            camposTarea.put('Type', 'Correo - Entrada');
            camposTarea.put('Subject', 'Test Subject');
            camposTarea.put('ActivityDate', System.today());
            camposTarea.put('Status', 'Completed');
            camposTarea.put('Description', 'Test Description');
            camposTarea.put('WhatId', caso.Id);
            camposTarea.put('WhoId', caso.ContactId);

            Task tareaCreada = GRR_Activity.crearTarea('GRR_Task', camposTarea);
            System.assertEquals('Correo - Entrada', tareaCreada.Type);

            Test.stopTest();
        }
    }

    @isTest
    public static void testFinalizarActividadCaso() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Id rtTarea = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            Task tarea = new Task();
            tarea.RecordTypeId = rtTarea;
            tarea.WhatId = caso.Id;
            tarea.WhoId = caso.ContactId;
            tarea.Status = 'Open';
            tarea.Type = 'Traslado Colaborador';
            tarea.Subject = 'Test Subject';
            tarea.ActivityDate = System.today();
            insert tarea;

            GRR_Activity.finalizarActividadCaso(caso.Id, 'Traslado Colaborador', null, null);
            Task tareaUpdate = [SELECT Id, Status FROM Task WHERE WhatId = :caso.Id LIMIT 1];
            System.assertEquals('Completed', tareaUpdate.Status);

            Test.stopTest();
        }
    }

    @isTest
    public static void testCrearActividadRetipificacion() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            CC_MCC__c mccTematica2 = new CC_MCC__c(
                Name = 'MCC Tematica 2',
                CC_Fecha_Vigencia_Inicio__c = Date.today(),
                CC_Tipo_Cliente__c = 'Cliente (GRR)',
                CC_Codigo_Externo__c = 'TEGR-000002',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
            );
            insert mccTematica2;
            CC_MCC__c mccProducto2 = new CC_MCC__c(
                Name = 'MCC Producto 2',
                CC_Fecha_Vigencia_Inicio__c = Date.today(),
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
                CC_Tipo_Cliente__c = 'Cliente (GRR)',
                CC_Codigo_Externo__c = 'PRGR-000002',
                CC_Tematica__c = mccTematica2.Id
            );
            insert mccProducto2;
            CC_MCC__c mccMotivo2 = new CC_MCC__c(
                Name = 'MCC Motivo 2',
                CC_Fecha_Vigencia_Inicio__c = Date.today(),
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
                CC_Tipo_Cliente__c = 'Cliente (GRR)',
                CC_Codigo_Externo__c = 'MOGR-000002',
                CC_Producto_Servicio__c = mccProducto2.Id
            );
            insert mccMotivo2;

            Id tareaCreada = GRR_Activity.crearActividadRetipificacion(caso.Id, mccTematica2.Id, mccProducto2.Id, mccMotivo2.Id);
            System.assertEquals(tareaCreada != null, true);

            Test.stopTest();
        }
    }

    @isTest
    public static void testReabrirTareaTrasladoColab() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Id rtTarea = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            Task tarea = new Task();
            tarea.RecordTypeId = rtTarea;
            tarea.WhatId = caso.Id;
            tarea.WhoId = caso.ContactId;
            tarea.Status = 'Completed';
            tarea.Type = 'Traslado Colaborador';
            tarea.Subject = 'Test Subject';
            tarea.ActivityDate = System.today();
            insert tarea;
            
            GRR_Activity.reabrirTareaTrasladoColab(caso.Id);
            Task tareaUpdate = [SELECT Id, Status FROM Task WHERE Id = :tarea.Id LIMIT 1];
            System.assertEquals('Open', tareaUpdate.Status);

            Test.stopTest();
        }
    }

}