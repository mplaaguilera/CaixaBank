public with sharing class DEMO_SecureAuthentication_VerifyOtp_Apex {

    @InvocableMethod(label='Secure authentication process - Verify OTP')
    public static List<Boolean> verifyOtp(List<String> otp) {
        return new List<Boolean>{otp[0] == '123456'};
    }
}