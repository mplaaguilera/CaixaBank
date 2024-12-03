@isTest
public class FRA_Case_Gestion_Controller_Test {
  
    private static Case crearCasoConCanalProcedencia(Id tematicaId,Id productoId,Id motivoId,Id causaId) {
        Case caso2 = new Case();
        caso2.Subject = 'Caso de prueba TF7';
        caso2.recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
        caso2.Origin = 'Phone';
        caso2.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
        caso2.CC_MCC_Tematica__c = tematicaId;
        caso2.CC_MCC_ProdServ__c = productoId;
        caso2.CC_MCC_Motivo__c = motivoId;
        caso2.CC_MCC_Causa__c = causaId;
        caso2.CC_En_Tercer_Nivel__c = true;
        caso2.Status = 'Activo';

        insert caso2;
        return caso2;
    }
    
    private static Case crearCasoSinCanalProcedencia(Id tematicaId,Id productoId,Id motivoId,Id causaId) {
        Case caso3 = new Case();
        caso3.Subject = 'Caso de prueba TF8';
        caso3.recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
        caso3.Origin = 'Phone';
        caso3.CC_MCC_Tematica__c = tematicaId;
        caso3.CC_MCC_ProdServ__c = productoId;
        caso3.CC_MCC_Motivo__c = motivoId;
        caso3.CC_MCC_Causa__c = causaId;
        caso3.CC_En_Tercer_Nivel__c = true;
        caso3.Status = 'Activo';

        insert caso3;
        return caso3;
    }
    
    private static CC_MCC__c crearTematica2() {
        CC_MCC__c mccTematica2 = new CC_MCC__c();
        mccTematica2.Name = 'MCC Tematica 2';
        mccTematica2.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = Date.today()-1;
        mccTematica2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        mccTematica2.CC_Codigo_Externo__c = 'TEFR-000002';
        mccTematica2.CC_Canal_Operativo__c = 'Sin canal';

        insert mccTematica2;
        return mccTematica2;
    }
    
    private static CC_MCC__c crearProducto2(Id tematicaId) {
        CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Cuenta corriente 2';
        mccProducto2.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = Date.today()-1;
        mccProducto2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        mccProducto2.CC_Tematica__c = tematicaId;
        mccProducto2.CC_Codigo_Externo__c = 'PRFR-000002';
        
        insert mccProducto2;
        return mccProducto2;
    }
    
    private static CC_MCC__c crearMotivo2(Id productoId) {
        CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Apertura sin autorización 2';
        mccMotivo2.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = Date.today()-1;
        mccMotivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        mccMotivo2.CC_Codigo_Externo__c = 'MOFR-000002';
        mccMotivo2.CC_Producto_Servicio__c = productoId;
        mccMotivo2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        mccMotivo2.OS_Requiere_Ref_Operacion__c = true;
       
        insert mccMotivo2;
        return mccMotivo2;     
    }

    private static CC_MCC__c crearCausa2(Id motivoId) {        
        CC_MCC__c mccCausa2 = new CC_MCC__c();
        mccCausa2.Name = 'Causa 2';
        mccCausa2.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        mccCausa2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        mccCausa2.CC_Motivo__c = motivoId;
        mccCausa2.CC_Codigo_Externo__c = 'CAFR-000002';
        
        insert mccCausa2;
        return mccCausa2;
    }
    
    private static CC_MCC__c crearSolucion2(Id causaId) {  
        CC_MCC__c mccSolucion2 = new CC_MCC__c();
        mccSolucion2.Name = 'Solucion 2';
        mccSolucion2.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        mccSolucion2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccSolucion2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
        mccSolucion2.CC_Causa__c = causaId;
        mccSolucion2.CC_Codigo_Externo__c = 'SOFR-000002';
        mccSolucion2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';

        insert mccSolucion2;
        return mccSolucion2;
    }     
    
    private static CBK_PicklistValues__c crearCustomPicklist() {  
        CBK_PicklistValues__c picklistLista = new CBK_PicklistValues__c();
        picklistLista.Name = 'FRA_CampanaFraude__c';
        picklistLista.CBK_Object__c = 'Case';
        picklistLista.CBK_Project__c = 'FRA';
        picklistLista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CBK_PicklistValues__c', 'CBK_Picklist');
        insert picklistLista;
        
        CBK_PicklistValues__c picklistValor = new CBK_PicklistValues__c();
        picklistValor.Name = 'Opción campaña fraude clases de test';
        picklistValor.CBK_Object__c = 'Case';
        picklistValor.CBK_Project__c = 'FRA';
        picklistValor.CBK_Picklist__c = picklistLista.Id;
        picklistValor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CBK_PicklistValues__c', 'CBK_PicklistValue');
        
        insert picklistValor;
        return picklistValor;
    }  
        
