public class SEG_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        if (SEG_Modificadores_Trigger.modificadorActivo('SEG_EmailMessage_AI_TRHan: bypass'))
		{
			return;
		}
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
	}


    private static List<EmailMessage> filtrarCorreosNoSEG(List<EmailMessage> correos) {
        List<EmailMessage> correosCc = new List<EmailMessage>();
        Set<Id> idsPadre = new Set<Id>();
        for (EmailMessage correo : correos) {
            if (String.isNotBlank(correo.ParentId)) {
                idsPadre.add(correo.ParentId);
            } else if (String.isNotBlank(correo.RelatedToId)) {
                idsPadre.add(correo.RelatedToId);
            }
        }

        if (!idsPadre.isEmpty()) {
            Map<Id, EmailMessage> mapaCorreos = new Map<Id, EmailMessage>();
            for (EmailMessage correo : correos) {
                mapaCorreos.put(correo.Id, correo);
            }

            Set<Id> idCasosCc = new Set<Id>();
            for (Case casoCc : [SELECT Id FROM Case WHERE Id IN :idsPadre AND RecordType.DeveloperName LIKE 'SEG_%']) {
                idCasosCc.add(casoCc.Id);
            }

            for (EmailMessage correo : correos) { 
                if (idCasosCc.contains(correo.ParentId) || idCasosCc.contains(correo.RelatedToId)) {
                    correosCc.add(mapaCorreos.get(correo.Id));
                }   
            }
        }
        return correosCc;
    }

    private static void process(List<EmailMessage> correos, Map<Id, EmailMessage> mapaCorreos) {
        List<EmailMessage> correosCc = filtrarCorreosNoSEG(correos);

        if (!correosCc.isEmpty()) {

            setAcuseReciboEmail (correosCc);

            //Se acumulan las inserciones/actualizaciones en las siguientes listas para ejecutarlas al final
            List<Case> casos = new List<Case>();

            //Hasta que se inserten las actividades de traslado no se pueden informar los Ids en las de
            //correo, así que se guardan las relaciones en este mapa y se informan los Ids al final
            Map<Id, Integer> relacionActividades = new Map<Id, Integer>();

            //En función de la operativa y de si el correo es saliente o entrante, se ejecutan acciones diferentes
            /*for (EmailMessage correo : correosCc) {
                if (correo.Status != '5') { //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
                    if (!correo.Incoming) {

                    } else {
                        //Correo ENTRANTE
                        List<Case> casoCorreo = [SELECT Id, Status, OwnerId FROM Case WHERE Id = :correo.ParentId LIMIT 1];
                        if (!casoCorreo.isEmpty()) {
                            for (Case c : casoCorreo) { //Solo entrará una vez
                                String referencia = CC_EmailMessage.referenciaCorreo(correo);
                                
                            }
                        }
                    }
                } //Fin "for (EmailMessage correo : newList)"
            }*/

            //Ejecución de las actualizaciones de caso
            //update casos;

            //CanalBPO: 
            //si es un email no draft se envia a Canal BPO. 
            envioCanalBPO(correosCc, mapaCorreos);
        }
	}

    private static void envioCanalBPO(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj)
    {
        System.debug('ANTES DE BPO');
        System.debug('Tamaño de listNewObj:'+listNewObj.size());
        Set<Id> caseIdSet = new Set<Id>();
        Map<id,boolean> mapCasosSincronizados = new Map<id,boolean>();
        for (EmailMessage correo : listNewObj) 
        {
            caseIdSet.add(correo.ParentId);
        }
        for(Case caso:[select id, SEG_Caso_sincronizado_en_BPO__c from Case where id in :caseIdSet])
        {
            mapCasosSincronizados.put(caso.id,caso.SEG_Caso_sincronizado_en_BPO__c);
        }
        for (EmailMessage correo : listNewObj) 
        {
            System.debug('correo.Status:'+correo.Status);
            System.debug('correo.Parentid:'+correo.PArentid);
            System.debug('correo.SEG_Caso_sincronizado_en_BPO__c:'+mapCasosSincronizados.get(correo.Parentid));
            if (correo.Status != '5' && mapCasosSincronizados.get(correo.Parentid)) 
            { //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
                //Correo ENTRANTE
                System.debug('ENVIO A BPO');
                try{
                    SEG_BPO_WS.actualizarCaso(correo.ParentId,'modificación');
                }catch(Exception ex){
                    System.debug('Error actualizando caso BPO:'+ ex.getMessage()); 
                }
                
            } 
        }
    }

	private List<EmailMessage> filtrarEmailMessageNoSeg(List<EmailMessage> listNewObj) {

		List<EmailMessage> newList = new List<EmailMessage> ();
		for (EmailMessage emailMessage : listNewObj) {
			if ((emailMessage.RelatedToId != null && OT_Proyectos.registroProyecto(emailMessage.RelatedToId) == 'SEG') || (emailMessage.ParentId != null && OT_Proyectos.registroProyecto(emailMessage.ParentId) == 'SEG')) {
				newList.add(emailMessage);
			}
		}
		return newList;
	}   

    public static void setAcuseReciboEmail (List<EmailMessage> listNewObj){
        system.debug('Email message setacusereciboEmail: '+listNewObj);
		List<EmailMessage> mensajesActualizar = new List<EmailMessage>();
        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		Id recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        Set<Id> setRTSeg = new Set<Id>();
        setRTSeg.add(recordTypeSEG);
        setRTSeg.add(recordTypeSeguimiento);
        Set<Id> idsPadre = new Set<Id>();
        for (EmailMessage correo : listNewObj) {
            if (String.isNotBlank(correo.ParentId)) {
                idsPadre.add(correo.ParentId);
            } else if (String.isNotBlank(correo.RelatedToId)) {
                idsPadre.add(correo.RelatedToId);
            }
        }

		List<Case> casos = [SELECT id, CC_AcuseRecibo__c ,CreatedDate FROM Case WHERE CC_AcuseRecibo__c  = '0' AND Id IN :idsPadre AND RecordTypeId IN :setRTSeg];
        for (EmailMessage mensaje : listNewObj) {
            if (!casos.isEmpty()) {
                if (mensaje.ParentId == casos[0].id && mensaje.incoming == false) {
                    mensajesActualizar.add(new EmailMessage(id = mensaje.Id,SEG_BotonPulsado__c= 'Acuse') );
                }
            }
        }
        
        update mensajesActualizar;
    }
}