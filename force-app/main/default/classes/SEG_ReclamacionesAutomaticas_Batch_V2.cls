/**
 *   @description SEG_ReclamacionesAutomaticas_Batch_V2
*/
public class SEG_ReclamacionesAutomaticas_Batch_V2 implements Database.Batchable<sObject> {

    private list<String> lstCasos;

    public SEG_ReclamacionesAutomaticas_Batch_V2(){
        CBK_Log.debug('Start - Batch reclamaciones automáticas ', logginglevel.INFO);
     }

     public SEG_ReclamacionesAutomaticas_Batch_V2(list<String> lstCasos){
        CBK_Log.debug('Start - Batch reclamaciones automáticas ', logginglevel.INFO);
        this.lstCasos = lstCasos;
    } 

	/**
	 *  @description Recuperar los contratos propios de Segmentos.
	 *  @param bc -> Objeto contexto
	 *  @return Database.QueryLocator
	 */
	public Database.QueryLocator start(Database.BatchableContext bc){
		Date todayDate = date.today();
        if (lstCasos==null) {
            return Database.getQueryLocator([SELECT Id from Case 
                                            WHERE id in (
                                                SELECT SEG_SR_Seguimiento__c
                                                FROM SEG_Contratos__c 
                                                WHERE SEG_Estado__c = 'No firmado' AND SEG_SR_Seguimiento__r.Status = 'Cerrado' AND SEG_NombreCuenta__c != null AND SEG_NombreCliente__c != null 
                                                AND SEG_SR_Seguimiento__r.SEG_Grupo__c != null
                                                AND ((SEG_Fecha_1_Reclamacion__c <= TODAY AND SEG_1a_Reclamacion_ejecutada_manualmente__c = false AND SEG_Fecha_1a_Reclamacion_Proceso__c = null)
                                                    OR (SEG_Fecha_2_Reclamacion__c <= TODAY AND SEG_2a_Reclamacion_ejecutada_manualmente__c = false AND SEG_Fecha_2a_Reclamacion_Proceso__c = null)
                                                    OR (SEG_Fecha_3_Reclamacion__c <= TODAY AND SEG_3a_Reclamacion_ejecutada_manualmente__c = false AND SEG_Fecha_3a_Reclamacion_Proceso__c = null)
                                                    OR (SEG_Fecha_Envio_Gestor__c <= TODAY AND SEG_Fecha_Envio_Gestor_Proceso__c = null)
                                                    )
                                                )]);
        } else {
            return Database.getQueryLocator([SELECT Id from Case 
                                            WHERE id in :lstCasos
                                            AND id in (
                                                SELECT SEG_SR_Seguimiento__c
                                                FROM SEG_Contratos__c 
                                                WHERE SEG_Estado__c = 'No firmado' AND SEG_SR_Seguimiento__r.Status = 'Cerrado' AND SEG_NombreCuenta__c != null AND SEG_NombreCliente__c != null 
                                                AND SEG_SR_Seguimiento__r.SEG_Grupo__c != null
                                                AND ((SEG_Fecha_1_Reclamacion__c <= TODAY AND SEG_1a_Reclamacion_ejecutada_manualmente__c = false AND SEG_Fecha_1a_Reclamacion_Proceso__c = null)
                                                    OR (SEG_Fecha_2_Reclamacion__c <= TODAY AND SEG_2a_Reclamacion_ejecutada_manualmente__c = false AND SEG_Fecha_2a_Reclamacion_Proceso__c = null)
                                                    OR (SEG_Fecha_3_Reclamacion__c <= TODAY AND SEG_3a_Reclamacion_ejecutada_manualmente__c = false AND SEG_Fecha_3a_Reclamacion_Proceso__c = null)
                                                    OR (SEG_Fecha_Envio_Gestor__c <= TODAY AND SEG_Fecha_Envio_Gestor_Proceso__c = null)
                                                    )
                                                )]);
        }
    }

	/**
	 *  @description Tratamiento de los clientes.
	 *  @param bc -> Objeto contexto
	 *  @param scope -> Scope del batch
	 */

	public void execute(Database.BatchableContext bc, List<Case> scope)
	{	
		if (scope.isEmpty()) {
			return;
		}
        
        //Modificador para deshabilitar eltrigger
        SEG_Modificadores_Trigger.activarModificador('SEG_EmailMessage_AI_TRHan: bypass');
        //SEG_Modificadores_Trigger.activarModificador('AV_Task_BI_TRHan: bypass');


		// Indicar el número de registros a tratar en el lote.
		CBK_Log.debug('Execute - Batch reclamaciones automáticas. Número registros lote: ' + scope.size(), logginglevel.INFO);

        Set<String> setCasos = New Set<String>();
		for (Case recl : scope) {
            setCasos.add(recl.Id);
		}
        SEG_ReclamacionesAutomaticas_Case proceso = New SEG_ReclamacionesAutomaticas_Case();
        proceso.procesarCasos(setCasos);
	}
    
	public void finish(Database.BatchableContext bc){
		CBK_Log.debug('Finalización - Batch reclamaciones automáticas', logginglevel.INFO);
	}
}