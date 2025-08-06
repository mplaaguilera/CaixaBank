public with sharing class CSBD_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
    }

    private static void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        List<EmailMessage> correosCsbd = CSBD_EmailMessage.descartarCorreosNoCsbd(listNewObj);
        validarBuzonSalida(listNewObj);
        gestionReferenciaCorreo(correosCsbd);
    }

    private static void validarBuzonSalida(List<EmailMessage> correos) {
        Boolean perfilValidar = false;
        Set<Id> oportunidadCorreoId = new Set<Id>();
        Set<Id> oportunidadesCSBDId = new Set<Id>();
        String entidadRelacionadaCorreo;
        Boolean esOportunidad;

        //Si no hay correos salientes no es necesario recuperar los buzones
        for (EmailMessage correo : correos) {
            if (!correo.Incoming) {
                //El correo es saliente y está relacionado con una oportunidad
                if (correo.RelatedToId != null) {
                    entidadRelacionadaCorreo = correo.RelatedToId;
                    esOportunidad = entidadRelacionadaCorreo.startsWith('006');
                    if (esOportunidad) {
                        oportunidadCorreoId.add(correo.RelatedToId);
                    }
                }
            }
        }
        //Hay correos salientes relacionados con oportunidades
        if (!oportunidadCorreoId.isEmpty()) {
            List<Opportunity> oportunidadesCorreos = [SELECT RecordType.DeveloperName
                                                        FROM Opportunity WHERE Id IN :oportunidadCorreoId];
            for (Opportunity oportunidad : oportunidadesCorreos) {
                if (oportunidad.RecordType.DeveloperName.startsWith('CSBD')) {
                    oportunidadesCSBDId.add(oportunidad.Id);
                }
            }
            if (!oportunidadesCSBDId.isEmpty() && !Test.isRunningTest()) {
                String prefijoProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name.substringBefore('_');
                if (new Set<String>{'CSBD', 'CC', 'AV', 'OS', 'AM', 'SEG', 'SAC'}.contains(prefijoProfileName)) {
                    String buzonesValidos = String.join(CC_MetodosUtiles.listaCampo([SELECT CSBD_Direccion_Correo__c FROM CSBD_Buzon_Envio_Manual_Correo__mdt WHERE CSBD_Activo__c = TRUE], 'CSBD_Direccion_Correo__c'), ',');
                    for (EmailMessage correo : correos) {
                        if (!correo.Incoming && oportunidadesCSBDId.contains(correo.RelatedToId)
                        && !buzonesValidos.contains(correo.FromAddress)) {
                            correo.addError('El buzón de salida indicado no es apto para el envío de correos.', false);
                        }
                    }
                }
            }
        }
    }

    private static void gestionReferenciaCorreo(List<EmailMessage> correosCsbd) {
        List<Task> tareasUpdate = new List<Task>();
        Map<Id, Id> mapaOportunidadesCorreosPendCliente = new Map<Id, Id>();

        Map<Id, Opportunity> oportunidades = new Map<Id, Opportunity>(
            [SELECT CSBD_Referencia_Correo_Saliente__c, CSBD_Dejar_Pendiente_Cliente__c FROM Opportunity
                WHERE Id IN :CC_MetodosUtiles.listaCampo(correosCsbd, 'RelatedToId', true)
                AND CSBD_Referencia_Correo_Saliente__c != NULL]
        );

        Id idRecordTypeTareaCsbd = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId();
        for (EmailMessage correoCsbd : correosCsbd) {
            if (correoCsbd.ActivityId != null) {
                //La tarea del correo se crea con el RT por defecto, es necesario actualizarla con el RT de CSBD
                Task tareaCorreoCsbd = new Task(Id = correoCsbd.ActivityId);
                tareaCorreoCsbd.RecordTypeId = idRecordTypeTareaCsbd;

                Opportunity oportunidad = oportunidades.get(correoCsbd.RelatedToId);

                //Solo para correos salientes generados por la operativa "Enviar Correo"
                if (!correoCsbd.Incoming && correoCsbd.HtmlBody != null
                && correoCsbd.HtmlBody.contains('#@' + oportunidad?.CSBD_Referencia_Correo_Saliente__c + '#')) {
                    //Se guarda la referencia a nivel de tarea para poder localizar ésta al recibir respuesta
                    tareaCorreoCsbd.CC_Referencia_Correo_Saliente__c = oportunidad?.CSBD_Referencia_Correo_Saliente__c;
                    tareaCorreoCsbd.CSBD_Email_Pendiente_Cliente__c = correoCsbd.Id;
                    //Si así lo ha indicado el usuario la oportunidad pasa a estado "Pendiente Cliente" hasta recibir respuesta
                    if (oportunidad?.CSBD_Dejar_Pendiente_Cliente__c) {
                        mapaOportunidadesCorreosPendCliente.put(correoCsbd.RelatedToId, correoCsbd.Id);
                    }
                }
                tareasUpdate.add(tareaCorreoCsbd);
            }
        }
        update tareasUpdate;
        CSBD_Opportunity.oportunidadPendienteCliente(mapaOportunidadesCorreosPendCliente);
    }
}