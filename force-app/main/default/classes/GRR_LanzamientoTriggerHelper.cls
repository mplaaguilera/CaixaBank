public with sharing class GRR_LanzamientoTriggerHelper {

    public static List<GRR_Lanzamiento__c> filtrarLanzamientosGRR(List<GRR_Lanzamiento__c> lstLanzamientos) {
        List<GRR_Lanzamiento__c> lanzamientosGRR = new List<GRR_Lanzamiento__c>();
        Id grrLanzamientoTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Lanzamiento__c', 'GRR_Lanzamiento');
        for (GRR_Lanzamiento__c lanzamiento : lstLanzamientos) {
            if (lanzamiento.recordTypeId == grrLanzamientoTypeId) {
                lanzamientosGRR.add(lanzamiento);
            }
        } 
        return lanzamientosGRR;
    } 

    public static void crearNuevasURs(List<GRR_Lanzamiento__c> lstLanzamientos) {
        Set<String> codURLanzamientos = new Set<String>();
        for (GRR_Lanzamiento__c lanzamiento : lstLanzamientos) {
            if (lanzamiento.GRR_Codigo_UR__c != null) {
                codURLanzamientos.add(lanzamiento.GRR_Codigo_UR__c);
            }
        }
        List<String> nombreURsExistentes = new List<String>();
        List<GRR_UR__c> ursAInsertar = new List<GRR_UR__c>();
        if (!codURLanzamientos.isEmpty()) {   
            List<GRR_UR__c> ursExistentes = new List<GRR_UR__c>([SELECT GRR_Id_UR__c FROM GRR_UR__c WHERE GRR_Id_UR__c IN :codURLanzamientos]);
            for (GRR_UR__c ur : ursExistentes) {
                nombreURsExistentes.add(ur.GRR_Id_UR__c); 
            }
            for (GRR_Lanzamiento__c lanzamiento : lstLanzamientos) {
                if (!nombreURsExistentes.contains(lanzamiento.GRR_Codigo_UR__c)) {
                    GRR_UR__c ur = new GRR_UR__c();
                    ur.GRR_Id_UR__c = lanzamiento.GRR_Codigo_UR__c;
                    ur.GRR_Direccion__c = lanzamiento.GRR_Direccion__c;
                    ur.GRR_Poblacion_UR__c = lanzamiento.GRR_Poblacion__c;
                    ur.GRR_Region__c = lanzamiento.GRR_Provincia__c;
                    
                    if (!ursAInsertar.contains(ur)) {
                        ursAInsertar.add(ur);
                    }
                }
            }
            Database.insert(ursAInsertar, false);                    
        }
    }

    //Informa campo lookup y actualiza fecha de lanzamiento con menos consultas.
    public static void informarLookupUR(List<GRR_Lanzamiento__c> lstLanzamientos) {
        Set<String> codURLanzamientos = new Set<String>();
        for (GRR_Lanzamiento__c lanzamiento : lstLanzamientos) {
            if (lanzamiento.GRR_Codigo_UR__c != null) {
                codURLanzamientos.add(lanzamiento.GRR_Codigo_UR__c);
            }
        }         
        List<GRR_Lanzamiento__c> lanzamientosActualizar = new List<GRR_Lanzamiento__c>(); 
        //Todos los Lanzamientos, no se puede hacer con lstLanzamientos porque son read only
        List<GRR_Lanzamiento__c> listaLanzamientos = [SELECT Id, GRR_UR__c, GRR_Codigo_UR__c, GRR_Fecha_Prevista_Posesion__c, GRR_Situacion__c FROM GRR_Lanzamiento__c WHERE Id IN :lstLanzamientos]; 
        if (codURLanzamientos != null) {
            Map<String, Id> mapaURIds = new Map<String, Id>(); 
            Map<Id, GRR_UR__c> mapaIdUrAux = new Map<Id, GRR_UR__c>();
            List<GRR_UR__c> ursToUpdate = new List<GRR_UR__c>();
            List<GRR_UR__c> listaURs =  [SELECT Id, GRR_Id_UR__c, GRR_Fecha_Proximo_Lanzamiento__c, GRR_Situacion_Proximo_Lanzamiento__c, GRR_Fecha_Ultimo_Lanzamiento__c, GRR_Situacion_Ultimo_Lanzamiento__c
                                            FROM GRR_UR__c 
                                            WHERE GRR_Id_UR__c IN :codURLanzamientos];
            for (GRR_UR__c ur : listaURs) {
                mapaURIds.put(ur.GRR_Id_UR__c, ur.Id);
                mapaIdUrAux.put(ur.Id, ur);
            }
            for (GRR_Lanzamiento__c lanzamiento : listaLanzamientos) {
                //Actualiza campo lookup a UR en lanzamiento
                if (mapaURIds.containsKey(lanzamiento.GRR_Codigo_UR__c)) {
                    lanzamiento.GRR_UR__c = mapaURIds.get(lanzamiento.GRR_Codigo_UR__c);
                    lanzamientosActualizar.add(lanzamiento);
                }
                //Actualiza fecha próximo/último lanzamiento en UR
                if (lanzamiento.GRR_UR__c != null && mapaURIds.containsKey(lanzamiento.GRR_Codigo_UR__c)) {
                    Id urId = lanzamiento.GRR_UR__c;
                    GRR_UR__c ur = mapaIdUrAux.get(urId);
                    Datetime fechaLanzamiento = lanzamiento.GRR_Fecha_Prevista_Posesion__c;
                    Datetime fechaLanzamientoProximaExistente = ur.GRR_Fecha_Proximo_Lanzamiento__c;
                    Datetime fechaLanzamientoUltimaExistente = ur.GRR_Fecha_Ultimo_Lanzamiento__c;
                    if (fechaLanzamiento != null && fechaLanzamiento > Datetime.now() && (fechaLanzamientoProximaExistente == null || fechaLanzamiento < fechaLanzamientoProximaExistente)) {
                        ur.GRR_Fecha_Proximo_Lanzamiento__c = fechaLanzamiento;
                        ur.GRR_Situacion_Proximo_Lanzamiento__c = lanzamiento.GRR_Situacion__c;
                    }
                    if (fechaLanzamiento != null && fechaLanzamiento <= Datetime.now() && (fechaLanzamientoUltimaExistente == null || fechaLanzamiento > fechaLanzamientoUltimaExistente)) {
                        ur.GRR_Fecha_Ultimo_Lanzamiento__c = fechaLanzamiento;
                        ur.GRR_Situacion_Ultimo_Lanzamiento__c = lanzamiento.GRR_Situacion__c;
                    }
                    if (!ursToUpdate.contains(ur)) { // Verificar si la UR ya está en la lista
                        ursToUpdate.add(ur);
                    }
                }
            }
            Database.update(lanzamientosActualizar, false);
            if (!ursToUpdate.isEmpty()) {
                update ursToUpdate;
            }
        }
    }

    public static void informarClaveLanzamiento(List<GRR_Lanzamiento__c> lstLanzamientos){
        for (GRR_Lanzamiento__c lanzamiento : lstLanzamientos) {
            if(String.isBlank(lanzamiento.GRR_Codigo_Lanzamiento__c)){
                lanzamiento.GRR_Codigo_Lanzamiento__c=lanzamiento.GRR_Codigo_UR__c +'-'+ lanzamiento.GRR_Fecha_Prevista_Posesion__c.format('yyyyMMdd');    
            }
        }
    }

    public static void regularizarFechaProxUR(List<GRR_Lanzamiento__c> lanzamientosGRR) {
        Map<Id,GRR_Lanzamiento__c> mapURFechaProx = new Map<Id,GRR_Lanzamiento__c>();
        //Obtenemos los URs de fechas de lanzamiento que se estan borrando
        for (GRR_Lanzamiento__c lanzamiento : lanzamientosGRR) {
            if(lanzamiento.GRR_UR__c!=null){ //Para evitar que se ejecute si se borra un UR y sus correspondientes fechas
                mapURFechaProx.put(lanzamiento.GRR_UR__c,lanzamiento);
            }
        }
        if(!mapURFechaProx.isEmpty()) {
            //Consultamos las URs para obtener sus fechas de lanzamiento
            Map<Id, GRR_UR__c> mapaURs = new Map<Id, GRR_UR__c>([SELECT Id, GRR_Fecha_Proximo_Lanzamiento__c,GRR_Situacion_Proximo_Lanzamiento__c,GRR_Situacion_Ultimo_Lanzamiento__c,GRR_Fecha_Ultimo_Lanzamiento__c,
                                                                (SELECT Id, GRR_Fecha_Prevista_Posesion__c,GRR_Situacion__c FROM Lanzamientos__r ORDER BY GRR_Fecha_Prevista_Posesion__c ASC)  FROM GRR_UR__c WHERE Id IN :mapURFechaProx.keySet()]);
            List<GRR_UR__c> listaURDef=new List<GRR_UR__c>();
            Datetime fechaBorrada;
            GRR_UR__c ur;
            GRR_Lanzamiento__c lanzamiento;
            Datetime fecha;
            String situacion;
            boolean actualizar=false;
            for (Id urId : mapaURs.keySet()) {
                fechaBorrada=mapURFechaProx.get(urId).GRR_Fecha_Prevista_Posesion__c;
                ur=mapaURs.get(urId);
                if(ur.GRR_Fecha_Proximo_Lanzamiento__c!=null && ur.GRR_Fecha_Proximo_Lanzamiento__c.isSameDay(fechaBorrada)){
                    lanzamiento=obtenerFechaProxima(ur,fechaBorrada);
                    if(lanzamiento!=null){
                        fecha=lanzamiento.GRR_Fecha_Prevista_Posesion__c;
                        situacion=lanzamiento.GRR_Situacion__c;
                    }
                    ur.GRR_Fecha_Proximo_Lanzamiento__c= fecha;
                    ur.GRR_Situacion_Proximo_Lanzamiento__c=situacion;
                    actualizar=true;
                }
                if(ur.GRR_Fecha_Ultimo_Lanzamiento__c!=null &&ur.GRR_Fecha_Ultimo_Lanzamiento__c.isSameDay(fechaBorrada)){
                    lanzamiento=obtenerFechaUltima(ur,fechaBorrada);
                    if(lanzamiento!=null){
                        fecha=lanzamiento.GRR_Fecha_Prevista_Posesion__c;
                        situacion=lanzamiento.GRR_Situacion__c;
                    }
                    ur.GRR_Fecha_Ultimo_Lanzamiento__c= fecha;
                    ur.GRR_Situacion_Ultimo_Lanzamiento__c=situacion;
                    actualizar=true;
                }
                if(actualizar){
                    listaURDef.add(ur);
                    actualizar=false;
                    fecha=null;
                    situacion=null;
                }       
            }    
            if(!listaURDef.isEmpty()){
                update listaURDef;
            }
        }
    }

    public static GRR_Lanzamiento__c obtenerFechaProxima(GRR_UR__c ur, Datetime fechaBorrada){   
        GRR_Lanzamiento__c lanzamientoProximo=null;
        for(GRR_Lanzamiento__c lanzamiento : ur.Lanzamientos__r) {
            if(lanzamiento.GRR_Fecha_Prevista_Posesion__c>fechaBorrada){
                lanzamientoProximo=lanzamiento;
                break;
            }    
        }
        return lanzamientoProximo;
    }

    public static GRR_Lanzamiento__c obtenerFechaUltima(GRR_UR__c ur, Datetime fechaBorrada) {
        GRR_Lanzamiento__c ultimoLanzamiento=null;
        for(GRR_Lanzamiento__c lanzamiento : ur.Lanzamientos__r) {
            if(lanzamiento.GRR_Fecha_Prevista_Posesion__c<fechaBorrada){
                ultimoLanzamiento=lanzamiento;     
            } 
        }
        return ultimoLanzamiento;
    }
}