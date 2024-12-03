public with sharing class CC_SeleccionarGC_CI_Controller {
    
    public class PickListWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        public PickListWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled
    public static List<pickListWrapper> getMCCGrupoList(String recordId) {
        
        Id recordTypeIdGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        List <CC_Grupo_Colaborador__c> grupos = new List <CC_Grupo_Colaborador__c>();
        grupos = [Select Id, name from CC_Grupo_Colaborador__c where recordtypeId =: recordTypeIdGrupoColaborador];
        List<pickListWrapper> optionsGrupos = new List<pickListWrapper>();
        List<String> nombreGrupo = new List<String>();
        for (CC_Grupo_Colaborador__c grupo : grupos) {
            PickListWrapper wrap = new PickListWrapper(grupo.Name, grupo.Id);       
            if (!nombreGrupo.contains(grupo.Name)) {
                nombreGrupo.add(grupo.Name);
                optionsGrupos.add(wrap);
            }
        }
        return optionsGrupos;
    }
	
	@AuraEnabled
    public static void updateAg (String recordId, String grupoColaboradorId, String grupoColaboradorName) {
	
		CC_Agrupador__c agrupador = new CC_Agrupador__c();
			
		agrupador.Id = recordId;
		agrupador.CC_CI_Id_GrupoColaborador_Interno__c = grupoColaboradorId;
        agrupador.CC_CI_Name_GrupoColaborador_Interno_c__c = grupoColaboradorName;
		update agrupador;
	}
    
    @AuraEnabled
    public static String getNombreGrupoColaborador (String recordId) {
        List<CC_Agrupador__c> agrupadores = new List <CC_Agrupador__c>();
        CC_Agrupador__c  agrupador = new CC_Agrupador__c();
        String defaultValue = '';
        String defaultValueInit = '--Seleccione una opción--';
        if (recordId!=null){
         	   	agrupadores = [SELECT Id, CC_CI_Name_GrupoColaborador_Interno_c__c from CC_Agrupador__c where id=: recordId LIMIT 1];
            	
            if (!agrupadores.isEmpty()){                
                agrupador = agrupadores.get(0);            	
                if (agrupador.CC_CI_Name_GrupoColaborador_Interno_c__c == null || agrupador.CC_CI_Name_GrupoColaborador_Interno_c__c == ''){
                    defaultValue = defaultValueInit;
                }else{
            	defaultValue = agrupador.CC_CI_Name_GrupoColaborador_Interno_c__c;            	
            	}
            }else {
            	defaultValue = defaultValueInit;
        	}
      
        } else {
            defaultValue = defaultValueInit;
        }
        
        return defaultValue;
    }

}