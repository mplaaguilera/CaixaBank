/**
*   @description SEG_sendToCognitive
*/
public class SEG_sendToCognitive {
    public String subject; //RV: Solicitud información auditoría
    public String body; //Durante estos días un grupo auditor …
    public String date_time; //2017-12-23 16:30:21 //NOTA la variable que espera cognitive es date-time. Se deberá haver replace antes de enviar
    public String zone; //BARCELONA
    public String organisation; //Banca Corporativa
    public String sr; //2-912076545
    public String origin; //BCorp
    public String total_attach; //2 //nota: la variable que espera cognitive es total_attach. Se deberá haver replace antes de enviar
    public cls_attachs[] attachs;
    public class cls_attachs {
        public String name; //exampleDoc.pdf
        public String binary; //ZWplbXBsbyBkZSBmaWNoZXJv…
        public String extension; //pdf
        public Integer size; //35
    }
}