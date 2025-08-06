public with sharing abstract class CC_TriggerHandlerBase implements CC_ITriggerHandler {
    /*
    * Esta clase implementa la CC_ITTriggerHandler para proveer los métodos abstractos / virtuales, permitiendo implementar
    * sólo aquellos que son necesarios; a excepción del método mainEntry que es obligatorio.
    */
	protected Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();

	/**
	 * Mapa para hacer un bypass con el propio registro
	 */
	public static Map<String, Opportunity> mapToByPass = new Map<String, Opportunity>();

	/**
	 * Mapa para hacer un bypass con el propio registro task
	 */
	public static Map<String, Task> mapToByPassTask = new Map<String, Task>();
	
	/*
    * Método para la primera llamada del contexto del trigger. Requerido implementar.
	*/
	public abstract void mainEntry(CC_TriggerParameters tp);
	
	/*
    * Método para las llamadas recurrentes (reentradas) en el mismo contexto. No es requerido implementar, pero aconsejable.
	*/
	public virtual void inProgressEntry(CC_TriggerParameters tp) {
		
	}
	
	/*
    * Actualización de objetos, si lo requiere el proceso.
	*/
	public virtual void updateObjects() {
		if(sObjectsToUpdate.size() > 0)
			update sObjectsToUpdate.values();
	}
}