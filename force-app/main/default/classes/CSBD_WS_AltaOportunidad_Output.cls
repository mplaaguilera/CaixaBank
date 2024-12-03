global with sharing class CSBD_WS_AltaOportunidad_Output {
    public List<Respuesta> respuestas {get;set;}

    public CSBD_WS_AltaOportunidad_Output() {
        respuestas = new List<Respuesta>();
    }

    public void add(Respuesta respuesta) {
        respuestas.add(respuesta);
    }

    public class Respuesta {
        public String referencia_usuario {get;set;}
        public String resultado {get;set;}
        public String codigoError {get;set;}
        public String detalleError {get;set;}
        public String opportunityId {get;set;}
        public String opportunityNumero {get;set;}
        public String detalleOportunidad {get;set;}
    }
}