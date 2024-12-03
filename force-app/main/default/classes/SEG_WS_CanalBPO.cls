@RestResource(urlMapping='/CanalBPO/*')
global with sharing class SEG_WS_CanalBPO {
    @HttpPost
    global static SEG_WS_CanalBPO.Output entradaCanalBPO() 
    {
        SEG_WS_CanalBPO.Input input = new SEG_WS_CanalBPO.Input();
        //if (!Test.isRunningTest()) {
            input = (SEG_WS_CanalBPO.Input)JSON.deserializeStrict(
                RestContext.request.requestBody.toString(), SEG_WS_CanalBPO.Input.class
            );
        //} 
        SEG_WS_CanalBPO.Output output = new SEG_WS_CanalBPO.Output();


        List<Case> listCasos = new List<Case>();
        listCasos = [select id,Status,SEG_Subestado__c,CC_MCC_Tematica__c,CC_MCC_ProdServ__c,CC_MCC_Motivo__c,SEG_Detalle__c,Account.CC_Numero_Documento__c,SEG_Email_Buzon_Entrada__c,SEG_Organizacion__c,SEG_Zona__c,SEG_Grupo__c  from Case where id=:input.caseId];
        if(listCasos.size()==0)
        {
            output.resultado='KO';
            output.mensaje='No se encuentra el Caso';
        }
        else
        {
            if(input.tipoProceso=='B03')
            {
                altaomodificacionCliente(input,listCasos[0]);
                //TO DO:, cambio de grupo a grupo respuesta
            }
            else if(input.tipoProceso=='B04')
            {
                nuevoCorreo(input,listCasos[0]);
            }
            else if(input.tipoProceso=='B05')
            {
                cambioAccion(input,listCasos[0]);
            }
            else if(input.tipoProceso=='B06')
            {
                nuevoCorreo(input,listCasos[0]);
            }
            else if(input.tipoProceso=='B07')
            {
                incidenciaBPM(input,listCasos[0]);
            }
            else if(input.tipoProceso=='B08')
            {
                enviadoDespacho(input,listCasos[0]);
            }
            else if(input.tipoProceso=='B10')
            {
                cierreBPO(input,listCasos[0]);
            }
            output.resultado='OK';
            output.mensaje='Operación registrada correctamente';
        }

        return output;
    }
    private static void altaomodificacionCliente(SEG_WS_CanalBPO.Input entrada,Case caso)
    {
        //TODO: Cambio de grupo, hay que enviar petición a BPO con S03 parecida al S01 y verificar nif
        List<SEG_WS_CanalBPO.ContenidoAdicional> listContenidoAdd = new  List<SEG_WS_CanalBPO.ContenidoAdicional>();
        List<SEG_WS_CanalBPO.Documentsid> listDocumentsid = new  List<SEG_WS_CanalBPO.Documentsid>();
        listContenidoAdd=entrada.contenidoAdicional;
        listDocumentsid=entrada.documentsid;
        String nifBpo;
        if(caso.Status=='Pendiente')
        {
            caso.Status='Activo';
            caso.SEG_Subestado__c='Pte Alta/Modificación Cliente';
            //update caso;
        }
        else
        {
            caso.SEG_Subestado__c='Pte Alta/Modificación Cliente';
            //update caso;
        }
        string mensaje;
        for(SEG_WS_CanalBPO.ContenidoAdicional conAd : listContenidoAdd)
        {
            mensaje = mensaje + ' ' + conAd.key + ': ' + conAd.value;
            if(conAd.key=='NIF')
            {
                nifBpo=conAd.value;
            }
        }

        String docsrel;
        if(!listDocumentsid.isEmpty()){
            for(SEG_WS_CanalBPO.Documentsid docsId : listDocumentsid)
            {
                docsrel = 'Documentos BPO:' + docsrel + ' ' + docsId.key + ': ' + docsId.value;
            }
            
        }

        if(caso.Account.CC_Numero_Documento__c == nifBpo){
            String sTipoBusqueda = 'DOC';
            //Map<String,Object> oData = CC_Busqueda_ALF_Controller.getIdentidad ('DOC', nifBpo,'');
            //Map<String,Object> oDataSegAlf = SEG_Busqueda_ALF_Controller.buscarClientesSegmentos(sTipoBusqueda, nifBpo);
            SEG_BPO_WS.altaomodificacionCliente(caso.Id,'alta');
        }
        else{
            String sTipoBusqueda = 'DOC';
            //Map<String,Object> oData = CC_Busqueda_ALF_Controller.getIdentidad ('DOC', nifBpo,'');
            //Map<String,Object> oDataSegAlf = SEG_Busqueda_ALF_Controller.buscarClientesSegmentos(sTipoBusqueda, nifBpo);
            SEG_BPO_WS.altaomodificacionCliente(caso.Id,'alta');
        }

        asignarGrupoRespuesta(caso);
        if(String.isNotBlank(mensaje))
        {
            postOnChatter(caso.id,mensaje);
        }
        if(String.isNotBlank(docsrel))
        {
            postOnChatter(caso.id,docsrel);
        }
    }
    private static void cierreBPO(SEG_WS_CanalBPO.Input entrada,Case caso)
    {
        List<SEG_WS_CanalBPO.ContenidoAdicional> listContenidoAdd = new  List<SEG_WS_CanalBPO.ContenidoAdicional>();
        listContenidoAdd=entrada.contenidoAdicional;

        if(caso.Status=='Pendiente'){
            caso.Status='Activo';
        }

        caso.SEG_Subestado__c='Finalizado BPM';
        asignarGrupoRespuesta(caso);

        string mensaje;
        for(SEG_WS_CanalBPO.ContenidoAdicional conAd : listContenidoAdd)
        {
            mensaje = mensaje + ' ' + conAd.key + ': ' + conAd.value;
        }
        if(String.isNotBlank(mensaje))
        {
            postOnChatter(caso.id,mensaje);
        }
    }
    private static void nuevoCorreo(SEG_WS_CanalBPO.Input entrada,Case caso)
    {
        List<SEG_WS_CanalBPO.ContenidoAdicional> listContenidoAdd = new  List<SEG_WS_CanalBPO.ContenidoAdicional>();
        listContenidoAdd=entrada.contenidoAdicional;
        
        string toAddress;
        string fromName;
        string remitente;
        string asunto;
        string textoentrada;

        
        for(SEG_WS_CanalBPO.ContenidoAdicional conAd : listContenidoAdd)
        {
            //mensaje = mensaje + ' ' + conAd.key + ': ' + conAd.value;
            if(conAd.key=='REMITENTE')
            {
                remitente=conAd.value;
            }
            else if(conAd.key=='RECEPTOR')
            {
                toAddress=conAd.value;
            }
            else if(conAd.key=='ASUNTO')
            {
                asunto=conAd.value;
            }
        }
        /*if(String.isNotBlank(mensaje))
        {
            postOnChatter(caso.id,mensaje);
        }*/
        if(String.isNotBlank(entrada.textoEmail))
        {
            crearEmailMessage(toAddress,remitente,asunto,textoentrada,caso.id);
        }
    }
    private static void incidenciaBPM(SEG_WS_CanalBPO.Input entrada,Case caso)
    {
        List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO'];


        if(caso.Status=='Pendiente')
        {
            caso.Status='Activo';
            caso.SEG_Subestado__c='Incidencia BPM';
            if(colasBO.size()==1)
            {
                caso.OwnerId=colasBO[0].id;
            }
            update caso;
        }
        else
        {
            caso.SEG_Subestado__c='Incidencia BPM';
            if(colasBO.size()==1)
            {
                caso.OwnerId=colasBO[0].id;
            }
            update caso;
        }  
    }
    private static void enviadoDespacho(SEG_WS_CanalBPO.Input entrada,Case caso)
    {
        List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO'];
        List<SEG_WS_CanalBPO.ContenidoAdicional> listContenidoAdd = new  List<SEG_WS_CanalBPO.ContenidoAdicional>();
        listContenidoAdd=entrada.contenidoAdicional;
        string mensaje;
        mensaje = 'Tipo proceso: ' + String.valueOf(entrada.tipoProceso) + '. Origen: ' + String.valueOf(entrada.origen) + '. Número de caso: ' + String.valueOf(entrada.caseNumber) + '. Fecha evento: '+ String.valueOf(entrada.fechaEvento) + '. Contenido Adicional: ';

        for(SEG_WS_CanalBPO.ContenidoAdicional conAd : listContenidoAdd)
        {
            mensaje = mensaje + ' ' + conAd.key + ': ' + conAd.value;
        }

        if(String.isNotBlank(mensaje))
        {
            postOnChatter(caso.id,mensaje);
        }


        if(caso.Status=='Pendiente')
        {
            caso.Status='Activo';
            caso.SEG_Subestado__c='Despacho BPM';
            /*if(colasBO.size()==1)
            {
                caso.OwnerId=colasBO[0].id;
            }*/
            update caso;
        }
        else
        {
            caso.SEG_Subestado__c='Despacho BPM';
            if(colasBO.size()==1)
            {
                caso.OwnerId=colasBO[0].id;
            }
            update caso;
        } 


        //nuevoCorreo(entrada,caso);
    }
    private static void cambioAccion(SEG_WS_CanalBPO.Input entrada,Case caso)
    {
        List<SEG_WS_CanalBPO.ContenidoAdicional> listContenidoAdd = new  List<SEG_WS_CanalBPO.ContenidoAdicional>();
        listContenidoAdd=entrada.contenidoAdicional;
        string mensaje;
        string accion;
        for(SEG_WS_CanalBPO.ContenidoAdicional conAd : listContenidoAdd)
        {
            mensaje = mensaje + ' ' + conAd.key + ': ' + conAd.value;
            if(conAd.key=='Accion')
            {
                accion=conAd.value;
            }
        }
        if(String.isNotBlank(mensaje))
        {
            postOnChatter(caso.id,mensaje);
        }
        //buscamos detalle por nombre
        List<CC_MCC__c> listadoMCC = new List<CC_MCC__c>();
        string accionid;
        if(String.isNotBlank(caso.CC_MCC_Motivo__c))
        {
            //TODO:cambiar los filtros de búsqueda algo parecido a = select id from CC_MCC__c where Name = 'Alta de bastanteo' and CC_Producto_Servicio__c='a0V5r000000hcekEAA' and CC_Tipo_Cliente__c='Segmentos'
            //listadoMCC = [select id from CC_MCC__c where name = :accion and CC_Motivo__c=:caso.CC_MCC_Motivo__c and CC_Producto_Servicio__c=:caso.CC_MCC_ProdServ__c and CC_Tematica__c =:caso.CC_MCC_Tematica__c and CC_Tipo_Cliente__c='Segmentos'];
            //listadoMCC = [select id from CC_MCC__c where name = :accion and CC_Motivo__c=:caso.CC_MCC_Motivo__c and CC_Tipo_Cliente__c='Segmentos'];
            listadoMCC = [select id from CC_MCC__c where name = :accion and CC_Producto_Servicio__c=:caso.CC_MCC_ProdServ__c and CC_Tipo_Cliente__c='Segmentos'];
            if(listadoMCC.size()>0)
            {
                accionid=listadoMCC[0].id;
            }
        }
        //caso.SEG_Detalle__c = accionid;
        caso.CC_MCC_Motivo__c = accionid;
        update caso;
        
        //listCasos = [select id,Status,SEG_Subestado__c,CC_MCC_Tematica__c,CC_MCC_ProdServ__c,CC_MCC_Motivo__c,SEG_Detalle__c from Case where id=:input.caseId];

    }
    private static void postOnChatter(Id caseId, String observacion){

    	FeedItem feed = new FeedItem();
		feed.ParentId = caseId; 
        feed.Body = 'Comentarios publicados en BPO: ' + observacion +'.'; 
		insert feed; 
    }
    public static void crearEmailMessage(String toAddress, string remitente, string asunto,String body,string idCaso) {
       
    System.debug('crearEmailMessage TEXTO EMAIL:' + body);
        EmailMessage correo = new EmailMessage();
        correo.Subject = asunto;
        correo.Status = '1';
        correo.FromAddress = remitente;
        correo.FromName = remitente;
        correo.Incoming = true;
        correo.MessageDate = DateTime.now();
        correo.ParentId = idCaso;
        correo.ToAddress = toAddress;
        correo.TextBody = body;
        correo.HtmlBody = body;
        insert correo;
        //return correo;
    }

    public static void asignarGrupoRespuesta(Case currentCase){
        Set<String> mccsCaso = new Set<String>();
        mccsCaso.add(currentCase.CC_MCC_Motivo__c);
        mccsCaso.add(currentCase.CC_MCC_ProdServ__c);
        mccsCaso.add(currentCase.CC_MCC_Tematica__c);
        mccsCaso.add(currentCase.SEG_Detalle__c);

        Group colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' LIMIT 1];
        
        List<CC_MCC_Grupo_Colaborador__c> gcolab = new List<CC_MCC_Grupo_Colaborador__c>(
            [SELECT Id, CC_MCC__c,SEG_Organizacion__c,SEG_Zona__c,SEG_Grupo_respuesta__c,CC_Grupo_Colaborador__c,
             CC_Grupo_Colaborador__r.RecordType.DeveloperName, SEG_Prioridad__c, SEG_Grupo_respuesta__r.Name, SEG_Grupo_respuesta__r.RecordType.DeveloperName,
             CC_Grupo_Colaborador__r.SEG_CierreAutomaticoSR__c
             FROM CC_MCC_Grupo_Colaborador__c 
             WHERE CC_MCC__c in :mccsCaso 
             AND (SEG_Organizacion__c=:currentCase.SEG_Organizacion__c OR SEG_Organizacion__c='Todas') 
             AND (SEG_Zona__c=:currentCase.SEG_Zona__c OR SEG_Zona__c='Todas')
             ORDER BY SEG_Prioridad__c ASC
             LIMIT 1]);
        
        if(gcolab.size() > 0)
        {
            String tipoGrupoRespuesta = gcolab[0].SEG_Grupo_respuesta__r?.RecordType?.DeveloperName;
            String grupoRespuesta = gcolab[0].SEG_Grupo_respuesta__c;
            String grupoRespuestaName = gcolab[0].SEG_Grupo_respuesta__r?.Name;
            Boolean bCierreCaso = false;
            
            if (String.isNotBlank(grupoRespuesta))
            {
                currentCase.SEG_Grupo__c = grupoRespuesta;
                currentCase.OwnerId = colasBO.id;
            }
            
        }
        update currentCase; 
    }
    @TestVisible
    public class Input {
        public String tipoProceso {get;set;}
        public String origen {get;set;}
        public String caseId {get;set;}
        public String caseNumber {get;set;}
        public String fechaEvento {get;set;}
        public String textoEmail {get;set;}
        public List<ContenidoAdicional> contenidoAdicional{get;set;}
        public List<Documentsid> documentsid{get;set;}
        //tambien se envian docAdjuntos pero esto deberá tratarse por otro canal
        //B03 - Solicitud Alta/Modificación de cliente a Siebel  --> Solicitar alta/modificación de cliente (no existe como Estado ni Subestado)
        //B04 - Envío del correo de modelos a cliente  --> Dar de alta un email anexado al caso 
        //B05 - Cambio de Tipo de Solicitud CBPO/ Acción en SIEBEL --> Ni idea, viene contenido adicional en la estructura
        //B06 - Nueva reclamación --> implica dar de alta un nuevo correo
        //B07 - Incidencia documental recibida en Canal --> llega info de contenido adicional
        //B08 – Envío a letrado realizado --> contenido adicional y cambio de estado
        //B10 – Finalización o Descarte de la instancia en canal  --> Desmarcar el check de sincronización

    }
    @TestVisible
    public class ContenidoAdicional{
        public String key {get;set;}
        public String value {get;set;}
    }
    @TestVisible
    public class Documentsid{
        public String key {get;set;}
        public String value {get;set;}
    }
    global class Output {
        public String resultado {get;set;}
        public String mensaje {get;set;}
    }

}