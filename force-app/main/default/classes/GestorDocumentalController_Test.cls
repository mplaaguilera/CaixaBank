@IsTest
public class GestorDocumentalController_Test {
  	@isTest static void testGestor() {       	
        
        Case caso = generarCaso();            
        String recordId = caso.Id;
        String docId = '';
        String idioma = 'es';
        String sexo = '';
        String cambioficina = '';
        String faltaentrega = '';
        String espera = '';
        String respuestacliente = '';
        String contestarrespuestacliente = '';
        String bloqueoretencionsaldo = '';
        Boolean solicitudcancelacionseguro = false;
        Boolean solicitudtestamentaria = false;
        Boolean cuadroamortizacion = false;
        Boolean partedocumentacion = false;
        Boolean documentacionadicional = false;
        Boolean documentacionnolocalizada = false;
        Boolean usuarioNow = false;
        String detalleinformacionenviar = '';        
        String helloletter = '';
        String codigoprestamo = '';
        Date fechafinalcalculo =  Date.newInstance(2020, 2, 17);
        String cuentaminombre = '';
        String solicitud = '';
        String movimientoCuenta = '';
        Boolean contactocliente = false;
        Boolean irrespetuoso = false;
        String informaciondocumentacionadicional = '';
        String fraude = '';
        String solicitudDocumentacion = '';
        Boolean allinone = false;
        String indicargastos = 'contrato';

        Map<String, Boolean> camposBoleanos = new Map<String, Boolean>();
        Map<String, String> camposTexto = new Map<String, String>();
        camposBoleanos.put('documentacionnolocalizadacliente', false);
        camposBoleanos.put('tasacioninmueblehipotecado', false);
        camposBoleanos.put('prestamotitulizado', false);
        camposBoleanos.put('prestamovendidotercero', false);
        camposBoleanos.put('solicitudfacturasgastos', false);
        camposBoleanos.put('contratotarjetacliente', false);
        camposBoleanos.put('extractosliquidacion', false);
        camposBoleanos.put('copiaparcialescritura', false);
        camposBoleanos.put('nolocalizacontratocuenta', false); 
        camposBoleanos.put('quejacobrotarifatelefonica', false); 
        camposBoleanos.put('solicitudinfoprestamo', false); 
        camposBoleanos.put('quejalimpieza', false); 
        camposBoleanos.put('quejapersonasinhogar', false); 
        camposBoleanos.put('solicitudinformacionrequisitos', false); 
        camposBoleanos.put('solicitudinformacionaportar', false); 
        camposBoleanos.put('informacioncondicionesfinanciacion', false); 
        camposBoleanos.put('ofreciosolucionesrefinanciacion', false);  
        camposBoleanos.put('cierrerecintocajero', false); 
        camposBoleanos.put('solicitudcancelacioncontratos', false); 
        camposBoleanos.put('intervencionFuerzasSeguridad', false); 

        camposTexto.put('indicargastos', indicargastos);        

            
        //Caso sin gestor documental
        GestorDocumentalController.generaDocumento(recordId, docId, idioma, sexo, cambioficina, faltaentrega, espera, 
        contactocliente, allinone, irrespetuoso, fraude, movimientoCuenta, usuarioNow, cuentaminombre,
        respuestacliente, contestarrespuestacliente, bloqueoretencionsaldo, solicitudcancelacionseguro, solicitudtestamentaria,
        solicitud, solicitudDocumentacion, informaciondocumentacionadicional, helloletter, codigoprestamo, fechafinalcalculo,
        cuadroamortizacion, partedocumentacion, documentacionadicional, documentacionnolocalizada,
        detalleinformacionenviar, camposBoleanos, camposTexto);      
        
        //Actualizar caso con gestor documental
        caso = [SELECT CC_Gestor_Documental__c FROM CASE WHERE Id = :caso.Id];
        docId = caso.CC_Gestor_Documental__c;
        
       	GestorDocumentalController.generaDocumento(recordId, docId, idioma, sexo, cambioficina, faltaentrega, espera, 
        contactocliente, allinone, irrespetuoso, fraude, movimientoCuenta, usuarioNow, cuentaminombre,
        respuestacliente, contestarrespuestacliente, bloqueoretencionsaldo, solicitudcancelacionseguro, solicitudtestamentaria,
        solicitud, solicitudDocumentacion, informaciondocumentacionadicional, helloletter, codigoprestamo, fechafinalcalculo,
        cuadroamortizacion, partedocumentacion, documentacionadicional, documentacionnolocalizada,
        detalleinformacionenviar, camposBoleanos, camposTexto);       
    }
    
    @isTest static void obtenerPlantillas() {     	       
       	SDOC__SDTemplate__c docSDOCs = generarPlantilla('Plantilla', 'Castellano', 'PDF');
       	GestorDocumentalController.obtenerPlantillas(docSDOCs.Id);        
    }
    
    @isTest static void obtenerCamposPlantillas() {
        SDOC__SDTemplate__c docSDOCsAtencionDeficiente = generarPlantilla('Atención Deficiente en Oficina ES', 'Castellano', 'PDF');

        //Lista de valores 
        CC_Lista_Valores__c lovSDOC = new CC_Lista_Valores__c();
        lovSDOC.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovSDOC.CC_Activa__c = true;
        lovSDOC.Name = 'Plantillas SDocs';
        insert lovSDOC;
        
        CC_Lista_Valores__c valorAtencionDeficiente = new CC_Lista_Valores__c();
        valorAtencionDeficiente.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorAtencionDeficiente.CC_Activa__c = true;
        valorAtencionDeficiente.CC_Lista__c = lovSDOC.Id;
        valorAtencionDeficiente.Name = 'Atención Deficiente en Oficina';
        valorAtencionDeficiente.CC_Valor__c = 'Atención Deficiente en Oficina';
        //valorAtencionDeficiente.CC_Campos_SDocs__c = 'CC_All_In_One__c;CC_Contacto_Cliente__c';
        insert valorAtencionDeficiente;
        
       
        
        List<String> listaPlantillas = new List<String>();
        listaPlantillas.add(docSDOCsAtencionDeficiente.Id);

        GestorDocumentalController.obtenerCamposPlantilla(listaPlantillas);          
    }
    
    private static Case generarCaso(){
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        insert caso;        
        return caso;
    } 
    
     private static SDOC__SDTemplate__c generarPlantilla(String nombre, String idioma, String formato){
        SDOC__SDTemplate__c documento = new SDOC__SDTemplate__c();
        documento.Name = nombre;	
        documento.SDOC__Language__c = idioma;
        documento.SDOC__Template_Format__c = formato;
        documento.SDOC__Active__c = true;
        insert documento;
        return documento;
    } 
   
      
}