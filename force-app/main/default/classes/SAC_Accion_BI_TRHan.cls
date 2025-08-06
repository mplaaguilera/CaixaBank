public with sharing class SAC_Accion_BI_TRHan extends CC_TriggerHandlerBase {

    final static String RECORDTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    final static String RECORDTYPEACCIONMASETRO = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();
    final static String RECORDTYPEACCIONOTRAS = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId();
    //final static String RECORDTYPERESPONDERESC = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_AccionResponderEsc').getRecordTypeId();

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Accion__c>)tp.newList, (Map<Id, SAC_Accion__c>)tp.newMap);
	}

    private void process(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapNewObj) {
        List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaTareasMaestro = new List<SAC_Accion__c>();
        //List<SAC_Accion__c> listaRespuestasEsc = new List<SAC_Accion__c>();
        //List<SAC_Accion__c> listaTareas = new list<SAC_Accion__c>(); 

        //listaTareas= SAC_TareasOperativas_Controller.recuperarTarea(idPropietario);

        for (SAC_Accion__c accion : listNewObj) {
            if (accion.recordTypeId == RECORDTYPEACCIONMASETRO){
                listaTareasMaestro.add(accion);
                listaAcciones.add(accion);   
            }
            else if(accion.recordTypeId == RECORDTYPEACCIONOTRAS) {
                listaAcciones.add(accion); 
            }
            // else if(accion.recordTypeId == RECORDTYPERESPONDERESC){
                
            //     listaRespuestasEsc.add(accion); 
            // }
        }

        if (!listaAcciones.isEmpty()) {
            SAC_CargarDatosMaestro.cargarDatos(listaAcciones);
            SAC_AccionMetodos.cargarDatos(listaAcciones);

            //el importe va de la tarea a la pretensión US356803
            //SAC_Accion_RellenarImporte.rellenarImporteAbono(listaAcciones);
            insertarAccionesReclamacion(listaAcciones);    
            SAC_AccionMetodos.AccionComprobarOwnerYStatus(listaAcciones);
            SAC_AccionMetodos.calcularFechaVencimientoInicial(listaAcciones);
            SAC_Accionmetodos.tareaReclamacionCerrada(listaAcciones);
            
            //Se establece la fecha de alta de las acciones
            SAC_AccionMetodos.establecerFechaAlta(listaAcciones);
        }

        if(!listaTareasMaestro.isEmpty()){
            SAC_AccionGGH.tareaUnicaGGH(listaAcciones);
        }
    }

    /*****************************************************************
     * Proposito: Método que asigna las acciones de las pretensiones a su correspondiente reclamación
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204755         Carlos Solis   28/05/21      Creación
    *****************************************************************/
    public static void insertarAccionesReclamacion(List<SAC_Accion__c> listNewAcciones) {
       
        List<Id> listaIdsCasos = new List<Id>();
        //Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];

        for (SAC_Accion__c accion : listNewAcciones) {
            //busco la pretension de la accion para saber cual es su padre
            if (accion.SAC_Pretension__c != null) {
                listaIdsCasos.add(accion.SAC_Pretension__c);
            }
            //accion.OwnerId = cola.Id;
            accion.SAC_Estado__c = (String.isBlank(accion.SAC_Estado__c)) ? 'SAC_PendienteEnviar' : accion.SAC_Estado__c;
        }

        if (Schema.sObjectType.Case.isAccessible()) {
            List<Case> listaPretensiones = [select id, SAC_Reclamacion__c from Case where id in :listaIdsCasos
                                            and recordtypeId = :RECORDTYPEPRETENSION];

            Map<Id, case> mapaPretensiones = new Map<Id, Case>();
            for (Case caso : listaPretensiones) {
                mapaPretensiones.put(caso.Id, caso);
            }

            for (SAC_Accion__c accion : listNewAcciones) {
                //asigno la reclamacion a la accion
                if (mapaPretensiones.containsKey(accion.SAC_Pretension__c)) {
                    accion.SAC_Reclamacion__c = mapaPretensiones.get(accion.SAC_Pretension__c).SAC_Reclamacion__c;
                }
            }
        }
    }
}