public without sharing class SAC_Accion_AI_TRHan  extends CC_TriggerHandlerBase {

    private static Set<String> objetos = new Set<String>{'SAC_Accion__c', 'SAC_TMECaso__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private final static Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private final static Id RECTYPEOTRASTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    private final static Id RECTYPEACCIONRESPONDERESC = mapRTsObjects.get('SAC_Accion__c').get('SAC_AccionResponderEsc').getRecordTypeId();
    private final static Id RECTYPETMETAREA = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_TMETarea').getRecordTypeId();

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SAC_Accion__c>)tp.newList, (Map<Id, SAC_Accion__c>)tp.newMap);
	}    

    private void process(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapNewObj){
        List<SAC_Accion__c> listNewObjSAC = new List<SAC_Accion__c>();
        Map<Id, SAC_Accion__c> mapNewObjSAC = new Map<Id, SAC_Accion__c>();

        for(SAC_Accion__c accion : listNewObj){
            if (accion.RecordTypeId == RECTYPEMAESTROTAREAS || accion.RecordTypeId == RECTYPEOTRASTAREAS || accion.RecordTypeId == RECTYPEACCIONRESPONDERESC) {
                listNewObjSAC.add(accion);
            }
        }

        for(SAC_Accion__c accion : mapNewObj.values()){
            if (accion.RecordTypeId == RECTYPEMAESTROTAREAS || accion.RecordTypeId == RECTYPEOTRASTAREAS || accion.RecordTypeId == RECTYPEACCIONRESPONDERESC) {
                mapNewObjSAC.put(accion.Id, accion);
            }
        }

        if (!listNewObjSAC.isEmpty()) {
            processSAC(listNewObjSAC, mapNewObjSAC);
        }
    }

    private void processSAC(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapNewObj){

        List<SAC_Accion__c> listaMaestro = new List<SAC_Accion__c>();
        List<SAC_Accion__c> otraLista = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaGenerica = new List<SAC_Accion__c>();
        List<SAC_TMECaso__c> tmeTareas = new List<SAC_TMECaso__c>();  //Lista para crear los tme de Tareas
        List<Id> listaIdsAcciones = new List<Id>();


        for(SAC_Accion__c accionIndividual : listNewObj){
            SAC_TMECaso__c tme = new SAC_TMECaso__c();
            tme.name = 'Ejecución de la tarea'; // TME de ejecución de la tarea (Cuenta el tiempo desde que se crea la tarea hasta que se finaliza)
            tme.RecordTypeId = RECTYPETMETAREA;
            tme.SAC_Accion__c= accionIndividual.id;

            tmeTareas.add(tme);
            if(accionIndividual.RecordTypeId == RECTYPEMAESTROTAREAS){
                listaMaestro.add(accionIndividual);
                listaIdsAcciones.add(accionIndividual.Id);
                listaGenerica.add(accionIndividual);
            }
            if(accionIndividual.RecordTypeId == RECTYPEOTRASTAREAS){
                otraLista.add(accionIndividual);
                listaGenerica.add(accionIndividual);
            }

        }
         SAC_DatabaseDML.insertListDML(tmeTareas, true); 
        //Database.insert(tmeTareas); 

        List<SAC_Accion__c> listaSelect = new List<SAC_Accion__c>();
        listaSelect = [SELECT Id, SAC_MaestroAccionesReclamacion__r.Name, SAC_IndexedThreadId__c FROM SAC_Accion__c WHERE RecordTypeId =: RECTYPEMAESTROTAREAS AND Id IN :listaIdsAcciones AND SAC_MaestroAccionesReclamacion__r.Name = 'GENERAL PARA OFICINAS'];


        if(!listaGenerica.isEmpty()){ 
            SAC_AplicaTareasAutomatizadas.automatizarCasoAplicaTarea(listaGenerica);
        }

        if(!otraLista.isEmpty()){
            SAC_Accion_PermisoPropietario.permisosNuevaAccionPropietario(otraLista); //Asignar permiso de edición al usuario sobre las acciones creadas
        }

        if(!listaSelect.isEmpty()){
            SAC_TareasOperativas_Controller.crearThreadId(listaSelect);
        }
    }
}