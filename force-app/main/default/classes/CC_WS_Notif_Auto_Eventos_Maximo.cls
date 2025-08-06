public class CC_WS_Notif_Auto_Eventos_Maximo {
    /*
    *  Creación Actualización de Volumen
    */
   public static Set<ID> crearActVolumen(List<CC_Agrupador__c> ListAgrupID) {
       Set<ID> oInputActVol = new Set<ID>();
       Map<String, Integer> returnVolumenes = new Map<String, Integer>();
       List<CC_Notificacion_Volumen__c> ListnotifVolumenUpd = new List<CC_Notificacion_Volumen__c>();
       List<CC_Agrupador__c> ListIncUpd = new List<CC_Agrupador__c>();

       try{        
           // Actualizamos el agrupador informado que es un evento
           for (CC_Agrupador__c inc : ListAgrupID){
               CC_Agrupador__c incidencia = new CC_Agrupador__c();
               incidencia.Id = inc.Id;
               incidencia.CC_Evento__c = true;
               incidencia.CC_Notificacion_Evento_Automatico__c = true;
               ListIncUpd.add(incidencia);
               
               // Creamos CC_Notificacion_Volumen__c
               Integer llamadasAtendidas;
               Integer llamadasAtendidasParcial;
               Integer llamadasAbandonadasAnterior;
               returnVolumenes = CC_Notificacion_Volumen_Crear_Controller.inicializarVolumenes(inc.Id);
               for(String  llamada : returnVolumenes.keySet()) { 
                   if(llamada == 'llamadasAtendidas'){
                       llamadasAtendidas = returnVolumenes.get(llamada);
                   }else if(llamada == 'llamadasAtendidasParcial'){
                       llamadasAtendidasParcial = returnVolumenes.get(llamada);
                   } else if(llamada == 'llamadasAbandonadasAnterior'){
                       llamadasAbandonadasAnterior = returnVolumenes.get(llamada);
                   }
               }
               CC_Notificacion_Volumen__c notifVolumen = new CC_Notificacion_Volumen__c();
               notifVolumen.CC_Agrupador_Id__c = inc.Id;
               notifVolumen.CC_Contenido__c = inc.CC_Descripcion__c;
               notifVolumen.CC_Mensaje__c = inc.CC_Titulo__c;
               notifVolumen.CC_Tipo__c = 'Notificación';
               notifVolumen.CC_Estado__c = 'Envío pendiente';
               notifVolumen.CC_Llamadas_Atendidas__c = llamadasAtendidas;
               notifVolumen.CC_Llamadas_Atendidas_Parcial__c = llamadasAtendidasParcial;
               notifVolumen.CC_Llamadas_Abandonadas__c = 0;
               notifVolumen.CC_Llamadas_Abandonadas_Parcial__c = llamadasAbandonadasAnterior;
               ListnotifVolumenUpd.add(notifVolumen);
           }
           
           if(!ListIncUpd.isEmpty()){
               Database.SaveResult[] oResUp = Database.update(ListIncUpd, false);
           }
           if(!ListnotifVolumenUpd.isEmpty()){
               Database.SaveResult[] oResNotVolumen = Database.insert(ListnotifVolumenUpd, false);
               // Creamo Set con los id de la actualizacion de volumen que se han insertado
               for (Database.SaveResult ActVolumen : oResNotVolumen) {
                   if (ActVolumen.isSuccess()) {
                       // Operation was successful, so get the ID of the record that was processed
                       oInputActVol.add(ActVolumen.getId());
                   }
               }
           }
       } catch(Exception e) {
           //result = 'KO';
           CBK_Log.error('Error en crearActVolumen ' + e.getMessage());
       }
       return oInputActVol;
   }
   /*
    *  Envío de la notificación automática del evento a MAXIMO
    */
   @InvocableMethod(label='Notificacion Automatica Evento' description='Notificación Automática Evento')
   static public void crearActualizarEventoMaximoAutomatico (List<Id> ListNotifEveID) {
       Set<ID> oInputActVol = new Set<ID>();
       Map<String, String> oData = new Map<String, String>();
       String LOV = 'Configuración Notificaciones Automáticas Eventos';
       String ValName = 'Activar/Desactivar';
       String Envio = '';
       // Recuperamos el valor del parámetro existente en la LOV
       oData = CC_MetodosUtiles.getLOVSimpleMethod(LOV, ValName);
       if (!oData.isEmpty()){
           for (String key : oData.keySet()){
               Envio = oData.get(key);
           }
       }
       
       List<CC_Agrupador__c> ListAgrupadores = [SELECT Id, CC_Evento__c, CC_Descripcion__c, CC_Titulo__c, CC_Numero_Casos__c, CC_Notificacion_Evento_Automatico__c, CC_Id_Maximo__c FROM CC_Agrupador__c WHERE Id IN :ListNotifEveID];
       Set<Id> lstAgrupadores = new Set<Id>();
       Set<Id> lstAgrupadores2 = new Set<Id>();
       List<CC_Agrupador__c> ListAgrupadoresAux = new List<CC_Agrupador__c>();
       // Controlamos que este activo el parámetro para realizar el envío automático de Actualización de Volumen a MAXIMO
       if (Envio == 'Y') {
           // Recuperamos el umbral de casos para la actualización de volumen
           Decimal umbralCasosActualizacionVolumen = [SELECT Valor_Numerico_Entero__c FROM CC_Parametros__mdt WHERE DeveloperName = 'CC_Actualizacion_Automatica_Volumen' LIMIT 1].Valor_Numerico_Entero__c;
           // Sólo se realizará la actualización de volumen si el Agrupador tiene asociados X o más casos del día en curso y ninguno de otros días
           for (CC_Agrupador__c agrupador : ListAgrupadores) {
            lstAgrupadores.add(agrupador.Id);
           }

           Integer numeroCasosDeHoy = [SELECT count() FROM Case WHERE CC_Agrupador_Id__c IN :lstAgrupadores and CreatedDate = TODAY];

           for (CC_Agrupador__c agrupador : ListAgrupadores) {
               if (numeroCasosDeHoy >= umbralCasosActualizacionVolumen) {
                 
                lstAgrupadores2.add(agrupador.Id);
               }
           }
           
           Integer numeroCasosTotal = [SELECT count() FROM Case WHERE CC_Agrupador_Id__c IN :lstAgrupadores2];
           for (CC_Agrupador__c agrupador : ListAgrupadores) {
               if (numeroCasosDeHoy == numeroCasosTotal) {
                //Nota Kevin: El for: ListAgrupadores anterior se agregaba a si mismo el agrupador
                //ListAgrupadores.add(agrupador);
                //Se a creado una lista auxiliar para agregar los agrupadores en otro For

                        ListAgrupadoresAux.add(agrupador);
               }
           }

           //Nuevo For implementado para añadir los agrupadores restantes
           for (CC_Agrupador__c agrupador : ListAgrupadoresAux) {
            ListAgrupadores.add(agrupador);
           }
           // Creamos la actualización de volumen y actualizamos el agrupador
           oInputActVol = crearActVolumen(ListAgrupadores);
           
           //Creación Evento Automático
           //Set<ID> oID = new Set<ID>(ListNotifEveID);

           //Esta llamada se está haciendo desde un batch. Comprobar desde dónde se triggerea de forma asíncrona
           //El cambio del campo "CC_Numero_Casos__c del objeto agrupador.
           //if(!System.isBatch() && !System.isScheduled())
           if (!System.isFuture() && !System.isBatch()){
                     CC_WS_Methods_Maximo.crearActualizarEventoMaximoFuture(oInputActVol);
           }
           
       }
   }
}