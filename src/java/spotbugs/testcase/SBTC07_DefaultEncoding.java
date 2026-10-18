package spotbugs.testcase;

import java.nio.charset.StandardCharsets;

/**
 * SB-TC07 (Internationalization - Loi bang ma tieng Viet) - xu ly ten nhan vien co dau.
 * Ky vong SpotBugs: DM_DEFAULT_ENCODING tai bugEncodeName (getBytes()) va bugDecodeName (new String(byte[])).
 */
public class SBTC07_DefaultEncoding {

    // BUG: dung bang ma mac dinh cua may (Windows thuong la Cp1252) -> ten co dau bi vo
    public byte[] bugEncodeName(String fullName) {
        return fullName.getBytes();
    }

    public String bugDecodeName(byte[] data) {
        return new String(data);
    }

    // FIX: luon chi dinh UTF-8
    public byte[] fixedEncodeName(String fullName) {
        return fullName.getBytes(StandardCharsets.UTF_8);
    }

    public String fixedDecodeName(byte[] data) {
        return new String(data, StandardCharsets.UTF_8);
    }
}
