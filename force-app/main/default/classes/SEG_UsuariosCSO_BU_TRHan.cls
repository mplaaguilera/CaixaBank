public with sharing class SEG_UsuariosCSO_BU_TRHan extends CC_TriggerHandlerBase {

		
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SEG_UsuariosCSO__c>)tp.newList, (Map<Id, SEG_UsuariosCSO__c>)tp.newMap, (Map<Id, SEG_UsuariosCSO__c>) tp.oldMap);
    }
    
    private void process(List<SEG_UsuariosCSO__c> listNewObj, Map<Id, SEG_UsuariosCSO__c> mapNewObj, Map<Id, SEG_UsuariosCSO__c> mapOldObj) {
        concatenacionUsuarioGrupo(listNewObj, mapOldObj);	
	}   

    public static void concatenacionUsuarioGrupo(List<SEG_UsuariosCSO__c> listNewObj, Map<Id, SEG_UsuariosCSO__c> mapOldObj) {
        for (SEG_UsuariosCSO__c usuarioCSO : listNewObj) {
            String valorFinal = '';
            if (usuarioCSO.SEG_Usuario__c != null && (usuarioCSO.SEG_Usuario__c != mapOldObj.get(usuarioCSO.Id).SEG_GrupoCSO__c || usuarioCSO.SEG_Usuario__c != mapOldObj.get(usuarioCSO.Id).SEG_GrupoCSO__c)) {
                valorFinal = usuarioCSO.SEG_Usuario__c;
                if (usuarioCSO.SEG_GrupoCSO__c != null) {
                    valorFinal= valorFinal + usuarioCSO.SEG_GrupoCSO__c;
                }
                usuarioCSO.SEG_UsuarioGrupo__c = valorFinal;
            }
        }    
    }
}