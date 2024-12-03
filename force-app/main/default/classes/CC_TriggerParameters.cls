public class CC_TriggerParameters {
    /*
    * Parámetros del trigger.
    */
    public CC_TriggerParameters(){}

	/*
    * Enumeración que representa los eventos del trigger.
	*/
	public Enum TriggerEvent { beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete, afterUndelete }
	public TriggerEvent tEvent;
	
	public List<SObject> oldList { get; set; }
	public List<SObject> newList { get; set; }
	public Map<Id, SObject> oldMap { get; set; }
	public Map<Id, SObject> newMap { get; set; }
	public String triggerObject { get; private set; }
	public Boolean isExecuting { get; private set; }
	
	/*
    * Constructor del objeto.
	* olist -> Listado de registros en estado 'before' event.
	* nlist -> Listado de registros en estado 'after' event.
	* omap -> Mapa de registros en estado 'before' event.
	* nmap -> Mapa de registros en estado 'after' event.
	* ib -> Flag para indicar el evento 'isBefore'.
	* ia -> Flag para indicar el evento 'isAfter'.
	* id -> Flag para indicar el evento 'isDelete'.
	* ii -> Flag para indicar el evento 'isInsert'.
	* iu -> Flag para indicar el evento 'isUpdate'.
	* iud -> Flag para indicar el evento 'isUnDelete'.
	* ie -> Flag para indicar el evento 'isExecuting'.
	*/
	public CC_TriggerParameters(List<SObject> olist, List<SObject> nlist, Map<Id, SObject> omap, Map<Id, SObject> nmap,
								Boolean ib, Boolean ia, Boolean id, Boolean ii, Boolean iu, Boolean iud, Boolean ie) {
		this.oldList = olist;
		this.newList = nlist;
		this.oldMap = omap;
		this.newMap = nmap;
		this.triggerObject = CC_UtilityClass.getSObjectTypeName((this.oldList != null && this.oldList.size() > 0) ? this.oldList[0] : this.newList[0]);
		if (ib & ii) tEvent = TriggerEvent.beforeInsert;
		else if (ib && iu) tEvent = TriggerEvent.beforeUpdate;
		else if (ib && id) tEvent = TriggerEvent.beforeDelete;
		else if (ia && ii) tEvent = TriggerEvent.afterInsert;
		else if (ia && iu) tEvent = TriggerEvent.afterUpdate;
		else if (ia && id) tEvent = TriggerEvent.afterDelete;
		else if (ia && iud) tEvent = TriggerEvent.afterUndelete;
		isExecuting = ie;
	}
}