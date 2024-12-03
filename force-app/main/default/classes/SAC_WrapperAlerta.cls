/*****************************************************************
 * Name: SAC_WrapperAlerta
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase wrapper para gestionar las alertas que han de generarse.
 * Clase test: SAC_Alertas_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US418231         Carlos Solis   26/07/2022   Creación
*****************************************************************/
public with sharing class SAC_WrapperAlerta {
    //Campos obligatorios
    public String idReclamacion;
    public String tipoAlerta;
    public String mensaje;
    public String idUsuarioDestinatario;
    //Campos opcionales
    public String idPretensionConsulta; //Se usa tambien para la consulta
    public String idAccion;
    public String idInteraccion;
    public String idGrupoColaborador;
    public List<String> listaEmailsGrupo = new List<String>();
    public String enlaceParaEmail{get; set;}
    public String idAlerta{get; set;} //Se informa en el momento en el que se insertan los registros de SAC_Alerta__c, para poder dar la id de la alerta a los emailMessage
    public String proyecto{get; set;} //Añadido 30/08/24. Se usa para indicar si la alerta debe ser de SAC o de SPV. Si se deja en blanco, pasará a ser de SAC. Introducir valores 'SAC' o 'SPV'

    public SAC_WrapperAlerta(String idReclamacionC, String tipoAlertaC, String mensajeC, String idUsuarioDestinatarioC, String idPretensionConsultaC, String idAccionC, String idInteraccionC) {
        //Campos obligatorios
        idReclamacion = idReclamacionC;
        tipoAlerta = tipoAlertaC;
        mensaje = mensajeC;
        idUsuarioDestinatario = idUsuarioDestinatarioC;
        //Campos opcionales
        idPretensionConsulta = idPretensionConsultaC;
        idAccion = idAccionC;
        idInteraccion = idInteraccionC;
    }

    
}