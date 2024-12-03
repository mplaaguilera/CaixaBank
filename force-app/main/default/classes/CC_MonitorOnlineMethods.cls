public with sharing class CC_MonitorOnlineMethods {
    
    public class WrapperInfoInicial{
        @AuraEnabled
        public List<PrevDataModel> previsionData {get; set;}
        @AuraEnabled
        public List<PrevDataModelChats> previsionDataChats {get; set;}
        @AuraEnabled
        public List<PickListWrapper> pickListEntries {get; set;}
        @AuraEnabled
        public List<PickListWrapper> pickListEntriesPro {get; set;}
        @AuraEnabled
        public List<PickListWrapper> pickListEntriesPre {get; set;}
        @AuraEnabled
        public DateTime hora {get; set;}
        @AuraEnabled
        public List<PickListWrapper> pickListEntriesServ {get; set;}
        
        public WrapperInfoInicial(List<PrevDataModel> previsionData, List<PrevDataModelChats> previsionDataChats, List<PickListWrapper> pickListEntries, List<PickListWrapper> pickListEntriesPro, List<PickListWrapper> pickListEntriesPre, DateTime hora, List<PickListWrapper> pickListEntriesServ) {
            this.previsionData = previsionData;
            this.previsionDataChats = previsionDataChats;
            this.pickListEntries = pickListEntries;
            this.pickListEntriesPro = pickListEntriesPro;
            this.pickListEntriesPre = pickListEntriesPre;            
            this.pickListEntriesServ = pickListEntriesServ;
            this.hora = hora;
        }

    }

    public class PickListWrapper {
        //Clase para almacenar valores de una picklist
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public PickListWrapper(String label, String value ) {
            this.label = label;
            this.value = value;

        }
    }

    public class PrevDataModel {
        //Clase para almacenar valores de una picklist
        @AuraEnabled
        public String franjaHoraria {get; set;}
        @AuraEnabled
        public String agentesDisponibles {get; set;}
        @AuraEnabled
        public String agentesNoDisponibles {get; set;}
        @AuraEnabled
        public Date fecha {get; set;}
        @AuraEnabled
        public String real {get; set;}
        @AuraEnabled
        public String calculo {get; set;}
        @AuraEnabled
        public String tipoPrev {get; set;}
        @AuraEnabled
        public String proveedor {get; set;}
        @AuraEnabled
        public String prevision {get; set;}
        @AuraEnabled
        public String servicio {get; set;}

        public PrevDataModel(String franjaHoraria, String agentesDisponibles, String agentesNoDisponibles, Date fecha, String real, String calculo, String tipoPrev, String proveedor, String prevision, String servicio ) {
            this.franjaHoraria = franjaHoraria;
            this.agentesDisponibles = agentesDisponibles;
            this.agentesNoDisponibles = agentesNoDisponibles;
            this.fecha = fecha;
            this.real = real;
            this.calculo = calculo;
            this.tipoPrev = tipoPrev; 
            this.proveedor = proveedor;
            this.prevision = prevision;
            this.servicio = servicio;
        }
    }
        public class PrevDataModelChats {
            //Clase para almacenar valores de una picklist
            @AuraEnabled
            public String franjaHoraria {get; set;}
            @AuraEnabled
            public String chatAtendidos {get; set;}
            @AuraEnabled
            public String chatsNoAtendidos {get; set;}
            @AuraEnabled
            public Date fecha {get; set;}
            @AuraEnabled
            public String real {get; set;}
            @AuraEnabled
            public String calculo {get; set;}
            @AuraEnabled
            public String tipoPrev {get; set;}
            @AuraEnabled
            public String proveedor {get; set;}
            @AuraEnabled
            public String prevision {get; set;}
            @AuraEnabled
            public String servicio {get; set;}
    
            public PrevDataModelChats(String franjaHoraria, String chatAtendidos, String chatsNoAtendidos, Date fecha, String real, String calculo, String tipoPrev, String proveedor, String prevision, String servicio ) {
                this.franjaHoraria = franjaHoraria;
                this.chatAtendidos = chatAtendidos;
                this.chatsNoAtendidos = chatsNoAtendidos;
                this.fecha = fecha;
                this.real = real;
                this.calculo = calculo;
                this.tipoPrev = tipoPrev; 
                this.proveedor = proveedor;
                this.prevision = prevision;
                this.servicio = servicio;
            }
    }

    @AuraEnabled(cacheable=false)
    public static WrapperInfoInicial getData(){
   // public static WrapperInfoInicial getData(/*String recTypeDevName*/){
        List<CC_Prevision__c> lstResult = new List<CC_Prevision__c>();
        List<CC_Prevision__c> listChats = new List<CC_Prevision__c>();
        List<CC_Prevision__c> listAgentes = new List<CC_Prevision__c>();
        List<CC_Prevision__c> listTotalesChats = new List<CC_Prevision__c>();
        List<CC_Prevision__c> listTotalesAgentes = new List<CC_Prevision__c>();
        List<PrevDataModel> resMod = new List<PrevDataModel>();
        List<PrevDataModelChats> resModChats = new List<PrevDataModelChats>();
        Datetime ahora = System.now();
        Date hoy = System.today();
        Date dema = System.today().addDays(1);
        String ahoraNum = String.valueOf(ahora).substring(11, 13);
        
        String campo = 'CC_'+ahoraNum+'__c';
        
        String query = 'SELECT Id, CC_Calculo__c, CC_Real__c, CC_Proveedor__c, CC_TipoDePrevisiones__c, RecordTypeId, CC_Fecha__c, CC_ConexionesDisponibles__c, CC_ConexionesNoDisponibles__c, CC_Chats_Atendidos__c, CC_Chats_No_Atendidos__c, CC_Servicio__c, CC_00__c, CC_01__c, CC_02__c, CC_03__c, CC_04__c, CC_05__c, CC_06__c, CC_07__c, CC_08__c, CC_09__c, CC_10__c,CC_11__c, CC_12__c, CC_13__c, CC_14__c, CC_15__c, CC_16__c, CC_17__c, CC_18__c, CC_19__c, CC_20__c, CC_21__c, CC_22__c, CC_23__c FROM CC_Prevision__c WHERE  CC_Fecha__c >=' + String.escapeSingleQuotes(String.valueOf(hoy)) + ' AND CC_Fecha__c < '+String.escapeSingleQuotes(String.valueOf(dema)) +' AND ' + String.escapeSingleQuotes(campo) +' != null';
        
        lstResult = Database.query(query);
        Id recordTypeIdChats = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Prevision__c', 'CC_Chats');
        if(!lstResult.isEmpty()){
            for(CC_Prevision__c prevFilt : lstResult){
                if(prevFilt.recordTypeId == recordTypeIdChats){
                    /*if(prevFilt.CC_Proveedor__c == 'TODOS'){
						listTotalesChats.add(prevFilt);
					}*/
                    listChats.add(prevFilt);
                }else{
                    /*if(prevFilt.CC_Proveedor__c == 'TODOS'){
						listTotalesAgentes.add(prevFilt);
					}*/
                    listAgentes.add(prevFilt);
                }
                
            }
        }
        
        List<String> franjaHoraria = new List<String>();
        franjaHoraria.add(ahoraNum);
        if(!lstResult.isEmpty()){
            if(!listAgentes.isEmpty()){
                resMod = obtenerUsuariosPorProv(listAgentes, franjaHoraria);
            }
            if(!listChats.isEmpty()){
                resModChats = obtenerChatsPorProv(listChats, franjaHoraria);
                }
            Schema.DescribeFieldResult fieldResultFH = CC_Prevision__c.CC_FranjaHoraria__c.getDescribe();
            Schema.DescribeFieldResult fieldResultPro = CC_Prevision__c.CC_Proveedor__c.getDescribe();
            Schema.DescribeFieldResult fieldResultPre = CC_Prevision__c.CC_TipoDePrevisiones__c.getDescribe();
            Schema.DescribeFieldResult pickListEntriesServ = CC_Prevision__c.CC_Servicio__c.getDescribe();
            List<PickListWrapper> picklistFH = getPickListValuesIntoList(fieldResultFH);
            List<PickListWrapper> picklistPro = getPickListValuesIntoList(fieldResultPro);
            List<PickListWrapper> picklistPre = getPickListValuesIntoList(fieldResultPre);
            List<PickListWrapper> picklistServ = getPickListValuesIntoList(pickListEntriesServ);
            
            WrapperInfoInicial result = new WrapperInfoInicial(resMod,resModChats, picklistFH, picklistPro, picklistPre, ahora, picklistServ);
            //update resMod;
            //update resModChats;
            return result;
        }
        else{
            return null;
        }
    }

    public static List<PrevDataModelChats> obtenerChatsPorProv(List<CC_Prevision__c> previsiones, List<String> franjaHoraria){
        if(franjaHoraria.isEmpty()){
            Schema.DescribeFieldResult fieldResultFH = CC_Prevision__c.CC_FranjaHoraria__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResultFH.getPicklistValues();
            for(Schema.PicklistEntry valor : picklistValues) {
                franjaHoraria.add(valor.getValue());
            }
        }
        franjaHoraria.sort();
        List<PrevDataModelChats> prevData = new List<PrevDataModelChats>();
        List<LiveChatTranscript> chats = obtenerChatsActuales();
        Set<LiveChatTranscript> chatsAtendidos =  new Set<LiveChatTranscript>();
        Set<LiveChatTranscript> chatsPerdidos =  new Set<LiveChatTranscript>();
        List<CC_Prevision__c> previsionesActualizar = new List<CC_Prevision__c>();
        for(LiveChatTranscript chat : chats) {
            if(chat.Status == 'Completed') {
                chatsAtendidos.add(chat);
            }
            else {
                chatsPerdidos.add(chat);
            }
        }
        Map<Integer, Map<String, Integer>> mapFranjaChatCompleted = new Map<Integer, Map<String, Integer>>();
        Map<Integer, Map<String, Integer>> mapFranjaChatMissed = new Map<Integer, Map<String, Integer>>();
        DateTime ahora = System.now();
        Integer ahoraNum = Integer.valueOf(String.valueOf(ahora).substring(11, 13));
        for (Integer hora = 0; hora <= 23; hora++)
        {
            Map<String, Integer> mapaChatAtendidos = new Map<String, Integer>();
            Map<String, Integer> mapaChatPerdidos = new Map<String, Integer>();
            for(LiveChatTranscript chat : chatsAtendidos)
            {
                if(ahoraNum >= hora)
                {
                    if(Integer.valueOf(String.valueOf(chat.Createddate).substring(11, 13)) <= Integer.valueOf(String.valueOf(hora)) && (chat.EndTime == null || Integer.valueOf(String.valueOf(chat.EndTime).substring(11, 13)) >= Integer.valueOf(String.valueOf(hora))))
                    {
                        if(mapaChatAtendidos.containsKey(chat.CC_Proveedor_Enrutado__c)) {
                            Integer num = mapaChatAtendidos.get(chat.CC_Proveedor_Enrutado__c);
                            num++;
                            mapaChatAtendidos.put(chat.CC_Proveedor_Enrutado__c, num);
                        }
                        else
                        {
                            mapaChatAtendidos.put(chat.CC_Proveedor_Enrutado__c, 1);
                        }
                    }
                }
            }
            mapFranjaChatCompleted.put(hora, mapaChatAtendidos);            

             for(LiveChatTranscript chat : chatsPerdidos)
            {
                if(ahoraNum >= hora)
                {
                    if(Integer.valueOf(String.valueOf(chat.Createddate).substring(11, 13)) <= Integer.valueOf(String.valueOf(hora)) && (chat.EndTime == null || Integer.valueOf(String.valueOf(chat.EndTime).substring(11, 13)) >= Integer.valueOf(String.valueOf(hora))))
                    {
                        if(mapaChatPerdidos.containsKey(chat.CC_Proveedor_Enrutado__c))
                        {
                            Integer num = mapaChatPerdidos.get(chat.CC_Proveedor_Enrutado__c);
                            num++;
                            mapaChatPerdidos.put(chat.CC_Proveedor_Enrutado__c, num);
                        }
                        else
                        {
                            mapaChatPerdidos.put(chat.CC_Proveedor_Enrutado__c, 1);
                        }
                    }
                }
            }            
            mapFranjaChatMissed.put(hora, mapaChatPerdidos);
        }

        for(String hora :franjaHoraria){
            //system.debug('hora' + hora);

            Integer totalCalculo = 0;
            Integer totalReal = 0;
            Integer totalNumConectadosAtendidos = 0;
            Integer totalNumConectadosMissed = 0;

            List<CC_Prevision__c> prevProvTodos = new List<CC_Prevision__c>();
            
            for(CC_Prevision__c prev : previsiones) {
                String campo = 'CC_'+hora+'__c';
            
                if(mapFranjaChatCompleted.containsKey(Integer.valueOf(hora)))
                {
                    Map<String, Integer> mapPorHora = mapFranjaChatCompleted.get(Integer.valueOf(hora));
                    if(mapPorHora.containsKey(prev.CC_Proveedor__c))
                    {
                        Integer numConectados = mapPorHora.get(prev.CC_Proveedor__c);
                        prev.CC_Chats_Atendidos__c = numConectados;
                        totalNumConectadosAtendidos += numConectados;
                    }
                    else
                    {
                        Integer numConectados = 0;
                        prev.CC_Chats_Atendidos__c = numConectados;
                    }
                }
                else
                {
                    Integer numConectados = 0;
                    prev.CC_Chats_Atendidos__c = numConectados;
                }
                
                if(mapFranjaChatMissed.containsKey(Integer.valueOf(hora)))
                {
                    Map<String, Integer> mapPorHora = mapFranjaChatMissed.get(Integer.valueOf(hora));
                    if(mapPorHora.containsKey(prev.CC_Proveedor__c))
                    {
                        Integer numConectados = mapPorHora.get(prev.CC_Proveedor__c);
                        prev.CC_Chats_No_Atendidos__c = numConectados;
                        totalNumConectadosMissed += numConectados;
                    }
                    else
                    {
                        Integer numConectados = 0;
                        prev.CC_Chats_No_Atendidos__c = numConectados;
                    }
                }
                else
                {
                    Integer numConectados = 0;
                    prev.CC_Chats_No_Atendidos__c = numConectados;
                }
                string campoPrevi= String.valueOf(prev.get(campo));
                //En el campo real guardamos el total de chats
                prev.CC_Real__c = prev.CC_Chats_No_Atendidos__c + prev.CC_Chats_Atendidos__c;
                //Hacemos el calculo de la cantidad de chat entrantes - el real
                prev.CC_Calculo__c = Integer.valueOf(campoPrevi) - prev.CC_Real__c;
                
                previsionesActualizar.add(prev);
                //System.debug('prevision actual -> hora ' + campo + ' - prov ' + prev.CC_Proveedor__c + ' - real ' + prev.CC_Real__c + ' - calculo ' + prev.CC_Calculo__c);
                if(prev.CC_Proveedor__c != 'TODOS'){
                    totalCalculo += Integer.valueOf(prev.CC_Calculo__c);
                    totalReal += Integer.valueOf(prev.CC_Real__c);

                    prevData.add(new PrevDataModelChats(String.valueOf(hora), String.valueOf(prev.CC_Chats_Atendidos__c), String.valueOf(prev.CC_Chats_No_Atendidos__c), prev.CC_Fecha__c, String.valueOf(prev.CC_Real__c), String.valueOf(prev.CC_Calculo__c),String.valueOf(prev.CC_TipoDePrevisiones__c), String.valueOf(prev.CC_Proveedor__c), campoPrevi, prev.CC_Servicio__c));
                }
                else{
                    prevProvTodos.add(prev);
                }
                //System.debug('fin bucle 2 calculo ' + totalCalculo + ' - real ' + totalReal);

            }
            if(!prevProvTodos.isEmpty()){
                for(CC_Prevision__c pr : prevProvTodos){
                    String campo = 'CC_'+hora+'__c';
                    string campoPrevi= String.valueOf(pr.get(campo));

                    pr.CC_Real__c = totalReal;
                    /*pr.CC_Calculo__c = totalCalculo - Integer.ValueOf(campoPrevi);*/
                    pr.CC_Chats_Atendidos__c = totalNumConectadosAtendidos;
                    pr.CC_Chats_No_Atendidos__c = totalNumConectadosMissed;
    
                    prevData.add(new PrevDataModelChats(String.valueOf(hora), String.valueOf(pr.CC_Chats_Atendidos__c), String.valueOf(pr.CC_Chats_No_Atendidos__c), pr.CC_Fecha__c, String.valueOf(pr.CC_Real__c), String.valueOf(pr.CC_Calculo__c),String.valueOf(pr.CC_TipoDePrevisiones__c), String.valueOf(pr.CC_Proveedor__c), campoPrevi, pr.CC_Servicio__c));
                }
            }
            
            
            //prevData.add(new PrevDataModelChats(String.valueOf(hora), String.valueOf(prev.CC_Chats_Atendidos__c), String.valueOf(prev.CC_Chats_No_Atendidos__c), prev.CC_Fecha__c, String.valueOf(prev.CC_Real__c), String.valueOf(prev.CC_Calculo__c),String.valueOf(prev.CC_TipoDePrevisiones__c), String.valueOf(prev.CC_Proveedor__c), campoPrevi, prev.CC_Servicio__c));
        }
       // update previsionesActualizar;
     	return prevData;
    
	}


    public static List<PrevDataModel> obtenerUsuariosPorProv(List<CC_Prevision__c> previsiones, List<String> franjaHoraria){
        if(franjaHoraria.isEmpty()){
            Schema.DescribeFieldResult fieldResultFH = CC_Prevision__c.CC_FranjaHoraria__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResultFH.getPicklistValues();
            for(Schema.PicklistEntry valor : picklistValues) {
                franjaHoraria.add(valor.getValue());
            }
        }
        franjaHoraria.sort();
        List<PrevDataModel> prevData = new List<PrevDataModel>();
        List<UserServicePresence> usuariosActivos = obtenerUsuariosActuales();
        Set<UserServicePresence> usuariosDisponibles =  new Set<UserServicePresence>();
        Set<UserServicePresence> usuariosNoDisponibles =  new Set<UserServicePresence>();
        List<CC_Prevision__c> previsionesActualizar = new List<CC_Prevision__c>();
        for(UserServicePresence usuario : usuariosActivos){
            if(usuario.ServicePresenceStatus.DeveloperName == 'Disponible'){
                    usuariosDisponibles.add(usuario);
            }
            else{
                usuariosNoDisponibles.add(usuario);
            }
        }
        
        Map<Integer, Map<String, Integer>> mapFranjaProveedorConexionDisponible = new Map<Integer, Map<String, Integer>>();
        Map<Integer, Map<String, Integer>> mapFranjaProveedorConexionNoDisponible = new Map<Integer, Map<String, Integer>>();
        Map<String, Integer> myMap = new Map<String, Integer>();
        DateTime ahora = System.now();
        Integer ahoraNum = Integer.valueOf(String.valueOf(ahora).substring(11, 13));
        for (Integer hora = 0; hora <= 23; hora++){
            Map<String, Integer> mapaProvConDisponible = new Map<String, Integer>();
            Map<String, Integer> mapaProvConNoDisponible = new Map<String, Integer>();
            for(UserServicePresence usuario : usuariosDisponibles){
                if(ahoraNum >= hora){
                    if(Integer.valueOf(String.valueOf(usuario.StatusStartDate).substring(11, 13)) <= Integer.valueOf(String.valueOf(hora)) && (usuario.StatusEndDate == null || Integer.valueOf(String.valueOf(usuario.StatusEndDate).substring(11, 13)) > Integer.valueOf(String.valueOf(hora)))){
                        if(mapaProvConDisponible.containsKey(usuario.User.CompanyName)){
                            Integer num = mapaProvConDisponible.get(usuario.User.CompanyName);
                            num++;
                            mapaProvConDisponible.put(usuario.User.CompanyName, num);
                        }
                        else
                        {
                            mapaProvConDisponible.put(usuario.User.CompanyName, 1);
                        }
                    }
                }
            }
            mapFranjaProveedorConexionDisponible.put(hora, mapaProvConDisponible);            

            for(UserServicePresence usuario : usuariosNoDisponibles)
            {
                if(ahoraNum >= hora)
                {
                    if(Integer.valueOf(String.valueOf(usuario.StatusStartDate).substring(11, 13)) <= Integer.valueOf(String.valueOf(hora)) && (usuario.StatusEndDate == null || Integer.valueOf(String.valueOf(usuario.StatusEndDate).substring(11, 13)) > Integer.valueOf(String.valueOf(hora))))
                    {
                        if(mapaProvConNoDisponible.containsKey(usuario.User.CompanyName))
                        {
                            Integer num = mapaProvConNoDisponible.get(usuario.User.CompanyName);
                            num++;
                            mapaProvConNoDisponible.put(usuario.User.CompanyName, num);
                        }
                        else
                        {
                            mapaProvConNoDisponible.put(usuario.User.CompanyName, 1);
                        }
                    }
                }
            }            
            mapFranjaProveedorConexionNoDisponible.put(hora, mapaProvConNoDisponible);
        }

        for(UserServicePresence usuario : usuariosActivos)
        {            
            //StatusEndDate, StatusStartDate
            if(myMap.containsKey(usuario.User.CompanyName))
            {
                Integer num = myMap.get(usuario.User.CompanyName);
                num++;
                myMap.put(usuario.User.CompanyName, num);
            }
            else
            {
                myMap.put(usuario.User.CompanyName, 1);
            }
        }
        
        for(String hora :franjaHoraria){
            Integer totalCalculo = 0;
            Integer totalReal = 0;
            Integer totalConexionesDisp = 0;
            Integer totalConexionesNoDisp = 0;

            List<CC_Prevision__c> prevProvTodos = new List<CC_Prevision__c>();
            for(CC_Prevision__c prev : previsiones)
            {
                String campo = 'CC_'+hora+'__c';
                string campoPrevi= String.valueOf(prev.get(campo));
                if(mapFranjaProveedorConexionDisponible.containsKey(Integer.valueOf(hora)))
                {
                    Map<String, Integer> mapPorHora = mapFranjaProveedorConexionDisponible.get(Integer.valueOf(hora));
                    if(mapPorHora.containsKey(prev.CC_Proveedor__c))
                    {
                        Integer numConectados = mapPorHora.get(prev.CC_Proveedor__c);
                        prev.CC_ConexionesDisponibles__c = numConectados;
                        totalConexionesDisp += numConectados;
                    }
                    else
                    {
                        Integer numConectados = 0;
                        prev.CC_ConexionesDisponibles__c = numConectados;
                    }
                }
                else
                {
                    Integer numConectados = 0;
                    prev.CC_ConexionesDisponibles__c = numConectados;
                }

                if(mapFranjaProveedorConexionNoDisponible.containsKey(Integer.valueOf(hora)))
                {
                    Map<String, Integer> mapPorHora = mapFranjaProveedorConexionNoDisponible.get(Integer.valueOf(hora));
                    if(mapPorHora.containsKey(prev.CC_Proveedor__c))
                    {
                        Integer numConectados = mapPorHora.get(prev.CC_Proveedor__c);
                        prev.CC_ConexionesNoDisponibles__c = numConectados;
                        totalConexionesNoDisp = numConectados;
                    }
                    else
                    {
                        Integer numConectados = 0;
                        prev.CC_ConexionesNoDisponibles__c = numConectados;
                    }
                }
                else
                {
                    Integer numConectados = 0;
                    prev.CC_ConexionesNoDisponibles__c = numConectados;
                }
                
            
                prev.CC_Real__c = prev.CC_ConexionesNoDisponibles__c + prev.CC_ConexionesDisponibles__c;
                prev.CC_Calculo__c = Integer.valueOf(campoPrevi) - prev.CC_Real__c;
                
                if(prev.CC_Proveedor__c != 'TODOS'){
                    totalCalculo += Integer.valueOf(prev.CC_Calculo__c);
                    totalReal += Integer.valueOf(prev.CC_Real__c);

                    prevData.add(new PrevDataModel(String.valueOf(hora), String.valueOf(prev.CC_ConexionesDisponibles__c), String.valueOf(prev.CC_ConexionesNoDisponibles__c), prev.CC_Fecha__c, String.valueOf(prev.CC_Real__c), String.valueOf(prev.CC_Calculo__c),String.valueOf(prev.CC_TipoDePrevisiones__c), String.valueOf(prev.CC_Proveedor__c), campoPrevi, prev.CC_Servicio__c));
                }
                else{
                    prevProvTodos.add(prev);
                }
            }
            if(!prevProvTodos.isEmpty()){
                for(CC_Prevision__c pr : prevProvTodos){
                    String campo = 'CC_'+hora+'__c';
                    string campoPrevi= String.valueOf(pr.get(campo));

                    pr.CC_Real__c = totalReal;
                    //pr.CC_Calculo__c = totalCalculo; 
                    pr.CC_ConexionesDisponibles__c = totalConexionesDisp;
                    pr.CC_ConexionesNoDisponibles__c = totalConexionesNoDisp;
        
                    prevData.add(new PrevDataModel(String.valueOf(hora), String.valueOf(pr.CC_ConexionesDisponibles__c), String.valueOf(pr.CC_ConexionesNoDisponibles__c), pr.CC_Fecha__c, String.valueOf(pr.CC_Real__c), String.valueOf(pr.CC_Calculo__c),String.valueOf(pr.CC_TipoDePrevisiones__c), String.valueOf(pr.CC_Proveedor__c), campoPrevi, pr.CC_Servicio__c));
                }
            }
        }

        


        // system.debug('previsionesActualizar' + previsionesActualizar);
        // try{
        //     update previsionesActualizar;
        // }catch(Exception e){
        //     CBK_Log.error(e);
        //     system.debug(e);
        // }
        //faltaria actualizar los registros encontrados pero el update lanza un LIMIT EXCEPTION (update previsiones;)
        return prevData;
    }

    public static List<UserServicePresence> obtenerUsuariosActuales(){
        Date hoy = System.today();
        List<UserServicePresence> usuarios = [SELECT Id, UserId, User.CompanyName, StatusEndDate, StatusStartDate, ServicePresenceStatus.DeveloperName FROM UserServicePresence WHERE (User.UserRole.DeveloperName = 'Contact_Center' OR User.UserRole.DeveloperName ='Contact_Center_sin_acceso_a_Directorio') AND ServicePresenceStatus.DeveloperName != 'Offline' AND CreatedDate >=: hoy];
        return usuarios;
    }

    public static List<LiveChatTranscript> obtenerChatsActuales(){
        Date hoy = System.today();
        List<LiveChatTranscript> chats = [SELECT Id, Status, CreatedDate, RecordType.DeveloperName, CC_Servicio_Chat__c, EndTime, CC_Proveedor_Enrutado__c FROM LiveChatTranscript WHERE RecordType.DeveloperName IN ('CC_Empleados', 'CC_Clientes') AND CreatedDate >=: hoy AND CC_Tipo__c = 'Agente' AND Status IN ('Completed', 'Missed')];
        return chats;
    }

    public static List<PickListWrapper> getPickListValuesIntoList(Schema.DescribeFieldResult fieldResult){
        List<PickListWrapper> pickListValuesList= new List<PickListWrapper>();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            PickListWrapper wrapper = new PickListWrapper(pickListVal.getLabel(), pickListVal.getValue());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
    }

    @AuraEnabled
    public static WrapperInfoInicial busquedaFiltrada(List<String> franjaHoraria, List<String> proveedores, List<String> tipoContacto, List<String> servicios, String tablaSeleccionada){
    // public static WrapperInfoInicial busquedaFiltrada(/*String recTypeDevName,*/ List<String> franjaHoraria, List<String> proveedores, List<String> tipoContacto){
        Date hoy = System.today();
        Date dema = System.today().addDays(1);
        franjaHoraria.sort();
        String formattedHoy = hoy.year() + '-' + String.valueOf(hoy.month()).leftPad(2, '0') + '-' + String.valueOf(hoy.day()).leftPad(2, '0');
        String formattedDema = dema.year() + '-' + String.valueOf(dema.month()).leftPad(2, '0') + '-' + String.valueOf(dema.day()).leftPad(2, '0');

        List<String> franjaHorariaAux = new List<String>();
        if(!franjaHoraria.isEmpty()){
        for(String fh :franjaHoraria){
            String campo = 'CC_'+fh+'__c';
            franjaHorariaAux.add(campo);
        }
    }               
        String query = 'SELECT Id, CC_Proveedor__c, CC_TipoDePrevisiones__c, CC_NumeroDePrevisiones__c, CC_FranjaHoraria__c, CC_Fecha__c, CC_Servicio__c, CC_00__c, CC_01__c, CC_02__c, CC_03__c, CC_04__c, CC_05__c, CC_06__c, CC_07__c, CC_08__c, CC_09__c, CC_10__c,CC_11__c, CC_12__c, CC_13__c, CC_14__c, CC_15__c, CC_16__c, CC_17__c, CC_18__c, CC_19__c, CC_20__c, CC_21__c, CC_22__c, CC_23__c FROM CC_Prevision__c WHERE CC_Fecha__c >= ' + String.escapeSingleQuotes(formattedHoy) + ' AND CC_Fecha__c < ' + String.escapeSingleQuotes(formattedDema) + ' AND RecordType.DeveloperName = \'' + String.escapeSingleQuotes(tablaSeleccionada) + '\'';        
        
        List<String> whereClauses = new List<String>();

        if(!franjaHoraria.isEmpty() || !proveedores.isEmpty() || !tipoContacto.isEmpty()){
            query += ' AND ';
        }
        List<String> whereClausesAux = new List<String>();

        if (!franjaHorariaAux.isEmpty()) {
            String franjaHorariaCondition;
            for(String aux :franjaHorariaAux){
                franjaHorariaCondition =  aux + ' != null ';
                whereClausesAux.add(franjaHorariaCondition);
            }
            if (whereClausesAux.size() > 1) {
               String queryaux = '(' + String.join(whereClausesAux, ' OR ') + ')';
               whereClauses.add(queryaux);
            }else{
                whereClauses.addAll(whereClausesAux);
            }
        }
    
        if (!proveedores.isEmpty()) {
            String proveedoresCondition = ' CC_Proveedor__c IN (\'' + String.join(proveedores, '\',\'') + '\')';
            whereClauses.add(proveedoresCondition);
        }
    
        if (!tipoContacto.isEmpty()) {
            String tipoContactoCondition = ' CC_TipoDePrevisiones__c IN (\'' + String.join(tipoContacto, '\',\'') + '\')';
            whereClauses.add(tipoContactoCondition);
        }
        if (!servicios.isEmpty()) {
            String tipoServiciosCondition = ' CC_Servicio__c IN (\'' + String.join(servicios, '\',\'') + '\')';
            whereClauses.add(tipoServiciosCondition);
        }
    
        if (!whereClauses.isEmpty()) {
            query += String.join(whereClauses, ' AND ');
        }
    
        List<CC_Prevision__c> resultados = Database.query(query);
        //system.debug('query' + resultados);
        DateTime ahora = System.now(); 
        WrapperInfoInicial result;
        List<PrevDataModel> resMod = new List<PrevDataModel>();
        List<PrevDataModelChats> resModChat = new List<PrevDataModelchats>();
        if(tablaSeleccionada == 'CC_Agentes'){
            resMod = obtenerUsuariosPorProv(resultados, franjaHoraria);
            result = new WrapperInfoInicial(resMod, null, null, null, null, ahora, null);
        }else{
            resModChat = obtenerChatsPorProv(resultados, franjaHoraria);
            result = new WrapperInfoInicial(null, resModChat, null, null, null, ahora, null);
        }
        //system.debug('agentes' + resMod);
        //system.debug('chats' + resModChat);
        return result;

    }

}