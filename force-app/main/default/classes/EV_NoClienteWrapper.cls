global class EV_NoClienteWrapper {

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

    global class ExternalMultiple {
        //public String[] externalIds;
        public List<CampaignMemberResponseMulti> datosExternal;
        public ExternalMultiple(List<CampaignMemberResponseMulti> datosExternal){
            this.datosExternal = datosExternal;
        } 
    }
    

    global EV_NoClienteWrapper() {
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
    }

    global class RequestInscripcionBody{
        public String idEvento;
        public String idInvitacion;
        public String numper;
        public EV_NoClienteWrapper datosFormulario;
    }

    global class RequestInscripcionBodyMultiple{
        public List<String> lstIdEvento;
        public String idInvitacion; 
        //public String numper;
        public EV_NoClienteWrapper datosFormulario;
    }

    global class CampaignMemberResponseMulti{
        public String externalId; 
        public String statusCode; 
        public String description;
    }

    global class CampaignMemberResponse{
        //public String Id;
        public String description;
        public String idInvitacion;
        
    }
}