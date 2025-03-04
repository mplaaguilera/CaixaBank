public with sharing class SAC_ReasignacionInteraccionMasiva_LWC_VF {
    public List<SAC_Interaccion__c> listaInteracciones{get;private set;}
    public SAC_ReasignacionInteraccionMasiva_LWC_VF(ApexPages.StandardSetController stdSetController) {
        listaInteracciones = (List<SAC_Interaccion__c>) stdSetController.getSelected();
    }

    private static List<SAC_Interaccion__c> getListaInteraccionesSelected(List<String> lstInteraccionesSelected){
        return [SELECT Id, SAC_CasoEscalado__c, RecordTypeId, OwnerId, SAC_GrupoColaborador__c, SAC_GrupoColaborador__r.SAC_Externo__c, SAC_GrupoColaborador__r.SAC_TienePropietario__c
                FROM SAC_Interaccion__c
                WHERE Id IN: lstInteraccionesSelected];
    }

    @AuraEnabled (cacheable = true)
    public static List<CC_Grupo_Colaborador_Contact__c> getUsuarios(List<String> lstIdInteraccionSelected){
        try{
            List<SAC_Interaccion__c> lstInteraccionesSelected = getListaInteraccionesSelected(lstIdInteraccionSelected);
            List<CC_Grupo_Colaborador_Contact__c> lstColaboradoresGrupo = new List<CC_Grupo_Colaborador_Contact__c>();
            if(!lstInteraccionesSelected.isEmpty()){
                String grupoId = lstInteraccionesSelected[0].SAC_GrupoColaborador__c;
                lstColaboradoresGrupo= [SELECT CC_Nombre__c, CC_Apellidos__c, CC_Usuario__c
                                        FROM CC_Grupo_Colaborador_Contact__c
                                        WHERE CC_Grupo_Colaborador__c =: grupoId AND CC_Usuario__r.IsActive =: true];
            }
            return lstColaboradoresGrupo;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String setNewOwnerToEscalate(List<String> lstIdInteraccionSelected, String userId){
    
        try {
            List<SAC_Interaccion__c> lstInteraccionToUpdate = new List<SAC_Interaccion__c>();
            List<SAC_Interaccion__c> lstInteraccionesSelected = getListaInteraccionesSelected(lstIdInteraccionSelected);
            if(!lstInteraccionesSelected.isEmpty()){
                for(SAC_Interaccion__c interaccion : lstInteraccionesSelected){
                    SAC_Interaccion__c i = new SAC_Interaccion__c();
                    i.Id = interaccion.Id;
                    i.OwnerId = userId;
                    lstInteraccionToUpdate.add(i);    
                }

                SAC_DatabaseDML.updateListDML(lstInteraccionToUpdate, true);
                //Database.update(lstInteraccionToUpdate);
                return 'SUCCCES';
            }

            return 'EMPTY';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string validationComponente(List<String> lstIdInteraccionSelected){
        try {
            Id recTypeEscalado = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
            Id recTypeEscaladoNV3 = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_EscaladoNV3').getRecordTypeId();
            Id recTypeConsulta = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();

            Boolean consulta = false;
            Boolean escalado = false;
                
            List<SAC_Interaccion__c> lstInteraccionesSelected = getListaInteraccionesSelected(lstIdInteraccionSelected);
            String error = 'No';
            if(!lstInteraccionesSelected.isEmpty()){
                String passGroup = '';
                for(SAC_Interaccion__c interaccion : lstInteraccionesSelected){
                    if(interaccion.RecordTypeId == recTypeConsulta){
                        if(escalado == true) {
                            error = 'RecordType';
                            return error;
                        }
                        if(interaccion.SAC_GrupoColaborador__r.SAC_TienePropietario__c == false){
                            error = 'NoPropietario';
                            return error;
                        }
                        consulta = true;
                    }else if(interaccion.RecordTypeId == recTypeEscalado || interaccion.RecordTypeId == recTypeEscaladoNV3){
                        if(consulta == true) {
                            error = 'RecordType';
                            return error;
                        }
                        escalado = true;
                    }
                    if(String.valueOf(interaccion.SAC_GrupoColaborador__c) != passGroup && passGroup != ''){
                        error = 'Grupo';
                        return error;
                    }
                    passGroup = interaccion.SAC_GrupoColaborador__c;
                }
            }else{
                error = 'Escalado';
            }

            Id userId = UserInfo.getUserId();
            List<CC_Grupo_Colaborador_Contact__c> lstGruposAdmin = [SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c
                WHERE (SAC_Administrador__c = true OR SAC_Supervisor__c =true) AND CC_Usuario__c =: userId AND CC_Usuario__r.IsActive = true];

            if(consulta == true) {
                for(CC_Grupo_Colaborador_Contact__c grupo : lstGruposAdmin) {
                    if(grupo.CC_Grupo_Colaborador__c == lstInteraccionesSelected[0].SAC_GrupoColaborador__c) {
                        return error;
                    }
                }
                error = 'NoAdminGrupo';
            }

            return error;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}