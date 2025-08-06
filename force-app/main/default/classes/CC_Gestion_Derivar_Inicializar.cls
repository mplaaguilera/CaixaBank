public with sharing class CC_Gestion_Derivar_Inicializar {
  
    public static Map<String, Object> getDatos(Id recordId, Boolean otpDerivar) {
        if (String.isBlank(recordId)) {
            return null;
        } else {
            Map<String, Object> retorno = new Map<String, Object>();
            Case caso = CC_Gestion_Derivar_Global.obtenerCaso(recordId);
            retorno.put('casoActual', caso);
            Map<String, Object> textosMap = CC_MetodosUtiles.getLOVNameValue(new List<String>{'Textos operativa Derivar'}, 'CC_Mensajes_Mostrar__c');          
            Map<String, String> gestorGenerico = CC_MetodosUtiles.buscarGestorGenerico();
            String gestorGenericoName = gestorGenerico.get('nombre');
            CC_Settings__c consultarGestorPool = CC_Settings__c.getValues('CC_Configuracion_Cita_Rapida');

            CC_Gestion_Derivar_Global.inicializarVariables(caso, otpDerivar, retorno, textosMap, consultarGestorPool);            
            CC_Gestion_Derivar_Global.rellenarAlerta(caso, retorno, otpDerivar);
            
            Boolean ambitoCSBD = (Boolean) retorno.get('ambitoCSBD');
            String ambitoMotivo = (String) retorno.get('ambitoMotivo');
            Boolean ambitoFraude = (Boolean) retorno.get('ambitoFraude');

            //Lista de Ambitos que se remiten automaticamente a su grupo colaborador asignado
            List<String> ambitosRemitidos = CC_Settings__c.getValues('CC_DerivacionRemitidosAutomaticos').CC_Configuracion_1__c.split(';');

            //Lista de Ambitos que tiene pririoridad aunque no sea cliente
            List<String> ambitosPrioridadNoClientes = CC_Settings__c.getValues('CC_AmbitosPrioridadSobreNoClientes').CC_Configuracion_1__c.split(';');

            Boolean ambitoAccionistas = retorno.get('ambitoMotivo') == 'Accionistas' ? true : false;

            if(caso.Account.AV_Confidencial__c && !caso.CC_En_Segundo_Nivel__c && !caso.CC_En_Tercer_Nivel__c && otpDerivar == null) {
                CC_Gestion_Derivar_Global.rellenarDatosClienteConfidencial(retorno, textosMap, caso, gestorGenericoName, consultarGestorPool);
            } else if (caso.Account != null && caso.Account.CC_Numero_Documento__c != null && String.valueOf(caso.Account.CC_Numero_Documento__c).startsWith('H')){   // COMUNDADES DE VECINOS
                CC_Gestion_Derivar_Global.rellenarDatosComunidadesVecinos(caso, retorno, textosMap);
            }else {
                //Grupo Colaborador
                if(ambitoFraude && caso.CC_MCC_Solucion__r.CC_AmbitoTareas__c == 'Fraude') {
                    CC_Gestion_Derivar_Global.rellenarDatosFraudeSolucion(retorno, textosMap);
                }
                if(!(Boolean) retorno.get('ocultarModalTrasladar')){
                    List<CC_MCC_Grupo_Colaborador__c> listaGrupoColaborador = CC_Gestion_Derivar_Global.obtenerListaGrupoColaborador(caso);
                    if(!listaGrupoColaborador.isEmpty() && otpDerivar == null) {
                        CC_Gestion_Derivar_Global.rellenarDatosGrupoColaborador(listaGrupoColaborador, retorno, textosMap);
                    }            
                }
                retorno.put('otpDerivar', otpDerivar);
                //Chequear por MOTIVO
                if(!caso.Account.AV_Cliente__c && otpDerivar == null && (caso.Account.Recordtype.Developername == 'CC_ClientePA'|| caso.Account.Recordtype.Developername == 'CC_Cliente') && !ambitoAccionistas && !ambitosPrioridadNoClientes.contains(ambitoMotivo)) {
                    CC_Gestion_Derivar_Global.rellenarDatosCliente(retorno);
                } else if (ambitoAccionistas){
                    CC_Gestion_Derivar_Global.rellenarDatosAmbitoAccionistas(caso, retorno, textosMap);
                } else if(ambitoMotivo == 'Cambio de oficina') {
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
                } else if (ambitoMotivo == 'Onboarding' || ambitoMotivo == 'Desistir') {
                    CC_Gestion_Derivar_Global.rellenarDatosOnboarding(caso, retorno, textosMap);
                } else if ((ambitoMotivo == 'Bizum Fraude' || ambitoMotivo == 'Caso a Fraude') && caso.CC_MCC_Solucion__r.CC_AmbitoTareas__c != 'Fraude') {
                    CC_Gestion_Derivar_Global.rellenarDatosFraude(retorno, textosMap);
                }  else if (ambitoMotivo == 'Argos Xpays') {
                    CC_Gestion_Derivar_Global.rellenarDatosArgosXpays(retorno, textosMap);
                } else if (ambitoMotivo == 'Argos General') {
                    CC_Gestion_Derivar_Global.rellenarDatosArgosGeneral(retorno, textosMap);
                } else if (ambitoMotivo == 'Phising/Smishing/Malware') {
                    CC_Gestion_Derivar_Global.rellenarDatosPhisingSmishingMalware(retorno, textosMap);
                } else if (ambitoMotivo == 'CashBack') {
                CC_Gestion_Derivar_Global.rellenarDatosCashBack(retorno, textosMap);
                } else if (ambitoMotivo == 'Refinanciación deudas') {
                CC_Gestion_Derivar_Global.rellenarDatosRefinanciacionDeudas(retorno, textosMap);
                } else if(ambitoCSBD) {
                    CC_Gestion_Derivar_Global.rellenarDatosAmbitoCSBD(caso, retorno, textosMap);   
                } else if (ambitoMotivo == 'Mecanismo de firma'){
                    CC_Gestion_Derivar_Global.rellenarDatosMecanismoFirma(caso, retorno, textosMap);
                } else if (ambitoMotivo == 'CBP'){
                    CC_Gestion_Derivar_Global.rellenarDatosCBP(caso, retorno, textosMap);//CBP    
                } else if(ambitoMotivo == 'Oficina sin tarea'){
                    CC_Gestion_Derivar_Global.rellenarDatosOficinaSinTarea(retorno, textosMap);
                } else if(ambitoMotivo == 'Colectivo vulnerable'){
                    CC_Gestion_Derivar_Global.rellenarDatosColectivosVulnerables(retorno, textosMap);
                } else if(ambitosRemitidos.contains(ambitoMotivo)){ //Lista de Ámbitos a remitir automaticamente a su grupo colaborador asignado
                    retorno.put('realizarRemitido', true);
                } else if(ambitoMotivo == 'Amenazas'){
                    CC_Gestion_Derivar_Global.rellenarDatosAmenazas(caso, retorno, textosMap);
                } else if(caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c == 'SAC' || caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c == 'SAC'){
                    CC_Gestion_Derivar_Global.rellenarDatosSAC(caso, retorno, textosMap);
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