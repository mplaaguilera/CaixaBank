/*****************************************************************
 * Name: SAC_LCMP_BusquedaCliente
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Testear el componente SAC_BusquedaCliente
 * Este clase se cubre con los siguientes test:
 * SAC_LCMP_BusquedaCliente_Test
 * SAC_LCMP_BusquedaSecundaria_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0                             Alexandre Pérez  20/11/2023   Creación
 * 1.1                             Alexandre Pérez  18/01/2024   tener en cuenta solo las pretensiones en estado Cerrado
****************************************************************/
public with sharing class SAC_GenialResultado_Batch implements Database.Batchable<sObject> {

    public SAC_GenialResultado_Batch() {
        //clase constructora necesaria para el fwk
        cbk_log.debug('SAC_GenialResultado_Batch constructor');
    }
    //mapa para saber al final del proceso el número de pretensiones totales ya que pueden caer en otras instancias del batch  

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //hacer una select para ver la última vez que se ejecutó
        return Database.getQueryLocator([SELECT Id, SAC_AccountId__c, SAC_EmailRepresentante__c, SAC_CodigoPostalRepresentante__c,SAC_DespachoRepresentante__c, 
        SAC_Detalle__c, SAC_DireccionRepresentante__c, SAC_EsPrincipal__c, SAC_FechaRecepcion__c, SAC_Idioma__c, SAC_Naturaleza__c, SAC_SuppliedNIF__c,
        SAC_Importe_Tipo__c, SAC_Importe_Reclamado__c, SAC_MCC_Motivo__c, SAC_NombreRepresentante__c, SAC_NumeroDelDocumento__c, SAC_Oficina_Afectada_Lookup__c,
        SAC_PaisRepresentante__c, SAC_PoblacionRepresentante__c, SAC_PretensionPrincipal__c, SAC_ProvinciaRepresentante__c, SAC_TelefonoRepresentante__c,
        SAC_MCC_Tematica__c, SAC_TipoDeDocumento__c, SAC_TipoDeRepresentante__c, SAC_MCC_ProdServ__c, SAC_Reclamacion__c, recordtypeId,
        SAC_Reclamacion__r.Id, SAC_Reclamacion__r.AccountId, SAC_Reclamacion__r.SAC_EmailRepresentante__c, SAC_Reclamacion__r.SAC_CodigoPostalRepresentante__c,
        SAC_Reclamacion__r.SAC_DespachoRepresentante__c, SAC_Reclamacion__r.SEG_Detalle__c, SAC_Reclamacion__r.SAC_DireccionRepresentante__c, 
        SAC_Reclamacion__r.SAC_EsPrincipal__c, SAC_Reclamacion__r.SAC_FechaRecepcion__c, SAC_Reclamacion__r.CC_Idioma__c, SAC_Reclamacion__r.SAC_Naturaleza__c, 
        SAC_Reclamacion__r.CC_SuppliedNIF__c, SAC_Reclamacion__r.SAC_Importe_Tipo__c, SAC_Reclamacion__r.CC_Importe_Reclamado__c, SAC_Reclamacion__r.CC_MCC_Motivo__c, 
        SAC_Reclamacion__r.SAC_NombreRepresentante__c, SAC_Reclamacion__r.SAC_NumeroDelDocumento__c, SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__c,
        SAC_Reclamacion__r.SAC_PaisRepresentante__c, SAC_Reclamacion__r.SAC_PoblacionRepresentante__c, SAC_Reclamacion__r.SAC_PretensionPrincipal__c, 
        SAC_Reclamacion__r.CC_MCC_ProdServ__c, SAC_Reclamacion__r.SAC_ProvinciaRepresentante__c, SAC_Reclamacion__r.SAC_TelefonoRepresentante__c,
        SAC_Reclamacion__r.CC_MCC_Tematica__c, SAC_Reclamacion__r.SAC_TipoDeDocumento__c, SAC_Reclamacion__r.SAC_TipoDeRepresentante__c
        FROM SAC_Genial_Resultado__c 
        //WHERE SAC_Reclamacion__r.ClosedDate = YESTERDAY AND SA]C_Reclamacion__r.Status = 'Cerrado'
        WHERE recordtype.developername = 'SAC_Reclamacion_IA' AND  SAC_Procesado__c = false AND SAC_Reclamacion__r.Status = 'Cerrado']);
    }

    public void execute(Database.BatchableContext bc, list<SAC_Genial_Resultado__c> scope){
        //set<Id> listaCasos = new set<Id>();
        cbk_log.debug('SAC_GenialResultado_Batch execute');
        map<Id, case> mapaReclamaciones = new map<Id, case>();
        map<Id, SAC_Genial_Resultado__c> mapaResultadoReclama = new map<Id, SAC_Genial_Resultado__c>();
        //map<Id, list<SAC_Genial_Resultado__c>> mapaResultadoPretension = new map<Id, list<SAC_Genial_Resultado__c>>();
        //map<Id, map<string,integer>> mapaConteo = new map<Id, map<string,integer>>();
        case reclama;

        for(SAC_Genial_Resultado__c resultado : scope){
            //if(!mapaReclamaciones.containsKey(resultado.SAC_Reclamacion__r.Id)) {

            //hacemos query al objeto case para usar luego el casteador en la funcion comparadora dentro de genialUtils
            //rt de la reclamación en el objeto de resultado
            //String recResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion_IA').getRecordTypeId();
            //rt de la pretensión en el objeto de resultado
            //String pretResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Pretension_IA').getRecordTypeId();
            reclama = new case(
                Id = resultado.SAC_Reclamacion__c,
                AccountId = resultado.SAC_Reclamacion__r.AccountId,
                SAC_EmailRepresentante__c = resultado.SAC_Reclamacion__r.SAC_EmailRepresentante__c,
                SAC_CodigoPostalRepresentante__c = resultado.SAC_Reclamacion__r.SAC_CodigoPostalRepresentante__c,
                SAC_DespachoRepresentante__c = resultado.SAC_Reclamacion__r.SAC_DespachoRepresentante__c,
                SEG_Detalle__c = resultado.SAC_Reclamacion__r.SEG_Detalle__c,
                SAC_DireccionRepresentante__c = resultado.SAC_Reclamacion__r.SAC_DireccionRepresentante__c,
                SAC_EsPrincipal__c = resultado.SAC_Reclamacion__r.SAC_EsPrincipal__c,
                SAC_FechaRecepcion__c = resultado.SAC_Reclamacion__r.SAC_FechaRecepcion__c,
                CC_Idioma__c = resultado.SAC_Reclamacion__r.CC_Idioma__c,
                SAC_Naturaleza__c = resultado.SAC_Reclamacion__r.SAC_Naturaleza__c,
                CC_SuppliedNIF__c = resultado.SAC_Reclamacion__r.CC_SuppliedNIF__c,
                SAC_Importe_Tipo__c = resultado.SAC_Reclamacion__r.SAC_Importe_Tipo__c,
                CC_Importe_Reclamado__c = resultado.SAC_Reclamacion__r.CC_Importe_Reclamado__c,
                CC_MCC_Motivo__c = resultado.SAC_Reclamacion__r.CC_MCC_Motivo__c,
                SAC_NombreRepresentante__c = resultado.SAC_Reclamacion__r.SAC_NombreRepresentante__c,
                SAC_NumeroDelDocumento__c = resultado.SAC_Reclamacion__r.SAC_NumeroDelDocumento__c,
                CC_Oficina_Afectada_Lookup__c = resultado.SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__c,
                SAC_PaisRepresentante__c = resultado.SAC_Reclamacion__r.SAC_PaisRepresentante__c,
                SAC_PoblacionRepresentante__c = resultado.SAC_Reclamacion__r.SAC_PoblacionRepresentante__c,
                SAC_PretensionPrincipal__c = resultado.SAC_Reclamacion__r.SAC_PretensionPrincipal__c,
                CC_MCC_ProdServ__c = resultado.SAC_Reclamacion__r.CC_MCC_ProdServ__c,
                SAC_ProvinciaRepresentante__c = resultado.SAC_Reclamacion__r.SAC_ProvinciaRepresentante__c,
                SAC_TelefonoRepresentante__c = resultado.SAC_Reclamacion__r.SAC_TelefonoRepresentante__c,
                CC_MCC_Tematica__c = resultado.SAC_Reclamacion__r.CC_MCC_Tematica__c,
                SAC_TipoDeDocumento__c = resultado.SAC_Reclamacion__r.SAC_TipoDeDocumento__c,
                SAC_TipoDeRepresentante__c = resultado.SAC_Reclamacion__r.SAC_TipoDeRepresentante__c            
            );
            mapaReclamaciones.put(reclama.Id, reclama);
            mapaResultadoReclama.put(resultado.SAC_Reclamacion__c, resultado); 
            /*if(resultado.recordTypeId == recResRT) {
                //por cada reclamacion sólo puede haber 1 caso de resultado reclamación
                mapaResultadoReclama.put(resultado.SAC_Reclamacion__c, resultado);      
            } else {
                //N casos de resultado de pretensión por reclamación
                //metemos listas de pretensiones por reclamación para hacer la comparación
                if(!mapaResultadoPretension.containsKey(resultado.SAC_Reclamacion__c)) {    
                    mapaResultadoPretension.put(resultado.SAC_Reclamacion__c, new list<SAC_Genial_Resultado__c>()); 
                }
                mapaResultadoPretension.put(resultado.SAC_Reclamacion__c, (list<SAC_Genial_Resultado__c>)mapaResultadoPretension.get(resultado.SAC_Reclamacion__c).add(resultado));
                //mapaResultadoPretension.put();
            }*/
        }

        //COMPARADOR DE PRETENSIONES
        //hacemos una query para obtener las pretensiones reales creadas (solo cerradas 1.1)
        //map<id, case> pretensionesCreadas = new list<case>();
        //lista de pretensiones creadas mapeadas por id de reclamacion
        map<id, list<case>> mapPretensionesCreadasReclama = new map<id, list<case>>();
        map<id, case> mapPretensiones = new map<id, case>();
        for(case pretension : [SELECT Id, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c, SEG_Detalle__c, SAC_Reclamacion__c, SAC_esPrincipal__c 
                                            FROM Case WHERE SAC_Reclamacion__c IN : mapaReclamaciones.KeySet() AND Status = 'Cerrado']) {
            
            if(!mapPretensionesCreadasReclama.containsKey(pretension.SAC_Reclamacion__c)) {
                mapPretensionesCreadasReclama.put(pretension.SAC_Reclamacion__c, new list<case>()); 
            }
            list<case> mapearPretensiones = mapPretensionesCreadasReclama.get(pretension.SAC_Reclamacion__c);
            mapearPretensiones.add(pretension);
            mapPretensionesCreadasReclama.put(pretension.SAC_Reclamacion__c, mapearPretensiones);
            mapPretensiones.put(pretension.Id, pretension);
        }

        map<id, list<SAC_Genial_Resultado__c>> mapPreResultadoCreadasReclama = new map<id, list<SAC_Genial_Resultado__c>>();
        map<id, SAC_Genial_Resultado__c> mapPreResultados = new map<id, SAC_Genial_Resultado__c>();
        for(SAC_Genial_Resultado__c pretResultado : [SELECT Id, SAC_MCC_Motivo__c, SAC_MCC_ProdServ__c, SAC_MCC_Tematica__c, SAC_Detalle__c, SAC_Reclamacion__C,
                                            SAC_Pretension__c, SAC_esPrincipal__c 
                                            FROM SAC_Genial_Resultado__c WHERE SAC_Reclamacion__c IN : mapaReclamaciones.KeySet() AND recordType.developerName = 'SAC_Pretension_IA']) {

            if(!mapPreResultadoCreadasReclama.containsKey(pretResultado.SAC_Reclamacion__c)) {    
                mapPreResultadoCreadasReclama.put(pretResultado.SAC_Reclamacion__c, new list<SAC_Genial_Resultado__c>()); 
            }
            list<SAC_Genial_Resultado__c> mapearResultados = mapPreResultadoCreadasReclama.get(pretResultado.SAC_Reclamacion__c);
            mapearResultados.add(pretResultado);
            mapPreResultadoCreadasReclama.put(pretResultado.SAC_Reclamacion__c, mapearResultados);
           //mapPreResultadoCreadasReclama.put(pretResultado.id, pretResultado);
            mapPreResultados.put(pretResultado.id, pretResultado);
        }
            
            //contamos el numero de aciertos
        map<string, integer> afinidad = new map<string, integer>();
        list<SAC_Genial_Resultado__c> updateSacResultado = new list<SAC_Genial_Resultado__c>();
        for(Id reclamacionId : mapPretensionesCreadasReclama.keySet()){
            integer pretensionesOK = 0;
            //integer pretensionesIA = mapPreResultadoCreadasReclama.isEmpty() ? 0 : mapPreResultadoCreadasReclama.get(reclamacionId).size();
            mapaResultadoReclama.get(reclamacionId).SAC_Numero_Pretensiones_IA__c = !mapPreResultadoCreadasReclama.containsKey(reclamacionId) ? 0 : mapPreResultadoCreadasReclama.get(reclamacionId).size();
            //integer pretensionesReales = mapPretensionesCreadasReclama.isEmpty() ? 0 : mapPretensionesCreadasReclama.get(reclamacionId).size();
            mapaResultadoReclama.get(reclamacionId).SAC_Numero_total_pretensiones__c = !mapPretensionesCreadasReclama.containsKey(reclamacionId) ? 0 : mapPretensionesCreadasReclama.get(reclamacionId).size();
            map<Id, id> listaAsociaciones = new map<id, id>();
            //map<Id, id> listaAsociacionesDirectas = new map<id, id>();
            list<Id> pretensionDesasignada = new list<Id>();
            //sacar del loop de afinidad las pretensiones shadow ya afines
            list<Id> afinidadTotalList = new list<Id>();
            //integer valorMáximo = 0;

            if(mapPretensionesCreadasReclama.containskey(reclamacionId) && mapPreResultadoCreadasReclama.containskey(reclamacionId)){
                for(case pretension : mapPretensionesCreadasReclama.get(reclamacionId)){
                    //pretensionesReales++;
                    //list<Id> ignorarAsociacionAfinidad = new list<Id>();
                    /*if(pretension){

                    }*/
                    pretensionDesasignada.add(pretension.Id);
                    for(SAC_Genial_Resultado__c pretResultado : mapPreResultadoCreadasReclama.get(reclamacionId)){
                        //ya venian asociados directamente(IA Activa)
                        /*if(string.isNotBlank(pretResultado.SAC_Pretension__c)){
                            listaAsociacionesDirectas.put(pretResultado.Id, pretResultado.SAC_Pretension__c);
                        }*/
                        //buscamos una pretension compatible para aquellas que se han creado sin la asociación directa(modo shadow)
                        if(afinidadTotalList.contains(pretResultado.Id)){
                            //pasamos al siguiente ya que esta tiene ya la afinidad total y evitamos que se vuelva a contar en caso de coincidir con otra pretensión
                            continue;
                        }
                        integer numAciertos = 0;
                            //nivel maximo del acierto;
                        integer nivel = 0;
                        //marcar para salir del bucle porque no encontrará ninguna mas afín y así se evitan duplicados
                        boolean bAfinidadTotal = false;
                            //poner todos los niveles y rellenar el mapa de afinidad para luego decidir como emparejar los resultados de pretensiones
                        if(pretResultado.SAC_MCC_Motivo__c == pretension.CC_MCC_Motivo__c){
                            numAciertos++;
                            nivel = 1;
                        }
                        if(pretResultado.SAC_MCC_ProdServ__c == pretension.CC_MCC_ProdServ__c){
                            numAciertos++;
                            nivel = 2;
                        }
                        if(pretResultado.SAC_MCC_Tematica__c == pretension.CC_MCC_Tematica__c){
                            numAciertos++;
                            nivel = 3;
                        }
                        if(pretResultado.SAC_Detalle__c == pretension.SEG_Detalle__c){
                            numAciertos++;
                            nivel = 4;
                        }
                        if(numAciertos == 4){
                            pretensionesOK++;
                            bAfinidadTotal = true;
                            afinidadTotalList.add(pretResultado.Id);
                        }
                        //} //else {
                        //if() {
                            //pretensionesIA++;
                            //numero de mcc acertados
                        /*if(string.isNotBlank(pretResultado.SAC_Pretension__c)){
                            listaAsociacionesDirectas.put(pretResultado.Id, pretResultado.SAC_Pretension__c);
                        } else*/ 
                        if(numAciertos*10+nivel > 0) {
                            afinidad.put(pretension.Id+'|'+pretResultado.Id, numAciertos*10+nivel);
                            //if(valorMaximo < numAciertos*10+nivel) {
                            //    valorMaximo = numAciertos*10+nivel;
                            //if(!listaAsociaciones.containsKey(pretResultado.Id)) {
                            if(pretensionDesasignada.contains(pretension.Id)) {
                                pretensionDesasignada.remove(pretensionDesasignada.indexOf(pretension.Id));
                                listaAsociaciones.put(pretResultado.Id, pretension.Id); 
                            //si hay alguna con mayor afinidad se cambia la asignacion y se guarda la desasignada para volverla a calcular    
                            } else if (afinidad.get(listaAsociaciones.get(pretResultado.Id) + '|' + pretResultado.Id) < numAciertos*10+nivel) {
                                pretensionDesasignada.add(listaAsociaciones.get(pretension.Id));
                                listaAsociaciones.put(pretResultado.Id, pretension.Id);
                            }
                                    
                            //}
                        }

                        //salimos del primer bucle ya que no va a encontarr ninguna más afin
                        if(bAfinidadTotal){
                            break;
                        }
                       // }
                        
                    }        
                    //se da prioridad al num de aciertos y desempata el nivel
                    
                }
            }
            
            //FUNCION RECURSIVA PARA TRATAR AFINIDAD
            asignarPretensionAresultado(afinidad, pretensionDesasignada, mapPreResultadoCreadasReclama.get(reclamacionId), listaAsociaciones);
            //agregamos la lista de asociaciones que ya venian dadas para analizarlas todas juntas
            //listaAsociaciones.putAll(listaAsociacionesDirectas);
            //map<string, boolean> resultadoComparacion = new map<string, boolean>();
            for(Id resultadoId : listaAsociaciones.keySet()){
                /*resultadoComparacion = genialUtils.comparaCampos(mapPreResultados.get(resultadoId), mapPretensiones.get(listaAsociaciones.get(resultadoId)));
                if(mapPreResultados.get(resultadoId).SAC_Reclamacion__c == null){
                    mapPreResultados.get(resultadoId).SAC_Reclamacion__c = listaAsociaciones.get(resultadoId);
                }   
                mapPreResultados.get(resultadoId).SAC_Pretension_Motivo_OK__c = resultadoComparacion.get(resultadoId).SAC_MCC_Motivo__c;
                mapPreResultados.get(resultadoId).SAC_Pretension_Detalle_OK__c = resultadoComparacion.get(resultadoId);
                mapPreResultados.get(resultadoId).SAC_Pretension_Tematica_OK__c = resultadoComparacion.get(resultadoId);
                mapPreResultados.get(resultadoId).SAC_Pretension_Producto_Servicio_OK__c = resultadoComparacion.get(resultadoId);
                updateSacResultado.add(mapPreResultados.get(resultadoId));*/
                SAC_GenialUtils.comparaCamposYcasteo(mapPretensiones.get(listaAsociaciones.get(resultadoId)), mapPreResultados.get(resultadoId));
                mapPreResultados.get(resultadoId).SAC_Pretension__c = listaAsociaciones.get(resultadoId);
            }
            //COMPARADOR DE RECLAMACIONES
            SAC_GenialUtils.comparaCamposYcasteo(mapaReclamaciones.get(reclamacionId), mapaResultadoReclama.get(reclamacionId));
            mapaResultadoReclama.get(reclamacionId).SAC_Numero_pretensiones_OK__c = pretensionesOK;
            mapaResultadoReclama.get(reclamacionId).SAC_Procesado__c = true;
           // mapaResultadoReclama.get(reclamaId).SAC_Numero_total_pretensiones__c = pretensionesOK;

        }
        updateSacResultado.addAll(mapPreResultados.values());
        updateSacResultado.addAll(mapaResultadoReclama.values());

        
       /* for(Id reclamaId : mapaReclamaciones.keySet()){
            SAC_GenialUtils.comparaCamposYcasteo(mapaReclamaciones.get(reclamaId), mapaResultadoReclama.get(reclamaId));      
        }*/

        //updateSacResultado.addAll(mapaResultadoReclama.values());
            //listaCasos.add(reclama.Id);
            //listaCasos.add();
        
        //update updateSacResultado;
        Database.SaveResult[] srList = Database.update(updateSacResultado, false);
        
        boolean hasError = false;
        List<Object> objs = new List<Object>();
        Map<String, String> msjs = new Map<String, String>();
        for (Integer i = 0; i < updateSacResultado.size(); i++) {
            Database.SaveResult sr = srList[i];
            if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                msjs.put(updateSacResultado[i].Id + '_' + updateSacResultado[i].Name, ((String)sr.getErrors()[0].getMessage()));
                objs.add(updateSacResultado[i]);
                hasError = true;
            }
        }
        if(hasError) {
            CBK_Log.error(msjs, objs);
        }
    }

    public void finish(Database.BatchableContext bc){
        //nada para el finish
        cbk_log.debug('SAC_GenialResultado_Batch finish');
    }

    /*funcion recursiva para decidir la asignacion de la pretension*/
    private static void asignarPretensionAresultado(map<string, integer> afinidad, list<Id> pretensionDesasignada, list<SAC_Genial_Resultado__c> resultados, map<id, id> listaAsociaciones){
        list<Id> internaDesasignadas = new list<Id>();
        for(Id pretensionId : pretensionDesasignada){
            for(SAC_Genial_Resultado__c resultado : resultados){
                if(afinidad.get(pretensionId + '|' + resultado.id) != 0 && 
                (!listaAsociaciones.containsKey(resultado.id) || afinidad.get(pretensionId + '|' + resultado.id) > afinidad.get(listaAsociaciones.get(resultado.id) +'|'+resultado.id))){
                    if(listaAsociaciones.containsKey(resultado.id)){
                        internaDesasignadas.add(listaAsociaciones.get(resultado.id));
                    }
                    listaAsociaciones.put(resultado.id, pretensionId);
                    
                }
            }
        }
        if(!internaDesasignadas.isEmpty()){
            asignarPretensionAresultado(afinidad, internaDesasignadas, resultados, listaAsociaciones);
        }
    }


}