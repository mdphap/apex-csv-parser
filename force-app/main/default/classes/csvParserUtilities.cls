/**
 * Helper utilities for identifying CSV token types based on parser configuration.
 *
 * <p>Provides convenience checks for separator, quote, end-of-line, and value
 * characters while delegating token definitions to `csvParserConfigs`.</p>
 */
public with sharing class csvParserUtilities {

    /**
     * Custom exception type for CSV parser utility failures.
     */
    public class csvParserUtilitiesException extends Exception {}

    /**
     * Determines whether the provided character matches the configured CSV separator.
     *
     * @param char2 Character to evaluate.
     * @return True when `char2` equals the configured separator; otherwise false.
     */
    public static Boolean isSeparator(String char2) {
        return char2.equals(csvParserConfigs.SEP);
    }

    /**
     * Determines whether the provided character matches the configured CSV quote character.
     *
     * @param char2 Character to evaluate.
     * @return True when `char2` equals the configured quote character; otherwise false.
     */
    public static Boolean isQuote(String char2) {
        return char2.equals(csvParserConfigs.QUOTE);
    }

    /**
     * Determines whether a single character is the configured end-of-line token.
     *
     * <p>This is primarily applicable when the configured EOL style is single-character
     * (for example, LF).</p>
     *
     * @param char2 Character to evaluate.
     * @return True when `char2` equals the configured EOL token; otherwise false.
     */
    // public static Boolean isEOL(String char2) {
    //     return char2.equals(csvParserConfigs.EOL_CHAR);
    // }

    /**
     * Determines whether two consecutive characters form the configured EOL token.
     *
     * <p>Used for multi-character EOL sequences such as CRLF.</p>
     *
     * @param char2 First character in sequence.
     * @param nextChar Next character in sequence.
     * @return True when both characters form the configured EOL token; otherwise false.
     */
    public static Boolean isEOL(String char2, String nextChar) {

        // if (String.isBlank(char2) || String.isBlank(nextChar)) {return false;}

        if (csvParserConfigs.EOL_STYLE == csvParserConfigs.EOL.LF) {
            return char2.equals(csvParserConfigs.EOL_CHAR);
        } else {
            String crlf = char2 + nextChar;
            return crlf.equals(csvParserConfigs.EOL_CHAR);
        }
    }

    /**
     * Determines whether the provided character should be treated as CSV value content.
     *
     * @param char2 Character to evaluate.
     * @return True when `char2` is not a separator, quote, or EOL token; otherwise false.
     */
    // public static Boolean isValue(String char2) {
    //     return (!isSeparator(char2) && !isQuote(char2) && !isEOL(char2) && !isEOL(char2, null));
    // }
}