/**
*   @description SEG_Grupo_Colaborador_Contact_AI_TRHan
*/
public class SEG_Grupo_Colaborador_Contact_AI_TRHan extends CC_TriggerHandlerBase {
 
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_Grupo_Colaborador_Contact__c>)tp.newList, (Map<ID, CC_Grupo_Colaborador_Contact__c>)tp.newMap);
	}
    
    private void process(List<CC_Grupo_Colaborador_Contact__c> listObj, Map<ID, CC_Grupo_Colaborador_Contact__c> mapObj) {
        
        // Validar que los usuarios asociados a un grupo de segmentos son de la misma tipología que su grupo.
        // JAV: 30/06/21 se comenta porque no se usa
        //SEG_SincronizarGrupoHelper.verificarUsuarioGrupoSegmentos (mapObj);
        
        // Marcar los grupos de segmentos como no sincronizados cuando se incorporan usuarios.
        //SEG_SincronizarGrupoHelper.actualizarUsuarioSegmentos(listObj);
	}
}