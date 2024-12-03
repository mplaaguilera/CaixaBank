/**********************************************************************************************************************
 Name:	  CSBD_WRAPPER_ConsultaOTP
 Copyright © 2022 CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Wrapper que contiene la estructura de datos de entrada del servicio para la obtención del sessionId de chat
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0			App CSBD			Esperanza Conde		04/03/2022			Init version
***********************************************************************************************************************/
public with sharing class CSBD_WRAPPER_ConsultaOTP {

    public consultaDetails consultaWrapper {Get;Set;}
    
    public class consultaDetails {
        public String      NUMPERSO                { Get;Set; }
        public String      IDIOMA                  { Get;Set; }
        public String      CANAL                   { Get;Set; }
        public String      EMAILCLIENTE            { Get;Set; }
        public String      TELEFONOCLIENTE         { Get;Set; }
        public String      NOMBRESOLICITANTE       { Get;Set; }
        public String      APELLIDO1               { Get;Set; }
        public String      APELLIDO2               { Get;Set; }
        public String      NIFSOLICITANTE          { Get;Set; }
        public String      NOMBREPRODUCTO          { Get;Set; }
        public String      DETALLEPRODUCTO         { Get;Set; }
        public String      HORARIOCONTACTO         { Get;Set; }
        public String      ORIGEN                  { Get;Set; }
            
    }
}