    @isTest
    public static void getTematicas() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasIntSupFRA()){
            CC_MCC__c tematicaCli=crearTematica2();
        	CC_MCC__c prodCli= crearProducto2(tematicaCli.Id);
            CC_MCC__c motivoCli = crearMotivo2(prodCli.Id);
            CC_MCC__c causaCli = crearCausa2(motivoCli.Id);
           
            Case caso = crearCasoConCanalProcedencia(tematicaCli.Id,prodCli.Id,motivoCli.Id,causaCli.Id);
            Case caso2= crearCasoSinCanalProcedencia(tematicaCli.Id,prodCli.Id,motivoCli.Id,causaCli.Id);

            Test.startTest();
            List<OT_Picklist.Item> productosCliente = FRA_Case_Gestion_Controller.getTematicas('Cliente (FRA)', caso.Id);
            List<OT_Picklist.Item> productosEmpleado = FRA_Case_Gestion_Controller.getTematicas('Cliente (FRA)',caso2.Id);
            System.assertNotEquals(null, productosCliente);
            System.assertNotEquals(null, productosEmpleado);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getProductos() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasIntSupFRA()){
            CC_MCC__c tematicaCli=crearTematica2();
            CC_MCC__c prodCli= crearProducto2(tematicaCli.Id);
            
            Test.startTest();
            List<OT_Picklist.Item> productos = FRA_Case_Gestion_Controller.getProductos('Cliente (FRA)','');
            List<OT_Picklist.Item> productosCliente = FRA_Case_Gestion_Controller.getProductos('Cliente (FRA)', tematicaCli.Id);
            System.assertNotEquals(null, productosCliente);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getMotivos() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasIntSupFRA()){
            CC_MCC__c tematicaCli=crearTematica2();
            CC_MCC__c prodCli= crearProducto2(tematicaCli.Id);
            CC_MCC__c motivoCli = crearMotivo2(prodCli.Id);

            Test.startTest();
            List<OT_Picklist.Item> motivos = FRA_Case_Gestion_Controller.getMotivos('','');
            List<OT_Picklist.Item> motivosCliente = FRA_Case_Gestion_Controller.getMotivos('Cliente (FRA)', prodCli.Id);
            System.assertNotEquals(null, motivosCliente);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getCausas() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasIntSupFRA()){
            CC_MCC__c tematicaCli=crearTematica2();
        	CC_MCC__c prodCli= crearProducto2(tematicaCli.Id);
            CC_MCC__c motivoCli = crearMotivo2(prodCli.Id);
            CC_MCC__c causaCli = crearCausa2(motivoCli.Id);

            Test.startTest();
            List<OT_Picklist.Item> causas = FRA_Case_Gestion_Controller.getCausas('', '');
            List<OT_Picklist.Item> causasCliente = FRA_Case_Gestion_Controller.getCausas('Cliente (FRA)', motivoCli.Id);
            System.assertNotEquals(null, causasCliente);
            Test.stopTest();
        }  
    }
    
    @isTest
    public static void getSoluciones() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasIntSupFRA()){
        	CC_MCC__c tematicaCli=crearTematica2();
        	CC_MCC__c prodCli= crearProducto2(tematicaCli.Id);
            CC_MCC__c motivoCli = crearMotivo2(prodCli.Id);
            CC_MCC__c causaCli = crearCausa2(motivoCli.Id);
            CC_MCC__c solucion=crearSolucion2(causaCli.Id);

            Test.startTest();
            List<OT_Picklist.Item> soluciones = FRA_Case_Gestion_Controller.getSoluciones('', '');
            List<OT_Picklist.Item> solucionesCliente = FRA_Case_Gestion_Controller.getSoluciones('Cliente (FRA)', causaCli.Id);
            System.assertNotEquals(null, solucionesCliente);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void validarGuardarTest() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasIntSupFRA()){
            CC_MCC__c tematicaCli=crearTematica2();
            CC_MCC__c prodCli= crearProducto2(tematicaCli.Id);
            CC_MCC__c motivoCli = crearMotivo2(prodCli.Id);
            CC_MCC__c causaCli = crearCausa2(motivoCli.Id);

            Case caso = crearCasoConCanalProcedencia(tematicaCli.Id,prodCli.Id,motivoCli.Id,causaCli.id);
            
            CC_MCC__c mccMotivo4 = new CC_MCC__c();
            mccMotivo4.Name = 'Apertura sin autorización 3';
            mccMotivo4.CC_Tipo_Cliente__c = 'Cliente (FRA)';
            mccMotivo4.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccMotivo4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mccMotivo4.CC_Codigo_Externo__c = 'MO-000004';
            mccMotivo4.CC_Producto_Servicio__c = prodCli.Id;
            mccMotivo4.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            insert mccMotivo4;
            
            Test.startTest();
            FRA_Case_Gestion_Controller.init(caso.Id);
            Map<String, Object> resultado = FRA_Case_Gestion_Controller.validarGuardar(caso.Id, caso.CC_MCC_Tematica__c, caso.CC_MCC_ProdServ__c, mccMotivo4.Id, true, 'Asesoramiento', 'Test referencia operacion', 'TEST', 'TEST');
            System.assertNotEquals(null, resultado);
            Test.stopTest();
        } 
    }

    @isTest
    public static void metodosSueltos() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasIntSupFRA()){
            CC_MCC__c tematicaCli=crearTematica2();
        	CC_MCC__c prodCli= crearProducto2(tematicaCli.Id);
            CC_MCC__c motivoCli = crearMotivo2(prodCli.Id);
            CC_MCC__c causaCli = crearCausa2(motivoCli.Id);
            Case caso = crearCasoConCanalProcedencia(tematicaCli.Id,prodCli.Id,motivoCli.Id,causaCli.id);

            Test.startTest();
            FRA_Case_Gestion_Controller.crearActividad(caso.Id, caso.Subject, caso.Description);
            System.assertEquals('Caso de prueba TF7', caso.Subject);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getCampanasFraude() {
        System.runAs(FRA_TestDataFactory.usuarioSoporteFRA()){
            CBK_PicklistValues__c valorPick = crearCustomPicklist();
     		
            Test.startTest();
            List<CBK_CustomPicklist_Controller.PicklistItems> resultPicklists = FRA_Case_Gestion_Controller.getPicklistValuesFMW();
            System.assertNotEquals(0, resultPicklists.size());
            Test.stopTest();
        }
    }
}