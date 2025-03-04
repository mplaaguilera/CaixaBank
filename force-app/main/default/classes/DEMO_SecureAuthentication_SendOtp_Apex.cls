public with sharing class DEMO_SecureAuthentication_SendOtp_Apex {

    @InvocableMethod(label='Secure authentication process - Send OTP')
    public static List<Boolean> sendOtp(List<String> customerId) {
        return new List<Boolean>{true};
    }

}