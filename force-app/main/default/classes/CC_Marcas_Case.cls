public with sharing class CC_Marcas_Case {

    @AuraEnabled(cacheable=true)
    public static List<CC_Caracteristica__c> caracteristicas(Id recordId) {
        String negocio = getNegocio(recordId);
        return [SELECT Name FROM CC_Caracteristica__c
                WHERE RecordType.DeveloperName = 'Marca' AND OS_Negocio__c = :negocio AND CC_Activo__c = True ORDER BY Name ASC];
    } 

    public static String getNegocio(Id recordId) {

        String prefijo = OT_Proyectos.registroProyecto(recordId);
        String negocio;
        if (prefijo == 'CC') {
            negocio = 'CC';

            Case recordTypeName = [SELECT RecordType.DeveloperName FROM Case WHERE Id = :recordId];
            if (recordTypeName != null && recordTypeName.RecordType.DeveloperName == 'CC_CSI_Bankia') {
                negocio = 'CSI_Bankia'; 
            }

        } else if (prefijo == 'OS') {
            negocio = 'COPS';
        } else if (prefijo == 'AM') {
            negocio = 'CAM';
        } else if (prefijo == 'SACH') {
            negocio = 'SACH';
        } else if (prefijo == 'HDT'){
            negocio = 'HDT';
        }
        return negocio;
    }
}