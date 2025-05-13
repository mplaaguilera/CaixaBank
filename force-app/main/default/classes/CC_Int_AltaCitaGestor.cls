public with sharing class CC_Int_AltaCitaGestor {
    
    public class AltaContacto {
        public String empleadoEx; 
        public String centroEx; 
        public String origen; 
        public String asunto; 
        public String fecContacto; 
        public String horaIni; 
        public String horaFin; 
        public String medio; 
        public String estado; 
        public String numper; 
        public String nomCli; 
        public String dispGestor; 
    }
    
    public class RespuestaAltaContacto {
        public String resultat;
        public String empleCont;
        public String numCont;
        public String txtError;
    } 
    
    public static Map<String, String> altaCitaGestor(String recordId, String empleadoEx, String nombreGestor, String centroEx, String asunto, String fecContacto, String horaIni, String medio) {
        Map<String, String> resultadoAltaCitaGestor = new Map<String, String>();
        String numperso;
        String mensaje = '';
        Decimal numpersoDecimal;
        CC_Settings__c configuracionToast = CC_Settings__c.getValues('CC_OperativaOficina');
        Account cuenta = new Account();
        String endpoint;
        String statusCode;
        String entrada;
        String error;
        String salida;
        Boolean finOk = false;
        Case[] caso = [SELECT Account.CC_Numperso__c, OwnerId, Account.Name, Account.AV_OficinaPrincipal__c, Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c FROM Case WHERE Id =: recordId];
        CC_Lista_Valores__c listaValorTareaCita = [SELECT Id, CC_Activa__c, CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE Name = 'Texto cita o tarea existe' LIMIT 1];
        Boolean existenTareasCitas = CC_Activity.identificarTareasCitasExistentes( caso[0], listaValorTareaCita);
        if(!caso.isEmpty()) {
            if(!existenTareasCitas){

                numperso = caso[0].Account.CC_Numperso__c;
                numpersoDecimal = Decimal.valueOf(numperso);
                
                Date fechaIniDate = Date.valueOf(fecContacto);
                String[] timeSplit = horaIni.split(':');
                Time horaIniTime = Time.newInstance(Integer.valueOf(timeSplit[0]),
                                                    Integer.valueOf(timeSplit[1]),
                                                    0,                            
                                                    0);  
                Datetime fechaIniDateTime = Datetime.newInstance(fechaIniDate,horaIniTime);
                String fecContactoFormato = fechaIniDateTime.format('ddMMyyyy'); //Llega con formato 2022-06-23
                
                String horaIniFormato = horaIni.replace(':', ''); //Llega con formato 09:30
                
                Datetime horaFin = fechaIniDateTime.addMinutes(30);
                String horaFinFormato = horaFin.format('HHmm');
                
                AltaContacto datosCita = crearDatosCita(empleadoEx, centroEx, asunto, fecContactoFormato, horaIniFormato, horaFinFormato, medio, numperso, caso[0].Account.Name);
                String bodyRequestAltaCita = JSON.serialize(datosCita);
                
                CC_InterfaceSettings__mdt configAltaCitaMdt = CC_MetodosUtiles.getInterfazConfigBody('CC_Int_AltaCitaGestor');
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(configAltaCitaMdt.CC_EndPoint__c);
                req.setClientCertificateName(configAltaCitaMdt.CC_Certificado__c);
                req.setMethod(configAltaCitaMdt.CC_TipoPeticion__c);
                req.setHeader('x-absis-customerInternalId', CC_MetodosUtiles.decimalToHex(numpersoDecimal));
                req.setHeader('Content-Type', configAltaCitaMdt.CC_ContentType__c);
                //Descomentar la linea del actor SOLO PARA DEVSER2  para que no falle el llamado.
                //req.setHeader('HTTP-HEADER-ACTOR', 'CBCCSF');
                req.setBody(bodyRequestAltaCita);
                endpoint = String.valueOf(req.getEndpoint()).right(94);
                entrada = 'CC_Numperso__c : ' + numpersoDecimal + ' Hexa: ' + CC_MetodosUtiles.decimalToHex(numpersoDecimal);
                
                Http http = new Http();
                HTTPResponse respuesta = http.send(req);
                statusCode = String.valueOf(respuesta.getStatusCode());
                salida = String.valueOf(respuesta.getBody());

                if(String.isNotBlank(respuesta.getBody()) && respuesta.getStatusCode() == 200){
                    RespuestaAltaContacto resultadoAltaContacto = (RespuestaAltaContacto) System.JSON.deserialize(respuesta.getBody(), RespuestaAltaContacto.class);
                    resultadoAltaCitaGestor.put('resultat', resultadoAltaContacto.resultat);
                    resultadoAltaCitaGestor.put('txtError', resultadoAltaContacto.txtError);

                    if(medio == '42') {
                        mensaje = configuracionToast.CC_Configuracion_12__c.replace('XX:XX', horaIni);
                        mensaje = mensaje.replace('XX', fecContacto);
                    } else {
                        mensaje = configuracionToast.CC_Configuracion_14__c.replace('XX:XX', horaIni);
                        mensaje = mensaje.replace('XX', fecContacto);
                    }
                    resultadoAltaCitaGestor.put('mensaje', mensaje);
                    resultadoAltaCitaGestor.put('cuenta', caso[0].Account.AV_OficinaPrincipal__c);
                    
                    //Si OK crear tarea para dejar constancia de que se ha solicitado la cita correctamente
                    if(resultadoAltaContacto.resultat == 'OK') {
                        Task tarea = new Task();
                        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
                        tarea.Subject = 'Cita gestor solicitada correctamente';
                        tarea.Description = 'Se ha generado la cita correctamente.' + '\n' + '\n';
                        tarea.Description += 'Asunto: ' + asunto + '\n';
                        tarea.Description += 'Fecha: ' + fechaIniDateTime.format('dd-MM-yyyy') + '\n';
                        tarea.Description += 'Hora: ' + horaIni + '-' + horaFin.format('HH:mm') + '\n';
                        tarea.Description += 'Gestor: ' + nombreGestor + '\n';
                        tarea.Status = 'Completed';
                        tarea.Priority = 'Normal';
                        tarea.ActivityDate = date.today();
                        tarea.WhatId = recordId;
                        tarea.OwnerId = caso[0].OwnerId;
                        tarea.Type = 'Cita gestor';
                        insert tarea;
                        CBK_Activity_Extension__c tareaExtension = new CBK_Activity_Extension__c();
                        tareaExtension.CC_Tipo_de_cita__c = medio == String.valueOf(42) ? 'Cita presencial' : 'Cita telefónica';
                        tareaExtension.AV_ActivityId__c = tarea.Id;
                        insert tareaExtension;
                        finOk = true;
                    }
                } else {
                    error = 'El proceso de consulta de alta de cita ha funcionado pero no se ha obtenido una respuesta válida.';
                    salida = String.valueOf(resultadoAltaCitaGestor.get('resultat'));
                    finOk = false;
                    throw new DefaultException('El proceso de consulta de alta de cita ha funcionado pero no se ha obtenido una respuesta válida. Por favor, vuelva a intentarlo o póngase en contacto con su administrador. ');
                }
            }else{
                resultadoAltaCitaGestor.put('textoTareaCitaCreada', listaValorTareaCita.CC_Mensajes_Mostrar__c);
                resultadoAltaCitaGestor.put('existeTareaCitaCreada', 'true');
            }
        }

        CC_TrazaInt__c traza = CC_TrazaInt.generarTraza('CC_Int_ObtInfCarterizaCliente', endpoint, statusCode, entrada, error, salida, finOK);
        if(traza != null){
            insert traza;
        }
        return resultadoAltaCitaGestor;
    }
    
    public static AltaContacto crearDatosCita(String empleadoEx, String centroEx, String asunto, String fecContacto, String horaIni, String horaFin, String medio, String numper, String nomCli) {
        AltaContacto datosCita = new AltaContacto();
        datosCita.empleadoEx = empleadoEx; //'56530';
        datosCita.centroEx = centroEx; //'00615';
        datosCita.origen = 'P'; 
        datosCita.asunto = asunto; //'ASUNTO';
        datosCita.fecContacto = fecContacto; //'17062022';
        datosCita.horaIni = horaIni; //'1100';
        datosCita.horaFin = horaFin; //'1130';
        datosCita.medio = medio; //'41';
        datosCita.estado = 'A'; 
        datosCita.numper = numper; //'33384823';
        datosCita.nomCli = nomCli; //'CLIENTE';
        datosCita.dispGestor = 'S'; 
        return datosCita;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getUrlNumeroOficina(Id recordId) {
        String hostnameEntero = String.valueOf(System.Url.getOrgDomainUrl());
        String hostnameSubstring1 = hostnameEntero.remove('Url:[delegate=');
        String hostnameLimpio = hostnameSubstring1.remove(']');
        Account cuenta = [SELECT CC_Numero_Oficina__c FROM Account WHERE Id = :recordId LIMIT 1];
        String url = hostnameLimpio + '/lightning/r/Account/' + cuenta.Id + '/view';
        return new Map<String, String>{'numeroOficina' => cuenta.CC_Numero_Oficina__c, 'url' => url};
    }
    
    private class DefaultException extends Exception {}
}