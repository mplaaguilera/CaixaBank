@isTest
public with sharing class SEG_ClasRapida_TRHan_Test {
    @testSetup
    static void testSetup() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('CBK_Framework_Login','CBK_Framework_Admin')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId(); 
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;

        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId(); 
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId(); 
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

       	CC_MCC__c mccDetalle = new CC_MCC__c();
        mccDetalle.Name = 'Detalle1';
        mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalle.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        mccDetalle.CC_Tematica__c = mccTematica.Id;
        mccDetalle.CC_Producto_Servicio__c = mccProducto.Id;
        mccDetalle.CC_Motivo__c = mccMotivo.Id;
        mccDetalle.CC_Codigo_Externo__c = 'DE-000001';
        insert mccDetalle;

        SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
        regla1.Name = 'CR1';
        regla1.SEG_Tematica__c = mccTematica.Id;
        regla1.SEG_Producto__c = mccProducto.Id;
        regla1.SEG_Motivo__c = mccMotivo.Id;
        regla1.SEG_Detalle__c = mccDetalle.Id;
        regla1.CBK_Negocio__c = 'Segmentos';
        regla1.SEG_Organizacion__c= 'Banca Corporativa';
        insert regla1;
    }

//Se comprueban el traspaso de Workflow tpmv a trigger de BI y BU
    @isTest
    public static void concatFechaNifTest(){
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        Test.startTest();
        System.runAs(usuarioTest) { 

        List<SEG_ClasificacionRapida__c> listClasificacionesInsert = [SELECT Id, SEG_TPMV__c, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c, CBK_Negocio__c, SEG_Organizacion__c FROM SEG_ClasificacionRapida__c LIMIT 1];
        for (SEG_ClasificacionRapida__c clasificacionInsertada : listClasificacionesInsert) {
            System.assertEquals(clasificacionInsertada.SEG_TPMV__c, String.valueOf(clasificacionInsertada.SEG_Tematica__c)+ String.valueOf(clasificacionInsertada.SEG_Producto__c) + String.valueOf(clasificacionInsertada.SEG_Motivo__c) + String.valueOf(clasificacionInsertada.SEG_Detalle__c), 'No se ha concatenado correctamente.');
            clasificacionInsertada.SEG_Detalle__c = null;
        }
        update(listClasificacionesInsert);

        List<SEG_ClasificacionRapida__c> listClasificacionesPostUpdates = [SELECT Id, SEG_TPMV__c, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c, CBK_Negocio__c, SEG_Organizacion__c FROM SEG_ClasificacionRapida__c  LIMIT 1];

        for (SEG_ClasificacionRapida__c clasificacionInsertada : listClasificacionesPostUpdates) {
            System.assertEquals(clasificacionInsertada.SEG_TPMV__c, String.valueOf(clasificacionInsertada.SEG_Tematica__c)+ String.valueOf(clasificacionInsertada.SEG_Producto__c) + String.valueOf(clasificacionInsertada.SEG_Motivo__c) , 'No se ha concatenado correctamente.');

        }
    }
    } 
}