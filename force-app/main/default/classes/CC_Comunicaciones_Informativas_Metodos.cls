public with sharing class CC_Comunicaciones_Informativas_Metodos {

    public static void llamadaQueueableAsociarCasosAComunicacionInformativa(Set<Id> idsComunicacionInformativa) {
        actualizarEstadisticasComunicacionInformativaQueueable actualizarEstadisticas = new actualizarEstadisticasComunicacionInformativaQueueable();
        Set<Id> idsComInformativa = idsComunicacionInformativa;
		actualizarEstadisticas.setParams(idsComInformativa);
		System.enqueueJob(actualizarEstadisticas);
    }

    public class actualizarEstadisticasComunicacionInformativaQueueable implements Queueable {

		private Set<Id> idsComunicacionInformativa;
		
		public void setParams(Set<Id> idsComunicacionInformativa) {
			this.idsComunicacionInformativa = idsComunicacionInformativa;
		}

		public void execute(QueueableContext context) {
        	actualizarEstadisticasComunicacionInformativa(idsComunicacionInformativa);
    	}
	}
    
    public static void actualizarEstadisticasComunicacionInformativa(Set<Id> idsComunicacionInformativa) {
        List<CC_Agrupador__c> comunicacionesInformativas = new List<CC_Agrupador__c>();
        Map<Id, List<Case>> mapComunicacionCasos = new Map<Id, List<Case>>();
        List<Case> casosComunicaciones = [SELECT Id, CC_Comunicacion_Informativa__c, Origin, CreatedDate FROM Case WHERE CC_Comunicacion_Informativa__c IN :idsComunicacionInformativa WITH SECURITY_ENFORCED];
        
        for (Case casoComunicacion : casosComunicaciones) {
            if(mapComunicacionCasos.containsKey(casoComunicacion.CC_Comunicacion_Informativa__c)){
                List<Case> lstCasosAgrupados = mapComunicacionCasos.get(casoComunicacion.CC_Comunicacion_Informativa__c);
                lstCasosAgrupados.add(casoComunicacion);
                mapComunicacionCasos.put(casoComunicacion.CC_Comunicacion_Informativa__c,lstCasosAgrupados);
            } else {
                mapComunicacionCasos.put(casoComunicacion.CC_Comunicacion_Informativa__c, new List<Case> {casoComunicacion});
            }
        }
        
        for (Id idComunicacionInformativa : idsComunicacionInformativa) {
            Integer numChat = 0;
            Integer numComentarios = 0;
            Integer numEmail = 0;
            Integer numPhone = 0;
            Integer numTwitter = 0;
            Integer numFax = 0;
            Integer numFormulario = 0;
            Integer numCarta = 0;
            Datetime fechaPrimerCaso;

            CC_Agrupador__c comunicacionInformativa = new CC_Agrupador__c(Id = idComunicacionInformativa);
            if(mapComunicacionCasos.containsKey(idComunicacionInformativa)){
                comunicacionInformativa.CC_Numero_Casos__c = mapComunicacionCasos.get(idComunicacionInformativa).size();
                fechaPrimerCaso = mapComunicacionCasos.get(idComunicacionInformativa)[0].CreatedDate;
                for (Case casoLista : mapComunicacionCasos.get(idComunicacionInformativa)) {
                    if(casoLista.CreatedDate > fechaPrimerCaso){
                        fechaPrimerCaso = casoLista.CreatedDate;
                    }
                    switch on casoLista.Origin {
                        when 'Chat' { numChat++; }
                        when 'Comentarios Stores'{ numComentarios++; }
                        when 'Email'{ numEmail++; }
                        when 'Phone'{ numPhone++; }
                        when 'Twitter'{ numTwitter++; }
                        when 'Fax'{ numFax++; }
                        when 'Formulario TF'{ numFormulario++; }
                        when 'Carta'{ numCarta++; }
                    }
                }
            }
            
            comunicacionInformativa.CC_Numero_Casos_Chat__c = numChat;
            comunicacionInformativa.CC_Numero_Casos_Apps__c = numComentarios;
            comunicacionInformativa.CC_Numero_Casos_Email__c = numEmail;
            comunicacionInformativa.CC_Numero_Casos_Telefono__c = numPhone;
            comunicacionInformativa.CC_Numero_Casos_Twitter__c = numTwitter;
            comunicacionInformativa.CC_Numero_Casos_Fax__c = numFax;
            comunicacionInformativa.CC_Numero_Casos_FormularioTF__c = numFormulario;
            comunicacionInformativa.CC_Numero_Casos_Carta__c = numCarta;
            if(fechaPrimerCaso != null){
                comunicacionInformativa.CC_Fecha_Deteccion__c = fechaPrimerCaso;
            }
            comunicacionesInformativas.add(comunicacionInformativa);
        }
        if(Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Chat__c.isUpdateable() &&
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Apps__c.isUpdateable() && 
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Email__c.isUpdateable() && 
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Telefono__c.isUpdateable() && 
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Twitter__c.isUpdateable() && 
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Fax__c.isUpdateable() &&
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_FormularioTF__c.isUpdateable() &&
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Carta__c.isUpdateable()){
            System.debug('comunicacionesInformativas: ' + comunicacionesInformativas);
            update comunicacionesInformativas;
        }
    }

    public static void actualizarEstadisticasComunicacionInformativaCampana(Set<Id> idsComunicacionInformativaCampana) {
        Map<Id, List<Case>> mapComunicacionCasos = new Map<Id, List<Case>>();
        List<CC_Agrupador__c> comunicacionesInformativasCampana = new List<CC_Agrupador__c>();
        List<Case> casosComunicaciones = [SELECT Id, CC_Comunicacion_Informativa_Campana__c, Origin, CreatedDate FROM Case WHERE CC_Comunicacion_Informativa_Campana__c IN :idsComunicacionInformativaCampana WITH SECURITY_ENFORCED];
        
        for (Case casoComunicacion : casosComunicaciones) {
            if(mapComunicacionCasos.containsKey(casoComunicacion.CC_Comunicacion_Informativa_Campana__c)){
                List<Case> lstCasosAgrupados = mapComunicacionCasos.get(casoComunicacion.CC_Comunicacion_Informativa_Campana__c);
                lstCasosAgrupados.add(casoComunicacion);
                mapComunicacionCasos.put(casoComunicacion.CC_Comunicacion_Informativa_Campana__c,lstCasosAgrupados);
            } else {
                mapComunicacionCasos.put(casoComunicacion.CC_Comunicacion_Informativa_Campana__c, new List<Case> {casoComunicacion});
            }
        }
        
        for (Id idComunicacionInformativaCampana : idsComunicacionInformativaCampana) {
            Integer numChat = 0;
            Integer numComentarios = 0;
            Integer numEmail = 0;
            Integer numPhone = 0;
            Integer numTwitter = 0;
            Integer numFax = 0;
            Integer numFormulario = 0;
            Integer numCarta = 0;
            Datetime fechaPrimerCaso;

            CC_Agrupador__c comunicacionInformativaCampana = new CC_Agrupador__c(Id = idComunicacionInformativaCampana);
            if(mapComunicacionCasos.containsKey(idComunicacionInformativaCampana)){
                comunicacionInformativaCampana.CC_Numero_Casos__c = mapComunicacionCasos.get(idComunicacionInformativaCampana).size();
                fechaPrimerCaso = mapComunicacionCasos.get(idComunicacionInformativaCampana)[0].CreatedDate;
                for (Case casoLista : mapComunicacionCasos.get(idComunicacionInformativaCampana)) {
                    if(casoLista.CreatedDate > fechaPrimerCaso){
                        fechaPrimerCaso = casoLista.CreatedDate;
                    }
                    switch on casoLista.Origin {
                        when 'Chat' { numChat++; }
                        when 'Comentarios Stores'{ numComentarios++; }
                        when 'Email'{ numEmail++; }
                        when 'Phone'{ numPhone++; }
                        when 'Twitter'{ numTwitter++; }
                        when 'Fax'{ numFax++; }
                        when 'Formulario TF'{ numFormulario++; }
                        when 'Carta'{ numCarta++; }
                    }
                }
            }

            comunicacionInformativaCampana.CC_Numero_Casos_Chat__c = numChat;
            comunicacionInformativaCampana.CC_Numero_Casos_Apps__c = numComentarios;
            comunicacionInformativaCampana.CC_Numero_Casos_Email__c = numEmail;
            comunicacionInformativaCampana.CC_Numero_Casos_Telefono__c = numPhone;
            comunicacionInformativaCampana.CC_Numero_Casos_Twitter__c = numTwitter;
            comunicacionInformativaCampana.CC_Numero_Casos_Fax__c = numFax;
            comunicacionInformativaCampana.CC_Numero_Casos_FormularioTF__c = numFormulario;
            comunicacionInformativaCampana.CC_Numero_Casos_Carta__c = numCarta;
            if(fechaPrimerCaso != null){
                comunicacionInformativaCampana.CC_Fecha_Deteccion__c = fechaPrimerCaso;
            }
            comunicacionesInformativasCampana.add(comunicacionInformativaCampana);
        }
        if(Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Chat__c.isUpdateable() &&
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Apps__c.isUpdateable() && 
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Email__c.isUpdateable() && 
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Telefono__c.isUpdateable() && 
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Twitter__c.isUpdateable() && 
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Fax__c.isUpdateable() &&
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_FormularioTF__c.isUpdateable() &&
        Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos_Carta__c.isUpdateable()){
            System.debug('comunicacionesInformativasCampana: ' + comunicacionesInformativasCampana);
            update comunicacionesInformativasCampana;
        }
        
    }
}