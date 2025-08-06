global class EV_NoClienteWrapperHibrido {
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

    global EV_NoClienteWrapperHibrido() {
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
    }
    
    global class LstEventFormat{
        public String idEvento; 
        public String formatoDeAsistencia; 
    }
    
    global class RequestInscripcionBodyMultipleHibrido{
        public EV_NoClienteWrapperHibrido datosFormulario;
        public List<LstEventFormat> lstIdEvento;
    }

    global class CampaignMemberResponseMultiHibrido{
        public String externalId; 
        public String statusCode; 
        public String description;
    }
    
    global class ExternalMultiple {
        public List<CampaignMemberResponseMultiHibrido> datosExternal;
        public ExternalMultiple(List<CampaignMemberResponseMultiHibrido> datosExternal){
            this.datosExternal = datosExternal;
        } 
    }
}