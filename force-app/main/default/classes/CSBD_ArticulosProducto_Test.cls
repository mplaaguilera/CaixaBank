/*****************************************************************
 * Name: CSBD_ArticulosProducto_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Testear el componente CSBD_ArticulosProducto
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       05/08/24     Creación
*****************************************************************/
/**
 * @description     clase de test para el componente CSBD_ArticulosProducto
 */
@isTest
public with sharing class CSBD_ArticulosProducto_Test {
    @TestSetup
    static void makeData(){
        User usuarioGeneral = CSBD_Usuarios.usuarioGestor(); //la funcion ya hace el insert

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name IN ('CSBD_PromptUser', 'Knowledge_LSF_Permission_Set')];
        PermissionSet permiSet1 = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet1.Id;
        Database.insert(permiSetAssi);

        PermissionSet permiSet2 = permiSets[1];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuarioGeneral.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        Database.insert(permiSetAssi2);

        System.runAs(usuarioGeneral){

            //opportunity con articulo de producto
            Map<String, Object> camposOppl = new Map<String, Object>();
            camposOppl.put('CSBD_Producto__c', 'MyBox Vida');
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOppl); //la funcion ya hace el insert

            //opportunity sin articulo de producto
            Map<String, Object> camposOpp2 = new Map<String, Object>();
            camposOpp2.put('CSBD_Producto__c', 'Deposito Bonificado');
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOpp2); //la funcion ya hace el insert

            //opportunity sin producto
            CSBD_Opportunity.crearOportunidad('CSBD_CMB'); //la funcion ya hace el insert

            //articulo
            String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
            CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
            oGrupo.RecordTypeId = sRecordType3;
            oGrupo.Name = 'Grupo1';
            oGrupo.CC_External__c = 'GC-00001';
            Database.insert(oGrupo);
    
            Account cuenta = new Account();
            cuenta.Name = 'PRUEBA TEST';
            cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
            Database.insert(cuenta);
    
            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
            contacto.FirstName = 'Test';
            contacto.LastName = 'Prueba';
            contacto.Email = 'mp@test.com';
            contacto.AccountId = cuenta.Id;
            Database.insert(contacto);
    
            Datetime fecha = Datetime.now();
            Datetime fechaInicio = fecha.addHours(2);
            Datetime fechaCaducidad = fecha.addHours(10);
    
            Knowledge__kav articulo = new Knowledge__kav();
            articulo.URLName = 'Apex-Test' + System.now().getTime();
            articulo.Title = 'Articulo test MyBox Vida';
            articulo.Answer__c = 'Contenido MyBox Vida';
            articulo.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
            articulo.CC_Fecha_Caducidad__c = fechaCaducidad;
            articulo.CC_Responsable_Externo__c = contacto.Id;
            articulo.ValidationStatus = 'Validado';
            articulo.CSBD_NombresProductos__c = 'MyBox Vida';
            Database.insert(articulo);
        }
    }

    @isTest
    static void productoOppConArticulo() {
        Opportunity opp = [SELECT Id, CSBD_Producto__c FROM Opportunity WHERE CSBD_Producto__c = 'MyBox Vida'];
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        Knowledge__kav articulo = [SELECT Id, KnowledgeArticleId, PublishStatus, Title FROM Knowledge__kav WHERE Title = 'Articulo test MyBox Vida'];
        KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);

        List<CSBD_ArticulosProducto.Request> listArtProdReq = new List<CSBD_ArticulosProducto.Request>();
        CSBD_ArticulosProducto.Request artProdReq = new CSBD_ArticulosProducto.Request();
        artProdReq.objectToSummarize = opp;
        listArtProdReq.add(artProdReq);

        List<CSBD_ArticulosProducto.Response> listArtProdResponses = new List<CSBD_ArticulosProducto.Response>();
        
        System.runAs(usuario){
            Test.startTest();
            listArtProdResponses = CSBD_ArticulosProducto.buscarArticulos(listArtProdReq);
            Test.stopTest();
        }

        String resultadoEsperado = 'Detalles Articulo test MyBox Vida:/nContenido MyBox Vida/n';
        System.assertEquals(resultadoEsperado, listArtProdResponses[0].Prompt,'El articulo no se obtiene correctamente');
    }

    @isTest
    static void productoOppSinArticulo() {
        Opportunity opp = [SELECT Id, CSBD_Producto__c FROM Opportunity WHERE CSBD_Producto__c = 'Deposito Bonificado'];
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_ArticulosProducto.Request> listArtProdReq = new List<CSBD_ArticulosProducto.Request>();
        CSBD_ArticulosProducto.Request artProdReq = new CSBD_ArticulosProducto.Request();
        artProdReq.objectToSummarize = opp;
        listArtProdReq.add(artProdReq);

        List<CSBD_ArticulosProducto.Response> listArtProdResponses = new List<CSBD_ArticulosProducto.Response>();

        System.runAs(usuario){
            Test.startTest();
            listArtProdResponses = CSBD_ArticulosProducto.buscarArticulos(listArtProdReq);
            Test.stopTest();
        }

        String resultadoEsperado = 'No se han encontrado articulos relacionados con ese producto.';
        System.assertEquals(resultadoEsperado, listArtProdResponses[0].Prompt,'El mensaje obtenido no es el esperado');
    }

    @isTest
    static void oppSinProducto() {
        Opportunity opp = [SELECT Id, CSBD_Producto__c FROM Opportunity WHERE CSBD_Producto__c = null];
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_ArticulosProducto.Request> listArtProdReq = new List<CSBD_ArticulosProducto.Request>();
        CSBD_ArticulosProducto.Request artProdReq = new CSBD_ArticulosProducto.Request();
        artProdReq.objectToSummarize = opp;
        listArtProdReq.add(artProdReq);

        List<CSBD_ArticulosProducto.Response> listArtProdResponses = new List<CSBD_ArticulosProducto.Response>();

        System.runAs(usuario){
            Test.startTest();
            listArtProdResponses = CSBD_ArticulosProducto.buscarArticulos(listArtProdReq);
            Test.stopTest();
        }

        String resultadoEsperado = 'No hay un producto en CSBD_Producto__c.';
        System.assertEquals(resultadoEsperado, listArtProdResponses[0].Prompt,'El mensaje obtenido no es el esperado');
    }

    @isTest
    static void forzarException() {
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];
        List<CSBD_ArticulosProducto.Request> listArtProdReq = new List<CSBD_ArticulosProducto.Request>();

        List<CSBD_ArticulosProducto.Response> listArtProdResponses = new List<CSBD_ArticulosProducto.Response>();
        ListException exc;
        System.runAs(usuario){
            Test.startTest();
            try{
                listArtProdResponses = CSBD_ArticulosProducto.buscarArticulos(listArtProdReq);
            }
            catch(ListException listExc){
                exc = listExc;
            }
            Test.stopTest();
        }

        System.assertEquals(new List<CSBD_ArticulosProducto.Response>(), listArtProdResponses,'El error no se ha capturado correctamente');
    }
}