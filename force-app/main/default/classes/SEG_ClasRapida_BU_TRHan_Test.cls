@isTest
private class SEG_ClasRapida_BU_TRHan_Test {
    
    @testSetup
    static void setupTestData() {
        List<SEG_ClasificacionRapida__c> records = new List<SEG_ClasificacionRapida__c>();
        for (Integer i = 0; i < 5; i++) {
            SEG_ClasificacionRapida__c record = new SEG_ClasificacionRapida__c(
                Name = 'Test Record ' + i,
                SEG_Tematica__c = 'Tematica ' + i,
                SEG_Producto__c = 'Producto ' + i,
                SEG_Motivo__c = 'Motivo ' + i,
                SEG_Detalle__c = 'Detalle ' + i,
                OS_Causa__c = 'Causa ' + i,
                OS_Solucion__c = 'Solucion ' + i,
                OS_GrupoTrabajo__c = 'Grupo ' + i
            );
            records.add(record);
        }
        insert records;
    }
    
    @isTest
    static void testConcatenaCR() {
        List<SEG_ClasificacionRapida__c> records = [SELECT Id, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c, OS_Causa__c, OS_Solucion__c, OS_GrupoTrabajo__c FROM SEG_ClasificacionRapida__c];
        
        Map<Id, SEG_ClasificacionRapida__c> oldMap = new Map<Id, SEG_ClasificacionRapida__c>();
        Map<Id, SEG_ClasificacionRapida__c> newMap = new Map<Id, SEG_ClasificacionRapida__c>();
        
        for (SEG_ClasificacionRapida__c record : records) {
            SEG_ClasificacionRapida__c modifiedRecord = record.clone(false);
            modifiedRecord.SEG_Tematica__c = 'Updated Tematica';
            newMap.put(record.Id, modifiedRecord);
            oldMap.put(record.Id, record);
        }
        
        Test.startTest();
        SEG_ClasRapida_BU_TRHan.concatenaCR(newMap, oldMap);
        Test.stopTest();
        
        for (Id recordId : newMap.keySet()) {
            System.assertNotEquals(newMap.get(recordId).SEG_TPMV__c, null, 'SEG_TPMV__c se debería hacer un update');
        }
    }
}