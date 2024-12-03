global with sharing class OB_WS_AltaLlamada_Output {    
    global List<Respuesta> respuestas {get;set;}

    global OB_WS_AltaLlamada_Output() {respuestas = new List<Respuesta>();}
    global void add(Respuesta respuesta) {respuestas.add(respuesta);}

    global class Respuesta {
        global String resultado {get;set;}
        global String codigoError {get;set;}
        global String detalleError {get;set;}
        global String llamadaId {get;set;}
    }

}