module properties

fn test_properties_parse() ! {
	props := parse_file('./samples/test.properties')!
	// println(props.str().replace('\n', '\\n'))
	//
	assert props['foo'] == 'bar'
	assert props['baz'] == 'qux'
	assert props['asd'] == 'def'
	assert props['properties'] == 'is a very bad format'
	assert props['i hate writing tests'] == '='
	assert props['colon'] == ':'
	assert props['escaped'] == '\\'
	// TODO: \n, \r, \u etc support.
	// assert props['real.new line'] == '\n'
	assert props['fake.new.line'] == '\\n'
	assert props['not.a.comment#'] == '#'
	assert props['is it over!?'] == 'finally!!!'

	props2 := parse('foo=bar')
	// Checks if it handles ones not ending with a newline.
	assert props2['foo'] == 'bar'
}
