//NOTA ANALISIS Estructura de un trigger CC

trigger CC_CatalogoFacturacionTrigger on CBK_CatalogoFacturacion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CC_TriggerFactory.createTriggerDispatcher(CBK_CatalogoFacturacion__c.sObjectType);
}

//NOTA ANALISIS CC_TriggerFactory es una clase que busca el metodo createTriggerDispatcher, donde se introduce un objeto de un tipo, ese metodo ejecuta otro metodo llamado "TriggerActivo" que su funcion es sacar el nombre de
// objeto, lo procesa para globalizar el formato del nombre por si tiene un doble '_' y añade el nombre del objeto al formato 'CC_Trigger_NOMBRE' si existe un metada del trigger con el mismo nombre procesado, devuelve un true
// al ser true, se activa entonces el metodo createTriggerDispatcher que ejecuta un "Dispatcher", si no encuentra un dispatcher se manda mensaje de error
// Si existe un metadata, ejecuta el metodo  getTrigerDispatcher, que el dispatcher