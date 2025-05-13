public with sharing class CC_Gestion_Derivar_Inicializar {
  
    public static Map<String, Object> getDatos(Id recordId, Boolean otpDerivar) {
        if (String.isBlank(recordId)) {
            return null;
        } else {
            Map<String, Object> retorno = new Map<String, Object>();
            Case caso = CC_Gestion_Derivar_Global.obtenerCaso(recordId);
            List<CC_MCC_Grupo_Colaborador__c> listaGrupoColaborador = CC_Gestion_Derivar_Global.obtenerListaGrupoColaborador(caso);
            Map<String, Object> textosMap = CC_MetodosUtiles.getLOVNameValue(new List<String>{'Textos operativa Derivar'}, 'CC_Mensajes_Mostrar__c');          
            Map<String, String> gestorGenerico = CC_MetodosUtiles.buscarGestorGenerico();
            String gestorGenericoName = gestorGenerico.get('nombre');
            CC_Settings__c consultarGestorPool = CC_Settings__c.getValues('CC_Configuracion_Cita_Rapida');

            CC_Gestion_Derivar_Global.inicializarVariables(caso, otpDerivar, retorno, textosMap, consultarGestorPool);            
            CC_Gestion_Derivar_Global.rellenarAlerta(caso, retorno, otpDerivar);
            
            Boolean ambitoCSBD = (Boolean) retorno.get('ambitoCSBD');
            String ambitoMotivo = (String) retorno.get('ambitoMotivo');
            Boolean ambitoFraude = (Boolean) retorno.get('ambitoFraude');


            
            if(caso.Account.AV_Confidencial__c && otpDerivar == null) {
                retorno.put('toastTrasladar3N', textosMap.get('Toast traslado 3N confidencial'));
            } else {
                //Grupo Colaborador
                if(!listaGrupoColaborador.isEmpty() && otpDerivar == null) {
                    CC_Gestion_Derivar_Global.rellenarDatosGrupoColaborador(listaGrupoColaborador, retorno, textosMap);
                }

                //Chequear por MOTIVO
                if(!caso.Account.AV_Cliente__c && otpDerivar == null && (caso.Account.Recordtype.Developername == 'CC_ClientePA'|| caso.Account.Recordtype.Developername == 'CC_Cliente')) {
                    CC_Gestion_Derivar_Global.rellenarDatosCliente(retorno);
                } else if(ambitoFraude && caso.CC_MCC_Solucion__r.CC_AmbitoTareas__c == 'Fraude') {
                    CC_Gestion_Derivar_Global.rellenarDatosFraudeSolucion(retorno, textosMap);
                } else if(ambitoMotivo == '' || ambitoMotivo == null) {
                    CC_Gestion_Derivar_Global.rellenarDatosOficinaNull(retorno, consultarGestorPool);
                }else if(ambitoMotivo == 'Ventas' || ambitoMotivo == 'Oficina'){
                    CC_Gestion_Derivar_Global.rellenarDatosVentaOficina(retorno);
                }else if(ambitoMotivo == 'Cambio de oficina') {
                    CC_Gestion_Derivar_Global.rellenarDatosCambioOficina(caso, retorno, textosMap);
                } else if(ambitoMotivo == 'Cambio de gestor') {
                    CC_Gestion_Derivar_Global.rellenarDatosCambioGestor(caso, retorno, textosMap);
                } else if(ambitoMotivo == 'Cajeros') {
                    CC_Gestion_Derivar_Global.rellenarDatosCajeros(retorno, textosMap);
                } else if(ambitoMotivo == 'Cajeros Incidencias') {
                    CC_Gestion_Derivar_Global.rellenarDatosCajerosIncidencias(caso, retorno, textosMap);
                } else if(ambitoMotivo == 'Testamentaría') {                
                    CC_Gestion_Derivar_Global.rellenarDatosTestamentaria(retorno, textosMap);
                } else if(ambitoMotivo == 'Vidacaixa' || ambitoMotivo == 'CaixaBank Talks') {
                    retorno.put('realizarRemitido', true);
                } else if(ambitoMotivo == 'No clientes') {
                    CC_Gestion_Derivar_Global.rellenarDatosNoCliente(retorno, textosMap);
                } else if(ambitoMotivo == 'Hub Imagin') {
                    retorno.put('hubImagin', true);                   
                } else if(ambitoMotivo == 'Oficina física') {
                    CC_Gestion_Derivar_Global.rellenarDatosOficinaFisica(caso, retorno);
                } else if(ambitoMotivo == 'Documentación') {
                    CC_Gestion_Derivar_Global.rellenarDatosDocumentacion(caso, retorno, textosMap);
                } else if (ambitoMotivo == 'Onboarding') {
                    CC_Gestion_Derivar_Global.rellenarDatosOnboarding(caso, retorno);
                } else if ((ambitoMotivo == 'Bizum Fraude' || ambitoMotivo == 'Caso a Fraude') && caso.CC_MCC_Solucion__r.CC_AmbitoTareas__c != 'Fraude') {
                    CC_Gestion_Derivar_Global.rellenarDatosFraude(retorno, textosMap);
                }  else if (ambitoMotivo == 'Argos Xpays') {
                    CC_Gestion_Derivar_Global.rellenarDatosArgosXpays(retorno, textosMap);
                } else if (ambitoMotivo == 'Argos General') {
                    CC_Gestion_Derivar_Global.rellenarDatosArgosGeneral(retorno, textosMap);
                } else if (ambitoMotivo == 'Phising/Smishing/Malware') {
                    CC_Gestion_Derivar_Global.rellenarDatosPhisingSmishingMalware(retorno, textosMap);
                } else if(ambitoCSBD) {
                    CC_Gestion_Derivar_Global.rellenarDatosAmbitoCSBD(caso, retorno, textosMap);   
                } else if (ambitoMotivo == 'Mecanismo de firma'){
                    CC_Gestion_Derivar_Global.rellenarDatosMecanismoFirma(caso,retorno, textosMap);   
                }

                //Gestion Ambito VENTAS
                Boolean ambitoVentas = (Boolean) retorno.get('ambitoVentas');
                if(ambitoVentas) {
                   CC_Gestion_Derivar_Global.rellenarDatosAmbitoVentas(caso, retorno, gestorGenericoName, consultarGestorPool,textosMap);
                }
            }

            CC_Gestion_Derivar_Global.rellenarNumeroOficina(caso, retorno);
            CC_Gestion_Derivar_Global.rellenarDatosGenerales(caso, retorno, textosMap, gestorGenericoName);
           
            return retorno;
        }
    }
}