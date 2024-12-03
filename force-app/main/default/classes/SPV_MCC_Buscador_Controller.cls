public with sharing class SPV_MCC_Buscador_Controller {

    @AuraEnabled
    public static Boolean compruebaPermisoSPV(Id caseId, Id idUsuario) {
        // Funcionalidad de otorgar permiso a usuarios que sean propietarios de algún registro de la familia de la reclamación a la que pertenece las pretensiones
        Boolean tienePermiso = false;

        Case casoActual = [SELECT SAC_Reclamacion__c, RecordTypeId FROM Case WHERE Id = :caseId];

         
        List<Case> listaFamilia = new List<Case>();

        Id recRec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
        Id recPret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Pretension').getRecordTypeId();

        if(casoActual.RecordTypeId == recRec){
            listaFamilia = [SELECT id, OwnerId, Subject FROM Case WHERE SAC_Reclamacion__c =: casoActual.Id OR id = :casoActual.Id];
        } else if(casoActual.RecordTypeId == recPret){
            listaFamilia = [SELECT id, OwnerId FROM Case
                            WHERE SAC_Reclamacion__c =: casoActual.SAC_Reclamacion__c OR id = :casoActual.SAC_Reclamacion__c];
        }
        // Comparamos el propietario de los registros de la familia con el usuario actual
        if(!listaFamilia.isEmpty()){
            for (Case caso : listaFamilia) {
                if(caso.OwnerId == idUsuario){
                    tienePermiso=true;
                    break;
                }
            }
        }
        return tienePermiso;
}
}