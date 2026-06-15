public with sharing class csvParser {

    private class csvParserException extends Exception {}

    private csvParserStates.STATES prevState;
    private csvParserStates.STATES state;
    // private STATE_TRANSITIONS transition;

    private Boolean inQuoteBlock = false;
    private csvQuoteBlockParser quoteBlockParser;
    private csvValueStreamer valueStreamer;
    private csvParserLogger logger;

    private List<String> chars = new List<String>();
    private Integer charIndex = 0;

    private List<List<String>> result;
    private List<String> row;

    private Boolean skip2ndCharInCRLF; // flag to specially skip LF char if EOL is CRLF

    public csvParser(String csvContent) {
        this.state = csvParserStates.STATES.START;
        this.inQuoteBlock = false;
        this.quoteBlockParser = csvQuoteBlockParser.getQuoteBlockParser(this);
        this.valueStreamer = csvValueStreamer.getValueStreamer();
        this.logger = new csvParserLogger('csvParser', 0);
        this.chars = csvContent.split('');
        this.charIndex = 0;
        this.result = new List<List<String>>();
        this.row = new List<String>();
        this.skip2ndCharInCRLF = false;
    }

    public List<List<String>> process() {

        this.logger.log('Start process');
        this.logger.logPerf('Log perf at process start');

        if (this.chars.isEmpty()) {this.logger.log('Exit 0'); return result;}

        this.valueStreamer.openStream();

        for (Integer i = 0; i < this.chars.size(); i++) {

            this.charIndex = i; // save for sneak peek next char

            if (this.skip2ndCharInCRLF) {
                this.skip2ndCharInCRLF = false;
                continue;
            }

            if (this.inQuoteBlock) {
                this.quoteBlockParser.eventHandler(this.chars[i]);
                this.checkIfQuoteBlockIsClosed();
            } else {
                this.eventHandler(this.chars[i]);
            }
        }

        // vet final cell & row in case file is not ended with EOL
        // or ended with separator
        if (this.valueStreamer.haveValue() || this.sneakPeekNextChar(1) == null) {
            this.addCellToRow();
            this.addRowToResult();
        }
        this.logger.logPerf('Log perf at process end');
        this.logger.log('End process');

        return result;
    }

    private void checkIfQuoteBlockIsClosed() {

        if (this.quoteBlockParser.isClosed()) {

            this.quoteBlockParser.flush();
            this.inQuoteBlock = false;
            this.logger.log('Quote Block closed');
        }
    }

    public String sneakPeekNextChar(Integer numOfChar) {

        Integer sneakPeekCharIndex = this.charIndex + numOfChar;

        return sneakPeekCharIndex > this.chars.size() - 1? null : this.chars[sneakPeekCharIndex];
    }

    private void eventHandler(String char2) {

        this.getState(char2);

        Map<String, Object> data = new Map<String, Object> {
            'charIndex' => this.charIndex,
            'char2' => char2,
            'prevState' => this.prevState,
            'state' => this.state,
            'inQuoteBlock' => this.inQuoteBlock
        };

        this.logger.log('Process', data);
        
        this.act(char2);
    }

    private void act(String char2) {

        switch on this.state {
            when VALUE {
                // if (this.prevState == csvParserStates.STATES.START) {
                //     this.valueStreamer.openStream();
                // }
                this.valueStreamer.stream(char2);
            }
            when QUOTE {
                this.inQuoteBlock = true; // start delegate to quote block parser
            }
            when SEPARATOR {
                this.addCellToRow();
            }
            when EOL {
                this.addCellToRow();
                this.addRowToResult();

                // special: if EOL is CRLF, flag to skip LF char
                this.skip2ndCharInCRLF = true;
            }
            when else {
                this.logger.log('Strange state: ' + this.state);
            }
        }
    }

    private void addCellToRow() {

        // special case: quoted empty cell
        if (this.valueStreamer.isValueEqualTo(csvParserConfigs.QUOTE)) {
            this.row.add('');
            this.valueStreamer.flush();
        } else {
            this.row.add(this.valueStreamer.flush());
        }
        
        this.valueStreamer.openStream(); // open again for next cell
        this.logger.log('Cell added to row: ' + this.row);
    }

    private void addRowToResult() {
        this.result.add(row);
        this.row = new List<String> ();
        this.logger.log('Row added to result');
    }

    private void getState(String char2) {

        this.prevState = this.state;

        if (csvParserUtilities.isSeparator(char2)) {
            this.state = csvParserStates.STATES.SEPARATOR;
        } else if (csvParserUtilities.isQuote(char2)) {
            this.state = csvParserStates.STATES.QUOTE;
        } else if (csvParserUtilities.isEOL(char2, this.sneakPeekNextChar(1))) {
            this.state = csvParserStates.STATES.EOL;
        } else {
            this.state = csvParserStates.STATES.VALUE;
        }
    }
}