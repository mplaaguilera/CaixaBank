/**********************************************************************************************************************
 Name:	  CBK_FlexQueueMonitor_Schedule
 Copyright © 2021  CaixaBank
***********************************************************************************************************************
Proposito: Clase Schedulable del FW de monitorización de la cola Flex (procesos batch).
***********************************************************************************************************************
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	22/06/2021			Init version
***********************************************************************************************************************/
global with sharing class CBK_FlexQueueMonitor_Schedule implements Schedulable {
    
    /**
    * @description Metodo invocado ne la ejecución del proceso planificado 
    * @author   fzaragoza | /04/2021 
    * @param    SC  Contexto del proceso planificado (SchedulableContext)
    **/
	global void execute(SchedulableContext SC){       
        List <AggregateResult> lstBacths =new List <AggregateResult> ();
        Map<String, CBK_FlexQueueMonitorSetting__c> mapFlexQueueCS;
        CBK_FlexQueueMonitorSetting__c configFlexQueueGeneral;
        List <CBK_FlexQueueMonitor__c> registrosInsertar  = new List<CBK_FlexQueueMonitor__c>();
        Map <String, CBK_FlexQueueMonitor_Schedule.aggregateProyect> mapBatchesProyecto = new Map <String, CBK_FlexQueueMonitor_Schedule.aggregateProyect>();
        List<AsyncApexJob> lstExecBatch = new List<AsyncApexJob>();

        lstBacths = [SELECT count(id), ApexClass.Name FROM AsyncApexJob where status = 'Holding' and JobType ='BatchApex' Group by ApexClass.Name];
        for(AggregateResult agr : lstBacths){
            String prefijo = ((String)agr.get('Name')).substringBefore('_');
            Integer numeroOcurrencias = (Integer)agr.get('expr0');
            if(mapBatchesProyecto.containsKey(prefijo)){
                mapBatchesProyecto.get(prefijo).addSumatorio(numeroOcurrencias); 
            }
            else{
                mapBatchesProyecto.put(prefijo, new aggregateProyect(numeroOcurrencias,prefijo));
            }
        }
        if (Test.isRunningTest()){
            mapBatchesProyecto.put('TST', new CBK_FlexQueueMonitor_Schedule.aggregateProyect(60,'TST'));
        }
        lstExecBatch = [SELECT ApexClass.Name,Status,TotalJobItems,JobItemsProcessed,ExtendedStatus,NumberOfErrors FROM AsyncApexJob WHERE JobType='BatchApex' AND Status IN ('Processing','Preparing','Queued')];
        //recuperamos los custom settings (si no hay usaremos los valores static para el global)
        mapFlexQueueCS = CBK_FlexQueueMonitorSetting__c.getAll();
        for(CBK_FlexQueueMonitorSetting__c setting : mapFlexQueueCS.values()){
            CBK_FlexQueueMonitor__c aux = CBK_FlexQueueMonitor_Schedule.ProcesarEntradaMonitorizacion(setting,mapBatchesProyecto,lstBacths,lstExecBatch);
            registrosInsertar.add(aux);
        }
        if(registrosInsertar.size()>0){
            insert registrosInsertar;
        }
    }

    @TestVisible 
    public class aggregateProyect{
        @TestVisible integer sumatorioBatches;
        String prefijoProyecto;
        public aggregateProyect(integer valor, String prefijo){
            sumatorioBatches = valor;
            prefijoProyecto = prefijo;
        }
        public void addSumatorio(integer valor){
            sumatorioBatches += valor;
        }
    }


    /**
    * @description Constructor
    * @author   fzaragoza | 24/06/2021 
    * @param    config registro de configuración que contiene la información de la aplicación/general (CBK_FlexQueueMonitorSetting__c)
    * @param    mapBatchesProyecto  Mapa de agregados de batchs por aplicación ( Map <String, CBK_FlexQueueMonitor_Schedule.aggregateProyect>)
    * @param    lstBacthsDetail  Conjunto de entradas en flexqueue por clase Batch (List <AggregateResult>)
    * @param    lstExecBatch  Conjunto de procesos batch en ejecución (Status: 'Processing','Preparing','Queued')
	* @return	CBK_FlexQueueMonitor__c  Registro resultante de la evaluación de la monitorización de la línea
    **/
    private static CBK_FlexQueueMonitor__c ProcesarEntradaMonitorizacion(CBK_FlexQueueMonitorSetting__c config, Map <String, CBK_FlexQueueMonitor_Schedule.aggregateProyect> mapBatchesProyecto , List <AggregateResult> lstBacthsDetail, List<AsyncApexJob> lstExecBatch){
        Integer totalBatches = 0;
        Boolean noNotificar = false;
        Boolean superaUmbral = false;
        if (config.CBK_Aplicacion__c == 'General'){
            for(aggregateProyect proy : mapBatchesProyecto.values()){
                totalBatches+=proy.sumatorioBatches;
            }
        }
        else{
            if (mapBatchesProyecto.containsKey(config.CBK_PrefijoAplicacion__c)){
                totalBatches=mapBatchesProyecto.get(config.CBK_PrefijoAplicacion__c).sumatorioBatches;
            }
        }
        //revisamos el total y si está activa la notificación, se mmanda el mail (si se revisa y cumple las condiciones)
        if (config.CBK_Activo__c == true &&config.CBK_Umbral__c<= totalBatches){
            superaUmbral = true;
            //consultamos la ultimas inserciones en el intervalo, para validar si se mandó correo o hay que mandarlo
            List <CBK_FlexQueueMonitor__c> lstRegistros = CBK_FlexQueueMonitor_Schedule.recuperarEntradasPrevias(config.CBK_PrefijoAplicacion__c,config.CBK_MinsIntervaloNotif__c) ;
            
            for (CBK_FlexQueueMonitor__c regMon : lstRegistros){
                if (regMon.CBK_NotificacionRealizada__c == true){
                    noNotificar = true;
                }
            }
            if(!noNotificar){
                CBK_FlexQueueMonitor_Schedule.envioMailNotificacion(config, totalBatches, lstBacthsDetail,lstExecBatch);
            }
        }
        CBK_FlexQueueMonitor__c returnValue = new CBK_FlexQueueMonitor__c();
        returnValue.CBK_Aplicacion__c = config.CBK_Aplicacion__c;
        returnValue.CBK_PrefijoAplicacion__c = config.CBK_PrefijoAplicacion__c;
        returnValue.CBK_HoldingBatches__c = totalBatches;
        returnValue.CBK_PorcentajeConsumoUmbral__c = (config.CBK_Umbral__c>0?(totalBatches/config.CBK_Umbral__c)*100:0);
        returnValue.CBK_NotificacionNecesaria__c = superaUmbral;
        returnValue.CBK_NotificacionRealizada__c = (superaUmbral?!noNotificar:false);
        return returnValue;
    }
    
    /**
    * @description Método de notificación vía mail para registros que superen el umbral
    * @author   fzaragoza | 24/06/2021 
    * @param    config  registro de configuración que contiene la información de la aplicación/general(CBK_FlexQueueMonitorSetting__c)
    * @param    numBatches  Numero de batches asociados a la entrada de aplicación
    * @param    lstBacthsDetail  Conjunto de entradas en flexqueue por clase Batch (List <AggregateResult>)
    * @param    lstExecBatch  Conjunto de procesos batch en ejecución (Status: 'Processing','Preparing','Queued')
    **/
    private static void envioMailNotificacion(CBK_FlexQueueMonitorSetting__c config, integer numBatches, List <AggregateResult> lstBacthsDetail, List<AsyncApexJob> lstExecBatch){
        List <String> toAddresses;
        List <String> ccAddresses;
        List <String> ccoAddresses;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        toAddresses = config.CBK_DestinatarioCorreoTo__c.split(';');
        mail.setToAddresses(toAddresses);
        if (!String.IsBlank(config.CBK_DestinatarioCorreoCC__c)){
            ccAddresses = config.CBK_DestinatarioCorreoCC__c.split(';');
            mail.setCcAddresses(ccAddresses);
        }
        if (!String.IsBlank(config.CBK_DestinatarioCorreoCCO__c)){
            ccoAddresses = config.CBK_DestinatarioCorreoCCO__c.split(';');
            mail.setBccAddresses(ccoAddresses);
        }
        if (!String.IsBlank(config.CBK_RemitenteCorreo__c)){
            List<OrgWideEmailAddress> owea = [SELECT Id,DisplayName FROM OrgWideEmailAddress WHERE Address = :config.CBK_RemitenteCorreo__c];
            if (!owea.isEmpty()) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            } 
        }
        else{
            mail.setTargetObjectId(UserInfo.getUserId());
        }
        mail.setSubject('Alerta de monitorización de cola Flexqueue - ' + config.CBK_Aplicacion__c +  ' - '+ System.URL.getSalesforceBaseUrl().toExternalForm().removeStart('https://'));
        String strHtmlBody = '<html><body><br>';
        if (config.CBK_Aplicacion__c == 'General'){
            strHtmlBody += 'Se ha producido una alerta de monitorización de cola Flexqueue.';
            strHtmlBody += '<br>Se ha superado el umbral configurado: ' + config.CBK_Umbral__c;
            strHtmlBody += '<br>Se han detectado un total de ' + numBatches + ' procesos batch en espera en la cola Flexqueue.';
        }
        else{
            strHtmlBody += 'Se ha producido una alerta de monitorización de cola Flexqueue para la aplicación: ' + config.CBK_Aplicacion__c;
            strHtmlBody += '<br>Se ha superado el umbral configurado en la aplicación: ' + config.CBK_Umbral__c;
            strHtmlBody += '<br>Se han detectado un total de ' + numBatches + ' procesos batch en espera en la cola Flexqueue asociados a esta aplicación.<br>';
        }
        Organization org = [select InstanceName from Organization LIMIT 1];
        strHtmlBody += '<br>Dominio organización: ' + System.URL.getSalesforceBaseUrl().toExternalForm().removeStart('https://') ;
        strHtmlBody += '<br>Identificador de la organización: ' + UserInfo.getOrganizationId();
        strHtmlBody += '<br>Instancia de la organización: ' + org.InstanceName ;
        strHtmlBody += '<br>';
        strHtmlBody += '<br><table border="1" style="border-collapse: collapse"><caption>Detalle procesos batch encolados</caption><tr><th>Número</th><th>Clase Proceso Batch</th></tr>';
        for(AggregateResult agr : lstBacthsDetail){
            if (config.CBK_Aplicacion__c == 'General' || config.CBK_PrefijoAplicacion__c == ((String)(agr.get('Name'))).substringBefore('_')){
                strHtmlBody += '<tr><td>' + String.valueOf(agr.get('expr0')) + '</td><td>' + (String)agr.get('Name') + '</td></tr>';   
            }
        }
        strHtmlBody += '</table>';
        if (lstExecBatch.size()>0){
            strHtmlBody += '<br><br><table border="1" style="border-collapse: collapse"><caption>Listado procesos batch en ejecución</caption><tr><th>Clase Proceso Batch</th><th>Status</th><th>Total Job Items</th><th>Job Items Procesados</th><th>Extended Status</th><th>Número de errores</th></tr>';
            for(AsyncApexJob runningBatch : lstExecBatch){
                    strHtmlBody += '<tr><td>' + String.valueOf(runningBatch.ApexClass.Name) + '</td><td>' + String.valueOf(runningBatch.Status)  + '</td><td>' + String.valueOf(runningBatch.TotalJobItems)  + '</td><td>' + String.valueOf(runningBatch.JobItemsProcessed)  + '</td><td>' + String.valueOf((runningBatch.ExtendedStatus==null)?'':runningBatch.ExtendedStatus) + '</td><td>' + String.valueOf(runningBatch.NumberOfErrors) + '</td></tr>';   
                    system.debug('<tr><td>' + String.valueOf(runningBatch.ApexClass.Name) + '</td><td>' + String.valueOf(runningBatch.Status)  + '</td><td>' + String.valueOf(runningBatch.TotalJobItems)  + '</td><td>' + String.valueOf(runningBatch.JobItemsProcessed)  + '</td><td>' + String.valueOf((runningBatch.ExtendedStatus==null)?'':runningBatch.ExtendedStatus) + '</td><td>' + String.valueOf(runningBatch.NumberOfErrors) + '</td></tr>');
            }
            strHtmlBody += '</table>';
        }
        strHtmlBody += '<br></body></html>';
        system.debug(strHtmlBody);
        mail.setHtmlBody(strHtmlBody);
        mail.setSaveAsActivity(false);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(exception e){
            system.debug(e);
        }
    }

    /**
    * @description Método para recuperar el listado de registros de monitorización almacenados para la applicación/general en el intervalo de tiempo indicado
    * @author   fzaragoza | 24/06/2021 
    * @param    config registro de configuración que contiene la información de la aplicación/general (CBK_FlexQueueMonitorSetting__c)
    * @param    prefijoAplicacion  Prefijo de la aplicación/general
    * @param    intervaloMinutos  Intervalo de tiempo hasta el que se remontará la consulta de información
	* @return	List<CBK_FlexQueueMonitor__c>  listado de registros de monitorización almacenados para la applicación/general en el intervalo de tiempo indicado
    **/
    private static List<CBK_FlexQueueMonitor__c> recuperarEntradasPrevias (String prefijoAplicacion, Decimal intervaloMinutos){
        datetime intervaloNotificacion = datetime.now().addminutes((Integer)(0-intervaloMinutos));
        List <CBK_FlexQueueMonitor__c> lstRegistros = [SELECT CBK_Aplicacion__c, CBK_PrefijoAplicacion__c, CBK_HoldingBatches__c, 
                                                        CBK_PorcentajeConsumoUmbral__c, CBK_NotificacionNecesaria__c, CBK_NotificacionRealizada__c 
                                                        FROM CBK_FlexQueueMonitor__c WHERE CBK_PrefijoAplicacion__c = :prefijoAplicacion and createddate >= :intervaloNotificacion];
        return lstRegistros;
    }
}