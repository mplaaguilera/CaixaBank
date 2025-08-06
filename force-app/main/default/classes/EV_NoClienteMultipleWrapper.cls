/**********************************************************************************************************************
 Name:	  EV_NoClienteMultipleWrapper
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Wrapper para WS inscripcion multiple de Talks
----------------------------------------------------------------------------------------------------------------------
Historial
----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		    US297853    	    Daniel Rodriguez	29/03/2023			Init version

***********************************************************************************************************************/
public class EV_NoClienteMultipleWrapper {

    public String nombre;
    public String nombreEmpresa;
    public String nifEmpresa;
    public String cargo;
    public String apellidos;
    public String documento;
    public String phone;
    public String idioma;
    public Boolean consentimientoTerceros;
    public Boolean marketing;
    public Boolean consentimientoGeneral;
    public String email;
    public String formatoDeAsistencia;
    public String provincia;
    public List<Companion> companion;

    public class Companion{
        public String nombre;
        public String apellidos;
        public String documento;
        public String idioma;

        public Companion(){
            this.nombre = nombre;
            this.apellidos = apellidos;
            this.documento = documento;
            this.idioma = idioma;
        }
    }

    public EV_NoClienteMultipleWrapper() {
        this.nombre = nombre;
        this.apellidos = apellidos;
        this.documento = documento;
        this.nombreEmpresa = nombreEmpresa;
        this.nifEmpresa = nifEmpresa;
        this.cargo = cargo;
        this.phone = phone;
        this.idioma = idioma;
        this.consentimientoTerceros = consentimientoTerceros;
        this.marketing = marketing;
        this.consentimientoGeneral = consentimientoGeneral;
        this.email = email;
        this.formatoDeAsistencia = formatoDeAsistencia;
        this.provincia = provincia;
        this.companion = companion;
    }

    public class RequestInscripcionBody{
        public String idEvento;
        public String idInvitacion;
        public EV_NoClienteMultipleWrapper datosFormulario;
    }

    public class CampaignMemberResponse{
        //public String Id;
        public String description;
        public String idInvitacion;
        public List<String> idInvitacionCompanion;
    }
}