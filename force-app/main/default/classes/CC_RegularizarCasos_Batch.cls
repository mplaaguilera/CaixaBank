/**
 * @description       : Batch para regularizar todos los casos creados desde el 1/05/2022
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 01-04-2023
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   10-24-2022   Adrian Mariscal   Initial Version
 * 1.1   12-22-2022   Adrian Mariscal   Corregido null pointer al buscar el propietario
**/
global with sharing class CC_RegularizarCasos_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    private String filtro;
    
    global CC_RegularizarCasos_Batch() {
        System.debug('Regularizacion iniciada sin filtros');
    }

    global CC_RegularizarCasos_Batch(String filtro) {
        System.debug('Regularizacion iniciada con filtros');
        this.filtro = filtro;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) { 
        Datetime fechaCreacion = Datetime.newInstance(2022, 05, 01);
        String query;
        String fields = 'Id,Origin,CC_Canal_Procedencia__c,CC_Canal_Operativo__c,CC_MCC_Tematica__c, CC_MCC_Tematica__r.CC_Codigo_Externo__c,CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.CC_Codigo_Externo__c,CC_Trasladado_Tercer_Nivel__c ,CC_Area_Negocio__c,OwnerId,CC_Owner_Anterior__c,ClosedDate';
        if(filtro == null){
            query = 'SELECT ' + fields +' FROM Case WHERE CreatedDate >= :fechaCreacion AND RecordType.DeveloperName LIKE \'CC_%\' AND Status = \'Cerrado\' AND CC_Facturado__c  = FALSE' ;
        }else{
            query = 'SELECT ' + fields +' FROM Case WHERE ' + filtro + ' AND CreatedDate >= :fechaCreacion AND RecordType.DeveloperName LIKE \'CC_%\' AND Status = \'Cerrado\' AND CC_Facturado__c  = FALSE';
        }
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        Set<Id> catalogosIds = new Set<Id>();
        Set<String> canalesEntrada = new Set<String>();
        Set<String> canalesProcedencia = new Set<String>();
        Set<String> canalesOperativos = new Set<String>();
        Set<String> tematicas = new Set<String>();
        Set<String> productos = new Set<String>();
        Set<Id> propietarios = new Set<Id>();
        Set<String> areas = new Set<String>();
        Datetime fechaIni;
        Datetime fechaFin;
        
        for(Case caso: scope){
            canalesEntrada.add(caso.Origin);
            canalesProcedencia.add(caso.CC_Canal_Procedencia__c);
            canalesOperativos.add(caso.CC_Canal_Operativo__c);
            tematicas.add(caso.CC_MCC_Tematica__c);
            productos.add(caso.CC_MCC_ProdServ__c);
            if(caso.CC_Trasladado_Tercer_Nivel__c ){
                propietarios.add(caso.CC_Owner_Anterior__c);
            }else{
                propietarios.add(caso.OwnerId);
            }            
            if(fechaIni == null || caso.ClosedDate < fechaIni){
                fechaIni = caso.ClosedDate;
            }
            if(fechaFin == null || caso.ClosedDate > fechaFin){
                fechaFin = caso.ClosedDate;
            }
        }

        //Busca Propietarios
        Map<Id,User> propietariosMap = new Map<Id,User>([SELECT Id,CompanyName FROM User WHERE Id IN :propietarios]);

        //Buscar Empresas
        Set<String> companias = new Set<String>();
        for(User u:propietariosMap.values()){
            companias.add(u.CompanyName);
        }

        //Busca catálogos
        Map<Id,CBK_CatalogoFacturacion__c> catalogoFacturacionMap = new Map<Id,CBK_CatalogoFacturacion__c>([SELECT Id,CC_Canal_de_Procedencia__c, CC_Canal_Operativo__c,CC_Tematica__c, CC_Tematica__r.CC_Codigo_Externo__c,CC_Producto__c, CC_Producto__r.CC_Codigo_Externo__c,CC_Fecha_Inicio_Vigencia__c,CC_Fecha_Fin_Vigencia__c,CC_Area_Negocio__c FROM CBK_CatalogoFacturacion__c 
            WHERE CC_Canal_de_Procedencia__c IN :canalesProcedencia
                AND CC_Canal_Operativo__c IN :canalesOperativos
                AND CC_Tematica__c IN :tematicas
                AND CC_Producto__c IN :productos
                AND CC_Activo__c = true]);

        String clave;
        
        Map<String,CBK_CatalogoFacturacion__c> catalogos = new Map<String,CBK_CatalogoFacturacion__c>();
        for(CBK_CatalogoFacturacion__c cf : catalogoFacturacionMap.values()){
            clave = cf.CC_Canal_de_Procedencia__c + '-' + cf.CC_Canal_Operativo__c + '-' + cf.CC_Tematica__c + '-' + cf.CC_Producto__c;
            areas.add(cf.CC_Area_Negocio__c);
            catalogos.put(clave,cf);
        }

        //Busca Precios
        Map<Id,CBK_Precio_Facturacion__c> precioFacturacionMap = new Map<Id,CBK_Precio_Facturacion__c>([SELECT Id,CC_Precio_Contacto__c,
                                                                                                CC_Fecha_Inicio_Vigencia__c,CC_Fecha_Fin_Vigencia__c,CC_Nombre_Empresa__c, CC_Canal_Entrada__c,CC_Area_Negocio__c
                                                                                                FROM CBK_Precio_Facturacion__c 
                                                                                                WHERE CC_Canal_Entrada__c IN :canalesEntrada 
                                                                                                    AND CC_Nombre_Empresa__c IN :companias 
                                                                                                    AND CC_Activo__c = true]);
        
        
        Map<String,CBK_Precio_Facturacion__c> precios = new Map<String,CBK_Precio_Facturacion__c>();
        for(CBK_Precio_Facturacion__c pf : precioFacturacionMap.values()){
            clave = pf.CC_Canal_Entrada__c + '-' + pf.CC_Area_Negocio__c + '-' + pf.CC_Nombre_Empresa__c;
            precios.put(clave,pf);
        }

        //Busca Margenes
        Map<Id,CBK_Margen_Facturacion__c> margenFacturacionMap = new Map<Id,CBK_Margen_Facturacion__c>([SELECT Id,CC_Area_de_Negocio__c,CC_Fecha_Inicio__c,CC_Fecha_Fin__c FROM CBK_Margen_Facturacion__c 
                                                                            WHERE CC_Area_de_Negocio__c IN :areas
                                                                                AND Activo__c = true]);

        
        Map<String,CBK_Margen_Facturacion__c> margenes = new Map<String,CBK_Margen_Facturacion__c>();
        for(CBK_Margen_Facturacion__c mf : margenFacturacionMap.values()){
            clave = mf.CC_Area_de_Negocio__c;
            margenes.put(clave,mf);
        }

        //Calcular facturacion        
        Map<Id,List<CBK_Precio_Facturacion__c>> casoPreciosMap = new Map<Id,List<CBK_Precio_Facturacion__c>>();
        List<Case> casosActualizarList = new List<Case>();
        List<Case> casosErroneos = new List<Case>();
        Boolean catalogoEncontrado;
        Boolean precioEncontrado;
        Boolean margenEncontrado;
        String propietario;
        for(Case caso:scope){
            catalogoEncontrado = false;
            precioEncontrado = false;
            margenEncontrado = false;
            clave = caso.CC_Canal_Procedencia__c + '-' + caso.CC_Canal_Operativo__c + '-' + caso.CC_MCC_Tematica__c + '-' + caso.CC_MCC_ProdServ__c;
            
            if(caso.CC_Trasladado_Tercer_Nivel__c ){
                propietario = caso.CC_Owner_Anterior__c;
            }else{
                propietario = caso.OwnerId;
            }

            if(catalogos.containsKey(clave)){
                catalogoEncontrado = true;
                caso.CC_Catalogo_Facturacion__c = catalogos.get(clave).Id;
                caso.CC_Area_Negocio__c = catalogos.get(clave).CC_Area_Negocio__c;
                
                String compania;
                if(propietariosMap.containsKey(propietario)){
                    compania = propietariosMap.get(propietario).CompanyName;
                }
                clave = caso.Origin + '-' + caso.CC_Area_Negocio__c + '-' + compania;

                if(precios.containsKey(clave)){
                    precioEncontrado = true;
                    caso.CC_Precio_Facturacion__c = precios.get(clave).Id;
                    caso.CC_Precio_Facturar__c = precios.get(clave).CC_Precio_Contacto__c;
                    caso.CC_Fecha_Facturacion__c = caso.ClosedDate.Date();
                    caso.CC_Facturado__c = true;
                }
				
                if(margenes.containsKey(caso.CC_Area_Negocio__c)){
                    margenEncontrado = true;
                    caso.CC_Margen_Facturacion__c = margenes.get(caso.CC_Area_Negocio__c).Id;
                }

                casosActualizarList.add(caso);
            }

        }

        if(!casosActualizarList.isEmpty())
        {
            Database.update(casosActualizarList,false);
        }
    
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Regularizacion finalizada');
    }          
}