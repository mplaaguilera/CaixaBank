public virtual class CBK_ServiceRestManager {

	public static final Integer CORRECT_STATUS_CODE = 200;
	public static final Integer CORRECT_STATUS_CODE_ACCEPTED = 202;
	public static final Integer CORRECT_STATUS_CODE_ACCEPTED_MAX_RANGE = 299;

	public static final Integer EXCEPTION_BAD_REQUEST_STATUS_CODE = 400; 
	public static final Integer EXCEPTION_UNAUTHORIZED = 401; 
	public static final Integer EXCEPTION_PRECONDITION_FAILED = 412; 
	public static final Integer EXCEPTION_STATUS_CODE = 500;
	public static final Integer EXCEPTION_TIMEOUT_CODE = 504;
	public static final Integer EXCEPTION_NOT_FOUND = 404;
	public static final Integer EXCEPTION_SERVICE_UNAVAILABLE = 503;



	public class BadResponseException extends Exception {
		public string message;
		public string status;
		public Integer statusCode;
		public string typeNameEx;

		public BadResponseException(String message, String status, Integer statusCode) {
			this(message);
			this.status = status;
			this.statusCode = statusCode;
			this.typeNameEx = 'BadResponseException';
		}
	}
}