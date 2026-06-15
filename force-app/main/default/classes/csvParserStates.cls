/**
 * Defines parser states and allowed state transitions for the CSV parser state machine.
 */
public with sharing class csvParserStates {

    /**
     * High-level parser states while processing CSV input.
     */
    public enum STATES {START, VALUE, QUOTE, SEPARATOR, EOL, END2}

    public csvParserStates(){}

    /**
     * Explicit transition keys between parser states.
     *
     * <p>Each value is formatted as `FROMSTATE_TOSTATE` and can be used to map
     * transition handlers in parser logic.</p>
     */
    // public enum STATE_TRANSITIONS {
    //     START_VALUE, START_QUOTE, START_SEPARATOR, START_EOL, START_END,
    //     VALUE_VALUE, VALUE_QUOTE, VALUE_SEPARATOR, VALUE_EOL, VALUE_END,
    //     QUOTE_VALUE, QUOTE_QUOTE, QUOTE_SEPARATOR, QUOTE_EOL, QUOTE_END,
    //     SEPARATOR_VALUE, SEPARATOR_QUOTE,SEPARATOR_SEPARATOR, SEPARATOR_EOL, SEPARATOR_END
    // }
}