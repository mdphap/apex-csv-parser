public with sharing class csvValueStreamer {

    private static csvValueStreamer singleton;
    public static csvValueStreamer getValueStreamer() {

        if (singleton == null) {
            singleton = new csvValueStreamer();
        }

        return singleton;
    }
    private csvParserLogger logger;

    private class csvValueStreamerException extends Exception {}
    private String result;
    private Boolean streamOpen = false;

    private csvValueStreamer() {
        this.logger = new csvParserLogger('csvValueStreamer');
    }

    public void openStream() {
        
        if (this.streamOpen) {
            csvValueStreamerException e = new csvValueStreamerException();
            e.setMessage('Stream is already opened');
            throw e;
        }
        this.result = '';
        this.streamOpen = true;
    }

    public void openStream(String char2) {
        this.openStream();
        this.stream(char2);
    }

    public void stream(String char2) {
        if (!this.streamOpen) {
            csvValueStreamerException e = new csvValueStreamerException();
            e.setMessage('Cannot write when stream is closed');
            throw e;
        }
        result += char2;
    }

    public String flush() {
        String resultToFlush = this.result;
        this.result = '';
        this.streamOpen = false;
        // this.logger.log('Flush value: ' + resultToFlush);
        return resultToFlush;
    }

    public Boolean isStreamOpen() {
        return this.streamOpen;
    }

    public Boolean haveValue() {
        return String.isNotBlank(this.result);
    }

    public Boolean isValueEqualTo(String char2) {

        if (String.isBlank(char2)) {return false;}
        
        return char2.equals(this.result);
    }
}