public with sharing class CC_WS_Contextualizador {
  @AuraEnabled
  public static Map <String, Object> ccWSContextualizador(String idCuenta, String idObjeto, String tipoObjeto) {
    Map <String, Object> mapRet = new Map <String, Object>();
      if(tipoObjeto == 'Case'){
        mapRet = obtenerDenegacionCase(idCuenta, idObjeto);
      }else if(tipoObjeto == 'Llamada'){
        mapRet = obtenerDenegacionLlamada(idCuenta, idObjeto);
      }
      return mapRet;
  }

    public static Map<String, Object> obtenerDenegacionCase(String idCuenta, String idObjeto){
        //List<Account> numPerson = [SELECT CC_NumPerso__c FROM Account WHERE Id = :idCuenta];
        Map <String, Object> mapReturn = new Map < String, Object > ();
        List <Case> caso = [SELECT CC_Info_Denegacion__c FROM Case WHERE Id =: idObjeto];
        String numPersonHexa = '';
        if(!String.isEmpty(idCuenta)){
            numPersonHexa = CC_MetodosUtiles.decimalToHex(decimal.valueOf(idCuenta));
        } else{
            mapReturn.put('Error al obtener numperson', 'Error al obtener numperson');
            return mapReturn;
        }
        if (!String.isEmpty(caso[0].CC_Info_Denegacion__c)) {
            Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(caso[0].CC_Info_Denegacion__c);
            mapReturn.put('MotivoDenegacion', m.get('MotivoDenegacion'));
        } else {
            mapReturn = llamadaServicio(numPersonHexa);
            if (!caso.isEmpty() && mapReturn.containsKey('MotivoDenegacion')) {
                caso[0].CC_Info_Denegacion__c = JSON.serialize(mapReturn);
            }
            if (!String.isEmpty(caso[0].CC_Info_Denegacion__c)) {
                update caso;
            }
        }
        return mapReturn;
    }

  public static Map<String, Object> obtenerDenegacionLlamada(String idCuenta, String idObjeto){
    List<Account> numPerson = [SELECT CC_NumPerso__c FROM Account WHERE Id = :idCuenta];
    String numPersonHexa;
    List <Case> caso = new List <Case>();
    List <CC_Llamada__c> llamada = [SELECT CC_Info_Denegacion__c FROM CC_Llamada__c where id = :idObjeto];
    Map <String, Object> mapReturn = new Map <String, Object> ();
    List<Task> idCase = [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :idObjeto ORDER BY CreatedDate ASC];
    
    if(!idCase.isEmpty()){
      caso = [SELECT CC_Info_Denegacion__c FROM Case WHERE Id =: idCase[0].WhatId];
    }
      if(!String.isEmpty(idCuenta) && !numperson.isEmpty() && !String.isEmpty(numPerson[0].CC_NumPerso__c)){
        numPersonHexa = CC_MetodosUtiles.decimalToHex(decimal.valueOf(numPerson[0].CC_NumPerso__c));
      } else{
        mapReturn.put('Error al obtener numperson', 'Error al obtener numperson');
        return mapReturn;
      }
      if (!String.isEmpty(llamada[0].CC_Info_Denegacion__c)) {
        Map <String, Object> m = (Map <String, Object>) JSON.deserializeUntyped(llamada[0].CC_Info_Denegacion__c);
        mapReturn.put('MotivoDenegacion', m.get('MotivoDenegacion'));
      } else {
        mapReturn = llamadaServicio(numPersonHexa);
        if (!caso.isEmpty() && mapReturn.containsKey('MotivoDenegacion')){
          caso[0].CC_Info_Denegacion__c = JSON.serialize(mapReturn);
        }
          
        if(!llamada.isEmpty() && mapReturn.containsKey('MotivoDenegacion')) {
            llamada[0].CC_Info_Denegacion__c = JSON.serialize(mapReturn);
          }
          if (!caso.isEmpty() && !String.isEmpty(caso[0].CC_Info_Denegacion__c)){
            update caso;
          }
          
          if(!llamada.isEmpty() && !String.isEmpty(llamada[0].CC_Info_Denegacion__c)) {
            update llamada;
          }
      }
    return mapReturn;
  }

  public static Map<String, Object> llamadaServicio(String numPersonHexa){
    Map < String, Object > mapReturn = new Map < String, Object > ();
    try {
      Map < String, String > mHeaders = new Map < String, String > ();
      mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
      //Descomentar esta linea SOLO PARA DEV  para que no falle el llamado. 
      //mHeaders.put('HTTP-HEADER-ACTOR', 'CBCCSF');
      mHeaders.put('x-absis-customerInternalId', numPersonHexa);
      HttpRequest req = CBK_HttpServiceIntegration.getRequest(null, 'CC_Contextualizador', 'GET', mHeaders);
  
      HTTPResponse response = CBK_HttpServiceIntegration.callHttpService(req, null, 'CC_Contextualizador');
      // Parse the JSON response
      if (response.getStatusCode() != 200) {
       mapReturn.put('Error', 'La llamada al servicio fallo');
      } else {
         WrapperClass jsonTransf = (WrapperClass) System.JSON.deserialize(response.getBody(), WrapperClass.class);
        //Le damos formato a la fecha ya que viene en milisegundos
        //Llenamos el mapa que luego va a usar el componente cc_Contextualizador
        mapReturn.put('MotivoDenegacion', jsonTransf.businessModel.serviceDomains.paymentExecution.context.declinedPayments.current.declineCodeDescription);
      }
    } catch (Exception e) {
   mapReturn.put('Error', 'Fallo el código');
    }

    return mapReturn;
  }
  
  public class Current {
    String movementId;
    Long movementDate;
    String commerceDescription;
    Double movementAmount;
    String declineCodeDescription;
    String declineCategoryDescription;
  }
  public class DeclinedPayments {
    Current current;
  }
  public class Context {
    DeclinedPayments declinedPayments;
  }
  public class PaymentExecution {
    Context context;
  }
  public class ServiceDomains {
    PaymentExecution paymentExecution;
  }
  public class BusinessModel {
    ServiceDomains serviceDomains;
  }
  public class WrapperClass {
    String id;
    BusinessModel businessModel;

  }
}