public interface CC_ITriggerDispatcher {
    /*
    * Interfaz para la gestión de los métodos de enrutado de los eventos del trigger.
    * Se incluyen métodos bulk para ejecución de operaciones DML únicas, obtención de datos para todo el contexto, etc.
    */

	/*
    * Método llamado por el framework de triggers para las operaciones bulk previas.
	*/
	void bulkBefore();
	
	/*
	* Método llamado por el framework de triggers para las operaciones bulk posteriores.
	*/
	void bulkAfter();
	
	/*
	* Método llamado por el framework de triggers para las operaciones finales después de las acciones bulk.
	*/
	void andFinally();
	
	/*
    * Método para las acciones a realizar antes de insertar los registros.
	*/
	void beforeInsert(CC_TriggerParameters tp);
	
	/*
    * Método para las acciones a realizar antes de actualizar los registros.
	*/
	void beforeUpdate(CC_TriggerParameters tp);
	
	/*
    * Método para las acciones a realizar antes de borrar los registros.
	*/
	void beforeDelete(CC_TriggerParameters tp);
	
	/*
    * Método para las acciones a realizar después de insertar los registros.
	*/
	void afterInsert(CC_TriggerParameters tp);
	
	/*
    * Método para las acciones a realizar después de actualizar los registros.
	*/
	void afterUpdate(CC_TriggerParameters tp);
	
	/*
    * Método para las acciones a realizar después de borrar los registros.
	*/
	void afterDelete(CC_TriggerParameters tp);
	
	/*
    * Método para realizar las acciones después de los registros que han sido recuperados.
	*/
	void afterUnDelete(CC_TriggerParameters tp);

}