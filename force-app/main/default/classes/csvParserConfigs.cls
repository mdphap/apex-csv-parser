/**
 * Central configuration holder for CSV parsing behavior used by OnePT utilities.
 *
 * <p>This class stores parser options such as separator, quote character,
 * end-of-line style, and verbose flag in static state for shared runtime use.</p>
 */
public with sharing class csvParserConfigs {

    public static String SEP {get; private set;}
    public static String QUOTE {get; private set;}
    public static EOL EOL_STYLE {get; private set;}
    public static String EOL_CHAR {get; private set;}
    public static Boolean VERBOSE {get; private set;}

    /**
     * Supported end-of-line styles for generated or parsed CSV content.
     */
    public enum EOL {LF, CRLF}

    static {
        SEP = ';';
        QUOTE = '"';
        EOL_STYLE = EOL.CRLF;
        getEolChar();
        VERBOSE = false;
    }

    /**
     * Updates the configured CSV field separator character.
     *
     * @param SEP Field separator to apply (for example, ';' or ',').
     */
    public static void setSeparator(String SEP) {
        csvParserConfigs.SEP = SEP;
    }

    /**
     * Updates the configured CSV quote character.
     *
     * @param QUOTE Quote character to apply when handling quoted values.
     */
    public static void setQuote(String QUOTE) {
        csvParserConfigs.QUOTE = QUOTE;
    }

    /**
     * Updates the configured end-of-line style and refreshes the EOL character value.
     *
     * @param EOL_STYLE End-of-line style to use for CSV content.
     */
    public static void setEolStyle(EOL EOL_STYLE) {
        csvParserConfigs.EOL_STYLE = EOL_STYLE;
        getEolChar();
    }

    /**
     * Enables or disables verbose parser behavior.
     *
     * @param VERBOSE True to enable verbose behavior; otherwise false.
     */
    public static void setVerbose(Boolean VERBOSE) {
        csvParserConfigs.VERBOSE = VERBOSE;
    }

    /**
     * Resolves and stores the newline character sequence for the selected EOL style.
     */
    private static void getEolChar() {
        switch on EOL_STYLE {
            when LF {
                EOL_CHAR = '\n';
            }
            when CRLF {
                EOL_CHAR = '\r\n';
            }
            when else {
                EOL_CHAR = '\r\n';
            }
        }
    }
}