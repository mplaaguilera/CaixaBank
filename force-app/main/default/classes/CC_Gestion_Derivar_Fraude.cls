public with sharing class CC_Gestion_Derivar_Fraude {

    @AuraEnabled
    public static Map<String, Object> crearCasoFraude(String recordId) {
        Map<String, Object> retorno = new Map<String, Object>();

        List<CC_Lista_Valores__c> textos = [SELECT Name, CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Textos operativa Derivar'];
        Map<String, String> textosMap = new Map<String, String>();
        for (CC_Lista_Valores__c texto : textos) {
            textosMap.put(texto.Name, texto.CC_Mensajes_Mostrar__c);
        }

        //Comprobamos si ya existe una task de fraude en el caso, en caso afirmativo significa que ya ha sido derivado y no puede volver a derivarse
        List<Task> tareaFraude = [SELECT Id, Subject FROM Task WHERE WhatId = :recordId AND Type = 'Fraude' LIMIT 1];

        if(tareaFraude.isEmpty()){ //El caso no ha sido derivado previamente, continua la ejecución

            Id rtCasoCC = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtCasoFraude = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
            
            List<Case> listaCasos = [SELECT Id, OwnerId, ContactId, Contact.AccountId, Subject, Description, CC_Idioma__c, CC_Tipo_Contacto__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, AccountId, Comments, CC_ContactoRelacionado__c, CC_Oficina__c, CC_MCC_Tematica__r.Name, CC_MCC_Motivo__c
                                     FROM Case WHERE RecordTypeId = :rtCasoCC AND Id = :recordId LIMIT 1];

            if(!listaCasos.isEmpty()){
                Case casoActual = listaCasos[0];

                //Creación del nuevo caso de fraude
                Case casoParaFraude = new Case();
                casoParaFraude.Subject = casoActual.Subject;
                casoParaFraude.Description = casoActual.Description;
                casoParaFraude.CC_Idioma__c = casoActual.CC_Idioma__c;
                casoParaFraude.CC_Tipo_Contacto__c = casoActual.CC_Tipo_Contacto__c;
                casoParaFraude.CC_Canal_Contacto__c = 'FRA_Call Center';
                casoParaFraude.Origin = 'CC';
                casoParaFraude.CC_Detalles_Consulta__c = casoActual.CC_Detalles_Consulta__c;
                casoParaFraude.CC_Detalles_Solucion__c = casoActual.CC_Detalles_Solucion__c;
                casoParaFraude.CC_Oficina__c = casoActual.CC_Oficina__c;
                casoParaFraude.Comments = casoActual.Comments;
                casoParaFraude.AccountId = casoActual.AccountId;
                casoParaFraude.ContactId = casoActual.ContactId;
                casoParaFraude.CC_CasoRelacionado__c = casoActual.Id;
                casoParaFraude.RecordTypeId = rtCasoFraude;

                if(casoActual.CC_ContactoRelacionado__c != null){
                    casoParaFraude.CC_ContactoRelacionado__c = casoActual.CC_ContactoRelacionado__c;
                }
                if(casoActual.CC_Oficina__c != null){
                    casoParaFraude.CC_Oficina__c = casoActual.CC_Oficina__c;
                }

                //Dependiendo de la temática del caso CC, ciertos campos del caso de Fraude se tienen que informar con diferente información
                if(casoActual.CC_MCC_Tematica__r.Name == 'Tarjetas'){ //Todos los casos cuya temática sea igual a Tarjetas se deben configurar con la parametrización de tarjetas.
                    casoParaFraude.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Tarjetas Payments';
                    casoParaFraude.CC_Canal_Resolucion__c = 'Buzón FRAUDE Tarjetas';  
                }else{ //El resto de casos equivaldrán a la parametrización de NOW.
                    casoParaFraude.CC_Canal_Procedencia__c = 'Teléfono FRAUDE CaixaBankNow';
                    casoParaFraude.CC_Canal_Resolucion__c = 'Buzón FRAUDE Now'; 
                }

                //Para asignar los niveles de MCC de temática, producto y motivo, nos basamos en la tabla de equivalencias del objeto CC_Lista_Valores__c
                if(casoActual.CC_MCC_Motivo__c != null){
                    Id rtTablaEquivlaneciasccfraude = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'FRA_TablaEquivalenciasDerivacion_CC_FRAUDE');
                    List<CC_Lista_Valores__c> tablaEquivalencias = [SELECT Id, FRA_MotivoDestino__c, FRA_MotivoDestino__r.CC_Producto_Servicio__c, FRA_MotivoDestino__r.CC_Producto_Servicio__r.CC_Tematica__c FROM CC_Lista_Valores__c WHERE RecordTypeId = :rtTablaEquivlaneciasccfraude AND CC_Activa__c = true AND FRA_MotivoOrigen__c = :casoActual.CC_MCC_Motivo__c AND FRA_MotivoDestino__c != null LIMIT 1];

                    if(!tablaEquivalencias.isEmpty()){
                        casoParaFraude.CC_MCC_Tematica__c = tablaEquivalencias[0].FRA_MotivoDestino__r.CC_Producto_Servicio__r.CC_Tematica__c;
                        casoParaFraude.CC_MCC_ProdServ__c = tablaEquivalencias[0].FRA_MotivoDestino__r.CC_Producto_Servicio__c;
                        casoParaFraude.CC_MCC_Motivo__c = tablaEquivalencias[0].FRA_MotivoDestino__c;
                    }
                }
                
                //Insertar el caso de fraude
                insert casoParaFraude;

                //Actualizar el caso de cc
                casoActual.CC_CasoRelacionado__c = casoParaFraude.Id;
                // casoActual.Status = 'Cerrado';
                // casoActual.CC_CierreAutomaticoCSBD__c = true;
                update casoActual;

                if(casoActual.CC_MCC_Tematica__r.Name == 'Tarjetas'){ //Todos los casos cuya temática sea igual a Tarjetas se deben configurar con la parametrización de tarjetas. 
                    List<Group> colaTarjetas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'FRA_BuzonFraudeTarjetas' LIMIT 1];
                    casoParaFraude.OwnerId = colaTarjetas[0].Id;

                }else{ //El resto de casos equivaldrán a la parametrización de NOW.
                    List<Group> colaNow = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'FRA_BuzonFraudeNow' LIMIT 1]; 
                    casoParaFraude.OwnerId = colaNow[0].Id; 
                }
                update casoParaFraude;

                //Crear la task asociada al caso de CC
                CC_Activity.crearActividadFraude(recordId, casoActual); 

                String comentarioDerivadoExito = (String) textosMap.get('Caso derivado a fraude');
                retorno.put('comentarioDerivadoExito', comentarioDerivadoExito);
                retorno.put('casoYaDerivado', false);
            }
        }else{ //El caso ha sido derivado previamente, muestra mensaje al usuario
            String comentarioCasoYaDerivado = (String) textosMap.get('Mensaje caso ya derivado fraude');
            retorno.put('comentarioCasoYaDerivado', comentarioCasoYaDerivado);
            retorno.put('casoYaDerivado', true);
        }
          
        return retorno;
    }

    public static void reabrirCasoFraude(Map<String, String> respuesta) {
        List<Case> casosAbrir =  new List<Case>();
        List<Task> tareasUpdate =  new List<Task>();

        String casoIdString = (String)respuesta.get('casoId');
        String motivo = (String)respuesta.get('motivo');

        if(casoIdString != null && casoIdString != ''){
            List<Case> casoTarea = [SELECT Id,CC_Resolucion__c, Status FROM Case Where Id = :casoIdString LIMIT 1];
            Task tareaRechazo = new Task(
                WhatId = casoIdString,
                Description = 'El caso fue rechazado por Fraude. Motivo: ' + motivo,
                Status = 'Completed',
                Type = 'Caso Rechazado en Fraude',
                Subject = 'Caso Rechazado en Fraude'
            );
            casoTarea[0].Status = 'Activo';
            casoTarea[0].CC_Resolucion__c = motivo;

            insert tareaRechazo;
            update casoTarea;
        }
        // for(Case casoTarea : [
        //     SELECT Id, 
        //         CC_Resolucion__c,
        //         Status,
        //         (
        //             SELECT OwnerId, Description, Status
        //             FROM Tasks                    
        //             WHERE Subject = 'Creación caso a Fraude' 
        //             AND Type = 'Fraude'
        //             ORDER BY CreatedDate DESC
        //             LIMIT 1
        //         )
        //     FROM Case 
        //     WHERE Id = :casoIdString
        // ]){
        //     if(casoTarea.Tasks.size()> 0){  
        //         Task tareaActualizar = casoTarea.Tasks[0];
        //         tareaActualizar.Description = 'El caso fue rechazado por Fraude. Motivo: ' + motivo;
        //         tareaActualizar.Status = 'Rechazada';   
        //         tareasUpdate.add(tareaActualizar); 
        //         //actualizar caso
        //         casoTarea.Status = 'Activo';
        //         casoTarea.CC_Resolucion__c = motivo;
        //         casosAbrir.add(casoTarea);
        //     }     
        // }     
      
        // if(casosAbrir.size() > 0 && tareasUpdate.size() > 0){
        //     update casosAbrir;
        //     update tareasUpdate;
        // }   
    }

    //llamado desde el Oficina Operativa Controller
    public static void reabrirCasoFraude(List<CC_DevolverCaso__e> reabrirEvents) {
        Map<String, String> resultado = new Map<String, String>();
        for(CC_DevolverCaso__e reabrirEvent : reabrirEvents){
            if(String.isNotBlank(reabrirEvent.CC_CasoId__c)) {
                resultado.put('casoId', reabrirEvent.CC_CasoId__c);    
                resultado.put('motivo', reabrirEvent.CC_resolucion3N__c);              
            }
        }
        if(resultado.size() > 0){
            reabrirCasoFraude(resultado);
        }
    }

    public static void devolverCasoCC(Map<String, Object> respuesta) {     
        String casoIdString = (String)respuesta.get('casoId');
        String motivo = (String)respuesta.get('motivo');
        if(!String.isEmpty(casoIdString)) {
            //Publicar el platform event para que la transacción salga por el usuario integración
            CC_DevolverCaso__e devolverCasoEvent = new CC_DevolverCaso__e();
            devolverCasoEvent.CC_CasoId__c = casoIdString; 
            devolverCasoEvent.CC_Origen__c = 'Fraude';
            devolverCasoEvent.CC_resolucion3N__c = motivo;
            Database.SaveResult sr = EventBus.publish(devolverCasoEvent);  
        } else {
            CC_CustomException.throwAuraException('Error en el proceso de devolución, no se recibió ningún id de caso');
        }
    }
}