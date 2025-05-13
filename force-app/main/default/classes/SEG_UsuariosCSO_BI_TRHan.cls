/**
*   @description SEG_Contratos_BI_TRHan
*/
public with sharing class SEG_UsuariosCSO_BI_TRHan extends CC_TriggerHandlerBase{
    
    /**
     * @description Entrada principal del trigger BI.
     * @param tp Parámetros de contexto del trigger.
     */
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SEG_UsuariosCSO__c>)tp.newList);
	}

    /**
     * @description Proceso principal del trigger BI.
     * @param listNewObj Listado de objetos New del trigger.
     */
    private void process(List<SEG_UsuariosCSO__c> listNewObj) {
        concatenacionUsuarioGrupo(listNewObj);
	}

    private void concatenacionUsuarioGrupo (List<SEG_UsuariosCSO__c> listNewObj) {
        for (SEG_UsuariosCSO__c usuarioCSO : listNewObj) {
            String valorFinal = '';
            if (usuarioCSO.SEG_Usuario__c != null) {
                valorFinal = usuarioCSO.SEG_Usuario__c;
                if (usuarioCSO.SEG_GrupoCSO__c != null) {
                    valorFinal= valorFinal + usuarioCSO.SEG_GrupoCSO__c;
                }
                usuarioCSO.SEG_UsuarioGrupo__c = valorFinal;
            }
        }
    }
}