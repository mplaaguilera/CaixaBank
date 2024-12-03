global class TMS_WS_Udp_Case_DTO {
    public class RequestDTO{
        public string estado {get; set;}
		public string numExp { get; set; }
		public string numperHeredero {get; set;}
        public string numperDifunto {get; set;}
        public string gestoria {get; set;}
        public string letrado {get; set;}
        public string phoneHeredero {get; set;}
        public string phoneInternacionalHeredero {get; set;}
        public string emailHeredero {get; set;}      
    }

    global class ResponseDTO{
        public string estado {get; set;}
        public string caseId {get; set;}
        public string mensajeError {get; set;}   
    }
}