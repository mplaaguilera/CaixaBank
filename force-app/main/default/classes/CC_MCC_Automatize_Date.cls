public with sharing class CC_MCC_Automatize_Date {

    @InvocableMethod(label='Automatizacion bajas de MCC' description='')
    public static void getMCC(List<String> lstMCCEntrada) {
        List<CC_MCC__c> lstObjMCCUpdate = new List<CC_MCC__c>();
        List<CBK_CatalogoFacturacion__c> lstObjCatUpdate = new List<CBK_CatalogoFacturacion__c>();
        List<Id> lstMCC = lstMCCEntrada[0].split(',');
        Set<Id> setTematicaId = new Set<Id>();
        Set<Id> setProductoId = new Set<Id>();
        Set<Id> setMotivoId = new Set<Id>();
        Set<Id> setCausaId = new Set<Id>();

        Map<Id, List<CC_MCC__c>> mapaTemMCC = new Map<Id, List<CC_MCC__c>>();
        Map<Id, List<CBK_CatalogoFacturacion__c>> mapaTemCat = new Map<Id, List<CBK_CatalogoFacturacion__c>>();
        Map<Id, List<CC_MCC__c>> mapaProdMCC = new Map<Id, List<CC_MCC__c>>();
        Map<Id, List<CBK_CatalogoFacturacion__c>> mapaProdCat = new Map<Id, List<CBK_CatalogoFacturacion__c>>();
        Map<Id, List<CC_MCC__c>> mapaMotMCC = new Map<Id, List<CC_MCC__c>>();
        Map<Id, List<CC_MCC__c>> mapaCauMCC = new Map<Id, List<CC_MCC__c>>();

        List<CC_MCC__c> lstObjMCCTem =new List<CC_MCC__c>();
        List<CBK_CatalogoFacturacion__c> lstObjCatTem =new List<CBK_CatalogoFacturacion__c>();
        List<CC_MCC__c> lstObjMCCProd =new List<CC_MCC__c>();
        List<CBK_CatalogoFacturacion__c> lstObjCatProd =new List<CBK_CatalogoFacturacion__c>();
        List<CC_MCC__c> lstObjMCCMot =new List<CC_MCC__c>();
        List<CC_MCC__c> lstObjMCCCau =new List<CC_MCC__c>();

        Datetime fechaFin = null;

        List<CC_MCC__c> lstObjMCCInicial = [SELECT Id, RecordType.DeveloperName, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE Id IN :lstMCC];
        if(!lstObjMCCInicial.isEmpty()){
            //Se mapean las listas de MCC por Record Type
            for (CC_MCC__c objMCC : lstObjMCCInicial) {
                if(objMCC.RecordType.DeveloperName =='CC_Tematica'){
                    setTematicaId.add(objMCC.Id);
                } 
                if(objMCC.RecordType.DeveloperName =='CC_Producto_Servicio'){
                    setProductoId.add(objMCC.Id);
                } 
                if(objMCC.RecordType.DeveloperName =='CC_Motivo'){
                    setMotivoId.add(objMCC.Id);
                }
                if(objMCC.RecordType.DeveloperName =='CC_Causa'){
                    setCausaId.add(objMCC.Id);
                }
            }
        }
        if(!setTematicaId.isEmpty()){
            lstObjMCCTem = [SELECT Id, CC_Tematica__c, CC_Tematica__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Inicio__c, RecordType.DeveloperName FROM CC_MCC__c WHERE CC_Tematica__c IN :setTematicaId AND CC_Activo__c = true];
            lstObjCatTem = [SELECT Id, CC_Tematica__c, CC_Tematica__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Fin_Vigencia__c, CC_Fecha_Inicio_Vigencia__c,RecordType.DeveloperName FROM CBK_CatalogoFacturacion__c WHERE CC_Tematica__c IN :setTematicaId];
            if(!lstObjMCCTem.isEmpty()){
                for(CC_MCC__c tematica: lstObjMCCTem){
                    if(mapaTemMCC.containsKey(tematica.CC_Tematica__c)) {
                        List<CC_MCC__c> lstTematica = mapaTemMCC.get(tematica.CC_Tematica__c);
                        lstTematica.add(tematica);
                        mapaTemMCC.put(tematica.CC_Tematica__c, lstTematica);
                    } else {
                        mapaTemMCC.put(tematica.CC_Tematica__c, new List<CC_MCC__c> {tematica });
                    }
                }
            }

            if(!lstObjCatTem.isEmpty()){
                for(CBK_CatalogoFacturacion__c tematica: lstObjCatTem){
                    if(mapaTemCat.containsKey(tematica.CC_Tematica__c)) {
                        List<CBK_CatalogoFacturacion__c> lstTematica = mapaTemCat.get(tematica.CC_Tematica__c);
                        lstTematica.add(tematica);
                        mapaTemCat.put(tematica.CC_Tematica__c, lstTematica);
                    } else {
                        mapaTemCat.put(tematica.CC_Tematica__c, new List<CBK_CatalogoFacturacion__c> {tematica });
                    }
                }
            }
        }
        if(!setProductoId.isEmpty()){
                lstObjMCCProd = [SELECT Id, CC_Producto_Servicio__c, CC_Producto_Servicio__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Inicio__c, RecordType.DeveloperName FROM CC_MCC__c WHERE CC_Producto_Servicio__c IN :setProductoId AND CC_Activo__c = true];
                lstObjCatProd = [SELECT Id, CC_Producto__c, CC_Producto__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Fin_Vigencia__c, CC_Fecha_Inicio_Vigencia__c,RecordType.DeveloperName FROM CBK_CatalogoFacturacion__c WHERE CC_Producto__c IN :setProductoId];
                if(!lstObjMCCProd.isEmpty()){
                    for(CC_MCC__c prod: lstObjMCCProd){
                        if(mapaProdMCC.containsKey(prod.CC_Producto_Servicio__c)) {
                            List<CC_MCC__c> lstProd = mapaProdMCC.get(prod.CC_Producto_Servicio__c);
                            lstProd.add(prod);
                            mapaProdMCC.put(prod.CC_Producto_Servicio__c, lstProd);
                        } else {
                            mapaProdMCC.put(prod.CC_Producto_Servicio__c, new List<CC_MCC__c> {prod });
                        }
                    }
                }
        

            if(!lstObjCatProd.isEmpty()){
                for(CBK_CatalogoFacturacion__c prod: lstObjCatProd){
                    if(mapaProdCat.containsKey(prod.CC_Producto__c)) {
                        List<CBK_CatalogoFacturacion__c> lstProd = mapaProdCat.get(prod.CC_Producto__c);
                        lstProd.add(prod);
                        mapaProdCat.put(prod.CC_Producto__c, lstProd);
                    } else {
                        mapaProdCat.put(prod.CC_Producto__c, new List<CBK_CatalogoFacturacion__c> {prod });
                    }
                }
            }
        }
        if(!setMotivoId.isEmpty()){
            lstObjMCCMot = [SELECT Id, CC_Motivo__c, CC_Motivo__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Inicio__c, RecordType.DeveloperName FROM CC_MCC__c WHERE CC_Motivo__c IN :setMotivoId AND CC_Activo__c = true];
            if(!lstObjMCCMot.isEmpty()){
                for(CC_MCC__c mot: lstObjMCCMot){
                    if(mapaMotMCC.containsKey(mot.CC_Motivo__c)) {
                        List<CC_MCC__c> lstMotivo = mapaMotMCC.get(mot.CC_Motivo__c);
                        lstMotivo.add(mot);
                        mapaMotMCC.put(mot.CC_Motivo__c, lstMotivo);
                    } else {
                        mapaMotMCC.put(mot.CC_Motivo__c, new List<CC_MCC__c> {mot });
                    }
                }
            }
        }
        if(!setCausaId.isEmpty()){
            lstObjMCCCau = [SELECT Id, CC_Causa__c, CC_Causa__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Inicio__c, RecordType.DeveloperName FROM CC_MCC__c WHERE CC_Causa__c IN :setCausaId AND CC_Activo__c = true];                    
            if(!lstObjMCCCau.isEmpty()){
                for(CC_MCC__c causa: lstObjMCCCau){
                    if(mapaCauMCC.containsKey(causa.CC_Causa__c)) {
                        List<CC_MCC__c> lstCau = mapaCauMCC.get(causa.CC_Causa__c);
                        lstCau.add(causa);
                        mapaCauMCC.put(causa.CC_Causa__c, lstCau);
                    } else {
                        mapaCauMCC.put(causa.CC_Causa__c, new List<CC_MCC__c> {causa });
                    }
                }
            }     
        }

        if(!lstObjMCCTem.isEmpty()){
                for(CC_MCC__c iniMCC : lstObjMCCInicial){
                    if(mapaTemMCC.containsKey(iniMCC.Id)){
                        List <CC_MCC__c> lstMCCRelatedTem = mapaTemMCC.get(iniMCC.Id);
                        for (CC_MCC__c mccRelatedTem : lstMCCRelatedTem) {
                            if((mccRelatedTem.CC_Fecha_Vigencia_Fin__c == null || mccRelatedTem.CC_Fecha_Vigencia_Fin__c <= System.now()) && mccRelatedTem.CC_Fecha_Vigencia_Inicio__c <= iniMCC.CC_Fecha_Vigencia_Fin__c){
                                mccRelatedTem.CC_Fecha_Vigencia_Fin__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                                lstObjMCCUpdate.add(mccRelatedTem);
                            }
                        }
                    }
                }
        }

        if(!lstObjCatTem.isEmpty()){
            for(CC_MCC__c iniMCC : lstObjMCCInicial){
                if(mapaTemCat.containsKey(iniMCC.Id)){
                    List <CBK_CatalogoFacturacion__c> lstCatRelatedTem = mapaTemCat.get(iniMCC.Id);
                    for (CBK_CatalogoFacturacion__c catRelatedTem : lstCatRelatedTem) {
                        if((catRelatedTem.CC_Fecha_Fin_Vigencia__c == null || catRelatedTem.CC_Fecha_Fin_Vigencia__c <= System.now()) && catRelatedTem.CC_Fecha_Inicio_Vigencia__c <= iniMCC.CC_Fecha_Vigencia_Fin__c){
                            catRelatedTem.CC_Fecha_Fin_Vigencia__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                            lstObjCatUpdate.add(catRelatedTem);
                        }
                    }
                }
            }
        }

        if(!lstObjMCCProd.isEmpty()){
            for(CC_MCC__c iniMCC : lstObjMCCInicial){
                if(mapaProdMCC.containsKey(iniMCC.Id)){
                    List <CC_MCC__c> lstMCCRelatedProd = mapaProdMCC.get(iniMCC.Id);
                    for (CC_MCC__c mccRelatedProd : lstMCCRelatedProd) {
                        if((mccRelatedProd.CC_Fecha_Vigencia_Fin__c == null || mccRelatedProd.CC_Fecha_Vigencia_Fin__c <= System.now()) && mccRelatedProd.CC_Fecha_Vigencia_Inicio__c <= iniMCC.CC_Fecha_Vigencia_Fin__c){
                            mccRelatedProd.CC_Fecha_Vigencia_Fin__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                            lstObjMCCUpdate.add(mccRelatedProd);
                        }
                    }
                }
            }
        }

        if(!lstObjCatProd.isEmpty()){
            for(CC_MCC__c iniMCC : lstObjMCCInicial){
                if(mapaProdCat.containsKey(iniMCC.Id)){
                    List <CBK_CatalogoFacturacion__c> lstCatRelatedProd = mapaProdCat.get(iniMCC.Id);
                    for (CBK_CatalogoFacturacion__c catRelatedProd : lstCatRelatedProd) {
                        if((catRelatedProd.CC_Fecha_Fin_Vigencia__c == null || catRelatedProd.CC_Fecha_Fin_Vigencia__c <= System.now()) && catRelatedProd.CC_Fecha_Inicio_Vigencia__c <= iniMCC.CC_Fecha_Vigencia_Fin__c){
                            catRelatedProd.CC_Fecha_Fin_Vigencia__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                            lstObjCatUpdate.add(catRelatedProd);
                        }
                    }
                }
            }
        }

        if(!lstObjMCCMot.isEmpty()){
            for(CC_MCC__c iniMCC : lstObjMCCInicial){
                if(mapaMotMCC.containsKey(iniMCC.Id)){
                    List <CC_MCC__c> lstMCCRelatedMot = mapaMotMCC.get(iniMCC.Id);
                    for (CC_MCC__c mccRelatedMot : lstMCCRelatedMot) {
                        if((mccRelatedMot.CC_Fecha_Vigencia_Fin__c == null || mccRelatedMot.CC_Fecha_Vigencia_Fin__c <= System.now()) && mccRelatedMot.CC_Fecha_Vigencia_Inicio__c <= iniMCC.CC_Fecha_Vigencia_Fin__c){
                            mccRelatedMot.CC_Fecha_Vigencia_Fin__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                            lstObjMCCUpdate.add(mccRelatedMot);
                        }
                    }
                    
                }
            }
        }

        if(!lstObjMCCCau.isEmpty()){
            for(CC_MCC__c iniMCC : lstObjMCCInicial){
                if(mapaCauMCC.containsKey(iniMCC.Id)){
                    List <CC_MCC__c> lstMCCRelatedCau = mapaCauMCC.get(iniMCC.Id);
                    for (CC_MCC__c mccRelatedCau : lstMCCRelatedCau) {
                        if((mccRelatedCau.CC_Fecha_Vigencia_Fin__c == null || mccRelatedCau.CC_Fecha_Vigencia_Fin__c <= System.now()) && mccRelatedCau.CC_Fecha_Vigencia_Inicio__c <= iniMCC.CC_Fecha_Vigencia_Fin__c){
                            mccRelatedCau.CC_Fecha_Vigencia_Fin__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                            
                            lstObjMCCUpdate.add(mccRelatedCau);
                        }
                    }
                }
            }
        }

        if(!lstObjMCCUpdate.isEmpty()){
                Database.update(lstObjMCCUpdate);
            }
        if(!lstObjCatUpdate.isEmpty()){

            Database.update(lstObjCatUpdate);
        }
    }



    
    public static void bajaProductos(List<CC_MCC__c> lstMCC) {
        Set<Id> setTematicaId = new Set<Id>();
        List<CC_MCC__c> lstObjMCCProd =new List<CC_MCC__c>();
        List<CBK_CatalogoFacturacion__c> lstObjCatTem =new List<CBK_CatalogoFacturacion__c>();
        Map<Id, List<CC_MCC__c>> mapaTemProdMCC = new Map<Id, List<CC_MCC__c>>(); 
        Map<Id, List<CBK_CatalogoFacturacion__c>> mapaTemCat = new Map<Id, List<CBK_CatalogoFacturacion__c>>(); 
        List<CC_MCC__c> lstObjMCCUpdate = new List<CC_MCC__c>();
        List<CBK_CatalogoFacturacion__c> lstObjCatUpdate = new List<CBK_CatalogoFacturacion__c>();

        if(!lstMCC.isEmpty()){
            for(CC_MCC__c mcc :lstMCC){
                setTematicaId.add(mcc.Id);  
            }
        }
        
        if(!setTematicaId.isEmpty()){
            lstObjMCCProd = [SELECT Id, CC_Activo__c, CC_Tematica__c, CC_Tematica__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Inicio__c, RecordType.DeveloperName FROM CC_MCC__c WHERE CC_Tematica__c IN :setTematicaId AND CC_Activo__c = true];
            lstObjCatTem = [SELECT Id, CC_Tematica__c, CC_Tematica__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Fin_Vigencia__c, CC_Fecha_Inicio_Vigencia__c,RecordType.DeveloperName FROM CBK_CatalogoFacturacion__c WHERE CC_Tematica__c IN :setTematicaId];
                    
            if(!lstObjMCCProd.isEmpty()){
                for(CC_MCC__c producto: lstObjMCCProd){
                    if(mapaTemProdMCC.containsKey(producto.CC_Tematica__c)) {
                        List<CC_MCC__c> lstProducto = mapaTemProdMCC.get(producto.CC_Tematica__c);
                        lstProducto.add(producto);
                        mapaTemProdMCC.put(producto.CC_Tematica__c, lstProducto);
                    } else {
                        mapaTemProdMCC.put(producto.CC_Tematica__c, new List<CC_MCC__c> {producto });
                    }
                }

                for(CC_MCC__c iniMCC : lstMCC){
                    if(mapaTemProdMCC.containsKey(iniMCC.Id)){
                        List <CC_MCC__c> lstMCCRelatedTem = mapaTemProdMCC.get(iniMCC.Id);
                        for (CC_MCC__c mccRelatedTem : lstMCCRelatedTem) {
                            if(mccRelatedTem.CC_Activo__c){
                                mccRelatedTem.CC_Fecha_Vigencia_Fin__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                                lstObjMCCUpdate.add(mccRelatedTem);
                            }
                        }
                    }
                }   
            }

            if(!lstObjCatTem.isEmpty()){
                for(CBK_CatalogoFacturacion__c tematica: lstObjCatTem){
                    if(mapaTemCat.containsKey(tematica.CC_Tematica__c)) {
                        List<CBK_CatalogoFacturacion__c> lstTematica = mapaTemCat.get(tematica.CC_Tematica__c);
                        lstTematica.add(tematica);
                        mapaTemCat.put(tematica.CC_Tematica__c, lstTematica);
                    } else {
                        mapaTemCat.put(tematica.CC_Tematica__c, new List<CBK_CatalogoFacturacion__c> {tematica });
                    }
                }

                for(CC_MCC__c iniMCC : lstMCC){
                    if(mapaTemCat.containsKey(iniMCC.Id)){
                        List <CBK_CatalogoFacturacion__c> lstCatRelatedTem = mapaTemCat.get(iniMCC.Id);
                        for (CBK_CatalogoFacturacion__c catRelatedTem : lstCatRelatedTem) {
                            if((catRelatedTem.CC_Fecha_Fin_Vigencia__c == null || catRelatedTem.CC_Fecha_Fin_Vigencia__c <= System.now()) && catRelatedTem.CC_Fecha_Inicio_Vigencia__c <= iniMCC.CC_Fecha_Vigencia_Fin__c){
                                catRelatedTem.CC_Fecha_Fin_Vigencia__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                                lstObjCatUpdate.add(catRelatedTem);
                            }
                        }
                    }
                }
            }
        }

        if(!lstObjMCCUpdate.isEmpty()){
            Database.update(lstObjMCCUpdate);
            bajaMotivos(lstObjMCCUpdate);
        }
        if(!lstObjCatUpdate.isEmpty()){

            Database.update(lstObjCatUpdate);
        }

    }

    public static void bajaMotivos(List<CC_MCC__c> lstMCC) {
        Set<Id> setProductoId = new Set<Id>();
        List<CC_MCC__c> lstObjMCCMot =new List<CC_MCC__c>();
        List<CBK_CatalogoFacturacion__c> lstObjCatProd =new List<CBK_CatalogoFacturacion__c>();
        Map<Id, List<CC_MCC__c>> mapaProdMotivoMCC = new Map<Id, List<CC_MCC__c>>();
        Map<Id, List<CBK_CatalogoFacturacion__c>> mapaProdCat = new Map<Id, List<CBK_CatalogoFacturacion__c>>();
        List<CC_MCC__c> lstObjMCCUpdate = new List<CC_MCC__c>();
        List<CBK_CatalogoFacturacion__c> lstObjCatUpdate = new List<CBK_CatalogoFacturacion__c>();

        if(!lstMCC.isEmpty()){
            for(CC_MCC__c mcc : lstMCC){
                setProductoId.add(mcc.Id);  
            }
        }

        if(!setProductoId.isEmpty()){
            lstObjMCCMot = [SELECT Id, CC_Activo__c, CC_Producto_Servicio__c, CC_Producto_Servicio__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Inicio__c, RecordType.DeveloperName FROM CC_MCC__c WHERE CC_Producto_Servicio__c IN :setProductoId AND CC_Activo__c = true];
            lstObjCatProd = [SELECT Id, CC_Producto__c, CC_Producto__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Fin_Vigencia__c, CC_Fecha_Inicio_Vigencia__c,RecordType.DeveloperName FROM CBK_CatalogoFacturacion__c WHERE CC_Producto__c IN :setProductoId];
            
            if(!lstObjMCCMot.isEmpty()){
                for(CC_MCC__c motivo: lstObjMCCMot){
                    if(mapaProdMotivoMCC.containsKey(motivo.CC_Producto_Servicio__c)) {
                        List<CC_MCC__c> lstMot= mapaProdMotivoMCC.get(motivo.CC_Producto_Servicio__c);
                        lstMot.add(motivo);
                        mapaProdMotivoMCC.put(motivo.CC_Producto_Servicio__c, lstMot);
                    } else {
                        mapaProdMotivoMCC.put(motivo.CC_Producto_Servicio__c, new List<CC_MCC__c> {motivo });
                    }
                }

                for(CC_MCC__c iniMCC : lstMCC){
                    if(mapaProdMotivoMCC.containsKey(iniMCC.Id)){
                        List <CC_MCC__c> lstMCCRelatedProd = mapaProdMotivoMCC.get(iniMCC.Id);
                        for (CC_MCC__c mccRelatedProd : lstMCCRelatedProd) {
                            if(mccRelatedProd.CC_Activo__c){
                                mccRelatedProd.CC_Fecha_Vigencia_Fin__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                                lstObjMCCUpdate.add(mccRelatedProd);
                            }
                        }
                    }
                }
            }
            
            if(!lstObjCatProd.isEmpty()){
                for(CBK_CatalogoFacturacion__c prod: lstObjCatProd){
                    if(mapaProdCat.containsKey(prod.CC_Producto__c)) {
                        List<CBK_CatalogoFacturacion__c> lstProd = mapaProdCat.get(prod.CC_Producto__c);
                        lstProd.add(prod);
                        mapaProdCat.put(prod.CC_Producto__c, lstProd);
                    } else {
                        mapaProdCat.put(prod.CC_Producto__c, new List<CBK_CatalogoFacturacion__c> {prod });
                    }
                }

                for(CC_MCC__c iniMCC : lstMCC){
                    if(mapaProdCat.containsKey(iniMCC.Id)){
                        List <CBK_CatalogoFacturacion__c> lstCatRelatedProd = mapaProdCat.get(iniMCC.Id);
                        for (CBK_CatalogoFacturacion__c catRelatedProd : lstCatRelatedProd) {
                            if((catRelatedProd.CC_Fecha_Fin_Vigencia__c == null || catRelatedProd.CC_Fecha_Fin_Vigencia__c <= System.now()) && catRelatedProd.CC_Fecha_Inicio_Vigencia__c <= iniMCC.CC_Fecha_Vigencia_Fin__c){
                                catRelatedProd.CC_Fecha_Fin_Vigencia__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                                lstObjCatUpdate.add(catRelatedProd);
                            }
                        }
                        
                    }
                }
            }      
        }

        if(!lstObjMCCUpdate.isEmpty()){
            Database.update(lstObjMCCUpdate);
            bajaCausa(lstObjMCCUpdate);
        }
        if(!lstObjCatUpdate.isEmpty()){

            Database.update(lstObjCatUpdate);
        }
            
    }

    public static void bajaCausa(List<CC_MCC__c> lstMCC) {
        Set<Id> setMotivoId = new Set<Id>();
        List<CC_MCC__c> lstObjMCCCau =new List<CC_MCC__c>();
        Map<Id, List<CC_MCC__c>> mapaMotCausaMCC = new Map<Id, List<CC_MCC__c>>();
        List<CC_MCC__c> lstObjMCCUpdate = new List<CC_MCC__c>();    

        if(!lstMCC.isEmpty()){
            for(CC_MCC__c mcc : lstMCC){
                setMotivoId.add(mcc.Id);  
            }
        }

        if(!setMotivoId.isEmpty()){
            lstObjMCCCau = [SELECT Id, CC_Activo__c, CC_Motivo__c, CC_Motivo__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Inicio__c, RecordType.DeveloperName FROM CC_MCC__c WHERE CC_Motivo__c IN :setMotivoId AND CC_Activo__c = true];
            if(!lstObjMCCCau.isEmpty()){
                for(CC_MCC__c causa: lstObjMCCCau){
                    if(mapaMotCausaMCC.containsKey(causa.CC_Motivo__c)) {
                        List<CC_MCC__c> lstCausa = mapaMotCausaMCC.get(causa.CC_Motivo__c);
                        lstCausa.add(causa);
                        mapaMotCausaMCC.put(causa.CC_Motivo__c, lstCausa);
                    } else {
                        mapaMotCausaMCC.put(causa.CC_Motivo__c, new List<CC_MCC__c> {causa });
                    }
                }

                for(CC_MCC__c iniMCC : lstMCC){
                    if(mapaMotCausaMCC.containsKey(iniMCC.Id)){
                        List <CC_MCC__c> lstMCCRelatedMot = mapaMotCausaMCC.get(iniMCC.Id);
                        for (CC_MCC__c mccRelatedMot : lstMCCRelatedMot) {
                            if(mccRelatedMot.CC_Activo__c){
                                mccRelatedMot.CC_Fecha_Vigencia_Fin__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                                lstObjMCCUpdate.add(mccRelatedMot);
                            }
                        }
                        
                    }
                }
            }            
        }
               
        if(!lstObjMCCUpdate.isEmpty()){
            Database.update(lstObjMCCUpdate);
            bajaSolucion(lstObjMCCUpdate);
        }

    }

    public static void bajaSolucion(List<CC_MCC__c> lstMCC) {
        Set<Id> setCausaId = new Set<Id>();
        List<CC_MCC__c> lstObjMCCSol =new List<CC_MCC__c>();
        Map<Id, List<CC_MCC__c>> mapaCauSolMCC = new Map<Id, List<CC_MCC__c>>();
        List<CC_MCC__c> lstObjMCCUpdate = new List<CC_MCC__c>();

        if(!lstMCC.isEmpty()){
            for(CC_MCC__c mcc : lstMCC){
                setCausaId.add(mcc.Id);  
            }
        }

      
        if(!setCausaId.isEmpty()){
            lstObjMCCSol = [SELECT Id, CC_Activo__c, CC_Causa__c, CC_Causa__r.CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Fin__c, CC_Fecha_Vigencia_Inicio__c, RecordType.DeveloperName FROM CC_MCC__c WHERE CC_Causa__c IN :setCausaId AND CC_Activo__c = true];                    
            if(!lstObjMCCSol.isEmpty()){
                for(CC_MCC__c sol: lstObjMCCSol){
                    if(mapaCauSolMCC.containsKey(sol.CC_Causa__c)) {
                        List<CC_MCC__c> lstSol = mapaCauSolMCC.get(sol.CC_Causa__c);
                        lstSol.add(sol);
                        mapaCauSolMCC.put(sol.CC_Causa__c, lstSol);
                    } else {
                        mapaCauSolMCC.put(sol.CC_Causa__c, new List<CC_MCC__c> {sol});
                    }
                }

                for(CC_MCC__c iniMCC : lstMCC){
                    if(mapaCauSolMCC.containsKey(iniMCC.Id)){
                        List <CC_MCC__c> lstMCCRelatedCau = mapaCauSolMCC.get(iniMCC.Id);
                        for (CC_MCC__c mccRelatedCau : lstMCCRelatedCau) {
                            if(mccRelatedCau.CC_Activo__c){
                                mccRelatedCau.CC_Fecha_Vigencia_Fin__c = iniMCC.CC_Fecha_Vigencia_Fin__c;
                                lstObjMCCUpdate.add(mccRelatedCau);
                            }
                        }
                        
                    }
                }
            }                  
        }

        if(!lstObjMCCUpdate.isEmpty()){
            Database.update(lstObjMCCUpdate);
        }
  
    }

    
}