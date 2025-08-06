/***********************************************************************
 * Name: SAC_SchedulableTaskMisClientes
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Clase que mediante los pendingProcess (framework schedulable) creará una task para el proyecto mis clientes en el momento en el que se informa una fecha de 
 * resolución en una reclamación. Previamente en el método crearTaskMisClientes() de la clase SAC_Reclamación, se creará un pending process por cada reclamación que tienen 
 * activado el check de SAC_GenerarTaskMisClientes__c, no tienen un sentido de resolución de inadmisión, y que solo tengan una única pretensión.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.1            US867835         Raúl Santos    01/04/2024   Creación
*************************************************************************/

public with sharing class SAC_SchedulableTaskMisClientes extends CBK_SCH_Queueable_Abstract{

    private static Set<String> objetos = new Set<String>{'Task', 'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPETASKEXPCLIENTE = mapRTsObjects.get('Task').get('AV_ExperienciaCliente').getRecordTypeId();

    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> lstInfoPp = this.lstInfoProcess;
        work(lstInfoPp);
    }

    @TestVisible
    private void work(List<CBK_SCH_PendingProcess__c> lstInfoPp) {

        try {
            Set<Id> setIdsReclamaciones = new Set<Id>();
            List<Case> listaReclamaciones = new List<Case>();

            //Recorrer los pendingProcess para sacar las ids de las reclamaciones y poder recuperarlas
            for (CBK_SCH_PendingProcess__c pendingProcessTask : lstInfoPp) {
                setIdsReclamaciones.add(pendingProcessTask.RecordId__c);
            }

            //Recuperar las reclamaciones
            if (!setIdsReclamaciones.isEmpty()) {
                listaReclamaciones = [SELECT Id, Subject, SAC_Reclamacion__c, CC_Oficina_Afectada_Lookup__r.CC_Numero_Oficina__c, CC_MCC_ProdServ__r.Name, SEG_Detalle__r.Name,
                                        SAC_MotivoSentidoResolucion__c, CC_Oficina_Afectada_Lookup__r.AV_MatriculaResponsable1__r.CC_Matricula__c, AccountId
                                        FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id IN :setIdsReclamaciones];
            }

            if(!listaReclamaciones.isEmpty()){
                //Crear una task por cada reclamacion
                List<Task> listaTaskInsertar = new List<Task>();

                //Recorrer reclamaciones e insertar la task de mis clientes
                for (Case reclamacion : listaReclamaciones) {
                    Task tareaMisClientes = new Task();
                    tareaMisClientes.RecordTypeId = RECTYPETASKEXPCLIENTE;
                    tareaMisClientes.Priority = 'Y';
                    tareaMisClientes.Status = 'Open';
                    tareaMisClientes.Subject = 'Reclamación del SAC';
                    tareaMisClientes.ActivityDate = System.today().addDays(7); //7 Dias
                    tareaMisClientes.AV_ExternalID__c = 'Task';
                    tareaMisClientes.AV_InOutbound__c = '001';
                    tareaMisClientes.AV_ToDelete__c = false;
                    tareaMisClientes.AV_OrigenAct__c = 'AV_CloseDeLoop';
                    tareaMisClientes.AV_OrigenApp__c = 'AV_SAC';
                    tareaMisClientes.AV_Tipo__c = 'LMD';
                    tareaMisClientes.AV_FechaFinAccionComercial__c = tareaMisClientes.ActivityDate;
                    tareaMisClientes.AV_FechaInicioVigencia__c = System.today();
                    tareaMisClientes.AV_Case__c = reclamacion.Id;
                    tareaMisClientes.AV_SurveyValue__c = 19;
                    tareaMisClientes.AV_Valor1__c = 'Enlace a la reclamación: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + reclamacion.Id;

                    if (String.isNotBlank(reclamacion.CC_Oficina_Afectada_Lookup__r.CC_Numero_Oficina__c)) {
                        tareaMisClientes.AV_Center__c = reclamacion.CC_Oficina_Afectada_Lookup__r.CC_Numero_Oficina__c;
                    }
                    if (String.isNotBlank(reclamacion.CC_MCC_ProdServ__r.Name) && String.isNotBlank(reclamacion.SEG_Detalle__r.Name)) {
                        String valorMCC = 'MCC Producto: ' + reclamacion.CC_MCC_ProdServ__r.Name + ' - MCC Detalle: ' + reclamacion.SEG_Detalle__r.Name;
                        tareaMisClientes.AV_Valor2__c = valorMCC.left(255);
                    }
                    if (String.isNotBlank(reclamacion.SAC_MotivoSentidoResolucion__c)) {
                        tareaMisClientes.AV_Valor3__c = reclamacion.SAC_MotivoSentidoResolucion__c.left(255);
                    }
                    if (String.isNotBlank(reclamacion.CC_Oficina_Afectada_Lookup__r.AV_MatriculaResponsable1__r.CC_Matricula__c)) {
                        tareaMisClientes.AV_CodigoGestorAsignado__c = reclamacion.CC_Oficina_Afectada_Lookup__r.AV_MatriculaResponsable1__r.CC_Matricula__c;
                    }
                    if (String.isNotBlank(reclamacion.AccountId)) {
                        tareaMisClientes.WhatId = reclamacion.AccountId;
                    }

                    listaTaskInsertar.add(tareaMisClientes);
                }

                //Insertar registros
                if (!listaTaskInsertar.isEmpty()) {
                    SAC_DatabaseDML.insertListDML(listaTaskInsertar, true);
                }

                //Añadir la id de las Task insertadas a el campo AV_ExternalID__c
                List<Task> listaTaskUpdatear = new List<Task>();
                for (Task tarea : listaTaskInsertar) {
                    tarea.AV_ExternalID__c = tarea.AV_ExternalID__c + tarea.Id;
                    listaTaskUpdatear.add(tarea);
                }

                //Updatear las Task
                if (!listaTaskUpdatear.isEmpty()) {
                    SAC_DatabaseDML.updateListDML(listaTaskUpdatear, true);
                }  
            }
        }catch(Exception e) {
            CBK_Log.error(e);
        }
    }
}