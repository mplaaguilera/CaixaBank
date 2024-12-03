public without sharing class SAC_MCC_AI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_MCC__c>)tp.newList, (Map<Id, CC_MCC__c>)tp.newMap);
    }

    private void process(List<CC_MCC__c> listNewObj, Map<Id, CC_MCC__c> mapNewObj) { 
		Id rtDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

        List<CC_MCC__c> lstMCC = new List<CC_MCC__c>(); 

        for (CC_MCC__c mcc : listNewObj){             
            if(mcc.RecordTypeId == rtDetalle){
                lstMCC.add(mcc);
            }
        }

        if(!lstMCC.isEmpty()){
            asignacionParametrizacionSLATME(lstMCC, mapNewObj);
        }        
    }


    /**************************************************************************
     * Proposito: Crear las parametrizaciones SLA/TMO automáticamente cuando se crea un registro 
     *  del objeto MCC del tipo Detalle
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE        Description
     * 1.0             US515086     Sergio Martín   06/02/2023      Creación
    **************************************************************************/ 
    private void asignacionParametrizacionSLATME(List<CC_MCC__c> lstMCC, Map<Id, CC_MCC__c> mapNewObj){
        Id rtMaestro = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_Maestro').getRecordTypeId();

        Id rtAlta = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLAAlta').getRecordTypeId();
        Id rtLetrado = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLALetrado').getRecordTypeId();
        Id rtRegulatorio = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLARegulatorio').getRecordTypeId();

        // Se recuperan las parametrizaciones creadas manualmente con el record type SAC_Maestro
        List<SAC_ParametrizacionSLATME__c> lstParametrizaciones = [SELECT Id, name, SAC_Duracion__c, SAC_CanalProcedencia__c FROM SAC_ParametrizacionSLATME__c WHERE RecordType.id =: rtMaestro];
        List<SAC_ParametrizacionSLATME__c> lstParametrizacionesInsertar = new List <SAC_ParametrizacionSLATME__c>();
        
        try { 
            for(CC_MCC__c mcc :lstMcc) {
                // Se recorren las Parametrizaciones recuperadas en la lista y según su nombre se crea un nuevo registro SAC_ParametrizacionSLATME__c con record type diferente
                for (SAC_ParametrizacionSLATME__c parametrizacion : lstParametrizaciones) { 
                    if(parametrizacion.Name.toUppercase().Contains('ALTA')) {
                        lstParametrizacionesInsertar.add(new SAC_ParametrizacionSLATME__c (Name = mcc.Name + ' ' + parametrizacion.Name, SAC_Duracion__c = parametrizacion.SAC_Duracion__c ,
                                                            SAC_MCC__c = mcc.id, SAC_CanalProcedencia__c = parametrizacion.SAC_CanalProcedencia__c, RecordTypeId = rtAlta));
                    } else if (parametrizacion.Name.toUppercase().Contains('REGULATORIO')) {
                        lstParametrizacionesInsertar.add(new SAC_ParametrizacionSLATME__c (Name = mcc.Name + ' ' + parametrizacion.Name, SAC_Duracion__c = parametrizacion.SAC_Duracion__c ,
                                                            SAC_MCC__c = mcc.id, SAC_CanalProcedencia__c = parametrizacion.SAC_CanalProcedencia__c, RecordTypeId = rtRegulatorio));
                    } else if (parametrizacion.Name.toUppercase().Contains('LETRADO')) {
                        lstParametrizacionesInsertar.add(new SAC_ParametrizacionSLATME__c (Name = mcc.Name + ' ' + parametrizacion.Name, SAC_Duracion__c = parametrizacion.SAC_Duracion__c ,
                                                            SAC_MCC__c = mcc.id, SAC_CanalProcedencia__c = parametrizacion.SAC_CanalProcedencia__c, RecordTypeId = rtLetrado));
                    }     
                }
            }
            
            insert lstParametrizacionesInsertar;
        } catch (Exception e) {
            CBK_Log.error(e);
        } 
          
    }
}