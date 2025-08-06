@isTest
public with sharing class HDT_MCC_Notificar_Vigentes_Test {
    @isTest
    public static void test() {
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id tematicaRecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            Id productoRecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            Id motivoRecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
    
            // Tematicas
            List<CC_MCC__c> listTematicas = new List<CC_MCC__c>();
            CC_MCC__c tematica1 = new CC_MCC__c(
                Name = 'Temática Test 1',
                CC_Tipo_Cliente__c = 'HDT Empleado',
                CC_Fecha_Vigencia_Inicio__c = System.now(),
                RecordTypeId = tematicaRecordTypeId,
                CC_Codigo_Externo__c = 'TE-0000010',
                CC_Canal_Operativo__c = 'Oficina',
                CC_Notificar__c = true
            );
            listTematicas.add(tematica1);
    
            CC_MCC__c tematica2 = new CC_MCC__c(
                Name = 'Temática Test 2',
                CC_Tipo_Cliente__c = 'HDT Empleado',
                CC_Fecha_Vigencia_Inicio__c = System.now().addDays(4),
                RecordTypeId = tematicaRecordTypeId,
                CC_Codigo_Externo__c = 'TE-0000011',
                CC_Canal_Operativo__c = 'Oficina',
                CC_Notificar__c = false
                );        
            listTematicas.add(tematica2);
                
            CC_MCC__c tematica3 = new CC_MCC__c(
                Name = 'Temática Test 3',
                CC_Tipo_Cliente__c = 'HDT Empleado',
                CC_Fecha_Vigencia_Inicio__c = System.now().addDays(10),
                RecordTypeId = tematicaRecordTypeId,
                CC_Codigo_Externo__c = 'TE-0000012',
                CC_Canal_Operativo__c = 'Oficina',
                CC_Notificar__c = true
            );
            listTematicas.add(tematica3);
            insert listTematicas;
            
            // Productos
            List<CC_MCC__c> listProductos = new List<CC_MCC__c>();
            CC_MCC__c producto1 = new CC_MCC__c(
                Name = 'Producto Test 1',
                CC_Fecha_Vigencia_Inicio__c = System.now().addDays(1),
                CC_Tematica__c = tematica1.Id,
                RecordTypeId = productoRecordTypeId,
                CC_Tipo_Cliente__c = 'HDT Empleado',
                CC_Codigo_Externo__c = 'PR-0000010',
                CC_Notificar__c = true
            );
            listProductos.add(producto1);
            
            CC_MCC__c producto2 = new CC_MCC__c(
                Name = 'Producto Test 2',
                CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-2),
                CC_Tematica__c = tematica2.Id,
                RecordTypeId = productoRecordTypeId,
                CC_Codigo_Externo__c = 'PR-0000011',
                CC_Tipo_Cliente__c = 'HDT Empleado',
                CC_Notificar__c = false
            );
            listProductos.add(producto2);
            
            CC_MCC__c producto3 = new CC_MCC__c(
                Name = 'Producto Test 3',
                CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-5),
                CC_Tematica__c = tematica3.Id,
                RecordTypeId = productoRecordTypeId,
                CC_Tipo_Cliente__c = 'HDT Empleado',
                CC_Codigo_Externo__c = 'PR-0000012',
                CC_Notificar__c = true
            );
            listProductos.add(producto3);
            insert listProductos;
    
            // Motivos
            List<CC_MCC__c> listMotivos = new List<CC_MCC__c>();
            CC_MCC__c motivo1 = new CC_MCC__c(
                Name = 'Motivo Test 1',
                CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-1),
                CC_Producto_Servicio__c = producto1.Id,
                RecordTypeId = motivoRecordTypeId,
                CC_Tipo_Cliente__c = 'HDT Empleado',
                CC_Codigo_Externo__c = 'MO-0000010',
                CC_Notificar__c = true
            );        
            listMotivos.add(motivo1);
            
            CC_MCC__c motivo2 = new CC_MCC__c(
                Name = 'Motivo Test 2',
                CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-3),
                CC_Producto_Servicio__c = producto2.Id,
                RecordTypeId = motivoRecordTypeId,
                CC_Tipo_Cliente__c = 'HDT Empleado',
                CC_Codigo_Externo__c = 'MO-0000011',
                CC_Notificar__c = false
            );
            listMotivos.add(motivo2);
            
            CC_MCC__c motivo3 = new CC_MCC__c(
                Name = 'Motivo Test 3',
                CC_Fecha_Vigencia_Inicio__c = System.now().addDays(1),
                CC_Producto_Servicio__c = producto3.Id,
                RecordTypeId = motivoRecordTypeId,
                CC_Tipo_Cliente__c = 'HDT Empleado',
                CC_Codigo_Externo__c = 'MO-0000012',
                CC_Notificar__c = false
            );
            listMotivos.add(motivo3);
            insert listMotivos;
    
    
            List<CC_MCC__c> listMCCVigentes = HDT_MCC_Notificar_Vigentes.obtenerMotivos();
            System.assertEquals(1, listMCCVigentes.size());
            System.assertEquals(motivo1.Id, listMCCVigentes[0].Id); 
        }
        
    }
}