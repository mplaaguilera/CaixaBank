/*****************************************************************
 * Name: SAC_ParametrizacionSLATME_BI_TRHan
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el Before Insert del objeto SAC_ParametrizacionSLATME__c
 * Las clases test que ejecutan esta clase: SAC_ParametrizacionSLATME_BI_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US1045056      Álex Polo       07/11/2024   Creación 
*****************************************************************/
/**
*   @description SAC_ParametrizacionSLATME_BI_TRHan
*/
public with sharing class SAC_ParametrizacionSLATME_BI_TRHan extends CC_TriggerHandlerBase{


    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_ParametrizacionSLATME__c>)tp.newList, (Map<Id, SAC_ParametrizacionSLATME__c>)tp.newMap);
	}
 
    private void process(List<SAC_ParametrizacionSLATME__c> listNewObj, Map<Id, SAC_ParametrizacionSLATME__c> mapNewObj) {
        if(!listNewObj.isEmpty()){
            comprobarTMEDuplicado(listNewObj, mapNewObj);
        }
    }

    /**************************************************************************
     * Proposito: Asignarle el valor correspondiente al campo SAC_DuplicadoMCCProcedenciaEstado__c antes de
     * añadirlo
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE        Description
     * 1.0             US1045056      Álex Polo     07/11/2024      Creación
    **************************************************************************/ 
    /**
	 * @description     Asignarle el valor correspondiente al campo SAC_DuplicadoMCCProcedenciaEstado__c antes de
     *                  INSERTAR el registro
	 * @param listNewObj -> Registros que se van a añadir (Lista)
     * @param mapNewObj -> Registros que se van a añadir (Mapa)
	 */
    public static void comprobarTMEDuplicado(List<SAC_ParametrizacionSLATME__c> listNewObj, Map<Id, SAC_ParametrizacionSLATME__c> mapNewObj){

        Id recTypeSlaLetrado = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLALetrado').getRecordTypeId();
        Id recTypeSlaRegulatorio = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLARegulatorio').getRecordTypeId();
        Id recTypeSlaAlta = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLAAlta').getRecordTypeId();
        Id recTypeMaestro = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_Maestro').getRecordTypeId();


        for(SAC_ParametrizacionSLATME__c registroTME :  listNewObj){
            //Se asigna el valor al campo en función del record type
            if(registroTME.RecordTypeId == recTypeSlaLetrado){
                registroTME.SAC_DuplicadoMCCProcedenciaEstado__c = registroTME.SAC_MCC__c + registroTME.SAC_CanalProcedencia__c + 'Letrado';
            }else if(registroTME.RecordTypeId == recTypeSlaRegulatorio){
                registroTME.SAC_DuplicadoMCCProcedenciaEstado__c = registroTME.SAC_MCC__c + registroTME.SAC_CanalProcedencia__c + 'Regulatorio';

            }else if(registroTME.RecordTypeId == recTypeSlaAlta){
                registroTME.SAC_DuplicadoMCCProcedenciaEstado__c = registroTME.SAC_MCC__c + registroTME.SAC_CanalProcedencia__c + 'Alta';
  
            }else if(registroTME.RecordTypeId == recTypeMaestro){
                registroTME.SAC_DuplicadoMCCProcedenciaEstado__c = registroTME.Name + registroTME.SAC_CanalProcedencia__c + 'Maestro';
              
            }else{
                //Si no es de ninguno de los tipos anteriores:
                String cadenaFormar = '';
                cadenaFormar = '' + registroTME.SAC_MCC__c + registroTME.SAC_CanalProcedencia__c;

                if(registroTME.SAC_Estados__c != null && String.valueOf(registroTME.SAC_Estados__c).toUppercase().contains('SAC_001')){
                    cadenaFormar = cadenaFormar + 'SAC_001';
                }
                if(registroTME.SAC_Estados__c != null && String.valueOf(registroTME.SAC_Estados__c).toUppercase().contains('SAC_002')){
                    cadenaFormar = cadenaFormar + 'SAC_002';
                }
                if(registroTME.SAC_Estados__c != null && String.valueOf(registroTME.SAC_Estados__c).toUppercase().contains('SAC_003')){
                    cadenaFormar = cadenaFormar + 'SAC_003';
                }
                if(registroTME.SAC_Estados__c != null && String.valueOf(registroTME.SAC_Estados__c).toUppercase().contains('SAC_004')){
                    cadenaFormar = cadenaFormar + 'SAC_004';
                }
                if(registroTME.SAC_Estados__c != null && String.valueOf(registroTME.SAC_Estados__c).toUppercase().contains('SAC_005')){
                    cadenaFormar = cadenaFormar + 'SAC_005';
                }
                if(registroTME.SAC_Estados__c != null && String.valueOf(registroTME.SAC_Estados__c).toUppercase().contains('SAC_006')){
                    cadenaFormar = cadenaFormar + 'SAC_006';
                }
                if(registroTME.SAC_Estados__c != null && String.valueOf(registroTME.SAC_Estados__c).toUppercase().contains('SAC_007')){
                    cadenaFormar = cadenaFormar + 'SAC_007';
                }
                if(registroTME.SAC_Estados__c != null && String.valueOf(registroTME.SAC_Estados__c).toUppercase().contains('SAC_008')){
                    cadenaFormar = cadenaFormar + 'SAC_008';
                }
                if(registroTME.SAC_Estados__c != null && String.valueOf(registroTME.SAC_Estados__c).toUppercase().contains('SAC_009')){
                    cadenaFormar = cadenaFormar + 'SAC_009';
                }

                //Se le asigana la cadena construida al campo
                registroTME.SAC_DuplicadoMCCProcedenciaEstado__c = cadenaFormar;

            }
        }
    }

}