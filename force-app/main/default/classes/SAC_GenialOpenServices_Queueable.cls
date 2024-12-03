/********************************************************************************************************
* Name: SAC_GenialOpenServices_Queueable
*
* @description : Se propone un queueable para secuenciar el envío de documentos hacia DocumentAI a través
* de open services. Para iniciarlo hay que llamarlo como null, null, (Id reclamacion). Con la función recursiva
* se irá llamando con la lista de documentos que irá vaciandose para enviarlos 1 a 1 y la lista de Ids de documento
* que se irán generando conforme se vayan enviando.
*
* Historial
*------------------------------------------------------------------
* VERSION        USER_STORY       AUTHOR         DATE         Description
* 1.0            US967489         Alex Pérez     18/07/24     Creación
********************************************************************************************************/

public with sharing class SAC_GenialOpenServices_Queueable implements Queueable, Database.AllowsCallouts {

    /**
     * @description     método constructor. Query de documentos
     * @param genial    datos recibidos de SAC_Genial_WS
     * @param fase      fase del queueable
     */

     //listado de links a documentos
     List<ContentDocumentLink> doculink;
     //listado de Ids de documentos proporcionados por open Services
     //list<Id> listExternoDocIds = new list<Id>();
     //Id de la reclamación
     public list<SAC_GenialOpenServicesIntegracion.DocumentsInfo> attachedDocuments;
     Id reclamaId;
     list<Id> listaReclama;
     //Ids de content document
     //boolean esValido;
     boolean bodyEnviado;

    public SAC_GenialOpenServices_Queueable(List<ContentDocumentLink> doculink, 
    list<SAC_GenialOpenServicesIntegracion.DocumentsInfo> attachedDocuments, list<Id> reclamaId) {
        //Obtener Ids de documentos
        //this.esValido = true;
        //si es el primer queueable de la cadena, el doculink estará a null así que tendrá que hacer la query
        /* if(doculink == null){
            this.doculink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :reclamaId];
            /*for(ContentDocumentLink cdl : doculink){
                listContentDocumentIds.add(cdl.ContentDocumentId);
            }*/    
        /*} else {
            this.doculink = doculink;
        } */
        this.doculink = doculink;
        this.attachedDocuments = attachedDocuments;
        this.reclamaId = reclamaId.get(0);
        this.listaReclama = reclamaId;   
        //solo entra en esta inicializacion al entrar a hacer recursividad, como el body es el primer paso ya estara enviado.     
        this.bodyEnviado = true;
        /* else {
            this.doculink = doculink;
        }*/

       /* if(listExternoDocIds != null){
            this.listExternoDocIds = listExternoDocIds;
        }*/
    }

    //constructor inicial con la lista de Ids de reclamaciones a enviar a Open Services
    public SAC_GenialOpenServices_Queueable(list<id> reclama){
        this.doculink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :reclama.get(0)];
        this.attachedDocuments = new list<SAC_GenialOpenServicesIntegracion.DocumentsInfo>();
        this.reclamaId = reclama.get(0);
        this.listaReclama = reclama;
        this.bodyEnviado = false;
        //reclama
    }

    /**
     * @description : execute de la clase queueable que se encarga de elegir entre
     * llamar a la integración de envío de documentos o llamar a la integración de envío de la oportunidad 
     * dependiendo del valor de doculink
     */
    public void execute(QueueableContext context) {
        //id generado por docIA proporcionado por Open Services
        SAC_GenialOpenServicesIntegracion.DocumentsInfo externoDocId;
        try{
            if(!this.bodyEnviado){
                //enviar el body en formato txt como primer documento
                externoDocId = SAC_GenialOpenServicesIntegracion.envioBody(this.reclamaId);
                if(externoDocId != null) {
                    this.attachedDocuments.add(externoDocId);
                    this.bodyEnviado = true;
                    queueableRecursivo(context.getJobId(), null);
                } else {
                    errorEnvio(new case(Id=this.reclamaId));
                    //en caso de fallar la subida de documentos, pasamos a la siguiente reclamación de la lista
                    this.listaReclama.remove(0);
                    if(!this.listaReclama.isEmpty()){
                        queueableRecursivo(context.getJobId(), this.listaReclama);
                    }
                }
            }
            else if(this.doculink.isEmpty()){
                ///id de la reclamacion con la lista de Ids externos de los docs obtenidos.
                ////SAC_genialEvioReclamacionOS_WS(this.reclamaId, listExternoDocIds);
                SAC_GenialOpenServicesIntegracion.envioReclamacion(this.attachedDocuments, this.reclamaId);
                this.listaReclama.remove(0);
                if(!listaReclama.isEmpty()){
                    //iteramos y empezamos con la siguiente reclamación
                    queueableRecursivo(context.getJobId(), listaReclama);
                }
            } else {
                externoDocId = SAC_GenialOpenServicesIntegracion.envioDocumento(this.doculink.get(0));      
                if(externoDocId != null) {
                    this.doculink.remove(0);
                    this.attachedDocuments.add(externoDocId);
                    queueableRecursivo(context.getJobId(), null);
                } else {
                    errorEnvio(new case(Id=this.reclamaId));
                    //en caso de fallar la subida de documentos, pasamos a la siguiente reclamación de la lista
                    this.listaReclama.remove(0);
                    if(!this.listaReclama.isEmpty()){
                        queueableRecursivo(context.getJobId(), this.listaReclama);
                    }
                }
                //para testing ya que la integración aun no tiene las rules aprobadas
                //queueableRecursivo(context.getJobId());
            }
        }catch(Exception e){
            List<Object> detalle = new List<Object>();
            detalle.add((Object)this.reclamaId);
            CBK_Log.error(e, detalle);
            errorEnvio(new case(Id=this.reclamaId));
            //en caso de fallar la subida de documentos, pasamos a la siguiente reclamación de la lista
            if(this.listaReclama.size() > 1){
                this.listaReclama.remove(0);
                queueableRecursivo(context.getJobId(), this.listaReclama);
            }
        }
    }

     /**
     * @description            funcion que monta el queueable recursivo con las reglas de QC
     * si la lista de Ids se pasa a null significa que está trabajando en la reclamación actual en posición 0
     * cuando se pase la lista o es el inicio del queueable o se ha iterado a la siguiente reclamación de la lista
     */
    private void queueableRecursivo(Id jobId, list<id> listaIds) {
        //if(!test.isRunningTest()){
            //paso para independizar la asignación de la reclamación principal
            //system.enqueueJob(new SAC_GenialQueueable(genialRequest, posicion));
        
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                        .addId(jobId)
                                        .addString('OPdoc')
                                        .build();
        //comprobar si ya ha acabado de enviar documentos a Open Services
        //integer posicion = doculink.isEmpty() ? 1 : 0;
        //try {
          /*  SAC_GenialOpenServices_Queueable opQ = new SAC_GenialOpenServices_Queueable(
                //reclamaId = this.reclamaId,
                doculink = this.doculink,
                //OpQ.listExternoDocIds = this.listExternoDocIds
                reclamaId = this.reclamaId
            );*/
        if(!test.isrunningtest()){
            if(listaIds == null){
                System.enqueueJob(new SAC_GenialOpenServices_Queueable(this.doculink, this.attachedDocuments, this.listaReclama), options);
            } else {
                //ha acabado con el envío anterior y realiza el siguiente de la lista
                System.enqueueJob(new SAC_GenialOpenServices_Queueable(listaIds), options);
            }
            
        }
        /*} catch (Exception e) {
            //Exception is thrown if there is already an enqueued job with the same 
            //signature
            //Assert.areEqual('Intento de ejecutar un Queueable duplicado', ex.getMessage());
            List<Object> detalle = new List<Object>();
            detalle.add((Object)genialRequest);
            CBK_Log.error(e, detalle);
        }*/
       // }
    }

    /*
    * Función para marcar como error de envío los casos que fallen. Puede fallar al enviar documentos o al enviar la reclamación.
    * también se llama al registrar un error por el try catch
    */
    public static void errorEnvio(case reclamacion) {
        reclamacion.SAC_GenialEstado__c = 'SAC_004';
        string nombreCola = 'SAC_PendienteAsignar';
        QueueSobject cola = null;
        List<QueueSobject> colas = [SELECT QueueId FROM QueueSobject WHERE queue.DeveloperName = : nombreCola AND SobjectType = 'Case' LIMIT 1];
        if(!colas.isEmpty()){
            cola = colas[0];
        }
        reclamacion.OwnerId = cola.QueueId;
        reclamacion.SAC_Tipo_integracion_IA__c = 'OpenServices';
        update reclamacion;

    }

    
}