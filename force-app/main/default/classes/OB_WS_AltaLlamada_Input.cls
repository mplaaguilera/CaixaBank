global class OB_WS_AltaLlamada_Input {    
    global List<Solicitud> solicitudes {get;set;}
    
    global OB_WS_AltaLlamada_Input() { solicitudes = new List<Solicitud>(); } 

    @SuppressWarnings('PMD.TooManyFields, PMD.VariableNamingConventions')
    global class Solicitud {
        global String fecha_Ultima_Validacion {get;set;}
        global String producto {get;set;}
        global String agente {get;set;}
        global String ani {get;set;}
        global String asunto {get;set;}
        global String caseConsultado {get;set;}
        global String connIdCognitivo {get;set;}
        global String connIdConsulta {get;set;}
        global String connIdLlamada {get;set;}
        global String contacto {get;set;}
        global String cuenta {get;set;}
        global String datosGenesis {get;set;}
        global String dnis {get;set;}        
        global String extension {get;set;}
        global String fechaFin {get;set;}
        global String fechaInicio {get;set;}
        global String idCognitivo {get;set;}
        global String identificacionCliente {get;set;}
        global String identificadoManualmente {get;set;}
        global String idioma {get;set;}
        global String llamadaPadre {get;set;}
        global String noIdentificado {get;set;}
        global String numPerso {get;set;}
        global String ownerId {get;set;}
        global String servicioGenesis {get;set;}
        global String tipoCierre {get;set;}
        global String tipo {get;set;}
        global String encuestaValor1 {get;set;}
        global String encuestaValor2 {get;set;}
        global String encuestaValor3 {get;set;}

    }
}