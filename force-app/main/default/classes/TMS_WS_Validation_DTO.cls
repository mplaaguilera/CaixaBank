global class TMS_WS_Validation_DTO {
    public class RequestDTO{
		public string numExp { get; set; }  
        public string numperSolicitanteCita {get; set;}
    }

    global class ResponseDTO{
        public string estado {get; set;}
        public string mensajeError {get; set;}   
    }
}