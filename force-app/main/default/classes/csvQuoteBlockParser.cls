public with sharing class csvQuoteBlockParser {
    
    private class csvQuoteBlockParserException extends Exception {}

    private static csvQuoteBlockParser singleton;
    public static csvQuoteBlockParser getQuoteBlockParser(csvParser mainParser) {

        if (singleton == null) {
            singleton = new csvQuoteBlockParser(mainParser);
        }

        return singleton;
    }

    private csvParser mainParser;
    private csvParserStates.STATES prevState;
    private csvParserStates.STATES state;
    private csvValueStreamer valueStreamer;
    private Boolean escapedQuote;

    private csvParserLogger logger;

    private csvQuoteBlockParser(csvParser mainParser)
    {
        this.mainParser = mainParser;
        this.state = csvParserStates.STATES.START;
        this.logger = new csvParserLogger('csvQuoteBlockParser', 1);
        this.valueStreamer = csvValueStreamer.getValueStreamer(); //  borrow value streamer from main parser
        this.escapedQuote = false;
    }

    public enum END_CATEGORY {ESCAPED_QUOTE, QUOTE_BLOCK_END}

    private END_CATEGORY endCategory;

    public void eventHandler(String char2) {
        // this.getStateTransition(char2);
        this.getState(char2);

        Map<String, Object> data = new Map<String, Object> {
            'char2' => char2,
            'prevState' => this.prevState,
            'state' => this.state
        };

        this.logger.log('Process', data);

        this.act(char2);
    }

    public Boolean isClosed() {

        return this.state == csvParserStates.STATES.END2;
    }

    public END_CATEGORY getEndCategory() {
        return this.endCategory;
    }

    public void flush() {
        this.prevState = null;
        this.state = csvParserStates.STATES.START;
        // this.transition = null;
        this.endCategory = null;
        this.escapedQuote = false;
    }

    private csvParserStates.STATES sneakPeekNextState(Integer numOfChar) {

        String nextChar = this.mainParser.sneakPeekNextChar(numOfChar);

        String nextNextChar = this.mainParser.sneakPeekNextChar(++numOfChar);

        if (nextChar == null) {
            return csvParserStates.STATES.EOL; // this is EOF but we can treat it as EOL
        } else if (csvParserUtilities.isSeparator(nextChar)) {
            return csvParserStates.STATES.SEPARATOR;
        } else if (csvParserUtilities.isQuote(nextChar)) {
            return csvParserStates.STATES.QUOTE;
        } else if (csvParserUtilities.isEOL(nextChar, nextNextChar)) {
            return csvParserStates.STATES.EOL;
        } else {
            return csvParserStates.STATES.VALUE;
        }
    }

    private void endMachineDueEscapedQuote() {
        this.state = csvParserStates.STATES.END2;
        this.endCategory = END_CATEGORY.ESCAPED_QUOTE;
    }

    private void endMachineDueQuoteBlockEnd() {
        this.state = csvParserStates.STATES.END2;
        this.endCategory = END_CATEGORY.QUOTE_BLOCK_END;
    }

    private void getState(String char2) {

        this.prevState = this.state;

        if (csvParserUtilities.isSeparator(char2)) {
            this.state = csvParserStates.STATES.SEPARATOR;
        } else if (csvParserUtilities.isQuote(char2)) {
            this.state = csvParserStates.STATES.QUOTE;
        } else {
            this.state = csvParserStates.STATES.VALUE;
        }
    }

    private void act(String char2) {

        switch on this.state {
            when VALUE {
                this.valueStreamer.stream(char2);
            }
            when QUOTE {
                this.handleQuoteInsideQuoteBlock(char2);
            }
            when SEPARATOR {
                this.valueStreamer.stream(char2);
            }
            when else {
                this.logger.log('Strange state: ' + this.state);
            }
        }
    }

    private void handleQuoteInsideQuoteBlock(String char2) {

        if (this.prevState == csvParserStates.STATES.START) {
            this.valueStreamer.stream(char2);
            this.endMachineDueEscapedQuote();
            return;
        }

        if (this.escapedQuote) { // realize escaped quote delayed values streaming
            this.valueStreamer.stream(char2);
            this.escapedQuote = false;
            return;
        }

        csvParserStates.STATES nextState = this.sneakPeekNextState(1);
        
        switch on nextState {
            when SEPARATOR {
                this.endMachineDueQuoteBlockEnd();
            }
            when QUOTE { // escaped quote
                this.escapedQuote = true; // set flag for escaped quote delayed values streaming
            }
            when EOL {
                this.endMachineDueQuoteBlockEnd();
            }
            when else {
                this.throwException('Inside quote block, a quote cannot be followed by: ' + nextState);
            }
        }
    }

    private void throwException(String message) {
        csvQuoteBlockParserException e = new csvQuoteBlockParserException();
        e.setMessage(message);
        throw e;
    }
}