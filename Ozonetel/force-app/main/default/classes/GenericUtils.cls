/**
 * (c) 2024 RedBus
 *
 * Name           : GenericUtils
 * Created Date   : 24 Jun 2024
 * Created By     : Angela Tony
 * Purpose        : Common Utility class for all Generic Use Cases
 * Test Class     : GenericUtilsTest
 *
 **/
public class GenericUtils {
    public static string getsha512hash(string text) {
        Blob inputBlob = Blob.valueOf(text);

        // Generate the SHA-512 hash
        Blob sha512Hash = Crypto.generateDigest('SHA-512', inputBlob);

        // Convert the Blob to a Hex string
        String sha512Hex = EncodingUtil.convertToHex(sha512Hash);

        System.debug('sha512Hex==>'+sha512Hex);
        return sha512Hex;
    }
}