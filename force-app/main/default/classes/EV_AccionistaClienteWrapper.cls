global class EV_AccionistaClienteWrapper {

    public String Nombre;
    public String NombreEmpresa;
    public String NIFEmpresa;
    public String Cargo;
    public String Apellidos;
    public String Documento;
    public String Phone;
    public String Idioma;
    public Boolean ConsentimientoTerceros;
    public Boolean Marketing;
    public Boolean ConsentimientoGeneral;
    public String Email;
    public String FormatoDeAsistencia;
    public String Provincia;
    public Companion companion;

    public class Companion{
        public String Nombre;
        public String Apellidos;
        public String Documento;
        public String idioma;

        public Companion(){
            this.Nombre = Nombre;
            this.Apellidos = Apellidos;
            this.Documento = Documento;
            this.idioma = idioma;
        }
    }

    global EV_AccionistaClienteWrapper() {
        this.Nombre = Nombre;
        this.Apellidos = Apellidos;
        this.Documento = Documento;
        this.NombreEmpresa = NombreEmpresa;
        this.NIFEmpresa = NIFEmpresa;
        this.Cargo = Cargo;
        this.Phone = Phone;
        this.Idioma = Idioma;
        this.ConsentimientoTerceros = ConsentimientoTerceros;
        this.Marketing = Marketing;
        this.ConsentimientoGeneral = ConsentimientoGeneral;
        this.Email = Email;
        this.FormatoDeAsistencia = FormatoDeAsistencia;
        this.Provincia = Provincia;
        this.companion = companion;
    }

    global class RequestInscripcionBody{
        public String idEvento;
        public String idInvitacion;
        public EV_AccionistaClienteWrapper datosFormulario;
    }

    global class CampaignMemberResponse{
        //public String Id;
        public String Description;
        public String idInvitacion;
        public String idInvitacionCompanion;
    }
}