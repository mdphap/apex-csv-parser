@IsTest
private class csvParserTest {

    @IsTest
    private static void readSingleNormalRow() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;VAL2;VAL3';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(
            new List<String>{'COL1', 'COL2', 'COL3'},
            result[0],
            'Simple semicolon-separated values should be parsed in order.'
        );

        System.assertEquals(
            new List<String>{'VAL1', 'VAL2', 'VAL3'},
            result[1],
            'Simple semicolon-separated values should be parsed in order.'
        );
    }

    @IsTest
    private static void readRowWithSeparatorInsideQuoteBlock() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;VAL2;"VAL3; VAL4"';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', 'VAL2', 'VAL3; VAL4'}, result[1]);
    }

    // TODO: enhance new line splitter
    @IsTest
    private static void readRowWithQuoteBlockContainsCRLF() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;VAL2;"VAL3 \r\n VAL4"';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', 'VAL2', 'VAL3 \r\n VAL4'}, result[1]);
    }

    @IsTest
    private static void readRowWithEscapedDoubleQuoteInsideQuoteBlock() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;VAL2;"He said ""Hello"""';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', 'VAL2', 'He said "Hello"'}, result[1]);
    }

    @IsTest
    private static void readRowWithEmptyField() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;;"VAL3"';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', '', 'VAL3'}, result[1]);
    }

    @IsTest
    private static void readRowWithEmptyQuotedField() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;"";"VAL3"';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', '', 'VAL3'}, result[1]);
    }

    @IsTest
    private static void readRowWithTrailingEmptyField() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;VAL2;';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', 'VAL2', ''}, result[1]);
    }

    @IsTest
    private static void readRowWithLeadingTrailingSpace() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;VAL2; VAL3 ';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', 'VAL2', ' VAL3 '}, result[1]);
    }

    @IsTest
    private static void readRowWithLeadingTrailingSpaceInQuoteBlock() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;VAL2;" VAL3 "';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', 'VAL2', ' VAL3 '}, result[1]);
    }

    @IsTest
    private static void readRowWithAllFieldsQuoted() {

        String csvContent = '"COL1";"COL2";"COL3"\r\n';
        csvContent += '"VAL1";"VAL2";"VAL3"';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', 'VAL2', 'VAL3'}, result[1]);
    }

    @IsTest
    private static void readRowWithMixQuoteAndUnquoteField() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;"VAL2,2";VAL3';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', 'VAL2,2', 'VAL3'}, result[1]);
    }

    @IsTest
    private static void readRowWithUnicodeChar() {

        String csvContent = 'COL1;COL2;COL3\r\n';
        csvContent += 'VAL1;告不象;VAL3';

        csvParser parser = new csvParser(csvContent);

        Test.startTest();
            List<List<String>> result = parser.process();
        Test.stopTest();

        System.assertEquals(2, result.size());

        System.assertEquals(new List<String>{'COL1', 'COL2', 'COL3'}, result[0]);

        System.assertEquals(new List<String>{'VAL1', '告不象', 'VAL3'}, result[1]);
    }

    @IsTest
    private static void testException_duplicateValueStramOpen()
    {
        csvValueStreamer streamer = csvValueStreamer.getValueStreamer();
        streamer.openStream();
        streamer.stream('sample');

        try {
            streamer.openStream();
        } catch (Exception e) {
            
        }
        System.Assert.isTrue(streamer.isStreamOpen());
        System.Assert.areEqual('sample', streamer.flush());
    }

    @IsTest
    private static void testException_loggerException()
    {
        csvParserLogger logger = new csvParserLogger('sample');
        logger.throwException = true;

        try {
            logger.log('sample');
            logger.log('sample', new Map<String, Object>());
            logger.logPerf();
        } catch (Exception e) {
            
        }
        System.Assert.isNotNull(logger);
    }

    @IsTest
    private static void testParserConfigMethods() {
        csvParserConfigs.setSeparator(',');
        System.Assert.areEqual(',', csvParserConfigs.SEP);

        csvParserConfigs.setQuote('');
        System.Assert.areEqual('', csvParserConfigs.QUOTE);

        csvParserConfigs.setEolStyle(csvParserConfigs.EOL.LF);
        System.Assert.areEqual('\n', csvParserConfigs.EOL_CHAR);

        csvParserConfigs.setVerbose(true);
        System.Assert.isTrue(csvParserConfigs.VERBOSE);
    }

    @IsTest
    private static void testParserStatesConstructor() {
        csvParserStates states = new csvParserStates();
        System.Assert.isNotNull(states);
    }
}