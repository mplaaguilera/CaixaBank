@isTest
public class CC_MCC_Automatize_Date_Test { 

    @TestSetup
    private static void crearMCC() {
        
        
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        //TEMATICAS
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];

        User usuario = new User();
        usuario.ProfileId = profileId;
        usuario.FirstName = 'Pruebafirst';
        usuario.LastName = 'Pruebalast';
        usuario.Email = 'tuser000@amamama.com';
        usuario.Username = 'tuser002@amamama.com' + System.currentTimeMillis();
        usuario.CompanyName = 'DXC';
        usuario.Title = 'title';
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'Europe/Paris';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        insert usuario;

        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordCau = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordSol = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        List <CC_MCC__c> lstTematicas = new List <CC_MCC__c>();
        
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccTematica.CC_Fecha_Vigencia_Fin__c = null;
        mccTematica.RecordTypeId = recordTem;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        lstTematicas.add(mccTematica);
        
        CC_MCC__c mccTematica2 = new CC_MCC__c();
        mccTematica2.Name = 'MCC Tematica 2';
        mccTematica2.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2023, 06, 19);
        mccTematica2.CC_Fecha_Vigencia_Fin__c = Datetime.newInstance(2023, 06, 20);
        mccTematica2.RecordTypeId = recordTem;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        lstTematicas.add(mccTematica2);
        
		insert lstTematicas;

        
        //PRODUCTO
        
        List <CC_MCC__c> lstProductos = new List <CC_MCC__c>();
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'MCC Producto';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccProducto.CC_Fecha_Vigencia_Fin__c = null;
        mccProducto.RecordTypeId = recordProd;
        mccProducto.CC_Tematica__c = lstTematicas[0].Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        lstProductos.add(mccProducto);
        
        CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'MCC Producto 2';
        mccProducto2.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccProducto2.CC_Fecha_Vigencia_Fin__c = null;
        mccProducto2.RecordTypeId = recordProd;
        mccProducto2.CC_Tematica__c = lstTematicas[1].Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002';
        lstProductos.add(mccProducto2);
        
        insert lstProductos;
        
        //MOTIVO
        
        List <CC_MCC__c> lstMotivos = new List <CC_MCC__c>();
        
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'MCC Motivo';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccMotivo.CC_Fecha_Vigencia_Fin__c = null;
        mccMotivo.RecordTypeId = recordMot;
        mccMotivo.CC_Tematica__c = lstTematicas[0].Id;
        mccMotivo.CC_Producto_Servicio__c = lstProductos[0].Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        lstMotivos.add(mccMotivo);
                
        CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'MCC Motivo 2';
        mccMotivo2.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccMotivo2.CC_Fecha_Vigencia_Fin__c = null;
        mccMotivo2.RecordTypeId = recordMot;
        mccMotivo2.CC_Tematica__c = lstTematicas[1].Id;
        mccMotivo2.CC_Producto_Servicio__c = lstProductos[1].Id;
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        lstMotivos.add(mccMotivo2);
        
        insert lstMotivos;
        
        //CAUSA
        
        List <CC_MCC__c> lstCausas = new List <CC_MCC__c>();
        
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'MCC Causa';
        mccCausa.CC_Tipo_Cliente__c = 'Empleado';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccCausa.CC_Fecha_Vigencia_Fin__c = null;
        mccCausa.RecordTypeId = recordCau;
        mccCausa.CC_Tematica__c = lstTematicas[0].Id;
        mccCausa.CC_Producto_Servicio__c = lstProductos[0].Id;
        mccCausa.CC_Motivo__c = lstMotivos[0].Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        lstCausas.add(mccCausa);
        
        CC_MCC__c mccCausa2 = new CC_MCC__c();
        mccCausa2.Name = 'MCC Causa 2';
        mccCausa2.CC_Tipo_Cliente__c = 'Empleado';
        mccCausa2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccCausa2.CC_Fecha_Vigencia_Fin__c = null;
        mccCausa2.RecordTypeId = recordCau;
        mccCausa2.CC_Tematica__c = lstTematicas[1].Id;
        mccCausa2.CC_Producto_Servicio__c = lstProductos[1].Id;
        mccCausa2.CC_Motivo__c = lstMotivos[1].Id;
        mccCausa2.CC_Codigo_Externo__c = 'CA-000002';
        lstCausas.add(mccCausa2);
        
        insert lstCausas;

        //SOLUCION
        
        List <CC_MCC__c> lstSolucion = new List <CC_MCC__c>();
        
        CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'Solucion';
        mccSolucion.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccSolucion.CC_Fecha_Vigencia_Fin__c = null;
        mccSolucion.RecordTypeId = recordSol;
        mccSolucion.CC_Tematica__c = lstTematicas[0].Id;
        mccSolucion.CC_Producto_Servicio__c = lstProductos[0].Id;
        mccSolucion.CC_Motivo__c = lstMotivos[0].Id;
        mccSolucion.CC_Causa__c = lstCausas[0].Id;
        mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
        lstSolucion.add(mccSolucion);
        
        CC_MCC__c mccSolucion2 = new CC_MCC__c();
        mccSolucion2.Name = 'Solucion 2';
        mccSolucion2.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucion2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccSolucion2.CC_Fecha_Vigencia_Fin__c = null;
        mccSolucion2.RecordTypeId = recordSol;
        mccSolucion2.CC_Tematica__c = lstTematicas[1].Id;
        mccSolucion2.CC_Producto_Servicio__c = lstProductos[1].Id;
        mccSolucion2.CC_Motivo__c = lstMotivos[1].Id;
        mccSolucion2.CC_Causa__c = lstCausas[1].Id;
        mccSolucion2.CC_Codigo_Externo__c = 'SO-000002';
        lstSolucion.add(mccSolucion2);
        
        insert lstSolucion;
        }
        
    }
    
    @isTest
    static void actualizarScheduledTem(){
        List<CC_MCC__c> mccUpdate = [SELECT Id FROM CC_MCC__c WHERE  CC_Codigo_Externo__c = 'TE-000002'];
        User usuario = [SELECT Id from User WHERE FirstName = 'Pruebafirst' LIMIT 1];
        List<String> idsMCC = new List<String>();
        if(!mccUpdate.isEmpty()){
            for(CC_MCC__c mccSelected : mccUpdate){
                idsMCC.add((String.valueOf(mccSelected.Id)));
            }
        }
        Test.startTest();
        System.runAs(usuario){
            CC_MCC_Automatize_Date.getMCC(idsMCC); 
        }  
        Test.stopTest();
    }
    
     @isTest
    static void actualizarScheduledProd(){
        List<CC_MCC__c> mccUpdate = [SELECT Id FROM CC_MCC__c WHERE  CC_Codigo_Externo__c = 'PR-000002'];
        User usuario = [SELECT Id from User WHERE FirstName = 'Pruebafirst' LIMIT 1];
        List<String> idsMCC = new List<String>();
        if(!mccUpdate.isEmpty()){
            for(CC_MCC__c mccSelected : mccUpdate){
                idsMCC.add((String.valueOf(mccSelected.Id)));
            }
        }
        Test.startTest();
        System.runAs(usuario){
            CC_MCC_Automatize_Date.getMCC(idsMCC);
        }
        Test.stopTest();
    }
    
     @isTest
    static void actualizarScheduledMot(){
        List<CC_MCC__c> mccUpdate = [SELECT Id FROM CC_MCC__c WHERE  CC_Codigo_Externo__c = 'MO-000002'];
        User usuario = [SELECT Id from User WHERE FirstName = 'Pruebafirst' LIMIT 1];
        List<String> idsMCC = new List<String>();
        if(!mccUpdate.isEmpty()){
            for(CC_MCC__c mccSelected : mccUpdate){
                idsMCC.add((String.valueOf(mccSelected.Id)));
            }
        }
        Test.startTest();
        System.runAs(usuario){
            CC_MCC_Automatize_Date.getMCC(idsMCC);
        }
        Test.stopTest();
    }
    
     @isTest
    static void actualizarScheduledCau(){
        List<CC_MCC__c> mccUpdate = [SELECT Id FROM CC_MCC__c WHERE  CC_Codigo_Externo__c = 'CA-000002'];
        User usuario = [SELECT Id from User WHERE FirstName = 'Pruebafirst' LIMIT 1];
        List<String> idsMCC = new List<String>();
        if(!mccUpdate.isEmpty()){
            for(CC_MCC__c mccSelected : mccUpdate){
                idsMCC.add((String.valueOf(mccSelected.Id)));
            }
        }
        Test.startTest();
        System.runAs(usuario){
            CC_MCC_Automatize_Date.getMCC(idsMCC);
        }
        Test.stopTest();
    }
    
    @isTest
    static void actualizarCausa(){
        User usuario = [SELECT Id from User WHERE FirstName = 'Pruebafirst' LIMIT 1];
        CC_MCC__c mccCausaUpdate = new CC_MCC__c();
        mccCausaUpdate.Name = 'MCC Causa';
        mccCausaUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccCausaUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccCausaUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccCausaUpdate.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        mccCausaUpdate.CC_Motivo__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Motivo'].Id;
        mccCausaUpdate.CC_Codigo_Externo__c = 'CA-000003';
        insert mccCausaUpdate;

        CC_MCC__c mccSolucionUpdate = new CC_MCC__c();
        mccSolucionUpdate.Name = 'Solucion1';
        mccSolucionUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucionUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccSolucionUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccSolucionUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucionUpdate.CC_Causa__c = mccCausaUpdate.Id;
        mccSolucionUpdate.CC_Codigo_Externo__c = 'SO-000003';
        insert mccSolucionUpdate;
        
        CC_MCC__c mccSolucionUpdate2 = new CC_MCC__c();
        mccSolucionUpdate2.Name = 'Solucion2';
        mccSolucionUpdate2.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucionUpdate2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccSolucionUpdate2.CC_Fecha_Vigencia_Fin__c = null;
        mccSolucionUpdate2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucionUpdate2.CC_Causa__c = mccCausaUpdate.Id;
        mccSolucionUpdate2.CC_Codigo_Externo__c = 'SO-000004';
        insert mccSolucionUpdate2;
        Test.startTest();
            System.runAs(usuario){        
                mccCausaUpdate.CC_Fecha_Vigencia_Fin__c =  Datetime.newInstance(2022, 05, 06);
                List <String> id = new List <String>();
                id.add(mccCausaUpdate.Id);
                try {
                    //CC_MCC_Automatize_Date.getMCC(id);
                    Database.update(mccCausaUpdate);
                } catch (Exception e) {
                    CBK_Log.error('Error al actualizar mccCausaUpdate' + e.getMessage());
                }
            }
        Test.stopTest();
        mccSolucionUpdate = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccSolucionUpdate.Id];
        mccSolucionUpdate2 = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccSolucionUpdate2.Id];
        System.assertEquals((mccCausaUpdate.CC_Fecha_Vigencia_Fin__c == mccSolucionUpdate.CC_Fecha_Vigencia_Fin__c), true);
        
        System.assertEquals((mccCausaUpdate.CC_Fecha_Vigencia_Fin__c == mccSolucionUpdate2.CC_Fecha_Vigencia_Fin__c), true);

    }
    @isTest
    static void actualizarMotivo(){
        User usuario = [SELECT Id from User WHERE FirstName = 'Pruebafirst' LIMIT 1];
        CC_MCC__c mccMotivoUpdate = new CC_MCC__c();
        mccMotivoUpdate.Name = 'MCC Motivo';
        mccMotivoUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivoUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccMotivoUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccMotivoUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivoUpdate.CC_Producto_Servicio__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        mccMotivoUpdate.CC_Codigo_Externo__c = 'MO-000003';
        insert mccMotivoUpdate;

        CC_MCC__c mccCausaUpdate = new CC_MCC__c();
        mccCausaUpdate.Name = 'MCC Causa';
        mccCausaUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccCausaUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccCausaUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccCausaUpdate.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        mccCausaUpdate.CC_Motivo__c = mccMotivoUpdate.Id;
        mccCausaUpdate.CC_Codigo_Externo__c = 'CA-000003';
        insert mccCausaUpdate;

        CC_MCC__c mccSolucionUpdate = new CC_MCC__c();
        mccSolucionUpdate.Name = 'Solucion1';
        mccSolucionUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucionUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccSolucionUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccSolucionUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucionUpdate.CC_Causa__c = mccCausaUpdate.Id;
        mccSolucionUpdate.CC_Codigo_Externo__c = 'SO-000003';
        insert mccSolucionUpdate;
        
        CC_MCC__c mccSolucionUpdate2 = new CC_MCC__c();
        mccSolucionUpdate2.Name = 'Solucion2';
        mccSolucionUpdate2.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucionUpdate2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccSolucionUpdate2.CC_Fecha_Vigencia_Fin__c = null;
        mccSolucionUpdate2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucionUpdate2.CC_Causa__c = mccCausaUpdate.Id;
        mccSolucionUpdate2.CC_Codigo_Externo__c = 'SO-000004';
        insert mccSolucionUpdate2;
        Test.startTest();
        System.runAs(usuario){
            mccMotivoUpdate.CC_Fecha_Vigencia_Fin__c =  Datetime.newInstance(2022, 05, 06);
             try {
                 Database.update(mccMotivoUpdate);
             } catch (Exception e) {
                CBK_Log.error('Error el actualizar mccMotivoUpdate' + e.getMessage());
             }
        }
        Test.stopTest();
        mccCausaUpdate = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccCausaUpdate.Id];
        mccSolucionUpdate = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccSolucionUpdate.Id];
        mccSolucionUpdate2 = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccSolucionUpdate2.Id];

        System.assertEquals((mccMotivoUpdate.CC_Fecha_Vigencia_Fin__c == mccCausaUpdate.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccMotivoUpdate.CC_Fecha_Vigencia_Fin__c == mccSolucionUpdate.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccMotivoUpdate.CC_Fecha_Vigencia_Fin__c == mccSolucionUpdate2.CC_Fecha_Vigencia_Fin__c), true);

    } 
    @isTest
    static void actualizarProducto(){
        User usuario = [SELECT Id from User WHERE FirstName = 'Pruebafirst' LIMIT 1];
        CC_MCC__c mccProductoUpdate = new CC_MCC__c();
        mccProductoUpdate.Name = 'MCC Producto';
        mccProductoUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccProductoUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccProductoUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccProductoUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProductoUpdate.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        mccProductoUpdate.CC_Codigo_Externo__c = 'PR-000003';
        insert mccProductoUpdate;

        CC_MCC__c mccMotivoUpdate = new CC_MCC__c();
        mccMotivoUpdate.Name = 'MCC Motivo';
        mccMotivoUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivoUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccMotivoUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccMotivoUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivoUpdate.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        mccMotivoUpdate.CC_Producto_Servicio__c = mccProductoUpdate.Id;
        mccMotivoUpdate.CC_Codigo_Externo__c = 'MO-000003';
        insert mccMotivoUpdate;

        CC_MCC__c mccCausaUpdate = new CC_MCC__c();
        mccCausaUpdate.Name = 'MCC Causa';
        mccCausaUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccCausaUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccCausaUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccCausaUpdate.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        mccCausaUpdate.CC_Motivo__c = mccMotivoUpdate.Id;
        mccCausaUpdate.CC_Codigo_Externo__c = 'CA-000003';
        insert mccCausaUpdate;

        CC_MCC__c mccSolucionUpdate = new CC_MCC__c();
        mccSolucionUpdate.Name = 'Solucion1';
        mccSolucionUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucionUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccSolucionUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccSolucionUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucionUpdate.CC_Causa__c = mccCausaUpdate.Id;
        mccSolucionUpdate.CC_Codigo_Externo__c = 'SO-000003';
        insert mccSolucionUpdate;
        
        CC_MCC__c mccSolucionUpdate2 = new CC_MCC__c();
        mccSolucionUpdate2.Name = 'Solucion2';
        mccSolucionUpdate2.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucionUpdate2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccSolucionUpdate2.CC_Fecha_Vigencia_Fin__c = null;
        mccSolucionUpdate2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucionUpdate2.CC_Causa__c = mccCausaUpdate.Id;
        mccSolucionUpdate2.CC_Codigo_Externo__c = 'SO-000004';
        insert mccSolucionUpdate2;
        Test.startTest();
        System.runAs(usuario){
            mccProductoUpdate.CC_Fecha_Vigencia_Fin__c =  Datetime.newInstance(2022, 05, 06);
             try {
                 Database.update(mccProductoUpdate);
             } catch (Exception e) {
                CBK_Log.error('Error el actualizar mccProductoUpdate' + e.getMessage());
             }
        }
        Test.stopTest();
        
        mccMotivoUpdate = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccMotivoUpdate.Id];
        mccCausaUpdate = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccCausaUpdate.Id];
        mccSolucionUpdate = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccSolucionUpdate.Id];
        mccSolucionUpdate2 = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccSolucionUpdate2.Id];

        System.assertEquals((mccProductoUpdate.CC_Fecha_Vigencia_Fin__c == mccMotivoUpdate.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccProductoUpdate.CC_Fecha_Vigencia_Fin__c == mccCausaUpdate.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccProductoUpdate.CC_Fecha_Vigencia_Fin__c == mccSolucionUpdate.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccProductoUpdate.CC_Fecha_Vigencia_Fin__c == mccSolucionUpdate2.CC_Fecha_Vigencia_Fin__c), true);

    }
    @isTest
    static void actualizarTematica(){
        User usuario = [SELECT Id from User WHERE FirstName = 'Pruebafirst' LIMIT 1];
        CC_MCC__c mccTematicaUpdate = new CC_MCC__c();
        mccTematicaUpdate.Name = 'MCC Tematica';
        mccTematicaUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccTematicaUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccTematicaUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematicaUpdate.CC_Codigo_Externo__c = 'TE-000003';
        insert mccTematicaUpdate;

        CC_MCC__c mccProductoUpdate = new CC_MCC__c();
        mccProductoUpdate.Name = 'MCC Producto';
        mccProductoUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccProductoUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccProductoUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccProductoUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProductoUpdate.CC_Tematica__c = mccTematicaUpdate.Id;
        mccProductoUpdate.CC_Codigo_Externo__c = 'PR-000003';
        insert mccProductoUpdate;

        CC_MCC__c mccProductoUpdate2 = new CC_MCC__c();
        mccProductoUpdate2.Name = 'MCC Producto';
        mccProductoUpdate2.CC_Tipo_Cliente__c = 'Empleado';
        mccProductoUpdate2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccProductoUpdate2.CC_Fecha_Vigencia_Fin__c = null;
        mccProductoUpdate2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProductoUpdate2.CC_Tematica__c = mccTematicaUpdate.Id;
        mccProductoUpdate2.CC_Codigo_Externo__c = 'PR-000004';
        insert mccProductoUpdate2;

        CC_MCC__c mccMotivoUpdate = new CC_MCC__c();
        mccMotivoUpdate.Name = 'MCC Motivo';
        mccMotivoUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivoUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccMotivoUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccMotivoUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivoUpdate.CC_Producto_Servicio__c = mccProductoUpdate.Id;
        mccMotivoUpdate.CC_Codigo_Externo__c = 'MO-000003';
        insert mccMotivoUpdate;

        CC_MCC__c mccMotivoUpdate2 = new CC_MCC__c();
        mccMotivoUpdate2.Name = 'MCC Motivo';
        mccMotivoUpdate2.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivoUpdate2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccMotivoUpdate2.CC_Fecha_Vigencia_Fin__c = null;
        mccMotivoUpdate2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivoUpdate2.CC_Producto_Servicio__c = mccProductoUpdate2.Id;
        mccMotivoUpdate2.CC_Codigo_Externo__c = 'MO-000004';
        insert mccMotivoUpdate2;
        
        CC_MCC__c mccCausaUpdate = new CC_MCC__c();
        mccCausaUpdate.Name = 'MCC Causa';
        mccCausaUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccCausaUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccCausaUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccCausaUpdate.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        mccCausaUpdate.CC_Motivo__c = mccMotivoUpdate.Id;
        mccCausaUpdate.CC_Codigo_Externo__c = 'CA-000003';
        insert mccCausaUpdate;

        CC_MCC__c mccSolucionUpdate = new CC_MCC__c();
        mccSolucionUpdate.Name = 'Solucion1';
        mccSolucionUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucionUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccSolucionUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccSolucionUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucionUpdate.CC_Causa__c = mccCausaUpdate.Id;
        mccSolucionUpdate.CC_Codigo_Externo__c = 'SO-000003';
        insert mccSolucionUpdate;
        
        CC_MCC__c mccSolucionUpdate2 = new CC_MCC__c();
        mccSolucionUpdate2.Name = 'Solucion2';
        mccSolucionUpdate2.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucionUpdate2.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccSolucionUpdate2.CC_Fecha_Vigencia_Fin__c = null;
        mccSolucionUpdate2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucionUpdate2.CC_Causa__c = mccCausaUpdate.Id;
        mccSolucionUpdate2.CC_Codigo_Externo__c = 'SO-000004';
        insert mccSolucionUpdate2;
        Test.startTest();
        System.runAs(usuario){
            mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c =  Datetime.newInstance(2022, 05, 06);
             try {
                 Database.update(mccTematicaUpdate);
             } catch (Exception e) {
                CBK_Log.error('Error el actualizar mccTematicaUpdate' + e.getMessage());

             }
        }
        Test.stopTest();
        
        mccProductoUpdate = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccProductoUpdate.Id];
        mccProductoUpdate2 = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccProductoUpdate2.Id];
        mccMotivoUpdate = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccMotivoUpdate.Id];
        mccMotivoUpdate2 = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccMotivoUpdate2.Id];
        mccCausaUpdate = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccCausaUpdate.Id];
        mccSolucionUpdate = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccSolucionUpdate.Id];
        mccSolucionUpdate2 = [SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccSolucionUpdate2.Id];

        System.assertEquals((mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c == mccProductoUpdate.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c == mccProductoUpdate2.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c == mccMotivoUpdate.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c == mccMotivoUpdate2.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c == mccCausaUpdate.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c == mccSolucionUpdate.CC_Fecha_Vigencia_Fin__c), true);
        System.assertEquals((mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c == mccSolucionUpdate2.CC_Fecha_Vigencia_Fin__c), true);

    }
    @isTest
    static void updateCatalogoProd(){
        User usuario = [SELECT Id from User WHERE FirstName = 'Pruebafirst' LIMIT 1];
        CC_MCC__c mccTematicaUpdate = new CC_MCC__c();
        mccTematicaUpdate.Name = 'MCC Tematica';
        mccTematicaUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccTematicaUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccTematicaUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematicaUpdate.CC_Codigo_Externo__c = 'TE-000003';
        insert mccTematicaUpdate;

        CC_MCC__c mccProductoUpdate = new CC_MCC__c();
        mccProductoUpdate.Name = 'MCC Producto';
        mccProductoUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccProductoUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccProductoUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccProductoUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProductoUpdate.CC_Tematica__c = mccTematicaUpdate.Id;
        mccProductoUpdate.CC_Codigo_Externo__c = 'PR-000003';
        insert mccProductoUpdate;

        CBK_CatalogoFacturacion__c catalogo= new CBK_CatalogoFacturacion__c();
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Tipo_Cliente__c='Empleado';
        catalogo.CC_Tematica__c=mccTematicaUpdate.Id;
        catalogo.CC_Producto__c=mccProductoUpdate.Id;
        catalogo.CC_Area_Negocio__c='ACCIONISTAS';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2022, 05, 05);

        insert catalogo;

        Test.startTest();
        System.runAs(usuario){
            mccProductoUpdate.CC_Fecha_Vigencia_Fin__c=Datetime.newInstance(2022, 05, 06);
            try {
                Database.update(mccProductoUpdate);
            } catch (Exception e) {
                CBK_Log.error('Error el actualizar mccProductoUpdate' + e.getMessage());
            }
        }
        Test.stopTest();

        mccProductoUpdate=[SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccProductoUpdate.Id];
        catalogo=[SELECT Id, CC_Fecha_Fin_Vigencia__c FROM CBK_CatalogoFacturacion__c WHERE Id = :catalogo.Id];

        System.assertEquals(catalogo.CC_Fecha_Fin_Vigencia__c == mccProductoUpdate.CC_Fecha_Vigencia_Fin__c, true);
    }
    @isTest
    static void updateCatalogoTem(){
        User usuario = [SELECT Id from User WHERE FirstName = 'Pruebafirst' LIMIT 1];
        CC_MCC__c mccTematicaUpdate = new CC_MCC__c();
        mccTematicaUpdate.Name = 'MCC Tematica';
        mccTematicaUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccTematicaUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccTematicaUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematicaUpdate.CC_Codigo_Externo__c = 'TE-000003';
        insert mccTematicaUpdate;

        CC_MCC__c mccProductoUpdate = new CC_MCC__c();
        mccProductoUpdate.Name = 'MCC Producto';
        mccProductoUpdate.CC_Tipo_Cliente__c = 'Empleado';
        mccProductoUpdate.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        mccProductoUpdate.CC_Fecha_Vigencia_Fin__c = null;
        mccProductoUpdate.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProductoUpdate.CC_Tematica__c = mccTematicaUpdate.Id;
        mccProductoUpdate.CC_Codigo_Externo__c = 'PR-000003';
        insert mccProductoUpdate;

        CBK_CatalogoFacturacion__c catalogo= new CBK_CatalogoFacturacion__c();
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Tipo_Cliente__c='Empleado';
        catalogo.CC_Tematica__c=mccTematicaUpdate.Id;
        catalogo.CC_Producto__c=mccProductoUpdate.Id;
        catalogo.CC_Area_Negocio__c='ACCIONISTAS';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2022, 05, 05);

        insert catalogo;

        Test.startTest();
        System.runAs(usuario){
            mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c=Datetime.newInstance(2022, 05, 06);
            try {
                Database.update(mccTematicaUpdate);
            } catch (Exception e) {
                CBK_Log.error('Error el actualizar mccTematicaUpdate' + e.getMessage());
            }
        }
        Test.stopTest();

        mccTematicaUpdate=[SELECT Id, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id = :mccTematicaUpdate.Id];
        catalogo=[SELECT Id, CC_Fecha_Fin_Vigencia__c FROM CBK_CatalogoFacturacion__c WHERE Id = :catalogo.Id];

        System.assertEquals(catalogo.CC_Fecha_Fin_Vigencia__c == mccTematicaUpdate.CC_Fecha_Vigencia_Fin__c, true);
    }
    /*
    @isTest
    static void programarDesactivacionMCC(){
        List<CC_MCC__c> mccInsert = new List<CC_MCC__c>();

        CC_MCC__c tematicaMcc = new CC_MCC__c();
        tematicaMcc.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematicaMcc.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        tematicaMcc.Name = 'Tematica Batch Test';
        tematicaMcc.CC_Tipo_Cliente__c = 'Cliente';
        tematicaMcc.CC_Canal_Operativo__c = 'Sin canal';
        tematicaMcc.CC_Codigo_Externo__c = 'TE-000003';
        Insert tematicaMcc;
        
        
        CC_MCC__c producto = new CC_MCC__c();        
        producto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        producto.Name = 'Producto Batch Test';
        producto.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        producto.CC_Tipo_Cliente__c = 'Cliente';
        producto.CC_Tematica__c = tematicaMcc.Id;
        producto.CC_Codigo_Externo__c = 'PR-000003';
        Insert producto;
        
        Test.startTest();

        tematicaMcc.CC_Fecha_Vigencia_Fin__c = System.now()+100;
        update tematicaMcc;

        List<CBK_Framework_Batch__c> listNewBatchtMcc = [SELECT Activo__c, params__c FROM CBK_Framework_Batch__c WHERE Class_Name__c = 'CC_MCC_Batch' AND Activo__c = true 
        AND Status__c != 'Completed' AND Status__c != 'Error'];

        List<CBK_Framework_Batch__c> listCbk = new List<CBK_Framework_Batch__c>();
        if (!listNewBatchtMcc.isEmpty()){
            for (CBK_Framework_Batch__c cbk : listNewBatchtMcc){
                if(cbk.params__C.contains(tematicaMcc.id)){
                    cbk.Activo__c = false;
                    listCbk.add(cbk);                
                        }
                    }
                }
        System.assertEquals(!listCbk.isEmpty(), true);

        tematicaMcc.CC_Fecha_Vigencia_Fin__c = System.now();

        update tematicaMcc;

        List<CBK_Framework_Batch__c> listUpdateBatchtMcc = [SELECT Activo__c, params__c FROM CBK_Framework_Batch__c WHERE Class_Name__c = 'CC_MCC_Batch' AND Activo__c = true 
        AND Status__c != 'Completed' AND Status__c != 'Error'];

        List<CBK_Framework_Batch__c> listCbk2 = new List<CBK_Framework_Batch__c>();
        if (!listUpdateBatchtMcc.isEmpty()){
            for (CBK_Framework_Batch__c cbk : listUpdateBatchtMcc){
                if(cbk.params__C.contains(tematicaMcc.id)){
                    cbk.Activo__c = false;
                    listCbk2.add(cbk);                
                        }
                    }
                }

        System.assertEquals(!listCbk2.isEmpty(), false);
        Test.stopTest();

    }
*/
    
    @isTest  
    static void lanzarBatchMcc(){
        
        List<Id> mcclist = new List<Id>();
        
        CC_MCC__c tematicaMcc = new CC_MCC__c();
        tematicaMcc.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        tematicaMcc.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        tematicaMcc.Name = 'Tematica Batch Test';
        tematicaMcc.CC_Tipo_Cliente__c = 'Cliente';
        tematicaMcc.CC_Canal_Operativo__c = 'Sin canal';
        tematicaMcc.CC_Codigo_Externo__c = 'TE-000003';
         tematicaMcc.CC_Fecha_Vigencia_Fin__c = system.now();
        Insert tematicaMcc;
        
        CC_MCC__c producto = new CC_MCC__c();        
        producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        producto.Name = 'Producto Batch Test';
        producto.CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05);
        producto.CC_Tipo_Cliente__c = 'Cliente';
        producto.CC_Tematica__c = tematicaMcc.Id;
        producto.CC_Codigo_Externo__c = 'PR-000003';
        Insert producto;
        
        mcclist.add(tematicaMcc.id);
        
        Test.startTest();
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        Database.executeBatch(new CC_MCC_Batch());
        System.assertEquals(producto.CC_Activo__c, false);
        }
        
        Test.stopTest();
    }
  }