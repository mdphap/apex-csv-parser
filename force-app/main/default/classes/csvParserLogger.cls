/**
 * Lightweight logger utility for CSV parser components.
 *
 * <p>Logging output is controlled by `csvParserConfigs.VERBOSE` and can include
 * optional structured payloads as JSON, indentation by nesting level, and basic
 * runtime performance counters.</p>
 */
public with sharing class csvParserLogger {

    private String tag;
    private Integer lvl;
    private String indentation = '';

    @TestVisible
    private Boolean throwException = false; // flag to help test exception method
    
    /**
     * Creates a logger with no indentation level.
     *
     * @param tag Tag label printed in log lines to identify the caller/component.
     */
    public csvParserLogger(String tag) {
        this.tag = tag;
        this.lvl = 0;
    }

    /**
     * Creates a logger with a specific indentation level.
     *
     * @param tag Tag label printed in log lines to identify the caller/component.
     * @param lvl Indentation level used to prefix log output.
     */
    public csvParserLogger(String tag, Integer lvl) {
        this.tag = tag;
        this.lvl = lvl;
        this.indentation = '-'.repeat(this.lvl);
    }

    /**
     * Writes a log message with optional structured data.
     *
     * <p>When verbose mode is disabled, the method exits without emitting logs.</p>
     *
     * @param message Main log message.
     * @param data Optional key/value payload serialized to JSON for debugging context.
     */
    public void log(String message, Map<String, Object> data) {
        try {

            if(Test.isRunningTest() && throwException) {throw new AuraHandledException('sample');}

            if (!csvParserConfigs.VERBOSE) { return; }
            String dataToPrint = data != null? JSON.serialize(data) : '';

            System.debug(
                String.format('[0] [{1}] {2} {3}', new List<String> {
                    this.indentation,
                    this.tag,
                    message, 
                    dataToPrint})
            );
        } catch (Exception e) {
            this.logException(e);
        }
        
    }

    /**
     * Writes a log message without additional payload data.
     *
     * <p>When verbose mode is disabled, the method exits without emitting logs.</p>
     *
     * @param message Main log message.
     */
    public void log(String message) {
        try {
            if(Test.isRunningTest() && throwException) {throw new AuraHandledException('sample');}
            
            if (!csvParserConfigs.VERBOSE) { return; }
            System.debug(
                String.format('[0] [{1}] {2}', new List<String> {
                    this.indentation,
                    this.tag,
                    message})
            );
        } catch (Exception e) {
            this.logException(e);
        }
    }

    /**
     * Logs current CPU and heap usage versus governor limits.
     *
     * <p>Metrics are emitted only when verbose mode is enabled.</p>
     */
    public void logPerf(String message) {

        if (!csvParserConfigs.VERBOSE) { return; }

        String cpuLog = String.format('{0} / {1}', new List<String> {
            String.valueOf(Limits.getCpuTime()),
            String.valueOf(Limits.getLimitCpuTime())
        });

        String memoryLog = String.format('{0} / {1}', new List<String> {
            String.valueOf(Limits.getHeapSize()),
            String.valueOf(Limits.getLimitHeapSize())
        });

        System.debug(message);
        System.debug('[CPU LIM] ' + cpuLog);
        System.debug('[MEM LIM] ' + memoryLog);
    }

    /**
     * Logs exception details to debug output.
     *
     * @param e Exception instance to log.
     */
    @TestVisible
    private void logException(Exception e) {
        System.debug('[csvParserLogger] Exception Message: ' + e.getMessage());
        System.debug('[csvParserLogger] Exception Stack: ' + e.getStackTraceString());
    }
}