/**
 * @description Clase para el traslado a colaborador de tipo WebService.
 * Apertura de contexto para no impactar en transacciones de los diferentes procesos.
 */
public with sharing class SEG_trasladoColaboradorWSQueueable implements Queueable, Database.AllowsCallouts{

    /**
     * @description Listado en modo "Stack" para procesar los traslados a colaborador con llamada a WebService
     */
    private List<SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador> listadoTrasladosColaborador;
    
    /**
     * @description Constructor del método Queueable.
     * @param listadoTraslados Listado de traslados a colaborador a realizar.
     */
    public SEG_trasladoColaboradorWSQueueable (List<SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador> listadoTraslados)
    {
        listadoTrasladosColaborador = new List<SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador>();
        if (listadoTraslados != null && !listadoTraslados.isEmpty())
        {
            listadoTrasladosColaborador.addAll(listadoTraslados);
        }
    }

    /**
     * @description Ejecución del proceso Queueable.
     * @param context Contexto del proceso asíncrono.
     */
    public void execute (QueueableContext context)
    {
        if (this.listadoTrasladosColaborador == null || this.listadoTrasladosColaborador.isEmpty())
        {
            return;
        }

        // Recuperar el traslado a colaborador a realizar.
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador traslado = this.listadoTrasladosColaborador[0];
        String grupoTrasladoId = (String.isNotBlank(traslado.newGrupoName))?traslado.newGrupoName:traslado.newGrupoColaboradorId;
        SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS resultadoWS = new SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS();
        resultadoWS.status = 'NOK';
        resultadoWS.codigo = '0001';
        resultadoWS.detalle = 'Traslado no enviado (SEG_trasladoColaboradorWSQueueable)';

        try
        {
            // Realización de un traslado de colaborador a Valija.
            if (traslado.tipoColaborador == 'VALIJA')
            {
                resultadoWS = SEG_trasladoColaboradorWS.realizarTrasladoValija(traslado);
            }

        }catch (Exception ex){
            // Registrar error en el tratamiento del traslado.
            CBK_Log.error(ex);
            resultadoWS.status = 'NOK';
            resultadoWS.codigo = '9999';
            resultadoWS.detalle = ((String.isNotBlank(resultadoWS.detalle)) ? resultadoWS.detalle + '. ' + ex.getMessage() : ex.getMessage()) + ' (' + ex.getStackTraceString() + ')';
        }

        // Tratamiento final del traslado a colaborador. Los  datos del resultado lo tenemos en el objeto <resultadoWS>
        try{
            if (resultadoWS.status == 'OK')
            {
                String descripcionChatter = 'Petición en ESPERA de recuperar los ficheros asociados al traslado al grupo <' + grupoTrasladoId + '> asociado a ' + traslado.tipoColaborador;

                /* FIX. Comentado. Aligerar la transacción.
                Task createTask = new Task(
                    RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                    ,Type = 'Envío realizado a Valija'
                    ,TaskSubtype = 'Task'
                    ,Subject = 'Envío realizado a Valija' 
                    ,ActivityDate = System.today()
                    ,Status = 'Completed'
                    ,Description = descripcionChatter
                    ,WhatId = traslado.caseId
                    ,Priority = 'Normal'
                    ,SEG_ReferenciaValija__c = resultadoWS.referenciaValija
                );
                insert createTask;
                */

                // Traslado realizado correctamente.
                SEG_Case_Operativas_Controller.postOnChatter(traslado.caseId, descripcionChatter, 'Autoasignar caso (Valija - WS)', null);
            }else{
                // Traslado NO realizado correctamente en el grupo respuesta. Controlamos cualquier excepción producida en el proceso.
                Case updateRetroceso = new Case();
                updateRetroceso.Id = traslado.caseId;
                updateRetroceso.Status = traslado.oldStatus;
                updateRetroceso.SEG_Subestado__c = traslado.oldSubStatus;
                SEG_wsValijaCasosComunesNoSharing.actualizarCaseQueueable(updateRetroceso);

                String descripcionChatter = 'Se ha producido un ERROR en el traslado al grupo colaborador <' + grupoTrasladoId + '> asociado a ' + traslado.tipoColaborador;
                descripcionChatter = descripcionChatter + '. Codigo: ' + resultadoWS.codigo;
                descripcionChatter = descripcionChatter + '. Detalle: ' + resultadoWS.detalle;
                SEG_Case_Operativas_Controller.postOnChatter(traslado.caseId, descripcionChatter, 'ERROR Autoasignar caso (Valija - WS)', null);
            }
        }catch (Exception ex){
            // Registrar error en el tratamiento del traslado.
            CBK_Log.error(ex);
        }

        // Si hay datos, seguir en la ejecución encadenada del Queueable.
        this.listadoTrasladosColaborador.remove(0);
        SEG_trasladoColaboradorWSQueueable nuevaEjecucionChained = new SEG_trasladoColaboradorWSQueueable(this.listadoTrasladosColaborador);
        if (!this.listadoTrasladosColaborador.isEmpty() && !Test.isRunningTest())
        {
            System.enqueueJob(nuevaEjecucionChained);
        }
    }
}