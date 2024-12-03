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
        Set<String> perfilesValidarSet = new Set<String>{'CSBD', 'CC', 'AV', 'OS', 'AM', 'SEG', 'SAC'};

        //Si no hay correos salientes no es necesario recuperar los buzones
        for (EmailMessage correo : correos) {
            if (!correo.Incoming) {
                //El correo es saliente y está relacionado con una oportunidad
                if(correo.RelatedToId != null){
                    entidadRelacionadaCorreo = correo.RelatedToId;
                    if(entidadRelacionadaCorreo.startsWith('006')){
                        oportunidadCorreoId.add(correo.RelatedToId);
                    }
                }
            }
        }
        //Hay correos salientes relacionados con oportunidades
        if (!oportunidadCorreoId.isEmpty()) {
            //Correos de oportunidades relacionadas con CSBD
            List<Opportunity> oportunidadesCorreos = [SELECT Recordtype.DeveloperName FROM Opportunity WHERE Id=:oportunidadCorreoId];
            for(Opportunity oportunidad: oportunidadesCorreos){
                if(oportunidad.RecordType.DeveloperName.startsWith('CSBD')){
                    oportunidadesCSBDId.add(oportunidad.Id);
                }
            }
            if(!oportunidadesCSBDId.isEmpty()){
                String nombreDeMiUser = [SELECT Name, Id FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
                for(String prefijoProfile: perfilesValidarSet){
                    if(nombreDeMiUser.startsWith(prefijoProfile)){
                        perfilValidar = true;
                        break;
                    }
                }
                if(perfilValidar){
                    //Se obtiene de CSBD_Buzon_Envio_Manual_Correo__mdt la lista de buzones de salida válidos
                    List<String> buzonesSalidaValidos = CC_MetodosUtiles.listaCampo(
                        [SELECT CSBD_Direccion_Correo__c FROM CSBD_Buzon_Envio_Manual_Correo__mdt WHERE CSBD_Activo__c = TRUE],
                        'CSBD_Direccion_Correo__c'
                    );
                    //Si el correo a enviar tiene un buzón de salida que no está en la lista, se muestra un error
                    for (EmailMessage correo : correos) {
                        //El error salta si se cumple el perfil, el correo es entrante, relacionado con una oportunidad CSBD y el remitente no es un buzón habilitado
                        if (!correo.Incoming && oportunidadesCSBDId.contains(correo.RelatedToId) && !buzonesSalidaValidos.contains(correo.FromAddress)) {
                            correo.addError('El buzón de salida indicado no es apto para el envío de correos.', false);
                        }
                    }
                }
            }    
        }
    }

    private static void gestionReferenciaCorreo(List<EmailMessage> correosCsbd) {
        Id idRecordTypeTareaCsbd = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CSBD_Task');

        List<Task> tareasUpdate = new List<Task>();
        Map<Id, Id> mapaOportunidadesCorreosPendCliente = new Map<Id, Id>();

        Map<Id, Opportunity> oportunidades = new Map<Id, Opportunity>(
            [SELECT CSBD_Referencia_Correo_Saliente__c, CSBD_Dejar_Pendiente_Cliente__c FROM Opportunity
                WHERE Id IN :CC_MetodosUtiles.listaCampo(correosCsbd, 'RelatedToId', true)
                AND CSBD_Referencia_Correo_Saliente__c != NULL]
        );

        for (EmailMessage correoCsbd : correosCsbd) {
            if (correoCsbd.ActivityId != null) {
                //La tarea del correo se crea con el RT por defecto, es necesario actualizarla con el RT de CSBD
                Task tareaCorreoCsbd = new Task(Id = correoCsbd.ActivityId);
                tareaCorreoCsbd.RecordTypeId = idRecordTypeTareaCsbd;

                //Solo para correos salientes generados por la operativa "Enviar Correo"
                if (!correoCsbd.Incoming && correoCsbd.HtmlBody != null
                && correoCsbd.HtmlBody.contains('#@' + oportunidades.get(correoCsbd.RelatedToId)?.CSBD_Referencia_Correo_Saliente__c + '#')) {
                    //Se guarda la referencia a nivel de tarea para poder localizar ésta al recibir respuesta
                    tareaCorreoCsbd.CC_Referencia_Correo_Saliente__c = oportunidades.get(correoCsbd.RelatedToId).CSBD_Referencia_Correo_Saliente__c;
                    tareaCorreoCsbd.CSBD_Email_Pendiente_Cliente__c = correoCsbd.Id;
                    //Si así lo ha indicado el usuario la oportunidad pasa a estado "Pendiente Cliente" hasta recibir respuesta
                    if (oportunidades.get(correoCsbd.RelatedToId).CSBD_Dejar_Pendiente_Cliente__c) {
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