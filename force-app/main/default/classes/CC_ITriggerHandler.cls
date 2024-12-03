public interface CC_ITriggerHandler {
    /*
    * Definición de la interfaz para los Trigger Handlers.
    * La lógica para los eventos iniciales (primera instancia del handler) se realiza en el método mainEntry.
    * La lógica para los eventos recurrentes (reentradas) se realiza en el método inProgressEntry.
    */

	/*
    * Llamada para la primera ejecución del contexto.
	*/
	void mainEntry(CC_TriggerParameters tp);
	
	/*
    * Llamada para las llamadas recurrentes (reentradas) en el mismo contexto.
	*/
	void inProgressEntry(CC_TriggerParameters tp);
	
	/*
    * Actualización de objetos, si lo requiere el proceso.
	*/
	void updateObjects();
}