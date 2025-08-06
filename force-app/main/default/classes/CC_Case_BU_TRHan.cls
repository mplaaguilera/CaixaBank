public with sharing class CC_Case_BU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }
    
    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
        //Obtención de RT CC_ y OS_
        Schema.DescribeSObjectResult recordType = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = recordType.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        
        for (Schema.RecordTypeInfo rt: lstRT){
            if ((rt.getDeveloperName().left(3)=='CC_') || (rt.getDeveloperName().left(3)=='AM_')) {
                setIdsRt.add(rt.getRecordTypeId());
                // system.debug(rt.getRecordTypeId());
            }
        }
        
        List<Case> listNewObjCC = New List<Case>();
        Map<Id, Case> mapNewObjCC = New Map<Id, Case>();
        for (Case tk: listNewObj) {
            if(((setIdsRt).contains(tk.RecordTypeId)) || (tk.RecordTypeId == null)){
                if((mapOldObj.get(tk.Id).CC_Facturado__c != tk.CC_Facturado__c) && (mapOldObj.get(tk.Id).CC_Facturado__c == true && tk.CC_Facturado__c == false) ||
                (mapOldObj.get(tk.Id).CC_Facturado__c == tk.CC_Facturado__c)){                    
                    listNewObjCC.add(tk);
                    mapNewObjCC.put(tk.Id,tk);
                }
            }
        }
        
        List<Case> listOldObjCC= New List<Case>();
        Map<Id, Case> mapOldObjCC = New Map<Id, Case>();
        for (Case tk: listOldObj){
            if(((setIdsRt).contains(tk.RecordTypeId))||(tk.RecordTypeId == null)){
                if((mapNewObj.get(tk.Id).CC_Facturado__c != tk.CC_Facturado__c) && (mapNewObj.get(tk.Id).CC_Facturado__c == false && tk.CC_Facturado__c == true) ||
                (mapNewObj.get(tk.Id).CC_Facturado__c == tk.CC_Facturado__c)){
                    listOldObjCC.add(tk);
                    mapOldObjCC.put(tk.Id,tk);
                }
            }
        }

        if (!mapOldObjCC.isEmpty() && !listNewObjCC.isEmpty()) {

            List<Id> idsCAM = obtenerIdsCAM(listNewObjCC);
            enmascararPANs(mapOldObjCC, listNewObjCC); // Se enmascaran los PANs de tarjeta de crédito en caso de detectarse
            encryptPANs(mapOldObjCC, listNewObjCC); // Se encripta el campo PAN en hexadecimal
            actualizarEstadoAutenticacion(mapOldObjCC, listNewObjCC); // US1182102: Autenticación - Reseteo del estado de autenticación en reclasificaciones de MCC
            validarCierreCaso(mapOldObjCC, listNewObjCC,idsCAM);
            cierreCasos(mapOldObjCC, listNewObjCC,idsCAM);
            actualizarBuzonSalida(listNewObjCC, mapOldObjCC);
            agrupadoresInactivos(mapOldObjCC, listNewObjCC, idsCAM);
            actualizarEstadoReversionImaginBank(mapOldObjCC, listNewObjCC, idsCAM);
            asignacionTRZ(mapOldObjCC, listNewObjCC, idsCAM);
            horasSLATraslado(mapOldObjCC, listNewObjCC);
            cambioPendinteCliente(mapOldObjCC, listNewObjCC, idsCAM);
            cambioPendienteColaborador(mapOldObjCC, listNewObjCC, idsCAM);
            cambioPendienteIncidencia(mapOldObjCC, listNewObjCC, idsCAM);
            cambioPendienteInterno(mapOldObjCC, listNewObjCC, idsCAM);
            envioCorreoConsultasOperativasAsignarPropietario(mapOldObjCC, listNewObjCC, idsCAM);
            cambioPropietarioColaConsultasOperativas(mapOldObjCC, listNewObjCC, idsCAM);
            ComprobarCambioNivel(mapOldObjCC, listNewObjCC, idsCAM);
            calculoTiempoNiveles(mapOldObjCC, listNewObjCC, idsCAM);
            
            CC_CaseTriggerHelper.accionesBeforeUpdate(listNewObjCC, mapOldObjCC, idsCAM);
            cambioPendienteInterno(mapOldObjCC, listNewObjCC, idsCAM);
            horaSLAConsultasOperativasPausa(mapOldObjCC, listNewObjCC, idsCAM);
            horaSLAConsultasOperativasRenaudar(mapOldObjCC, listNewObjCC, idsCAM);
            
            
            //CAM Específico
            gestionEntitlementsCAM(mapOldObjCC, listNewObjCC, idsCAM);
            if (!Test.isRunningTest()) {
                vincularCasoOrigen(mapOldObjCC, listNewObjCC);
            }
            CC_CaseTriggerHelper.caseGestionado(listNewObjCC, mapOldObjCC, idsCAM);
            CC_CaseTriggerHelper.calcularFacturacion(listNewObjCC, mapOldObjCC, idsCAM);     
        }
    }

    // US1182102: Autenticación - Reseteo del estado de autenticación en reclasificaciones de MCC
    private void actualizarEstadoAutenticacion(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Set<Id> idsMotivos = new Set<Id>();
        for (Case caso : listNewObj) {
            if (caso.RecordTypeId == rtCliente && caso.CC_MCC_Motivo__c != mapOldObj.get(caso.Id).CC_MCC_Motivo__c) {
                idsMotivos.add(caso.CC_MCC_Motivo__c);
            }
        }
        if (!idsMotivos.isEmpty()) {
            Map<Id, CC_MCC__c> mapMotivos = new Map<Id, CC_MCC__c>([SELECT Id, CC_ImpedirNivel2__c FROM CC_MCC__c WHERE Id IN :idsMotivos]);
            for (Case caso : listNewObj) {
                Case casoAnterior = mapOldObj.get(caso.Id);
                if (caso.RecordTypeId == rtCliente && caso.CC_MCC_Motivo__c != casoAnterior.CC_MCC_Motivo__c) {
                    CC_MCC__c nuevoMotivo = mapMotivos.get(caso.CC_MCC_Motivo__c);
                    if (nuevoMotivo.CC_ImpedirNivel2__c && casoAnterior.CC_OTP_Nivel__c == 'Nivel 2' && casoAnterior.CC_Status_Autorizacion__c == 'APPROVED') {
                        caso.CC_Status_Autorizacion__c = 'SIN ESTADO';
                    }
                }
            }
        }
    }
    
    private void enmascararPANs(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        for (Case caso : listNewObj) {
            
            // Campo "Asunto"
            if (!String.isEmpty(caso.Subject) && caso.Subject != mapOldObj.get(caso.Id).Subject) {
                String sujeto = caso.Subject;
				caso.Subject = CC_CaseTriggerHelper.metodoMatcher(sujeto);
            }
            
            // Campo "Descripción"
            if (!String.isEmpty(caso.Description) && caso.Description != mapOldObj.get(caso.Id).Description) {
                String description = caso.Description;
				caso.Description = CC_CaseTriggerHelper.metodoMatcher(description);
            }
            
            // Campo "Detalle Consulta"
            if (!String.isEmpty(caso.CC_Detalles_Consulta__c) && caso.CC_Detalles_Consulta__c != mapOldObj.get(caso.Id).CC_Detalles_Consulta__c) {
                String detallesConsulta = caso.CC_Detalles_Consulta__c;
				caso.CC_Detalles_Consulta__c = CC_CaseTriggerHelper.metodoMatcher(detallesConsulta);
            }
            
            // Campo "Detalle Solución"
            if (!String.isEmpty(caso.CC_Detalles_Solucion__c) && caso.CC_Detalles_Solucion__c != mapOldObj.get(caso.Id).CC_Detalles_Solucion__c) {
                String detallesSolucion = caso.CC_Detalles_Solucion__c;
				caso.CC_Detalles_Solucion__c = CC_CaseTriggerHelper.metodoMatcher(detallesSolucion);
            }
        }
    }
    
    //Funcion para desencryptar el campo PAN, recibe el campo PAN encoded a b64 y crypted
    public static String decryptPANs(String b64coded) {
        List<CC_CryptoMetadata__mdt> cryptoValues = [SELECT CC_Key__c, CC_Vector__c FROM CC_CryptoMetadata__mdt LIMIT 1];
        Blob vector = null;
        Blob key = null;
        if(!cryptoValues.isEmpty()){
            vector = Blob.valueOf(cryptoValues[0].CC_Vector__c);
            key = EncodingUtil.base64decode(cryptoValues[0].CC_Key__c);
        }
        Blob b = EncodingUtil.base64decode(b64coded);
        Blob noCrypto = Crypto.decrypt('AES256', key, vector, b);
        
        return noCrypto.toString();
    }
    
    //Funcion para encryptar el campo PAN en AES256
    private void encryptPANs(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        List<CC_CryptoMetadata__mdt> cryptoValues = [SELECT CC_Key__c, CC_Vector__c FROM CC_CryptoMetadata__mdt LIMIT 1];
        Blob vector = null;
        Blob key = null;
        if (!cryptoValues.isEmpty()){
            vector = Blob.valueOf(cryptoValues[0].CC_Vector__c);
            key = EncodingUtil.base64decode(cryptoValues[0].CC_Key__c);
        }
        
        for (Case caso : listNewObj) {
            if (caso.CC_PAN__c != mapOldObj.get(caso.Id).CC_PAN__c && !caso.CC_PAN_Encriptado__c) {
                Blob data = Blob.valueOf(caso.CC_PAN__c);
                Blob encrypted = Crypto.encrypt('AES256', key, vector, data);
                String encryptedString = EncodingUtil.base64encode(encrypted);
                //System.debug('campo encriptado ' + encryptedString);
                caso.CC_PAN__c = encryptedString;
                /*ANTIGUA FORMA DE ENCRIPTAR:
                String encryptedPan = caso.CC_PAN__c.replaceAll('[^0-9]', '');
                caso.CC_PAN__c = CC_MetodosUtiles.decimalToHex(decimal.valueOf(encryptedPan));
                */
                caso.CC_PAN_Encriptado__c = true;
            }
            
            if (caso.CC_Digitos_Tarjeta__c != mapOldObj.get(caso.Id).CC_Digitos_Tarjeta__c && !caso.CC_DigitosTarjeta_Encriptado__c) {
                /*Blob vector = Blob.valueOf('1234567891234567');
                Blob key = Crypto.generateAesKey(128);
                Blob data = Blob.valueOf(caso.CC_Digitos_Tarjeta__c);
                Blob encrypted = Crypto.encrypt('AES128', key, vector, data);
                String encryptedString = EncodingUtil.base64encode(encrypted);
                */String encryptedPan = caso.CC_Digitos_Tarjeta__c.replaceAll('[^0-9]', '');
                caso.CC_Digitos_Tarjeta__c = CC_MetodosUtiles.decimalToHex(decimal.valueOf(encryptedPan));
                //caso.CC_Digitos_Tarjeta__c = encryptedString;
                caso.CC_DigitosTarjeta_Encriptado__c = true;
            }
        }
    }
    
    private void cambioPendinteCliente(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM){
        Id idRtCasoEmpleado =CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case','CC_Empleado');
        
        if(!mapOldObj.isEmpty() && !listNewObj.isEmpty()){
            for (Case caso : listNewObj){
               
                Datetime ahora = DateTime.now();
                if(!idsCAM.contains(caso.Id)){
                    if (mapOldObj.get(caso.Id).Status != 'Pendiente Cliente' && caso.Status == 'Pendiente Cliente' ){
                        caso.CC_Inicio_Pendiente_Cliente__c = DateTime.now();
                        
                        if(caso.RecordTypeId == idRtCasoEmpleado){
                        	if(caso.CC_En_Segundo_Nivel__c == true)
                        	{
                            	caso.CC_Tiempo_Nivel_2__c = ((caso.CC_Tiempo_Nivel_2__c==null)?0: caso.CC_Tiempo_Nivel_2__c) + ((ahora.getTime() - mapOldObj.get(caso.Id).CC_Fecha_Traslado_2N__c.getTime())/1000);
                        	}else if(caso.CC_En_Tercer_Nivel__c == true){
                            	caso.CC_Tiempo_Nivel_3__c = ((caso.CC_Tiempo_Nivel_3__c==null)?0: caso.CC_Tiempo_Nivel_3__c) + ((ahora.getTime() - mapOldObj.get(caso.Id).CC_Fecha_Traslado_3N__c.getTime())/1000);
                        	}else{
                                caso.CC_Tiempo_Nivel_1__c = ((caso.CC_Tiempo_Nivel_1__c==null)?0: caso.CC_Tiempo_Nivel_1__c) + ((ahora.getTime() - mapOldObj.get(caso.Id).CC_Fecha_Traslado_1N__c.getTime())/1000);
                        	}
                          }
                    }
                    else if (mapOldObj.get(caso.Id).Status == 'Pendiente Cliente' && (caso.Status == 'Activo' || caso.Status == 'Cerrado' ) && mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Cliente__c != null && mapOldObj.get(caso.Id).CC_Contador_Pendientes__c !=null){
                        caso.CC_Fin_Pendiente_Cliente__c = ahora;
                        //US932544 apartado 13. 
                        if(caso.RecordTypeId == idRtCasoEmpleado){
                        	caso.CC_Tiempo_Empleado__c = caso.CC_Tiempo_Empleado__c + (ahora.getTime() - mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Cliente__c.getTime())/1000;
                        
                        	if(caso.CC_En_Segundo_Nivel__c == true)
                        	{
                        	    caso.CC_Fecha_Traslado_2N__c = system.now();
                        	} else if(caso.CC_En_Tercer_Nivel__c == true){
                            	caso.CC_Fecha_Traslado_3N__c = system.now();
                        	} else if(caso.CC_En_Tercer_Nivel__c == false && caso.CC_En_Segundo_Nivel__c == false){
                            	caso.CC_Fecha_Traslado_1N__c = system.now();
                        	}
                        //
                        if(caso.CC_Fecha_Reapertura__c == null){
                            caso.CC_Contador_Pendientes__c = mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Cliente__c.getTime() != null ? mapOldObj.get(caso.Id).CC_Contador_Pendientes__c + (ahora.getTime() - mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Cliente__c.getTime()):mapOldObj.get(caso.Id).CC_Contador_Pendientes__c;
                            
                        }
                        
                    	}
                	}
            	}
        	}
    	}
    }
    
    
    private void cambioPendienteColaborador (Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM){
        Id idRtCasoEmpleado =CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case','CC_Empleado');
        Datetime ahora = DateTime.now();
        
        if(!mapOldObj.isEmpty() && !listNewObj.isEmpty()){
            for (Case caso : listNewObj){

                if(!idsCAM.contains(caso.Id)){
                    if (mapOldObj.get(caso.Id).Status != 'Pendiente Colaborador' && caso.Status == 'Pendiente Colaborador' ){
                        caso.CC_Inicio_Pendiente_Colaborador__c = DateTime.now();
                        if(caso.RecordTypeId == idRtCasoEmpleado && caso.CC_En_Segundo_Nivel__c == false && caso.CC_En_Tercer_Nivel__c == false){
                            caso.CC_Tiempo_Nivel_1__c = ((caso.CC_Tiempo_Nivel_1__c==null)?0: caso.CC_Tiempo_Nivel_1__c) + ((ahora.getTime() - mapOldObj.get(caso.Id).CC_Fecha_Traslado_1N__c.getTime())/1000);
                        }else if (caso.RecordTypeId == idRtCasoEmpleado && caso.CC_En_Segundo_Nivel__c == true) {
                            caso.CC_Tiempo_Nivel_2__c = ((caso.CC_Tiempo_Nivel_2__c==null)?0: caso.CC_Tiempo_Nivel_2__c) + ((ahora.getTime() - mapOldObj.get(caso.Id).CC_Fecha_Traslado_2N__c.getTime())/1000);
                        }
                    }

                    else if(mapOldObj.get(caso.Id).Status == 'Pendiente Colaborador' && caso.Status == 'Activo' && mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Colaborador__c != null && mapOldObj.get(caso.Id).CC_Contador_Pendientes__c !=null){
                       
                        caso.CC_Fin_Pendiente_Colaborador__c = ahora;
                        //US932544 apartado 14. 
                        if(caso.RecordTypeId == idRtCasoEmpleado){
                        caso.CC_Tiempo_Nivel_3__c = caso.CC_Tiempo_Nivel_3__c + (ahora.getTime() - mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Colaborador__c.getTime())/1000;
                        if(caso.CC_En_Segundo_Nivel__c == true)
                        	{
                        	    caso.CC_Fecha_Traslado_2N__c = system.now();
                        	} else if(caso.CC_En_Tercer_Nivel__c == true){
                            	caso.CC_Fecha_Traslado_3N__c = system.now();
                        	} else if(caso.CC_En_Tercer_Nivel__c == false && caso.CC_En_Segundo_Nivel__c == false){
                            	caso.CC_Fecha_Traslado_1N__c = system.now();
                        	}
                        }
                        //
                        if(caso.CC_Fecha_Reapertura__c == null){
                            caso.CC_Contador_Pendientes__c = mapOldObj.get(caso.Id).CC_Contador_Pendientes__c + (ahora.getTime() - mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Colaborador__c.getTime());
                        }
                    }
                }
            }
        }
    }
    
    
    private void cambioPendienteIncidencia (Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM){
        for (Case caso : listNewObj){
            if(!idsCAM.contains(caso.Id)){
                
                if (mapOldObj.get(caso.Id).Status != 'Pendiente Incidencia' && caso.Status == 'Pendiente Incidencia' ){
                    caso.CC_Inicio_Pendiente_Incidencia__c = DateTime.now();
                }
                else if (mapOldObj.get(caso.Id).Status == 'Pendiente Incidencia' &&  mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Incidencia__c != null && mapOldObj.get(caso.Id).CC_Contador_Pendientes__c !=null){
                    Datetime ahora = DateTime.now();
                    caso.CC_Fin_Pendiente_Incidencia__c = ahora;
                    if(caso.CC_Fecha_Reapertura__c == null){
                        caso.CC_Contador_Pendientes__c = mapOldObj.get(caso.Id).CC_Contador_Pendientes__c + (ahora.getTime() - mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Incidencia__c.getTime());
                    }
                }
            }
        }
    }
    
    private void cambioPendienteInterno(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM){
        for (Case caso : listNewObj){
            if(!idsCAM.contains(caso.Id)){
                if (mapOldObj.get(caso.Id).Status != 'Pendiente Interno' && caso.Status == 'Pendiente Interno' ){
                    caso.CC_Inicio_Pendiente_Interno__c = DateTime.now();
                } 
                //SE COMENTA PORQUE NO ES CORRECTO HACERLO AQUI, SI SE ACTIVA EL CASO PASA PORQUE EL AGENTE DEL 3N ACEPTA EL CASO. 
                /*else if (mapOldObj.get(caso.Id).Status == 'Pendiente Interno' && caso.Status == 'Activo' && mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Interno__c != null && mapOldObj.get(caso.Id).CC_Contador_Pendientes__c !=null){
                    Datetime ahora = DateTime.now();
                    caso.CC_Fin_Pendiente_Interno__c = ahora;
                    caso.CC_Contador_Pendientes__c = mapOldObj.get(caso.Id).CC_Contador_Pendientes__c + (ahora.getTime() - mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Interno__c.getTime());
                }*/
            }
        }
    }
    
    private void horaSLAConsultasOperativasPausa(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for (Case caso : listNewObj) {
            if(!idsCAM.contains(caso.Id) && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas' && caso.Origin == 'Email' && mapOldObj.get(caso.Id).Status == 'Activo' &&
            (caso.Status == 'Pendiente Interno' || caso.Status == 'Pendiente Incidencia' || caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Colaborador')){
                caso.CC_EstadoSLA__c = caso.CC_Flag_Prioridad_Formulario__c;
            }
        }
    }
    
    private void horaSLAConsultasOperativasRenaudar(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        Map<Integer, List<Integer>> festivosPorMesMap = new  Map<Integer, List<Integer>>();
        List<Case> newListCase = new List<Case>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for (Case caso : listNewObj) {
            if(!idsCAM.contains(caso.Id) && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas' && caso.Origin == 'Email' && (caso.Status == 'Activo' || (mapOldObj.get(caso.Id).Status == 'Pendiente Cliente' && caso.Status == 'Cerrado') || (caso.CC_En_Tercer_Nivel__c && caso.Status == 'Cerrado') || (mapOldObj.get(caso.Id).Status == 'Pendiente Incidencia' && caso.Status == 'Cerrado')) &&
            (((mapOldObj.get(caso.Id).CC_En_Tercer_Nivel__c && !caso.CC_En_Tercer_Nivel__c || (caso.CC_En_Tercer_Nivel__c && caso.Status == 'Cerrado'))) || mapOldObj.get(caso.Id).Status == 'Pendiente Incidencia' || mapOldObj.get(caso.Id).Status == 'Pendiente Cliente' || mapOldObj.get(caso.Id).Status == 'Pendiente Colaborador')) {
                newListCase.add(caso);
            }
        }
        if (!newListCase.isEmpty()) {
            festivosPorMesMap = CC_MetodosUtiles.sacarFestivosPorMes();
            if (!festivosPorMesMap.isEmpty()) {
                for (Case caso : newListCase) {
                    if (caso.CC_EstadoSLA__c != null && !caso.CC_EstadoSLA__c.contains('Rojo')) {
                        //Necesarios para guardar las fechas anteriores de finalización del SLA
                        Datetime fechaAmarilloAnterior, fechaRojoAnterior;
                        //Necesarios para guardar la fecha inicio y fin de las operativas pendientes
                        Datetime  fechaInicioPausa, fechaFinPausa;
                        //Necesarios para guardar las nuevas fechas de finalización del SLA
                        Datetime slaAmarillo, slaRojo;
                        
                        fechaAmarilloAnterior = Datetime.valueOf(caso.CC_FechasSLA__c.substring(0,19));
                        fechaRojoAnterior = Datetime.valueOf(caso.CC_FechasSLA__c.substring(20));
                        
                        /*if(mapOldObj.get(caso.Id).Status == 'Pendiente Interno') {
                            Datetime ahora = DateTime.now();
                            fechaInicioPausa = caso.CC_Inicio_Pendiente_Interno__c;
                            fechaFinPausa = ahora;
                        }*/
                        if((mapOldObj.get(caso.Id).CC_En_Tercer_Nivel__c && !caso.CC_En_Tercer_Nivel__c) || (caso.CC_En_Tercer_Nivel__c && caso.Status == 'Cerrado')) {
                            Datetime ahora = DateTime.now();
                            fechaInicioPausa = caso.CC_Inicio_Pendiente_Interno__c;
                            fechaFinPausa = ahora;
                        }else if(mapOldObj.get(caso.Id).Status == 'Pendiente Incidencia') {
                            fechaInicioPausa = caso.CC_Inicio_Pendiente_Incidencia__c;
                            fechaFinPausa = caso.CC_Fin_Pendiente_Incidencia__c;
                        } else if(mapOldObj.get(caso.Id).Status == 'Pendiente Cliente') {
                            fechaInicioPausa = caso.CC_Inicio_Pendiente_Cliente__c;
                            fechaFinPausa = caso.CC_Fin_Pendiente_Cliente__c;
                        } else if(mapOldObj.get(caso.Id).Status == 'Pendiente Colaborador') {
                            fechaInicioPausa = caso.CC_Inicio_Pendiente_Colaborador__c;
                            fechaFinPausa = caso.CC_Fin_Pendiente_Colaborador__c;
                        }
                        
                        //Necesario para el cálculo del sla.
                        Datetime ahora = fechaFinPausa;
                        Integer segundos;
                        slaAmarillo = fechaAmarilloAnterior;
                        
                        
                        //Primero tenemos en cuenta si se despausa el sla en horario no laboral, festivo o finde.
                        if(CC_MetodosUtiles.isWeekend(ahora) ||(festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day()))) {
                            
                            //si el sla esta en verde fechaInicioPausa < fechaAmarilloAnterior y fechaInicioPausa < fechaRojoAnterior
                            //Si el sla esta en amarillo, ya no hay que calcular el amarillo, solo el sla del rojo, fechainiciopausa > fechaAmarilloAnterior y fechainiciopausa < fechaRojoAnterior
                            if (caso.CC_EstadoSLA__c.contains('Verde')) {
                                //SLA Amarillo : calcular las horas que faltan para que se ponga en amarillo
                                segundos = Integer.valueOf((fechaAmarilloAnterior.getTime() - fechaInicioPausa.getTime())/1000);
                                do {
                                    
                                    ahora = ahora.addDays(1);
                                    if(!CC_MetodosUtiles.isWeekend(ahora) && (!festivosPorMesMap.containsKey(ahora.month()) || (festivosPorMesMap.containsKey(ahora.month())  && !festivosPorMesMap.get(ahora.month()).contains(ahora.day())))) {//si tras sumar ya no es finde ni festivo
                                        ahora = CC_MetodosUtiles.isWeekend(ahora.addSeconds(segundos)) || (festivosPorMesMap.containsKey(ahora.addSeconds(segundos).month()) && festivosPorMesMap.get(ahora.addSeconds(segundos).month()).contains(ahora.addSeconds(segundos).day())) ? ahora:ahora.addSeconds(segundos);
                                    }
                                    
                                } while (CC_MetodosUtiles.isWeekend(ahora) || (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())));
                                
                                slaAmarillo = ahora;
                                ahora = fechaFinPausa;
                            }
                            
                            //SLA Rojo : calcular las horas que faltan para que se ponga en rojo
                            segundos = Integer.valueOf((fechaRojoAnterior.getTime() - fechaInicioPausa.getTime())/1000);
                            do {
                                ahora = ahora.addDays(1);
                                if(!CC_MetodosUtiles.isWeekend(ahora) && (!festivosPorMesMap.containsKey(ahora.month()) || (festivosPorMesMap.containsKey(ahora.month())  && !festivosPorMesMap.get(ahora.month()).contains(ahora.day())))) {//si tras sumar ya no es finde ni festivo
                                    ahora = CC_MetodosUtiles.isWeekend(ahora.addSeconds(segundos)) || (festivosPorMesMap.containsKey(ahora.addSeconds(segundos).month()) && festivosPorMesMap.get(ahora.addSeconds(segundos).month()).contains(ahora.addSeconds(segundos).day())) ? ahora:ahora.addSeconds(segundos);
                                }
                                
                            } while (CC_MetodosUtiles.isWeekend(ahora) || (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())));
                            
                            slaRojo = ahora;
                            
                        } else { //Cuando el SLA se despausa en horario laboral.
                            
                            //si el sla esta en verde fechaInicioPausa < fechaAmarilloAnterior y fechaInicioPausa < fechaRojoAnterior
                            //Si el sla esta en amarillo, ya no hay que calcular el amarillo, solo el sla del rojo, fechainiciopausa > fechaAmarilloAnterior y fechainiciopausa < fechaRojoAnterior
                            if (caso.CC_EstadoSLA__c.contains('Verde')) {
                                //calcular las horas que faltan para que se ponga en amarillo y en rojo
                                //SLA Amarillo : calcular las horas que faltan para que se ponga en amarillo
                                segundos = Integer.valueOf((fechaAmarilloAnterior.getTime() - fechaInicioPausa.getTime())/1000);
                                ahora = (CC_MetodosUtiles.isWeekend(ahora.addSeconds(segundos)) || (festivosPorMesMap.containsKey(ahora.addSeconds(segundos).month()) && festivosPorMesMap.get(ahora.addSeconds(segundos).month()).contains(ahora.addSeconds(segundos).day()))) ? ahora:ahora.addSeconds(segundos);
                                
                                if (ahora == fechaFinPausa) { //si la ahora sigue siendo igual que el createddate quiere decir que no lo ha sumado porque al sumar esas horas o bien es festivo o bien es finde
                                    ahora = ahora.addSeconds(segundos);
                                    do {
                                        
                                        ahora = Integer.valueOf(ahora.format('u')) == 6  ? ahora.addDays(2): ahora;
                                        ahora = Integer.valueOf(ahora.format('u')) == 7  ? ahora.addDays(1): ahora;
                                        ahora = (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())) ? ahora.addDays(1): ahora;
                                        
                                    } while (CC_MetodosUtiles.isWeekend(ahora) || (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())));
                                }
                                
                                slaAmarillo = ahora;
                                ahora = fechaFinPausa;
                            }
                            //SLA Rojo : calcular las horas que faltan para que se ponga en rojo
                            segundos = Integer.valueOf((fechaRojoAnterior.getTime() - fechaInicioPausa.getTime())/1000);
                            ahora = (CC_MetodosUtiles.isWeekend(ahora.addSeconds(segundos)) || (festivosPorMesMap.containsKey(ahora.addSeconds(segundos).month()) && festivosPorMesMap.get(ahora.addSeconds(segundos).month()).contains(ahora.addSeconds(segundos).day()))) ? ahora:ahora.addSeconds(segundos);
                            if (ahora == fechaFinPausa) { //si la ahora sigue siendo igual  que la fecha fin pauda quiere decir que no lo ha sumado porque al sumar esas horas o bien es festivo o bien es finde
                                ahora = ahora.addSeconds(segundos);
                                do {
                                    
                                    ahora = Integer.valueOf(ahora.format('u')) == 6  ? ahora.addDays(2): ahora;
                                    ahora = Integer.valueOf(ahora.format('u')) == 7  ? ahora.addDays(1): ahora;
                                    ahora = (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())) ? ahora.addDays(1): ahora;
                                    
                                } while (CC_MetodosUtiles.isWeekend(ahora) || (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())));
                            }
                            slaRojo = ahora;
                            
                        }
                        caso.CC_FechasSLA__c = String.valueOf(slaAmarillo) + '-' +String.valueOf(slaRojo);
                    }
                    caso.CC_EstadoSLA__c = '';
                    
                }
            }
            
        }
    }
    
    private void horasSLATraslado (Map<Id, Case> mapOldObj, List<Case> listNewObj){
        Map <Id, Case> casosCambiar = new Map <Id, Case>();
        Map <Id, Datetime> casosFecha = new Map <Id, Datetime>();
        
        for (Case caso : listNewObj){
            //Si se ha hecho un traslado a colaborador, a 3N o a incidencia desde un caso de llamada o de chat lo analizamos
            if (mapOldObj.get(caso.Id).Status == 'Activo' && (caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Interno' || caso.Status == 'Pendiente Incidencia') && (caso.Origin == 'Chat' ||  caso.Origin == 'Phone')){
                
                casosCambiar.put(caso.Id, caso);
                if (caso.Status == 'Pendiente Colaborador'){
                    casosFecha.put(caso.Id, caso.CC_Fecha_Traslado_Colaborador__c);
                }
                else if (caso.Status == 'Pendiente Interno'){
                    casosFecha.put(caso.Id, DateTime.now());
                }
                else if (caso.Status == 'Pendiente Incidencia') {
                    casosFecha.put(caso.Id, DateTime.now());
                }
            }
        }
        
        if (!casosCambiar.isEmpty()){
            List<Case> casosSLACumplido = new List <Case>();
            
            //Map para tener el nombre de la lista de valores con sus valores
            Map<String, Map<String, List <Time>>> horariosPorCanalProcedencia = new Map<String, Map<String, List <Time>>> ();
            horariosPorCanalProcedencia = CC_MetodosUtiles.horariosPorCanalProcedencia();
            
            //Map<Mes, List<dias>>
            Map<Integer, List<Integer>> festivosPorMesMap = new Map<Integer, List<Integer>> ();
            festivosPorMesMap = CC_MetodosUtiles.sacarFestivosPorMes();
            
            Double horasSLATraslado = 0;
            for (Case caso : casosCambiar.values()){
                if (caso.CC_Horas_Hasta_Traslado__c == null || caso.CC_Horas_Hasta_Traslado__c == 0){
                    horasSLATraslado = calcularSLA(caso, horariosPorCanalProcedencia.get(caso.CC_Canal_Procedencia__c), casosFecha.get(caso.Id), festivosPorMesMap);
                    caso.CC_Horas_Hasta_Traslado__c = horasSLATraslado;
                }
            }
        }
    }
    private static Double calcularSLA (Case caso, Map<String, List <Time>> horario, Datetime fechaTraslado, Map<Integer, List<Integer>> festivos){
        Datetime fechaCreacion = caso.CreatedDate;
        Double horasPasadas = 0;
        
        if(fechaTraslado != null && fechaCreacion !=null){
            //Trabajan 24/7
            if (caso.CC_Canal_Procedencia__c == 'Atención al Cliente' || (caso.Origin == 'Chat') || (horario == null)){
                
                //No se pueden restar campos tipo dateTime, por lo que hay que pasarlo a ms y después a horas para restarlo
                horasPasadas =  CC_MetodosUtiles.restarHoras(fechaTraslado, fechaCreacion);
                if (caso.CC_Inicio_Pendiente_Cliente__c != null && caso.CC_Fin_Pendiente_Cliente__c != null){
                    horasPasadas = horasPasadas - CC_MetodosUtiles.restarHoras(caso.CC_Fin_Pendiente_Cliente__c, caso.CC_Inicio_Pendiente_Cliente__c);
                }
                
            }
            else{
                Double horasTrabajoViernes;
                Double horasTrabajoNormal;

                if (horario.size() > 1){
                    
                    horasTrabajoViernes = CC_MetodosUtiles.restarHoras(horario.get('V').get(1), horario.get('V').get(0));
                    horasTrabajoNormal = CC_MetodosUtiles.restarHoras(horario.get('L-J').get(1), horario.get('L-J').get(0));
                    
                    
                }
                else{

                    horasTrabajoNormal = CC_MetodosUtiles.restarHoras(horario.get('L-V').get(1), horario.get('L-V').get(0));
                    
                }
                
                if (!fechaCreacion.isSameDay(fechaTraslado)){
                    
                    
                    Datetime diaSemanaBucle = fechaCreacion.date();
                    
                    
                    //Horas que cuentan del primer día, si no se ha trasladado el mismo día que se hace el traslado
                    if (fechaCreacion.time() >= CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada') && fechaCreacion.time() <= CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Salida')){
                        
                        if (caso.CC_Inicio_Pendiente_Cliente__c != null && fechaCreacion.isSameDay(caso.CC_Inicio_Pendiente_Cliente__c)) { // Si ha habido una petición de información
                            horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), fechaCreacion.time());
                            if (caso.CC_Fin_Pendiente_Cliente__c != null && fechaCreacion.isSameDay(caso.CC_Fin_Pendiente_Cliente__c)) {
                                if (caso.CC_Fin_Pendiente_Cliente__c.time() <= CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Salida')) {  // Si se ha recibido la peticion de cliente en horario laboral
                                    horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Salida'), caso.CC_Fin_Pendiente_Cliente__c.time());
                                }
                            }
                        }
                        else{
                            //Si no ha habido una petición de información
                            horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Salida'), fechaCreacion.time());
                            
                        }
                    }
                    else{
                        if (fechaCreacion.time() < CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada')){     //El caso se ha creado antes de que entraran a trabajar
                            if (caso.CC_Inicio_Pendiente_Cliente__c != null && fechaCreacion.isSameDay(caso.CC_Inicio_Pendiente_Cliente__c)) { // Si ha habido una petición de información
                                horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada'));
                            }
                            else{
                                horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Salida'), CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada'));
                            }
                        }
                        
                    }
                    Integer i = 1;
                    while (!diaSemanaBucle.addDays(i).format('u').equals(fechaTraslado.format('u'))) {
                        Boolean solicitudInformacionAtendida = false;
                        
                        if (!CC_MetodosUtiles.isFestive(diaSemanaBucle.addDays(i), festivos) && !CC_MetodosUtiles.isWeekend(diaSemanaBucle.addDays(i))) {
                            
                            if(caso.CC_Inicio_Pendiente_Cliente__c != null && diaSemanaBucle.addDays(i).isSameDay(caso.CC_Inicio_Pendiente_Cliente__c)){
                                horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.addDays(i).format('u'), 'Entrada') );
                                solicitudInformacionAtendida = true;
                                
                            }
                            if(caso.CC_Fin_Pendiente_Cliente__c != null && diaSemanaBucle.addDays(i).isSameDay(caso.CC_Fin_Pendiente_Cliente__c)){
                                if (caso.CC_Fin_Pendiente_Cliente__c.time() < CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.addDays(i).format('u'), 'Entrada')){
                                    if (Integer.valueOf(diaSemanaBucle.addDays(i).format('u')) == 5) {
                                        horasPasadas = horasPasadas + horasTrabajoViernes;
                                        
                                    }
                                    else{
                                        horasPasadas = horasPasadas + horasTrabajoNormal;
                                        
                                    }
                                }
                                else{ //Si el fin de la peticion de cliente ha llegado en jornada laboral
                                    if (caso.CC_Fin_Pendiente_Cliente__c.time() <= CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.addDays(i).format('u'), 'Salida')){
                                        horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.addDays(i).format('u'), 'Salida'), caso.CC_Fin_Pendiente_Cliente__c.time());
                                    }
                                    
                                }
                                solicitudInformacionAtendida = true;
                            }
                            
                            //Si no es festivo ni fin de semana se suman las horas que trabajan dependiendo de si es viernes o no
                            if (!solicitudInformacionAtendida){
                                if (Integer.valueOf(diaSemanaBucle.addDays(i).format('u')) == 5) {
                                    horasPasadas = horasPasadas + horasTrabajoViernes;
                                    
                                }
                                else{
                                    horasPasadas = horasPasadas + horasTrabajoNormal;
                                    
                                }
                            }
                            
                        }
                        i ++;
                    }
                    if (caso.CC_Fin_Pendiente_Cliente__c != null && fechaCreacion.addDays(i).isSameDay(caso.CC_Fin_Pendiente_Cliente__c)){ //Si el día de traslado ha sido el mismo día que se ha recibido la información
                        if (caso.CC_Fin_Pendiente_Cliente__c.time() < CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.addDays(i).format('u'), 'Entrada')){  //Si se recibe la información cuando no está trabajando
                            horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(fechaTraslado.time(), CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.addDays(i).format('u'), 'Entrada'));
                        }
                        else{
                            horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(fechaTraslado.time(), caso.CC_Fin_Pendiente_Cliente__c.time());
                        }
                        if (fechaCreacion.addDays(i).isSameDay(caso.CC_Inicio_Pendiente_Cliente__c)){ //Si la solicitud de información se ha hecho el mismo día que el traslado
                            horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.addDays(i).format('u'), 'Entrada'));
                        }
                    }
                    else{
                        horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(fechaTraslado.time(), CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada'));
                    }
                }
                else{
                    //Ha sido trasladado el mismo día que se ha creado
                    if (fechaCreacion.time() >= CC_MetodosUtiles.horarioDiaTurno(horario, fechaTraslado.format('u'), 'Entrada') && fechaCreacion.time() <= CC_MetodosUtiles.horarioDiaTurno(horario, fechaTraslado.format('u'), 'Salida')){
                        //Si ha habido una petición de información
                        if (caso.CC_Inicio_Pendiente_Cliente__c != null && caso.CC_Fin_Pendiente_Cliente__c != null){
                            horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), fechaCreacion.time());
                            horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(fechaTraslado.time(), caso.CC_Fin_Pendiente_Cliente__c.time());
                        }
                        else{
                            horasPasadas = CC_MetodosUtiles.restarHoras(fechaTraslado.time(), fechaCreacion.time());
                        }
                    }
                    else{
                        //El caso se ha creado antes de que entraran a trabajar
                        if (caso.CC_Inicio_Pendiente_Cliente__c != null && caso.CC_Fin_Pendiente_Cliente__c != null){
                            horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada'));
                            horasPasadas = horasPasadas + CC_MetodosUtiles.restarHoras(fechaTraslado.time(), caso.CC_Fin_Pendiente_Cliente__c.time());
                        }
                        else{
                            horasPasadas = CC_MetodosUtiles.restarHoras(fechaTraslado.time(), CC_MetodosUtiles.horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada'));
                        }
                    }
                }
            }
        }
        
        return horasPasadas;
    }
    
    
    private static void cierreCasos(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        Id idRtCasoEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case','CC_Empleado');
        Set<Id> setIdsCasos = new Set<Id>();
        List<Case> casos = new List<Case>();
        List<Case> casosTelefonia = new List<Case>();
        
        for (Case caso : listNewObj) {
            if (mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado'
            && !idsCAM.contains(caso.Id)
            && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'
            && caso.RecordTypeId == idRtCasoEmpleado) {
                casos.add(caso);
            } else if(mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado' && caso.Origin == 'Phone' /*&& caso.Account.CC_Tipo_Centro__c == 'OF' && caso.Account.CC_SubTipo_Centro__c == 'BP'*/ && caso.RecordTypeId == idRtCasoEmpleado) {
                setIdsCasos.add(caso.Id);
                casosTelefonia.add(caso);
            }
        }
        
        if (!casosTelefonia.isEmpty()) {
            generarURLLimeSurvey(casosTelefonia, setIdsCasos);
        }
        
        if (!casos.isEmpty()) {
            List<Task> tareasLlamadasSalientes = [SELECT Id, WhatId FROM Task WHERE CC_Llamada_Id__c != NULL AND WhatId IN :CC_MetodosUtiles.listaCampo(casos, 'Id') AND Type = 'Llamada saliente'];
            if (!tareasLlamadasSalientes.isEmpty()) {
                for (Case caso : casos) {
                    for (Task tarea : tareasLlamadasSalientes) {
                        if (tarea.WhatId == caso.Id) {
                            caso.CC_Llamada_Saliente__c = true;
                        }
                    }
                }
            }
        }
    }
    
    private static void validarCierreCaso(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        //Para los casos que nos llegan como parámetro
        
        //Obtenemos el perfil del usuario
        Id profileId = UserInfo.getProfileId();
        String profileName;
        if(profileId != null){
            List<Profile> perfil = [SELECT Name FROM Profile WHERE Id = :profileId];
            if(!perfil.isEmpty()){
                profileName = perfil[0].Name;
            }
            
        }
        
        Map<Id, Case> casoIdCaso = new Map<Id, Case>();
        for (Case caso : listNewObj)  {
            
            
            if (mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado' && !idsCAM.contains(caso.Id)) {
                
                if(!Test.isRunningTest() && !System.isBatch() &&
                !caso.CC_CierreAutomaticoCSBD__c &&
                profileName != null && profileName != 'CC_Integración' && profileName.startsWith('CC') &&
                (mapOldObj.get(caso.Id).CC_Cerrado_Operativa__c == caso.CC_Cerrado_Operativa__c) &&
                (mapOldObj.get(caso.Id).CC_Fecha_Cierre_SolInf__c == caso.CC_Fecha_Cierre_SolInf__c)){
                    caso.addError('Debe usar el botón \'Guardar y Cerrar\' o la operativa correspondiente');
                }else{
                    casoIdCaso.put(caso.Id, caso);
                }
            }
        }
        if (casoIdCaso.size() > 0) {
            //Buscamos los tipos de actividad excluidos de la validación
            List<String> actividadesExcluidas = new List<String>();
            for (CC_Actividad_Cerrar_Caso__mdt actividad : [SELECT MasterLabel FROM CC_Actividad_Cerrar_Caso__mdt]) {
                actividadesExcluidas.add(actividad.MasterLabel);
            }
            
            //Damos error para los casos con actividades abiertas (no excluidas)
            List<Task> actividades = [SELECT WhatId, Type, Status, Subject, CC_Tipo_Cierre__c FROM Task WHERE WhatId IN :casoIdCaso.keySet()
            AND Type NOT IN :actividadesExcluidas];
            
            Id recordType3N = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Tercer_Nivel');
            List<CC_Grupo_Colaborador__c> listaGruposColaboradores = [SELECT Name, RecordTypeId FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :recordType3N AND Name <> NULL];
            
            //Mirar si el caso tiene tarea completada de reasignación con un grupo de 3N
            Set<Id> setCasos3N = new Set<Id>();
            if(!actividades.isEmpty()){
                for(Task tarea : actividades){
                    String nombreGrupo = tarea.Subject;
                    if(nombreGrupo != null){
                        for(CC_Grupo_Colaborador__c grupo : listaGruposColaboradores){
                            if(tarea?.Status == 'Completed' && nombreGrupo?.contains(grupo.Name) && tarea?.Type == 'Reasignación'){
                                setCasos3N.add(tarea.WhatId);
                            }
                        }
                    }
                }
            }
            
            //Cerrar Actividad 3N en caso que este abierta
            List<Task> cerrarTareas = new List<Task>();
            if(!setCasos3N.isEmpty() && !actividades.isEmpty()){
                for(Id idCaso : setCasos3N){
                    for(Task tarea : actividades){
                        if(idCaso == tarea.WhatId && tarea.Status == 'Open' && tarea.Type == 'Traslado Tercer Nivel'){
                            tarea.Status = 'Completed';
                            tarea.CC_Tipo_Cierre__c = 'Resuelto por 3N';
                            cerrarTareas.add(tarea);
                            for(Case caso : listNewObj){
                                if(tarea.WhatId == caso.id && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas') {
                                    Datetime ahora = DateTime.now();
                                    caso.CC_Fin_Pendiente_Interno__c = ahora;
                                }
                            }
                        }
                    }
                }
            }
            
            if(!cerrarTareas.isEmpty()){
                update cerrarTareas;
            }
            
            // DPK - US1183569 - EMPLEADOS CCO: Caso con actividad de documentación no recibida y no cerrado automáticamente (IN1261860)
            Id rtEmpleados = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');

            for (Task actividad : actividades) { 
                 if(!(casoIdCaso.get(actividad.whatId).RecordTypeId == rtEmpleados && mapOldObj.get(actividad.whatId).Status == 'Pendiente cliente' && casoIdCaso.get(actividad.whatId).CC_Admin__c) && actividad.Status == 'Open'){               
                        casoIdCaso.get(actividad.WhatId).addError('Existen actividades pendientes que deben completarse antes de cerrar el caso.');
                }
            }
        }
    }
    
    private void actualizarBuzonSalida(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        for (Case caso : listNewObj) {
            if (caso.CC_Canal_Procedencia__c != mapOldObj.get(caso.Id).CC_Canal_Procedencia__c
            || caso.CC_Idioma__c != mapOldObj.get(caso.Id).CC_Idioma__c) {
                //El canal de procedencia o el idioma han cambiado, se actualiza el buz�n de salida del caso
                caso.CC_Buzon_Salida__c = obtenerBuzon(caso.CC_Canal_Procedencia__c, caso.CC_Idioma__c, caso.recordTypeId);
            }
        }
    }
    
    private String obtenerBuzon(String canalProcedencia, String idioma, Id recordTypeId) {
        idioma = idioma == 'ca' ? 'Català' : idioma == 'en' ? 'Inglés' : 'Castellano';
        
        Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
		Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');

        List<CC_Buzones_Por_Defecto__mdt> buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
        WHERE CC_Canal_Procedencia__c = :canalProcedencia AND CC_Idioma__c = :idioma];

        if (buzones.isEmpty() && canalProcedencia == 'Formulario Consultas Operativas') {
            buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
            WHERE  DeveloperName = 'CC_Buzon_Defecto_Empleados' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = TRUE];
        }
        		//Si no se ha encontrado  ningún buzón se usa el por defecto en el idioma del caso para clientes
        if (buzones.isEmpty() && recordTypeId == rtCliente){
            buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
						WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = :idioma
						AND CC_Activo__c = true];
        }
		//Si no se ha encontrado  ningún buzón se usa el por defecto en el idioma del caso para empleados
		if (buzones.isEmpty() && recordTypeId == rtEmpleado){
            buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
						WHERE CC_Canal_Procedencia__c = 'Por defecto empleados' AND CC_Idioma__c = :idioma
						AND CC_Activo__c = true];
        }

		//Si no encuentra ningún buzón se usa el por defecto en castellano para clientes
		if (buzones.isEmpty() && recordTypeId == rtCliente){
			buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
						WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano'
						AND CC_Activo__c = true];
		}
		//Si no encuentra ningún buzón se usa el por defecto en castellano para empleados		
		if (buzones.isEmpty() && recordTypeId == rtEmpleado){
			buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
						WHERE CC_Canal_Procedencia__c = 'Por defecto empleados' AND CC_Idioma__c = 'Castellano'
						AND CC_Activo__c = true];
		}
        return !buzones.isEmpty() ? buzones[0].CC_Direccion_Correo__c : null;
    }
    
    
    private static void agrupadoresInactivos(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        Map<Id, List<Case>> casoIdCaso = new Map<Id, List<Case>>();
        Set<Id> idsAgrupadores = new Set<Id>();
        List<Case> idsCasos = new List<Case>();
        Set<Id> setIdsCasos = new Set<Id>();
        Map<Id, Case> agrupadorCaso = new Map<Id, Case>();
        Map<Id, List<Case>> mapIdCaseURL = new Map<Id, List<Case>>();
        
        for (Case caso : listNewObj)  {
            if (!idsCAM.contains(caso.Id)) {
                if ((mapOldObj.get(caso.Id).CC_Agrupador_Id__c != caso.CC_Agrupador_Id__c) || (mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado') ) {
                    idsAgrupadores.add(caso.CC_Agrupador_Id__c);
                    
                    if(casoIdCaso.containsKey(caso.CC_Agrupador_Id__c)) {
                        List<Case> listCasos = casoIdCaso.get(caso.CC_Agrupador_Id__c);
                        listCasos.add(caso);
                        casoIdCaso.put(caso.CC_Agrupador_Id__c, listCasos);
                    } else {
                        casoIdCaso.put(caso.CC_Agrupador_Id__c, new List<Case> { caso });
                    }
                    
                    if(mapIdCaseURL.containsKey(caso.CC_Agrupador_Id__c)) {
                        List<Case> listCasos = mapIdCaseURL.get(caso.CC_Agrupador_Id__c);
                        listCasos.add(caso);
                        mapIdCaseURL.put(caso.CC_Agrupador_Id__c, listCasos);
                    } else {
                        mapIdCaseURL.put(caso.CC_Agrupador_Id__c, new List<Case> { caso });
                    }
                }
            }
        }
        
        if (!idsAgrupadores.isEmpty()) {
            for (CC_Agrupador__c agrupador : [SELECT CC_Estado__c, RecordTypeId, RecordType.DeveloperName FROM CC_Agrupador__c WHERE ID IN :idsAgrupadores]) {
                for (Case caso : casoIdCaso.get(agrupador.Id)) {
                    if (agrupador != null && caso != null && caso.Status != 'Cerrado'
                    && (agrupador.CC_Estado__c == null || agrupador.CC_Estado__c == 'Cerrado' || agrupador.CC_Estado__c == 'Rechazado')) {
                        caso.addError('Solo se pueden asociar agrupadores activos.');
                    } else if (caso.Status == 'Cerrado' && mapOldObj.get(caso.Id).Status != 'Cerrado'
                    && caso.RecordTypeId != null && caso.RecordTypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado')
                    && caso.CC_URL_Encuesta_3N__c == null && agrupador.RecordType.DeveloperName == 'CC_Incidencia' && mapIdCaseURL.get(agrupador.Id) != null) {
                        idsCasos.add(caso);
                        setIdsCasos.add(caso.Id);
                    }
                }
            }
        }
        
        if (!idsCasos.isEmpty()) {
            generarURLLimeSurvey(idsCasos, setIdsCasos); //Generar la encuesta de empleados
            //generarURL(idsCasos);
        }
    }
    
    private static void generarURLLimeSurvey(List<Case> listNewObj, Set<Id> setIdsCasos){
        Map<Id, String> encuesta = CC_MetodosUtiles.generarURLsLimeSurvey(listNewObj);
        for(Case caso : listNewObj){
             caso.CC_URL_Encuesta_3N__c = !encuesta.isEmpty() ? encuesta.get(caso.Id) : null;
         }
    }
    
    private void cambioPropietarioColaConsultasOperativas(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        List<Case> newListCase = new List<Case>();
        List<Case> newListCaseGrupoTransfer = new List<Case>();
        Set<String> colasCasos = new Set<String>();
        Set<String> colasGrupoTransfer = new Set<String>();
        
        for (Case caso : listNewObj) {
            if (!idsCAM.contains(caso.Id) &&
            caso.CC_Cola_Procedencia__c != null &&
            caso.CC_Grupo_Transfer__c == null &&
            caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas' &&
            mapOldObj.get(caso.Id).Status == 'Activo' &&
            (caso.Status == 'Pendiente Incidencia' || caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Colaborador') &&
            caso.CC_En_Tercer_Nivel__c == false){
                newListCase.add(caso);
                colasCasos.add(caso.CC_Cola_Procedencia__c);
                //System.debug('NSB - cambioPropietarioColaConsultasOperativas'+caso.CC_Cola_Procedencia__c);
            }
            if (!idsCAM.contains(caso.Id) &&
            caso.CC_Cola_Procedencia__c != null &&
            caso.CC_Grupo_Transfer__c != null &&
            caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas' &&
            mapOldObj.get(caso.Id).Status == 'Activo' &&
            (caso.Status == 'Pendiente Incidencia' || caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Colaborador') &&
            caso.CC_En_Tercer_Nivel__c == false){
                newListCaseGrupoTransfer.add(caso);
                colasGrupoTransfer.add(caso.CC_Grupo_Transfer__c);
            }
        }
        
        if (!newListCase.isEmpty() && !colasCasos.isEmpty()){
            List<Group> colas = [SELECT DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :colasCasos];
            Map<String,Id> mapColas = new Map<String,Id>();
            for (Group cola : colas) {
                mapColas.put(cola.DeveloperName,cola.Id);
            }
            for (Case caso : newListCase ){
                caso.OwnerId = mapColas.get(caso.CC_Cola_Procedencia__c);
            }
        }
        
        if (!newListCaseGrupoTransfer.isEmpty() && !colasGrupoTransfer.isEmpty()){
            List<Group> colas = [SELECT DeveloperName FROM Group WHERE Type = 'Queue' AND Id IN :colasGrupoTransfer];
            Map<String,Id> mapColas = new Map<String,Id>();
            for (Group cola : colas) {
                mapColas.put(cola.Id, cola.Id);
            }
            for (Case caso : newListCaseGrupoTransfer){
                caso.OwnerId = mapColas.get(caso.CC_Grupo_Transfer__c);
            }
        }
    }
    
    private void envioCorreoConsultasOperativasAsignarPropietario(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        //hay que vigilar que solo se envie una vez
        List<Case> newListCase = new List<Case>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for (Case caso : listNewObj) {
            if(!idsCAM.contains(caso.Id) && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'
            && (mapOldObj.get(caso.Id).OwnerId.getsobjecttype() != User.SObjectType && caso.OwnerId.getsobjecttype() == User.SObjectType) && !caso.CC_Correo_Asignacion_Enviado__c){
                newListCase.add(caso);
            }
        }
        if (!newListCase.isEmpty()){
            
            List<CC_Buzones_Por_Defecto__mdt> buzonDefault = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
            WHERE CC_Canal_Procedencia__c = 'Formulario Consultas Operativas' AND CC_Activo__c = true];
            List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
            if (Test.isRunningTest()) {
                owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName like 'Atención%' LIMIT 1];
            } else {
                owa = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonDefault[0].CC_Direccion_Correo__c];
                
            }
            if (!owa.isEmpty()) {
                List<EmailTemplate> emailTemplates = [SELECT Developername, subject, htmlvalue FROM EmailTemplate WHERE Developername IN ('CC_ConsultasOperativasCanalFormulario_Asignacion_CAS','CC_ConsultasOperativasCanalFormulario_Asignacion_CAT')];
                Map<String,String> templateSubjectPorIdioma = new Map<String,String>();
                Map<String,String> templateHTMLBodyPorIdioma = new Map<String,String>();
                if (!emailTemplates.isEmpty()){
                    for(EmailTemplate template : emailTemplates) {
                        
                        if (template.DeveloperName.contains('_CAT')){
                            templateSubjectPorIdioma.put('ca', template.subject);
                            templateHTMLBodyPorIdioma.put('ca', template.htmlvalue);
                        }else {
                            templateSubjectPorIdioma.put('es', template.subject);
                            templateHTMLBodyPorIdioma.put('es', template.htmlvalue);
                        }
                    }
                    
                    
                    for (Case caso : newListCase) {
                        
                        Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
                        correo.setOrgWideEmailAddressId(owa[0].Id);
                        correo.setToAddresses(new List<String>{caso.CC_MailTelfNotif__c});
                        correo.setTreatBodiesAsTemplate(true);
                        correo.setSubject(templateSubjectPorIdioma.get(caso.CC_Idioma__c));
                        correo.setHtmlBody(templateHTMLBodyPorIdioma.get(caso.CC_Idioma__c));
                        correo.setTreatTargetObjectAsRecipient(false);
                        correo.setWhatId(caso.Id);
                        correo.setSaveAsActivity(true);
                        allmsg.add(correo);
                        
                        caso.CC_Correo_Asignacion_Enviado__c = true;
                        
                    }
                }
                
            }
        }
        //Enviamos todos los mensajes
        if (!allmsg.isEmpty()) {
            for (Messaging.SendEmailResult sr : Messaging.sendEmail(allmsg, false)) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
    }
    
    
    private CC_MCC__c encontrarMCCPorId (List<CC_MCC__C> lista, Id id) {
        for (CC_MCC__c mcc : lista) {
            if (mcc.id == id) {
                return mcc;
            }
        }
        return null;
    }
    private void actualizarEstadoReversionImaginBank(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        // Condiciones: casos que se hayan cerrado, tengan un contacto asignado y aún no se hayan puesto en ningún estado de reversión
        List<Id> idMCCs = new List<Id>();
        List<Case> listaCasosCerrados = new List<Case>();
        for (Case caso : listNewObj) {
            if(!idsCAM.contains(caso.Id)){
                if (mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado'
                && String.IsBlank(caso.CC_Estado_Reversion__c) && caso.ContactId != null
                && caso.CC_MCC_Motivo__c != null && caso.CC_MCC_Causa__c != null) {
                    idMCCs.add(caso.CC_MCC_Motivo__c);
                    idMCCs.add(caso.CC_MCC_Causa__c);
                    listaCasosCerrados.add(caso);
                }
                else if (caso.CC_Estado_Reversion__c == 'Pendiente Envío' && mapOldObj.get(caso.Id).Status == 'Cerrado' && caso.Status == 'Activo') {
                    caso.CC_Estado_Reversion__c = '';
                }
            }
        }
        
        if (!idMCCs.isEmpty()) {
            // Condiciones: casos que tengan el motivo y causa necesarios
            List<Id> idContactos = new List<Id>();
            List<Case> listaCasosReversion = new List<Case>();
            List<CC_MCC__c> listaMCCs = [SELECT Name FROM CC_MCC__c WHERE Id IN :idMCCs];
            for (Case caso : listaCasosCerrados) {
                String nombreMotivo = encontrarMCCPorId(listaMCCs, caso.CC_MCC_Motivo__c).Name;
                String nombreCausa = encontrarMCCPorId(listaMCCs, caso.CC_MCC_Causa__c).Name;
                if (nombreMotivo == 'Reversión' && nombreCausa == 'Solicita reversión') {
                    idContactos.add(caso.AccountId);
                    listaCasosReversion.add(caso);
                }
            }
            
            if (!listaCasosReversion.isEmpty()) {
                // Condiciones: el contacto asociado al caso tiene la característica necesaria
                List<CC_Caracteristica_Detalle__c> listaCaracteristicasDetalle =
                [SELECT CC_Cuenta__c, CC_Cliente__c, CC_Identificador_Formula__c FROM CC_Caracteristica_Detalle__c WHERE CC_Cuenta__c  IN :idContactos
                AND CC_Caracteristica__r.CC_Activo__c = true AND CC_Caracteristica__r.Name = 'Cliente migrado a ImaginBank'];
                for (Case caso : listaCasosReversion) {
                    for (CC_Caracteristica_Detalle__c detalle : listaCaracteristicasDetalle) {
                        if (detalle.CC_Cuenta__c == caso.AccountId) {
                            // Si se cumplen todas las condiciones buscamos el caso en la lista del trigger y lo actualizamos
                            for (Case nuevoCaso : listNewObj) {
                                if (caso.Id == nuevoCaso.Id) {
                                    nuevoCaso.CC_Estado_Reversion__c = 'Pendiente envío';
                                    nuevoCaso.CC_NIF__c = detalle.CC_Identificador_Formula__c;
                                    nuevoCaso.CC_Numero_Caso__c = nuevoCaso.CaseNumber;
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
    
    //Funcion para generar registros de Trazabilidad
    private void asignacionTRZ(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        List<Id> casosAsignacion = new List<Id>();
        List<Id> casosResolucion = new List<Id>();
        List<Id> casosCierre = new List<Id>();
        
        for (Case caso : listNewObj) {
            if(!idsCAM.contains(caso.Id)){
                //Asignacion del caso
                if (caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.CC_Fecha_Reapertura__c == null && caso.CC_Fecha_Limite_Resolucion__c != null) {
                    caso.CC_Tramo_TRZ__c = 'Asignada - En gestion';
                    casosAsignacion.add(caso.Id);
                }
                //Resolucion y Cierre
                if (caso.Status == 'Cerrado' && mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.CC_Fecha_Limite_Resolucion__c != null) {
                    caso.CC_Tramo_TRZ__c = 'Cerrada';
                    casosResolucion.add(caso.Id);
                    casosCierre.add(caso.Id);
                } else if (caso.Status == 'Rechazado' && mapOldObj.get(caso.Id).Status != 'Rechazado' && caso.CC_Fecha_Limite_Resolucion__c != null) { //Rechazo
                    caso.CC_Tramo_TRZ__c = 'Cerrada';
                    casosCierre.add(caso.Id);
                }
            }
        }
        if (!casosAsignacion.isEmpty()) {
            CC_Trazabilidad_Methods.altaPaso('Asignacion', '', casosAsignacion);
        }
        if (!casosResolucion.isEmpty()) {
            CC_Trazabilidad_Methods.altaPaso('Resolucion', '', casosResolucion);
        }
        if (!casosCierre.isEmpty()) {
            CC_Trazabilidad_Methods.altaPaso('Cierre',     '', casosCierre);
        }
    }
    
    private void gestionEntitlementsCAM(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM){
        
        Set<Id> casesCloseMilestoneSet = new Set<Id>();
        
        for(Case caso : listNewObj){
            
            if(idsCAM.contains(caso.Id) ) {
                Case oldCase = mapOldObj.get(caso.Id);
                
                //Si el propietario cambia y es un usuario
                if(oldCase.OwnerId != caso.OwnerId && String.valueOf(caso.OwnerId).startsWith('005')){
                    caso.AM_Fecha_ultima_toma_propiedad__c = System.now();
                }
                //Si el propietario cambia a usuario y el anterior era grupo, cerramos milestones
                if(oldCase.OwnerId != caso.OwnerId && String.valueOf(caso.OwnerId).startsWith('005') && String.valueOf(oldCase.OwnerId).startsWith('00G')){
                    if(!casesCloseMilestoneSet.contains(caso.Id))casesCloseMilestoneSet.add(caso.Id);
                }
                //Recogemos los casos que se cierran para cerrar sus milestones
                if(oldCase.Status!=caso.Status && (caso.Status=='Cerrado' || caso.Status=='Rechazado')){
                    if(!casesCloseMilestoneSet.contains(caso.Id))casesCloseMilestoneSet.add(caso.Id);
                }
            }
        }
        if(!casesCloseMilestoneSet.isEmpty()){
            List<CaseMilestone> milestonesEnCurso = [SELECT CompletionDate, TargetDate, CaseId FROM CaseMilestone WHERE CaseId=:casesCloseMilestoneSet AND CompletionDate = null];
            
            for(CaseMilestone caseMilest: milestonesEnCurso){
                caseMilest.CompletionDate=system.now();
            }
            Update milestonesEnCurso;
        }
    }
    
    private static List<Id> obtenerIdsCAM(List<Case> casos) {
        List<Id> idsCAM = new List<Id>();
        for (Case caso : casos) {
            if (caso.RecordTypeId != null //Necesario ya que en ocasiones el caso aún no tiene RT al hacer insert
            && Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName().startsWith('AM_')) {
                idsCAM.add(caso.Id);
            }
        }
        return idsCAM;
    }
    
    
    private static void vincularCasoOrigen(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        Id idRecordTypeCcCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        List<Id> idCasosEvaluar = new List<Id>();
        for (Case casoNew : listNewObj) {
            if (casoNew.RecordTypeId == idRecordTypeCcCliente
            && (casoNew.CC_MCC_Tematica__c != mapOldObj.get(casoNew.Id).CC_MCC_Tematica__c || casoNew.ContactId != mapOldObj.get(casoNew.Id).ContactId)
            && String.isNotBlank(casoNew.ContactId)
            && String.isNotBlank(casoNew.CC_MCC_Tematica__c)
            && String.isBlank(mapOldObj.get(casoNew.Id).CC_Caso_Origen__c)
            && !casoNew.CC_No_Identificado__c) {
                idCasosEvaluar.add(casoNew.Id);
            }
        }
        if (!idCasosEvaluar.isEmpty()) {
            CC_Case.vincularCasoOrigen(idCasosEvaluar);
        }
    }
    
    //US932544 parte 1
    private void comprobarCambioNivel(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM){
        Id idRtCasoEmpleado =CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case','CC_Empleado');
        for (Case caso : listNewObj) {
         if(caso.RecordTypeId == idRtCasoEmpleado) {
            
             	//Relleno del campo Fecha Traslado 2N
             	// 6a. y 8a. en CaseTriggerHelpercambiosEstadoPendiente
             	// // 5.
        	if (((mapOldObj.get(caso.Id).status == 'Cerrado' || mapOldObj.get(caso.Id).status == 'Rechazado') && caso.status == 'Activo' && caso.CC_En_Segundo_Nivel__c == true)) 
        	{
				caso.CC_Fecha_Traslado_2N__c = System.now(); 

                //Relleno del campo Fecha Traslado 3N
                // 3. en CC_Llamada_GC -> traspasarTercerNivel  
                	// 6a. y 7a. en CaseTriggerHelpercambiosEstadoPendiente
                	// 4. 
			}else if ((mapOldObj.get(caso.Id).status == 'Cerrado' || mapOldObj.get(caso.Id).status == 'Rechazado') && caso.status == 'Activo' && caso.CC_En_Tercer_Nivel__c == true) 
        	{
				caso.CC_Fecha_Traslado_3N__c  = System.now();  
            
                //Relleno del campo Fecha Traslado 1N
                // 1. 
			}else if ((caso.CC_En_Tercer_Nivel__c == false && caso.CC_En_Segundo_Nivel__c == false && caso.CC_Fecha_Traslado_1N__c == null)
                       // 2. 
                     || ((mapOldObj.get(caso.Id).status == 'Cerrado' || mapOldObj.get(caso.Id).status == 'Rechazado')
                      && caso.status == 'Activo' 
                      && caso.CC_En_Segundo_Nivel__c == false 
                      && caso.CC_En_Tercer_Nivel__c == false)
                      // 7a. y 8a. 
                      || ((mapOldObj.get(caso.Id).CC_En_Tercer_Nivel__c == true || mapOldObj.get(caso.Id).CC_En_Segundo_Nivel__c == true)
                      && (caso.CC_En_Segundo_Nivel__c == false && caso.CC_En_Tercer_Nivel__c == false)))
                      {
			caso.CC_Fecha_Traslado_1N__c  = System.now();
			}
          }
        }
    }
    //US932544 parte 2
    private void calculoTiempoNiveles(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM){
        Id idRtCasoEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case','CC_Empleado');
        Datetime ahora = DateTime.now();
                
        for (Case caso : listNewObj) {

            if(caso.RecordTypeId == idRtCasoEmpleado) {
        
            //Relleno del campo Tiempo Nivel 2
            // 7b.
        if((mapOldObj.get(caso.Id).CC_En_Segundo_Nivel__c == true && caso.CC_En_Segundo_Nivel__c == false)
           	// 11.
          || (mapOldObj.get(caso.Id).status != 'Cerrado' && caso.status == 'Cerrado' &&  caso.CC_En_Segundo_Nivel__c == true)){
            
            caso.CC_Tiempo_Nivel_2__c = ((caso.CC_Tiempo_Nivel_2__c==null)?0: caso.CC_Tiempo_Nivel_2__c) + ((ahora.getTime() - mapOldObj.get(caso.Id).CC_Fecha_Traslado_2N__c.getTime())/1000);
            
              //Relleno del campo Tiempo Nivel 3
              // 8b.
        		}else if ((mapOldObj.get(caso.Id).CC_En_Tercer_Nivel__c == true && caso.CC_En_Tercer_Nivel__c == false) 
              // 12.
                   || (mapOldObj.get(caso.Id).status != 'Cerrado' && caso.status == 'Cerrado' &&  caso.CC_En_Tercer_Nivel__c == true)) {
            
            		caso.CC_Tiempo_Nivel_3__c = ((caso.CC_Tiempo_Nivel_3__c==null)?0: caso.CC_Tiempo_Nivel_3__c) + ((ahora.getTime() - mapOldObj.get(caso.Id).CC_Fecha_Traslado_3N__c.getTime())/1000);
            
              //Relleno del campo Tiempo Nivel 1
              //6b.
        		}else if ((mapOldObj.get(caso.Id).status == 'Activo' && caso.status == 'Pendiente Interno' 
                  	&& (mapOldObj.get(caso.Id).CC_En_Segundo_Nivel__c == false && mapOldObj.get(caso.Id).CC_En_Tercer_Nivel__c == false) 
                  	&& (caso.CC_En_Tercer_Nivel__c == true || caso.CC_En_Segundo_Nivel__c == true))
              //10.     
                 	|| (mapOldObj.get(caso.Id).status == 'Activo' && caso.status == 'Cerrado' 
                  	&& mapOldObj.get(caso.Id).CC_En_Tercer_Nivel__c == false 
                  	&& mapOldObj.get(caso.Id).CC_En_Segundo_Nivel__c == false)
                  	){
                    caso.CC_Tiempo_Nivel_1__c = ((caso.CC_Tiempo_Nivel_1__c==null)?0: caso.CC_Tiempo_Nivel_1__c) + ((ahora.getTime() - mapOldObj.get(caso.Id).CC_Fecha_Traslado_1N__c.getTime())/1000);
             }   
            }
        }
    }
    
}