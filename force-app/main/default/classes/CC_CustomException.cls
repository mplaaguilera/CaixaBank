public class CC_CustomException extends Exception {
   
    public static void throwException(String message, Boolean isAuraException) {
        if (String.isEmpty(message)) {
            message = 'Se ha producido un error inesperado.';
        }
        if (isAuraException) {
            throw new AuraHandledException(message);
        } else {
            throw new CC_CustomException(message);
        }
    }

    public static void throwAuraException(String message) {
        throwException(message, true);
    }

    public static void throwCustomException(String message) {
        throwException(message, false);
    }

}