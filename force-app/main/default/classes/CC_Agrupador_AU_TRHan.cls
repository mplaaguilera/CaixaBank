public  with sharing class CC_Agrupador_AU_TRHan extends CC_TriggerHandlerBase { 

    private static final Id COMINFORMATIVART = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
    private static final Id COMINFORMATIVACAMPANART = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
    private static final Id COMINFORMATIVAMARCART = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Marca').getRecordTypeId();
    private static final Id INCIDENCIART = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
    private static final Id MASIVACONTROLRT = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Masiva_Control').getRecordTypeId();
    private static final Id SEGUIMIENTORT = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Seguimiento').getRecordTypeId();


    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Agrupador__c>)tp.newList, (Map<Id, CC_Agrupador__c>)tp.oldMap);
    }

    private void process(List<CC_Agrupador__c> listNewObj, Map<Id, CC_Agrupador__c> mapOldObj) {

        List<CC_Agrupador__c> listNotificarAgrupador = new List<CC_Agrupador__c>();
        List<CC_Agrupador__c> listNotificarAutoEventoAgrupador = new List<CC_Agrupador__c>();
        List<CC_Agrupador__c> listAgrupadoresActualizar = new List<CC_Agrupador__c>();
        List<Id> idsRechazadoAgrupador = new List<Id>();
        List<Id> idsCierreAutomCasos = new List<Id>();

        //Obtenemos el valor de la configuracion de la notificacion de evento automatico
        List<CC_Parametros__mdt> configuracionAgrupador = [SELECT Valor_Numerico_Entero__c FROM CC_Parametros__mdt WHERE DeveloperName = 'CC_Actualizacion_Automatica_Volumen' LIMIT 1];
        Decimal valorConfiguracion = 0;
        if(!configuracionAgrupador.isEmpty()) {
            valorConfiguracion = configuracionAgrupador[0].Valor_Numerico_Entero__c;
        }

        for(CC_Agrupador__c agrupador : listNewObj) {
            /*
            RT = CC_Incidencia
            CC_Publica__c = false -> true
            */
            if(agrupador.RecordTypeId == INCIDENCIART && agrupador.CC_Publica__c == true && mapOldObj.get(agrupador.Id).CC_Publica__c == false){  
                listNotificarAgrupador.add(agrupador);
            }

            /*
            RT != CC_Comunicacion_Informativa && RT != CC_Comunicacion_Informativa_de_Campana
            CC_Estado__c = !(Cerrado) -> Cerrado
            */
            if(agrupador.RecordTypeId != COMINFORMATIVART && agrupador.RecordTypeId != COMINFORMATIVACAMPANART && agrupador.CC_Estado__c == 'Cerrado' && mapOldObj.get(agrupador.Id).CC_Estado__c != 'Cerrado'){ 
                idsCierreAutomCasos.add(agrupador.Id);
            }

            /*
            RT = CC_Incidencia
            CC_Notificacion_Evento_Automatico__c = false -> true
            CC_Id_Maximo__c != null
            CC_No_Enviar_Evento__c = false
            CC_Numero_Casos__c >= valorConfiguracion
            CC_Numero_Casos__c != (OLD) CC_Numero_Casos__c
            */
            if(agrupador.RecordTypeId == INCIDENCIART && !agrupador.CC_Notificacion_Evento_Automatico__c && agrupador.CC_Id_Maximo__c != null && !agrupador.CC_No_Enviar_Evento__c && agrupador.CC_Numero_Casos__c >= valorConfiguracion && mapOldObj.get(agrupador.Id).CC_Numero_Casos__c != agrupador.CC_Numero_Casos__c){
                listNotificarAutoEventoAgrupador.add(agrupador);
            }

            /*
            RT = CC_Incidencia
            CC_Estado__c = !(Rechazado) -> Rechazado
            */
            if(agrupador.RecordTypeId == INCIDENCIART && agrupador.CC_Estado__c == 'Rechazado' && mapOldObj.get(agrupador.Id).CC_Estado__c != 'Rechazado'){ //SOLO SI CAMBIA A RECHAZADO
                idsRechazadoAgrupador.add(agrupador.Id);
            }

            /*
            CC_Numero_Casos__c > (OLD) CC_Numero_Casos__c
            */
            if (agrupador.CC_Numero_Casos__c  > mapOldObj.get(agrupador.Id).CC_Numero_Casos__c ) {
                listAgrupadoresActualizar.add(agrupador);
            }
        }

        if(!listNotificarAgrupador.isEmpty()){
            notificarAgrupador(listNotificarAgrupador);
        }

        if(!idsCierreAutomCasos.isEmpty()){
            CC_Agrupador.cierreAgrupador(idsCierreAutomCasos);
        }

        if(!listNotificarAutoEventoAgrupador.isEmpty()){
            notificarAutomaticaEvento(listNotificarAutoEventoAgrupador);
        }

        if(!idsRechazadoAgrupador.isEmpty()){
            CC_Agrupador_Rechazado.agrupadorRechazado(idsRechazadoAgrupador);
        }

        if(!listAgrupadoresActualizar.isEmpty()){
            agrupadorAviso(listAgrupadoresActualizar, mapOldObj);
        }
    }

    private void notificarAgrupador(List<CC_Agrupador__c> listAgrupadores) {

        List<CC_Notificacion.AgrupadorMensajeInfo> listAgrupadoresNotificar = new List<CC_Notificacion.AgrupadorMensajeInfo>();
        List<CC_Agrupador__c> listAgrupadoresActualizar = new List<CC_Agrupador__c>();
        

        for(CC_Agrupador__c agrupador : listAgrupadores){
            //Generamos la notificacion
            CC_Notificacion.AgrupadorMensajeInfo notificacion = new CC_Notificacion.AgrupadorMensajeInfo();
            notificacion.idAgrupador = agrupador.Id;
            notificacion.mensaje = 'Se ha generado una nueva incidencia pública: ' + agrupador.Name + ' - ' + agrupador.CC_Titulo__c;
            listAgrupadoresNotificar.add(notificacion);
        }
        if(!listAgrupadoresNotificar.isEmpty()){
            //Notificar a los usuarios de que se ha publicado un agrupador
            CC_Notificacion.publicarToastAviso(listAgrupadoresNotificar);
        }
    }

    private void notificarAutomaticaEvento(List<CC_Agrupador__c> listAgrupadores) {

        List<Id> idsProcesarAgrupador = new List<Id>();
        Decimal umbralCasosActualizacionVolumen = [SELECT Valor_Numerico_Entero__c FROM CC_Parametros__mdt WHERE DeveloperName = 'CC_Actualizacion_Automatica_Volumen' LIMIT 1].Valor_Numerico_Entero__c;

        for(CC_Agrupador__c agrupador : listAgrupadores){
            if(agrupador.CC_Numero_Casos__c  >= umbralCasosActualizacionVolumen){
                idsProcesarAgrupador.add(agrupador.Id);
            }
        }

        if(!idsProcesarAgrupador.isEmpty()){
            CC_WS_Notif_Auto_Eventos_Maximo.crearActualizarEventoMaximoAutomatico(idsProcesarAgrupador);
        }
    }
   
    private void agrupadorAviso(List<CC_Agrupador__c> listAgrupadoresActualizar, Map<Id, CC_Agrupador__c> mapAgrupadoresAntiguos) {
        Set<String> destinatarios = new Set<String>();

        Id recordTypeAgrupador = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        Id recordTypeAgrupadorMasivaControl = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Masiva_Control').getRecordTypeId();
        Id recordTypeAgrupadorSeguimiento = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Seguimiento').getRecordTypeId();
        
        //Invocamos al método de agrupadorAviso
        String tipoNoficicacion = [SELECT Id from CustomNotificationType WHERE DeveloperName = 'CC_Cierre_Maximo' LIMIT 1].Id;
        //Llamar al metodo de aviso de agrupador
        CC_Aviso_Agrupador.publicarEventoDeAviso(listAgrupadoresActualizar);
        for (CC_Agrupador__c agrupador : listAgrupadoresActualizar) {
            if(agrupador.CC_Estado__c == 'Pendiente Revision' && mapAgrupadoresAntiguos.get(agrupador.Id).CC_Estado__c != 'Pendiente Revision'){
                //Generar el aviso
                if(agrupador.RecordTypeId == recordTypeAgrupador || agrupador.RecordTypeId == recordTypeAgrupadorMasivaControl || agrupador.RecordTypeId == recordTypeAgrupadorSeguimiento){
                    String tituloNotificacion = 'El agrupador ' + agrupador.Name + ' está Pendiente revisión solución';
                    String textoNotificacion = 'La solución del Maximo es:  ' + agrupador.CC_Detalle_solucion__c ;
                    destinatarios.add(agrupador.OwnerId);
                    //mandar notificacion
                    Boolean haFallado = CC_Notificacion_Metodos.enviarNotificacion(destinatarios, agrupador.Id, tituloNotificacion, tipoNoficicacion, textoNotificacion);
 
                    destinatarios.clear();
                }
            }
        }
    }
}