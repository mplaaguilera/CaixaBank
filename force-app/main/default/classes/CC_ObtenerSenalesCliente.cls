public with sharing class CC_ObtenerSenalesCliente {
   
    public class RespuestaSenalesCliente{
        public LoyaltySignal[] loyaltySignals;

        public RespuestaSenalesCliente() {
            this.loyaltySignals = new List<LoyaltySignal>();
        }
    }

    public class LoyaltySignal {
        public String key;	
        public String value;
    }
    
    public static void obtenerSenalesCliente(String numperso, CC_InterfaceSettings__mdt configPartyReferenceMdt) {
        Map<String,String> resultadoSenalesCliente = new Map<String,String>();

        //CC_InterfaceSettings__mdt configPartyReferenceMdt = CC_MetodosUtiles.getInterfazConfigBody('CC_Int_ObtenerSenalesCliente');

        System.debug('numperso '+numperso); 

        Decimal numpersoDecimal = Decimal.valueOf(numperso);

        System.debug('numpersoDecimal '+CC_MetodosUtiles.decimalToHex(numpersoDecimal)); 

        HttpRequest req = new HttpRequest();
        req.setEndpoint(configPartyReferenceMdt.CC_EndPoint__c);
        req.setClientCertificateName(configPartyReferenceMdt.CC_Certificado__c);
        req.setMethod(configPartyReferenceMdt.CC_TipoPeticion__c);
        req.setHeader('x-absis-customerInternalId', CC_MetodosUtiles.decimalToHex(numpersoDecimal));

        try {
            Http http = new Http();
            HTTPResponse respuesta = http.send(req);
            System.debug( 'respuesta' +respuesta );
            System.debug( 'respuesta.getBody()' +respuesta.getBody() );
            
            if(String.isNotBlank(respuesta.getBody()) && respuesta.getStatusCode() == 200){
                RespuestaSenalesCliente senalesClienteList = (RespuestaSenalesCliente) System.JSON.deserialize(respuesta.getBody(), RespuestaSenalesCliente.class);
                
                for(LoyaltySignal senalCliente : senalesClienteList.loyaltySignals) {
                    resultadoSenalesCliente.put(senalCliente.key, senalCliente.value);
                }
            }
            else{
                System.debug('respuesta vacía o <>200');
            }
        } 
        catch (Exception e) {
            System.debug('Excepction error ' + e.getMessage());
            CBK_Log.error(e);
        }        
        //Si hay señales para el numperso actualizamos el cliente
        if(!resultadoSenalesCliente.isEmpty()){
            actualizarSenalesCliente(resultadoSenalesCliente, numperso);
        }
    }

    public static void actualizarSenalesCliente(Map<String,String> resultadoSenalesCliente, String numperso) {
        Boolean esSenior = false;
        Boolean actualizarCliente = false;

        for(String senalCliente: resultadoSenalesCliente.keySet()){
            if(senalCliente == '23'){
                esSenior = true;
            }
        }
        List<Account> clienteSenior = [SELECT CC_Marca_senior__c, LastName FROM Account WHERE CC_NumPerso__c=:numperso];
        if(!clienteSenior.isEmpty() && clienteSenior.size() == 1){           
            if(esSenior){
                if(!clienteSenior[0].CC_Marca_senior__c){
                    clienteSenior[0].CC_Marca_senior__c = true;
                    actualizarCliente = true;
                }
            }
            else{

                if(clienteSenior[0].CC_Marca_senior__c){ //&& menor de 65 años (solo puede dejar de ser senior antes de esta edad)
                    clienteSenior[0].CC_Marca_senior__c = false;
                    actualizarCliente = true;
                }
            }
        }
        if(actualizarCliente){
            Update clienteSenior;
        }
    }
}