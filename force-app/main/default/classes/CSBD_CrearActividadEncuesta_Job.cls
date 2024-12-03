public with sharing class CSBD_CrearActividadEncuesta_Job implements Queueable {
    private String param1;
    private String param2;
    private String param3;
    private Id idLlamadaParam;

    public CSBD_CrearActividadEncuesta_Job(Id idLlamadaParam, String param1,String param2, String param3) {
        this.idLlamadaParam = idLlamadaParam;
        this.param1 = param1;
        this.param2 = param2;
        this.param3 = param3;
    }

    public void execute(QueueableContext context) {
        crearActividadOportunidadNoFuture(idLlamadaParam, param1, param2, param3);
    }

    private static void crearActividadOportunidadNoFuture(Id llamadaId, String tipoActividad, String detalle, String tipoCierre) {
        List<Task> actividades = new List<Task>();
        for (AggregateResult resultado : [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaId GROUP BY WhatId]) {
            actividades.add(crearObjetoActividad(llamadaId, String.valueOf(resultado.get('WhatId')), tipoActividad, detalle, tipoCierre));
        }
        insert actividades;
    }

    private static Task crearObjetoActividad(Id llamadaId, Id whatId, String tipoActividad, String asunto, String tipoCierre) {
        Task actividad = new Task(
            Subject = tipoActividad + (asunto != null ? ' (' + asunto + ')' : ''),
            CC_Llamada_Id__c = llamadaId,
            ActivityDate = System.today(),
            CC_Fecha_Inicio__c = System.now(),
            WhatId = whatId,
            Type = tipoActividad,
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId()
        );
        if (tipoCierre != null) {
            actividad.CC_Fecha_Fin__c = System.now();
            actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
            actividad.Status = 'Completed';
        }
        return actividad;
    }

    private static String obtenerTipoCierre(String tipoCierre) {
		for (Schema.PicklistEntry tipo : CC_Llamada__c.CC_Tipo_Cierre__c.getDescribe().getPicklistValues()) {
			if (tipo.getValue().equals(tipoCierre)) {
				return tipo.getLabel();
			}
		}
		return tipoCierre;
	}
}