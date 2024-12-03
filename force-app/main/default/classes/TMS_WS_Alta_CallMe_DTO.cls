global class TMS_WS_Alta_CallMe_DTO {
    public class RequestDTO{
		public string numExp { get; set; }
		public string horaInicio {get; set;}
        public string horaFin {get; set;}
        public string comentario {get; set;}
        public string tipologia {get; set;}
        public string telefonoContacto {get; set;}   
        public string numperSolicitanteCita {get; set;}
    }

    global class ResponseDTO{
        public string estado {get; set;}
        public string mensajeError {get; set;}   
    }
}